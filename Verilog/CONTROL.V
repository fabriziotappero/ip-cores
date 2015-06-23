/****************************************************************************************
 MODULE:		Sub Level Controller Block

 FILE NAME:	control.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Controller block

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module CNTRL ( 	// Input
							clock,
							reset,
							OpCode,
							ACCNeg,
							ACCZero,
							Grant,
							// Ouptut
							NextState,
							PCInEn,
							IRInEn,
							ACCInEn,
							ACCOutEn,
							MemReq,
							RdWrBar,
							AddressSel,
							ALUSrcBSel
							);


// Parameter
parameter OpcodeSize = 8;
parameter StateSize = 2;
parameter Low	= 1'b0;
parameter High	= 1'b1;
parameter SelInstrAddr	 = 1'b0;
parameter SelOperandAddr = 1'b1;
parameter SelAddress	= 1'b0;
parameter SelData 	= 1'b1;

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
parameter  MAP = 8'h64;


// Current State options
parameter Init	 		= 2'b00;
parameter InstrFetch = 2'b01;
parameter InstrExec  = 2'b10;
parameter InstrStop  = 2'b11;


// Input
input clock;
input reset;
input [OpcodeSize - 1 : 0] OpCode;
input ACCNeg;
input ACCZero;
input Grant;

// Output
output [StateSize - 1 : 0] NextState;
output PCInEn;
output IRInEn;
output ACCInEn;
output ACCOutEn;
output MemReq;
output RdWrBar;
output AddressSel;
output ALUSrcBSel;

// Signal Declerations
reg PCInEn;
reg IRInEn;
reg ACCInEn;
reg ACCOutEn;
reg MemReq;
reg RdWrBar;
reg AddressSel;
reg ALUSrcBSel;
wire [StateSize - 1 : 0] NextState;


reg [1:0]state;
// Assignments
assign NextState = state;

// Finite State Machine's Sequential Section
always @(posedge reset or negedge clock)
begin
	if(reset == 1'b1)
	begin
		state <= Init;		
	end
	else
	begin // Grant = 1 -bit, opcode = 8-bit, state = 2-bit
		casex ({Grant,OpCode,state})
		   11'b0_xxxxxxxx_00:  state <= Init;
			11'b1_00000000_00:  state <= InstrFetch;
			11'b1_00000000_01:  state <= InstrExec;
			11'b1_00000001_01:  state <= InstrExec;
			11'b1_00000010_01:  state <= InstrExec;
			11'b1_00000011_01:  state <= InstrExec;
			11'b1_00000100_01:  state <= InstrExec;
			11'b1_00000101_01:  state <= InstrExec;
			11'b1_00000110_01:  state <= InstrExec;
			11'b1_00000111_01:  state <= InstrExec;
			11'b1_00001000_01:  state <= InstrExec;
			11'b1_00001001_01:  state <= InstrExec;
			11'b1_00001010_01:  state <= InstrExec;
			11'b1_00001011_01:  state <= InstrExec;
			11'b1_00001100_01:  state <= InstrExec;
			11'b1_00001101_01:  state <= InstrExec;
			11'b1_00001110_01:  state <= InstrExec;
			11'b1_00001111_01:  state <= InstrExec;
			11'b1_00010000_01:  state <= InstrExec;
			11'b1_00010001_01:  state <= InstrExec;
			11'b1_00010010_01:  state <= InstrExec;
			11'b1_00010011_01:  state <= InstrExec;
			11'b1_00010100_01:  state <= InstrExec;
			11'b1_00010101_01:  state <= InstrExec;
			11'b1_00010110_01:  state <= InstrExec;
			11'b1_00010111_01:  state <= InstrExec;
			11'b1_00011000_01:  state <= InstrExec;
			11'b1_00011001_01:  state <= InstrExec;
			11'b1_00011010_01:  state <= InstrExec;
			11'b1_00011011_01:  state <= InstrExec;
			11'b1_00011100_01:  state <= InstrExec;
			11'b1_00011101_01:  state <= InstrExec;
			11'b1_00011110_01:  state <= InstrExec;
			11'b1_00011111_01:  state <= InstrExec;
			11'b1_00100000_01:  state <= InstrExec;
			11'b1_00100001_01:  state <= InstrExec;
			11'b1_00100010_01:  state <= InstrExec;
			11'b1_00100011_01:  state <= InstrExec;
			11'b1_00100100_01:  state <= InstrExec;
			11'b1_00100101_01:  state <= InstrExec;
			11'b1_00100110_01:  state <= InstrExec;
			11'b1_00100111_01:  state <= InstrExec;
			11'b1_00101000_01:  state <= InstrExec;
			11'b1_00101001_01:  state <= InstrExec;
			11'b1_00101010_01:  state <= InstrExec;
			11'b1_00101011_01:  state <= InstrExec;
			11'b1_00101100_01:  state <= InstrExec;
			11'b1_00101101_01:  state <= InstrExec;
			11'b1_00101110_01:  state <= InstrExec;
			11'b1_00101111_01:  state <= InstrExec;
			11'b1_00110000_01:  state <= InstrExec;
			11'b1_00110001_01:  state <= InstrExec;
			11'b1_00110010_01:  state <= InstrExec;
			11'b1_00110011_01:  state <= InstrExec;
			11'b1_00110100_01:  state <= InstrExec;
			11'b1_00110101_01:  state <= InstrExec;
			11'b1_00110110_01:  state <= InstrExec;
			11'b1_00110111_01:  state <= InstrExec;
			11'b1_00111000_01:  state <= InstrExec;
			11'b1_00111001_01:  state <= InstrExec;
			11'b1_00111010_01:  state <= InstrExec;
			11'b1_00111011_01:  state <= InstrExec;
			11'b1_00111100_01:  state <= InstrExec;
			11'b1_00111101_01:  state <= InstrExec;
			11'b1_00111110_01:  state <= InstrExec;
			11'b1_00111111_01:  state <= InstrExec;
			11'b1_01000000_01:  state <= InstrExec;
			11'b1_01000001_01:  state <= InstrExec;
			11'b1_01000010_01:  state <= InstrExec;
			11'b1_01000011_01:  state <= InstrExec;
			11'b1_01000100_01:  state <= InstrExec;
			11'b1_01000101_01:  state <= InstrExec;
			11'b1_01000110_01:  state <= InstrExec;
			11'b1_01000111_01:  state <= InstrExec;
			11'b1_01001000_01:  state <= InstrExec;
			11'b1_01001001_01:  state <= InstrExec;
			11'b1_01001010_01:  state <= InstrExec;
			11'b1_01001011_01:  state <= InstrExec;
			11'b1_01001100_01:  state <= InstrExec;
			11'b1_01001101_01:  state <= InstrExec;
			11'b1_01001110_01:  state <= InstrExec;
			11'b1_01001111_01:  state <= InstrExec;
			11'b1_01010000_01:  state <= InstrExec;
			11'b1_01010001_01:  state <= InstrExec;
			11'b1_01010010_01:  state <= InstrExec;
			11'b1_01010011_01:  state <= InstrExec;
			11'b1_01010100_01:  state <= InstrExec;
			11'b1_01010101_01:  state <= InstrExec;
			11'b1_01010110_01:  state <= InstrExec;
			11'b1_01010111_01:  state <= InstrExec;
			11'b1_01011000_01:  state <= InstrExec;
			11'b1_01011001_01:  state <= InstrExec;
			11'b1_01011010_01:  state <= InstrExec;
			11'b1_01011011_01:  state <= InstrExec;
			11'b1_01011100_01:  state <= InstrExec;
			11'b1_01011101_01:  state <= InstrExec;
			11'b1_01011110_01:  state <= InstrExec;
			11'b1_01011111_01:  state <= InstrExec;
			11'b1_01100000_01:  state <= InstrExec;
			11'b1_01100001_01:  state <= InstrExec;
			11'b1_01100010_01:  state <= InstrExec;
			11'b1_01100011_01:  state <= InstrExec;
			11'b1_01100100_01:  state <= InstrExec;
			11'b1_01100101_01:  state <= InstrExec;
			11'b1_01100110_01:  state <= InstrExec;
			11'b1_01100111_01:  state <= InstrExec;
			11'b1_01101000_01:  state <= InstrExec;
			11'b1_01101001_01:  state <= InstrExec;
			11'b1_01101010_01:  state <= InstrExec;
			11'b1_01101011_01:  state <= InstrExec;
			11'b1_01101100_01:  state <= InstrExec;
			11'b1_01101101_01:  state <= InstrExec;
			11'b1_01101110_01:  state <= InstrExec;
			11'b1_01101111_01:  state <= InstrExec;
			11'b1_01110000_01:  state <= InstrExec;
			11'b1_01110001_01:  state <= InstrExec;
			11'b1_01110010_01:  state <= InstrExec;
			11'b1_01110011_01:  state <= InstrExec;
			11'b1_01110100_01:  state <= InstrExec;
			11'b1_01110101_01:  state <= InstrExec;
			11'b1_01110110_01:  state <= InstrExec;
			11'b1_01110111_01:  state <= InstrExec;
			11'b1_01111000_01:  state <= InstrExec;
			11'b1_01111001_01:  state <= InstrExec;
			11'b1_01111010_01:  state <= InstrExec;
			11'b1_01111011_01:  state <= InstrExec;
			11'b1_01111100_01:  state <= InstrExec;
			11'b1_01111101_01:  state <= InstrExec;
			11'b1_01111110_01:  state <= InstrExec;
			11'b1_01111111_01:  state <= InstrExec;
			11'b1_10000000_01:  state <= InstrExec;
			11'b1_10000001_01:  state <= InstrExec;
			11'b1_10000010_01:  state <= InstrExec;
			11'b1_10000011_01:  state <= InstrExec;
			11'b1_10000100_01:  state <= InstrExec;
			11'b1_10000101_01:  state <= InstrExec;
			11'b1_10000110_01:  state <= InstrExec;
			11'b1_10000111_01:  state <= InstrExec;
			11'b1_10001000_01:  state <= InstrExec;
			11'b1_10001001_01:  state <= InstrExec;
			11'b1_10001010_01:  state <= InstrExec;
			11'b1_10001011_01:  state <= InstrExec;
			11'b1_10001100_01:  state <= InstrExec;
			11'b1_10001101_01:  state <= InstrExec;
			11'b1_10001110_01:  state <= InstrExec;
			11'b1_10001111_01:  state <= InstrExec;
			11'b1_10010000_01:  state <= InstrExec;
			11'b1_10010001_01:  state <= InstrExec;
			11'b1_10010010_01:  state <= InstrExec;
			11'b1_10010011_01:  state <= InstrExec;
			11'b1_10010100_01:  state <= InstrExec;
			11'b1_10010101_01:  state <= InstrExec;
			11'b1_10010110_01:  state <= InstrExec;
			11'b1_10010111_01:  state <= InstrExec;
			11'b1_10011000_01:  state <= InstrExec;
			11'b1_10011001_01:  state <= InstrExec;
			11'b1_10011010_01:  state <= InstrExec;
			11'b1_10011011_01:  state <= InstrExec;
			11'b1_10011100_01:  state <= InstrExec;
			11'b1_10011101_01:  state <= InstrExec;
			11'b1_10011110_01:  state <= InstrExec;
			11'b1_10011111_01:  state <= InstrExec;
			11'b1_10100000_01:  state <= InstrExec;
			11'b1_10100001_01:  state <= InstrExec;
			11'b1_10100010_01:  state <= InstrExec;
			11'b1_10100011_01:  state <= InstrExec;
			11'b1_10100100_01:  state <= InstrExec;
			11'b1_10100101_01:  state <= InstrExec;
			11'b1_10100110_01:  state <= InstrExec;
			11'b1_10100111_01:  state <= InstrExec;
			11'b1_10101000_01:  state <= InstrExec;
			11'b1_10101001_01:  state <= InstrExec;
			11'b1_10101010_01:  state <= InstrExec;
			11'b1_10101011_01:  state <= InstrExec;
			11'b1_10101100_01:  state <= InstrExec;
			11'b1_10101101_01:  state <= InstrExec;
			11'b1_10101110_01:  state <= InstrExec;
			11'b1_10101111_01:  state <= InstrExec;
			11'b1_10110000_01:  state <= InstrExec;
			11'b1_10110001_01:  state <= InstrExec;
			11'b1_10110010_01:  state <= InstrExec;
			11'b1_10110011_01:  state <= InstrExec;
			11'b1_10110100_01:  state <= InstrExec;
			11'b1_10110101_01:  state <= InstrExec;
			11'b1_10110110_01:  state <= InstrExec;
			11'b1_10110111_01:  state <= InstrExec;
			11'b1_10111000_01:  state <= InstrExec;
			11'b1_10111001_01:  state <= InstrExec;
			11'b1_10111010_01:  state <= InstrExec;
			11'b1_10111011_01:  state <= InstrExec;
			11'b1_10111100_01:  state <= InstrExec;
			11'b1_10111101_01:  state <= InstrExec;
			11'b1_10111110_01:  state <= InstrExec;
			11'b1_10111111_01:  state <= InstrExec;
			11'b1_11000000_01:  state <= InstrExec;
			11'b1_11000001_01:  state <= InstrExec;
			11'b1_11000010_01:  state <= InstrExec;
			11'b1_11000011_01:  state <= InstrExec;
			11'b1_11000100_01:  state <= InstrExec;
			11'b1_11000101_01:  state <= InstrExec;
			11'b1_11000110_01:  state <= InstrExec;
			11'b1_11000111_01:  state <= InstrExec;
			11'b1_11001000_01:  state <= InstrExec;
			11'b1_11001001_01:  state <= InstrExec;
			11'b1_11001010_01:  state <= InstrExec;
			11'b1_11001011_01:  state <= InstrExec;
			11'b1_11001100_01:  state <= InstrExec;
			11'b1_11001101_01:  state <= InstrExec;
			11'b1_11001110_01:  state <= InstrExec;
			11'b1_11001111_01:  state <= InstrExec;
			11'b1_11010000_01:  state <= InstrExec;
			11'b1_11010001_01:  state <= InstrExec;
			11'b1_11010010_01:  state <= InstrExec;
			11'b1_11010011_01:  state <= InstrExec;
			11'b1_11010100_01:  state <= InstrExec;
			11'b1_11010101_01:  state <= InstrExec;
			11'b1_11010110_01:  state <= InstrExec;
			11'b1_11010111_01:  state <= InstrExec;
			11'b1_11011000_01:  state <= InstrExec;
			11'b1_11011001_01:  state <= InstrExec;
			11'b1_11011010_01:  state <= InstrExec;
			11'b1_11011011_01:  state <= InstrExec;
			11'b1_11011100_01:  state <= InstrExec;
			11'b1_11011101_01:  state <= InstrExec;
			11'b1_11011110_01:  state <= InstrExec;
			11'b1_11011111_01:  state <= InstrExec;
			11'b1_11100000_01:  state <= InstrExec;
			11'b1_11100001_01:  state <= InstrExec;
			11'b1_11100010_01:  state <= InstrExec;
			11'b1_11100011_01:  state <= InstrExec;
			11'b1_11100100_01:  state <= InstrExec;
			11'b1_11100101_01:  state <= InstrExec;
			11'b1_11100110_01:  state <= InstrExec;
			11'b1_11100111_01:  state <= InstrExec;
			11'b1_11101000_01:  state <= InstrExec;
			11'b1_11101001_01:  state <= InstrExec;
			11'b1_11101010_01:  state <= InstrExec;
			11'b1_11101011_01:  state <= InstrExec;
			11'b1_11101100_01:  state <= InstrExec;
			11'b1_11101101_01:  state <= InstrExec;
			11'b1_11101110_01:  state <= InstrExec;
			11'b1_11101111_01:  state <= InstrExec;
			11'b1_11110000_01:  state <= InstrExec;
			11'b1_11110001_01:  state <= InstrExec;
			11'b1_11110010_01:  state <= InstrExec;
			11'b1_11110011_01:  state <= InstrExec;
			11'b1_11110100_01:  state <= InstrExec;
			11'b1_11110101_01:  state <= InstrExec;
			11'b1_11110110_01:  state <= InstrExec;
			11'b1_11110111_01:  state <= InstrExec;
			11'b1_11111000_01:  state <= InstrExec;
			11'b1_11111001_01:  state <= InstrExec;
			11'b1_11111010_01:  state <= InstrExec;
			11'b1_11111011_01:  state <= InstrExec;
			11'b1_11111100_01:  state <= InstrExec;
			11'b1_11111101_01:  state <= InstrExec;
			11'b1_11111110_01:  state <= InstrExec;
			11'b1_11111111_01:  state <= InstrExec;
			11'b1_00000111_10:  state <= InstrStop;
			11'b1_xxxxxxxx_10:  state <= InstrFetch;
			11'b1_00000111_11:  state <= Init;
			default:			     state <= Init;
		endcase
	end
end


// Finite State Machine's Combinatorial Section
always @(reset or state or ACCNeg or ACCZero or OpCode)
begin
	if (reset == 1'b1)
	begin
		PCInEn 		<= Low;
		IRInEn 		<= Low;
		ACCInEn 		<= Low;
		ACCOutEn 	<= Low;
		MemReq 		<= Low;
		RdWrBar 		<= Low;
		AddressSel 	<= Low;
		ALUSrcBSel 	<= Low;
	end
	else
	if (state == InstrFetch)
	begin
	   PCInEn 		<= High;
		IRInEn 		<= High;
		ACCInEn 		<= Low;
		ACCOutEn 	<= Low;
	   MemReq 		<= High;
		RdWrBar 		<= High;
		AddressSel 	<= SelInstrAddr;
	   ALUSrcBSel 	<= SelAddress;
	end
	else
 	if (state == InstrExec)
	begin
    case (OpCode)
   
	 LDA:
  		begin
        PCInEn 		<= Low;
		  IRInEn 		<= Low;
		  ACCInEn 		<= High;
		  ACCOutEn 		<= Low;
        MemReq 		<= High;
		  RdWrBar 		<= High;
		  AddressSel 	<= SelOperandAddr;
        ALUSrcBSel 	<= SelData;
      end
    STO:
    	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= High;
        MemReq <= High;
		  RdWrBar <= Low;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
      end
    ADD:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
       end
    SUB:
    	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
      end
    JMP:
    	begin
        PCInEn <= High;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
      end
    JGE:
    	begin
        PCInEn <= ~ACCNeg;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
      end
    JNE:
    	begin
        PCInEn <= ~ACCZero;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
      end
    STP:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelAddress;
        ALUSrcBSel <= SelAddress;
	   end
    SHR:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= Low;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
	   end
    SHL:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= Low;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
   	end
    AND:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
   	end
    OR:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
   	end
    XOR:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
   	end
    COM:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
   	end
    SWP:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= High;
		  ACCOutEn <= Low;
        MemReq <= High;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelData;
   	end
    NOP:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
   	end
    default:
	 	begin
        PCInEn <= Low;
		  IRInEn <= Low;
		  ACCInEn <= Low;
		  ACCOutEn <= Low;
        MemReq <= Low;
		  RdWrBar <= High;
		  AddressSel <= SelOperandAddr;
        ALUSrcBSel <= SelAddress;
      end
    endcase
	 end
	else
 	if (state == InstrStop)
   begin
       PCInEn <= Low;
		 IRInEn <= Low;
		 ACCInEn <= Low;
		 ACCOutEn <= Low;
       MemReq <= Low;
		 RdWrBar <= High;
		 AddressSel <= SelAddress;
       ALUSrcBSel <= SelAddress;
   end
end
endmodule
