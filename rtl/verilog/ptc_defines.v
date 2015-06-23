//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE PWM/Timer/Counter Definitions                      ////
////                                                              ////
////  This file is part of the PTC project                        ////
////  http://www.opencores.org/cores/ptc/                         ////
////                                                              ////
////  Description                                                 ////
////  PTC definitions.                                            ////
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
// Revision 1.2  2001/08/21 23:23:50  lampret
// Changed directory structure, defines and port names.
//
// Revision 1.2  2001/07/17 00:18:08  lampret
// Added new parameters however RTL still has some issues related to hrc_match and int_match
//
// Revision 1.1  2001/06/05 07:45:36  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

//
// Width of the PTC counter
//
//
`define PTC_CW	32

//
// Undefine this one if you don't want to remove PTC block from your design
// but you also don't need it. When it is undefined, all PTC ports still
// remain valid and the core can be synthesized however internally there is
// no PTC funationality.
//
// Defined by default (duhh !).
//
`define PTC_IMPLEMENTED

//
// Undefine if you don't need to read PTC registers.
// When it is undefined all reads of PTC registers return zero. This
// is usually useful if you want really small area (for example when
// implemented in FPGA).
//
// To follow PTC IP core specification document this one must be defined.
// Also to successfully run the test bench it must be defined. By default
// it is defined.
//
`define PTC_READREGS

//
// Full WISHBONE address decoding
//
// It is is undefined, partial WISHBONE address decoding is performed.
// Undefine it if you need to save some area.
//
// By default it is defined.
//
`define PTC_FULL_DECODE

//
// Strict 32-bit WISHBONE access
//
// If this one is defined, all WISHBONE accesses must be 32-bit. If it is
// not defined, err_o is asserted whenever 8- or 16-bit access is made.
// Undefine it if you need to save some area.
//
// By default it is defined.
//
`define PTC_STRICT_32BIT_ACCESS

//
// WISHBONE address bits used for full decoding of PTC registers.
//
`define PTC_ADDRHH 15
`define PTC_ADDRHL 5
`define PTC_ADDRLH 1
`define PTC_ADDRLL 0

//
// Bits of WISHBONE address used for partial decoding of PTC registers.
//
// Default 4:2.
//
`define PTC_OFS_BITS	`PTC_ADDRHL-1:`PTC_ADDRLH+1

//
// Addresses of PTC registers
//
// To comply with PTC IP core specification document they must go from
// address 0 to address 0xC in the following order: RPTC_CNTR, RPTC_HRC,
// RPTC_LRC and RPTC_CTRL
//
// If particular alarm/ctrl register is not needed, it's address definition
// can be omitted and the register will not be implemented. Instead a fixed
// default value will
// be used.
//
`define PTC_RPTC_CNTR	2'h0	// Address 0x0
`define PTC_RPTC_HRC	2'h1	// Address 0x4
`define PTC_RPTC_LRC	2'h2	// Address 0x8
`define PTC_RPTC_CTRL	2'h3	// Address 0xc

//
// Default values for unimplemented PTC registers
//
`define PTC_DEF_RPTC_CNTR	`PTC_CW'b0
`define PTC_DEF_RPTC_HRC	`PTC_CW'b0
`define PTC_DEF_RPTC_LRC	`PTC_CW'b0
`define PTC_DEF_RPTC_CTRL	9'h01		// RPTC_CTRL[EN] = 1

//
// RPTC_CTRL bits
//
// To comply with the PTC IP core specification document they must go from
// bit 0 to bit 8 in the following order: EN, ECLK, NEC, OE, SINGLE, INTE,
// INT, CNTRRST, CAPTE
//
`define PTC_RPTC_CTRL_EN		0
`define PTC_RPTC_CTRL_ECLK		1
`define PTC_RPTC_CTRL_NEC		2
`define PTC_RPTC_CTRL_OE		3
`define PTC_RPTC_CTRL_SINGLE		4
`define PTC_RPTC_CTRL_INTE		5
`define PTC_RPTC_CTRL_INT		6
`define PTC_RPTC_CTRL_CNTRRST		7
`define PTC_RPTC_CTRL_CAPTE		8

