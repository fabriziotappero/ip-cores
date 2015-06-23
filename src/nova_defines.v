//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : nova_defines.v
// Generated : April 20,2008
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Global parameters of nova
//-------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
//BitStream_controller parameters
//-------------------------------------------------------------------------------------------------

//---Beha_BitStream_ram.v---
`define Beha_Bitstream_ram_size	131071  //Beha_Bitstream_ram size

//bitstream_gclk_gen
//Assume running at 1.5MHz,so 50,000 cycles is needed for each frame
//1)50,000 cycles are not enough for foreman300,8th   frame.So increase to 51,000 cycles
//2)51,000 cycles are not enough for foreman300,11th  frame.So increase to 51,500 cycles
//3)51,500 cycles are not enough for foreman300,38th  frame.So increase to 52,000 cycles
//4)52,000 cycles are not enough for foreman300,66th  frame.So increase to 52,500 cycles
//5)52,500 cycles are not enough for foreman300,138th frame.So increase to 55,000 cycles
//6)55,000 cycles are not enough for foreman300,223th frame.So increase to 56,000 cycles
//After ext_frame_RAM is changed from async read (the FPGA does not support async read mode)to sync read,
//the cycles required to decode each frame increased
//7)56,000 cycles are not enough for foreman300,138th frame.So increase to 56,500 cycles
//8)56,500 cycles are not enough for foreman300,223th frame.So increase to 57,300 cycles
`define cycles_per_frame0 17'd45000
`define cycles_per_frame1 17'd50000 //fast enough for akiyo300
`define cycles_per_frame2	17'd57300 //preferred frequency for most critical sequence:foreman300
`define cycles_per_frame3	17'd70000

//---pc_decoding---
`define rst_consumed_bits_sel 3'b000
`define exp_golomb            3'b001
`define fixed_length          3'b011
`define dependent_variable    3'b010
`define cavlc_consumed        3'b110
`define trailing_bits         3'b111
`define pcm_alignment         3'b101

//---syntax_decoding---
//mb_type_general
`define MB_Inter16x16            4'b0000
`define MB_Inter16x8             4'b0001
`define MB_Inter8x16             4'b0010
`define MB_P_8x8                 4'b0011
`define MB_P_8x8ref0             4'b0100	
`define MB_P_skip                4'b0101
`define MB_I_PCM                 4'b0110		
`define MB_type_reserved0        4'b0111
`define MB_Intra16x16_CBPChroma0 4'b1000
`define MB_Intra16x16_CBPChroma1 4'b1001
`define MB_Intra16x16_CBPChroma2 4'b1010
`define MB_type_reserved1        4'b1011
`define MB_Intra4x4              4'b1100
`define MB_type_reserved2        4'b1101
`define MB_type_reserved3        4'b1110
`define MB_type_rst              4'b1111

//MBTypeGen_mbAddrA,MBTypeGen_mbAddrB_reg
`define MB_addrA_addrB_Inter      2'b00
`define MB_addrA_addrB_P_skip     2'b01
`define MB_addrA_addrB_Intra16x16 2'b10
`define MB_addrA_addrB_Intra4x4   2'b11

//MBTypeGen_mbAddrD
`define MB_addrD_Inter_P_skip 1'b0
`define MB_addrD_Intra        1'b1

//Gray-encoded FSM states to reduce power consumption during state switching
`define rst_parser 		    2'b00
`define start_code_prefix 2'b01
`define nal_unit 			    2'b11

`define rst_nal_unit						           3'b000
`define forbidden_zero_bit_2_nal_unit_type 3'b001
`define slice_layer_non_IDR_rbsp			     3'b011
`define slice_layer_IDR_rbsp				       3'b010
`define seq_parameter_set_rbsp			       3'b110
`define pic_parameter_set_rbsp		  	     3'b111
`define rbsp_trailing_one_bit				       3'b101
`define rbsp_trailing_zero_bits		         3'b100

`define rst_slice_layer_wo_partitioning 2'b00
`define slice_header				            2'b01
`define slice_data				              2'b11

`define rst_seq_parameter_set                     4'b0000
`define fixed_header                              4'b0001
`define level_idc_s                               4'b0011
`define seq_parameter_set_id_sps_s                4'b0010
`define log2_max_frame_num_minus4_s               4'b0110
`define pic_order_cnt_type_s                      4'b0111
`define log2_max_pic_order_cnt_lsb_minus4_s       4'b0101
`define num_ref_frames_s                          4'b0100
`define gaps_in_frame_num_value_allowed_flag_s    4'b1100
`define pic_width_in_mbs_minus1_s                 4'b1101
`define pic_height_in_map_units_minus1_s          4'b1111
`define frame_mbs_only_flag_2_frame_cropping_flag 4'b1110
`define vui_parameter_present_flag_s              4'b1010

`define rst_pic_parameter_set								 		                   4'b0000
`define pic_parameter_set_id_pps_s								                 4'b0001
`define seq_parameter_set_id_pps_s								                 4'b0011
`define entropy_coding_mode_flag_2_pic_order_present_flag			     4'b0010
`define num_slice_groups_minus1_s									                 4'b0110
`define num_ref_idx_l0_active_minus1_pps_s						             4'b0111
`define num_ref_idx_l1_active_minus1_pps_s						             4'b0101
`define weighted_pred_flag_2_weighted_bipred_idc					         4'b0100
`define pic_init_qp_minus26_s										                   4'b1100
`define pic_init_qs_minus26_s										                   4'b1101
`define chroma_qp_index_offset_s									                 4'b1111
`define deblocking_filter_control_2_redundant_pic_cnt_present_flag 4'b1110

`define rst_slice_header							              4'b0000
`define first_mb_in_slice_s						              4'b0001
`define slice_type_s								                4'b0011
`define pic_parameter_set_id_slice_header_s		      4'b0010
`define frame_num_s								                  4'b0110
`define idr_pic_id_s								                4'b0111
`define pic_order_cnt_lsb_s						              4'b0101
`define num_ref_idx_active_override_flag_s		      4'b0100
`define num_ref_idx_l0_active_minus1_slice_header_s 4'b1100
`define ref_pic_list_reordering					            4'b1101
`define dec_ref_pic_marking						              4'b1111
`define slice_qp_delta_s							              4'b1110
`define disable_deblocking_filter_idc_s			        4'b1010
`define slice_alpha_c0_offset_div2_s				        4'b1011
`define slice_beta_offset_div2_s					          4'b1001

//ref_pic_list_reordering_state 
`define rst_ref_pic_list_reordering		    3'b000
`define ref_pic_list_reordering_flag_l0_s 3'b001

//dec_ref_pic_marking_state 
`define rst_dec_ref_pic_marking								                  2'b00
`define no_output_of_prior_pics_flag_2_long_term_reference_flag 2'b01
`define adaptive_ref_pic_marking_mode_flag_s					          2'b11

`define rst_slice_data		       4'b0000
`define mb_skip_run_s			       4'b0001
`define skip_run_duration		     4'b0011
`define mb_type_s				         4'b0010
`define pcm_alignment_zero_bit_s 4'b0110
`define pcm_byte_s			         4'b0111
`define sub_mb_pred			         4'b0101
`define mb_pred				           4'b0100
`define coded_block_pattern_s	   4'b1100
`define mb_qp_delta_s			       4'b1101
`define residual				         4'b1111
`define mb_num_update			       4'b1110

//mb_pred_state 
`define rst_mb_pred					           3'b000
`define prev_intra4x4_pred_mode_flag_s 3'b001
`define rem_intra4x4_pred_mode_s	     3'b011
`define intra_chroma_pred_mode_s	     3'b010
`define ref_idx_l0_s				           3'b110
`define mvd_l0_s					             3'b111

//sub_mb_pred_state 
`define rst_sub_mb_pred  2'b00
`define sub_mb_type_s	   2'b01
`define sub_ref_idx_l0_s 2'b11
`define sub_mvd_l0_s	   2'b10

`define rst_residual		      4'b0000
`define Intra16x16DCLevel_s	  4'b0001
`define Intra16x16ACLevel_s	  4'b0011
`define Intra16x16ACLevel_0_s 4'b0010
`define LumaLevel_s			      4'b0110
`define LumaLevel_0_s		      4'b0111
`define ChromaDCLevel_Cb_s    4'b0101
`define ChromaDCLevel_Cr_s	  4'b0100
`define ChromaACLevel_Cb_s	  4'b1100
`define ChromaACLevel_Cr_s	  4'b1101
`define ChromaACLevel_0_s		  4'b1110

`define rst_cavlc_decoder		     4'b0000
`define nAnB_decoding_s		       4'b0001	
`define nC_decoding_s			       4'b0011
`define NumCoeffTrailingOnes_LUT 4'b0010
`define TrailingOnesSignFlag	   4'b0110
`define LevelPrefix			         4'b0111
`define LevelSuffix			         4'b0101
`define total_zeros_LUT		       4'b0100 
`define run_before_LUT		       4'b1100
`define RunOfZeros			         4'b1101
`define LevelRunCombination	     4'b1111

//---LumaLevel_mbAddrB_RF---
`define LumaLevel_mbAddrB_RF_data_width 20			
`define LumaLevel_mbAddrB_RF_data_depth 11
//---ChromaLevel_Cb_mbAddrB_RF---			
`define ChromaLevel_Cb_mbAddrB_RF_data_width 10 
`define ChromaLevel_Cb_mbAddrB_RF_data_depth 11
//---ChromaLevel_Cr_mbAddrB_RF---
`define ChromaLevel_Cr_mbAddrB_RF_data_width 10
`define ChromaLevel_Cr_mbAddrB_RF_data_depth 11

//---Intra4x4_PredMode_RF---
`define Intra4x4_PredMode_RF_data_width 16
`define Intra4x4_PredMode_RF_data_depth 11

//---mvx_mbAddrB_RF---
`define mvx_mbAddrB_RF_data_width 32
`define mvx_mbAddrB_RF_data_depth 11
//---mvy_mbAddrB_RF---
`define mvy_mbAddrB_RF_data_width 32	
`define mvy_mbAddrB_RF_data_depth 11
//---mvx_mbAddrC_RF---
`define mvx_mbAddrC_RF_data_width 8
`define mvx_mbAddrC_RF_data_depth 10
//---mvy_mbAddrC_RF---
`define mvy_mbAddrC_RF_data_width 8
`define mvy_mbAddrC_RF_data_depth 10

//-------------------------------------------------------------------------------------------------
//Intra prediction parameters
//-------------------------------------------------------------------------------------------------

//---Intra_mbAddrB_RAM---
`define Intra_mbAddrB_RAM_data_width 32
`define Intra_mbAddrB_RAM_data_depth 88

//---Intra_pred_PE,Intra_pred_pipeline,Intra_pred_reg_ctrl---
`define Intra4x4_Vertical            4'b0000
`define Intra4x4_Horizontal          4'b0001
`define Intra4x4_DC                  4'b0010
`define Intra4x4_Diagonal_Down_Left  4'b0011
`define Intra4x4_Diagonal_Down_Right 4'b0100
`define Intra4x4_Vertical_Right      4'b0101
`define Intra4x4_Horizontal_Down     4'b0110
`define Intra4x4_Vertical_Left       4'b0111
`define Intra4x4_Horizontal_Up       4'b1000

`define Intra16x16_Vertical          2'b00
`define Intra16x16_Horizontal        2'b01
`define Intra16x16_DC                2'b10
`define Intra16x16_Plane             2'b11

`define Intra_chroma_DC              2'b00
`define Intra_chroma_Horizontal      2'b01
`define Intra_chroma_Vertical        2'b10
`define Intra_chroma_Plane           2'b11

//-------------------------------------------------------------------------------------------------
//Inter prediction parameters
//-------------------------------------------------------------------------------------------------

//---Inter_pred_LPE,Inter_pred_pipeline,Inter_pred_reg_ctrl,Inter_pred_sliding_window---
`define pos_Int 4'b0000
`define pos_a   4'b0100
`define pos_b   4'b1000
`define pos_c   4'b1100
`define pos_d   4'b0001
`define pos_e   4'b0101
`define pos_f   4'b1001
`define pos_g   4'b1101
`define pos_h   4'b0010
`define pos_i   4'b0110
`define pos_j   4'b1010
`define pos_k   4'b1110
`define pos_n   4'b0011
`define pos_p   4'b0111
`define pos_q   4'b1011
`define pos_r   4'b1111

//---Inter_pred_pipeline
`define pic_width       8'd176
`define pic_height      8'd144
`define half_pic_width  7'd88
`define half_pic_height 7'd72

//-------------------------------------------------------------------------------------------------
//Deblocking filter parameters
//-------------------------------------------------------------------------------------------------

//---bs_decoding---
`define I8x8   2'b00 //size of inter prediction partitions
`define I16x8	 2'b01
`define I8x16	 2'b10
`define I16x16 2'b11

//---DF_mbAddrA_RAM---
`define DF_mbAddrA_RAM_data_width 32
`define DF_mbAddrA_RAM_data_depth 32

//---DF_mbAddrB_RAM---
`define DF_mbAddrB_RAM_data_width 32
`define DF_mbAddrB_RAM_data_depth 352

//---rec_DF_RAM0---
`define rec_DF_RAM0_data_width 32
`define rec_DF_RAM0_data_depth 96

//---rec_DF_RAM1---
`define rec_DF_RAM1_data_width 32
`define rec_DF_RAM1_data_depth 96

//-------------------------------------------------------------------------------------------------
//Hybrid pipeline control parameters
//-------------------------------------------------------------------------------------------------

