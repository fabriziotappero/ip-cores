//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : pc_decoding.v
// Generated : June 6, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding program counter for bitstream_buffer
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module pc_decoding (clk,reset_n,parser_state,nal_unit_state,slice_header_state,ref_pic_list_reordering_state,
	dec_ref_pic_marking_state,slice_data_state,sub_mb_pred_state,mb_pred_state,seq_parameter_set_state,
	pic_parameter_set_state,exp_golomb_len,dependent_variable_len,cavlc_consumed_bits_len,
	pc);
	input clk,reset_n;
	input [1:0] parser_state;
	input [2:0] nal_unit_state;
	input [3:0] slice_header_state;
	input [2:0] ref_pic_list_reordering_state;
	input [1:0] dec_ref_pic_marking_state;
	input [3:0] slice_data_state;
	input [1:0] sub_mb_pred_state;
	input [2:0] mb_pred_state;
	input [3:0] seq_parameter_set_state;
	input [3:0] pic_parameter_set_state;
	input [3:0] exp_golomb_len;
	input [3:0] dependent_variable_len;
	input [4:0] cavlc_consumed_bits_len;
	output [6:0] pc;
	reg	[6:0] pc;
	
	reg [2:0] consumed_bits_sel;
	reg [4:0] FixedLen;
		
	always @ (reset_n or parser_state or nal_unit_state or slice_header_state or ref_pic_list_reordering_state or
		dec_ref_pic_marking_state or slice_data_state or sub_mb_pred_state or mb_pred_state or
		seq_parameter_set_state or pic_parameter_set_state)
		if (reset_n == 0)
			consumed_bits_sel <= `rst_consumed_bits_sel; 
		else if (parser_state == `start_code_prefix)
			consumed_bits_sel <= `fixed_length;
		else if (nal_unit_state == `forbidden_zero_bit_2_nal_unit_type)
			consumed_bits_sel <= `fixed_length;
		else if (slice_header_state != `rst_slice_header)
			case (slice_header_state)
				`first_mb_in_slice_s                        :consumed_bits_sel <= `exp_golomb;						 
				`slice_type_s                               :consumed_bits_sel <= `exp_golomb;								 
				`pic_parameter_set_id_slice_header_s        :consumed_bits_sel <= `exp_golomb;
				`frame_num_s                                :consumed_bits_sel <= `dependent_variable;
				`idr_pic_id_s                               :consumed_bits_sel <= `exp_golomb;
				`pic_order_cnt_lsb_s                        :consumed_bits_sel <= `dependent_variable;
				`num_ref_idx_active_override_flag_s         :consumed_bits_sel <= `fixed_length;
				`num_ref_idx_l0_active_minus1_slice_header_s:consumed_bits_sel <= `exp_golomb;
				`ref_pic_list_reordering:
				case (ref_pic_list_reordering_state)
					`ref_pic_list_reordering_flag_l0_s:consumed_bits_sel <= `fixed_length;
					default                           :consumed_bits_sel <= `rst_consumed_bits_sel;
				endcase
				`dec_ref_pic_marking:
				case (dec_ref_pic_marking_state)
					`no_output_of_prior_pics_flag_2_long_term_reference_flag:consumed_bits_sel <= `fixed_length;
					`adaptive_ref_pic_marking_mode_flag_s                   :consumed_bits_sel <= `fixed_length;
					default                                                 :consumed_bits_sel <= `rst_consumed_bits_sel;
				endcase
				`slice_qp_delta_s               :consumed_bits_sel <= `exp_golomb;			 
				`disable_deblocking_filter_idc_s:consumed_bits_sel <= `exp_golomb;			  
				`slice_alpha_c0_offset_div2_s   :consumed_bits_sel <= `exp_golomb;			 
				`slice_beta_offset_div2_s       :consumed_bits_sel <= `exp_golomb;
				default                         :consumed_bits_sel <= `rst_consumed_bits_sel;
			endcase
		else if (slice_data_state != `rst_slice_data)
			case (slice_data_state)
				`mb_skip_run_s           :consumed_bits_sel <= `exp_golomb;	    
				`mb_type_s               :consumed_bits_sel <= `exp_golomb;	  
				`pcm_alignment_zero_bit_s:consumed_bits_sel <= `exp_golomb; 
				`pcm_byte_s              :consumed_bits_sel <= `pcm_alignment;	  
				`sub_mb_pred:
				case (sub_mb_pred_state)
					`rst_sub_mb_pred:consumed_bits_sel <= `rst_consumed_bits_sel;
					default         :consumed_bits_sel <= `exp_golomb;
				endcase
				`mb_pred:
				case (mb_pred_state)
					`prev_intra4x4_pred_mode_flag_s:consumed_bits_sel <= `fixed_length; 
					`rem_intra4x4_pred_mode_s      :consumed_bits_sel <= `fixed_length; 
					`intra_chroma_pred_mode_s      :consumed_bits_sel <= `exp_golomb; 
					`ref_idx_l0_s                  :consumed_bits_sel <= `exp_golomb;
					`mvd_l0_s                      :consumed_bits_sel <= `exp_golomb;
					default                        :consumed_bits_sel <= `rst_consumed_bits_sel;
				endcase
				`coded_block_pattern_s:consumed_bits_sel <= `exp_golomb;	    
				`mb_qp_delta_s        :consumed_bits_sel <= `exp_golomb;	     
				`residual             :consumed_bits_sel <= `cavlc_consumed;
				default               :consumed_bits_sel <= `rst_consumed_bits_sel;
			endcase
		else if (seq_parameter_set_state != `rst_seq_parameter_set)
			case (seq_parameter_set_state)
				`fixed_header                             :consumed_bits_sel <= `fixed_length;
				`level_idc_s                              :consumed_bits_sel <= `fixed_length;
				`seq_parameter_set_id_sps_s               :consumed_bits_sel <= `exp_golomb;                
				`log2_max_frame_num_minus4_s              :consumed_bits_sel <= `exp_golomb;      
				`pic_order_cnt_type_s                     :consumed_bits_sel <= `exp_golomb;      
				`log2_max_pic_order_cnt_lsb_minus4_s			:consumed_bits_sel <= `exp_golomb;    
				`num_ref_frames_s                         :consumed_bits_sel <= `exp_golomb;
				`gaps_in_frame_num_value_allowed_flag_s		:consumed_bits_sel <= `fixed_length;	
				`pic_width_in_mbs_minus1_s                :consumed_bits_sel <= `exp_golomb;      
				`pic_height_in_map_units_minus1_s         :consumed_bits_sel <= `exp_golomb;
				`frame_mbs_only_flag_2_frame_cropping_flag:consumed_bits_sel <= `fixed_length;
				`vui_parameter_present_flag_s             :consumed_bits_sel <= `fixed_length;		
				default                                   :consumed_bits_sel <= `rst_consumed_bits_sel;
			endcase
		else if (pic_parameter_set_state != `rst_pic_parameter_set)
			case (pic_parameter_set_state)
				`pic_parameter_set_id_pps_s                                :consumed_bits_sel <= `exp_golomb;
				`seq_parameter_set_id_pps_s                                :consumed_bits_sel <= `exp_golomb;
				`entropy_coding_mode_flag_2_pic_order_present_flag         :consumed_bits_sel <= `fixed_length;
				`num_slice_groups_minus1_s                                 :consumed_bits_sel <= `exp_golomb;
				`num_ref_idx_l0_active_minus1_pps_s                        :consumed_bits_sel <= `exp_golomb;
				`num_ref_idx_l1_active_minus1_pps_s                        :consumed_bits_sel <= `exp_golomb;
				`weighted_pred_flag_2_weighted_bipred_idc                  :consumed_bits_sel <= `fixed_length;
				`pic_init_qp_minus26_s                                     :consumed_bits_sel <= `exp_golomb;
				`pic_init_qs_minus26_s                                     :consumed_bits_sel <= `exp_golomb;
				`chroma_qp_index_offset_s                                  :consumed_bits_sel <= `exp_golomb;
				`deblocking_filter_control_2_redundant_pic_cnt_present_flag:consumed_bits_sel <= `fixed_length;  
				default                                                    :consumed_bits_sel <= `rst_consumed_bits_sel;
			endcase																										
		else if (nal_unit_state == `rbsp_trailing_one_bit)
			consumed_bits_sel <= `fixed_length;
		else if (nal_unit_state == `rbsp_trailing_zero_bits)
			consumed_bits_sel <= `trailing_bits;
		else
			consumed_bits_sel <= `rst_consumed_bits_sel;	
			
	always @ (reset_n or parser_state or nal_unit_state or slice_header_state or ref_pic_list_reordering_state or
		dec_ref_pic_marking_state or slice_data_state or mb_pred_state or seq_parameter_set_state or pic_parameter_set_state)
		if (reset_n == 0)
			FixedLen <= 0;
		else 
			begin
				if (parser_state == `start_code_prefix)
					FixedLen <= 5'd16;
				else if (nal_unit_state == `forbidden_zero_bit_2_nal_unit_type)
					FixedLen <= 8;
				else if (slice_header_state == `num_ref_idx_active_override_flag_s)
					FixedLen <= 1;
				else if (ref_pic_list_reordering_state == `ref_pic_list_reordering_flag_l0_s)
					FixedLen <= 1;
				else if (dec_ref_pic_marking_state == `no_output_of_prior_pics_flag_2_long_term_reference_flag)
					FixedLen <= 2;
				else if (dec_ref_pic_marking_state == `adaptive_ref_pic_marking_mode_flag_s)
					FixedLen <= 1;
				else if (slice_data_state == `pcm_byte_s)
					FixedLen <= 5'd16;
				else if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)
					FixedLen <= 1;
				else if (mb_pred_state == `rem_intra4x4_pred_mode_s)
					FixedLen <= 3;
				else if (seq_parameter_set_state == `fixed_header)
					FixedLen <= 5'd16;	
				else if (seq_parameter_set_state == `level_idc_s)
					FixedLen <= 8;	
				else if (seq_parameter_set_state == `gaps_in_frame_num_value_allowed_flag_s)
					FixedLen <= 1;	
				else if (seq_parameter_set_state == `frame_mbs_only_flag_2_frame_cropping_flag)
					FixedLen <= 3;
				else if (seq_parameter_set_state == `vui_parameter_present_flag_s)
					FixedLen <= 1;
				else if (pic_parameter_set_state == `entropy_coding_mode_flag_2_pic_order_present_flag)
					FixedLen <= 2;
				else if (pic_parameter_set_state == `weighted_pred_flag_2_weighted_bipred_idc)
					FixedLen <= 3;
				else if (pic_parameter_set_state == `deblocking_filter_control_2_redundant_pic_cnt_present_flag)
					FixedLen <= 3;
				else if (nal_unit_state == `rbsp_trailing_one_bit)
					FixedLen <= 1;
				else 
					FixedLen <= 1;
			end	
			
	reg [6:0] pc_reg;
	always @ (consumed_bits_sel or pc_reg or exp_golomb_len or dependent_variable_len or
		cavlc_consumed_bits_len or FixedLen)
		case (consumed_bits_sel)
			`exp_golomb        :pc <= pc_reg + exp_golomb_len;
			`dependent_variable:pc <= pc_reg + dependent_variable_len;
			`cavlc_consumed    :pc <= pc_reg + cavlc_consumed_bits_len;
			`fixed_length      :pc <= pc_reg + FixedLen;
			`trailing_bits     :pc <= (pc_reg[2:0] == 3'b000)? pc_reg:{{pc_reg[6:3] + 1},3'b0};
			`pcm_alignment     :pc <= (pc_reg[2:0] == 3'b000)? pc_reg:{{pc_reg[6:3] + 1},3'b0};
			default            :pc <= pc_reg;
		endcase
	always @ (posedge clk)
		pc_reg <= (reset_n == 0)? 0:pc;

endmodule	
				
			