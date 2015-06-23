//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: Destination Address Check                       ////
////                                                              ////
//// DESCRIPTION: Destination Address Checker of  10 Gigabit      ////
////              Ethernet MAC.                                   ////
////                                                              ////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/                ////
////                                                              ////
//// AUTHOR(S):                                                   ////
//// Zheng Cao                                                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.            ////
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
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2006/05/31 05:59:41  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxDAchecker(rxclk,reset,local_invalid, broad_valid, multi_valid, MAC_Addr, da_addr);
   input  rxclk;
   input  reset;

   output local_invalid;
   output broad_valid;
   output multi_valid;

   input [47:0] MAC_Addr;
   input [47:0] da_addr;
 
   parameter TP = 1;
    
   reg multi_valid;
   reg broad_valid;
   reg local_valid;
   always @(posedge rxclk or posedge reset) begin
         if (reset) begin
           multi_valid <=#TP 0;
           broad_valid <=#TP 0;
           local_valid <=#TP 0;
         end
         else begin
           multi_valid <=#TP (da_addr==`MULTICAST);
           broad_valid <=#TP (da_addr==`BROADCAST);
           local_valid <=#TP (da_addr==MAC_Addr);
         end
  end

  assign local_invalid = 1'b0;//~local_valid & ~multi_valid & ~broad_valid;

endmodule
