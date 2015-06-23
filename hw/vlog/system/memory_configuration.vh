//////////////////////////////////////////////////////////////////
//                                                              //
//  Memory configuration and Wishbone address decoding          //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  This module provides a set of functions that are used to    //
//  decode memory addresses so other modules know if an address //
//  is for example in main memory, or boot memory, or a UART    //
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

// e.g. 24 for 32MBytes, 26 for 128MBytes
localparam MAIN_MSB             = 26; 

// e.g. 13 for 4k words
localparam BOOT_MSB             = 13;  

localparam MAIN_BASE            = 32'h0000_0000; /*  Main Memory            */
localparam BOOT_BASE            = 32'h0000_0000; /*  Cachable Boot Memory   */
localparam AMBER_TM_BASE        = 16'h1300;      /*  Timers Module          */
localparam AMBER_IC_BASE        = 16'h1400;      /*  Interrupt Controller   */
localparam AMBER_UART0_BASE     = 16'h1600;      /*  UART 0                 */
localparam AMBER_UART1_BASE     = 16'h1700;      /*  UART 1                 */
localparam ETHMAC_BASE          = 16'h2000;      /*  Ethernet MAC           */
localparam HIBOOT_BASE          = 32'h2800_0000; /*  Uncachable Boot Memory */
localparam TEST_BASE            = 16'hf000;      /*  Test Module            */



function in_loboot_mem;
    input [31:0] address;
begin
in_loboot_mem  = (address >= BOOT_BASE   && 
                 address < (BOOT_BASE   + 2**(BOOT_MSB+1)-1));
end
endfunction


function in_hiboot_mem;
    input [31:0] address;
begin
in_hiboot_mem  = (address[31:BOOT_MSB+1] == HIBOOT_BASE[31:BOOT_MSB+1]);
end
endfunction


function in_boot_mem;
    input [31:0] address;
begin
in_boot_mem  =  in_loboot_mem(address) || in_hiboot_mem(address);
end
endfunction


function in_main_mem;
    input [31:0] address;
begin
in_main_mem  = (address >= MAIN_BASE   && 
                address < (MAIN_BASE   + 2**(MAIN_MSB+1)-1)) &&
                !in_boot_mem ( address );
end
endfunction


// UART 0 address space
function in_uart0;
    input [31:0] address;
begin
    in_uart0 = address [31:16] == AMBER_UART0_BASE;
end
endfunction


// UART 1 address space
function in_uart1;
    input [31:0] address;
begin
    in_uart1 = address [31:16] == AMBER_UART1_BASE;
end
endfunction


// Interrupt Controller address space
function in_ic;
    input [31:0] address;
begin
    in_ic = address [31:16] == AMBER_IC_BASE;
end
endfunction


// Timer Module address space
function in_tm;
    input [31:0] address;
begin
    in_tm = address [31:16] == AMBER_TM_BASE;
end
endfunction


// Test module
function in_test;
    input [31:0] address;
begin
    in_test = address [31:16] == TEST_BASE;
end
endfunction


// Ethernet MAC
function in_ethmac;
    input [31:0] address;
begin
    in_ethmac = address [31:16] == ETHMAC_BASE;
end
endfunction


// Used in fetch.v and l2cache.v to allow accesses to these addresses
// to be cached
function in_cachable_mem;
    input [31:0] address;
begin
    in_cachable_mem = in_loboot_mem     ( address ) || 
                      in_main_mem       ( address ) ; 
end
endfunction

