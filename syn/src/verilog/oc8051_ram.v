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
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_ram (clk, rst, rd_addr, rd_data, wr_addr, wr_data, wr);
// clk          clock
// rd_addr      read addres
// rd_data      read data
// wr_addr      write addres
// wr_data      write data
// wr           write


input clk, wr, rst;
input [7:0] rd_addr, wr_addr, wr_data;
output [7:0] rd_data;

wire [7:0] dob;
RAMB4_S8_S8 ram1(.DOA(rd_data), .DOB(dob), .ADDRA({1'b0, rd_addr}), .DIA(8'h00), .ENA(1'b1), .CLKA(clk), .WEA(1'b0),
                .RSTA(rst), .ADDRB({1'b0, wr_addr}), .DIB(wr_data), .ENB(1'b1), .CLKB(clk), .WEB(wr), .RSTB(rst));


endmodule



module RAMB4_S8_S8(DOA, DOB, ADDRA, DIA, ENA, CLKA, WEA, RSTA, ADDRB, DIB, ENB, CLKB, WEB, RSTB); // synthesis syn_black_box
output [7:0] DOA;
output [7:0] DOB;
input [8:0] ADDRA;
input [7:0] DIA;
input ENA;
input CLKA;
input WEA;
input RSTA;
input [8:0] ADDRB;
input [7:0] DIB;
input ENB;
input CLKB;
input WEB;
input RSTB;
endmodule
