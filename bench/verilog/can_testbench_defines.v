//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_testbench_defines.v                                     ////
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
//// Copyright (C) 2002, 2003 Authors                             ////
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
// Revision 1.9  2003/09/30 20:53:58  mohor
// Fixing the core to be Bosch VHDL Reference compatible.
//
// Revision 1.8  2003/02/18 00:17:44  mohor
// Define CAN_CLOCK_DIVIDER_MODE not used any more. Deleted.
//
// Revision 1.7  2003/02/09 02:24:11  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.6  2003/01/14 12:19:29  mohor
// rx_fifo is now working.
//
// Revision 1.5  2003/01/09 14:46:52  mohor
// Temporary files (backup).
//
// Revision 1.4  2003/01/08 02:09:44  mohor
// Acceptance filter added.
//
// Revision 1.3  2002/12/28 04:13:53  mohor
// Backup version.
//
// Revision 1.2  2002/12/27 00:12:48  mohor
// Header changed, testbench improved to send a frame (crc still missing).
//
// Revision 1.1  2002/12/26 16:00:29  mohor
// Testbench define file added. Clock divider register added.
//
//
//
//

/* Mode register */
`define CAN_MODE_RESET                  1'h1    /* Reset mode */

/* Bit Timing 0 register value */
//`define CAN_TIMING0_BRP                 6'h0    /* Baud rate prescaler (2*(value+1)) */
//`define CAN_TIMING0_SJW                 2'h2    /* SJW (value+1) */

`define CAN_TIMING0_BRP                 6'h3    /* Baud rate prescaler (2*(value+1)) */
`define CAN_TIMING0_SJW                 2'h1    /* SJW (value+1) */

/* Bit Timing 1 register value */
//`define CAN_TIMING1_TSEG1               4'h4    /* TSEG1 segment (value+1) */
//`define CAN_TIMING1_TSEG2               3'h3    /* TSEG2 segment (value+1) */
//`define CAN_TIMING1_SAM                 1'h0    /* Triple sampling */

`define CAN_TIMING1_TSEG1               4'hf    /* TSEG1 segment (value+1) */
`define CAN_TIMING1_TSEG2               3'h2    /* TSEG2 segment (value+1) */
`define CAN_TIMING1_SAM                 1'h0    /* Triple sampling */


