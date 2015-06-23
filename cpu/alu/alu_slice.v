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
// CREATED		"Mon Oct 13 11:51:12 2014"

module alu_slice(
	op2,
	op1,
	cy_in,
	R,
	S,
	V,
	cy_out,
	result
);


input wire	op2;
input wire	op1;
input wire	cy_in;
input wire	R;
input wire	S;
input wire	V;
output wire	cy_out;
output wire	result;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;




assign	SYNTHESIZED_WIRE_0 = op2 | cy_in | op1;

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_0 & SYNTHESIZED_WIRE_1;

assign	SYNTHESIZED_WIRE_4 = cy_in & op2 & op1;

assign	result =  ~SYNTHESIZED_WIRE_2;

assign	SYNTHESIZED_WIRE_2 = ~(SYNTHESIZED_WIRE_3 | SYNTHESIZED_WIRE_4);

assign	SYNTHESIZED_WIRE_5 = op2 | op1;

assign	SYNTHESIZED_WIRE_7 = cy_in & SYNTHESIZED_WIRE_5;

assign	SYNTHESIZED_WIRE_8 = op1 & op2;

assign	cy_out = ~(R | SYNTHESIZED_WIRE_10);

assign	SYNTHESIZED_WIRE_10 = ~(SYNTHESIZED_WIRE_7 | SYNTHESIZED_WIRE_8 | S);

assign	SYNTHESIZED_WIRE_1 = V | SYNTHESIZED_WIRE_10;


endmodule
