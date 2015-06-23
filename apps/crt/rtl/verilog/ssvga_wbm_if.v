//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  LITTLE-ENDIAN WISHBONE master interface.                    ////
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
// Revision 1.2  2002/02/01 15:24:46  mihad
// Repaired a few bugs, updated specification, added test bench files and design document
//
// Revision 1.1.1.1  2001/10/02 15:33:33  mihad
// New project directory structure
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ssvga_defines.v"

module ssvga_wbm_if(
	// Clock and reset
	wb_clk_i, wb_rst_i,

	// WISHBONE Master I/F
	wbm_cyc_o, wbm_stb_o, wbm_sel_o, wbm_we_o,
	wbm_adr_o, wbm_dat_o, wbm_cab_o,
	wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_rty_i,

	// Other signals
	ssvga_en, fifo_full,
	fifo_wr_en, fifo_dat,
    pix_start_addr, resync
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
// Other signals
//
input			ssvga_en;	// Global enable
input			fifo_full;	// FIFO is full
output			fifo_wr_en;	// FIFO write enable
output	[31:0]		fifo_dat;	// FIFO data
input   [31:2]  pix_start_addr ;
input           resync ;    // when pixel buffer underrun occures, master must resynchronize operation to start of screen

//
// Internal regs and wires
//
reg	[`SSVGA_VMCW-1:0] vmaddr_r;	// Video memory address counter
//reg	[31:0]		shift_r;	// Shift register
//reg	[1:0]		shift_empty_r;	// Shift register empty flags

// frame finished indicator - whenever video memory address shows 640x480 pixels read
reg  frame_read ;
wire frame_read_in = ( vmaddr_r == `SSVGA_VMCW'h0_00_00 ) & wbm_ack_i & wbm_stb_o || ~ssvga_en || resync ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if (wb_rst_i)
        frame_read <= #1 1'b0 ;
    else
        frame_read <= #1 frame_read_in ;
end

//
// Video memory address generation
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		vmaddr_r <= #1 ((`PIXEL_NUM/4)-1) ;
	else if (frame_read)
		vmaddr_r <= #1 ((`PIXEL_NUM/4)-1);
	else if (wbm_ack_i & wbm_stb_o)
		vmaddr_r <= #1 vmaddr_r - 1;

reg [31:2] wbm_adr ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if (wb_rst_i)
		wbm_adr <= #1 30'h0000_0000 ;
    else if (frame_read)
        wbm_adr <= #1 pix_start_addr ;
    else if (wbm_ack_i & wbm_stb_o)
        wbm_adr <= #1 wbm_adr + 1 ;
end

//
// Shift register
//
/*always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		shift_r <= #1 32'h0000_0000;
	else if (wbm_ack_i & wbm_cyc_o)
		shift_r <= #1 wbm_dat_i;
	else if (!fifo_full)
		shift_r <= #1 {16'h00, shift_r[31:16]};

//
// Shift register empty flags
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		shift_empty_r <= #1 2'b11 ;
	else if (wbm_ack_i & wbm_cyc_o)
		shift_empty_r <= #1 2'b00;
	else if (!fifo_full)
		shift_empty_r <= #1 {1'b1, shift_empty_r[1]};
*/
//
// Generate WISHBONE output signals
//
assign wbm_cyc_o = ssvga_en & !frame_read ;
assign wbm_stb_o = wbm_cyc_o & !fifo_full;
assign wbm_sel_o = 4'b1111;
assign wbm_we_o = 1'b0;
assign wbm_adr_o = {wbm_adr, 2'b00};
assign wbm_dat_o = 32'h0000_0000;
assign wbm_cab_o = 1'b1;

//
// Generate other signals
//
assign fifo_wr_en = wbm_ack_i & wbm_stb_o ;
assign fifo_dat = wbm_dat_i ;

endmodule
