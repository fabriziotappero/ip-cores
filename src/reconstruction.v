//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : reconstruction.v
// Generated : Jan 3,2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// reconstruction top module,including:
//  rec_gclk_gen
//  hybrid_pipeline_ctrl
//  IQIT
//  Intra_pred_top
//  sum
//  DF_top
//  rec_DF_RAM_ctrl
//  rec_DF_RAM0
//  rec_DF_RAM1
//  ext_RAM_ctrl
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module reconstruction (clk,reset_n,mb_type_general,mb_num_h,mb_num_v,NextMB_IsSkip,LowerMB_IsSkip,
	slice_data_state,residual_state,cavlc_decoder_state,
	end_of_one_residual_block,end_of_NonZeroCoeff_CAVLC,end_of_one_frame,
	Intra16x16_predmode,Intra4x4_predmode_CurrMb,Intra_chroma_predmode,
	QPy,QPc,i4x4_CbCr,slice_alpha_c0_offset_div2,slice_beta_offset_div2,
	CodedBlockPatternLuma,CodedBlockPatternChroma,TotalCoeff,Is_skip_run_entry,
	skip_mv_calc,disable_DF,
	
	coeffLevel_0,coeffLevel_1,coeffLevel_2, coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6, coeffLevel_7,
	coeffLevel_8,coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15,
	mv_is16x16,mv_below8x8,
	mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3,mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3,
	end_of_BS_DEC,bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3,
	
	trigger_CAVLC,blk4x4_rec_counter,end_of_DCBlk_IQIT,end_of_one_blk4x4_sum,
	end_of_MB_DEC,gclk_end_of_MB_DEC,curr_DC_IsZero,
	ext_frame_RAM0_cs_n,ext_frame_RAM0_wr,ext_frame_RAM0_addr,ext_frame_RAM0_data,
	ext_frame_RAM1_cs_n,ext_frame_RAM1_wr,ext_frame_RAM1_addr,ext_frame_RAM1_data,
	dis_frame_RAM_din
	);
	input clk;
	input reset_n;
	input [3:0] mb_type_general;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input NextMB_IsSkip;
	input LowerMB_IsSkip;
	input [3:0] slice_data_state;
	input [3:0] residual_state; 
	input [3:0] cavlc_decoder_state;
	input end_of_one_residual_block;
	input end_of_NonZeroCoeff_CAVLC;
	input end_of_one_frame;
	input [1:0] Intra16x16_predmode;
	input [63:0] Intra4x4_predmode_CurrMb;
	input [1:0] Intra_chroma_predmode;
	input [5:0] QPy;
	input [5:0] QPc;
	input [1:0] i4x4_CbCr;
	input [3:0] slice_alpha_c0_offset_div2;
	input [3:0]	slice_beta_offset_div2;
	input [3:0] CodedBlockPatternLuma;
	input [1:0] CodedBlockPatternChroma;
	input [4:0] TotalCoeff;
	input Is_skip_run_entry;
	input skip_mv_calc;
	input disable_DF;
	input [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5; 
	input [8:0] coeffLevel_6, coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11;
	input [8:0] coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15;
	input mv_is16x16;
	input [3:0] mv_below8x8;
	input [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	input [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	input end_of_BS_DEC;
	input [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	input [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	input [31:0] ext_frame_RAM0_data;
	input [31:0] ext_frame_RAM1_data;
	
	output trigger_CAVLC; 
	output [4:0] blk4x4_rec_counter;
	output end_of_DCBlk_IQIT;
	output end_of_one_blk4x4_sum; 
	output end_of_MB_DEC;
	output gclk_end_of_MB_DEC;
	output curr_DC_IsZero;
	
	output ext_frame_RAM0_cs_n;
	output ext_frame_RAM0_wr;
	output [13:0] ext_frame_RAM0_addr;
	
	output ext_frame_RAM1_cs_n;
	output ext_frame_RAM1_wr;
	output [13:0] ext_frame_RAM1_addr;
	
	output [31:0] dis_frame_RAM_din;
	
	wire gclk_endof1resblk;
	wire gclk_1D;
	wire gclk_2D;
	wire gclk_rescale;
	wire gclk_rounding;
	wire gclk_intra_mbAddrA_luma;
	wire gclk_intra_mbAddrA_Cb;
	wire gclk_intra_mbAddrA_Cr;
	wire gclk_intra_mbAddrB;
	wire gclk_intra_mbAddrC_luma;
	wire gclk_intra_mbAddrD;
	wire gclk_seed;
	wire gclk_Inter_ref_rf;
	wire gclk_pred_output;
	wire gclk_blk4x4_sum;
	wire gclk_DF;
	wire gclk_end_of_MB_DEC;

	wire curr_CBPLuma_IsZero;
	wire curr_DC_IsZero;
	wire end_of_ACBlk4x4_IQIT;
	wire end_of_one_blk4x4_intra;
	wire end_of_one_blk4x4_inter;
	wire end_of_one_blk4x4_sum;
	wire end_of_MB_DF;
	wire end_of_MB_DEC;
	wire trigger_blk4x4_intra_pred;
	wire trigger_blk4x4_inter_pred;
	wire trigger_blk4x4_rec_sum;
	wire [15:0] res_luma_DConly;
	wire res_chroma_DConly;
	wire res_AC;
	wire res_DC;
	wire res_luma;
	wire [2:0] OneD_counter;
	wire [2:0] TwoD_counter;
	wire [2:0] rescale_counter;
	wire [2:0] rounding_counter;
	wire [2:0] blk4x4_intra_preload_counter;
	wire [3:0] blk4x4_intra_precompute_counter;
	wire [2:0] blk4x4_intra_calculate_counter;
	wire [5:0] blk4x4_inter_preload_counter;
	wire [3:0] blk4x4_inter_calculate_counter;
	wire [1:0] Inter_chroma2x2_counter;
	wire [4:0] blk4x4_rec_counter;
	wire [2:0] blk4x4_sum_counter;
	wire [4:0] blk4x4_rec_counter_2_raster_order;
	wire [5:0] DF_edge_counter_MR;
	wire [1:0] one_edge_counter_MR;
	wire [1:0] Inter_blk4x4_pred_output_valid;
	wire mv_below8x8_curr;
	wire [3:0] pos_FracL;
	
	wire [3:0] Intra4x4_predmode;	
	wire [8:0] IQIT_output_0, IQIT_output_1, IQIT_output_2, IQIT_output_3;
	wire [8:0] IQIT_output_4, IQIT_output_5, IQIT_output_6, IQIT_output_7;
	wire [8:0] IQIT_output_8, IQIT_output_9, IQIT_output_10,IQIT_output_11;
	wire [8:0] IQIT_output_12,IQIT_output_13,IQIT_output_14,IQIT_output_15;
	wire [7:0] Intra_pred_PE0_out,Intra_pred_PE1_out,Intra_pred_PE2_out,Intra_pred_PE3_out;
	wire [7:0] Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3;
	wire [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	wire [7:0] blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2;
	wire [7:0] blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6;
	wire [7:0] blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10;
	wire [7:0] blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14;
	wire [8:0] curr_DC_scaled;
	wire [23:0] sum_right_column_reg;
	
	wire DF_duration;
	wire gclk_Intra_mbAddrB_RAM;
	wire Intra_mbAddrB_RAM_rd;
	wire Intra_mbAddrB_RAM_wr;
	wire [6:0] Intra_mbAddrB_RAM_rd_addr,Intra_mbAddrB_RAM_wr_addr;
	wire [31:0] Intra_mbAddrB_RAM_din;
	wire [31:0] Intra_mbAddrB_RAM_dout;
	wire gclk_DF_mbAddrA_RF;
	wire DF_mbAddrA_RF_rd;
	wire DF_mbAddrA_RF_wr;
	wire [4:0] DF_mbAddrA_RF_rd_addr;
	wire [4:0] DF_mbAddrA_RF_wr_addr;
	wire [31:0] DF_mbAddrA_RF_din;
	wire [31:0] DF_mbAddrA_RF_dout;
	wire gclk_DF_mbAddrB_RAM;
	wire DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr;
	wire [8:0] DF_mbAddrB_RAM_addr;
	wire [31:0] DF_mbAddrB_RAM_din;
	wire [31:0] DF_mbAddrB_RAM_dout;
	wire gclk_rec_DF_RAM0,gclk_rec_DF_RAM1;
	wire [31:0] rec_DF_RAM_dout;
	wire rec_DF_RAM0_wr,rec_DF_RAM1_wr;
	wire rec_DF_RAM0_rd,rec_DF_RAM1_rd;
	wire [6:0] rec_DF_RAM0_addr,rec_DF_RAM1_addr;
	wire [31:0] rec_DF_RAM0_din,rec_DF_RAM1_din;
	wire [31:0] rec_DF_RAM0_dout,rec_DF_RAM1_dout;
	wire dis_frame_RAM_wr;
	wire [13:0] dis_frame_RAM_wr_addr;
	wire [31:0] dis_frame_RAM_din;
	wire ref_frame_RAM_rd;
	wire [13:0] ref_frame_RAM_rd_addr;
	wire [31:0] ref_frame_RAM_dout;
	
	
	rec_gclk_gen rec_gclk_gen (
		.clk(clk),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC),
		.OneD_counter(OneD_counter),
		.TwoD_counter(TwoD_counter),
		.rescale_counter(rescale_counter),
		.rounding_counter(rounding_counter),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.gclk_1D(gclk_1D),
		.gclk_2D(gclk_2D),
		.gclk_rescale(gclk_rescale),
		.gclk_rounding(gclk_rounding),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.NextMB_IsSkip(NextMB_IsSkip),
		.mb_type_general(mb_type_general),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_intra_preload_counter(blk4x4_intra_preload_counter),
		.blk4x4_intra_precompute_counter(blk4x4_intra_precompute_counter),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.Intra4x4_predmode(Intra4x4_predmode),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.gclk_intra_mbAddrA_luma(gclk_intra_mbAddrA_luma),
		.gclk_intra_mbAddrA_Cb(gclk_intra_mbAddrA_Cb),
		.gclk_intra_mbAddrA_Cr(gclk_intra_mbAddrA_Cr),
		.gclk_intra_mbAddrB(gclk_intra_mbAddrB),
		.gclk_intra_mbAddrC_luma(gclk_intra_mbAddrC_luma),
		.gclk_intra_mbAddrD(gclk_intra_mbAddrD),
		.gclk_seed(gclk_seed),
		.blk4x4_inter_preload_counter(blk4x4_inter_preload_counter),
		.gclk_Inter_ref_rf(gclk_Inter_ref_rf),
		.Inter_blk4x4_pred_output_valid(Inter_blk4x4_pred_output_valid),
		.gclk_pred_output(gclk_pred_output),
		.gclk_blk4x4_sum(gclk_blk4x4_sum),
		.end_of_MB_DEC(end_of_MB_DEC),
		.end_of_BS_DEC(end_of_BS_DEC),
		.DF_duration(DF_duration),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.gclk_DF(gclk_DF),
		.Intra_mbAddrB_RAM_rd(Intra_mbAddrB_RAM_rd),
		.Intra_mbAddrB_RAM_wr(Intra_mbAddrB_RAM_wr),
		.gclk_Intra_mbAddrB_RAM(gclk_Intra_mbAddrB_RAM),
		.rec_DF_RAM0_cs_n(rec_DF_RAM0_cs_n),
		.gclk_rec_DF_RAM0(gclk_rec_DF_RAM0),
		.rec_DF_RAM1_cs_n(rec_DF_RAM1_cs_n),
		.gclk_rec_DF_RAM1(gclk_rec_DF_RAM1),
		.DF_mbAddrA_RF_rd(DF_mbAddrA_RF_rd),
		.DF_mbAddrA_RF_wr(DF_mbAddrA_RF_wr),
		.gclk_DF_mbAddrA_RF(gclk_DF_mbAddrA_RF),
		.DF_mbAddrB_RAM_rd(DF_mbAddrB_RAM_rd),
		.DF_mbAddrB_RAM_wr(DF_mbAddrB_RAM_wr),
		.gclk_DF_mbAddrB_RAM(gclk_DF_mbAddrB_RAM)
		);
	hybrid_pipeline_ctrl hybrid_pipeline_ctrl (
		.clk(clk),
		.reset_n(reset_n),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.mb_type_general(mb_type_general),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.TotalCoeff(TotalCoeff),
		.Is_skip_run_entry(Is_skip_run_entry),
		.skip_mv_calc(skip_mv_calc),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_DCBlk_IQIT(end_of_DCBlk_IQIT),
		.end_of_ACBlk4x4_IQIT(end_of_ACBlk4x4_IQIT),
		.end_of_one_blk4x4_intra(end_of_one_blk4x4_intra),
		.end_of_one_blk4x4_inter(end_of_one_blk4x4_inter),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.end_of_MB_DF(end_of_MB_DF),
		.disable_DF(disable_DF),
		
		.curr_CBPLuma_IsZero(curr_CBPLuma_IsZero),
		.end_of_MB_DEC(end_of_MB_DEC),
		.trigger_CAVLC(trigger_CAVLC),
		.trigger_blk4x4_intra_pred(trigger_blk4x4_intra_pred),
		.trigger_blk4x4_inter_pred(trigger_blk4x4_inter_pred),
		.trigger_blk4x4_rec_sum(trigger_blk4x4_rec_sum)
		);
	IQIT IQIT (
		.clk(clk),
		.reset_n(reset_n),
		.TotalCoeff(TotalCoeff),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.gclk_1D(gclk_1D),
		.gclk_2D(gclk_2D),
		.gclk_rescale(gclk_rescale),
		.gclk_rounding(gclk_rounding),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC),
		.QPy(QPy),
		.QPc(QPc),
		.i4x4_CbCr(i4x4_CbCr),
		.coeffLevel_ext_0({{7{coeffLevel_0[8]}},coeffLevel_0}),
		.coeffLevel_ext_1({{7{coeffLevel_1[8]}},coeffLevel_1}),
		.coeffLevel_ext_2({{7{coeffLevel_2[8]}},coeffLevel_2}),
		.coeffLevel_ext_3({{7{coeffLevel_3[8]}},coeffLevel_3}),
		.coeffLevel_ext_4({{7{coeffLevel_4[8]}},coeffLevel_4}),
		.coeffLevel_ext_5({{7{coeffLevel_5[8]}},coeffLevel_5}),
		.coeffLevel_ext_6({{7{coeffLevel_6[8]}},coeffLevel_6}),
		.coeffLevel_ext_7({{7{coeffLevel_7[8]}},coeffLevel_7}),
		.coeffLevel_ext_8({{7{coeffLevel_8[8]}},coeffLevel_8}),
		.coeffLevel_ext_9({{7{coeffLevel_9[8]}},coeffLevel_9}),
		.coeffLevel_ext_10({{7{coeffLevel_10[8]}},coeffLevel_10}),
		.coeffLevel_ext_11({{7{coeffLevel_11[8]}},coeffLevel_11}),
		.coeffLevel_ext_12({{7{coeffLevel_12[8]}},coeffLevel_12}),
		.coeffLevel_ext_13({{7{coeffLevel_13[8]}},coeffLevel_13}),
		.coeffLevel_ext_14({{7{coeffLevel_14[8]}},coeffLevel_14}),
		.coeffLevel_ext_15({{7{coeffLevel_15[8]}},coeffLevel_15}),
		
		.OneD_counter(OneD_counter),
		.TwoD_counter(TwoD_counter),
		.rescale_counter(rescale_counter),
		.rounding_counter(rounding_counter),
		.curr_DC_IsZero(curr_DC_IsZero),
		.curr_DC_scaled(curr_DC_scaled),
		.rounding_output_0(IQIT_output_0),
		.rounding_output_1(IQIT_output_1),
		.rounding_output_2(IQIT_output_2),
		.rounding_output_3(IQIT_output_3),
		.rounding_output_4(IQIT_output_4),
		.rounding_output_5(IQIT_output_5),
		.rounding_output_6(IQIT_output_6),
		.rounding_output_7(IQIT_output_7),
		.rounding_output_8(IQIT_output_8),
		.rounding_output_9(IQIT_output_9),
		.rounding_output_10(IQIT_output_10),
		.rounding_output_11(IQIT_output_11),
		.rounding_output_12(IQIT_output_12),
		.rounding_output_13(IQIT_output_13),
		.rounding_output_14(IQIT_output_14),
		.rounding_output_15(IQIT_output_15),
		.end_of_ACBlk4x4_IQIT(end_of_ACBlk4x4_IQIT),
		.end_of_DCBlk_IQIT(end_of_DCBlk_IQIT)
		);
	Intra_pred_top Intra_pred_top (
		.clk(clk),
		.reset_n(reset_n),
		.gclk_intra_mbAddrA_luma(gclk_intra_mbAddrA_luma),
		.gclk_intra_mbAddrA_Cb(gclk_intra_mbAddrA_Cb),
		.gclk_intra_mbAddrA_Cr(gclk_intra_mbAddrA_Cr),
		.gclk_intra_mbAddrB(gclk_intra_mbAddrB),
		.gclk_intra_mbAddrC_luma(gclk_intra_mbAddrC_luma),
		.gclk_intra_mbAddrD(gclk_intra_mbAddrD),
		.gclk_seed(gclk_seed),
		.gclk_Intra_mbAddrB_RAM(gclk_Intra_mbAddrB_RAM),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.mb_type_general(mb_type_general),
		.NextMB_IsSkip(NextMB_IsSkip),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra4x4_predmode_CurrMb(Intra4x4_predmode_CurrMb),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.trigger_blk4x4_intra_pred(trigger_blk4x4_intra_pred),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.sum_right_column_reg(sum_right_column_reg),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		.blk4x4_pred_output0(blk4x4_pred_output0), 
		.blk4x4_pred_output1(blk4x4_pred_output1), 
		.blk4x4_pred_output2(blk4x4_pred_output2),
		.blk4x4_pred_output4(blk4x4_pred_output4), 
		.blk4x4_pred_output5(blk4x4_pred_output5), 
		.blk4x4_pred_output6(blk4x4_pred_output6),
		.blk4x4_pred_output8(blk4x4_pred_output8), 
		.blk4x4_pred_output9(blk4x4_pred_output9), 
		.blk4x4_pred_output10(blk4x4_pred_output10),
		.blk4x4_pred_output12(blk4x4_pred_output12),
		.blk4x4_pred_output13(blk4x4_pred_output13),
		.blk4x4_pred_output14(blk4x4_pred_output14),
		.Intra_mbAddrB_RAM_wr(Intra_mbAddrB_RAM_wr),
		.Intra_mbAddrB_RAM_wr_addr(Intra_mbAddrB_RAM_wr_addr),
		.Intra_mbAddrB_RAM_din(Intra_mbAddrB_RAM_din),
		
		.PE0_out(Intra_pred_PE0_out),
		.PE1_out(Intra_pred_PE1_out),
		.PE2_out(Intra_pred_PE2_out),
		.PE3_out(Intra_pred_PE3_out), 
		.Intra4x4_predmode(Intra4x4_predmode),
		.blk4x4_intra_preload_counter(blk4x4_intra_preload_counter),
		.blk4x4_intra_precompute_counter(blk4x4_intra_precompute_counter),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.end_of_one_blk4x4_intra(end_of_one_blk4x4_intra),
		.Intra_mbAddrB_RAM_rd(Intra_mbAddrB_RAM_rd)
		);
	Inter_pred_top Inter_pred_top (
		.clk(clk),
		.gclk_Inter_ref_rf(gclk_Inter_ref_rf),
		.reset_n(reset_n),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.trigger_blk4x4_inter_pred(trigger_blk4x4_inter_pred),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.mb_type_general_bit3(mb_type_general[3]),
		.mv_is16x16(mv_is16x16),
		.mv_below8x8(mv_below8x8),
		.mvx_CurrMb0(mvx_CurrMb0),
		.mvx_CurrMb1(mvx_CurrMb1),
		.mvx_CurrMb2(mvx_CurrMb2),
		.mvx_CurrMb3(mvx_CurrMb3),
		.mvy_CurrMb0(mvy_CurrMb0),
		.mvy_CurrMb1(mvy_CurrMb1),
		.mvy_CurrMb2(mvy_CurrMb2),
		.mvy_CurrMb3(mvy_CurrMb3),
		.ref_frame_RAM_dout(ref_frame_RAM_dout),
		
		.Inter_pred_out0(Inter_pred_out0),
		.Inter_pred_out1(Inter_pred_out1),
		.Inter_pred_out2(Inter_pred_out2),
		.Inter_pred_out3(Inter_pred_out3),
		.blk4x4_inter_preload_counter(blk4x4_inter_preload_counter),
		.blk4x4_inter_calculate_counter(blk4x4_inter_calculate_counter),
		.Inter_chroma2x2_counter(Inter_chroma2x2_counter),
		.mv_below8x8_curr(mv_below8x8_curr),
		.pos_FracL(pos_FracL),
		.end_of_one_blk4x4_inter(end_of_one_blk4x4_inter),
		.Inter_blk4x4_pred_output_valid(Inter_blk4x4_pred_output_valid),
		.ref_frame_RAM_rd(ref_frame_RAM_rd),
		.ref_frame_RAM_rd_addr(ref_frame_RAM_rd_addr)
		);
	sum sum (
		.clk(clk),
		.reset_n(reset_n),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.TotalCoeff(TotalCoeff),
		.curr_CBPLuma_IsZero(curr_CBPLuma_IsZero),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.curr_DC_IsZero(curr_DC_IsZero),
		.curr_DC_scaled(curr_DC_scaled),
		.gclk_pred_output(gclk_pred_output),
		.gclk_blk4x4_sum(gclk_blk4x4_sum),
		.trigger_blk4x4_rec_sum(trigger_blk4x4_rec_sum),
		.IQIT_output_0(IQIT_output_0), 
		.IQIT_output_1(IQIT_output_1),
		.IQIT_output_2(IQIT_output_2), 
		.IQIT_output_3(IQIT_output_3),
		.IQIT_output_4(IQIT_output_4), 
		.IQIT_output_5(IQIT_output_5), 
		.IQIT_output_6(IQIT_output_6), 
		.IQIT_output_7(IQIT_output_7),
		.IQIT_output_8(IQIT_output_8), 
		.IQIT_output_9(IQIT_output_9), 
		.IQIT_output_10(IQIT_output_10),
		.IQIT_output_11(IQIT_output_11),
		.IQIT_output_12(IQIT_output_12),
		.IQIT_output_13(IQIT_output_13),
		.IQIT_output_14(IQIT_output_14),
		.IQIT_output_15(IQIT_output_15),
		.mb_type_general(mb_type_general),
		.Intra4x4_predmode(Intra4x4_predmode),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.Intra_pred_PE0_out(Intra_pred_PE0_out),
		.Intra_pred_PE1_out(Intra_pred_PE1_out),
		.Intra_pred_PE2_out(Intra_pred_PE2_out),
		.Intra_pred_PE3_out(Intra_pred_PE3_out),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.Inter_pred_out0(Inter_pred_out0),
		.Inter_pred_out1(Inter_pred_out1),
		.Inter_pred_out2(Inter_pred_out2),
		.Inter_pred_out3(Inter_pred_out3),
		.blk4x4_inter_calculate_counter(blk4x4_inter_calculate_counter),
		.Inter_chroma2x2_counter(Inter_chroma2x2_counter),
		.Inter_blk4x4_pred_output_valid(Inter_blk4x4_pred_output_valid),
		.mv_below8x8_curr(mv_below8x8_curr),
		.pos_FracL(pos_FracL),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v), 
		.LowerMB_IsSkip(LowerMB_IsSkip),
		
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		.blk4x4_rec_counter_2_raster_order(blk4x4_rec_counter_2_raster_order),
		.sum_right_column_reg(sum_right_column_reg),
		.blk4x4_pred_output0(blk4x4_pred_output0), 
		.blk4x4_pred_output1(blk4x4_pred_output1), 
		.blk4x4_pred_output2(blk4x4_pred_output2),
		.blk4x4_pred_output4(blk4x4_pred_output4), 
		.blk4x4_pred_output5(blk4x4_pred_output5), 
		.blk4x4_pred_output6(blk4x4_pred_output6),
		.blk4x4_pred_output8(blk4x4_pred_output8), 
		.blk4x4_pred_output9(blk4x4_pred_output9), 
		.blk4x4_pred_output10(blk4x4_pred_output10),
		.blk4x4_pred_output12(blk4x4_pred_output12),
		.blk4x4_pred_output13(blk4x4_pred_output13),
		.blk4x4_pred_output14(blk4x4_pred_output14),
		.Intra_mbAddrB_RAM_wr(Intra_mbAddrB_RAM_wr),
		.Intra_mbAddrB_RAM_wr_addr(Intra_mbAddrB_RAM_wr_addr),
		.Intra_mbAddrB_RAM_din(Intra_mbAddrB_RAM_din)
		);
	DF_top DF_top (
		.clk(clk),
		.reset_n(reset_n),
		.gclk_DF(gclk_DF),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.gclk_DF_mbAddrA_RF(gclk_DF_mbAddrA_RF),
		.gclk_DF_mbAddrB_RAM(gclk_DF_mbAddrB_RAM),
		.end_of_BS_DEC(end_of_BS_DEC),
		.disable_DF(disable_DF),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.bs_V0(bs_V0),
		.bs_V1(bs_V1),
		.bs_V2(bs_V2),
		.bs_V3(bs_V3),
		.bs_H0(bs_H0),
		.bs_H1(bs_H1),
		.bs_H2(bs_H2),
		.bs_H3(bs_H3),
		.QPy(QPy),
		.QPc(QPc),
		.slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
		.slice_beta_offset_div2(slice_beta_offset_div2),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_rec_counter_2_raster_order(blk4x4_rec_counter_2_raster_order),
		.rec_DF_RAM_dout(rec_DF_RAM_dout),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		
		.DF_duration(DF_duration),
		.end_of_MB_DF(end_of_MB_DF),
		.DF_edge_counter_MR(DF_edge_counter_MR),
		.one_edge_counter_MR(one_edge_counter_MR),
		.DF_mbAddrA_RF_rd(DF_mbAddrA_RF_rd),
		.DF_mbAddrA_RF_wr(DF_mbAddrA_RF_wr),
		.DF_mbAddrB_RAM_rd(DF_mbAddrB_RAM_rd),
		.DF_mbAddrB_RAM_wr(DF_mbAddrB_RAM_wr),
		.dis_frame_RAM_wr(dis_frame_RAM_wr),
		.dis_frame_RAM_wr_addr(dis_frame_RAM_wr_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din)
		);
	rec_DF_RAM_ctrl rec_DF_RAM_ctrl (
		.clk(clk),
		.reset_n(reset_n),
		.disable_DF(disable_DF),
		.end_of_MB_DEC(end_of_MB_DEC),
		.DF_edge_counter_MR(DF_edge_counter_MR),
		.one_edge_counter_MR(one_edge_counter_MR),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_rec_counter_2_raster_order(blk4x4_rec_counter_2_raster_order),
		.rec_DF_RAM0_dout(rec_DF_RAM0_dout),
		.rec_DF_RAM1_dout(rec_DF_RAM1_dout),
		
		.rec_DF_RAM_dout(rec_DF_RAM_dout),
		.rec_DF_RAM0_wr(rec_DF_RAM0_wr),
		.rec_DF_RAM0_rd(rec_DF_RAM0_rd),
		.rec_DF_RAM0_addr(rec_DF_RAM0_addr),
		.rec_DF_RAM0_din(rec_DF_RAM0_din),
		.rec_DF_RAM1_wr(rec_DF_RAM1_wr),
		.rec_DF_RAM1_rd(rec_DF_RAM1_rd),
		.rec_DF_RAM1_addr(rec_DF_RAM1_addr),
		.rec_DF_RAM1_din(rec_DF_RAM1_din)
		);
	ram_sync_1r_sync_1w #(`rec_DF_RAM0_data_width,`rec_DF_RAM0_data_depth)
	rec_DF_RAM0 (
		.clk(gclk_rec_DF_RAM0),
		.rst_n(reset_n),
		.wr_n(~rec_DF_RAM0_wr),
		.rd_n(~rec_DF_RAM0_rd),
		.wr_addr(rec_DF_RAM0_addr),
		.rd_addr(rec_DF_RAM0_addr),
		.data_in(rec_DF_RAM0_din),
		.data_out(rec_DF_RAM0_dout)
		); 
	ram_sync_1r_sync_1w #(`rec_DF_RAM1_data_width,`rec_DF_RAM1_data_depth)
	rec_DF_RAM1 (
		.clk(gclk_rec_DF_RAM1),
		.rst_n(reset_n),
		.wr_n(~rec_DF_RAM1_wr),
		.rd_n(~rec_DF_RAM1_rd),
		.wr_addr(rec_DF_RAM1_addr),
		.rd_addr(rec_DF_RAM1_addr),
		.data_in(rec_DF_RAM1_din),
		.data_out(rec_DF_RAM1_dout)
		);
	ext_RAM_ctrl ext_RAM_ctrl(
		.clk(clk),
		.reset_n(reset_n),
		.end_of_one_frame(end_of_one_frame),
		.ref_frame_RAM_rd(ref_frame_RAM_rd),
		.ref_frame_RAM_rd_addr(ref_frame_RAM_rd_addr),
		.dis_frame_RAM_wr(dis_frame_RAM_wr),
		.dis_frame_RAM_wr_addr(dis_frame_RAM_wr_addr),
		//.dis_frame_RAM_din(dis_frame_RAM_din),
		.ref_frame_RAM_dout(ref_frame_RAM_dout),
		.ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr(ext_frame_RAM0_addr),
		.ext_frame_RAM0_data(ext_frame_RAM0_data),
		.ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr(ext_frame_RAM1_addr),
		.ext_frame_RAM1_data(ext_frame_RAM1_data)
		);
endmodule