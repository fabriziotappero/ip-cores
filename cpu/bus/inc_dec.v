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
// CREATED		"Mon Oct 13 12:30:20 2014"

module inc_dec(
	carry_in,
	limit6,
	decrement,
	d,
	address
);


input wire	carry_in;
input wire	limit6;
input wire	decrement;
input wire	[15:0] d;
output wire	[15:0] address;

wire	[15:0] address_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_40;
wire	SYNTHESIZED_WIRE_41;
wire	SYNTHESIZED_WIRE_42;
wire	SYNTHESIZED_WIRE_43;
wire	SYNTHESIZED_WIRE_44;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_45;
wire	SYNTHESIZED_WIRE_46;
wire	SYNTHESIZED_WIRE_47;
wire	SYNTHESIZED_WIRE_48;
wire	SYNTHESIZED_WIRE_49;
wire	SYNTHESIZED_WIRE_50;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_51;
wire	SYNTHESIZED_WIRE_52;
wire	SYNTHESIZED_WIRE_53;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_31;
wire	SYNTHESIZED_WIRE_34;
wire	SYNTHESIZED_WIRE_35;
wire	SYNTHESIZED_WIRE_36;
wire	SYNTHESIZED_WIRE_37;
wire	SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_39;




assign	SYNTHESIZED_WIRE_34 = carry_in & SYNTHESIZED_WIRE_40 & SYNTHESIZED_WIRE_41 & SYNTHESIZED_WIRE_42 & SYNTHESIZED_WIRE_43 & SYNTHESIZED_WIRE_44 & SYNTHESIZED_WIRE_5 & SYNTHESIZED_WIRE_45;

assign	SYNTHESIZED_WIRE_51 = SYNTHESIZED_WIRE_46 & SYNTHESIZED_WIRE_47 & SYNTHESIZED_WIRE_48 & SYNTHESIZED_WIRE_49 & SYNTHESIZED_WIRE_50 & SYNTHESIZED_WIRE_12;

assign	SYNTHESIZED_WIRE_38 = SYNTHESIZED_WIRE_51 & SYNTHESIZED_WIRE_52 & SYNTHESIZED_WIRE_53 & SYNTHESIZED_WIRE_16;


inc_dec_2bit	b2v_dual_adder_0(
	.carry_borrow_in(carry_in),
	.d1_in(d[1]),
	.d0_in(d[0]),
	.dec1_in(SYNTHESIZED_WIRE_40),
	.dec0_in(SYNTHESIZED_WIRE_41),
	.carry_borrow_out(SYNTHESIZED_WIRE_22),
	.d1_out(address_ALTERA_SYNTHESIZED[1]),
	.d0_out(address_ALTERA_SYNTHESIZED[0]));


inc_dec_2bit	b2v_dual_adder_10(
	.carry_borrow_in(SYNTHESIZED_WIRE_51),
	.d1_in(d[13]),
	.d0_in(d[12]),
	.dec1_in(SYNTHESIZED_WIRE_53),
	.dec0_in(SYNTHESIZED_WIRE_52),
	.carry_borrow_out(SYNTHESIZED_WIRE_37),
	.d1_out(address_ALTERA_SYNTHESIZED[13]),
	.d0_out(address_ALTERA_SYNTHESIZED[12]));


inc_dec_2bit	b2v_dual_adder_2(
	.carry_borrow_in(SYNTHESIZED_WIRE_22),
	.d1_in(d[3]),
	.d0_in(d[2]),
	.dec1_in(SYNTHESIZED_WIRE_45),
	.dec0_in(SYNTHESIZED_WIRE_42),
	.carry_borrow_out(SYNTHESIZED_WIRE_25),
	.d1_out(address_ALTERA_SYNTHESIZED[3]),
	.d0_out(address_ALTERA_SYNTHESIZED[2]));


inc_dec_2bit	b2v_dual_adder_4(
	.carry_borrow_in(SYNTHESIZED_WIRE_25),
	.d1_in(d[5]),
	.d0_in(d[4]),
	.dec1_in(SYNTHESIZED_WIRE_43),
	.dec0_in(SYNTHESIZED_WIRE_44),
	.carry_borrow_out(SYNTHESIZED_WIRE_39),
	.d1_out(address_ALTERA_SYNTHESIZED[5]),
	.d0_out(address_ALTERA_SYNTHESIZED[4]));


inc_dec_2bit	b2v_dual_adder_7(
	.carry_borrow_in(SYNTHESIZED_WIRE_47),
	.d1_in(d[8]),
	.d0_in(d[7]),
	.dec1_in(SYNTHESIZED_WIRE_46),
	.dec0_in(SYNTHESIZED_WIRE_48),
	.carry_borrow_out(SYNTHESIZED_WIRE_31),
	.d1_out(address_ALTERA_SYNTHESIZED[8]),
	.d0_out(address_ALTERA_SYNTHESIZED[7]));


inc_dec_2bit	b2v_dual_adder_9(
	.carry_borrow_in(SYNTHESIZED_WIRE_31),
	.d1_in(d[10]),
	.d0_in(d[9]),
	.dec1_in(SYNTHESIZED_WIRE_50),
	.dec0_in(SYNTHESIZED_WIRE_49),
	.carry_borrow_out(SYNTHESIZED_WIRE_36),
	.d1_out(address_ALTERA_SYNTHESIZED[10]),
	.d0_out(address_ALTERA_SYNTHESIZED[9]));

assign	SYNTHESIZED_WIRE_47 = SYNTHESIZED_WIRE_34 & SYNTHESIZED_WIRE_35;

assign	SYNTHESIZED_WIRE_35 =  ~limit6;

assign	SYNTHESIZED_WIRE_41 = d[0] ^ decrement;

assign	SYNTHESIZED_WIRE_40 = d[1] ^ decrement;

assign	SYNTHESIZED_WIRE_50 = d[10] ^ decrement;

assign	SYNTHESIZED_WIRE_12 = d[11] ^ decrement;

assign	address_ALTERA_SYNTHESIZED[11] = SYNTHESIZED_WIRE_36 ^ d[11];

assign	SYNTHESIZED_WIRE_52 = d[12] ^ decrement;

assign	SYNTHESIZED_WIRE_53 = d[13] ^ decrement;

assign	SYNTHESIZED_WIRE_16 = d[14] ^ decrement;

assign	address_ALTERA_SYNTHESIZED[14] = SYNTHESIZED_WIRE_37 ^ d[14];

assign	address_ALTERA_SYNTHESIZED[15] = SYNTHESIZED_WIRE_38 ^ d[15];

assign	SYNTHESIZED_WIRE_42 = d[2] ^ decrement;

assign	SYNTHESIZED_WIRE_45 = d[3] ^ decrement;

assign	SYNTHESIZED_WIRE_44 = d[4] ^ decrement;

assign	SYNTHESIZED_WIRE_43 = d[5] ^ decrement;

assign	SYNTHESIZED_WIRE_5 = d[6] ^ decrement;

assign	address_ALTERA_SYNTHESIZED[6] = SYNTHESIZED_WIRE_39 ^ d[6];

assign	SYNTHESIZED_WIRE_48 = d[7] ^ decrement;

assign	SYNTHESIZED_WIRE_46 = d[8] ^ decrement;

assign	SYNTHESIZED_WIRE_49 = d[9] ^ decrement;

assign	address = address_ALTERA_SYNTHESIZED;

endmodule
