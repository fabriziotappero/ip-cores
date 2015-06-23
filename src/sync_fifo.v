// -*- mode: Verilog; verilog-auto-lineup-declaration: nil; -*-
//-----------------------------------------------------------------------------
// Title         : Synchronous FIFO
// Project       : Common
//-----------------------------------------------------------------------------
// File          : sync_fifo.v
//-----------------------------------------------------------------------------
// Description : Synchronous FIFO using BRAM.
//
// Implements a variable width/depth synchronous FIFO. The synthesis
// tool may choose to implement the memory as a block RAM.
//-----------------------------------------------------------------------------
// Copyright 1994-2009 Beyond Circuits. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//   1. Redistributions of source code must retain the above copyright notice, 
//      this list of conditions and the following disclaimer.
//   2. Redistributions in binary form must reproduce the above copyright notice, 
//      this list of conditions and the following disclaimer in the documentation 
//      and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE BEYOND CIRCUITS ``AS IS'' AND ANY EXPRESS OR 
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
// SHALL BEYOND CIRCUITS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY 
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//------------------------------------------------------------------------------

`timescale 1ns/1ns
module sync_fifo
  #(
    parameter depth = 32,
    parameter width = 32,
    // Need the log of the parameters as parameters also due to an XST bug.
    parameter log2_depth = log2(depth),
    parameter log2_depthp1 = log2(depth+1)
    )
  (
   input clk,
   input reset,
   input wr_enable,
   input rd_enable,
   output reg empty,
   output reg full,
   output [width-1:0] rd_data,
   input [width-1:0] wr_data,
   output reg [log2_depthp1-1:0] count
   );

  // log2 -- return the log base 2 of value.
  function integer log2;
    input [31:0] value;
    begin
      value = value-1;
      for (log2=0; value>0; log2=log2+1)
	value = value>>1;
    end
  endfunction

  // increment -- add one to value modulo depth.
  function [log2_depth-1:0] increment;
    input [log2_depth-1:0] value;
    begin
      if (value == depth-1)
	increment = 0;
      else
	increment = value+1;
    end
  endfunction

  // writing -- true when we write to the RAM.
  wire writing = wr_enable && (rd_enable || !full);

  // reading -- true when we are reading from the RAM.
  wire reading = rd_enable && !empty;

  // rd_ptr -- the read pointer.
  reg [log2_depth-1:0] rd_ptr;

  // next_rd_ptr -- the next value for the read pointer.
  // We need to name this combinational value because it
  // is needed to use the write-before-read style RAM.
  reg [log2_depth-1:0] next_rd_ptr;
  always @(*)
    if (reset)
      next_rd_ptr = 0;
    else if (reading)
      next_rd_ptr = increment(rd_ptr);
    else
      next_rd_ptr = rd_ptr;

  always @(posedge clk)
    rd_ptr <= next_rd_ptr;

  // wr_ptr -- the write pointer
  reg [log2_depth-1:0] wr_ptr;

  // next_wr_ptr -- the next value for the write pointer.
  reg [log2_depth-1:0] next_wr_ptr;
  always @(*)
    if (reset)
      next_wr_ptr = 0;
    else if (writing)
      next_wr_ptr = increment(wr_ptr);
    else
      next_wr_ptr = wr_ptr;

  always @(posedge clk)
    wr_ptr <= next_wr_ptr;
      
  // count -- the number of valid entries in the FIFO.
  always @(posedge clk)
    if (reset)
      count <= 0;
    else if (writing && !reading)
      count <= count+1;
    else if (reading && !writing)
      count <= count-1;

  // empty -- true if the FIFO is empty.
  // Note that this doesn't depend on count so if the count
  // output is unused the logic for computing the count can
  // be optimized away.
  always @(posedge clk)
    if (reset)
      empty <= 1;
    else if (reading && next_wr_ptr == next_rd_ptr && !full)
      empty <= 1;
    else
      if (writing && !reading)
	empty <= 0;
  
  // full -- true if the FIFO is full.
  // Again, this is not dependent on count.
  always @(posedge clk)
    if (reset)
      full <= 0;
    else if (writing && next_wr_ptr == next_rd_ptr)
      full <= 1;
    else if (reading && !writing)
      full <= 0;
  
  // We need to infer a write first style RAM so that when 
  // the FIFO is empty the write data can flow through to
  // the read side and be available the next clock cycle.
  reg [width-1:0] mem [depth-1:0];
  always @(posedge clk)
    begin
      if (writing)
	mem[wr_ptr] <= wr_data;
      rd_ptr <= next_rd_ptr;
    end

  assign rd_data = mem[rd_ptr];

endmodule
