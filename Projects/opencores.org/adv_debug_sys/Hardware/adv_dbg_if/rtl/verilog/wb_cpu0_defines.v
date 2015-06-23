//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_defines.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the Advanced Debug Interface.          ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 - 2010 Authors                            ////
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


// Length of the MODULE ID register
`define	DBG_TOP_MODULE_ID_LENGTH	2

// How many modules can be supported by the module id length
`define     DBG_TOP_MAX_MODULES           4

// Chains
`define DBG_TOP_WISHBONE_DEBUG_MODULE  2'h0
`define DBG_TOP_CPU0_DEBUG_MODULE      2'h1
`define DBG_TOP_CPU1_DEBUG_MODULE      2'h2
`define DBG_TOP_JSP_DEBUG_MODULE       2'h3

// Length of data
`define DBG_TOP_MODULE_DATA_LEN  53


// If WISHBONE sub-module is supported uncomment the following line
`define DBG_WISHBONE_SUPPORTED

// If CPU_0 sub-module is supported uncomment the following line
`define DBG_CPU0_SUPPORTED

// If CPU_1 sub-module is supported uncomment the following line
//`define DBG_CPU1_SUPPORTED

// To include the JTAG Serial Port (JSP), uncomment the following line
//`define DBG_JSP_SUPPORTED  

// Define this if you intend to use the JSP in a system with multiple
// devices on the JTAG chain
//`define ADBG_JSP_SUPPORT_MULTI

// If this is defined, status bits will be skipped on burst
// reads and writes to improve download speeds.
`define ADBG_USE_HISPEED
