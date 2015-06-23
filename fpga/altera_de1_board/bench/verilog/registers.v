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
// $Rev: 16 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-04 23:03:47 +0200 (Tue, 04 Aug 2009) $
//----------------------------------------------------------------------------

// CPU registers
//======================

wire       [15:0] r0    = dut.openMSP430_0.execution_unit_0.register_file_0.r0;
wire       [15:0] r1    = dut.openMSP430_0.execution_unit_0.register_file_0.r1;
wire       [15:0] r2    = dut.openMSP430_0.execution_unit_0.register_file_0.r2;
wire       [15:0] r3    = dut.openMSP430_0.execution_unit_0.register_file_0.r3;
wire       [15:0] r4    = dut.openMSP430_0.execution_unit_0.register_file_0.r4;
wire       [15:0] r5    = dut.openMSP430_0.execution_unit_0.register_file_0.r5;
wire       [15:0] r6    = dut.openMSP430_0.execution_unit_0.register_file_0.r6;
wire       [15:0] r7    = dut.openMSP430_0.execution_unit_0.register_file_0.r7;
wire       [15:0] r8    = dut.openMSP430_0.execution_unit_0.register_file_0.r8;
wire       [15:0] r9    = dut.openMSP430_0.execution_unit_0.register_file_0.r9;
wire       [15:0] r10   = dut.openMSP430_0.execution_unit_0.register_file_0.r10;
wire       [15:0] r11   = dut.openMSP430_0.execution_unit_0.register_file_0.r11;
wire       [15:0] r12   = dut.openMSP430_0.execution_unit_0.register_file_0.r12;
wire       [15:0] r13   = dut.openMSP430_0.execution_unit_0.register_file_0.r13;
wire       [15:0] r14   = dut.openMSP430_0.execution_unit_0.register_file_0.r14;
wire       [15:0] r15   = dut.openMSP430_0.execution_unit_0.register_file_0.r15;


// RAM cells
//======================

//wire       [15:0] mem200 = {dut.ram_8x512_hi_0.inst.mem[0],  dut.ram_8x512_lo_0.inst.mem[0]};
//wire       [15:0] mem202 = {dut.ram_8x512_hi_0.inst.mem[1],  dut.ram_8x512_lo_0.inst.mem[1]};
//wire       [15:0] mem204 = {dut.ram_8x512_hi_0.inst.mem[2],  dut.ram_8x512_lo_0.inst.mem[2]};
//wire       [15:0] mem206 = {dut.ram_8x512_hi_0.inst.mem[3],  dut.ram_8x512_lo_0.inst.mem[3]};
//wire       [15:0] mem208 = {dut.ram_8x512_hi_0.inst.mem[4],  dut.ram_8x512_lo_0.inst.mem[4]};
//wire       [15:0] mem20A = {dut.ram_8x512_hi_0.inst.mem[5],  dut.ram_8x512_lo_0.inst.mem[5]};
//wire       [15:0] mem20C = {dut.ram_8x512_hi_0.inst.mem[6],  dut.ram_8x512_lo_0.inst.mem[6]};
//wire       [15:0] mem20E = {dut.ram_8x512_hi_0.inst.mem[7],  dut.ram_8x512_lo_0.inst.mem[7]};
//wire       [15:0] mem210 = {dut.ram_8x512_hi_0.inst.mem[8],  dut.ram_8x512_lo_0.inst.mem[8]};
//wire       [15:0] mem212 = {dut.ram_8x512_hi_0.inst.mem[9],  dut.ram_8x512_lo_0.inst.mem[9]};
//wire       [15:0] mem214 = {dut.ram_8x512_hi_0.inst.mem[10], dut.ram_8x512_lo_0.inst.mem[10]};
//wire       [15:0] mem216 = {dut.ram_8x512_hi_0.inst.mem[11], dut.ram_8x512_lo_0.inst.mem[11]};
//wire       [15:0] mem218 = {dut.ram_8x512_hi_0.inst.mem[12], dut.ram_8x512_lo_0.inst.mem[12]};
//wire       [15:0] mem21A = {dut.ram_8x512_hi_0.inst.mem[13], dut.ram_8x512_lo_0.inst.mem[13]};
//wire       [15:0] mem21C = {dut.ram_8x512_hi_0.inst.mem[14], dut.ram_8x512_lo_0.inst.mem[14]};
//wire       [15:0] mem21E = {dut.ram_8x512_hi_0.inst.mem[15], dut.ram_8x512_lo_0.inst.mem[15]};
//wire       [15:0] mem220 = {dut.ram_8x512_hi_0.inst.mem[16], dut.ram_8x512_lo_0.inst.mem[16]};
//wire       [15:0] mem222 = {dut.ram_8x512_hi_0.inst.mem[17], dut.ram_8x512_lo_0.inst.mem[17]};
//wire       [15:0] mem224 = {dut.ram_8x512_hi_0.inst.mem[18], dut.ram_8x512_lo_0.inst.mem[18]};
//wire       [15:0] mem226 = {dut.ram_8x512_hi_0.inst.mem[19], dut.ram_8x512_lo_0.inst.mem[19]};
//wire       [15:0] mem228 = {dut.ram_8x512_hi_0.inst.mem[20], dut.ram_8x512_lo_0.inst.mem[20]};
//wire       [15:0] mem22A = {dut.ram_8x512_hi_0.inst.mem[21], dut.ram_8x512_lo_0.inst.mem[21]};
//wire       [15:0] mem22C = {dut.ram_8x512_hi_0.inst.mem[22], dut.ram_8x512_lo_0.inst.mem[22]};
//wire       [15:0] mem22E = {dut.ram_8x512_hi_0.inst.mem[23], dut.ram_8x512_lo_0.inst.mem[23]};
//wire       [15:0] mem230 = {dut.ram_8x512_hi_0.inst.mem[24], dut.ram_8x512_lo_0.inst.mem[24]};
//wire       [15:0] mem232 = {dut.ram_8x512_hi_0.inst.mem[25], dut.ram_8x512_lo_0.inst.mem[25]};
//wire       [15:0] mem234 = {dut.ram_8x512_hi_0.inst.mem[26], dut.ram_8x512_lo_0.inst.mem[26]};
//wire       [15:0] mem236 = {dut.ram_8x512_hi_0.inst.mem[27], dut.ram_8x512_lo_0.inst.mem[27]};
//wire       [15:0] mem238 = {dut.ram_8x512_hi_0.inst.mem[28], dut.ram_8x512_lo_0.inst.mem[28]};
//wire       [15:0] mem23A = {dut.ram_8x512_hi_0.inst.mem[29], dut.ram_8x512_lo_0.inst.mem[29]};
//wire       [15:0] mem23C = {dut.ram_8x512_hi_0.inst.mem[30], dut.ram_8x512_lo_0.inst.mem[30]};
//wire       [15:0] mem23E = {dut.ram_8x512_hi_0.inst.mem[31], dut.ram_8x512_lo_0.inst.mem[31]};
//wire       [15:0] mem240 = {dut.ram_8x512_hi_0.inst.mem[32], dut.ram_8x512_lo_0.inst.mem[32]};
//wire       [15:0] mem242 = {dut.ram_8x512_hi_0.inst.mem[33], dut.ram_8x512_lo_0.inst.mem[33]};
//wire       [15:0] mem244 = {dut.ram_8x512_hi_0.inst.mem[34], dut.ram_8x512_lo_0.inst.mem[34]};
//wire       [15:0] mem246 = {dut.ram_8x512_hi_0.inst.mem[35], dut.ram_8x512_lo_0.inst.mem[35]};
//wire       [15:0] mem248 = {dut.ram_8x512_hi_0.inst.mem[36], dut.ram_8x512_lo_0.inst.mem[36]};
//wire       [15:0] mem24A = {dut.ram_8x512_hi_0.inst.mem[37], dut.ram_8x512_lo_0.inst.mem[37]};
//wire       [15:0] mem24C = {dut.ram_8x512_hi_0.inst.mem[38], dut.ram_8x512_lo_0.inst.mem[38]};
//wire       [15:0] mem24E = {dut.ram_8x512_hi_0.inst.mem[39], dut.ram_8x512_lo_0.inst.mem[39]};
//wire       [15:0] mem250 = {dut.ram_8x512_hi_0.inst.mem[40], dut.ram_8x512_lo_0.inst.mem[40]};
//wire       [15:0] mem252 = {dut.ram_8x512_hi_0.inst.mem[41], dut.ram_8x512_lo_0.inst.mem[41]};
//wire       [15:0] mem254 = {dut.ram_8x512_hi_0.inst.mem[42], dut.ram_8x512_lo_0.inst.mem[42]};
//wire       [15:0] mem256 = {dut.ram_8x512_hi_0.inst.mem[43], dut.ram_8x512_lo_0.inst.mem[43]};
//wire       [15:0] mem258 = {dut.ram_8x512_hi_0.inst.mem[44], dut.ram_8x512_lo_0.inst.mem[44]};
//wire       [15:0] mem25A = {dut.ram_8x512_hi_0.inst.mem[45], dut.ram_8x512_lo_0.inst.mem[45]};
//wire       [15:0] mem25C = {dut.ram_8x512_hi_0.inst.mem[46], dut.ram_8x512_lo_0.inst.mem[46]};
//wire       [15:0] mem25E = {dut.ram_8x512_hi_0.inst.mem[47], dut.ram_8x512_lo_0.inst.mem[47]};
//wire       [15:0] mem260 = {dut.ram_8x512_hi_0.inst.mem[48], dut.ram_8x512_lo_0.inst.mem[48]};
//wire       [15:0] mem262 = {dut.ram_8x512_hi_0.inst.mem[49], dut.ram_8x512_lo_0.inst.mem[49]};
//wire       [15:0] mem264 = {dut.ram_8x512_hi_0.inst.mem[50], dut.ram_8x512_lo_0.inst.mem[50]};
//wire       [15:0] mem266 = {dut.ram_8x512_hi_0.inst.mem[51], dut.ram_8x512_lo_0.inst.mem[51]};
//wire       [15:0] mem268 = {dut.ram_8x512_hi_0.inst.mem[52], dut.ram_8x512_lo_0.inst.mem[52]};
//wire       [15:0] mem26A = {dut.ram_8x512_hi_0.inst.mem[53], dut.ram_8x512_lo_0.inst.mem[53]};
//wire       [15:0] mem26C = {dut.ram_8x512_hi_0.inst.mem[54], dut.ram_8x512_lo_0.inst.mem[54]};
//wire       [15:0] mem26E = {dut.ram_8x512_hi_0.inst.mem[55], dut.ram_8x512_lo_0.inst.mem[55]};
//wire       [15:0] mem270 = {dut.ram_8x512_hi_0.inst.mem[56], dut.ram_8x512_lo_0.inst.mem[56]};
//wire       [15:0] mem272 = {dut.ram_8x512_hi_0.inst.mem[57], dut.ram_8x512_lo_0.inst.mem[57]};
//wire       [15:0] mem274 = {dut.ram_8x512_hi_0.inst.mem[58], dut.ram_8x512_lo_0.inst.mem[58]};
//wire       [15:0] mem276 = {dut.ram_8x512_hi_0.inst.mem[59], dut.ram_8x512_lo_0.inst.mem[59]};
//wire       [15:0] mem278 = {dut.ram_8x512_hi_0.inst.mem[60], dut.ram_8x512_lo_0.inst.mem[60]};
//wire       [15:0] mem27A = {dut.ram_8x512_hi_0.inst.mem[61], dut.ram_8x512_lo_0.inst.mem[61]};
//wire       [15:0] mem27C = {dut.ram_8x512_hi_0.inst.mem[62], dut.ram_8x512_lo_0.inst.mem[62]};
//wire       [15:0] mem27E = {dut.ram_8x512_hi_0.inst.mem[63], dut.ram_8x512_lo_0.inst.mem[63]};
//wire       [15:0] mem280 = {dut.ram_8x512_hi_0.inst.mem[64], dut.ram_8x512_lo_0.inst.mem[64]};


// Program Memory cells
//======================
reg   [15:0] pmem [0:2047];

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
wire              nmi_detect  = dut.openMSP430_0.frontend_0.nmi_pnd;
wire              irq_detect  = dut.openMSP430_0.frontend_0.irq_detect;

// Debug interface
wire              dbg_en      = dut.openMSP430_0.dbg_en;
wire              dbg_clk     = dut.openMSP430_0.clock_module_0.dbg_clk;
wire              dbg_rst     = dut.openMSP430_0.clock_module_0.dbg_rst;


// CPU internals
//======================

wire mclk     = dut.openMSP430_0.mclk;
wire puc_rst  = dut.openMSP430_0.puc_rst;
