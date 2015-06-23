//////////////////////////////////////////////////////////////////
//                                                              //
//  RAM-based register Bank for Amber Core                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains 37 32-bit registers, 16 of which are visible       //
//  ina any one operating mode.                                 //
//  The block is designed using syncronous RAM primitive,       //
//  and fits well into an FPGA design                           //
//                                                              //
//  Author(s):                                                  //
//      - Dmitry Tarnyagin, dmitry.tarnyagin@lockless.no        //
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

module a23_ram_register_bank (

input                       i_clk,
input                       i_fetch_stall,

input       [1:0]           i_mode_exec,            // registered cpu mode from execution stage
input       [1:0]           i_mode_exec_nxt,        // 1 periods delayed from i_mode_idec
                                                    // Used for register reads
input       [1:0]           i_mode_rds_exec,        // Use raw version in this implementation,
                                                    // includes i_user_mode_regs_store
input                       i_user_mode_regs_load,
input       [3:0]           i_rm_sel,
input       [3:0]           i_rds_sel,
input       [3:0]           i_rn_sel,

input                       i_pc_wen,
input       [3:0]           i_reg_bank_wsel,

input       [23:0]          i_pc,                   // program counter [25:2]
input       [31:0]          i_reg,

input       [3:0]           i_status_bits_flags,
input                       i_status_bits_irq_mask,
input                       i_status_bits_firq_mask,

output      [31:0]          o_rm,
output      [31:0]          o_rs,
output      [31:0]          o_rd,
output      [31:0]          o_rn,
output      [31:0]          o_pc

);

`include "a23_localparams.vh"
`include "a23_functions.vh"

wire  [1:0]  mode_idec;
wire  [1:0]  mode_exec;
wire  [1:0]  mode_rds;

wire  [4:0]  rm_addr;
wire  [4:0]  rds_addr;
wire  [4:0]  rn_addr;
wire  [4:0]  wr_addr;

// Register pool in embedded ram memory
reg   [31:0] reg_ram_n[31:0];
reg   [31:0] reg_ram_m[31:0];
reg   [31:0] reg_ram_ds[31:0];

wire  [31:0] rds_out;
wire  [31:0] rm_out;
wire  [31:0] rn_out;

// Synchronous ram input buffering
reg   [4:0]  rm_addr_reg;
reg   [4:0]  rds_addr_reg;
reg   [4:0]  rn_addr_reg;

// User Mode Registers
reg   [23:0] r15 = 24'hc0_ffee;

wire  [31:0] r15_out_rm;
wire  [31:0] r15_out_rm_nxt;
wire  [31:0] r15_out_rn;

// r15 selectors
reg          rn_15 = 1'b0;   
reg          rm_15 = 1'b0;
reg          rds_15 = 1'b0;

// Write Enables from execute stage
assign mode_idec = i_mode_exec_nxt & ~{2{i_user_mode_regs_load}};
assign wr_addr = reg_addr(mode_idec, i_reg_bank_wsel);

// Read Enables from stage 1 (fetch)
assign mode_exec = i_mode_exec_nxt;
assign rm_addr = reg_addr(mode_exec, i_rm_sel);
assign rn_addr = reg_addr(mode_exec, i_rn_sel);

// Rds
assign mode_rds = i_mode_rds_exec;
assign rds_addr = reg_addr(mode_rds, i_rds_sel);

    
// ========================================================
// r15 Register Read based on Mode
// ========================================================
assign r15_out_rm     = { i_status_bits_flags, 
                          i_status_bits_irq_mask, 
                          i_status_bits_firq_mask, 
                          r15, 
                          i_mode_exec};

assign r15_out_rm_nxt = { i_status_bits_flags, 
                          i_status_bits_irq_mask, 
                          i_status_bits_firq_mask, 
                          i_pc, 
                          i_mode_exec};
                      
assign r15_out_rn     = {6'd0, r15, 2'd0};


// ========================================================
// Program Counter out
// ========================================================
assign o_pc = r15_out_rn;

// ========================================================
// Rm Selector
// ========================================================
assign rm_out = reg_ram_m[rm_addr_reg];

assign o_rm =	rm_15 ?				r15_out_rm :
						rm_out;

// ========================================================
// Rds Selector
// ========================================================
assign rds_out = reg_ram_ds[rds_addr_reg];

assign o_rs =	rds_15  ?			r15_out_rn :
						rds_out;

// ========================================================
// Rd Selector
// ========================================================
assign o_rd =	rds_15  ? 			r15_out_rm_nxt :
						rds_out;

// ========================================================
// Rn Selector
// ========================================================
assign rn_out = reg_ram_n[rn_addr_reg];

assign o_rn =	rn_15  ?			r15_out_rn :
						rn_out;
// ========================================================
// Register Update
// ========================================================
always @ ( posedge i_clk )
    if (!i_fetch_stall)
        begin

        // Register write.
        // Actually the code is synthesed as a syncronous ram
        // with an additional  pass-through multiplexor for
        // read-when-write handling.
        reg_ram_n[wr_addr]      <= i_reg;
        reg_ram_m[wr_addr]      <= i_reg;
        reg_ram_ds[wr_addr]     <= i_reg;
        r15                     <= i_pc_wen ? i_pc : r15;

        // The latching is actually implemented in a hard block.
        rn_addr_reg             <= rn_addr;
        rm_addr_reg             <= rm_addr;
        rds_addr_reg            <= rds_addr;

        rn_15                   <= i_rn_sel == 4'hF;
        rm_15                   <= i_rm_sel == 4'hF;
        rds_15                  <= i_rds_sel == 4'hF;
        end
    
// ========================================================
// Register mapping:
// ========================================================
// 0xxxx : r0 - r14
// 10xxx : r8_firq - r14_firq
// 110xx : r13_irq - r14_irq
// 111xx : r13_svc - r14_svc

function [4:0] reg_addr;
input [1:0] mode;
input [3:0] sel;
begin
	casez ({mode, sel}) // synthesis full_case parallel_case
		6'b??0???:	reg_addr = {1'b0, sel};		// r0 - r7
		6'b1?1100:	reg_addr = {1'b0, sel};		// irq and svc r12
		6'b001???:	reg_addr = {1'b0, sel};		// user r8 - r14
		6'b011???:	reg_addr = {2'b10, sel[2:0]};	// fiq r8-r14
		6'b1?10??:	reg_addr = {1'b0, sel};		// irq and svc r8-r11
		6'b101101:	reg_addr = {3'b110, sel[1:0]};	// irq r13
		6'b101110:	reg_addr = {3'b110, sel[1:0]};	// irq r14
		6'b101111:	reg_addr = {3'b110, sel[1:0]};	// irq r15, just to make the case full
		6'b111101:	reg_addr = {3'b111, sel[1:0]};	// svc r13
		6'b111110:	reg_addr = {3'b111, sel[1:0]};	// svc r14
		6'b111111:	reg_addr = {3'b111, sel[1:0]};	// svc r15, just to make the case full
	endcase
end
endfunction

// synthesis translate_off
// To be used as probes...
wire [31:0] r0;
wire [31:0] r1;
wire [31:0] r2;
wire [31:0] r3;
wire [31:0] r4;
wire [31:0] r5;
wire [31:0] r6;
wire [31:0] r7;
wire [31:0] r8;
wire [31:0] r9;
wire [31:0] r10;
wire [31:0] r11;
wire [31:0] r12;
wire [31:0] r13;
wire [31:0] r14;
wire [31:0] r13_svc;
wire [31:0] r14_svc;
wire [31:0] r13_irq;
wire [31:0] r14_irq;
wire [31:0] r8_firq;
wire [31:0] r9_firq;
wire [31:0] r10_firq;
wire [31:0] r11_firq;
wire [31:0] r12_firq;
wire [31:0] r13_firq;
wire [31:0] r14_firq;
wire [31:0] r0_out;
wire [31:0] r1_out;
wire [31:0] r2_out;
wire [31:0] r3_out;
wire [31:0] r4_out;
wire [31:0] r5_out;
wire [31:0] r6_out;
wire [31:0] r7_out;
wire [31:0] r8_out;
wire [31:0] r9_out;
wire [31:0] r10_out;
wire [31:0] r11_out;
wire [31:0] r12_out;
wire [31:0] r13_out;
wire [31:0] r14_out;

assign r0  = reg_ram_m[ 0];
assign r1  = reg_ram_m[ 1];
assign r2  = reg_ram_m[ 2];
assign r3  = reg_ram_m[ 3];
assign r4  = reg_ram_m[ 4];
assign r5  = reg_ram_m[ 5];
assign r6  = reg_ram_m[ 6];
assign r7  = reg_ram_m[ 7];
assign r8  = reg_ram_m[ 8];
assign r9  = reg_ram_m[ 9];
assign r10 = reg_ram_m[10];
assign r11 = reg_ram_m[11];
assign r12 = reg_ram_m[12];
assign r13 = reg_ram_m[13];
assign r14 = reg_ram_m[14];
assign r13_svc  = reg_ram_m[29];
assign r14_svc  = reg_ram_m[30];
assign r13_irq  = reg_ram_m[25];
assign r14_irq  = reg_ram_m[26];
assign r8_firq  = reg_ram_m[16];
assign r9_firq  = reg_ram_m[17];
assign r10_firq = reg_ram_m[18];
assign r11_firq = reg_ram_m[19];
assign r12_firq = reg_ram_m[20];
assign r13_firq = reg_ram_m[21];
assign r14_firq = reg_ram_m[22];
assign r0_out  = reg_ram_m[reg_addr(mode_exec,  0)];
assign r1_out  = reg_ram_m[reg_addr(mode_exec,  1)];
assign r2_out  = reg_ram_m[reg_addr(mode_exec,  2)];
assign r3_out  = reg_ram_m[reg_addr(mode_exec,  3)];
assign r4_out  = reg_ram_m[reg_addr(mode_exec,  4)];
assign r5_out  = reg_ram_m[reg_addr(mode_exec,  5)];
assign r6_out  = reg_ram_m[reg_addr(mode_exec,  6)];
assign r7_out  = reg_ram_m[reg_addr(mode_exec,  7)];
assign r8_out  = reg_ram_m[reg_addr(mode_exec,  8)];
assign r9_out  = reg_ram_m[reg_addr(mode_exec,  9)];
assign r10_out = reg_ram_m[reg_addr(mode_exec, 10)];
assign r11_out = reg_ram_m[reg_addr(mode_exec, 11)];
assign r12_out = reg_ram_m[reg_addr(mode_exec, 12)];
assign r13_out = reg_ram_m[reg_addr(mode_exec, 13)];
assign r14_out = reg_ram_m[reg_addr(mode_exec, 14)];
// synthesis translate_on

endmodule


