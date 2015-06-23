//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 fpga top module                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   fpga top module                                            ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2002/09/30 17:34:02  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_fpga_top (clk, rst,
//
// interrupt interface
//
   int1, int2,
//
// 2x7 led display output (port 0)
//
   dispout, 
//
// ports
//
   p0_out, p1_out, p2_out, p3_out, 
//
// external instruction rom interface
//
   ea, iadr_o, istb_o, iack_i, icyc_o, idat_i,
//
// external data ram interface
//
   stb_o, cyc_o, dat_i, dat_o, adr_o, ack_i, we_o,
//
// serial interface
//
   rxd, txd, 
//
// timer/counter interface
//
   t0, t1);

input clk, rst, int1, int2, ea, iack_i, ack_i, rxd, t0, t1;
input [7:0] dat_i;
input [31:0] idat_i;
output txd, istb_o, icyc_o, stb_o, cyc_o, we_o;
output [13:0] dispout;
output [7:0] p0_out, p1_out, p2_out, p3_out, dat_o;
output [15:0] adr_o, iadr_o;


wire cstb_o, ccyc_o, cack_i;
wire [15:0] cadr_o;
wire [31:0] cdat_i;


wire nrst;

assign nrst = ~rst;

oc8051_top oc8051_top_1(.rst(nrst), .clk(clk),
//
// interrupt interface
//
    .int0(int1), .int1(int2),
//
// external rom interface
//
    .ea(ea), .iadr_o(cadr_o),  .idat_i(cdat_i), .istb_o(cstb_o), .iack_i(cack_i), .icyc_o(ccyc_o),
//
// external ram interface
//
    .dat_i(dat_i), .dat_o(dat_o), .adr_o(adr_o), .we_o(we_o), .ack_i(ack_i), .stb_o(stb_o),
    .cyc_o(cyc_o),
//
//  ports interface
//
     .p0_in(8'hb0), .p1_in(8'hb1), .p2_in(8'hb2), .p3_in(8'hb3),
     .p0_out(p0_out), .p1_out(p1_out), .p2_out(p2_out), .p3_out(p3_out),
//
// serial interface
//
     .rxd(rxd), .txd(txd),
//
// timer/counter interface
//
     .t0(t0), .t1(t1));





oc8051_icache oc8051_icache1(.rst(rst), .clk(clk),
// oc8051
        .adr_i(cadr_o), .dat_o(cdat_i), .stb_i(cstb_o), .ack_o(cack_i),
        .cyc_i(ccyc_o),
// external rom
        .dat_i(idat_i), .stb_o(istb_o), .adr_o(iadr_o), .ack_i(iack_i),
        .cyc_o(icyc_o));


defparam oc8051_icache1.ADR_WIDTH = 6;  // cache address wihth
defparam oc8051_icache1.LINE_WIDTH = 3; // line address width (2 => 4x32)
defparam oc8051_icache1.BL_NUM = 7; // number of blocks (2^BL_WIDTH-1); BL_WIDTH = ADR_WIDTH - LINE_WIDTH
defparam oc8051_icache1.CACHE_RAM = 64; // cache ram x 32 (2^ADR_WIDTH)



  disp disp1(.in(p0_out), .out(dispout));

endmodule
