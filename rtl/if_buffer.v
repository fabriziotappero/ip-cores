//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Instruction Fetch Buffer module                  //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Buffer for fetched instructions to help reduce penalty of   //
//  cache misses during stall cycles.                           //
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

module if_buffer (
  input wire                    clk,
  input wire                    rst,
  input wire                    flush,

  // Write interface
  input wire                    if_valid,
  input wire  [`INSTR_SZ-1:0]   if_instr,
  input wire  [`ADDR_SZ-1:0]    if_fpc,
  input wire  [`BP_SZ-1:0]      if_bprd_info,

  // Read interface
  input wire                    if_ifb_pop_en,
  output wire                   ifb_full,
  output wire                   if_id_valid,
  output wire [`INSTR_SZ-1:0]   if_id_instr,
  output wire [`ADDR_SZ-1:0]    if_id_fpc,
  output wire [`BP_SZ-1:0]      if_id_bprd_info
  );

  // Local wires
  wire [`IFB_PTR_SZ:0]      ifb_rd_ptr, ifb_rd_ptr_in;
  wire [`IFB_PTR_SZ:0]      ifb_wr_ptr, ifb_wr_ptr_in;
  wire [`IFB_ENTRIES-1:0]   ifb_rd_ptr_vec;             // 1-hot vector for reading
  wire                      ifb_empty;
  wire                      ifb_push;
  wire                      ifb_pop;
  wire [`IFB_PTR_SZ:0]      ifb_valid_counter, ifb_valid_counter_in;
  wire                      ifb_valid_counter_ld;

  wire [`IFB_ENTRY_SZ-1:0]  ifb_entry    [`IFB_ENTRIES-1:0];
  wire [`IFB_ENTRY_SZ-1:0]  ifb_entry_in;
  wire [`IFB_ENTRIES-1:0]   ifb_entry_ld;
  reg  [`IFB_ENTRY_SZ-1:0]  ifb_rd_entry;

  // Handle muxing outputs
  integer i;
  always @* begin
    ifb_rd_entry = {`IFB_ENTRY_SZ{1'b0}};
    for (i=0; i<`IFB_ENTRIES; i=i+1) begin
      ifb_rd_entry = ifb_rd_entry | ({`IFB_ENTRY_SZ{ifb_rd_ptr_vec[i]}} & ifb_entry[i]);
    end
  end
  assign if_id_valid = !ifb_empty;
  assign {if_id_instr,if_id_fpc,if_id_bprd_info} = ifb_rd_entry;

  // Handle updating the read and write pointers
  assign ifb_push       = if_valid & !ifb_full;
  assign ifb_pop        = if_ifb_pop_en & !ifb_empty;
  assign ifb_wr_ptr_in  = ((ifb_wr_ptr==`IFB_ENTRIES) | flush) ? {`IFB_PTR_SZ+1{1'b0}} : ifb_wr_ptr + 1;
  assign ifb_rd_ptr_in  = ((ifb_rd_ptr==`IFB_ENTRIES) | flush) ? {`IFB_PTR_SZ+1{1'b0}} : ifb_rd_ptr + 1;

  wire [`IFB_ENTRIES-1:0] ifb_rd_ptr_vec_in = (`IFB_ENTRIES'h1 << ifb_rd_ptr_in);

  wire ifb_wr_ptr_ld = ifb_push | flush;
  wire ifb_rd_ptr_ld = ifb_pop | flush;
  MDFFLR #(`IFB_PTR_SZ+1) ifb_wr_ptr_ff (clk, rst, ifb_wr_ptr_ld, {`IFB_PTR_SZ+1{1'b0}}, ifb_wr_ptr_in, ifb_wr_ptr);
  MDFFLR #(`IFB_PTR_SZ+1) ifb_rd_ptr_ff (clk, rst, ifb_rd_ptr_ld, {`IFB_PTR_SZ+1{1'b0}}, ifb_rd_ptr_in, ifb_rd_ptr);
  MDFFLR #(`IFB_ENTRIES)  ifb_rd_ptr_vec_ff (clk, rst, ifb_rd_ptr_ld, `IFB_ENTRIES'h1, ifb_rd_ptr_vec_in, ifb_rd_ptr_vec);

  // Handle occupancy detection
  wire ifb_full_in = (ifb_wr_ptr_in[`IFB_PTR_SZ] ^ ifb_rd_ptr_in[`IFB_PTR_SZ])   & (ifb_wr_ptr_in[`IFB_PTR_SZ-1:0]==ifb_rd_ptr_in[`IFB_PTR_SZ-1:0]);
  wire ifb_empty_in = (ifb_wr_ptr_in[`IFB_PTR_SZ] ~^ ifb_rd_ptr_in[`IFB_PTR_SZ]) & (ifb_wr_ptr_in[`IFB_PTR_SZ-1:0]==ifb_rd_ptr_in[`IFB_PTR_SZ-1:0]);
  MDFFR #(1) ifb_full_ff (clk, rst, 1'b0, ifb_full_in, ifb_full);
  MDFFR #(1) ifb_empty_ff (clk, rst, 1'b1, ifb_empty_in, ifb_empty);

  // Instantiate flops for entries
  assign ifb_entry_in = {if_valid,if_instr, if_fpc, if_bprd_info};
  genvar g;
  generate
    for (g=0; g<`IFB_ENTRIES; g=g+1)
    begin : ifb_entry_gen
      MDFFL #(`IFB_ENTRY_SZ) entry_ff (clk, ifb_entry_ld[g], ifb_entry_in, ifb_entry[g]);
    end
  endgenerate

endmodule
