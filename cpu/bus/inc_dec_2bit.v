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
// CREATED		"Mon Oct 13 12:26:57 2014"

module inc_dec_2bit(
	carry_borrow_in,
	d1_in,
	d0_in,
	dec1_in,
	dec0_in,
	carry_borrow_out,
	d1_out,
	d0_out
);


input wire	carry_borrow_in;
input wire	d1_in;
input wire	d0_in;
input wire	dec1_in;
input wire	dec0_in;
output wire	carry_borrow_out;
output wire	d1_out;
output wire	d0_out;

wire	SYNTHESIZED_WIRE_0;




assign	SYNTHESIZED_WIRE_0 = dec0_in & carry_borrow_in;

assign	carry_borrow_out = dec0_in & dec1_in & carry_borrow_in;

assign	d1_out = d1_in ^ SYNTHESIZED_WIRE_0;

assign	d0_out = carry_borrow_in ^ d0_in;


endmodule
