//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 project
// http://opencores.org/project,next186
//
// Filename: Next186_BIU_2T_delayread.v
// Description: Part of the Next186 CPU project, bus interface unit
// Version 1.0
// Creation date: 20Jan2012 - 10Mar2012
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
//	- Links the CPU with a 32bit static synchronous RAM (or cache) 
//	- Able to address up to 1MB 
//	- 16byte instruction queue 
//	- Works at 2 X CPU frequency (80Mhz on Spartan3AN), requiring minimum 2T for an instruction.
//	- The 32bit data bus and the double CPU clock allows the instruction queue to be almost always full, avoiding the CPU starving. 
//	  The data un-alignement penalties are required only when data words crosses the 4byte boundaries.
//
//////////////////////////////////////////////////////////////////////////////////
//
// How to compute each instruction duration, in clock cycles (for this particular BIU implementation!):
//
// 1 - From the Next186_features.doc see for each instruction how many T states are required (you will notice they are always
//		less or equal than 486 and much less than the original 80186
// 2 - Multiply this number by 2 - the BIU works at double ALU frequency because it needs to multiplex the data and instructions,
//		in order to keep the ALU permanently feed with instructions. The 16bit queue acts like a flexible instruction buffer.
// 3 - Add penalties, as follows:
//			+1T for each memory read - because of the synchronous SRAM which need this extra cycle to deliver the data
//			+2T for each jump - required to flush and re-fill the instruction queue
//			+1T for each 16bit(word) read/write which overlaps the 4byte boundary - specific to 32bit bus width
//			+1T if the jump is made at an address with the latest 2bits 11 - specific to 32bit bus width
//			+1T when the instruction queue empties - this case appears very rare, when a lot of 5-6 bytes memory write instructions are executed in direct sequence
//
//		Some examples:
// 		- "lea ax,[bx+si+1234]" requires 2T
// 		- "add ax, 2345" requires 2T
// 		- "xchg ax, bx" requires 4T
// 		- "inc word ptr [1]" requires 5T (2x2T inc M + 1T read)
// 		- "inc word ptr [3]" requires 7T (2x2T inc M + 1T read + 1T unaligned read + 1T unaligned write)
// 		- "imul ax,bx,234" requires 4T (2x2T imul)
// 		- "loop address != 3(mod 4)" requires 4T (2x1T loop + 2T flush)
// 		- "loop address == 3(mod 4)" requires 5T (2x1T loop + 2T flush + 1T unaligned jump)
// 		- "call address 0" requires 4T (2x1T call near + 2T flush
// 		- "ret address 0" requires 7T (2x2T ret + 1T read penalty + 2T flush)
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module BIU186_32bSync_2T_DelayRead(
	input CLK,
	output [47:0]INSTR,
	input [2:0]ISIZE,
	input IFETCH,
	input FLUSH,
	input MREQ,
	input WR,
	input WORD,
	input [20:0]ADDR,
	input [20:0]IADDR,
	output reg CE186,	// CPU clock enable
	input [31:0]RAM_DIN,
	output [31:0]RAM_DOUT,
	output [18:0]RAM_ADDR,
	output RAM_MREQ,
	output wire[3:0]RAM_WMASK,
	output reg [15:0]DOUT,
	input [15:0]DIN,
	input CE,		// BIU clock enable
	output reg data_bound,
	input [1:0]WSEL,	// normally {~ADDR[0], ADDR[0]}
	output reg RAM_RD,
	output reg RAM_WR
);

	reg [31:0]queue[3:0];
	reg [1:0]STATE = 0;
	reg OLDSTATE = 1;
	reg [3:0]qpos = 0;
	reg [4:0]qsize = 0;
	reg [1:0]rpos = 0;
	reg [18:0]piaddr = 0;
	reg [7:0]exdata = 0;
	reg rdi = 0;
	
	reg [1:0]NEXTSTATE;
	reg sflush;
	wire [4:0]newqsize = sflush ? -IADDR[1:0] : CE186 && IFETCH && ~FLUSH ? qsize - ISIZE : qsize;
	wire qnofull = qsize < 13;
	reg iread;// = (qnofull && !RAM_RD && !RAM_WR) || sflush;
	wire [3:0]nqpos = (FLUSH && IFETCH) ? {2'b00, IADDR[1:0]} : (qpos + ISIZE);
	wire [18:0]MIADDR = sflush ? IADDR[20:2] : piaddr;
	wire split = (&ADDR[1:0]) && WORD; // data between dwords
	wire [15:0]DSWAP = {WSEL[1] ? DIN[15:8] : DIN[7:0], WSEL[0] ? DIN[15:8] : DIN[7:0]};	//ADDR[0] ? {DIN[7:0], DIN[15:8]} : DIN;
	wire [1:0]a1 = nqpos[3:2] + 1;
	wire [1:0]a2 = nqpos[3:2] + 2;
	wire [31:0]q1 = rdi && (a1 == rpos) ? RAM_DIN : queue[a1];
	wire [7:0]q2 = rdi && (a2 == rpos) ? RAM_DIN[7:0] : queue[a2][7:0];

	assign INSTR = {q2, q1, queue[nqpos[3:2]]} >> {nqpos[1:0], 3'b000};
//	assign DOUT = split ? {RAM_DIN[7:0], exdata} : (RAM_DIN >> {ADDR[1:0], 3'b000}); 
	assign RAM_DOUT = {DSWAP, DSWAP};
	assign RAM_MREQ = iread || RAM_RD || RAM_WR;
	assign RAM_ADDR = iread ? MIADDR : ADDR[20:2] + data_bound; 
	assign RAM_WMASK = data_bound ? {3'b000, RAM_WR} : {2'b00, WORD & RAM_WR, RAM_WR} << ADDR[1:0];

	always @(*) begin
		RAM_RD = 0;
		RAM_WR = 0;
		CE186 = 0;
		sflush = 0;
		data_bound = 0;
		iread = 0;
		
		case(ADDR[1:0])
			2'b00: DOUT = RAM_DIN[15:0];
			2'b01: DOUT = RAM_DIN[23:8];
			2'b10: DOUT = RAM_DIN[31:16];
			2'b11: DOUT = {RAM_DIN[7:0], WORD ? exdata : RAM_DIN[31:24]};
		endcase
		
		case(STATE)
			0: begin	// no cpu activity on first state
				iread = qnofull;
				NEXTSTATE = 1;
			end
			1: begin
				NEXTSTATE = 1;
				if(FLUSH && IFETCH && !OLDSTATE) begin
					sflush = 1;
					iread = 1;
				end else if((FLUSH && IFETCH && (qsize > 5)) || (qsize > 11)) begin
					NEXTSTATE = 0;
					if(MREQ) begin
						if(WR) begin	// write
							RAM_WR = 1;
							if(split) NEXTSTATE = 3;
							else CE186 = 1;
						end else begin
							RAM_RD = 1;
							NEXTSTATE = split ? 2 : 3;
						end	
					end else begin
						iread = qnofull;
						CE186 = 1;
					end
				end else iread = 1; // else nextstate = 1
			end
			2: begin
				RAM_RD = 1;
				data_bound = 1;	// split memory access
				NEXTSTATE = 3;
			end
			3: begin
				RAM_WR = WR && MREQ;
				iread = !(WR && MREQ) && qnofull;
				data_bound = split; 
				CE186 = 1;
				NEXTSTATE = 0;
			end
		endcase
	end
	
	always @ (posedge CLK) if(CE) begin
		rdi <= iread;
		if(rdi) queue[rpos] <= RAM_DIN;
		if(iread) begin
			qsize <= {newqsize[4:2] + 1, newqsize[1:0]};
			piaddr <= MIADDR + 1;
		end else begin
			qsize <= newqsize;
			piaddr <= MIADDR;
		end
		if(CE186 && IFETCH) qpos <= nqpos;
		if(sflush) rpos <= 0;
		else if(rdi) rpos <= rpos + 1;
		OLDSTATE <= STATE[0];
		STATE <= NEXTSTATE;
		if(data_bound) exdata <= RAM_DIN[31:24];
	end

endmodule

