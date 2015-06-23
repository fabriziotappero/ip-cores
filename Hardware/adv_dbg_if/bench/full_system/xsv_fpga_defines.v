//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1K test app definitions                                   ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/xess/                   ////
////                                                              ////
////  Description                                                 ////
////  DEfine target technology etc. Right now FIFOs are available ////
////  only for Xilinx Virtex FPGAs. (TARGET_VIRTEX)               ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, damjan.lampret@opencores.org          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
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
// $Log: xsv_fpga_defines.v,v $
// Revision 1.3  2010-01-08 01:41:07  Nathan
// Removed unused, non-existant include from CPU behavioral model.  Minor text edits.
//
// Revision 1.2  2008/07/11 08:16:01  Nathan
// Ran through dos2unix
//
// Revision 1.1  2008/07/08 19:11:54  Nathan
// Added second testbench to simulate a complete system, including OR1200, wb_conbus, and onchipram.  Renamed sim-only testbench directory from verilog to simulated_system.
//
// Revision 1.4  2004/04/05 08:44:35  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.2  2002/03/29 20:58:51  lampret
// Changed hardcoded address for fake MC to use a define.
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
//

//
// Define to target to Xilinx Virtex
//
//`define TARGET_VIRTEX

//
// Interrupts
//
`define APP_INT_RES1	1:0
`define APP_INT_UART	2
`define APP_INT_RES2	3
`define APP_INT_ETH	4
`define APP_INT_PS2	5
`define APP_INT_RES3	19:6

//
// Address map
//
`define APP_ADDR_DEC_W	3
`define APP_ADDR_SDRAM	`APP_ADDR_DEC_W'b001
`define APP_ADDR_DEC2_W  8
`define APP_ADDR_OCRAM	`APP_ADDR_DEC2_W'h00
`define APP_ADDR_DECP_W  8
//`define APP_ADDR_PERIP  `APP_ADDR_DECP_W'h99
`define APP_ADDR_VGA	`APP_ADDR_DECP_W'h97
`define APP_ADDR_ETH	`APP_ADDR_DECP_W'h92
`define APP_ADDR_AUDIO	`APP_ADDR_DECP_W'h9d
`define APP_ADDR_UART	`APP_ADDR_DECP_W'h90
`define APP_ADDR_PS2	`APP_ADDR_DECP_W'h94
`define APP_ADDR_RES1	`APP_ADDR_DECP_W'h9e
//`define APP_ADDR_RES2	`APP_ADDR_DECP_W'h9f
//`define APP_ADDR_FAKEMC	4'h6

// For simulation...
// `define DBG_IF_MODEL 1
