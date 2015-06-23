//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_defines.v                                               ////
////                                                              ////
////                                                              ////
////  This file is part of the CAN Protocol Controller            ////
////  http://www.opencores.org/projects/can/                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002, 2003, 2004 Authors                       ////
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
//// The CAN protocol is developed by Robert Bosch GmbH and       ////
//// protected by patents. Anybody who wants to implement this    ////
//// CAN IP core on silicon has to obtain a CAN protocol license  ////
//// from Bosch.                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.13  2004/02/08 14:28:03  mohor
// Header changed.
//
// Revision 1.12  2003/10/17 05:55:20  markom
// mbist signals updated according to newest convention
//
// Revision 1.11  2003/09/05 12:46:42  mohor
// ALTERA_RAM supported.
//
// Revision 1.10  2003/08/14 16:04:52  simons
// Artisan ram instances added.
//
// Revision 1.9  2003/06/27 20:56:15  simons
// Virtual silicon ram instances added.
//
// Revision 1.8  2003/06/09 11:32:36  mohor
// Ports added for the CAN_BIST.
//
// Revision 1.7  2003/03/20 16:51:55  mohor
// *** empty log message ***
//
// Revision 1.6  2003/03/12 04:19:13  mohor
// 8051 interface added (besides WISHBONE interface). Selection is made in
// can_defines.v file.
//
// Revision 1.5  2003/03/05 15:03:20  mohor
// Xilinx RAM added.
//
// Revision 1.4  2003/03/01 22:52:47  mohor
// Actel APA ram supported.
//
// Revision 1.3  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.2  2002/12/27 00:12:52  mohor
// Header changed, testbench improved to send a frame (crc still missing).
//
// Revision 1.1.1.1  2002/12/20 16:39:21  mohor
// Initial
//
//
//


// Uncomment following line if you want to use WISHBONE interface. Otherwise
// 8051 interface is used.
// `define   CAN_WISHBONE_IF

// Uncomment following line if you want to use CAN in Actel APA devices (embedded memory used)
// `define   ACTEL_APA_RAM

// Uncomment following line if you want to use CAN in Altera devices (embedded memory used)
// `define   ALTERA_RAM

// Uncomment following line if you want to use CAN in Xilinx devices (embedded memory used)
// `define   XILINX_RAM

// Uncomment the line for the ram used in ASIC implementation
// `define   VIRTUALSILICON_RAM
// `define   ARTISAN_RAM

// Uncomment the following line when RAM BIST is needed (ASIC implementation)
//`define CAN_BIST                    // Bist (for ASIC implementation)

/* width of MBIST control bus */
//`define CAN_MBIST_CTRL_WIDTH 3
