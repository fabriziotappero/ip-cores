//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Logic functions                                             ////
////                                                              ////
////  Description                                                 ////
////  Logic functions such as multiplexers                        ////
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
`ifdef MUX_ANDOR
`define MODULE mux_andor
module `BASE`MODULE ( a, sel, dout);
`undef MODULE

parameter width = 32;
parameter nr_of_ports = 4;

input [nr_of_ports*width-1:0] a;
input [nr_of_ports-1:0] sel;
output reg [width-1:0] dout;

integer i,j;

always @ (a, sel)
begin
    dout = a[width-1:0] & {width{sel[0]}};
    for (i=1;i<nr_of_ports;i=i+1)
        for (j=0;j<width;j=j+1)
            dout[j] = (a[i*width + j] & sel[i]) | dout[j];
end

endmodule
`endif

`ifdef MUX2_ANDOR
`define MODULE mux2_andor
module `BASE`MODULE ( a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 2;
input [width-1:0] a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX3_ANDOR
`define MODULE mux3_andor
module `BASE`MODULE ( a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 3;
input [width-1:0] a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE    
endmodule
`endif

`ifdef MUX4_ANDOR
`define MODULE mux4_andor
module `BASE`MODULE ( a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 4;
input [width-1:0] a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX5_ANDOR
`define MODULE mux5_andor
module `BASE`MODULE ( a4, a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 5;
input [width-1:0] a4, a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a4,a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef MUX6_ANDOR
`define MODULE mux6_andor
module `BASE`MODULE ( a5, a4, a3, a2, a1, a0, sel, dout);
`undef MODULE

parameter width = 32;
localparam nr_of_ports = 6;
input [width-1:0] a5, a4, a3, a2, a1, a0;
input [nr_of_ports-1:0] sel;
output [width-1:0] dout;

`define MODULE mux_andor
`BASE`MODULE
    # ( .width(width), .nr_of_ports(nr_of_ports))
    mux0( .a({a5,a4,a3,a2,a1,a0}), .sel(sel), .dout(dout));
`undef MODULE

endmodule
`endif

`ifdef PARITY

`define MODULE parity_generate
module `BASE`MODULE (data, parity);
`undef MODULE
parameter word_size = 32;
parameter chunk_size = 8;
parameter parity_type = 1'b0; // 0 - even, 1 - odd parity
input [word_size-1:0] data;
output reg [word_size/chunk_size-1:0] parity;
integer i,j;
always @ (data)
for (i=0;i<word_size/chunk_size;i=i+1) begin
    parity[i] = parity_type;
    for (j=0;j<chunk_size;j=j+1) begin
        parity[i] = data[i*chunk_size+j] ^ parity[i];
    end
end
endmodule

`define MODULE parity_check
module `BASE`MODULE( data, parity, parity_error);
`undef MODULE
parameter word_size = 32;
parameter chunk_size = 8;
parameter parity_type = 1'b0; // 0 - even, 1 - odd parity
input [word_size-1:0] data;
input [word_size/chunk_size-1:0] parity;
output parity_error;
reg [word_size/chunk_size-1:0] error_flag;
integer i,j;
always @ (data or parity)
for (i=0;i<word_size/chunk_size;i=i+1) begin
    error_flag[i] = parity[i] ^ parity_type;
    for (j=0;j<chunk_size;j=j+1) begin
        error_flag[i] = data[i*chunk_size+j] ^ error_flag[i];
    end
end
assign parity_error = |error_flag;
endmodule

`endif