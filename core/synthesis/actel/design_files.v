//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: openMSP430_fpga_top.v
// 
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 37 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-12-29 21:58:14 +0100 (Tue, 29 Dec 2009) $
//----------------------------------------------------------------------------

//=============================================================================
// FPGA Specific modules
//=============================================================================

`include "../src/openMSP430_fpga.v"
`include "../src/smartgen/pmem.v"
`include "../src/smartgen/dmem.v"


//=============================================================================
// openMSP430
//=============================================================================

`include "../src/openMSP430.v"
`include "../src/omsp_frontend.v"
`include "../src/omsp_execution_unit.v"
`include "../src/omsp_register_file.v"
`include "../src/omsp_alu.v"
`include "../src/omsp_mem_backbone.v"
`include "../src/omsp_clock_module.v"
`include "../src/omsp_sfr.v"
`include "../src/omsp_watchdog.v"
`include "../src/omsp_sync_cell.v"

`include "../src/openMSP430_defines.v"
`ifdef DBG_EN
   `include "../src/omsp_dbg.v"
   `include "../src/omsp_dbg_uart.v"
   `include "../src/openMSP430_defines.v"
   `ifdef DBG_HWBRK_0
      `include "../src/omsp_dbg_hwbrk.v"
   `endif
`endif
