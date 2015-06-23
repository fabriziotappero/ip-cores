/****************************************************************************************
 MODULE:		Sub Level Multiplexer Block

 FILE NAME:	mux16.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Multiplexer block

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module MUX16 (	// Input
					A_in,
					B_in,
					A_Select,
					// Output
					Out
					);

// Parameter
parameter DataWidth = 32;
parameter AddrWidth = 24;

// Input
input  [AddrWidth - 1 : 0]  A_in;
input  [DataWidth - 1 : 0]  B_in;
input  A_Select;

// Output
output [DataWidth - 1 : 0]  Out;

//Dataflow description of MUX16

assign Out = A_Select ? B_in : {8'b0, A_in};

endmodule
