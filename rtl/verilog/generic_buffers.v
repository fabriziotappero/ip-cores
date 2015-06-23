//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SMII                                                        ////
////                                                              ////
////  Description                                                 ////
////  Low pin count serial MII ethernet interface                 ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB          michael.unneback@orsoc.se           ////
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
module obufdff
  (
   input d,
   output reg pad,
   input clk,
   input rst
   );

   always @ (posedge clk or posedge rst)
     if (rst)
       pad <= #1 1'b0;
     else
       pad <= #1 d;
   
endmodule // obufdff

module ibufdff
  (
   input pad,
   output reg q,
   input clk,
   input rst
   );

   always @ (posedge clk or posedge rst)
     if (rst)
       q <= #1 1'b0;
     else
       q <= #1 pad;
   
endmodule // ibufdff

module iobuftri
  (
   input i,
   input oe,
   output o,
   inout pad
   );

   assign #1 pad = oe ? i : 1'bz;
   assign #1 i = pad;
   
endmodule // iobuftri

module obuf
  (
   input i,
   inout pad
   );

   assign #1 pad = i;
   
endmodule // iobuftri
