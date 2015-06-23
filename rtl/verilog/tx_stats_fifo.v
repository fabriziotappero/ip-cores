//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "tx_hold_fifo.v"                                  ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
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


`include "defines.v"

module tx_stats_fifo(/*AUTOARG*/
  // Outputs
  txsfifo_rdata, txsfifo_rempty,
  // Inputs
  clk_xgmii_tx, reset_xgmii_tx_n, wb_clk_i, wb_rst_i, txsfifo_wdata,
  txsfifo_wen
  );

input         clk_xgmii_tx;
input         reset_xgmii_tx_n;
input         wb_clk_i;
input         wb_rst_i;

input [13:0]  txsfifo_wdata;
input         txsfifo_wen;

output [13:0] txsfifo_rdata;
output        txsfifo_rempty;

generic_fifo #(
  .DWIDTH (14),
  .AWIDTH (`TX_STAT_FIFO_AWIDTH),
  .REGISTER_READ (1),
  .EARLY_READ (1),
  .CLOCK_CROSSING (1),
  .ALMOST_EMPTY_THRESH (7),
  .ALMOST_FULL_THRESH (12),
  .MEM_TYPE (`MEM_AUTO_SMALL)
)
fifo0(
    .wclk (clk_xgmii_tx),
    .wrst_n (reset_xgmii_tx_n),
    .wen (txsfifo_wen),
    .wdata (txsfifo_wdata),
    .wfull (),
    .walmost_full (),

    .rclk (wb_clk_i),
    .rrst_n (~wb_rst_i),
    .ren (1'b1),
    .rdata (txsfifo_rdata),
    .rempty (txsfifo_rempty),
    .ralmost_empty ()
);

endmodule
