//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: top_lpc_7seg.v,v 1.2 2008-07-26 19:15:29 hharte Exp $  ////
////  top_lpc_7seg.v - LPC Peripheral to 7-Segment Display for    ////
////  Enterpoint Raggedstone1 card.                               ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
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

module lpc_7seg
(
    RST, // Active Low (From PCI bus)
    DISP_SEL,
    DISP_LED,
    
    LPC_CLK,
    LFRAME,
    LAD,
    LAD_OE
);

input          RST ;

output   [3:0] DISP_SEL ;
output   [6:0] DISP_LED ;

input          LPC_CLK;
input          LFRAME;
inout    [3:0] LAD;
output         LAD_OE;

wire     [2:0] dma_chan_i = 3'b000; 
wire           dma_tc_i = 1'b0; 
wire     [3:0] lad_i; 
wire     [3:0] lad_o; 
wire           periph_lad_oe;

assign LAD = (periph_lad_oe ? lad_o : 4'bzzzz);
assign LAD_OE = periph_lad_oe;

wire    [24:0] wb_adr_o;
wire    [31:0] wb_dat_i;
wire    [31:0] wb_dat_o;
wire     [3:0] wb_sel_o;
wire           wb_we_o;
wire           wb_stb_o;
wire           wb_cyc_o;
wire           wb_ack_i;
wire           wb_rty_i;
wire           wb_err_i;
wire           wb_int_i;

// Instantiate the module
wb_lpc_periph lpc_periph (
    .clk_i(LPC_CLK), 
    .nrst_i(RST), 
    .wbm_adr_o(wb_adr_o), 
    .wbm_dat_o(wb_dat_o), 
    .wbm_dat_i(wb_dat_i), 
    .wbm_sel_o(wb_sel_o), 
    .wbm_tga_o(wb_tga_o), 
    .wbm_we_o(wb_we_o), 
    .wbm_stb_o(wb_stb_o), 
    .wbm_cyc_o(wb_cyc_o), 
    .wbm_ack_i(wb_ack_i), 
    .wbm_err_i(wb_err_i), 	 
    .dma_chan_o(dma_chan_i), 
    .dma_tc_o(dma_tc_i), 
    .lframe_i(~LFRAME), 
    .lad_i(LAD), 
    .lad_o(lad_o), 
    .lad_oe(periph_lad_oe)
    );

// Instantiate the 7-Segment module
wb_7seg seven_seg0 (
    .clk_i(LPC_CLK), 
    .nrst_i(RST), 
    .wb_adr_i(wb_adr_o), 
    .wb_dat_o(wb_dat_i), 
    .wb_dat_i(wb_dat_o), 
    .wb_sel_i(wb_sel_o), 
    .wb_we_i(wb_we_o), 
    .wb_stb_i(wb_stb_o), 
    .wb_cyc_i(wb_cyc_o), 
    .wb_ack_o(wb_ack_i), 
    .wb_err_o(wb_err_i), 
    .wb_int_o(wb_int_i), 
    .DISP_SEL(DISP_SEL), 
    .DISP_LED(DISP_LED)
    );

endmodule
