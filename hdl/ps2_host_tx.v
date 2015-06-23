//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_tx.v                                               ////
////                                                              ////
////  Description                                                 ////
////  Transmitter part, sending bits down the ps2_data line       ////
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

module ps2_host_tx(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_posedge,
  inout  wire ps2_data,
  input  wire [7:0] tx_data,
  input  wire send_req,
  output wire busy
);

reg [11:0] frame;
wire frame_is_zero = ~|frame;
always @(posedge sys_clk)
begin
  if (sys_rst | (~send_req & frame_is_zero)) begin
    frame <= 0;
  end
  else if (frame_is_zero) begin
    frame <= {2'b00, tx_data[0], tx_data[1], tx_data[2], tx_data[3],
                     tx_data[4], tx_data[5], tx_data[6], tx_data[7], ~^tx_data, 1'b1};
  end
  else begin
    frame <= (ps2_clk_posedge) ? {frame[10:0], 1'b0} : frame;
  end
end

// Send data down the line.
assign ps2_data = ((~|frame[10:0]) | frame[0]) ? 1'bz : frame[11];

// Keep high until all bits transmitted and ACK received
assign busy = ~frame_is_zero;

endmodule
