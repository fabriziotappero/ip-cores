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
// *File Name: omsp_execution_unit.v
// 
// *Module Description:
//                       openMSP430 Execution unit
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 34 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-12-29 20:10:34 +0100 (Di, 29 Dez 2009) $
//----------------------------------------------------------------------------
`include "timescale.v"
`include "openMSP430_defines.v"

module  omsp_execution_unit (

// OUTPUTs
    cpuoff,                        // Turns off the CPU
    dbg_reg_din,                   // Debug unit CPU register data input
    gie,                           // General interrupt enable
    mab,                           // Memory address bus
    mb_en,                         // Memory bus enable
    mb_wr,                         // Memory bus write transfer
    mdb_out,                       // Memory data bus output
    oscoff,                        // Turns off LFXT1 clock input
    pc_sw,                         // Program counter software value
    pc_sw_wr,                      // Program counter software write
    scg1,                          // System clock generator 1. Turns off the SMCLK

// INPUTs
    dbg_halt_st,                   // Halt/Run status from CPU
    dbg_mem_dout,                  // Debug unit data output
    dbg_reg_wr,                    // Debug unit CPU register write
    e_state,                       // Execution state
    exec_done,                     // Execution completed
    inst_ad,                       // Decoded Inst: destination addressing mode
    inst_as,                       // Decoded Inst: source addressing mode
    inst_alu,                      // ALU control signals
    inst_bw,                       // Decoded Inst: byte width
    inst_dest,                     // Decoded Inst: destination (one hot)
    inst_dext,                     // Decoded Inst: destination extended instruction word
    inst_irq_rst,                  // Decoded Inst: reset interrupt
    inst_jmp,                      // Decoded Inst: Conditional jump
    inst_sext,                     // Decoded Inst: source extended instruction word
    inst_so,                       // Decoded Inst: Single-operand arithmetic
    inst_src,                      // Decoded Inst: source (one hot)
    inst_type,                     // Decoded Instruction type
    mclk,                          // Main system clock
    mdb_in,                        // Memory data bus input
    pc,                            // Program counter
    pc_nxt,                        // Next PC value (for CALL & IRQ)
    puc                            // Main system reset
);

// OUTPUTs
//=========
output 	            cpuoff;        // Turns off the CPU
output       [15:0] dbg_reg_din;   // Debug unit CPU register data input
output 	            gie;           // General interrupt enable
output       [15:0] mab;           // Memory address bus
output              mb_en;         // Memory bus enable
output        [1:0] mb_wr;         // Memory bus write transfer
output       [15:0] mdb_out;       // Memory data bus output
output 	            oscoff;        // Turns off LFXT1 clock input
output       [15:0] pc_sw;         // Program counter software value
output              pc_sw_wr;      // Program counter software write
output              scg1;          // System clock generator 1. Turns off the SMCLK

// INPUTs
//=========
input               dbg_halt_st;   // Halt/Run status from CPU
input        [15:0] dbg_mem_dout;  // Debug unit data output
input               dbg_reg_wr;    // Debug unit CPU register write
input         [3:0] e_state;       // Execution state
input               exec_done;     // Execution completed
input         [7:0] inst_ad;       // Decoded Inst: destination addressing mode
input         [7:0] inst_as;       // Decoded Inst: source addressing mode
input        [11:0] inst_alu;      // ALU control signals
input               inst_bw;       // Decoded Inst: byte width
input        [15:0] inst_dest;     // Decoded Inst: destination (one hot)
input        [15:0] inst_dext;     // Decoded Inst: destination extended instruction word
input               inst_irq_rst;  // Decoded Inst: reset interrupt
input         [7:0] inst_jmp;      // Decoded Inst: Conditional jump
input        [15:0] inst_sext;     // Decoded Inst: source extended instruction word
input         [7:0] inst_so;       // Decoded Inst: Single-operand arithmetic
input        [15:0] inst_src;      // Decoded Inst: source (one hot)
input         [2:0] inst_type;     // Decoded Instruction type
input               mclk;          // Main system clock
input        [15:0] mdb_in;        // Memory data bus input
input        [15:0] pc;            // Program counter
input        [15:0] pc_nxt;        // Next PC value (for CALL & IRQ)
input               puc;           // Main system reset


//=============================================================================
// 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
//=============================================================================

wire         [15:0] alu_out;
wire         [15:0] alu_out_add;
wire          [3:0] alu_stat;
wire          [3:0] alu_stat_wr;
wire         [15:0] op_dst;
wire         [15:0] op_src;
wire         [15:0] reg_dest;
wire         [15:0] reg_src;
wire         [15:0] mdb_in_bw;
wire         [15:0] mdb_in_val;
wire          [3:0] status;


//=============================================================================
// 2)  REGISTER FILE
//=============================================================================

wire reg_dest_wr  = ((e_state==`E_EXEC) & (
                     (inst_type[`INST_TO] & inst_ad[`DIR] & ~inst_alu[`EXEC_NO_WR])  |
                     (inst_type[`INST_SO] & inst_as[`DIR] & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_so[`RETI])) |
                      inst_type[`INST_JMP])) | dbg_reg_wr;

wire reg_sp_wr    = (((e_state==`E_IRQ_1) | (e_state==`E_IRQ_3)) & ~inst_irq_rst) |
                     ((e_state==`E_DST_RD) & (inst_so[`PUSH] | inst_so[`CALL]));

wire reg_sr_wr    =  (e_state==`E_DST_RD) & inst_so[`RETI];

wire reg_sr_clr   =  (e_state==`E_IRQ_2);

wire reg_pc_call  = ((e_state==`E_EXEC)   & inst_so[`CALL]) | 
                    ((e_state==`E_DST_WR) & inst_so[`RETI]);

wire reg_incr     =  (exec_done          & inst_as[`INDIR_I]) |
                    ((e_state==`E_SRC_RD) & inst_so[`RETI])    |
                    ((e_state==`E_EXEC)   & inst_so[`RETI]);

assign dbg_reg_din = reg_dest;


omsp_register_file register_file_0 (

// OUTPUTs
    .cpuoff       (cpuoff),       // Turns off the CPU
    .gie          (gie),          // General interrupt enable
    .oscoff       (oscoff),       // Turns off LFXT1 clock input
    .pc_sw        (pc_sw),        // Program counter software value
    .pc_sw_wr     (pc_sw_wr),     // Program counter software write
    .reg_dest     (reg_dest),     // Selected register destination content
    .reg_src      (reg_src),      // Selected register source content
    .scg1         (scg1),         // System clock generator 1. Turns off the SMCLK
    .status       (status),       // R2 Status {V,N,Z,C}

// INPUTs
    .alu_stat     (alu_stat),     // ALU Status {V,N,Z,C}
    .alu_stat_wr  (alu_stat_wr),  // ALU Status write {V,N,Z,C}
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_dest    (inst_dest),    // Register destination selection
    .inst_src     (inst_src),     // Register source selection
    .mclk         (mclk),         // Main system clock
    .pc           (pc),           // Program counter
    .puc          (puc),          // Main system reset
    .reg_dest_val (alu_out),      // Selected register destination value
    .reg_dest_wr  (reg_dest_wr),  // Write selected register destination
    .reg_pc_call  (reg_pc_call),  // Trigger PC update for a CALL instruction
    .reg_sp_val   (alu_out_add),  // Stack Pointer next value
    .reg_sp_wr    (reg_sp_wr),    // Stack Pointer write
    .reg_sr_clr   (reg_sr_clr),   // Status register clear for interrupts
    .reg_sr_wr    (reg_sr_wr),    // Status Register update for RETI instruction
    .reg_incr     (reg_incr)      // Increment source register
);


//=============================================================================
// 3)  SOURCE OPERAND MUXING
//=============================================================================
// inst_as[`DIR]    : Register direct.   -> Source is in register
// inst_as[`IDX]    : Register indexed.  -> Source is in memory, address is register+offset
// inst_as[`INDIR]  : Register indirect.
// inst_as[`INDIR_I]: Register indirect autoincrement.
// inst_as[`SYMB]   : Symbolic (operand is in memory at address PC+x).
// inst_as[`IMM]    : Immediate (operand is next word in the instruction stream).
// inst_as[`ABS]    : Absolute (operand is in memory at address x).
// inst_as[`CONST]  : Constant.

wire src_reg_src_sel    =  (e_state==`E_IRQ_0)                    |
                           (e_state==`E_IRQ_2)                    |
                          ((e_state==`E_SRC_RD) & ~inst_as[`ABS]) |
                          ((e_state==`E_SRC_WR) & ~inst_as[`ABS]) |
                          ((e_state==`E_EXEC)   &  inst_as[`DIR] & ~inst_type[`INST_JMP]);

wire src_reg_dest_sel   =  (e_state==`E_IRQ_1)                    |
                           (e_state==`E_IRQ_3)                    |
                          ((e_state==`E_DST_RD) & (inst_so[`PUSH] | inst_so[`CALL]));

wire src_mdb_in_val_sel = ((e_state==`E_DST_RD) &  inst_so[`RETI])                     |
                          ((e_state==`E_EXEC)   & (inst_as[`INDIR] | inst_as[`INDIR_I] |
                                                   inst_as[`IDX]   | inst_as[`SYMB]    |
                                                   inst_as[`ABS]));

wire src_inst_dext_sel =  ((e_state==`E_DST_RD) & ~(inst_so[`PUSH] | inst_so[`CALL])) |
                          ((e_state==`E_DST_WR) & ~(inst_so[`PUSH] | inst_so[`CALL]   |
                                                    inst_so[`RETI]));

wire src_inst_sext_sel =  ((e_state==`E_EXEC)   &  (inst_type[`INST_JMP] | inst_as[`IMM] |
                                                    inst_as[`CONST]      | inst_so[`RETI]));


assign op_src = src_reg_src_sel     ?  reg_src    :
                src_reg_dest_sel    ?  reg_dest   :
                src_mdb_in_val_sel  ?  mdb_in_val :
                src_inst_dext_sel   ?  inst_dext  :
                src_inst_sext_sel   ?  inst_sext  : 16'h0000;


//=============================================================================
// 4)  DESTINATION OPERAND MUXING
//=============================================================================
// inst_ad[`DIR]    : Register direct.
// inst_ad[`IDX]    : Register indexed.
// inst_ad[`SYMB]   : Symbolic (operand is in memory at address PC+x).
// inst_ad[`ABS]    : Absolute (operand is in memory at address x).


wire dst_inst_sext_sel  = ((e_state==`E_SRC_RD) & (inst_as[`IDX] | inst_as[`SYMB] |
                                                   inst_as[`ABS]))                |
                          ((e_state==`E_SRC_WR) & (inst_as[`IDX] | inst_as[`SYMB] |
                                                   inst_as[`ABS]));

wire dst_mdb_in_bw_sel  = ((e_state==`E_DST_WR) &   inst_so[`RETI]) |
                          ((e_state==`E_EXEC)   & ~(inst_ad[`DIR] | inst_type[`INST_JMP] |
                                                    inst_type[`INST_SO]) & ~inst_so[`RETI]);

wire dst_fffe_sel       =  (e_state==`E_IRQ_0)  |
                           (e_state==`E_IRQ_1)  |
                           (e_state==`E_IRQ_3)  |
                          ((e_state==`E_DST_RD) & (inst_so[`PUSH] | inst_so[`CALL]) & ~inst_so[`RETI]);

wire dst_reg_dest_sel   = ((e_state==`E_DST_RD) & ~(inst_so[`PUSH] | inst_so[`CALL] | inst_ad[`ABS] | inst_so[`RETI])) |
                          ((e_state==`E_DST_WR) &  ~inst_ad[`ABS]) |
                          ((e_state==`E_EXEC)   &  (inst_ad[`DIR] | inst_type[`INST_JMP] |
                                                    inst_type[`INST_SO]) & ~inst_so[`RETI]);


assign op_dst = dbg_halt_st        ? dbg_mem_dout  :
                dst_inst_sext_sel  ? inst_sext     :
                dst_mdb_in_bw_sel  ? mdb_in_bw     :
                dst_reg_dest_sel   ? reg_dest      :
                dst_fffe_sel       ? 16'hfffe      : 16'h0000;


//=============================================================================
// 5)  ALU
//=============================================================================

wire exec_cycle = (e_state==`E_EXEC);

omsp_alu alu_0 (

// OUTPUTs
    .alu_out      (alu_out),      // ALU output value
    .alu_out_add  (alu_out_add),  // ALU adder output value
    .alu_stat     (alu_stat),     // ALU Status {V,N,Z,C}
    .alu_stat_wr  (alu_stat_wr),  // ALU Status write {V,N,Z,C}

// INPUTs
    .dbg_halt_st  (dbg_halt_st),  // Halt/Run status from CPU
    .exec_cycle   (exec_cycle),   // Instruction execution cycle
    .inst_alu     (inst_alu),     // ALU control signals
    .inst_bw      (inst_bw),      // Decoded Inst: byte width
    .inst_jmp     (inst_jmp),     // Decoded Inst: Conditional jump
    .inst_so      (inst_so),      // Single-operand arithmetic
    .op_dst       (op_dst),       // Destination operand
    .op_src       (op_src),       // Source operand
    .status       (status)        // R2 Status {V,N,Z,C}
);


//=============================================================================
// 6)  MEMORY INTERFACE
//=============================================================================

// Detect memory read/write access
assign      mb_en     = ((e_state==`E_IRQ_1)  & ~inst_irq_rst)      |
                        ((e_state==`E_IRQ_3)  & ~inst_irq_rst)      |
                        ((e_state==`E_SRC_RD) & ~inst_as[`IMM])     |
                         (e_state==`E_SRC_WR)                       |
                        ((e_state==`E_EXEC)   & inst_so[`RETI])     |
                         (e_state==`E_DST_RD)                       |
                         (e_state==`E_DST_WR);

wire  [1:0] mb_wr_msk =  inst_alu[`EXEC_NO_WR]  ? 2'b00 :
                        ~inst_bw                ? 2'b11 :
                         alu_out_add[0]         ? 2'b10 : 2'b01;
assign      mb_wr     = ({2{(e_state==`E_IRQ_1)}}  |
                         {2{(e_state==`E_IRQ_3)}}  |
                         {2{(e_state==`E_DST_WR)}} |
                         {2{(e_state==`E_SRC_WR)}}) & mb_wr_msk;

// Memory address bus
assign      mab       = alu_out_add[15:0];

// Memory data bus output
reg  [15:0] mdb_out_nxt;
always @(posedge mclk or posedge puc)
  if (puc)                                            mdb_out_nxt <= 16'h0000;
  else if (e_state==`E_DST_RD)                        mdb_out_nxt <= pc_nxt;
  else if ((e_state==`E_EXEC & ~inst_so[`CALL]) |
           (e_state==`E_IRQ_0) | (e_state==`E_IRQ_2)) mdb_out_nxt <= alu_out;

assign      mdb_out = inst_bw ? {2{mdb_out_nxt[7:0]}} : mdb_out_nxt;

// Format memory data bus input depending on BW
reg        mab_lsb;
always @(posedge mclk or posedge puc)
  if (puc)        mab_lsb <= 1'b0;
  else if (mb_en) mab_lsb <= alu_out_add[0];

assign mdb_in_bw  = ~inst_bw ? mdb_in :
                     mab_lsb ? {2{mdb_in[15:8]}} : mdb_in;

// Memory data bus input buffer (buffer after a source read)
reg         mdb_in_buf_en;
always @(posedge mclk or posedge puc)
  if (puc)  mdb_in_buf_en <= 1'b0;
  else      mdb_in_buf_en <= (e_state==`E_SRC_RD);

reg         mdb_in_buf_valid;
always @(posedge mclk or posedge puc)
  if (puc)                   mdb_in_buf_valid <= 1'b0;
  else if (e_state==`E_EXEC) mdb_in_buf_valid <= 1'b0;
  else if (mdb_in_buf_en)    mdb_in_buf_valid <= 1'b1;

reg  [15:0] mdb_in_buf;
always @(posedge mclk or posedge puc)
  if (puc)                mdb_in_buf <= 16'h0000;
  else if (mdb_in_buf_en) mdb_in_buf <= mdb_in_bw;

assign mdb_in_val = mdb_in_buf_valid ? mdb_in_buf : mdb_in_bw;


endmodule // omsp_execution_unit

`include "openMSP430_undefines.v"
