/*********************************************************
 MODULE:		Sub Level SDRAM Data Multiplexer

 FILE NAME:	sdram_mux.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will generate a multiplexor for SDRAM data path.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module sdram_mux(	// Input
						sdram_out,
						oe,
						// Output
						dq
						);


// Parameter
`include        "parameter.v"

// Input
input [data_size - 1 : 0]sdram_out;
input oe;

// Output
output [data_size - 1 : 0]dq;

// Internal wire and reg signals


// Assignment
assign dq = oe ? sdram_out : 32'hzzzz_zzzz;

endmodule
