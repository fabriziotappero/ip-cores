//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : bitstream_gclk_gen.v
// Generated : Jan 9,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Gated clock generation module for bitstream controller
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module bitstream_gclk_gen (clk,reset_n,freq_ctrl0,freq_ctrl1,parser_state,nal_unit_state,slice_layer_wo_partitioning_state,
	slice_header_state,slice_data_state,seq_parameter_set_state,pic_parameter_set_state,residual_state,cavlc_decoder_state,
	mb_num,TotalCoeff,start_code_prefix_found,pc_2to0,deblocking_filter_control_present_flag,
	disable_deblocking_filter_idc,end_of_one_residual_block,
	Intra4x4PredMode_mbAddrB_cs_n,mvx_mbAddrB_cs_n,mvy_mbAddrB_cs_n,mvx_mbAddrC_cs_n,mvy_mbAddrC_cs_n,
	LumaLevel_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_cs_n,	
	trigger_CAVLC,blk4x4_rec_counter,end_of_DCBlk_IQIT,end_of_one_blk4x4_sum,end_of_MB_DEC,disable_DF,bs_dec_counter,
	
	gclk_parser,gclk_nal,gclk_slice,gclk_sps,gclk_pps,
	gclk_slice_header,gclk_slice_data,gclk_residual,gclk_cavlc,
	gclk_Intra4x4PredMode_mbAddrB_RF,
	gclk_mvx_mbAddrB_RF,gclk_mvy_mbAddrB_RF,gclk_mvx_mbAddrC_RF,gclk_mvy_mbAddrC_RF,
	gclk_LumaLevel_mbAddrB_RF,gclk_ChromaLevel_Cb_mbAddrB_RF,gclk_ChromaLevel_Cr_mbAddrB_RF,gclk_bs_dec,
	end_of_one_frame);
	input clk;
	input reset_n;
	input freq_ctrl0;
	input freq_ctrl1;
	input [1:0] parser_state;
	input [2:0] nal_unit_state;
	input [1:0] slice_layer_wo_partitioning_state;
	input [3:0] slice_header_state;
	input [3:0] slice_data_state;
	input [3:0] seq_parameter_set_state;
	input [3:0] pic_parameter_set_state;
	input [3:0] residual_state;
	input [3:0] cavlc_decoder_state;
	input [6:0] mb_num;
	input [4:0] TotalCoeff;
	input start_code_prefix_found;
	input [2:0] pc_2to0;
	input deblocking_filter_control_present_flag;
	input [1:0] disable_deblocking_filter_idc;
	input end_of_one_residual_block;
	input Intra4x4PredMode_mbAddrB_cs_n;
	input mvx_mbAddrB_cs_n;
	input mvy_mbAddrB_cs_n;
	input mvx_mbAddrC_cs_n;
	input mvy_mbAddrC_cs_n;
	input LumaLevel_mbAddrB_cs_n;
	input ChromaLevel_Cb_mbAddrB_cs_n;
	input ChromaLevel_Cr_mbAddrB_cs_n; 
	input trigger_CAVLC;
	input [4:0] blk4x4_rec_counter;
	input end_of_DCBlk_IQIT;
	input end_of_one_blk4x4_sum;
	input end_of_MB_DEC;
	input disable_DF;
	input [1:0] bs_dec_counter;
	
	output gclk_parser;
	output gclk_nal;
	output gclk_slice;
	output gclk_sps;
	output gclk_pps;
	output gclk_slice_header;
	output gclk_slice_data;
	output gclk_residual;
	output gclk_cavlc;
	output gclk_Intra4x4PredMode_mbAddrB_RF;
	output gclk_mvx_mbAddrB_RF;
	output gclk_mvy_mbAddrB_RF;
	output gclk_mvx_mbAddrC_RF;
	output gclk_mvy_mbAddrC_RF;
	output gclk_LumaLevel_mbAddrB_RF;
	output gclk_ChromaLevel_Cb_mbAddrB_RF;
	output gclk_ChromaLevel_Cr_mbAddrB_RF;
	output gclk_bs_dec;
	output end_of_one_frame;

  //Input pin freq_ctrl0 & freq_ctrl1 can be used to adjust frequency after the chip is fabricated
	reg [16:0] cycles_per_frame;
	always @ (freq_ctrl0 or freq_ctrl1)
		case ({freq_ctrl1,freq_ctrl0})
			2'b00:cycles_per_frame   <= `cycles_per_frame0;
			2'b01:cycles_per_frame   <= `cycles_per_frame1;
			2'b11:cycles_per_frame   <= `cycles_per_frame3;
			default:cycles_per_frame <= `cycles_per_frame2;
		endcase
	
	//---------------------------------------------------------------------------------
	// decoding rate control
	//---------------------------------------------------------------------------------
	reg [16:0] frame_cycle_counter;
	reg end_of_one_frame;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				frame_cycle_counter <= 0;
				end_of_one_frame	<= 1'b0;
			end
		else if (parser_state == `start_code_prefix)
			begin
				frame_cycle_counter <= 0;
				end_of_one_frame 	<= 1'b0;
			end
		else if (frame_cycle_counter < cycles_per_frame)
			begin
				frame_cycle_counter <= frame_cycle_counter + 1;
				end_of_one_frame	<= 1'b0;
			end
		else
			begin
				frame_cycle_counter <= 0;
				end_of_one_frame	<= 1'b1;
			end
	//PPS and SPS doesn't need rate control,so after PPS/SPS decoding,bitstream parser should continue
	//without waiting for "end_of_one_frame" signal when parser_state == rst_parser.
	//PPS_SPS_complete is used to identify whether next nal_unit to be decoded is PPS/SPS or normal frame
	reg PPS_SPS_complete;
	always @ (posedge gclk_slice or negedge reset_n)
		if (reset_n == 1'b0)
			PPS_SPS_complete <= 1'b0;
		else if (slice_layer_wo_partitioning_state == `slice_header)
			PPS_SPS_complete <= 1'b1;
	
   	//1.gclk_parser
	wire parser_ena;
	reg l_parser_ena;
	wire gclk_parser;  
	assign parser_ena = (
	(parser_state == `rst_parser && (!PPS_SPS_complete || (PPS_SPS_complete && end_of_one_frame))) ||
	(parser_state == `start_code_prefix && start_code_prefix_found == 1'b1)						  ||
	(nal_unit_state == `rbsp_trailing_one_bit && pc_2to0 == 3'b000)								  ||
	nal_unit_state == `rbsp_trailing_zero_bits)? 1'b1:1'b0;
	always @ (clk or parser_ena)
		if (!clk) l_parser_ena <= parser_ena;
	assign gclk_parser = l_parser_ena & clk;
	
	//2.gclk_nal
	//including rate control for end of one frame
	wire nal_ena;
	reg l_nal_ena;
	wire gclk_nal;
	assign nal_ena = (parser_state == `nal_unit && (
	nal_unit_state == `rst_nal_unit 															||
	nal_unit_state == `forbidden_zero_bit_2_nal_unit_type 									||
	(((slice_data_state == `skip_run_duration && end_of_MB_DEC)|| slice_data_state == `mb_num_update)	
	&& mb_num == 98)																		|| 
	seq_parameter_set_state == `vui_parameter_present_flag_s 								||
	pic_parameter_set_state == `deblocking_filter_control_2_redundant_pic_cnt_present_flag 	||
	nal_unit_state == `rbsp_trailing_one_bit 												||
	nal_unit_state == `rbsp_trailing_zero_bits))? 1'b1:1'b0;
	always @ (clk or nal_ena)
		if (!clk) l_nal_ena <= nal_ena;
	assign gclk_nal = l_nal_ena & clk;
	
	//3.gclk_slice:for slice_layer_wo_partitioning_state FSM
	wire slice_ena;
	reg l_slice_ena;
	wire gclk_slice;
	assign slice_ena = (
	(nal_unit_state == `slice_layer_non_IDR_rbsp || nal_unit_state == `slice_layer_IDR_rbsp) && 
	(slice_layer_wo_partitioning_state == `rst_slice_layer_wo_partitioning ||
	(slice_header_state == `slice_qp_delta_s && deblocking_filter_control_present_flag == 1'b0)			||
	(slice_header_state == `disable_deblocking_filter_idc_s && disable_deblocking_filter_idc == 2'b01)   ||
	slice_header_state == `slice_beta_offset_div2_s														||
	(((slice_data_state == `skip_run_duration && end_of_MB_DEC) || slice_data_state == `mb_num_update)	
	&& mb_num == 98)))? 1'b1:1'b0; 
	always @ (clk or slice_ena)
		if (!clk) l_slice_ena <= slice_ena;
	assign gclk_slice = l_slice_ena & clk;
	
	//4.gclk_sps
	wire sps_ena;
	reg l_sps_ena;
	wire gclk_sps;
	assign sps_ena = (nal_unit_state == `seq_parameter_set_rbsp)? 1'b1:1'b0;
	always @ (clk or sps_ena)
		if (!clk)	l_sps_ena <= sps_ena;
	assign gclk_sps = l_sps_ena & clk;
	
	//5.gclk_pps
	wire pps_ena;
	reg l_pps_ena;
	wire gclk_pps;
	
	assign pps_ena = (nal_unit_state == `pic_parameter_set_rbsp)? 1'b1:1'b0;
	always @ (clk or pps_ena)
		if (!clk)	l_pps_ena <= pps_ena;
	assign gclk_pps = l_pps_ena & clk;
	
	//6.gclk_slice_header
	wire slice_header_ena;
	reg l_slice_header_ena;
	wire gclk_slice_header;
	assign slice_header_ena = (slice_layer_wo_partitioning_state == `slice_header)? 1'b1:1'b0;
	always @ (clk or slice_header_ena)
		if (!clk)	l_slice_header_ena <= slice_header_ena;
	assign gclk_slice_header = l_slice_header_ena & clk; 
	
	//7.gclk_slice_data
	//including rate control for skipped macroblock:skip_run_duration
	//including rate control for normal  macroblock:mb_num_update
	wire slice_data_ena;
	reg l_slice_data_ena;
	wire gclk_slice_data;
	assign slice_data_ena = (slice_layer_wo_partitioning_state == `slice_data &&	(
	(slice_data_state != `skip_run_duration && slice_data_state != `residual) ||
	(slice_data_state == `skip_run_duration && end_of_MB_DEC == 1'b1) 	 	||
	(slice_data_state == `residual          && end_of_MB_DEC == 1'b1)))? 1'b1:1'b0;
	always @ (clk or slice_data_ena)
		if (!clk)	l_slice_data_ena <= slice_data_ena;
	assign gclk_slice_data = l_slice_data_ena & clk; 
	
	//8.gclk_residual
	wire residual_ena;
	reg	l_residual_ena;
	wire gclk_residual;
	
	assign residual_ena = (slice_data_state == `residual && 
	(residual_state == `rst_residual 																	|| 
	
	((residual_state == `Intra16x16DCLevel_s || residual_state == `ChromaDCLevel_Cb_s 
	|| residual_state == `ChromaDCLevel_Cr_s) && 
	((end_of_one_residual_block == 1 && TotalCoeff == 0) || end_of_DCBlk_IQIT))							|| 
	
	((residual_state == `Intra16x16ACLevel_s || residual_state == `Intra16x16ACLevel_0_s 
	|| residual_state == `LumaLevel_s || residual_state == `LumaLevel_0_s) 
	&& blk4x4_rec_counter == 15 && end_of_one_blk4x4_sum == 1)											||
	(residual_state == `ChromaACLevel_Cb_s && blk4x4_rec_counter == 19 && end_of_one_blk4x4_sum == 1) 	||
	(residual_state == `ChromaACLevel_Cr_s && blk4x4_rec_counter == 23 && end_of_one_blk4x4_sum == 1) 	||
	(residual_state == `ChromaACLevel_0_s  && blk4x4_rec_counter == 23 && end_of_one_blk4x4_sum == 1)))? 1'b1:1'b0;
	
	always @ (clk or residual_ena)
		if (!clk)	l_residual_ena <= residual_ena;
	assign gclk_residual = l_residual_ena & clk; 
	
	//9.gclk_cavlc
	wire cavlc_ena;
	reg l_cavlc_ena;
	wire gclk_cavlc;
	assign cavlc_ena = (slice_data_state == `residual && (cavlc_decoder_state != `rst_cavlc_decoder ||
	(cavlc_decoder_state == `rst_cavlc_decoder && trigger_CAVLC)))? 1'b1:1'b0;
	
	always @ (clk or cavlc_ena)
		if (!clk)	l_cavlc_ena <= cavlc_ena;
	assign gclk_cavlc = l_cavlc_ena & clk;
	
	//----------------------------------------------------------------------
	//gclk for bitstream controller register file
	//----------------------------------------------------------------------
	//1.gclk_Intra4x4PredMode_mbAddrB_RF
	reg	l_Intra4x4PredMode_mbAddrB_RF_ena;
	wire gclk_Intra4x4PredMode_mbAddrB_RF;
	always @ (clk or Intra4x4PredMode_mbAddrB_cs_n)
		if (!clk) l_Intra4x4PredMode_mbAddrB_RF_ena <= ~Intra4x4PredMode_mbAddrB_cs_n;
	assign gclk_Intra4x4PredMode_mbAddrB_RF = clk & l_Intra4x4PredMode_mbAddrB_RF_ena;
	
	//2.gclk_mvx_mbAddrB_RF
	reg	l_mvx_mbAddrB_RF_ena;
	wire gclk_mvx_mbAddrB_RF;
	always @ (clk or mvx_mbAddrB_cs_n)
		if (!clk) l_mvx_mbAddrB_RF_ena <= ~mvx_mbAddrB_cs_n;
	assign gclk_mvx_mbAddrB_RF = clk & l_mvx_mbAddrB_RF_ena;
	
	//3.gclk_mvy_mbAddrB_RF
	reg	l_mvy_mbAddrB_RF_ena;
	wire gclk_mvy_mbAddrB_RF;
	always @ (clk or mvy_mbAddrB_cs_n)
		if (!clk) l_mvy_mbAddrB_RF_ena <= ~mvy_mbAddrB_cs_n;
	assign gclk_mvy_mbAddrB_RF = clk & l_mvy_mbAddrB_RF_ena;
	
	//4.gclk_mvx_mbAddrC_RF
	reg	l_mvx_mbAddrC_RF_ena;
	wire gclk_mvx_mbAddrC_RF;
	always @ (clk or mvx_mbAddrC_cs_n)
		if (!clk) l_mvx_mbAddrC_RF_ena <= ~mvx_mbAddrC_cs_n;
	assign gclk_mvx_mbAddrC_RF = clk & l_mvx_mbAddrC_RF_ena;
	
	//5.gclk_mvy_mbAddrC_RF
	reg	l_mvy_mbAddrC_RF_ena;
	wire gclk_mvy_mbAddrC_RF;
	always @ (clk or mvy_mbAddrC_cs_n)
		if (!clk) l_mvy_mbAddrC_RF_ena <= ~mvy_mbAddrC_cs_n;
	assign gclk_mvy_mbAddrC_RF = clk & l_mvy_mbAddrC_RF_ena;
	//----------------------------------------------------------------------
	//gclk for CAVLC_decoder related regfiles
	//---------------------------------------------------------------------- 
	//1.gclk_LumaLevel_mbAddrB_RF
	reg	l_LumaLevel_mbAddrB_RF_ena;
	wire gclk_LumaLevel_mbAddrB_RF;
	always @ (clk or LumaLevel_mbAddrB_cs_n)
		if (!clk) l_LumaLevel_mbAddrB_RF_ena <= ~LumaLevel_mbAddrB_cs_n;
	assign gclk_LumaLevel_mbAddrB_RF = clk & l_LumaLevel_mbAddrB_RF_ena;
	
	//2.gclk_ChromaLevel_Cb_mbAddrB_RF
	reg	l_ChromaLevel_Cb_mbAddrB_RF_ena;
	wire gclk_ChromaLevel_Cb_mbAddrB_RF;
	always @ (clk or ChromaLevel_Cb_mbAddrB_cs_n)
		if (!clk) l_ChromaLevel_Cb_mbAddrB_RF_ena <= ~ChromaLevel_Cb_mbAddrB_cs_n;
	assign gclk_ChromaLevel_Cb_mbAddrB_RF = clk & l_ChromaLevel_Cb_mbAddrB_RF_ena;
	
	//3.gclk_ChromaLevel_Cr_mbAddrB_RF
	reg	l_ChromaLevel_Cr_mbAddrB_RF_ena;
	wire gclk_ChromaLevel_Cr_mbAddrB_RF;
	always @ (clk or ChromaLevel_Cr_mbAddrB_cs_n)
		if (!clk) l_ChromaLevel_Cr_mbAddrB_RF_ena <= ~ChromaLevel_Cr_mbAddrB_cs_n;
	assign gclk_ChromaLevel_Cr_mbAddrB_RF = clk & l_ChromaLevel_Cr_mbAddrB_RF_ena;
	
	//----------------------------------------------------------------------
	//gclk for boundary strength decoding
	//----------------------------------------------------------------------
	wire bs_dec_ena;
	reg l_bs_dec_ena;
	wire gclk_bs_dec; 
	
	assign bs_dec_ena = ((end_of_MB_DEC == 1'b1 && disable_DF == 1'b0) || bs_dec_counter != 0)? 1'b1:1'b0;
	always @ (clk or bs_dec_ena)
		if (!clk)	l_bs_dec_ena <= bs_dec_ena;
	assign gclk_bs_dec = l_bs_dec_ena & clk;
	
endmodule
	 

	