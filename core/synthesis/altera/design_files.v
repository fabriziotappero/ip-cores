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
`include "../src/arch.v"
`include "../src/openMSP430_fpga.v"

`ifdef CYCLONE_II
   `include "../src/megawizard/cyclone2_pmem.v"
   `include "../src/megawizard/cyclone2_dmem.v"
`endif
`ifdef CYCLONE_III
   `include "../src/megawizard/cyclone3_pmem.v"
   `include "../src/megawizard/cyclone3_dmem.v"
`endif
`ifdef CYCLONE_IV_GX
   `include "../src/megawizard/cyclone4gx_pmem.v"
   `include "../src/megawizard/cyclone4gx_dmem.v"
`endif
`ifdef ARRIA_GX
   `include "../src/megawizard/arriagx_pmem.v"
   `include "../src/megawizard/arriagx_dmem.v"
`endif
`ifdef ARRIA_II_GX
   `include "../src/megawizard/arria2gx_pmem.v"
   `include "../src/megawizard/arria2gx_dmem.v"
`endif
`ifdef STRATIX
   `include "../src/megawizard/stratix_pmem.v"
   `include "../src/megawizard/stratix_dmem.v"
`endif
`ifdef STRATIX_II
   `include "../src/megawizard/stratix2_pmem.v"
   `include "../src/megawizard/stratix2_dmem.v"
`endif
`ifdef STRATIX_III
   `include "../src/megawizard/stratix3_pmem.v"
   `include "../src/megawizard/stratix3_dmem.v"
`endif


//=============================================================================
// openMSP430
//=============================================================================

`include "../../../rtl/verilog/openMSP430.v"
`include "../../../rtl/verilog/omsp_frontend.v"
`include "../../../rtl/verilog/omsp_execution_unit.v"
`include "../../../rtl/verilog/omsp_register_file.v"
`include "../../../rtl/verilog/omsp_alu.v"
`include "../../../rtl/verilog/omsp_sfr.v"
`include "../../../rtl/verilog/omsp_clock_module.v"
`include "../../../rtl/verilog/omsp_mem_backbone.v"
`include "../../../rtl/verilog/omsp_watchdog.v"
`include "../../../rtl/verilog/omsp_sync_cell.v"
`include "../../../rtl/verilog/omsp_sync_reset.v"

`include "../src/openMSP430_defines.v"
`ifdef DBG_EN
   `include "../../../rtl/verilog/omsp_dbg.v"
   `include "../../../rtl/verilog/omsp_dbg_uart.v"
   `include "../src/openMSP430_defines.v"
   `ifdef DBG_HWBRK_0
      `include "../../../rtl/verilog/omsp_dbg_hwbrk.v"
   `endif
`endif
`include "../src/openMSP430_defines.v"
`ifdef MULTIPLIER
   `include "../../../rtl/verilog/omsp_multiplier.v"
`endif
