//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name: eth_phy_defines.v                                ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Tadej Markovic, tadej@opencores.org                   ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002,  Authors                                 ////
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
// Revision 1.1  2002/09/13 11:57:20  mohor
// New testbench. Thanks to Tadej M - "The Spammer".
//
//
//

// Address of PHY device (LXT971A)
`define ETH_PHY_ADDR                 5'h01

// LED/Configuration pins on PHY device - see the specification, page 26, table 8
// Initial set of bits 13, 12 and 8 of Control Register
`define LED_CFG1                     1'b0
`define LED_CFG2                     1'b0
`define LED_CFG3                     1'b1

// Supported speeds and physical ports - see the specification, page 67, table 41
// Set bits 15 to 9 of Status Register
`define SUPPORTED_SPEED_AND_PORT     7'h3F

// Extended status register (address 15)
// Set bit 8 of Status Register
`define EXTENDED_STATUS              1'b0

// Default status bits - see the specification, page 67, table 41
// Set bits 6 to 0 of Status Register
`define DEFAULT_STATUS               7'h09

// PHY ID 1 number - see the specification, page 68, table 42
// Set bits of Phy Id Register 1
`define PHY_ID1                      16'h0013

// PHY ID 2 number - see the specification, page 68, table 43
// Set bits 15 to 10 of Phy Id Register 2
`define PHY_ID2                      6'h1E

// Manufacturer MODEL number - see the specification, page 68, table 43
// Set bits 9 to 4 of Phy Id Register 2
`define MAN_MODEL_NUM                6'h0E

// Manufacturer REVISION number - see the specification, page 68, table 43
// Set bits 3 to 0 of Phy Id Register 2
`define MAN_REVISION_NUM             4'h2




