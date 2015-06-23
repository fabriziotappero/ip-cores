//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 project
// http://opencores.org/project,next186
//
// Filename: Next186_Regs.v
// Description: Part of the Next186 CPU project, registers module
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
`timescale 1ns / 1ps


module Next186_Regs(
		input [2:0]RASEL,
		input [2:0]RBSEL,
		input BASEL,
		input [1:0]BBSEL,
		input [1:0]RSSEL,
		input [15:0]DIN,
		input [15:0]ALUOUT,
		input [15:0]ADDR16,
		input [15:0]DIMM,
		input [4:0]WE, // 4=flags, 3=TMP16, 2=RSSEL, 1=RASEL_HI, 0=RASEL_LO
		input IFETCH,
		input [15:0]FIN,
		input [1:0]DISEL,
		input [15:0]IPIN,
		input WORD,
		input INCSP,
		input DECCX,
		input DIVOP,
		input DIVEND,
		input DIVC,
		input DIVSGN,
		output [1:0]CXZ,
		output [15:0]FOUT,
		output [15:0]RA,
		output [15:0]RB,
		output reg [15:0]TMP16,
		output reg [15:0]SP,
		output reg [15:0]IP,
		output reg [15:0]AX,
		output reg [15:0]BX,
		output reg [15:0]BP,
		output reg [15:0]SI,
		output reg [15:0]DI,
		output [15:0]RS,
		output [15:0]CS,
		output reg [15:0]DX,
		output DIVEXC,
		input CLK,
		input CLKEN
    );

	reg [15:0]CX;
	reg [15:0]SREG[3:0];
	reg [8:0]FLG;
	reg [15:0]REG_ASEL;
	reg [15:0]REG_BSEL;
	wire [15:0]RW = DISEL[0] ? ALUOUT : ADDR16; // x1=ALU, 10=ADDR, 00=DIN
	wire [2:0]ASEL = {WORD & RASEL[2], RASEL[1:0]};
	wire [2:0]BSEL = {WORD & RBSEL[2], RBSEL[1:0]};
	wire [7:0]RWHI = WORD || &WE[1:0] ? RW[15:8] : RW[7:0];
	wire [8:0]RWDL = {DIVOP && ~DIVC ? DX[7:0] : RW[7:0], AX[15]};
	wire [8:0]RWDH = {DIVOP && ~DIVC ? DX[15:7] : {RWHI, RW[7]}};
	wire [8:0]RWAH = {DIVOP && ~DIVC ? AX[15:8] : RWHI, AX[7]};
	assign DIVEXC = WORD ? RWDH[8] : RWAH[8];	
	
	wire FASTDIN = ~|DISEL;
	wire [15:0]FDRW = FASTDIN ? DIN : RW;
	wire [7:0]FASTDINH = WORD || &WE[1:0] ? DIN[15:8] : DIN[7:0]; // fast data path for AH/DH (tweak for speed)
	wire [15:0]CXM1 = CX + 16'hffff;

	assign FOUT = {4'b0000, FLG[8:3], 1'b0, FLG[2], 1'b0, FLG[1], 1'b1, FLG[0]};
	assign CS = SREG[1];
	assign CXZ = {|CX[15:1], CX[0]};
	
	wire [15:0]RA1 = {REG_ASEL[15:8], WORD | !RASEL[2] ? REG_ASEL[7:0] : REG_ASEL[15:8]};
	assign RA = BASEL ? RA1 : TMP16;
	assign RB = BBSEL[1] ? BBSEL[0] ? SREG[BSEL[1:0]] : DIMM : BBSEL[0] ? {REG_BSEL[15:8], WORD | !RBSEL[2] ? REG_BSEL[7:0] : REG_BSEL[15:8]} : TMP16;
	assign RS = SREG[RSSEL];
	
	always @* begin 
		case(ASEL)
			0: REG_ASEL = AX;
			1: REG_ASEL = CX;
			2: REG_ASEL = DX;
			3: REG_ASEL = BX;
			4: REG_ASEL = SP;
			5: REG_ASEL = BP;
			6: REG_ASEL = SI;
			7: REG_ASEL = DI;
		endcase
		case(BSEL)
			0: REG_BSEL = AX;
			1: REG_BSEL = CX;
			2: REG_BSEL = DX;
			3: REG_BSEL = BX;
			4: REG_BSEL = SP;
			5: REG_BSEL = BP;
			6: REG_BSEL = SI;
			7: REG_BSEL = DI;
		endcase
	end
/*	
	 BUFG BUFG_inst (
      .O(CLKD),     // Clock buffer output
      .I(CLK)      // Clock buffer input
   );
*/
	always @(posedge CLK)
		if(CLKEN) begin
			if(WE[0] && ASEL == 0) AX[7:0] <= FDRW[7:0];
			else if(DIVOP) AX[7:0] <= {AX[6:0], DIVC  ^ DIVSGN};
			
			if(WE[1] && ASEL == 0) AX[15:8] <= FASTDIN ? FASTDINH : (DIVOP && ~DIVEND ? RWAH[7:0] : RWAH[8:1]);
			else if(DIVOP) AX[15:8] <= AX[14:7];
			
			if(WE[0] && ASEL == 1) CX[7:0] <= FDRW[7:0];
			else if(DECCX) CX[7:0] <= CXM1[7:0];
			
			if(WE[1] && ASEL == 1) CX[15:8] <= FASTDIN ? FASTDINH : RWHI;
			else if(DECCX) CX[15:8] <= CXM1[15:8];
			
			if(WE[0] && ASEL == 2) DX[7:0] <= FASTDIN ? DIN[7:0] : (DIVOP && ~DIVEND ? RWDL[7:0] : RWDL[8:1]);
			if(WE[1] && ASEL == 2) DX[15:8] <= FASTDIN ? FASTDINH : (DIVOP && ~DIVEND ? RWDH[7:0] : RWDH[8:1]);
			
			if(WE[0] && ASEL == 3) BX[7:0] <= FDRW[7:0];
			if(WE[1] && ASEL == 3) BX[15:8] <= FASTDIN ? FASTDINH : RWHI;
			
			if(WE[0] && ASEL == 4) SP <= FDRW;
			else if(INCSP) SP <= ADDR16;
			
			if(WE[0] && ASEL == 5) BP <= FDRW;
			if(WE[0] && ASEL == 6) SI <= FDRW;
			if(WE[0] && ASEL == 7) DI <= FDRW;
				
			if(WE[2])
				case(RASEL[1:0])
					0: SREG[0] <= FDRW;
					1: SREG[1] <= FDRW;
					2: SREG[2] <= FDRW;
					3: SREG[3] <= FDRW;
				endcase
				
			if(WE[3]) TMP16 <= |WE[1:0] ? (&DISEL[1:0] ? DIN : ADDR16) : FDRW;		// TMP16
			else TMP16 <= RA;	// XCHG, MUL

			if(WE[4]) FLG <= {FIN[11:6], FIN[4], FIN[2], FIN[0]};			// FLAGS

			if(IFETCH) IP <= IPIN;		// IP
		end

endmodule
