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
// CREATED		"Mon Oct 13 12:39:04 2014"

module bus_control(
	ctl_bus_ff_oe,
	ctl_bus_zero_oe,
	ctl_bus_db_oe,
	bus_db_oe,
	db
);


input wire	ctl_bus_ff_oe;
input wire	ctl_bus_zero_oe;
input wire	ctl_bus_db_oe;
output wire	bus_db_oe;
inout wire	[7:0] db;

wire	[7:0] bus;
wire	[7:0] vcc;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_2;




assign	db[7] = SYNTHESIZED_WIRE_3 ? bus[7] : 1'bz;
assign	db[6] = SYNTHESIZED_WIRE_3 ? bus[6] : 1'bz;
assign	db[5] = SYNTHESIZED_WIRE_3 ? bus[5] : 1'bz;
assign	db[4] = SYNTHESIZED_WIRE_3 ? bus[4] : 1'bz;
assign	db[3] = SYNTHESIZED_WIRE_3 ? bus[3] : 1'bz;
assign	db[2] = SYNTHESIZED_WIRE_3 ? bus[2] : 1'bz;
assign	db[1] = SYNTHESIZED_WIRE_3 ? bus[1] : 1'bz;
assign	db[0] = SYNTHESIZED_WIRE_3 ? bus[0] : 1'bz;


assign	bus = {ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe,ctl_bus_ff_oe} & vcc;

assign	SYNTHESIZED_WIRE_2 =  ~SYNTHESIZED_WIRE_3;

assign	bus_db_oe = ctl_bus_db_oe & SYNTHESIZED_WIRE_2;

assign	SYNTHESIZED_WIRE_3 = ctl_bus_ff_oe | ctl_bus_zero_oe;

assign	vcc = 8'b11111111;

endmodule
