/****************************************************************************************
 MODULE:		Sub Level Program Counter Block

 FILE NAME:	pc.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Program Counter block

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module PC (	// Input
				clock,
				reset,
				PCInEn,
				PCDataIn,
				// Output
				PCDataOut
				);

// Parameter
parameter AddrWidth = 24;

// Inputs
input clock;
input reset;
input PCInEn;
input [AddrWidth - 1 : 0] PCDataIn;

// Outputs
output [AddrWidth - 1 : 0] PCDataOut;

// Signal Declerations
reg [AddrWidth - 1 : 0] PCDataOut;


// Main Block
always @ (posedge reset or negedge clock)
begin
	if(reset == 1'b1)
 		PCDataOut <= 24'h000;
	else
 	if (PCInEn == 1'b1)
   	PCDataOut <= PCDataIn;
	else
   	PCDataOut <= PCDataOut;
end
endmodule
