// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_l2d.v
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
module bw_r_l2d (/*AUTOARG*/
   // Outputs
   wr_en_buf, word_en_buf, way_sel_buf, so, set_buf, 
   scdata_scbuf_decc_top_buf, scdata_scbuf_decc_bot_buf, 
   scbuf_scdata_fbdecc_top_buf, scbuf_scdata_fbdecc_bot_buf, 
   l2d_fuse_data_out, decc_out, decc_in_buf, col_offset_buf, 
   fuse_l2d_rid_buf, fuse_l2d_data_in_buf, arst_l_buf, se_buf, 
   sehold_buf, fuse_l2d_rden_buf, fuse_l2d_wren_buf, fuse_clk1_buf, 
   fuse_clk2_buf, mem_write_disable_buf, 
   // Inputs
   wr_en, word_en, way_sel, si, set, sehold, se, 
   scdata_scbuf_decc_top, scdata_scbuf_decc_bot, 
   scbuf_scdata_fbdecc_top, scbuf_scdata_fbdecc_bot, rclk, 
   mem_write_disable, fuse_read_data_in, fuse_l2d_wren, fuse_l2d_rid, 
   fuse_l2d_rden, fuse_l2d_data_in, efc_scdata_fuse_clk2, 
   efc_scdata_fuse_clk1, decc_read_in, decc_in, col_offset, arst_l
   );

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		arst_l;			// To bot_rep of bw_r_l2d_rep_bot.v
   input		col_offset;		// To bot_rep of bw_r_l2d_rep_bot.v
   input [155:0]	decc_in;		// To bot_rep of bw_r_l2d_rep_bot.v
   input [155:0]	decc_read_in;		// To mem_0 of bw_r_l2d_32k.v
   input		efc_scdata_fuse_clk1;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		efc_scdata_fuse_clk2;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		fuse_l2d_data_in;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		fuse_l2d_rden;		// To bot_rep of bw_r_l2d_rep_bot.v
   input [2:0]		fuse_l2d_rid;		// To bot_rep of bw_r_l2d_rep_bot.v
   input [5:0]		fuse_l2d_wren;		// To bot_rep of bw_r_l2d_rep_bot.v
   input		fuse_read_data_in;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		mem_write_disable;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		rclk;			// To mem_0 of bw_r_l2d_32k.v, ...
   input [155:0]	scbuf_scdata_fbdecc_bot;// To top_rep of bw_r_l2d_rep_top.v
   input [155:0]	scbuf_scdata_fbdecc_top;// To top_rep of bw_r_l2d_rep_top.v
   input [155:0]	scdata_scbuf_decc_bot;	// To bot_rep of bw_r_l2d_rep_bot.v
   input [155:0]	scdata_scbuf_decc_top;	// To bot_rep of bw_r_l2d_rep_bot.v
   input		se;			// To bot_rep of bw_r_l2d_rep_bot.v
   input		sehold;			// To bot_rep of bw_r_l2d_rep_bot.v
   input [9:0]		set;			// To bot_rep of bw_r_l2d_rep_bot.v
   input		si;			// To bot_rep of bw_r_l2d_rep_bot.v
   input [11:0]		way_sel;		// To bot_rep of bw_r_l2d_rep_bot.v
   input [3:0]		word_en;		// To bot_rep of bw_r_l2d_rep_bot.v
   input		wr_en;			// To bot_rep of bw_r_l2d_rep_bot.v
   // End of automatics

   output [2:0]		fuse_l2d_rid_buf;	// From bot_rep of bw_r_l2d_rep_bot.v
   output 		fuse_l2d_data_in_buf;	// From bot_rep of bw_r_l2d_rep_bot.v
   output 		arst_l_buf;		// From bot_rep of bw_r_l2d_rep_bot.v
   output 		se_buf;			// From bot_rep of bw_r_l2d_rep_bot.v
   output		sehold_buf;		// From bot_rep of bw_r_l2d_rep_bot.v
   output 		fuse_l2d_rden_buf;	// From bot_rep of bw_r_l2d_rep_bot.v
   output [5:0]		fuse_l2d_wren_buf;	// From bot_rep of bw_r_l2d_rep_bot.v
   output 		fuse_clk1_buf;
   output 		fuse_clk2_buf;
   output 		mem_write_disable_buf;
   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		col_offset_buf;		// From top_rep of bw_r_l2d_rep_top.v
   output [155:0]	decc_in_buf;		// From top_rep of bw_r_l2d_rep_top.v
   output [155:0]	decc_out;		// From mem_1 of bw_r_l2d_32k.v
   output		l2d_fuse_data_out;	// From mem_0 of bw_r_l2d_32k.v
   output [155:0]	scbuf_scdata_fbdecc_bot_buf;// From bot_rep of bw_r_l2d_rep_bot.v
   output [155:0]	scbuf_scdata_fbdecc_top_buf;// From bot_rep of bw_r_l2d_rep_bot.v
   output [155:0]	scdata_scbuf_decc_bot_buf;// From top_rep of bw_r_l2d_rep_top.v
   output [155:0]	scdata_scbuf_decc_top_buf;// From top_rep of bw_r_l2d_rep_top.v
   output [9:0]		set_buf;		// From top_rep of bw_r_l2d_rep_top.v
   output		so;			// From mem_0 of bw_r_l2d_32k.v
   output [11:0]	way_sel_buf;		// From top_rep of bw_r_l2d_rep_top.v
   output [3:0]		word_en_buf;		// From top_rep of bw_r_l2d_rep_top.v
   output		wr_en_buf;		// From top_rep of bw_r_l2d_rep_top.v
   // End of automatics

   wire [155:0] 	decc_out_0;
   wire 		l2d_fuse_data_out_0;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			col_offset_l;		// From bot_rep of bw_r_l2d_rep_bot.v
   wire [155:0]		decc_in_l;		// From bot_rep of bw_r_l2d_rep_bot.v
   wire [155:0]		fbdb_l;			// From top_rep of bw_r_l2d_rep_top.v
   wire [155:0]		fbdt_l;			// From top_rep of bw_r_l2d_rep_top.v
   wire			fuse_read_data_in_buf;	// From bot_rep of bw_r_l2d_rep_bot.v
   wire [155:0]		sbdb_l;			// From bot_rep of bw_r_l2d_rep_bot.v
   wire [155:0]		sbdt_l;			// From bot_rep of bw_r_l2d_rep_bot.v
   wire [9:0]		set_l;			// From bot_rep of bw_r_l2d_rep_bot.v
   wire			si_buf;			// From bot_rep of bw_r_l2d_rep_bot.v
   wire [11:0]		way_sel_l;		// From bot_rep of bw_r_l2d_rep_bot.v
   wire [3:0]		word_en_l;		// From bot_rep of bw_r_l2d_rep_bot.v
   wire			wr_en_l;		// From bot_rep of bw_r_l2d_rep_bot.v
   // End of automatics



   bw_r_l2d_rep_bot  bot_rep (/*AUTOINST*/
			      // Outputs
			      .fuse_l2d_rden_buf(fuse_l2d_rden_buf),
			      .fuse_l2d_wren_buf(fuse_l2d_wren_buf[5:0]),
			      .si_buf	(si_buf),
			      .arst_l_buf(arst_l_buf),
			      .se_buf	(se_buf),
			      .sehold_buf(sehold_buf),
			      .fuse_l2d_rid_buf(fuse_l2d_rid_buf[2:0]),
			      .fuse_read_data_in_buf(fuse_read_data_in_buf),
			      .fuse_l2d_data_in_buf(fuse_l2d_data_in_buf),
			      .word_en_l(word_en_l[3:0]),
			      .col_offset_l(col_offset_l),
			      .set_l	(set_l[9:0]),
			      .wr_en_l	(wr_en_l),
			      .way_sel_l(way_sel_l[11:0]),
			      .decc_in_l(decc_in_l[155:0]),
			      .scbuf_scdata_fbdecc_top_buf(scbuf_scdata_fbdecc_top_buf[155:0]),
			      .scbuf_scdata_fbdecc_bot_buf(scbuf_scdata_fbdecc_bot_buf[155:0]),
			      .sbdt_l	(sbdt_l[155:0]),
			      .sbdb_l	(sbdb_l[155:0]),
			      .fuse_clk1_buf(fuse_clk1_buf),
			      .fuse_clk2_buf(fuse_clk2_buf),
			      .mem_write_disable_buf(mem_write_disable_buf),
			      // Inputs
			      .fuse_l2d_rden(fuse_l2d_rden),
			      .fuse_l2d_wren(fuse_l2d_wren[5:0]),
			      .si	(si),
			      .arst_l	(arst_l),
			      .se	(se),
			      .sehold	(sehold),
			      .fuse_l2d_rid(fuse_l2d_rid[2:0]),
			      .fuse_read_data_in(fuse_read_data_in),
			      .fuse_l2d_data_in(fuse_l2d_data_in),
			      .word_en	(word_en[3:0]),
			      .col_offset(col_offset),
			      .set	(set[9:0]),
			      .wr_en	(wr_en),
			      .way_sel	(way_sel[11:0]),
			      .decc_in	(decc_in[155:0]),
			      .fbdt_l	(fbdt_l[155:0]),
			      .fbdb_l	(fbdb_l[155:0]),
			      .scdata_scbuf_decc_top(scdata_scbuf_decc_top[155:0]),
			      .scdata_scbuf_decc_bot(scdata_scbuf_decc_bot[155:0]),
			      .efc_scdata_fuse_clk1(efc_scdata_fuse_clk1),
			      .efc_scdata_fuse_clk2(efc_scdata_fuse_clk2),
			      .mem_write_disable(mem_write_disable));
   

   bw_r_l2d_rep_top  top_rep (/*AUTOINST*/
			      // Outputs
			      .word_en_buf(word_en_buf[3:0]),
			      .col_offset_buf(col_offset_buf),
			      .set_buf	(set_buf[9:0]),
			      .wr_en_buf(wr_en_buf),
			      .way_sel_buf(way_sel_buf[11:0]),
			      .decc_in_buf(decc_in_buf[155:0]),
			      .fbdt_l	(fbdt_l[155:0]),
			      .fbdb_l	(fbdb_l[155:0]),
			      .scdata_scbuf_decc_top_buf(scdata_scbuf_decc_top_buf[155:0]),
			      .scdata_scbuf_decc_bot_buf(scdata_scbuf_decc_bot_buf[155:0]),
			      // Inputs
			      .word_en_l(word_en_l[3:0]),
			      .col_offset_l(col_offset_l),
			      .set_l	(set_l[9:0]),
			      .wr_en_l	(wr_en_l),
			      .way_sel_l(way_sel_l[11:0]),
			      .decc_in_l(decc_in_l[155:0]),
			      .scbuf_scdata_fbdecc_top(scbuf_scdata_fbdecc_top[155:0]),
			      .scbuf_scdata_fbdecc_bot(scbuf_scdata_fbdecc_bot[155:0]),
			      .sbdt_l	(sbdt_l[155:0]),
			      .sbdb_l	(sbdb_l[155:0]));
   

			      
   /*
    bw_r_l2d_32k	AUTO_TEMPLATE(
    .way_sel_l(way_sel_l[@"(+ 9 (* @ 2))":@"(+ 8 (* @ 2))"]),
    .fuse_l2d_wren(fuse_l2d_wren_buf[@"(+ 4 @)"]),
    .fuse_l2d_rden(fuse_l2d_rden_buf),
    .si(si_buf),
    .se(se_buf),
    .arst_l(arst_l_buf),
    .sehold(sehold_buf),
    .mem_write_disable(mem_write_disable_buf),
    .fuse_l2d_rid(fuse_l2d_rid_buf[2:0]),
    .fuse_clk1(fuse_clk1_buf),
    .fuse_clk2(fuse_clk2_buf),
    .fuse_l2d_data_in(fuse_l2d_data_in_buf),
    .fuse_read_data_in(fuse_read_data_in_buf));
    */

   
   bw_r_l2d_32k mem_0(
		      //Inputs
           	      .si		(scan_out_0),
		      .fuse_read_data_in(l2d_fuse_data_out_0),
		      //Outputs
		      .decc_out(decc_out_0[155:0]),
		      /*AUTOINST*/
		      // Outputs
		      .so		(so),
		      .l2d_fuse_data_out(l2d_fuse_data_out),
		      // Inputs
		      .decc_in_l	(decc_in_l[155:0]),
		      .decc_read_in	(decc_read_in[155:0]),
		      .word_en_l	(word_en_l[3:0]),
		      .way_sel_l	(way_sel_l[9:8]),	 // Templated
		      .set_l		(set_l[9:0]),
		      .col_offset_l	(col_offset_l),
		      .wr_en_l		(wr_en_l),
		      .rclk		(rclk),
		      .arst_l		(arst_l_buf),		 // Templated
		      .mem_write_disable(mem_write_disable_buf), // Templated
		      .sehold		(sehold_buf),		 // Templated
		      .se		(se_buf),		 // Templated
		      .fuse_l2d_wren	(fuse_l2d_wren_buf[4]),	 // Templated
		      .fuse_l2d_rden	(fuse_l2d_rden_buf),	 // Templated
		      .fuse_l2d_rid	(fuse_l2d_rid_buf[2:0]), // Templated
		      .fuse_clk1	(fuse_clk1_buf),	 // Templated
		      .fuse_clk2	(fuse_clk2_buf),	 // Templated
		      .fuse_l2d_data_in	(fuse_l2d_data_in_buf));	 // Templated
   
   bw_r_l2d_32k  mem_1(
		       //Inputs
		       .decc_read_in(decc_out_0),
		       //Outputs
		       .l2d_fuse_data_out(l2d_fuse_data_out_0),
		       .so		(scan_out_0),
		       /*AUTOINST*/
		       // Outputs
		       .decc_out	(decc_out[155:0]),
		       // Inputs
		       .decc_in_l	(decc_in_l[155:0]),
		       .word_en_l	(word_en_l[3:0]),
		       .way_sel_l	(way_sel_l[11:10]),	 // Templated
		       .set_l		(set_l[9:0]),
		       .col_offset_l	(col_offset_l),
		       .wr_en_l		(wr_en_l),
		       .rclk		(rclk),
		       .arst_l		(arst_l_buf),		 // Templated
		       .mem_write_disable(mem_write_disable_buf), // Templated
		       .sehold		(sehold_buf),		 // Templated
		       .se		(se_buf),		 // Templated
		       .si		(si_buf),		 // Templated
		       .fuse_l2d_wren	(fuse_l2d_wren_buf[5]),	 // Templated
		       .fuse_l2d_rden	(fuse_l2d_rden_buf),	 // Templated
		       .fuse_l2d_rid	(fuse_l2d_rid_buf[2:0]), // Templated
		       .fuse_clk1	(fuse_clk1_buf),	 // Templated
		       .fuse_clk2	(fuse_clk2_buf),	 // Templated
		       .fuse_l2d_data_in(fuse_l2d_data_in_buf),	 // Templated
		       .fuse_read_data_in(fuse_read_data_in_buf)); // Templated

endmodule // bw_r_l2d
