`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   BMSTU
// Engineer:  Oleg Odintsov
// 
// Create Date:    15:09:47 01/19/2012 
// Design Name: 
// Module Name:    ag_main
// Project Name:    Agat Hardware Project
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

module ROM2kx8(input CLK, input[10:0] AB, input CS, output[7:0] DO);
	reg[7:0] mem[0:2047];
	reg[7:0] R;
	assign DO = CS? R: 8'bZ;
	always @(posedge CLK) if (CS) R <= mem[AB];
	initial begin
		`include "monitor7.v"
	end
endmodule

module ag_main(
    input clk50x,
	 input[3:0] btns,
	 input[3:0] switches,
	 output[7:0] leds,
	 output[3:0] controls,
	 output[4:0] vga_bus,
	 input[1:0] ps2_bus_in
    );

//	assign leds = 0;
//	assign controls = 0;
//	assign vga_bus = 0;
	
	wire clk1, clk1x, clk10, clk50;
	reg turbo = 0;
	BUFG bg1(clk50, clk50x);
	clk_div#5 cd5(clk50, clk10);
	clk_div#10 cd10(clk10, clk1x);
	BUFGMUX bgm1(clk1, clk1x, clk10, turbo);
//	assign clk1 = turbo?clk10:clk1x;

	
	wire clk_vram;
	wire[13:0] AB2;
	wire[15:0] DI2;
	
	wire [15:0] AB;	// address bus
	wire [7:0] DI;		// data in, read bus
	wire [7:0] DO;		// data out, write bus
	wire read;
	wire rom_cs, ram_cs;
	wire phi_1, phi_2;
	
	RAM32Kx8x16 base_ram(phi_2, AB[14:0], ram_cs, read, DI, DO, 
							clk_vram, AB2, 1, DI2);
	ROM2kx8 rom1(phi_2, AB[10:0], rom_cs, DI);
	
	wire [3:0] AB_HH = AB[15:12];
	wire [3:0] AB_HL = AB[11:8];
	wire [3:0] AB_LH = AB[7:4];
	wire [3:0] AB_LL = AB[3:0];
	wire [7:0] AB_H = AB[15:8];
	wire [7:0] AB_L = AB[7:0];
	wire AB_CXXX = (AB_HH == 4'hC);
	wire AB_FXXX = (AB_HH == 4'hF);
	
	wire AB_C0XX = AB_CXXX && !AB_HL;
	
	wire AB_C00X = AB_C0XX && (AB_LH == 4'h0);
	wire AB_C01X = AB_C0XX && (AB_LH == 4'h1);
	wire AB_C02X = AB_C0XX && (AB_LH == 4'h2);
	wire AB_C03X = AB_C0XX && (AB_LH == 4'h3);
	wire AB_C04X = AB_C0XX && (AB_LH == 4'h4);
	wire AB_C05X = AB_C0XX && (AB_LH == 4'h5);
	wire AB_C7XX = AB_CXXX && (AB_HL == 4'h7);

	reg timer_ints = 0;
	
	assign rom_cs = AB_FXXX && AB[11]; // F800-FFFF
	assign ram_cs = !AB[15];
	

	reg reset_auto = 1;
	wire reset;
	wire WE = ~read;		// write enable
	supply0 IRQ;		// interrupt request
	wire NMI;		// non-maskable interrupt request
	supply1 RDY;		// Ready signal. Pauses CPU when RDY=0 
	supply1 SO;			// Set Overflow, not used.
	wire SYNC;
	
	
	assign NMI = timer_ints & vga_bus[0];
	
	reg[7:0] vmode = 0;
	wire[7:0] key_reg;
	wire key_rus;
	reg key_clear = 0;
	wire key_rst, key_pause;
	
	reg beep_reg = 0, tape_out_reg = 0;
	

	assign reset  = btns[0];
	assign leds = AB[11:4];
	assign controls = {1'b0, beep_reg ^ tape_out_reg, tape_out_reg, beep_reg};

	ag_video video(clk50, vmode, clk_vram, AB2, DI2, vga_bus);
	
	
	wire[1:0] ps2_bus;
	
	signal_filter sf1(clk1, ps2_bus_in[0], ps2_bus[0]);
	signal_filter sf2(clk1, ps2_bus_in[1], ps2_bus[1]);


	ag_keyb keyb(phi_2, ps2_bus, key_reg, key_clear, key_rus, key_rst, key_pause);
	
	assign DI = (AB_C00X && !WE)?key_reg:8'bZ;
	wire reset_all = reset | reset_auto | key_rst;
	
	always @(posedge phi_2) begin
		turbo <= switches[0];
		key_clear <= AB_C01X;
		if (AB_C04X) timer_ints <= 1;
		else if (AB_C05X || reset_all) timer_ints <= 0;

		if (AB_C02X) tape_out_reg <= ~tape_out_reg;
		if (AB_C03X) beep_reg <= ~beep_reg;
		if (AB_C7XX) vmode <= AB_L;
	end
	always @(posedge vga_bus[0]) begin
		reset_auto <= 0;
	end
	
	ag6502_ext_clock clk(clk50, clk1, phi_1, phi_2);
	ag6502 cpu(clk1, phi_1, phi_2, AB, read, DI, DO, 
					RDY & ~key_pause, ~reset_all, ~IRQ, ~NMI, SO, SYNC);

endmodule
