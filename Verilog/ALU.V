/****************************************************************************************
 MODULE:		Sub Level Arithmatic Logic Unit Block

 FILE NAME:	alu.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Arithmatic Logic Unit block

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module ALU (// Input
				ALUSrcA,
				ALUSrcB,
				OpCode,
				CurrentState,
				// Output
				ALUDataOut
				);

// Parameter
parameter DataWidth = 32;
parameter OpcodeSize = 8;
parameter StateSize = 2;
parameter FunctionSize = 8;

// Instructions options
parameter  LDA = 8'h0;
parameter  STO = 8'h1;
parameter  ADD = 8'h2;
parameter  SUB = 8'h3;
parameter  JMP = 8'h4;
parameter  JGE = 8'h5;
parameter  JNE = 8'h6;
parameter  STP = 8'h7;
parameter  SHR = 8'h8; 
parameter  SHL = 8'h9; 
parameter  AND = 8'ha;
parameter  OR  = 8'hb;
parameter  XOR = 8'hc;
parameter  COM = 8'hd;
parameter  SWP = 8'he;
parameter  NOP = 8'hf;

// Instruction for Memory Map devices
parameter  MAP = 9'h64;

// Current State options
parameter Init	 		= 2'b00;
parameter InstrFetch = 2'b01;
parameter InstrExec  = 2'b10;

// Function Select options
parameter FnAdd	= 8'b0000_0000;
parameter FnSub	= 8'b0000_0001;
parameter FnPassB = 8'b0000_0010;
parameter FnIncB	= 8'b0000_0011;
parameter FnShtR	= 8'b0000_0100;
parameter FnShtL	= 8'b0000_0101;
parameter FnAnd	= 8'b0000_0110;
parameter FnOr 	= 8'b0000_0111;
parameter FnXor	= 8'b0000_1000;
parameter FnCom	= 8'b0000_1001;
parameter FnSwp	= 8'b0000_1010;
parameter FnNop   = 8'b0000_1011;

// Input
input [DataWidth - 1 : 0] ALUSrcA;
input [DataWidth - 1 : 0] ALUSrcB;
input [OpcodeSize - 1 : 0] OpCode;
input [StateSize - 1 : 0] CurrentState;

// Output
output [DataWidth - 1 : 0] ALUDataOut;

// Signal Assignments
reg [DataWidth - 1 : 0] ALUDataOut;
reg [FunctionSize - 1 : 0] FunctSel;
reg CIn;

wire [DataWidth - 1 : 0] AIn, BIn;


// Assignment
assign AIn = ALUSrcA;
assign BIn = ALUSrcB;



always @(OpCode or CurrentState)
begin
	if (CurrentState == InstrFetch)
	begin
		if (OpCode != STP) // In the Fetch cycle increment PC
		begin
		   FunctSel <= FnIncB;
		   CIn <= 1;
		end
    	else
		begin
		   FunctSel <= FnPassB;
		   CIn <= 0;
		end
	end
	else
 	if(CurrentState == InstrExec)
	begin
		case (OpCode)
			LDA :
			begin
				FunctSel <= FnPassB;
			   CIn <= 0;
			end

			STO :
			begin
				FunctSel <= FnAdd;
		      CIn <= 0;
		   end

			ADD :
			begin
       		FunctSel <= FnAdd;
			   CIn <= 0;
	      end

			SUB :
			begin
	      	FunctSel <= FnSub;
		      CIn <= 0;
	      end

			JMP :
			begin
	      	FunctSel <= FnPassB;
	       	CIn <= 0;
       	end

			JGE :
			begin
	      	FunctSel <= FnPassB;
	       	CIn <= 0;
       	end

			JNE :
			begin
	      	FunctSel <= FnPassB;
		      CIn <= 0;
       	end

			STP :
			begin
	   	    FunctSel <= FnPassB;
		       CIn <= 0;
	      end

			SHR :
			begin
	   	    FunctSel <= FnShtR;
		       CIn <= 0;
	      end

			SHL :
			begin
	   	    FunctSel <= FnShtL;
		       CIn <= 0;
	      end

			AND :
			begin
	   	    FunctSel <= FnAnd;
		       CIn <= 0;
	      end

	 		OR :
			begin
	   	    FunctSel <= FnOr;
		       CIn <= 0;
	      end

			XOR :
			begin
	   	    FunctSel <= FnXor;
		       CIn <= 0;
	      end

	 		COM :
			begin
	   	    FunctSel <= FnCom;
		       CIn <= 0;
	      end

			SWP :
			begin
	   	    FunctSel <= FnSwp;
		       CIn <= 0;
	      end

			NOP :
			begin
	   	    FunctSel <= FnNop;
		       CIn <= 0;
	      end

			default :    ;
		endcase
	end
end


always @(AIn or BIn or CIn or FunctSel)
begin
	case (FunctSel)
		FnAdd	 	:    ALUDataOut <= AIn + BIn;
		FnSub	 	:    ALUDataOut <= AIn - BIn;
		FnPassB  :    ALUDataOut <= BIn;
		FnIncB   :    ALUDataOut <= BIn + CIn;
		FnShtR	:	  ALUDataOut <= AIn >> 1;
		FnShtL	:	  ALUDataOut <= AIn << 1;
		FnAnd 	:	  ALUDataOut <= AIn & BIn;
		FnOr  	:	  ALUDataOut <= AIn | BIn;
		FnXor 	:	  ALUDataOut <= AIn ^ BIn;
		FnCom 	:	  ALUDataOut <= ~BIn;
		FnSwp		:	  ALUDataOut <= {BIn[15:0],BIn[31:16]};
		FnNop		:	  ALUDataOut <= BIn;
		default 	:    ALUDataOut <= AIn + BIn;
	endcase
end


endmodule
