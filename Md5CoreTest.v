/*
Copyright (C) 2014 John Leitch (johnleitch@outlook.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
`timescale 1ns / 1ns

`include "Md5CoreTestMacros.v"

module Md5CoreTest;

reg clk, reset, test_all;
wire [31:0] a, b, c, d;
reg [31:0] count = 0;
reg [511:0] chunk;

Md5Core m (
  .clk(clk), 
  .wb(chunk), 
  .a0('h67452301), 
  .b0('hefcdab89), 
  .c0('h98badcfe), 
  .d0('h10325476), 
  .a64(a), 
  .b64(b), 
  .c64(c), 
  .d64(d)
);

initial
  begin
    clk = 0;
    forever #10 clk = !clk;
  end
  
initial
  begin
    reset = 0;
    #5 reset = 1;
    #4 reset = 0;
  end
 
`include "Md5CoreTestCases.v"
    
always @(posedge clk) count <= count + 1;
always @(posedge clk) if (count == `DoneCount) test_all <= `TestAllExp;
    
endmodule  

 

