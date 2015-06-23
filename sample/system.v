//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 project
// http://opencores.org/project,next186
//
// Filename: system.v
// Description: Next80186 evaluation system with 4K SRAM, working at 80MHZ
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
//
// Comments:
// This project was developed and tested on a XILINX Spartan3AN board.
//
//	This is a demonstration system containing:
//		- Next80186 CPU
//		- Next80186 BIU - 32bit bus, 80Mhz
//		- 4KB SRAM (2KB at address 00000h - interrupt table zone, 2KB at address FF800h - ROM zone)
//		- 1DCM with 50Mhz input and 80Mhz output
//	The system is connected to RS232, to 9 LEDs on board and to a RESET button. 
//
///////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module system(
//		output [17:0]RAM_ADDR,
//		output CE,
//		output [3:0]RAM_WMASK,
//		output RAM_MREQ, 
//		output RAM_WR,
//		output [31:0]RAM_DIN,
//		output [31:0]RAM_DOUT,
//		output [47:0]INSTR,
//		output IFETCH,
//		output FLUSH,
//		output MREQ,
//		output WR,
//		output WORD,
//		output [19:0]ADDR,
//		output [19:0]IADDR,
//		output [15:0]DIN,
//		output [15:0]DOUT,
//		output [2:0]ISIZE,
//		output HALT,
//		output IORQ,
		
		input CLK_50MHZ,
		input BTN_SOUTH,
		output reg[7:0]LED,	
		output FPGA_AWAKE,	// HALT
		input RS232_DCE_RXD,
		output reg RS232_DCE_TXD
    );


	wire [19:0]ADDR;
	wire [19:0]IADDR;
	wire [15:0]DIN;
	wire [15:0]DOUT;
	wire [47:0]INSTR;
	wire [2:0]ISIZE;
	wire [31:0]RAM_DIN;
	wire [31:0]RAM_DOUT; 
	wire [17:0]RAM_ADDR; 
	wire [3:0] RAM_WMASK;
	wire RAM_MREQ; 
	wire CE;
	wire MREQ;
	wire WR;
	wire WORD;
	wire IFETCH;
	wire FLUSH;
	wire HALT;
	wire IORQ;
	
	reg s_RS232_DCE_RXD;
	wire CLK;
	reg [4:0]rstcount = 0;

	Next186_CPU CPU186
	(
		 .ADDR(ADDR), 
		 .DIN({DIN[15:1], IORQ ? s_RS232_DCE_RXD : DIN[0]}), 
		 .DOUT(DOUT), 
		 .CLK(CLK), 
		 .CE(CE), 
		 .INTR(1'b0), 
		 .NMI(1'b0), 
		 .RST(BTN_SOUTH || !rstcount[4]), 
		 .MREQ(MREQ), 
		 .IORQ(IORQ), 
//		 .INTA(INTA), 
		 .WR(WR), 
		 .WORD(WORD), 
//		 .LOCK(LOCK), 
		 .IADDR(IADDR), 
		 .INSTR(INSTR), 
		 .IFETCH(IFETCH), 
		 .FLUSH(FLUSH), 
		 .ISIZE(ISIZE),
		 .HALT(FPGA_AWAKE)
	 );
	 
	 BIU186_32bSync_2T_DelayRead BIU186 
	 (
		 .CLK(CLK), 
		 .INSTR(INSTR), 
		 .ISIZE(ISIZE), 
		 .IFETCH(IFETCH), 
		 .FLUSH(FLUSH), 
		 .MREQ(MREQ), 
		 .WR(WR), 
		 .WORD(WORD), 
		 .ADDR(ADDR), 
		 .IADDR(IADDR), 
		 .CE186(CE), 
		 .RAM_DIN(RAM_DIN), 
		 .RAM_DOUT(RAM_DOUT), 
		 .RAM_ADDR(RAM_ADDR), 
		 .RAM_MREQ(RAM_MREQ), 
		 .RAM_WMASK(RAM_WMASK), 
		 .DOUT(DIN), 
		 .DIN(DOUT), 
		 .CE(1'b1)
    );
	 
	 wire block0 = RAM_ADDR[17:9] == 9'b000000000;
	 wire block1 = RAM_ADDR[17:9] == 9'b111111111;
	 
	 sram SRAM_ 
	 (
		  .clka(CLK), // input clka
		  .ena(RAM_MREQ && (block0 || block1)), // input ena
		  .wea(RAM_WMASK), // input [3 : 0] wea
		  .addra(RAM_ADDR[9:0]), // input [9 : 0] addra
		  .dina(RAM_DOUT), // input [31 : 0] dina
		  .douta(RAM_DIN) // output [31 : 0] douta
	  );

	dcm system_clock 
	(
    .CLKIN_IN(CLK_50MHZ), 
    .CLKFX_OUT(CLK)
//    .CLKIN_IBUFG_OUT(CLKIN_IBUFG_OUT), 
//    .CLK0_OUT(CLK0_OUT)
    );


		always @ (posedge CLK) begin
			if(CE && IORQ && WR) begin
				if(ADDR[0]) RS232_DCE_TXD <= DOUT[0];
				else LED <= DOUT[7:0];
			end
			s_RS232_DCE_RXD <= RS232_DCE_RXD;
			if(CE && ~rstcount[4]) rstcount <= rstcount + 1;
		end
endmodule
