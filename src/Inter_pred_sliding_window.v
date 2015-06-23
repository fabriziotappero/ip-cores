//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_pred_sliding_window.v
// Generated : Oct 25, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Prepare the appropriate registers for Inter prediction (luma & chroma) 
// 1)Luma:horizontal window 6x9,vertical window 1x9
// 2)Chroma:window 2x2
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_pred_sliding_window (IsInterLuma,IsInterChroma,Is_InterChromaCopy,mv_below8x8_curr,
	pos_FracL,blk4x4_rec_counter_1to0,blk4x4_inter_calculate_counter,
	Inter_ref_00_00,Inter_ref_01_00,Inter_ref_02_00,Inter_ref_03_00,Inter_ref_04_00,Inter_ref_05_00,
	Inter_ref_06_00,Inter_ref_07_00,Inter_ref_08_00,Inter_ref_09_00,Inter_ref_10_00,Inter_ref_11_00,Inter_ref_12_00,
	Inter_ref_00_01,Inter_ref_01_01,Inter_ref_02_01,Inter_ref_03_01,Inter_ref_04_01,Inter_ref_05_01,
	Inter_ref_06_01,Inter_ref_07_01,Inter_ref_08_01,Inter_ref_09_01,Inter_ref_10_01,Inter_ref_11_01,Inter_ref_12_01,
	Inter_ref_00_02,Inter_ref_01_02,Inter_ref_02_02,Inter_ref_03_02,Inter_ref_04_02,Inter_ref_05_02,
	Inter_ref_06_02,Inter_ref_07_02,Inter_ref_08_02,Inter_ref_09_02,Inter_ref_10_02,Inter_ref_11_02,Inter_ref_12_02,
	Inter_ref_00_03,Inter_ref_01_03,Inter_ref_02_03,Inter_ref_03_03,Inter_ref_04_03,Inter_ref_05_03,
	Inter_ref_06_03,Inter_ref_07_03,Inter_ref_08_03,Inter_ref_09_03,Inter_ref_10_03,Inter_ref_11_03,Inter_ref_12_03,
	Inter_ref_00_04,Inter_ref_01_04,Inter_ref_02_04,Inter_ref_03_04,Inter_ref_04_04,Inter_ref_05_04,
	Inter_ref_06_04,Inter_ref_07_04,Inter_ref_08_04,Inter_ref_09_04,Inter_ref_10_04,Inter_ref_11_04,Inter_ref_12_04,
	Inter_ref_00_05,Inter_ref_01_05,Inter_ref_02_05,Inter_ref_03_05,Inter_ref_04_05,Inter_ref_05_05,
	Inter_ref_06_05,Inter_ref_07_05,Inter_ref_08_05,Inter_ref_09_05,Inter_ref_10_05,Inter_ref_11_05,Inter_ref_12_05,
	Inter_ref_00_06,Inter_ref_01_06,Inter_ref_02_06,Inter_ref_03_06,Inter_ref_04_06,Inter_ref_05_06,
	Inter_ref_06_06,Inter_ref_07_06,Inter_ref_08_06,Inter_ref_09_06,Inter_ref_10_06,Inter_ref_11_06,Inter_ref_12_06,
	Inter_ref_00_07,Inter_ref_01_07,Inter_ref_02_07,Inter_ref_03_07,Inter_ref_04_07,Inter_ref_05_07,
	Inter_ref_06_07,Inter_ref_07_07,Inter_ref_08_07,Inter_ref_09_07,Inter_ref_10_07,Inter_ref_11_07,Inter_ref_12_07,
	Inter_ref_00_08,Inter_ref_01_08,Inter_ref_02_08,Inter_ref_03_08,Inter_ref_04_08,Inter_ref_05_08,
	Inter_ref_06_08,Inter_ref_07_08,Inter_ref_08_08,Inter_ref_09_08,Inter_ref_10_08,Inter_ref_11_08,Inter_ref_12_08,
	Inter_ref_00_09,Inter_ref_01_09,Inter_ref_02_09,Inter_ref_03_09,Inter_ref_04_09,Inter_ref_05_09,
	Inter_ref_06_09,Inter_ref_07_09,Inter_ref_08_09,Inter_ref_09_09,Inter_ref_10_09,Inter_ref_11_09,Inter_ref_12_09,
	Inter_ref_00_10,Inter_ref_01_10,Inter_ref_02_10,Inter_ref_03_10,Inter_ref_04_10,Inter_ref_05_10,
	Inter_ref_06_10,Inter_ref_07_10,Inter_ref_08_10,Inter_ref_09_10,Inter_ref_10_10,Inter_ref_11_10,Inter_ref_12_10,
	Inter_ref_00_11,Inter_ref_01_11,Inter_ref_02_11,Inter_ref_03_11,Inter_ref_04_11,Inter_ref_05_11,
	Inter_ref_06_11,Inter_ref_07_11,Inter_ref_08_11,Inter_ref_09_11,Inter_ref_10_11,Inter_ref_11_11,Inter_ref_12_11,
	Inter_ref_00_12,Inter_ref_01_12,Inter_ref_02_12,Inter_ref_03_12,Inter_ref_04_12,Inter_ref_05_12,
	Inter_ref_06_12,Inter_ref_07_12,Inter_ref_08_12,Inter_ref_09_12,Inter_ref_10_12,Inter_ref_11_12,Inter_ref_12_12, 
	
	Inter_pix_copy0,Inter_pix_copy1,Inter_pix_copy2,Inter_pix_copy3,
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
	Inter_C_window_0_0,Inter_C_window_1_0,Inter_C_window_2_0,
	Inter_C_window_0_1,Inter_C_window_1_1,Inter_C_window_2_1,
	Inter_C_window_0_2,Inter_C_window_1_2,Inter_C_window_2_2,
	Inter_bi_window_0,Inter_bi_window_1,Inter_bi_window_2,Inter_bi_window_3);
	input IsInterLuma;
	input IsInterChroma;
	input Is_InterChromaCopy;
	input mv_below8x8_curr;
	input [3:0] pos_FracL;
	input [1:0] blk4x4_rec_counter_1to0;
	input [3:0] blk4x4_inter_calculate_counter;
	
	input [7:0] Inter_ref_00_00,Inter_ref_01_00,Inter_ref_02_00,Inter_ref_03_00,Inter_ref_04_00,Inter_ref_05_00;
	input [7:0] Inter_ref_06_00,Inter_ref_07_00,Inter_ref_08_00,Inter_ref_09_00,Inter_ref_10_00,Inter_ref_11_00,Inter_ref_12_00;
	input [7:0] Inter_ref_00_01,Inter_ref_01_01,Inter_ref_02_01,Inter_ref_03_01,Inter_ref_04_01,Inter_ref_05_01;
	input [7:0] Inter_ref_06_01,Inter_ref_07_01,Inter_ref_08_01,Inter_ref_09_01,Inter_ref_10_01,Inter_ref_11_01,Inter_ref_12_01;
	input [7:0] Inter_ref_00_02,Inter_ref_01_02,Inter_ref_02_02,Inter_ref_03_02,Inter_ref_04_02,Inter_ref_05_02;
	input [7:0] Inter_ref_06_02,Inter_ref_07_02,Inter_ref_08_02,Inter_ref_09_02,Inter_ref_10_02,Inter_ref_11_02,Inter_ref_12_02;
	input [7:0] Inter_ref_00_03,Inter_ref_01_03,Inter_ref_02_03,Inter_ref_03_03,Inter_ref_04_03,Inter_ref_05_03;
	input [7:0] Inter_ref_06_03,Inter_ref_07_03,Inter_ref_08_03,Inter_ref_09_03,Inter_ref_10_03,Inter_ref_11_03,Inter_ref_12_03;
	input [7:0] Inter_ref_00_04,Inter_ref_01_04,Inter_ref_02_04,Inter_ref_03_04,Inter_ref_04_04,Inter_ref_05_04;
	input [7:0] Inter_ref_06_04,Inter_ref_07_04,Inter_ref_08_04,Inter_ref_09_04,Inter_ref_10_04,Inter_ref_11_04,Inter_ref_12_04;
	input [7:0] Inter_ref_00_05,Inter_ref_01_05,Inter_ref_02_05,Inter_ref_03_05,Inter_ref_04_05,Inter_ref_05_05;
	input [7:0] Inter_ref_06_05,Inter_ref_07_05,Inter_ref_08_05,Inter_ref_09_05,Inter_ref_10_05,Inter_ref_11_05,Inter_ref_12_05;
	input [7:0] Inter_ref_00_06,Inter_ref_01_06,Inter_ref_02_06,Inter_ref_03_06,Inter_ref_04_06,Inter_ref_05_06;
	input [7:0] Inter_ref_06_06,Inter_ref_07_06,Inter_ref_08_06,Inter_ref_09_06,Inter_ref_10_06,Inter_ref_11_06,Inter_ref_12_06;
	input [7:0] Inter_ref_00_07,Inter_ref_01_07,Inter_ref_02_07,Inter_ref_03_07,Inter_ref_04_07,Inter_ref_05_07;
	input [7:0] Inter_ref_06_07,Inter_ref_07_07,Inter_ref_08_07,Inter_ref_09_07,Inter_ref_10_07,Inter_ref_11_07,Inter_ref_12_07;
	input [7:0] Inter_ref_00_08,Inter_ref_01_08,Inter_ref_02_08,Inter_ref_03_08,Inter_ref_04_08,Inter_ref_05_08;
	input [7:0] Inter_ref_06_08,Inter_ref_07_08,Inter_ref_08_08,Inter_ref_09_08,Inter_ref_10_08,Inter_ref_11_08,Inter_ref_12_08;
	input [7:0] Inter_ref_00_09,Inter_ref_01_09,Inter_ref_02_09,Inter_ref_03_09,Inter_ref_04_09,Inter_ref_05_09;
	input [7:0] Inter_ref_06_09,Inter_ref_07_09,Inter_ref_08_09,Inter_ref_09_09,Inter_ref_10_09,Inter_ref_11_09,Inter_ref_12_09;
	input [7:0] Inter_ref_00_10,Inter_ref_01_10,Inter_ref_02_10,Inter_ref_03_10,Inter_ref_04_10,Inter_ref_05_10;
	input [7:0] Inter_ref_06_10,Inter_ref_07_10,Inter_ref_08_10,Inter_ref_09_10,Inter_ref_10_10,Inter_ref_11_10,Inter_ref_12_10;
	input [7:0] Inter_ref_00_11,Inter_ref_01_11,Inter_ref_02_11,Inter_ref_03_11,Inter_ref_04_11,Inter_ref_05_11;
	input [7:0] Inter_ref_06_11,Inter_ref_07_11,Inter_ref_08_11,Inter_ref_09_11,Inter_ref_10_11,Inter_ref_11_11,Inter_ref_12_11;
	input [7:0] Inter_ref_00_12,Inter_ref_01_12,Inter_ref_02_12,Inter_ref_03_12,Inter_ref_04_12,Inter_ref_05_12;
	input [7:0] Inter_ref_06_12,Inter_ref_07_12,Inter_ref_08_12,Inter_ref_09_12,Inter_ref_10_12,Inter_ref_11_12,Inter_ref_12_12; 
	
	output [7:0] Inter_pix_copy0,Inter_pix_copy1,Inter_pix_copy2,Inter_pix_copy3;
	output [7:0] Inter_H_window_0_0,Inter_H_window_1_0,Inter_H_window_2_0,Inter_H_window_3_0,Inter_H_window_4_0,Inter_H_window_5_0;
	output [7:0] Inter_H_window_0_1,Inter_H_window_1_1,Inter_H_window_2_1,Inter_H_window_3_1,Inter_H_window_4_1,Inter_H_window_5_1;
	output [7:0] Inter_H_window_0_2,Inter_H_window_1_2,Inter_H_window_2_2,Inter_H_window_3_2,Inter_H_window_4_2,Inter_H_window_5_2;
	output [7:0] Inter_H_window_0_3,Inter_H_window_1_3,Inter_H_window_2_3,Inter_H_window_3_3,Inter_H_window_4_3,Inter_H_window_5_3;
	output [7:0] Inter_H_window_0_4,Inter_H_window_1_4,Inter_H_window_2_4,Inter_H_window_3_4,Inter_H_window_4_4,Inter_H_window_5_4;
	output [7:0] Inter_H_window_0_5,Inter_H_window_1_5,Inter_H_window_2_5,Inter_H_window_3_5,Inter_H_window_4_5,Inter_H_window_5_5;
	output [7:0] Inter_H_window_0_6,Inter_H_window_1_6,Inter_H_window_2_6,Inter_H_window_3_6,Inter_H_window_4_6,Inter_H_window_5_6;
	output [7:0] Inter_H_window_0_7,Inter_H_window_1_7,Inter_H_window_2_7,Inter_H_window_3_7,Inter_H_window_4_7,Inter_H_window_5_7;
	output [7:0] Inter_H_window_0_8,Inter_H_window_1_8,Inter_H_window_2_8,Inter_H_window_3_8,Inter_H_window_4_8,Inter_H_window_5_8;
	output [7:0] Inter_V_window_0,Inter_V_window_1,Inter_V_window_2,Inter_V_window_3,Inter_V_window_4;
	output [7:0] Inter_V_window_5,Inter_V_window_6,Inter_V_window_7,Inter_V_window_8;
	output [7:0] Inter_C_window_0_0,Inter_C_window_1_0,Inter_C_window_2_0;
	output [7:0] Inter_C_window_0_1,Inter_C_window_1_1,Inter_C_window_2_1;
	output [7:0] Inter_C_window_0_2,Inter_C_window_1_2,Inter_C_window_2_2;
	output [7:0] Inter_bi_window_0,Inter_bi_window_1,Inter_bi_window_2,Inter_bi_window_3;
	
	reg [7:0] Inter_pix_copy0,Inter_pix_copy1,Inter_pix_copy2,Inter_pix_copy3;
	reg [7:0] Inter_H_window_0_0,Inter_H_window_1_0,Inter_H_window_2_0,Inter_H_window_3_0,Inter_H_window_4_0,Inter_H_window_5_0;
	reg [7:0] Inter_H_window_0_1,Inter_H_window_1_1,Inter_H_window_2_1,Inter_H_window_3_1,Inter_H_window_4_1,Inter_H_window_5_1;
	reg [7:0] Inter_H_window_0_2,Inter_H_window_1_2,Inter_H_window_2_2,Inter_H_window_3_2,Inter_H_window_4_2,Inter_H_window_5_2;
	reg [7:0] Inter_H_window_0_3,Inter_H_window_1_3,Inter_H_window_2_3,Inter_H_window_3_3,Inter_H_window_4_3,Inter_H_window_5_3;
	reg [7:0] Inter_H_window_0_4,Inter_H_window_1_4,Inter_H_window_2_4,Inter_H_window_3_4,Inter_H_window_4_4,Inter_H_window_5_4;
	reg [7:0] Inter_H_window_0_5,Inter_H_window_1_5,Inter_H_window_2_5,Inter_H_window_3_5,Inter_H_window_4_5,Inter_H_window_5_5;
	reg [7:0] Inter_H_window_0_6,Inter_H_window_1_6,Inter_H_window_2_6,Inter_H_window_3_6,Inter_H_window_4_6,Inter_H_window_5_6;
	reg [7:0] Inter_H_window_0_7,Inter_H_window_1_7,Inter_H_window_2_7,Inter_H_window_3_7,Inter_H_window_4_7,Inter_H_window_5_7;
	reg [7:0] Inter_H_window_0_8,Inter_H_window_1_8,Inter_H_window_2_8,Inter_H_window_3_8,Inter_H_window_4_8,Inter_H_window_5_8;
	reg [7:0] Inter_V_window_0,Inter_V_window_1,Inter_V_window_2,Inter_V_window_3,Inter_V_window_4;
	reg [7:0] Inter_V_window_5,Inter_V_window_6,Inter_V_window_7,Inter_V_window_8;
	reg [7:0] Inter_C_window_0_0,Inter_C_window_1_0,Inter_C_window_2_0;
	reg [7:0] Inter_C_window_0_1,Inter_C_window_1_1,Inter_C_window_2_1;
	reg [7:0] Inter_C_window_0_2,Inter_C_window_1_2,Inter_C_window_2_2;
	reg [7:0] Inter_bi_window_0,Inter_bi_window_1,Inter_bi_window_2,Inter_bi_window_3;
	
	parameter pos_Int = 4'b0000;
	parameter pos_a   = 4'b0100;
	parameter pos_b   = 4'b1000;
	parameter pos_c   = 4'b1100; 
	parameter pos_d   = 4'b0001;
	parameter pos_e   = 4'b0101;
	parameter pos_f   = 4'b1001;
	parameter pos_g   = 4'b1101;
	parameter pos_h   = 4'b0010;
	parameter pos_i   = 4'b0110;
	parameter pos_j   = 4'b1010;
	parameter pos_k   = 4'b1110;
	parameter pos_n   = 4'b0011;
	parameter pos_p   = 4'b0111;
	parameter pos_q   = 4'b1011;
	parameter pos_r   = 4'b1111;
	
	//-------------------------------
	//sliding window control		 
	//-------------------------------
	wire Is_blk4x4_0;//When inter 8x8(or above) predicted: top-left blk4x4
					 //When inter 4x4           predicted: each blk4x4
	wire Is_blk4x4_1;
	wire Is_blk4x4_2;
	wire Is_blk4x4_3;
	assign Is_blk4x4_0 = (IsInterLuma && (mv_below8x8_curr || (!mv_below8x8_curr && 
							blk4x4_rec_counter_1to0 == 2'b00))); 									//top-left
	assign Is_blk4x4_1 = (IsInterLuma && (!mv_below8x8_curr && blk4x4_rec_counter_1to0 == 2'b01));	//top-right
	assign Is_blk4x4_2 = (IsInterLuma && (!mv_below8x8_curr && blk4x4_rec_counter_1to0 == 2'b10));	//bottom-left
	assign Is_blk4x4_3 = (IsInterLuma && (!mv_below8x8_curr && blk4x4_rec_counter_1to0 == 2'b11)); 	//bottom-right
	
	//For both luma & chroma,if current pixel is to be directly copied instead of inter calculated,
	//the sliding windows output Inter_pix_copy0 ~ 3 is the inter prediction output
	always @ (IsInterLuma or pos_FracL or blk4x4_inter_calculate_counter
		or Is_blk4x4_0 or Is_blk4x4_1 or Is_blk4x4_2 or Is_blk4x4_3
		or Is_InterChromaCopy or mv_below8x8_curr
		or Inter_ref_00_00 or Inter_ref_01_00 or Inter_ref_02_00 or Inter_ref_03_00
		or Inter_ref_00_01 or Inter_ref_01_01 or Inter_ref_02_01 or Inter_ref_03_01
		or Inter_ref_00_02 or Inter_ref_01_02 or Inter_ref_02_02 or Inter_ref_03_02 
		or Inter_ref_04_02 or Inter_ref_05_02 or Inter_ref_06_02 or Inter_ref_07_02 
		or Inter_ref_08_02 or Inter_ref_09_02 or Inter_ref_00_03 or Inter_ref_01_03
		or Inter_ref_02_03 or Inter_ref_03_03 or Inter_ref_04_03 or Inter_ref_05_03
		or Inter_ref_06_03 or Inter_ref_07_03 or Inter_ref_08_03 or Inter_ref_09_03
		or Inter_ref_02_04 or Inter_ref_03_04 or Inter_ref_04_04 or Inter_ref_05_04
		or Inter_ref_06_04 or Inter_ref_07_04 or Inter_ref_08_04 or Inter_ref_09_04
		or Inter_ref_02_05 or Inter_ref_03_05 or Inter_ref_04_05 or Inter_ref_05_05
		or Inter_ref_06_05 or Inter_ref_07_05 or Inter_ref_08_05 or Inter_ref_09_05
		or Inter_ref_02_06 or Inter_ref_03_06 or Inter_ref_04_06 or Inter_ref_05_06
		or Inter_ref_06_06 or Inter_ref_07_06 or Inter_ref_08_06 or Inter_ref_09_06
		or Inter_ref_02_07 or Inter_ref_03_07 or Inter_ref_04_07 or Inter_ref_05_07
		or Inter_ref_06_07 or Inter_ref_07_07 or Inter_ref_08_07 or Inter_ref_09_07
		or Inter_ref_02_08 or Inter_ref_03_08 or Inter_ref_04_08 or Inter_ref_05_08
		or Inter_ref_06_08 or Inter_ref_07_08 or Inter_ref_08_08 or Inter_ref_09_08
		or Inter_ref_02_09 or Inter_ref_03_09 or Inter_ref_04_09 or Inter_ref_05_09
		or Inter_ref_06_09 or Inter_ref_07_09 or Inter_ref_08_09 or Inter_ref_09_09)
		if (IsInterLuma && pos_FracL == `pos_Int)
			case ({Is_blk4x4_0,Is_blk4x4_1,Is_blk4x4_2,Is_blk4x4_3})
				4'b1000:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_pix_copy0 <= Inter_ref_02_02;	Inter_pix_copy1 <= Inter_ref_02_03;
								Inter_pix_copy2 <= Inter_ref_02_04;	Inter_pix_copy3 <= Inter_ref_02_05;end
					4'd3:begin	Inter_pix_copy0 <= Inter_ref_03_02;	Inter_pix_copy1 <= Inter_ref_03_03;
								Inter_pix_copy2 <= Inter_ref_03_04;	Inter_pix_copy3 <= Inter_ref_03_05;end
					4'd2:begin	Inter_pix_copy0 <= Inter_ref_04_02;	Inter_pix_copy1 <= Inter_ref_04_03;
								Inter_pix_copy2 <= Inter_ref_04_04;	Inter_pix_copy3 <= Inter_ref_04_05;end
					4'd1:begin	Inter_pix_copy0 <= Inter_ref_05_02;	Inter_pix_copy1 <= Inter_ref_05_03;
								Inter_pix_copy2 <= Inter_ref_05_04;	Inter_pix_copy3 <= Inter_ref_05_05;end
					default:begin	Inter_pix_copy0 <= 0;	Inter_pix_copy1 <= 0;
									Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;end
			  	endcase
				4'b0100:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_pix_copy0 <= Inter_ref_06_02;	Inter_pix_copy1 <= Inter_ref_06_03;
								Inter_pix_copy2 <= Inter_ref_06_04;	Inter_pix_copy3 <= Inter_ref_06_05;end
					4'd3:begin	Inter_pix_copy0 <= Inter_ref_07_02;	Inter_pix_copy1 <= Inter_ref_07_03;
								Inter_pix_copy2 <= Inter_ref_07_04;	Inter_pix_copy3 <= Inter_ref_07_05;end
					4'd2:begin	Inter_pix_copy0 <= Inter_ref_08_02;	Inter_pix_copy1 <= Inter_ref_08_03;
								Inter_pix_copy2 <= Inter_ref_08_04;	Inter_pix_copy3 <= Inter_ref_08_05;end
					4'd1:begin	Inter_pix_copy0 <= Inter_ref_09_02;	Inter_pix_copy1 <= Inter_ref_09_03;
								Inter_pix_copy2 <= Inter_ref_09_04;	Inter_pix_copy3 <= Inter_ref_09_05;end
					default:begin	Inter_pix_copy0 <= 0;	Inter_pix_copy1 <= 0;
									Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;end
			  	endcase 
				4'b0010:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_pix_copy0 <= Inter_ref_02_06;	Inter_pix_copy1 <= Inter_ref_02_07;
								Inter_pix_copy2 <= Inter_ref_02_08;	Inter_pix_copy3 <= Inter_ref_02_09;end
					4'd3:begin	Inter_pix_copy0 <= Inter_ref_03_06;	Inter_pix_copy1 <= Inter_ref_03_07;
								Inter_pix_copy2 <= Inter_ref_03_08;	Inter_pix_copy3 <= Inter_ref_03_09;end
					4'd2:begin	Inter_pix_copy0 <= Inter_ref_04_06;	Inter_pix_copy1 <= Inter_ref_04_07;
								Inter_pix_copy2 <= Inter_ref_04_08;	Inter_pix_copy3 <= Inter_ref_04_09;end
					4'd1:begin	Inter_pix_copy0 <= Inter_ref_05_06;	Inter_pix_copy1 <= Inter_ref_05_07;
								Inter_pix_copy2 <= Inter_ref_05_08;	Inter_pix_copy3 <= Inter_ref_05_09;end
					default:begin	Inter_pix_copy0 <= 0;	Inter_pix_copy1 <= 0;
									Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;end
			  	endcase
				4'b0001:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_pix_copy0 <= Inter_ref_06_06;	Inter_pix_copy1 <= Inter_ref_06_07;
								Inter_pix_copy2 <= Inter_ref_06_08;	Inter_pix_copy3 <= Inter_ref_06_09;end
					4'd3:begin	Inter_pix_copy0 <= Inter_ref_07_06;	Inter_pix_copy1 <= Inter_ref_07_07;
								Inter_pix_copy2 <= Inter_ref_07_08;	Inter_pix_copy3 <= Inter_ref_07_09;end
					4'd2:begin	Inter_pix_copy0 <= Inter_ref_08_06;	Inter_pix_copy1 <= Inter_ref_08_07;
								Inter_pix_copy2 <= Inter_ref_08_08;	Inter_pix_copy3 <= Inter_ref_08_09;end
					4'd1:begin	Inter_pix_copy0 <= Inter_ref_09_06;	Inter_pix_copy1 <= Inter_ref_09_07;
								Inter_pix_copy2 <= Inter_ref_09_08;	Inter_pix_copy3 <= Inter_ref_09_09;end
					default:begin	Inter_pix_copy0 <= 0;	Inter_pix_copy1 <= 0;
									Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;end
			  	endcase
				default:begin	Inter_pix_copy0 <= 0;	Inter_pix_copy1 <= 0;
								Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;end
			endcase
		else if (Is_InterChromaCopy)
			case (mv_below8x8_curr)
				1'b1://only one cycle
				begin
					Inter_pix_copy0 <= (blk4x4_inter_calculate_counter != 0)? Inter_ref_00_00:0;
					Inter_pix_copy1 <= (blk4x4_inter_calculate_counter != 0)? Inter_ref_01_00:0;
					Inter_pix_copy2 <= (blk4x4_inter_calculate_counter != 0)? Inter_ref_00_01:0;
					Inter_pix_copy3 <= (blk4x4_inter_calculate_counter != 0)? Inter_ref_01_01:0;
				end
				1'b0://4 cycles,each cycle for one blk2x2 in blk2x2-zig-zag order
					case (blk4x4_inter_calculate_counter)
						4'd4:
						begin 
							Inter_pix_copy0 <= Inter_ref_00_00;	Inter_pix_copy1 <= Inter_ref_01_00;
							Inter_pix_copy2 <= Inter_ref_00_01; Inter_pix_copy3 <= Inter_ref_01_01;
						end
						4'd3:
						begin
							Inter_pix_copy0 <= Inter_ref_02_00; Inter_pix_copy1 <= Inter_ref_03_00;
							Inter_pix_copy2 <= Inter_ref_02_01; Inter_pix_copy3 <= Inter_ref_03_01;
						end
						4'd2:
						begin
							Inter_pix_copy0 <= Inter_ref_00_02; Inter_pix_copy1 <= Inter_ref_01_02;
							Inter_pix_copy2 <= Inter_ref_00_03; Inter_pix_copy3 <= Inter_ref_01_03;
						end
						4'd1:
						begin
							Inter_pix_copy0 <= Inter_ref_02_02; Inter_pix_copy1 <= Inter_ref_03_02;
							Inter_pix_copy2 <= Inter_ref_02_03; Inter_pix_copy3 <= Inter_ref_03_03;
						end
						default:
						begin
							Inter_pix_copy0 <= 0; Inter_pix_copy1 <= 0;	Inter_pix_copy2 <= 0;	Inter_pix_copy3 <= 0;
						end
					endcase
			endcase
		else
			begin	
				Inter_pix_copy0 <= 0; Inter_pix_copy1 <= 0; Inter_pix_copy2 <= 0; Inter_pix_copy3 <= 0; 
			end
	
	//Horizontal sliding windows:Inter_H_window_0_0 ~ Inter_H_window_5_8 (6x9 windows)
	//							 Inter_H_window_x_0,Inter_H_window_x_1,Inter_H_window_x_6,Inter_H_window_x_7,Inter_H_window_x_8
	//							 are only used for pos_j/pos_i/pos_k/pos_f/pos_q
	//Vertical   sliding window:Inter_V_window_0 ~ Inter_V_window_8
	//Chroma     sliding window:Inter_C_window_0 ~ Inter_C_window_3
	
	//By careful study,we find that pos_b calculate cycle4 needs the same window as pos_a calculate cycl5.
	//Similar cases happens with pos_b and pos_a/pos_c,pos_h and pos_d/pos_n, pos_j and pos_f/pos_q/pos_i/pos_k......
	
	//Inter_H_window_counter0:for Inter_H_window_x_0/1/6/7/8 sliding window control
	reg [2:0] Inter_H_window_counter0;
	always @ (pos_FracL or blk4x4_inter_calculate_counter)
		if  ((pos_FracL == `pos_j && blk4x4_inter_calculate_counter == 4'd5) 						||
			((pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd5)	||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd8))
			Inter_H_window_counter0 <= 3'd4;
		else if ((pos_FracL == `pos_j && blk4x4_inter_calculate_counter == 4'd4) 						||
				((pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd4)	||
				((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd6))
			Inter_H_window_counter0 <= 3'd3;
		else if ((pos_FracL == `pos_j && blk4x4_inter_calculate_counter == 4'd3) 						||
				((pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd3)	||
				((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd4))
			Inter_H_window_counter0 <= 3'd2;
		else if ((pos_FracL == `pos_j && blk4x4_inter_calculate_counter == 4'd2) 						||
				((pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd2)	||
				((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd2))
			Inter_H_window_counter0 <= 3'd1;
		else
			Inter_H_window_counter0 <= 0;
			
	
	//Inter_H_window_x_0,Inter_H_window_x_1
	//Inter_H_window_x_6,Inter_H_window_x_7,Inter_H_window_x_8
	//Active only for pos j,i/k/f/q
	always @ (Is_blk4x4_0 or Is_blk4x4_1 or Is_blk4x4_2 or Is_blk4x4_3 or Inter_H_window_counter0
		
		or Inter_ref_00_00 or Inter_ref_01_00 or Inter_ref_02_00 or Inter_ref_03_00
		or Inter_ref_04_00 or Inter_ref_05_00 or Inter_ref_06_00 or Inter_ref_07_00
		or Inter_ref_08_00 or Inter_ref_09_00 or Inter_ref_10_00 or Inter_ref_11_00 or Inter_ref_12_00
		
		or Inter_ref_00_01 or Inter_ref_01_01 or Inter_ref_02_01 or Inter_ref_03_01
		or Inter_ref_04_01 or Inter_ref_05_01 or Inter_ref_06_01 or Inter_ref_07_01
		or Inter_ref_08_01 or Inter_ref_09_01 or Inter_ref_10_01 or Inter_ref_11_01 or Inter_ref_12_01
		
		or Inter_ref_00_06 or Inter_ref_01_06 or Inter_ref_02_06 or Inter_ref_03_06
		or Inter_ref_04_06 or Inter_ref_05_06 or Inter_ref_06_06 or Inter_ref_07_06
		or Inter_ref_08_06 or Inter_ref_09_06 or Inter_ref_10_06 or Inter_ref_11_06 or Inter_ref_12_06
		
		or Inter_ref_00_07 or Inter_ref_01_07 or Inter_ref_02_07 or Inter_ref_03_07
		or Inter_ref_04_07 or Inter_ref_05_07 or Inter_ref_06_07 or Inter_ref_07_07
		or Inter_ref_08_07 or Inter_ref_09_07 or Inter_ref_10_07 or Inter_ref_11_07 or Inter_ref_12_07
		
		or Inter_ref_00_08 or Inter_ref_01_08 or Inter_ref_02_08 or Inter_ref_03_08
		or Inter_ref_04_08 or Inter_ref_05_08 or Inter_ref_06_08 or Inter_ref_07_08
		or Inter_ref_08_08 or Inter_ref_09_08 or Inter_ref_10_08 or Inter_ref_11_08 or Inter_ref_12_08 
		
		or Inter_ref_00_04 or Inter_ref_01_04 or Inter_ref_02_04 or Inter_ref_03_04
		or Inter_ref_04_04 or Inter_ref_05_04 or Inter_ref_06_04 or Inter_ref_07_04
		or Inter_ref_08_04 or Inter_ref_09_04 or Inter_ref_10_04 or Inter_ref_11_04 or Inter_ref_12_04
		
		or Inter_ref_00_05 or Inter_ref_01_05 or Inter_ref_02_05 or Inter_ref_03_05
		or Inter_ref_04_05 or Inter_ref_05_05 or Inter_ref_06_05 or Inter_ref_07_05
		or Inter_ref_08_05 or Inter_ref_09_05 or Inter_ref_10_05 or Inter_ref_11_05 or Inter_ref_12_05
		
		or Inter_ref_00_10 or Inter_ref_01_10 or Inter_ref_02_10 or Inter_ref_03_10
		or Inter_ref_04_10 or Inter_ref_05_10 or Inter_ref_06_10 or Inter_ref_07_10
		or Inter_ref_08_10 or Inter_ref_09_10 or Inter_ref_10_10 or Inter_ref_11_10 or Inter_ref_12_10 
		
		or Inter_ref_00_11 or Inter_ref_01_11 or Inter_ref_02_11 or Inter_ref_03_11
		or Inter_ref_04_11 or Inter_ref_05_11 or Inter_ref_06_11 or Inter_ref_07_11
		or Inter_ref_08_11 or Inter_ref_09_11 or Inter_ref_10_11 or Inter_ref_11_11 or Inter_ref_12_11
		
		or Inter_ref_00_12 or Inter_ref_01_12 or Inter_ref_02_12 or Inter_ref_03_12
		or Inter_ref_04_12 or Inter_ref_05_12 or Inter_ref_06_12 or Inter_ref_07_12
		or Inter_ref_08_12 or Inter_ref_09_12 or Inter_ref_10_12 or Inter_ref_11_12 or Inter_ref_12_12 
		)
		case ({Is_blk4x4_0,Is_blk4x4_1,Is_blk4x4_2,Is_blk4x4_3}) 
			4'b1000: //Left top blk4x4
			case (Inter_H_window_counter0)
				3'd4:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_00_00;Inter_H_window_1_0 <= Inter_ref_01_00;
					Inter_H_window_2_0 <= Inter_ref_02_00;Inter_H_window_3_0 <= Inter_ref_03_00;
					Inter_H_window_4_0 <= Inter_ref_04_00;Inter_H_window_5_0 <= Inter_ref_05_00;
						
					Inter_H_window_0_1 <= Inter_ref_00_01;Inter_H_window_1_1 <= Inter_ref_01_01; 
					Inter_H_window_2_1 <= Inter_ref_02_01;Inter_H_window_3_1 <= Inter_ref_03_01;
					Inter_H_window_4_1 <= Inter_ref_04_01;Inter_H_window_5_1 <= Inter_ref_05_01;
					
					Inter_H_window_0_6 <= Inter_ref_00_06;Inter_H_window_1_6 <= Inter_ref_01_06; 
					Inter_H_window_2_6 <= Inter_ref_02_06;Inter_H_window_3_6 <= Inter_ref_03_06;
					Inter_H_window_4_6 <= Inter_ref_04_06;Inter_H_window_5_6 <= Inter_ref_05_06;
							
					Inter_H_window_0_7 <= Inter_ref_00_07;Inter_H_window_1_7 <= Inter_ref_01_07; 
					Inter_H_window_2_7 <= Inter_ref_02_07;Inter_H_window_3_7 <= Inter_ref_03_07;
					Inter_H_window_4_7 <= Inter_ref_04_07;Inter_H_window_5_7 <= Inter_ref_05_07;
							
					Inter_H_window_0_8 <= Inter_ref_00_08;Inter_H_window_1_8 <= Inter_ref_01_08; 
					Inter_H_window_2_8 <= Inter_ref_02_08;Inter_H_window_3_8 <= Inter_ref_03_08;
					Inter_H_window_4_8 <= Inter_ref_04_08;Inter_H_window_5_8 <= Inter_ref_05_08;
				end
				3'd3:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_01_00;Inter_H_window_1_0 <= Inter_ref_02_00;
					Inter_H_window_2_0 <= Inter_ref_03_00;Inter_H_window_3_0 <= Inter_ref_04_00;
					Inter_H_window_4_0 <= Inter_ref_05_00;Inter_H_window_5_0 <= Inter_ref_06_00;
							
					Inter_H_window_0_1 <= Inter_ref_01_01;Inter_H_window_1_1 <= Inter_ref_02_01; 
					Inter_H_window_2_1 <= Inter_ref_03_01;Inter_H_window_3_1 <= Inter_ref_04_01;
					Inter_H_window_4_1 <= Inter_ref_05_01;Inter_H_window_5_1 <= Inter_ref_06_01;
						
					Inter_H_window_0_6 <= Inter_ref_01_06;Inter_H_window_1_6 <= Inter_ref_02_06; 
					Inter_H_window_2_6 <= Inter_ref_03_06;Inter_H_window_3_6 <= Inter_ref_04_06;
					Inter_H_window_4_6 <= Inter_ref_05_06;Inter_H_window_5_6 <= Inter_ref_06_06;
							
					Inter_H_window_0_7 <= Inter_ref_01_07;Inter_H_window_1_7 <= Inter_ref_02_07; 
					Inter_H_window_2_7 <= Inter_ref_03_07;Inter_H_window_3_7 <= Inter_ref_04_07;
					Inter_H_window_4_7 <= Inter_ref_05_07;Inter_H_window_5_7 <= Inter_ref_06_07;
							
					Inter_H_window_0_8 <= Inter_ref_01_08;Inter_H_window_1_8 <= Inter_ref_02_08; 
					Inter_H_window_2_8 <= Inter_ref_03_08;Inter_H_window_3_8 <= Inter_ref_04_08;
					Inter_H_window_4_8 <= Inter_ref_05_08;Inter_H_window_5_8 <= Inter_ref_06_08;
				end
				3'd2:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_02_00;Inter_H_window_1_0 <= Inter_ref_03_00;
					Inter_H_window_2_0 <= Inter_ref_04_00;Inter_H_window_3_0 <= Inter_ref_05_00;
					Inter_H_window_4_0 <= Inter_ref_06_00;Inter_H_window_5_0 <= Inter_ref_07_00;
						
					Inter_H_window_0_1 <= Inter_ref_02_01;Inter_H_window_1_1 <= Inter_ref_03_01; 
					Inter_H_window_2_1 <= Inter_ref_04_01;Inter_H_window_3_1 <= Inter_ref_05_01;
					Inter_H_window_4_1 <= Inter_ref_06_01;Inter_H_window_5_1 <= Inter_ref_07_01;
						
					Inter_H_window_0_6 <= Inter_ref_02_06;Inter_H_window_1_6 <= Inter_ref_03_06; 
					Inter_H_window_2_6 <= Inter_ref_04_06;Inter_H_window_3_6 <= Inter_ref_05_06;
					Inter_H_window_4_6 <= Inter_ref_06_06;Inter_H_window_5_6 <= Inter_ref_07_06;
							
					Inter_H_window_0_7 <= Inter_ref_02_07;Inter_H_window_1_7 <= Inter_ref_03_07; 
					Inter_H_window_2_7 <= Inter_ref_04_07;Inter_H_window_3_7 <= Inter_ref_05_07;
					Inter_H_window_4_7 <= Inter_ref_06_07;Inter_H_window_5_7 <= Inter_ref_07_07;
							
					Inter_H_window_0_8 <= Inter_ref_02_08;Inter_H_window_1_8 <= Inter_ref_03_08; 
					Inter_H_window_2_8 <= Inter_ref_04_08;Inter_H_window_3_8 <= Inter_ref_05_08;
					Inter_H_window_4_8 <= Inter_ref_06_08;Inter_H_window_5_8 <= Inter_ref_07_08;
				end
				3'd1:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_03_00;Inter_H_window_1_0 <= Inter_ref_04_00;
					Inter_H_window_2_0 <= Inter_ref_05_00;Inter_H_window_3_0 <= Inter_ref_06_00;
					Inter_H_window_4_0 <= Inter_ref_07_00;Inter_H_window_5_0 <= Inter_ref_08_00;
						
					Inter_H_window_0_1 <= Inter_ref_03_01;Inter_H_window_1_1 <= Inter_ref_04_01; 
					Inter_H_window_2_1 <= Inter_ref_05_01;Inter_H_window_3_1 <= Inter_ref_06_01;
					Inter_H_window_4_1 <= Inter_ref_07_01;Inter_H_window_5_1 <= Inter_ref_08_01;
						
					Inter_H_window_0_6 <= Inter_ref_03_06;Inter_H_window_1_6 <= Inter_ref_04_06; 
					Inter_H_window_2_6 <= Inter_ref_05_06;Inter_H_window_3_6 <= Inter_ref_06_06;
					Inter_H_window_4_6 <= Inter_ref_07_06;Inter_H_window_5_6 <= Inter_ref_08_06;
							
					Inter_H_window_0_7 <= Inter_ref_03_07;Inter_H_window_1_7 <= Inter_ref_04_07; 
					Inter_H_window_2_7 <= Inter_ref_05_07;Inter_H_window_3_7 <= Inter_ref_06_07;
					Inter_H_window_4_7 <= Inter_ref_07_07;Inter_H_window_5_7 <= Inter_ref_08_07;
							
					Inter_H_window_0_8 <= Inter_ref_03_08;Inter_H_window_1_8 <= Inter_ref_04_08; 
					Inter_H_window_2_8 <= Inter_ref_05_08;Inter_H_window_3_8 <= Inter_ref_06_08;
					Inter_H_window_4_8 <= Inter_ref_07_08;Inter_H_window_5_8 <= Inter_ref_08_08;
				end
				default:
				begin
					Inter_H_window_0_0 <= 0;Inter_H_window_1_0 <= 0;Inter_H_window_2_0 <= 0;
					Inter_H_window_3_0 <= 0;Inter_H_window_4_0 <= 0;Inter_H_window_5_0 <= 0;
						
					Inter_H_window_0_1 <= 0;Inter_H_window_1_1 <= 0;Inter_H_window_2_1 <= 0;
					Inter_H_window_3_1 <= 0;Inter_H_window_4_1 <= 0;Inter_H_window_5_1 <= 0;
						
					Inter_H_window_0_6 <= 0;Inter_H_window_1_6 <= 0;Inter_H_window_2_6 <= 0;
					Inter_H_window_3_6 <= 0;Inter_H_window_4_6 <= 0;Inter_H_window_5_6 <= 0;
							
					Inter_H_window_0_7 <= 0;Inter_H_window_1_7 <= 0;Inter_H_window_2_7 <= 0;
					Inter_H_window_3_7 <= 0;Inter_H_window_4_7 <= 0;Inter_H_window_5_7 <= 0;
							
					Inter_H_window_0_8 <= 0;Inter_H_window_1_8 <= 0;Inter_H_window_2_8 <= 0;
					Inter_H_window_3_8 <= 0;Inter_H_window_4_8 <= 0;Inter_H_window_5_8 <= 0;
				end
			endcase
			4'b0100: //Right top blk8x8
			case (Inter_H_window_counter0)
				3'd4:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_04_00;Inter_H_window_1_0 <= Inter_ref_05_00;
					Inter_H_window_2_0 <= Inter_ref_06_00;Inter_H_window_3_0 <= Inter_ref_07_00;
					Inter_H_window_4_0 <= Inter_ref_08_00;Inter_H_window_5_0 <= Inter_ref_09_00;
							
					Inter_H_window_0_1 <= Inter_ref_04_01;Inter_H_window_1_1 <= Inter_ref_05_01; 
					Inter_H_window_2_1 <= Inter_ref_06_01;Inter_H_window_3_1 <= Inter_ref_07_01;
					Inter_H_window_4_1 <= Inter_ref_08_01;Inter_H_window_5_1 <= Inter_ref_09_01;
						
					Inter_H_window_0_6 <= Inter_ref_04_06;Inter_H_window_1_6 <= Inter_ref_05_06; 
					Inter_H_window_2_6 <= Inter_ref_06_06;Inter_H_window_3_6 <= Inter_ref_07_06;
					Inter_H_window_4_6 <= Inter_ref_08_06;Inter_H_window_5_6 <= Inter_ref_09_06;
							
					Inter_H_window_0_7 <= Inter_ref_04_07;Inter_H_window_1_7 <= Inter_ref_05_07; 
					Inter_H_window_2_7 <= Inter_ref_06_07;Inter_H_window_3_7 <= Inter_ref_07_07;
					Inter_H_window_4_7 <= Inter_ref_08_07;Inter_H_window_5_7 <= Inter_ref_09_07;
							
					Inter_H_window_0_8 <= Inter_ref_04_08;Inter_H_window_1_8 <= Inter_ref_05_08; 
					Inter_H_window_2_8 <= Inter_ref_06_08;Inter_H_window_3_8 <= Inter_ref_07_08;
					Inter_H_window_4_8 <= Inter_ref_08_08;Inter_H_window_5_8 <= Inter_ref_09_08;
				end
				3'd3:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_05_00;Inter_H_window_1_0 <= Inter_ref_06_00;
					Inter_H_window_2_0 <= Inter_ref_07_00;Inter_H_window_3_0 <= Inter_ref_08_00;
					Inter_H_window_4_0 <= Inter_ref_09_00;Inter_H_window_5_0 <= Inter_ref_10_00;
							
					Inter_H_window_0_1 <= Inter_ref_05_01;Inter_H_window_1_1 <= Inter_ref_06_01; 
					Inter_H_window_2_1 <= Inter_ref_07_01;Inter_H_window_3_1 <= Inter_ref_08_01;
					Inter_H_window_4_1 <= Inter_ref_09_01;Inter_H_window_5_1 <= Inter_ref_10_01;
						
					Inter_H_window_0_6 <= Inter_ref_05_06;Inter_H_window_1_6 <= Inter_ref_06_06; 
					Inter_H_window_2_6 <= Inter_ref_07_06;Inter_H_window_3_6 <= Inter_ref_08_06;
					Inter_H_window_4_6 <= Inter_ref_09_06;Inter_H_window_5_6 <= Inter_ref_10_06;
							
					Inter_H_window_0_7 <= Inter_ref_05_07;Inter_H_window_1_7 <= Inter_ref_06_07; 
					Inter_H_window_2_7 <= Inter_ref_07_07;Inter_H_window_3_7 <= Inter_ref_08_07;
					Inter_H_window_4_7 <= Inter_ref_09_07;Inter_H_window_5_7 <= Inter_ref_10_07;
							
					Inter_H_window_0_8 <= Inter_ref_05_08;Inter_H_window_1_8 <= Inter_ref_06_08; 
					Inter_H_window_2_8 <= Inter_ref_07_08;Inter_H_window_3_8 <= Inter_ref_08_08;
					Inter_H_window_4_8 <= Inter_ref_09_08;Inter_H_window_5_8 <= Inter_ref_10_08;
				end
				3'd2:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_06_00;Inter_H_window_1_0 <= Inter_ref_07_00;
					Inter_H_window_2_0 <= Inter_ref_08_00;Inter_H_window_3_0 <= Inter_ref_09_00;
					Inter_H_window_4_0 <= Inter_ref_10_00;Inter_H_window_5_0 <= Inter_ref_11_00;
						
					Inter_H_window_0_1 <= Inter_ref_06_01;Inter_H_window_1_1 <= Inter_ref_07_01; 
					Inter_H_window_2_1 <= Inter_ref_08_01;Inter_H_window_3_1 <= Inter_ref_09_01;
					Inter_H_window_4_1 <= Inter_ref_10_01;Inter_H_window_5_1 <= Inter_ref_11_01;
					
					Inter_H_window_0_6 <= Inter_ref_06_06;Inter_H_window_1_6 <= Inter_ref_07_06; 
					Inter_H_window_2_6 <= Inter_ref_08_06;Inter_H_window_3_6 <= Inter_ref_09_06;
					Inter_H_window_4_6 <= Inter_ref_10_06;Inter_H_window_5_6 <= Inter_ref_11_06;
							
					Inter_H_window_0_7 <= Inter_ref_06_07;Inter_H_window_1_7 <= Inter_ref_07_07; 
					Inter_H_window_2_7 <= Inter_ref_08_07;Inter_H_window_3_7 <= Inter_ref_09_07;
					Inter_H_window_4_7 <= Inter_ref_10_07;Inter_H_window_5_7 <= Inter_ref_11_07;
							
					Inter_H_window_0_8 <= Inter_ref_06_08;Inter_H_window_1_8 <= Inter_ref_07_08; 
					Inter_H_window_2_8 <= Inter_ref_08_08;Inter_H_window_3_8 <= Inter_ref_09_08;
					Inter_H_window_4_8 <= Inter_ref_10_08;Inter_H_window_5_8 <= Inter_ref_11_08;
				end
				3'd1:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_07_00;Inter_H_window_1_0 <= Inter_ref_08_00;
					Inter_H_window_2_0 <= Inter_ref_09_00;Inter_H_window_3_0 <= Inter_ref_10_00;
					Inter_H_window_4_0 <= Inter_ref_11_00;Inter_H_window_5_0 <= Inter_ref_12_00;
						
					Inter_H_window_0_1 <= Inter_ref_07_01;Inter_H_window_1_1 <= Inter_ref_08_01; 
					Inter_H_window_2_1 <= Inter_ref_09_01;Inter_H_window_3_1 <= Inter_ref_10_01;
					Inter_H_window_4_1 <= Inter_ref_11_01;Inter_H_window_5_1 <= Inter_ref_12_01;
					
					Inter_H_window_0_6 <= Inter_ref_07_06;Inter_H_window_1_6 <= Inter_ref_08_06; 
					Inter_H_window_2_6 <= Inter_ref_09_06;Inter_H_window_3_6 <= Inter_ref_10_06;
					Inter_H_window_4_6 <= Inter_ref_11_06;Inter_H_window_5_6 <= Inter_ref_12_06;
							
					Inter_H_window_0_7 <= Inter_ref_07_07;Inter_H_window_1_7 <= Inter_ref_08_07; 
					Inter_H_window_2_7 <= Inter_ref_09_07;Inter_H_window_3_7 <= Inter_ref_10_07;
					Inter_H_window_4_7 <= Inter_ref_11_07;Inter_H_window_5_7 <= Inter_ref_12_07;
							
					Inter_H_window_0_8 <= Inter_ref_07_08;Inter_H_window_1_8 <= Inter_ref_08_08; 
					Inter_H_window_2_8 <= Inter_ref_09_08;Inter_H_window_3_8 <= Inter_ref_10_08;
					Inter_H_window_4_8 <= Inter_ref_11_08;Inter_H_window_5_8 <= Inter_ref_12_08;
				end
				default:
				begin
					Inter_H_window_0_0 <= 0;Inter_H_window_1_0 <= 0;Inter_H_window_2_0 <= 0;
					Inter_H_window_3_0 <= 0;Inter_H_window_4_0 <= 0;Inter_H_window_5_0 <= 0;
						
					Inter_H_window_0_1 <= 0;Inter_H_window_1_1 <= 0;Inter_H_window_2_1 <= 0;
					Inter_H_window_3_1 <= 0;Inter_H_window_4_1 <= 0;Inter_H_window_5_1 <= 0;
						
					Inter_H_window_0_6 <= 0;Inter_H_window_1_6 <= 0;Inter_H_window_2_6 <= 0;
					Inter_H_window_3_6 <= 0;Inter_H_window_4_6 <= 0;Inter_H_window_5_6 <= 0;
							
					Inter_H_window_0_7 <= 0;Inter_H_window_1_7 <= 0;Inter_H_window_2_7 <= 0;
					Inter_H_window_3_7 <= 0;Inter_H_window_4_7 <= 0;Inter_H_window_5_7 <= 0;
							
					Inter_H_window_0_8 <= 0;Inter_H_window_1_8 <= 0;Inter_H_window_2_8 <= 0;
					Inter_H_window_3_8 <= 0;Inter_H_window_4_8 <= 0;Inter_H_window_5_8 <= 0;
				end
			endcase
			4'b0010: //Left bottom blk4x4
			case (Inter_H_window_counter0)
				3'd4:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_00_04;Inter_H_window_1_0 <= Inter_ref_01_04;
					Inter_H_window_2_0 <= Inter_ref_02_04;Inter_H_window_3_0 <= Inter_ref_03_04;
					Inter_H_window_4_0 <= Inter_ref_04_04;Inter_H_window_5_0 <= Inter_ref_05_04;
							
					Inter_H_window_0_1 <= Inter_ref_00_05;Inter_H_window_1_1 <= Inter_ref_01_05; 
					Inter_H_window_2_1 <= Inter_ref_02_05;Inter_H_window_3_1 <= Inter_ref_03_05;
					Inter_H_window_4_1 <= Inter_ref_04_05;Inter_H_window_5_1 <= Inter_ref_05_05;
						
					Inter_H_window_0_6 <= Inter_ref_00_10;Inter_H_window_1_6 <= Inter_ref_01_10; 
					Inter_H_window_2_6 <= Inter_ref_02_10;Inter_H_window_3_6 <= Inter_ref_03_10;
					Inter_H_window_4_6 <= Inter_ref_04_10;Inter_H_window_5_6 <= Inter_ref_05_10;
							
					Inter_H_window_0_7 <= Inter_ref_00_11;Inter_H_window_1_7 <= Inter_ref_01_11; 
					Inter_H_window_2_7 <= Inter_ref_02_11;Inter_H_window_3_7 <= Inter_ref_03_11;
					Inter_H_window_4_7 <= Inter_ref_04_11;Inter_H_window_5_7 <= Inter_ref_05_11;
							
					Inter_H_window_0_8 <= Inter_ref_00_12;Inter_H_window_1_8 <= Inter_ref_01_12; 
					Inter_H_window_2_8 <= Inter_ref_02_12;Inter_H_window_3_8 <= Inter_ref_03_12;
					Inter_H_window_4_8 <= Inter_ref_04_12;Inter_H_window_5_8 <= Inter_ref_05_12;
				end
				3'd3:
				begin
					Inter_H_window_0_0 <= Inter_ref_01_04;Inter_H_window_1_0 <= Inter_ref_02_04;
					Inter_H_window_2_0 <= Inter_ref_03_04;Inter_H_window_3_0 <= Inter_ref_04_04;
					Inter_H_window_4_0 <= Inter_ref_05_04;Inter_H_window_5_0 <= Inter_ref_06_04;
							
					Inter_H_window_0_1 <= Inter_ref_01_05;Inter_H_window_1_1 <= Inter_ref_02_05; 
					Inter_H_window_2_1 <= Inter_ref_03_05;Inter_H_window_3_1 <= Inter_ref_04_05;
					Inter_H_window_4_1 <= Inter_ref_05_05;Inter_H_window_5_1 <= Inter_ref_06_05;
						
					Inter_H_window_0_6 <= Inter_ref_01_10;Inter_H_window_1_6 <= Inter_ref_02_10; 
					Inter_H_window_2_6 <= Inter_ref_03_10;Inter_H_window_3_6 <= Inter_ref_04_10;
					Inter_H_window_4_6 <= Inter_ref_05_10;Inter_H_window_5_6 <= Inter_ref_06_10;
							
					Inter_H_window_0_7 <= Inter_ref_01_11;Inter_H_window_1_7 <= Inter_ref_02_11; 
					Inter_H_window_2_7 <= Inter_ref_03_11;Inter_H_window_3_7 <= Inter_ref_04_11;
					Inter_H_window_4_7 <= Inter_ref_05_11;Inter_H_window_5_7 <= Inter_ref_06_11;
							
					Inter_H_window_0_8 <= Inter_ref_01_12;Inter_H_window_1_8 <= Inter_ref_02_12; 
					Inter_H_window_2_8 <= Inter_ref_03_12;Inter_H_window_3_8 <= Inter_ref_04_12;
					Inter_H_window_4_8 <= Inter_ref_05_12;Inter_H_window_5_8 <= Inter_ref_06_12;
				end
				3'd2:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_02_04;Inter_H_window_1_0 <= Inter_ref_03_04;
					Inter_H_window_2_0 <= Inter_ref_04_04;Inter_H_window_3_0 <= Inter_ref_05_04;
					Inter_H_window_4_0 <= Inter_ref_06_04;Inter_H_window_5_0 <= Inter_ref_07_04;
							
					Inter_H_window_0_1 <= Inter_ref_02_05;Inter_H_window_1_1 <= Inter_ref_03_05; 
					Inter_H_window_2_1 <= Inter_ref_04_05;Inter_H_window_3_1 <= Inter_ref_05_05;
					Inter_H_window_4_1 <= Inter_ref_06_05;Inter_H_window_5_1 <= Inter_ref_07_05;
						
					Inter_H_window_0_6 <= Inter_ref_02_10;Inter_H_window_1_6 <= Inter_ref_03_10; 
					Inter_H_window_2_6 <= Inter_ref_04_10;Inter_H_window_3_6 <= Inter_ref_05_10;
					Inter_H_window_4_6 <= Inter_ref_06_10;Inter_H_window_5_6 <= Inter_ref_07_10;
							
					Inter_H_window_0_7 <= Inter_ref_02_11;Inter_H_window_1_7 <= Inter_ref_03_11; 
					Inter_H_window_2_7 <= Inter_ref_04_11;Inter_H_window_3_7 <= Inter_ref_05_11;
					Inter_H_window_4_7 <= Inter_ref_06_11;Inter_H_window_5_7 <= Inter_ref_07_11;
							
					Inter_H_window_0_8 <= Inter_ref_02_12;Inter_H_window_1_8 <= Inter_ref_03_12; 
					Inter_H_window_2_8 <= Inter_ref_04_12;Inter_H_window_3_8 <= Inter_ref_05_12;
					Inter_H_window_4_8 <= Inter_ref_06_12;Inter_H_window_5_8 <= Inter_ref_07_12;
				end
				3'd1:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_03_04;Inter_H_window_1_0 <= Inter_ref_04_04;
					Inter_H_window_2_0 <= Inter_ref_05_04;Inter_H_window_3_0 <= Inter_ref_06_04;
					Inter_H_window_4_0 <= Inter_ref_07_04;Inter_H_window_5_0 <= Inter_ref_08_04;
							
					Inter_H_window_0_1 <= Inter_ref_03_05;Inter_H_window_1_1 <= Inter_ref_04_05; 
					Inter_H_window_2_1 <= Inter_ref_05_05;Inter_H_window_3_1 <= Inter_ref_06_05;
					Inter_H_window_4_1 <= Inter_ref_07_05;Inter_H_window_5_1 <= Inter_ref_08_05;
						
					Inter_H_window_0_6 <= Inter_ref_03_10;Inter_H_window_1_6 <= Inter_ref_04_10; 
					Inter_H_window_2_6 <= Inter_ref_05_10;Inter_H_window_3_6 <= Inter_ref_06_10;
					Inter_H_window_4_6 <= Inter_ref_07_10;Inter_H_window_5_6 <= Inter_ref_08_10;
							
					Inter_H_window_0_7 <= Inter_ref_03_11;Inter_H_window_1_7 <= Inter_ref_04_11; 
					Inter_H_window_2_7 <= Inter_ref_05_11;Inter_H_window_3_7 <= Inter_ref_06_11;
					Inter_H_window_4_7 <= Inter_ref_07_11;Inter_H_window_5_7 <= Inter_ref_08_11;
							
					Inter_H_window_0_8 <= Inter_ref_03_12;Inter_H_window_1_8 <= Inter_ref_04_12; 
					Inter_H_window_2_8 <= Inter_ref_05_12;Inter_H_window_3_8 <= Inter_ref_06_12;
					Inter_H_window_4_8 <= Inter_ref_07_12;Inter_H_window_5_8 <= Inter_ref_08_12;
				end
				default:
				begin
					Inter_H_window_0_0 <= 0;Inter_H_window_1_0 <= 0;Inter_H_window_2_0 <= 0;
					Inter_H_window_3_0 <= 0;Inter_H_window_4_0 <= 0;Inter_H_window_5_0 <= 0;
						
					Inter_H_window_0_1 <= 0;Inter_H_window_1_1 <= 0;Inter_H_window_2_1 <= 0;
					Inter_H_window_3_1 <= 0;Inter_H_window_4_1 <= 0;Inter_H_window_5_1 <= 0;
						
					Inter_H_window_0_6 <= 0;Inter_H_window_1_6 <= 0;Inter_H_window_2_6 <= 0;
					Inter_H_window_3_6 <= 0;Inter_H_window_4_6 <= 0;Inter_H_window_5_6 <= 0;
							
					Inter_H_window_0_7 <= 0;Inter_H_window_1_7 <= 0;Inter_H_window_2_7 <= 0;
					Inter_H_window_3_7 <= 0;Inter_H_window_4_7 <= 0;Inter_H_window_5_7 <= 0;
							
					Inter_H_window_0_8 <= 0;Inter_H_window_1_8 <= 0;Inter_H_window_2_8 <= 0;
					Inter_H_window_3_8 <= 0;Inter_H_window_4_8 <= 0;Inter_H_window_5_8 <= 0;
				end
			endcase
			4'b0001: //Right bottom blk4x4
			case (Inter_H_window_counter0)
				3'd4:
				begin
					Inter_H_window_0_0 <= Inter_ref_04_04;Inter_H_window_1_0 <= Inter_ref_05_04;
					Inter_H_window_2_0 <= Inter_ref_06_04;Inter_H_window_3_0 <= Inter_ref_07_04;
					Inter_H_window_4_0 <= Inter_ref_08_04;Inter_H_window_5_0 <= Inter_ref_09_04;
							
					Inter_H_window_0_1 <= Inter_ref_04_05;Inter_H_window_1_1 <= Inter_ref_05_05; 
					Inter_H_window_2_1 <= Inter_ref_06_05;Inter_H_window_3_1 <= Inter_ref_07_05;
					Inter_H_window_4_1 <= Inter_ref_08_05;Inter_H_window_5_1 <= Inter_ref_09_05;
						
					Inter_H_window_0_6 <= Inter_ref_04_10;Inter_H_window_1_6 <= Inter_ref_05_10; 
					Inter_H_window_2_6 <= Inter_ref_06_10;Inter_H_window_3_6 <= Inter_ref_07_10;
					Inter_H_window_4_6 <= Inter_ref_08_10;Inter_H_window_5_6 <= Inter_ref_09_10;
							
					Inter_H_window_0_7 <= Inter_ref_04_11;Inter_H_window_1_7 <= Inter_ref_05_11; 
					Inter_H_window_2_7 <= Inter_ref_06_11;Inter_H_window_3_7 <= Inter_ref_07_11;
					Inter_H_window_4_7 <= Inter_ref_08_11;Inter_H_window_5_7 <= Inter_ref_09_11;
							
					Inter_H_window_0_8 <= Inter_ref_04_12;Inter_H_window_1_8 <= Inter_ref_05_12; 
					Inter_H_window_2_8 <= Inter_ref_06_12;Inter_H_window_3_8 <= Inter_ref_07_12;
					Inter_H_window_4_8 <= Inter_ref_08_12;Inter_H_window_5_8 <= Inter_ref_09_12;
				end
				3'd3:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_05_04;Inter_H_window_1_0 <= Inter_ref_06_04;
					Inter_H_window_2_0 <= Inter_ref_07_04;Inter_H_window_3_0 <= Inter_ref_08_04;
					Inter_H_window_4_0 <= Inter_ref_09_04;Inter_H_window_5_0 <= Inter_ref_10_04;
							
					Inter_H_window_0_1 <= Inter_ref_05_05;Inter_H_window_1_1 <= Inter_ref_06_05; 
					Inter_H_window_2_1 <= Inter_ref_07_05;Inter_H_window_3_1 <= Inter_ref_08_05;
					Inter_H_window_4_1 <= Inter_ref_09_05;Inter_H_window_5_1 <= Inter_ref_10_05;
						
					Inter_H_window_0_6 <= Inter_ref_05_10;Inter_H_window_1_6 <= Inter_ref_06_10; 
					Inter_H_window_2_6 <= Inter_ref_07_10;Inter_H_window_3_6 <= Inter_ref_08_10;
					Inter_H_window_4_6 <= Inter_ref_09_10;Inter_H_window_5_6 <= Inter_ref_10_10;
							
					Inter_H_window_0_7 <= Inter_ref_05_11;Inter_H_window_1_7 <= Inter_ref_06_11; 
					Inter_H_window_2_7 <= Inter_ref_07_11;Inter_H_window_3_7 <= Inter_ref_08_11;
					Inter_H_window_4_7 <= Inter_ref_09_11;Inter_H_window_5_7 <= Inter_ref_10_11;
							
					Inter_H_window_0_8 <= Inter_ref_05_12;Inter_H_window_1_8 <= Inter_ref_06_12; 
					Inter_H_window_2_8 <= Inter_ref_07_12;Inter_H_window_3_8 <= Inter_ref_08_12;
					Inter_H_window_4_8 <= Inter_ref_09_12;Inter_H_window_5_8 <= Inter_ref_10_12;
				end
				3'd2:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_06_04;Inter_H_window_1_0 <= Inter_ref_07_04;
					Inter_H_window_2_0 <= Inter_ref_08_04;Inter_H_window_3_0 <= Inter_ref_09_04;
					Inter_H_window_4_0 <= Inter_ref_10_04;Inter_H_window_5_0 <= Inter_ref_11_04;
							
					Inter_H_window_0_1 <= Inter_ref_06_05;Inter_H_window_1_1 <= Inter_ref_07_05; 
					Inter_H_window_2_1 <= Inter_ref_08_05;Inter_H_window_3_1 <= Inter_ref_09_05;
					Inter_H_window_4_1 <= Inter_ref_10_05;Inter_H_window_5_1 <= Inter_ref_11_05;
						
					Inter_H_window_0_6 <= Inter_ref_06_10;Inter_H_window_1_6 <= Inter_ref_07_10; 
					Inter_H_window_2_6 <= Inter_ref_08_10;Inter_H_window_3_6 <= Inter_ref_09_10;
					Inter_H_window_4_6 <= Inter_ref_10_10;Inter_H_window_5_6 <= Inter_ref_11_10;
							
					Inter_H_window_0_7 <= Inter_ref_06_11;Inter_H_window_1_7 <= Inter_ref_07_11; 
					Inter_H_window_2_7 <= Inter_ref_08_11;Inter_H_window_3_7 <= Inter_ref_09_11;
					Inter_H_window_4_7 <= Inter_ref_10_11;Inter_H_window_5_7 <= Inter_ref_11_11;
							
					Inter_H_window_0_8 <= Inter_ref_06_12;Inter_H_window_1_8 <= Inter_ref_07_12; 
					Inter_H_window_2_8 <= Inter_ref_08_12;Inter_H_window_3_8 <= Inter_ref_09_12;
					Inter_H_window_4_8 <= Inter_ref_10_12;Inter_H_window_5_8 <= Inter_ref_11_12;
				end
				3'd1:
				begin 	
					Inter_H_window_0_0 <= Inter_ref_07_04;Inter_H_window_1_0 <= Inter_ref_08_04;
					Inter_H_window_2_0 <= Inter_ref_09_04;Inter_H_window_3_0 <= Inter_ref_10_04;
					Inter_H_window_4_0 <= Inter_ref_11_04;Inter_H_window_5_0 <= Inter_ref_12_04;
							
					Inter_H_window_0_1 <= Inter_ref_07_05;Inter_H_window_1_1 <= Inter_ref_08_05; 
					Inter_H_window_2_1 <= Inter_ref_09_05;Inter_H_window_3_1 <= Inter_ref_10_05;
					Inter_H_window_4_1 <= Inter_ref_11_05;Inter_H_window_5_1 <= Inter_ref_12_05;
						
					Inter_H_window_0_6 <= Inter_ref_07_10;Inter_H_window_1_6 <= Inter_ref_08_10; 
					Inter_H_window_2_6 <= Inter_ref_09_10;Inter_H_window_3_6 <= Inter_ref_10_10;
					Inter_H_window_4_6 <= Inter_ref_11_10;Inter_H_window_5_6 <= Inter_ref_12_10;
							
					Inter_H_window_0_7 <= Inter_ref_07_11;Inter_H_window_1_7 <= Inter_ref_08_11; 
					Inter_H_window_2_7 <= Inter_ref_09_11;Inter_H_window_3_7 <= Inter_ref_10_11;
					Inter_H_window_4_7 <= Inter_ref_11_11;Inter_H_window_5_7 <= Inter_ref_12_11;
							
					Inter_H_window_0_8 <= Inter_ref_07_12;Inter_H_window_1_8 <= Inter_ref_08_12; 
					Inter_H_window_2_8 <= Inter_ref_09_12;Inter_H_window_3_8 <= Inter_ref_10_12;
					Inter_H_window_4_8 <= Inter_ref_11_12;Inter_H_window_5_8 <= Inter_ref_12_12;
				end
				default:
				begin
					Inter_H_window_0_0 <= 0;Inter_H_window_1_0 <= 0;Inter_H_window_2_0 <= 0;
					Inter_H_window_3_0 <= 0;Inter_H_window_4_0 <= 0;Inter_H_window_5_0 <= 0;
						
					Inter_H_window_0_1 <= 0;Inter_H_window_1_1 <= 0;Inter_H_window_2_1 <= 0;
					Inter_H_window_3_1 <= 0;Inter_H_window_4_1 <= 0;Inter_H_window_5_1 <= 0;
						
					Inter_H_window_0_6 <= 0;Inter_H_window_1_6 <= 0;Inter_H_window_2_6 <= 0;
					Inter_H_window_3_6 <= 0;Inter_H_window_4_6 <= 0;Inter_H_window_5_6 <= 0;
							
					Inter_H_window_0_7 <= 0;Inter_H_window_1_7 <= 0;Inter_H_window_2_7 <= 0;
					Inter_H_window_3_7 <= 0;Inter_H_window_4_7 <= 0;Inter_H_window_5_7 <= 0;
							
					Inter_H_window_0_8 <= 0;Inter_H_window_1_8 <= 0;Inter_H_window_2_8 <= 0;
					Inter_H_window_3_8 <= 0;Inter_H_window_4_8 <= 0;Inter_H_window_5_8 <= 0;
				end
			endcase
			default:
			begin
				Inter_H_window_0_0 <= 0;Inter_H_window_1_0 <= 0;Inter_H_window_2_0 <= 0;
				Inter_H_window_3_0 <= 0;Inter_H_window_4_0 <= 0;Inter_H_window_5_0 <= 0;
					
				Inter_H_window_0_1 <= 0;Inter_H_window_1_1 <= 0;Inter_H_window_2_1 <= 0;
				Inter_H_window_3_1 <= 0;Inter_H_window_4_1 <= 0;Inter_H_window_5_1 <= 0;
						
				Inter_H_window_0_6 <= 0;Inter_H_window_1_6 <= 0;Inter_H_window_2_6 <= 0;
				Inter_H_window_3_6 <= 0;Inter_H_window_4_6 <= 0;Inter_H_window_5_6 <= 0;
							
				Inter_H_window_0_7 <= 0;Inter_H_window_1_7 <= 0;Inter_H_window_2_7 <= 0;
				Inter_H_window_3_7 <= 0;Inter_H_window_4_7 <= 0;Inter_H_window_5_7 <= 0;
							
				Inter_H_window_0_8 <= 0;Inter_H_window_1_8 <= 0;Inter_H_window_2_8 <= 0;
				Inter_H_window_3_8 <= 0;Inter_H_window_4_8 <= 0;Inter_H_window_5_8 <= 0;
			end
		endcase
		
	//Inter_H_window_counter1:for Inter_H_window_x_2/3/4/5 sliding window control
	reg [2:0] Inter_H_window_counter1;
	always @ (pos_FracL or blk4x4_inter_calculate_counter)
		if (((pos_FracL == `pos_b || pos_FracL == `pos_a || pos_FracL == `pos_c || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd4) 					 ||
			((pos_FracL == `pos_j || pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd5) ||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd8))
			Inter_H_window_counter1 <= 3'd4;
		else if (((pos_FracL == `pos_b || pos_FracL == `pos_a || pos_FracL == `pos_c || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd3) 					 ||
			((pos_FracL == `pos_j || pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd4) ||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd6))
			Inter_H_window_counter1 <= 3'd3;
		else if (((pos_FracL == `pos_b || pos_FracL == `pos_a || pos_FracL == `pos_c || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd2) 					 ||
			((pos_FracL == `pos_j || pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd3) ||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd4))
			Inter_H_window_counter1 <= 3'd2;
		else if (((pos_FracL == `pos_b || pos_FracL == `pos_a || pos_FracL == `pos_c || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd1) 					 ||
			((pos_FracL == `pos_j || pos_FracL == `pos_f || pos_FracL == `pos_q) && blk4x4_inter_calculate_counter == 4'd2) ||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd2))
			Inter_H_window_counter1 <= 3'd1;
		else
			Inter_H_window_counter1 <= 0;
			
	//Inter_H_window_x_2,Inter_H_window_x_3,Inter_H_window_x_4,Inter_H_window_x_5
	always @ (Is_blk4x4_0 or Is_blk4x4_1 or Is_blk4x4_2 or Is_blk4x4_3 or pos_FracL or Inter_H_window_counter1 
		or Inter_ref_00_02 or Inter_ref_01_02 or Inter_ref_02_02 or Inter_ref_03_02
		or Inter_ref_04_02 or Inter_ref_05_02 or Inter_ref_06_02 or Inter_ref_07_02
		or Inter_ref_08_02 or Inter_ref_09_02 or Inter_ref_10_02 or Inter_ref_11_02 or Inter_ref_12_02
		
		or Inter_ref_00_03 or Inter_ref_01_03 or Inter_ref_02_03 or Inter_ref_03_03
		or Inter_ref_04_03 or Inter_ref_05_03 or Inter_ref_06_03 or Inter_ref_07_03
		or Inter_ref_08_03 or Inter_ref_09_03 or Inter_ref_10_03 or Inter_ref_11_03 or Inter_ref_12_03
		
		or Inter_ref_00_04 or Inter_ref_01_04 or Inter_ref_02_04 or Inter_ref_03_04
		or Inter_ref_04_04 or Inter_ref_05_04 or Inter_ref_06_04 or Inter_ref_07_04
		or Inter_ref_08_04 or Inter_ref_09_04 or Inter_ref_10_04 or Inter_ref_11_04 or Inter_ref_12_04
		
		or Inter_ref_00_05 or Inter_ref_01_05 or Inter_ref_02_05 or Inter_ref_03_05
		or Inter_ref_04_05 or Inter_ref_05_05 or Inter_ref_06_05 or Inter_ref_07_05
		or Inter_ref_08_05 or Inter_ref_09_05 or Inter_ref_10_05 or Inter_ref_11_05 or Inter_ref_12_05
		
		or Inter_ref_00_06 or Inter_ref_01_06 or Inter_ref_02_06 or Inter_ref_03_06
		or Inter_ref_04_06 or Inter_ref_05_06 or Inter_ref_06_06 or Inter_ref_07_06
		or Inter_ref_08_06 or Inter_ref_09_06 or Inter_ref_10_06 or Inter_ref_11_06 or Inter_ref_12_06
		
		or Inter_ref_00_07 or Inter_ref_01_07 or Inter_ref_02_07 or Inter_ref_03_07
		or Inter_ref_04_07 or Inter_ref_05_07 or Inter_ref_06_07 or Inter_ref_07_07
		or Inter_ref_08_07 or Inter_ref_09_07 or Inter_ref_10_07 or Inter_ref_11_07 or Inter_ref_12_07
		
		or Inter_ref_00_08 or Inter_ref_01_08 or Inter_ref_02_08 or Inter_ref_03_08
		or Inter_ref_04_08 or Inter_ref_05_08 or Inter_ref_06_08 or Inter_ref_07_08
		or Inter_ref_08_08 or Inter_ref_09_08 or Inter_ref_10_08 or Inter_ref_11_08 or Inter_ref_12_08
		
		or Inter_ref_00_09 or Inter_ref_01_09 or Inter_ref_02_09 or Inter_ref_03_09
		or Inter_ref_04_09 or Inter_ref_05_09 or Inter_ref_06_09 or Inter_ref_07_09
		or Inter_ref_08_09 or Inter_ref_09_09 or Inter_ref_10_09 or Inter_ref_11_09 or Inter_ref_12_09
		
		or Inter_ref_00_10 or Inter_ref_01_10 or Inter_ref_02_10 or Inter_ref_03_10
		or Inter_ref_04_10 or Inter_ref_05_10 or Inter_ref_06_10 or Inter_ref_07_10
		or Inter_ref_08_10 or Inter_ref_09_10 or Inter_ref_10_10 or Inter_ref_11_10 or Inter_ref_12_10
		)
		case ({Is_blk4x4_0,Is_blk4x4_1,Is_blk4x4_2,Is_blk4x4_3}) 
			4'b1000: //Left top blk4x4
			case (Inter_H_window_counter1)
				3'd4:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_00_03;Inter_H_window_1_2 <= Inter_ref_01_03;
						Inter_H_window_2_2 <= Inter_ref_02_03;Inter_H_window_3_2 <= Inter_ref_03_03;
						Inter_H_window_4_2 <= Inter_ref_04_03;Inter_H_window_5_2 <= Inter_ref_05_03;
							
						Inter_H_window_0_3 <= Inter_ref_00_04;Inter_H_window_1_3 <= Inter_ref_01_04;
						Inter_H_window_2_3 <= Inter_ref_02_04;Inter_H_window_3_3 <= Inter_ref_03_04;
						Inter_H_window_4_3 <= Inter_ref_04_04;Inter_H_window_5_3 <= Inter_ref_05_04;
						
						Inter_H_window_0_4 <= Inter_ref_00_05;Inter_H_window_1_4 <= Inter_ref_01_05;
						Inter_H_window_2_4 <= Inter_ref_02_05;Inter_H_window_3_4 <= Inter_ref_03_05;
						Inter_H_window_4_4 <= Inter_ref_04_05;Inter_H_window_5_4 <= Inter_ref_05_05;
							
						Inter_H_window_0_5 <= Inter_ref_00_06;Inter_H_window_1_5 <= Inter_ref_01_06;
						Inter_H_window_2_5 <= Inter_ref_02_06;Inter_H_window_3_5 <= Inter_ref_03_06;
						Inter_H_window_4_5 <= Inter_ref_04_06;Inter_H_window_5_5 <= Inter_ref_05_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_00_02;Inter_H_window_1_2 <= Inter_ref_01_02;
						Inter_H_window_2_2 <= Inter_ref_02_02;Inter_H_window_3_2 <= Inter_ref_03_02;
						Inter_H_window_4_2 <= Inter_ref_04_02;Inter_H_window_5_2 <= Inter_ref_05_02;
							
						Inter_H_window_0_3 <= Inter_ref_00_03;Inter_H_window_1_3 <= Inter_ref_01_03;
						Inter_H_window_2_3 <= Inter_ref_02_03;Inter_H_window_3_3 <= Inter_ref_03_03;
						Inter_H_window_4_3 <= Inter_ref_04_03;Inter_H_window_5_3 <= Inter_ref_05_03;
						
						Inter_H_window_0_4 <= Inter_ref_00_04;Inter_H_window_1_4 <= Inter_ref_01_04;
						Inter_H_window_2_4 <= Inter_ref_02_04;Inter_H_window_3_4 <= Inter_ref_03_04;
						Inter_H_window_4_4 <= Inter_ref_04_04;Inter_H_window_5_4 <= Inter_ref_05_04;
							
						Inter_H_window_0_5 <= Inter_ref_00_05;Inter_H_window_1_5 <= Inter_ref_01_05;
						Inter_H_window_2_5 <= Inter_ref_02_05;Inter_H_window_3_5 <= Inter_ref_03_05;
						Inter_H_window_4_5 <= Inter_ref_04_05;Inter_H_window_5_5 <= Inter_ref_05_05;
					end
				3'd3:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_01_03;Inter_H_window_1_2 <= Inter_ref_02_03;
						Inter_H_window_2_2 <= Inter_ref_03_03;Inter_H_window_3_2 <= Inter_ref_04_03;
						Inter_H_window_4_2 <= Inter_ref_05_03;Inter_H_window_5_2 <= Inter_ref_06_03;
							
						Inter_H_window_0_3 <= Inter_ref_01_04;Inter_H_window_1_3 <= Inter_ref_02_04;
						Inter_H_window_2_3 <= Inter_ref_03_04;Inter_H_window_3_3 <= Inter_ref_04_04;
						Inter_H_window_4_3 <= Inter_ref_05_04;Inter_H_window_5_3 <= Inter_ref_06_04;
						
						Inter_H_window_0_4 <= Inter_ref_01_05;Inter_H_window_1_4 <= Inter_ref_02_05;
						Inter_H_window_2_4 <= Inter_ref_03_05;Inter_H_window_3_4 <= Inter_ref_04_05;
						Inter_H_window_4_4 <= Inter_ref_05_05;Inter_H_window_5_4 <= Inter_ref_06_05;
							
						Inter_H_window_0_5 <= Inter_ref_01_06;Inter_H_window_1_5 <= Inter_ref_02_06;
						Inter_H_window_2_5 <= Inter_ref_03_06;Inter_H_window_3_5 <= Inter_ref_04_06;
						Inter_H_window_4_5 <= Inter_ref_05_06;Inter_H_window_5_5 <= Inter_ref_06_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_01_02;Inter_H_window_1_2 <= Inter_ref_02_02;
						Inter_H_window_2_2 <= Inter_ref_03_02;Inter_H_window_3_2 <= Inter_ref_04_02;
						Inter_H_window_4_2 <= Inter_ref_05_02;Inter_H_window_5_2 <= Inter_ref_06_02;
							
						Inter_H_window_0_3 <= Inter_ref_01_03;Inter_H_window_1_3 <= Inter_ref_02_03;
						Inter_H_window_2_3 <= Inter_ref_03_03;Inter_H_window_3_3 <= Inter_ref_04_03;
						Inter_H_window_4_3 <= Inter_ref_05_03;Inter_H_window_5_3 <= Inter_ref_06_03;
						
						Inter_H_window_0_4 <= Inter_ref_01_04;Inter_H_window_1_4 <= Inter_ref_02_04;
						Inter_H_window_2_4 <= Inter_ref_03_04;Inter_H_window_3_4 <= Inter_ref_04_04;
						Inter_H_window_4_4 <= Inter_ref_05_04;Inter_H_window_5_4 <= Inter_ref_06_04;
							
						Inter_H_window_0_5 <= Inter_ref_01_05;Inter_H_window_1_5 <= Inter_ref_02_05;
						Inter_H_window_2_5 <= Inter_ref_03_05;Inter_H_window_3_5 <= Inter_ref_04_05;
						Inter_H_window_4_5 <= Inter_ref_05_05;Inter_H_window_5_5 <= Inter_ref_06_05;
					end
				3'd2:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_02_03;Inter_H_window_1_2 <= Inter_ref_03_03;
						Inter_H_window_2_2 <= Inter_ref_04_03;Inter_H_window_3_2 <= Inter_ref_05_03;
						Inter_H_window_4_2 <= Inter_ref_06_03;Inter_H_window_5_2 <= Inter_ref_07_03;
							
						Inter_H_window_0_3 <= Inter_ref_02_04;Inter_H_window_1_3 <= Inter_ref_03_04;
						Inter_H_window_2_3 <= Inter_ref_04_04;Inter_H_window_3_3 <= Inter_ref_05_04;
						Inter_H_window_4_3 <= Inter_ref_06_04;Inter_H_window_5_3 <= Inter_ref_07_04;
						
						Inter_H_window_0_4 <= Inter_ref_02_05;Inter_H_window_1_4 <= Inter_ref_03_05;
						Inter_H_window_2_4 <= Inter_ref_04_05;Inter_H_window_3_4 <= Inter_ref_05_05;
						Inter_H_window_4_4 <= Inter_ref_06_05;Inter_H_window_5_4 <= Inter_ref_07_05;
							
						Inter_H_window_0_5 <= Inter_ref_02_06;Inter_H_window_1_5 <= Inter_ref_03_06;
						Inter_H_window_2_5 <= Inter_ref_04_06;Inter_H_window_3_5 <= Inter_ref_05_06;
						Inter_H_window_4_5 <= Inter_ref_06_06;Inter_H_window_5_5 <= Inter_ref_07_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_02_02;Inter_H_window_1_2 <= Inter_ref_03_02;
						Inter_H_window_2_2 <= Inter_ref_04_02;Inter_H_window_3_2 <= Inter_ref_05_02;
						Inter_H_window_4_2 <= Inter_ref_06_02;Inter_H_window_5_2 <= Inter_ref_07_02;
							
						Inter_H_window_0_3 <= Inter_ref_02_03;Inter_H_window_1_3 <= Inter_ref_03_03;
						Inter_H_window_2_3 <= Inter_ref_04_03;Inter_H_window_3_3 <= Inter_ref_05_03;
						Inter_H_window_4_3 <= Inter_ref_06_03;Inter_H_window_5_3 <= Inter_ref_07_03;
						
						Inter_H_window_0_4 <= Inter_ref_02_04;Inter_H_window_1_4 <= Inter_ref_03_04;
						Inter_H_window_2_4 <= Inter_ref_04_04;Inter_H_window_3_4 <= Inter_ref_05_04;
						Inter_H_window_4_4 <= Inter_ref_06_04;Inter_H_window_5_4 <= Inter_ref_07_04;
							
						Inter_H_window_0_5 <= Inter_ref_02_05;Inter_H_window_1_5 <= Inter_ref_03_05;
						Inter_H_window_2_5 <= Inter_ref_04_05;Inter_H_window_3_5 <= Inter_ref_05_05;
						Inter_H_window_4_5 <= Inter_ref_06_05;Inter_H_window_5_5 <= Inter_ref_07_05;
					end	
				3'd1:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_03_03;Inter_H_window_1_2 <= Inter_ref_04_03;
						Inter_H_window_2_2 <= Inter_ref_05_03;Inter_H_window_3_2 <= Inter_ref_06_03;
						Inter_H_window_4_2 <= Inter_ref_07_03;Inter_H_window_5_2 <= Inter_ref_08_03;
							
						Inter_H_window_0_3 <= Inter_ref_03_04;Inter_H_window_1_3 <= Inter_ref_04_04;
						Inter_H_window_2_3 <= Inter_ref_05_04;Inter_H_window_3_3 <= Inter_ref_06_04;
						Inter_H_window_4_3 <= Inter_ref_07_04;Inter_H_window_5_3 <= Inter_ref_08_04;
						
						Inter_H_window_0_4 <= Inter_ref_03_05;Inter_H_window_1_4 <= Inter_ref_04_05;
						Inter_H_window_2_4 <= Inter_ref_05_05;Inter_H_window_3_4 <= Inter_ref_06_05;
						Inter_H_window_4_4 <= Inter_ref_07_05;Inter_H_window_5_4 <= Inter_ref_08_05;
							
						Inter_H_window_0_5 <= Inter_ref_03_06;Inter_H_window_1_5 <= Inter_ref_04_06;
						Inter_H_window_2_5 <= Inter_ref_05_06;Inter_H_window_3_5 <= Inter_ref_06_06;
						Inter_H_window_4_5 <= Inter_ref_07_06;Inter_H_window_5_5 <= Inter_ref_08_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_03_02;Inter_H_window_1_2 <= Inter_ref_04_02;
						Inter_H_window_2_2 <= Inter_ref_05_02;Inter_H_window_3_2 <= Inter_ref_06_02;
						Inter_H_window_4_2 <= Inter_ref_07_02;Inter_H_window_5_2 <= Inter_ref_08_02;
							
						Inter_H_window_0_3 <= Inter_ref_03_03;Inter_H_window_1_3 <= Inter_ref_04_03;
						Inter_H_window_2_3 <= Inter_ref_05_03;Inter_H_window_3_3 <= Inter_ref_06_03;
						Inter_H_window_4_3 <= Inter_ref_07_03;Inter_H_window_5_3 <= Inter_ref_08_03;
						
						Inter_H_window_0_4 <= Inter_ref_03_04;Inter_H_window_1_4 <= Inter_ref_04_04;
						Inter_H_window_2_4 <= Inter_ref_05_04;Inter_H_window_3_4 <= Inter_ref_06_04;
						Inter_H_window_4_4 <= Inter_ref_07_04;Inter_H_window_5_4 <= Inter_ref_08_04;
							
						Inter_H_window_0_5 <= Inter_ref_03_05;Inter_H_window_1_5 <= Inter_ref_04_05;
						Inter_H_window_2_5 <= Inter_ref_05_05;Inter_H_window_3_5 <= Inter_ref_06_05;
						Inter_H_window_4_5 <= Inter_ref_07_05;Inter_H_window_5_5 <= Inter_ref_08_05;
					end
				default:
				begin
					Inter_H_window_0_2 <= 0;Inter_H_window_1_2 <= 0;Inter_H_window_2_2 <= 0;
					Inter_H_window_3_2 <= 0;Inter_H_window_4_2 <= 0;Inter_H_window_5_2 <= 0;
						
					Inter_H_window_0_3 <= 0;Inter_H_window_1_3 <= 0;Inter_H_window_2_3 <= 0;
					Inter_H_window_3_3 <= 0;Inter_H_window_4_3 <= 0;Inter_H_window_5_3 <= 0;
						
					Inter_H_window_0_4 <= 0;Inter_H_window_1_4 <= 0;Inter_H_window_2_4 <= 0;
					Inter_H_window_3_4 <= 0;Inter_H_window_4_4 <= 0;Inter_H_window_5_4 <= 0;
							
					Inter_H_window_0_5 <= 0;Inter_H_window_1_5 <= 0;Inter_H_window_2_5 <= 0;
					Inter_H_window_3_5 <= 0;Inter_H_window_4_5 <= 0;Inter_H_window_5_5 <= 0;
				end
			endcase
			4'b0100: //Right top blk4x4
			case (Inter_H_window_counter1)
				3'd4:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_04_03;Inter_H_window_1_2 <= Inter_ref_05_03;
						Inter_H_window_2_2 <= Inter_ref_06_03;Inter_H_window_3_2 <= Inter_ref_07_03;
						Inter_H_window_4_2 <= Inter_ref_08_03;Inter_H_window_5_2 <= Inter_ref_09_03;
							
						Inter_H_window_0_3 <= Inter_ref_04_04;Inter_H_window_1_3 <= Inter_ref_05_04;
						Inter_H_window_2_3 <= Inter_ref_06_04;Inter_H_window_3_3 <= Inter_ref_07_04;
						Inter_H_window_4_3 <= Inter_ref_08_04;Inter_H_window_5_3 <= Inter_ref_09_04;
						
						Inter_H_window_0_4 <= Inter_ref_04_05;Inter_H_window_1_4 <= Inter_ref_05_05;
						Inter_H_window_2_4 <= Inter_ref_06_05;Inter_H_window_3_4 <= Inter_ref_07_05;
						Inter_H_window_4_4 <= Inter_ref_08_05;Inter_H_window_5_4 <= Inter_ref_09_05;
							
						Inter_H_window_0_5 <= Inter_ref_04_06;Inter_H_window_1_5 <= Inter_ref_05_06;
						Inter_H_window_2_5 <= Inter_ref_06_06;Inter_H_window_3_5 <= Inter_ref_07_06;
						Inter_H_window_4_5 <= Inter_ref_08_06;Inter_H_window_5_5 <= Inter_ref_09_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_04_02;Inter_H_window_1_2 <= Inter_ref_05_02;
						Inter_H_window_2_2 <= Inter_ref_06_02;Inter_H_window_3_2 <= Inter_ref_07_02;
						Inter_H_window_4_2 <= Inter_ref_08_02;Inter_H_window_5_2 <= Inter_ref_09_02;
							
						Inter_H_window_0_3 <= Inter_ref_04_03;Inter_H_window_1_3 <= Inter_ref_05_03;
						Inter_H_window_2_3 <= Inter_ref_06_03;Inter_H_window_3_3 <= Inter_ref_07_03;
						Inter_H_window_4_3 <= Inter_ref_08_03;Inter_H_window_5_3 <= Inter_ref_09_03;
						
						Inter_H_window_0_4 <= Inter_ref_04_04;Inter_H_window_1_4 <= Inter_ref_05_04;
						Inter_H_window_2_4 <= Inter_ref_06_04;Inter_H_window_3_4 <= Inter_ref_07_04;
						Inter_H_window_4_4 <= Inter_ref_08_04;Inter_H_window_5_4 <= Inter_ref_09_04;
							
						Inter_H_window_0_5 <= Inter_ref_04_05;Inter_H_window_1_5 <= Inter_ref_05_05;
						Inter_H_window_2_5 <= Inter_ref_06_05;Inter_H_window_3_5 <= Inter_ref_07_05;
						Inter_H_window_4_5 <= Inter_ref_08_05;Inter_H_window_5_5 <= Inter_ref_09_05;
					end
				3'd3:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_05_03;Inter_H_window_1_2 <= Inter_ref_06_03;
						Inter_H_window_2_2 <= Inter_ref_07_03;Inter_H_window_3_2 <= Inter_ref_08_03;
						Inter_H_window_4_2 <= Inter_ref_09_03;Inter_H_window_5_2 <= Inter_ref_10_03;
							
						Inter_H_window_0_3 <= Inter_ref_05_04;Inter_H_window_1_3 <= Inter_ref_06_04;
						Inter_H_window_2_3 <= Inter_ref_07_04;Inter_H_window_3_3 <= Inter_ref_08_04;
						Inter_H_window_4_3 <= Inter_ref_09_04;Inter_H_window_5_3 <= Inter_ref_10_04;
						
						Inter_H_window_0_4 <= Inter_ref_05_05;Inter_H_window_1_4 <= Inter_ref_06_05;
						Inter_H_window_2_4 <= Inter_ref_07_05;Inter_H_window_3_4 <= Inter_ref_08_05;
						Inter_H_window_4_4 <= Inter_ref_09_05;Inter_H_window_5_4 <= Inter_ref_10_05;
							
						Inter_H_window_0_5 <= Inter_ref_05_06;Inter_H_window_1_5 <= Inter_ref_06_06;
						Inter_H_window_2_5 <= Inter_ref_07_06;Inter_H_window_3_5 <= Inter_ref_08_06;
						Inter_H_window_4_5 <= Inter_ref_09_06;Inter_H_window_5_5 <= Inter_ref_10_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_05_02;Inter_H_window_1_2 <= Inter_ref_06_02;
						Inter_H_window_2_2 <= Inter_ref_07_02;Inter_H_window_3_2 <= Inter_ref_08_02;
						Inter_H_window_4_2 <= Inter_ref_09_02;Inter_H_window_5_2 <= Inter_ref_10_02;
							
						Inter_H_window_0_3 <= Inter_ref_05_03;Inter_H_window_1_3 <= Inter_ref_06_03;
						Inter_H_window_2_3 <= Inter_ref_07_03;Inter_H_window_3_3 <= Inter_ref_08_03;
						Inter_H_window_4_3 <= Inter_ref_09_03;Inter_H_window_5_3 <= Inter_ref_10_03;
						
						Inter_H_window_0_4 <= Inter_ref_05_04;Inter_H_window_1_4 <= Inter_ref_06_04;
						Inter_H_window_2_4 <= Inter_ref_07_04;Inter_H_window_3_4 <= Inter_ref_08_04;
						Inter_H_window_4_4 <= Inter_ref_09_04;Inter_H_window_5_4 <= Inter_ref_10_04;
							
						Inter_H_window_0_5 <= Inter_ref_05_05;Inter_H_window_1_5 <= Inter_ref_06_05;
						Inter_H_window_2_5 <= Inter_ref_07_05;Inter_H_window_3_5 <= Inter_ref_08_05;
						Inter_H_window_4_5 <= Inter_ref_09_05;Inter_H_window_5_5 <= Inter_ref_10_05;
					end
				3'd2:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_06_03;Inter_H_window_1_2 <= Inter_ref_07_03;
						Inter_H_window_2_2 <= Inter_ref_08_03;Inter_H_window_3_2 <= Inter_ref_09_03;
						Inter_H_window_4_2 <= Inter_ref_10_03;Inter_H_window_5_2 <= Inter_ref_11_03;
							
						Inter_H_window_0_3 <= Inter_ref_06_04;Inter_H_window_1_3 <= Inter_ref_07_04;
						Inter_H_window_2_3 <= Inter_ref_08_04;Inter_H_window_3_3 <= Inter_ref_09_04;
						Inter_H_window_4_3 <= Inter_ref_10_04;Inter_H_window_5_3 <= Inter_ref_11_04;
						
						Inter_H_window_0_4 <= Inter_ref_06_05;Inter_H_window_1_4 <= Inter_ref_07_05;
						Inter_H_window_2_4 <= Inter_ref_08_05;Inter_H_window_3_4 <= Inter_ref_09_05;
						Inter_H_window_4_4 <= Inter_ref_10_05;Inter_H_window_5_4 <= Inter_ref_11_05;
							
						Inter_H_window_0_5 <= Inter_ref_06_06;Inter_H_window_1_5 <= Inter_ref_07_06;
						Inter_H_window_2_5 <= Inter_ref_08_06;Inter_H_window_3_5 <= Inter_ref_09_06;
						Inter_H_window_4_5 <= Inter_ref_10_06;Inter_H_window_5_5 <= Inter_ref_11_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_06_02;Inter_H_window_1_2 <= Inter_ref_07_02;
						Inter_H_window_2_2 <= Inter_ref_08_02;Inter_H_window_3_2 <= Inter_ref_09_02;
						Inter_H_window_4_2 <= Inter_ref_10_02;Inter_H_window_5_2 <= Inter_ref_11_02;
							
						Inter_H_window_0_3 <= Inter_ref_06_03;Inter_H_window_1_3 <= Inter_ref_07_03;
						Inter_H_window_2_3 <= Inter_ref_08_03;Inter_H_window_3_3 <= Inter_ref_09_03;
						Inter_H_window_4_3 <= Inter_ref_10_03;Inter_H_window_5_3 <= Inter_ref_11_03;
						
						Inter_H_window_0_4 <= Inter_ref_06_04;Inter_H_window_1_4 <= Inter_ref_07_04;
						Inter_H_window_2_4 <= Inter_ref_08_04;Inter_H_window_3_4 <= Inter_ref_09_04;
						Inter_H_window_4_4 <= Inter_ref_10_04;Inter_H_window_5_4 <= Inter_ref_11_04;
							
						Inter_H_window_0_5 <= Inter_ref_06_05;Inter_H_window_1_5 <= Inter_ref_07_05;
						Inter_H_window_2_5 <= Inter_ref_08_05;Inter_H_window_3_5 <= Inter_ref_09_05;
						Inter_H_window_4_5 <= Inter_ref_10_05;Inter_H_window_5_5 <= Inter_ref_11_05;
					end	
				3'd1:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_07_03;Inter_H_window_1_2 <= Inter_ref_08_03;
						Inter_H_window_2_2 <= Inter_ref_09_03;Inter_H_window_3_2 <= Inter_ref_10_03;
						Inter_H_window_4_2 <= Inter_ref_11_03;Inter_H_window_5_2 <= Inter_ref_12_03;
							
						Inter_H_window_0_3 <= Inter_ref_07_04;Inter_H_window_1_3 <= Inter_ref_08_04;
						Inter_H_window_2_3 <= Inter_ref_09_04;Inter_H_window_3_3 <= Inter_ref_10_04;
						Inter_H_window_4_3 <= Inter_ref_11_04;Inter_H_window_5_3 <= Inter_ref_12_04;
						
						Inter_H_window_0_4 <= Inter_ref_07_05;Inter_H_window_1_4 <= Inter_ref_08_05;
						Inter_H_window_2_4 <= Inter_ref_09_05;Inter_H_window_3_4 <= Inter_ref_10_05;
						Inter_H_window_4_4 <= Inter_ref_11_05;Inter_H_window_5_4 <= Inter_ref_12_05;
							                                                                
						Inter_H_window_0_5 <= Inter_ref_07_06;Inter_H_window_1_5 <= Inter_ref_08_06;
						Inter_H_window_2_5 <= Inter_ref_09_06;Inter_H_window_3_5 <= Inter_ref_10_06;
						Inter_H_window_4_5 <= Inter_ref_11_06;Inter_H_window_5_5 <= Inter_ref_12_06;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_07_02;Inter_H_window_1_2 <= Inter_ref_08_02;
						Inter_H_window_2_2 <= Inter_ref_09_02;Inter_H_window_3_2 <= Inter_ref_10_02;
						Inter_H_window_4_2 <= Inter_ref_11_02;Inter_H_window_5_2 <= Inter_ref_12_02;
							                                                                
						Inter_H_window_0_3 <= Inter_ref_07_03;Inter_H_window_1_3 <= Inter_ref_08_03;
						Inter_H_window_2_3 <= Inter_ref_09_03;Inter_H_window_3_3 <= Inter_ref_10_03;
						Inter_H_window_4_3 <= Inter_ref_11_03;Inter_H_window_5_3 <= Inter_ref_12_03;
						                                                                        
						Inter_H_window_0_4 <= Inter_ref_07_04;Inter_H_window_1_4 <= Inter_ref_08_04;
						Inter_H_window_2_4 <= Inter_ref_09_04;Inter_H_window_3_4 <= Inter_ref_10_04;
						Inter_H_window_4_4 <= Inter_ref_11_04;Inter_H_window_5_4 <= Inter_ref_12_04;
							                                                                
						Inter_H_window_0_5 <= Inter_ref_07_05;Inter_H_window_1_5 <= Inter_ref_08_05;
						Inter_H_window_2_5 <= Inter_ref_09_05;Inter_H_window_3_5 <= Inter_ref_10_05;
						Inter_H_window_4_5 <= Inter_ref_11_05;Inter_H_window_5_5 <= Inter_ref_12_05;
					end
				default:
				begin
					Inter_H_window_0_2 <= 0;Inter_H_window_1_2 <= 0;Inter_H_window_2_2 <= 0;
					Inter_H_window_3_2 <= 0;Inter_H_window_4_2 <= 0;Inter_H_window_5_2 <= 0;
						
					Inter_H_window_0_3 <= 0;Inter_H_window_1_3 <= 0;Inter_H_window_2_3 <= 0;
					Inter_H_window_3_3 <= 0;Inter_H_window_4_3 <= 0;Inter_H_window_5_3 <= 0;
						
					Inter_H_window_0_4 <= 0;Inter_H_window_1_4 <= 0;Inter_H_window_2_4 <= 0;
					Inter_H_window_3_4 <= 0;Inter_H_window_4_4 <= 0;Inter_H_window_5_4 <= 0;
							
					Inter_H_window_0_5 <= 0;Inter_H_window_1_5 <= 0;Inter_H_window_2_5 <= 0;
					Inter_H_window_3_5 <= 0;Inter_H_window_4_5 <= 0;Inter_H_window_5_5 <= 0;
				end
			endcase
			4'b0010: //Left bottom blk4x4
			case (Inter_H_window_counter1)
				3'd4:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_00_07;Inter_H_window_1_2 <= Inter_ref_01_07;
						Inter_H_window_2_2 <= Inter_ref_02_07;Inter_H_window_3_2 <= Inter_ref_03_07;
						Inter_H_window_4_2 <= Inter_ref_04_07;Inter_H_window_5_2 <= Inter_ref_05_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_00_08;Inter_H_window_1_3 <= Inter_ref_01_08;
						Inter_H_window_2_3 <= Inter_ref_02_08;Inter_H_window_3_3 <= Inter_ref_03_08;
						Inter_H_window_4_3 <= Inter_ref_04_08;Inter_H_window_5_3 <= Inter_ref_05_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_00_09;Inter_H_window_1_4 <= Inter_ref_01_09;
						Inter_H_window_2_4 <= Inter_ref_02_09;Inter_H_window_3_4 <= Inter_ref_03_09;
						Inter_H_window_4_4 <= Inter_ref_04_09;Inter_H_window_5_4 <= Inter_ref_05_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_00_10;Inter_H_window_1_5 <= Inter_ref_01_10;
						Inter_H_window_2_5 <= Inter_ref_02_10;Inter_H_window_3_5 <= Inter_ref_03_10;
						Inter_H_window_4_5 <= Inter_ref_04_10;Inter_H_window_5_5 <= Inter_ref_05_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_00_06;Inter_H_window_1_2 <= Inter_ref_01_06;
						Inter_H_window_2_2 <= Inter_ref_02_06;Inter_H_window_3_2 <= Inter_ref_03_06;
						Inter_H_window_4_2 <= Inter_ref_04_06;Inter_H_window_5_2 <= Inter_ref_05_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_00_07;Inter_H_window_1_3 <= Inter_ref_01_07;
						Inter_H_window_2_3 <= Inter_ref_02_07;Inter_H_window_3_3 <= Inter_ref_03_07;
						Inter_H_window_4_3 <= Inter_ref_04_07;Inter_H_window_5_3 <= Inter_ref_05_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_00_08;Inter_H_window_1_4 <= Inter_ref_01_08;
						Inter_H_window_2_4 <= Inter_ref_02_08;Inter_H_window_3_4 <= Inter_ref_03_08;
						Inter_H_window_4_4 <= Inter_ref_04_08;Inter_H_window_5_4 <= Inter_ref_05_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_00_09;Inter_H_window_1_5 <= Inter_ref_01_09;
						Inter_H_window_2_5 <= Inter_ref_02_09;Inter_H_window_3_5 <= Inter_ref_03_09;
						Inter_H_window_4_5 <= Inter_ref_04_09;Inter_H_window_5_5 <= Inter_ref_05_09;
					end
				3'd3:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_01_07;Inter_H_window_1_2 <= Inter_ref_02_07;
						Inter_H_window_2_2 <= Inter_ref_03_07;Inter_H_window_3_2 <= Inter_ref_04_07;
						Inter_H_window_4_2 <= Inter_ref_05_07;Inter_H_window_5_2 <= Inter_ref_06_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_01_08;Inter_H_window_1_3 <= Inter_ref_02_08;
						Inter_H_window_2_3 <= Inter_ref_03_08;Inter_H_window_3_3 <= Inter_ref_04_08;
						Inter_H_window_4_3 <= Inter_ref_05_08;Inter_H_window_5_3 <= Inter_ref_06_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_01_09;Inter_H_window_1_4 <= Inter_ref_02_09;
						Inter_H_window_2_4 <= Inter_ref_03_09;Inter_H_window_3_4 <= Inter_ref_04_09;
						Inter_H_window_4_4 <= Inter_ref_05_09;Inter_H_window_5_4 <= Inter_ref_06_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_01_10;Inter_H_window_1_5 <= Inter_ref_02_10;
						Inter_H_window_2_5 <= Inter_ref_03_10;Inter_H_window_3_5 <= Inter_ref_04_10;
						Inter_H_window_4_5 <= Inter_ref_05_10;Inter_H_window_5_5 <= Inter_ref_06_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_01_06;Inter_H_window_1_2 <= Inter_ref_02_06;
						Inter_H_window_2_2 <= Inter_ref_03_06;Inter_H_window_3_2 <= Inter_ref_04_06;
						Inter_H_window_4_2 <= Inter_ref_05_06;Inter_H_window_5_2 <= Inter_ref_06_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_01_07;Inter_H_window_1_3 <= Inter_ref_02_07;
						Inter_H_window_2_3 <= Inter_ref_03_07;Inter_H_window_3_3 <= Inter_ref_04_07;
						Inter_H_window_4_3 <= Inter_ref_05_07;Inter_H_window_5_3 <= Inter_ref_06_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_01_08;Inter_H_window_1_4 <= Inter_ref_02_08;
						Inter_H_window_2_4 <= Inter_ref_03_08;Inter_H_window_3_4 <= Inter_ref_04_08;
						Inter_H_window_4_4 <= Inter_ref_05_08;Inter_H_window_5_4 <= Inter_ref_06_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_01_09;Inter_H_window_1_5 <= Inter_ref_02_09;
						Inter_H_window_2_5 <= Inter_ref_03_09;Inter_H_window_3_5 <= Inter_ref_04_09;
						Inter_H_window_4_5 <= Inter_ref_05_09;Inter_H_window_5_5 <= Inter_ref_06_09;
					end
				3'd2:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_02_07;Inter_H_window_1_2 <= Inter_ref_03_07;
						Inter_H_window_2_2 <= Inter_ref_04_07;Inter_H_window_3_2 <= Inter_ref_05_07;
						Inter_H_window_4_2 <= Inter_ref_06_07;Inter_H_window_5_2 <= Inter_ref_07_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_02_08;Inter_H_window_1_3 <= Inter_ref_03_08;
						Inter_H_window_2_3 <= Inter_ref_04_08;Inter_H_window_3_3 <= Inter_ref_05_08;
						Inter_H_window_4_3 <= Inter_ref_06_08;Inter_H_window_5_3 <= Inter_ref_07_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_02_09;Inter_H_window_1_4 <= Inter_ref_03_09;
						Inter_H_window_2_4 <= Inter_ref_04_09;Inter_H_window_3_4 <= Inter_ref_05_09;
						Inter_H_window_4_4 <= Inter_ref_06_09;Inter_H_window_5_4 <= Inter_ref_07_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_02_10;Inter_H_window_1_5 <= Inter_ref_03_10;
						Inter_H_window_2_5 <= Inter_ref_04_10;Inter_H_window_3_5 <= Inter_ref_05_10;
						Inter_H_window_4_5 <= Inter_ref_06_10;Inter_H_window_5_5 <= Inter_ref_07_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_02_06;Inter_H_window_1_2 <= Inter_ref_03_06;
						Inter_H_window_2_2 <= Inter_ref_04_06;Inter_H_window_3_2 <= Inter_ref_05_06;
						Inter_H_window_4_2 <= Inter_ref_06_06;Inter_H_window_5_2 <= Inter_ref_07_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_02_07;Inter_H_window_1_3 <= Inter_ref_03_07;
						Inter_H_window_2_3 <= Inter_ref_04_07;Inter_H_window_3_3 <= Inter_ref_05_07;
						Inter_H_window_4_3 <= Inter_ref_06_07;Inter_H_window_5_3 <= Inter_ref_07_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_02_08;Inter_H_window_1_4 <= Inter_ref_03_08;
						Inter_H_window_2_4 <= Inter_ref_04_08;Inter_H_window_3_4 <= Inter_ref_05_08;
						Inter_H_window_4_4 <= Inter_ref_06_08;Inter_H_window_5_4 <= Inter_ref_07_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_02_09;Inter_H_window_1_5 <= Inter_ref_03_09;
						Inter_H_window_2_5 <= Inter_ref_04_09;Inter_H_window_3_5 <= Inter_ref_05_09;
						Inter_H_window_4_5 <= Inter_ref_06_09;Inter_H_window_5_5 <= Inter_ref_07_09;
					end	
				3'd1:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_03_07;Inter_H_window_1_2 <= Inter_ref_04_07;
						Inter_H_window_2_2 <= Inter_ref_05_07;Inter_H_window_3_2 <= Inter_ref_06_07;
						Inter_H_window_4_2 <= Inter_ref_07_07;Inter_H_window_5_2 <= Inter_ref_08_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_03_08;Inter_H_window_1_3 <= Inter_ref_04_08;
						Inter_H_window_2_3 <= Inter_ref_05_08;Inter_H_window_3_3 <= Inter_ref_06_08;
						Inter_H_window_4_3 <= Inter_ref_07_08;Inter_H_window_5_3 <= Inter_ref_08_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_03_09;Inter_H_window_1_4 <= Inter_ref_04_09;
						Inter_H_window_2_4 <= Inter_ref_05_09;Inter_H_window_3_4 <= Inter_ref_06_09;
						Inter_H_window_4_4 <= Inter_ref_07_09;Inter_H_window_5_4 <= Inter_ref_08_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_03_10;Inter_H_window_1_5 <= Inter_ref_04_10;
						Inter_H_window_2_5 <= Inter_ref_05_10;Inter_H_window_3_5 <= Inter_ref_06_10;
						Inter_H_window_4_5 <= Inter_ref_07_10;Inter_H_window_5_5 <= Inter_ref_08_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_03_06;Inter_H_window_1_2 <= Inter_ref_04_06;
						Inter_H_window_2_2 <= Inter_ref_05_06;Inter_H_window_3_2 <= Inter_ref_06_06;
						Inter_H_window_4_2 <= Inter_ref_07_06;Inter_H_window_5_2 <= Inter_ref_08_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_03_07;Inter_H_window_1_3 <= Inter_ref_04_07;
						Inter_H_window_2_3 <= Inter_ref_05_07;Inter_H_window_3_3 <= Inter_ref_06_07;
						Inter_H_window_4_3 <= Inter_ref_07_07;Inter_H_window_5_3 <= Inter_ref_08_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_03_08;Inter_H_window_1_4 <= Inter_ref_04_08;
						Inter_H_window_2_4 <= Inter_ref_05_08;Inter_H_window_3_4 <= Inter_ref_06_08;
						Inter_H_window_4_4 <= Inter_ref_07_08;Inter_H_window_5_4 <= Inter_ref_08_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_03_09;Inter_H_window_1_5 <= Inter_ref_04_09;
						Inter_H_window_2_5 <= Inter_ref_05_09;Inter_H_window_3_5 <= Inter_ref_06_09;
						Inter_H_window_4_5 <= Inter_ref_07_09;Inter_H_window_5_5 <= Inter_ref_08_09;
					end
				default:
				begin
					Inter_H_window_0_2 <= 0;Inter_H_window_1_2 <= 0;Inter_H_window_2_2 <= 0;
					Inter_H_window_3_2 <= 0;Inter_H_window_4_2 <= 0;Inter_H_window_5_2 <= 0;
						
					Inter_H_window_0_3 <= 0;Inter_H_window_1_3 <= 0;Inter_H_window_2_3 <= 0;
					Inter_H_window_3_3 <= 0;Inter_H_window_4_3 <= 0;Inter_H_window_5_3 <= 0;
						
					Inter_H_window_0_4 <= 0;Inter_H_window_1_4 <= 0;Inter_H_window_2_4 <= 0;
					Inter_H_window_3_4 <= 0;Inter_H_window_4_4 <= 0;Inter_H_window_5_4 <= 0;
							
					Inter_H_window_0_5 <= 0;Inter_H_window_1_5 <= 0;Inter_H_window_2_5 <= 0;
					Inter_H_window_3_5 <= 0;Inter_H_window_4_5 <= 0;Inter_H_window_5_5 <= 0;
				end
			endcase
			4'b0001: //Right bottom blk4x4
			case (Inter_H_window_counter1)
				3'd4:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_04_07;Inter_H_window_1_2 <= Inter_ref_05_07;
						Inter_H_window_2_2 <= Inter_ref_06_07;Inter_H_window_3_2 <= Inter_ref_07_07;
						Inter_H_window_4_2 <= Inter_ref_08_07;Inter_H_window_5_2 <= Inter_ref_09_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_04_08;Inter_H_window_1_3 <= Inter_ref_05_08;
						Inter_H_window_2_3 <= Inter_ref_06_08;Inter_H_window_3_3 <= Inter_ref_07_08;
						Inter_H_window_4_3 <= Inter_ref_08_08;Inter_H_window_5_3 <= Inter_ref_09_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_04_09;Inter_H_window_1_4 <= Inter_ref_05_09;
						Inter_H_window_2_4 <= Inter_ref_06_09;Inter_H_window_3_4 <= Inter_ref_07_09;
						Inter_H_window_4_4 <= Inter_ref_08_09;Inter_H_window_5_4 <= Inter_ref_09_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_04_10;Inter_H_window_1_5 <= Inter_ref_05_10;
						Inter_H_window_2_5 <= Inter_ref_06_10;Inter_H_window_3_5 <= Inter_ref_07_10;
						Inter_H_window_4_5 <= Inter_ref_08_10;Inter_H_window_5_5 <= Inter_ref_09_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_04_06;Inter_H_window_1_2 <= Inter_ref_05_06;
						Inter_H_window_2_2 <= Inter_ref_06_06;Inter_H_window_3_2 <= Inter_ref_07_06;
						Inter_H_window_4_2 <= Inter_ref_08_06;Inter_H_window_5_2 <= Inter_ref_09_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_04_07;Inter_H_window_1_3 <= Inter_ref_05_07;
						Inter_H_window_2_3 <= Inter_ref_06_07;Inter_H_window_3_3 <= Inter_ref_07_07;
						Inter_H_window_4_3 <= Inter_ref_08_07;Inter_H_window_5_3 <= Inter_ref_09_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_04_08;Inter_H_window_1_4 <= Inter_ref_05_08;
						Inter_H_window_2_4 <= Inter_ref_06_08;Inter_H_window_3_4 <= Inter_ref_07_08;
						Inter_H_window_4_4 <= Inter_ref_08_08;Inter_H_window_5_4 <= Inter_ref_09_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_04_09;Inter_H_window_1_5 <= Inter_ref_05_09;
						Inter_H_window_2_5 <= Inter_ref_06_09;Inter_H_window_3_5 <= Inter_ref_07_09;
						Inter_H_window_4_5 <= Inter_ref_08_09;Inter_H_window_5_5 <= Inter_ref_09_09;
					end
				3'd3:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_05_07;Inter_H_window_1_2 <= Inter_ref_06_07;
						Inter_H_window_2_2 <= Inter_ref_07_07;Inter_H_window_3_2 <= Inter_ref_08_07;
						Inter_H_window_4_2 <= Inter_ref_09_07;Inter_H_window_5_2 <= Inter_ref_10_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_05_08;Inter_H_window_1_3 <= Inter_ref_06_08;
						Inter_H_window_2_3 <= Inter_ref_07_08;Inter_H_window_3_3 <= Inter_ref_08_08;
						Inter_H_window_4_3 <= Inter_ref_09_08;Inter_H_window_5_3 <= Inter_ref_10_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_05_09;Inter_H_window_1_4 <= Inter_ref_06_09;
						Inter_H_window_2_4 <= Inter_ref_07_09;Inter_H_window_3_4 <= Inter_ref_08_09;
						Inter_H_window_4_4 <= Inter_ref_09_09;Inter_H_window_5_4 <= Inter_ref_10_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_05_10;Inter_H_window_1_5 <= Inter_ref_06_10;
						Inter_H_window_2_5 <= Inter_ref_07_10;Inter_H_window_3_5 <= Inter_ref_08_10;
						Inter_H_window_4_5 <= Inter_ref_09_10;Inter_H_window_5_5 <= Inter_ref_10_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_05_06;Inter_H_window_1_2 <= Inter_ref_06_06;
						Inter_H_window_2_2 <= Inter_ref_07_06;Inter_H_window_3_2 <= Inter_ref_08_06;
						Inter_H_window_4_2 <= Inter_ref_09_06;Inter_H_window_5_2 <= Inter_ref_10_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_05_07;Inter_H_window_1_3 <= Inter_ref_06_07;
						Inter_H_window_2_3 <= Inter_ref_07_07;Inter_H_window_3_3 <= Inter_ref_08_07;
						Inter_H_window_4_3 <= Inter_ref_09_07;Inter_H_window_5_3 <= Inter_ref_10_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_05_08;Inter_H_window_1_4 <= Inter_ref_06_08;
						Inter_H_window_2_4 <= Inter_ref_07_08;Inter_H_window_3_4 <= Inter_ref_08_08;
						Inter_H_window_4_4 <= Inter_ref_09_08;Inter_H_window_5_4 <= Inter_ref_10_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_05_09;Inter_H_window_1_5 <= Inter_ref_06_09;
						Inter_H_window_2_5 <= Inter_ref_07_09;Inter_H_window_3_5 <= Inter_ref_08_09;
						Inter_H_window_4_5 <= Inter_ref_09_09;Inter_H_window_5_5 <= Inter_ref_10_09;
					end
				3'd2:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_06_07;Inter_H_window_1_2 <= Inter_ref_07_07;
						Inter_H_window_2_2 <= Inter_ref_08_07;Inter_H_window_3_2 <= Inter_ref_09_07;
						Inter_H_window_4_2 <= Inter_ref_10_07;Inter_H_window_5_2 <= Inter_ref_11_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_06_08;Inter_H_window_1_3 <= Inter_ref_07_08;
						Inter_H_window_2_3 <= Inter_ref_08_08;Inter_H_window_3_3 <= Inter_ref_09_08;
						Inter_H_window_4_3 <= Inter_ref_10_08;Inter_H_window_5_3 <= Inter_ref_11_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_06_09;Inter_H_window_1_4 <= Inter_ref_07_09;
						Inter_H_window_2_4 <= Inter_ref_08_09;Inter_H_window_3_4 <= Inter_ref_09_09;
						Inter_H_window_4_4 <= Inter_ref_10_09;Inter_H_window_5_4 <= Inter_ref_11_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_06_10;Inter_H_window_1_5 <= Inter_ref_07_10;
						Inter_H_window_2_5 <= Inter_ref_08_10;Inter_H_window_3_5 <= Inter_ref_09_10;
						Inter_H_window_4_5 <= Inter_ref_10_10;Inter_H_window_5_5 <= Inter_ref_11_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_06_06;Inter_H_window_1_2 <= Inter_ref_07_06;
						Inter_H_window_2_2 <= Inter_ref_08_06;Inter_H_window_3_2 <= Inter_ref_09_06;
						Inter_H_window_4_2 <= Inter_ref_10_06;Inter_H_window_5_2 <= Inter_ref_11_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_06_07;Inter_H_window_1_3 <= Inter_ref_07_07;
						Inter_H_window_2_3 <= Inter_ref_08_07;Inter_H_window_3_3 <= Inter_ref_09_07;
						Inter_H_window_4_3 <= Inter_ref_10_07;Inter_H_window_5_3 <= Inter_ref_11_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_06_08;Inter_H_window_1_4 <= Inter_ref_07_08;
						Inter_H_window_2_4 <= Inter_ref_08_08;Inter_H_window_3_4 <= Inter_ref_09_08;
						Inter_H_window_4_4 <= Inter_ref_10_08;Inter_H_window_5_4 <= Inter_ref_11_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_06_09;Inter_H_window_1_5 <= Inter_ref_07_09;
						Inter_H_window_2_5 <= Inter_ref_08_09;Inter_H_window_3_5 <= Inter_ref_09_09;
						Inter_H_window_4_5 <= Inter_ref_10_09;Inter_H_window_5_5 <= Inter_ref_11_09;
					end	
				3'd1:
				if (pos_FracL == `pos_p || pos_FracL == `pos_r)
					begin
						Inter_H_window_0_2 <= Inter_ref_07_07;Inter_H_window_1_2 <= Inter_ref_08_07;
						Inter_H_window_2_2 <= Inter_ref_09_07;Inter_H_window_3_2 <= Inter_ref_10_07;
						Inter_H_window_4_2 <= Inter_ref_11_07;Inter_H_window_5_2 <= Inter_ref_12_07;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_07_08;Inter_H_window_1_3 <= Inter_ref_08_08;
						Inter_H_window_2_3 <= Inter_ref_09_08;Inter_H_window_3_3 <= Inter_ref_10_08;
						Inter_H_window_4_3 <= Inter_ref_11_08;Inter_H_window_5_3 <= Inter_ref_12_08;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_07_09;Inter_H_window_1_4 <= Inter_ref_08_09;
						Inter_H_window_2_4 <= Inter_ref_09_09;Inter_H_window_3_4 <= Inter_ref_10_09;
						Inter_H_window_4_4 <= Inter_ref_11_09;Inter_H_window_5_4 <= Inter_ref_12_09;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_07_10;Inter_H_window_1_5 <= Inter_ref_08_10;
						Inter_H_window_2_5 <= Inter_ref_09_10;Inter_H_window_3_5 <= Inter_ref_10_10;
						Inter_H_window_4_5 <= Inter_ref_11_10;Inter_H_window_5_5 <= Inter_ref_12_10;
					end
				else
					begin
						Inter_H_window_0_2 <= Inter_ref_07_06;Inter_H_window_1_2 <= Inter_ref_08_06;
						Inter_H_window_2_2 <= Inter_ref_09_06;Inter_H_window_3_2 <= Inter_ref_10_06;
						Inter_H_window_4_2 <= Inter_ref_11_06;Inter_H_window_5_2 <= Inter_ref_12_06;
							                                                                   
						Inter_H_window_0_3 <= Inter_ref_07_07;Inter_H_window_1_3 <= Inter_ref_08_07;
						Inter_H_window_2_3 <= Inter_ref_09_07;Inter_H_window_3_3 <= Inter_ref_10_07;
						Inter_H_window_4_3 <= Inter_ref_11_07;Inter_H_window_5_3 <= Inter_ref_12_07;
						                                                                           
						Inter_H_window_0_4 <= Inter_ref_07_08;Inter_H_window_1_4 <= Inter_ref_08_08;
						Inter_H_window_2_4 <= Inter_ref_09_08;Inter_H_window_3_4 <= Inter_ref_10_08;
						Inter_H_window_4_4 <= Inter_ref_11_08;Inter_H_window_5_4 <= Inter_ref_12_08;
							                                                                   
						Inter_H_window_0_5 <= Inter_ref_07_09;Inter_H_window_1_5 <= Inter_ref_08_09;
						Inter_H_window_2_5 <= Inter_ref_09_09;Inter_H_window_3_5 <= Inter_ref_10_09;
						Inter_H_window_4_5 <= Inter_ref_11_09;Inter_H_window_5_5 <= Inter_ref_12_09;
					end
				default:
				begin
					Inter_H_window_0_2 <= 0;Inter_H_window_1_2 <= 0;Inter_H_window_2_2 <= 0;
					Inter_H_window_3_2 <= 0;Inter_H_window_4_2 <= 0;Inter_H_window_5_2 <= 0;
						
					Inter_H_window_0_3 <= 0;Inter_H_window_1_3 <= 0;Inter_H_window_2_3 <= 0;
					Inter_H_window_3_3 <= 0;Inter_H_window_4_3 <= 0;Inter_H_window_5_3 <= 0;
						
					Inter_H_window_0_4 <= 0;Inter_H_window_1_4 <= 0;Inter_H_window_2_4 <= 0;
					Inter_H_window_3_4 <= 0;Inter_H_window_4_4 <= 0;Inter_H_window_5_4 <= 0;
							
					Inter_H_window_0_5 <= 0;Inter_H_window_1_5 <= 0;Inter_H_window_2_5 <= 0;
					Inter_H_window_3_5 <= 0;Inter_H_window_4_5 <= 0;Inter_H_window_5_5 <= 0;
				end
			endcase
			default:
			begin
				Inter_H_window_0_2 <= 0;Inter_H_window_1_2 <= 0;Inter_H_window_2_2 <= 0;
				Inter_H_window_3_2 <= 0;Inter_H_window_4_2 <= 0;Inter_H_window_5_2 <= 0;
						
				Inter_H_window_0_3 <= 0;Inter_H_window_1_3 <= 0;Inter_H_window_2_3 <= 0;
				Inter_H_window_3_3 <= 0;Inter_H_window_4_3 <= 0;Inter_H_window_5_3 <= 0;
						
				Inter_H_window_0_4 <= 0;Inter_H_window_1_4 <= 0;Inter_H_window_2_4 <= 0;
				Inter_H_window_3_4 <= 0;Inter_H_window_4_4 <= 0;Inter_H_window_5_4 <= 0;
							
				Inter_H_window_0_5 <= 0;Inter_H_window_1_5 <= 0;Inter_H_window_2_5 <= 0;
				Inter_H_window_3_5 <= 0;Inter_H_window_4_5 <= 0;Inter_H_window_5_5 <= 0;
			end
		endcase
		
	//Inter_V_window_counter:for Inter_V_window_0 ~ Inter_V_window_8
	reg [2:0] Inter_V_window_counter;
	always @ (pos_FracL or blk4x4_inter_calculate_counter)
		if  (((pos_FracL == `pos_h || pos_FracL == `pos_d || pos_FracL == `pos_n || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd4)	||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd8))
			Inter_V_window_counter <= 3'd4;
		else if  (((pos_FracL == `pos_h || pos_FracL == `pos_d || pos_FracL == `pos_n || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd3)	||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd6))
			Inter_V_window_counter <= 3'd3;
		else if  (((pos_FracL == `pos_h || pos_FracL == `pos_d || pos_FracL == `pos_n || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd2)	||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd4))
			Inter_V_window_counter <= 3'd2;
		else if  (((pos_FracL == `pos_h || pos_FracL == `pos_d || pos_FracL == `pos_n || pos_FracL == `pos_e || pos_FracL == `pos_g 
			|| pos_FracL == `pos_p || pos_FracL == `pos_r) && blk4x4_inter_calculate_counter == 4'd1)	||
			((pos_FracL == `pos_i || pos_FracL == `pos_k) && blk4x4_inter_calculate_counter == 4'd2))
			Inter_V_window_counter <= 3'd1;
		else
			Inter_V_window_counter <= 0;
	
	//Inter_V_window_0 ~ Inter_V_window_8
	always @ (Is_blk4x4_0 or Is_blk4x4_1 or Is_blk4x4_2 or Is_blk4x4_3 or pos_FracL or Inter_V_window_counter
		or Inter_ref_02_00 or Inter_ref_02_01 or Inter_ref_02_02 or Inter_ref_02_03 or Inter_ref_02_04
		or Inter_ref_02_05 or Inter_ref_02_06 or Inter_ref_02_07 or Inter_ref_02_08 or Inter_ref_02_09
		or Inter_ref_02_10 or Inter_ref_02_11 or Inter_ref_02_12
		
		or Inter_ref_03_00 or Inter_ref_03_01 or Inter_ref_03_02 or Inter_ref_03_03 or Inter_ref_03_04
		or Inter_ref_03_05 or Inter_ref_03_06 or Inter_ref_03_07 or Inter_ref_03_08 or Inter_ref_03_09
		or Inter_ref_03_10 or Inter_ref_03_11 or Inter_ref_03_12
		
		or Inter_ref_04_00 or Inter_ref_04_01 or Inter_ref_04_02 or Inter_ref_04_03 or Inter_ref_04_04
		or Inter_ref_04_05 or Inter_ref_04_06 or Inter_ref_04_07 or Inter_ref_04_08 or Inter_ref_04_09
		or Inter_ref_04_10 or Inter_ref_04_11 or Inter_ref_04_12
		
		or Inter_ref_05_00 or Inter_ref_05_01 or Inter_ref_05_02 or Inter_ref_05_03 or Inter_ref_05_04
		or Inter_ref_05_05 or Inter_ref_05_06 or Inter_ref_05_07 or Inter_ref_05_08 or Inter_ref_05_09
		or Inter_ref_05_10 or Inter_ref_05_11 or Inter_ref_05_12
		
		or Inter_ref_06_00 or Inter_ref_06_01 or Inter_ref_06_02 or Inter_ref_06_03 or Inter_ref_06_04
		or Inter_ref_06_05 or Inter_ref_06_06 or Inter_ref_06_07 or Inter_ref_06_08 or Inter_ref_06_09
		or Inter_ref_06_10 or Inter_ref_06_11 or Inter_ref_06_12
		
		or Inter_ref_07_00 or Inter_ref_07_01 or Inter_ref_07_02 or Inter_ref_07_03 or Inter_ref_07_04
		or Inter_ref_07_05 or Inter_ref_07_06 or Inter_ref_07_07 or Inter_ref_07_08 or Inter_ref_07_09
		or Inter_ref_07_10 or Inter_ref_07_11 or Inter_ref_07_12
		
		or Inter_ref_08_00 or Inter_ref_08_01 or Inter_ref_08_02 or Inter_ref_08_03 or Inter_ref_08_04
		or Inter_ref_08_05 or Inter_ref_08_06 or Inter_ref_08_07 or Inter_ref_08_08 or Inter_ref_08_09
		or Inter_ref_08_10 or Inter_ref_08_11 or Inter_ref_08_12
		
		or Inter_ref_09_00 or Inter_ref_09_01 or Inter_ref_09_02 or Inter_ref_09_03 or Inter_ref_09_04
		or Inter_ref_09_05 or Inter_ref_09_06 or Inter_ref_09_07 or Inter_ref_09_08 or Inter_ref_09_09
		or Inter_ref_09_10 or Inter_ref_09_11 or Inter_ref_09_12
		
		or Inter_ref_10_00 or Inter_ref_10_01 or Inter_ref_10_02 or Inter_ref_10_03 or Inter_ref_10_04
		or Inter_ref_10_05 or Inter_ref_10_06 or Inter_ref_10_07 or Inter_ref_10_08 or Inter_ref_10_09
		or Inter_ref_10_10 or Inter_ref_10_11 or Inter_ref_10_12
		)	
		case ({Is_blk4x4_0,Is_blk4x4_1,Is_blk4x4_2,Is_blk4x4_3}) 
			4'b1000: //Left top blk4x4
			case (Inter_V_window_counter)
				3'd4:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_03_00;Inter_V_window_1 <= Inter_ref_03_01;
						Inter_V_window_2 <= Inter_ref_03_02;Inter_V_window_3 <= Inter_ref_03_03;
						Inter_V_window_4 <= Inter_ref_03_04;Inter_V_window_5 <= Inter_ref_03_05;
						Inter_V_window_6 <= Inter_ref_03_06;Inter_V_window_7 <= Inter_ref_03_07;
						Inter_V_window_8 <= Inter_ref_03_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_02_00;Inter_V_window_1 <= Inter_ref_02_01;
						Inter_V_window_2 <= Inter_ref_02_02;Inter_V_window_3 <= Inter_ref_02_03;
						Inter_V_window_4 <= Inter_ref_02_04;Inter_V_window_5 <= Inter_ref_02_05;
						Inter_V_window_6 <= Inter_ref_02_06;Inter_V_window_7 <= Inter_ref_02_07;
						Inter_V_window_8 <= Inter_ref_02_08;
					end
				3'd3:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_04_00;Inter_V_window_1 <= Inter_ref_04_01;
						Inter_V_window_2 <= Inter_ref_04_02;Inter_V_window_3 <= Inter_ref_04_03;
						Inter_V_window_4 <= Inter_ref_04_04;Inter_V_window_5 <= Inter_ref_04_05;
						Inter_V_window_6 <= Inter_ref_04_06;Inter_V_window_7 <= Inter_ref_04_07;
						Inter_V_window_8 <= Inter_ref_04_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_03_00;Inter_V_window_1 <= Inter_ref_03_01;
						Inter_V_window_2 <= Inter_ref_03_02;Inter_V_window_3 <= Inter_ref_03_03;
						Inter_V_window_4 <= Inter_ref_03_04;Inter_V_window_5 <= Inter_ref_03_05;
						Inter_V_window_6 <= Inter_ref_03_06;Inter_V_window_7 <= Inter_ref_03_07;
						Inter_V_window_8 <= Inter_ref_03_08;
					end
				3'd2:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_05_00;Inter_V_window_1 <= Inter_ref_05_01;
						Inter_V_window_2 <= Inter_ref_05_02;Inter_V_window_3 <= Inter_ref_05_03;
						Inter_V_window_4 <= Inter_ref_05_04;Inter_V_window_5 <= Inter_ref_05_05;
						Inter_V_window_6 <= Inter_ref_05_06;Inter_V_window_7 <= Inter_ref_05_07;
						Inter_V_window_8 <= Inter_ref_05_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_04_00;Inter_V_window_1 <= Inter_ref_04_01;
						Inter_V_window_2 <= Inter_ref_04_02;Inter_V_window_3 <= Inter_ref_04_03;
						Inter_V_window_4 <= Inter_ref_04_04;Inter_V_window_5 <= Inter_ref_04_05;
						Inter_V_window_6 <= Inter_ref_04_06;Inter_V_window_7 <= Inter_ref_04_07;
						Inter_V_window_8 <= Inter_ref_04_08;
					end
				3'd1:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_06_00;Inter_V_window_1 <= Inter_ref_06_01;
						Inter_V_window_2 <= Inter_ref_06_02;Inter_V_window_3 <= Inter_ref_06_03;
						Inter_V_window_4 <= Inter_ref_06_04;Inter_V_window_5 <= Inter_ref_06_05;
						Inter_V_window_6 <= Inter_ref_06_06;Inter_V_window_7 <= Inter_ref_06_07;
						Inter_V_window_8 <= Inter_ref_06_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_05_00;Inter_V_window_1 <= Inter_ref_05_01;
						Inter_V_window_2 <= Inter_ref_05_02;Inter_V_window_3 <= Inter_ref_05_03;
						Inter_V_window_4 <= Inter_ref_05_04;Inter_V_window_5 <= Inter_ref_05_05;
						Inter_V_window_6 <= Inter_ref_05_06;Inter_V_window_7 <= Inter_ref_05_07;
						Inter_V_window_8 <= Inter_ref_05_08;
					end
				default:
				begin 
					Inter_V_window_0 <= 0;Inter_V_window_1 <= 0;Inter_V_window_2 <= 0;
					Inter_V_window_3 <= 0;Inter_V_window_4 <= 0;Inter_V_window_5 <= 0;
					Inter_V_window_6 <= 0;Inter_V_window_7 <= 0;Inter_V_window_8 <= 0;
				end
			endcase
			4'b0100: //Right top blk4x4
			case (Inter_V_window_counter)
				3'd4:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_07_00;Inter_V_window_1 <= Inter_ref_07_01;
						Inter_V_window_2 <= Inter_ref_07_02;Inter_V_window_3 <= Inter_ref_07_03;
						Inter_V_window_4 <= Inter_ref_07_04;Inter_V_window_5 <= Inter_ref_07_05;
						Inter_V_window_6 <= Inter_ref_07_06;Inter_V_window_7 <= Inter_ref_07_07;
						Inter_V_window_8 <= Inter_ref_07_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_06_00;Inter_V_window_1 <= Inter_ref_06_01;
						Inter_V_window_2 <= Inter_ref_06_02;Inter_V_window_3 <= Inter_ref_06_03;
						Inter_V_window_4 <= Inter_ref_06_04;Inter_V_window_5 <= Inter_ref_06_05;
						Inter_V_window_6 <= Inter_ref_06_06;Inter_V_window_7 <= Inter_ref_06_07;
						Inter_V_window_8 <= Inter_ref_06_08;
					end
				3'd3:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_08_00;Inter_V_window_1 <= Inter_ref_08_01;
						Inter_V_window_2 <= Inter_ref_08_02;Inter_V_window_3 <= Inter_ref_08_03;
						Inter_V_window_4 <= Inter_ref_08_04;Inter_V_window_5 <= Inter_ref_08_05;
						Inter_V_window_6 <= Inter_ref_08_06;Inter_V_window_7 <= Inter_ref_08_07;
						Inter_V_window_8 <= Inter_ref_08_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_07_00;Inter_V_window_1 <= Inter_ref_07_01;
						Inter_V_window_2 <= Inter_ref_07_02;Inter_V_window_3 <= Inter_ref_07_03;
						Inter_V_window_4 <= Inter_ref_07_04;Inter_V_window_5 <= Inter_ref_07_05;
						Inter_V_window_6 <= Inter_ref_07_06;Inter_V_window_7 <= Inter_ref_07_07;
						Inter_V_window_8 <= Inter_ref_07_08;
					end
				3'd2:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_09_00;Inter_V_window_1 <= Inter_ref_09_01;
						Inter_V_window_2 <= Inter_ref_09_02;Inter_V_window_3 <= Inter_ref_09_03;
						Inter_V_window_4 <= Inter_ref_09_04;Inter_V_window_5 <= Inter_ref_09_05;
						Inter_V_window_6 <= Inter_ref_09_06;Inter_V_window_7 <= Inter_ref_09_07;
						Inter_V_window_8 <= Inter_ref_09_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_08_00;Inter_V_window_1 <= Inter_ref_08_01;
						Inter_V_window_2 <= Inter_ref_08_02;Inter_V_window_3 <= Inter_ref_08_03;
						Inter_V_window_4 <= Inter_ref_08_04;Inter_V_window_5 <= Inter_ref_08_05;
						Inter_V_window_6 <= Inter_ref_08_06;Inter_V_window_7 <= Inter_ref_08_07;
						Inter_V_window_8 <= Inter_ref_08_08;
					end
				3'd1:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_10_00;Inter_V_window_1 <= Inter_ref_10_01;
						Inter_V_window_2 <= Inter_ref_10_02;Inter_V_window_3 <= Inter_ref_10_03;
						Inter_V_window_4 <= Inter_ref_10_04;Inter_V_window_5 <= Inter_ref_10_05;
						Inter_V_window_6 <= Inter_ref_10_06;Inter_V_window_7 <= Inter_ref_10_07;
						Inter_V_window_8 <= Inter_ref_10_08;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_09_00;Inter_V_window_1 <= Inter_ref_09_01;
						Inter_V_window_2 <= Inter_ref_09_02;Inter_V_window_3 <= Inter_ref_09_03;
						Inter_V_window_4 <= Inter_ref_09_04;Inter_V_window_5 <= Inter_ref_09_05;
						Inter_V_window_6 <= Inter_ref_09_06;Inter_V_window_7 <= Inter_ref_09_07;
						Inter_V_window_8 <= Inter_ref_09_08;
					end
				default:
				begin 
					Inter_V_window_0 <= 0;Inter_V_window_1 <= 0;Inter_V_window_2 <= 0;
					Inter_V_window_3 <= 0;Inter_V_window_4 <= 0;Inter_V_window_5 <= 0;
					Inter_V_window_6 <= 0;Inter_V_window_7 <= 0;Inter_V_window_8 <= 0;
				end
			endcase
			4'b0010: //Left bottom blk4x4
			case (Inter_V_window_counter)
				3'd4:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_03_04;Inter_V_window_1 <= Inter_ref_03_05;
						Inter_V_window_2 <= Inter_ref_03_06;Inter_V_window_3 <= Inter_ref_03_07;
						Inter_V_window_4 <= Inter_ref_03_08;Inter_V_window_5 <= Inter_ref_03_09;
						Inter_V_window_6 <= Inter_ref_03_10;Inter_V_window_7 <= Inter_ref_03_11;
						Inter_V_window_8 <= Inter_ref_03_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_02_04;Inter_V_window_1 <= Inter_ref_02_05;
						Inter_V_window_2 <= Inter_ref_02_06;Inter_V_window_3 <= Inter_ref_02_07;
						Inter_V_window_4 <= Inter_ref_02_08;Inter_V_window_5 <= Inter_ref_02_09;
						Inter_V_window_6 <= Inter_ref_02_10;Inter_V_window_7 <= Inter_ref_02_11;
						Inter_V_window_8 <= Inter_ref_02_12;
					end
				3'd3:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_04_04;Inter_V_window_1 <= Inter_ref_04_05;
						Inter_V_window_2 <= Inter_ref_04_06;Inter_V_window_3 <= Inter_ref_04_07;
						Inter_V_window_4 <= Inter_ref_04_08;Inter_V_window_5 <= Inter_ref_04_09;
						Inter_V_window_6 <= Inter_ref_04_10;Inter_V_window_7 <= Inter_ref_04_11;
						Inter_V_window_8 <= Inter_ref_04_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_03_04;Inter_V_window_1 <= Inter_ref_03_05;
						Inter_V_window_2 <= Inter_ref_03_06;Inter_V_window_3 <= Inter_ref_03_07;
						Inter_V_window_4 <= Inter_ref_03_08;Inter_V_window_5 <= Inter_ref_03_09;
						Inter_V_window_6 <= Inter_ref_03_10;Inter_V_window_7 <= Inter_ref_03_11;
						Inter_V_window_8 <= Inter_ref_03_12;
					end
				3'd2:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_05_04;Inter_V_window_1 <= Inter_ref_05_05;
						Inter_V_window_2 <= Inter_ref_05_06;Inter_V_window_3 <= Inter_ref_05_07;
						Inter_V_window_4 <= Inter_ref_05_08;Inter_V_window_5 <= Inter_ref_05_09;
						Inter_V_window_6 <= Inter_ref_05_10;Inter_V_window_7 <= Inter_ref_05_11;
						Inter_V_window_8 <= Inter_ref_05_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_04_04;Inter_V_window_1 <= Inter_ref_04_05;
						Inter_V_window_2 <= Inter_ref_04_06;Inter_V_window_3 <= Inter_ref_04_07;
						Inter_V_window_4 <= Inter_ref_04_08;Inter_V_window_5 <= Inter_ref_04_09;
						Inter_V_window_6 <= Inter_ref_04_10;Inter_V_window_7 <= Inter_ref_04_11;
						Inter_V_window_8 <= Inter_ref_04_12;
					end
				3'd1:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_06_04;Inter_V_window_1 <= Inter_ref_06_05;
						Inter_V_window_2 <= Inter_ref_06_06;Inter_V_window_3 <= Inter_ref_06_07;
						Inter_V_window_4 <= Inter_ref_06_08;Inter_V_window_5 <= Inter_ref_06_09;
						Inter_V_window_6 <= Inter_ref_06_10;Inter_V_window_7 <= Inter_ref_06_11;
						Inter_V_window_8 <= Inter_ref_06_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_05_04;Inter_V_window_1 <= Inter_ref_05_05;
						Inter_V_window_2 <= Inter_ref_05_06;Inter_V_window_3 <= Inter_ref_05_07;
						Inter_V_window_4 <= Inter_ref_05_08;Inter_V_window_5 <= Inter_ref_05_09;
						Inter_V_window_6 <= Inter_ref_05_10;Inter_V_window_7 <= Inter_ref_05_11;
						Inter_V_window_8 <= Inter_ref_05_12;
					end
				default:
				begin 
					Inter_V_window_0 <= 0;Inter_V_window_1 <= 0;Inter_V_window_2 <= 0;
					Inter_V_window_3 <= 0;Inter_V_window_4 <= 0;Inter_V_window_5 <= 0;
					Inter_V_window_6 <= 0;Inter_V_window_7 <= 0;Inter_V_window_8 <= 0;
				end
			endcase
			4'b0001: //Right bottom blk4x4
			case (Inter_V_window_counter)
				3'd4:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_07_04;Inter_V_window_1 <= Inter_ref_07_05;
						Inter_V_window_2 <= Inter_ref_07_06;Inter_V_window_3 <= Inter_ref_07_07;
						Inter_V_window_4 <= Inter_ref_07_08;Inter_V_window_5 <= Inter_ref_07_09;
						Inter_V_window_6 <= Inter_ref_07_10;Inter_V_window_7 <= Inter_ref_07_11;
						Inter_V_window_8 <= Inter_ref_07_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_06_04;Inter_V_window_1 <= Inter_ref_06_05;
						Inter_V_window_2 <= Inter_ref_06_06;Inter_V_window_3 <= Inter_ref_06_07;
						Inter_V_window_4 <= Inter_ref_06_08;Inter_V_window_5 <= Inter_ref_06_09;
						Inter_V_window_6 <= Inter_ref_06_10;Inter_V_window_7 <= Inter_ref_06_11;
						Inter_V_window_8 <= Inter_ref_06_12;
					end
				3'd3:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_08_04;Inter_V_window_1 <= Inter_ref_08_05;
						Inter_V_window_2 <= Inter_ref_08_06;Inter_V_window_3 <= Inter_ref_08_07;
						Inter_V_window_4 <= Inter_ref_08_08;Inter_V_window_5 <= Inter_ref_08_09;
						Inter_V_window_6 <= Inter_ref_08_10;Inter_V_window_7 <= Inter_ref_08_11;
						Inter_V_window_8 <= Inter_ref_08_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_07_04;Inter_V_window_1 <= Inter_ref_07_05;
						Inter_V_window_2 <= Inter_ref_07_06;Inter_V_window_3 <= Inter_ref_07_07;
						Inter_V_window_4 <= Inter_ref_07_08;Inter_V_window_5 <= Inter_ref_07_09;
						Inter_V_window_6 <= Inter_ref_07_10;Inter_V_window_7 <= Inter_ref_07_11;
						Inter_V_window_8 <= Inter_ref_07_12;
					end
				3'd2:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_09_04;Inter_V_window_1 <= Inter_ref_09_05;
						Inter_V_window_2 <= Inter_ref_09_06;Inter_V_window_3 <= Inter_ref_09_07;
						Inter_V_window_4 <= Inter_ref_09_08;Inter_V_window_5 <= Inter_ref_09_09;
						Inter_V_window_6 <= Inter_ref_09_10;Inter_V_window_7 <= Inter_ref_09_11;
						Inter_V_window_8 <= Inter_ref_09_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_08_04;Inter_V_window_1 <= Inter_ref_08_05;
						Inter_V_window_2 <= Inter_ref_08_06;Inter_V_window_3 <= Inter_ref_08_07;
						Inter_V_window_4 <= Inter_ref_08_08;Inter_V_window_5 <= Inter_ref_08_09;
						Inter_V_window_6 <= Inter_ref_08_10;Inter_V_window_7 <= Inter_ref_08_11;
						Inter_V_window_8 <= Inter_ref_08_12;
					end
				3'd1:
				if (pos_FracL == `pos_g || pos_FracL == `pos_r || pos_FracL == `pos_k)
					begin
						Inter_V_window_0 <= Inter_ref_10_04;Inter_V_window_1 <= Inter_ref_10_05;
						Inter_V_window_2 <= Inter_ref_10_06;Inter_V_window_3 <= Inter_ref_10_07;
						Inter_V_window_4 <= Inter_ref_10_08;Inter_V_window_5 <= Inter_ref_10_09;
						Inter_V_window_6 <= Inter_ref_10_10;Inter_V_window_7 <= Inter_ref_10_11;
						Inter_V_window_8 <= Inter_ref_10_12;
					end
				else
					begin
						Inter_V_window_0 <= Inter_ref_09_04;Inter_V_window_1 <= Inter_ref_09_05;
						Inter_V_window_2 <= Inter_ref_09_06;Inter_V_window_3 <= Inter_ref_09_07;
						Inter_V_window_4 <= Inter_ref_09_08;Inter_V_window_5 <= Inter_ref_09_09;
						Inter_V_window_6 <= Inter_ref_09_10;Inter_V_window_7 <= Inter_ref_09_11;
						Inter_V_window_8 <= Inter_ref_09_12;
					end
				default:
				begin 
					Inter_V_window_0 <= 0;Inter_V_window_1 <= 0;Inter_V_window_2 <= 0;
					Inter_V_window_3 <= 0;Inter_V_window_4 <= 0;Inter_V_window_5 <= 0;
					Inter_V_window_6 <= 0;Inter_V_window_7 <= 0;Inter_V_window_8 <= 0;
				end
			endcase
			default:
			begin 
				Inter_V_window_0 <= 0;Inter_V_window_1 <= 0;Inter_V_window_2 <= 0;
				Inter_V_window_3 <= 0;Inter_V_window_4 <= 0;Inter_V_window_5 <= 0;
				Inter_V_window_6 <= 0;Inter_V_window_7 <= 0;Inter_V_window_8 <= 0;
			end
		endcase
	
	//Luma bilinear window
	always @ (Is_blk4x4_0 or Is_blk4x4_1 or Is_blk4x4_2 or Is_blk4x4_3 or pos_FracL or blk4x4_inter_calculate_counter
		or Inter_ref_02_02 or Inter_ref_03_02 or Inter_ref_04_02 or Inter_ref_05_02 or Inter_ref_06_02
		or Inter_ref_07_02 or Inter_ref_08_02 or Inter_ref_09_02 or Inter_ref_10_02
		or Inter_ref_02_03 or Inter_ref_03_03 or Inter_ref_04_03 or Inter_ref_05_03 or Inter_ref_06_03
		or Inter_ref_07_03 or Inter_ref_08_03 or Inter_ref_09_03 or Inter_ref_10_03
		or Inter_ref_02_04 or Inter_ref_03_04 or Inter_ref_04_04 or Inter_ref_05_04 or Inter_ref_06_04
		or Inter_ref_07_04 or Inter_ref_08_04 or Inter_ref_09_04 or Inter_ref_10_04
		or Inter_ref_02_05 or Inter_ref_03_05 or Inter_ref_04_05 or Inter_ref_05_05 or Inter_ref_06_05
		or Inter_ref_07_05 or Inter_ref_08_05 or Inter_ref_09_05 or Inter_ref_10_05
		or Inter_ref_02_06 or Inter_ref_03_06 or Inter_ref_04_06 or Inter_ref_05_06 or Inter_ref_06_06
		or Inter_ref_07_06 or Inter_ref_08_06 or Inter_ref_09_06 or Inter_ref_10_06
		or Inter_ref_02_07 or Inter_ref_03_07 or Inter_ref_04_07 or Inter_ref_05_07 or Inter_ref_06_07
		or Inter_ref_07_07 or Inter_ref_08_07 or Inter_ref_09_07 or Inter_ref_10_07
		or Inter_ref_02_08 or Inter_ref_03_08 or Inter_ref_04_08 or Inter_ref_05_08 or Inter_ref_06_08
		or Inter_ref_07_08 or Inter_ref_08_08 or Inter_ref_09_08 or Inter_ref_10_08
		or Inter_ref_02_09 or Inter_ref_03_09 or Inter_ref_04_09 or Inter_ref_05_09 or Inter_ref_06_09
		or Inter_ref_07_09 or Inter_ref_08_09 or Inter_ref_09_09 or Inter_ref_10_09
		or Inter_ref_02_10 or Inter_ref_03_10 or Inter_ref_04_10 or Inter_ref_05_10 or Inter_ref_06_10
		or Inter_ref_07_10 or Inter_ref_08_10 or Inter_ref_09_10)
		case ({Is_blk4x4_0,Is_blk4x4_1,Is_blk4x4_2,Is_blk4x4_3})
			4'b1000: //Left top blk4x4
			case (pos_FracL)
				pos_a,pos_d:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_02_02;Inter_bi_window_1 <= Inter_ref_02_03;
								Inter_bi_window_2 <= Inter_ref_02_04;Inter_bi_window_3 <= Inter_ref_02_05;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_03_02;Inter_bi_window_1 <= Inter_ref_03_03;
								Inter_bi_window_2 <= Inter_ref_03_04;Inter_bi_window_3 <= Inter_ref_03_05;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_04_02;Inter_bi_window_1 <= Inter_ref_04_03;
								Inter_bi_window_2 <= Inter_ref_04_04;Inter_bi_window_3 <= Inter_ref_04_05;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_05_02;Inter_bi_window_1 <= Inter_ref_05_03;
								Inter_bi_window_2 <= Inter_ref_05_04;Inter_bi_window_3 <= Inter_ref_05_05;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase			
				pos_c:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_03_02;Inter_bi_window_1 <= Inter_ref_03_03;
								Inter_bi_window_2 <= Inter_ref_03_04;Inter_bi_window_3 <= Inter_ref_03_05;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_04_02;Inter_bi_window_1 <= Inter_ref_04_03;
								Inter_bi_window_2 <= Inter_ref_04_04;Inter_bi_window_3 <= Inter_ref_04_05;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_05_02;Inter_bi_window_1 <= Inter_ref_05_03;
								Inter_bi_window_2 <= Inter_ref_05_04;Inter_bi_window_3 <= Inter_ref_05_05;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_06_02;Inter_bi_window_1 <= Inter_ref_06_03;
								Inter_bi_window_2 <= Inter_ref_06_04;Inter_bi_window_3 <= Inter_ref_06_05;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				pos_n:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_02_03;Inter_bi_window_1 <= Inter_ref_02_04;
								Inter_bi_window_2 <= Inter_ref_02_05;Inter_bi_window_3 <= Inter_ref_02_06;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_03_03;Inter_bi_window_1 <= Inter_ref_03_04;
								Inter_bi_window_2 <= Inter_ref_03_05;Inter_bi_window_3 <= Inter_ref_03_06;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_04_03;Inter_bi_window_1 <= Inter_ref_04_04;
								Inter_bi_window_2 <= Inter_ref_04_05;Inter_bi_window_3 <= Inter_ref_04_06;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_05_03;Inter_bi_window_1 <= Inter_ref_05_04;
								Inter_bi_window_2 <= Inter_ref_05_05;Inter_bi_window_3 <= Inter_ref_05_06;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				default:
				begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
						Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
			endcase
			4'b0100: //Right top blk4x4
			case (pos_FracL)
				pos_a,pos_d:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_06_02;Inter_bi_window_1 <= Inter_ref_06_03;
								Inter_bi_window_2 <= Inter_ref_06_04;Inter_bi_window_3 <= Inter_ref_06_05;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_07_02;Inter_bi_window_1 <= Inter_ref_07_03;
								Inter_bi_window_2 <= Inter_ref_07_04;Inter_bi_window_3 <= Inter_ref_07_05;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_08_02;Inter_bi_window_1 <= Inter_ref_08_03;
								Inter_bi_window_2 <= Inter_ref_08_04;Inter_bi_window_3 <= Inter_ref_08_05;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_09_02;Inter_bi_window_1 <= Inter_ref_09_03;
								Inter_bi_window_2 <= Inter_ref_09_04;Inter_bi_window_3 <= Inter_ref_09_05;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase			
				pos_c:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_07_02;Inter_bi_window_1 <= Inter_ref_07_03;
								Inter_bi_window_2 <= Inter_ref_07_04;Inter_bi_window_3 <= Inter_ref_07_05;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_08_02;Inter_bi_window_1 <= Inter_ref_08_03;
								Inter_bi_window_2 <= Inter_ref_08_04;Inter_bi_window_3 <= Inter_ref_08_05;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_09_02;Inter_bi_window_1 <= Inter_ref_09_03;
								Inter_bi_window_2 <= Inter_ref_09_04;Inter_bi_window_3 <= Inter_ref_09_05;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_10_02;Inter_bi_window_1 <= Inter_ref_10_03;
								Inter_bi_window_2 <= Inter_ref_10_04;Inter_bi_window_3 <= Inter_ref_10_05;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				pos_n:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_06_03;Inter_bi_window_1 <= Inter_ref_06_04;
								Inter_bi_window_2 <= Inter_ref_06_05;Inter_bi_window_3 <= Inter_ref_06_06;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_07_03;Inter_bi_window_1 <= Inter_ref_07_04;
								Inter_bi_window_2 <= Inter_ref_07_05;Inter_bi_window_3 <= Inter_ref_07_06;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_08_03;Inter_bi_window_1 <= Inter_ref_08_04;
								Inter_bi_window_2 <= Inter_ref_08_05;Inter_bi_window_3 <= Inter_ref_08_06;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_09_03;Inter_bi_window_1 <= Inter_ref_09_04;
								Inter_bi_window_2 <= Inter_ref_09_05;Inter_bi_window_3 <= Inter_ref_09_06;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				default:
				begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
						Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
			endcase
			4'b0010: //Left bottom blk4x4
			case (pos_FracL)
				pos_a,pos_d:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_02_06;Inter_bi_window_1 <= Inter_ref_02_07;
								Inter_bi_window_2 <= Inter_ref_02_08;Inter_bi_window_3 <= Inter_ref_02_09;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_03_06;Inter_bi_window_1 <= Inter_ref_03_07;
								Inter_bi_window_2 <= Inter_ref_03_08;Inter_bi_window_3 <= Inter_ref_03_09;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_04_06;Inter_bi_window_1 <= Inter_ref_04_07;
								Inter_bi_window_2 <= Inter_ref_04_08;Inter_bi_window_3 <= Inter_ref_04_09;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_05_06;Inter_bi_window_1 <= Inter_ref_05_07;
								Inter_bi_window_2 <= Inter_ref_05_08;Inter_bi_window_3 <= Inter_ref_05_09;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase			
				pos_c:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_03_06;Inter_bi_window_1 <= Inter_ref_03_07;
								Inter_bi_window_2 <= Inter_ref_03_08;Inter_bi_window_3 <= Inter_ref_03_09;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_04_06;Inter_bi_window_1 <= Inter_ref_04_07;
								Inter_bi_window_2 <= Inter_ref_04_08;Inter_bi_window_3 <= Inter_ref_04_09;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_05_06;Inter_bi_window_1 <= Inter_ref_05_07;
								Inter_bi_window_2 <= Inter_ref_05_08;Inter_bi_window_3 <= Inter_ref_05_09;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_06_06;Inter_bi_window_1 <= Inter_ref_06_07;
								Inter_bi_window_2 <= Inter_ref_06_08;Inter_bi_window_3 <= Inter_ref_06_09;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				pos_n:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_02_07;Inter_bi_window_1 <= Inter_ref_02_08;
								Inter_bi_window_2 <= Inter_ref_02_09;Inter_bi_window_3 <= Inter_ref_02_10;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_03_07;Inter_bi_window_1 <= Inter_ref_03_08;
								Inter_bi_window_2 <= Inter_ref_03_09;Inter_bi_window_3 <= Inter_ref_03_10;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_04_07;Inter_bi_window_1 <= Inter_ref_04_08;
								Inter_bi_window_2 <= Inter_ref_04_09;Inter_bi_window_3 <= Inter_ref_04_10;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_05_07;Inter_bi_window_1 <= Inter_ref_05_08;
								Inter_bi_window_2 <= Inter_ref_05_09;Inter_bi_window_3 <= Inter_ref_05_10;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				default:
				begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
						Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
			endcase
			4'b0001: //Right bottom blk4x4
			case (pos_FracL)
				pos_a,pos_d:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_06_06;Inter_bi_window_1 <= Inter_ref_06_07;
								Inter_bi_window_2 <= Inter_ref_06_08;Inter_bi_window_3 <= Inter_ref_06_09;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_07_06;Inter_bi_window_1 <= Inter_ref_07_07;
								Inter_bi_window_2 <= Inter_ref_07_08;Inter_bi_window_3 <= Inter_ref_07_09;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_08_06;Inter_bi_window_1 <= Inter_ref_08_07;
								Inter_bi_window_2 <= Inter_ref_08_08;Inter_bi_window_3 <= Inter_ref_08_09;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_09_06;Inter_bi_window_1 <= Inter_ref_09_07;
								Inter_bi_window_2 <= Inter_ref_09_08;Inter_bi_window_3 <= Inter_ref_09_09;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase			
				pos_c:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_07_06;Inter_bi_window_1 <= Inter_ref_07_07;
								Inter_bi_window_2 <= Inter_ref_07_08;Inter_bi_window_3 <= Inter_ref_07_09;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_08_06;Inter_bi_window_1 <= Inter_ref_08_07;
								Inter_bi_window_2 <= Inter_ref_08_08;Inter_bi_window_3 <= Inter_ref_08_09;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_09_06;Inter_bi_window_1 <= Inter_ref_09_07;
								Inter_bi_window_2 <= Inter_ref_09_08;Inter_bi_window_3 <= Inter_ref_09_09;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_10_06;Inter_bi_window_1 <= Inter_ref_10_07;
								Inter_bi_window_2 <= Inter_ref_10_08;Inter_bi_window_3 <= Inter_ref_10_09;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				pos_n:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	Inter_bi_window_0 <= Inter_ref_06_07;Inter_bi_window_1 <= Inter_ref_06_08;
								Inter_bi_window_2 <= Inter_ref_06_09;Inter_bi_window_3 <= Inter_ref_06_10;	end
					4'd3:begin	Inter_bi_window_0 <= Inter_ref_07_07;Inter_bi_window_1 <= Inter_ref_07_08;
								Inter_bi_window_2 <= Inter_ref_07_09;Inter_bi_window_3 <= Inter_ref_07_10;	end
					4'd2:begin	Inter_bi_window_0 <= Inter_ref_08_07;Inter_bi_window_1 <= Inter_ref_08_08;
								Inter_bi_window_2 <= Inter_ref_08_09;Inter_bi_window_3 <= Inter_ref_08_10;	end
					4'd1:begin	Inter_bi_window_0 <= Inter_ref_09_07;Inter_bi_window_1 <= Inter_ref_09_08;
								Inter_bi_window_2 <= Inter_ref_09_09;Inter_bi_window_3 <= Inter_ref_09_10;	end
					default:begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
									Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
				endcase
				default:
				begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
						Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
			endcase
			default:
			begin	Inter_bi_window_0 <= 0;Inter_bi_window_1 <= 0;
					Inter_bi_window_2 <= 0;Inter_bi_window_3 <= 0;	end
		endcase
		
	//chroma sliding window:Inter_C_window_0 ~ Inter_C_window_3 
	always @ (IsInterChroma or blk4x4_inter_calculate_counter or mv_below8x8_curr
		or Inter_ref_00_00 or Inter_ref_01_00 or Inter_ref_02_00 or Inter_ref_03_00 or Inter_ref_04_00
		or Inter_ref_00_01 or Inter_ref_01_01 or Inter_ref_02_01 or Inter_ref_03_01 or Inter_ref_04_01
		or Inter_ref_00_02 or Inter_ref_01_02 or Inter_ref_02_02 or Inter_ref_03_02 or Inter_ref_04_02
		or Inter_ref_00_03 or Inter_ref_01_03 or Inter_ref_02_03 or Inter_ref_03_03 or Inter_ref_04_03
		or Inter_ref_00_04 or Inter_ref_01_04 or Inter_ref_02_04 or Inter_ref_03_04 or Inter_ref_04_04
		)
		if (IsInterChroma && mv_below8x8_curr == 1'b0)
			case (blk4x4_inter_calculate_counter)
				4'd4:
				begin 
					Inter_C_window_0_0 <= Inter_ref_00_00; Inter_C_window_1_0 <= Inter_ref_01_00;
					Inter_C_window_2_0 <= Inter_ref_02_00;
					Inter_C_window_0_1 <= Inter_ref_00_01; Inter_C_window_1_1 <= Inter_ref_01_01;
					Inter_C_window_2_1 <= Inter_ref_02_01;
					Inter_C_window_0_2 <= Inter_ref_00_02; Inter_C_window_1_2 <= Inter_ref_01_02;
					Inter_C_window_2_2 <= Inter_ref_02_02;
				end
				4'd3:
				begin 
					Inter_C_window_0_0 <= Inter_ref_02_00; Inter_C_window_1_0 <= Inter_ref_03_00;
					Inter_C_window_2_0 <= Inter_ref_04_00;
					Inter_C_window_0_1 <= Inter_ref_02_01; Inter_C_window_1_1 <= Inter_ref_03_01;
					Inter_C_window_2_1 <= Inter_ref_04_01;
					Inter_C_window_0_2 <= Inter_ref_02_02; Inter_C_window_1_2 <= Inter_ref_03_02;
					Inter_C_window_2_2 <= Inter_ref_04_02;
				end
				4'd2:
				begin 
					Inter_C_window_0_0 <= Inter_ref_00_02; Inter_C_window_1_0 <= Inter_ref_01_02;
					Inter_C_window_2_0 <= Inter_ref_02_02;
					Inter_C_window_0_1 <= Inter_ref_00_03; Inter_C_window_1_1 <= Inter_ref_01_03;
					Inter_C_window_2_1 <= Inter_ref_02_03;
					Inter_C_window_0_2 <= Inter_ref_00_04; Inter_C_window_1_2 <= Inter_ref_01_04;
					Inter_C_window_2_2 <= Inter_ref_02_04;
				end
				4'd1:
				begin 
					Inter_C_window_0_0 <= Inter_ref_02_02; Inter_C_window_1_0 <= Inter_ref_03_02;
					Inter_C_window_2_0 <= Inter_ref_04_02;
					Inter_C_window_0_1 <= Inter_ref_02_03; Inter_C_window_1_1 <= Inter_ref_03_03;
					Inter_C_window_2_1 <= Inter_ref_04_03;
					Inter_C_window_0_2 <= Inter_ref_02_04; Inter_C_window_1_2 <= Inter_ref_03_04;
					Inter_C_window_2_2 <= Inter_ref_04_04;
				end
				default:
				begin 
					Inter_C_window_0_0 <= 0; Inter_C_window_1_0 <= 0;Inter_C_window_2_0 <= 0;
					Inter_C_window_0_1 <= 0; Inter_C_window_1_1 <= 0;Inter_C_window_2_1 <= 0;
					Inter_C_window_0_2 <= 0; Inter_C_window_1_2 <= 0;Inter_C_window_2_2 <= 0;
				end
			endcase
		else if (IsInterChroma && mv_below8x8_curr == 1'b1)
			case (blk4x4_inter_calculate_counter)
				4'd1:
				begin 
					Inter_C_window_0_0 <= Inter_ref_00_00; Inter_C_window_1_0 <= Inter_ref_01_00;
					Inter_C_window_2_0 <= Inter_ref_02_00;
					Inter_C_window_0_1 <= Inter_ref_00_01; Inter_C_window_1_1 <= Inter_ref_01_01;
					Inter_C_window_2_1 <= Inter_ref_02_01;
					Inter_C_window_0_2 <= Inter_ref_00_02; Inter_C_window_1_2 <= Inter_ref_01_02;
					Inter_C_window_2_2 <= Inter_ref_02_02;
				end
				default:
				begin 
					Inter_C_window_0_0 <= 0; Inter_C_window_1_0 <= 0;Inter_C_window_2_0 <= 0;
					Inter_C_window_0_1 <= 0; Inter_C_window_1_1 <= 0;Inter_C_window_2_1 <= 0;
					Inter_C_window_0_2 <= 0; Inter_C_window_1_2 <= 0;Inter_C_window_2_2 <= 0;
				end
			endcase	
		else
			begin 
				Inter_C_window_0_0 <= 0; Inter_C_window_1_0 <= 0;Inter_C_window_2_0 <= 0;
				Inter_C_window_0_1 <= 0; Inter_C_window_1_1 <= 0;Inter_C_window_2_1 <= 0;
				Inter_C_window_0_2 <= 0; Inter_C_window_1_2 <= 0;Inter_C_window_2_2 <= 0;
			end
				
endmodule				
					
		
	
					
						
		 
	 
	