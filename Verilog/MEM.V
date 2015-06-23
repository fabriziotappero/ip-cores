/****************************************************************************************
 MODULE:		Sub Level Memory Block

 FILE NAME:	mem.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Behavioral Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level Behavioral Memory Block, It uses 12 Address and 16 Data Line
 the memory size would be 2 ^ 12 = 4096 * 16-bit wide = 65536 bits.
 65536 bits / 8 = 8192 Byte ->  8K Byte of memory.

 This memory is organized as 4096 locations of 16-bit (2 Byte) wide.

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module MEM (// Input
				DataIn,
				Address,
				MemReq,
				RdWrBar,
				clock,
				// Output
				DataOut
				);


// Parameter
parameter words = 4096;
parameter AccessTime = 0;
parameter DataWidth = 32;
parameter AddrWidth = 24;

// Input
input [DataWidth - 1 : 0] DataIn;
input [AddrWidth - 1 : 0] Address;
input MemReq;
input RdWrBar;
input clock;

// Output
output [DataWidth - 1 : 0] DataOut;

// Internal Memory Declerations
// 4096 x 16 bit wide

reg [DataWidth - 1 : 0] MEM_Data [0:words-1];

// Signal Declerations
wire [DataWidth - 1 : 0] Data;

// Assignments
// Read Cycle
assign Data = (MemReq && RdWrBar)? MEM_Data [Address]:32'hz;
assign #AccessTime DataOut = Data; // Delay in a continuous assign


// Write Cycle
always @(posedge clock)
begin
	if(MemReq && ~RdWrBar)
		MEM_Data [Address] <= DataIn;
end

endmodule
