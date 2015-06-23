//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data ram                                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   data ram                                                   ////
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
// Revision 1.10  2003/06/20 13:36:37  simont
// ram modules added.
//
// Revision 1.9  2003/06/17 14:17:22  simont
// BIST signals added.
//
// Revision 1.8  2003/04/02 16:12:04  simont
// generic_dpram used
//
// Revision 1.7  2003/04/02 11:26:21  simont
// updating...
//
// Revision 1.6  2003/01/26 14:19:22  rherveille
// Replaced oc8051_ram by generic_dpram.
//
// Revision 1.5  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.4  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_ram_top (clk, 
                       rst, 
		       rd_addr, 
		       rd_data, 
		       wr_addr, 
		       bit_addr, 
		       wr_data, 
		       wr, 
		       bit_data_in, 
		       bit_data_out
`ifdef OC8051_BIST
         ,
         scanb_rst,
         scanb_clk,
         scanb_si,
         scanb_so,
         scanb_en
`endif
		       );

// on-chip ram-size (2**ram_aw bytes)
parameter ram_aw = 8; // default 256 bytes


//
// clk          (in)  clock
// rd_addr      (in)  read addres [oc8051_ram_rd_sel.out]
// rd_data      (out) read data [oc8051_ram_sel.in_ram]
// wr_addr      (in)  write addres [oc8051_ram_wr_sel.out]
// bit_addr     (in)  bit addresable instruction [oc8051_decoder.bit_addr -r]
// wr_data      (in)  write data [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// bit_data_in  (in)  bit data input [oc8051_alu.desCy]
// bit_data_out (out)  bit data output [oc8051_ram_sel.bit_in]
//

input clk, wr, bit_addr, bit_data_in, rst;
input [7:0] wr_data;
input [7:0] rd_addr, wr_addr;
output bit_data_out;
output [7:0] rd_data;

`ifdef OC8051_BIST
input   scanb_rst;
input   scanb_clk;
input   scanb_si;
output  scanb_so;
input   scanb_en;
`endif

// rd_addr_m    read address modified
// wr_addr_m    write address modified
// wr_data_m    write data modified
reg [7:0] wr_data_m;
reg [7:0] rd_addr_m, wr_addr_m;


wire       rd_en;
reg        bit_addr_r,
           rd_en_r;
reg  [7:0] wr_data_r;
wire [7:0] rd_data_m;
reg  [2:0] bit_select;

assign bit_data_out = rd_data[bit_select];


assign rd_data = rd_en_r ? wr_data_r: rd_data_m;
assign rd_en   = (rd_addr_m == wr_addr_m) & wr;

oc8051_ram_256x8_two_bist oc8051_idata(
                           .clk     ( clk        ),
                           .rst     ( rst        ),
			   .rd_addr ( rd_addr_m  ),
			   .rd_data ( rd_data_m  ),
			   .rd_en   ( !rd_en     ),
			   .wr_addr ( wr_addr_m  ),
			   .wr_data ( wr_data_m  ),
			   .wr_en   ( 1'b1       ),
			   .wr      ( wr         )
`ifdef OC8051_BIST
         ,
         .scanb_rst(scanb_rst),
         .scanb_clk(scanb_clk),
         .scanb_si(scanb_si),
         .scanb_so(scanb_so),
         .scanb_en(scanb_en)
`endif
			   );

always @(posedge clk or posedge rst)
  if (rst) begin
    bit_addr_r <= #1 1'b0;
    bit_select <= #1 3'b0;
  end else begin
    bit_addr_r <= #1 bit_addr;
    bit_select <= #1 rd_addr[2:0];
  end


always @(posedge clk or posedge rst)
  if (rst) begin
    rd_en_r    <= #1 1'b0;
    wr_data_r  <= #1 8'h0;
  end else begin
    rd_en_r    <= #1 rd_en;
    wr_data_r  <= #1 wr_data_m;
  end


always @(rd_addr or bit_addr)
  casex ( {bit_addr, rd_addr[7]} ) // synopsys full_case parallel_case
      2'b0?: rd_addr_m = rd_addr;
      2'b10: rd_addr_m = {4'b0010, rd_addr[6:3]};
      2'b11: rd_addr_m = {1'b1, rd_addr[6:3], 3'b000};
  endcase


always @(wr_addr or bit_addr_r)
  casex ( {bit_addr_r, wr_addr[7]} ) // synopsys full_case parallel_case
      2'b0?: wr_addr_m = wr_addr;
      2'b10: wr_addr_m = {8'h00, 4'b0010, wr_addr[6:3]};
      2'b11: wr_addr_m = {8'h00, 1'b1, wr_addr[6:3], 3'b000};
  endcase


always @(rd_data or bit_select or bit_data_in or wr_data or bit_addr_r)
  casex ( {bit_addr_r, bit_select} ) // synopsys full_case parallel_case
      4'b0_???: wr_data_m = wr_data;
      4'b1_000: wr_data_m = {rd_data[7:1], bit_data_in};
      4'b1_001: wr_data_m = {rd_data[7:2], bit_data_in, rd_data[0]};
      4'b1_010: wr_data_m = {rd_data[7:3], bit_data_in, rd_data[1:0]};
      4'b1_011: wr_data_m = {rd_data[7:4], bit_data_in, rd_data[2:0]};
      4'b1_100: wr_data_m = {rd_data[7:5], bit_data_in, rd_data[3:0]};
      4'b1_101: wr_data_m = {rd_data[7:6], bit_data_in, rd_data[4:0]};
      4'b1_110: wr_data_m = {rd_data[7], bit_data_in, rd_data[5:0]};
      4'b1_111: wr_data_m = {bit_data_in, rd_data[6:0]};
  endcase


endmodule
