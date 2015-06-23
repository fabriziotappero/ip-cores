//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : BitStream_parser_FSM_gating.v
// Generated : June 26,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// BitStream_parser_FSM,clock gating version
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module BitStream_parser_FSM (clk,reset_n,end_of_one_blk4x4_sum,end_of_MB_DEC,
	gclk_parser,gclk_nal,gclk_slice,gclk_sps,gclk_pps,gclk_slice_header,
	gclk_slice_data,gclk_residual,gclk_cavlc,
	trigger_CAVLC,BitStream_buffer_valid_n,nal_unit_type,
	slice_type,num_ref_idx_active_override_flag,
	deblocking_filter_control_present_flag,disable_deblocking_filter_idc,
	mb_skip_run,mb_type_general,prev_intra4x4_pred_mode_flag,CodedBlockPatternLuma,
	CodedBlockPatternChroma,pc_2to0,NumSubMbPart,NumMbPart,
	TotalCoeff,TrailingOnes,maxNumCoeff,zerosLeft,run,
	
	parser_state,nal_unit_state,slice_layer_wo_partitioning_state,slice_header_state,slice_header_s6,
	ref_pic_list_reordering_state,dec_ref_pic_marking_state,slice_data_state,sub_mb_pred_state,
	mb_pred_state,seq_parameter_set_state,pic_parameter_set_state,residual_state,cavlc_decoder_state,
	heading_one_en,pic_num,mb_num,mb_num_h,mb_num_v,
	NextMB_IsSkip,LowerMB_IsSkip,Is_skip_run_entry,Is_skip_run_end,
	luma4x4BlkIdx,mbPartIdx,subMbPartIdx,compIdx,i8x8,i4x4,i4x4_CbCr,
	coeffNum,i_level,i_run,i_TotalCoeff,
	suffix_length_initialized,IsRunLoop);
	input clk;
	input reset_n;
	input end_of_one_blk4x4_sum;
	input end_of_MB_DEC;
	input gclk_parser;
	input gclk_nal;
	input gclk_slice;
	input gclk_sps;
	input gclk_pps;
	input gclk_slice_header;
	input gclk_slice_data;
	input gclk_residual;
	input gclk_cavlc;
	input trigger_CAVLC;
	input BitStream_buffer_valid_n;
	input [4:0] nal_unit_type;
	input [2:0] slice_type;
	input num_ref_idx_active_override_flag;
	input deblocking_filter_control_present_flag;
	input [1:0] disable_deblocking_filter_idc;
	input [6:0] mb_skip_run;
	input [3:0] mb_type_general;
	input prev_intra4x4_pred_mode_flag;
	input [3:0] CodedBlockPatternLuma;
	input [1:0] CodedBlockPatternChroma;
	input [2:0] pc_2to0;
	input [2:0] NumMbPart;
	input [2:0] NumSubMbPart;
	input [4:0] TotalCoeff;
	input [1:0] TrailingOnes;
	input [4:0] maxNumCoeff;
	input [3:0] zerosLeft;
	input [3:0] run;
	
	output [1:0] parser_state;
	output [2:0] nal_unit_state;
	output [1:0] slice_layer_wo_partitioning_state;
	output [3:0] slice_header_state; 
	output slice_header_s6;
	output [2:0] ref_pic_list_reordering_state;
	output [1:0] dec_ref_pic_marking_state;
	output [3:0] slice_data_state;
	output [1:0] sub_mb_pred_state;
	output [2:0] mb_pred_state;
	output [3:0] seq_parameter_set_state;
	output [3:0] pic_parameter_set_state;
	output [3:0] residual_state;
	output [3:0] cavlc_decoder_state;
	output heading_one_en;
	output [5:0] pic_num;
	output [6:0] mb_num;
	output [3:0] mb_num_h;
	output [3:0] mb_num_v;
	output NextMB_IsSkip;
	output LowerMB_IsSkip;
	output Is_skip_run_entry;
	output Is_skip_run_end;
	output [3:0] luma4x4BlkIdx;
	output [1:0] mbPartIdx;
	output [1:0] subMbPartIdx;
	output compIdx;
	output [1:0] i8x8,i4x4;
	output [1:0] i4x4_CbCr;
	output [3:0] coeffNum;
	output [3:0] i_level;
	output [3:0] i_run;
	output [3:0] i_TotalCoeff;
	output suffix_length_initialized;
	output IsRunLoop;
	
	reg [1:0] parser_state;
	reg [2:0] nal_unit_state;
	reg [1:0] slice_layer_wo_partitioning_state;
	reg [3:0] seq_parameter_set_state;
	reg [3:0] pic_parameter_set_state;
	reg [3:0] slice_header_state;
	reg [2:0] ref_pic_list_reordering_state;
 	reg [1:0] dec_ref_pic_marking_state;
	reg [3:0] slice_data_state;
	reg [2:0] mb_pred_state;
	reg [1:0] sub_mb_pred_state;
	reg [3:0] residual_state;
	reg [3:0] cavlc_decoder_state;
	
	wire heading_one_en;
	reg [6:0] mb_num;
	reg [3:0] mb_num_h;
	reg [3:0] mb_num_v;
	reg [1:0] mbPartIdx;
	reg [1:0] subMbPartIdx;
	reg compIdx;
	reg	[1:0] i8x8,i4x4;
	reg [1:0] i4x4_CbCr;
	reg [3:0] coeffNum;
	reg [3:0] coeffNum_reg;
	reg [3:0] i_level,i_run,i_TotalCoeff;
	reg [6:0] count_mb_skip_run;//number of MBs to be skipped
	reg [7:0] count_pcm_byte;
	reg [3:0] luma4x4BlkIdx;
	reg [5:0] pic_num;
	reg suffix_length_initialized;
	reg IsRunLoop;
	
	/*
	// synopsys translate_off
	integer	tracefile;
	initial
		begin
			tracefile = $fopen("trace.txt");
		end
	// synopsys translate_on
	*/

	//--------------
	//parser_state
	//--------------
	always @ (posedge gclk_parser or negedge reset_n)
		if (reset_n == 0)
			parser_state <= `rst_parser;
		else
			case (parser_state)
				`rst_parser			  :parser_state <= (BitStream_buffer_valid_n == 1'b0)? `start_code_prefix:`rst_parser;
				`start_code_prefix:parser_state <= `nal_unit;
				`nal_unit			    :parser_state <= `rst_parser;
			endcase
	//---------------
	//nal_unit_state
	//---------------
	always @ (posedge gclk_nal or negedge reset_n)
		if (reset_n == 0)
			nal_unit_state <= `rst_nal_unit;
		else
			case (nal_unit_state)
				`rst_nal_unit:nal_unit_state <= `forbidden_zero_bit_2_nal_unit_type;
				`forbidden_zero_bit_2_nal_unit_type:
				case (nal_unit_type)
					5'b00001:nal_unit_state <= `slice_layer_non_IDR_rbsp;
					5'b00101:nal_unit_state <= `slice_layer_IDR_rbsp;
					5'b00111:nal_unit_state <= `seq_parameter_set_rbsp;
					5'b01000:nal_unit_state <= `pic_parameter_set_rbsp;
				endcase
				`slice_layer_non_IDR_rbsp,`slice_layer_IDR_rbsp:nal_unit_state <= `rbsp_trailing_one_bit;
				`seq_parameter_set_rbsp :nal_unit_state <= `rbsp_trailing_one_bit;
				`pic_parameter_set_rbsp :nal_unit_state <= `rbsp_trailing_one_bit; 
				`rbsp_trailing_one_bit  :nal_unit_state <= (pc_2to0 == 3'b000)? `rst_nal_unit:`rbsp_trailing_zero_bits;
				`rbsp_trailing_zero_bits:nal_unit_state <= `rst_nal_unit;
			endcase
	//----------------------------------
	//slice_layer_wo_partitioning_state
	//----------------------------------
	always @ (posedge gclk_slice or negedge reset_n)
		if (reset_n == 1'b0)
			slice_layer_wo_partitioning_state <= `rst_slice_layer_wo_partitioning;
		else
			case (slice_layer_wo_partitioning_state)
				`rst_slice_layer_wo_partitioning	:slice_layer_wo_partitioning_state <= `slice_header;
				`slice_header					            :slice_layer_wo_partitioning_state <= `slice_data;
				`slice_data						            :slice_layer_wo_partitioning_state <= `rst_slice_layer_wo_partitioning;
			endcase
	//------------------------
	//seq_parameter_set_state
	//------------------------
	always @ (posedge gclk_sps or negedge reset_n)
		if (reset_n == 0)
			seq_parameter_set_state <= `rst_seq_parameter_set;
		else
			case (seq_parameter_set_state)
				`rst_seq_parameter_set					          :seq_parameter_set_state <= `fixed_header;
				`fixed_header							                :seq_parameter_set_state <= `level_idc_s;
				`level_idc_s								              :seq_parameter_set_state <= `seq_parameter_set_id_sps_s;
				`seq_parameter_set_id_sps_s				        :seq_parameter_set_state <= `log2_max_frame_num_minus4_s;
				`log2_max_frame_num_minus4_s				      :seq_parameter_set_state <= `pic_order_cnt_type_s;
				`pic_order_cnt_type_s					            :seq_parameter_set_state <= `log2_max_pic_order_cnt_lsb_minus4_s;
				`log2_max_pic_order_cnt_lsb_minus4_s		  :seq_parameter_set_state <= `num_ref_frames_s;
				`num_ref_frames_s						              :seq_parameter_set_state <= `gaps_in_frame_num_value_allowed_flag_s;
				`gaps_in_frame_num_value_allowed_flag_s	  :seq_parameter_set_state <= `pic_width_in_mbs_minus1_s;
				`pic_width_in_mbs_minus1_s				        :seq_parameter_set_state <= `pic_height_in_map_units_minus1_s;
				`pic_height_in_map_units_minus1_s		      :seq_parameter_set_state <= `frame_mbs_only_flag_2_frame_cropping_flag;
				`frame_mbs_only_flag_2_frame_cropping_flag:seq_parameter_set_state <= `vui_parameter_present_flag_s;
				`vui_parameter_present_flag_s			        :seq_parameter_set_state <= `rst_seq_parameter_set;
			endcase
	//------------------------
	//pic_parameter_set_state
	//------------------------
	always @ (posedge gclk_pps or negedge reset_n)
		if (reset_n == 0)
			pic_parameter_set_state <= `rst_pic_parameter_set;
		else
			case (pic_parameter_set_state)
				`rst_pic_parameter_set				                             :pic_parameter_set_state <= `pic_parameter_set_id_pps_s;
				`pic_parameter_set_id_pps_s			                           :pic_parameter_set_state <= `seq_parameter_set_id_pps_s;
				`seq_parameter_set_id_pps_s			                           :pic_parameter_set_state <= `entropy_coding_mode_flag_2_pic_order_present_flag;
				`entropy_coding_mode_flag_2_pic_order_present_flag         :pic_parameter_set_state <= `num_slice_groups_minus1_s;
				`num_slice_groups_minus1_s			                           :pic_parameter_set_state <= `num_ref_idx_l0_active_minus1_pps_s;
				`num_ref_idx_l0_active_minus1_pps_s	                       :pic_parameter_set_state <= `num_ref_idx_l1_active_minus1_pps_s;
				`num_ref_idx_l1_active_minus1_pps_s	                       :pic_parameter_set_state <= `weighted_pred_flag_2_weighted_bipred_idc;
				`weighted_pred_flag_2_weighted_bipred_idc                  :pic_parameter_set_state <= `pic_init_qp_minus26_s;
				`pic_init_qp_minus26_s				                             :pic_parameter_set_state <= `pic_init_qs_minus26_s;
				`pic_init_qs_minus26_s				                             :pic_parameter_set_state <= `chroma_qp_index_offset_s;
				`chroma_qp_index_offset_s			                             :pic_parameter_set_state <= `deblocking_filter_control_2_redundant_pic_cnt_present_flag;
				`deblocking_filter_control_2_redundant_pic_cnt_present_flag:pic_parameter_set_state <= `rst_pic_parameter_set;
			endcase
	//-------------------
	//slice_header_state
	//-------------------
	always @ (posedge gclk_slice_header or negedge reset_n)
		if (reset_n == 0)
			begin
				slice_header_state            <= `rst_slice_header;
				ref_pic_list_reordering_state <= `rst_ref_pic_list_reordering;
				dec_ref_pic_marking_state     <= `rst_dec_ref_pic_marking;
			end
		else
			case (slice_header_state)
				`rst_slice_header                   :slice_header_state <= `first_mb_in_slice_s;
				`first_mb_in_slice_s                :slice_header_state <= `slice_type_s;
				`slice_type_s                       :slice_header_state <= `pic_parameter_set_id_slice_header_s;
				`pic_parameter_set_id_slice_header_s:slice_header_state <= `frame_num_s;
				`frame_num_s:
				if (nal_unit_type == 5'b00101)	     slice_header_state <= `idr_pic_id_s;
				else							                   slice_header_state <= `pic_order_cnt_lsb_s;
				`idr_pic_id_s                       :slice_header_state <= `pic_order_cnt_lsb_s;
				`pic_order_cnt_lsb_s:
				if (slice_type == 3'b101) 	         slice_header_state <= `num_ref_idx_active_override_flag_s;
				else						                     slice_header_state <= `dec_ref_pic_marking;
				`num_ref_idx_active_override_flag_s:
				if (num_ref_idx_active_override_flag == 1'b1) slice_header_state <= `num_ref_idx_l0_active_minus1_slice_header_s;
				else                                          slice_header_state <= `ref_pic_list_reordering;
				`num_ref_idx_l0_active_minus1_slice_header_s :slice_header_state <= `ref_pic_list_reordering;
				`ref_pic_list_reordering:
				case (ref_pic_list_reordering_state)
					`rst_ref_pic_list_reordering:
					if (slice_type == 3'b101)
						ref_pic_list_reordering_state <= `ref_pic_list_reordering_flag_l0_s;
					else
						begin
							ref_pic_list_reordering_state <= `rst_ref_pic_list_reordering;
							slice_header_state            <= `dec_ref_pic_marking;
						end
					`ref_pic_list_reordering_flag_l0_s:
					begin
						ref_pic_list_reordering_state <= `rst_ref_pic_list_reordering;
						slice_header_state            <= `dec_ref_pic_marking;
					end
				endcase
				`dec_ref_pic_marking:
				case (dec_ref_pic_marking_state)
					`rst_dec_ref_pic_marking:
					dec_ref_pic_marking_state <= (nal_unit_type == 3'b101)? `no_output_of_prior_pics_flag_2_long_term_reference_flag:`adaptive_ref_pic_marking_mode_flag_s;
					`no_output_of_prior_pics_flag_2_long_term_reference_flag:
					begin
						dec_ref_pic_marking_state <= `rst_dec_ref_pic_marking;
						slice_header_state        <= `slice_qp_delta_s;
					end
					`adaptive_ref_pic_marking_mode_flag_s:
					begin
						dec_ref_pic_marking_state <= `rst_dec_ref_pic_marking;
						slice_header_state        <= `slice_qp_delta_s;
					end
				endcase
				`slice_qp_delta_s:
				slice_header_state <= (deblocking_filter_control_present_flag == 1'b1)? `disable_deblocking_filter_idc_s:`rst_slice_header;
				`disable_deblocking_filter_idc_s:
				slice_header_state <= (disable_deblocking_filter_idc != 2'b01)? `slice_alpha_c0_offset_div2_s:`rst_slice_header;
				`slice_alpha_c0_offset_div2_s:slice_header_state <= `slice_beta_offset_div2_s;
				`slice_beta_offset_div2_s	   :slice_header_state <= `rst_slice_header;
			endcase
	
	assign slice_header_s6 = (slice_header_state == `frame_num_s)? 1'b1:1'b0;
	//------------------
	//slice_data_state
	//------------------
	reg  Is_skip_run_entry;	//for trigger inter pred.Originally it's a wire type which will trigger inter_pred signal too early
							            //than expected:cause inter_pred rise up before mv_below8x8 is set to 4'b0 for P_skip.Thus the 
							            //preload_counter after inter_pred will sample wrong mv_below8x8/mv_below8x8_curr.
							            //Then it is changed to reg type to appear one cycle later @ May 15,2006
	wire Is_skip_run_end;   //for stop triggering inter pred 
		
	always @ (posedge clk)
		if (reset_n == 1'b0)
			Is_skip_run_entry <= 1'b0;
		else if (slice_data_state == `mb_skip_run_s && mb_skip_run != 0)
			Is_skip_run_entry <= 1'b1;
		else 
			Is_skip_run_entry <= 1'b0;
			
	assign Is_skip_run_end = (slice_data_state == `skip_run_duration && end_of_MB_DEC && (mb_num == 98 || count_mb_skip_run == (mb_skip_run - 1)))? 1'b1:1'b0;
			
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 0)
			begin
				slice_data_state 	<= `rst_slice_data;
				mb_pred_state 		<= `rst_mb_pred;
				sub_mb_pred_state <= `rst_sub_mb_pred;
			end
		else
			case (slice_data_state)
				`rst_slice_data   :slice_data_state <= (slice_type != 3'b111)? `mb_skip_run_s:`mb_type_s; 
				`mb_skip_run_s    :slice_data_state <= (mb_skip_run == 0)? `mb_type_s:`skip_run_duration;
				`skip_run_duration:slice_data_state <= (mb_num == 98)? `rst_slice_data:(count_mb_skip_run < (mb_skip_run - 1))? `skip_run_duration:`mb_type_s;
				`mb_type_s        :slice_data_state <= (mb_type_general == `MB_P_8x8 || mb_type_general == `MB_P_8x8ref0)? `sub_mb_pred:`mb_pred;
				`sub_mb_pred:
				case (sub_mb_pred_state)
					`rst_sub_mb_pred:sub_mb_pred_state <= `sub_mb_type_s;
					`sub_mb_type_s	:sub_mb_pred_state <= (mbPartIdx == 2'b11)? `sub_mvd_l0_s:`sub_mb_type_s; 
					`sub_mvd_l0_s:
					if (mbPartIdx == 2'b11 && {1'b0,subMbPartIdx} == (NumSubMbPart - 1) && compIdx == 1'b1)
						begin
							sub_mb_pred_state <= `rst_sub_mb_pred;
							slice_data_state  <= `coded_block_pattern_s;
						end
				endcase
				`mb_pred:
				case (mb_pred_state)
					`rst_mb_pred:
					if (mb_type_general[3] == 1'b1) //Intra
						mb_pred_state <= (mb_type_general == `MB_Intra4x4)? `prev_intra4x4_pred_mode_flag_s:`intra_chroma_pred_mode_s;
					else
						mb_pred_state  <= `mvd_l0_s;
					`prev_intra4x4_pred_mode_flag_s:
					mb_pred_state <= (prev_intra4x4_pred_mode_flag == 1'b0)? `rem_intra4x4_pred_mode_s:
									 (luma4x4BlkIdx == 4'b1111)? `intra_chroma_pred_mode_s:`prev_intra4x4_pred_mode_flag_s; 
					`rem_intra4x4_pred_mode_s:
					mb_pred_state <= (luma4x4BlkIdx == 4'b1111)? `intra_chroma_pred_mode_s:`prev_intra4x4_pred_mode_flag_s; 
					`intra_chroma_pred_mode_s:
					begin
						mb_pred_state    <= `rst_mb_pred;
						slice_data_state <= (mb_type_general[3:2] != 2'b10)? `coded_block_pattern_s:`mb_qp_delta_s;
					end
					`mvd_l0_s:
					if ({1'b0,mbPartIdx} == (NumMbPart - 1) && compIdx == 1'b1)
						begin
							mb_pred_state    <= `rst_mb_pred;
							slice_data_state <= `coded_block_pattern_s;
						end
				endcase
				`coded_block_pattern_s:slice_data_state <= (CodedBlockPatternLuma == 0 && CodedBlockPatternChroma == 0)? `residual:`mb_qp_delta_s;
				`mb_qp_delta_s:
				slice_data_state <= (CodedBlockPatternLuma == 0 && CodedBlockPatternChroma == 0 && mb_type_general[3:2] != 2'b10)? `mb_num_update:`residual;
				`residual:slice_data_state <= `mb_num_update;
				`mb_num_update:slice_data_state <= `rst_slice_data;
			endcase
	//---------------
	//residual_state
	//---------------
	always @ (posedge gclk_residual or negedge reset_n)
		if (reset_n == 1'b0)
			residual_state <= `rst_residual;
		else
			case (residual_state)
				`rst_residual:
				if (mb_type_general[3] == 1'b1 && mb_type_general != `MB_Intra4x4)//Intra16x16
					residual_state <= `Intra16x16DCLevel_s;
				else
					residual_state <= (CodedBlockPatternLuma == 0)? `LumaLevel_0_s:`LumaLevel_s; 
				`Intra16x16DCLevel_s:residual_state <= (CodedBlockPatternLuma == 0)? `Intra16x16ACLevel_0_s:`Intra16x16ACLevel_s;
				`Intra16x16ACLevel_s,`Intra16x16ACLevel_0_s,`LumaLevel_s,`LumaLevel_0_s:
				residual_state <= (CodedBlockPatternChroma == 0)? `ChromaACLevel_0_s:`ChromaDCLevel_Cb_s;
				`ChromaDCLevel_Cb_s:residual_state <= `ChromaDCLevel_Cr_s;    
				`ChromaDCLevel_Cr_s:residual_state <= (CodedBlockPatternChroma == 2'b01)? `ChromaACLevel_0_s:`ChromaACLevel_Cb_s;
				`ChromaACLevel_Cb_s:residual_state <= `ChromaACLevel_Cr_s;	
				`ChromaACLevel_Cr_s:residual_state <= `rst_residual;
				`ChromaACLevel_0_s :residual_state <= `rst_residual;
			endcase
	//--------------------
	//cavlc_decoder_state
	//--------------------
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			cavlc_decoder_state <= `rst_cavlc_decoder;
		else
			case (cavlc_decoder_state)
				`rst_cavlc_decoder	:cavlc_decoder_state <= `nAnB_decoding_s;
				`nAnB_decoding_s		:cavlc_decoder_state <= `nC_decoding_s;
				`nC_decoding_s		:cavlc_decoder_state <= `NumCoeffTrailingOnes_LUT;
				`NumCoeffTrailingOnes_LUT://add trigger_CAVLC to trap a special case:after all-zero CrDC2x2 CAVLC decoding.
										              //Without adding trigger_CAVLC here,the gclk_cavlc can not catch trigger_CAVLC
										              //because it rises up too early (rise up at NumCoeffTrailingOnes_LUT instead of rst_cavlc_decoder)
				cavlc_decoder_state <= (TotalCoeff == 0)? ((trigger_CAVLC)? `nAnB_decoding_s:`rst_cavlc_decoder):(TrailingOnes == 0)? `LevelPrefix:`TrailingOnesSignFlag; 
				`TrailingOnesSignFlag:cavlc_decoder_state <= (TotalCoeff == {3'b0,TrailingOnes})?`total_zeros_LUT:`LevelPrefix;
				`LevelPrefix         :cavlc_decoder_state <= `LevelSuffix;
				`LevelSuffix         :cavlc_decoder_state <= ({1'b0,i_level} == TotalCoeff-1)? ((TotalCoeff == maxNumCoeff)?`LevelRunCombination:`total_zeros_LUT):`LevelPrefix;
				`total_zeros_LUT	   :cavlc_decoder_state <= (TotalCoeff == 1)? `RunOfZeros:`run_before_LUT; 
				`run_before_LUT	     :cavlc_decoder_state <= `RunOfZeros;
				`RunOfZeros		       :cavlc_decoder_state <= ({1'b0,i_run} == (TotalCoeff - 1) || {1'b0,i_run} == (TotalCoeff - 2) || zerosLeft == 0)? `LevelRunCombination:`run_before_LUT;
				`LevelRunCombination :cavlc_decoder_state <= (i_TotalCoeff == 0)? `rst_cavlc_decoder:`LevelRunCombination;
			endcase
	assign heading_one_en = (
							seq_parameter_set_state == `seq_parameter_set_id_sps_s ||
							seq_parameter_set_state == `log2_max_frame_num_minus4_s ||
							seq_parameter_set_state == `pic_order_cnt_type_s ||
							seq_parameter_set_state == `log2_max_pic_order_cnt_lsb_minus4_s ||
							seq_parameter_set_state == `num_ref_frames_s ||
							seq_parameter_set_state == `pic_width_in_mbs_minus1_s ||
							seq_parameter_set_state == `pic_height_in_map_units_minus1_s ||
							pic_parameter_set_state == `pic_parameter_set_id_pps_s ||
							pic_parameter_set_state == `seq_parameter_set_id_pps_s ||
							pic_parameter_set_state == `num_slice_groups_minus1_s || 
							pic_parameter_set_state == `num_ref_idx_l0_active_minus1_pps_s ||
							pic_parameter_set_state == `num_ref_idx_l1_active_minus1_pps_s ||
							pic_parameter_set_state == `pic_init_qp_minus26_s ||
							pic_parameter_set_state == `pic_init_qs_minus26_s ||
							pic_parameter_set_state == `chroma_qp_index_offset_s ||
							slice_header_state == `first_mb_in_slice_s || 
							slice_header_state == `slice_type_s || 
							slice_header_state == `pic_parameter_set_id_slice_header_s ||
							slice_header_state == `idr_pic_id_s ||
							slice_header_state == `num_ref_idx_l0_active_minus1_slice_header_s ||
							slice_header_state == `slice_qp_delta_s || 
							slice_header_state == `disable_deblocking_filter_idc_s || 
							slice_header_state == `slice_alpha_c0_offset_div2_s || 
							slice_header_state == `slice_beta_offset_div2_s || 
							slice_data_state == `mb_skip_run_s ||
							slice_data_state == `mb_type_s ||
							slice_data_state == `coded_block_pattern_s || 
							slice_data_state == `mb_qp_delta_s || 
							mb_pred_state == `intra_chroma_pred_mode_s || 
							mb_pred_state == `mvd_l0_s ||
							sub_mb_pred_state == `sub_mb_type_s ||
							sub_mb_pred_state == `sub_mvd_l0_s ||
							cavlc_decoder_state == `NumCoeffTrailingOnes_LUT ||
							cavlc_decoder_state == `LevelPrefix || 
							cavlc_decoder_state == `total_zeros_LUT)? 1'b0:1'b1;
	
	//count_mb_skip_run
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			count_mb_skip_run <= 1'b0;
		else if (slice_data_state == `skip_run_duration)
			count_mb_skip_run <= (mb_num == 98)? 0:(count_mb_skip_run < (mb_skip_run - 1))? (count_mb_skip_run + 1):0;
			
	assign NextMB_IsSkip  = (slice_data_state == `skip_run_duration && (count_mb_skip_run < (mb_skip_run - 1)))? 1'b1:1'b0; 
	
	reg LowerMB_IsSkip;
	always @ (slice_data_state or mb_skip_run or count_mb_skip_run)
		if (slice_data_state == `skip_run_duration)
			begin 
				if (mb_skip_run < 13)
					LowerMB_IsSkip <= 1'b0;
				else
					LowerMB_IsSkip <= (count_mb_skip_run < (mb_skip_run - 12))? 1'b1:1'b0;
			end
		else
			LowerMB_IsSkip <= 1'b0;
	
	//mb_num_h
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			mb_num_h <= 0;
		else if (slice_data_state == `skip_run_duration || slice_data_state == `mb_num_update)
			mb_num_h <= (mb_num_h == 10) ? 0:(mb_num_h + 1);
	
	//mb_num_v
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			mb_num_v <= 0;
		else if ((slice_data_state == `skip_run_duration || slice_data_state == `mb_num_update) && mb_num_h == 10)
			mb_num_v <= (mb_num_v == 8) ? 0:(mb_num_v + 1);
	
	//mb_num
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			mb_num <= 0;
		else if (slice_data_state == `skip_run_duration || slice_data_state == `mb_num_update)
			mb_num <= (mb_num == 98)? 0:(mb_num + 1);
			
	//pic_num
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			pic_num <= 0;
		else if ((slice_data_state == `skip_run_duration || slice_data_state == `mb_num_update) && mb_num == 98)
			pic_num <= pic_num + 1;
	
	//luma4x4BlkIdx
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			luma4x4BlkIdx <= 0;
		else
			case (mb_pred_state)
				`prev_intra4x4_pred_mode_flag_s:
				if (prev_intra4x4_pred_mode_flag == 1'b1)
					luma4x4BlkIdx <= (luma4x4BlkIdx == 4'b1111)? 0:(luma4x4BlkIdx + 1);
				`rem_intra4x4_pred_mode_s:luma4x4BlkIdx <= (luma4x4BlkIdx == 4'b1111)? 0:(luma4x4BlkIdx + 1);
			endcase
	
	//mbPartIdx
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			mbPartIdx <= 0;
		else if (mb_pred_state == `mvd_l0_s && compIdx == 1'b1)
			mbPartIdx <= ({1'b0,mbPartIdx} < (NumMbPart-1))? (mbPartIdx + 1):0;
		else if (sub_mb_pred_state == `sub_mb_type_s)
			mbPartIdx <= (mbPartIdx == 2'b11)? 0:(mbPartIdx + 1);
		else if (sub_mb_pred_state == `sub_mvd_l0_s && {1'b0,subMbPartIdx} == NumSubMbPart - 1 && compIdx == 1'b1)
			mbPartIdx <= (mbPartIdx == 2'b11)? 0:(mbPartIdx + 1);
	
	//subMbPartIdx
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			subMbPartIdx <= 0;
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1'b1)
			subMbPartIdx <= ({1'b0,subMbPartIdx} < NumSubMbPart-1)? (subMbPartIdx + 1):0;
	
	//compIdx
	always @ (posedge gclk_slice_data or negedge reset_n)
		if (reset_n == 1'b0)
			compIdx <= 0;
		else if (mb_pred_state == `mvd_l0_s || sub_mb_pred_state == `sub_mvd_l0_s)
			compIdx <= ~ compIdx;
	
	//i8x8
	always @ (posedge clk)
		if (reset_n == 1'b0)
			i8x8 <= 0;
		else if (slice_data_state == `residual && residual_state == `rst_residual && mb_type_general != `MB_Intra16x16_CBPChroma0 && mb_type_general != `MB_Intra16x16_CBPChroma1 && mb_type_general != `MB_Intra16x16_CBPChroma2)
			i8x8 <= 0;
		else if ((residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s) && end_of_one_blk4x4_sum == 1 && i4x4 == 2'b11)
			i8x8 <= (i8x8 == 2'b11)? 0:(i8x8 + 1);
	
	//i4x4
	always @ (posedge clk)
		if (reset_n == 1'b0)
			i4x4 <= 0;
		else if ((residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s) && end_of_one_blk4x4_sum == 1)
			i4x4 <= (i4x4 == 2'b11)? 0:(i4x4 + 1);
			
	//i4x4_CbCr
	always @ (posedge clk)
		if (reset_n == 1'b0)
			i4x4_CbCr <= 0;
		else if ((residual_state == `ChromaACLevel_Cb_s || residual_state == `ChromaACLevel_Cr_s) && end_of_one_blk4x4_sum == 1'b1) 
			i4x4_CbCr <= (i4x4_CbCr == 2'b11)? 0:(i4x4_CbCr + 1);
	
	//suffix_length_initialized
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			suffix_length_initialized <= 1'b0;
		else if (cavlc_decoder_state == `rst_cavlc_decoder)
			suffix_length_initialized <= 1'b0;
		else if (cavlc_decoder_state == `LevelPrefix)
			suffix_length_initialized <= 1'b1;
			
	//i_level
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			i_level <= 0;
		else if (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT)
			i_level <= 0;
		else if (cavlc_decoder_state == `TrailingOnesSignFlag)
			i_level <= i_level + TrailingOnes;
		else if (cavlc_decoder_state == `LevelSuffix && {1'b0,i_level} != (TotalCoeff-1))
			i_level <= i_level + 1;
			
	//i_run
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			i_run <= 0;
		else if (cavlc_decoder_state == `total_zeros_LUT)
			i_run <= 0;
		else if (cavlc_decoder_state == `RunOfZeros && {1'b0,i_run} != (TotalCoeff - 1) && {1'b0,i_run} != (TotalCoeff - 2) && zerosLeft != 0)
			i_run <= i_run + 1;
			
	//i_TotalCoeff
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
		   i_TotalCoeff <= 0;  
		//enter from LevelSuffix
		else if (cavlc_decoder_state == `LevelSuffix && {1'b0,i_level} == (TotalCoeff-1) && TotalCoeff == maxNumCoeff)
		   i_TotalCoeff <= TotalCoeff - 1;
		//enter from RunOfZeros
		else if (cavlc_decoder_state == `RunOfZeros && ({1'b0,i_run} == (TotalCoeff - 1) || {1'b0,i_run} == (TotalCoeff - 2) || zerosLeft == 0))
			i_TotalCoeff <= TotalCoeff - 1;  
		//Inside LevelRunCombination loop
		else if (cavlc_decoder_state == `LevelRunCombination && i_TotalCoeff != 0)
			i_TotalCoeff <= i_TotalCoeff-1; 
	
	//coeffNum
	always @ (cavlc_decoder_state or run or coeffNum_reg)
	   if (cavlc_decoder_state == `nAnB_decoding_s)
	      coeffNum <= 4'b1111;
	   else if (cavlc_decoder_state == `LevelRunCombination)
	      coeffNum <= coeffNum_reg + run + 1;
	   else 
	      coeffNum <= coeffNum_reg;
	    		
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			coeffNum_reg <= 0;
		else 
			coeffNum_reg <= coeffNum;
		
	//IsRunLoop
	always @ (posedge gclk_cavlc or negedge reset_n)
		if (reset_n == 1'b0)
			IsRunLoop <= 0;
		else if (cavlc_decoder_state == `RunOfZeros)
			IsRunLoop <= ({1'b0,i_run} == TotalCoeff - 1 || {1'b0,i_run} == TotalCoeff - 2 || zerosLeft == 0)? 1'b0:1'b1;
			
endmodule
				
				
										
							
					