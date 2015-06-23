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
// CREATED		"Mon Oct 13 12:17:04 2014"

module alu_core(
	cy_in,
	S,
	V,
	R,
	op1,
	op2,
	cy_out,
	vf_out,
	result
);


input wire	cy_in;
input wire	S;
input wire	V;
input wire	R;
input wire	[3:0] op1;
input wire	[3:0] op2;
output wire	cy_out;
output wire	vf_out;
output wire	[3:0] result;

wire	[3:0] result_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_3;

assign	cy_out = SYNTHESIZED_WIRE_3;




alu_slice	b2v_alu_slice_bit_0(
	.cy_in(cy_in),
	.op1(op1[0]),
	.op2(op2[0]),
	.S(S),
	.V(V),
	.R(R),
	.result(result_ALTERA_SYNTHESIZED[0]),
	.cy_out(SYNTHESIZED_WIRE_0));


alu_slice	b2v_alu_slice_bit_1(
	.cy_in(SYNTHESIZED_WIRE_0),
	.op1(op1[1]),
	.op2(op2[1]),
	.S(S),
	.V(V),
	.R(R),
	.result(result_ALTERA_SYNTHESIZED[1]),
	.cy_out(SYNTHESIZED_WIRE_1));


alu_slice	b2v_alu_slice_bit_2(
	.cy_in(SYNTHESIZED_WIRE_1),
	.op1(op1[2]),
	.op2(op2[2]),
	.S(S),
	.V(V),
	.R(R),
	.result(result_ALTERA_SYNTHESIZED[2]),
	.cy_out(SYNTHESIZED_WIRE_5));


alu_slice	b2v_alu_slice_bit_3(
	.cy_in(SYNTHESIZED_WIRE_5),
	.op1(op1[3]),
	.op2(op2[3]),
	.S(S),
	.V(V),
	.R(R),
	.result(result_ALTERA_SYNTHESIZED[3]),
	.cy_out(SYNTHESIZED_WIRE_3));

assign	vf_out = SYNTHESIZED_WIRE_3 ^ SYNTHESIZED_WIRE_5;

assign	result = result_ALTERA_SYNTHESIZED;

endmodule
