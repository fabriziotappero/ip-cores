/*
 * wb_slv_wrapper.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module wb_slv_wrapper (
  // wishbone side
  input         rst_i,clk_i,
  input         stb_i,we_i,
  output        ack_o,
  input  [31:0] adr_i,  // in byte
  input  [31:0] dat_i,
  output [31:0] dat_o,
  // localbus side
  output        rst,clk,
  output        wr_out,rd_out,
  output [ 7:0] addr_out,  // in byte
  output [31:0] data_out,
  input  [31:0] data_in
);

reg  stb_i_d1;
wire stb_internal = stb_i && !stb_i_d1;
reg  ack_internal;

// localbus output
always @(posedge rst_i or posedge clk_i) begin
  if (rst_i)
    stb_i_d1 <= 1'b0;
  else if (ack_internal)
    stb_i_d1 <= 1'b0;
  else
    stb_i_d1 <= stb_i;
end

assign {rst, clk}     = {rst_i, clk_i};
assign wr_out         = stb_internal &&  we_i;
assign rd_out         = stb_internal && !we_i;
assign addr_out[ 7:0] = adr_i[ 7:0];
assign data_out[31:0] = dat_i[31:0];

// wishbone output
always @(posedge rst_i or posedge clk_i) begin
  if (rst_i)
    ack_internal <= 1'b0;
  else if (ack_internal)
    ack_internal <= 1'b0;
  else if (stb_i)
    ack_internal <= 1'b1;
  else
    ack_internal <= ack_internal;
end

assign ack_o       = ack_internal;
assign dat_o[31:0] = data_in[31:0];

endmodule
