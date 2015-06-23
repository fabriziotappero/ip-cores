//////////////////////////////////////////////////////////////////////
////                                                              ////
////  timescale.v                                                 ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////  http://www.opencores.org/projects/DebugInterface/           ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2004 Authors                            ////
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
// $Log: timescale.v,v $
// Revision 1.2  2010-01-08 01:41:08  Nathan
// Removed unused, non-existant include from CPU behavioral model.  Minor text edits.
//
// Revision 1.1  2008/07/08 19:11:56  Nathan
// Added second testbench to simulate a complete system, including OR1200, wb_conbus, and onchipram.  Renamed sim-only testbench directory from verilog to simulated_system.
//
// Revision 1.1  2008/06/18 18:34:48  Nathan
// Initial working version.  Only Wishbone module implemented.  Simple testbench included, with CPU and Wishbone behavioral models from the old dbg_interface.
//
// Revision 1.1.1.1  2008/05/14 12:07:36  Nathan
// Original from OpenCores
//
// Revision 1.4  2004/03/28 20:27:40  igorm
// New release of the debug interface (3rd. release).
//
// Revision 1.3  2004/01/17 17:01:25  mohor
// Almost finished.
//
// Revision 1.2  2003/12/23 14:26:01  mohor
// New version of the debug interface. Not finished, yet.
//
//
//
//
`timescale 1ns/10ps

