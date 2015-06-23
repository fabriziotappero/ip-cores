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
		output [19:0]ADDR,
		output [3:0]WMASK,
		output [15:0]PORT_ADDR,
//		output [47:0]CPU_INSTR,
		
		input CLK,
		input CE,
		output CPU_CE,
		input INTR,
		input NMI,
		input RST,
		output INTA,
		output LOCK,
		output HALT,
		output MREQ,
		output IORQ,
		output WR,
		output WORD
    );

	wire [15:0] CPU_DIN;
	wire [19:0] CPU_IADDR;
	wire [19:0] CPU_ADDR;
	wire [47:0] CPU_INSTR;
	wire CPU_MREQ; // CPU memory request
	wire IFETCH;
	wire FLUSH;
	wire [2:0]ISIZE;
	wire CE_186;
	assign ADDR[1:0] = CPU_ADDR[1:0];
	assign CPU_CE = CE_186 & CE;
	assign PORT_ADDR = CPU_ADDR[15:0];

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
		 .ADDR(CPU_ADDR), 
		 .IADDR(CPU_IADDR), 
		 .CE186(CE_186), 
		 .RAM_DIN(DIN), 
		 .RAM_DOUT(DOUT), 
		 .RAM_ADDR(ADDR[19:2]), 
		 .RAM_MREQ(MREQ), 
		 .RAM_WMASK(WMASK), 
		 .DOUT(CPU_DIN), 
		 .DIN(CPU_DOUT), 
		 .CE(CE)
	);
		 
endmodule
