/*
 *  Copyright (c) 2008  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`timescale 1ns/10ps

`include "defines.v"

module regfile (
`ifdef DEBUG
    output [15:0] ax,
    output [15:0] dx,
    output [15:0] bp,
    output [15:0] si,
    output [15:0] es,
`endif

    output [15:0] a,
    output [15:0] b,
    output [15:0] c,
    output [15:0] cs,
    output [15:0] ip,
    input  [31:0] d,
    output [15:0] s,

    output reg [8:0] flags,

    input         wr,
    input         wrfl,
    input         wrhi,
    input         clk,
    input         rst,
    input  [ 3:0] addr_a,
    input  [ 3:0] addr_b,
    input  [ 3:0] addr_c,
    input  [ 3:0] addr_d,
    input  [ 1:0] addr_s,
    input  [ 8:0] iflags,
    input         word_op,
    input         a_byte,
    input         b_byte,
    input         c_byte,
    output        cx_zero,
    input         wr_ip0
  );

  // Net declarations
  reg [15:0] r[15:0];
  wire [7:0] a8, b8, c8;

  // Assignments
`ifdef DEBUG
  assign ax = r[0];
  assign dx = r[2];
  assign bp = r[5];
  assign si = r[6];
  assign es = r[8];
`endif
  assign a = (a_byte & ~addr_a[3]) ? { {8{a8[7]}}, a8} : r[addr_a];
  assign a8 = addr_a[2] ? r[addr_a[1:0]][15:8] : r[addr_a][7:0];

  assign b = (b_byte & ~addr_b[3]) ? { {8{b8[7]}}, b8} : r[addr_b];
  assign b8 = addr_b[2] ? r[addr_b[1:0]][15:8] : r[addr_b][7:0];

  assign c = (c_byte & ~addr_c[3]) ? { {8{c8[7]}}, c8} : r[addr_c];
  assign c8 = addr_c[2] ? r[addr_c[1:0]][15:8] : r[addr_c][7:0];

  assign s = r[{2'b10,addr_s}];

  assign cs = r[9];
  assign cx_zero = (addr_d==4'd1) ? (d==16'd0) : (r[1]==16'd0);

  assign ip = r[15];

  // Behaviour
  always @(posedge clk)
    if (rst) begin
      r[0]  <= 16'd0; r[1]  <= 16'd0;
      r[2]  <= 16'd0; r[3]  <= 16'd0;
      r[4]  <= 16'd0; r[5]  <= 16'd0;
      r[6]  <= 16'd0; r[7]  <= 16'd0;
      r[8]  <= 16'd0; r[9]  <= 16'hf000;
      r[10] <= 16'd0; r[11] <= 16'd0;
      r[12] <= 16'd0; r[13] <= 16'd0;
      r[14] <= 16'd0; r[15] <= 16'hfff0;
      flags <= 9'd0;
    end else
      begin
        if (wr) begin
          if (word_op | addr_d[3:2]==2'b10)
             r[addr_d] <= word_op ? d[15:0] : {{8{d[7]}},d[7:0]};
          else if (addr_d[3]~^addr_d[2]) r[addr_d][7:0] <= d[7:0];
          else r[{2'b0,addr_d[1:0]}][15:8] <= d[7:0];
        end
        if (wrfl) flags <= iflags;
        if (wrhi) r[4'd2] <= d[31:16];
        if (wr_ip0) r[14] <= ip;
      end
endmodule