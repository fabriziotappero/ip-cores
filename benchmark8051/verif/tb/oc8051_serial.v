//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 test serial interface                                  ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   submodul of oc8051_tb, used to comunicate with 8051        ////
////   serial potr                                                ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_serial (clk, rst, rxd, txd);

parameter FREQ  = 25000;
parameter BRATE = 9.6;

parameter DELAY = FREQ/BRATE;

input        clk,
             rst,
	     rxd;

output       txd;

reg          txd,
             transmit;
reg          txd_start;
reg   [8:0]  txd_data;
reg   [15:0] count;
reg   [8:0]  txd_buf;
reg   [63:0] wait_t;
reg   [7:0]  buff [0:65535];

reg          receive;
reg   [7:0]  rxd_buf;
reg   [63:0] wait_r;

reg   [7:0] tmp;

reg receive_r;
reg rxd_r;

initial
begin
  $readmemh("../../../serial.txt", buff);
end

/*
always @(posedge clk or posedge rst)
  if (rst) begin
    count <= #1 16'h0;
  end else begin
    count <= #1 count + 16'h1;
    $display (" serial h: %h   d: %d    count: %h", buff[count],  buff[count], count);
  end
*/

always @(posedge clk or posedge rst)
  if (rst) begin
    wait_t   <= #1 64'h0;
    txd_buf  <= #1 9'h1ff;
    txd      <= #1 1'b1;
    transmit <= #1 1'b0;
  end else if (txd_start) begin
    transmit <= #1 1'b1;
    txd_buf  <= #1 {txd_data, 1'b0};
  end else if ((wait_t >= DELAY) & transmit) begin
    wait_t         <= #1 64'h0;
    {txd_buf, txd} <= #1 {1'b1, txd_buf};
    transmit       <= #1 ~&{txd_buf, txd};
  end else begin
    wait_t  <= #1 wait_t + 64'h1;
  end

always @(posedge clk or posedge rst)
  if (rst) begin
    wait_r    <= #1 64'h0;
    rxd_buf   <= #1 8'hff;
    rxd_r     <= #1 1'b0;
    receive   <= #1 1'b0;
  end else if (rxd_r & !rxd & !receive) begin
    wait_r  <= #1 DELAY / 2;
    rxd_r <= #1 1'b0;
    receive <= #1 1'b1;
    rxd_buf <= #1 8'hff;
  end else if ((wait_r >= DELAY) & receive) begin
    wait_r  <= #1 64'h0;
    {rxd_buf, receive} <= #1 {rxd, rxd_buf};
  end else if (receive) begin
    wait_r  <= #1 wait_r + 64'h1;
  end else begin
    rxd_r <= #1 rxd;
  end


always @(posedge clk or posedge rst)
begin
  if (rst) begin
    receive_r <= #1 1'b0;
    txd_start <= #1 1'b0;
    txd_data  <= #1 8'h0;
    tmp       <= #1 8'h0;
  end else if (!receive & receive_r) begin
    receive_r <= #1 1'b0;
    if ((tmp==8'h3f) && (rxd_buf==8'h20)) begin
      txd_start <= #1 1'b1;
      txd_data  <= #1 8'h33;
    end else if (rxd_buf==8'h33) begin
      txd_start <= #1 1'b1;
      txd_data  <= #1 8'h36;
    end else if (rxd_buf==8'h36) begin
      txd_start <= #1 1'b1;
      txd_data  <= #1 8'h0a;
    end
    tmp         <= #1 rxd_buf;
    $display (" receive:  %s , %h", rxd_buf, rxd_buf);
  end else begin
    txd_start   <= #1 1'b0;
    receive_r   <= #1 receive;
  end
end

endmodule
