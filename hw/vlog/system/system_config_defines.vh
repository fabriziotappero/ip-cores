//////////////////////////////////////////////////////////////////
//                                                              //
//  System Configuration and Debug                              //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains a set of defines used to configure and debug       //
//  the Amber peripherals.                                      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

`ifndef _SYSTEM_CONFIG_DEFINES
`define _SYSTEM_CONFIG_DEFINES

// Select the A23 or A25 version of the core
// You can also select the A25 core on the command line using the run script
//`define AMBER_A25_CORE


// Frequency = 800 / AMBER_CLK_DIVIDER
// 20 = 40.00 MHz
// 24 = 33.33 MHz
// 29 = 27.58 MHz
// 40 = 20.00 MHz
//
// Note that for FPGA synthesis this value is overridden
// by a value specified in $AMBER_BASE/hw/fpga/bin/Makefile
`ifdef XILINX_VIRTEX6_FPGA
    `define AMBER_CLK_DIVIDER 13
`else 
    `define AMBER_CLK_DIVIDER 20
`endif

// Specify a device, if none defined then the
// generic library is used which is the fastest for simulations
// `define XILINX_SPARTAN6_FPGA
// `define XILINX_VIRTEX6_FPGA

// UART Baud rate for both uarts
// e.g. 921600, 460800, 230400, 57600
// `define AMBER_UART_BAUD 921600
`define AMBER_UART_BAUD 921600


// --------------------------------------------------------------------
// Debug switches 
// --------------------------------------------------------------------

// Add jitter to wishbone accesses
//`define AMBER_WISHBONE_DEBUG

// Print UART debug messages
//`define AMBER_UART_DEBUG

// Print Interrupt Controller debug messages
//`define AMBER_IC_DEBUG

// Debug the loading of the memory file into memory
//`define AMBER_LOAD_MEM_DEBUG

// Debug main memory interface
// `define AMBER_MEMIF_DEBUG
// --------------------------------------------------------------------


// --------------------------------------------------------------------
// Waveform dumping
// --------------------------------------------------------------------

// Normally these defines are fed in via the simulator command line

// Create a VCD Dump File
// `define AMBER_DUMP_VCD
// Measured in system clock ticks
//`define AMBER_DUMP_START  25348000
`define AMBER_DUMP_LENGTH 150000

// --------------------------------------------------------------------
// Xilinx FPGA ?
// --------------------------------------------------------------------
`ifdef XILINX_SPARTAN6_FPGA
    `define XILINX_FPGA
`endif
`ifdef XILINX_VIRTEX6_FPGA
    `define XILINX_FPGA
`endif

    
// --------------------------------------------------------------------
// File Names
// --------------------------------------------------------------------
`ifndef AMBER_TEST_NAME
    `define AMBER_TEST_NAME         "add"
`endif
`ifndef MAIN_MEM_FILE
    `define MAIN_MEM_FILE           "not-defined"
`endif
`ifndef BOOT_MEM_FILE
    `define BOOT_MEM_FILE           "../tests/add.mem"
`endif
`ifndef BOOT_MEM32_PARAMS_FILE
    `define BOOT_MEM32_PARAMS_FILE    "not-defined"
`endif
`ifndef BOOT_MEM128_PARAMS_FILE
    `define BOOT_MEM128_PARAMS_FILE    "not-defined"
`endif
`ifndef AMBER_LOG_FILE
    `define AMBER_LOG_FILE          "tests.log"
`endif
`ifndef AMBER_VCD_FILE
    `define AMBER_VCD_FILE          "sim.vcd"
`endif


`endif

