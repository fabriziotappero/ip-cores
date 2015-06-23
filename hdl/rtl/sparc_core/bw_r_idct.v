// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_idct.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
////////////////////////////////////////////////////////////////////////
/*
 //  Module Name:  bw_r_idct.v
 //  Description:	
 //    Contains the RTL for the icache and dcache tag blocks.  
 //    This is a 1RW 512 entry X 33b macro, with 132b rd and 132b wr,
 //    broken into 4 33b segments with its own write enable.
 //    Address and Control inputs are available the stage before
 //    array access, which is referred to as "_x".  Write data is
 //    available in the same stage as the write to the ram, referred
 //    to as "_y".  Read data is also read out and available in "_y".
 //
 //            X       |      Y
 //     index          |  ram access
 //     index sel      |  write_tag 
 //     rd/wr req      |     -> read_tag
 //     way enable     |
 */


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

//FPGA_SYN enables all FPGA related modifications
 





module bw_r_idct(rdtag_w0_y, rdtag_w1_y, rdtag_w2_y, rdtag_w3_y, so, rclk, se, 
	si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x, 
	dec_wrway_x, rdreq_x, wrreq_x, wrtag_w0_y, wrtag_w1_y, wrtag_w2_y, 
	wrtag_w3_y, adj);

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input			rst_tri_en;
	input	[6:0]		index0_x;
	input	[6:0]		index1_x;
	input			index_sel_x;
	input	[3:0]		dec_wrway_x;
	input			rdreq_x;
	input			wrreq_x;
	input	[32:0]		wrtag_w0_y;
	input	[32:0]		wrtag_w1_y;
	input	[32:0]		wrtag_w2_y;
	input	[32:0]		wrtag_w3_y;
	input	[3:0]		adj;
	output	[32:0]		rdtag_w0_y;
	output	[32:0]		rdtag_w1_y;
	output	[32:0]		rdtag_w2_y;
	output	[32:0]		rdtag_w3_y;
	output			so;

	wire			clk;
	reg	[6:0]		index_y;
	reg			rdreq_y;
	reg			wrreq_y;
	reg	[3:0]		dec_wrway_y;
	wire	[6:0]		index_x;
	wire	[3:0]		we;

   	reg [131:0]  rdtag_sa_y; //for error_inject XMR

	assign clk = rclk;
	assign index_x = (index_sel_x ? index1_x : index0_x);
	assign we = ({4 {((wrreq_y & reset_l) & (~rst_tri_en))}} & dec_wrway_y);

	always @(posedge clk) begin
	  if (~sehold) begin
	    rdreq_y <= rdreq_x;
	    wrreq_y <= wrreq_x;
	    index_y <= index_x;
	    dec_wrway_y <= dec_wrway_x;
	  end
	end

	bw_r_idct_array ictag_ary_00(
		.we	(we[0]),
		.clk	(clk),
		.rd_data(rdtag_w0_y), 
		.wr_data(wrtag_w0_y),
		.addr	(index_y));

	bw_r_idct_array ictag_ary_01(
		.we	(we[1]),
		.clk	(clk),
		.rd_data(rdtag_w1_y),
		.wr_data(wrtag_w1_y),
		.addr	(index_y));

	bw_r_idct_array ictag_ary_10(
		.we	(we[2]),
		.clk	(clk),
		.rd_data(rdtag_w2_y),
		.wr_data(wrtag_w2_y),
		.addr	(index_y));

	bw_r_idct_array ictag_ary_11(
		.we	(we[3]),
		.clk	(clk),
		.rd_data(rdtag_w3_y),
		.wr_data(wrtag_w3_y),
		.addr	(index_y));

endmodule

module bw_r_idct_array(we, clk, rd_data, wr_data, addr);

input we;
input clk;
input [32:0] wr_data;
input [6:0] addr;
output [32:0] rd_data;
reg [32:0] rd_data;

reg	[32:0]		array[127:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;


	always @(negedge clk) begin
	  if (we) array[addr] <= wr_data;
	  else rd_data <= array[addr];
	end
endmodule
























































































































































































































































