//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : BitStream_controller.v
// Generated : June 12,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// top module for bitstream controller
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module BitStream_controller (clk,reset_n,freq_ctrl0,freq_ctrl1,BitStream_buffer_input,pin_disable_DF,
	trigger_CAVLC,blk4x4_rec_counter,end_of_DCBlk_IQIT,end_of_one_blk4x4_sum,end_of_MB_DEC,gclk_end_of_MB_DEC,
	curr_DC_IsZero,
	
	BitStream_ram_ren,BitStream_ram_addr,pic_num,
	mb_type_general,mb_num_h,mb_num_v,NextMB_IsSkip,LowerMB_IsSkip,
	slice_data_state,residual_state,cavlc_decoder_state,
	end_of_one_residual_block,end_of_NonZeroCoeff_CAVLC,end_of_one_frame,
	Intra16x16_predmode,Intra4x4_predmode_CurrMb,Intra_chroma_predmode,
	QPy,QPc,i4x4_CbCr,slice_alpha_c0_offset_div2,slice_beta_offset_div2,
	CodedBlockPatternLuma,CodedBlockPatternChroma,TotalCoeff,
	Is_skip_run_entry,skip_mv_calc,disable_DF,
	coeffLevel_0,coeffLevel_1,coeffLevel_2, coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6, coeffLevel_7,
	coeffLevel_8,coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15,
	mv_is16x16,mv_below8x8,
	mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3,mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3,
	end_of_BS_DEC,bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3,
	
	slice_header_s6
	);
	input clk,reset_n;
	input freq_ctrl0;
	input freq_ctrl1;
	input [15:0] BitStream_buffer_input;
	input pin_disable_DF;
	input trigger_CAVLC;
	input [4:0] blk4x4_rec_counter;
	input end_of_DCBlk_IQIT;
	input end_of_one_blk4x4_sum;
	input end_of_MB_DEC;
	input gclk_end_of_MB_DEC;
	input curr_DC_IsZero;
	
	output BitStream_ram_ren;
	output [16:0] BitStream_ram_addr;
	output [5:0] pic_num;
	
  output [3:0] mb_type_general;
	output [3:0] mb_num_h;
	output [3:0] mb_num_v;
	output NextMB_IsSkip;
	output LowerMB_IsSkip;
	output [3:0] slice_data_state;
	output [3:0] residual_state; 
	output [3:0] cavlc_decoder_state;
	output end_of_one_residual_block;
	output end_of_NonZeroCoeff_CAVLC;
	output end_of_one_frame;
	output [1:0] Intra16x16_predmode;
	output [63:0] Intra4x4_predmode_CurrMb;
	output [1:0] Intra_chroma_predmode;
	output [5:0] QPy;
	output [5:0] QPc;
	output [1:0] i4x4_CbCr;
	output [3:0] slice_alpha_c0_offset_div2;
	output [3:0] slice_beta_offset_div2;
	output [3:0] CodedBlockPatternLuma;
	output [1:0] CodedBlockPatternChroma;
	output [4:0] TotalCoeff;
	output Is_skip_run_entry;
	output skip_mv_calc;
	output disable_DF;
	output [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5; 
	output [8:0] coeffLevel_6, coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11;
	output [8:0] coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15;
	output mv_is16x16;
	output [3:0] mv_below8x8;
	output [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	output [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	output end_of_BS_DEC;
	output [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	output [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	
	output slice_header_s6;
	
	wire gclk_parser;
	wire gclk_nal;
	wire gclk_slice;
	wire gclk_sps;
	wire gclk_pps;
	wire gclk_slice_header;
	wire gclk_slice_data;
	wire gclk_residual;
	wire gclk_cavlc;
	wire gclk_bs_dec;
	wire gclk_Intra4x4PredMode_mbAddrB_RF;
	wire gclk_mvx_mbAddrB_RF;
	wire gclk_mvy_mbAddrB_RF;
	wire gclk_mvx_mbAddrC_RF;
	wire gclk_mvy_mbAddrC_RF;
	wire gclk_LumaLevel_mbAddrB_RF;
	wire gclk_ChromaLevel_Cb_mbAddrB_RF;
	wire gclk_ChromaLevel_Cr_mbAddrB_RF;
	wire [6:0] pc;
	wire [5:0] QPy,QPc;
	wire [3:0] CodedBlockPatternLuma;
	wire [1:0] CodedBlockPatternChroma;
	wire [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5; 
	wire [8:0] coeffLevel_6, coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11;
	wire [8:0] coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15;
	wire [63:0] Intra4x4PredMode_CurrMb;
	wire mv_is16x16;
	wire Is_skip_run_end;
	wire Is_skipMB_mv_calc;
	wire [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	wire [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	
	wire BitStream_buffer_valid_n;
	wire [15:0] BitStream_buffer_output;
	wire [1:0] parser_state;
	wire [2:0] nal_unit_state;
	wire [1:0] slice_layer_wo_partitioning_state;
	wire [3:0] slice_header_state;
	wire [2:0] ref_pic_list_reordering_state;
	wire [1:0] dec_ref_pic_marking_state;
	wire [3:0] slice_data_state;
	wire [1:0] sub_mb_pred_state;
	wire [2:0] mb_pred_state;
	wire [3:0] seq_parameter_set_state;
	wire [3:0] pic_parameter_set_state;
	wire [3:0] residual_state;
	wire [3:0] cavlc_decoder_state;
	wire [3:0] exp_golomb_len;
	wire [3:0] dependent_variable_len;
	wire [4:0] cavlc_consumed_bits_len;
	wire heading_one_en;
	wire [3:0] heading_one_pos;
	wire [7:0] exp_golomb_decoding_output;
	wire [9:0] dependent_variable_decoding_output;
	wire Intra4x4PredMode_mbAddrB_cs_n;
	wire Intra4x4PredMode_mbAddrB_wr_n;
	wire [3:0] Intra4x4PredMode_mbAddrB_rd_addr;
	wire [3:0] Intra4x4PredMode_mbAddrB_wr_addr;
	wire [15:0] Intra4x4PredMode_mbAddrB_din;
	wire [15:0] Intra4x4PredMode_mbAddrB_dout;
	wire mvx_mbAddrB_cs_n;
	wire mvy_mbAddrB_cs_n;
	wire mvx_mbAddrC_cs_n;
	wire mvy_mbAddrC_cs_n;
	wire mvx_mbAddrB_wr_n;
	wire mvy_mbAddrB_wr_n;
	wire mvx_mbAddrC_wr_n;
	wire mvy_mbAddrC_wr_n;
	wire [3:0] mvx_mbAddrB_rd_addr;
	wire [3:0] mvy_mbAddrB_rd_addr;
	wire [3:0] mvx_mbAddrC_rd_addr;
	wire [3:0] mvy_mbAddrC_rd_addr;
	wire [3:0] mvx_mbAddrB_wr_addr;
	wire [3:0] mvy_mbAddrB_wr_addr;
	wire [3:0] mvx_mbAddrC_wr_addr;
	wire [3:0] mvy_mbAddrC_wr_addr;
	wire [31:0] mvx_mbAddrA;
	wire [31:0] mvy_mbAddrA;
	wire [31:0] mvx_mbAddrB_din;
	wire [31:0] mvx_mbAddrB_dout;
	wire [31:0] mvy_mbAddrB_din;
	wire [31:0] mvy_mbAddrB_dout;
	wire [7:0] mvx_mbAddrC_din;
	wire [7:0] mvx_mbAddrC_dout;
	wire [7:0] mvy_mbAddrC_din;
	wire [7:0] mvy_mbAddrC_dout;
	wire end_of_NonZeroCoeff_CAVLC;
	wire start_code_prefix_found;
	wire [4:0] nal_unit_type;
	wire deblocking_filter_control_present_flag;
	wire [1:0] disable_deblocking_filter_idc;
	wire disable_DF;
	wire [6:0] mb_skip_run;
	wire [2:0] NumMbPart;
	wire [2:0] NumSubMbPart;
	wire [1:0] MBTypeGen_mbAddrA;
	wire MBTypeGen_mbAddrD;
	wire [21:0]MBTypeGen_mbAddrB_reg;
	wire [3:0] log2_max_frame_num_minus4;
	wire [3:0] log2_max_pic_order_cnt_lsb_minus4;
	wire constrained_intra_pred_flag;
	wire num_ref_idx_active_override_flag;
	wire [2:0] num_ref_idx_l0_active_minus1;
	wire [2:0] slice_type;
	wire [4:0] mb_type;
	wire [3:0] mb_type_general;
	wire [1:0] sub_mb_type;
	wire [5:0] pic_init_qp_minus26;
	wire [4:0] chroma_qp_index_offset;
	wire [2:0] rem_intra4x4_pred_mode;
	wire [7:0] mvd;
	wire prev_intra4x4_pred_mode_flag;
	wire cavlc_decoder_en;
	wire [5:0] pic_num;
	wire [6:0] mb_num;
	wire [3:0] mb_num_h;
	wire [3:0] mb_num_v;
	wire [3:0] luma4x4BlkIdx;
	wire [1:0] mbPartIdx;
	wire [1:0] subMbPartIdx;
	wire compIdx;
	wire suffix_length_initialized;
	wire IsRunLoop;
	wire [1:0] i8x8,i4x4;
	wire [1:0] i4x4_CbCr;
	wire [3:0] coeffNum;
	wire [3:0] i_level;
	wire [3:0] i_run;
	wire [3:0] i_TotalCoeff;
	wire [4:0] TotalCoeff;
	wire [1:0] TrailingOnes;
	wire [4:0] maxNumCoeff;
	wire [3:0] zerosLeft;
	wire [3:0] run;
	
	wire [1:0] Luma_8x8_AllZeroCoeff_mbAddrA;
	wire [19:0] LumaLevel_mbAddrA;
	wire [19:0] LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3;
	wire LumaLevel_mbAddrB_cs_n;
	wire [19:0] LumaLevel_mbAddrB_dout;
	wire ChromaLevel_Cb_mbAddrB_cs_n;
	wire ChromaLevel_Cr_mbAddrB_cs_n;
	wire [1:0] bs_dec_counter;
	wire [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	wire [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	wire mv_mbAddrB_rd_for_DF;
	
	BitStream_buffer BitStream_buffer (
		.clk(clk),
		.reset_n(reset_n),
		.BitStream_buffer_input(BitStream_buffer_input),
		.pc(pc),
		.BitStream_ram_ren(BitStream_ram_ren),
		.BitStream_buffer_valid_n(BitStream_buffer_valid_n),
		.BitStream_buffer_output(BitStream_buffer_output),
		.BitStream_ram_addr(BitStream_ram_addr)
		); 
	bitstream_gclk_gen bitstream_gclk_gen (
		.clk(clk),
		.reset_n(reset_n),
		.freq_ctrl0(freq_ctrl0),
		.freq_ctrl1(freq_ctrl1),
		.parser_state(parser_state),
		.nal_unit_state(nal_unit_state),
		.slice_layer_wo_partitioning_state(slice_layer_wo_partitioning_state),
		.slice_header_state(slice_header_state),
		.slice_data_state(slice_data_state),
		.seq_parameter_set_state(seq_parameter_set_state),
		.pic_parameter_set_state(pic_parameter_set_state),
		.residual_state(residual_state), 
		.cavlc_decoder_state(cavlc_decoder_state),
		.mb_num(mb_num),
		.TotalCoeff(TotalCoeff),
		.start_code_prefix_found(start_code_prefix_found),
		.pc_2to0(pc[2:0]),
		.deblocking_filter_control_present_flag(deblocking_filter_control_present_flag),
		.disable_deblocking_filter_idc(disable_deblocking_filter_idc),
		.end_of_one_residual_block(end_of_one_residual_block),
		.Intra4x4PredMode_mbAddrB_cs_n(Intra4x4PredMode_mbAddrB_cs_n),
		.mvx_mbAddrB_cs_n(mvx_mbAddrB_cs_n),
		.mvy_mbAddrB_cs_n(mvy_mbAddrB_cs_n),
		.mvx_mbAddrC_cs_n(mvx_mbAddrC_cs_n),
		.mvy_mbAddrC_cs_n(mvy_mbAddrC_cs_n),
		.LumaLevel_mbAddrB_cs_n(LumaLevel_mbAddrB_cs_n),
		.ChromaLevel_Cb_mbAddrB_cs_n(ChromaLevel_Cb_mbAddrB_cs_n),
		.ChromaLevel_Cr_mbAddrB_cs_n(ChromaLevel_Cr_mbAddrB_cs_n),
		.trigger_CAVLC(trigger_CAVLC),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.end_of_DCBlk_IQIT(end_of_DCBlk_IQIT),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.end_of_MB_DEC(end_of_MB_DEC), 
		.disable_DF(disable_DF),
		.bs_dec_counter(bs_dec_counter),
		
		.gclk_parser(gclk_parser),
		.gclk_nal(gclk_nal),
		.gclk_slice(gclk_slice),
		.gclk_sps(gclk_sps),
		.gclk_pps(gclk_pps),
		.gclk_slice_header(gclk_slice_header),
		.gclk_slice_data(gclk_slice_data),
		.gclk_residual(gclk_residual),
		.gclk_cavlc(gclk_cavlc),
		.gclk_Intra4x4PredMode_mbAddrB_RF(gclk_Intra4x4PredMode_mbAddrB_RF),
		.gclk_mvx_mbAddrB_RF(gclk_mvx_mbAddrB_RF),
		.gclk_mvy_mbAddrB_RF(gclk_mvy_mbAddrB_RF),
		.gclk_mvx_mbAddrC_RF(gclk_mvx_mbAddrC_RF),
		.gclk_mvy_mbAddrC_RF(gclk_mvy_mbAddrC_RF),
		.gclk_LumaLevel_mbAddrB_RF(gclk_LumaLevel_mbAddrB_RF),
		.gclk_ChromaLevel_Cb_mbAddrB_RF(gclk_ChromaLevel_Cb_mbAddrB_RF),
		.gclk_ChromaLevel_Cr_mbAddrB_RF(gclk_ChromaLevel_Cr_mbAddrB_RF),
		.gclk_bs_dec(gclk_bs_dec),
		.end_of_one_frame(end_of_one_frame)
		);
	BitStream_parser_FSM BitStream_parser_FSM(
		.clk(clk),
		.reset_n(reset_n),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.end_of_MB_DEC(end_of_MB_DEC),
		.gclk_parser(gclk_parser),
		.gclk_nal(gclk_nal),
		.gclk_slice(gclk_slice),
		.gclk_sps(gclk_sps),
		.gclk_pps(gclk_pps),
		.gclk_slice_header(gclk_slice_header),
		.gclk_slice_data(gclk_slice_data),
		.gclk_residual(gclk_residual),
		.gclk_cavlc(gclk_cavlc),
		.trigger_CAVLC(trigger_CAVLC),
		.BitStream_buffer_valid_n(BitStream_buffer_valid_n),
		.nal_unit_type(nal_unit_type),
		.slice_type(slice_type),
		.num_ref_idx_active_override_flag(num_ref_idx_active_override_flag),
		.deblocking_filter_control_present_flag(deblocking_filter_control_present_flag),
		.disable_deblocking_filter_idc(disable_deblocking_filter_idc),
		.mb_skip_run(mb_skip_run),
		.mb_type_general(mb_type_general),
		.prev_intra4x4_pred_mode_flag(prev_intra4x4_pred_mode_flag),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.pc_2to0(pc[2:0]),
		.NumSubMbPart(NumSubMbPart),
		.NumMbPart(NumMbPart),
		.TotalCoeff(TotalCoeff),
		.TrailingOnes(TrailingOnes),
		.maxNumCoeff(maxNumCoeff),
		.zerosLeft(zerosLeft),
		.run(run),
		
		.parser_state(parser_state),
		.nal_unit_state(nal_unit_state),
		.slice_layer_wo_partitioning_state(slice_layer_wo_partitioning_state),
		.slice_header_state(slice_header_state),
		.slice_header_s6(slice_header_s6),
		.ref_pic_list_reordering_state(ref_pic_list_reordering_state),
		.dec_ref_pic_marking_state(dec_ref_pic_marking_state),
		.slice_data_state(slice_data_state),
		.sub_mb_pred_state(sub_mb_pred_state),
		.mb_pred_state(mb_pred_state),
		.seq_parameter_set_state(seq_parameter_set_state),
		.pic_parameter_set_state(pic_parameter_set_state),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.heading_one_en(heading_one_en),
		.pic_num(pic_num),
		.mb_num(mb_num),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.NextMB_IsSkip(NextMB_IsSkip),
		.LowerMB_IsSkip(LowerMB_IsSkip),
		.Is_skip_run_entry(Is_skip_run_entry),
		.Is_skip_run_end(Is_skip_run_end),
		.luma4x4BlkIdx(luma4x4BlkIdx),
		.mbPartIdx(mbPartIdx),
		.subMbPartIdx(subMbPartIdx),
		.compIdx(compIdx),
		.i8x8(i8x8),
		.i4x4(i4x4),
		.i4x4_CbCr(i4x4_CbCr),
		.coeffNum(coeffNum),
		.i_level(i_level),
		.i_run(i_run),
		.i_TotalCoeff(i_TotalCoeff),
		.suffix_length_initialized(suffix_length_initialized),
		.IsRunLoop(IsRunLoop)
		);	
	pc_decoding pc_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.parser_state(parser_state),
		.nal_unit_state(nal_unit_state),
		.slice_header_state(slice_header_state),
		.ref_pic_list_reordering_state(ref_pic_list_reordering_state),
		.dec_ref_pic_marking_state(dec_ref_pic_marking_state),
		.slice_data_state(slice_data_state),
		.sub_mb_pred_state(sub_mb_pred_state),
		.mb_pred_state(mb_pred_state),
		.seq_parameter_set_state(seq_parameter_set_state),
		.pic_parameter_set_state(pic_parameter_set_state),
		.exp_golomb_len(exp_golomb_len),
		.dependent_variable_len(dependent_variable_len),
		.cavlc_consumed_bits_len(cavlc_consumed_bits_len),
		.pc(pc)
		);
	heading_one_detector heading_one_detector (
		.heading_one_en(heading_one_en),
		.BitStream_buffer_output(BitStream_buffer_output),
		.heading_one_pos(heading_one_pos)
		);
	exp_golomb_decoding exp_golomb_decoding (
		.reset_n(reset_n),
		.heading_one_pos(heading_one_pos),
		.BitStream_buffer_output(BitStream_buffer_output),
		.num_ref_idx_l0_active_minus1(num_ref_idx_l0_active_minus1),
		.exp_golomb_decoding_output(exp_golomb_decoding_output),
		.exp_golomb_len(exp_golomb_len),
		.slice_header_state(slice_header_state),
		.slice_data_state(slice_data_state),
		.mb_pred_state(mb_pred_state),
		.sub_mb_pred_state(sub_mb_pred_state), 
		.seq_parameter_set_state(seq_parameter_set_state),
		.pic_parameter_set_state(pic_parameter_set_state)
		);
	dependent_variable_decoding dependent_variable_decoding (
		.slice_header_state(slice_header_state),
		.log2_max_frame_num_minus4(log2_max_frame_num_minus4),
		.log2_max_pic_order_cnt_lsb_minus4(log2_max_pic_order_cnt_lsb_minus4),
		.BitStream_buffer_output(BitStream_buffer_output),
		.dependent_variable_len(dependent_variable_len),
		.dependent_variable_decoding_output(dependent_variable_decoding_output)
		);
	QP_decoding QP_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.slice_header_state(slice_header_state),
		.slice_data_state(slice_data_state),
		.pic_init_qp_minus26(pic_init_qp_minus26),
		.exp_golomb_decoding_output_5to0(exp_golomb_decoding_output[5:0]),
		.chroma_qp_index_offset(chroma_qp_index_offset),
		.QPy(QPy),
		.QPc(QPc)
		);
	CodedBlockPattern_decoding CodedBlockPattern_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.slice_data_state(slice_data_state),
		.slice_type(slice_type),
		.mb_type(mb_type),
		.mb_type_general(mb_type_general),
		.exp_golomb_decoding_output_5to0(exp_golomb_decoding_output[5:0]),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma)
		);
	Intra4x4_PredMode_decoding Intra4x4_PredMode_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.mb_pred_state(mb_pred_state),
		.luma4x4BlkIdx(luma4x4BlkIdx),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.MBTypeGen_mbAddrA(MBTypeGen_mbAddrA),
		.MBTypeGen_mbAddrB_reg(MBTypeGen_mbAddrB_reg),
		.constrained_intra_pred_flag(constrained_intra_pred_flag),
		.rem_intra4x4_pred_mode(rem_intra4x4_pred_mode),
		.prev_intra4x4_pred_mode_flag(prev_intra4x4_pred_mode_flag),
		.Intra4x4PredMode_mbAddrB_dout(Intra4x4PredMode_mbAddrB_dout),
		//pic_num can be wired out for debug purpose
		//.pic_num(pic_num),
		
		.Intra4x4PredMode_CurrMb(Intra4x4_predmode_CurrMb),
		.Intra4x4PredMode_mbAddrB_cs_n(Intra4x4PredMode_mbAddrB_cs_n),
		.Intra4x4PredMode_mbAddrB_wr_n(Intra4x4PredMode_mbAddrB_wr_n),
		.Intra4x4PredMode_mbAddrB_rd_addr(Intra4x4PredMode_mbAddrB_rd_addr),
		.Intra4x4PredMode_mbAddrB_wr_addr(Intra4x4PredMode_mbAddrB_wr_addr),
		.Intra4x4PredMode_mbAddrB_din(Intra4x4PredMode_mbAddrB_din)
		);
	ram_async_1r_sync_1w # (`Intra4x4_PredMode_RF_data_width,`Intra4x4_PredMode_RF_data_depth)
	Intra4x4_PredMode_RF (
		.clk(gclk_Intra4x4PredMode_mbAddrB_RF),
		.rst_n(reset_n),
		.cs_n(Intra4x4PredMode_mbAddrB_cs_n),
		.wr_n(Intra4x4PredMode_mbAddrB_wr_n),
		.rd_addr(Intra4x4PredMode_mbAddrB_rd_addr),
		.wr_addr(Intra4x4PredMode_mbAddrB_wr_addr),
		.data_in(Intra4x4PredMode_mbAddrB_din),
		.data_out(Intra4x4PredMode_mbAddrB_dout)
		);
	Inter_mv_decoding Inter_mv_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.Is_skip_run_entry(Is_skip_run_entry),
		.Is_skip_run_end(Is_skip_run_end),
		.slice_data_state(slice_data_state),
		.mb_pred_state(mb_pred_state),
		.sub_mb_pred_state(sub_mb_pred_state),
		.mvd(mvd),
		.mb_num(mb_num),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.mb_type_general(mb_type_general),
		.sub_mb_type(sub_mb_type),
		.end_of_MB_DEC(end_of_MB_DEC),
		.mbPartIdx(mbPartIdx),
		.subMbPartIdx(subMbPartIdx),
		.compIdx(compIdx),
		.MBTypeGen_mbAddrA(MBTypeGen_mbAddrA),
		.MBTypeGen_mbAddrB_reg(MBTypeGen_mbAddrB_reg),
		.MBTypeGen_mbAddrD(MBTypeGen_mbAddrD),
		.mvx_mbAddrB_dout(mvx_mbAddrB_dout),
		.mvy_mbAddrB_dout(mvy_mbAddrB_dout),
		.mvx_mbAddrC_dout(mvx_mbAddrC_dout),
		.mvy_mbAddrC_dout(mvy_mbAddrC_dout),
		.mv_mbAddrB_rd_for_DF(mv_mbAddrB_rd_for_DF),
		
		.skip_mv_calc(skip_mv_calc),
		.Is_skipMB_mv_calc(Is_skipMB_mv_calc),
		.mvx_mbAddrA(mvx_mbAddrA),
		.mvy_mbAddrA(mvy_mbAddrA),
		.mvx_mbAddrB_cs_n(mvx_mbAddrB_cs_n),
		.mvx_mbAddrB_wr_n(mvx_mbAddrB_wr_n),
		.mvx_mbAddrB_rd_addr(mvx_mbAddrB_rd_addr),
		.mvx_mbAddrB_wr_addr(mvx_mbAddrB_wr_addr),
		.mvx_mbAddrB_din(mvx_mbAddrB_din),
		.mvy_mbAddrB_cs_n(mvy_mbAddrB_cs_n),
		.mvy_mbAddrB_wr_n(mvy_mbAddrB_wr_n),
		.mvy_mbAddrB_rd_addr(mvy_mbAddrB_rd_addr),
		.mvy_mbAddrB_wr_addr(mvy_mbAddrB_wr_addr),
		.mvy_mbAddrB_din(mvy_mbAddrB_din),
		.mvx_mbAddrC_cs_n(mvx_mbAddrC_cs_n),
		.mvx_mbAddrC_wr_n(mvx_mbAddrC_wr_n),
		.mvx_mbAddrC_rd_addr(mvx_mbAddrC_rd_addr),
		.mvx_mbAddrC_wr_addr(mvx_mbAddrC_wr_addr),
		.mvx_mbAddrC_din(mvx_mbAddrC_din),
		.mvy_mbAddrC_cs_n(mvy_mbAddrC_cs_n),
		.mvy_mbAddrC_wr_n(mvy_mbAddrC_wr_n),
		.mvy_mbAddrC_rd_addr(mvy_mbAddrC_rd_addr),
		.mvy_mbAddrC_wr_addr(mvy_mbAddrC_wr_addr),
		.mvy_mbAddrC_din(mvy_mbAddrC_din),
		.mv_is16x16(mv_is16x16),
		.mvx_CurrMb0(mvx_CurrMb0),
		.mvx_CurrMb1(mvx_CurrMb1),
		.mvx_CurrMb2(mvx_CurrMb2),
		.mvx_CurrMb3(mvx_CurrMb3),
		.mvy_CurrMb0(mvy_CurrMb0),
		.mvy_CurrMb1(mvy_CurrMb1),
		.mvy_CurrMb2(mvy_CurrMb2),
		.mvy_CurrMb3(mvy_CurrMb3)
		);
	ram_async_1r_sync_1w # (`mvx_mbAddrB_RF_data_width,`mvx_mbAddrB_RF_data_depth)
	mvx_mbAddrB_RF (
		.clk(gclk_mvx_mbAddrB_RF), 
		.rst_n(reset_n), 
		.cs_n(mvx_mbAddrB_cs_n),
		.wr_n(mvx_mbAddrB_wr_n),
		.rd_addr(mvx_mbAddrB_rd_addr),
		.wr_addr(mvx_mbAddrB_wr_addr),
		.data_in(mvx_mbAddrB_din),
		.data_out(mvx_mbAddrB_dout)
		);
	ram_async_1r_sync_1w # (`mvy_mbAddrB_RF_data_width,`mvy_mbAddrB_RF_data_depth)
	mvy_mbAddrB_RF (
		.clk(gclk_mvy_mbAddrB_RF),
		.rst_n(reset_n),
		.cs_n(mvy_mbAddrB_cs_n), 
		.wr_n(mvy_mbAddrB_wr_n),
		.rd_addr(mvy_mbAddrB_rd_addr),
		.wr_addr(mvy_mbAddrB_wr_addr),
		.data_in(mvy_mbAddrB_din),
		.data_out(mvy_mbAddrB_dout)
		);
	ram_async_1r_sync_1w # (`mvx_mbAddrC_RF_data_width,`mvx_mbAddrC_RF_data_depth)
	mvx_mbAddrC_RF (
		.clk(gclk_mvx_mbAddrC_RF),
		.rst_n(reset_n),
		.cs_n(mvx_mbAddrC_cs_n),
		.wr_n(mvx_mbAddrC_wr_n),
		.rd_addr(mvx_mbAddrC_rd_addr),
		.wr_addr(mvx_mbAddrC_wr_addr),
		.data_in(mvx_mbAddrC_din),
		.data_out(mvx_mbAddrC_dout)
		);
	ram_async_1r_sync_1w # (`mvy_mbAddrC_RF_data_width,`mvy_mbAddrC_RF_data_depth)
	mvy_mbAddrC_RF (
		.clk(gclk_mvy_mbAddrC_RF),
		.rst_n(reset_n),
		.cs_n(mvy_mbAddrC_cs_n),
		.wr_n(mvy_mbAddrC_wr_n),
		.rd_addr(mvy_mbAddrC_rd_addr),
		.wr_addr(mvy_mbAddrC_wr_addr),
		.data_in(mvy_mbAddrC_din),
		.data_out(mvy_mbAddrC_dout)
		);
	syntax_decoding syntax_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.end_of_MB_DEC(end_of_MB_DEC),
		.pin_disable_DF(pin_disable_DF),
		.parser_state(parser_state),
		.nal_unit_state(nal_unit_state),
		.seq_parameter_set_state(seq_parameter_set_state),
		.pic_parameter_set_state(pic_parameter_set_state),
		.slice_header_state(slice_header_state),
		.slice_data_state(slice_data_state),
		.mb_pred_state(mb_pred_state),
		.sub_mb_pred_state(sub_mb_pred_state),
		.exp_golomb_decoding_output(exp_golomb_decoding_output),
		.BitStream_buffer_output(BitStream_buffer_output),
		.dependent_variable_decoding_output(dependent_variable_decoding_output),
		.mbPartIdx(mbPartIdx),
		
		.nal_unit_type(nal_unit_type),
		.start_code_prefix_found(start_code_prefix_found),
		.deblocking_filter_control_present_flag(deblocking_filter_control_present_flag),
		.disable_deblocking_filter_idc(disable_deblocking_filter_idc),
		.disable_DF(disable_DF),
		.slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
		.slice_beta_offset_div2(slice_beta_offset_div2),
		.mb_skip_run(mb_skip_run),
		.NumMbPart(NumMbPart),
		.NumSubMbPart(NumSubMbPart),
		.MBTypeGen_mbAddrA(MBTypeGen_mbAddrA),
		.MBTypeGen_mbAddrD(MBTypeGen_mbAddrD),
		.MBTypeGen_mbAddrB_reg(MBTypeGen_mbAddrB_reg),
		.log2_max_frame_num_minus4(log2_max_frame_num_minus4),
		.log2_max_pic_order_cnt_lsb_minus4(log2_max_pic_order_cnt_lsb_minus4),
		.constrained_intra_pred_flag(constrained_intra_pred_flag),
		.num_ref_idx_active_override_flag(num_ref_idx_active_override_flag),
		.num_ref_idx_l0_active_minus1(num_ref_idx_l0_active_minus1),
		.slice_type(slice_type),
		.mb_type(mb_type),
		.mb_type_general(mb_type_general),
		.Intra16x16_predmode(Intra16x16_predmode),
		.intra_chroma_pred_mode(Intra_chroma_predmode),
		.sub_mb_type(sub_mb_type),
		.pic_init_qp_minus26(pic_init_qp_minus26),
		.chroma_qp_index_offset(chroma_qp_index_offset),
		.rem_intra4x4_pred_mode(rem_intra4x4_pred_mode),
		.prev_intra4x4_pred_mode_flag(prev_intra4x4_pred_mode_flag),
		.mvd(mvd),
		.mv_below8x8(mv_below8x8)
		);
	cavlc_decoder cavlc_decoder(
		.clk(clk),
		.reset_n(reset_n),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.gclk_LumaLevel_mbAddrB_RF(gclk_LumaLevel_mbAddrB_RF),
		.gclk_ChromaLevel_Cb_mbAddrB_RF(gclk_ChromaLevel_Cb_mbAddrB_RF),
		.gclk_ChromaLevel_Cr_mbAddrB_RF(gclk_ChromaLevel_Cr_mbAddrB_RF),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.i8x8(i8x8),
		.i4x4(i4x4),
		.i4x4_CbCr(i4x4_CbCr),
		.i_level(i_level),
		.i_run(i_run),
		.i_TotalCoeff(i_TotalCoeff),
		.coeffNum(coeffNum),
		.heading_one_pos(heading_one_pos),
		.BitStream_buffer_output(BitStream_buffer_output),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.suffix_length_initialized(suffix_length_initialized),
		.IsRunLoop(IsRunLoop),
		
		.Luma_8x8_AllZeroCoeff_mbAddrA(Luma_8x8_AllZeroCoeff_mbAddrA),
		.LumaLevel_mbAddrA(LumaLevel_mbAddrA),
		.LumaLevel_CurrMb0(LumaLevel_CurrMb0),
		.LumaLevel_CurrMb1(LumaLevel_CurrMb1),
		.LumaLevel_CurrMb2(LumaLevel_CurrMb2),
		.LumaLevel_CurrMb3(LumaLevel_CurrMb3),
		.LumaLevel_mbAddrB_dout(LumaLevel_mbAddrB_dout),
		.LumaLevel_mbAddrB_cs_n(LumaLevel_mbAddrB_cs_n),
		.ChromaLevel_Cb_mbAddrB_cs_n(ChromaLevel_Cb_mbAddrB_cs_n),
		.ChromaLevel_Cr_mbAddrB_cs_n(ChromaLevel_Cr_mbAddrB_cs_n),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC),
		.cavlc_consumed_bits_len(cavlc_consumed_bits_len),
		.TotalCoeff(TotalCoeff),
		.TrailingOnes(TrailingOnes),
		.maxNumCoeff(maxNumCoeff),
		.zerosLeft(zerosLeft),
		.run(run),
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
		.coeffLevel_15(coeffLevel_15)
		);
	bs_decoding bs_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.gclk_bs_dec(gclk_bs_dec),
		.end_of_MB_DEC(end_of_MB_DEC),
		.end_of_one_blk4x4_sum(end_of_one_blk4x4_sum),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.disable_DF(disable_DF),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.mb_type_general(mb_type_general),
		.slice_data_state(slice_data_state),
		.residual_state(residual_state),
		.MBTypeGen_mbAddrA(MBTypeGen_mbAddrA),
		.MBTypeGen_mbAddrB_reg(MBTypeGen_mbAddrB_reg),
		.end_of_one_residual_block(end_of_one_residual_block),
		.TotalCoeff(TotalCoeff),
		.curr_DC_IsZero(curr_DC_IsZero),
		.Is_skipMB_mv_calc(Is_skipMB_mv_calc),
		.mvx_mbAddrA(mvx_mbAddrA),
		.mvy_mbAddrA(mvy_mbAddrA),
		.mvx_mbAddrB_dout(mvx_mbAddrB_dout),
		.mvy_mbAddrB_dout(mvy_mbAddrB_dout),
		.mvx_CurrMb0(mvx_CurrMb0),
		.mvx_CurrMb1(mvx_CurrMb1),
		.mvx_CurrMb2(mvx_CurrMb2),
		.mvx_CurrMb3(mvx_CurrMb3),
		.mvy_CurrMb0(mvy_CurrMb0),
		.mvy_CurrMb1(mvy_CurrMb1),
		.mvy_CurrMb2(mvy_CurrMb2),
		.mvy_CurrMb3(mvy_CurrMb3),
		
		.bs_dec_counter(bs_dec_counter),
		.end_of_BS_DEC(end_of_BS_DEC),
		.mv_mbAddrB_rd_for_DF(mv_mbAddrB_rd_for_DF),
		.bs_V0(bs_V0),
		.bs_V1(bs_V1),
		.bs_V2(bs_V2),
		.bs_V3(bs_V3),
		.bs_H0(bs_H0),
		.bs_H1(bs_H1),
		.bs_H2(bs_H2),
		.bs_H3(bs_H3)
		);
endmodule
	
	