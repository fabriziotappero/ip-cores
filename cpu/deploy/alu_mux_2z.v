// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Fri Oct 31 21:18:33 2014"

module alu_mux_2z(
	sel_a,
	sel_zero,
	a,
	ena,
	Q
);


input wire	sel_a;
input wire	sel_zero;
input wire	[3:0] a;
output wire	ena;
output wire	[3:0] Q;

wire	[3:0] SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;




assign	SYNTHESIZED_WIRE_0 = a & {sel_a,sel_a,sel_a,sel_a};

assign	ena = sel_a | sel_zero;

assign	Q = SYNTHESIZED_WIRE_0 & {SYNTHESIZED_WIRE_1,SYNTHESIZED_WIRE_1,SYNTHESIZED_WIRE_1,SYNTHESIZED_WIRE_1};

assign	SYNTHESIZED_WIRE_1 =  ~sel_zero;


endmodule
