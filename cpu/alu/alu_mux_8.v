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
// CREATED		"Mon Oct 13 12:04:13 2014"

module alu_mux_8(
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	sel,
	out
);


input wire	in0;
input wire	in1;
input wire	in2;
input wire	in3;
input wire	in4;
input wire	in5;
input wire	in6;
input wire	in7;
input wire	[2:0] sel;
output wire	out;

wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;




assign	SYNTHESIZED_WIRE_12 = SYNTHESIZED_WIRE_20 & SYNTHESIZED_WIRE_21 & SYNTHESIZED_WIRE_22 & in0;

assign	SYNTHESIZED_WIRE_14 = sel[0] & SYNTHESIZED_WIRE_21 & SYNTHESIZED_WIRE_22 & in1;

assign	SYNTHESIZED_WIRE_13 = SYNTHESIZED_WIRE_20 & sel[1] & SYNTHESIZED_WIRE_22 & in2;

assign	SYNTHESIZED_WIRE_15 = sel[0] & sel[1] & SYNTHESIZED_WIRE_22 & in3;

assign	SYNTHESIZED_WIRE_17 = SYNTHESIZED_WIRE_20 & SYNTHESIZED_WIRE_21 & sel[2] & in4;

assign	SYNTHESIZED_WIRE_16 = sel[0] & SYNTHESIZED_WIRE_21 & sel[2] & in5;

assign	SYNTHESIZED_WIRE_18 = SYNTHESIZED_WIRE_20 & sel[1] & sel[2] & in6;

assign	SYNTHESIZED_WIRE_19 = sel[0] & sel[1] & sel[2] & in7;

assign	out = SYNTHESIZED_WIRE_12 | SYNTHESIZED_WIRE_13 | SYNTHESIZED_WIRE_14 | SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16 | SYNTHESIZED_WIRE_17 | SYNTHESIZED_WIRE_18 | SYNTHESIZED_WIRE_19;

assign	SYNTHESIZED_WIRE_20 =  ~sel[0];

assign	SYNTHESIZED_WIRE_21 =  ~sel[1];

assign	SYNTHESIZED_WIRE_22 =  ~sel[2];


endmodule
