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
// CREATED		"Sun Nov 09 09:13:38 2014"

module resets(
	reset_in,
	clk,
	M1,
	T2,
	fpga_reset,
	clrpc,
	nreset
);


input wire	reset_in;
input wire	clk;
input wire	M1;
input wire	T2;
input wire	fpga_reset;
output reg	clrpc;
output wire	nreset;

wire	nclk;
reg	x1;
wire	x2;
wire	x3;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_3;
reg	DFF_res;
wire	SYNTHESIZED_WIRE_6;

assign	nreset = SYNTHESIZED_WIRE_6;




always@(posedge nclk or negedge SYNTHESIZED_WIRE_8)
begin
if (!SYNTHESIZED_WIRE_8)
	begin
	x1 <= 1;
	end
else
	begin
	x1 <= ~x1 & reset_in | x1 & ~SYNTHESIZED_WIRE_1;
	end
end

assign	SYNTHESIZED_WIRE_1 =  ~reset_in;

assign	x2 = x1 & SYNTHESIZED_WIRE_9;

assign	SYNTHESIZED_WIRE_9 = M1 & T2;

assign	x3 = x1 & SYNTHESIZED_WIRE_3;

assign	SYNTHESIZED_WIRE_6 =  ~DFF_res;

assign	SYNTHESIZED_WIRE_3 =  ~SYNTHESIZED_WIRE_9;

assign	nclk =  ~clk;

assign	SYNTHESIZED_WIRE_8 =  ~fpga_reset;


always@(posedge clk or negedge SYNTHESIZED_WIRE_8)
begin
if (!SYNTHESIZED_WIRE_8)
	begin
	DFF_res <= 1;
	end
else
	begin
	DFF_res <= x3;
	end
end


always@(posedge nclk or negedge SYNTHESIZED_WIRE_6)
begin
if (!SYNTHESIZED_WIRE_6)
	begin
	clrpc <= 0;
	end
else
	begin
	clrpc <= ~clrpc & x2 | clrpc & ~SYNTHESIZED_WIRE_9;
	end
end


endmodule
