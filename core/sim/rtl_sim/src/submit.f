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
// $Rev: 154 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-10-15 22:44:20 +0200 (Mon, 15 Oct 2012) $
//=============================================================================

//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/
../../../bench/verilog/tb_openMSP430.v
../../../bench/verilog/ram.v
../../../bench/verilog/io_cell.v
../../../bench/verilog/msp_debug.v


//=============================================================================
// CPU
//=============================================================================

+incdir+../../../rtl/verilog/
-f ../src/core.f


//=============================================================================
// Peripherals
//=============================================================================

+incdir+../../../rtl/verilog/periph/
../../../rtl/verilog/periph/omsp_gpio.v
../../../rtl/verilog/periph/omsp_timerA.v
//../../../rtl/verilog/periph/omsp_uart.v
../../../rtl/verilog/periph/template_periph_8b.v
../../../rtl/verilog/periph/template_periph_16b.v
