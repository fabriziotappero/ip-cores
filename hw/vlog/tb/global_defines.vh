//////////////////////////////////////////////////////////////////
//                                                              //
//  Global testbench defines                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains a set of defines for each module so if the module  //
//  hierarchy changes, hierarchical references to signals       //
//  will still work as long as this file is updated.            //
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

// ---------------------------------------------------------------
// Module hierarchy defines
// ---------------------------------------------------------------
`ifndef _GLOBAL_DEFINES
`define _GLOBAL_DEFINES

`ifndef AMBER_TIMEOUT
    `define AMBER_TIMEOUT 0
`endif

`define U_TB                    tb
`define U_SYSTEM                `U_TB.u_system

`define U_AMBER                 `U_SYSTEM.u_amber
`define U_FETCH                 `U_AMBER.u_fetch
`define U_MMU                   `U_FETCH.u_mmu
`define U_CACHE                 `U_FETCH.u_cache
`define U_COPRO15               `U_AMBER.u_coprocessor
`define U_EXECUTE               `U_AMBER.u_execute
`define U_WB                    `U_AMBER.u_write_back
`define U_REGISTER_BANK         `U_EXECUTE.u_register_bank
`define U_DECODE                `U_AMBER.u_decode
`define U_DECOMPILE             `U_DECODE.u_decompile
`define U_L2CACHE               `U_SYSTEM.u_l2cache
`define U_TEST_MODULE           `U_SYSTEM.u_test_module

`ifdef AMBER_A25_CORE
    `define U_MEM               `U_AMBER.u_mem
    `define U_DCACHE            `U_MEM.u_dcache
    `define U_WISHBONE          `U_AMBER.u_wishbone
    `define U_BOOT_MEM          `U_SYSTEM.boot_mem128.u_boot_mem
`else    
    `define U_WISHBONE          `U_FETCH.u_wishbone
    `define U_BOOT_MEM          `U_SYSTEM.boot_mem32.u_boot_mem
`endif
// ---------------------------------------------------------------

`define TB_DEBUG_MESSAGE        $display("\nDEBUG in %m @ tick %8d ", `U_TB.clk_count );
`define TB_WARNING_MESSAGE      $display("\nWARNING in %m @ tick %8d", `U_TB.clk_count );
`define TB_ERROR_MESSAGE        $display("\nFATAL ERROR in %m @ tick %8d", `U_TB.clk_count ); force `U_TB.testfail = 1'd1;


`ifdef XILINX_FPGA
// Full DDR3 memory Model
`define U_RAM                tb.u_ddr3_model_c3.memory
`else
// Simplified Main Memory Model
`define U_RAM                tb.u_system.u_main_mem.ram
`endif

`endif
