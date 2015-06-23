//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host.v                                                  ////
////                                                              ////
////  Description                                                 ////
////  Top file, gluing all parts together                         ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ps2_host_clk_ctrl.v"
`include "ps2_host_watchdog.v"
`include "ps2_host_rx.v"
`include "ps2_host_tx.v"

module ps2_host(
  input wire sys_clk,
  input wire sys_rst,
  inout wire ps2_clk,
  inout wire ps2_data,

  input  wire [7:0] tx_data,
  input  wire send_req,
  output wire busy,

  output wire [7:0] rx_data,
  output wire ready,
  output wire error
);

ps2_host_clk_ctrl ps2_host_clk_ctrl (
  .sys_clk(sys_clk),
  .sys_rst(sys_rst),
  .send_req(send_req),
  .ps2_clk(ps2_clk),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_clk_negedge(ps2_clk_negedge)
);

ps2_host_watchdog ps2_host_watchdog(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_clk_negedge(ps2_clk_negedge),
  .watchdog_rst(watchdog_rst)
);

ps2_host_rx ps2_host_rx(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst | busy | watchdog_rst),
  .ps2_clk_negedge(ps2_clk_negedge),
  .ps2_data(ps2_data),
  .rx_data(rx_data),
  .ready(ready),
  .error(error)
);

ps2_host_tx ps2_host_tx(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst | watchdog_rst),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_data(ps2_data),
  .tx_data(tx_data),
  .send_req(send_req),
  .busy(busy)
);

endmodule
