//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ge_1000baseX_constants.v"                        ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
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
////                                                              ////
//// This module is based on the coding method described in       ////
//// IEEE Std 802.3-2008 Clause 36 "Physical Coding Sublayer(PCS) ////
//// and Physical Medium Attachment (PMA) sublayer, type          ////
//// 1000BASE-X"; see :                                           ////
////                                                              ////
//// http://standards.ieee.org/about/get/802/802.3.html           ////
//// and                                                          ////
//// doc/802.3-2008_section3.pdf, Clause/Section 36.              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

// XMIT Autonegotiation parameter - ctrl for the PCS TX state machine   
`define XMIT_IDLE           0
`define XMIT_CONFIGURATION  1
`define XMIT_DATA           2
   
`define RUDI_INVALID 0
`define RUDI_IDLE    1
`define RUDI_CONF    2
   
// Special K code-groups - K codes
`define K28_0_symbol 8'h1c
`define K28_1_symbol 8'h3c
`define K28_2_symbol 8'h5c
`define K28_3_symbol 8'h7c
`define K28_4_symbol 8'h9c
`define K28_5_symbol 8'hbc
`define K28_6_symbol 8'hdc
`define K28_7_symbol 8'hfc
`define K23_7_symbol 8'hf7
`define K27_7_symbol 8'hfb
`define K29_7_symbol 8'hfd
`define K30_7_symbol 8'hfe

// Special D code-groups - D codes   
`define D21_5_symbol  8'hb5
`define D2_2_symbol   8'h42
`define D5_6_symbol   8'hc5
`define D16_2_symbol  8'h50
`define D0_0_symbol   8'h00

`define D21_2_symbol  8'h55
`define D21_6_symbol  8'hd5

`define D6_6_symbol   8'hc6
`define D10_1_symbol  8'h2a
`define D3_3_symbol   8'h63
`define D27_7_symbol  8'hfb
`define D3_0_symbol   8'h03

`define D30_2_symbol  8'h5e
`define D12_4_symbol  8'h8c
`define D8_6_symbol   8'hc8
`define D13_7_symbol  8'hed

// Code group ordered_sets
`define I_CODE  4'b0001
`define I1_CODE 4'b0010
`define I2_CODE 4'b0011
`define C_CODE  4'b0100
`define C1_CODE 4'b0101
`define C2_CODE 4'b0110
`define R_CODE  4'b0111
`define S_CODE  4'b1000
`define T_CODE  4'b1001
`define V_CODE  4'b1010

// -ve and +ve 10b symbols 
`define pK28_5_10b_symbol 10'b1100000101 // 0x305
`define nK28_5_10b_symbol 10'b0011111010 // 0x0fa

`define pD5_6_10b_symbol  10'b1010010110 // 0x296
`define nD5_6_10b_symbol  10'b1010010110 // 0x296
   
`define pD16_2_10b_symbol 10'b1001000101 // 0x245
`define nD16_2_10b_symbol 10'b0110110101 // 0x1b5

`define pD0_0_10b_symbol  10'b0110001011 // 0x18b
`define nD0_0_10b_symbol  10'b1001110100 // 0x274 

`define pK27_7_10b_symbol 10'b0010010111  // 0x097
`define nK27_7_10b_symbol 10'b1101101000  // 0x368


