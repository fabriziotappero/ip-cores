// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: timing_adapter_fifo_32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/timing_adapter_fifo_32.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : (Simulation only)
//
// Timing adapter FIFO  
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

//  --------------------------------------------------------------------------------
// | simple_atlantic_fifo
//  --------------------------------------------------------------------------------

`timescale 1ns / 1ps
module timing_adapter_fifo_32 (
      output reg [ 3: 0] fill_level ,
    
      // Interface: clock
      input              clk,
      input              reset,
      // Interface: data_in
      output reg         in_ready,
      input              in_valid,
      input      [36: 0] in_data,
      // Interface: data_out
      input              out_ready,
      output reg         out_valid,
      output reg [36: 0] out_data
);

   // ---------------------------------------------------------------------
   //| Internal Parameters
   // ---------------------------------------------------------------------
   parameter DEPTH = 8;
   parameter DATA_WIDTH = 37;
   parameter ADDR_WIDTH = 3;
           
   // ---------------------------------------------------------------------
   //| Signals
   // ---------------------------------------------------------------------
   reg [ADDR_WIDTH-1:0] wr_addr;
   reg [ADDR_WIDTH-1:0] rd_addr;
   reg [ADDR_WIDTH-1:0] next_wr_addr;
   reg [ADDR_WIDTH-1:0] next_rd_addr;
   reg [ADDR_WIDTH-1:0] mem_rd_addr;
   reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];
   reg empty;
   reg full;
   reg out_ready_vector;
   
   // ---------------------------------------------------------------------
   //| FIFO Status
   // ---------------------------------------------------------------------
   always @(out_ready or wr_addr or rd_addr or full) 
   begin
//      out_valid = !empty;
      out_ready_vector = out_ready;
      in_ready  = !full;
      next_wr_addr = wr_addr + 1;
      next_rd_addr = rd_addr + 1;
      fill_level[ADDR_WIDTH-1:0] = wr_addr - rd_addr;
      fill_level[ADDR_WIDTH] = 0;

      if (full)
           fill_level = DEPTH;

   end
   
   // ---------------------------------------------------------------------
   //| Manage Pointers
   // ---------------------------------------------------------------------
   always @ (posedge reset or posedge clk) 
   begin
      if (reset) 
        begin
             wr_addr  <= 0;
             rd_addr  <= 0;
             empty    <= 1;
             rd_addr  <= 0;
             full     <= 0;
             out_valid<= 0;
        end 
      else 
       begin
         out_valid <= !empty;
         if (in_ready && in_valid) 
          begin
            wr_addr <= next_wr_addr;
            empty   <= 0;
            if (next_wr_addr == rd_addr)
              full <= 1;
          end
         
         if (out_ready_vector && out_valid) 
          begin
            rd_addr <= next_rd_addr;
            full    <= 0;
            if (next_rd_addr == wr_addr) 
             begin
               empty <= 1;
               out_valid <= 0;
             end
          end
         
         if (out_ready_vector && out_valid && in_ready && in_valid) 
          begin
            full  <= full;
            empty <= empty;
          end
       end
   end // always @ (posedge reset, posedge clk)
   

   always @ (rd_addr or out_ready or out_valid or next_rd_addr) 
   begin
      mem_rd_addr = rd_addr;
      if (out_ready && out_valid) 
      begin
        mem_rd_addr = next_rd_addr;
      end
   end
   

   // ---------------------------------------------------------------------
   //| Infer Memory
   // ---------------------------------------------------------------------
   always @ (posedge reset or posedge clk) 
   begin
      if (reset)
        mem[0] <= 38'h0;
      else
       begin 
           if (in_ready && in_valid)
            mem[wr_addr] <= in_data;
       end
      out_data = mem[mem_rd_addr];
   end
   
endmodule // 



