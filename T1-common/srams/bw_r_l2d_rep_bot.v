// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_l2d_rep_bot.v
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
module bw_r_l2d_rep_bot (/*AUTOARG*/
   // Outputs
   fuse_l2d_rden_buf, fuse_l2d_wren_buf, si_buf, arst_l_buf, se_buf, 
   sehold_buf, fuse_l2d_rid_buf, fuse_read_data_in_buf, 
   fuse_l2d_data_in_buf, word_en_l, col_offset_l, set_l, wr_en_l, 
   way_sel_l, decc_in_l, scbuf_scdata_fbdecc_top_buf, 
   scbuf_scdata_fbdecc_bot_buf, sbdt_l, sbdb_l, fuse_clk1_buf, 
   fuse_clk2_buf, mem_write_disable_buf, 
   // Inputs
   fuse_l2d_rden, fuse_l2d_wren, si, arst_l, se, sehold, 
   fuse_l2d_rid, fuse_read_data_in, fuse_l2d_data_in, word_en, 
   col_offset, set, wr_en, way_sel, decc_in, fbdt_l, fbdb_l, 
   scdata_scbuf_decc_top, scdata_scbuf_decc_bot, 
   efc_scdata_fuse_clk1, efc_scdata_fuse_clk2, mem_write_disable
   );

   input           fuse_l2d_rden;
   input [5:0] 	   fuse_l2d_wren;
   input 	   si;
   input 	   arst_l;
   input 	   se;
   input 	   sehold;
   input [2:0] 	   fuse_l2d_rid;
   input 	   fuse_read_data_in;
   input 	   fuse_l2d_data_in;
   input [3:0] 	   word_en;
   input 	   col_offset;
   input [9:0] 	   set;
   input 	   wr_en;
   input [11:0]	   way_sel;
   input [155:0]   decc_in;
   input [155:0]   fbdt_l;
   input [155:0]   fbdb_l;
   input [155:0]   scdata_scbuf_decc_top;
   input [155:0]   scdata_scbuf_decc_bot;
   input 	   efc_scdata_fuse_clk1;
   input 	   efc_scdata_fuse_clk2;
   input 	   mem_write_disable;

   output 	   fuse_l2d_rden_buf;
   output [5:0]    fuse_l2d_wren_buf;
   output 	   si_buf;
   output 	   arst_l_buf;
   output 	   se_buf;
   output 	   sehold_buf;
   output [2:0]    fuse_l2d_rid_buf;
   output 	   fuse_read_data_in_buf;
   output 	   fuse_l2d_data_in_buf;
   output [3:0]    word_en_l;
   output 	   col_offset_l;
   output [9:0]    set_l;
   output 	   wr_en_l;
   output [11:0]   way_sel_l;
   output [155:0]  decc_in_l;
   output [155:0]  scbuf_scdata_fbdecc_top_buf;
   output [155:0]  scbuf_scdata_fbdecc_bot_buf;
   output [155:0]  sbdt_l;
   output [155:0]  sbdb_l;
   output 	   fuse_clk1_buf;
   output 	   fuse_clk2_buf;
   output 	   mem_write_disable_buf;
   
   ///////////////////////////////////////////////////////////////////////
   // Non-inverting Buffers
   ///////////////////////////////////////////////////////////////////////
   assign fuse_l2d_rden_buf = fuse_l2d_rden;
   assign fuse_l2d_wren_buf[5:0] = fuse_l2d_wren[5:0];
   assign si_buf = si;
   assign arst_l_buf = arst_l;
   assign se_buf = se;
   assign sehold_buf = sehold;
   assign fuse_l2d_rid_buf[2:0] = fuse_l2d_rid[2:0];
   assign fuse_read_data_in_buf = fuse_read_data_in;
   assign fuse_l2d_data_in_buf = fuse_l2d_data_in;
   assign fuse_clk1_buf = efc_scdata_fuse_clk1;
   assign fuse_clk2_buf = efc_scdata_fuse_clk2;
   assign mem_write_disable_buf = mem_write_disable;
   
   ///////////////////////////////////////////////////////////////////////
   // Inverting Buffers
   ///////////////////////////////////////////////////////////////////////
   assign word_en_l[3:0] = ~word_en[3:0];
   assign col_offset_l = ~col_offset;
   assign set_l[9:0] = ~set[9:0];
   assign wr_en_l = ~wr_en;
   assign way_sel_l = ~way_sel;
   assign decc_in_l[155:0] = ~decc_in[155:0];
   assign scbuf_scdata_fbdecc_top_buf[155:0] = ~fbdt_l[155:0];
   assign scbuf_scdata_fbdecc_bot_buf[155:0] = ~fbdb_l[155:0];
   assign sbdt_l[155:0] = ~scdata_scbuf_decc_top[155:0];
   assign sbdb_l[155:0] = ~scdata_scbuf_decc_bot[155:0];

endmodule // bw_r_l2d_rep_bot


