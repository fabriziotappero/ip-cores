//////////////////////////////////////////////////////////////////////
////                                                              ////
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

// Wishbone LPC Master/Slave Interface Definitions

`define LPC_START       4'b0000
`define LPC_STOP        4'b1111
`define LPC_FW_READ     4'b1101
`define LPC_FW_WRITE    4'b1110

`define LPC_SYNC_READY  4'b0000             // LPC Sync Ready
`define LPC_SYNC_SWAIT  4'b0101             // LPC Sync Short Wait (up to 8 cycles)
`define LPC_SYNC_LWAIT  4'b0110             // LPC Sync Long Wait (no limit)
`define LPC_SYNC_MORE   4'b1001             // LPC Sync Ready More (DMA only)
`define LPC_SYNC_ERROR  4'b1010             // LPC Sync Error

`define LPC_ST_IDLE     14'h000             // LPC Idle state
`define LPC_ST_START    14'h001             // LPC Start state
`define LPC_ST_CYCTYP   14'h002             // LPC Cycle Type State
`define LPC_ST_ADDR     14'h004             // LPC Address state (4 cycles)
`define LPC_ST_CHAN     14'h008             // LPC Address state (4 cycles)
`define LPC_ST_SIZE     14'h010             // LPC Address state (4 cycles)
`define LPC_ST_H_DATA   14'h020             // LPC Host Data state (2 cycles)
`define LPC_ST_P_DATA   14'h040             // LPC Peripheral Data state (2 cycles)
`define LPC_ST_H_TAR1   14'h080             // LPC Host Turnaround 1 (Drive LAD 4'hF)
`define LPC_ST_H_TAR2   14'h100             // LPC Host Turnaround 2 (Float LAD)
`define LPC_ST_P_TAR1   14'h200             // LPC Peripheral Turnaround 1 (Drive LAD = 4'hF)
`define LPC_ST_P_TAR2   14'h400             // LPC Peripheral Turnaround 2 (Float LAD)
`define LPC_ST_WB_RETIRE 14'h400            // Retire Wishbone transfer (Host only), ends WB cycle.
`define LPC_ST_SYNC     14'h800             // LPC Sync State (may be multiple cycles for wait-states)
`define LPC_ST_P_WAIT1  14'h1000            // LPC Sync State (may be multiple cycles for wait-states)
`define LPC_ST_FWW_SYNC 14'h2000            // LPC Sync State for Firmware Writes (must not generate wait-states)


`define WB_SEL_BYTE     4'b0001             // Byte Transfer
`define WB_SEL_SHORT    4'b0011             // Short Transfer
`define WB_SEL_WORD     4'b1111             // Word Transfer

`define WB_TGA_MEM      2'b00               // Memory Cycle
`define WB_TGA_IO       2'b01               // I/O Cycle
`define WB_TGA_FW       2'b10               // Firmware Cycle
`define WB_TGA_DMA      2'b11               // DMA Cycle

// LDRQ States

`define LDRQ_ST_IDLE    4'h0
`define LDRQ_ST_ADDR    4'h1
`define LDRQ_ST_ACT     4'h2
`define LDRQ_ST_DONE    4'h4
