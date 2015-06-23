//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_watchdog.v                                         ////
////                                                              ////
////  Description                                                 ////
////  Generate reset signal if ps2_clk line is too quiet          ////
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
`include "ps2_host_defines.v"

module ps2_host_watchdog(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_posedge,
  input  wire ps2_clk_negedge,
  output wire watchdog_rst
);

wire ps2_clk_edge = ps2_clk_posedge | ps2_clk_negedge;

reg watchdog_active;
always @(posedge sys_clk)
begin
  if (sys_rst | watchdog_rst | ~(watchdog_active | ps2_clk_edge)) begin
    watchdog_active = 0;
  end
  else begin
    watchdog_active = 1;
  end
end

reg [`T_200_MICROSECONDS_SIZE - 1:0] watchdog_timer;
always @(posedge sys_clk)
begin
  if (sys_rst | watchdog_rst | ~watchdog_active | ps2_clk_edge) begin
    watchdog_timer <= `T_200_MICROSECONDS;
  end
  else begin
    watchdog_timer <= watchdog_timer - 1;
  end
end

assign watchdog_rst = (|watchdog_timer) ? 1'b0 : 1'b1;

endmodule
