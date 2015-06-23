//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  Top level of SSVGA.                                         ////
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

module ssvga_top(
	// Clock and reset
	wb_clk_i, wb_rst_i,

	// WISHBONE Master I/F
	wbm_cyc_o, wbm_stb_o, wbm_sel_o, wbm_we_o,
	wbm_adr_o, wbm_dat_o, wbm_cab_o,
	wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_rty_i,

	// WISHBONE Slave I/F
	wbs_cyc_i, wbs_stb_i, wbs_sel_i, wbs_we_i,
	wbs_adr_i, wbs_dat_i, wbs_cab_i,
	wbs_dat_o, wbs_ack_o, wbs_err_o, wbs_rty_o,

	// Signals to VGA display
	pad_hsync_o, pad_vsync_o, pad_rgb_o, led_o
);

//
// I/O ports
//

//
// Clock and reset
//
input			wb_clk_i;	// Write Clock
input			wb_rst_i;	// Reset

//
// WISHBONE Master I/F
//
output			wbm_cyc_o;
output			wbm_stb_o;
output	[3:0]		wbm_sel_o;
output			wbm_we_o;
output	[31:0]		wbm_adr_o;
output	[31:0]		wbm_dat_o;
output			wbm_cab_o;
input	[31:0]		wbm_dat_i;
input			wbm_ack_i;
input			wbm_err_i;
input			wbm_rty_i;

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
// VGA display
//
output			pad_hsync_o;	// H sync
output			pad_vsync_o;	// V sync
output	[15:0]		pad_rgb_o;	// Digital RGB data
output			led_o;

//
// Internal wires and regs
//
wire			ssvga_en;	// Global enable
wire			fifo_full;	// FIFO full flag
wire			fifo_empty;	// FIFO empty flag
wire            wbm_restart ; // indicator on when WISHBONE master should restart whole screen because of pixel buffer underrun
wire			crtc_hblank;	// H blank
wire			crtc_vblank;	// V blank
wire			fifo_wr_en;	// FIFO write enable
wire			fifo_rd_en;	// FIFO read enable
wire	[31:0]		fifo_in;	// FIFO input data
wire	[7:0]		fifo_out;	// FIFO output data
//wire	[7:0]		pal_indx;	// Palette index
wire			pal_wr_en;	// Palette write enable
wire			pal_rd_en;	// Palette read enable
wire    [15:0]  pal_pix_dat ; // pixel output from pallete RAM

reg go ;

// rgb output assignment - when blank output transmits black pixels, otherwise it transmits pallete data
reg drive_blank_reg ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        drive_blank_reg <= #1 1'b0 ;
    else
        drive_blank_reg <= #1 ( crtc_hblank || crtc_vblank || ~go ) ;
end

assign pad_rgb_o =  drive_blank_reg ? 16'h0000 : pal_pix_dat ;

assign led_o = ssvga_en ;

//
// Read FIFO when blanks are not asserted and fifo has been filled once
//
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        go <= #1 1'b0 ;
    else
    if ( ~ssvga_en )
        go <= #1 1'b0 ;
    else
        go <= #1 ( fifo_full & crtc_hblank & crtc_vblank ) || ( go && ~fifo_empty ) ;
end

assign fifo_rd_en = !crtc_hblank & !crtc_vblank & go ;

assign wbm_restart = go & fifo_empty ;

//
// Palette index is either color index from FIFO or
// address from WISHBONE slave when writing into palette
//
//assign pal_indx = (pal_wr_en || pal_rd_en) ? wbs_adr_i[9:2] : fifo_out;

//
// Instantiation of WISHBONE Master block
//
wire [31:2] pix_start_addr ;
ssvga_wbm_if ssvga_wbm_if(

	// Clock and reset
	.wb_clk_i(wb_clk_i),
	.wb_rst_i(wb_rst_i),

	// WISHBONE Master I/F
	.wbm_cyc_o(wbm_cyc_o),
	.wbm_stb_o(wbm_stb_o),
	.wbm_sel_o(wbm_sel_o),
	.wbm_we_o(wbm_we_o),
	.wbm_adr_o(wbm_adr_o),
	.wbm_dat_o(wbm_dat_o),
	.wbm_cab_o(wbm_cab_o),
	.wbm_dat_i(wbm_dat_i),
	.wbm_ack_i(wbm_ack_i),
	.wbm_err_i(wbm_err_i),
	.wbm_rty_i(wbm_rty_i),

	// FIFO control and other signals
	.ssvga_en(ssvga_en),
	.fifo_full(fifo_full),
	.fifo_wr_en(fifo_wr_en),
	.fifo_dat(fifo_in),
    .pix_start_addr(pix_start_addr),
    .resync(wbm_restart)
);

//
// Instantiation of WISHBONE Slave block
//
wire [15:0] wbs_pal_data ;
ssvga_wbs_if ssvga_wbs_if(

	// Clock and reset
	.wb_clk_i(wb_clk_i),
	.wb_rst_i(wb_rst_i),

	// WISHBONE Slave I/F
	.wbs_cyc_i(wbs_cyc_i),
	.wbs_stb_i(wbs_stb_i),
	.wbs_sel_i(wbs_sel_i),
	.wbs_we_i(wbs_we_i),
	.wbs_adr_i(wbs_adr_i),
	.wbs_dat_i(wbs_dat_i),
	.wbs_cab_i(wbs_cab_i),
	.wbs_dat_o(wbs_dat_o),
	.wbs_ack_o(wbs_ack_o),
	.wbs_err_o(wbs_err_o),
	.wbs_rty_o(wbs_rty_o),

	// Control for other SSVGA blocks
	.ssvga_en(ssvga_en),
	.pal_wr_en(pal_wr_en),
    .pal_rd_en(pal_rd_en),
	.pal_dat(wbs_pal_data),
    .pix_start_addr(pix_start_addr)
);

//
// Instantiation of line FIFO block
//
ssvga_fifo ssvga_fifo(
	.clk(wb_clk_i),
	.rst(wb_rst_i),
	.wr_en(fifo_wr_en),
	.rd_en(fifo_rd_en),
	.dat_i(fifo_in),
	.dat_o(fifo_out),
	.full(fifo_full),
	.empty(fifo_empty),
    .ssvga_en(ssvga_en)
);

//
// Instantiation of 256x16 Palette block
//
RAMB4_S16_S16 ssvga_pallete
(
    .ADDRA(wbs_adr_i[9:2]),
    .DIA(wbs_dat_i[15:0]),
    .ENA(1'b1),
    .RSTA(wb_rst_i),
    .CLKA(wb_clk_i),
    .WEA(pal_wr_en),
    .DOA(wbs_pal_data),
    .ADDRB(fifo_out),
    .DIB(16'h0000),
    .ENB(1'b1),
    .RSTB(wb_rst_i),
    .CLKB(wb_clk_i),
    .WEB(1'b0),
    .DOB(pal_pix_dat)
) ;

/*generic_spram_256x16 ssvga_palette(
	// Generic synchronous single-port RAM interface
	.clk(wb_clk_i),
	.rst(wb_rst_i),
	.ce(1'b1),
	.we(pal_wr_en),
	.oe(1'b1),
	.addr(pal_indx),
	.di(wbs_dat_i[15:0]),
	.do(pad_rgb_o)
);
*/
//
// Instantiation of CRT controller block
//
ssvga_crtc ssvga_crtc(
	.crt_clk(wb_clk_i),
	.rst(wb_rst_i),
	.hsync(pad_hsync_o),
	.vsync(pad_vsync_o),
	.hblank(crtc_hblank),
	.vblank(crtc_vblank)
);

endmodule
