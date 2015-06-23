//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Fetch module                         //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Handles updating Program Counter and fetching instructions  //
//  from the Instruction Cache.                                 //
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

module if_stage (
  input wire                    clk,
  input wire                    rst,
  
  // Flush/stall interfaces
  input wire                    rob_pipe_flush, 
  input wire  [`ADDR_SZ-1:0]    rob_flush_target,
  input wire                    ds_stall,

  // Instruction cache interface
  output wire                   if_ic_req,
  output wire [`ADDR_SZ-1:0]    if_ic_fpc,
  output wire [`ADDR_SZ-1:0]    r_if_ic_fpc,
  input wire  [`INSTR_SZ-1:0]   ic_if_data,
  input wire                    ic_if_data_valid,
  input wire                    ic_if_ready,

  // Interface to ID stage
  output wire                   if_id_valid,
  output wire [`INSTR_SZ-1:0]   if_id_instr,
  output wire [`ADDR_SZ-1:0]    if_id_fpc,
  output wire [`BP_SZ-1:0]      if_id_bprd_info
  );

  // Internal wires/regs
  wire                  if_stall;
  wire                  if_valid;
  wire  [`ADDR_SZ-1:0]  if_fpc;       // Current fetch pc
  wire  [`ADDR_SZ-1:0]  r_if_fpc;     // flopped FPC
  wire  [`ADDR_SZ-1:0]  r_if_fpc_in;
  wire  [`INSTR_SZ-1:0] if_instr;
  wire  [`BP_SZ-1:0]    if_bprd_info;
  wire                  if_br_predict_valid;
  wire                  if_br_predict_taken;
  wire  [`ADDR_SZ-1:0]  if_br_predict_target;

  // Note that Icache will have 1 cycle latency, so we won't know if it's a miss until
  // one cycle later.  Since we don't want to have to wait to figure out if it's a hit
  // before we increment the FPC (want to be optimistic), we'll have to be able to reset
  // the FPC if it's a miss.
  assign if_ic_req   = !if_stall;
  assign if_ic_fpc   = if_fpc;
  assign r_if_ic_fpc = r_if_fpc;
  assign if_valid    = ic_if_data_valid & !rob_pipe_flush;
  assign if_instr    = ic_if_data;

  // Handle the FPC generation
  wire  [`ADDR_SZ-1:0]  if_fpc_p4 = if_fpc + `ADDR_SZ'h4;
  reg   [`ADDR_SZ-1:0]  if_fpc_in;
  always @* begin
    casez({rob_pipe_flush, if_br_predict_taken, !ic_if_ready})
      3'b1??:   if_fpc_in = rob_flush_target;       // Flush target
      3'b01?:   if_fpc_in = if_br_predict_target;   // Taken branch target
      3'b001:   if_fpc_in = r_if_fpc;               // Previous FPC
      default:  if_fpc_in = if_fpc_p4;              // Next incrmented FPC
    endcase
  end

  MDFFLR #(`ADDR_SZ) if_fpc_ff   (clk, rst, if_ic_req, `RESET_ADDR, if_fpc_in, if_fpc);

  // Flop Icache request signals so we can re-request if it ends up being a miss
  assign r_if_fpc_in = rob_pipe_flush ? rob_flush_target : if_ic_fpc;
  MDFFR  #(`ADDR_SZ) r_if_fpc_ff (clk, rst, `RESET_ADDR, if_fpc, r_if_fpc);

  // Handle branch prediction
  // TODO: throw in branch prediction
  // Note: Try to identify jumps and other unconditional branches here, for quick recovery
  `ifdef DYN_BPRD
  assign if_br_predict_valid  = 1'b0;
  assign if_br_predict_taken  = 1'b0;
  assign if_br_predict_target = {`ADDR_SZ{1'b0}};
  assign if_bprd_info         = {if_br_predict_target, if_br_predict_taken, if_br_predict_valid};
  `else
  // tie-offs should optimize logic away
  assign if_br_predict_valid  = 1'b0;
  assign if_br_predict_taken  = 1'b0;
  assign if_br_predict_target = {`ADDR_SZ{1'b0}};
  assign if_bprd_info         = {if_br_predict_target, if_br_predict_taken, if_br_predict_valid};
  `endif

  `ifdef USE_IFB
  wire ifb_full;
  if_buffer ifb (
    .clk(clk),
    .rst(rst),
    .flush(rob_pipe_flush),
    .if_valid(if_valid),
    .if_instr(if_instr),
    .if_fpc(if_fpc),
    .if_bprd_info(if_bprd_info),
    .if_ifb_pop_en(!ds_stall),
    .ifb_full(ifb_full),
    .if_id_valid(if_id_valid),
    .if_id_instr(if_id_instr),
    .if_id_fpc(if_id_fpc),
    .if_id_bprd_info(if_id_bprd_info)
  );

  assign if_stall = ifb_full;   // Only stall if IFB is full
  `else

  MDFFLR #(1)         if_id_valid_ff     (clk, rst, !if_stall, 1'b0, if_valid, if_id_valid);
  MDFFL  #(`INSTR_SZ) if_id_instr_ff     (clk, !if_stall, if_instr, if_id_instr);
  MDFFL  #(`ADDR_SZ)  if_id_fpc_ff       (clk, !if_stall, if_ic_fpc_q, if_id_fpc);
  MDFFL  #(`BP_SZ)    if_id_bprd_info_ff (clk, if_valid, if_bprd_info, if_id_bprd_info);

  assign if_stall = if_id_valid & ds_stall;   // Stall if we have a valid instruction going to ID and DS stalling

  `endif  // USE_IFB
endmodule
