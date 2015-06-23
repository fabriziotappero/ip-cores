////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2010>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
////									////
//// To Do:								////
//// - Everything							////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////
 module 
  Nexys2_T6502_default 
    #( parameter 
      CHIP_ID=32'hf1c2e093,
      CLOCK_FREQ=50,
      CLOCK_PLL_DIV=4,
      CLOCK_PLL_MULT=2,
      CLOCK_PLL_SIZE=4,
      CLOCK_SRC=0,
      JTAG_USER1_RESET=8'h12,
      JTAG_USER1_WIDTH=8,
      PROG_ROM_ADD=7,
      PROG_ROM_WORDS=128,
      RAM_ADD=11,
      RAM_WORDS=2048,
      RESET_SENSE=0,
      ROM_ADD=7,
      ROM_WORDS=128,
      UART_DIV=0,
      UART_PRESCALE=5'b01100,
      UART_PRE_SIZE=5,
      VEC_TABLE=8'hff,
      WIDTH_16=16,
      WIDTH_1=1,
      WIDTH_23=23,
      WIDTH_2=2,
      WIDTH_3=3,
      WIDTH_40=40,
      WIDTH_4=4,
      WIDTH_7=7,
      WIDTH_8=8)
     (
 inout   wire                 EPPWAIT,
 inout   wire                 PS2C,
 inout   wire                 PS2D,
 inout   wire                 USBCLK,
 inout   wire                 USBDIR,
 inout   wire                 USBMODE,
 inout   wire                 USBOE,
 inout   wire                 USBPKTEND,
 inout   wire                 USBWR,
 inout   wire    [ 1 :  0]        USBADR,
 inout   wire    [ 15 :  0]        MEMDB,
 inout   wire    [ 39 :  0]        PIO,
 inout   wire    [ 7 :  0]        EPPDB,
 input   wire                 A_CLK,
 input   wire                 B_CLK,
 input   wire                 CTS,
 input   wire                 EPPASTB,
 input   wire                 EPPDSTB,
 input   wire                 FLASHSTSTS,
 input   wire                 JTAG_TCK,
 input   wire                 JTAG_TDI,
 input   wire                 JTAG_TMS,
 input   wire                 JTAG_TRESET_N,
 input   wire                 RAMWAIT,
 input   wire                 RS_RX,
 input   wire                 RXD,
 input   wire                 USBFLAG,
 input   wire                 USBRDY,
 input   wire    [ 3 :  0]        BTN,
 input   wire    [ 7 :  0]        SW,
 output   wire                 DP,
 output   wire                 FLASHCS,
 output   wire                 FLASHRP,
 output   wire                 HSYNC_N,
 output   wire                 JA_1,
 output   wire                 JA_10,
 output   wire                 JA_2,
 output   wire                 JA_3,
 output   wire                 JA_4,
 output   wire                 JA_7,
 output   wire                 JA_8,
 output   wire                 JA_9,
 output   wire                 JB_1,
 output   wire                 JB_10,
 output   wire                 JB_2,
 output   wire                 JB_3,
 output   wire                 JB_4,
 output   wire                 JB_7,
 output   wire                 JB_8,
 output   wire                 JB_9,
 output   wire                 JC_1,
 output   wire                 JC_10,
 output   wire                 JC_2,
 output   wire                 JC_3,
 output   wire                 JC_4,
 output   wire                 JC_7,
 output   wire                 JC_8,
 output   wire                 JC_9,
 output   wire                 JTAG_TDO,
 output   wire                 MEMOE,
 output   wire                 MEMWR,
 output   wire                 RAMADV,
 output   wire                 RAMCLK,
 output   wire                 RAMCRE,
 output   wire                 RAMCS,
 output   wire                 RAMLB,
 output   wire                 RAMUB,
 output   wire                 RS_TX,
 output   wire                 RTS,
 output   wire                 TXD,
 output   wire                 VSYNC_N,
 output   wire    [ 1 :  0]        VGABLUE,
 output   wire    [ 2 :  0]        VGAGREEN,
 output   wire    [ 2 :  0]        VGARED,
 output   wire    [ 23 :  1]        MEMADR,
 output   wire    [ 3 :  0]        AN,
 output   wire    [ 6 :  0]        SEG,
 output   wire    [ 7 :  0]        LED);
wire                        a_clk_pad_in;
wire                        aux_jtag_capture_dr;
wire                        aux_jtag_select;
wire                        aux_jtag_shift_dr;
wire                        aux_jtag_shiftcapture_dr_clk;
wire                        aux_jtag_tdi;
wire                        aux_jtag_tdo;
wire                        aux_jtag_test_logic_reset;
wire                        aux_jtag_update_dr_clk;
wire                        b_clk_pad_in;
wire                        clk;
wire                        dp_pad_out;
wire                        eppastb_in;
wire                        eppdb_oe;
wire                        eppdstb_in;
wire                        eppwait_in;
wire                        eppwait_oe;
wire                        eppwait_out;
wire                        eppwr_in;
wire                        flashcs_n_out;
wire                        flashrp_n_out;
wire                        flashststs_in;
wire                        ja_10_pad_out;
wire                        ja_1_pad_out;
wire                        ja_2_pad_out;
wire                        ja_3_pad_out;
wire                        ja_4_pad_out;
wire                        ja_7_pad_out;
wire                        ja_8_pad_out;
wire                        ja_9_pad_out;
wire                        jb_10_pad_out;
wire                        jb_1_pad_out;
wire                        jb_2_pad_out;
wire                        jb_3_pad_out;
wire                        jb_4_pad_out;
wire                        jb_7_pad_out;
wire                        jb_8_pad_out;
wire                        jb_9_pad_out;
wire                        jc_10_pad_out;
wire                        jc_1_pad_out;
wire                        jc_2_pad_out;
wire                        jc_3_pad_out;
wire                        jc_4_pad_out;
wire                        jc_7_pad_out;
wire                        jc_8_pad_out;
wire                        jc_9_pad_out;
wire                        jtag_capture_dr;
wire                        jtag_select;
wire                        jtag_shift_dr;
wire                        jtag_shiftcapture_dr_clk;
wire                        jtag_tclk_pad_in;
wire                        jtag_tdi;
wire                        jtag_tdi_pad_in;
wire                        jtag_tdo;
wire                        jtag_tdo_pad_oe;
wire                        jtag_tdo_pad_out;
wire                        jtag_test_logic_reset;
wire                        jtag_tms_pad_in;
wire                        jtag_trst_n_pad_in;
wire                        jtag_update_dr_clk;
wire                        memdb_oe;
wire                        memoe_n_out;
wire                        memwr_n_out;
wire                        one_usec;
wire                        ps2_clk_pad_in;
wire                        ps2_clk_pad_oe;
wire                        ps2_data_pad_in;
wire                        ps2_data_pad_oe;
wire                        ramadv_n_out;
wire                        ramclk_out;
wire                        ramcre_out;
wire                        ramcs_n_out;
wire                        ramlb_n_out;
wire                        ramub_n_out;
wire                        ramwait_in;
wire                        reset;
wire                        rs_rx_pad_in;
wire                        rs_tx_pad_out;
wire                        uart_cts_pad_in;
wire                        uart_rts_pad_out;
wire                        uart_rxd_pad_in;
wire                        uart_txd_pad_out;
wire                        usbadr_oe;
wire                        usbclk_in;
wire                        usbclk_oe;
wire                        usbclk_out;
wire                        usbdir_in;
wire                        usbdir_oe;
wire                        usbdir_out;
wire                        usbflag_in;
wire                        usbmode_in;
wire                        usbmode_oe;
wire                        usbmode_out;
wire                        usboe_in;
wire                        usboe_oe;
wire                        usboe_out;
wire                        usbpktend_in;
wire                        usbpktend_oe;
wire                        usbpktend_out;
wire                        usbrdy_in;
wire                        usbwr_in;
wire                        usbwr_oe;
wire                        usbwr_out;
wire                        vga_hsync_n_pad_out;
wire                        vga_vsync_n_pad_out;
wire     [ 1 :  0]              usbadr_in;
wire     [ 1 :  0]              usbadr_out;
wire     [ 1 :  0]              vga_blue_pad_out;
wire     [ 15 :  0]              memdb_in;
wire     [ 15 :  0]              memdb_out;
wire     [ 2 :  0]              vga_green_pad_out;
wire     [ 2 :  0]              vga_red_pad_out;
wire     [ 23 :  1]              memadr_out;
wire     [ 3 :  0]              an_pad_out;
wire     [ 3 :  0]              btn_pad_in;
wire     [ 39 :  0]              pio_in;
wire     [ 39 :  0]              pio_oe;
wire     [ 39 :  0]              pio_out;
wire     [ 6 :  0]              seg_pad_out;
wire     [ 7 :  0]              eppdb_in;
wire     [ 7 :  0]              eppdb_out;
wire     [ 7 :  0]              led_pad_out;
wire     [ 7 :  0]              sw_pad_in;
cde_pad_in_dig
a_clk_pad 
   (
   .PAD      ( A_CLK  ),
   .pad_in      ( a_clk_pad_in  ));
cde_pad_out_dig
#( .WIDTH (4))
an_pad 
   (
   .PAD      ( AN[3:0]  ),
   .pad_out      ( an_pad_out[3:0]  ));
cde_pad_in_dig
b_clk_pad 
   (
   .PAD      ( B_CLK  ),
   .pad_in      ( b_clk_pad_in  ));
cde_pad_in_dig
#( .WIDTH (4))
btn_pad 
   (
   .PAD      ( BTN[3:0]  ),
   .pad_in      ( btn_pad_in[3:0]  ));
cde_clock_sys
#( .CLOCK_SRC (CLOCK_SRC),
   .FREQ (CLOCK_FREQ),
   .PLL_DIV (CLOCK_PLL_DIV),
   .PLL_MULT (CLOCK_PLL_MULT),
   .PLL_SIZE (CLOCK_PLL_SIZE),
   .RESET_SENSE (RESET_SENSE))
clock_sys 
   (
    .a_clk_pad_in      ( a_clk_pad_in  ),
    .b_clk_pad_in      ( b_clk_pad_in  ),
    .div_clk_out      ( clk  ),
    .one_usec      ( one_usec  ),
    .pwron_pad_in      ( uart_cts_pad_in  ),
    .reset      ( reset  ));
Nexys2_T6502_core
#( .JTAG_USER1_RESET (JTAG_USER1_RESET),
   .JTAG_USER1_WIDTH (JTAG_USER1_WIDTH),
   .PROG_ROM_ADD (PROG_ROM_ADD),
   .PROG_ROM_WORDS (PROG_ROM_WORDS),
   .RAM_ADD (RAM_ADD),
   .RAM_WORDS (RAM_WORDS),
   .ROM_ADD (ROM_ADD),
   .ROM_WORDS (ROM_WORDS),
   .UART_DIV (UART_DIV),
   .UART_PRESCALE (UART_PRESCALE),
   .UART_PRE_SIZE (UART_PRE_SIZE),
   .VEC_TABLE (VEC_TABLE))
core 
   (
    .an_pad_out      ( an_pad_out  ),
    .aux_jtag_capture_dr      ( aux_jtag_capture_dr  ),
    .aux_jtag_select      ( aux_jtag_select  ),
    .aux_jtag_shift_dr      ( aux_jtag_shift_dr  ),
    .aux_jtag_shiftcapture_dr_clk      ( aux_jtag_shiftcapture_dr_clk  ),
    .aux_jtag_tdi      ( aux_jtag_tdi  ),
    .aux_jtag_tdo      ( aux_jtag_tdo  ),
    .aux_jtag_test_logic_reset      ( aux_jtag_test_logic_reset  ),
    .aux_jtag_update_dr_clk      ( aux_jtag_update_dr_clk  ),
    .btn_pad_in      ( btn_pad_in  ),
    .clk      ( clk  ),
    .cts_pad_in      ( uart_cts_pad_in  ),
    .dp_pad_out      ( dp_pad_out  ),
    .eppastb_in      ( eppastb_in  ),
    .eppdb_in      ( eppdb_in  ),
    .eppdb_oe      ( eppdb_oe  ),
    .eppdb_out      ( eppdb_out  ),
    .eppdstb_in      ( eppdstb_in  ),
    .eppwait_in      ( eppwait_in  ),
    .eppwait_oe      ( eppwait_oe  ),
    .eppwait_out      ( eppwait_out  ),
    .eppwr_in      ( eppwr_in  ),
    .flashcs_n_out      ( flashcs_n_out  ),
    .flashrp_n_out      ( flashrp_n_out  ),
    .flashststs_in      ( flashststs_in  ),
    .ja_10_pad_out      ( ja_10_pad_out  ),
    .ja_1_pad_out      ( ja_1_pad_out  ),
    .ja_2_pad_out      ( ja_2_pad_out  ),
    .ja_3_pad_out      ( ja_3_pad_out  ),
    .ja_4_pad_out      ( ja_4_pad_out  ),
    .ja_7_pad_out      ( ja_7_pad_out  ),
    .ja_8_pad_out      ( ja_8_pad_out  ),
    .ja_9_pad_out      ( ja_9_pad_out  ),
    .jb_10_pad_out      ( jb_10_pad_out  ),
    .jb_1_pad_out      ( jb_1_pad_out  ),
    .jb_2_pad_out      ( jb_2_pad_out  ),
    .jb_3_pad_out      ( jb_3_pad_out  ),
    .jb_4_pad_out      ( jb_4_pad_out  ),
    .jb_7_pad_out      ( jb_7_pad_out  ),
    .jb_8_pad_out      ( jb_8_pad_out  ),
    .jb_9_pad_out      ( jb_9_pad_out  ),
    .jc_10_pad_out      ( jc_10_pad_out  ),
    .jc_1_pad_out      ( jc_1_pad_out  ),
    .jc_2_pad_out      ( jc_2_pad_out  ),
    .jc_3_pad_out      ( jc_3_pad_out  ),
    .jc_4_pad_out      ( jc_4_pad_out  ),
    .jc_7_pad_out      ( jc_7_pad_out  ),
    .jc_8_pad_out      ( jc_8_pad_out  ),
    .jc_9_pad_out      ( jc_9_pad_out  ),
    .jtag_capture_dr      ( jtag_capture_dr  ),
    .jtag_select      ( jtag_select  ),
    .jtag_shift_dr      ( jtag_shift_dr  ),
    .jtag_shiftcapture_dr_clk      ( jtag_shiftcapture_dr_clk  ),
    .jtag_tdi      ( jtag_tdi  ),
    .jtag_tdo      ( jtag_tdo  ),
    .jtag_test_logic_reset      ( jtag_test_logic_reset  ),
    .jtag_update_dr_clk      ( jtag_update_dr_clk  ),
    .led_pad_out      ( led_pad_out  ),
    .memadr_out      ( memadr_out  ),
    .memdb_in      ( memdb_in  ),
    .memdb_oe      ( memdb_oe  ),
    .memdb_out      ( memdb_out  ),
    .memoe_n_out      ( memoe_n_out  ),
    .memwr_n_out      ( memwr_n_out  ),
    .one_usec      ( one_usec  ),
    .pio_in      ( pio_in  ),
    .pio_oe      ( pio_oe  ),
    .pio_out      ( pio_out  ),
    .ps2_clk_pad_in      ( ps2_clk_pad_in  ),
    .ps2_clk_pad_oe      ( ps2_clk_pad_oe  ),
    .ps2_data_pad_in      ( ps2_data_pad_in  ),
    .ps2_data_pad_oe      ( ps2_data_pad_oe  ),
    .ramadv_n_out      ( ramadv_n_out  ),
    .ramclk_out      ( ramclk_out  ),
    .ramcre_out      ( ramcre_out  ),
    .ramcs_n_out      ( ramcs_n_out  ),
    .ramlb_n_out      ( ramlb_n_out  ),
    .ramub_n_out      ( ramub_n_out  ),
    .ramwait_in      ( ramwait_in  ),
    .reset      ( reset  ),
    .rs_rx_pad_in      ( rs_rx_pad_in  ),
    .rs_tx_pad_out      ( rs_tx_pad_out  ),
    .rts_pad_out      ( uart_rts_pad_out  ),
    .seg_pad_out      ( seg_pad_out  ),
    .sw_pad_in      ( sw_pad_in  ),
    .uart_rxd_pad_in      ( uart_rxd_pad_in  ),
    .uart_txd_pad_out      ( uart_txd_pad_out  ),
    .usbadr_in      ( usbadr_in  ),
    .usbadr_oe      ( usbadr_oe  ),
    .usbadr_out      ( usbadr_out  ),
    .usbclk_in      ( usbclk_in  ),
    .usbclk_oe      ( usbclk_oe  ),
    .usbclk_out      ( usbclk_out  ),
    .usbdir_in      ( usbdir_in  ),
    .usbdir_oe      ( usbdir_oe  ),
    .usbdir_out      ( usbdir_out  ),
    .usbflag_in      ( usbflag_in  ),
    .usbmode_in      ( usbmode_in  ),
    .usbmode_oe      ( usbmode_oe  ),
    .usbmode_out      ( usbmode_out  ),
    .usboe_in      ( usboe_in  ),
    .usboe_oe      ( usboe_oe  ),
    .usboe_out      ( usboe_out  ),
    .usbpktend_in      ( usbpktend_in  ),
    .usbpktend_oe      ( usbpktend_oe  ),
    .usbpktend_out      ( usbpktend_out  ),
    .usbrdy_in      ( usbrdy_in  ),
    .usbwr_in      ( usbwr_in  ),
    .usbwr_oe      ( usbwr_oe  ),
    .usbwr_out      ( usbwr_out  ),
    .vga_blue_pad_out      ( vga_blue_pad_out  ),
    .vga_green_pad_out      ( vga_green_pad_out  ),
    .vga_hsync_n_pad_out      ( vga_hsync_n_pad_out  ),
    .vga_red_pad_out      ( vga_red_pad_out  ),
    .vga_vsync_n_pad_out      ( vga_vsync_n_pad_out  ));
cde_pad_in_dig
cts_pad 
   (
   .PAD      ( CTS  ),
   .pad_in      ( uart_cts_pad_in  ));
cde_pad_out_dig
dp_pad 
   (
   .PAD      ( DP  ),
   .pad_out      ( dp_pad_out  ));
cde_pad_in_dig
eppastb_pad 
   (
   .PAD      ( EPPASTB  ),
   .pad_in      ( eppastb_in  ));
cde_pad_se_dig
#( .WIDTH (8))
eppdb_pad 
   (
   .PAD      ( EPPDB[7:0]  ),
   .pad_in      ( eppdb_in[7:0]  ),
   .pad_oe      ( eppdb_oe  ),
   .pad_out      ( eppdb_out[7:0]  ));
cde_pad_in_dig
eppdstb_pad 
   (
   .PAD      ( EPPDSTB  ),
   .pad_in      ( eppdstb_in  ));
cde_pad_se_dig
eppwait_pad 
   (
   .PAD      ( EPPWAIT  ),
   .pad_in      ( eppwait_in  ),
   .pad_oe      ( eppwait_oe  ),
   .pad_out      ( eppwait_out  ));
cde_pad_out_dig
flashcs_n_pad 
   (
   .PAD      ( FLASHCS  ),
   .pad_out      ( flashcs_n_out  ));
cde_pad_out_dig
flashrp_n_pad 
   (
   .PAD      ( FLASHRP  ),
   .pad_out      ( flashrp_n_out  ));
cde_pad_in_dig
flashststs_pad 
   (
   .PAD      ( FLASHSTSTS  ),
   .pad_in      ( flashststs_in  ));
cde_pad_out_dig
ja_10_pad 
   (
   .PAD      ( JA_10  ),
   .pad_out      ( ja_10_pad_out  ));
cde_pad_out_dig
ja_1_pad 
   (
   .PAD      ( JA_1  ),
   .pad_out      ( ja_1_pad_out  ));
cde_pad_out_dig
ja_2_pad 
   (
   .PAD      ( JA_2  ),
   .pad_out      ( ja_2_pad_out  ));
cde_pad_out_dig
ja_3_pad 
   (
   .PAD      ( JA_3  ),
   .pad_out      ( ja_3_pad_out  ));
cde_pad_out_dig
ja_4_pad 
   (
   .PAD      ( JA_4  ),
   .pad_out      ( ja_4_pad_out  ));
cde_pad_out_dig
ja_7_pad 
   (
   .PAD      ( JA_7  ),
   .pad_out      ( ja_7_pad_out  ));
cde_pad_out_dig
ja_8_pad 
   (
   .PAD      ( JA_8  ),
   .pad_out      ( ja_8_pad_out  ));
cde_pad_out_dig
ja_9_pad 
   (
   .PAD      ( JA_9  ),
   .pad_out      ( ja_9_pad_out  ));
cde_pad_out_dig
jb_10_pad 
   (
   .PAD      ( JB_10  ),
   .pad_out      ( jb_10_pad_out  ));
cde_pad_out_dig
jb_1_pad 
   (
   .PAD      ( JB_1  ),
   .pad_out      ( jb_1_pad_out  ));
cde_pad_out_dig
jb_2_pad 
   (
   .PAD      ( JB_2  ),
   .pad_out      ( jb_2_pad_out  ));
cde_pad_out_dig
jb_3_pad 
   (
   .PAD      ( JB_3  ),
   .pad_out      ( jb_3_pad_out  ));
cde_pad_out_dig
jb_4_pad 
   (
   .PAD      ( JB_4  ),
   .pad_out      ( jb_4_pad_out  ));
cde_pad_out_dig
jb_7_pad 
   (
   .PAD      ( JB_7  ),
   .pad_out      ( jb_7_pad_out  ));
cde_pad_out_dig
jb_8_pad 
   (
   .PAD      ( JB_8  ),
   .pad_out      ( jb_8_pad_out  ));
cde_pad_out_dig
jb_9_pad 
   (
   .PAD      ( JB_9  ),
   .pad_out      ( jb_9_pad_out  ));
cde_pad_out_dig
jc_10_pad 
   (
   .PAD      ( JC_10  ),
   .pad_out      ( jc_10_pad_out  ));
cde_pad_out_dig
jc_1_pad 
   (
   .PAD      ( JC_1  ),
   .pad_out      ( jc_1_pad_out  ));
cde_pad_out_dig
jc_2_pad 
   (
   .PAD      ( JC_2  ),
   .pad_out      ( jc_2_pad_out  ));
cde_pad_out_dig
jc_3_pad 
   (
   .PAD      ( JC_3  ),
   .pad_out      ( jc_3_pad_out  ));
cde_pad_out_dig
jc_4_pad 
   (
   .PAD      ( JC_4  ),
   .pad_out      ( jc_4_pad_out  ));
cde_pad_out_dig
jc_7_pad 
   (
   .PAD      ( JC_7  ),
   .pad_out      ( jc_7_pad_out  ));
cde_pad_out_dig
jc_8_pad 
   (
   .PAD      ( JC_8  ),
   .pad_out      ( jc_8_pad_out  ));
cde_pad_out_dig
jc_9_pad 
   (
   .PAD      ( JC_9  ),
   .pad_out      ( jc_9_pad_out  ));
cde_jtag_tap
#( .CHIP_ID_VAL (CHIP_ID))
jtag_tap 
   (
   .aux_capture_dr_o      ( aux_jtag_capture_dr  ),
   .aux_select_o      ( aux_jtag_select  ),
   .aux_shift_dr_o      ( aux_jtag_shift_dr  ),
   .aux_shiftcapture_dr_clk_o      ( aux_jtag_shiftcapture_dr_clk  ),
   .aux_tdi_o      ( aux_jtag_tdi  ),
   .aux_tdo_i      ( aux_jtag_tdo  ),
   .aux_test_logic_reset_o      ( aux_jtag_test_logic_reset  ),
   .aux_update_dr_clk_o      ( aux_jtag_update_dr_clk  ),
   .capture_dr_o      ( jtag_capture_dr  ),
   .select_o      ( jtag_select  ),
   .shift_dr_o      ( jtag_shift_dr  ),
   .shiftcapture_dr_clk_o      ( jtag_shiftcapture_dr_clk  ),
   .tdi_o      ( jtag_tdi  ),
   .tdo_i      ( jtag_tdo  ),
   .test_logic_reset_o      ( jtag_test_logic_reset  ),
   .update_dr_clk_o      ( jtag_update_dr_clk  ),
    .tclk_pad_in      ( jtag_tclk_pad_in  ),
    .tdi_pad_in      ( jtag_tdi_pad_in  ),
    .tdo_pad_oe      ( jtag_tdo_pad_oe  ),
    .tdo_pad_out      ( jtag_tdo_pad_out  ),
    .tms_pad_in      ( jtag_tms_pad_in  ),
    .trst_n_pad_in      ( jtag_trst_n_pad_in  ));
cde_pad_in_dig
jtag_tclk_pad 
   (
   .PAD      ( JTAG_TCK  ),
    .pad_in      ( jtag_tclk_pad_in  ));
cde_pad_in_dig
jtag_tdi_pad 
   (
   .PAD      ( JTAG_TDI  ),
    .pad_in      ( jtag_tdi_pad_in  ));
cde_pad_tri_dig
jtag_tdo_pad 
   (
   .PAD      ( JTAG_TDO  ),
    .pad_oe      ( jtag_tdo_pad_oe  ),
    .pad_out      ( jtag_tdo_pad_out  ));
cde_pad_in_dig
jtag_tms_pad 
   (
   .PAD      ( JTAG_TMS  ),
    .pad_in      ( jtag_tms_pad_in  ));
cde_pad_in_dig
jtag_trst_n_pad 
   (
   .PAD      ( JTAG_TRESET_N  ),
    .pad_in      ( jtag_trst_n_pad_in  ));
cde_pad_out_dig
#( .WIDTH (8))
led_pad 
   (
   .PAD      ( LED[7:0]  ),
   .pad_out      ( led_pad_out[7:0]  ));
cde_pad_out_dig
#( .WIDTH (23))
memadr_pad 
   (
   .PAD      ( MEMADR[23:1]  ),
   .pad_out      ( memadr_out[23:1]  ));
cde_pad_se_dig
#( .WIDTH (16))
memdb_pad 
   (
   .PAD      ( MEMDB[15:0]  ),
   .pad_in      ( memdb_in[15:0]  ),
   .pad_oe      ( memdb_oe  ),
   .pad_out      ( memdb_out[15:0]  ));
cde_pad_out_dig
memoe_n_pad 
   (
   .PAD      ( MEMOE  ),
   .pad_out      ( memoe_n_out  ));
cde_pad_out_dig
memwr_n_pad 
   (
   .PAD      ( MEMWR  ),
   .pad_out      ( memwr_n_out  ));
cde_pad_se0_dig
#( .WIDTH (40))
pio_pad 
   (
   .PAD      ( PIO[39:0]  ),
   .pad_in      ( pio_in[39:0]  ),
   .pad_oe      ( pio_oe[39:0]  ),
   .pad_out      ( pio_out[39:0]  ));
cde_pad_od_dig
ps2_clk_pad 
   (
   .PAD      ( PS2C  ),
   .pad_in      ( ps2_clk_pad_in  ),
   .pad_oe      ( ps2_clk_pad_oe  ));
cde_pad_od_dig
ps2_data_pad 
   (
   .PAD      ( PS2D  ),
   .pad_in      ( ps2_data_pad_in  ),
   .pad_oe      ( ps2_data_pad_oe  ));
cde_pad_out_dig
ramadv_n_pad 
   (
   .PAD      ( RAMADV  ),
   .pad_out      ( ramadv_n_out  ));
cde_pad_out_dig
ramclk_pad 
   (
   .PAD      ( RAMCLK  ),
   .pad_out      ( ramclk_out  ));
cde_pad_out_dig
ramcre_pad 
   (
   .PAD      ( RAMCRE  ),
   .pad_out      ( ramcre_out  ));
cde_pad_out_dig
ramcs_n_pad 
   (
   .PAD      ( RAMCS  ),
   .pad_out      ( ramcs_n_out  ));
cde_pad_out_dig
ramlb_n_pad 
   (
   .PAD      ( RAMLB  ),
   .pad_out      ( ramlb_n_out  ));
cde_pad_out_dig
ramub_n_pad 
   (
   .PAD      ( RAMUB  ),
   .pad_out      ( ramub_n_out  ));
cde_pad_in_dig
ramwait_pad 
   (
   .PAD      ( RAMWAIT  ),
   .pad_in      ( ramwait_in  ));
cde_pad_in_dig
rs_rx_pad 
   (
   .PAD      ( RS_RX  ),
   .pad_in      ( rs_rx_pad_in  ));
cde_pad_out_dig
rs_tx_pad 
   (
   .PAD      ( RS_TX  ),
   .pad_out      ( rs_tx_pad_out  ));
cde_pad_out_dig
rts_pad 
   (
   .PAD      ( RTS  ),
   .pad_out      ( uart_rts_pad_out  ));
cde_pad_in_dig
rxd_pad 
   (
   .PAD      ( RXD  ),
   .pad_in      ( uart_rxd_pad_in  ));
cde_pad_out_dig
#( .WIDTH (7))
seg_pad 
   (
   .PAD      ( SEG[6:0]  ),
   .pad_out      ( seg_pad_out[6:0]  ));
cde_pad_in_dig
#( .WIDTH (8))
sw_pad 
   (
   .PAD      ( SW[7:0]  ),
   .pad_in      ( sw_pad_in[7:0]  ));
cde_pad_out_dig
txd_pad 
   (
   .PAD      ( TXD  ),
   .pad_out      ( uart_txd_pad_out  ));
cde_pad_se_dig
#( .WIDTH (2))
usbadr_pad 
   (
   .PAD      ( USBADR[1:0]  ),
   .pad_in      ( usbadr_in[1:0]  ),
   .pad_oe      ( usbadr_oe  ),
   .pad_out      ( usbadr_out[1:0]  ));
cde_pad_se_dig
usbclk_pad 
   (
   .PAD      ( USBCLK  ),
   .pad_in      ( usbclk_in  ),
   .pad_oe      ( usbclk_oe  ),
   .pad_out      ( usbclk_out  ));
cde_pad_se_dig
usbdir_pad 
   (
   .PAD      ( USBDIR  ),
   .pad_in      ( usbdir_in  ),
   .pad_oe      ( usbdir_oe  ),
   .pad_out      ( usbdir_out  ));
cde_pad_in_dig
usbflag_pad 
   (
   .PAD      ( USBFLAG  ),
   .pad_in      ( usbflag_in  ));
cde_pad_se_dig
usbmode_pad 
   (
   .PAD      ( USBMODE  ),
   .pad_in      ( usbmode_in  ),
   .pad_oe      ( usbmode_oe  ),
   .pad_out      ( usbmode_out  ));
cde_pad_se_dig
usboe_pad 
   (
   .PAD      ( USBOE  ),
   .pad_in      ( usboe_in  ),
   .pad_oe      ( usboe_oe  ),
   .pad_out      ( usboe_out  ));
cde_pad_se_dig
usbpktend_pad 
   (
   .PAD      ( USBPKTEND  ),
   .pad_in      ( usbpktend_in  ),
   .pad_oe      ( usbpktend_oe  ),
   .pad_out      ( usbpktend_out  ));
cde_pad_in_dig
usbrdy_pad 
   (
   .PAD      ( USBRDY  ),
   .pad_in      ( usbrdy_in  ));
cde_pad_se_dig
usbwr_pad 
   (
   .PAD      ( USBWR  ),
   .pad_in      ( usbwr_in  ),
   .pad_oe      ( usbwr_oe  ),
   .pad_out      ( usbwr_out  ));
cde_pad_out_dig
#( .WIDTH (2))
vga_blue_pad 
   (
   .PAD      ( VGABLUE[1:0]  ),
   .pad_out      ( vga_blue_pad_out[1:0]  ));
cde_pad_out_dig
#( .WIDTH (3))
vga_green_pad 
   (
   .PAD      ( VGAGREEN[2:0]  ),
   .pad_out      ( vga_green_pad_out[2:0]  ));
cde_pad_out_dig
vga_hsync_n_pad 
   (
   .PAD      ( HSYNC_N  ),
   .pad_out      ( vga_hsync_n_pad_out  ));
cde_pad_out_dig
#( .WIDTH (3))
vga_red_pad 
   (
   .PAD      ( VGARED[2:0]  ),
   .pad_out      ( vga_red_pad_out[2:0]  ));
cde_pad_out_dig
vga_vsync_n_pad 
   (
   .PAD      ( VSYNC_N  ),
   .pad_out      ( vga_vsync_n_pad_out  ));
  endmodule
