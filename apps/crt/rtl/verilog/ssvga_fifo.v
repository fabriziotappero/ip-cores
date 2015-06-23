//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  512 entry FIFO for storing line video data. It uses one     ////
////  clock for reading and writing.                              ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2001/10/02 15:33:33  mihad
// New project directory structure
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ssvga_fifo(
	clk, rst, dat_i, wr_en, rd_en,
	dat_o, full, empty, ssvga_en
);

//
// I/O ports
//
input			clk;		// Clock
input			rst;		// Reset
input	[31:0]	dat_i;		// Input data
input			wr_en;		// Write enable
input			rd_en;		// Read enable
output	[7:0]	dat_o;		// Output data
output			full;		// Full flag
output			empty;		// Empty flag
input           ssvga_en ;  // vga enable

//
// Internal wires and regs
//
reg	[7:0]		wr_ptr;		    // Write pointer
reg	[7:0]		wr_ptr_plus1;   // Write pointer
reg	[9:0]		rd_ptr;		    // Read pointer
reg	[9:0]		rd_ptr_plus1;	// Read pointer plus1
wire			rd_en_int;	    // FIFO internal read enable

//
// Write pointer + 1
//

always @(posedge clk or posedge rst)
    if (rst)
		wr_ptr_plus1 <= #1 8'b0000_0001 ;
    else if (~ssvga_en)
        wr_ptr_plus1 <= #1 8'b0000_0001 ;
	else if (wr_en)
		wr_ptr_plus1 <= #1 wr_ptr_plus1 + 1;

//
// Write pointer
//
always @(posedge clk or posedge rst)
	if (rst)
		wr_ptr <= #1 8'b0000_0000;
    else if (~ssvga_en)
        wr_ptr <= #1 8'b0000_0000;
	else if (wr_en)
		wr_ptr <= #1 wr_ptr_plus1 ;

//
// Read pointer
//
always @(posedge clk or posedge rst)
	if (rst)
		rd_ptr <= #1 10'b00_0000_0000;
    else if (~ssvga_en)
        rd_ptr <= #1 10'b00_0000_0000;
	else if (rd_en_int)
		rd_ptr <= #1 rd_ptr_plus1 ;

always @(posedge clk or posedge rst)
	if (rst)
		rd_ptr_plus1 <= #1 10'b00_0000_0001;
    else if (~ssvga_en)
        rd_ptr_plus1 <= #1 10'b00_0000_0001;
	else if (rd_en_int)
		rd_ptr_plus1 <= #1 rd_ptr_plus1 + 1 ;

//
// Empty is asserted when both pointers match
//
assign empty = ( rd_ptr == {wr_ptr, 2'b00} ) ;

//
// Full is asserted when both pointers match
// and wr_ptr did increment in previous clock cycle
//
assign full = ( wr_ptr_plus1 == rd_ptr[9:2] ) ;

wire valid_pix = 1'b1 ;

//
// Read enable for FIFO
//
assign rd_en_int = rd_en & !empty & valid_pix;

wire [8:0] ram_pix_address = rd_en_int ? {rd_ptr_plus1[9:2], rd_ptr_plus1[0]} : {rd_ptr[9:2], rd_ptr[0]} ;

wire [7:0] dat_o_low ;
wire [7:0] dat_o_high ;

assign dat_o = rd_ptr[1] ? dat_o_high : dat_o_low ;

RAMB4_S8_S16 ramb4_s8_0(
	.CLKA(clk),
	.RSTA(rst),
	.ADDRA(ram_pix_address),
	.DIA(8'h00),
	.ENA(1'b1),
	.WEA(1'b0),
	.DOA(dat_o_low),

	.CLKB(clk),
	.RSTB(rst),
	.ADDRB(wr_ptr),
	.DIB(dat_i[15:0]),
	.ENB(1'b1),
	.WEB(wr_en),
	.DOB()
);

RAMB4_S8_S16 ramb4_s8_1(
	.CLKA(clk),
	.RSTA(rst),
	.ADDRA(ram_pix_address),
	.DIA(8'h00),
	.ENA(1'b1),
	.WEA(1'b0),
	.DOA(dat_o_high),

	.CLKB(clk),
	.RSTB(rst),
	.ADDRB(wr_ptr),
	.DIB(dat_i[31:16]),
	.ENB(1'b1),
	.WEB(wr_en),
	.DOB()
);

endmodule
