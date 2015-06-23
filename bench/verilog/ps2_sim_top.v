//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_sim_top.v                                               ////
////                                                              ////
////  This file is part of the "ps2" project                      ////
////  http://www.opencores.org/cores/ps2/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
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
// Revision 1.4  2003/07/01 12:33:45  mihad
// Added an option to use constant values instead of RAM
// in the translation table.
//
// Revision 1.3  2003/05/28 16:26:51  simons
// Change the address width.
//
// Revision 1.2  2002/04/09 13:16:04  mihad
// Mouse interface added
//
// Revision 1.1.1.1  2002/02/18 16:16:55  mihad
// Initial project import - working
//
//

`include "ps2_defines.v"
module ps2_sim_top
(
    wb_clk_i,
    wb_rst_i,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_sel_i,
    wb_adr_i,
    wb_dat_i,
    wb_dat_o,
    wb_ack_o,

    wb_int_o,

    ps2_kbd_clk_io,
    ps2_kbd_data_io

    `ifdef PS2_AUX
    ,
    wb_intb_o,

    ps2_aux_clk_io,
    ps2_aux_data_io
    `endif
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0] wb_sel_i ;

input [3:0]  wb_adr_i ;
input [31:0] wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o,
       wb_int_o ;

inout  ps2_kbd_clk_io,
       ps2_kbd_data_io ;
`ifdef PS2_AUX
output wb_intb_o ;
inout  ps2_aux_clk_io ;
inout  ps2_aux_data_io ;
`endif

wire ps2_kbd_clk_pad_i  = ps2_kbd_clk_io ;
wire ps2_kbd_data_pad_i = ps2_kbd_data_io ;

wire ps2_kbd_clk_pad_o,
     ps2_kbd_data_pad_o,
     ps2_kbd_clk_pad_oe_o,
     ps2_kbd_data_pad_oe_o ;

ps2_top i_ps2_top
(
    .wb_clk_i              (wb_clk_i),
    .wb_rst_i              (wb_rst_i),
    .wb_cyc_i              (wb_cyc_i),
    .wb_stb_i              (wb_stb_i),
    .wb_we_i               (wb_we_i),
    .wb_sel_i              (wb_sel_i),
    .wb_adr_i              (wb_adr_i),
    .wb_dat_i              (wb_dat_i),
    .wb_dat_o              (wb_dat_o),
    .wb_ack_o              (wb_ack_o),

    .wb_int_o              (wb_int_o),

    .ps2_kbd_clk_pad_i     (ps2_kbd_clk_pad_i),
    .ps2_kbd_data_pad_i    (ps2_kbd_data_pad_i),
    .ps2_kbd_clk_pad_o     (ps2_kbd_clk_pad_o),
    .ps2_kbd_data_pad_o    (ps2_kbd_data_pad_o),
    .ps2_kbd_clk_pad_oe_o  (ps2_kbd_clk_pad_oe_o),
    .ps2_kbd_data_pad_oe_o (ps2_kbd_data_pad_oe_o)

    `ifdef PS2_AUX
    ,
    .wb_intb_o (wb_intb_o),

    .ps2_aux_clk_pad_i (ps2_aux_clk_io),
    .ps2_aux_data_pad_i (ps2_aux_data_io),
    .ps2_aux_clk_pad_o (ps2_aux_clk_pad_o),
    .ps2_aux_data_pad_o (ps2_aux_data_pad_o),
    .ps2_aux_clk_pad_oe_o (ps2_aux_clk_pad_oe_o),
    .ps2_aux_data_pad_oe_o (ps2_aux_data_pad_oe_o)
    `endif
) ;

assign ps2_kbd_clk_io  = ps2_kbd_clk_pad_oe_o  ? ps2_kbd_clk_pad_o  : 1'bz ;
assign ps2_kbd_data_io = ps2_kbd_data_pad_oe_o ? ps2_kbd_data_pad_o : 1'bz ;

`ifdef PS2_AUX
assign ps2_aux_clk_io  = ps2_aux_clk_pad_oe_o  ? ps2_aux_clk_pad_o  : 1'bz ;
assign ps2_aux_data_io = ps2_aux_data_pad_oe_o ? ps2_aux_data_pad_o : 1'bz ;
`endif
endmodule
