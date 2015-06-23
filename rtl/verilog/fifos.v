//////////////////////////////////////////////////////////////////////
////                                                              ////
////  fifos.v                                                     ////
////                                                              ////
////                                                              ////
////  This file is part of the Wiegand Protocol Controller        ////
////  http://www.opencores.org/projects/wiegand/                  ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Jeff Anderson                                          ////
////       jeaander@opencores.org                                 ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
//  Revisions at end of file
//
 
// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "wiegand_defines.v"

//pulling in data bus width from WIEGAND_defines file
`ifdef WIEGAND_WIDTH64
  `define WIEGAND_FIFODATAWIDTH 64
`elsif WIEGAND_WIDTH32
  `define WIEGAND_FIFODATAWIDTH 32
`elsif WIEGAND_WIDTH16
  `define WIEGAND_FIFODATAWIDTH 16
`else
  `define WIEGAND_FIFODATAWIDTH 8
`endif

//define depth of FIFO; pulling in depth from WIEGAND_defines
//`define WIEGAND_FIFODEPTH 16
  
//uncomment a single implementation of FIFO; pulling in implementation from WIEGAND_defines
//`define WIEGAND_CUSTOMFIFO

module fifo_wieg
( 
  clk_rd,
  clk_wr,
  d_i,
  d_o,
  rst,
  wr_en,
  rd_en,
  full,
  empty
);
  input clk_rd;
  input clk_wr;
  input [`WIEGAND_FIFODATAWIDTH-1:0] d_i;
  output [`WIEGAND_FIFODATAWIDTH-1:0] d_o;
  input rst;
  input wr_en;
  input rd_en;
  output full;
  output empty;
  
`ifdef WIEGAND_CUSTOMFIFO
  `ifdef WIEGAND_WIDTH64
    wire [7:0] full_int;
    wire [7:0] empty_int;
    assign full = |full_int;
    assign empty = |empty_int;
    custom_fifo_dp custom_fifo_dp1(clk_rd,clk_wr,d_i[63:56],d_o[63:56],rst,wr_en,rd_en,full_int[0],empty_int[0]);
    custom_fifo_dp custom_fifo_dp2(clk_rd,clk_wr,d_i[55:48],d_o[55:48],rst,wr_en,rd_en,full_int[1],empty_int[1]);
    custom_fifo_dp custom_fifo_dp3(clk_rd,clk_wr,d_i[47:40],d_o[47:40],rst,wr_en,rd_en,full_int[2],empty_int[2]);
    custom_fifo_dp custom_fifo_dp4(clk_rd,clk_wr,d_i[39:32],d_o[39:32],rst,wr_en,rd_en,full_int[3],empty_int[3]);
    custom_fifo_dp custom_fifo_dp5(clk_rd,clk_wr,d_i[31:24],d_o[31:24],rst,wr_en,rd_en,full_int[4],empty_int[4]);
    custom_fifo_dp custom_fifo_dp6(clk_rd,clk_wr,d_i[23:16],d_o[23:16],rst,wr_en,rd_en,full_int[5],empty_int[5]);
    custom_fifo_dp custom_fifo_dp7(clk_rd,clk_wr,d_i[15:8],d_o[15:8],rst,wr_en,rd_en,full_int[6],empty_int[6]);
    custom_fifo_dp custom_fifo_dp8(clk_rd,clk_wr,d_i[7:0],d_o[7:0],rst,wr_en,rd_en,full_int[7],empty_int[7]);
  `elsif WIEGAND_WIDTH32
    wire [3:0] full_int;
    wire [3:0] empty_int;
    assign full = |full_int;
    assign empty = |empty_int;
    custom_fifo_dp custom_fifo_dp5(clk_rd,clk_wr,d_i[31:24],d_o[31:24],rst,wr_en,rd_en,full_int[0],empty_int[0]);
    custom_fifo_dp custom_fifo_dp6(clk_rd,clk_wr,d_i[23:16],d_o[23:16],rst,wr_en,rd_en,full_int[1],empty_int[1]);
    custom_fifo_dp custom_fifo_dp7(clk_rd,clk_wr,d_i[15:8],d_o[15:8],rst,wr_en,rd_en,full_int[2],empty_int[2]);
    custom_fifo_dp custom_fifo_dp8(clk_rd,clk_wr,d_i[7:0],d_o[7:0],rst,wr_en,rd_en,full_int[3],empty_int[3]);
  `elsif WIEGAND_WIDTH16
    wire [1:0] full_int;
    wire [1:0] empty_int;
    assign full = |full_int;
    assign empty = |empty_int;
    custom_fifo_dp custom_fifo_dp7(clk_rd,clk_wr,d_i[15:8],d_o[15:8],rst,wr_en,rd_en,full_int[0],empty_int[0]);
    custom_fifo_dp custom_fifo_dp8(clk_rd,clk_wr,d_i[7:0],d_o[7:0],rst,wr_en,rd_en,full_int[1],empty_int[1]);
  `else
    custom_fifo_dp custom_fifo_dp8(clk_rd,clk_wr,d_i[7:0],d_o[7:0],rst,wr_en,rd_en,full,empty);
  `endif
`endif 
 
endmodule

module custom_fifo_dp (
  clk_rd,
  clk_wr,
  d_i,
  d_o,
  rst,
  wr_en,
  rd_en,
  full,
  empty
);
  input clk_rd;
  input clk_wr;
  input [7:0] d_i;
  output [7:0] d_o;
  input rst;
  input wr_en;
  input rd_en;
  output full;
  output empty;
  
  reg [`WIEGAND_FIFODEPTH-1:0] addr_rd;
  reg [`WIEGAND_FIFODEPTH-1:0] addr_wr;
  reg [7:0] fifo_out;
  wire [7:0] mem_byte_out;
  wire [`WIEGAND_FIFODEPTH-1:0] full_int;
  
  //bytewide memory array in FIFO.  user sets depth.
  genvar c;
  generate
    for (c = 0; c < `WIEGAND_FIFODEPTH; c = c + 1) begin: mem
      mem_byte mem_byte(rst,clk_wr,d_i,mem_byte_out,addr_wr[c],addr_rd[c]);
    end
  endgenerate
  
  //read logic needed here to handle clock domain change
  assign d_o = fifo_out;
  always @(posedge clk_rd or posedge rst) begin
    if (rst)  fifo_out <= 8'h0;
    else      fifo_out <= mem_byte_out;
  end
  
  //addressing logic is simply a circular shift register that gets reset to 1
  always @(posedge clk_wr or posedge rst) begin
    if (rst)  addr_wr <= `WIEGAND_FIFODEPTH'h1;
    else if (wr_en&(~full)) begin
      addr_wr[`WIEGAND_FIFODEPTH-1:1] <= addr_wr[`WIEGAND_FIFODEPTH-2:0];
      addr_wr[0] <= addr_wr[`WIEGAND_FIFODEPTH-1];
    end
  end
  
  always @(posedge clk_rd or posedge rst) begin
    if (rst)  addr_rd <= `WIEGAND_FIFODEPTH'h1;
    else if (rd_en&(~empty)) begin
      addr_rd[`WIEGAND_FIFODEPTH-1:1] <= addr_rd[`WIEGAND_FIFODEPTH-2:0];
      addr_rd[0] <= addr_rd[`WIEGAND_FIFODEPTH-1];
    end
  end
  
  //use address logic for flags
  assign empty = (addr_wr == addr_rd);              //when read addr catches write addr, we're empty
  
  assign full = empty?1'b0:|full_int;              //if fifo isn't empty, then OR all full flag outputs
 
  assign full_int[0] = (addr_wr[`WIEGAND_FIFODEPTH-1] & addr_rd[0]);  //when we've written to entire mem, we're full
  genvar d;
  generate
    for (d = 1; d < `WIEGAND_FIFODEPTH; d = d + 1) begin: flag
      assign full_int[d] = (addr_wr[d-1] & addr_rd[d]);   //when we've written to entire mem, we're full
    end
  endgenerate
  
endmodule

module mem_byte(
  rst,
  clk,
  din,
  dout,
  wen,
  ren
);

  input rst;
  input clk;
  input[7:0] din;
  output [7:0] dout;
  input wen;
  input ren;
  
  reg[7:0] byte_reg;
  
  //just a byte-wide register with input and output enables
  assign dout = ren?byte_reg:8'bz;
  
  always @(posedge clk or posedge rst) begin
    if (rst)        byte_reg <= 8'h0;
    else if (wen)   byte_reg <= din;
  end
  
endmodule

//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: $
//