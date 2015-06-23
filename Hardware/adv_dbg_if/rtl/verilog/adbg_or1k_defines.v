//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_or1k_defines.v                                         ////
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
//// Copyright (C) 2008 - 2010       Authors                      ////
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
// $Log: adbg_or1k_defines.v,v $
// Revision 1.3  2010-01-10 22:54:10  Nathan
// Update copyright dates
//
// Revision 1.2  2009/05/17 20:54:56  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/22 20:28:31  Nathan
// Changed names of all files and modules (prefixed an a, for advanced).  Cleanup, indenting.  No functional changes.
//
// Revision 1.3  2008/07/06 20:02:54  Nathan
// Fixes for synthesis with Xilinx ISE (also synthesizable with 
// Quartus II 7.0).  Ran through dos2unix.
//
// Revision 1.2  2008/06/26 20:52:31  Nathan
// OR1K module tested and working.  Added copyright / license info 
// to _define files.  Other cleanup.
//


// These relate to the number of internal registers, and how
// many bits are required in the Reg. Select register
`define DBG_OR1K_REGSELECT_SIZE 1
`define DBG_OR1K_NUM_INTREG 1

// Register index definitions for module-internal registers
// Index 0 is the Status register, used for stall and reset
`define DBG_OR1K_INTREG_STATUS 1'b0

`define DBG_OR1K_STATUS_LEN 2

// Valid commands/opcodes for the or1k debug module
// 0000  NOP
// 0001 - 0010 Reserved
// 0011  Write burst, 32-bit access
// 0100 - 0110  Reserved
// 0111  Read burst, 32-bit access
// 1000  Reserved
// 1001  Internal register select/write
// 1010 - 1100 Reserved
// 1101  Internal register select
// 1110 - 1111 Reserved


`define DBG_OR1K_CMD_BWRITE32 4'h3
`define DBG_OR1K_CMD_BREAD32  4'h7
`define DBG_OR1K_CMD_IREG_WR  4'h9
`define DBG_OR1K_CMD_IREG_SEL 4'hd
