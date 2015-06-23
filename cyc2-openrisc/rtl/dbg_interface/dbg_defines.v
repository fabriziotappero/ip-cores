//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_defines.v                                               ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001 Authors                              ////
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
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.8  2002/01/25 07:58:34  mohor
// IDCODE bug fixed, chains reused to decreas size of core. Data is shifted-in
// not filled-in. Tested in hw.
//
// Revision 1.7  2001/12/06 10:08:06  mohor
// Warnings from synthesys tools fixed.
//
// Revision 1.6  2001/11/28 09:38:30  mohor
// Trace disabled by default.
//
// Revision 1.5  2001/10/15 09:55:47  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.4  2001/09/24 14:06:42  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.3  2001/09/20 10:11:25  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.2  2001/09/18 14:13:47  mohor
// Trace fixed. Some registers changed, trace simplified.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
// Revision 1.3  2001/06/01 22:22:35  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:00  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:08  mohor
// Initial release
//
//



// Enable TRACE
//`define TRACE_ENABLED  // Uncomment this define to activate the trace


// Define IDCODE Value
`define IDCODE_VALUE  32'hdeadbeef

// Define master clock (RISC clock)
//`define	RISC_CLOCK  50   // Half period = 50 ns => MCLK = 10 Mhz
`define	RISC_CLOCK  2.5   // Half period = 5 ns => MCLK = 200 Mhz

// Length of the Instruction register
`define	IR_LENGTH	4

// Length of the Data register (must be equal to the longest scan chain for shifting the data in)
`define	DR_LENGTH	74

// Length of the CHAIN ID register
`define	CHAIN_ID_LENGTH	4

// Length of the CRC
`define	CRC_LENGTH	8

// Trace buffer size and counter and write/read pointer width. This can be expanded when more RAM is avaliable
`define TRACECOUNTERWIDTH        5  
`define TRACEBUFFERLENGTH        32 // 2^5

`define TRACESAMPLEWIDTH         36

// OpSelect width
`define OPSELECTWIDTH            3
`define OPSELECTIONCOUNTER       8    //2^3

// OpSelect (dbg_op_i) signal meaning
`define DEBUG_READ_PC            0
`define DEBUG_READ_LSEA          1
`define DEBUG_READ_LDATA         2
`define DEBUG_READ_SDATA         3
`define DEBUG_READ_SPR           4
`define DEBUG_WRITE_SPR          5
`define DEBUG_READ_INSTR         6
//`define Reserved                 7

// Supported Instructions
`define EXTEST          4'b0000
`define SAMPLE_PRELOAD  4'b0001
`define IDCODE          4'b0010
`define CHAIN_SELECT    4'b0011
`define INTEST          4'b0100
`define CLAMP           4'b0101
`define CLAMPZ          4'b0110
`define HIGHZ           4'b0111
`define DEBUG           4'b1000
`define BYPASS          4'b1111

// Chains
`define GLOBAL_BS_CHAIN     4'b0000
`define RISC_DEBUG_CHAIN    4'b0001
`define RISC_TEST_CHAIN     4'b0010
`define TRACE_TEST_CHAIN    4'b0011
`define REGISTER_SCAN_CHAIN 4'b0100
`define WISHBONE_SCAN_CHAIN 4'b0101

// Registers addresses
`define MODER_ADR           5'h00
`define TSEL_ADR            5'h01
`define QSEL_ADR            5'h02
`define SSEL_ADR            5'h03
`define RISCOP_ADR          5'h04
`define RECSEL_ADR          5'h10


// Registers default values (after reset)
`define MODER_DEF           2'h0
`define TSEL_DEF            32'h00000000
`define QSEL_DEF            32'h00000000
`define SSEL_DEF            32'h00000000
`define RISCOP_DEF          2'h0
`define RECSEL_DEF          7'h0
