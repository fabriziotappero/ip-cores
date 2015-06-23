//////////////////////////////////////////////////////////////////////
////                                                              ////
////  GPIO Testbench Definitions                                  ////
////                                                              ////
////  This file is part of the GPIO project                       ////
////  http://www.opencores.org/cores/gpio/                        ////
////                                                              ////
////  Description                                                 ////
////  Testbench definitions that affect how testbench simulation  ////
////  is performed.                                               ////
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
// Revision 1.2  2001/08/21 22:01:50  lampret
// More intensive verification.
//
// Revision 1.1  2001/08/21 21:39:27  lampret
// Changed directory structure, port names and drfines.
//
// Revision 1.2  2001/07/14 20:37:23  lampret
// Test bench improvements.
//
// Revision 1.1  2001/06/05 07:45:22  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

//
// Define if you want VCD dump
//
`define GPIO_DUMP_VCD

//
// Intensity of verification
//
// Higher number means more intensive verification. Higher number
// means more loops of each subtest (e.g. for some subtests
// 5 means 50 loops, for others 100 etc). Good numbers are from 1
// (very fast and very little verification) to 200 (slow but thorough).
// Default is 200.
//
`define GPIO_VERIF_INTENSITY 200
