//---------------------------------------------------------------------------------------
//	Project:	light8080 SOC		WiCores Solutions 
// 
//	Filename:	tb_l80soc.v			(February 04, 2012)
// 
//	Author(s):	Moti Litochevski 
// 
//	Description:
//		This file implements the light8080 SOC test bench. 
//
//---------------------------------------------------------------------------------------
//
//	To Do: 
//	- 
// 
//---------------------------------------------------------------------------------------
// 
//	Copyright (C) 2012 Moti Litochevski 
// 
//	This source file may be used and distributed without restriction provided that this 
//	copyright statement is not removed from the file and that any derivative work 
//	contains the original copyright notice and the associated disclaimer.
//
//	THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, 
//	INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND 
//	FITNESS FOR A PARTICULAR PURPOSE. 
// 
//---------------------------------------------------------------------------------------

`timescale 1ns / 1ns

module test;
//---------------------------------------------------------------------------------------
// test bench global defines 
// the following define selects between CPU instruction trace and uart transmitted bytes 
//`define CPU_TRACE		1

//---------------------------------------------------------------------------------------
// internal signals 
reg clock;				// global clock 
reg reset;				// global reset 

// UUT interfaces 
wire rxd, txd;
wire [7:0] p1dio, p2dio;
wire [3:0] extint;
reg sp1dio0;

//---------------------------------------------------------------------------------------
// test bench implementation 
// global signals generation  
initial
begin
	clock = 0;
	reset = 1;
	#100 reset = 0;
end 

// clock generator - 50MHz clock 
always 
begin 
	#10 clock = 0;
	#10 clock = 1;
end 

// test bench dump variables 
initial 
begin 
	$display("");
	$display("  light8080 SOC simulation");
	$display("--------------------------------------");
	$dumpfile("test.vcd");
	$dumpvars(0, test);
	$display("");
end 

// simulation end condition 
always @ (posedge clock) 
begin 
	if (dut.cpu_io && (dut.cpu_addr[7:0] == 8'hff))
	begin 
		$display("");
		$display("Simulation ended by software");
		$finish;
	end 
end 

//------------------------------------------------------------------
// device under test 
l80soc dut 
(
	.clock(clock), 
	.reset(reset),
	.txd(txd), 
	.rxd(rxd),
	.p1dio(p1dio), 
	.p2dio(p2dio),
	.extint(extint) 
);

//------------------------------------------------------------------
// uart receive is not used in this test becnch 
assign rxd = 1'b1;

// external interrupt 0 is connected to the p1dio[0] rising edge 
assign extint[3:1] = 3'b0;
assign extint[0] = ((sp1dio0 == 1'b0) && (p1dio[0] == 1'b1)) ? 1'b1 : 1'b0;

// p1dio[0] rising edge detection 
always @ (posedge reset or posedge clock)
begin  
	if (reset) 
		sp1dio0 <= 1'b0;
	else if (p1dio[0] == 1'b1)
		sp1dio0 <= 1'b1;
	else 
		sp1dio0 <= 1'b0;
end 

//------------------------------------------------------------------
// test bench output log selection - either simple CPU trace or UART 
// transmit port log 
`ifdef CPU_TRACE 
// display executed instructions 
reg [15:0] saddr;
reg scpu_rd;
always @ (posedge clock) 
begin 
	if (dut.cpu.uc_decode) 
	begin 
		$display("");
		$write("%x : %x", saddr, dut.cpu.data_in);
	end 
	else if (scpu_rd) 
		$write("%x", dut.cpu.data_in);
	
	// sampled address bus and read pulse 
	saddr <= dut.cpu.addr_out;
	scpu_rd <= dut.cpu.rd;
end 
`else 
// display characters transmitted to the uart 
initial 
begin 
	$display("Characters sent to the UART:");
end 

// check uart write pulse 
always @ (posedge clock) 
begin 
	if (dut.txValid) 
		$write("%c", dut.cpu_dout);
end 
`endif 
endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
