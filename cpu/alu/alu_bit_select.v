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
// CREATED		"Mon Oct 13 12:21:31 2014"

module alu_bit_select(
	bsel,
	bs_out_high,
	bs_out_low
);


input wire	[2:0] bsel;
output wire	[3:0] bs_out_high;
output wire	[3:0] bs_out_low;

wire	[3:0] bs_out_high_ALTERA_SYNTHESIZED;
wire	[3:0] bs_out_low_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;




assign	bs_out_low_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_12 & SYNTHESIZED_WIRE_13 & SYNTHESIZED_WIRE_14;

assign	bs_out_low_ALTERA_SYNTHESIZED[1] = bsel[0] & SYNTHESIZED_WIRE_13 & SYNTHESIZED_WIRE_14;

assign	bs_out_low_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_12 & bsel[1] & SYNTHESIZED_WIRE_14;

assign	bs_out_low_ALTERA_SYNTHESIZED[3] = bsel[0] & bsel[1] & SYNTHESIZED_WIRE_14;

assign	bs_out_high_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_12 & SYNTHESIZED_WIRE_13 & bsel[2];

assign	bs_out_high_ALTERA_SYNTHESIZED[1] = bsel[0] & SYNTHESIZED_WIRE_13 & bsel[2];

assign	bs_out_high_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_12 & bsel[1] & bsel[2];

assign	bs_out_high_ALTERA_SYNTHESIZED[3] = bsel[0] & bsel[1] & bsel[2];

assign	SYNTHESIZED_WIRE_12 =  ~bsel[0];

assign	SYNTHESIZED_WIRE_13 =  ~bsel[1];

assign	SYNTHESIZED_WIRE_14 =  ~bsel[2];

assign	bs_out_high = bs_out_high_ALTERA_SYNTHESIZED;
assign	bs_out_low = bs_out_low_ALTERA_SYNTHESIZED;

endmodule
