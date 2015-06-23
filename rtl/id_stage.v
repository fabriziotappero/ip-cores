//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Decode module                        //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Handles basic decoding of instruction type and register     //
//  sources and destinations for Dispatch stages.               //
//  We could do full instruction decoding in this stage, but    //
//  to save on pipeline flops we will only decode what is needed//
//  for dispatch.  We can use the issue stage to do necessary   // 
//  decoding for each functional unit.                          //
//                                                              //
//  Author(s):                                                  //
//      - Joshua Smith, smjoshua@umich.edu                      //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2012 Authors and OPENCORES.ORG                 //
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
`include "ooops_defs.v"

module id_stage (
  input wire                      clk,
  input wire                      rst,

  // Flush/stall interface
  input wire                      rob_pipe_flush, 
  input wire                      ds_stall,

  // Interface to IF stage
  input wire                      if_id_valid,
  input wire  [`INSTR_SZ-1:0]     if_id_instr,
  input wire  [`ADDR_SZ-1:0]      if_id_fpc,
  input wire  [`BP_SZ-1:0]        if_id_bprd_info,

  // Interface to Dispatch stage
  output wire                     id_ds1_valid,
  output wire [`ADDR_SZ-1:0]      id_ds1_fpc,
  output wire                     id_ds1_in_dly_slot,
  output wire [`DEC_BUS_SZ-1:0]   id_ds1_dec_bus,
  output wire [`BP_SZ-1:0]        id_ds1_bprd_info
  );

  // Internal wires
  wire                    id_type_br;
  wire                    id_type_ldst;
  wire                    id_type_multdiv;
  wire                    id_type_alu;
  wire [`DEC_BUS_SZ-1:0]  id_dec_bus;
  wire                    id_rs_need;
  wire                    id_rt_need;
  wire                    id_rd_write;
  wire [`REG_IDX_SZ-1:0]  id_rs_idx;
  wire [`REG_IDX_SZ-1:0]  id_rt_idx;
  wire [`REG_IDX_SZ-1:0]  id_rd_idx;

  // Handle stalling indications
  wire id_stall     = ds_stall;
  
  // Determine basic instruction type
  wire id_instr_special   = ~(|if_id_instr[31:26]);

  // MULT/DIV
  wire id_mult           = (id_instr_special & if_id_instr[5:1]==5'b01100);
  wire id_div            = (id_instr_special & if_id_instr[5:1]==5'b01101);
  assign id_type_multdiv = id_mult | id_div;

  // LDST
  wire id_mem_ld      = (if_id_instr[31:29]==3'b100) && (~if_id_instr[27] | (if_id_instr[28:26]==3'b011));
  wire id_mem_st      = (if_id_instr[31:28]==4'b1010) && (if_id_instr[27:26]!=2'b10);
  assign id_type_ldst = id_mem_ld || id_mem_st;

  // Branch
  wire id_br_beq      = (if_id_instr[31:27]==5'b00010);
  wire id_br_bge      = (if_id_instr[31:26]==6'b000001) && (if_id_instr[20:17]==4'b0000);
  wire id_br_bgt      = (if_id_instr[31:27]==5'b00011) && (if_id_instr[20:16]==5'b00000);
  wire id_br_neg      = (id_br_beq && if_id_instr[26]) ||   // BNE
                        (id_br_bge && if_id_instr[17]) ||   // BLTZ
                        (id_br_bgt && !if_id_instr[26]);    // BLEZ
  wire id_br_j        = (if_id_instr[31:27]==5'b00001);
  wire id_br_jr       = id_instr_special && (if_id_instr[5:1]==5'b00100);
  wire id_br_link     = (id_br_bge && if_id_instr[20]) ||   // BGEZAL, BLTZAL
                        (id_br_j   && if_id_instr[16]);     // JAL
  wire id_br_link_reg = (id_br_jr  && if_id_instr[0]);      // JALR
  wire id_except      = id_instr_special && (if_id_instr[5:1]==5'b00110);
  //wire id_break       = id_except && if_id_instr[0];
  wire id_syscall     = id_except && !if_id_instr[0];
  assign id_type_br   = (id_br_beq | id_br_bge | id_br_bgt | id_br_j | id_br_jr | id_except);

  // ALU
  wire id_alu_shift     = id_instr_special && (if_id_instr[5:3]==3'b000);
  wire id_alu_shift_imm = id_alu_shift & !if_id_instr[2];
  wire id_alu_cmp       = (id_instr_special && if_id_instr[5:1]==5'b10101) || // SLT/SLTU
                          (if_id_instr[31:27]==5'b00101);                     // SLTI/SLTIU
  wire id_alu_log_reg   = id_instr_special && (if_id_instr[5:2]==4'b1001);
  wire id_alu_log_imm   = (if_id_instr[31:28]==4'b0011) && !(&if_id_instr[27:26]);
  wire id_hilo_mov      = id_instr_special & (if_id_instr[5:2]==4'b0100);
  wire id_mfhi          = id_hilo_mov & (if_id_instr[1:0]==2'b00);
  wire id_mflo          = id_hilo_mov & (if_id_instr[1:0]==2'b10);
  wire id_mthi          = id_hilo_mov & (if_id_instr[1:0]==2'b01);
  wire id_mtlo          = id_hilo_mov & (if_id_instr[1:0]==2'b11);
  wire id_alu_add_sub   = (id_instr_special && (if_id_instr[5:2]==4'b1000)) ||    // ADD/SUB Reg
                          (if_id_instr[31:27]==5'b00100);                         // ADDI
  wire id_alu_lui       = (if_id_instr[31:26]==6'b001111);

  // Coprocessor ops included
  wire id_cp_op   = (if_id_instr[31:26]==6'b010000) && !(|if_id_instr[25:24]) && !(|if_id_instr[22:21]);
  wire id_cp_to   = id_cp_op && if_id_instr[23];
  //wire id_cp_num  = if_id_instr[27:26];

  assign id_type_alu = id_alu_shift | id_alu_cmp | id_alu_log_reg | id_alu_log_imm | 
                       id_type_br | id_hilo_mov | id_alu_add_sub | id_alu_lui | id_cp_op;



  // Determine register indices
  // Figure out whether operands require register values.
  // This is so we know whether to stall for forwarded data for an operand
  // For ALU operations, all but LUI need reg_s.  Immediate instructions don't need reg_t
  assign id_rs_need = (id_type_alu & !id_alu_lui & !id_br_j) |
                      (id_alu_shift & !id_alu_shift_imm) | 
                      (id_div | id_mult) |
                      (id_type_ldst);
  assign id_rt_need = (id_type_alu & !id_alu_imm) | id_type_multdiv | id_br_beq | id_cp_to | id_mem_st;
  assign id_rd_wr   = !(id_mem_st | (id_type_br & !id_br_link) | id_cp_to | id_syscall);

  // Handle moves to/from HI and LO
  assign id_rs_idx = id_mfhi ? `REG_IDX_SZ'd32 :
                     id_mflo ? `REG_IDX_SZ'd33 : id_reg_s_idx_pre;
  assign id_rt_idx = id_reg_t_idx_pre;
  assign id_rd_idx = id_mthi ? `REG_IDX_SZ'd32 :
                     id_mtlo ? `REG_IDX_SZ'd33 : id_reg_d_idx_pre;

  // Determine if instructions are in a delay slot
  // This is needed by the ROB in case a branch is mispredicted so we know not to flush the delay instruction.
  wire id_in_dly_slot_set = !id_stall & (if_id_valid & id_type_br);
  wire id_in_dly_slot_rst = !id_stall & (if_id_valid & id_in_dly_slot);
  wire id_in_dly_slot_in  = (id_in_dly_slot_set | id_in_dly_slot) & !id_in_dly_slot_rst;
  MDFFR #(1) id_in_dly_slot_ff (clk, rst, 1'b0, id_in_dly_slot_in, id_in_dly_slot); 

  wire id_in_dly_slot = if_id_valid & id_in_dly_slot;

  // Put together decode bus
  assign id_dec_bus[`DEC_REG_D_IDX]     = id_rd_idx;
  assign id_dec_bus[`DEC_REG_T_IDX]     = id_rt_idx;
  assign id_dec_bus[`DEC_REG_S_IDX]     = id_rs_idx;
  assign id_dec_bus[`DEC_REG_D_WR]      = id_rd_wr;
  assign id_dec_bus[`DEC_REG_T_NEED]    = id_rt_need;
  assign id_dec_bus[`DEC_REG_S_NEED]    = id_rs_need;
  assign id_dec_bus[`DEC_TYPE_CP]       = id_cp_op;
  assign id_dec_bus[`DEC_TYPE_BR]       = id_type_br;
  assign id_dec_bus[`DEC_TYPE_LDST]     = id_type_ldst;
  assign id_dec_bus[`DEC_TYPE_MULTDIV]  = id_type_multdiv;
  assign id_dec_bus[`DEC_TYPE_ALU]      = id_type_alu;

  wire id_valid = if_id_valid & !rob_pipe_flush;

  // Flop outputs to DS stage
  MDFFLR #(1)           id_ds1_valid_ff       (clk, rst, !id_stall, 1'b0, id_valid, id_ds1_valid);
  MDFFL  #(`ADDR_SZ)    id_ds1_fpc_ff         (clk, if_id_valid, if_id_fpc, id_ds1_fpc);
  MDFFLR #(1)           id_ds1_in_dly_slot_ff (clk, rst, if_id_valid, 1'b0, id_in_dly_slot, id_ds1_in_dly_slot);
  MDFFL  #(`DEC_BUS_SZ) id_ds1_dec_bus_ff     (clk, if_id_valid, id_dec_bus, id_ds1_dec_bus);
  MDFFL  #(`BP_SZ)      id_ds1_bprd_info_ff   (clk, if_id_valid, if_id_bprd_info, id_ds1_bprd_info);
  
endmodule
