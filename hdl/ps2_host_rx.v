//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_rx.v                                               ////
////                                                              ////
////  Description                                                 ////
////  Receiver part, gathering bits from the ps2_data line        ////
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

module ps2_host_rx(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_negedge,
  input  wire ps2_data,
  output reg [7:0] rx_data,
  output reg ready,
  output reg error
);

// Read in 11 bit long frame.
reg [11:0] frame;
always @(posedge sys_clk)
begin
  if (sys_rst | ready) begin
    frame <= 1;
  end
  else begin
    frame <= (ps2_clk_negedge) ? {frame[10:0], ps2_data} : frame;
  end
end

// 12th bit marks end of frame.
always @(posedge sys_clk)
begin
  ready <= (sys_rst) ? 0 : frame[11];
end

// Return rx_data in most significant bit first order.
always @(posedge sys_clk)
begin
  if (sys_rst) begin
    rx_data <= 0;
  end
  else begin
    rx_data <= (frame[11]) ? {frame[2], frame[3], frame[4], frame[5],
                              frame[6], frame[7], frame[8], frame[9]} : rx_data;
  end
end

// Check that 1st bit is 0, odd parity bit is correct and last bit is 1.
always @(posedge sys_clk)
begin
  if (sys_rst) begin
    error <= 0;
  end
  else begin
    error <= (frame[11]) ? ~(~frame[10] & (~frame[1] == ^frame[9:2]) & frame[0]) : error;
  end
end

endmodule
