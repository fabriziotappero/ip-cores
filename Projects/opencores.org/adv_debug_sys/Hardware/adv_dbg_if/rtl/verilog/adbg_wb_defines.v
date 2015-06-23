//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_wb_defines.v                                           ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Advanced Debug Interface.      ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2010        Authors                       ////
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
// $Log: adbg_wb_defines.v,v $
// Revision 1.4  2010-01-10 22:54:11  Nathan
// Update copyright dates
//
// Revision 1.3  2009/05/17 20:54:57  Nathan
// Changed email address to opencores.org
//
// Revision 1.2  2009/05/04 00:50:11  Nathan
// Changed the WB BIU to use big-endian byte ordering, to match the OR1000.  Kept little-endian ordering as a compile-time option in case this is ever used with a little-endian CPU.
//
// Revision 1.1  2008/07/22 20:28:32  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//

// Endian-ness of the Wishbone interface.
// Default is BIG endian, to match the OR1200.
// If using a LITTLE endian CPU, e.g. an x86, un-comment this line.
//`define DBG_WB_LITTLE_ENDIAN

// These relate to the number of internal registers, and how
// many bits are required in the Reg. Select register
`define DBG_WB_REGSELECT_SIZE 1
`define DBG_WB_NUM_INTREG 1

// Register index definitions for module-internal registers
// The WB module has just 1, the error register
`define DBG_WB_INTREG_ERROR 1'b0

// Valid commands/opcodes for the wishbone debug module
// 0000  NOP
// 0001  Write burst, 8-bit access
// 0010  Write burst, 16-bit access
// 0011  Write burst, 32-bit access
// 0100  Reserved
// 0101  Read burst, 8-bit access
// 0110  Read burst, 16-bit access
// 0111  Read burst, 32-bit access
// 1000  Reserved
// 1001  Internal register select/write
// 1010 - 1100 Reserved
// 1101  Internal register select
// 1110 - 1111 Reserved

`define DBG_WB_CMD_BWRITE8  4'h1
`define DBG_WB_CMD_BWRITE16 4'h2
`define DBG_WB_CMD_BWRITE32 4'h3
`define DBG_WB_CMD_BREAD8   4'h5
`define DBG_WB_CMD_BREAD16  4'h6
`define DBG_WB_CMD_BREAD32  4'h7
`define DBG_WB_CMD_IREG_WR  4'h9
`define DBG_WB_CMD_IREG_SEL 4'hd
