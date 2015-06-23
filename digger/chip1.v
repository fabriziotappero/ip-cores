`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   BMSTU
// Engineer:  Oleg Odintsov
// 
// Create Date:    18:21:00 01/17/2012 
// Design Name: 
// Project Name:    Agat Hardware Project
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////



module rot_driver(input clk,
				input rot_a, input rot_b, 
				output wire rot_dir, output wire rot_event_out);

	reg rot_a_latch = 0, rot_b_latch = 0;
	assign rot_dir = rot_b_latch, rot_event_out = rot_a_latch;
	always @(posedge clk) begin
		case ({rot_a, rot_b})
		2'b00: rot_a_latch <= 1;
		2'b11: rot_a_latch <= 0;
		2'b10: rot_b_latch <= 1;
		2'b01: rot_b_latch <= 0;
		endcase
	end
endmodule

module btn_driver(input clk, input btn, output reg sig = 0);
	parameter nskip = 'hfff;
	integer counter = 0;
	wire lock = counter?1:0;
	
	always @(posedge clk) begin
		if (counter) counter <= counter - 1;
		if (!lock && sig != btn) begin
			sig <= btn;
			counter <= nskip;
		end
	end
endmodule


module chip1(
	 input clk,
    input b1,
    input b2,
    input b3,
    input b4,
	 input[3:0] SW,
	 input rot_a, rot_b, rot_center,
    output[7:0] led,
    output vga_red,
    output vga_green,
    output vga_blue,
    output vga_hsync,
    output vga_vsync,
	 output [3:0]j4,
	 input spi_miso, output spi_mosi, output spi_sck, output dac_cs, output dac_clr,
	 output spi_rom_cs,
	 output spi_amp_cs,
	 output spi_adc_conv,
	 output strataflash_oe,
	 output strataflash_ce,
    output strataflash_we,
	 output platformflash_oe,
	 input  ps2_clk,
	 input  ps2_data
    );
	 
	 
			
	 // access to DAC
	 assign spi_mosi = 0, spi_sck = 0, dac_cs = 0, dac_clr = 0;
	 // block other devices to access to DAC
	 assign spi_rom_cs = 1, spi_amp_cs = 1, spi_adc_conv = 0;
	 assign strataflash_oe = 1, strataflash_ce = 1, strataflash_we = 1;
	 assign platformflash_oe = 0;

	 wire[4:0] vga_bus;
	 assign {vga_red, vga_green, vga_blue, vga_hsync, vga_vsync} = vga_bus;
	 wire[1:0] ps2_bus = {ps2_clk, ps2_data};
	 
	 wire rot_dir, rot_event;
	 
	 wire clk_cpu;
	 wire b1v, b2v, b3v, b4v, brc;
	 rot_driver rot(clk_cpu, rot_a, rot_b, rot_dir, rot_event);
	 btn_driver b1d(clk_cpu, b1, b1v);
	 btn_driver b2d(clk_cpu, b2, b2v);
	 btn_driver b3d(clk_cpu, b3, b3v);
	 btn_driver b4d(clk_cpu, b4, b4v);
	 btn_driver rrd(clk_cpu, rot_center, brc);
	 reg rot_v = 0;

	 always @(posedge rot_event) begin
		rot_v <= rot_dir;
	 end

	 
//	 assign j4 = 0, vga_bus = 0;
	 
	 wire[4:0] btns = {brc, b4v | (rot_event & ~rot_v), b3v, b2v, b1v | (rot_event & rot_v)};
	 ag_main agate(clk, btns, SW, led, j4, vga_bus, ps2_bus, clk_cpu);
	 
endmodule
