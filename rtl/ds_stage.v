//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Dispatch module                      //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Instruction dispatch block handles instruction register     //
//  renaming, and dependency checking, and dispatching          //
//  instructions to the ROB and appropriate Reservation Station.//
//  Due to the structure of the map table, Dispatch is pipelined//
//  into 2 stages: DS1 and DS2.                                 //
//                                                              //
//  DS1 stage will be for determining which checkpoint has the  //
//  latest valid mapping for a register, and for allocating the //
//  destination physical register.                              //
//                                                              //
//  DS2 stage will be for reading the map tables and dispatching//
//  to the Reservation Stations.                                //
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

module ds_stage (
  input wire                        clk,
  input wire                        rst,
  
  // Flush/stall interface
  input wire                        rob_pipe_flush, 
  output wire                       ds_stall,

  // Interface to ID stage
  input wire                        id_ds1_valid,
  input wire  [`ADDR_SZ-1:0]        id_ds1_fpc,
  input wire                        id_ds1_in_dly_slot,
  input wire  [`DEC_BUS_SZ-1:0]     id_ds1_dec_bus,
  input wire  [`BP_SZ-1:0]          id_ds1_bprd_info,

  // Interface to CDB (for tag monitoring)
  input wire                        ex_cdb_valid,
  input wire  [`TAG_SZ-1:0]         ex_cdb_tag,
  input wire  [`REG_IDX_SZ-1:0]     ex_cdb_dest_idx,

  // Interface to ROB
  input wire                        rob_ds_full,
  input wire  [`ROB_PTR_SZ-1:0]     rob_ds_tail_ptr,
  input wire  [`CHKPT_PTR_SZ-1:0]   rob_ds_chkpt_ptr,
  input wire  [`FL_PTR_SZ-1:0]      rob_ds_fl_head_ptr,
  input wire                        rob_ds_ret_valid,
  input wire                        rob_ds_ret_dest_write,
  input wire                        rob_ds_ret_chkpt_free,
  input wire  [`REG_IDX_SZ-1:0]     rob_ds_ret_idx,
  input wire  [`TAG_SZ-1:0]         rob_ds_ret_tag,
  input wire  [`TAG_SZ-1:0]         rob_ds_ret_tag_old,
  output wire                       ds2_rob_valid,
  output wire [`ADDR_SZ-1:0]        ds2_rob_fpc,
  output wire                       ds2_rob_in_dly_slot,
  output wire [`DEC_BUS_SZ-1:0]     ds2_rob_dec_bus,
  output wire [`REN_BUS_SZ-1:0]     ds2_rob_ren_info,
  output wire [`BP_SZ-1:0]          ds2_rob_bprd_info,
  output wire [`CHKPT_PTR_SZ-1:0]   ds2_rob_chkpt_ptr,
  output wire [`FL_PTR_SZ-1:0]      ds2_rob_fl_head_ptr,

  // Interface to ALU RS
  input wire                        rs_ds_alu_full,
  output wire                       ds2_rs_alu_valid,
  output wire [`ADDR_SZ-1:0]        ds2_rs_alu_fpc,
  output wire [`REN_BUS_SZ-1:0]     ds2_rs_alu_ren_info,
  output wire [`ALU_CTL_SZ-1:0]     ds2_rs_alu_ctl,
  output wire [`ROB_PTR_SZ-1:0]     ds2_rs_alu_rob_ptr

  // Interface to MULT/DIV RS
  //input wire                        rs_ds_mult_div_full,
  //output wire                       ds2_rs_mult_div_valid,
  //output wire [`REN_BUS_SZ-1:0]     ds2_rs_mult_div_ren_info,
  //output wire [`MULTDIV_CTL_SZ-1:0] ds2_rs_mult_div_ctl,
  //output wire [`ROB_PTR_SZ-1:0]     ds2_rs_mult_div_rob_ptr,

  //// Interface to LDST RS
  //input wire                        rs_ds_ldst_full,
  //output wire                       ds2_rs_ldst_valid,
  //output wire [`REN_BUS_SZ-1:0]     ds2_rs_ldst_ren_info,
  //output wire [`LDST_CTL_SZ-1:0]    ds2_rs_ldst_ctl,
  //output wire [`ROB_PTR_SZ-1:0]     ds2_rs_ldst_rob_ptr
  );

  // Internal wires/regs
  // DS1 stage signals
  wire [`REG_IDX_SZ-1:0]  ds1_src1_idx, ds1_src2_idx, ds1_dest_idx;
  wire                    ds1_dest_wr;
  wire                    ds1_type_br;

  // DS2 stage signals
  wire                    ds2_valid;
  wire [`ADDR_SZ-1:0]     ds2_fpc;
  wire                    ds2_in_dly_slot;
  wire [`DEC_BUS_SZ-1:0]  ds2_dec_bus;
  wire [`BP_SZ-1:0]       ds2_bprd_info;
  wire [`TAG_SZ-1:0]      ds2_src1_tag, ds2_src2_tag;
  wire                    ds2_src1_valid, ds2_src2_valid;
  wire [`TAG_SZ-1:0]      ds2_dest_tag;
  wire [`TAG_SZ-1:0]      ds2_dest_tag_old;
  wire [`REN_BUS_SZ-1:0]  ds2_ren_info;
  wire [`FL_PTR_SZ-1:0]   ds2_fl_head_ptr;

  // Handle stalling pipe for full ROB/RS
  // Since the stall has to propagate back to IF/ID stages, we may need this
  // to be an early signal (from a flop ideally).  In this case we may need ID stage
  // signals to determine the stall.
  assign ds_stall = map_table_init | ds2_valid & (
                      rob_ds_full |
                      (rs_ds_alu_full       & ds2_dec_bus[`DEC_TYPE_ALU]) |
                      (rs_ds_mult_div_full  & ds2_dec_bus[`DEC_TYPE_MULTDIV]) |
                      (rs_ds_ldst_full      & ds2_dec_bus[`DEC_TYPE_LDST]));


  // Instantiate Map table for register renaming
  // Note: for MULT/DIV we will use both rename ports for the single instruction
  // because they write to both HI and LO.
  assign ds1_src1_idx = id_ds1_dec_bus[`DEC_REG_S_IDX];
  assign ds1_src2_idx = id_ds1_dec_bus[`DEC_REG_T_IDX];
  assign ds1_dest_idx = id_ds1_dec_bus[`DEC_REG_D_IDX];
  assign ds1_dest_wr  = id_ds1_valid & id_ds1_dec_bus[`DEC_REG_D_WR] & !ds_stall;
  assign ds1_type_br  = id_ds1_valid & id_ds1_dec_bus[`DEC_TYPE_BR] & !ds_stall;

  map_table mt0 (
    .clk(clk),
    .rst(rst),
    .map_table_init(map_table_init),

    .ds1_valid(id_ds1_valid),
    .ds1_src1_idx(ds1_src1_idx),
    .ds1_src2_idx(ds1_src2_idx),
    .ds1_dest_idx(ds1_dest_idx),
    .ds1_dest_wr(ds1_dest_wr),
    .ds1_type_br(ds1_type_br),
    .ds2_src1_tag(ds2_src1_tag),
    .ds2_src2_tag(ds2_src2_tag),
    .ds2_src1_valid(ds_src1_valid),
    .ds2_src2_valid(ds_src2_valid),
    .ds2_dest_tag(ds2_dest_tag),
    .ds2_dest_tag_old(ds2_dest_tag_old),
    .ds2_fl_head_ptr(ds2_fl_head_ptr),
    .ds2_chkpt_ptr(ds2_rob_chkpt_ptr),

    //.ex_cdb_bus(ex_cdb_bus),
    .rob_pipe_flush(rob_pipe_flush),
    .rob_ds_ret_valid(rob_ds_ret_valid),
    .rob_ds_ret_dest_write(rob_ds_ret_dest_write),
    .rob_ds_chkpt_ptr(rob_ds_chkpt_ptr),
    .rob_ds_fl_head_ptr(rob_ds_fl_head_ptr),
    .rob_ds_ret_chkpt_free(rob_ds_ret_chkpt_free),
    .rob_ds_ret_idx(rob_ds_ret_idx),
    .rob_ds_ret_tag(rob_ds_ret_tag),
    .rob_ds_ret_tag_old(rob_ds_ret_tag_old)
  );

  // Flop info into DS2 stage
  MDFFLR #(1)           ds2_valid_ff       (clk, rst, !ds_stall, 1'b0, id_ds1_valid, ds2_valid);
  MDFFL  #(`ADDR_SZ)    ds2_fpc_ff         (clk, id_ds1_valid, id_ds1_fpc, ds2_fpc);
  MDFFLR #(1)           ds2_in_dly_slot_ff (clk, rst, id_ds1_valid, 1'b0, id_ds1_in_dly_slot, ds2_in_dly_slot);
  MDFFL  #(`DEC_BUS_SZ) ds2_dec_bus_ff     (clk, id_ds1_valid, id_ds1_dec_bus, ds2_dec_bus);
  MDFFL  #(`BP_SZ)      ds2_bprd_info_ff   (clk, id_ds1_valid, id_ds1_bprd_info, ds2_bprd_info);
  

  // Construct dispatch packets to the different Reservation Stations
  assign ds2_ren_info = { ds2_dec_bus[`DEC_REG_D_IDX],      // DEST_IDX
                          ds2_dec_bus[`DEC_REG_D_WR],       // DEST_VLD
                          ds2_dest_tag_old,                 // DEST_TAG_OLD
                          ds2_dest_tag,                     // DEST_TAG
                          ds2_src2_valid,                   // SRC2_VLD
                          ds2_dec_bus[`DEC_REG_T_NEED],     // SRC2_NEED
                          ds2_src2_tag,                     // SRC2_TAG
                          ds2_src1_valid,                   // SRC1_VLD
                          ds2_dec_bus[`DEC_REG_S_NEED],     // SRC1_NEED
                          ds2_src1_tag                      // SRC1_TAG
                        };

  // Handle outputs to ROB
  assign ds_rob_valid         = ds2_valid;
  assign ds_rob_fpc           = ds2_fpc;
  assign ds_rob_in_dly_slot   = ds2_in_dly_slot;
  assign ds_rob_dec_bus       = ds2_dec_bus;
  assign ds_rob_ren_info      = ds2_ren_info;
  assign ds_rob_bprd_info     = ds2_bprd_info;
  assign ds_rob_fl_head_ptr   = ds2_fl_head_ptr;

  // Handle outputs to ALU RS
  assign ds2_rs_alu_valid    = ds2_valid & ds2_dec_bus[`DEC_TYPE_ALU] & !ds_stall;
  assign ds2_rs_alu_fpc      = ds2_fpc;
  assign ds2_rs_alu_ren_info = ds2_ren_info;
  assign ds2_rs_alu_rob_ptr  = rob_ds_tail_ptr;

endmodule
