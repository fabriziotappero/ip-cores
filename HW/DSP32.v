`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: DSP32.v
// Description: Part of the Next186 SoC PC project, DSP coprocessor
// Version 1.0
// Creation date: Jan2015
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
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
// 8 x 64integers overlapping data windows, over 256 integers 
// command: 16'b0c000vvvvvvvvvvv = set r/w pointer - 256 32bit integers, 2048 instructions. c=1 for code write, 0 for data read/write
// command: 16'b10wwwvvvvvvvvvvv = run ip - 2048 instructions, 3 bit data window offset
//
// Instructions:
// D=dest(0..63), S=src(0..63)
//	0 - MOV D,S [mov 0,0 = HALT, mov 8,8..mov 15,15 = set data window, other mov x,x = NOP, CF unaffected]
// 1 - SAR D,n	[n[2:0] = shift arythmetic right 1..8, CF <- D[0]]
//	2 - ADD D,S
//	3 - ADC D,S
// 4 - SUB D,S
// 5 - SBB D,S
// 6 - MULH D,S	[{D, CF} <- D*S >> 32]
// 7 - MULL D,S	[{D, CF} <- D*S]
// 8 - MULM	 D,S	[{D, CF} <- D*S >> 16]
// 9 - TOWORD D,S [D <- {WORD(D), WORD(S)}, CF unaffected] 
// 10- SHR D,n [n[2:0] = shift logic right 1..8, CF enters through left, CF <- D[0]]
// 11- AND D, S [CF <- 1]
// 12- OR D, S	[CF <- (D | S) != 0]
// 13- XOR D, S [CF <- !CF]
//////////////////////////////////////////////////////////////////////////////////

module DSP32(
		input clk,
		input cmd,
		input ce,
		input wr,
		input [15:0]din,
		output [15:0]dout,
		output reg halt
);

	reg [10:0]rwp = 0;	// read/write pointer
	reg [10:0]ip = 0;  // instruction pointer
	reg [2:0]dwin = 0; // data window
	reg [2:0]dwin1 = 0;
	reg hi = 0;
	reg [15:0]lodata;
	reg [31:0]res;
	reg wcode = 0;
	reg CF;	// carry flag
	reg [2:0]op;
	wire [15:0]instr;
	reg [15:0]instr1;
	reg run = 1'b0;
	reg mc;
	wire signed [31:0]D;
	wire signed [31:0]S;
	wire cin = (instr1[14] ^ (CF & instr1[12]));
	wire [32:0]sumdiff = D + ({32{instr1[14]}} ^ S) + cin;
	wire signed [63:0]mul = D * S;
	wire [15:0]S16 = (~|S[31:15] | &S[31:15]) ? S[15:0] : {S[31], {15{!S[31]}}};
	wire [15:0]D16 = (~|D[31:15] | &D[31:15]) ? D[15:0] : {D[31], {15{!D[31]}}};
	wire extwrite = ce && wr && !cmd && hi && !wcode;

	assign ihalt = ~|instr;
	
	instrmem Code
	(
	  .clka(clk), // input clka
	  .wea(ce && !cmd && wcode && wr), // input [0 : 0] wea
	  .addra(rwp), // input [10 : 0] addra
	  .dina(din), // input [15 : 0] dina
	  .clkb(clk), // input clkb
	  .enb(run || (!ihalt && !extwrite)),
	  .addrb(ip), // input [10 : 0] addrb
	  .doutb(instr) // output [15 : 0] doutb
	);
	
	regs DSRegs
	(
		.clk(clk),
		.we(!halt || extwrite),
		.rd(!extwrite),
		.wa(extwrite ? rwp[7:0] : {dwin1 + instr1[11], instr1[10:6]}),
		.din(extwrite ? {din, lodata} : res),
		.rda({dwin + instr[11], instr[10:6]}),
		.D(D),
		.rsa({dwin + instr[5], instr[4:0]}),
		.S(S),
		.rra({rwp[7:0], hi}),
		.dout(dout)
	);
	
	always @(op, S, D, S16, D16, instr1, sumdiff, mul) begin
		mc = 1'bx;
		case(op)
			0: res = S;
			1: res =  $signed({instr1[12] ? D[31] : CF, D[30:0]}) >>> (instr1[2:0] + 1);
			2: res = sumdiff[31:0];
			3: {res, mc} = {mul, 1'b0} >> (instr1[15] ? 16 : instr1[12] ? 0 : 32);
			4: res = {D16, S16};
			5: res = S & D;
			6: res = S | D;
			7: res = S ^ D;
		endcase
	end


	always @(posedge clk) begin

		if(ce)
			if(cmd) begin
				if(wr && !din[15]) {hi, wcode, rwp} <= {1'b0, din[14], din[10:0]};	// set rwp
			end else begin
				hi <= !hi;
				lodata <= din;
				if(wcode || hi) rwp <= rwp + 1'b1;
			end
			
		if(ce && cmd && wr && din[15]) {run, dwin, ip} <= {1'b1, din[13:0]}; // run
		else begin
			run <= 1'b0;
			if(!extwrite) begin
				ip <= ip + 1'b1;
				if({instr[15:9], instr[5:3]} == 10'b0000001001) dwin <= instr[2:0];
				dwin1 <= dwin;
			end
		end
		
		if(!extwrite) begin // if not write external data
			halt <= ihalt;
			instr1 <= instr;
			
			case(instr[15:12])
				0: op <= 3'b000; // S
				1,10: op <= 3'b001; // SAR, SHR
				2,3,4,5: op <= 3'b010; // adder
				6,7,8: op <= 3'b011; // MULHI, MULLO, MULM
				9: op <= 3'b100; // TOWORD
				11: op <= 3'b101; // AND
				12: op <= 3'b110; // OR
				13: op <= 3'b111; // XOR
				default: op <= 3'bxxx;
			endcase

			case(op)
				1: CF <= S[0];
				2: CF <= sumdiff[32] ^ instr1[14];
				3: CF <= mc;
				5: CF <= 1'b1;	// and
				6: CF <= |res;	// or
				7: CF <= !CF;	// xor
			endcase

		end
	end

endmodule


module regs(
	input clk,
	input we,
	input rd,
	input [7:0]wa,
	input [31:0]din,
	input [7:0]rda,
	output reg [31:0]D,
	input [7:0]rsa,
	output reg [31:0]S,
	input [8:0]rra,
	output [15:0]dout
);
	
	reg [31:0]r[255:0];

	datamem16 RdRegs
	(
	  .clka(clk), // input clka
	  .wea(we), // input [0 : 0] wea
	  .addra(wa), // input [7 : 0] addra
	  .dina(din), // input [31 : 0] dina
	  .clkb(clk), // input clkb
	  .addrb(rra), // input [8 : 0] addrb
	  .doutb(dout) // output [15 : 0] doutb);
	);

	always @(posedge clk) begin
		if(we) r[wa] <= din;
		if(rd) D <= /*(we && rda == wa) ? din :*/ r[rda];
		if(rd) S <= /*(we && rsa == wa) ? din :*/ r[rsa];
	end

endmodule

