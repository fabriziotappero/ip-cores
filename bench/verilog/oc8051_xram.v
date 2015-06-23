//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 external data ram                                      ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   external data ram                                          ////
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
// Revision 1.4  2002/10/17 18:53:04  simont
// added parameter DELAY
//
// Revision 1.3  2002/09/30 17:34:01  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_xram (clk, rst, wr, addr, data_in, data_out, ack, stb);
//
// external data ram for simulation. part of oc8051_tb
// it's tehnology dependent
//
// clk          (in)  clock
// addr         (in)  addres
// data_in      (out) data input
// data_out     (in)  data output
// wr           (in)  write
// ack          (out) acknowlage
// stb          (in)  strobe
//

parameter DELAY=1;


input clk, wr, stb, rst;
input [7:0] data_in;
input [15:0] addr;
output [7:0] data_out;
output ack;

reg ackw, ackr;
reg [7:0] data_out;
reg [2:0] cnt;

//
// buffer
reg [7:0] buff [65535:0];  //64kb
//reg [7:0] buff [8388607:0];  //8Mb

assign ack =  ackw || ackr;


//
// writing to ram
always @(posedge clk or posedge rst)
begin
  if (rst)
    ackw <= #1 1'b0;
  else if (wr && stb && ((DELAY==3'b000) || (cnt==3'b000))) begin
    buff[addr] <= #1 data_in;
    ackw <= #1 1'b1;
  end else ackw <= #1 1'b0;
end

always @(posedge clk or posedge rst)
  if (rst)
    ackr <= #1 1'b0;
  else if (stb && !wr && ((DELAY==3'b000) || (cnt==3'b000))) begin
    data_out <= #1 buff[addr];
    ackr <= #1 1'b1;
  end else begin
    ackr <= #1 1'b0;
    data_out <= #1 8'h00;
  end

always @(posedge clk or posedge rst)
begin
  if (rst)
    cnt <= #1 DELAY;
  else if (cnt==3'b000)
    cnt <= #1 DELAY;
  else if (stb)
    cnt <= #1 cnt - 3'b001;
  else cnt <= #1 DELAY;
end


endmodule
