//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 

// RAM with 1 synchronous write port and one async read port

module ram_1r_1w (/*AUTOARG*/
  // Outputs
  rd_data, 
  // Inputs
  clk, wr_addr, wr_en, wr_data, rd_addr
  );

  parameter  width = 8;
  parameter  depth = 128;
  parameter  addr_sz = 7;

  input               clk;
  input [addr_sz-1:0] wr_addr;
  input               wr_en;
  input [width-1:0]   wr_data;

  input [addr_sz-1:0] rd_addr;
  output [width-1:0]  rd_data;

  reg [width-1:0]     mem [0:depth-1];

  always @(posedge clk)
    begin
      if (wr_en)
        mem[wr_addr] <= #1 wr_data;
    end

  assign rd_data = mem[rd_addr];

endmodule // ram_1r_1w

  