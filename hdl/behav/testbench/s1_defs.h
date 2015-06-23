/*
 * Simply RISC S1 Definitions
 *
 * (C) Copyleft 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * Simple constant definitions used by the S1 Core design.
 */

`include "t1_defs.h"
`timescale 1ns/100ps

// Size of the buses
`define WB_ADDR_WIDTH 64
`define WB_DATA_WIDTH 64

// States of the FSM of the bridge
`define STATE_WAKEUP          4'b0000
`define STATE_IDLE            4'b0001
`define STATE_REQUEST_LATCHED 4'b0010
`define STATE_PACKET_LATCHED  4'b0011
`define STATE_REQUEST_GRANTED 4'b0100
`define STATE_ACCESS2_BEGIN   4'b0101
`define STATE_ACCESS2_END     4'b0110
`define STATE_ACCESS3_BEGIN   4'b0111
`define STATE_ACCESS3_END     4'b1000
`define STATE_ACCESS4_BEGIN   4'b1001
`define STATE_ACCESS4_END     4'b1010
`define STATE_PACKET_READY    4'b1011

// Constants used by the timer of the Reset Controller
`define TIMER_BITS 16
`define RESET_CYCLES_1   100
`define RESET_CYCLES_2  1000
`define RESET_CYCLES_3  2000
`define RESET_CYCLES_4  3000
`define GCLK_CYCLES      900

