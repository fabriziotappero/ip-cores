//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: serirq_defines.v,v 1.2 2008-12-27 19:46:18 hharte Exp $
////  wb_lpc_defines.v                                            ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
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

// Wishbone SERIRQ Host/Slave Interface Definitions
`define SERIRQ_ST_IDLE    13'h000             // SERIRQ Idle state
`define SERIRQ_ST_START   13'h001             // SERIRQ Start state
`define SERIRQ_ST_START_R 13'h002             // SERIRQ Start state
`define SERIRQ_ST_START_T 13'h004             // SERIRQ Start state
`define SERIRQ_ST_IRQ     13'h008             // SERIRQ IRQ Frame State
`define SERIRQ_ST_IRQ_R   13'h010             // SERIRQ IRQ Frame State
`define SERIRQ_ST_IRQ_T   13'h020             // SERIRQ IRQ Frame State
`define SERIRQ_ST_STOP    13'h040             // SERIRQ Stop State
`define SERIRQ_ST_STOP_R  13'h080             // SERIRQ Stop State
`define SERIRQ_ST_STOP_T  13'h100             // SERIRQ Stop State
`define SERIRQ_ST_WAIT_STOP 13'h200

`define SERIRQ_MODE_CONTINUOUS 1'b0           // Serirq "Continuous Mode"
`define SERIRQ_MODE_QUIET  1'b1               // Serirq "Quiet Mode"
