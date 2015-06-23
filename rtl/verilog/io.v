//////////////////////////////////////////////////////////////////////
////                                                              ////
////  IO functions                                                ////
////                                                              ////
////  Description                                                 ////
////  IO functions such as IOB flip-flops                         ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
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
//////////////////////////////////////////////////////////////////////
`ifdef O_DFF
`timescale 1ns/1ns
`define MODULE o_dff
module `BASE`MODULE (d_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
parameter reset_value = {width{1'b0}};
input  [width-1:0]  d_i;
output [width-1:0] o_pad;
input clk, rst;
wire [width-1:0] d_i_int `SYN_KEEP;
reg  [width-1:0] o_pad_int;
assign d_i_int = d_i;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : dffs
    always @ (posedge clk or posedge rst)
    if (rst)
        o_pad_int[i] <= reset_value[i];
    else
        o_pad_int[i] <= d_i_int[i];
    assign #1 o_pad[i] = o_pad_int[i];
end
endgenerate
endmodule
`endif

`ifdef IO_DFF_OE
`timescale 1ns/1ns
`define MODULE io_dff_oe
module `BASE`MODULE ( d_i, d_o, oe, io_pad, clk, rst);
`undef MODULE
parameter width = 1;
parameter reset_value = 1'b0;
input  [width-1:0] d_o;
output reg [width-1:0] d_i;
input oe;
inout [width-1:0] io_pad;
input clk, rst;
wire [width-1:0] oe_d `SYN_KEEP;
reg [width-1:0] oe_q;
reg [width-1:0] d_o_q;
assign oe_d = {width{oe}};
genvar i;
generate
for (i=0;i<width;i=i+1) begin : dffs
    always @ (posedge clk or posedge rst)
    if (rst)
        oe_q[i] <= 1'b0;
    else
        oe_q[i] <= oe_d[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        d_o_q[i] <= reset_value;
    else
        d_o_q[i] <= d_o[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        d_i[i] <= reset_value;
    else
        d_i[i] <= io_pad[i];
    assign #1 io_pad[i] = (oe_q[i]) ? d_o_q[i] : 1'bz;
end
endgenerate
endmodule
`endif

`ifdef O_DDR
`ifdef ALTERA
`define MODULE o_ddr
module `BASE`MODULE (d_h_i, d_l_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
input  [width-1:0] d_h_i, d_l_i;
output [width-1:0] o_pad;
input clk, rst;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : ddr
    ddio_out ddio_out0( .aclr(rst), .datain_h(d_h_i[i]), .datain_l(d_l_i[i]), .outclock(clk), .dataout(o_pad[i]) );
end
endgenerate
endmodule
`else
`define MODULE o_ddr
module `BASE`MODULE (d_h_i, d_l_i, o_pad, clk, rst);
`undef MODULE
parameter width = 1;
input  [width-1:0] d_h_i, d_l_i;
output [width-1:0] o_pad;
input clk, rst;
reg [width-1:0] ff1;
reg [width-1:0] ff2;
genvar i;
generate
for (i=0;i<width;i=i+1) begin : ddr
    always @ (posedge clk or posedge rst)
    if (rst)
        ff1[i] <= 1'b0;
    else
        ff1[i] <= d_h_i[i];
    always @ (posedge clk or posedge rst)
    if (rst)
        ff2[i] <= 1'b0;
    else
        ff2[i] <= d_l_i[i];
    assign o_pad = (clk) ? ff1 : ff2;
end
endgenerate
endmodule
`endif
`endif

`ifdef O_CLK
`define MODULE o_clk
module `BASE`MODULE ( clk_o_pad, clk, rst);
`undef MODULE
input clk, rst;
output clk_o_pad;
`define MODULE o_ddr
`BASE`MODULE o_ddr0( .d_h_i(1'b1), .d_l_i(1'b0), .o_pad(clk_o_pad), .clk(clk), .rst(rst));
`undef MODULE
endmodule
`endif