//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "wishbone.v"                                      ////
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

module stats(/*AUTOARG*/
  // Outputs
  stats_tx_pkts, stats_tx_octets, stats_rx_pkts, stats_rx_octets,
  // Inputs
  wb_rst_i, wb_clk_i, txsfifo_wen, txsfifo_wdata, rxsfifo_wen,
  rxsfifo_wdata, reset_xgmii_tx_n, reset_xgmii_rx_n, clk_xgmii_tx,
  clk_xgmii_rx, clear_stats_tx_pkts, clear_stats_tx_octets,
  clear_stats_rx_pkts, clear_stats_rx_octets
  );


/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input                   clear_stats_rx_octets;  // To stats_sm0 of stats_sm.v
input                   clear_stats_rx_pkts;    // To stats_sm0 of stats_sm.v
input                   clear_stats_tx_octets;  // To stats_sm0 of stats_sm.v
input                   clear_stats_tx_pkts;    // To stats_sm0 of stats_sm.v
input                   clk_xgmii_rx;           // To rx_stats_fifo0 of rx_stats_fifo.v
input                   clk_xgmii_tx;           // To tx_stats_fifo0 of tx_stats_fifo.v
input                   reset_xgmii_rx_n;       // To rx_stats_fifo0 of rx_stats_fifo.v
input                   reset_xgmii_tx_n;       // To tx_stats_fifo0 of tx_stats_fifo.v
input [13:0]            rxsfifo_wdata;          // To rx_stats_fifo0 of rx_stats_fifo.v
input                   rxsfifo_wen;            // To rx_stats_fifo0 of rx_stats_fifo.v
input [13:0]            txsfifo_wdata;          // To tx_stats_fifo0 of tx_stats_fifo.v
input                   txsfifo_wen;            // To tx_stats_fifo0 of tx_stats_fifo.v
input                   wb_clk_i;               // To tx_stats_fifo0 of tx_stats_fifo.v, ...
input                   wb_rst_i;               // To tx_stats_fifo0 of tx_stats_fifo.v, ...
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output [31:0]           stats_rx_octets;        // From stats_sm0 of stats_sm.v
output [31:0]           stats_rx_pkts;          // From stats_sm0 of stats_sm.v
output [31:0]           stats_tx_octets;        // From stats_sm0 of stats_sm.v
output [31:0]           stats_tx_pkts;          // From stats_sm0 of stats_sm.v
// End of automatics

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [13:0]             rxsfifo_rdata;          // From rx_stats_fifo0 of rx_stats_fifo.v
wire                    rxsfifo_rempty;         // From rx_stats_fifo0 of rx_stats_fifo.v
wire [13:0]             txsfifo_rdata;          // From tx_stats_fifo0 of tx_stats_fifo.v
wire                    txsfifo_rempty;         // From tx_stats_fifo0 of tx_stats_fifo.v
// End of automatics

tx_stats_fifo tx_stats_fifo0(/*AUTOINST*/
                             // Outputs
                             .txsfifo_rdata     (txsfifo_rdata[13:0]),
                             .txsfifo_rempty    (txsfifo_rempty),
                             // Inputs
                             .clk_xgmii_tx      (clk_xgmii_tx),
                             .reset_xgmii_tx_n  (reset_xgmii_tx_n),
                             .wb_clk_i          (wb_clk_i),
                             .wb_rst_i          (wb_rst_i),
                             .txsfifo_wdata     (txsfifo_wdata[13:0]),
                             .txsfifo_wen       (txsfifo_wen));

rx_stats_fifo rx_stats_fifo0(/*AUTOINST*/
                             // Outputs
                             .rxsfifo_rdata     (rxsfifo_rdata[13:0]),
                             .rxsfifo_rempty    (rxsfifo_rempty),
                             // Inputs
                             .clk_xgmii_rx      (clk_xgmii_rx),
                             .reset_xgmii_rx_n  (reset_xgmii_rx_n),
                             .wb_clk_i          (wb_clk_i),
                             .wb_rst_i          (wb_rst_i),
                             .rxsfifo_wdata     (rxsfifo_wdata[13:0]),
                             .rxsfifo_wen       (rxsfifo_wen));

stats_sm stats_sm0(/*AUTOINST*/
                   // Outputs
                   .stats_tx_octets     (stats_tx_octets[31:0]),
                   .stats_tx_pkts       (stats_tx_pkts[31:0]),
                   .stats_rx_octets     (stats_rx_octets[31:0]),
                   .stats_rx_pkts       (stats_rx_pkts[31:0]),
                   // Inputs
                   .wb_clk_i            (wb_clk_i),
                   .wb_rst_i            (wb_rst_i),
                   .txsfifo_rdata       (txsfifo_rdata[13:0]),
                   .txsfifo_rempty      (txsfifo_rempty),
                   .rxsfifo_rdata       (rxsfifo_rdata[13:0]),
                   .rxsfifo_rempty      (rxsfifo_rempty),
                   .clear_stats_tx_octets(clear_stats_tx_octets),
                   .clear_stats_tx_pkts (clear_stats_tx_pkts),
                   .clear_stats_rx_octets(clear_stats_rx_octets),
                   .clear_stats_rx_pkts (clear_stats_rx_pkts));

endmodule
