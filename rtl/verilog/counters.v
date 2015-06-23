//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, counters                                 ////
////                                                              ////
////  Description                                                 ////
////  counters                                                    ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more counters                                        ////
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

`ifdef CNT_SHREG_WRAP
`define MODULE cnt_shreg_wrap
module `BASE`MODULE ( q, rst, clk);
`undef MODULE

   parameter length = 4;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif

`ifdef CNT_SHREG_CE_WRAP
`define MODULE cnt_shreg_ce_wrap
module `BASE`MODULE ( cke, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif

`ifdef CNT_SHREG_CLEAR
`define MODULE cnt_shreg_clear
module `BASE`MODULE ( clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (clear)
            q <= {1'b1,{length-1{1'b0}}};
        else
            q <= q >> 1;
            
endmodule
`endif

`ifdef CNT_SHREG_CE_CLEAR
`define MODULE cnt_shreg_ce_clear
module `BASE`MODULE ( cke, clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke, clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            if (clear)
                q <= {1'b1,{length-1{1'b0}}};
            else
                q <= q >> 1;
            
endmodule
`endif

`ifdef CNT_SHREG_CE_CLEAR_WRAP
`define MODULE cnt_shreg_ce_clear_wrap
module `BASE`MODULE ( cke, clear, q, rst, clk);
`undef MODULE

   parameter length = 4;
   input cke, clear;
   output reg [0:length-1] q;
   input rst;
   input clk;

    always @ (posedge clk or posedge rst)
    if (rst)
        q <= {1'b1,{length-1{1'b0}}};
    else
        if (cke)
            if (clear)
                q <= {1'b1,{length-1{1'b0}}};
            else
            q <= {q[length-1],q[0:length-2]};
            
endmodule
`endif
