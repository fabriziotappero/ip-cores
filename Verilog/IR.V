/****************************************************************************************
 MODULE:		Sub Level Instruction Register Block

 FILE NAME:	ir.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Instruction Register block

   This module generates the OPERAND and OPCODE to be used by
   modules ALU and CONTROLLER
   Inputs:
 
 	Internal Name	   Net Name		From
 	-----------------------------------------------------------
 	IRDataIn: [15:0]  MemDataOut	input into cpu module 	(from memory)
 
 	IRInEn: 	    		IRInEn		Controller
 
 	clock:		    	clock		 	input into cpu Module	(from stimulus.v)
 	reset:		    	reset		 	input into cpu Module	(from stimulus.v)
   Outputs:
 
 	Internal Name	    Net Name		 	Used By
 	-----------------------------------------------------------
 
 	OpCode: [3:0]	    OpCode		 		ALU and Controller
 
 	OperandOut: [11:0] OperandAddress	MUX12
 
 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

 module  IR (	// Input
					clock,
					reset,
					IRInEn,
					IRDataIn,
					// Output
 					OperandOut,
					OpCodeOut
					);


// Parameter
parameter DataWidth = 32;
parameter AddrWidth = 24;
parameter OpcodeSize = 8;

// Input
input  [DataWidth - 1 : 0] IRDataIn;
input	 IRInEn;
input  clock;
input  reset;

// Output
output [AddrWidth - 1 : 0] OperandOut;
output [OpcodeSize - 1 : 0]  OpCodeOut;

// Signal Declerations
reg [AddrWidth - 1 : 0]  OperandOut;
reg [OpcodeSize - 1 : 0]   OpCodeOut;


always @ (posedge reset or negedge clock)
begin
	if(reset == 1'b1)
	begin
		OperandOut <= 24'h00_0000;
		OpCodeOut  <= 8'h00;
	end
	else
	if(IRInEn == 1'b1)
	begin
		OperandOut <= IRDataIn [23:0];
		OpCodeOut  <= IRDataIn [31:24];
	end
	else
	begin
		OperandOut <= OperandOut;
		OpCodeOut  <= OpCodeOut;
	end
end
endmodule

