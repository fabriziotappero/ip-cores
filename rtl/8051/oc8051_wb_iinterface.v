//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 wishbone interface to instruction rom                  ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
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
// Revision 1.5  2003/05/05 10:34:27  simont
// registering outputs.
//
// Revision 1.4  2003/04/16 10:02:45  simont
// fix bug (cyc_o and stb_o)
//
// Revision 1.3  2003/04/03 19:19:02  simont
// change adr_i and adr_o length.
//
// Revision 1.2  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.1  2002/10/28 16:42:08  simont
// initial import
//
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_wb_iinterface(rst, clk, 
                  adr_i, dat_o, cyc_i, stb_i, ack_o,
		  adr_o, dat_i, cyc_o, stb_o, ack_i
		  );
//
// rst           (in)  reset - pin
// clk           (in)  clock - pini
input rst, clk;

//
// interface to oc8051 cpu
//
// adr_i    (in)  address
// dat_o    (out) data output
// stb_i    (in)  strobe
// ack_o    (out) acknowledge
// cyc_i    (in)  cycle
input         stb_i,
              cyc_i;
input  [15:0] adr_i;
output        ack_o;
output [31:0] dat_o;

//
// interface to instruction rom
//
// adr_o    (out) address
// dat_i    (in)  data input
// stb_o    (out) strobe
// ack_i    (in) acknowledge
// cyc_o    (out)  cycle
input         ack_i;
input  [31:0] dat_i;
output        stb_o,
              cyc_o;
output [15:0] adr_o;

//
// internal bufers and wires
//
reg [15:0] adr_o;
reg        stb_o;

assign ack_o = ack_i;
assign dat_o = dat_i;
//assign stb_o = stb_i || ack_i;
assign cyc_o = stb_o;
//assign adr_o = ack_i ? adr : adr_i;

always @(posedge clk or posedge rst)
  if (rst) begin
    stb_o <= #1 1'b0;
    adr_o <= #1 16'h0000;
  end else if (ack_i) begin
    stb_o <= #1 stb_i;
    adr_o <= #1 adr_i;
  end else if (!stb_o & stb_i) begin
    stb_o <= #1 1'b1;
    adr_o <= #1 adr_i;
  end

endmodule
