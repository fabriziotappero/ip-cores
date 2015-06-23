//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data ram                                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   data ram for virtex                                        ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
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
// Revision 1.2  2002/09/30 17:34:02  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on
module oc8051_cache_ram (clk, rst, addr0, data0, addr1, data1_i, data1_o, wr1);
//
// this module is part of oc8051_icache
// it's tehnology dependent
//
// clk          (in)  clock
// addr0        (in)  addres port 0
// data0        (out) data output port 0
// addr1        (in)  address port 1
// data1_i      (in)  data input port 1
// data1_o      (out) data output port 1
// wr1          (in)  write port 1
//

parameter ADR_WIDTH = 7; // cache address wihth
parameter CACHE_RAM = 128; // cache ram x 32 (2^ADR_WIDTH)

input clk, wr1, rst;
input [ADR_WIDTH-1:0] addr0, addr1;
input [31:0] data1_i;
output [31:0] data0, data1_o;


//


wire [7:0] dob;
RAMB4_S8_S8 ram1(.DOA(data0), .DOB(data1_o), .ADDRA({1'b0, addr0}), .DIA(8'h00), .ENA(1'b1), .CLKA(clk), .WEA(1'b0),
                .RSTA(rst), .ADDRB({1'b0, addr1}), .DIB(data1_i), .ENB(1'b1), .CLKB(clk), .WEB(wr1), .RSTB(rst));


endmodule
