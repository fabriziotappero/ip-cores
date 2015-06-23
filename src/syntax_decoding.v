//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : syntax_decoding.v
// Generated : May 23, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding each sytax inside the bitstream
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module syntax_decoding (clk,reset_n,mb_num_h,mb_num_v,end_of_MB_DEC,pin_disable_DF,
	parser_state,nal_unit_state,seq_parameter_set_state,pic_parameter_set_state,
	slice_header_state,slice_data_state,mb_pred_state,sub_mb_pred_state,
	exp_golomb_decoding_output,BitStream_buffer_output,dependent_variable_decoding_output,mbPartIdx,
	
	nal_unit_type,start_code_prefix_found,
	deblocking_filter_control_present_flag,disable_deblocking_filter_idc,disable_DF,
	slice_alpha_c0_offset_div2,slice_beta_offset_div2,
	mb_skip_run,NumMbPart,NumSubMbPart,
	MBTypeGen_mbAddrA,MBTypeGen_mbAddrD,MBTypeGen_mbAddrB_reg,
	log2_max_frame_num_minus4,log2_max_pic_order_cnt_lsb_minus4,constrained_intra_pred_flag,
	num_ref_idx_active_override_flag,num_ref_idx_l0_active_minus1,
	slice_type,mb_type,mb_type_general,sub_mb_type,Intra16x16_predmode,intra_chroma_pred_mode,
	pic_init_qp_minus26,chroma_qp_index_offset,
	rem_intra4x4_pred_mode,prev_intra4x4_pred_mode_flag,mvd,mv_below8x8);
	input clk,reset_n;
	input [3:0] mb_num_h,mb_num_v;
	input end_of_MB_DEC; 
	input pin_disable_DF;
	input [1:0] parser_state;
	input [2:0] nal_unit_state;
	input [3:0] seq_parameter_set_state;
	input [3:0] pic_parameter_set_state;
	input [3:0] slice_header_state;
	input [3:0] slice_data_state;
	input [2:0] mb_pred_state;
	input [1:0] sub_mb_pred_state;
	input [15:0] BitStream_buffer_output;
	input [7:0] exp_golomb_decoding_output;
	input [9:0] dependent_variable_decoding_output;
	input [1:0] mbPartIdx; 
	
	output [4:0] nal_unit_type;
	output start_code_prefix_found;
	output deblocking_filter_control_present_flag;
	output [1:0] disable_deblocking_filter_idc;
	output disable_DF; 
	output [3:0] slice_alpha_c0_offset_div2;
	output [3:0] slice_beta_offset_div2;
	output [6:0] mb_skip_run;
	output [2:0] NumMbPart;
	output [2:0] NumSubMbPart;
	output [1:0] MBTypeGen_mbAddrA;
	output MBTypeGen_mbAddrD;
	output [21:0] MBTypeGen_mbAddrB_reg;
	output [3:0] log2_max_frame_num_minus4;
	output [3:0] log2_max_pic_order_cnt_lsb_minus4;
	output constrained_intra_pred_flag;
	output num_ref_idx_active_override_flag;
	output [2:0] num_ref_idx_l0_active_minus1;
	output [2:0] slice_type;
	output [4:0] mb_type;
	output [3:0] mb_type_general;
	output [1:0] Intra16x16_predmode;
	output [1:0] intra_chroma_pred_mode;
	output [1:0] sub_mb_type;
	output [5:0] pic_init_qp_minus26;
	output [4:0] chroma_qp_index_offset;
	output [2:0] rem_intra4x4_pred_mode;
	output prev_intra4x4_pred_mode_flag;
	output [7:0] mvd;
	output [3:0] mv_below8x8;
	//--------------------------
	//start_code_prefix
	//--------------------------
	reg start_code_prefix_found;
	always @ (parser_state or BitStream_buffer_output)
		if (parser_state == `start_code_prefix)
			begin
				if (BitStream_buffer_output == 16'b0000000000000001)
					start_code_prefix_found <= 1;
				else
					start_code_prefix_found <= 0;
			end
		else
			start_code_prefix_found <= 0;
	//--------------------------
	//nal_unit
	//--------------------------
	reg forbidden_zero_bit;
	reg [1:0] nal_ref_idc;
	reg [4:0] nal_unit_type_reg;
	wire [4:0] nal_unit_type;
	assign nal_unit_type = (nal_unit_state == `forbidden_zero_bit_2_nal_unit_type)? BitStream_buffer_output[12:8]:nal_unit_type_reg; 
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				forbidden_zero_bit <= 0;
				nal_ref_idc        <= 0;
				nal_unit_type_reg  <= 0;
			end
		else if (nal_unit_state == `forbidden_zero_bit_2_nal_unit_type)
			begin
				forbidden_zero_bit <= BitStream_buffer_output[15];
				nal_ref_idc        <= BitStream_buffer_output[14:13];
				nal_unit_type_reg  <= nal_unit_type;
			end
	//--------------------------
	//seq_parameter_set
	//--------------------------
	reg [7:0] profile_idc;
	reg constraint_set0_flag,constraint_set1_flag,constraint_set2_flag,constraint_set3_flag;
	reg [3:0] reserved_zero_4bits;
	reg [7:0] level_idc;
	reg [4:0] seq_parameter_set_id_sps;
	reg [3:0] log2_max_frame_num_minus4;
	reg [1:0] pic_order_cnt_type;
	reg [3:0] log2_max_pic_order_cnt_lsb_minus4;
	reg [2:0] num_ref_frames; //however,we only support 1 reference frame currently
	reg gaps_in_frame_num_value_allowed_flag;
	reg [3:0] pic_width_in_mbs_minus1; 
	reg [3:0] pic_height_in_map_units_minus1;
	reg frame_mbs_only_flag;
	reg direct_8x8_inference_flag;
	reg frame_cropping_flag;
	reg vui_parameter_present_flag;
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				profile_idc                          <= 0;
				constraint_set0_flag                 <= 0;
				constraint_set1_flag                 <= 0;		
				constraint_set2_flag                 <= 0;
				constraint_set3_flag                 <= 0;
				reserved_zero_4bits	                 <= 0;
				level_idc                            <= 0;
				seq_parameter_set_id_sps             <= 0;
				log2_max_frame_num_minus4            <= 0;
				pic_order_cnt_type                   <= 0;
				log2_max_pic_order_cnt_lsb_minus4    <= 0;
				num_ref_frames                       <= 0; 
				gaps_in_frame_num_value_allowed_flag <= 0;
				pic_width_in_mbs_minus1              <= 0; 
				pic_height_in_map_units_minus1       <= 0;
				frame_mbs_only_flag                  <= 0;
				direct_8x8_inference_flag            <= 0;
				frame_cropping_flag                  <= 0;
				vui_parameter_present_flag           <= 0;
			end
		else 
			case (seq_parameter_set_state)
				`fixed_header:
				begin
					profile_idc <= BitStream_buffer_output[15:8];
					constraint_set0_flag <= BitStream_buffer_output[7];
					constraint_set1_flag <= BitStream_buffer_output[6];
					constraint_set2_flag <= BitStream_buffer_output[5];
					constraint_set3_flag <= BitStream_buffer_output[4];
					reserved_zero_4bits  <= BitStream_buffer_output[3:0];
				end
				`level_idc_s                           :level_idc                            <= BitStream_buffer_output[15:8];
				`seq_parameter_set_id_sps_s            :seq_parameter_set_id_sps             <= exp_golomb_decoding_output[4:0];
				`log2_max_frame_num_minus4_s           :log2_max_frame_num_minus4            <= exp_golomb_decoding_output[3:0];
				`pic_order_cnt_type_s                  :pic_order_cnt_type                   <= exp_golomb_decoding_output[1:0];
				`log2_max_pic_order_cnt_lsb_minus4_s   :log2_max_pic_order_cnt_lsb_minus4    <= exp_golomb_decoding_output[3:0];
				`num_ref_frames_s                      :num_ref_frames                       <= exp_golomb_decoding_output[0];
				`gaps_in_frame_num_value_allowed_flag_s:gaps_in_frame_num_value_allowed_flag <= BitStream_buffer_output[15];
				`pic_width_in_mbs_minus1_s             :pic_width_in_mbs_minus1              <= exp_golomb_decoding_output[3:0];
				`pic_height_in_map_units_minus1_s      :pic_height_in_map_units_minus1       <= exp_golomb_decoding_output[3:0];
				`frame_mbs_only_flag_2_frame_cropping_flag:
				begin
					frame_mbs_only_flag       <= BitStream_buffer_output[15];
					direct_8x8_inference_flag <= BitStream_buffer_output[14];
					frame_cropping_flag       <= BitStream_buffer_output[13];
				end
				`vui_parameter_present_flag_s:vui_parameter_present_flag <= BitStream_buffer_output[15];
			endcase
	//--------------------------
	//pic_parameter_set
	//--------------------------
	reg [7:0] pic_parameter_set_id_pps;
	reg [4:0] seq_parameter_set_id_pps;
	reg entropy_coding_mode_flag;
	reg pic_order_present_flag;
	reg [2:0] num_slice_groups_minus1;
	reg [2:0] num_ref_idx_l0_active_minus1;
	reg [2:0] num_ref_idx_l1_active_minus1;
	reg weighted_pred_flag;
	reg [1:0] weighted_bipred_idc;
	reg [5:0] pic_init_qp_minus26,pic_init_qs_minus26;
	reg [4:0] chroma_qp_index_offset;
	reg deblocking_filter_control_present_flag;
	reg constrained_intra_pred_flag;
	reg redundant_pic_cnt_present_flag;
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				pic_parameter_set_id_pps               <= 0;
				seq_parameter_set_id_pps               <= 0;
				entropy_coding_mode_flag               <= 0;
				pic_order_present_flag                 <= 0;
				num_slice_groups_minus1                <= 0;
				num_ref_idx_l0_active_minus1           <= 0;
				num_ref_idx_l1_active_minus1           <= 0;
				weighted_pred_flag                     <= 0;
				weighted_bipred_idc                    <= 0;
				pic_init_qp_minus26                    <= 0;
				pic_init_qs_minus26                    <= 0;
				chroma_qp_index_offset                 <= 0;
				deblocking_filter_control_present_flag <= 0;
				constrained_intra_pred_flag            <= 0;
				redundant_pic_cnt_present_flag         <= 0;
			end
		else 
			case (pic_parameter_set_state)
				`pic_parameter_set_id_pps_s:pic_parameter_set_id_pps <= exp_golomb_decoding_output[7:0];
				`seq_parameter_set_id_pps_s:seq_parameter_set_id_pps <= exp_golomb_decoding_output[4:0];
			 	`entropy_coding_mode_flag_2_pic_order_present_flag:
				begin
					entropy_coding_mode_flag <= BitStream_buffer_output[15];
					pic_order_present_flag   <= BitStream_buffer_output[14];
				end
			 	`num_slice_groups_minus1_s         :num_slice_groups_minus1 <= exp_golomb_decoding_output[2:0];
				`num_ref_idx_l0_active_minus1_pps_s:num_ref_idx_l0_active_minus1 <= exp_golomb_decoding_output[2:0];
				`num_ref_idx_l1_active_minus1_pps_s:num_ref_idx_l1_active_minus1 <= exp_golomb_decoding_output[2:0];
				`weighted_pred_flag_2_weighted_bipred_idc:
				begin
					weighted_pred_flag  <= BitStream_buffer_output[15];
					weighted_bipred_idc <= BitStream_buffer_output[14:13];
				end
				`pic_init_qp_minus26_s   :pic_init_qp_minus26 <= exp_golomb_decoding_output[5:0];
				`pic_init_qs_minus26_s   :pic_init_qs_minus26 <= exp_golomb_decoding_output[5:0];
				`chroma_qp_index_offset_s:chroma_qp_index_offset <= exp_golomb_decoding_output[4:0];
				`deblocking_filter_control_2_redundant_pic_cnt_present_flag:
				begin
					deblocking_filter_control_present_flag <= BitStream_buffer_output[15];
					constrained_intra_pred_flag            <= BitStream_buffer_output[14];
					redundant_pic_cnt_present_flag         <= BitStream_buffer_output[13];
				end
			endcase
	//--------------------------
	//slice_header
	//--------------------------
	reg first_mb_in_slice;
	reg [2:0] slice_type;
	reg [7:0] pic_parameter_set_id_slice_header;
	reg [3:0] frame_num;
	reg idr_pic_id;
	reg [9:0] pic_order_cnt_lsb;
	reg num_ref_idx_active_override_flag;
	reg [1:0] disable_deblocking_filter_idc;
	reg [3:0] slice_alpha_c0_offset_div2_dec;
	reg [3:0] slice_beta_offset_div2_dec;
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				first_mb_in_slice                 <= 0;
				slice_type                        <= 0;
				pic_parameter_set_id_slice_header <= 0;
				frame_num                         <= 0;
				idr_pic_id                        <= 0;
				pic_order_cnt_lsb                 <= 0;
				num_ref_idx_active_override_flag  <= 0;
				disable_deblocking_filter_idc     <= 0;
				slice_alpha_c0_offset_div2_dec    <= 0;
				slice_beta_offset_div2_dec        <= 0;
			end
		else
			case (slice_header_state)
				`first_mb_in_slice_s                :first_mb_in_slice                 <= exp_golomb_decoding_output[0];
				`slice_type_s                       :slice_type                        <= exp_golomb_decoding_output[2:0];
				`pic_parameter_set_id_slice_header_s:pic_parameter_set_id_slice_header <= exp_golomb_decoding_output;
				`frame_num_s                        :frame_num                         <= dependent_variable_decoding_output[3:0];
				`idr_pic_id_s                       :idr_pic_id                        <= exp_golomb_decoding_output[0];
				`pic_order_cnt_lsb_s                :pic_order_cnt_lsb                 <= dependent_variable_decoding_output[9:0];
				`num_ref_idx_active_override_flag_s :num_ref_idx_active_override_flag  <= BitStream_buffer_output[15];
				//num_ref_idx_l0_active_minus1_slice_header_s:
				//slice_qp_delta_s:slice_qp_delta <= exp_golomb_decoding_output[5:0];
				`disable_deblocking_filter_idc_s    :disable_deblocking_filter_idc     <= exp_golomb_decoding_output[1:0];
				`slice_alpha_c0_offset_div2_s       :slice_alpha_c0_offset_div2_dec    <= exp_golomb_decoding_output[3:0];
				`slice_beta_offset_div2_s           :slice_beta_offset_div2_dec 	     <= exp_golomb_decoding_output[3:0];
				//slice_group_change_cycle_s:
			endcase
	
	wire [3:0] slice_alpha_c0_offset_div2;
	wire [3:0] slice_beta_offset_div2;
	assign slice_alpha_c0_offset_div2 = {4{deblocking_filter_control_present_flag}} & slice_alpha_c0_offset_div2_dec;
	assign slice_beta_offset_div2 	  = {4{deblocking_filter_control_present_flag}} & slice_beta_offset_div2_dec;
	
	reg sw_disable_DF;
	always @ (posedge clk)
		if (reset_n == 0)
			sw_disable_DF <= 0;
		else if (slice_header_state == `disable_deblocking_filter_idc_s && disable_deblocking_filter_idc == 1)
			sw_disable_DF <= 1;
		else
			sw_disable_DF <= 0;
			
	assign disable_DF = sw_disable_DF | pin_disable_DF; 
	//--------------------------
	//slice_data
	//--------------------------
	wire [6:0] mb_skip_run;
	reg [6:0] mb_skip_run_reg;
	reg [4:0] mb_type;
	reg [3:0] mb_type_general;
	reg [3:0] mb_type_general_reg;
	reg [1:0] Intra16x16_predmode;
		
	//mb_type_general
	assign mb_skip_run = (slice_data_state == `mb_skip_run_s)? exp_golomb_decoding_output[6:0]:mb_skip_run_reg; 
	always @ (slice_data_state or slice_type or exp_golomb_decoding_output or mb_type_general_reg)
		if (slice_data_state == `skip_run_duration)
			mb_type_general <= `MB_P_skip;
		else if (slice_data_state == `mb_type_s)
			begin
				if (slice_type == 2 || slice_type == 7)	//I slice
					case (exp_golomb_decoding_output)
						0:                      mb_type_general <= `MB_Intra4x4;
						1,2,3,4,13,14,15,16:    mb_type_general <= `MB_Intra16x16_CBPChroma0;
						5,6,7,8,17,18,19,20:    mb_type_general <= `MB_Intra16x16_CBPChroma1;
						9,10,11,12,21,22,23,24: mb_type_general <= `MB_Intra16x16_CBPChroma2;
						default:                mb_type_general <= `MB_Inter16x16;
					endcase
				else                                    //P slice
					case (exp_golomb_decoding_output)
						0:                      mb_type_general <= `MB_Inter16x16;
						1:                      mb_type_general <= `MB_Inter16x8;
						2:                      mb_type_general <= `MB_Inter8x16;
						3:                      mb_type_general <= `MB_P_8x8;
						4:                      mb_type_general <= `MB_P_8x8ref0;
						5:                      mb_type_general <= `MB_Intra4x4;
						6,7,8,9,18,19,20,21:    mb_type_general <= `MB_Intra16x16_CBPChroma0;
						10,11,12,13,22,23,24,25:mb_type_general <= `MB_Intra16x16_CBPChroma1;
						14,15,16,17,26,27,28,29:mb_type_general <= `MB_Intra16x16_CBPChroma0;
						default:                mb_type_general <= `MB_Inter16x8;
					endcase
			end
		else
			mb_type_general <= mb_type_general_reg;
			
	//Intra16x16_predmode
	always @ (posedge clk)
		if (reset_n == 0)
			Intra16x16_predmode <= 2'b0;
		else if (slice_data_state == `mb_type_s)
			begin
				if (slice_type == 2 || slice_type == 7)	//I slice
					begin
						if (exp_golomb_decoding_output != 0)
							case (exp_golomb_decoding_output[1:0])
								2'b00:Intra16x16_predmode <= 2'b11;
								2'b01:Intra16x16_predmode <= 2'b00;
								2'b10:Intra16x16_predmode <= 2'b01;
								2'b11:Intra16x16_predmode <= 2'b10;
							endcase
					end
				else if (exp_golomb_decoding_output[4:0] > 5) //P slice
					case (exp_golomb_decoding_output[1:0])
						2'b00:Intra16x16_predmode <= 2'b10;
						2'b01:Intra16x16_predmode <= 2'b11;
						2'b10:Intra16x16_predmode <= 2'b00;
						2'b11:Intra16x16_predmode <= 2'b01;
					endcase
			end
	
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				mb_skip_run_reg <= 0;
				mb_type <= 0;
				mb_type_general_reg <= `MB_type_rst;
			end
		else 
			case (slice_data_state)
				`mb_skip_run_s:mb_skip_run_reg <= mb_skip_run;
				`skip_run_duration:
				begin
					mb_type <= 5'd31;
					mb_type_general_reg <= mb_type_general;
				end
				`mb_type_s:
				begin
					mb_type <= exp_golomb_decoding_output[4:0];
					mb_type_general_reg <= mb_type_general;
				end
				//pcm_byte_s: --> Currently no deal with it
				//coded_block_pattern_s: --> See CodedBlockPattern_decoding.v
				//mb_qp_delta_s:mb_qp_delta <= exp_golomb_decoding_output;
			endcase
	//Update MBTypeGen information
	reg [1:0] MBTypeGen_mbAddrA;
	reg MBTypeGen_mbAddrD_tmp;
	reg MBTypeGen_mbAddrD;
	reg [21:0] MBTypeGen_mbAddrB_reg;
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				MBTypeGen_mbAddrA <= 0;
				MBTypeGen_mbAddrD_tmp <= 0;
				MBTypeGen_mbAddrB_reg <= 0;
			end
		else if (slice_data_state == `skip_run_duration && end_of_MB_DEC)//for P_skip
			begin
				if (mb_num_h != 10)
					MBTypeGen_mbAddrA <= `MB_addrA_addrB_P_skip;
				if (mb_num_h == 9)
					MBTypeGen_mbAddrD_tmp <= 1'b0;
				if (mb_num_v != 8)
					case (mb_num_h)
						0:MBTypeGen_mbAddrB_reg[1:0]    <= `MB_addrA_addrB_P_skip;1:MBTypeGen_mbAddrB_reg[3:2] 	 <= `MB_addrA_addrB_P_skip;
						2:MBTypeGen_mbAddrB_reg[5:4]    <= `MB_addrA_addrB_P_skip;3:MBTypeGen_mbAddrB_reg[7:6] 	 <= `MB_addrA_addrB_P_skip;
						4:MBTypeGen_mbAddrB_reg[9:8]    <= `MB_addrA_addrB_P_skip;5:MBTypeGen_mbAddrB_reg[11:10] <= `MB_addrA_addrB_P_skip;
						6:MBTypeGen_mbAddrB_reg[13:12] 	<= `MB_addrA_addrB_P_skip;7:MBTypeGen_mbAddrB_reg[15:14] <= `MB_addrA_addrB_P_skip;
						8:MBTypeGen_mbAddrB_reg[17:16] 	<= `MB_addrA_addrB_P_skip;9:MBTypeGen_mbAddrB_reg[19:18] <= `MB_addrA_addrB_P_skip;
						10:MBTypeGen_mbAddrB_reg[21:20]	<= `MB_addrA_addrB_P_skip;
					endcase
			end
		else if (slice_data_state == `mb_num_update)
			begin
				if (mb_num_h != 10)
					begin
						if (mb_type_general[3] == 1'b0)
							MBTypeGen_mbAddrA <= `MB_addrA_addrB_Inter;
						else if (mb_type_general[3:2] == 2'b10)
							MBTypeGen_mbAddrA <= `MB_addrA_addrB_Intra16x16;
						else if (mb_type_general == `MB_Intra4x4)
							MBTypeGen_mbAddrA <= `MB_addrA_addrB_Intra4x4;
					end
				if (mb_num_h == 9)
					MBTypeGen_mbAddrD_tmp <= mb_type_general[3];
				if (mb_num_v != 8)
					begin
						if (mb_type_general[3] == 1'b0)
							case (mb_num_h)
								0:MBTypeGen_mbAddrB_reg[1:0]   <= `MB_addrA_addrB_Inter; 1:MBTypeGen_mbAddrB_reg[3:2]   <= `MB_addrA_addrB_Inter;
								2:MBTypeGen_mbAddrB_reg[5:4]   <= `MB_addrA_addrB_Inter; 3:MBTypeGen_mbAddrB_reg[7:6]   <= `MB_addrA_addrB_Inter;
								4:MBTypeGen_mbAddrB_reg[9:8]   <= `MB_addrA_addrB_Inter; 5:MBTypeGen_mbAddrB_reg[11:10] <= `MB_addrA_addrB_Inter;
								6:MBTypeGen_mbAddrB_reg[13:12] <= `MB_addrA_addrB_Inter; 7:MBTypeGen_mbAddrB_reg[15:14] <= `MB_addrA_addrB_Inter;
								8:MBTypeGen_mbAddrB_reg[17:16] <= `MB_addrA_addrB_Inter; 9:MBTypeGen_mbAddrB_reg[19:18] <= `MB_addrA_addrB_Inter;
								10:MBTypeGen_mbAddrB_reg[21:20]<= `MB_addrA_addrB_Inter;
							endcase
						else if (mb_type_general[3:2] == 2'b10)
							case (mb_num_h)
								0:MBTypeGen_mbAddrB_reg[1:0]   <= `MB_addrA_addrB_Intra16x16; 1:MBTypeGen_mbAddrB_reg[3:2]   <= `MB_addrA_addrB_Intra16x16;
								2:MBTypeGen_mbAddrB_reg[5:4]   <= `MB_addrA_addrB_Intra16x16; 3:MBTypeGen_mbAddrB_reg[7:6]   <= `MB_addrA_addrB_Intra16x16;
								4:MBTypeGen_mbAddrB_reg[9:8]   <= `MB_addrA_addrB_Intra16x16; 5:MBTypeGen_mbAddrB_reg[11:10] <= `MB_addrA_addrB_Intra16x16;
								6:MBTypeGen_mbAddrB_reg[13:12] <= `MB_addrA_addrB_Intra16x16; 7:MBTypeGen_mbAddrB_reg[15:14] <= `MB_addrA_addrB_Intra16x16;
								8:MBTypeGen_mbAddrB_reg[17:16] <= `MB_addrA_addrB_Intra16x16; 9:MBTypeGen_mbAddrB_reg[19:18] <= `MB_addrA_addrB_Intra16x16;
								10:MBTypeGen_mbAddrB_reg[21:20]<= `MB_addrA_addrB_Intra16x16;
							endcase
						else if (mb_type_general == `MB_Intra4x4)
							case (mb_num_h)
								0:MBTypeGen_mbAddrB_reg[1:0]   <= `MB_addrA_addrB_Intra4x4;	1:MBTypeGen_mbAddrB_reg[3:2]   <= `MB_addrA_addrB_Intra4x4;
								2:MBTypeGen_mbAddrB_reg[5:4]   <= `MB_addrA_addrB_Intra4x4;	3:MBTypeGen_mbAddrB_reg[7:6]   <= `MB_addrA_addrB_Intra4x4;
								4:MBTypeGen_mbAddrB_reg[9:8]   <= `MB_addrA_addrB_Intra4x4;	5:MBTypeGen_mbAddrB_reg[11:10] <= `MB_addrA_addrB_Intra4x4;
								6:MBTypeGen_mbAddrB_reg[13:12] <= `MB_addrA_addrB_Intra4x4; 7:MBTypeGen_mbAddrB_reg[15:14] <= `MB_addrA_addrB_Intra4x4;
								8:MBTypeGen_mbAddrB_reg[17:16] <= `MB_addrA_addrB_Intra4x4; 9:MBTypeGen_mbAddrB_reg[19:18] <= `MB_addrA_addrB_Intra4x4;
								10:MBTypeGen_mbAddrB_reg[21:20]<= `MB_addrA_addrB_Intra4x4;
							endcase
					end
			end
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			MBTypeGen_mbAddrD <= 0;
		else if (mb_num_h == 0)
			MBTypeGen_mbAddrD <= MBTypeGen_mbAddrD_tmp;
	
	//----------------------------------------------------------------------
	//mb_pred & sub_mb_pred	
	//	--> Also refer to Intra4x4_PredMode_decoding.v & Inter_mv_decoding.v
	//----------------------------------------------------------------------
	wire prev_intra4x4_pred_mode_flag;
	reg prev_intra4x4_pred_mode_flag_reg;
	wire [2:0] rem_intra4x4_pred_mode;
	reg [2:0] rem_intra4x4_pred_mode_reg;
	reg [1:0] intra_chroma_pred_mode;
	wire [7:0] mvd;
	reg [7:0] mvd_reg;
	reg [7:0] sub_mb_type_reg;
	assign prev_intra4x4_pred_mode_flag = (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)? BitStream_buffer_output[15]:prev_intra4x4_pred_mode_flag_reg;
	assign rem_intra4x4_pred_mode = (mb_pred_state == `rem_intra4x4_pred_mode_s)? BitStream_buffer_output[15:13]:rem_intra4x4_pred_mode_reg;	
	assign mvd = ((mb_pred_state == `mvd_l0_s) || (sub_mb_pred_state == `sub_mvd_l0_s))? exp_golomb_decoding_output[7:0]:mvd_reg;				
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				prev_intra4x4_pred_mode_flag_reg <= 0;
				rem_intra4x4_pred_mode_reg       <= 0;
				intra_chroma_pred_mode           <= 0;
				mvd_reg                          <= 0;
				sub_mb_type_reg                  <= 0;
			end
		else
			begin
				case (mb_pred_state)
					`prev_intra4x4_pred_mode_flag_s:prev_intra4x4_pred_mode_flag_reg <= prev_intra4x4_pred_mode_flag;
					`rem_intra4x4_pred_mode_s      :rem_intra4x4_pred_mode_reg       <= rem_intra4x4_pred_mode;
					`intra_chroma_pred_mode_s      :intra_chroma_pred_mode           <= exp_golomb_decoding_output[1:0];
					//ref_idx_l0_s: --> only 1 reference frame,so never jump into this state
					`mvd_l0_s:	mvd_reg <= mvd;
				endcase
				case (sub_mb_pred_state)
					`sub_mb_type_s:
					case (mbPartIdx)
						0:sub_mb_type_reg[1:0] <= exp_golomb_decoding_output[1:0];
						1:sub_mb_type_reg[3:2] <= exp_golomb_decoding_output[1:0];
						2:sub_mb_type_reg[5:4] <= exp_golomb_decoding_output[1:0];
						3:sub_mb_type_reg[7:6] <= exp_golomb_decoding_output[1:0];
					endcase
					//sub_ref_idx_l0_s: --> only 1 reference frame,so never jump into this state
					`sub_mvd_l0_s: mvd_reg <= mvd;
				endcase
			end
	reg [2:0] NumMbPart;
	reg [2:0] NumSubMbPart;
	reg [1:0] sub_mb_type;
	always @ (sub_mb_pred_state or sub_mb_type_reg or mbPartIdx)
		if (sub_mb_pred_state == `sub_mvd_l0_s)
			case (mbPartIdx)
				0:sub_mb_type <= sub_mb_type_reg[1:0]; 
				1:sub_mb_type <= sub_mb_type_reg[3:2];
				2:sub_mb_type <= sub_mb_type_reg[5:4];
				3:sub_mb_type <= sub_mb_type_reg[7:6];
			endcase
		else
			sub_mb_type <= 0;							 
	always @ (mb_pred_state or mb_type_general or sub_mb_pred_state)
		if (mb_pred_state == `mvd_l0_s)
			case (mb_type_general)
				0:NumMbPart <= 3'd1;
				default:NumMbPart <= 3'd2;
			endcase
		else if (sub_mb_pred_state == `sub_mvd_l0_s)
			NumMbPart <= 3'd4;
		else 
			NumMbPart <= 3'd0;	
	always @ (sub_mb_pred_state or mbPartIdx or sub_mb_type_reg)
		if (sub_mb_pred_state == `sub_mvd_l0_s)
			case (mbPartIdx)
				0:
				case (sub_mb_type_reg[1:0])
					2'b00      :NumSubMbPart <= 3'd1;
					2'b01,2'b10:NumSubMbPart <= 3'd2;
					2'b11      :NumSubMbPart <= 3'd4;
				endcase
				1:
				case (sub_mb_type_reg[3:2])
					2'b00      :NumSubMbPart <= 3'd1;
					2'b01,2'b10:NumSubMbPart <= 3'd2;
					2'b11      :NumSubMbPart <= 3'd4;
				endcase
				2:
				case (sub_mb_type_reg[5:4])
					2'b00      :NumSubMbPart <= 3'd1;
					2'b01,2'b10:NumSubMbPart <= 3'd2;
					2'b11      :NumSubMbPart <= 3'd4;
				endcase
				3:
				case (sub_mb_type_reg[7:6])
					2'b00      :NumSubMbPart <= 3'd1;
					2'b01,2'b10:NumSubMbPart <= 3'd2;
					2'b11      :NumSubMbPart <= 3'd4;
				endcase
			endcase
		else
			NumSubMbPart <= 0;
			
	//mv_below8x8
	reg [3:0] mv_below8x8; 
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mv_below8x8 <= 4'b0;
		else if (sub_mb_pred_state == `sub_mb_type_s)
			case (mbPartIdx)
				0:mv_below8x8[0] <= (exp_golomb_decoding_output[1:0] == 2'b00)? 1'b0:1'b1; 
				1:mv_below8x8[1] <= (exp_golomb_decoding_output[1:0] == 2'b00)? 1'b0:1'b1; 
				2:mv_below8x8[2] <= (exp_golomb_decoding_output[1:0] == 2'b00)? 1'b0:1'b1; 
				3:mv_below8x8[3] <= (exp_golomb_decoding_output[1:0] == 2'b00)? 1'b0:1'b1; 
			endcase
		else if (slice_data_state == `mb_pred || slice_data_state == `skip_run_duration)
			mv_below8x8 <= 4'b0;
			
endmodule
				
				
			
				
					
					
					
					
	
	
		
	
	
			
				
				
				
				
	
			
			
		
			
			
			
		
	
		
			
					
			