//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: definition of parameters                        ////
////                                                              ////
//// DESCRIPTION:                                                 ////
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
// Revision 1.1.1.1  2006/05/31 05:59:44  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`define ALLONES 64'hffffffffffffffff
`define ALLONES8 8'hff
`define ALLZEROS   8'h00

///////////////////////////////////////////////
// Length parameters
///////////////////////////////////////////////
`define MAX_VALID_LENGTH 12'h0be
`define MAX_VALID_BITS_MORE 3'h6
`define MAX_TAG_LENGTH 12'h0bf
`define MAX_TAG_BITS_MORE 3'h2
`define MAX_JUMBO_LENGTH 12'h466
`define MIN_VALID_LENGTH 8'h08
///////////////////////////////////////////////
// Frame field parameters
///////////////////////////////////////////////
`define PREAMBLE 8'h55
`define START      8'hfb
`define TERMINATE  8'hfd 	
`define SFD        8'hd5
`define SEQUENCE   8'h9a
`define ERROR      8'hfe
`define IDLE       8'h07
`define TAG_SIGN   16'h0081//8100
`define PAUSE_SIGN 32'h01000888//8808

`define MULTICAST  48'h0180C2000001
`define BROADCAST  48'hffffffffffff
////////////////////////////////////////////////
// Frame bytes counter parameter
//////////////////////////////////////////////// 
`define COUNTER_WIDTH 12
