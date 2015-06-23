//=============================================================================
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
//-----------------------------------------------------------------------------
// 
// File Name: submit.f
// 
// Author(s):
//             - Olivier Girard,    olgirard@gmail.com
//
//-----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//=============================================================================

+define+OPENMSP430_SIMULATION

//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/
../../../bench/verilog/tb_openMSP430_fpga.v
../../../bench/verilog/msp_debug.v


//=============================================================================
// Altera library
//=============================================================================
+libext+.v

../../../bench/verilog/altsyncram.v


//=============================================================================
// FPGA Specific modules
//=============================================================================

+incdir+../../../rtl/verilog/
../../../rtl/verilog/OpenMSP430_fpga.v
../../../rtl/verilog/io_mux.v
../../../rtl/verilog/driver_7segment.v
../../../rtl/verilog/ram16x512.v
../../../rtl/verilog/rom16x2048.v


//=============================================================================
// openMSP430
//=============================================================================

+incdir+../../../rtl/verilog/openmsp430/
+incdir+../../../rtl/verilog/openmsp430/periph/
../../../rtl/verilog/openmsp430/openMSP430.v
../../../rtl/verilog/openmsp430/omsp_frontend.v
../../../rtl/verilog/openmsp430/omsp_execution_unit.v
../../../rtl/verilog/openmsp430/omsp_register_file.v
../../../rtl/verilog/openmsp430/omsp_alu.v
../../../rtl/verilog/openmsp430/omsp_sfr.v
../../../rtl/verilog/openmsp430/omsp_mem_backbone.v
../../../rtl/verilog/openmsp430/omsp_clock_module.v
../../../rtl/verilog/openmsp430/omsp_dbg.v
../../../rtl/verilog/openmsp430/omsp_dbg_hwbrk.v
../../../rtl/verilog/openmsp430/omsp_dbg_uart.v
../../../rtl/verilog/openmsp430/omsp_watchdog.v
../../../rtl/verilog/openmsp430/omsp_multiplier.v
../../../rtl/verilog/openmsp430/omsp_sync_reset.v
../../../rtl/verilog/openmsp430/omsp_sync_cell.v
../../../rtl/verilog/openmsp430/omsp_scan_mux.v
../../../rtl/verilog/openmsp430/omsp_and_gate.v
../../../rtl/verilog/openmsp430/omsp_wakeup_cell.v
../../../rtl/verilog/openmsp430/omsp_clock_gate.v
../../../rtl/verilog/openmsp430/omsp_clock_mux.v
../../../rtl/verilog/openmsp430/periph/omsp_gpio.v
../../../rtl/verilog/openmsp430/periph/omsp_timerA.v
