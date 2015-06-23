//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : exp_golomb_decoding.v
// Generated : June 6, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Exp-Golomb code decoding
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module exp_golomb_decoding (reset_n,heading_one_pos,BitStream_buffer_output,num_ref_idx_l0_active_minus1,
	slice_header_state,slice_data_state,mb_pred_state,sub_mb_pred_state, 
	seq_parameter_set_state,pic_parameter_set_state,exp_golomb_decoding_output,exp_golomb_len);	
	input reset_n;
	input [3:0] heading_one_pos;
	input [15:0] BitStream_buffer_output;
	input [2:0] num_ref_idx_l0_active_minus1;
	input [3:0] slice_header_state;
	input [3:0] slice_data_state;
	input [2:0] mb_pred_state;
	input [1:0] sub_mb_pred_state;
	input [3:0] seq_parameter_set_state;
	input [3:0] pic_parameter_set_state;
	output [7:0] exp_golomb_decoding_output;
	output [3:0] exp_golomb_len;
	
	reg [7:0] exp_golomb_decoding_output;
	reg [3:0] exp_golomb_len;
	
	parameter rst_exp_golomb_sel = 2'b00;
	parameter ue = 2'b01;
	parameter se = 2'b10;
	parameter te = 2'b11; 
			
	reg [7:0] codeNum;
	reg [1:0] exp_golomb_sel;
	
	always @ (exp_golomb_sel or heading_one_pos or BitStream_buffer_output)
		if (exp_golomb_sel != rst_exp_golomb_sel)
			case (heading_one_pos)
				0:codeNum <= 0;											
				1:codeNum <= {6'b0,BitStream_buffer_output[14:13]} - 1;
				2:codeNum <= {5'b0,BitStream_buffer_output[13:11]} - 1;
				3:codeNum <= {4'b0,BitStream_buffer_output[12:9]}  - 1;
				4:codeNum <= {3'b0,BitStream_buffer_output[11:7]}  - 1;
				5:codeNum <= {2'b0,BitStream_buffer_output[10:5]}  - 1;
				6:codeNum <= {1'b0,BitStream_buffer_output[9:3]}   - 1;
				7:codeNum <= BitStream_buffer_output[8:1]          - 1;
				default:codeNum <= 0;
			endcase
		else 
			codeNum <= 0; 
	
	wire [2:0] te_range;
	assign te_range = num_ref_idx_l0_active_minus1 + 1;
	always @ (exp_golomb_sel or heading_one_pos or te_range)
		case (exp_golomb_sel)
			ue,se:exp_golomb_len 	<= (heading_one_pos << 1) + 1;
			te	 :exp_golomb_len 	<= (te_range == 2)? 1:((heading_one_pos << 1) + 1);
			default:exp_golomb_len 	<= 0;
		endcase
		
	wire [7:0] codeNum_se_tmp; 
	assign codeNum_se_tmp = codeNum >> 1;
	always @ (exp_golomb_sel or codeNum or codeNum_se_tmp or te_range)
		case (exp_golomb_sel)
			ue:exp_golomb_decoding_output <= codeNum;
			se:
			case (codeNum[0])
				1:exp_golomb_decoding_output <= (codeNum + 1) >> 1;
				0:exp_golomb_decoding_output <= ~codeNum_se_tmp + 1;
			endcase
			te:
			if (te_range == 2)	exp_golomb_decoding_output <= (codeNum == 0)? 8'd0:8'd1;
			else				exp_golomb_decoding_output <= codeNum;
			default:exp_golomb_decoding_output <= 0;
		endcase
	
	always @ (reset_n or slice_header_state or slice_data_state or mb_pred_state or sub_mb_pred_state or 
		seq_parameter_set_state or pic_parameter_set_state)
		if (reset_n == 0) 
			exp_golomb_sel <= rst_exp_golomb_sel;
		else if (slice_header_state != `rst_slice_header)
			case (slice_header_state)
				`first_mb_in_slice_s					      :exp_golomb_sel	<= ue;						 
				`slice_type_s						            :exp_golomb_sel	<= ue;								 
				`pic_parameter_set_id_slice_header_s:exp_golomb_sel <= ue;		 
				`idr_pic_id_s						            :exp_golomb_sel	<= ue;								  
				`slice_qp_delta_s					          :exp_golomb_sel	<= se;							  
				`disable_deblocking_filter_idc_s		:exp_golomb_sel	<= ue;			  
				`slice_alpha_c0_offset_div2_s		    :exp_golomb_sel <= se;				  
				`slice_beta_offset_div2_s			      :exp_golomb_sel	<= ue;
				default								              :exp_golomb_sel	<= rst_exp_golomb_sel;
			endcase
		else if (slice_data_state != `rst_slice_data)
			case (slice_data_state)
				`mb_skip_run_s     :exp_golomb_sel	<= ue;			  
				`mb_type_s		     :exp_golomb_sel	<= ue;				  
				`sub_mb_pred:
				case (sub_mb_pred_state)
					`sub_mb_type_s	 :exp_golomb_sel	<= ue;	  
					`sub_ref_idx_l0_s:exp_golomb_sel	<= te; 
					`sub_mvd_l0_s		 :exp_golomb_sel	<= se;
					default					 :exp_golomb_sel	<= rst_exp_golomb_sel;
				endcase
				`mb_pred:
				case (mb_pred_state)
					`intra_chroma_pred_mode_s:exp_golomb_sel <= ue;	    
					`ref_idx_l0_s            :exp_golomb_sel <= te;				    
					`mvd_l0_s                :exp_golomb_sel <= se;
					default					         :exp_golomb_sel <= rst_exp_golomb_sel;
				endcase
				`coded_block_pattern_s		 :exp_golomb_sel <= ue;
				`mb_qp_delta_s				     :exp_golomb_sel <= se;
				default						         :exp_golomb_sel <= rst_exp_golomb_sel;
			endcase
		else if (seq_parameter_set_state != `rst_seq_parameter_set)
			case (seq_parameter_set_state)
				`seq_parameter_set_id_sps_s			    :exp_golomb_sel	<= ue;                
				`log2_max_frame_num_minus4_s        :exp_golomb_sel	<= ue;      
				`pic_order_cnt_type_s               :exp_golomb_sel	<= ue;      
				`log2_max_pic_order_cnt_lsb_minus4_s:exp_golomb_sel	<= ue;      
				`num_ref_frames_s					          :exp_golomb_sel	<= ue;                          
				`pic_width_in_mbs_minus1_s          :exp_golomb_sel	<= ue;      
				`pic_height_in_map_units_minus1_s   :exp_golomb_sel	<= ue;
				default								              :exp_golomb_sel	<= rst_exp_golomb_sel;
			endcase
		else if (pic_parameter_set_state != `rst_pic_parameter_set)
			case (pic_parameter_set_state)
				`pic_parameter_set_id_pps_s			   :exp_golomb_sel	<= ue;					
				`seq_parameter_set_id_pps_s			   :exp_golomb_sel	<= ue;
				`num_slice_groups_minus1_s			   :exp_golomb_sel	<= ue;						
				`num_ref_idx_l0_active_minus1_pps_s:exp_golomb_sel	<= ue;						
				`num_ref_idx_l1_active_minus1_pps_s:exp_golomb_sel	<= ue;					 
				`pic_init_qp_minus26_s				     :exp_golomb_sel	<= se;						
				`pic_init_qs_minus26_s				     :exp_golomb_sel	<= se;						
				`chroma_qp_index_offset_s			     :exp_golomb_sel	<= se;
				default								             :exp_golomb_sel	<= rst_exp_golomb_sel;
			endcase
		else
			exp_golomb_sel	<= rst_exp_golomb_sel;
		
endmodule
			
	