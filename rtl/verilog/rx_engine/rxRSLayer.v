//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rxRSLayer                                       ////
////                                                              ////
//// DESCRIPTION: Reconciliation SubLayer of 10 Gigabit Ethernet. ////
////                                                              ////
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
// Revision 1.2  2006/06/16 06:36:28  fisher5090
// no message
//
// Revision 1.1.1.1  2006/05/31 05:59:43  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxRSLayer(rxclk, rxclk_180, rxclk_2x, reset, link_fault, rxd64, rxc8, rxd_in, rxc_in);
    input rxclk;
    input rxclk_180;
    input rxclk_2x;
    input reset;     
    input [31:0] rxd_in;
    input [3:0] rxc_in;
    output [1:0] link_fault;
    output [63:0] rxd64;
    output [7:0] rxc8;

    wire  local_fault;
    wire  remote_fault;
    wire[1:0]  link_fault;

    rxRSIO datapath(.rxclk(rxclk), 
                    .rxclk_180(rxclk_180),
                    .rxclk_2x(rxclk_2x),
                    .reset(reset), 
                    .rxd_in(rxd_in), 
                    .rxc_in(rxc_in), 
                    .rxd64(rxd64), 
                    .rxc8(rxc8), 
                    .local_fault(local_fault), 
                    .remote_fault(remote_fault)
                   );
 
    rxLinkFaultState statemachine(.rxclk(rxclk_180),
                                  .reset(reset),
                                  .local_fault(local_fault), 
                                  .remote_fault(remote_fault), 
                                  .link_fault(link_fault)
                   );

endmodule
