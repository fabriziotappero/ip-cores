//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: unit186.v
// Description: Part of the Next186 SoC PC project, 80186 unit (CPU + BIU)
// Version 1.0
// Creation date: Mar2012
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
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module unit186(
		input [15:0]INPORT,
		input [31:0]DIN,
		output [15:0]CPU_DOUT,
		output [31:0]DOUT,
		output [20:0]ADDR,
		output [3:0]WMASK,
		output [15:0]PORT_ADDR,
		
		input CLK,
		input CE,
		output CPU_CE,
		output CE_186,
		input INTR,
		input NMI,
		input RST,
		output INTA,
		output LOCK,
		output HALT,
		output MREQ,
		output IORQ,
		output WR,
		output WORD,
		
		input PLANAR,
		input [3:0]VGA_WPLANE,
		input [1:0]VGA_RPLANE,
		input [7:0]VGA_BITMASK,
		input [2:0]VGA_RWMODE,
		input [3:0]VGA_SETRES,
		input [3:0]VGA_ENABLE_SETRES,
		input [1:0]VGA_LOGOP,
		input [3:0]VGA_COLOR_COMPARE,
		input [3:0]VGA_COLOR_DONT_CARE
    );

	wire [15:0] CPU_DIN;
	wire [20:0] CPU_IADDR;
	wire [20:0] CPU_ADDR;
	wire [47:0] CPU_INSTR;
	wire CPU_MREQ; // CPU memory request
	wire IFETCH;
	wire FLUSH;
	wire [2:0]ISIZE;
	
	wire [3:0]RAM_WMASK;
	wire [31:0]RAM_DOUT;
	wire VGAWORD;
	wire [7:0]N_COMPARE = ((DIN[31:24] ^ {8{VGA_COLOR_COMPARE[3]}}) & {8{VGA_COLOR_DONT_CARE[3]}}) |
						  ((DIN[23:16] ^ {8{VGA_COLOR_COMPARE[2]}}) & {8{VGA_COLOR_DONT_CARE[2]}}) |
						  ((DIN[15:8]  ^ {8{VGA_COLOR_COMPARE[1]}}) & {8{VGA_COLOR_DONT_CARE[1]}}) |
						  ((DIN[7:0]   ^ {8{VGA_COLOR_COMPARE[0]}}) & {8{VGA_COLOR_DONT_CARE[0]}});
	wire [7:0]SEL_RDATA = VGA_RWMODE[2] ? ~N_COMPARE : (DIN >> {VGA_RPLANE, 3'b000});
	reg [31:0]VGA_LATCH;
	wire VGA_SEL = PLANAR && (CPU_ADDR[19:16] == 4'ha);
	wire RAM_RD;
	wire RAM_WR;
	reg s_RAM_RD;
	
	assign ADDR[1:0] = CPU_ADDR[1:0];
	assign CPU_CE = CE_186 & CE;
	assign PORT_ADDR = CPU_ADDR[15:0];
	assign WMASK = (VGA_SEL & RAM_WR) ? VGA_WPLANE : RAM_WMASK;
	wire [7:0]VGA_BITMASK1 = VGA_SEL ? (VGA_RWMODE[1:0] == 2'b01 ? 8'h00 : VGA_RWMODE[1:0] == 2'b11 ? (VGA_BITMASK & RAM_DOUT[7:0]) : VGA_BITMASK) : 8'hff;
	wire [3:0]EXPAND = VGA_SEL ? VGA_RWMODE[1:0] == 2'b00 ? VGA_ENABLE_SETRES : 4'b1111 : 4'b0000;
	wire [3:0]EXPAND_BIT = VGA_RWMODE[1:0] == 2'b10 ? RAM_DOUT[3:0] : VGA_SETRES;
	wire [31:0]RAM_DOUT1 = {EXPAND[3] ? {8{EXPAND_BIT[3]}} : RAM_DOUT[31:24], EXPAND[2] ? {8{EXPAND_BIT[2]}} : RAM_DOUT[23:16], 
							EXPAND[1] ? {8{EXPAND_BIT[1]}} : RAM_DOUT[15:8],  EXPAND[0] ? {8{EXPAND_BIT[0]}} : RAM_DOUT[7:0]};
	reg [31:0]RAM_DOUT2;
	assign DOUT = ({4{VGA_BITMASK1}} & RAM_DOUT2) | ({4{~VGA_BITMASK1}} & VGA_LATCH);
	
	always @(*)
		if(VGA_SEL)
			case(VGA_LOGOP)
				2'b00: RAM_DOUT2 = RAM_DOUT1;
				2'b01: RAM_DOUT2 = RAM_DOUT1 & VGA_LATCH;
				2'b10: RAM_DOUT2 = RAM_DOUT1 | VGA_LATCH;
				2'b11: RAM_DOUT2 = RAM_DOUT1 ^ VGA_LATCH;
			endcase
		else RAM_DOUT2 = RAM_DOUT1;
	

	Next186_CPU cpu 
	(
		 .ADDR(CPU_ADDR), 
		 .DIN(IORQ | INTA ? INPORT : CPU_DIN), 
		 .DOUT(CPU_DOUT), 
		 .CLK(CLK), 
		 .CE(CPU_CE), 
		 .INTR(INTR), 
		 .NMI(NMI), 
		 .RST(RST), 
		 .MREQ(CPU_MREQ), 
		 .IORQ(IORQ), 
		 .INTA(INTA), 
		 .WR(WR), 
		 .WORD(WORD), 
		 .LOCK(LOCK), 
		 .IADDR(CPU_IADDR), 
		 .INSTR(CPU_INSTR), 
		 .IFETCH(IFETCH), 
		 .FLUSH(FLUSH), 
		 .ISIZE(ISIZE), 
		 .HALT(HALT)
   );
	 

	BIU186_32bSync_2T_DelayRead BIU 
	(
		 .CLK(CLK), 
		 .INSTR(CPU_INSTR), 
		 .ISIZE(ISIZE), 
		 .IFETCH(IFETCH), 
		 .FLUSH(FLUSH), 
		 .MREQ(CPU_MREQ), 
		 .WR(WR), 
		 .WORD(WORD), 
		 .ADDR(VGA_SEL ? {2'b11, CPU_ADDR[15], ~CPU_ADDR[15], CPU_ADDR[14:0], WORD, WORD} : CPU_ADDR), 
		 .IADDR(CPU_IADDR), 
		 .CE186(CE_186), 
		 .RAM_DIN(s_RAM_RD ? {4{SEL_RDATA}} : DIN), 
		 .RAM_DOUT(RAM_DOUT), 
		 .RAM_ADDR(ADDR[20:2]), 
		 .RAM_MREQ(MREQ), 
		 .RAM_WMASK(RAM_WMASK), 
		 .DOUT(CPU_DIN), 
		 .DIN(CPU_DOUT), 
		 .CE(CE),
		 .data_bound(VGAWORD),
		 .WSEL(VGA_SEL ? {VGAWORD, VGAWORD} : {~CPU_ADDR[0], CPU_ADDR[0]}),
		 .RAM_RD(RAM_RD),
		 .RAM_WR(RAM_WR)
	);
	
	always @(posedge CLK) if(CE) begin
		s_RAM_RD <= VGA_SEL & RAM_RD;
		if(s_RAM_RD) VGA_LATCH <= DIN;
	end
		 
endmodule
