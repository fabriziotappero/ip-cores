//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Cache Control module                 //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Controller for Instruction Cache.  Block takes requests from//
//  the IF stage, handles the inputs to the cache RAMs, detects //
//  cache hits, and generates bus requests if the cache misses. //
//  The controller is only capable of handling one outstanding  //
//  miss and does no prefetching.                               //
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

module icache_ctl (
  input wire                      clk,
  input wire                      rst,
  input wire                      rob_pipe_flush,

  // Coprocessor interface (for IC enable)
  input wire                      cp0_ic_enable,

  // IF interface
  input wire                      if_ic_req,
  input wire  [`ADDR_SZ-1:0]      if_ic_fpc,
  input wire  [`ADDR_SZ-1:0]      r_if_ic_fpc,
  output wire [`INSTR_SZ-1:0]     ic_if_data,
  output wire                     ic_if_data_valid,
  output wire                     ic_if_ready,

  // Interface to cache memories
  input wire  [`IC_TAGRAM_SZ-1:0] ic_tagram_data,
  input wire  [`IC_LINE_SZ-1:0]   ic_dataram_data,
  output wire [`IC_LINE_SZ-1:0]   ic_dataram_wr_data,
  output wire [`IC_SI_SZ-1:0]     ic_dataram_addr,
  output wire                     ic_dataram_wren,
  output wire [`IC_TAGRAM_SZ-1:0] ic_tagram_wr_data,
  output wire [`IC_SI_SZ-1:0]     ic_tagram_addr,
  output wire                     ic_tagram_wren,

  // Memory interface
  output wire                     ic2bus_req,
  output wire [`ADDR_SZ-1:0]      ic2bus_fpc,
  input wire                      bus2ic_valid,
  input wire  [`SYS_BUS_SZ-1:0]   bus2ic_data
  );

  parameter IC_STATE_IDLE   = 3'h0,
            IC_STATE_REQ    = 3'h1,
            IC_STATE_WAIT   = 3'h2,
            IC_STATE_WR_RAM = 3'h3,
            IC_STATE_INIT   = 3'h4;

  // Internal wires/regs
  wire                          ic_cache_hit;
  wire                          ic_tag_match;
  wire                          ic_tag_valid;
  wire [`IC_TAG_SZ-1:0]         ic_tag;
  wire                          r_if_ic_req;

  wire [2:0]                    ic_state;
  reg  [2:0]                    ic_nstate;
  wire [`IC_SI]                 ic_init_ctr;
  wire [`IC_SI]                 ic_init_nctr;
  wire                          ic_do_init;
  wire                          ic_init_done;
  wire                          ic_initialized;
  wire                          ic_initialized_ld;

  // Latch req signal so we can correctly assert "hit" and also request to memory
  // on a cache miss.
  MDFFR #(1) r_if_ic_req_ff (clk, rst, 1'b0, if_ic_req, r_if_ic_req);

  // If we get a cache miss and then a flush happens, need to make sure that instruction
  // coming back isn't sent down the pipe.
  wire rob_pipe_flush_seen, rob_pipe_flush_seen_in;
  assign rob_pipe_flush_seen_in = rob_pipe_flush_seen ? ~bus2ic_valid : rob_pipe_flush & (ic_state != IC_STATE_IDLE);
  MDFFR #(1) rob_pipe_flush_seen_ff (clk, rst, 1'b0, rob_pipe_flush_seen_in, rob_pipe_flush_seen);

  // Handle interface to Data and Tag SRAMs
  `ifdef USE_IC
  assign ic_do_init          = (ic_state == IC_STATE_INIT);
  assign ic_dataram_wren     = ic_do_init || (bus2ic_valid & !rob_pipe_flush_seen);
  assign ic_dataram_wr_data  = ic_do_init ? {`IC_LINE_SZ{1'b0}} : bus2ic_data;
  assign ic_dataram_addr     = (ic_state == IC_STATE_INIT) ? ic_init_ctr[`IC_SI] : 
                               (ic_state == IC_STATE_WAIT) ? ic2bus_fpc[`IC_SI] :
                                                             if_ic_fpc[`IC_SI];

  assign ic_tagram_wren      = ic_do_init || (bus2ic_valid & !rob_pipe_flush_seen);
  assign ic_tagram_wr_data   = ic_do_init ? {`IC_TAGRAM_SZ{1'b0}} : {1'b1, 1'b0, ic2bus_fpc[`IC_TAG]};
  assign ic_tagram_addr      = (ic_state == IC_STATE_INIT) ? ic_init_ctr[`IC_SI] : 
                               (ic_state == IC_STATE_WAIT) ? ic2bus_fpc[`IC_SI] :
                                                             if_ic_fpc[`IC_SI];
  `else
  // If not including Icache, then just zero cache inputs out
  assign ic_do_init          = 1'b0;
  assign ic_dataram_wren     = 1'b0;
  assign ic_dataram_wr_data  = {`IC_LINE_SZ{1'b0}};
  assign ic_dataram_addr     = {`IC_SI_SZ{1'b0}};

  assign ic_tagram_wren      = 1'b0;
  assign ic_tagram_wr_data   = {`IC_LINE_SZ{1'b0}};
  assign ic_tagram_addr      = {`IC_SI_SZ{1'b0}};
  `endif
  
  // Handle tag comparison and IF interface
  // Note: ic_if_ready just means we've initialized SRAMs.  This will block
  // IF requests and stall the pipeline on startup.
  `ifdef USE_IC
  assign ic_tag           = ic_tagram_data[`IC_TAGRAM_TAG];
  assign ic_tag_valid     = ic_tagram_data[`IC_TAGRAM_VLD];
  assign ic_tag_match     = (ic_tag == r_if_ic_fpc[`IC_TAG]);
  assign ic_cache_hit     = ic_tag_match & (r_if_ic_req & ic_tag_valid & cp0_ic_enable & ic_initialized & !rob_pipe_flush_seen);
  assign ic_if_ready      = ic_initialized & (ic_nstate == IC_STATE_IDLE);
  assign ic_if_data       = r_if_ic_fpc[2] ? ic_dataram_data[63:32] : ic_dataram_data[31:0];
  assign ic_if_data_valid = ic_cache_hit;
  `else
  // If not including Icache, then need to force everything as a cache miss and only return bus2ic_data
  assign ic_tag           = {`IC_TAG_SZ{1'b0}};
  assign ic_tag_valid     = 1'b0;
  assign ic_tag_match     = 1'b0;
  assign ic_cache_hit     = bus2ic_valid & !rob_pipe_flush_seen;
  assign ic_if_ready      = 1'b1; // No need to initialize cache
  assign ic_if_data       = r_if_ic_fpc[2] ? bus2ic_data[63:32] : bus2ic_data[31:0];
  assign ic_if_data_valid = ic_cache_hit;

  `endif

  
  // Icache state machine
  always @*
    case (ic_state)
      // From the IDLE state
      //  + move to req if we detect a miss
      IC_STATE_IDLE: begin
          if (r_if_ic_req & !ic_cache_hit)
            ic_nstate = IC_STATE_REQ;
          else
            ic_nstate = IC_STATE_IDLE;
        end

      // In the REQ state we send the request to memory for the needed data.
      // Then transition to WAIT state to wait for memory response
      // TODO: Need to stall here if arbiter doesn't accept our request
      IC_STATE_REQ: begin
        ic_nstate = IC_STATE_WAIT;
        end

      // In the WAIT state we wait for memory response, then transition to
      // WR_RAM state to write the data.
      IC_STATE_WAIT: begin
        if (bus2ic_valid) ic_nstate = IC_STATE_IDLE;
        else              ic_nstate = IC_STATE_WAIT;
        end

      // From the INIT state, we initialize each line of the cache to invalid
      // and transition to IDLE after writing each line.
      IC_STATE_INIT: begin
          if (ic_init_ctr == `IC_NUM_LINES-1)
            ic_nstate = IC_STATE_IDLE;
          else
            ic_nstate = IC_STATE_INIT;
        end

      default: ic_nstate = IC_STATE_IDLE;
    endcase

  // For the initialization, just loop through every set in cache and write it as invalid.  When done
  // set ic_initialized.
  `ifdef USE_IC
  assign ic_init_done      = (ic_state == IC_STATE_INIT) & (ic_init_ctr == `IC_NUM_LINES-1);
  assign ic_initialized_ld = ic_init_done;
  assign ic_init_nctr      = ic_init_ctr + `IC_SI_SZ'h1;
  `else
  assign ic_init_done      = 1'b1;
  assign ic_initialized_ld = 1'b0;
  assign ic_init_nctr      = {`IC_SI_SZ{1'b0}};
  `endif

  MDFFR  #(3)         ic_state_ff (clk, rst, IC_STATE_INIT, ic_nstate, ic_state);
  MDFFLR #(`IC_SI_SZ) ic_init_ctr_ff (clk, rst, (ic_state == IC_STATE_INIT), `IC_SI_SZ'h0, ic_init_nctr, ic_init_ctr);
  MDFFLR #(1)         ic_initialized_ff (clk, rst, ic_initialized_ld, 1'b0, 1'b1, ic_initialized);

  // Handle memory request outputs
  // Note that we request from the bus the cycle after detecting a hit, so if_ic_fpc should be corrected from miss already.
  assign ic2bus_fpc = if_ic_fpc;
  assign ic2bus_req = (ic_state == IC_STATE_REQ);

endmodule
