//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 project
// http://opencores.org/project,next186
//
// Filename: Next186_ALU.v
// Description: Part of the Next186 CPU project, arithmetic-logic unit and effective address unit implementation
// Version 1.0
// Creation date: 11Apr2011 - 07Jun2011
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2011 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it 
// and/or modify it under the terms of the GNU Lesser General 
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any 
// later version. 
// 
// This source is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
//	ADD			00_000
//	OR				00_001
//	ADC			00_010
//	SBB			00_011
//	AND			00_100
//	SUB			00_101
//	XOR			00_110
//	CMP			00_111
//
//	INC			01_000
//	DEC			01_001
//	NOT			01_010
//	NEG			01_011
//	DAA			01_100	// +0066h
//	DAS			01_101	// -0066h
//	AAA			01_110	// +0106h
//	AAS			01_111	// -0106h
//
//	MUL			10_000
//	IMUL			10_001
//
//	FLAGOP		11_001
// CBW			11_010
//	CWD			11_011
//	SHF/ROT 1	11_100
// SHF/ROT n	11_101
//	PASS FLAGS	11_110	// ALUOP <- FLAGS, clear TF, IF
//	PASS RB		11_111	// ALUOP <- RB, FLAGS <- RA
//
//
//  FLAGS:		X X X X OF DF IF TF  |  SF ZF X AF X PF X CF
//
// 09Feb2013 - fixed DAA,DAS bug
// 07Jul2013 - fixed OV/CY flags for IMUL
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Next186_ALU(
    input [15:0] RA,
    input [15:0] RB,
	 input [15:0] TMP16,
	 input [15:0] FETCH23,
	 input [15:0]FIN,
	 input [4:0]ALUOP,
	 input [2:0]EXOP,
	 input [3:0]FLAGOP,
	 input WORD,
	 input INC2,
	 output reg [15:0]FOUT,
    output reg [15:0]ALUOUT,
	 output reg ALUCONT,
	 output NULLSHIFT,
	 output COUT,
	 input [2:0]STAGE,
	 input CLK
    );

	reg CPLOP2;	
	wire [15:0]SUMOP1 = ALUOP[3:1] == 3'b101 ? 16'h0000 : RA;	// NEG, NOT
	reg [15:0]SUMOP21;
	wire [15:0]SUMOP2 = CPLOP2 ? ~SUMOP21 : SUMOP21;
	wire SCIN1 = ALUOP[3:1] == 3'b001 ? FIN[0] : ALUOP[3:0] == 4'b1010 ? 1'b1 : 1'b0;		//ADD/ADC, NOT
	wire SCIN = CPLOP2 ? ~SCIN1 : SCIN1; 	// carry in
	wire SC16OUT;
	wire SC8OUT;
	wire AF;
	wire [15:0]SUMOUT;
	wire parity = ~^ALUOUT[7:0];
	wire zero8 = ~|ALUOUT[7:0];
	wire zero = ~|ALUOUT[15:0];
	wire overflow8 = (SUMOP1[7] & SUMOP2[7] & !SUMOUT[7]) | (!SUMOP1[7] & !SUMOP2[7] & SUMOUT[7]);
	wire overflow = (SUMOP1[15] & SUMOP2[15] & !SUMOUT[15]) | (!SUMOP1[15] & !SUMOP2[15] & SUMOUT[15]);
	wire LONIBBLE = (RA[3:0] > 4'h9)  || FIN[4];
	wire HINIBBLE = (RA[7:0] > 8'h99) || FIN[0];

// ADDER		
	assign {AF, SUMOUT[3:0]} = SUMOP1[3:0] + SUMOP2[3:0] + SCIN;
	assign {SC8OUT, SUMOUT[7:4]} = SUMOP1[7:4] + SUMOP2[7:4] + AF;
	assign {SC16OUT, SUMOUT[15:8]} = SUMOP1[15:8] + SUMOP2[15:8] + SC8OUT;
	assign COUT = (WORD ? SC16OUT : SC8OUT) ^ CPLOP2;

// SHIFTER
	reg [4:0]SHNOPT;	// optimized shift
	wire [4:0]SHN = {STAGE[2:1] ^ SHNOPT[4:3], SHNOPT[2:0]};
	assign NULLSHIFT = ~|SHNOPT;
	wire [2:0]COUNT = |SHN[4:3] ? 0 : SHN[2:0];
	wire [2:0]SCOUNT = (EXOP[0] ? COUNT[2:0] : 3'b000) - (EXOP[0] ? 3'b001 : COUNT[2:0]);
	reg [7:0]SHEX;
	wire [17:0]SHBAR = (EXOP[0] ? {1'bx, SHEX, WORD ? RA[15:8]: SHEX, RA[7:0]} : {RA, SHEX, 1'bx}) >> SCOUNT;

// MULTIPLIER
	wire signed [16:0]MULOP1 = WORD ? {ALUOP[0] & TMP16[15], TMP16} : {ALUOP[0] ? {9{TMP16[7]}} : 9'b000000000, TMP16[7:0]};
	wire signed [16:0]MULOP2 = WORD ? {ALUOP[0] & FETCH23[15], FETCH23} : {ALUOP[0] ? {9{FETCH23[7]}} : 9'b000000000, FETCH23[7:0]};
	wire signed [31:0]MUL = MULOP1 * MULOP2;
	
	always @* begin
		FOUT[15:8] = {4'bxxxx, WORD ? overflow : overflow8, FIN[10:8]};
		FOUT[7] = WORD ? ALUOUT[15] : ALUOUT[7];
		FOUT[6] = WORD ? zero : zero8;
		FOUT[5] = 1'bx;
		FOUT[4] = AF ^ CPLOP2;
		FOUT[3] = 1'bx;
		FOUT[2] = parity;
		FOUT[1] = 1'bx;
		FOUT[0] = COUT;
		ALUOUT = 16'hxxxx;
		ALUCONT = 1'bx;

		case(ALUOP[3:0])	// complement second operand
			4'b0000, 4'b0010, 4'b1000, 4'b1100, 4'b1110: CPLOP2 = 1'b0;	// ADD, ADC, INC, DEC, DAA, AAA
			default: CPLOP2 = 1'b1;
		endcase

		case(ALUOP[3:0])
			4'b1000, 4'b1001:	SUMOP21 = INC2 && WORD ? 2 : 1;	// INC/DEC
			4'b1100, 4'b1101:	SUMOP21 = {9'b000000000, HINIBBLE, HINIBBLE, 2'b00, LONIBBLE, LONIBBLE, 1'b0};
			4'b1110, 4'b1111:	SUMOP21 = {7'b0000000, LONIBBLE, 5'b00000, LONIBBLE, LONIBBLE, 1'b0};
			default: SUMOP21 = RB;
		endcase
	
		if(ALUOP[0]) 
			case({WORD, EXOP[2:1]})
				3'b000:	SHNOPT = {2'b00, RB[2:0]};
				3'b001, 3'b101:  SHNOPT = RB[4:0];
				3'b010, 3'b011: SHNOPT = |RB[4:3] ? 5'b01000 : RB[4:0];
				3'b100:	SHNOPT = {1'b0, RB[3:0]};
				3'b110, 3'b111: SHNOPT = RB[4] ? 5'b10000 : RB[4:0];	
			endcase
		else SHNOPT = 5'b00001;
		
		case({WORD, EXOP})
			4'b1000:	SHEX = RA[15:8];					// ROL16
			4'b0010: SHEX = {FIN[0], RA[7:1]};		// RCL8
			4'b0011, 4'b1011:	SHEX = {RA[6:0], FIN[0]};		// RCR8, RCR16
			4'b0111:	SHEX = {8{RA[7]}};				// SAR8
			4'b0000, 4'b0001, 4'b1001:	SHEX = RA[7:0];		// ROL8, ROR8, ROR16
			4'b1010: SHEX = {FIN[0], RA[15:9]};		// RCL16
			4'b1111:	SHEX = {8{RA[15]}};				// SAR16
			default: SHEX = 8'h00;						// SHL16, SHR16, SHL8, SHR8
		endcase

		case(ALUOP)
			5'b00000, 5'b00010, 5'b00011, 5'b00101, 5'b00111, 5'b01010, 5'b01011: ALUOUT = SUMOUT;	// ADD, ADC, SBB, SUB, CMP, NOT, NEG
			5'b00001: begin	// OR
				ALUOUT = RA | RB;
				FOUT[0] = 1'b0;
				FOUT[11] = 1'b0;
				FOUT[4] = FIN[4];
			end
			5'b00100: begin	// AND
				ALUOUT = RA & RB;
				FOUT[0] = 1'b0;
				FOUT[11] = 1'b0;
				FOUT[4] = FIN[4];
			end
			5'b00110: begin	// XOR
				ALUOUT = RA ^ RB;
				FOUT[0] = 1'b0;
				FOUT[11] = 1'b0;
				FOUT[4] = FIN[4];
			end
			5'b01000, 5'b01001: begin	// INC, DEC
				ALUOUT = SUMOUT;
				FOUT[0] = FIN[0];
			end
			5'b01100, 5'b01101: begin 	// DAA, DAS
				ALUOUT = SUMOUT;
				FOUT[0] = HINIBBLE;
				FOUT[4] = LONIBBLE;
			end
			5'b01110, 5'b01111: begin	// AAA, AAS
				ALUOUT = {SUMOUT[15:8], 4'b0000, SUMOUT[3:0]};
				FOUT[0] = LONIBBLE;
				FOUT[4] = LONIBBLE;
			end
			5'b10000, 5'b10001 : begin	// MUL, IMUL
				ALUOUT = STAGE[1] ? MUL[31:16] : MUL[15:0];
//07Jul2013 - fixed OV/CY flags for IMUL
				FOUT[0] = WORD ? MUL[31:16] != {16{MUL[15] & ALUOP[0]}} : MUL[15:8] != {8{MUL[7] & ALUOP[0]}}; 
				FOUT[11] = FOUT[0];
			end
			5'b11001: begin		// flag op
				FOUT[11:8] = FIN[11:8];
				FOUT[7] = FIN[7];
				FOUT[6] = FIN[6];
				FOUT[4] = FIN[4];
				FOUT[2] = FIN[2];
				FOUT[0] = FIN[0];
				case(FLAGOP)
					4'b1000: FOUT[0] = 1'b0;		// CLC
					4'b0101: FOUT[0] = !FIN[0];	// CMC
					4'b1001: FOUT[0] = 1'b1;		// STC
					4'b1100: FOUT[10] = 1'b0;		// CLD
					4'b1101: FOUT[10] = 1'b1;		// STD
					4'b1010:	FOUT[9] = 1'b0;		// CLI
					default: FOUT[9] = 1'b1;		// STI
				endcase
			end
			5'b11010: ALUOUT[7:0] = {8{RB[7]}};
			5'b11011: ALUOUT[15:0] = {16{RB[15]}};
			5'b11100, 5'b11101: begin	// ROT/SHF
				ALUOUT = SHBAR[16:1];
				FOUT[0] = EXOP[0] ? SHBAR[0] : WORD ? SHBAR[17] : SHBAR[9];
				FOUT[11] = WORD ? RA[15] ^ ALUOUT[15] : RA[7] ^ ALUOUT[7]; // OF is defined only for 1bit rotate/shift
				if(!EXOP[2]) begin	// ROT
					FOUT[7] = FIN[7];
					FOUT[6] = FIN[6];
					FOUT[4] = FIN[4];
					FOUT[2] = FIN[2];
				end
				case({SHN[4:3], STAGE[2:1]})
					4'b0100, 4'b1101, 4'b0110: ALUCONT = |SHN[2:0];
					4'b1000, 4'b1100, 4'b1001: ALUCONT = 1'b1;
					default: ALUCONT = 1'b0;
				endcase
			end

			5'b11110:	begin
				ALUOUT = FIN;
				FOUT[11] = FIN[11];
				FOUT[9] = 1'b0;	// IF
				FOUT[8] = 1'b0;	// TF
				FOUT[7] = FIN[7];
				FOUT[6] = FIN[6];
				FOUT[4] = FIN[4];
				FOUT[2] = FIN[2];
				FOUT[0] = FIN[0];
			end
			5'b11111:	begin
				ALUOUT = RB;
				FOUT = {WORD ? RA[15:8] : FIN[15:8], RA[7:0]};
			end
		endcase
	end

endmodule

// 0000 - BX+SI+DISP
// 0001 - BX+DI+DISP
// 0010 - BP+SI+DISP
// 0011 - BP+DI+DISP
// 0100 - SI+DISP
// 0101 - DI+DISP
// 0110 - BP+DISP
// 0111 - BX+DISP
// 1000 - SP-2
// 1001 - SP+2
// 1010 - BX+AL
// 1011 - TMP16+2
// 1100 - 
// 1101 - SP+2+DISP
// 1110 - DISP[7:0]<<2
// 1111 - PIO
module Next186_EA(
    input [15:0] SP,
    input [15:0] BX,
    input [15:0] BP,
    input [15:0] SI,
    input [15:0] DI,
	 input [15:0] PIO,
	 input [15:0] TMP16,
	 input [7:0]  AL,
    input [15:0] AIMM,
	 input [3:0]EAC,
    output [15:0] ADDR16
    );

	reg [15:0]OP1;
	reg [15:0]OP2;
	reg [15:0]OP3;
		
	always @* begin
		case(EAC)
			4'b0000, 4'b0001, 4'b0111, 4'b1010: OP1 = BX;
			4'b0010, 4'b0011, 4'b0110:  OP1 = BP; 
			4'b1000, 4'b1001, 4'b1101: OP1 = SP;
			4'b1011: OP1 = TMP16;
			default: OP1 = 16'h0000;
		endcase
		case(EAC)
			4'b0000, 4'b0010, 4'b0100: OP2 = SI;
			4'b0001, 4'b0011, 4'b0101: OP2 = DI;
			4'b1001, 4'b1011, 4'b1101:	OP2 = 16'h0002;	// SP/TMP16 + 2
			default: OP2 = 16'h0000;
		endcase
		case(EAC)
			4'b1000: OP3 = 16'hfffe;	// SP - 2
			4'b1010: OP3 = {8'b00000000, AL};	// XLAT
			4'b1001, 4'b1011:	OP3 = 16'h0000;	// SP/TMP16 + 2
			4'b1110: OP3 = {6'b000000, AIMM[7:0], 2'b00};	// int
			4'b1111: OP3 = PIO;	// in,out
			default: OP3 = AIMM;
		endcase
	end
	
	assign ADDR16 = OP1 + OP2 + OP3;
endmodule
