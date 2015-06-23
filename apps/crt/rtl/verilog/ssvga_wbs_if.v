//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  LITTLE-ENDIAN WISHBONE slave interface.                     ////
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

`define SEL_PAL 10
`define SEL_ADDRESS 2

module ssvga_wbs_if(
	// Clock and reset
	wb_clk_i, wb_rst_i,

	// WISHBONE Slave I/F
	wbs_cyc_i, wbs_stb_i, wbs_sel_i, wbs_we_i,
	wbs_adr_i, wbs_dat_i, wbs_cab_i,
	wbs_dat_o, wbs_ack_o, wbs_err_o, wbs_rty_o,

	// Other signals
	ssvga_en, pal_wr_en, pal_rd_en, pal_dat,
    pix_start_addr
);

//
// I/O ports
//

//
// Clock and reset
//
input			wb_clk_i;	// Pixel Clock
input			wb_rst_i;	// Reset

//
// WISHBONE Slave I/F
//
input			wbs_cyc_i;
input			wbs_stb_i;
input	[3:0]		wbs_sel_i;
input			wbs_we_i;
input	[31:0]		wbs_adr_i;
input	[31:0]		wbs_dat_i;
input			wbs_cab_i;
output	[31:0]		wbs_dat_o;
output			wbs_ack_o;
output			wbs_err_o;
output			wbs_rty_o;

//
// Other signals
//
output			ssvga_en;	// Global enable
output			pal_wr_en;	// Palette write enable
output			pal_rd_en;	// Palette read enable
input	[15:0]		pal_dat;	// Palette data
output  [31:2] pix_start_addr ;

//
// Internal regs and wires
//
reg			wbs_ack_o;	// WISHBONE ack
reg			wbs_err_o;	// WISHBONE err
reg	[0:0]		ctrl_r;		// Control register
wire			valid_access;	// Access to SSVGA

//
// Control register
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		ctrl_r <= #1 1'b0;
	else if (valid_access & wbs_we_i & !wbs_adr_i[`SEL_PAL] & !wbs_adr_i[`SEL_ADDRESS])
		ctrl_r <= #1 wbs_dat_i[0];

reg [31:2] pix_start_addr ;
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		pix_start_addr <= #1 30'h0000_0000 ;
	else if (valid_access & wbs_we_i & !wbs_adr_i[`SEL_PAL] & wbs_adr_i[`SEL_ADDRESS] )
		pix_start_addr <= #1 wbs_dat_i[31:2] ;

//
// Generate delayed WISHBONE ack/err
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i) begin
		wbs_ack_o <= #1 1'b0;
		wbs_err_o <= #1 1'b0;
	end
	else if (valid_access) begin
		wbs_ack_o <= #1 1'b1;
		wbs_err_o <= #1 1'b0;
	end
	else if (wbs_cyc_i & wbs_stb_i) begin
		wbs_ack_o <= #1 1'b0;
		wbs_err_o <= #1 1'b1;
	end
	else begin
		wbs_ack_o <= #1 1'b0;
		wbs_err_o <= #1 1'b0;
	end

//
// Generate WISHBONE output signals
//
reg [31:0] wbs_dat_o ;
always@(wbs_adr_i or pal_dat or ctrl_r or pix_start_addr)
begin
    if ( wbs_adr_i[`SEL_PAL] )
        wbs_dat_o = {16'h0000, pal_dat} ;
    else
    if ( wbs_adr_i[`SEL_ADDRESS] )
        wbs_dat_o = {pix_start_addr, 2'b00} ;
    else
        wbs_dat_o = {{31{1'b0}}, ctrl_r};
end

assign wbs_rty_o = 1'b0;

//
// Generate other signals
//
assign valid_access = wbs_cyc_i & wbs_stb_i & (wbs_sel_i == 4'b1111);
assign ssvga_en = ctrl_r[0];
assign pal_wr_en = valid_access & wbs_we_i & wbs_adr_i[`SEL_PAL];
assign pal_rd_en = valid_access & ~wbs_we_i & wbs_adr_i[`SEL_PAL];

endmodule
