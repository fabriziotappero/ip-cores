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
// CREATED		"Fri Nov 07 10:28:37 2014"

module reg_latch(
	we,
	oe,
	clk,
	db
);


input wire	we;
input wire	oe;
input wire	clk;
inout wire	[7:0] db;

reg	[7:0] latch;




assign	db[7] = oe ? latch[7] : 1'bz;
assign	db[6] = oe ? latch[6] : 1'bz;
assign	db[5] = oe ? latch[5] : 1'bz;
assign	db[4] = oe ? latch[4] : 1'bz;
assign	db[3] = oe ? latch[3] : 1'bz;
assign	db[2] = oe ? latch[2] : 1'bz;
assign	db[1] = oe ? latch[1] : 1'bz;
assign	db[0] = oe ? latch[0] : 1'bz;


always@(posedge clk)
begin
if (we)
	begin
	latch[7:0] <= db[7:0];
	end
end


endmodule
