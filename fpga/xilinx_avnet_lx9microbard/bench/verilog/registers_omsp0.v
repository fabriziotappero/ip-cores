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
// *File Name: registers.v
// 
// *Module Description:
//                      Direct connections to internal registers & memory.
//
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 143 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-05-09 22:20:03 +0200 (Wed, 09 May 2012) $
//----------------------------------------------------------------------------

// CPU registers
//======================

wire       [15:0] omsp0_r0    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r0;
wire       [15:0] omsp0_r1    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r1;
wire       [15:0] omsp0_r2    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r2;
wire       [15:0] omsp0_r3    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r3;
wire       [15:0] omsp0_r4    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r4;
wire       [15:0] omsp0_r5    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r5;
wire       [15:0] omsp0_r6    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r6;
wire       [15:0] omsp0_r7    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r7;
wire       [15:0] omsp0_r8    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r8;
wire       [15:0] omsp0_r9    = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r9;
wire       [15:0] omsp0_r10   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r10;
wire       [15:0] omsp0_r11   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r11;
wire       [15:0] omsp0_r12   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r12;
wire       [15:0] omsp0_r13   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r13;
wire       [15:0] omsp0_r14   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r14;
wire       [15:0] omsp0_r15   = dut.omsp_system_0_inst.openMSP430_0.execution_unit_0.register_file_0.r15;


// Data Memory cells
//======================

wire       [15:0] omsp0_mem200 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[0];
wire       [15:0] omsp0_mem202 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[1];
wire       [15:0] omsp0_mem204 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[2];
wire       [15:0] omsp0_mem206 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[3];
wire       [15:0] omsp0_mem208 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[4];
wire       [15:0] omsp0_mem20A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[5];
wire       [15:0] omsp0_mem20C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[6];
wire       [15:0] omsp0_mem20E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[7];
wire       [15:0] omsp0_mem210 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[8];
wire       [15:0] omsp0_mem212 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[9];
wire       [15:0] omsp0_mem214 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[10];
wire       [15:0] omsp0_mem216 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[11];
wire       [15:0] omsp0_mem218 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[12];
wire       [15:0] omsp0_mem21A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[13];
wire       [15:0] omsp0_mem21C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[14];
wire       [15:0] omsp0_mem21E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[15];
wire       [15:0] omsp0_mem220 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[16];
wire       [15:0] omsp0_mem222 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[17];
wire       [15:0] omsp0_mem224 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[18];
wire       [15:0] omsp0_mem226 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[19];
wire       [15:0] omsp0_mem228 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[20];
wire       [15:0] omsp0_mem22A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[21];
wire       [15:0] omsp0_mem22C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[22];
wire       [15:0] omsp0_mem22E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[23];
wire       [15:0] omsp0_mem230 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[24];
wire       [15:0] omsp0_mem232 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[25];
wire       [15:0] omsp0_mem234 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[26];
wire       [15:0] omsp0_mem236 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[27];
wire       [15:0] omsp0_mem238 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[28];
wire       [15:0] omsp0_mem23A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[29];
wire       [15:0] omsp0_mem23C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[30];
wire       [15:0] omsp0_mem23E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[31];
wire       [15:0] omsp0_mem240 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[32];
wire       [15:0] omsp0_mem242 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[33];
wire       [15:0] omsp0_mem244 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[34];
wire       [15:0] omsp0_mem246 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[35];
wire       [15:0] omsp0_mem248 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[36];
wire       [15:0] omsp0_mem24A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[37];
wire       [15:0] omsp0_mem24C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[38];
wire       [15:0] omsp0_mem24E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[39];
wire       [15:0] omsp0_mem250 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[40];
wire       [15:0] omsp0_mem252 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[41];
wire       [15:0] omsp0_mem254 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[42];
wire       [15:0] omsp0_mem256 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[43];
wire       [15:0] omsp0_mem258 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[44];
wire       [15:0] omsp0_mem25A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[45];
wire       [15:0] omsp0_mem25C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[46];
wire       [15:0] omsp0_mem25E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[47];
wire       [15:0] omsp0_mem260 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[48];
wire       [15:0] omsp0_mem262 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[49];
wire       [15:0] omsp0_mem264 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[50];
wire       [15:0] omsp0_mem266 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[51];
wire       [15:0] omsp0_mem268 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[52];
wire       [15:0] omsp0_mem26A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[53];
wire       [15:0] omsp0_mem26C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[54];
wire       [15:0] omsp0_mem26E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[55];
wire       [15:0] omsp0_mem270 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[56];
wire       [15:0] omsp0_mem272 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[57];
wire       [15:0] omsp0_mem274 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[58];
wire       [15:0] omsp0_mem276 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[59];
wire       [15:0] omsp0_mem278 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[60];
wire       [15:0] omsp0_mem27A = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[61];
wire       [15:0] omsp0_mem27C = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[62];
wire       [15:0] omsp0_mem27E = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[63];
wire       [15:0] omsp0_mem280 = dut.ram_16x1k_sp_dmem_omsp0.ram_sp_inst.mem[64];


// Program Memory cells
//======================
reg   [15:0] pmem [0:8191];

// Interrupt vectors
wire  [15:0] irq_vect_15 = pmem[(1<<(`PMEM_MSB+1))-1];  // RESET Vector
wire  [15:0] irq_vect_14 = pmem[(1<<(`PMEM_MSB+1))-2];  // NMI
wire  [15:0] irq_vect_13 = pmem[(1<<(`PMEM_MSB+1))-3];  // IRQ 13
wire  [15:0] irq_vect_12 = pmem[(1<<(`PMEM_MSB+1))-4];  // IRQ 12
wire  [15:0] irq_vect_11 = pmem[(1<<(`PMEM_MSB+1))-5];  // IRQ 11
wire  [15:0] irq_vect_10 = pmem[(1<<(`PMEM_MSB+1))-6];  // IRQ 10
wire  [15:0] irq_vect_09 = pmem[(1<<(`PMEM_MSB+1))-7];  // IRQ  9
wire  [15:0] irq_vect_08 = pmem[(1<<(`PMEM_MSB+1))-8];  // IRQ  8
wire  [15:0] irq_vect_07 = pmem[(1<<(`PMEM_MSB+1))-9];  // IRQ  7
wire  [15:0] irq_vect_06 = pmem[(1<<(`PMEM_MSB+1))-10]; // IRQ  6
wire  [15:0] irq_vect_05 = pmem[(1<<(`PMEM_MSB+1))-11]; // IRQ  5
wire  [15:0] irq_vect_04 = pmem[(1<<(`PMEM_MSB+1))-12]; // IRQ  4
wire  [15:0] irq_vect_03 = pmem[(1<<(`PMEM_MSB+1))-13]; // IRQ  3
wire  [15:0] irq_vect_02 = pmem[(1<<(`PMEM_MSB+1))-14]; // IRQ  2
wire  [15:0] irq_vect_01 = pmem[(1<<(`PMEM_MSB+1))-15]; // IRQ  1
wire  [15:0] irq_vect_00 = pmem[(1<<(`PMEM_MSB+1))-16]; // IRQ  0

// Interrupt detection
wire              omsp0_nmi_detect  = dut.omsp_system_0_inst.openMSP430_0.frontend_0.nmi_pnd;
wire              omsp0_irq_detect  = dut.omsp_system_0_inst.openMSP430_0.frontend_0.irq_detect;

// Debug interface
wire              omsp0_dbg_en      = dut.omsp_system_0_inst.openMSP430_0.dbg_en;
wire              omsp0_dbg_clk     = dut.omsp_system_0_inst.openMSP430_0.clock_module_0.dbg_clk;
wire              omsp0_dbg_rst     = dut.omsp_system_0_inst.openMSP430_0.clock_module_0.dbg_rst;


// CPU internals
//======================

wire omsp0_mclk     = dut.omsp_system_0_inst.openMSP430_0.mclk;
wire omsp0_puc_rst  = dut.omsp_system_0_inst.openMSP430_0.puc_rst;
