//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  Definitions.                                                ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
// Revision 1.1.1.1  2001/10/02 15:33:33  mihad
// New project directory structure
//
//

//`define XILINX_RAMB4
`define SSVGA_640x480

`ifdef SSVGA_640x480
`define PIXEL_NUM 'd307200 // 383330
`define SSVGA_HCW	10
`define SSVGA_VCW	10
//`define SSVGA_HTOT	`SSVGA_HCW'd3178
//`define SSVGA_HPULSE	`SSVGA_HCW'd381
`define SSVGA_HTOT	    `SSVGA_HCW'd750
`define SSVGA_HPULSE	`SSVGA_HCW'd90
`define SSVGA_HFRONTP   `SSVGA_HCW'd10
`define SSVGA_HBACKP    `SSVGA_HCW'd10

//`define SSVGA_VTOT	`SSVGA_VCW'd525
//`define SSVGA_VPULSE	`SSVGA_VCW'd3
`define SSVGA_VTOT	    `SSVGA_VCW'd511
`define SSVGA_VPULSE	`SSVGA_VCW'd4
`define SSVGA_VFRONTP   `SSVGA_HCW'd12
`define SSVGA_VBACKP    `SSVGA_HCW'd15
`define SSVGA_VMCW	17
`endif

`define XILINX_RAMB4