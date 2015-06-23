//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Register Free List module                        //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  The free list is a circular FIFO used to keep track of free //
//  physical registers that can be allocated to new instructions//
//  New tags are allocated from the head and freed tags are     //
//  written to the tail of the FIFO.                            //
//  The head pointer+1 is passed along with branches so that    //
//  The FIFO state can be recovered after a misprediction.      //
//                                                              //
//  Note: MULT/DIV instructions will require two tags since     //
//  they update both HI and LO registers.                       //
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

// TODO: consider making this a bit-vector-based free list to save on
// flop usage.  With tag FIFO, we have (`ARCH_REGS+`ROB_SZ)*`TAG_SZ flops
// just for the storage.
module free_list (
  input wire                    clk,
  input wire                    rst,
  input wire                    ds1_dest_wr,

  input wire                    rob_pipe_flush,
  input wire  [`FL_PTR_SZ-1:0]  rob_ds_fl_head_ptr,
  input wire                    rob_ds_ret_valid,
  input wire                    rob_ds_ret_dest_write,
  input wire  [`TAG_SZ-1:0]     rob_ds_ret_tag_old,

  output wire [`TAG_SZ-1:0]     ds1_dest_tag,
  output wire [`FL_PTR_SZ-1:0]  ds1_fl_head_ptr
  );

  // Internal wires/regs
  wire  [`TAG_SZ-1:0]     tag_list  [`FL_SZ-1:0];
  wire  [`TAG_SZ-1:0]     tag_list_in  [`FL_SZ-1:0];
  wire  [`FL_SZ-1:0]      tag_list_ld;
  wire  [`FL_PTR_SZ-1:0]  head_ptr;
  wire  [`FL_PTR_SZ-1:0]  head_ptr_p1;
  wire  [`FL_PTR_SZ-1:0]  head_ptr_p2;
  wire  [`FL_PTR_SZ-1:0]  head_ptr_in;
  wire  [`FL_PTR_SZ-1:0]  tail_ptr;
  wire  [`FL_PTR_SZ-1:0]  tail_ptr_p1;
  wire  [`FL_PTR_SZ-1:0]  tail_ptr_in;
  wire                    pop;
  wire                    push;
  wire  [`FL_PTR_SZ-1:0]  rob_ds_fl_head_ptr_p1;
  wire  [`TAG_SZ-1:0]     ds1_dest_tag_in;
  wire  [`FL_PTR_SZ-1:0]  ds1_fl_head_ptr_in;
  integer                 i;

  // Handle output generation
  // For timing, make dest_tag and fl_head_ptr available from a flop.
  // TODO: verify corner cases such as free list becomes empty (so next head_ptr is tail_ptr) and instruction retiring.
  assign ds1_dest_tag_in    = rob_pipe_flush                    ? tag_list[rob_ds_fl_head_ptr] : 
                              //(head_ptr_p1 == tail_ptr) & push  ? rob_ds_ret_tag_old : 
                                                                  tag_list[head_ptr_p1];    // ds1_dest_wr case

  assign rob_ds_fl_head_ptr_p1 = (rob_ds_fl_head_ptr == `FL_SZ-1) ? {`FL_PTR_SZ{1'b0}} : rob_ds_fl_head_ptr + `FL_PTR_SZ'h1;
  assign ds1_fl_head_ptr_in = rob_pipe_flush ? rob_ds_fl_head_ptr_p1 : head_ptr_p2;

  MDFFLR #(`TAG_SZ)    ds1_dest_tag_ff    (clk, rst, pop | rob_pipe_flush, `ARCH_REGS, ds1_dest_tag_in, ds1_dest_tag);
  MDFFLR #(`FL_PTR_SZ) ds1_fl_head_ptr_ff (clk, rst, pop | rob_pipe_flush, `ARCH_REGS+1, ds1_fl_head_ptr_in, ds1_fl_head_ptr);
  

  // Handle updating head/tail pointers
  assign pop          = ds1_dest_wr;
  assign push         = rob_ds_ret_valid & rob_ds_ret_dest_write;
  assign head_ptr_p1  = (head_ptr == `FL_SZ-1) ? {`FL_PTR_SZ{1'b0}} : head_ptr + `FL_PTR_SZ'h1;
  assign head_ptr_p2  = (head_ptr == `FL_SZ-2) ? {`FL_PTR_SZ{1'b0}} : head_ptr + `FL_PTR_SZ'h2;
  assign tail_ptr_p1  = (tail_ptr == `FL_SZ-1) ? {`FL_PTR_SZ{1'b0}} : tail_ptr + `FL_PTR_SZ'h1;
  assign head_ptr_in  = (rob_pipe_flush) ? rob_ds_fl_head_ptr : head_ptr_p1;
  assign tail_ptr_in  = tail_ptr_p1;

  // Initialize head pointer to NUM_ARCH_REGS because architected registers will
  // be allocated out of reset. 
  MDFFLR #(`FL_PTR_SZ) head_ptr_ff (clk, rst, pop | rob_pipe_flush, `ARCH_REGS, head_ptr_in, head_ptr);
  MDFFLR #(`FL_PTR_SZ) tail_ptr_ff (clk, rst, push, {`FL_PTR_SZ{1'b0}}, tail_ptr_in, tail_ptr);

  // Handle updating list
  // Reset list so that physical registers beyond 33 are initialized into free list
  assign tag_list_ld  = (push << tail_ptr);
  genvar g;
  generate
    for (g=0; g<`FL_SZ; g=g+1) begin: fl_gen
      assign tag_list_in[g] = rob_ds_ret_tag_old;
      if (g < `ARCH_REGS)
        MDFFLR #(`TAG_SZ) tag_list_ff (clk, rst, tag_list_ld[g], `TAG_SZ'h0, tag_list_in[g], tag_list[g]);
      else
        MDFFLR #(`TAG_SZ) tag_list_ff (clk, rst, tag_list_ld[g], g[`TAG_SZ-1:0], tag_list_in[g], tag_list[g]);
    end
  endgenerate

endmodule
