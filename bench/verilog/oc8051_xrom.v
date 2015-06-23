//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 exteranl program rom                                   ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   external program rom for 8051 core                         ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
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
// Revision 1.1  2003/04/02 11:38:40  simont
// initial inport
//
// Revision 1.1  2002/10/17 18:56:13  simont
// initial CVS input
//
//

module oc8051_xrom (rst, clk, addr, data, stb_i, cyc_i, ack_o);

parameter DELAY=5;


input rst, clk, stb_i, cyc_i;
input [15:0] addr;
output ack_o;
output [31:0] data;


reg ack_o;
reg [31:0] data;

reg [7:0] buff [0:65535];
//reg [7:0] buff [8388607:0];
reg [2:0] cnt;
integer i;


initial
begin
//  for (i=0; i<65536; i=i+1)
//    buff [i] = 8'h00;
  $readmemh("../../../bench/in/oc8051_xrom.in", buff);
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    data <= #1 31'h0;
    ack_o <= #1 1'b0;
  end else if (stb_i && ((DELAY==3'b000) || (cnt==3'b000))) begin
    data <= #1 {buff[addr+3], buff[addr+2], buff[addr+1], buff [addr]};
    ack_o <= #1 1'b1;
  end else
    ack_o <= #1 1'b0;
end

always @(posedge clk or posedge rst)
begin
  if (rst)
    cnt <= #1 DELAY;
  else if (cnt == 3'b000)
    cnt <= #1 DELAY;
  else if (stb_i)
    cnt <= #1 cnt - 3'b001;
  else cnt <= #1 DELAY;
end

endmodule


