//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the NextZ80 project
// http://www.opencores.org/cores/nextz80/
//
// Filename: NextZ80ALU.v
// Description: Implementation of Z80 compatible CPU - ALU
// Version 1.0
// Creation date: 28Jan2011 - 18Mar2011
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

//FLAGS: S Z X1 N X2 PV N C
//	OP[4:0]
//	00000	-	ADD	D0,D1
//	00001	-	ADC	D0,D1
//	00010	-	SUB	D0,D1
//	00011	-	SBC	D0,D1
//	00100	-	AND	D0,D1
//	00101	-	XOR	D0,D1
//	00110	-	OR		D0,D1
//	00111	-	CP		D0,D1
//	01000	-	INC	D0
//	01001	-	CPL	D0
// 01010	-	DEC	D0
//	01011	-	RRD
// 01100	-	RLD
//	01101	-	DAA
//	01110	-	INC16
//	01111	-  DEC16
// 10000	-	ADD16LO
//	10001	-	ADD16HI
//	10010	-	
//	10011	-	
//	10100	-	CCF, pass D0
// 10101	-	SCF, pass D0
// 10110	-	
//	10111	-	
//	11000	-	RLCA	D0
//	11001	-	RRCA	D0
//	11010	-	RLA	D0
//	11011	- 	RRA	D0
//	11100	-	{ROT, BIT, SET, RES} D0,EXOP 
//				  RLC		D0			C <-- D0 <-- D0[7]
//            RRC		D0			D0[0] --> D0 --> C
//            RL		D0			C <-- D0 <-- C
//            RR		D0			C --> D0 --> C
//            SLA		D0			C <-- D0 <-- 0
//            SRA		D0			D0[7] --> D0 --> C
//            SLL		D0			C <-- D0 <-- 1
//            SRL		D0			0 --> D0 --> C
//	11101	-	IN, pass D1
//	11110	-	FLAGS <- D0
//	11111	-	NEG	D1	
///////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ALU8(
    input [7:0] D0,
    input [7:0] D1,
	 input [7:0] FIN,
    output reg[7:0] FOUT,
    output reg [15:0] ALU8DOUT,
    input [4:0] OP,
	 input [5:0] EXOP, // EXOP[5:4] = 2'b11 for CPI/D/R
	 input LDIFLAGS,	 // zero HF and NF on inc/dec16
	 input DSTHI		 // destination lo
    );
	
	wire [7:0] daaadjust;
	wire cdaa, hdaa;
	daa daa_adjust(.flags(FIN), .val(D0), .adjust(daaadjust), .cdaa(cdaa), .hdaa(hdaa));
	
	wire parity = ~^ALU8DOUT[15:8];
	wire zero = ALU8DOUT[15:8] == 0;
	reg csin, cin;
	wire [7:0]d0mux = OP[4:1] == 4'b1111 ? 0 : D0;
	reg [7:0]_d1mux;
	wire [7:0]d1mux = OP[1] ? ~_d1mux : _d1mux;
	wire [8:0]sum;
	wire hf;
	assign {hf, sum[3:0]} = d0mux[3:0] + d1mux[3:0] + cin;
	assign sum[8:4] = d0mux[7:4] + d1mux[7:4] + hf;
	wire overflow = (d0mux[7] & d1mux[7] & !sum[7]) | (!d0mux[7] & !d1mux[7] & sum[7]);
	reg [7:0]dbit;

	always @* begin
		ALU8DOUT = 16'hxxxx;
		FOUT = 8'hxx;
		case({OP[4:2]})
			0,1,4,7: _d1mux = D1;
			2: _d1mux = 1;
			3: _d1mux = daaadjust;		// DAA
			6,5: _d1mux = 8'hxx;
		endcase
		case({OP[2:0], FIN[0]})
			0,1,2,7,8,9,10,11,12,13:	cin = 0;
			3,4,5,6,14,15: cin = 1;
		endcase
		case(EXOP[3:0])
			0: dbit =  8'b11111110;
			1: dbit =  8'b11111101;
			2: dbit =  8'b11111011;
			3: dbit =  8'b11110111;
			4: dbit =  8'b11101111;
			5: dbit =  8'b11011111;
			6: dbit =  8'b10111111;
			7: dbit =  8'b01111111;
			8: dbit =  8'b00000001;
			9: dbit =  8'b00000010;
			10: dbit = 8'b00000100;
			11: dbit = 8'b00001000;
			12: dbit = 8'b00010000;
			13: dbit = 8'b00100000;
			14: dbit = 8'b01000000;
			15: dbit = 8'b10000000;
		endcase
		case(OP[3] ? EXOP[2:0] : OP[2:0])
			0,5:	csin = D0[7];
			1: 	csin = D0[0];
			2,3:	csin = FIN[0];
			4,7:	csin = 0;
			6:		csin = 1;
		endcase
		case(OP[4:0])
			0,1,2,3,8,10:	begin		// ADD, ADC, SUB, SBC, INC, DEC
				ALU8DOUT[15:8] = sum[7:0];
				ALU8DOUT[7:0] = sum[7:0];
				FOUT[0] = OP[3] ? FIN[0] : (sum[8] ^ OP[1]); // inc/dec
				FOUT[1] = OP[1];
				FOUT[2] = overflow;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = hf ^ OP[1];
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero & (FIN[6] | ~EXOP[5] | ~DSTHI | OP[3]); //(EXOP[5] & DSTHI) ? (zero & FIN[6]) : zero;				// adc16/sbc16
				FOUT[7] = ALU8DOUT[15];
			end
			16,17:	begin		// ADD16LO, ADD16HI
				ALU8DOUT[15:8] = sum[7:0];
				ALU8DOUT[7:0] = sum[7:0];
				FOUT[0] = sum[8];
				FOUT[1] = OP[1];
				FOUT[2] = FIN[2];
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = hf ^ OP[1];
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = FIN[6];
				FOUT[7] = FIN[7];
			end
			7: begin		// CP
				ALU8DOUT[15:8] = sum[7:0];
				FOUT[0] = EXOP[5] ? FIN[0] : !sum[8]; // CPI/D/R
				FOUT[1] = OP[1];
				FOUT[2] = overflow;
				FOUT[3] = D1[3];
				FOUT[4] = !hf;
				FOUT[5] = D1[5];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			31:	begin		// NEG
				ALU8DOUT[15:8] = sum[7:0];
				FOUT[0] = !sum[8];
				FOUT[1] = OP[1];
				FOUT[2] = overflow;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = !hf;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			4: begin			// AND
				ALU8DOUT[15:8] = D0 & D1;
				FOUT[0] = 0;
				FOUT[1] = 0;
				FOUT[2] = parity;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = 1;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			5,6: begin		//XOR, OR
				ALU8DOUT[15:8] = OP[0] ? (D0 ^ D1) : (D0 | D1);
				FOUT[0] = 0;
				FOUT[1] = 0;
				FOUT[2] = parity;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = 0;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			9: begin			// CPL
				ALU8DOUT[15:8] = ~D0;
				FOUT[0] = FIN[0];
				FOUT[1] = 1;
				FOUT[2] = FIN[2];
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = 1;
				FOUT[5] = ALU8DOUT[13];
				FOUT[7:6] = FIN[7:6];
			end
			11,12: begin					// RLD, RRD
				if(OP[0]) ALU8DOUT = {D0[7:4], D1[3:0], D0[3:0], D1[7:4]};
				else ALU8DOUT = {D0[7:4], D1[7:0], D0[3:0]};
				FOUT[0] = FIN[0];
				FOUT[1] = 0;
				FOUT[2] = parity;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = 0;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end			
			13: begin	// DAA
				ALU8DOUT[15:8] = sum[7:0];
				FOUT[0] = cdaa;
				FOUT[1] = FIN[1];
				FOUT[2] = parity;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = hdaa;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			14,15: begin	// inc/dec 16
				ALU8DOUT = {D0, D1} + (OP[0] ? 16'hffff : 16'h0001);
				FOUT[0] = FIN[0];
				FOUT[1] = LDIFLAGS ? 1'b0 : FIN[1];
				FOUT[2] = ALU8DOUT != 0;
				FOUT[3] = FIN[3];
				FOUT[4] = LDIFLAGS ? 1'b0 : FIN[4];
				FOUT[5] = FIN[5];
				FOUT[6] = FIN[6];
				FOUT[7] = FIN[7];
			end
			20,21: begin		// CCF, SCF
				ALU8DOUT[15:8] = D0;
				FOUT[0] = OP[0] ? 1'b1 : !FIN[0];
				FOUT[1] = 1'b0;
				FOUT[2] = FIN[2];
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = OP[0] ? 1'b0 : FIN[0];
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = FIN[6];
				FOUT[7] = FIN[7];				
			end
			24,25,26,27, 28: begin 							// ROT, BIT, RES, SET
				case({OP[2], EXOP[4:3]})
					0,1,2,3,4:	// rot - shift
						if(OP[2] ? EXOP[0] : OP[0]){ALU8DOUT[15:8], FOUT[0]} = {csin, D0};		// right
						else							 	{FOUT[0], ALU8DOUT[15:8]} = {D0, csin};		// left
					5,6: begin	// BIT, RES 
						FOUT[0] = FIN[0]; 
						ALU8DOUT[15:8] = D0 & dbit; 
					end		
					7: begin 	// SET
						FOUT[0] = FIN[0]; 
						ALU8DOUT[15:8] = D0 | dbit; 
					end			
				endcase
				ALU8DOUT[7:0] = ALU8DOUT[15:8];
				FOUT[1] = 0;
				FOUT[2] = OP[2] ? (EXOP[3] ? zero : parity) : FIN[2];
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = OP[2] & EXOP[3];
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = OP[2] ? zero : FIN[6];
				FOUT[7] = OP[2] ? ALU8DOUT[15] : FIN[7];
			end
			29:	begin		// IN, pass D1
				ALU8DOUT = {D1, D1};
				FOUT[0] = FIN[0];
				FOUT[1] = 0;
				FOUT[2] = parity;
				FOUT[3] = ALU8DOUT[11];
				FOUT[4] = 0;
				FOUT[5] = ALU8DOUT[13];
				FOUT[6] = zero;
				FOUT[7] = ALU8DOUT[15];
			end
			30: FOUT = D0;		// FLAGS <- D0
			default:;
		endcase
	end
endmodule

module daa (
	input [7:0]flags,
	input [7:0]val,
	output wire [7:0]adjust,
	output reg cdaa,
	output reg hdaa
	);
	
	wire h08 = val[7:4] < 9;
	wire h09 = val[7:4] < 10;
	wire l05 = val[3:0] < 6;
	wire l09 = val[3:0] < 10;
	reg [1:0]aa;
	assign adjust = ({1'b0, aa[1], aa[1], 2'b0, aa[0], aa[0], 1'b0} ^ {8{flags[1]}}) + flags[1];
	
	always @* begin
		case({flags[0], h08, h09, flags[4], l09})
			5'b00101, 5'b01101:	aa = 0;
			5'b00111, 5'b01111, 5'b01000, 5'b01010, 5'b01100, 5'b01110:	aa = 1;
			5'b00001, 5'b01001, 5'b10001, 5'b10101, 5'b11001, 5'b11101:	aa = 2;
			default: aa = 3;
		endcase
		case({flags[0], h08, h09, l09})
			4'b0011, 4'b0111, 4'b0100, 4'b0110:	cdaa = 0;
			default: cdaa = 1;
		endcase
		case({flags[1], flags[4], l05, l09})
			4'b0000, 4'b0010, 4'b0100, 4'b0110, 4'b1110, 4'b1111:	hdaa = 1;
			default:	hdaa = 0;
		endcase
	end
endmodule


module ALU16(
    input [15:0] D0,
    input [7:0] D1,
    output wire[15:0] DOUT,
    input [2:0]OP	// 0-NOP, 1-INC, 2-INC2, 3-ADD, 4-NOP, 5-DEC, 6-DEC2
    );
	
	reg [15:0] mux;
	always @*
		case(OP)
			0: mux = 0;				// post inc
			1: mux = 1;				// post inc
			2: mux = 2;				// post inc
			3: mux = {D1[7], D1[7], D1[7], D1[7], D1[7], D1[7], D1[7], D1[7], D1[7:0]};	// post inc
			4: mux = 0;				// no post inc			
			5: mux = 16'hffff;	// no post inc
			6: mux = 16'hfffe;	// no post inc
			default: mux = 16'hxxxx;
		endcase
	
	assign DOUT = D0 + mux;
endmodule
