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
// CREATED		"Mon Oct 13 11:55:31 2014"

module alu_shifter_core(
	shift_in,
	shift_right,
	shift_left,
	db,
	shift_db0,
	shift_db7,
	out_high,
	out_low
);


input wire	shift_in;
input wire	shift_right;
input wire	shift_left;
input wire	[7:0] db;
output wire	shift_db0;
output wire	shift_db7;
output wire	[3:0] out_high;
output wire	[3:0] out_low;

wire	[3:0] out_high_ALTERA_SYNTHESIZED;
wire	[3:0] out_low_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_32;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;
wire	SYNTHESIZED_WIRE_29;
wire	SYNTHESIZED_WIRE_30;
wire	SYNTHESIZED_WIRE_31;

assign	shift_db0 = db[0];
assign	shift_db7 = db[7];



assign	SYNTHESIZED_WIRE_9 = shift_in & shift_left;

assign	SYNTHESIZED_WIRE_8 = db[0] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_10 = db[1] & shift_right;

assign	SYNTHESIZED_WIRE_12 = db[0] & shift_left;

assign	SYNTHESIZED_WIRE_11 = db[1] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_13 = db[2] & shift_right;

assign	SYNTHESIZED_WIRE_15 = db[1] & shift_left;

assign	SYNTHESIZED_WIRE_14 = db[2] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_16 = db[3] & shift_right;

assign	SYNTHESIZED_WIRE_18 = db[2] & shift_left;

assign	SYNTHESIZED_WIRE_17 = db[3] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_19 = db[4] & shift_right;

assign	SYNTHESIZED_WIRE_21 = db[3] & shift_left;

assign	SYNTHESIZED_WIRE_20 = db[4] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_22 = db[5] & shift_right;

assign	SYNTHESIZED_WIRE_24 = db[4] & shift_left;

assign	SYNTHESIZED_WIRE_23 = db[5] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_25 = db[6] & shift_right;

assign	SYNTHESIZED_WIRE_27 = db[5] & shift_left;

assign	SYNTHESIZED_WIRE_26 = db[6] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_28 = db[7] & shift_right;

assign	SYNTHESIZED_WIRE_30 = db[6] & shift_left;

assign	SYNTHESIZED_WIRE_29 = db[7] & SYNTHESIZED_WIRE_32;

assign	SYNTHESIZED_WIRE_31 = shift_in & shift_right;

assign	SYNTHESIZED_WIRE_32 = ~(shift_right | shift_left);

assign	out_low_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_8 | SYNTHESIZED_WIRE_9 | SYNTHESIZED_WIRE_10;

assign	out_low_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_11 | SYNTHESIZED_WIRE_12 | SYNTHESIZED_WIRE_13;

assign	out_low_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_14 | SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16;

assign	out_low_ALTERA_SYNTHESIZED[3] = SYNTHESIZED_WIRE_17 | SYNTHESIZED_WIRE_18 | SYNTHESIZED_WIRE_19;

assign	out_high_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_20 | SYNTHESIZED_WIRE_21 | SYNTHESIZED_WIRE_22;

assign	out_high_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_23 | SYNTHESIZED_WIRE_24 | SYNTHESIZED_WIRE_25;

assign	out_high_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_26 | SYNTHESIZED_WIRE_27 | SYNTHESIZED_WIRE_28;

assign	out_high_ALTERA_SYNTHESIZED[3] = SYNTHESIZED_WIRE_29 | SYNTHESIZED_WIRE_30 | SYNTHESIZED_WIRE_31;

assign	out_high = out_high_ALTERA_SYNTHESIZED;
assign	out_low = out_low_ALTERA_SYNTHESIZED;

endmodule
