//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Cache module                         //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Top-level module for Instruction Cache block.  This includes//
//  the instantiation of the data and tag RAMs as well as the   //
//  cache controller logic.                                     //
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

module icache_top (
  input wire                    clk,
  input wire                    rst,
  input wire                    rob_pipe_flush,

  // Coprocessor interface
  input wire                    cp0_ic_enable,
  
  // IF interface
  input wire                    if_ic_req,
  input wire  [`ADDR_SZ-1:0]    if_ic_fpc,
  input wire  [`ADDR_SZ-1:0]    r_if_ic_fpc,
  output wire [`INSTR_SZ-1:0]   ic_if_data,
  output wire                   ic_if_data_valid,
  output wire                   ic_if_cache_hit,
  output wire                   ic_if_cache_miss,
  output wire                   ic_if_ready,

  // Memory interface
  output wire                   ic2bus_req,
  output wire [`ADDR_SZ-1:0]    ic2bus_fpc,
  input wire                    bus2ic_valid,
  input wire  [`SYS_BUS_SZ-1:0] bus2ic_data
  );

  // Internal wires
  wire  [`IC_SI_SZ-1:0]     ic_dataram_addr;
  wire  [`IC_LINE_SZ-1:0]   ic_dataram_data;
  wire  [`IC_LINE_SZ-1:0]   ic_dataram_wr_data;
  wire                      ic_dataram_wren;

  wire  [`IC_SI_SZ-1:0]     ic_tagram_addr;
  wire  [`IC_TAGRAM_SZ-1:0] ic_tagram_data;
  wire  [`IC_TAGRAM_SZ-1:0] ic_tagram_wr_data;
  wire                      ic_tagram_wren;
  
  // Instantiate IC controller
  icache_ctl icache_ctl0(
    .clk(clk),
    .rst(rst),
    .rob_pipe_flush(rob_pipe_flush),
    .cp0_ic_enable(cp0_ic_enable),
    .if_ic_req(if_ic_req),
    .if_ic_fpc(if_ic_fpc),
    .r_if_ic_fpc(r_if_ic_fpc),
    .ic_if_data(ic_if_data),
    .ic_if_data_valid(ic_if_data_valid),
    .ic_if_ready(ic_if_ready),
    .ic_tagram_data(ic_tagram_data),
    .ic_dataram_data(ic_dataram_data),
    .ic_dataram_wr_data(ic_dataram_wr_data),
    .ic_dataram_addr(ic_dataram_addr),
    .ic_dataram_wren(ic_dataram_wren),
    .ic_tagram_wr_data(ic_tagram_wr_data),
    .ic_tagram_addr(ic_tagram_addr),
    .ic_tagram_wren(ic_tagram_wren),
    .ic2bus_req(ic2bus_req),
    .ic2bus_fpc(ic2bus_fpc),
    .bus2ic_valid(bus2ic_valid),
    .bus2ic_data(bus2ic_data)
  );

  // Instantiate IC data and tag RAMs
  `ifdef USE_IC
  sp_sram #(.DW(`IC_LINE_SZ), .IW(`IC_SI_SZ)) d0 (
    .clk(clk),
    .addr(ic_dataram_addr),
    .wren(ic_dataram_wren),
    .din(ic_dataram_wr_data),
    .dout(ic_dataram_data)
  );
  sp_sram #(.DW(`IC_TAGRAM_SZ), .IW(`IC_SI_SZ)) t0 (
    .clk(clk),
    .addr(ic_tagram_addr),
    .wren(ic_tagram_wren),
    .din(ic_tagram_wr_data),
    .dout(ic_tagram_data)
  );
  `else
  assign ic_dataram_data = {`IC_LINE_SZ{1'b0}};
  assign ic_tagram_data  = {`IC_TAGRAM_SZ{1'b0}};
  `endif

endmodule
