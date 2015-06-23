//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_top.v                                                   ////
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
// Revision 1.5  2003/06/30 15:29:27  simons
// Error fixed again.
//
// Revision 1.4  2003/06/30 15:25:45  simons
// Error fixed.
//
// Revision 1.3  2003/05/28 16:27:09  simons
// Change the address width.
//
// Revision 1.2  2002/04/09 13:21:15  mihad
// Added mouse interface and everything for its handling, cleaned up some unused code
//
// Revision 1.1.1.1  2002/02/18 16:16:56  mihad
// Initial project import - working
//
//

`include "ps2_defines.v"
// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_top
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

    ps2_kbd_clk_pad_i,
    ps2_kbd_data_pad_i,
    ps2_kbd_clk_pad_o,
    ps2_kbd_data_pad_o,
    ps2_kbd_clk_pad_oe_o,
    ps2_kbd_data_pad_oe_o
    `ifdef PS2_AUX
    ,
    wb_intb_o,

    ps2_aux_clk_pad_i,
    ps2_aux_data_pad_i,
    ps2_aux_clk_pad_o,
    ps2_aux_data_pad_o,
    ps2_aux_clk_pad_oe_o,
    ps2_aux_data_pad_oe_o
    `endif
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0] wb_sel_i ;

input [3:0] wb_adr_i ;
input [31:0] wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o ;

output wb_int_o ;

input ps2_kbd_clk_pad_i,
      ps2_kbd_data_pad_i ;

output ps2_kbd_clk_pad_o,
       ps2_kbd_data_pad_o,
       ps2_kbd_clk_pad_oe_o,
       ps2_kbd_data_pad_oe_o ;

`ifdef PS2_AUX
output wb_intb_o ;
input ps2_aux_clk_pad_i,
      ps2_aux_data_pad_i ;

output ps2_aux_clk_pad_o,
       ps2_aux_data_pad_o,
       ps2_aux_clk_pad_oe_o,
       ps2_aux_data_pad_oe_o ;

assign ps2_aux_clk_pad_o  = 1'b0 ;
assign ps2_aux_data_pad_o = 1'b0 ;
`endif

wire rx_released,
     rx_kbd_data_ready,
     rx_translated_data_ready,
     rx_kbd_read_wb,
     rx_kbd_read_tt,
     tx_kbd_write,
     tx_kbd_write_ack,
     tx_error_no_keyboard_ack,
     ps2_ctrl_kbd_data_en_,
     ps2_ctrl_kbd_clk_en_,
     ps2_ctrl_kbd_clk,
     inhibit_kbd_if ;

wire [15:0] devide_reg;

wire [7:0] rx_scan_code,
           rx_translated_scan_code,
           tx_kbd_data ;

assign ps2_kbd_clk_pad_o  = 1'b0 ;
assign ps2_kbd_data_pad_o = 1'b0 ;

ps2_io_ctrl i_ps2_io_ctrl_keyboard
(
    .clk_i               (wb_clk_i),
    .rst_i               (wb_rst_i),
    .ps2_ctrl_clk_en_i_  (ps2_ctrl_kbd_clk_en_),
    .ps2_ctrl_data_en_i_ (ps2_ctrl_kbd_data_en_),
    .ps2_clk_pad_i       (ps2_kbd_clk_pad_i),
    .ps2_clk_pad_oe_o    (ps2_kbd_clk_pad_oe_o),
    .ps2_data_pad_oe_o   (ps2_kbd_data_pad_oe_o),
    .inhibit_if_i        (inhibit_kbd_if),
    .ps2_ctrl_clk_o      (ps2_ctrl_kbd_clk)
);

`ifdef PS2_AUX
wire rx_aux_data_ready,
     rx_aux_read,
     tx_aux_write,
     tx_aux_write_ack,
     tx_error_no_aux_ack,
     ps2_ctrl_aux_data_en_,
     ps2_ctrl_aux_clk_en_,
     ps2_ctrl_aux_clk,
     inhibit_aux_if ;

wire [7:0] rx_aux_data,
           tx_aux_data ;

ps2_io_ctrl i_ps2_io_ctrl_auxiliary
(
    .clk_i               (wb_clk_i),
    .rst_i               (wb_rst_i),
    .ps2_ctrl_clk_en_i_  (ps2_ctrl_aux_clk_en_),
    .ps2_ctrl_data_en_i_ (ps2_ctrl_aux_data_en_),
    .ps2_clk_pad_i       (ps2_aux_clk_pad_i),
    .ps2_clk_pad_oe_o    (ps2_aux_clk_pad_oe_o),
    .ps2_data_pad_oe_o   (ps2_aux_data_pad_oe_o),
    .inhibit_if_i        (inhibit_aux_if),
    .ps2_ctrl_clk_o      (ps2_ctrl_aux_clk)
);

ps2_mouse #(`PS2_TIMER_60USEC_VALUE_PP, `PS2_TIMER_60USEC_BITS_PP, `PS2_TIMER_5USEC_VALUE_PP, `PS2_TIMER_5USEC_BITS_PP)
i_ps2_mouse
(
    .clk                         (wb_clk_i),
    .reset                       (wb_rst_i),
    .ps2_clk_en_o_               (ps2_ctrl_aux_clk_en_),
    .ps2_data_en_o_              (ps2_ctrl_aux_data_en_),
    .ps2_clk_i                   (ps2_ctrl_aux_clk),
    .ps2_data_i                  (ps2_aux_data_pad_i),
    .rx_scan_code                (rx_aux_data),
    .rx_data_ready               (rx_aux_data_ready),
    .rx_read                     (rx_aux_read),
    .tx_data                     (tx_aux_data),
    .tx_write                    (tx_aux_write),
    .tx_write_ack_o              (tx_aux_write_ack),
    .tx_error_no_ack             (tx_error_no_aux_ack),
    .devide_reg_i                (devide_reg)
);

`endif

ps2_keyboard #(`PS2_TIMER_60USEC_VALUE_PP, `PS2_TIMER_60USEC_BITS_PP, `PS2_TIMER_5USEC_VALUE_PP, `PS2_TIMER_5USEC_BITS_PP)
i_ps2_keyboard
(
    .clk                         (wb_clk_i),
    .reset                       (wb_rst_i),
    .ps2_clk_en_o_               (ps2_ctrl_kbd_clk_en_),
    .ps2_data_en_o_              (ps2_ctrl_kbd_data_en_),
    .ps2_clk_i                   (ps2_ctrl_kbd_clk),
    .ps2_data_i                  (ps2_kbd_data_pad_i),
    .rx_released                 (rx_released),
    .rx_scan_code                (rx_scan_code),
    .rx_data_ready               (rx_kbd_data_ready),
    .rx_read                     (rx_kbd_read_tt),
    .tx_data                     (tx_kbd_data),
    .tx_write                    (tx_kbd_write),
    .tx_write_ack_o              (tx_kbd_write_ack),
    .tx_error_no_keyboard_ack    (tx_error_no_keyboard_ack),
    .translate                   (translate),
    .devide_reg_i                (devide_reg)
);

ps2_wb_if i_ps2_wb_if
(
    .wb_clk_i                      (wb_clk_i),
    .wb_rst_i                      (wb_rst_i),
    .wb_cyc_i                      (wb_cyc_i),
    .wb_stb_i                      (wb_stb_i),
    .wb_we_i                       (wb_we_i),
    .wb_sel_i                      (wb_sel_i),
    .wb_adr_i                      (wb_adr_i),
    .wb_dat_i                      (wb_dat_i),
    .wb_dat_o                      (wb_dat_o),
    .wb_ack_o                      (wb_ack_o),

    .wb_int_o                      (wb_int_o),

    .devide_reg_o                  (devide_reg),   

    .rx_scancode_i                 (rx_translated_scan_code),
    .rx_kbd_data_ready_i           (rx_translated_data_ready),
    .rx_kbd_read_o                 (rx_kbd_read_wb),
    .tx_kbd_data_o                 (tx_kbd_data),
    .tx_kbd_write_o                (tx_kbd_write),
    .tx_kbd_write_ack_i            (tx_kbd_write_ack),
    .translate_o                   (translate),
    .ps2_kbd_clk_i                 (ps2_kbd_clk_pad_i),
    .inhibit_kbd_if_o              (inhibit_kbd_if)
    `ifdef PS2_AUX
    ,
    .wb_intb_o                     (wb_intb_o),

    .rx_aux_data_i                 (rx_aux_data),
    .rx_aux_data_ready_i           (rx_aux_data_ready),
    .rx_aux_read_o                 (rx_aux_read),
    .tx_aux_data_o                 (tx_aux_data),
    .tx_aux_write_o                (tx_aux_write),
    .tx_aux_write_ack_i            (tx_aux_write_ack),
    .ps2_aux_clk_i                 (ps2_aux_clk_pad_i),
    .inhibit_aux_if_o              (inhibit_aux_if)
    `endif
) ;

ps2_translation_table i_ps2_translation_table
(
    .reset_i                    (wb_rst_i),
    .clock_i                    (wb_clk_i),
    .translate_i                (translate),
    .code_i                     (rx_scan_code),
    .code_o                     (rx_translated_scan_code),
    .address_i                  (8'h00),
    .data_i                     (8'h00),
    .we_i                       (1'b0),
    .re_i                       (1'b0),
    .data_o                     (),
    .rx_data_ready_i            (rx_kbd_data_ready),
    .rx_translated_data_ready_o (rx_translated_data_ready),
    .rx_read_i                  (rx_kbd_read_wb),
    .rx_read_o                  (rx_kbd_read_tt),
    .rx_released_i              (rx_released)
) ;

endmodule // ps2_top
