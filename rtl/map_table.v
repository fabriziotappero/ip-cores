//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Register Map Table module                        //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  The Map Table is responsible for maintaining the mapping    //
//  from architectural->physical registers.  This block         //
//  consists of a free list for allocating new physical         //
//  registers and also the tables for mapping source operands.  // 
//                                                              //
//  To avoid excessive flop usage for the map tables, block rams//
//  will be used instead.                                       //
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

module map_table (
  input wire                      clk,
  input wire                      rst,
  output wire                     map_table_init,

  // Rename port
  input wire                      ds1_valid,
  input wire  [`REG_IDX_SZ-1:0]   ds1_src1_idx,
  input wire  [`REG_IDX_SZ-1:0]   ds1_src2_idx,
  input wire  [`REG_IDX_SZ-1:0]   ds1_dest_idx,
  input wire                      ds1_dest_wr,
  input wire                      ds1_type_br,
  output wire [`TAG_SZ-1:0]       ds2_src1_tag,
  output wire [`TAG_SZ-1:0]       ds2_src2_tag,
  output wire                     ds2_src1_valid,
  output wire                     ds2_src2_valid,
  output wire [`TAG_SZ-1:0]       ds2_dest_tag,
  output wire [`TAG_SZ-1:0]       ds2_dest_tag_old,
  output wire [`FL_PTR_SZ-1:0]    ds2_fl_head_ptr,
  output wire [`CHKPT_PTR_SZ-1:0] ds2_chkpt_ptr,

  // Writeback port
  //input wire  [`CDB_BUS_SZ-1:0]   ex_cdb_bus,

  // Retire and flush port
  input wire                      rob_pipe_flush,
  input wire                      rob_ds_ret_valid,
  input wire                      rob_ds_ret_dest_write,
  input wire  [`CHKPT_PTR_SZ-1:0] rob_ds_chkpt_ptr,
  input wire  [`FL_PTR_SZ-1:0]    rob_ds_fl_head_ptr,
  input wire                      rob_ds_ret_chkpt_free,
  input wire  [`REG_IDX_SZ-1:0]   rob_ds_ret_idx,
  input wire  [`TAG_SZ-1:0]       rob_ds_ret_tag,
  input wire  [`TAG_SZ-1:0]       rob_ds_ret_tag_old
  );

  // Internal wires and regs
  wire  [`TAG_SZ-1:0]       ds1_dest_tag;
  wire  [`FL_PTR_SZ-1:0]    ds1_fl_head_ptr;
  wire  [`ARCH_REGS-1:0]    dfa_dirty_bit [`CHKPT_NUM-1:0];
  wire  [`ARCH_REGS-1:0]    dfa_dirty_bit_in [`CHKPT_NUM-1:0];
  wire  [`CHKPT_NUM-1:0]    dfa_dirty_bit_ld; // load is per checkpoint/column
  wire  [`CHKPT_NUM-1:0]    dfa_dirty_bit_row [`ARCH_REGS-1:0];
  wire  [`CHKPT_PTR_SZ-1:0] ds1_src1_chkpt, ds1_src2_chkpt, ds1_dest_chkpt;
  
  wire  [`CHKPT_PTR_SZ-1:0] chkpt_head_ptr;
  wire  [`CHKPT_PTR_SZ-1:0] chkpt_head_ptr_p1;
  wire  [`CHKPT_PTR_SZ-1:0] chkpt_tail_ptr;
  wire  [`CHKPT_PTR_SZ-1:0] chkpt_tail_ptr_p1;
  wire  [`CHKPT_NUM-1:0]    chkpt_valid_mask;
  wire  [`CHKPT_NUM-1:0]    chkpt_valid_mask_in;
  wire                      chkpt_allocate;

  genvar                    g,k;

  // Instantiate free list
  free_list fl (
    .clk(clk),
    .rst(rst),
    .ds1_dest_wr(ds1_dest_wr),
    .rob_pipe_flush(rob_pipe_flush),
    .rob_ds_fl_head_ptr(rob_ds_fl_head_ptr),
    .rob_ds_ret_valid(rob_ds_ret_valid),
    .rob_ds_ret_dest_write(rob_ds_ret_dest_write),
    .rob_ds_ret_tag_old(rob_ds_ret_tag_old),
    .ds1_dest_tag(ds1_dest_tag),
    .ds1_fl_head_ptr(ds1_fl_head_ptr)
  );

  // Maintain the checkpoint head/tail pointers
  // Operation:
  // - Upon a pipe flush, restore both head and tail pointers to same pointer value from the ROB.
  // - When a new checkpoint is allocated, advance head pointer by 1
  // - When an instruction which allocated a checkpoint retires, advance tail pointer by 1.
  assign chkpt_allocate = ds1_type_br & ~rob_pipe_flush;
  wire [`CHKPT_PTR_SZ-1:0] chkpt_head_ptr_in = rob_pipe_flush ? rob_ds_chkpt_ptr : chkpt_head_ptr_p1;
  wire [`CHKPT_PTR_SZ-1:0] chkpt_tail_ptr_in = rob_pipe_flush ? rob_ds_chkpt_ptr : chkpt_tail_ptr_p1;
  wire chkpt_head_ptr_ld = rob_pipe_flush | chkpt_allocate;
  wire chkpt_tail_ptr_ld = rob_pipe_flush | (rob_ds_ret_valid & rob_ds_ret_chkpt_free);

  MDFFLR #(`CHKPT_PTR_SZ) chkpt_head_ptr_ff (clk, rst, chkpt_head_ptr_ld, `CHKPT_PTR_SZ'h0, chkpt_head_ptr_in, chkpt_head_ptr);
  MDFFLR #(`CHKPT_PTR_SZ) chkpt_tail_ptr_ff (clk, rst, chkpt_tail_ptr_ld, `CHKPT_PTR_SZ'h0, chkpt_tail_ptr_in, chkpt_tail_ptr);

  assign chkpt_head_ptr_p1 = (chkpt_head_ptr == `CHKPT_NUM-1) ? `CHKPT_PTR_SZ'h0 : chkpt_head_ptr + `CHKPT_PTR_SZ'h1;
  assign chkpt_tail_ptr_p1 = (chkpt_tail_ptr == `CHKPT_NUM-1) ? `CHKPT_PTR_SZ'h0 : chkpt_tail_ptr + `CHKPT_PTR_SZ'h1;

  // Keep a bit-vector mask of valid (allocated) checkpoints for the DFA search
  // Initialize checkpoint 0 to valid, this will be the checkpoint used out of reset.
  wire [`CHKPT_NUM-1:0] allocated_chkpt = (`CHKPT_NUM'h1 << chkpt_head_ptr_p1) & {`CHKPT_NUM{chkpt_allocate}};
  wire [`CHKPT_NUM-1:0] freed_chkpt     = (`CHKPT_NUM'h1 << chkpt_tail_ptr) & {`CHKPT_NUM{rob_ds_ret_chkpt_free}};
  wire [`CHKPT_NUM-1:0] rob_ds_chkpt_vec = (`CHKPT_NUM'h1 << rob_ds_chkpt_ptr);
  assign chkpt_valid_mask_in = rob_pipe_flush ? rob_ds_chkpt_vec : ((chkpt_valid_mask | allocated_chkpt) & ~freed_chkpt);
  MDFFLR #(`CHKPT_NUM)    chkpt_valid_mask_ff (clk, rst, chkpt_head_ptr_ld | chkpt_tail_ptr_ld, `CHKPT_NUM'h1, chkpt_valid_mask_in, chkpt_valid_mask);

  /*
   Handle the DFA (Dirty Flag Array) for determining which checkpoint contains the
   most recent mapping for an architectural register.  This is needed to setup the
   SRAM address input for the RAT lookup.
   
   Structure:
   - Maintain a grid of bits (one row for each arch. reg, one column for each checkpoint).
   - Head/Tail pointer keep track of most recently/least recently allocated valid checkpoints.
   
   Operation:
   - When a new checkpoint is allocated for a branch or speculation point, we advance
     the head pointer and clear the entire DFA column for that checkpoint.  For branches which
     write a register, the write should update the old checkpoint, not the newly allocated one.
   - When a register write operation comes through, update the row of the head checkpoint
     corresponding to the destination architectural register index.
    
  */
  wire [`CHKPT_NUM-1:0] dfa_column_clear = allocated_chkpt;
  wire [`CHKPT_NUM-1:0] ds1_active_chkpt = (`CHKPT_NUM'h1 << chkpt_head_ptr);
  assign dfa_dirty_bit_ld = dfa_column_clear |                                // Clear newly allocated checkpoint
                            (ds1_active_chkpt & {`CHKPT_NUM{ds1_dest_wr}});   // Update current checkpoint
  
  wire [`ARCH_REGS-1:0] ds1_dest_idx_vec = (1 << ds1_dest_idx);
  generate
    for (g=0; g<`CHKPT_NUM; g=g+1) begin : dfa_gen
      for (k=0; k<`ARCH_REGS; k=k+1) begin : dfa_dirty_bit_gen
        assign dfa_dirty_bit_in[g][k] = ~dfa_column_clear[g] & ((ds1_dest_idx_vec[k] & ds1_dest_wr) ? 1'b1 : dfa_dirty_bit[g][k]);

        MDFFLR #(1) dfa_dirty_bit_ff (clk, rst, dfa_dirty_bit_ld[g], 1'b0, dfa_dirty_bit_in[g][k], dfa_dirty_bit[g][k]);

        // generate a "row" version as well
        assign dfa_dirty_bit_row[k][g] = dfa_dirty_bit[g][k] & chkpt_valid_mask[g];
      end
    end
  endgenerate

  // Determine which checkpoint contains the most recent mapping for each source and the destination
  // TODO: For now, assume 4 checkpoints.  Find a nice way to make this general.
  assign ds1_src1_chkpt = (chkpt_head_ptr == 2'h0) ? (dfa_dirty_bit_row[ds1_src1_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][2] ? 2'h2 : 2'h3) :
                          (chkpt_head_ptr == 2'h1) ? (dfa_dirty_bit_row[ds1_src1_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][3] ? 2'h3 : 2'h0) :
                          (chkpt_head_ptr == 2'h2) ? (dfa_dirty_bit_row[ds1_src1_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][0] ? 2'h0 : 2'h1) :
                                                     (dfa_dirty_bit_row[ds1_src1_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_src1_idx][1] ? 2'h1 : 2'h2);
  assign ds1_src2_chkpt = (chkpt_head_ptr == 2'h0) ? (dfa_dirty_bit_row[ds1_src2_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][2] ? 2'h2 : 2'h3) :
                          (chkpt_head_ptr == 2'h1) ? (dfa_dirty_bit_row[ds1_src2_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][3] ? 2'h3 : 2'h0) :
                          (chkpt_head_ptr == 2'h2) ? (dfa_dirty_bit_row[ds1_src2_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][0] ? 2'h0 : 2'h1) :
                                                     (dfa_dirty_bit_row[ds1_src2_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_src2_idx][1] ? 2'h1 : 2'h2);
  assign ds1_dest_chkpt = (chkpt_head_ptr == 2'h0) ? (dfa_dirty_bit_row[ds1_dest_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][2] ? 2'h2 : 2'h3) :
                          (chkpt_head_ptr == 2'h1) ? (dfa_dirty_bit_row[ds1_dest_idx][1] ? 2'h1 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][3] ? 2'h3 : 2'h0) :
                          (chkpt_head_ptr == 2'h2) ? (dfa_dirty_bit_row[ds1_dest_idx][2] ? 2'h2 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][0] ? 2'h0 : 2'h1) :
                                                     (dfa_dirty_bit_row[ds1_dest_idx][3] ? 2'h3 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][0] ? 2'h0 :
                                                      dfa_dirty_bit_row[ds1_dest_idx][1] ? 2'h1 : 2'h2);

  // If no dirty bit set for any of the valid checkpoints, then committed copy must have latest mapping
  wire ds1_src1_use_rrat = ~(|dfa_dirty_bit_row[ds1_src1_idx]);
  wire ds1_src2_use_rrat = ~(|dfa_dirty_bit_row[ds1_src2_idx]);
  wire ds1_dest_use_rrat = ~(|dfa_dirty_bit_row[ds1_dest_idx]);

  // Generate the RAT SRAM read/write addresses and controls
  // Note: since tables are SRAM-based, we need to initialize the RRAT so that 
  // registers are mapped correctly out of reset
  wire [`REG_IDX_SZ-1:0] map_table_init_ctr, map_table_init_ctr_in;
  wire map_table_init_in = map_table_init & (map_table_init_ctr != `ARCH_REGS);
  MDFFR #(1) map_table_init_ff (clk, rst, 1'b1, map_table_init_in, map_table_init);

  assign map_table_init_ctr_in = map_table_init_ctr + `REG_IDX_SZ'h1;
  MDFFLR #(`REG_IDX_SZ) map_table_init_ctr_ff (clk, rst, map_table_init, `REG_IDX_SZ'h0, map_table_init_ctr_in, map_table_init_ctr);

  wire [`REG_IDX_SZ+`CHKPT_PTR_SZ-1:0] ds1_rat_src1_rd_addr = {ds1_src1_idx,ds1_src1_chkpt};
  wire [`REG_IDX_SZ+`CHKPT_PTR_SZ-1:0] ds1_rat_src2_rd_addr = {ds1_src2_idx,ds1_src2_chkpt};
  wire [`REG_IDX_SZ+`CHKPT_PTR_SZ-1:0] ds1_rat_dest_rd_addr = {ds1_dest_idx,ds1_dest_chkpt};

  // Writes need to come from DS2 stage in case we read and write the same arch. register
  wire                                 ds2_rat_wren, ds2_rat_wren_in;
  wire [`REG_IDX_SZ+`CHKPT_PTR_SZ-1:0] ds2_rat_wr_addr, ds2_rat_wr_addr_in;
  wire [`TAG_SZ-1:0]                   ds2_rat_wr_data;

  assign ds2_rat_wren_in = ds1_dest_wr;
  assign ds2_rat_wr_addr_in = {ds1_dest_idx,chkpt_head_ptr};
  MDFFR #(1) ds2_rat_wren_ff (clk, rst, 1'b0, ds2_rat_wren_in, ds2_rat_wren);
  MDFFR #(`REG_IDX_SZ+`CHKPT_PTR_SZ) ds2_rat_wr_addr_ff (clk, rst, 1'b0, ds2_rat_wr_addr_in, ds2_rat_wr_addr);
  assign ds2_rat_wr_data = ds2_dest_tag;

  wire [`TAG_SZ-1:0] ds2_rat_src1_rd_data, ds2_rrat_src1_rd_data;
  wire [`TAG_SZ-1:0] ds2_rat_src2_rd_data, ds2_rrat_src2_rd_data;
  wire [`TAG_SZ-1:0] ds2_rat_dest_rd_data, ds2_rrat_dest_rd_data;

  wire [`REG_IDX_SZ-1:0] ds_rrat_wr_addr = map_table_init ? map_table_init_ctr : rob_ds_ret_idx;
  wire [`TAG_SZ-1:0]     ds_rrat_wr_data = map_table_init ? map_table_init_ctr : rob_ds_ret_tag;
  wire                   ds_rrat_wren    = map_table_init | rob_ds_ret_valid & rob_ds_ret_dest_write;
  
  // Instantiate RAT SRAM blocks
  // Note that we need 3 copies for the required 3 read ports (2 source operand tag reads, 1 previous dest tag read)
  // Read copy 1
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ+`CHKPT_PTR_SZ)) rat0 (
    .clk(clk),
    .a_addr(ds1_rat_src1_rd_addr),   // Read port
    .a_dout(ds2_rat_src1_rd_data),

    .b_addr(ds2_rat_wr_addr),        // Write port
    .b_wren(ds2_rat_wren),
    .b_din(ds2_rat_wr_data)
  );

  // Read copy 2
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ+`CHKPT_PTR_SZ)) rat1 (
    .clk(clk),
    .a_addr(ds1_rat_src2_rd_addr),   // Read port
    .a_dout(ds2_rat_src2_rd_data),

    .b_addr(ds2_rat_wr_addr),        // Write port
    .b_wren(ds2_rat_wren),
    .b_din(ds2_rat_wr_data)
  );

  // Write copy 1
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ+`CHKPT_PTR_SZ)) rat2 (
    .clk(clk),
    .a_addr(ds1_rat_dest_rd_addr),   // Read port
    .a_dout(ds2_rat_dest_rd_data),

    .b_addr(ds2_rat_wr_addr),        // Write port
    .b_wren(ds2_rat_wren),
    .b_din(ds2_rat_wr_data)
  );

  // Instantiate tables for the committed RAT copies
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ)) rrat0 (
    .clk(clk),
    .a_addr(ds1_src1_idx),           // Read port
    .a_dout(ds2_rrat_src1_rd_data),

    .b_addr(ds_rrat_wr_addr),        // Write port  (controlled by retire)
    .b_wren(ds_rrat_wren),
    .b_din(ds_rrat_wr_data)
  );
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ)) rrat1 (
    .clk(clk),
    .a_addr(ds1_src2_idx),           // Read port
    .a_dout(ds2_rrat_src2_rd_data),

    .b_addr(ds_rrat_wr_addr),        // Write port  (controlled by retire)
    .b_wren(ds_rrat_wren),
    .b_din(ds_rrat_wr_data)
  );
  dp_sram #(.DW(`TAG_SZ), .IW(`REG_IDX_SZ)) rrat2 (
    .clk(clk),
    .a_addr(ds1_dest_idx),           // Read port
    .a_dout(ds2_rrat_dest_rd_data),

    .b_addr(ds_rrat_wr_addr),        // Write port  (controlled by retire)
    .b_wren(ds_rrat_wren),
    .b_din(ds_rrat_wr_data)
  );

  // Since writes to map tables occur in DS2 stage, need to detect forwarding from previous instructions
  wire ds1_src1_wr_fwd = (ds1_src1_idx == ds2_rat_wr_addr[`REG_IDX_SZ+`CHKPT_PTR_SZ-1:`CHKPT_PTR_SZ]) & ds2_rat_wren;
  wire ds1_src2_wr_fwd = (ds1_src2_idx == ds2_rat_wr_addr[`REG_IDX_SZ+`CHKPT_PTR_SZ-1:`CHKPT_PTR_SZ]) & ds2_rat_wren;
  wire ds1_dest_wr_fwd = (ds1_dest_idx == ds2_rat_wr_addr[`REG_IDX_SZ+`CHKPT_PTR_SZ-1:`CHKPT_PTR_SZ]) & ds2_rat_wren;
  wire ds2_src1_wr_fwd, ds2_src2_wr_fwd, ds2_dest_wr_fwd;
  MDFFR #(1) ds2_src1_wr_fwd_ff (clk, rst, 1'b0, ds1_src1_wr_fwd, ds2_src1_wr_fwd);
  MDFFR #(1) ds2_src2_wr_fwd_ff (clk, rst, 1'b0, ds1_src2_wr_fwd, ds2_src2_wr_fwd);
  MDFFR #(1) ds2_dest_wr_fwd_ff (clk, rst, 1'b0, ds1_dest_wr_fwd, ds2_dest_wr_fwd);

  wire [`TAG_SZ-1:0] r_ds2_rat_wr_data;
  wire r_ds2_wr_data_ld = ds2_rat_wren & (ds1_src1_wr_fwd | ds1_src2_wr_fwd | ds1_dest_wr_fwd);
  MDFFL #(`TAG_SZ) r_ds2_rat_wr_data_ff (clk, r_ds2_wr_data_ld, ds2_rat_wr_data, r_ds2_rat_wr_data);

  // Generate DS2 stage outputs
  // Mux between RRAT and RAT outputs
  MDFFL #(`CHKPT_PTR_SZ) ds2_chkpt_ptr_ff   (clk, ds1_valid, chkpt_head_ptr, ds2_chkpt_ptr);
  MDFFL #(`FL_PTR_SZ)    ds2_fl_head_ptr_ff (clk, ds1_valid, ds1_fl_head_ptr, ds2_fl_head_ptr);

  wire ds2_src1_use_rrat, ds2_src2_use_rrat, ds2_dest_use_rrat;
  MDFFLR #(1) ds2_src1_use_rrat_ff (clk, rst, ds1_valid, 1'b0, ds1_src1_use_rrat, ds2_src1_use_rrat);
  MDFFLR #(1) ds2_src2_use_rrat_ff (clk, rst, ds1_valid, 1'b0, ds1_src2_use_rrat, ds2_src2_use_rrat);
  MDFFLR #(1) ds2_dest_use_rrat_ff (clk, rst, ds1_valid, 1'b0, ds1_dest_use_rrat, ds2_dest_use_rrat);
  MDFFL  #(`TAG_SZ) ds2_dest_tag_ff (clk, ds1_valid, ds1_dest_tag, ds2_dest_tag);

  assign ds2_src1_tag     = ds2_src1_wr_fwd ? r_ds2_rat_wr_data : ds2_src1_use_rrat ? ds2_rrat_src1_rd_data : ds2_rat_src1_rd_data;
  assign ds2_src2_tag     = ds2_src2_wr_fwd ? r_ds2_rat_wr_data : ds2_src2_use_rrat ? ds2_rrat_src2_rd_data : ds2_rat_src2_rd_data;
  assign ds2_dest_tag_old = ds2_dest_wr_fwd ? r_ds2_rat_wr_data : ds2_dest_use_rrat ? ds2_rrat_dest_rd_data : ds2_rat_dest_rd_data;
  
  

    
endmodule
