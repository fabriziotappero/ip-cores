//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_defines.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Set of core customization defines.                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
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
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


///
/// LCD Controller defines
///
`define ADDR_WIDTH 7			// Address bus width
`define ADDR_RNG `ADDR_WIDTH-1:0	// Address bus range
`define DAT_WIDTH 8			// data bus width
`define DAT_RNG `DAT_WIDTH-1:0		// Address bus range
`define MEM_LENGTH 67			// Number of LCD memory positions.
`define MEM_ADDR_WIDTH 7		// Memory address bus width
`define MEM_LOW1  `ADDR_WIDTH'h00 //0	// Memory address of the first character at the first line
`define MEM_HIGH1 `ADDR_WIDTH'h15 //21	// Memory address of the last character at the first line
`define MEM_LOW2  `ADDR_WIDTH'h40 //64	// Memory address of the first character at the second line
`define MEM_HIGH2 `ADDR_WIDTH'h55 //85	// Memory address of the last character at the second line

`define INIT_DELAY_COUNTER_WIDTH 20	// Delay cycle counter width for init & main FSM
`define TX_DELAY_COUNTER_WIDTH 11	// Delay cycle counter width for TX FSM
`define _1MS_DELAY_CYCLES 50		// Number of cycles for a 1ms delay

///
/// WB wrapper defines
///

// WB interface
`define WB_DAT_WIDTH 32			// WB data bus width
`define WB_DAT_RNG `WB_DAT_WIDTH-1:0	// WB data bus range
`define WB_ADDR_WIDTH 32		// WB address bus width
`define WB_ADDR_RNG `WB_ADDR_WIDTH-1:0	// WB address bus range
`define WB_BSEL_WIDTH 4			// WB byte sel bus width
`define WB_BSEL_RNG `WB_BSEL_WIDTH-1:0	// WB byte sel bus range
`define ADDRESS_BIT


// Command and status registers address mask
`define SPECIAL_REG_ADDR_MASK 32'h00000080

// LCD characters memory mapping
`define FIRST_LCD_ADDR 0			// Address at where first LCD character is mapped (0)

// Command register and command codes
`define COMMAND_REG_ADDR 32'h00000080		// Address at where command register is mapped (128)
`define COMMAND_NOP_CODE 32'h00000000		// Code for repaint command	
`define COMMAND_REPAINT_CODE 32'h00000001	// Code for repaint command

// Status register and status codes
`define STATUS_REG_ADDR 32'h00000080		// Address at where status register is mapped (129)
`define STATUS_IDDLE_CODE 32'h00000000		// Code for iddle status
`define STATUS_BUSY_CODE 32'h00000001		// Code for busy status

