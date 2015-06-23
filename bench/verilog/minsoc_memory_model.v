//////////////////////////////////////////////////////////////////////
////                                                              ////
//// 	     Wishbone Single-Port Synchronous RAM 		  		  ////
////	      	    	Memory Model 		                  	  ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/minsoc/  		 	  ////
////                                                              ////
////  Description                                                 ////
////  This Wishbone controller connects to the wrapper of         ////
////  the single-port synchronous memory interface.               ////
////  Besides universal memory due to onchip_ram it provides a    ////
////  generic way to set the depth of the memory.                 ////
////                                                              ////
////  To Do:                                                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Raul Fajardo, rfajardo@gmail.com	                  ////
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
//// from http://www.gnu.org/licenses/lgpl.html                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// Revision History
//
//
// Revision 1.0 2009/08/18 15:15:00   fajardo
// Created interface and tested
//

`include "timescale.v"

module minsoc_memory_model ( 
  wb_clk_i, wb_rst_i, 
 
  wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, 
  wb_stb_i, wb_ack_o, wb_err_o 
); 
 
// 
// Parameters 
//
parameter    adr_width = 2;
 
// 
// I/O Ports 
// 
input      wb_clk_i; 
input      wb_rst_i; 
 
// 
// WB slave i/f 
// 
input  [31:0]   wb_dat_i; 
output [31:0]   wb_dat_o; 
input  [31:0]   wb_adr_i; 
input  [3:0]    wb_sel_i; 
input      wb_we_i; 
input      wb_cyc_i; 
input      wb_stb_i; 
output     wb_ack_o; 
output     wb_err_o; 
 
// 
// Internal regs and wires 
// 
wire    we; 
wire [3:0]  be_i; 
wire [31:0]  wb_dat_o; 
reg    ack_we; 
reg    ack_re; 
// 
// Aliases and simple assignments 
// 
assign wb_ack_o = ack_re | ack_we; 
assign wb_err_o = wb_cyc_i & wb_stb_i & (|wb_adr_i[23:adr_width+2]);  // If Access to > (8-bit leading prefix ignored) 
assign we = wb_cyc_i & wb_stb_i & wb_we_i & (|wb_sel_i[3:0]); 
assign be_i = (wb_cyc_i & wb_stb_i) * wb_sel_i; 
 
// 
// Write acknowledge 
// 
always @ (negedge wb_clk_i or posedge wb_rst_i) 
begin 
if (wb_rst_i) 
    ack_we <= 1'b0; 
  else 
  if (wb_cyc_i & wb_stb_i & wb_we_i & ~ack_we) 
    ack_we <= #1 1'b1; 
  else 
    ack_we <= #1 1'b0; 
end 
 
// 
// read acknowledge 
// 
always @ (posedge wb_clk_i or posedge wb_rst_i) 
begin 
  if (wb_rst_i) 
    ack_re <= 1'b0; 
  else 
  if (wb_cyc_i & wb_stb_i & ~wb_err_o & ~wb_we_i & ~ack_re) 
    ack_re <= #1 1'b1; 
  else 
    ack_re <= #1 1'b0; 
end 

    minsoc_onchip_ram #
	(
		.aw(adr_width)
	)
	block_ram_0 ( 
        .clk(wb_clk_i), 
        .rst(wb_rst_i),
        .addr(wb_adr_i[adr_width+1:2]), 
        .di(wb_dat_i[7:0]), 
        .doq(wb_dat_o[7:0]), 
        .we(we), 
        .oe(1'b1),
        .ce(be_i[0])); 

    minsoc_onchip_ram #
	(
		.aw(adr_width)
	)
	block_ram_1 ( 
        .clk(wb_clk_i), 
        .rst(wb_rst_i),
        .addr(wb_adr_i[adr_width+1:2]), 
        .di(wb_dat_i[15:8]), 
        .doq(wb_dat_o[15:8]), 
        .we(we), 
        .oe(1'b1),
        .ce(be_i[1])); 

    minsoc_onchip_ram #
	(
		.aw(adr_width)
	)
	block_ram_2 ( 
        .clk(wb_clk_i), 
        .rst(wb_rst_i),
        .addr(wb_adr_i[adr_width+1:2]), 
        .di(wb_dat_i[23:16]), 
        .doq(wb_dat_o[23:16]), 
        .we(we), 
        .oe(1'b1),
        .ce(be_i[2])); 

    minsoc_onchip_ram #
	(
		.aw(adr_width)
	)
	block_ram_3 ( 
        .clk(wb_clk_i), 
        .rst(wb_rst_i),
        .addr(wb_adr_i[adr_width+1:2]), 
        .di(wb_dat_i[31:24]), 
        .doq(wb_dat_o[31:24]), 
        .we(we), 
        .oe(1'b1),
        .ce(be_i[3])); 

endmodule 

