//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart16550                                                   ////
////                                                              ////
////  Description                                                 ////
////  16550 compatibel uart on a wishbone bus                     ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      -                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_defines.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  Defines of the Core                                         ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None                                                        ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing.                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// 2011/10/01  Split into 8 bit and 32 bit versions
//             always provide baudrate output enable
//             converted PRESCALER_PRESET from `define to parameter
//             Removed unused `defines, added back LITTLE_ENDIAN
//             Removed all # delays for non-blocking statement
//             Changed all module names to start with `VARIANT
//             Converted reset from async to sync
//             jt_eaton
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.13  2003/06/11 16:37:47  gorban
// This fixes errors in some cases when data is being read and put to the FIFO at the same time. Patch is submitted by Scott Furman. Update is very recommended.
//
// Revision 1.12  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.10  2001/12/11 08:55:40  mohor
// Scratch register define added.
//
// Revision 1.9  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.8  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.7  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.6  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.5  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.4  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.3  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:11+02  jacob
// Initial revision
//
//
// Interrupt Enable register bits
 // Received Data available interrupt
 // Transmitter Holding Register empty interrupt
 // Receiver Line Status Interrupt
 // Modem Status Interrupt
// Interrupt Identification register bits
 // Interrupt pending when 0
 // Interrupt identification
// Interrupt identification values for bits 3:1
 // Receiver Line Status
 // Receiver Data available
 // Timeout Indication
 // Transmitter Holding Register empty
 // Modem Status
// FIFO Control Register bits
 // Trigger level
// FIFO trigger level values
// Line Control register bits
 // bits in character
 // stop bits
 // parity enable
 // even parity
 // stick parity
 // Break control
 // Divisor Latch access bit
// Modem Control register bits
 // Loopback mode
// Line Status Register bits
 // Data ready
 // Overrun Error
 // Parity Error
 // Framing Error
 // Break interrupt
 // Transmit FIFO is empty
 // Transmitter Empty indicator
 // Error indicator
// Modem Status Register bits
 // Delta signals
 // Complement signals
// FIFO parameter defines
// receiver fifo has width 11 because it has break, parity and framing error bits
// Defines hard baud prescaler register - uncomment to enable
//`define PRESCALER_PRESET_HARD
// 115200 baud preset values
// 20MHz: prescaler 10.8 (11, rounded up)
//`define PRESCALER_HIGH_PRESET 8'd0
//`define PRESCALER_LOW_PRESET 8'd11
// 50MHz: prescaler 27.1
//`define PRESCALER_HIGH_PRESET 8'd0
//`define PRESCALER_LOW_PRESET 8'd27
 module 
  wb_uart16550_bus16_big 
    #( parameter 
      PRESCALER_PRESET=16'h1234,
      wb_addr_width=8,
      wb_byte_lanes=2,
      wb_data_width=16)
     (
 input   wire                 cts_pad_i,
 input   wire                 dcd_pad_i,
 input   wire                 dsr_pad_i,
 input   wire                 ri_pad_i,
 input   wire                 srx_pad_i,
 input   wire                 wb_clk_i,
 input   wire                 wb_cyc_i,
 input   wire                 wb_rst_i,
 input   wire                 wb_stb_i,
 input   wire                 wb_we_i,
 input   wire    [ 1 :  0]        wb_sel_i,
 input   wire    [ 15 :  0]        wb_dat_i,
 input   wire    [ 7 :  1]        wb_adr_i,
 output   wire                 baud_o,
 output   wire                 dtr_pad_o,
 output   wire                 int_o,
 output   wire                 rts_pad_o,
 output   wire                 stx_pad_o,
 output   wire                 wb_ack_o,
 output   wire    [ 15 :  0]        wb_dat_o);
   wire [7:0]                      rb_dll_rdata;
   wire [7:0]                      ie_dlh_rdata;
   wire [7:0]                      tr_reg_wdata;
   wire [3:0]                      ie_reg_wdata;
   wire [15:0]                     dl_reg_wdata;
   wire [7:0]                      scratch;
   wire [3:0]                      ier;
   wire [3:0]                      iir;
   wire [7:0]                      fcr;
   wire [4:0]                      mcr;
   wire [7:0]                      lcr;
   wire [7:0]                      msr;
   wire [7:0]                      lsr;
   wire [5-1:0] rf_count;
   wire [5-1:0] tf_count;
   wire [2:0]                      tstate;
   wire [3:0]                      rstate; 
   wire                            we_o;
   wire                            re_o;
   wire                            tr_reg_wr;
   wire                            rb_dll_reg_dec;
   wire                            ls_reg_dec;
   wire                            ms_reg_dec;
   wire                            ii_reg_dec;
   wire                            ie_reg_wr;
   wb_uart16550_bus16_big_wb_fsm  wb_interface
     (
      .clk         ( wb_clk_i    ),
      .wb_rst_i    ( wb_rst_i    ),
      .wb_we_i     ( wb_we_i     ),
      .wb_stb_i    ( wb_stb_i    ),
      .wb_cyc_i    ( wb_cyc_i    ),
      .wb_ack_o    ( wb_ack_o    ),
      .we_o        ( we_o        ),
      .re_o        ( re_o        )
      );
 wb_uart16550_bus16_big_wb
#(.LC_REG_RST(8'b00000011),
  .II_REG_PAD(4'b1100),
  .FC_REG_RST(8'b11000000)
)
 micro_reg (
            .clk              ( wb_clk_i           ),
            .reset            ( wb_rst_i           ),
            .enable           (1'b1                ),
            .cs               ( wb_cyc_i           ),
            .wr               ( wb_we_i            ),
            .rd               (~wb_we_i            ),
            .addr             ( wb_adr_i           ),
            .byte_lanes       ( wb_sel_i           ),
            .wdata            ( wb_dat_i           ),
            .rdata            ( wb_dat_o           ),
            .rb_dll_reg_rdata ( rb_dll_rdata       ),
            .rb_dll_reg_dec   ( rb_dll_reg_dec     ),
            .tr_reg_wr_0      ( tr_reg_wr          ),
            .tr_reg_wdata     ( tr_reg_wdata       ),
            .dll_reg_wdata    ( dl_reg_wdata[7:0]  ),
            .dlh_reg_wdata    ( dl_reg_wdata[15:8] ),
            .ls_reg_dec       ( ls_reg_dec         ),
            .ms_reg_dec       ( ms_reg_dec         ),
            .ii_reg_dec       ( ii_reg_dec         ),
            .ie_dlh_reg_rdata ( ie_dlh_rdata       ),
            .ie_reg_wr_0      ( ie_reg_wr          ),
            .ie_reg_wdata     ( ie_reg_wdata       ),
            .ii_reg_rdata     ( iir                ),
            .fc_reg           ( fcr                ),
            .next_fc_reg      ( {fcr[7:6],6'h00}   ),
            .lc_reg           ( lcr                ),
            .lc_reg_rdata     ( lcr                ),
            .next_lc_reg      ( lcr                ),
            .mc_reg           ( mcr                ),
            .mc_reg_rdata     ( mcr                ),
            .next_mc_reg      ( mcr                ),
            .ls_reg_rdata     ( lsr                ),
            .ms_reg_rdata     ( msr                ),
            .sr_reg           ( scratch            ),
            .sr_reg_rdata     ( scratch            ),
            .next_sr_reg      ( scratch            ),
            .rb_dll_reg_cs    (                    ),
            .tr_reg_cs        (                    ),
            .tr_reg_dec       (                    ),
            .ie_dlh_reg_cs    (                    ),
            .ie_dlh_reg_dec   (                    ),
            .ie_reg_cs        (                    ),
            .ie_reg_dec       (                    ),
            .dll_reg_cs       (                    ),
            .dll_reg_dec      (                    ),
            .dll_reg_wr_0     (                    ),
            .dlh_reg_cs       (                    ),
            .dlh_reg_dec      (                    ),
            .dlh_reg_wr_0     (                    ),
            .ii_reg_cs        (                    ),
            .fc_reg_cs        (                    ),
            .fc_reg_dec       (                    ),
            .fc_reg_wr_0      (                    ),
            .lc_reg_cs        (                    ),
            .lc_reg_dec       (                    ),
            .lc_reg_wr_0      (                    ),
            .mc_reg_cs        (                    ),
            .mc_reg_dec       (                    ),
            .mc_reg_wr_0      (                    ),
            .ls_reg_cs        (                    ),
            .ms_reg_cs        (                    ),
            .sr_reg_cs        (                    ),
            .sr_reg_dec       (                    ),
            .sr_reg_wr_0      (                    ),
            .debug_0_reg_cs   (                    ),
            .debug_0_reg_dec  (                    ),
            .debug_1_reg_cs   (                    ),
            .debug_1_reg_dec  (                    ),
            .debug_0_reg_rdata ({msr,lcr,iir,ier,lsr}),
            .debug_1_reg_rdata ({8'b0, fcr[7:6],mcr, rf_count, rstate, tf_count, tstate})
);
   wb_uart16550_bus16_big_regs  
     #(.PRESCALER_PRESET(PRESCALER_PRESET))
    regs
     (
      .clk           ( wb_clk_i       ),
      .wb_rst_i      ( wb_rst_i       ),
      .wb_we_i       ( we_o           ),
      .wb_re_i       ( re_o           ),
      .wb_dat_i      ( dl_reg_wdata   ),
      .tr_reg_wr     ( tr_reg_wr      ),
      .tr_reg_wdata  ( tr_reg_wdata   ),
      .rb_dll_reg_rd ( rb_dll_reg_dec ),
      .rdata_rb_dll  ( rb_dll_rdata   ),
      .rdata_ie_dlh  ( ie_dlh_rdata   ),
      .ls_reg_rd     ( ls_reg_dec     ),
      .ms_reg_rd     ( ms_reg_dec     ),
      .ii_reg_rd     ( ii_reg_dec     ),
      .ie_reg_wr     ( ie_reg_wr      ),
      .ie_reg_wdata  ( ie_reg_wdata   ),
      .cts_pad_i     ( cts_pad_i      ), 
      .dsr_pad_i     ( dsr_pad_i      ),
      .ri_pad_i      ( ri_pad_i       ),  
      .dcd_pad_i     ( dcd_pad_i      ),
      .stx_pad_o     ( stx_pad_o      ),
      .srx_pad_i     ( srx_pad_i      ),
      .ier           ( ier            ), 
      .iir           ( iir            ), 
      .fcr           ( fcr            ), 
      .lcr           ( lcr            ), 
      .msr           ( msr            ), 
      .lsr           ( lsr            ),
      .mcr           ( mcr            ),
      .rf_count      ( rf_count       ),
      .tf_count      ( tf_count       ),
      .tstate        ( tstate         ),
      .rstate        ( rstate         ),
      .rts_pad_o     ( rts_pad_o      ),
      .dtr_pad_o     ( dtr_pad_o      ),
      .int_o         ( int_o          ), 
      .baud_o        ( baud_o         )
      );
  endmodule
 /*********************************************/  
 /* Vendor:                  opencores.org    */  
 /* Library:                      wishbone    */  
 /* Component:                wb_uart16550    */  
 /* Version:                     bus16_big    */  
 /* MemMap:                             wb    */  
 /* Base:                             0x00    */  
 /* Type:                                     */  
 /* Endian:                            Big    */  
 /*********************************************/  
 /* AddressBlock:              mb_microbus    */  
 /* NumBase:                             0    */  
 /* Range:                           0x100    */  
 /* NumRange:                          256    */  
 /* NumAddBits:                          8    */  
 /* Width:                              16    */  
 /* Byte_lanes:                          2    */  
 /* Byte_size:                           8    */  
 /*********************************************/  
 /* Reg Name:                   rb_dll_reg    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                       tr_reg    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          0    */  
 /* Reg access:               write-strobe    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                   ie_dlh_reg    */  
 /* Reg Offset:                        0x1    */  
 /* Reg numOffset:                       1    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                       ie_reg    */  
 /* Reg Offset:                        0x1    */  
 /* Reg numOffset:                       1    */  
 /* Reg size:                            4    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          0    */  
 /* Reg access:               write-strobe    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                      dll_reg    */  
 /* Reg Offset:                        0x0    */  
 /* Reg numOffset:                       0    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          0    */  
 /* Reg access:               write-strobe    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                      dlh_reg    */  
 /* Reg Offset:                        0x1    */  
 /* Reg numOffset:                       1    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          0    */  
 /* Reg access:               write-strobe    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                       ii_reg    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            4    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                       fc_reg    */  
 /* Reg Offset:                        0x2    */  
 /* Reg numOffset:                       2    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 write-only    */  
 /* Reg has_read:                        0    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                       lc_reg    */  
 /* Reg Offset:                        0x3    */  
 /* Reg numOffset:                       3    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                       mc_reg    */  
 /* Reg Offset:                        0x4    */  
 /* Reg numOffset:                       4    */  
 /* Reg size:                            5    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                       ls_reg    */  
 /* Reg Offset:                        0x5    */  
 /* Reg numOffset:                       5    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                       ms_reg    */  
 /* Reg Offset:                        0x6    */  
 /* Reg numOffset:                       6    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                       sr_reg    */  
 /* Reg Offset:                        0x7    */  
 /* Reg numOffset:                       7    */  
 /* Reg size:                            8    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                 read-write    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       1    */  
 /*********************************************/  
 /* Reg Name:                  debug_0_reg    */  
 /* Reg Offset:                        0x8    */  
 /* Reg numOffset:                       8    */  
 /* Reg size:                           32    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /* Reg Name:                  debug_1_reg    */  
 /* Reg Offset:                        0xc    */  
 /* Reg numOffset:                      12    */  
 /* Reg size:                           32    */  
 /* Reg Dim:                           0x1    */  
 /* Reg numDim:                          1    */  
 /* Reg DimBits:                         0    */  
 /* Reg Create:                          1    */  
 /* Reg access:                  read-only    */  
 /* Reg has_read:                        1    */  
 /* Reg has_write:                       0    */  
 /*********************************************/  
 /*********************************************/  
 /* Max_dim:                             1    */  
 /* num_add:                             0    */  
 /* mas_has_read:                        1    */  
 /* mas_has_write:                       1    */  
 /* mas_has_create:                      1    */  
 /*********************************************/  
 /*********************************************/  
module wb_uart16550_bus16_big_wb
#(  parameter UNSELECTED = {16{1'b1}},
    parameter UNMAPPED   = {16{1'b0}},
    parameter II_REG_PAD = 4'b0,
    parameter FC_REG_RST = 8'b0,
    parameter LC_REG_RST = 8'b0,
    parameter MC_REG_RST = 5'b0,
    parameter MC_REG_PAD = 3'b0,
    parameter SR_REG_RST = 8'b0)
 (
 input  wire             clk,
 input  wire             reset,
 input  wire             enable,
 input  wire             cs,
 input  wire             wr,
 input  wire             rd,
 input  wire  [16-1:0]    wdata,
 output  reg  [16-1:0]    rdata,
 input  wire  [2-1:0]    byte_lanes,
 input  wire  [8-1:1]    addr,
 output  wire  rb_dll_reg_cs  ,
 output   reg  rb_dll_reg_dec  ,
 input  wire  [8-1:0]    rb_dll_reg_rdata  ,
 output  wire  tr_reg_cs  ,
 output   reg  tr_reg_dec  ,
 output   reg  tr_reg_wr_0  ,
 output  reg  [8-1:0]    tr_reg_wdata  ,
 output  wire  ie_dlh_reg_cs  ,
 output   reg  ie_dlh_reg_dec  ,
 input  wire  [8-1:0]    ie_dlh_reg_rdata  ,
 output  wire  ie_reg_cs  ,
 output   reg  ie_reg_dec  ,
 output   reg  ie_reg_wr_0  ,
 output  reg  [4-1:0]    ie_reg_wdata  ,
 output  wire  dll_reg_cs  ,
 output   reg  dll_reg_dec  ,
 output   reg  dll_reg_wr_0  ,
 output  reg  [8-1:0]    dll_reg_wdata  ,
 output  wire  dlh_reg_cs  ,
 output   reg  dlh_reg_dec  ,
 output   reg  dlh_reg_wr_0  ,
 output  reg  [8-1:0]    dlh_reg_wdata  ,
 output  wire  ii_reg_cs  ,
 output   reg  ii_reg_dec  ,
 input  wire  [4-1:0]    ii_reg_rdata  ,
 output  wire  fc_reg_cs  ,
 output   reg  fc_reg_dec  ,
 output   reg  fc_reg_wr_0  ,
 output  reg  [8-1:0]    fc_reg  ,
 input  wire  [8-1:0]    next_fc_reg  ,
 output  wire  lc_reg_cs  ,
 output   reg  lc_reg_dec  ,
 input  wire  [8-1:0]    lc_reg_rdata  ,
 output   reg  lc_reg_wr_0  ,
 output  reg  [8-1:0]    lc_reg  ,
 input  wire  [8-1:0]    next_lc_reg  ,
 output  wire  mc_reg_cs  ,
 output   reg  mc_reg_dec  ,
 input  wire  [5-1:0]    mc_reg_rdata  ,
 output   reg  mc_reg_wr_0  ,
 output  reg  [5-1:0]    mc_reg  ,
 input  wire  [5-1:0]    next_mc_reg  ,
 output  wire  ls_reg_cs  ,
 output   reg  ls_reg_dec  ,
 input  wire  [8-1:0]    ls_reg_rdata  ,
 output  wire  ms_reg_cs  ,
 output   reg  ms_reg_dec  ,
 input  wire  [8-1:0]    ms_reg_rdata  ,
 output  wire  sr_reg_cs  ,
 output   reg  sr_reg_dec  ,
 input  wire  [8-1:0]    sr_reg_rdata  ,
 output   reg  sr_reg_wr_0  ,
 output  reg  [8-1:0]    sr_reg  ,
 input  wire  [8-1:0]    next_sr_reg  ,
 output  wire  debug_0_reg_cs  ,
 output   reg  debug_0_reg_dec  ,
 input  wire  [32-1:0]    debug_0_reg_rdata  ,
 output  wire  debug_1_reg_cs  ,
 output   reg  debug_1_reg_dec  ,
 input  wire  [32-1:0]    debug_1_reg_rdata  
);
parameter RB_DLL_REG = 8'd0;
parameter RB_DLL_REG_END = 8'd1;
parameter TR_REG = 8'd0;
parameter TR_REG_END = 8'd1;
parameter IE_DLH_REG = 8'd1;
parameter IE_DLH_REG_END = 8'd2;
parameter IE_REG = 8'd1;
parameter IE_REG_END = 8'd2;
parameter DLL_REG = 8'd0;
parameter DLL_REG_END = 8'd1;
parameter DLH_REG = 8'd1;
parameter DLH_REG_END = 8'd2;
parameter II_REG = 8'd2;
parameter II_REG_END = 8'd3;
parameter FC_REG = 8'd2;
parameter FC_REG_END = 8'd3;
parameter LC_REG = 8'd3;
parameter LC_REG_END = 8'd4;
parameter MC_REG = 8'd4;
parameter MC_REG_END = 8'd5;
parameter LS_REG = 8'd5;
parameter LS_REG_END = 8'd6;
parameter MS_REG = 8'd6;
parameter MS_REG_END = 8'd7;
parameter SR_REG = 8'd7;
parameter SR_REG_END = 8'd8;
parameter DEBUG_0_REG = 8'd8;
parameter DEBUG_0_REG_END = 8'd9;
parameter DEBUG_1_REG = 8'd12;
parameter DEBUG_1_REG_END = 8'd13;
 reg  [16-1:0]    rdata_i;
reg  [8-1:0]    fc_reg_wdata;
reg  [8-1:0]    lc_reg_wdata;
reg  [5-1:0]    mc_reg_wdata;
reg  [8-1:0]    sr_reg_wdata;
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ       rb_dll_reg     read-only           2       1               8        0        1        0                 1           0           8            0          1       */  
/*QQQ           tr_reg  write-strobe           2       1               8        0        1        0                 1           0           8            0          1       */  
/*QQQ       ie_dlh_reg     read-only           2       1               8        1        1        0                 1           1           8            0          1       */  
/*QQQ           ie_reg  write-strobe           2       1               4        1        1        0                 1           1           4            4          1       */  
/*QQQ          dll_reg  write-strobe           2       1               8        0        1        0                 1           0           8            0          1       */  
/*QQQ          dlh_reg  write-strobe           2       1               8        1        1        0                 1           1           8            0          1       */  
/*QQQ           ii_reg     read-only           2       1               4        2        1        0                 1           0           4            4          1       */  
/*QQQ           fc_reg    write-only           2       1               8        2        1        0                 1           0           8            0          1       */  
/*QQQ           lc_reg    read-write           2       1               8        3        1        0                 1           1           8            0          1       */  
/*QQQ           mc_reg    read-write           2       1               5        4        1        0                 1           0           5            3          1       */  
/*QQQ           ls_reg     read-only           2       1               8        5        1        0                 1           1           8            0          1       */  
/*QQQ           ms_reg     read-only           2       1               8        6        1        0                 1           0           8            0          1       */  
/*QQQ           sr_reg    read-write           2       1               8        7        1        0                 1           1           8            0          1       */  
/*QQQ      debug_0_reg     read-only           2       4              32        8        1        0                 1           0           8            0          1       */  
/*QQQ      debug_1_reg     read-only           2       4              32       12        1        0                 1           0           8            0          1       */  
always@(*)
  if(rd && cs)
    begin
  if(byte_lanes[ 1 ])
   rdata[1*8+8-1:1*8] =  rdata_i[1*8+8-1:1*8];         
  else
                rdata[1*8+8-1:1*8] = UNMAPPED;
    end
  else          rdata[1*8+8-1:1*8] = UNSELECTED;
always@(*)
    case(addr[8-1:1])
RB_DLL_REG[8-1:1]:      rdata_i[1*8+8-1:1*8] =  rb_dll_reg_rdata ;//QQQQ
II_REG[8-1:1]:      rdata_i[1*8+8-1:1*8] = {II_REG_PAD , ii_reg_rdata };//QQQQ
MC_REG[8-1:1]:      rdata_i[1*8+8-1:1*8] = {MC_REG_PAD , mc_reg_rdata };//QQQQ
MS_REG[8-1:1]:      rdata_i[1*8+8-1:1*8] =  ms_reg_rdata ;//QQQQ
{DEBUG_0_REG[8-1:2],1'b1}:      rdata_i[1*8+8-1:1*8] =  debug_0_reg_rdata[1*8+8-1:1*8] ;//QQQQ
{DEBUG_0_REG[8-1:2],1'b0}:      rdata_i[1*8+8-1:1*8] =  debug_0_reg_rdata[1*8+8-1+(8*2):1*8+(8*2)]      ;//QQQQ
{DEBUG_1_REG[8-1:2],1'b1}:      rdata_i[1*8+8-1:1*8] =  debug_1_reg_rdata[1*8+8-1:1*8] ;//QQQQ
{DEBUG_1_REG[8-1:2],1'b0}:      rdata_i[1*8+8-1:1*8] =  debug_1_reg_rdata[1*8+8-1+(8*2):1*8+(8*2)]      ;//QQQQ
    default:    rdata_i[1*8+8-1:1*8] = UNMAPPED;
    endcase
always@(*)
    begin
tr_reg_wdata     =  wdata[1*8+8-1:1*8]; //  28   
dll_reg_wdata     =  wdata[1*8+8-1:1*8]; //  28   
fc_reg_wdata     =  wdata[1*8+8-1:1*8]; //  28   
mc_reg_wdata     =  wdata[1*8+5-1:1*8]; //  28   
    end
always@(*)
    begin
tr_reg_wr_0 = cs && wr && enable && byte_lanes[ 1 ] && ( addr[8-1:1]== TR_REG[8-1:1] );
dll_reg_wr_0 = cs && wr && enable && byte_lanes[ 1 ] && ( addr[8-1:1]== DLL_REG[8-1:1] );
fc_reg_wr_0 = cs && wr && enable && byte_lanes[ 1 ] && ( addr[8-1:1]== FC_REG[8-1:1] );
mc_reg_wr_0 = cs && wr && enable && byte_lanes[ 1 ] && ( addr[8-1:1]== MC_REG[8-1:1] );
    end
/*QQQ        Reg_Name     Reg_Access sys_byte_lanes  reg_byte_lanes reg_size  reg_add   ar_base log_byte_lane phy_byte_lane  reg_lane   pad_size        padding     bigend    */  
/*QQQ       rb_dll_reg     read-only           2       1               8        0        1        1                 0           0           8            0          1       */  
/*QQQ           tr_reg  write-strobe           2       1               8        0        1        1                 0           0           8            0          1       */  
/*QQQ       ie_dlh_reg     read-only           2       1               8        1        1        1                 0           1           8            0          1       */  
/*QQQ           ie_reg  write-strobe           2       1               4        1        1        1                 0           1           4            4          1       */  
/*QQQ          dll_reg  write-strobe           2       1               8        0        1        1                 0           0           8            0          1       */  
/*QQQ          dlh_reg  write-strobe           2       1               8        1        1        1                 0           1           8            0          1       */  
/*QQQ           ii_reg     read-only           2       1               4        2        1        1                 0           0           4            4          1       */  
/*QQQ           fc_reg    write-only           2       1               8        2        1        1                 0           0           8            0          1       */  
/*QQQ           lc_reg    read-write           2       1               8        3        1        1                 0           1           8            0          1       */  
/*QQQ           mc_reg    read-write           2       1               5        4        1        1                 0           0           5            3          1       */  
/*QQQ           ls_reg     read-only           2       1               8        5        1        1                 0           1           8            0          1       */  
/*QQQ           ms_reg     read-only           2       1               8        6        1        1                 0           0           8            0          1       */  
/*QQQ           sr_reg    read-write           2       1               8        7        1        1                 0           1           8            0          1       */  
/*QQQ      debug_0_reg     read-only           2       4              32        8        1        1                 0           0           8            0          1       */  
/*QQQ      debug_1_reg     read-only           2       4              32       12        1        1                 0           0           8            0          1       */  
always@(*)
  if(rd && cs)
    begin
  if(byte_lanes[ 0 ])
   rdata[0*8+8-1:0*8] =  rdata_i[0*8+8-1:0*8];         
  else
                rdata[0*8+8-1:0*8] = UNMAPPED;
    end
  else          rdata[0*8+8-1:0*8] = UNSELECTED;
always@(*)
    case(addr[8-1:1])
IE_DLH_REG[8-1:1]:      rdata_i[0*8+8-1:0*8] =  ie_dlh_reg_rdata ;//QQQQ
LC_REG[8-1:1]:      rdata_i[0*8+8-1:0*8] =  lc_reg_rdata ;//QQQQ
LS_REG[8-1:1]:      rdata_i[0*8+8-1:0*8] =  ls_reg_rdata ;//QQQQ
SR_REG[8-1:1]:      rdata_i[0*8+8-1:0*8] =  sr_reg_rdata ;//QQQQ
{DEBUG_0_REG[8-1:2],1'b1}:      rdata_i[0*8+8-1:0*8] =  debug_0_reg_rdata[0*8+8-1:0*8] ;//QQQQ
{DEBUG_0_REG[8-1:2],1'b0}:      rdata_i[0*8+8-1:0*8] =  debug_0_reg_rdata[0*8+8-1+(8*2):0*8+(8*2)]      ;//QQQQ
{DEBUG_1_REG[8-1:2],1'b1}:      rdata_i[0*8+8-1:0*8] =  debug_1_reg_rdata[0*8+8-1:0*8] ;//QQQQ
{DEBUG_1_REG[8-1:2],1'b0}:      rdata_i[0*8+8-1:0*8] =  debug_1_reg_rdata[0*8+8-1+(8*2):0*8+(8*2)]      ;//QQQQ
    default:    rdata_i[0*8+8-1:0*8] = UNMAPPED;
    endcase
always@(*)
    begin
ie_reg_wdata     =  wdata[0*8+4-1:0*8]; //  28   
dlh_reg_wdata     =  wdata[0*8+8-1:0*8]; //  28   
lc_reg_wdata     =  wdata[0*8+8-1:0*8]; //  28   
sr_reg_wdata     =  wdata[0*8+8-1:0*8]; //  28   
    end
always@(*)
    begin
ie_reg_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[8-1:1]== IE_REG[8-1:1] );
dlh_reg_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[8-1:1]== DLH_REG[8-1:1] );
lc_reg_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[8-1:1]== LC_REG[8-1:1] );
sr_reg_wr_0 = cs && wr && enable && byte_lanes[ 0 ] && ( addr[8-1:1]== SR_REG[8-1:1] );
    end
 always@(*)
     begin
        rb_dll_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== RB_DLL_REG[8-1:1] );//. 2. 1.   5
        tr_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== TR_REG[8-1:1] );//. 2. 1.   5
        dll_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== DLL_REG[8-1:1] );//. 2. 1.   5
        ii_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== II_REG[8-1:1] );//. 2. 1.   5
        fc_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== FC_REG[8-1:1] );//. 2. 1.   5
        mc_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== MC_REG[8-1:1] );//. 2. 1.   5
        ms_reg_dec = cs && byte_lanes[ 1 ] && ( addr[8-1:1]== MS_REG[8-1:1] );//. 2. 1.   5
        ie_dlh_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== IE_DLH_REG[8-1:1] );//. 2. 1.   5
        ie_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== IE_REG[8-1:1] );//. 2. 1.   5
        dlh_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== DLH_REG[8-1:1] );//. 2. 1.   5
        lc_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== LC_REG[8-1:1] );//. 2. 1.   5
        ls_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== LS_REG[8-1:1] );//. 2. 1.   5
        sr_reg_dec = cs && byte_lanes[ 0 ] && ( addr[8-1:1]== SR_REG[8-1:1] );//. 2. 1.   5
        debug_0_reg_dec = cs && ( addr[8-1:2]== DEBUG_0_REG[8-1:2] );//  4
        debug_1_reg_dec = cs && ( addr[8-1:2]== DEBUG_1_REG[8-1:2] );//  4
     end
  /* verilator lint_off UNSIGNED */           
assign   rb_dll_reg_cs = cs && ( addr >= RB_DLL_REG ) && ( addr < RB_DLL_REG_END );
assign   tr_reg_cs = cs && ( addr >= TR_REG ) && ( addr < TR_REG_END );
assign   ie_dlh_reg_cs = cs && ( addr >= IE_DLH_REG ) && ( addr < IE_DLH_REG_END );
assign   ie_reg_cs = cs && ( addr >= IE_REG ) && ( addr < IE_REG_END );
assign   dll_reg_cs = cs && ( addr >= DLL_REG ) && ( addr < DLL_REG_END );
assign   dlh_reg_cs = cs && ( addr >= DLH_REG ) && ( addr < DLH_REG_END );
assign   ii_reg_cs = cs && ( addr >= II_REG ) && ( addr < II_REG_END );
assign   fc_reg_cs = cs && ( addr >= FC_REG ) && ( addr < FC_REG_END );
assign   lc_reg_cs = cs && ( addr >= LC_REG ) && ( addr < LC_REG_END );
assign   mc_reg_cs = cs && ( addr >= MC_REG ) && ( addr < MC_REG_END );
assign   ls_reg_cs = cs && ( addr >= LS_REG ) && ( addr < LS_REG_END );
assign   ms_reg_cs = cs && ( addr >= MS_REG ) && ( addr < MS_REG_END );
assign   sr_reg_cs = cs && ( addr >= SR_REG ) && ( addr < SR_REG_END );
assign   debug_0_reg_cs = cs && ( addr >= DEBUG_0_REG ) && ( addr < DEBUG_0_REG_END );
assign   debug_1_reg_cs = cs && ( addr >= DEBUG_1_REG ) && ( addr < DEBUG_1_REG_END );
  /* verilator lint_on UNSIGNED */           
   always@(posedge clk)
     if(reset)  fc_reg <=  FC_REG_RST;
        else
       begin
    if(fc_reg_wr_0)    fc_reg[8-1:0]  <=  fc_reg_wdata[8-1:0]  ;
    else    fc_reg[8-1:0]   <=    next_fc_reg[8-1:0];
     end
   always@(posedge clk)
     if(reset)  lc_reg <=  LC_REG_RST;
        else
       begin
    if(lc_reg_wr_0)    lc_reg[8-1:0]  <=  lc_reg_wdata[8-1:0]  ;
    else    lc_reg[8-1:0]   <=    next_lc_reg[8-1:0];
     end
   always@(posedge clk)
     if(reset)  mc_reg <=  MC_REG_RST;
        else
       begin
    if(mc_reg_wr_0)    mc_reg[5-1:0]  <=  mc_reg_wdata[5-1:0]  ;
    else    mc_reg[5-1:0]   <=    next_mc_reg[5-1:0];
     end
   always@(posedge clk)
     if(reset)  sr_reg <=  SR_REG_RST;
        else
       begin
    if(sr_reg_wr_0)    sr_reg[8-1:0]  <=  sr_reg_wdata[8-1:0]  ;
    else    sr_reg[8-1:0]   <=    next_sr_reg[8-1:0];
     end
endmodule 
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  raminfr.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  Inferrable Distributed RAM for FIFOs                        ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None                .                                       ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing so far.                                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////                                                              ////
////  Created:        2002/07/22                                  ////
////  Last Updated:   2002/07/22                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.1  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
//Following is the Verilog code for a dual-port RAM with asynchronous read. 
module wb_uart16550_bus16_big_raminfr  
  #(parameter addr_width = 4,
    parameter data_width = 8,
    parameter depth      = 16)
   (
   input  wire  clk,   
   input  wire   we,   
   input  wire [addr_width-1:0] a,   
   input  wire [addr_width-1:0] dpra,   
   input  wire [data_width-1:0] di,   
   output wire [data_width-1:0] dpo   
   ); 
reg    [data_width-1:0] ram [depth-1:0]; 
  always @(posedge clk) begin   
    if (we)   
      ram[a] <= di;   
  end   
  assign dpo = ram[dpra];   
endmodule 
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_receiver.v                                             ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core receiver logic                                    ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None known                                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Thourough testing.                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.29  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.28  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.27  2001/12/30 20:39:13  mohor
// More than one character was stored in case of break. End of the break
// was not detected correctly.
//
// Revision 1.26  2001/12/20 13:28:27  mohor
// Missing declaration of rf_push_q fixed.
//
// Revision 1.25  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.24  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.23  2001/12/19 07:33:54  mohor
// Synplicity was having troubles with the comment.
//
// Revision 1.22  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.21  2001/12/13 10:31:16  mohor
// timeout irq must be set regardless of the rda irq (rda irq does not reset the
// timeout counter).
//
// Revision 1.20  2001/12/10 19:52:05  gorban
// Igor fixed break condition bugs
//
// Revision 1.19  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.18  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.17  2001/11/28 19:36:39  gorban
// Fixed: timeout and break didn't pay attention to current data format when counting time
//
// Revision 1.16  2001/11/27 22:17:09  gorban
// Fixed bug that prevented synthesis in uart_receiver.v
//
// Revision 1.15  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.14  2001/11/10 12:43:21  gorban
// Logic Synthesis bugs fixed. Some other minor changes
//
// Revision 1.13  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.12  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.11  2001/10/31 15:19:22  gorban
// Fixes to break and timeout conditions
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.6  2001/06/23 11:21:48  gorban
// DL made 16-bit long. Fixed transmission/reception bugs.
//
// Revision 1.5  2001/06/02 14:28:14  gorban
// Fixed receiver and transmitter. Major bug fixed.
//
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:49  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.1  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:11+02  jacob
// Initial revision
//
//
module wb_uart16550_bus16_big_receiver  (
   input wire				clk,
   input wire 				wb_rst_i,
   input wire [7:0] 				lcr,
   input wire 				rf_pop,
   input wire 				srx_pad_in,
   input wire 				enable,
   output reg [9:0] 			counter_t,
   output wire [5-1:0] 	rf_count,
   output wire [11-1:0] 	rf_data_out,
   output wire				rf_error_bit,
   output wire				rf_overrun,
   input wire				rx_reset,
   input wire  				lsr_mask,
   output reg  [3:0] 			rstate,
   output wire 				rf_push_pulse
);
   reg [3:0] 				rcounter16;
   reg [2:0] 				rbit_counter;
   reg [7:0] 				rshift;			// receiver shift register
   reg 					rparity;		// received parity
   reg 					rparity_error;
   reg 					rframing_error;		// framing error flag
   reg 					rbit_in;
   reg 					rparity_xor;
   reg [7:0] 				counter_b;	// counts the 0 (low) signals
   reg 					rf_push_q;
   // RX FIFO signals
   reg [11-1:0] 	rf_data_in;
   reg 					rf_push;
   wire 				break_error = (counter_b == 0);
   // RX FIFO instance
   wb_uart16550_bus16_big_rfifo  #(11) fifo_rx(
					      .clk(		clk		), 
					      .wb_rst_i(	wb_rst_i	),
					      .data_in(	rf_data_in	),
					      .data_out(	rf_data_out	),
					      .push(		rf_push_pulse		),
					      .pop(		rf_pop		),
					      .overrun(	rf_overrun	),
					      .count(		rf_count	),
					      .error_bit(	rf_error_bit	),
					      .fifo_reset(	rx_reset	),
					      .reset_status(lsr_mask)
					      );
   wire 				rcounter16_eq_7 = (rcounter16 == 4'd7);
   wire 				rcounter16_eq_0 = (rcounter16 == 4'd0);
   wire 				rcounter16_eq_1 = (rcounter16 == 4'd1);
   wire [3:0] 				rcounter16_minus_1 = rcounter16 - 3'd1;
   parameter  sr_idle 					= 4'd0;
   parameter  sr_rec_start 			= 4'd1;
   parameter  sr_rec_bit 				= 4'd2;
   parameter  sr_rec_parity			= 4'd3;
   parameter  sr_rec_stop 				= 4'd4;
   parameter  sr_check_parity 		= 4'd5;
   parameter  sr_rec_prepare 			= 4'd6;
   parameter  sr_end_bit				= 4'd7;
   parameter  sr_ca_lc_parity	      = 4'd8;
   parameter  sr_wait1 					= 4'd9;
   parameter  sr_push 					= 4'd10;
   always @(posedge clk )
     begin
	if (wb_rst_i)
	  begin
	     rstate 			<=  sr_idle;
	     rbit_in 				<=  1'b0;
	     rcounter16 			<=  0;
	     rbit_counter 		<=  0;
	     rparity_xor 		<=  1'b0;
	     rframing_error 	<=  1'b0;
	     rparity_error 		<=  1'b0;
	     rparity 				<=  1'b0;
	     rshift 				<=  0;
	     rf_push 				<=  1'b0;
	     rf_data_in 			<=  0;
	  end
	else
	  if (enable)
	    begin
	       case (rstate)
		 sr_idle : begin
		    rf_push 			  <=  1'b0;
		    rf_data_in 	  <=  0;
		    rcounter16 	  <=  4'b1110;
		    if (srx_pad_in==1'b0 & ~break_error)   // detected a pulse (start bit?)
		      begin
			 rstate 		  <=  sr_rec_start;
		      end
		 end
		 sr_rec_start :	begin
  		    rf_push 			  <=  1'b0;
		    if (rcounter16_eq_7)    // check the pulse
		      if (srx_pad_in==1'b1)   // no start bit
			rstate <=  sr_idle;
		      else            // start bit detected
			rstate <=  sr_rec_prepare;
		    rcounter16 <=  rcounter16_minus_1;
		 end
		 sr_rec_prepare:begin
		    case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
		      2'b00 : rbit_counter <=  3'b100;
		      2'b01 : rbit_counter <=  3'b101;
		      2'b10 : rbit_counter <=  3'b110;
		      2'b11 : rbit_counter <=  3'b111;
		    endcase
		    if (rcounter16_eq_0)
		      begin
			 rstate		<=  sr_rec_bit;
			 rcounter16	<=  4'b1110;
			 rshift		<=  0;
		      end
		    else
		      rstate <=  sr_rec_prepare;
		    rcounter16 <=  rcounter16_minus_1;
		 end
		 sr_rec_bit :	begin
		    if (rcounter16_eq_0)
		      rstate <=  sr_end_bit;
		    if (rcounter16_eq_7) // read the bit
		      case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
			2'b00 : rshift[4:0]  <=  {srx_pad_in, rshift[4:1]};
			2'b01 : rshift[5:0]  <=  {srx_pad_in, rshift[5:1]};
			2'b10 : rshift[6:0]  <=  {srx_pad_in, rshift[6:1]};
			2'b11 : rshift[7:0]  <=  {srx_pad_in, rshift[7:1]};
		      endcase
		    rcounter16 <=  rcounter16_minus_1;
		 end
		 sr_end_bit :   begin
		    if (rbit_counter==3'b0) // no more bits in word
		      if (lcr[3]) // choose state based on parity
			rstate <=  sr_rec_parity;
		      else
			begin
			   rstate <=  sr_rec_stop;
			   rparity_error <=  1'b0;  // no parity - no error :)
			end
		    else		// else we have more bits to read
		      begin
			 rstate <=  sr_rec_bit;
			 rbit_counter <=  rbit_counter - 3'd1;
		      end
		    rcounter16 <=  4'b1110;
		 end
		 sr_rec_parity: begin
		    if (rcounter16_eq_7)	// read the parity
		      begin
			 rparity <=  srx_pad_in;
			 rstate <=  sr_ca_lc_parity;
		      end
		    rcounter16 <=  rcounter16_minus_1;
		 end
		 sr_ca_lc_parity : begin    // rcounter equals 6
		    rcounter16  <=  rcounter16_minus_1;
		    rparity_xor <=  ^{rshift,rparity}; // calculate parity on all incoming data
		    rstate      <=  sr_check_parity;
		 end
		 sr_check_parity: begin	  // rcounter equals 5
		    case ({lcr[4],lcr[5]})
		      2'b00: rparity_error <=   rparity_xor == 0;  // no error if parity 1
		      2'b01: rparity_error <=  ~rparity;      // parity should sticked to 1
		      2'b10: rparity_error <=   rparity_xor == 1;   // error if parity is odd
		      2'b11: rparity_error <=   rparity;	  // parity should be sticked to 0
		    endcase
		    rcounter16 <=  rcounter16_minus_1;
		    rstate <=  sr_wait1;
		 end
		 sr_wait1 :	if (rcounter16_eq_0)
		   begin
		      rstate <=  sr_rec_stop;
		      rcounter16 <=  4'b1110;
		   end
		 else
		   rcounter16 <=  rcounter16_minus_1;
		 sr_rec_stop :	begin
		    if (rcounter16_eq_7)	// read the parity
		      begin
			 rframing_error <=  !srx_pad_in; // no framing error if input is 1 (stop bit)
			 rstate <=  sr_push;
		      end
		    rcounter16 <=  rcounter16_minus_1;
		 end
		 sr_push :	begin
		    ///////////////////////////////////////
		    //				$display($time, ": received: %b", rf_data_in);
		    if(srx_pad_in | break_error)
		      begin
			 if(break_error)
        		   rf_data_in 	<=  {8'b0, 3'b100}; // break input (empty character) to receiver FIFO
			 else
        		   rf_data_in  <=  {rshift, 1'b0, rparity_error, rframing_error};
      			 rf_push 		  <=  1'b1;
    			 rstate        <=  sr_idle;
		      end
		    else if(~rframing_error)  // There's always a framing before break_error -> wait for break or srx_pad_in
		      begin
       			 rf_data_in  <=  {rshift, 1'b0, rparity_error, rframing_error};
      			 rf_push 		  <=  1'b1;
      			 rcounter16 	  <=  4'b1110;
    			 rstate 		  <=  sr_rec_start;
		      end
		 end
		 default : rstate <=  sr_idle;
	       endcase
	    end  // if (enable)
     end // always of receiver
   always @ (posedge clk )
     begin
	if(wb_rst_i)
	  rf_push_q <= 0;
	else
	  rf_push_q <=  rf_push;
     end
   assign rf_push_pulse = rf_push & ~rf_push_q;
   //
   // Break condition detection.
   // Works in conjuction with the receiver state machine
   reg 	[9:0]	toc_value; // value to be set to timeout counter
   always @(lcr)
     case (lcr[3:0])
       4'b0000: toc_value = 447; // 7 bits
       4'b0100: toc_value = 479; // 7.5 bits
       4'b0001,	4'b1000	: toc_value = 511; // 8 bits
       4'b1100: toc_value = 543; // 8.5 bits
       4'b0010, 4'b0101, 4'b1001: toc_value = 575; // 9 bits
       4'b0011, 4'b0110, 4'b1010, 4'b1101: toc_value = 639; // 10 bits
       4'b0111, 4'b1011, 4'b1110: toc_value = 703; // 11 bits
       4'b1111: toc_value = 767; // 12 bits
     endcase // case(lcr[3:0])
   wire [7:0] 	brc_value; // value to be set to break counter
   assign 		brc_value = toc_value[9:2]; // the same as timeout but 1 insead of 4 character times
   always @(posedge clk )
     begin
	if (wb_rst_i)
	  counter_b <=  8'd159;
	else
	  if (srx_pad_in)
	    counter_b <=  brc_value; // character time length - 1
	  else
	    if(enable & counter_b != 8'b0)            // only work on enable times  break not reached.
	      counter_b <=  counter_b - 1;  // decrement break counter
     end // always of break condition detection
   ///
   /// Timeout condition detection
   always @(posedge clk )
     begin
	if (wb_rst_i)
	  counter_t <=  10'd639; // 10 bits for the default 8N1
	else
	  if(rf_push_pulse || rf_pop || rf_count == 0) // counter is reset when RX FIFO is empty, accessed or above trigger level
	    counter_t <=  toc_value;
	  else
	    if (enable && counter_t != 10'b0)  // we don't want to underflow
	      counter_t <=  counter_t - 1;		
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_regs.v                                                 ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  Registers of the uart 16550 core                            ////
////                                                              ////
////  Known problems (limits):                                    ////
////  Inserts 1 wait state in all WISHBONE transfers              ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing or verification.                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   (See log for the revision history           ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.41  2004/05/21 11:44:41  tadejm
// Added synchronizer flops for RX input.
//
// Revision 1.40  2003/06/11 16:37:47  gorban
// This fixes errors in some cases when data is being read and put to the FIFO at the same time. Patch is submitted by Scott Furman. Update is very recommended.
//
// Revision 1.39  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.38  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.37  2001/12/27 13:24:09  mohor
// lsr[7] was not showing overrun errors.
//
// Revision 1.36  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.35  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.34  2001/12/19 07:33:54  mohor
// Synplicity was having troubles with the comment.
//
// Revision 1.33  2001/12/17 10:14:43  mohor
// Things related to msr register changed. After THRE IRQ occurs, and one
// character is written to the transmit fifo, the detection of the THRE bit in the
// LSR is delayed for one character time.
//
// Revision 1.32  2001/12/14 13:19:24  mohor
// MSR register fixed.
//
// Revision 1.31  2001/12/14 10:06:58  mohor
// After reset modem status register MSR should be reset.
//
// Revision 1.30  2001/12/13 10:09:13  mohor
// thre irq should be cleared only when being source of interrupt.
//
// Revision 1.29  2001/12/12 09:05:46  mohor
// LSR status bit 0 was not cleared correctly in case of reseting the FCR (rx fifo).
//
//
// Revision 1.27  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.26  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.25  2001/11/28 19:36:39  gorban
// Fixed: timeout and break didn't pay attention to current data format when counting time
//
// Revision 1.24  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.23  2001/11/12 21:57:29  gorban
// fixed more typo bugs
//
// Revision 1.22  2001/11/12 15:02:28  mohor
// lsr1r error fixed.
//
// Revision 1.21  2001/11/12 14:57:27  mohor
// ti_int_pnd error fixed.
//
// Revision 1.20  2001/11/12 14:50:27  mohor
// ti_int_d error fixed.
//
// Revision 1.19  2001/11/10 12:43:21  gorban
// Logic Synthesis bugs fixed. Some other minor changes
//
// Revision 1.18  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.17  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.16  2001/11/02 09:55:16  mohor
// no message
//
// Revision 1.15  2001/10/31 15:19:22  gorban
// Fixes to break and timeout conditions
//
// Revision 1.14  2001/10/29 17:00:46  gorban
// fixed parity sending and tx_fifo resets over- and underrun
//
// Revision 1.13  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.12  2001/10/19 16:21:40  gorban
// Changes data_out to be synchronous again as it should have been.
//
// Revision 1.11  2001/10/18 20:35:45  gorban
// small fix
//
// Revision 1.10  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.9  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.10  2001/06/23 11:21:48  gorban
// DL made 16-bit long. Fixed transmission/reception bugs.
//
// Revision 1.9  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.8  2001/05/29 20:05:04  gorban
// Fixed some bugs and synthesis problems.
//
// Revision 1.7  2001/05/27 17:37:49  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.6  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.5  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:11+02  jacob
// Initial revision
//
//
module wb_uart16550_bus16_big_regs 
  #(parameter PRESCALER_PRESET = 16'h0000 )
   ( 
   input  wire                             clk,
   input  wire                             wb_rst_i,
   input  wire [15:0]                      wb_dat_i,
   input  wire [7:0]                       tr_reg_wdata,
   input  wire [3:0]                       ie_reg_wdata,
   input  wire                             wb_we_i,
   input  wire                             wb_re_i,
   input  wire                             tr_reg_wr,
   input  wire                             rb_dll_reg_rd,
   input  wire                             ls_reg_rd,
   input  wire                             ms_reg_rd,
   input  wire                             ii_reg_rd,
   input  wire                             ie_reg_wr,
   input  wire                             cts_pad_i,
   input  wire                             dsr_pad_i,
   input  wire                             ri_pad_i,
   input  wire                             dcd_pad_i,
   input  wire                             srx_pad_i,
   output wire                             stx_pad_o,
   output wire                             rts_pad_o,
   output wire                             dtr_pad_o,
   output  reg                             int_o,
   output wire                             baud_o,
   output  reg  [3:0]                      ier,
   output  reg  [3:0]                      iir,
   input  wire  [7:0]                      fcr,
   input  wire  [4:0]                      mcr,
   input  wire  [7:0]                      lcr,
   output  reg  [7:0]                      msr,
   output wire  [7:0]                      lsr,
   output wire  [5-1:0] rf_count,
   output wire  [5-1:0] tf_count,
   output wire  [2:0]                      tstate,
   output wire  [3:0]                      rstate,
   output wire  [7:0]                      rdata_rb_dll,
   output wire  [7:0]                      rdata_ie_dlh
          );
   reg                      enable;
   wire                     srx_pad;
   reg [15:0]               dl;  // 32-bit divisor latch
   reg                      start_dlc; // activate dlc on writing to UART_DL1
   reg                      lsr_mask_d; // delay for lsr_mask condition
   reg                      msi_reset; // reset MSR 4 lower bits indicator
   //reg                                         threi_clear; // THRE interrupt clear flag
   reg [15:0]               dlc;  // 32-bit divisor latch counter
   reg [3:0]                trigger_level; // trigger level of the receiver FIFO
   reg                      rx_reset;
   reg                      tx_reset;
   wire                     dlab;               // divisor latch access bit
   wire                     loopback;           // loopback bit (MCR bit 4)
   wire                     cts, dsr, ri, dcd;       // effective signals
   wire                     cts_c, dsr_c, ri_c, dcd_c; // Complement effective signals (considering loopback)
   // LSR bits wires and regs
   wire                  lsr0, lsr1, lsr2, lsr3, lsr4, lsr5, lsr6, lsr7;
   reg                      lsr0r, lsr1r, lsr2r, lsr3r, lsr4r, lsr5r, lsr6r, lsr7r;
   wire                  lsr_mask; // lsr_mask
   // Interrupt signals
   wire                  rls_int;  // receiver line status interrupt
   wire                  rda_int;  // receiver data available interrupt
   wire                  ti_int;   // timeout indicator interrupt
   wire                  thre_int; // transmitter holding register empty interrupt
   wire                  ms_int;   // modem status interrupt
   // FIFO signals
   reg                      tf_push;
   reg                      rf_pop;
   wire [11-1:0]   rf_data_out;
   wire                  rf_error_bit; // an error (parity or framing) is inside the fifo
   wire                  rf_overrun;
   wire                  rf_push_pulse;   
   wire [9:0]                  counter_t;
   wire                  thre_set_en; // THRE status is delayed one character time when a character is written to fifo.
   reg [7:0]                  block_cnt;   // While counter counts, THRE status is blocked (delayed one character cycle)
   reg [7:0]                  block_value; // One character length minus stop bit
   // Transmitter Instance
   wire                  serial_out;
   wire                  serial_in;
   wire     lsr_mask_condition;
   wire     iir_read;
   wire     msr_read;
   wire     fifo_read;
   wire     fifo_write;
   wire  rls_int_rise;
   wire  thre_int_rise;
   wire  ms_int_rise;
   wire  ti_int_rise;
   wire  rda_int_rise;
   reg      lsr0_d;
   reg      lsr1_d; // delayed
   reg      lsr2_d; // delayed
   reg      lsr3_d; // delayed
   reg      lsr4_d; // delayed
   reg      lsr5_d;
   reg      lsr6_d;
   reg      lsr7_d;
   reg      rls_int_d;
   reg      thre_int_d;
   reg      ms_int_d;
   reg      ti_int_d;
   reg      rda_int_d;
   reg      rls_int_pnd;
   reg      rda_int_pnd;
   reg      thre_int_pnd;
   reg      ms_int_pnd;
   reg      ti_int_pnd;
   //
   // ASSIGNS
   //
   assign              rdata_rb_dll = dlab ? dl[7:0]  : rf_data_out[10:3];
   assign              rdata_ie_dlh = dlab ? dl[15:8] : {4'd0,ier};
   assign baud_o = enable; // baud_o is actually the enable signal
   assign                                     lsr[7:0] = { lsr7r, lsr6r, lsr5r, lsr4r, lsr3r, lsr2r, lsr1r, lsr0r };
   assign                                     {cts, dsr, ri, dcd} = ~{cts_pad_i,dsr_pad_i,ri_pad_i,dcd_pad_i};
   assign                  {cts_c, dsr_c, ri_c, dcd_c} = loopback ? {mcr[1],mcr[0],mcr[2],mcr[3]}
   : {cts_pad_i,dsr_pad_i,ri_pad_i,dcd_pad_i};
   assign                                     dlab = lcr[7];
   assign                                     loopback = mcr[4];
   // assign modem outputs
   assign                                     rts_pad_o = mcr[1];
   assign                                     dtr_pad_o = mcr[0];
   // handle loopback
   assign                  serial_in = loopback ? serial_out : srx_pad;
   assign stx_pad_o = loopback ? 1'b1 : serial_out;
   wb_uart16550_bus16_big_transmitter  transmitter(
        .clk             (clk), 
        .wb_rst_i        (wb_rst_i), 
        .lcr             (lcr), 
        .tf_push         (tf_push), 
        .tf_data_in      (tr_reg_wdata), 
        .enable          (enable), 
        .stx_pad_o       (serial_out), 
        .tstate          (tstate), 
        .tf_count        (tf_count), 
        .tx_reset        (tx_reset), 
        .lsr_mask        (lsr_mask));
   // Synchronizing and sampling serial RX input
   wb_uart16550_bus16_big_sync_flops     
    #(.width(1),
      .init_value(1'b1))
    i_uart_sync_flops
     (
      .rst_i           (wb_rst_i),
      .clk_i           (clk),
      .stage1_rst_i    (1'b0),
      .stage1_clk_en_i (1'b1),
      .async_dat_i     (srx_pad_i),
      .sync_dat_o      (srx_pad)
      );
   // Receiver Instance
   wb_uart16550_bus16_big_receiver  receiver(
                .clk               (clk), 
                .wb_rst_i          (wb_rst_i), 
                .lcr               (lcr), 
                .rf_pop            (rf_pop), 
                .srx_pad_in        (serial_in), 
                .enable            (enable), 
                .counter_t         (counter_t), 
                .rf_count          (rf_count), 
                .rf_data_out       (rf_data_out), 
                .rf_error_bit      (rf_error_bit), 
                .rf_overrun        (rf_overrun),  
                .rx_reset          (rx_reset), 
                .lsr_mask          (lsr_mask), 
                .rstate            (rstate), 
                .rf_push_pulse     ( rf_push_pulse)
);
   // rf_pop signal handling
   always @(posedge clk )
     begin
    if (wb_rst_i)
      rf_pop <=  0; 
    else
      if (rf_pop)    // restore the signal to 0 after one clock cycle
        rf_pop <=  0;
      else
        if (wb_re_i && rb_dll_reg_rd && !dlab)
          rf_pop <=  1; // advance read pointer
     end
   assign lsr_mask_condition = (wb_re_i && ls_reg_rd && !dlab);
   assign iir_read = (wb_re_i && ii_reg_rd && !dlab);
   assign msr_read = (wb_re_i && ms_reg_rd && !dlab);
   assign fifo_read = (wb_re_i && rb_dll_reg_rd && !dlab);
   assign fifo_write = (tr_reg_wr && wb_we_i && !dlab);
   // lsr_mask_d delayed signal handling
   always @(posedge clk )
     begin
    if (wb_rst_i)
      lsr_mask_d <=  0;
    else // reset bits in the Line Status Register
      lsr_mask_d <=  lsr_mask_condition;
     end
   // lsr_mask is rise detected
   assign lsr_mask = lsr_mask_condition && ~lsr_mask_d;
   // msi_reset signal handling
   always @(posedge clk )
     begin
    if (wb_rst_i)
      msi_reset <=  1;
    else
      if (msi_reset)
        msi_reset <=  0;
      else
        if (msr_read)
          msi_reset <=  1; // reset bits in Modem Status Register
     end
   // Interrupt Enable Register
   always @(posedge clk )
     if (wb_rst_i)
       begin
      ier <=  4'b0000; // no interrupts after reset
       end
     else
       if (wb_we_i && ie_reg_wr && !dlab)
       ier <=  ie_reg_wdata; 
   // UART_DL2
   always @(posedge clk )
     if (wb_rst_i)       dl[15:8] <=  PRESCALER_PRESET[15:8];
     else
     if (wb_we_i && ie_reg_wr && dlab)
       dl[15:8] <=          wb_dat_i[15:8];
   // UART_DL1
   always @(posedge clk )
     if (wb_rst_i)
        dl[7:0]   <=  PRESCALER_PRESET[7:0];
     else
     if (tr_reg_wr && wb_we_i  && dlab)
         dl[7:0]   <=  wb_dat_i[7:0];
   // FIFO Control Register and rx_reset, tx_reset signals
   always @(posedge clk )
     if (wb_rst_i) begin
    rx_reset <=  0;
    tx_reset <=  0;
     end else
       begin
      rx_reset <=  fcr[2];
      tx_reset <=  fcr[1];
       end
   // TX_FIFO 
   always @(posedge clk )
     if (wb_rst_i)
       begin
      tf_push   <=  1'b0;
      start_dlc <=  1'b0;
       end
     else
       if (tr_reg_wr && wb_we_i)
     if (dlab)
       begin
          start_dlc <=  1'b1; // enable DL counter
          tf_push   <=  1'b0;
       end
     else
       begin
          tf_push   <=  1'b1;
          start_dlc <=  1'b0;
       end // else: !if(dlab)
       else
     begin
        start_dlc <=  1'b0;
        tf_push   <=  1'b0;
     end // else: !if(dlab)
   // Receiver FIFO trigger level selection logic (asynchronous mux)
   always @(fcr)
     case (fcr[7:6])
       2'b00 : trigger_level = 1;
       2'b01 : trigger_level = 4;
       2'b10 : trigger_level = 8;
       2'b11 : trigger_level = 14;
     endcase // case(fcr[`UART_FC_TL])
   //
   //  STATUS REGISTERS  //
   //
   // Modem Status Register
   reg [3:0] delayed_modem_signals;
   always @(posedge clk )
     begin
    if (wb_rst_i)
      begin
           msr <=  0;
         delayed_modem_signals[3:0] <=  0;
      end
    else begin
       msr[3:0] <=  msi_reset ? 4'b0 :
                        msr[3:0] | ({dcd, ri, dsr, cts} ^ delayed_modem_signals[3:0]);
       msr[7:4] <=  {dcd_c, ri_c, dsr_c, cts_c};
       delayed_modem_signals[3:0] <=  {dcd, ri, dsr, cts};
    end
     end
   // Line Status Register
   // activation conditions
   assign lsr0 = (rf_count==0 && rf_push_pulse);  // data in receiver fifo available set condition
   assign lsr1 = rf_overrun;     // Receiver overrun error
   assign lsr2 = rf_data_out[1]; // parity error bit
   assign lsr3 = rf_data_out[0]; // framing error bit
   assign lsr4 = rf_data_out[2]; // break error in the character
   assign lsr5 = (tf_count==5'b0 && thre_set_en);  // transmitter fifo is empty
   assign lsr6 = (tf_count==5'b0 && thre_set_en && (tstate == /*`S_IDLE */ 0)); // transmitter empty
   assign lsr7 = rf_error_bit | rf_overrun;
   // lsr bit0 (receiver data available)
   always @(posedge clk )
     if (wb_rst_i) lsr0_d <=  0;
     else lsr0_d <=  lsr0;
   always @(posedge clk )
     if (wb_rst_i) lsr0r <=  0;
     else lsr0r <=  (rf_count==1 && rf_pop && !rf_push_pulse || rx_reset) ? 0 : // deassert condition
            lsr0r || (lsr0 && ~lsr0_d); // set on rise of lsr0 and keep asserted until deasserted 
   // lsr bit 1 (receiver overrun)
   always @(posedge clk )
     if (wb_rst_i) lsr1_d <=  0;
     else lsr1_d <=  lsr1;
   always @(posedge clk )
     if (wb_rst_i) lsr1r <=  0;
     else    lsr1r <=     lsr_mask ? 0 : lsr1r || (lsr1 && ~lsr1_d); // set on rise
   // lsr bit 2 (parity error)
   always @(posedge clk )
     if (wb_rst_i) lsr2_d <=  0;
     else lsr2_d <=  lsr2;
   always @(posedge clk )
     if (wb_rst_i) lsr2r <=  0;
     else lsr2r <=  lsr_mask ? 0 : lsr2r || (lsr2 && ~lsr2_d); // set on rise
   // lsr bit 3 (framing error)
   always @(posedge clk )
     if (wb_rst_i) lsr3_d <=  0;
     else lsr3_d <=  lsr3;
   always @(posedge clk )
     if (wb_rst_i) lsr3r <=  0;
     else lsr3r <=  lsr_mask ? 0 : lsr3r || (lsr3 && ~lsr3_d); // set on rise
   // lsr bit 4 (break indicator)
   always @(posedge clk )
     if (wb_rst_i) lsr4_d <=  0;
     else lsr4_d <=  lsr4;
   always @(posedge clk )
     if (wb_rst_i) lsr4r <=  0;
     else lsr4r <=  lsr_mask ? 0 : lsr4r || (lsr4 && ~lsr4_d);
   // lsr bit 5 (transmitter fifo is empty)
   always @(posedge clk )
     if (wb_rst_i) lsr5_d <=  1;
     else lsr5_d <=  lsr5;
   always @(posedge clk )
     if (wb_rst_i) lsr5r <=  1;
     else lsr5r <=  (fifo_write) ? 0 :  lsr5r || (lsr5 && ~lsr5_d);
   // lsr bit 6 (transmitter empty indicator)
   always @(posedge clk )
     if (wb_rst_i) lsr6_d <=  1;
     else lsr6_d <=  lsr6;
   always @(posedge clk )
     if (wb_rst_i) lsr6r <=  1;
     else lsr6r <=  (fifo_write) ? 0 : lsr6r || (lsr6 && ~lsr6_d);
   // lsr bit 7 (error in fifo)
   always @(posedge clk )
     if (wb_rst_i) lsr7_d <=  0;
     else lsr7_d <=  lsr7;
   always @(posedge clk )
     if (wb_rst_i) lsr7r <=  0;
     else lsr7r <=  lsr_mask ? 0 : lsr7r || (lsr7 && ~lsr7_d);
   // Frequency divider
   always @(posedge clk ) 
     begin
    if (wb_rst_i)
      dlc <=  0;
    else
      if (start_dlc | ~ (|dlc))
          dlc <=  dl - 1;               // preset counter
      else
        dlc <=  dlc - 1;              // decrement counter
     end
   // Enable signal generation logic
   always @(posedge clk )
     begin
    if (wb_rst_i)
      enable <=  1'b0;
    else
      if (|dl & ~(|dlc))     // dl>0 & dlc==0
        enable <=  1'b1;
      else
        enable <=  1'b0;
     end
   // Delaying THRE status for one character cycle after a character is written to an empty fifo.
   always @(lcr)
     case (lcr[3:0])
       4'b0000                             : block_value =  95; // 6 bits
       4'b0100                             : block_value = 103; // 6.5 bits
       4'b0001, 4'b1000                    : block_value = 111; // 7 bits
       4'b1100                             : block_value = 119; // 7.5 bits
       4'b0010, 4'b0101, 4'b1001           : block_value = 127; // 8 bits
       4'b0011, 4'b0110, 4'b1010, 4'b1101  : block_value = 143; // 9 bits
       4'b0111, 4'b1011, 4'b1110           : block_value = 159; // 10 bits
       4'b1111                             : block_value = 175; // 11 bits
     endcase // case(lcr[3:0])
   // Counting time of one character minus stop bit
   always @(posedge clk )
     begin
    if (wb_rst_i)
      block_cnt <=  8'd0;
    else
      if(lsr5r & fifo_write)  // THRE bit set & write to fifo occured
        block_cnt <=  block_value;
      else
        if (enable & block_cnt != 8'b0)  // only work on enable times
          block_cnt <=  block_cnt - 1;  // decrement break counter
     end // always of break condition detection
   // Generating THRE status enable signal
   assign thre_set_en = ~(|block_cnt);
   //
   //    INTERRUPT LOGIC
   //
   assign rls_int  = ier[2]  && (lsr[1] || lsr[2] || lsr[3] || lsr[4]);
   assign rda_int  = ier[0]  && (rf_count >= {1'b0,trigger_level});
   assign thre_int = ier[1] &&  lsr[5];
   assign ms_int   = ier[3]   && (| msr[3:0]);
   assign ti_int   = ier[0]  && (counter_t == 10'b0) && (|rf_count);
   // delay lines
   always  @(posedge clk )
     if (wb_rst_i) rls_int_d <=  0;
     else rls_int_d <=  rls_int;
   always  @(posedge clk )
     if (wb_rst_i) rda_int_d <=  0;
     else rda_int_d <=  rda_int;
   always  @(posedge clk )
     if (wb_rst_i) thre_int_d <=  0;
     else thre_int_d <=  thre_int;
   always  @(posedge clk )
     if (wb_rst_i) ms_int_d <=  0;
     else ms_int_d <=  ms_int;
   always  @(posedge clk )
     if (wb_rst_i) ti_int_d <=  0;
     else ti_int_d <=  ti_int;
   // rise detection signals
   assign rda_int_rise      = rda_int & ~rda_int_d;
   assign rls_int_rise      = rls_int & ~rls_int_d;
   assign thre_int_rise     = thre_int & ~thre_int_d;
   assign ms_int_rise       = ms_int & ~ms_int_d;
   assign ti_int_rise       = ti_int & ~ti_int_d;
   // interrupt pending flags
   // interrupt pending flags assignments
   always  @(posedge clk )
     if (wb_rst_i) rls_int_pnd <=  0; 
     else 
       rls_int_pnd <=  lsr_mask ? 0 :                          // reset condition
               rls_int_rise ? 1 :                        // latch condition
               rls_int_pnd && ier[2];    // default operation: remove if masked
   always  @(posedge clk )
     if (wb_rst_i) rda_int_pnd <=  0; 
     else 
       rda_int_pnd <=  ((rf_count == {1'b0,trigger_level}) && fifo_read) ? 0 :      // reset condition
               rda_int_rise ? 1 :                        // latch condition
               rda_int_pnd && ier[0];    // default operation: remove if masked
   always  @(posedge clk )
     if (wb_rst_i) thre_int_pnd <=  0; 
     else 
       thre_int_pnd <=  fifo_write || (iir_read & ~iir[0] & iir[3:1] == 3'b001)? 0 : 
            thre_int_rise ? 1 :
            thre_int_pnd && ier[1];
   always  @(posedge clk )
     if (wb_rst_i) ms_int_pnd <=  0; 
     else 
       ms_int_pnd <=  msr_read ? 0 : 
              ms_int_rise ? 1 :
              ms_int_pnd && ier[3];
   always  @(posedge clk )
     if (wb_rst_i) ti_int_pnd <=  0; 
     else 
       ti_int_pnd <=  fifo_read ? 0 : 
              ti_int_rise ? 1 :
              ti_int_pnd && ier[0];
   // end of pending flags
   // INT_O logic
   always @(posedge clk )
     begin
    if (wb_rst_i)    
      int_o <=  1'b0;
    else
      int_o <=  
            rls_int_pnd        ?    ~lsr_mask             :
            rda_int_pnd        ? 1                        :
            ti_int_pnd         ? ~fifo_read               :
            thre_int_pnd       ? !(fifo_write & iir_read) :
            ms_int_pnd         ? ~msr_read                :
            0;    // if no interrupt are pending
     end
   // Interrupt Identification register
   always @(posedge clk )
     begin
    if (wb_rst_i)
      iir <=  1;
    else
      if (rls_int_pnd)  // interrupt is pending
        begin
           iir[3:1] <=  3'b011;    // set identification register to correct value
           iir[0] <=  1'b0;        // and clear the IIR bit 0 (interrupt pending)
        end else // the sequence of conditions determines priority of interrupt identification
          if (rda_int)
        begin
           iir[3:1] <=  3'b010;
           iir[0] <=  1'b0;
        end
          else if (ti_int_pnd)
        begin
           iir[3:1] <=  3'b110;
           iir[0] <=  1'b0;
        end
          else if (thre_int_pnd)
        begin
           iir[3:1] <=  3'b001;
           iir[0] <=  1'b0;
        end
          else if (ms_int_pnd)
        begin
           iir[3:1] <=  3'b000;
           iir[0] <=  1'b0;
        end else    // no interrupt is pending
          begin
             iir[3:1] <=  0;
             iir[0] <=  1'b1;
          end
     end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_rfifo.v (Modified from uart_fifo.v)                    ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core receiver FIFO                                     ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing.                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2002/07/22                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.3  2003/06/11 16:37:47  gorban
// This fixes errors in some cases when data is being read and put to the FIFO at the same time. Patch is submitted by Scott Furman. Update is very recommended.
//
// Revision 1.2  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.1  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.16  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.15  2001/12/18 09:01:07  mohor
// Bug that was entered in the last update fixed (rx state machine).
//
// Revision 1.14  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.13  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.12  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.11  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/24 08:48:10  mohor
// FIFO was not cleared after the data was read bug fixed.
//
// Revision 1.7  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.3  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:48  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//
module wb_uart16550_bus16_big_rfifo  (clk, 
	wb_rst_i, data_in, data_out,
// Control signals
	push, // push strobe, active high
	pop,   // pop strobe, active high
// status signals
	overrun,
	count,
	error_bit,
	fifo_reset,
	reset_status
	);
// FIFO parameters
parameter fifo_width = 8;
parameter fifo_depth = 16;
parameter fifo_pointer_w = 4;
parameter fifo_counter_w = 5;
input				clk;
input				wb_rst_i;
input				push;
input				pop;
input	[fifo_width-1:0]	data_in;
input				fifo_reset;
input       reset_status;
output	[fifo_width-1:0]	data_out;
output				overrun;
output	[fifo_counter_w-1:0]	count;
output				error_bit;
wire	[fifo_width-1:0]	data_out;
wire [7:0] data8_out;
// flags FIFO
reg	[2:0]	fifo[fifo_depth-1:0];
// FIFO pointers
reg	[fifo_pointer_w-1:0]	top;
reg	[fifo_pointer_w-1:0]	bottom;
reg	[fifo_counter_w-1:0]	count;
reg				overrun;
wire [fifo_pointer_w-1:0] top_plus_1 = top + 4'h1;
wb_uart16550_bus16_big_raminfr 
  #( .addr_width  ( fifo_pointer_w ),
     .data_width  ( 8              ),
     .depth       ( fifo_depth     )
     ) rfifo (
             .clk(clk), 
	     .we(push), 
             .a(top), 
             .dpra(bottom), 
             .di(data_in[fifo_width-1:fifo_width-8]), 
             .dpo(data8_out)
		); 
always @(posedge clk ) // synchronous FIFO
begin
	if (wb_rst_i)
	begin
		top		<=  0;
        	bottom  	<=  0;	   
		count		<=  0;
		fifo[0] <=  0;
		fifo[1] <=  0;
		fifo[2] <=  0;
		fifo[3] <=  0;
		fifo[4] <=  0;
		fifo[5] <=  0;
		fifo[6] <=  0;
		fifo[7] <=  0;
		fifo[8] <=  0;
		fifo[9] <=  0;
		fifo[10] <=  0;
		fifo[11] <=  0;
		fifo[12] <=  0;
		fifo[13] <=  0;
		fifo[14] <=  0;
		fifo[15] <=  0;
	end
	else
	if (fifo_reset) begin
		top		<=  0;
		bottom		<=  0;
		count		<=  0;
		fifo[0] <=  0;
		fifo[1] <=  0;
		fifo[2] <=  0;
		fifo[3] <=  0;
		fifo[4] <=  0;
		fifo[5] <=  0;
		fifo[6] <=  0;
		fifo[7] <=  0;
		fifo[8] <=  0;
		fifo[9] <=  0;
		fifo[10] <=  0;
		fifo[11] <=  0;
		fifo[12] <=  0;
		fifo[13] <=  0;
		fifo[14] <=  0;
		fifo[15] <=  0;
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)  // overrun condition
			begin
				top       <=  top_plus_1;
				fifo[top] <=  data_in[2:0];
				count     <=  count + 5'd1;
			end
		2'b01 : if(count>0)
			begin
        fifo[bottom] <=  0;
				bottom   <=  bottom + 4'd1;
				count	 <=  count - 5'd1;
			end
		2'b11 : begin
				bottom   <=  bottom + 4'd1;
				top       <=  top_plus_1;
				fifo[top] <=  data_in[2:0];
		        end
    default: ;
		endcase
	end
end   // always
always @(posedge clk ) // synchronous FIFO
begin
  if (wb_rst_i)
    overrun   <=  1'b0;
  else
  if(fifo_reset | reset_status) 
    overrun   <=  1'b0;
  else
  if(push & ~pop & (count==fifo_depth))
    overrun   <=  1'b1;
end   // always
// please note though that data_out is only valid one clock after pop signal
assign data_out = {data8_out,fifo[bottom]};
// Additional logic for detection of error conditions (parity and framing) inside the FIFO
// for the Line Status Register bit 7
wire	[2:0]	word0 = fifo[0];
wire	[2:0]	word1 = fifo[1];
wire	[2:0]	word2 = fifo[2];
wire	[2:0]	word3 = fifo[3];
wire	[2:0]	word4 = fifo[4];
wire	[2:0]	word5 = fifo[5];
wire	[2:0]	word6 = fifo[6];
wire	[2:0]	word7 = fifo[7];
wire	[2:0]	word8 = fifo[8];
wire	[2:0]	word9 = fifo[9];
wire	[2:0]	word10 = fifo[10];
wire	[2:0]	word11 = fifo[11];
wire	[2:0]	word12 = fifo[12];
wire	[2:0]	word13 = fifo[13];
wire	[2:0]	word14 = fifo[14];
wire	[2:0]	word15 = fifo[15];
// a 1 is returned if any of the error bits in the fifo is 1
assign	error_bit = |(word0[2:0]  | word1[2:0]  | word2[2:0]  | word3[2:0]  |
            		      word4[2:0]  | word5[2:0]  | word6[2:0]  | word7[2:0]  |
            		      word8[2:0]  | word9[2:0]  | word10[2:0] | word11[2:0] |
            		      word12[2:0] | word13[2:0] | word14[2:0] | word15[2:0] );
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_sync_flops.v                                             ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core receiver logic                                    ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None known                                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Thourough testing.                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andrej Erzen (andreje@flextronics.si)                 ////
////      - Tadej Markovic (tadejm@flextronics.si)                ////
////                                                              ////
////  Created:        2004/05/20                                  ////
////  Last Updated:   2004/05/20                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
//
module wb_uart16550_bus16_big_sync_flops 
(
  // internal signals
  rst_i,
  clk_i,
  stage1_rst_i,
  stage1_clk_en_i,
  async_dat_i,
  sync_dat_o
);
parameter width         = 1;
parameter init_value    = 1'b0;
input                           rst_i;                  // reset input
input                           clk_i;                  // clock input
input                           stage1_rst_i;           // synchronous reset for stage 1 FF
input                           stage1_clk_en_i;        // synchronous clock enable for stage 1 FF
input   [width-1:0]             async_dat_i;            // asynchronous data input
output  [width-1:0]             sync_dat_o;             // synchronous data output
//
// Interal signal declarations
//
reg     [width-1:0]             sync_dat_o;
reg     [width-1:0]             flop_0;
// first stage
always @ (posedge clk_i )
begin
    if (rst_i)
        flop_0 <=  {width{init_value}};
    else
        flop_0 <=  async_dat_i;    
end
// second stage
always @ (posedge clk_i )
begin
    if (rst_i)
        sync_dat_o <=  {width{init_value}};
    else if (stage1_rst_i)
        sync_dat_o <=  {width{init_value}};
    else if (stage1_clk_en_i)
        sync_dat_o <=  flop_0;       
end
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_tfifo.v                                                ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core transmitter FIFO                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing.                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2002/07/22                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.1  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.16  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.15  2001/12/18 09:01:07  mohor
// Bug that was entered in the last update fixed (rx state machine).
//
// Revision 1.14  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.13  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.12  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.11  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/24 08:48:10  mohor
// FIFO was not cleared after the data was read bug fixed.
//
// Revision 1.7  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.3  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:48  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//
module wb_uart16550_bus16_big_tfifo  (clk, 
	wb_rst_i, data_in, data_out,
// Control signals
	push, // push strobe, active high
	pop,   // pop strobe, active high
// status signals
	overrun,
	count,
	fifo_reset,
	reset_status
	);
// FIFO parameters
parameter fifo_width = 8;
parameter fifo_depth = 16;
parameter fifo_pointer_w = 4;
parameter fifo_counter_w = 5;
input				clk;
input				wb_rst_i;
input				push;
input				pop;
input	[fifo_width-1:0]	data_in;
input				fifo_reset;
input       reset_status;
output	[fifo_width-1:0]	data_out;
output				overrun;
output	[fifo_counter_w-1:0]	count;
wire	[fifo_width-1:0]	data_out;
// FIFO pointers
reg	[fifo_pointer_w-1:0]	top;
reg	[fifo_pointer_w-1:0]	bottom;
reg	[fifo_counter_w-1:0]	count;
reg				overrun;
wire [fifo_pointer_w-1:0] top_plus_1 = top + 4'd1;
wb_uart16550_bus16_big_raminfr 
  #( .addr_width  ( fifo_pointer_w ),
     .data_width  ( fifo_width     ),
     .depth       ( fifo_depth     )
     ) tfifo (
     .clk      ( clk      ), 
     .we       ( push     ), 
     .a        ( top      ), 
     .dpra     ( bottom   ), 
     .di       ( data_in  ), 
     .dpo      ( data_out )
     ); 
always @(posedge clk ) // synchronous FIFO
begin
	if (wb_rst_i)
	begin
		top		<=  0;
		bottom		<=  0;
		count		<=  0;
	end
	else
	if (fifo_reset) begin
		top		<=  0;
		bottom		<=  0;
		count		<=  0;
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)  // overrun condition
			begin
				top       <=  top_plus_1;
				count     <=  count + 5'd1;
			end
		2'b01 : if(count>0)
			begin
				bottom   <=  bottom + 4'd1;
				count	 <=  count - 5'd1;
			end
		2'b11 : begin
				bottom   <=  bottom + 4'd1;
				top       <=  top_plus_1;
		        end
    default: ;
		endcase
	end
end   // always
always @(posedge clk ) // synchronous FIFO
begin
  if (wb_rst_i)
    overrun   <=  1'b0;
  else
  if(fifo_reset | reset_status) 
    overrun   <=  1'b0;
  else
  if(push & (count==fifo_depth))
    overrun   <=  1'b1;
end   // always
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_transmitter.v                                          ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core transmitter logic                                 ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None known                                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Thourough testing.                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.18  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.16  2002/01/08 11:29:40  mohor
// tf_pop was too wide. Now it is only 1 clk cycle width.
//
// Revision 1.15  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.14  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.13  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.12  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.11  2001/10/29 17:00:46  gorban
// fixed parity sending and tx_fifo resets over- and underrun
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.6  2001/06/23 11:21:48  gorban
// DL made 16-bit long. Fixed transmission/reception bugs.
//
// Revision 1.5  2001/06/02 14:28:14  gorban
// Fixed receiver and transmitter. Major bug fixed.
//
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:49  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.1  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//
module wb_uart16550_bus16_big_transmitter  (
      input  wire                                   clk,
      input  wire                                   wb_rst_i,
      input  wire  [7:0]                            lcr,
      input  wire                                   tf_push,
      input  wire  [7:0]                            tf_data_in,
      input  wire                                   enable,
      input  wire                                   tx_reset,
      input  wire                                   lsr_mask, 
      output wire                                   stx_pad_o,
      output  reg [2:0]                             tstate,
      output wire [5-1:0]        tf_count
     );
reg [4:0]                                  counter;
reg [2:0]                                  bit_counter;   // counts the bits to be sent
reg [6:0]                                  shift_out;     // output shift register
reg                                        stx_o_tmp;
reg                                        parity_xor;  // parity of the word
reg                                        tf_pop;
reg                                        bit_out;
// TX FIFO instance
//
// Transmitter FIFO signals
wire [8-1:0]                tf_data_out;
wire                                       tf_overrun;
assign stx_pad_o = lcr[6] ? 1'b0 : stx_o_tmp;    // Break condition
wb_uart16550_bus16_big_tfifo  fifo_tx(     // error bit signal is not used in transmitter FIFO
     .clk           ( clk         ), 
     .wb_rst_i      ( wb_rst_i    ),
     .data_in       ( tf_data_in  ),
     .data_out      ( tf_data_out ),
     .push          ( tf_push     ),
     .pop           ( tf_pop      ),
     .overrun       ( tf_overrun  ),
     .count         ( tf_count    ),
     .fifo_reset    ( tx_reset    ),
     .reset_status  ( lsr_mask    )
);
// TRANSMITTER FINAL STATE MACHINE
parameter s_idle        = 3'd0;
parameter s_send_start  = 3'd1;
parameter s_send_byte   = 3'd2;
parameter s_send_parity = 3'd3;
parameter s_send_stop   = 3'd4;
parameter s_pop_byte    = 3'd5;
always @(posedge clk )
begin
  if (wb_rst_i)
  begin
     tstate       <=  s_idle;
     stx_o_tmp       <=  1'b1;
     counter   <=  5'b0;
     shift_out   <=  7'b0;
     bit_out     <=  1'b0;
     parity_xor  <=  1'b0;
     tf_pop      <=  1'b0;
     bit_counter <=  3'b0;
  end
  else
  if (enable)
  begin
     case (tstate)
     s_idle      :     if (~|tf_count) // if tf_count==0
               begin
                    tstate <=  s_idle;
                    stx_o_tmp <=  1'b1;
               end
               else
               begin
                    tf_pop <=  1'b0;
                    stx_o_tmp  <=  1'b1;
                    tstate  <=  s_pop_byte;
               end
     s_pop_byte :     begin
                    tf_pop <=  1'b1;
                    case (lcr[1:0])  // number of bits in a word
                    2'b00 : begin
                         bit_counter <=  3'b100;
                         parity_xor  <=  ^tf_data_out[4:0];
                         end
                    2'b01 : begin
                         bit_counter <=  3'b101;
                         parity_xor  <=  ^tf_data_out[5:0];
                         end
                    2'b10 : begin
                         bit_counter <=  3'b110;
                         parity_xor  <=  ^tf_data_out[6:0];
                         end
                    2'b11 : begin
                         bit_counter <=  3'b111;
                         parity_xor  <=  ^tf_data_out[7:0];
                         end
                    endcase
                    {shift_out[6:0], bit_out} <=  tf_data_out;
                    tstate <=  s_send_start;
               end
     s_send_start :     begin
                    tf_pop <=  1'b0;
                    if (~|counter)
                         counter <=  5'b01111;
                    else
                    if (counter == 5'b00001)
                    begin
                         counter <=  0;
                         tstate <=  s_send_byte;
                    end
                    else
                         counter <=  counter - 5'd1;
                    stx_o_tmp <=  1'b0;
               end
     s_send_byte :     begin
                    if (~|counter)
                         counter <=  5'b01111;
                    else
                    if (counter == 5'b00001)
                    begin
                         if (bit_counter > 3'b0)
                         begin
                              bit_counter <=  bit_counter - 3'd1;
                              {shift_out[5:0],bit_out  } <=  {shift_out[6:1], shift_out[0]};
                              tstate <=  s_send_byte;
                         end
                         else   // end of byte
                         if (~lcr[3])
                         begin
                              tstate <=  s_send_stop;
                         end
                         else
                         begin
                              case ({lcr[4],lcr[5]})
                              2'b00:     bit_out <=  ~parity_xor;
                              2'b01:     bit_out <=  1'b1;
                              2'b10:     bit_out <=  parity_xor;
                              2'b11:     bit_out <=  1'b0;
                              endcase
                              tstate <=  s_send_parity;
                         end
                         counter <=  0;
                    end
                    else
                         counter <=  counter - 5'd1;
                    stx_o_tmp <=  bit_out; // set output pin
               end
     s_send_parity :     begin
                    if (~|counter)
                         counter <=  5'b01111;
                    else
                    if (counter == 5'b00001)
                    begin
                         counter <=  5'd0;
                         tstate <=  s_send_stop;
                    end
                    else
                         counter <=  counter - 5'd1;
                    stx_o_tmp <=  bit_out;
               end
     s_send_stop :  begin
                    if (~|counter)
                      begin
                              casez ({lcr[2],lcr[1:0]})
                                3'b0??:       counter <=  5'b01101;     // 1 stop bit ok igor
                                3'b100:       counter <=  5'b10101;     // 1.5 stop bit
                                default:       counter <=  5'b11101;     // 2 stop bits
                              endcase
                         end
                    else
                    if (counter == 5'b00001)
                    begin
                         counter <=  0;
                         tstate <=  s_idle;
                    end
                    else
                         counter <=  counter - 5'd1;
                    stx_o_tmp <=  1'b1;
               end
          default : // should never get here
               tstate <=  s_idle;
     endcase
  end // end if enable
  else
    tf_pop <=  1'b0;  // tf_pop must be 1 cycle width
end // transmitter logic
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_wb.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core WISHBONE interface.                               ////
////                                                              ////
////  Known problems (limits):                                    ////
////  Inserts one wait state on all transfers.                    ////
////  Note affected signals and the way they are affected.        ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing.                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
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
// Revision 1.16  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.15  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//
// Revision 1.12  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.11  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.10  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.9  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.8  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.7  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/21 19:12:01  gorban
// Corrected some Linter messages.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:13+02  jacob
// Initial revision
//
//
// UART core WISHBONE interface 
//
// Author: Jacob Gorban   (jacob.gorban@flextronicssemi.com)
// Company: Flextronics Semiconductor
//
module wb_uart16550_bus16_big_wb_fsm  
(
input  wire    clk,
input  wire    wb_rst_i,
input  wire    wb_we_i,
input  wire    wb_stb_i,
input  wire    wb_cyc_i,
output  reg    wb_ack_o,
output wire    we_o,
output wire    re_o
);
reg            wb_we_is;
reg            wb_cyc_is;
reg            wb_stb_is;
reg            wre;
reg [1:0]      wbstate;
// Sample input signals
always  @(posedge clk )
    if (wb_rst_i) 
       begin
        wb_we_is  <=  0;
        wb_cyc_is <=  0;
        wb_stb_is <=  0;
       end 
    else 
       begin
        wb_we_is  <=  wb_we_i;
        wb_cyc_is <=  wb_cyc_i;
        wb_stb_is <=  wb_stb_i;
       end
always  @(posedge clk )
    if (wb_rst_i) 
       begin
        wb_ack_o <=  1'b0;
        wbstate <=  0;
        wre <=  1'b1;
       end 
    else
        case (wbstate)
            0: begin
                if (wb_stb_is && wb_cyc_is) 
                  begin
                    wre      <=  0;
                    wbstate  <=  1;
                    wb_ack_o <=  1;
                  end 
                 else 
                  begin
                    wre      <=  1;
                    wb_ack_o <=  0;
                  end
               end
            1: begin
               wb_ack_o      <=  0;
               wbstate       <=  2;
               wre           <=  0;
               end
            2,3: begin
                 wb_ack_o    <=  0;
                 wbstate     <=  0;
                 wre         <=  0;
                 end
        endcase
assign we_o =  wb_we_is && wb_stb_is *& wb_cyc_is && wre ; //WE for registers    
assign re_o = ~wb_we_is && wb_stb_is && wb_cyc_is && wre ; //RE for registers    
endmodule
