//////////////////////////////////////////////////////////////////
//                                                              //
//  OoOPs Core Register Map Table testbench                     //
//                                                              //
//  This file is part of the OoOPs project                      //
//  http://www.opencores.org/project,oops                       //
//                                                              //
//  Description:                                                //
//  Small, self-contained testbench for basic functionality of  //
//  the Map Table.                                              //
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

module test_map_table;

  // I/O to Map Table DUT
  reg                       clk;
  reg                       rst;
  reg                       ds1_valid;
  reg   [`REG_IDX_SZ-1:0]   ds1_src1_idx;
  reg   [`REG_IDX_SZ-1:0]   ds1_src2_idx;
  reg   [`REG_IDX_SZ-1:0]   ds1_dest_idx;
  reg                       ds1_dest_wr;
  reg                       ds1_type_br;
  reg                       rob_pipe_flush;
  reg                       rob_ds_ret_valid;
  reg                       rob_ds_ret_dest_write;
  reg   [`CHKPT_PTR_SZ-1:0] rob_ds_chkpt_ptr;
  reg   [`FL_PTR_SZ-1:0]    rob_ds_fl_head_ptr;
  reg                       rob_ds_ret_chkpt_free;
  reg   [`REG_IDX_SZ-1:0]   rob_ds_ret_idx;
  reg   [`TAG_SZ-1:0]       rob_ds_ret_tag;
  reg   [`TAG_SZ-1:0]       rob_ds_ret_tag_old;
  
  wire                      map_table_init;
  wire  [`TAG_SZ-1:0]       ds2_src1_tag;
  wire  [`TAG_SZ-1:0]       ds2_src2_tag;
  wire                      ds2_src1_valid;
  wire                      ds2_src2_valid;
  wire  [`TAG_SZ-1:0]       ds2_dest_tag;
  wire  [`TAG_SZ-1:0]       ds2_dest_tag_old;
  wire  [`FL_PTR_SZ-1:0]    ds2_fl_head_ptr;
  wire  [`CHKPT_PTR_SZ-1:0] ds2_chkpt_ptr;


  // Instantiate DUT
  map_table m0 (
    .clk(clk),
    .rst(rst),
    .map_table_init(map_table_init),

    .ds1_valid(ds1_valid),
    .ds1_src1_idx(ds1_src1_idx),
    .ds1_src2_idx(ds1_src2_idx),
    .ds1_dest_idx(ds1_dest_idx),
    .ds1_dest_wr(ds1_dest_wr),
    .ds1_type_br(ds1_type_br),
    .ds2_src1_tag(ds2_src1_tag),
    .ds2_src2_tag(ds2_src2_tag),
    .ds2_src1_valid(ds2_src1_valid),
    .ds2_src2_valid(ds2_src2_valid),
    .ds2_dest_tag(ds2_dest_tag),
    .ds2_dest_tag_old(ds2_dest_tag_old),
    .ds2_fl_head_ptr(ds2_fl_head_ptr),
    .ds2_chkpt_ptr(ds2_chkpt_ptr),

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


  // generate clk
  always begin
    #5;
    clk = ~clk;
  end

  initial begin
    // Initialize clk and inputs
    clk = 1'b0;
    rst = 1'b1;

    ds1_valid               = 0;
    ds1_src1_idx            = 0;  
    ds1_src2_idx            = 0;  
    ds1_dest_idx            = 0;  
    ds1_dest_wr             = 1'b0;
    ds1_type_br             = 1'b0;
    rob_pipe_flush          = 1'b0;
    rob_ds_ret_valid        = 1'b0;
    rob_ds_ret_dest_write   = 1'b0;
    rob_ds_chkpt_ptr        = 0;
    rob_ds_fl_head_ptr      = 0;
    rob_ds_ret_chkpt_free   = 0;
    rob_ds_ret_idx          = 0;
    rob_ds_ret_tag          = 0;
    rob_ds_ret_tag_old      = 0;

    // Set up waveform dump
    `ifdef WAVE_DUMP
    $dumpfile("wave.vcd");
    $dumpvars(0,test_map_table);
    `endif

    // Assert reset for a couple clks
    $display("Asserting reset..."); 
    repeat (3) @(negedge clk);
    rst = 1'b0;
    $display("Reset done.");

    // Wait for initialization to be done
    while (map_table_init)
      @(negedge clk);

    // Rename one instruction
    set_rename_inputs(1, 2, 3, 1'b1, 1'b0); // Read r1, r2; write r3; not branch
    @(negedge clk);
    clear_rename_inputs;

    // Check output src and dest tags
    if ((ds2_src1_tag != 'd1) || (ds2_src2_tag != 'd2) || (ds2_dest_tag != 'd34))
      fail('d1);

    // Rename a second dependent instruction
    set_rename_inputs(1, 3, 4, 1'b1, 1'b0); // Read r1, r3; write r4; not branch
    @(negedge clk);
    clear_rename_inputs;

    // Check output src and dest tags
    if ((ds2_src1_tag != 'd1) || (ds2_src2_tag != 'd34) || (ds2_dest_tag != 'd35))
      fail('d2);
    

    // Rename a branch which does not write a register to allocate new checkpoint
    set_rename_inputs(3, 4, 4, 1'b0, 1'b1); // Read r3, r4; no write;  is branch
    @(negedge clk);
    clear_rename_inputs;
    
    // Check output src tags and checkpoint ptr
    if ((ds2_src1_tag != 'd34) || (ds2_src2_tag != 'd35) || (ds2_dest_tag != 'd36) ||
        (ds2_chkpt_ptr != 'd0))
      fail('d3);
    
  
    // Rename two more instructions to overwrite r3 and r4, then recover from checkpoint
    set_rename_inputs(1, 2, 3, 1'b1, 1'b0); // Read r1, r2; write r3; not branch
    @(negedge clk);
    // Check tag and chkpt_ptr outputs
    if ((ds2_src1_tag != 'd1) || (ds2_src2_tag != 'd2) || (ds2_dest_tag != 'd36) || (ds2_dest_tag_old != 'd34) || (ds2_chkpt_ptr != 'd1))
      fail('d4);

    set_rename_inputs(1, 3, 4, 1'b1, 1'b0); // Read r1, r3; write r4; not branch
    @(negedge clk);
    clear_rename_inputs;
    // Check tag and chkpt_ptr outputs
    if ((ds2_src1_tag != 'd1) || (ds2_src2_tag != 'd36) || (ds2_dest_tag_old != 'd35) || (ds2_chkpt_ptr != 'd1))
      fail('d5);
    
    // Retire in-flight instructions, then recover checkpoint from branch misprediction
    set_retire_inputs(1'b0, 1'b1, 1'b0, 0, 'd35, 'd3, 'd34, 'd3);
    @(negedge clk);
    set_retire_inputs(1'b0, 1'b1, 1'b0, 0, 'd36, 'd4, 'd35, 'd4);
    @(negedge clk);
    set_retire_inputs(1'b1, 1'b0, 1'b0, 0, 'd37, 'd4, 'd36, 'd35); // Branch flush, don't free checkpoint
    @(negedge clk);
    clear_retire_inputs;

    // Now rename instruction that reads r3 and r4
    set_rename_inputs(3, 4, 4, 1'b1, 1'b0); // Read r3, r4; write r4; not branch
    @(negedge clk);
    clear_rename_inputs;
    // Check output tags and chkpt_ptr
    if ((ds2_src1_tag != 'd34) || (ds2_src2_tag != 'd35) || (ds2_dest_tag != 'd37) || (ds2_dest_tag_old != 'd35) || (ds2_chkpt_ptr != 'd0))
      fail('d6);
    
    

    // Let clock run for a few cycles before finishing
    repeat (5) @(negedge clk);
    $display("Finished!");
    $finish;
  end


  // Task to easily set all rename inputs
  task set_rename_inputs;
    input [`REG_IDX_SZ-1:0] src1_idx, src2_idx, dest_idx;
    input                   dest_wr;
    input                   type_br;

    begin
      ds1_valid     = 1'b1;
      ds1_src1_idx  = src1_idx;
      ds1_src2_idx  = src2_idx;
      ds1_dest_idx  = dest_idx;
      ds1_dest_wr   = dest_wr;
      ds1_type_br   = type_br;
    end
  endtask

  task clear_rename_inputs;
    begin
      ds1_valid     = 1'b0;
      ds1_src1_idx  = 0;
      ds1_src2_idx  = 0;
      ds1_dest_wr   = 1'b0;
      ds1_type_br   = 1'b0;
    end
  endtask

  task set_retire_inputs;
    input                     pipe_flush, dest_write, chkpt_free;
    input [`CHKPT_PTR_SZ-1:0] chkpt_ptr;
    input [`FL_PTR_SZ-1:0]    fl_head_ptr;
    input [`REG_IDX_SZ-1:0]   dest_idx;
    input [`TAG_SZ-1:0]       dest_tag, dest_tag_old;

    begin
      rob_ds_ret_valid        = 1'b1;
      rob_pipe_flush          = pipe_flush;
      rob_ds_ret_dest_write   = dest_write;
      rob_ds_ret_chkpt_free   = chkpt_free;
      rob_ds_chkpt_ptr        = chkpt_ptr;
      rob_ds_fl_head_ptr      = fl_head_ptr;
      rob_ds_ret_idx          = dest_idx;
      rob_ds_ret_tag          = dest_tag;
      rob_ds_ret_tag_old      = dest_tag_old;
    end
  endtask

  task clear_retire_inputs;
    begin
      rob_ds_ret_valid        = 1'b0;
      rob_pipe_flush          = 1'b0;
      rob_ds_ret_dest_write   = 1'b0;
      rob_ds_ret_chkpt_free   = 1'b0;
      rob_ds_chkpt_ptr        = 0;
      rob_ds_fl_head_ptr      = 0;
      rob_ds_ret_idx          = 0;
      rob_ds_ret_tag          = 0;
      rob_ds_ret_tag_old      = 0;
    end
  endtask

  task fail;
    input integer test_num;
    begin
      $display("ERROR: Failed on test %0d at time %0d", test_num, $time);
      repeat(3) @(negedge clk);
      $finish;
    end
  endtask
endmodule
