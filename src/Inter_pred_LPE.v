//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_pred_LPE.v
// Generated : Oct 11, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Processing Element for Inter prediction of Luma pixels
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_pred_LPE (clk,reset_n,pos_FracL,IsInterLuma,
	blk4x4_inter_calculate_counter,
	Inter_H_window_0_0,Inter_H_window_1_0,Inter_H_window_2_0,Inter_H_window_3_0,Inter_H_window_4_0,Inter_H_window_5_0,
	Inter_H_window_0_1,Inter_H_window_1_1,Inter_H_window_2_1,Inter_H_window_3_1,Inter_H_window_4_1,Inter_H_window_5_1,
	Inter_H_window_0_2,Inter_H_window_1_2,Inter_H_window_2_2,Inter_H_window_3_2,Inter_H_window_4_2,Inter_H_window_5_2,
	Inter_H_window_0_3,Inter_H_window_1_3,Inter_H_window_2_3,Inter_H_window_3_3,Inter_H_window_4_3,Inter_H_window_5_3,
	Inter_H_window_0_4,Inter_H_window_1_4,Inter_H_window_2_4,Inter_H_window_3_4,Inter_H_window_4_4,Inter_H_window_5_4,
	Inter_H_window_0_5,Inter_H_window_1_5,Inter_H_window_2_5,Inter_H_window_3_5,Inter_H_window_4_5,Inter_H_window_5_5,
	Inter_H_window_0_6,Inter_H_window_1_6,Inter_H_window_2_6,Inter_H_window_3_6,Inter_H_window_4_6,Inter_H_window_5_6,
	Inter_H_window_0_7,Inter_H_window_1_7,Inter_H_window_2_7,Inter_H_window_3_7,Inter_H_window_4_7,Inter_H_window_5_7,
	Inter_H_window_0_8,Inter_H_window_1_8,Inter_H_window_2_8,Inter_H_window_3_8,Inter_H_window_4_8,Inter_H_window_5_8,
	Inter_V_window_0,Inter_V_window_1,Inter_V_window_2,Inter_V_window_3,Inter_V_window_4,
	Inter_V_window_5,Inter_V_window_6,Inter_V_window_7,Inter_V_window_8,
	Inter_bi_window_0,Inter_bi_window_1,Inter_bi_window_2,Inter_bi_window_3,
	
	LPE0_out,LPE1_out,LPE2_out,LPE3_out
	);
	input clk,reset_n;
	input [3:0] pos_FracL;
	input IsInterLuma;
	input [3:0] blk4x4_inter_calculate_counter;
	
	input [7:0] Inter_H_window_0_0,Inter_H_window_1_0,Inter_H_window_2_0,Inter_H_window_3_0,Inter_H_window_4_0,Inter_H_window_5_0;
	input [7:0] Inter_H_window_0_1,Inter_H_window_1_1,Inter_H_window_2_1,Inter_H_window_3_1,Inter_H_window_4_1,Inter_H_window_5_1;
	input [7:0] Inter_H_window_0_2,Inter_H_window_1_2,Inter_H_window_2_2,Inter_H_window_3_2,Inter_H_window_4_2,Inter_H_window_5_2;
	input [7:0] Inter_H_window_0_3,Inter_H_window_1_3,Inter_H_window_2_3,Inter_H_window_3_3,Inter_H_window_4_3,Inter_H_window_5_3;
	input [7:0] Inter_H_window_0_4,Inter_H_window_1_4,Inter_H_window_2_4,Inter_H_window_3_4,Inter_H_window_4_4,Inter_H_window_5_4;
	input [7:0] Inter_H_window_0_5,Inter_H_window_1_5,Inter_H_window_2_5,Inter_H_window_3_5,Inter_H_window_4_5,Inter_H_window_5_5;
	input [7:0] Inter_H_window_0_6,Inter_H_window_1_6,Inter_H_window_2_6,Inter_H_window_3_6,Inter_H_window_4_6,Inter_H_window_5_6;
	input [7:0] Inter_H_window_0_7,Inter_H_window_1_7,Inter_H_window_2_7,Inter_H_window_3_7,Inter_H_window_4_7,Inter_H_window_5_7;
	input [7:0] Inter_H_window_0_8,Inter_H_window_1_8,Inter_H_window_2_8,Inter_H_window_3_8,Inter_H_window_4_8,Inter_H_window_5_8;
	input [7:0] Inter_V_window_0,Inter_V_window_1,Inter_V_window_2,Inter_V_window_3,Inter_V_window_4;
	input [7:0] Inter_V_window_5,Inter_V_window_6,Inter_V_window_7,Inter_V_window_8;
	input [7:0] Inter_bi_window_0,Inter_bi_window_1,Inter_bi_window_2,Inter_bi_window_3;
	
	output [7:0] LPE0_out,LPE1_out,LPE2_out,LPE3_out;
	
	reg [7:0] LPE0_out,LPE1_out,LPE2_out,LPE3_out;
	
	reg [14:0] b0_raw_reg,b1_raw_reg,b2_raw_reg,b3_raw_reg,b4_raw_reg,b5_raw_reg,b6_raw_reg,b7_raw_reg,b8_raw_reg;
	reg [7:0] b0_reg,b1_reg,b2_reg,b3_reg;
	reg [7:0] h0_reg,h1_reg,h2_reg,h3_reg;
	//------------------------
	//Vertical 6tap filter
	//------------------------
	wire Is_V_jfqik; //Is_V_jfqik: whether read from original [7:0] integer pixels and round as +16 >> 5 or read from b_raw[14:0] and round as +512 >> 10
	wire [14:0] V_6tapfilter0_A,V_6tapfilter0_B,V_6tapfilter0_C,V_6tapfilter0_D,V_6tapfilter0_E,V_6tapfilter0_F;	
	wire [14:0] V_6tapfilter1_A,V_6tapfilter1_B,V_6tapfilter1_C,V_6tapfilter1_D,V_6tapfilter1_E,V_6tapfilter1_F;
	wire [14:0] V_6tapfilter2_A,V_6tapfilter2_B,V_6tapfilter2_C,V_6tapfilter2_D,V_6tapfilter2_E,V_6tapfilter2_F;
	wire [14:0] V_6tapfilter3_A,V_6tapfilter3_B,V_6tapfilter3_C,V_6tapfilter3_D,V_6tapfilter3_E,V_6tapfilter3_F;
	wire [7:0] V_6tapfilter0_round_out,V_6tapfilter1_round_out,V_6tapfilter2_round_out,V_6tapfilter3_round_out;
	filterV_6tap V_6tapfilter0 (
		.A(V_6tapfilter0_A),
		.B(V_6tapfilter0_B),
		.C(V_6tapfilter0_C),
		.D(V_6tapfilter0_D),
		.E(V_6tapfilter0_E),
		.F(V_6tapfilter0_F),
		.Is_jfqik(Is_V_jfqik),
		.round_out(V_6tapfilter0_round_out)
		);
	filterV_6tap V_6tapfilter1 (
		.A(V_6tapfilter1_A),
		.B(V_6tapfilter1_B),
		.C(V_6tapfilter1_C),
		.D(V_6tapfilter1_D),
		.E(V_6tapfilter1_E),
		.F(V_6tapfilter1_F),
		.Is_jfqik(Is_V_jfqik),
		.round_out(V_6tapfilter1_round_out)
		);
	filterV_6tap V_6tapfilter2 (
		.A(V_6tapfilter2_A),
		.B(V_6tapfilter2_B),
		.C(V_6tapfilter2_C),
		.D(V_6tapfilter2_D),
		.E(V_6tapfilter2_E),
		.F(V_6tapfilter2_F),
		.Is_jfqik(Is_V_jfqik),
		.round_out(V_6tapfilter2_round_out)
		);
	filterV_6tap V_6tapfilter3 (
		.A(V_6tapfilter3_A),
		.B(V_6tapfilter3_B),
		.C(V_6tapfilter3_C),
		.D(V_6tapfilter3_D),
		.E(V_6tapfilter3_E),
		.F(V_6tapfilter3_F),
		.Is_jfqik(Is_V_jfqik),
		.round_out(V_6tapfilter3_round_out)
		);
	assign Is_V_jfqik = (
	(pos_FracL == `pos_j && (
			blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd3 ||
			blk4x4_inter_calculate_counter == 4'd2 || blk4x4_inter_calculate_counter == 4'd1)) 	||
	((pos_FracL == `pos_f || pos_FracL == `pos_q) && (	
			blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd3 ||
			blk4x4_inter_calculate_counter == 4'd2 || blk4x4_inter_calculate_counter == 4'd1))	||
	((pos_FracL == `pos_i || pos_FracL == `pos_k) && (	
			blk4x4_inter_calculate_counter == 4'd7 || blk4x4_inter_calculate_counter == 4'd5 ||
			blk4x4_inter_calculate_counter == 4'd3 || blk4x4_inter_calculate_counter == 4'd1)))? 1'b1:1'b0;	
	
	assign V_6tapfilter0_A = (Is_V_jfqik)? b0_raw_reg:{7'b0,Inter_V_window_0};
	assign V_6tapfilter0_B = (Is_V_jfqik)? b1_raw_reg:{7'b0,Inter_V_window_1};
	assign V_6tapfilter0_C = (Is_V_jfqik)? b2_raw_reg:{7'b0,Inter_V_window_2};
	assign V_6tapfilter0_D = (Is_V_jfqik)? b3_raw_reg:{7'b0,Inter_V_window_3};
	assign V_6tapfilter0_E = (Is_V_jfqik)? b4_raw_reg:{7'b0,Inter_V_window_4};
	assign V_6tapfilter0_F = (Is_V_jfqik)? b5_raw_reg:{7'b0,Inter_V_window_5};
	
	assign V_6tapfilter1_A = (Is_V_jfqik)? b1_raw_reg:{7'b0,Inter_V_window_1};
	assign V_6tapfilter1_B = (Is_V_jfqik)? b2_raw_reg:{7'b0,Inter_V_window_2};
	assign V_6tapfilter1_C = (Is_V_jfqik)? b3_raw_reg:{7'b0,Inter_V_window_3};
	assign V_6tapfilter1_D = (Is_V_jfqik)? b4_raw_reg:{7'b0,Inter_V_window_4};
	assign V_6tapfilter1_E = (Is_V_jfqik)? b5_raw_reg:{7'b0,Inter_V_window_5};
	assign V_6tapfilter1_F = (Is_V_jfqik)? b6_raw_reg:{7'b0,Inter_V_window_6};
	
	assign V_6tapfilter2_A = (Is_V_jfqik)? b2_raw_reg:{7'b0,Inter_V_window_2};
	assign V_6tapfilter2_B = (Is_V_jfqik)? b3_raw_reg:{7'b0,Inter_V_window_3};
	assign V_6tapfilter2_C = (Is_V_jfqik)? b4_raw_reg:{7'b0,Inter_V_window_4};
	assign V_6tapfilter2_D = (Is_V_jfqik)? b5_raw_reg:{7'b0,Inter_V_window_5};
	assign V_6tapfilter2_E = (Is_V_jfqik)? b6_raw_reg:{7'b0,Inter_V_window_6};
	assign V_6tapfilter2_F = (Is_V_jfqik)? b7_raw_reg:{7'b0,Inter_V_window_7};
	
	assign V_6tapfilter3_A = (Is_V_jfqik)? b3_raw_reg:{7'b0,Inter_V_window_3};
	assign V_6tapfilter3_B = (Is_V_jfqik)? b4_raw_reg:{7'b0,Inter_V_window_4};
	assign V_6tapfilter3_C = (Is_V_jfqik)? b5_raw_reg:{7'b0,Inter_V_window_5};
	assign V_6tapfilter3_D = (Is_V_jfqik)? b6_raw_reg:{7'b0,Inter_V_window_6};
	assign V_6tapfilter3_E = (Is_V_jfqik)? b7_raw_reg:{7'b0,Inter_V_window_7};
	assign V_6tapfilter3_F = (Is_V_jfqik)? b8_raw_reg:{7'b0,Inter_V_window_8};
			
	//------------------------
	//Horizontal 6tap filter
	//------------------------
	wire H_need_round;
	wire [14:0] H_6tapfilter0_raw_out;
	wire [14:0] H_6tapfilter1_raw_out;
	wire [14:0] H_6tapfilter2_raw_out;
	wire [14:0] H_6tapfilter3_raw_out;
	wire [14:0] H_6tapfilter4_raw_out;
	wire [14:0] H_6tapfilter5_raw_out;
	wire [14:0] H_6tapfilter6_raw_out;
	wire [14:0] H_6tapfilter7_raw_out;
	wire [14:0] H_6tapfilter8_raw_out;
	wire [7:0]  H_6tapfilter0_round_out;
	wire [7:0]  H_6tapfilter1_round_out;
	wire [7:0]  H_6tapfilter2_round_out;
	wire [7:0]  H_6tapfilter3_round_out;
	wire [7:0]  H_6tapfilter4_round_out;
	wire [7:0]  H_6tapfilter5_round_out;
	wire [7:0]  H_6tapfilter6_round_out;
	wire [7:0]  H_6tapfilter7_round_out;
	wire [7:0]  H_6tapfilter8_round_out;
	
	assign H_need_round = (blk4x4_inter_calculate_counter != 0 && pos_FracL != `pos_Int && pos_FracL != `pos_i 
	&& pos_FracL != `pos_j && pos_FracL != `pos_k && pos_FracL != `pos_d && pos_FracL != `pos_n); 
	
	filterH_6tap H_6tapfilter0 (
		.A(Inter_H_window_0_0),
		.B(Inter_H_window_1_0),
		.C(Inter_H_window_2_0),
		.D(Inter_H_window_3_0),
		.E(Inter_H_window_4_0),
		.F(Inter_H_window_5_0),
		.H_need_round(1'b0),
		.raw_out(H_6tapfilter0_raw_out),
		.round_out(H_6tapfilter0_round_out)
		);
	filterH_6tap H_6tapfilter1 (
		.A(Inter_H_window_0_1),
		.B(Inter_H_window_1_1),
		.C(Inter_H_window_2_1),
		.D(Inter_H_window_3_1),
		.E(Inter_H_window_4_1),
		.F(Inter_H_window_5_1),
		.H_need_round(1'b0),
		.raw_out(H_6tapfilter1_raw_out),
		.round_out(H_6tapfilter1_round_out)
		);
	filterH_6tap H_6tapfilter2 (
		.A(Inter_H_window_0_2),
		.B(Inter_H_window_1_2),
		.C(Inter_H_window_2_2),
		.D(Inter_H_window_3_2),
		.E(Inter_H_window_4_2),
		.F(Inter_H_window_5_2),
		.H_need_round(H_need_round),
		.raw_out(H_6tapfilter2_raw_out),
		.round_out(H_6tapfilter2_round_out)
		);
	filterH_6tap H_6tapfilter3 (
		.A(Inter_H_window_0_3),
		.B(Inter_H_window_1_3),
		.C(Inter_H_window_2_3),
		.D(Inter_H_window_3_3),
		.E(Inter_H_window_4_3),
		.F(Inter_H_window_5_3),
		.H_need_round(H_need_round),
		.raw_out(H_6tapfilter3_raw_out),
		.round_out(H_6tapfilter3_round_out)
		);
	filterH_6tap H_6tapfilter4 (
		.A(Inter_H_window_0_4),
		.B(Inter_H_window_1_4),
		.C(Inter_H_window_2_4),
		.D(Inter_H_window_3_4),
		.E(Inter_H_window_4_4),
		.F(Inter_H_window_5_4),
		.H_need_round(H_need_round),
		.raw_out(H_6tapfilter4_raw_out),
		.round_out(H_6tapfilter4_round_out)
		);
	filterH_6tap H_6tapfilter5 (
		.A(Inter_H_window_0_5),
		.B(Inter_H_window_1_5),
		.C(Inter_H_window_2_5),
		.D(Inter_H_window_3_5),
		.E(Inter_H_window_4_5),
		.F(Inter_H_window_5_5),
		.H_need_round(H_need_round),
		.raw_out(H_6tapfilter5_raw_out),
		.round_out(H_6tapfilter5_round_out)
		);
	filterH_6tap H_6tapfilter6 (
		.A(Inter_H_window_0_6),
		.B(Inter_H_window_1_6),
		.C(Inter_H_window_2_6),
		.D(Inter_H_window_3_6),
		.E(Inter_H_window_4_6),
		.F(Inter_H_window_5_6),
		.H_need_round(H_need_round),
		.raw_out(H_6tapfilter6_raw_out),
		.round_out(H_6tapfilter6_round_out)
		);
	filterH_6tap H_6tapfilter7 (
		.A(Inter_H_window_0_7),
		.B(Inter_H_window_1_7),
		.C(Inter_H_window_2_7),
		.D(Inter_H_window_3_7),
		.E(Inter_H_window_4_7),
		.F(Inter_H_window_5_7),
		.H_need_round(1'b0),
		.raw_out(H_6tapfilter7_raw_out),
		.round_out(H_6tapfilter7_round_out)
		);
	filterH_6tap H_6tapfilter8 (
		.A(Inter_H_window_0_8),
		.B(Inter_H_window_1_8),
		.C(Inter_H_window_2_8),
		.D(Inter_H_window_3_8),
		.E(Inter_H_window_4_8),
		.F(Inter_H_window_5_8),
		.H_need_round(1'b0),
		.raw_out(H_6tapfilter8_raw_out),
		.round_out(H_6tapfilter8_round_out)
		);
	
	//--------------------
	//bilinear filter
	//--------------------
	reg [7:0] bilinear0_A,bilinear0_B;
	reg [7:0] bilinear1_A,bilinear1_B;
	reg [7:0] bilinear2_A,bilinear2_B;
	reg [7:0] bilinear3_A,bilinear3_B;
	wire [7:0] bilinear0_out;
	wire [7:0] bilinear1_out;
	wire [7:0] bilinear2_out; 
	wire [7:0] bilinear3_out;
	bilinear bilinear0 (
		.A(bilinear0_A),
		.B(bilinear0_B),
		.bilinear_out(bilinear0_out)
		);
	bilinear bilinear1 (
		.A(bilinear1_A),
		.B(bilinear1_B),
		.bilinear_out(bilinear1_out)
		);
	bilinear bilinear2 (
		.A(bilinear2_A),
		.B(bilinear2_B),
		.bilinear_out(bilinear2_out)
		);
	bilinear bilinear3 (
		.A(bilinear3_A),
		.B(bilinear3_B),
		.bilinear_out(bilinear3_out)
		);
	always @ (IsInterLuma or pos_FracL or blk4x4_inter_calculate_counter
		or Inter_bi_window_0 or Inter_bi_window_1 or Inter_bi_window_2 or Inter_bi_window_3
		or H_6tapfilter2_round_out or H_6tapfilter3_round_out or H_6tapfilter4_round_out or H_6tapfilter5_round_out
		or V_6tapfilter0_round_out or V_6tapfilter1_round_out or V_6tapfilter2_round_out or V_6tapfilter3_round_out
		or b0_reg or b1_reg or b2_reg or b3_reg or h0_reg or h1_reg or h2_reg or h3_reg)
		if (IsInterLuma)
			case ({pos_FracL})
				`pos_a,`pos_c:
				if (blk4x4_inter_calculate_counter != 4'd0)
					begin 
						bilinear0_A <= Inter_bi_window_0; bilinear0_B <= H_6tapfilter2_round_out;
						bilinear1_A <= Inter_bi_window_1; bilinear1_B <= H_6tapfilter3_round_out;
						bilinear2_A <= Inter_bi_window_2; bilinear2_B <= H_6tapfilter4_round_out;
						bilinear3_A <= Inter_bi_window_3; bilinear3_B <= H_6tapfilter5_round_out;
					end
				else 
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
				`pos_d,`pos_n:
				if (blk4x4_inter_calculate_counter != 4'd0)
					begin 
						bilinear0_A <= Inter_bi_window_0; bilinear0_B <= V_6tapfilter0_round_out;
						bilinear1_A <= Inter_bi_window_1; bilinear1_B <= V_6tapfilter1_round_out;
						bilinear2_A <= Inter_bi_window_2; bilinear2_B <= V_6tapfilter2_round_out;
						bilinear3_A <= Inter_bi_window_3; bilinear3_B <= V_6tapfilter3_round_out;
					end
				else 
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
				`pos_e,`pos_g,`pos_p,`pos_r:
				if (blk4x4_inter_calculate_counter != 4'd0)
					begin 
						bilinear0_A <= H_6tapfilter2_round_out;	bilinear0_B <= V_6tapfilter0_round_out;
						bilinear1_A <= H_6tapfilter3_round_out;	bilinear1_B <= V_6tapfilter1_round_out;
						bilinear2_A <= H_6tapfilter4_round_out;	bilinear2_B <= V_6tapfilter2_round_out;
						bilinear3_A <= H_6tapfilter5_round_out;	bilinear3_B <= V_6tapfilter3_round_out;
					end
				else
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
				`pos_i,`pos_k:
				if (blk4x4_inter_calculate_counter == 4'd7 || blk4x4_inter_calculate_counter == 4'd5 ||
					blk4x4_inter_calculate_counter == 4'd3 || blk4x4_inter_calculate_counter == 4'd1)
					begin 
						bilinear0_A <= h0_reg; 	bilinear0_B <= V_6tapfilter0_round_out;
						bilinear1_A <= h1_reg; 	bilinear1_B <= V_6tapfilter1_round_out;
						bilinear2_A <= h2_reg; 	bilinear2_B <= V_6tapfilter2_round_out;
						bilinear3_A <= h3_reg; 	bilinear3_B <= V_6tapfilter3_round_out;
					end
				else 
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
				`pos_f,`pos_q:
				if (blk4x4_inter_calculate_counter != 4'd5 && blk4x4_inter_calculate_counter != 4'd0)
					begin 
						bilinear0_A <= b0_reg;	bilinear0_B <= V_6tapfilter0_round_out;
						bilinear1_A <= b1_reg;	bilinear1_B <= V_6tapfilter1_round_out;
						bilinear2_A <= b2_reg;	bilinear2_B <= V_6tapfilter2_round_out;
						bilinear3_A <= b3_reg;	bilinear3_B <= V_6tapfilter3_round_out;
					end
				else
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
				default:
					begin 
						bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
						bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
					end
			endcase
		else
			begin 
				bilinear0_A <= 0; bilinear0_B <= 0; bilinear1_A <= 0; bilinear1_B <= 0;
				bilinear2_A <= 0; bilinear2_B <= 0; bilinear3_A <= 0; bilinear3_B <= 0;
			end
			
	//------------------------------------------------------------------------------------------		
	//only "b","h" and "j" of half-pel positions need to be stored to predict quater-pel samples
	//------------------------------------------------------------------------------------------
	
	//b0_raw_reg0 ~ b8_raw_reg:update after j/f/q/i/k horizontal filtering
	wire b_raw_reg_ena;
	assign b_raw_reg_ena = (IsInterLuma && 
	((pos_FracL == `pos_j && blk4x4_inter_calculate_counter != 4'd1 && blk4x4_inter_calculate_counter != 4'd0) ||
	((pos_FracL == `pos_f || pos_FracL == `pos_q) && (blk4x4_inter_calculate_counter == 4'd5 || 
												    blk4x4_inter_calculate_counter == 4'd4 ||
												    blk4x4_inter_calculate_counter == 4'd3 ||
												    blk4x4_inter_calculate_counter == 4'd2))	||
	((pos_FracL == `pos_i || pos_FracL == `pos_k) && (blk4x4_inter_calculate_counter == 4'd8 || 
													blk4x4_inter_calculate_counter == 4'd6 ||
													blk4x4_inter_calculate_counter == 4'd4 ||
													blk4x4_inter_calculate_counter == 4'd2))));
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				b0_raw_reg <= 0; b1_raw_reg <= 0; b2_raw_reg <= 0; b3_raw_reg <= 0; b4_raw_reg <= 0;
				b5_raw_reg <= 0; b6_raw_reg <= 0; b7_raw_reg <= 0; b8_raw_reg <= 0; 
			end
		else if (b_raw_reg_ena)
			begin
				b0_raw_reg <= H_6tapfilter0_raw_out;b1_raw_reg <= H_6tapfilter1_raw_out;b2_raw_reg <= H_6tapfilter2_raw_out;
				b3_raw_reg <= H_6tapfilter3_raw_out;b4_raw_reg <= H_6tapfilter4_raw_out;b5_raw_reg <= H_6tapfilter5_raw_out;
				b6_raw_reg <= H_6tapfilter6_raw_out;b7_raw_reg <= H_6tapfilter7_raw_out;b8_raw_reg <= H_6tapfilter8_raw_out;
			end
			
	//b0_reg ~ b3_reg:update for decoding f,q
	//Note:position q needs "b" of next line
	wire b_reg_ena;
	assign b_reg_ena = (IsInterLuma && ((pos_FracL == `pos_f || pos_FracL == `pos_q) && (blk4x4_inter_calculate_counter == 4'd5 ||
	blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd3 || blk4x4_inter_calculate_counter == 4'd2)));
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				b0_reg <= 0; b1_reg <= 0; b2_reg <= 0; b3_reg <= 0;
			end
		else if (b_reg_ena)	
			begin
				if (pos_FracL == `pos_q)
					begin
						b0_reg <= H_6tapfilter3_round_out; b1_reg <= H_6tapfilter4_round_out;
						b2_reg <= H_6tapfilter5_round_out; b3_reg <= H_6tapfilter6_round_out;
					end
				else	
					begin
						b0_reg <= H_6tapfilter2_round_out; b1_reg <= H_6tapfilter3_round_out;
						b2_reg <= H_6tapfilter4_round_out; b3_reg <= H_6tapfilter5_round_out;
					end
			end
			
	//h0_reg ~ h3_reg:update for decoding i,k
	wire h_reg_ena;
	assign h_reg_ena = (IsInterLuma && ((pos_FracL == `pos_i || pos_FracL == `pos_k) && (blk4x4_inter_calculate_counter == 4'd8 ||
	blk4x4_inter_calculate_counter == 4'd6 || blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd2)));
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				h0_reg <= 0; h1_reg <= 0; h2_reg <= 0; h3_reg <= 0;
			end
		else if (h_reg_ena)
			begin
				h0_reg <= V_6tapfilter0_round_out; h1_reg <= V_6tapfilter1_round_out;
				h2_reg <= V_6tapfilter2_round_out; h3_reg <= V_6tapfilter3_round_out;
			end
	//------------------------------------------------------------------------------------------		
	//LPE output
	//------------------------------------------------------------------------------------------
	always @ (IsInterLuma or pos_FracL or blk4x4_inter_calculate_counter  
		or V_6tapfilter0_round_out or V_6tapfilter1_round_out or V_6tapfilter2_round_out or V_6tapfilter3_round_out
		or H_6tapfilter2_round_out or H_6tapfilter3_round_out or H_6tapfilter4_round_out or H_6tapfilter5_round_out
		or bilinear0_out or bilinear1_out or bilinear2_out or bilinear3_out)
		if (IsInterLuma)
			case (pos_FracL)
				//pos_Int: directly bypassed by Inter_pix_copy0 ~ Inter_pix_copy3
				`pos_b:
				if (blk4x4_inter_calculate_counter != 0)
					begin
						LPE0_out <= H_6tapfilter2_round_out; LPE1_out <= H_6tapfilter3_round_out;
						LPE2_out <= H_6tapfilter4_round_out; LPE3_out <= H_6tapfilter5_round_out;	
					end
				else
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
				`pos_h:
				if (blk4x4_inter_calculate_counter != 0)
					begin
						LPE0_out <= V_6tapfilter0_round_out; LPE1_out <= V_6tapfilter1_round_out;
						LPE2_out <= V_6tapfilter2_round_out; LPE3_out <= V_6tapfilter3_round_out;	
					end
				else
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
				`pos_j:
				if (blk4x4_inter_calculate_counter != 4'd5 && blk4x4_inter_calculate_counter != 0)
					begin
						LPE0_out <= V_6tapfilter0_round_out; LPE1_out <= V_6tapfilter1_round_out;
						LPE2_out <= V_6tapfilter2_round_out; LPE3_out <= V_6tapfilter3_round_out;	
					end
				else
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end	
				`pos_a,`pos_c,`pos_d,`pos_e,`pos_g,`pos_n,`pos_p,`pos_r,`pos_f,`pos_q:
				if (blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd3 ||
					blk4x4_inter_calculate_counter == 4'd2 || blk4x4_inter_calculate_counter == 4'd1)
					begin
						LPE0_out <= bilinear0_out; LPE1_out <= bilinear1_out;
						LPE2_out <= bilinear2_out; LPE3_out <= bilinear3_out;	
					end
				else
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
				`pos_i,`pos_k:
				if (blk4x4_inter_calculate_counter == 4'd7 || blk4x4_inter_calculate_counter == 4'd5 ||
					blk4x4_inter_calculate_counter == 4'd3 || blk4x4_inter_calculate_counter == 4'd1)
					begin
						LPE0_out <= bilinear0_out; LPE1_out <= bilinear1_out;
						LPE2_out <= bilinear2_out; LPE3_out <= bilinear3_out;	
					end
				else
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
				default:
					begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
			endcase
		else 
			begin LPE0_out <= 0; LPE1_out <= 0;LPE2_out <= 0; LPE3_out <= 0;end
			
endmodule

module filterH_6tap(A,B,C,D,E,F,H_need_round,raw_out,round_out);
	input [7:0] A,B,C,D,E,F;
	input H_need_round;
	output [14:0] raw_out; 	//always output
	output [7:0]  round_out;
	
	wire [8:0] sum_AF;
	wire [8:0] sum_BE;
	wire [8:0] sum_CD;
	wire [10:0] sum_4CD;
	wire [11:0] sum_1;
	wire [12:0] sum_2;
	wire [13:0] sum_3;
	wire [14:0] sum_round;
	wire [9:0] round_tmp;
	
	assign sum_AF = A + F;
	assign sum_BE = B + E;
	assign sum_CD = C + D;
	assign sum_4CD = {sum_CD,2'b0};
	assign sum_1 = {1'b0,sum_4CD} + {3'b111,~sum_BE} + 1;
	assign sum_2 = {4'b0,sum_AF} + {sum_1[11],sum_1};
	assign sum_3 = {sum_1,2'b0};
	assign raw_out = {{2{sum_2[12]}},sum_2} + {sum_3[13],sum_3};
	//round
	assign sum_round = (H_need_round)? (raw_out + 16):0;
	assign round_tmp = (H_need_round)? sum_round[14:5]:0;
	assign round_out = (round_tmp[9])? 8'd0:((round_tmp[8])? 8'd255:round_tmp[7:0]);
endmodule

module filterV_6tap(A,B,C,D,E,F,Is_jfqik,round_out);
	input [14:0] A,B,C,D,E,F;
	input Is_jfqik;
	output [7:0] round_out;
	
	wire [15:0] sum_AF;
	wire [15:0] sum_BE;
	wire [15:0] sum_CD;
	wire [17:0] sum_4CD;
	wire [17:0] sum_1;
	wire [17:0] sum_2;
	wire [19:0] sum_3;
	wire [19:0] raw_out;
	
	wire [19:0] sum_round;
	wire [9:0] round_tmp;
	
	assign sum_AF = {A[14],A} + {F[14],F};
	assign sum_BE = {B[14],B} + {E[14],E};
	assign sum_CD = {C[14],C} + {D[14],D};
	assign sum_4CD = {sum_CD,2'b0};
	assign sum_1 = sum_4CD + {~sum_BE[15],~sum_BE[15],~sum_BE} + 1;
	assign sum_2 = {{2{sum_AF[15]}},sum_AF} + sum_1;
	assign sum_3 = {sum_1,2'b0};
	assign raw_out = {{2{sum_2[17]}},sum_2} + sum_3;
	//round
	assign sum_round = (Is_jfqik)? (raw_out + 512):(raw_out + 16);
	assign round_tmp = (Is_jfqik)? sum_round[19:10]:sum_round[14:5];
	assign round_out = (round_tmp[9])? 8'd0:((round_tmp[8])? 8'd255:round_tmp[7:0]);
endmodule

module bilinear (A,B,bilinear_out);
	input [7:0] A,B;
	output [7:0] bilinear_out;
	wire [8:0] sum_AB;
	
	assign sum_AB = A + B + 1; //here A and B should NOT extend as {A[7],A}
	assign bilinear_out = sum_AB[8:1];
endmodule
	
	
	