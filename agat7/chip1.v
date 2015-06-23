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



module chip1(
	 input clk,
    input b1,
    input b2,
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
	 
	 
//	 assign j4 = 0, vga_bus = 0;
	 
	 wire[3:0] btns = {0, 0, b2, b1};
	 ag_main agate(clk, btns, SW, led, j4, vga_bus, ps2_bus);
	 
endmodule
