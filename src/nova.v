//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : nova.v
// Generated : Feb 25,2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Top module of nova design, including two main blocks: BitStream controller and reconstruction datapath
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module nova (clk,reset_n,BitStream_buffer_input,BitStream_ram_ren,BitStream_ram_addr,
	pic_num,pin_disable_DF,freq_ctrl0,freq_ctrl1,
	ext_frame_RAM0_cs_n,ext_frame_RAM0_wr,ext_frame_RAM0_addr,ext_frame_RAM0_data,
	ext_frame_RAM1_cs_n,ext_frame_RAM1_wr,ext_frame_RAM1_addr,ext_frame_RAM1_data,
	dis_frame_RAM_din,
	
	slice_header_s6
	);
	input clk,reset_n;
	input [15:0] BitStream_buffer_input;
	input pin_disable_DF;
	input freq_ctrl0;
	input freq_ctrl1;
	
	output BitStream_ram_ren;
	output [16:0] BitStream_ram_addr;
	output [5:0] pic_num;
	//---ext_frame_RAM0---
	output ext_frame_RAM0_cs_n;
	output ext_frame_RAM0_wr;
	output [13:0] ext_frame_RAM0_addr;
	//inout [31:0] ext_frame_RAM0_data;
	input [31:0] ext_frame_RAM0_data;
	
	//---ext_frame_RAM1---
	output ext_frame_RAM1_cs_n;
	output ext_frame_RAM1_wr;
	output [13:0] ext_frame_RAM1_addr;
	//inout [31:0] ext_frame_RAM1_data;
	input [31:0] ext_frame_RAM1_data;
	
	output [31:0] dis_frame_RAM_din;
	output slice_header_s6;
	   
	wire trigger_CAVLC;	
	wire end_of_NonZeroCoeff_CAVLC;
	wire end_of_DCBlk_IQIT;
	wire end_of_one_blk4x4_sum;
	wire end_of_MB_DEC;
	wire gclk_end_of_MB_DEC;
	wire end_of_one_residual_block;
	wire end_of_one_frame;
	wire Is_skip_run_entry;
	wire Is_skip_run_end;
	wire skip_mv_calc;
	wire [3:0] mb_type_general;
	wire [3:0] mb_num_h;
	wire [3:0] mb_num_v;
	wire NextMB_IsSkip;
	wire LowerMB_IsSkip;
	wire [4:0] blk4x4_rec_counter;
	wire [3:0] slice_data_state;
	wire [3:0] residual_state; 
	wire [3:0] cavlc_decoder_state;
	wire [1:0] Intra16x16_predmode;
	wire [63:0] Intra4x4_predmode_CurrMb;
	wire [1:0] Intra_chroma_predmode;
	wire [5:0] QPy;
	wire [5:0] QPc;
	wire [1:0] i4x4_CbCr;
	wire [3:0] slice_alpha_c0_offset_div2;
	wire [3:0] slice_beta_offset_div2;
	wire [3:0] CodedBlockPatternLuma;
	wire [1:0] CodedBlockPatternChroma;
	wire [4:0] TotalCoeff;
	wire disable_DF;
	wire [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5; 
	wire [8:0] coeffLevel_6, coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11;
	wire [8:0] coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15;	
	wire mv_is16x16;
	wire [3:0] mv_below8x8;
	wire [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	wire [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	wire [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	wire [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	wire curr_DC_IsZero;
	wire end_of_BS_DEC;
		
	BitStream_controller BitStream_controller (
		.clk(clk),
	  .reset_n(reset_n),
		.freq_ctrl0(freq_ctrl0),
		.freq_ctrl1(freq_ctrl1),
	  .BitStream_buffer_input(BitStream_buffer_input),
		.pin_disable_DF(pin_disable_DF),
	  .trigger_CAVLC(trigger_CAVLC),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.end_of_DCBlk_IQIT(end_of_DCBlk_IQIT),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.end_of_MB_DEC(end_of_MB_DEC),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.curr_DC_IsZero(curr_DC_IsZero),
	    
		.BitStream_ram_ren(BitStream_ram_ren),
		.BitStream_ram_addr(BitStream_ram_addr),
		.pic_num(pic_num),
		.mb_type_general(mb_type_general),
	  .mb_num_h(mb_num_h),
	  .mb_num_v(mb_num_v),
		.NextMB_IsSkip(NextMB_IsSkip),
		.LowerMB_IsSkip(LowerMB_IsSkip),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC),
		.end_of_one_frame(end_of_one_frame),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra4x4_predmode_CurrMb(Intra4x4_predmode_CurrMb),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.QPy(QPy),
		.QPc(QPc),
		.i4x4_CbCr(i4x4_CbCr),
		.slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
		.slice_beta_offset_div2(slice_beta_offset_div2),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.TotalCoeff(TotalCoeff),
		.Is_skip_run_entry(Is_skip_run_entry),
		.skip_mv_calc(skip_mv_calc),
		.disable_DF(disable_DF),
		.coeffLevel_0(coeffLevel_0),
		.coeffLevel_1(coeffLevel_1),
		.coeffLevel_2(coeffLevel_2), 
		.coeffLevel_3(coeffLevel_3), 
		.coeffLevel_4(coeffLevel_4), 
		.coeffLevel_5(coeffLevel_5), 
		.coeffLevel_6(coeffLevel_6), 
		.coeffLevel_7(coeffLevel_7),
		.coeffLevel_8(coeffLevel_8),
		.coeffLevel_9(coeffLevel_9),
		.coeffLevel_10(coeffLevel_10),
		.coeffLevel_11(coeffLevel_11),
		.coeffLevel_12(coeffLevel_12),
		.coeffLevel_13(coeffLevel_13),
		.coeffLevel_14(coeffLevel_14),
		.coeffLevel_15(coeffLevel_15),
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
		.end_of_BS_DEC(end_of_BS_DEC),
		.bs_V0(bs_V0),
		.bs_V1(bs_V1),
		.bs_V2(bs_V2),
		.bs_V3(bs_V3),
		.bs_H0(bs_H0),
		.bs_H1(bs_H1),
		.bs_H2(bs_H2),
		.bs_H3(bs_H3),
		
		.slice_header_s6(slice_header_s6)
		);
	reconstruction reconstruction (
		.clk(clk),
	  .reset_n(reset_n),
	  .mb_type_general(mb_type_general),
	  .mb_num_h(mb_num_h),
	  .mb_num_v(mb_num_v),
		.NextMB_IsSkip(NextMB_IsSkip),
		.LowerMB_IsSkip(LowerMB_IsSkip),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC),
		.end_of_one_frame(end_of_one_frame),
	  .Intra16x16_predmode(Intra16x16_predmode),
		.Intra4x4_predmode_CurrMb(Intra4x4_predmode_CurrMb),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.QPy(QPy),
		.QPc(QPc),
		.i4x4_CbCr(i4x4_CbCr),
		.slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
		.slice_beta_offset_div2(slice_beta_offset_div2),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.TotalCoeff(TotalCoeff), 
		.Is_skip_run_entry(Is_skip_run_entry),
		.skip_mv_calc(skip_mv_calc),
		.disable_DF(disable_DF),
		.coeffLevel_0(coeffLevel_0),
		.coeffLevel_1(coeffLevel_1),
		.coeffLevel_2(coeffLevel_2), 
		.coeffLevel_3(coeffLevel_3), 
		.coeffLevel_4(coeffLevel_4), 
		.coeffLevel_5(coeffLevel_5), 
		.coeffLevel_6(coeffLevel_6), 
		.coeffLevel_7(coeffLevel_7),
		.coeffLevel_8(coeffLevel_8),
		.coeffLevel_9(coeffLevel_9),
		.coeffLevel_10(coeffLevel_10),
		.coeffLevel_11(coeffLevel_11),
		.coeffLevel_12(coeffLevel_12),
		.coeffLevel_13(coeffLevel_13),
		.coeffLevel_14(coeffLevel_14),
		.coeffLevel_15(coeffLevel_15),
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
		.end_of_BS_DEC(end_of_BS_DEC),
		.bs_V0(bs_V0),
		.bs_V1(bs_V1),
		.bs_V2(bs_V2),
		.bs_V3(bs_V3),
		.bs_H0(bs_H0),
		.bs_H1(bs_H1),
		.bs_H2(bs_H2),
		.bs_H3(bs_H3),
			
		.trigger_CAVLC(trigger_CAVLC),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.end_of_DCBlk_IQIT(end_of_DCBlk_IQIT),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.end_of_MB_DEC(end_of_MB_DEC),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.curr_DC_IsZero(curr_DC_IsZero),
		.ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr(ext_frame_RAM0_addr),
		.ext_frame_RAM0_data(ext_frame_RAM0_data),
		.ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr(ext_frame_RAM1_addr),
		.ext_frame_RAM1_data(ext_frame_RAM1_data),
		.dis_frame_RAM_din(dis_frame_RAM_din)
		);

endmodule
