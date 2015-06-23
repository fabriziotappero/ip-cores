//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rx clk generator                                ////
////                                                              ////
//// DESCRIPTION: Clk generator for Receive engine of 10 Gigabit  ////
////     Ethernet MAC.                                            ////
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

module rxClkgen(rxclk_in, reset, rxclk, rxclk_180, locked);
    input rxclk_in;
    input reset;
    output rxclk;
    output rxclk_180;
    output locked;
    // 2x clock should be provided with dcm
    wire rxclk;
    wire rxclk_180;
  //  wire rxclk_2x;
    /*dcm0 rx_dcm(.CLKIN_IN(rxclk_in), 
                .RST_IN(reset), 
                .CLKIN_IBUFG_OUT(), 
                .CLK0_OUT(rxclk), 
                .CLK180_OUT(rxclk_180),	
                .LOCKED_OUT(locked)
               );*/
    assign rxclk = rxclk_in;
    assign rxclk_180 = ~rxclk;
    assign locked = ~reset;

endmodule
