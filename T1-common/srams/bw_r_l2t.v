// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_l2t.v
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
// Local header file includes / local define
// The sctag_pcx*** signals need to be appropriately bound in the
// instantiation made in sctag.v
////////////////////////////////////////////////////////////////////////

module bw_r_l2t( /*AUTOARG*/
   // Outputs
   so, l2t_fuse_repair_value, l2t_fuse_repair_en, way_sel, way_sel_1, 
   tag_way0, tag_way1, tag_way2, tag_way3, tag_way4, tag_way5, 
   tag_way6, tag_way7, tag_way8, tag_way9, tag_way10, tag_way11, 
   // Inputs
   index, bist_index, rd_en, bist_rd_en, way, bist_way, wr_en, 
   bist_wr_en, wrdata0, bist_wrdata0, wrdata1, bist_wrdata1, 
   lkup_tag_d1, rclk, fuse_l2t_wren, fuse_l2t_rid, 
   fuse_l2t_repair_value, fuse_l2t_repair_en, efc_sctag_fuse_clk1, 
   rst_tri_en, si, se, arst_l, sehold
   );

// select xbar

input	[9:0]	index ; // from addrdp
input	[9:0]	bist_index ; // BIST INPUT


input		rd_en ;  // enable from arbctl is speculatively asserted.
input		bist_rd_en ; // BIST INPUT

input	[11:0]	way; // way for a fill/tag write
input	[11:0]	bist_way;// BIST INPUT

input	 	wr_en; // on a fill in px2 or a diag/tecc write.
input		bist_wr_en ; // BIST INPUT

input	[27:0]	wrdata0 ; // wr tag
input	[7:0]	bist_wrdata0 ; // wr tag
input	[27:0]	wrdata1 ; // wr tag
input	[7:0]	bist_wrdata1 ; // wr tag

input	[27:1]	lkup_tag_d1 ; //ecc bits are appended to this tag.

input		rclk;

// input	[3:0]	tag_stm ;  ?? may not be needed.


input          fuse_l2t_wren;          //redundancy reg wr enable, qualified
input [5:0]    fuse_l2t_rid;           //redundancy register id <5:2> == subbank, <1:0> determines row/col red.
input [6:0]    fuse_l2t_repair_value;  //data in for redundancy register  
input [1:0]    fuse_l2t_repair_en;     //enable bits to turn on redundancy
input	       efc_sctag_fuse_clk1;




input		rst_tri_en;
input 		si, se;
output 		so;
input		arst_l;
input		sehold;

output  [6:0]    l2t_fuse_repair_value;  //data out for redundancy register
output  [1:0]    l2t_fuse_repair_en;     //enable bits out

output	[11:0]	way_sel; // compare outputs
output	[11:0]	way_sel_1; // compare outputs

output	[27:0] tag_way0;
output	[27:0] tag_way1;
output	[27:0] tag_way2;
output	[27:0] tag_way3;
output	[27:0] tag_way4;
output	[27:0] tag_way5;
output	[27:0] tag_way6;
output	[27:0] tag_way7;
output	[27:0] tag_way8;
output	[27:0] tag_way9;
output	[27:0] tag_way10;
output	[27:0] tag_way11;

reg	[27:0]	wrdata0_d1_l, wrdata1_d1_l ;
wire	[11:0]	gbl_red_bank_id;
reg	[6:0]	l2t_fuse_repair_value;
reg	[1:0]	l2t_fuse_repair_en;

wire	[6:0]	red_reg_q_ab, red_reg_q_89, red_reg_q_67, red_reg_q_45 ;
wire	[6:0]	red_reg_q_01, red_reg_q_23;
wire	[1:0]	red_reg_enq_ab, red_reg_enq_89, red_reg_enq_67, red_reg_enq_45 ;
wire	[1:0]	red_reg_enq_01, red_reg_enq_23;
wire	[5:0]	wr_en_subbank;
wire	[27:0]	tag_wrdata0_px2, tag_wrdata1_px2 ;

assign  tag_wrdata0_px2 = ( bist_wr_en ) ?  { bist_wrdata0[3:0],
                                          {3{bist_wrdata0[7:0]}} } : wrdata0;

assign  tag_wrdata1_px2 = ( bist_wr_en ) ?  { bist_wrdata1[3:0],
                                          {3{bist_wrdata1[7:0]}} } : wrdata1;

// Inputs that are flopped

always	@(posedge rclk) begin
	wrdata0_d1_l <= (sehold)? wrdata0_d1_l: ~tag_wrdata0_px2 ;
	wrdata1_d1_l <= (sehold)? wrdata1_d1_l: ~tag_wrdata1_px2 ;

`ifdef	INNO_MUXEX
`else
//----- PURELY FOR VERIFICATION -----------------------
	if(wr_en) begin
		case(way)
			12'b000000000001: ;
			12'b000000000010: ;
			12'b000000000100: ;
			12'b000000001000: ;
			12'b000000010000: ;
			12'b000000100000: ;
			12'b000001000000: ;
			12'b000010000000: ;
			12'b000100000000: ;
			12'b001000000000: ;
			12'b010000000000: ;
			12'b100000000000: ;
			default:
			`ifdef MODELSIM
				$display("L2_TAG_ERR"," way select error %h ", way[11:0]);
			`else
				$error("L2_TAG_ERR"," way select error %h ", way[11:0]); 
			`endif	
		endcase
	end // of if
//----- PURELY FOR VERIFICATION -----------------------
`endif
end

assign		way_sel_1 = way_sel ;

assign gbl_red_bank_id[0] = ( fuse_l2t_rid[5:2] == 4'd0) ;
assign gbl_red_bank_id[1] = ( fuse_l2t_rid[5:2] == 4'd1) ;
assign gbl_red_bank_id[2] = ( fuse_l2t_rid[5:2] == 4'd2) ;
assign gbl_red_bank_id[3] = ( fuse_l2t_rid[5:2] == 4'd3) ;
assign gbl_red_bank_id[4] = ( fuse_l2t_rid[5:2] == 4'd4) ;
assign gbl_red_bank_id[5] = ( fuse_l2t_rid[5:2] == 4'd5) ;
assign gbl_red_bank_id[6] = ( fuse_l2t_rid[5:2] == 4'd6) ;
assign gbl_red_bank_id[7] = ( fuse_l2t_rid[5:2] == 4'd7) ;
assign gbl_red_bank_id[8] = ( fuse_l2t_rid[5:2] == 4'd8) ;
assign gbl_red_bank_id[9] = ( fuse_l2t_rid[5:2] == 4'd9) ;
assign gbl_red_bank_id[10] = ( fuse_l2t_rid[5:2] == 4'd10) ;
assign gbl_red_bank_id[11] = ( fuse_l2t_rid[5:2] == 4'd11) ;


//assign	wr_en_subbank[0] = fuse_l2t_wren & ( |(gbl_red_bank_id[1:0]) );
//assign	wr_en_subbank[1] = fuse_l2t_wren & ( |(gbl_red_bank_id[5:4]) );
//assign	wr_en_subbank[2] = fuse_l2t_wren & ( |(gbl_red_bank_id[9:8]) );
//assign	wr_en_subbank[3] = fuse_l2t_wren & ( |(gbl_red_bank_id[3:2]) );
//assign	wr_en_subbank[4] = fuse_l2t_wren & ( |(gbl_red_bank_id[7:6]) );
//assign	wr_en_subbank[5] = fuse_l2t_wren & ( |(gbl_red_bank_id[11:10]) );

// JC modified begin
// Write enable signal goes directly to subbank without any gating circuits.
assign  wr_en_subbank[0] = fuse_l2t_wren;
assign  wr_en_subbank[1] = fuse_l2t_wren;
assign  wr_en_subbank[2] = fuse_l2t_wren;
assign  wr_en_subbank[3] = fuse_l2t_wren;
assign  wr_en_subbank[4] = fuse_l2t_wren;
assign  wr_en_subbank[5] = fuse_l2t_wren;
// JC modified begin



always  @(/*AUTOSENSE*/gbl_red_bank_id or red_reg_enq_01
          or red_reg_enq_23 or red_reg_enq_45 or red_reg_enq_67
          or red_reg_enq_89 or red_reg_enq_ab or red_reg_q_01
          or red_reg_q_23 or red_reg_q_45 or red_reg_q_67
          or red_reg_q_89 or red_reg_q_ab)begin

  	case(gbl_red_bank_id)

	12'b000000000001: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_01[1:0], red_reg_q_01[6:0] } 	 ;
	end
	12'b000000000010: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_01[1:0], red_reg_q_01[6:0] } 	 ;
	end
	12'b000000000100: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_23[1:0], red_reg_q_23[6:0] } 	 ;
	end
	12'b000000001000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_23[1:0], red_reg_q_23[6:0] } 	 ;
	end
	12'b000000010000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_45[1:0], red_reg_q_45[6:0] } 	 ;
	end
	12'b000000100000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_45[1:0], red_reg_q_45[6:0] } 	 ;
	end
	12'b000001000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_67[1:0], red_reg_q_67[6:0] } 	 ;
	end
	12'b000010000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_67[1:0], red_reg_q_67[6:0] } 	 ;
	end
	12'b000100000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_89[1:0], red_reg_q_89[6:0] } 	 ;
	end
	12'b001000000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_89[1:0], red_reg_q_89[6:0] } 	 ;
	end
	12'b010000000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_ab[1:0], red_reg_q_ab[6:0] } 	 ;
	end
	12'b100000000000: begin
		{ l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} =
		{ red_reg_enq_ab[1:0], red_reg_q_ab[6:0] } 	 ;
	end

        default: begin
// JC added begin
// remove implicit latch.
                { l2t_fuse_repair_en[1:0], l2t_fuse_repair_value[6:0]} = 9'b0;
// JCadded end

		 end

	endcase

end

/* bw_r_l2t_subbank 	AUTO_TEMPLATE	 (
                            // Outputs
                            .wayselect0 (way_sel[0]),
                            .wayselect1 (way_sel[1]),
                            .tag_way0   (tag_way0[27:0]),
                            .tag_way1   (tag_way1[27:0]),
                            .red_reg_q_array2(red_reg_q_01[6:0]),
                            .red_reg_enq_array2(red_reg_enq_01[1:0]),
                            // Inputs
                            .way        (way[1:0]),
                            .bist_way   (bist_way[1:0]),
                            .wd_b_l     (wrdata0_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[0]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[1]),
                            .gbl_red_wr_en(wr_en_subbank[0]));

*/

 bw_r_l2t_subbank 	subbank01(/*AUTOINST*/
                              // Outputs
                              .sout     (),                      // Templated
                              .wayselect0(way_sel[0]),           // Templated
                              .wayselect1(way_sel[1]),           // Templated
                              .tag_way0 (tag_way0[27:0]),        // Templated
                              .tag_way1 (tag_way1[27:0]),        // Templated
                              .red_reg_q_array2(red_reg_q_01[6:0]), // Templated
                              .red_reg_enq_array2(red_reg_enq_01[1:0]), // Templated
                              // Inputs
                              .index    (index[9:0]),
                              .bist_index(bist_index[9:0]),
                              .wr_en    (wr_en),
                              .bist_wr_en(bist_wr_en),
                              .rd_en    (rd_en),
                              .bist_rd_en(bist_rd_en),
                              .way      (way[1:0]),              // Templated
                              .bist_way (bist_way[1:0]),         // Templated
                              .wd_b_l   (wrdata0_d1_l[27:0]),    // Templated
                              .lkuptag  (lkup_tag_d1[27:1]),     // Templated
                              .rclk     (rclk),                  // Templated
                              .sehold   (sehold),                // Templated
                              .se       (se),                    // Templated
                              .sin      (),                      // Templated
                              .rst_tri_en(rst_tri_en),           // Templated
                              .arst_l   (arst_l),                // Templated
                              .gbl_red_rid(fuse_l2t_rid[1:0]),   // Templated
                              .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                              .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                              .fclk1    (efc_sctag_fuse_clk1),   // Templated
                              .gbl_red_bank_id_top(gbl_red_bank_id[0]), // Templated
                              .gbl_red_bank_id_bottom(gbl_red_bank_id[1]), // Templated
                              .gbl_red_wr_en(wr_en_subbank[0]));  // Templated

/* bw_r_l2t_subbank     AUTO_TEMPLATE    (
                            // Outputs
                            .wayselect0 (way_sel[4]),
                            .wayselect1 (way_sel[5]),
                            .tag_way0   (tag_way4[27:0]),
                            .tag_way1   (tag_way5[27:0]),
                            .red_reg_q_array2(red_reg_q_45[6:0]),
                            .red_reg_enq_array2(red_reg_enq_45[1:0]),
                            // Inputs
                            .way        (way[5:4]),
                            .bist_way   (bist_way[5:4]),
                            .wd_b_l     (wrdata0_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[4]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[5]),
                            .gbl_red_wr_en(wr_en_subbank[1]));

*/

 bw_r_l2t_subbank 	subbank45(/*AUTOINST*/
                              // Outputs
                              .sout     (),                      // Templated
                              .wayselect0(way_sel[4]),           // Templated
                              .wayselect1(way_sel[5]),           // Templated
                              .tag_way0 (tag_way4[27:0]),        // Templated
                              .tag_way1 (tag_way5[27:0]),        // Templated
                              .red_reg_q_array2(red_reg_q_45[6:0]), // Templated
                              .red_reg_enq_array2(red_reg_enq_45[1:0]), // Templated
                              // Inputs
                              .index    (index[9:0]),
                              .bist_index(bist_index[9:0]),
                              .wr_en    (wr_en),
                              .bist_wr_en(bist_wr_en),
                              .rd_en    (rd_en),
                              .bist_rd_en(bist_rd_en),
                              .way      (way[5:4]),              // Templated
                              .bist_way (bist_way[5:4]),         // Templated
                              .wd_b_l   (wrdata0_d1_l[27:0]),    // Templated
                              .lkuptag  (lkup_tag_d1[27:1]),     // Templated
                              .rclk     (rclk),                  // Templated
                              .sehold   (sehold),                // Templated
                              .se       (se),                    // Templated
                              .sin      (),                      // Templated
                              .rst_tri_en(rst_tri_en),           // Templated
                              .arst_l   (arst_l),                // Templated
                              .gbl_red_rid(fuse_l2t_rid[1:0]),   // Templated
                              .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                              .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                              .fclk1    (efc_sctag_fuse_clk1),   // Templated
                              .gbl_red_bank_id_top(gbl_red_bank_id[4]), // Templated
                              .gbl_red_bank_id_bottom(gbl_red_bank_id[5]), // Templated
                              .gbl_red_wr_en(wr_en_subbank[1]));  // Templated

/* bw_r_l2t_subbank     AUTO_TEMPLATE    (
                            // Outputs
                            .wayselect0 (way_sel[8]),
                            .wayselect1 (way_sel[9]),
                            .tag_way0   (tag_way8[27:0]),
                            .tag_way1   (tag_way9[27:0]),
                            .red_reg_q_array2(red_reg_q_89[6:0]),
                            .red_reg_enq_array2(red_reg_enq_89[1:0]),
                            // Inputs
                            .way        (way[9:8]),
                            .bist_way   (bist_way[9:8]),
                            .wd_b_l     (wrdata0_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[8]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[9]),
                            .gbl_red_wr_en(wr_en_subbank[2]));

*/


 bw_r_l2t_subbank 	subbank89(/*AUTOINST*/
                              // Outputs
                              .sout     (),                      // Templated
                              .wayselect0(way_sel[8]),           // Templated
                              .wayselect1(way_sel[9]),           // Templated
                              .tag_way0 (tag_way8[27:0]),        // Templated
                              .tag_way1 (tag_way9[27:0]),        // Templated
                              .red_reg_q_array2(red_reg_q_89[6:0]), // Templated
                              .red_reg_enq_array2(red_reg_enq_89[1:0]), // Templated
                              // Inputs
                              .index    (index[9:0]),
                              .bist_index(bist_index[9:0]),
                              .wr_en    (wr_en),
                              .bist_wr_en(bist_wr_en),
                              .rd_en    (rd_en),
                              .bist_rd_en(bist_rd_en),
                              .way      (way[9:8]),              // Templated
                              .bist_way (bist_way[9:8]),         // Templated
                              .wd_b_l   (wrdata0_d1_l[27:0]),    // Templated
                              .lkuptag  (lkup_tag_d1[27:1]),     // Templated
                              .rclk     (rclk),                  // Templated
                              .sehold   (sehold),                // Templated
                              .se       (se),                    // Templated
                              .sin      (),                      // Templated
                              .rst_tri_en(rst_tri_en),           // Templated
                              .arst_l   (arst_l),                // Templated
                              .gbl_red_rid(fuse_l2t_rid[1:0]),   // Templated
                              .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                              .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                              .fclk1    (efc_sctag_fuse_clk1),   // Templated
                              .gbl_red_bank_id_top(gbl_red_bank_id[8]), // Templated
                              .gbl_red_bank_id_bottom(gbl_red_bank_id[9]), // Templated
                              .gbl_red_wr_en(wr_en_subbank[2]));  // Templated

/* bw_r_l2t_subbank     AUTO_TEMPLATE    (
                            // Outputs
                            .wayselect0 (way_sel[2]),
                            .wayselect1 (way_sel[3]),
                            .tag_way0   (tag_way2[27:0]),
                            .tag_way1   (tag_way3[27:0]),
                            .red_reg_q_array2(red_reg_q_23[6:0]),
                            .red_reg_enq_array2(red_reg_enq_23[1:0]),
                            // Inputs
                            .way        (way[3:2]),
                            .bist_way   (bist_way[3:2]),
                            .wd_b_l     (wrdata1_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[2]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[3]),
                            .gbl_red_wr_en(wr_en_subbank[3]));

*/

 bw_r_l2t_subbank 	subbank23(/*AUTOINST*/
                              // Outputs
                              .sout     (),                      // Templated
                              .wayselect0(way_sel[2]),           // Templated
                              .wayselect1(way_sel[3]),           // Templated
                              .tag_way0 (tag_way2[27:0]),        // Templated
                              .tag_way1 (tag_way3[27:0]),        // Templated
                              .red_reg_q_array2(red_reg_q_23[6:0]), // Templated
                              .red_reg_enq_array2(red_reg_enq_23[1:0]), // Templated
                              // Inputs
                              .index    (index[9:0]),
                              .bist_index(bist_index[9:0]),
                              .wr_en    (wr_en),
                              .bist_wr_en(bist_wr_en),
                              .rd_en    (rd_en),
                              .bist_rd_en(bist_rd_en),
                              .way      (way[3:2]),              // Templated
                              .bist_way (bist_way[3:2]),         // Templated
                              .wd_b_l   (wrdata1_d1_l[27:0]),    // Templated
                              .lkuptag  (lkup_tag_d1[27:1]),     // Templated
                              .rclk     (rclk),                  // Templated
                              .sehold   (sehold),                // Templated
                              .se       (se),                    // Templated
                              .sin      (),                      // Templated
                              .rst_tri_en(rst_tri_en),           // Templated
                              .arst_l   (arst_l),                // Templated
                              .gbl_red_rid(fuse_l2t_rid[1:0]),   // Templated
                              .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                              .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                              .fclk1    (efc_sctag_fuse_clk1),   // Templated
                              .gbl_red_bank_id_top(gbl_red_bank_id[2]), // Templated
                              .gbl_red_bank_id_bottom(gbl_red_bank_id[3]), // Templated
                              .gbl_red_wr_en(wr_en_subbank[3]));  // Templated

/* bw_r_l2t_subbank     AUTO_TEMPLATE    (
                            // Outputs
                            .wayselect0 (way_sel[6]),
                            .wayselect1 (way_sel[7]),
                            .tag_way0   (tag_way6[27:0]),
                            .tag_way1   (tag_way7[27:0]),
                            .red_reg_q_array2(red_reg_q_67[6:0]),
                            .red_reg_enq_array2(red_reg_enq_67[1:0]),
                            // Inputs
                            .way        (way[7:6]),
                            .bist_way   (bist_way[7:6]),
                            .wd_b_l     (wrdata1_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[6]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[7]),
                            .gbl_red_wr_en(wr_en_subbank[4]));

*/

 bw_r_l2t_subbank       subbank67(/*AUTOINST*/
                                  // Outputs
                                  .sout (),                      // Templated
                                  .wayselect0(way_sel[6]),       // Templated
                                  .wayselect1(way_sel[7]),       // Templated
                                  .tag_way0(tag_way6[27:0]),     // Templated
                                  .tag_way1(tag_way7[27:0]),     // Templated
                                  .red_reg_q_array2(red_reg_q_67[6:0]), // Templated
                                  .red_reg_enq_array2(red_reg_enq_67[1:0]), // Templated
                                  // Inputs
                                  .index(index[9:0]),
                                  .bist_index(bist_index[9:0]),
                                  .wr_en(wr_en),
                                  .bist_wr_en(bist_wr_en),
                                  .rd_en(rd_en),
                                  .bist_rd_en(bist_rd_en),
                                  .way  (way[7:6]),              // Templated
                                  .bist_way(bist_way[7:6]),      // Templated
                                  .wd_b_l(wrdata1_d1_l[27:0]),   // Templated
                                  .lkuptag(lkup_tag_d1[27:1]),   // Templated
                                  .rclk (rclk),                  // Templated
                                  .sehold(sehold),               // Templated
                                  .se   (se),                    // Templated
                                  .sin  (),                      // Templated
                                  .rst_tri_en(rst_tri_en),       // Templated
                                  .arst_l(arst_l),               // Templated
                                  .gbl_red_rid(fuse_l2t_rid[1:0]), // Templated
                                  .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                                  .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                                  .fclk1(efc_sctag_fuse_clk1),   // Templated
                                  .gbl_red_bank_id_top(gbl_red_bank_id[6]), // Templated
                                  .gbl_red_bank_id_bottom(gbl_red_bank_id[7]), // Templated
                                  .gbl_red_wr_en(wr_en_subbank[4])); // Templated

/* bw_r_l2t_subbank     AUTO_TEMPLATE    (
                            // Outputs
                            .wayselect0 (way_sel[10]),
                            .wayselect1 (way_sel[11]),
                            .tag_way0   (tag_way10[27:0]),
                            .tag_way1   (tag_way11[27:0]),
                            .red_reg_q_array2(red_reg_q_ab[6:0]),
                            .red_reg_enq_array2(red_reg_enq_ab[1:0]),
                            // Inputs
                            .way        (way[11:10]),
                            .bist_way   (bist_way[11:10]),
                            .wd_b_l     (wrdata1_d1_l[27:0]),
                            .lkuptag    (lkup_tag_d1[27:1]),
                            .rclk       (rclk),
                            .sehold     (sehold),
                            .se         (se),
                            .sin        (),
                            .sout        (),
                            .rst_tri_en (rst_tri_en),
                            .arst_l     (arst_l),
                            .gbl_red_rid(fuse_l2t_rid[1:0]),
                            .gbl_red_reg_en(fuse_l2t_repair_en[1:0]),
                            .gbl_red_reg_d(fuse_l2t_repair_value[6:0]),
                            .fclk1      (efc_sctag_fuse_clk1),
                            .gbl_red_bank_id_top(gbl_red_bank_id[10]),
                            .gbl_red_bank_id_bottom(gbl_red_bank_id[11]),
                            .gbl_red_wr_en(wr_en_subbank[5]));

*/

 bw_r_l2t_subbank       subbankab(/*AUTOINST*/
                                  // Outputs
                                  .sout (),                      // Templated
                                  .wayselect0(way_sel[10]),      // Templated
                                  .wayselect1(way_sel[11]),      // Templated
                                  .tag_way0(tag_way10[27:0]),    // Templated
                                  .tag_way1(tag_way11[27:0]),    // Templated
                                  .red_reg_q_array2(red_reg_q_ab[6:0]), // Templated
                                  .red_reg_enq_array2(red_reg_enq_ab[1:0]), // Templated
                                  // Inputs
                                  .index(index[9:0]),
                                  .bist_index(bist_index[9:0]),
                                  .wr_en(wr_en),
                                  .bist_wr_en(bist_wr_en),
                                  .rd_en(rd_en),
                                  .bist_rd_en(bist_rd_en),
                                  .way  (way[11:10]),            // Templated
                                  .bist_way(bist_way[11:10]),    // Templated
                                  .wd_b_l(wrdata1_d1_l[27:0]),   // Templated
                                  .lkuptag(lkup_tag_d1[27:1]),   // Templated
                                  .rclk (rclk),                  // Templated
                                  .sehold(sehold),               // Templated
                                  .se   (se),                    // Templated
                                  .sin  (),                      // Templated
                                  .rst_tri_en(rst_tri_en),       // Templated
                                  .arst_l(arst_l),               // Templated
                                  .gbl_red_rid(fuse_l2t_rid[1:0]), // Templated
                                  .gbl_red_reg_en(fuse_l2t_repair_en[1:0]), // Templated
                                  .gbl_red_reg_d(fuse_l2t_repair_value[6:0]), // Templated
                                  .fclk1(efc_sctag_fuse_clk1),   // Templated
                                  .gbl_red_bank_id_top(gbl_red_bank_id[10]), // Templated
                                  .gbl_red_bank_id_bottom(gbl_red_bank_id[11]), // Templated
                                  .gbl_red_wr_en(wr_en_subbank[5])); // Templated


endmodule





module	bw_r_l2t_subbank(/*AUTOARG*/
   // Outputs
   sout, wayselect0, wayselect1, tag_way0, tag_way1, 
   red_reg_q_array2, red_reg_enq_array2, 
   // Inputs
   index, bist_index, wr_en, bist_wr_en, rd_en, bist_rd_en, way, 
   bist_way, wd_b_l, lkuptag, rclk, sehold, se, sin, rst_tri_en, 
   arst_l, gbl_red_rid, gbl_red_reg_en, gbl_red_reg_d, fclk1, 
   gbl_red_bank_id_top, gbl_red_bank_id_bottom, gbl_red_wr_en
   );

// !!! Changed gbl_red_wren to gbl_red_wr_en as it is in schematic !!!

//////////////
// INPUTS
//////////////

input	[9:0]	index;
input	[9:0]	bist_index;
input		wr_en;
input		bist_wr_en;
input		rd_en;
input		bist_rd_en;
input	[1:0]	way;
input	[1:0]	bist_way;

input	[27:0]	wd_b_l ; //inverted data. not flopped here
input	[27:1]	lkuptag; //not flopped here

input		rclk;
input		sehold;
input		se;
input		sin;
input		rst_tri_en;

// not coded in the spec
// arst function

input		arst_l;  // redundancy registers.

input	[1:0]	gbl_red_rid;

input	[1:0]	gbl_red_reg_en;
input	[6:0]	gbl_red_reg_d;

input		fclk1;
input		gbl_red_bank_id_top;
input		gbl_red_bank_id_bottom;

input		gbl_red_wr_en ;

// !!! Changed gbl_red_wren to gbl_red_wr_en as it is in schematic !!!



//////////////
// OUTPUTS
//////////////

output 		sout;
output		wayselect0;
output		wayselect1;

output	[27:0]	tag_way0 ;
output	[27:0]	tag_way1 ;


output	[6:0]	red_reg_q_array2;
output	[1:0]	red_reg_enq_array2;

// !!! Taken out ssclk !!!

// !!! Registering all tag outputs including wayselect as it is how implemented in design !!!
wire		temp_wayselect0; //Registering wayselect signal 
wire		temp_wayselect1; //Registering wayselect signal

reg		wayselect0; // Registering wayselect signal
reg		wayselect1; // Registering wayselect signal

reg	[27:0]	temp_tag_way0 ; // Registering tag read out data 
reg	[27:0]	temp_tag_way1 ; // Registering tag read out data
// !!! Registering all tag outputs including wayselect as it is how implemented in design !!!

reg	[9:0]	index_d1; 
reg	[1:0]	way_d1;
reg		wren_d1, rden_d1 ;
reg             [27:0]  way0[1023:0] ;
reg             [27:0]  way1[1023:0] ;
reg	[27:0]	tag_way0, tag_way1 ;

// JC modified begin
// the size of row redundant register is 1 bit smaller than
// the size of column one.
reg    [7:0]   rid_subbank0_reg0 ;
reg    [7:0]   rid_subbank0_reg1 ;
// JC modified end
reg    [8:0]   rid_subbank0_reg2 ;
reg    [8:0]   rid_subbank0_reg3 ;

// JC modified begin
reg    [7:0]   rid_subbank1_reg0 ;
reg    [7:0]   rid_subbank1_reg1 ;
// JC modified end

reg    [8:0]   rid_subbank1_reg2 ;
reg    [8:0]   rid_subbank1_reg3 ;

reg [1:0]	red_reg_enq_array2;
reg [6:0]	red_reg_q_array2;
wire	[3:0]	red_reg;


////////////////////////////
// REDUNDANCY LOGIC
////////////////////////////
assign	red_reg = { gbl_red_bank_id_top, gbl_red_bank_id_bottom, gbl_red_rid[1:0] };

// JC modified begin
// The following modification include
// 1. the size of row redundant register changes.
// 2. the redundant output does not gate with clock



always	@(posedge fclk1 or arst_l ) begin

	if(!arst_l) begin
		rid_subbank0_reg0 = 8'b0 ;
		rid_subbank0_reg1 = 8'b0 ;
		rid_subbank0_reg2 = 9'b0 ;
		rid_subbank0_reg3 = 9'b0 ;
		rid_subbank1_reg0 = 8'b0 ;
		rid_subbank1_reg1 = 8'b0 ;
		rid_subbank1_reg2 = 9'b0 ;
		rid_subbank1_reg3 = 9'b0 ;
	end
	
	 else if(gbl_red_wr_en) begin
                case(red_reg)

                4'b1000:        rid_subbank0_reg0 = {gbl_red_reg_d[5:0], gbl_red_reg_en[1:0]};

                4'b1001:        rid_subbank0_reg1 = {gbl_red_reg_d[5:0], gbl_red_reg_en[1:0]};

                4'b1010:        rid_subbank0_reg2 = {gbl_red_reg_d[6:0], gbl_red_reg_en[1:0]};

                4'b1011:        rid_subbank0_reg3 = {gbl_red_reg_d[6:0], gbl_red_reg_en[1:0]};

                4'b0100:        rid_subbank1_reg0 = {gbl_red_reg_d[5:0], gbl_red_reg_en[1:0]};

                4'b0101:        rid_subbank1_reg1 = {gbl_red_reg_d[5:0], gbl_red_reg_en[1:0]};

                4'b0110:        rid_subbank1_reg2 = {gbl_red_reg_d[6:0], gbl_red_reg_en[1:0]};

                4'b0111:        rid_subbank1_reg3 = {gbl_red_reg_d[6:0], gbl_red_reg_en[1:0]};

                default: ; // Do nothing

                endcase
        end // of else if

end // of always

always  @( red_reg or rid_subbank0_reg0 or rid_subbank0_reg1 or rid_subbank0_reg2 or rid_subbank0_reg3 or
           rid_subbank1_reg0 or rid_subbank1_reg1 or rid_subbank1_reg2 or rid_subbank1_reg3) begin

                case(red_reg)

                4'b1000:
                { red_reg_q_array2, red_reg_enq_array2 }  = {1'b0,rid_subbank0_reg0};

                4'b1001:
                { red_reg_q_array2, red_reg_enq_array2 }  = {1'b0,rid_subbank0_reg1};

                4'b1010:
                { red_reg_q_array2, red_reg_enq_array2 }  = rid_subbank0_reg2;

                4'b1011:
                { red_reg_q_array2, red_reg_enq_array2 }  = rid_subbank0_reg3;

                4'b0100:
                { red_reg_q_array2, red_reg_enq_array2 }  = {1'b0,rid_subbank1_reg0};

                4'b0101:
                { red_reg_q_array2, red_reg_enq_array2 }  = {1'b0,rid_subbank1_reg1};

                4'b0110:
                { red_reg_q_array2, red_reg_enq_array2 }  = rid_subbank1_reg2;

                4'b0111:
                { red_reg_q_array2, red_reg_enq_array2 }  = rid_subbank1_reg3;

                default:
                { red_reg_q_array2, red_reg_enq_array2 }  = 9'b0;

                endcase
end


always	@(posedge rclk) begin

	index_d1 <= 	( sehold) ? index_d1 :
		( bist_wr_en | bist_rd_en ) ? bist_index : index ;
	way_d1	<= 	(sehold)? way_d1 :
		( bist_wr_en | bist_rd_en ) ? bist_way : way ;
	wren_d1 <= 	( sehold)? wren_d1 :
		( bist_wr_en | wr_en ) ;
	rden_d1 <= 	( sehold)? rden_d1 :  
		( bist_rd_en | rd_en );

end

// !!! Flopping output signals !!!
always	@(posedge rclk) begin
        wayselect0 <= temp_wayselect0;
        wayselect1 <= temp_wayselect1;
	tag_way0 <= temp_tag_way0;
	tag_way1 <= temp_tag_way1;
end
// !!! Flopping output signals !!!

////////////////////////////////
// COMPARE OPERATION 
////////////////////////////////

// !!! Also, we are gating wayselect with rd_en so, in other cycles (write or no op)
// all wayselect signals are miss. !!!
 
assign	temp_wayselect0 = (rden_d1) ? ( lkuptag == temp_tag_way0[27:1] ) : 0 ;
assign	temp_wayselect1 = (rden_d1) ? ( lkuptag == temp_tag_way1[27:1] ) : 0 ;

////////////////////////////////
// READ OPERATION
////////////////////////////////
always	@( /*AUTOSENSE*/ /*memory or*/ index_d1 or rden_d1
          or rst_tri_en or wren_d1) begin

`ifdef	INNO_MUXEX
`else
	if(wren_d1==1'bx) begin
		`ifdef MODELSIM
		       $display("L2_TAG_ERR"," wr en error %b ", wren_d1);
		`else	   
               $error("L2_TAG_ERR"," wr en error %b ", wren_d1);
		`endif	   
        end
`endif


        if( rden_d1)  begin

`ifdef  INNO_MUXEX
`else
//----- PURELY FOR VERIFICATION -----------------------
         if(index_d1==10'bx) begin
		`ifdef MODELSIM
                $display("L2_TAG_ERR"," index error %h ", index_d1[9:0]);
		`else		
                $error("L2_TAG_ERR"," index error %h ", index_d1[9:0]);
		`endif		
         end
//----- PURELY FOR VERIFICATION -----------------------
`endif
	 if( wren_d1 ) 	begin
                temp_tag_way0 = 28'bx ;
                temp_tag_way1 = 28'bx ;
	 end
	 else	begin
                temp_tag_way0 = way0[index_d1] ;
                temp_tag_way1 = way1[index_d1] ;
         end

        end // of if rden_d1

	else  begin
// !!! When Tag is in write or no-op cycles, all output will be "0" since SAs are precharged !!!

                temp_tag_way0 = 0;
                temp_tag_way1 = 0;

        end

end

////////////////////////////////
// WRITE OPERATION 
////////////////////////////////
always	@(negedge rclk ) begin
        if( wren_d1 & ~rst_tri_en) begin

`ifdef	INNO_MUXEX
`else
//----- PURELY FOR VERIFICATION -----------------------
          if(index_d1==10'bx) begin
		`ifdef MODELSIM  
                $display("L2_TAG_ERR"," index error %h ", index_d1[9:0]);
		`else
                $error("L2_TAG_ERR"," index error %h ", index_d1[9:0]);
		`endif		
          end
//----- PURELY FOR VERIFICATION -----------------------
`endif
	       
// !!! When Tag is in write or no-op cycles, all output will be "0" since SAs are precharged !!!

                temp_tag_way0 = 0;
                temp_tag_way1 = 0;

                case(way_d1)
                2'b01 : begin
                                way0[index_d1] = ~wd_b_l;
                          end
                2'b10 : begin
                                way1[index_d1] = ~wd_b_l;
			  end

		default: ; 
                endcase
   	 end
end












endmodule


