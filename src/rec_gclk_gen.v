//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : rec_gclk_gen.v
// Generated : Jan 3, 2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Gated clock generation module for reconstruction
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module rec_gclk_gen(clk,
	//IQIT
	end_of_NonZeroCoeff_CAVLC,OneD_counter,TwoD_counter,rescale_counter,
	rounding_counter,residual_state,cavlc_decoder_state,
	gclk_1D,gclk_2D,gclk_rescale,gclk_rounding,
	//Intra pred
	mb_num_h,mb_num_v,NextMB_IsSkip,
	mb_type_general,blk4x4_rec_counter,blk4x4_sum_counter,blk4x4_intra_preload_counter,
	blk4x4_intra_precompute_counter,blk4x4_intra_calculate_counter,
	Intra4x4_predmode,Intra16x16_predmode,Intra_chroma_predmode,
	gclk_intra_mbAddrA_luma,gclk_intra_mbAddrA_Cb,gclk_intra_mbAddrA_Cr,
	gclk_intra_mbAddrB,gclk_intra_mbAddrC_luma,gclk_intra_mbAddrD,gclk_seed,
	//Inter pred
	blk4x4_inter_preload_counter,gclk_Inter_ref_rf,
	//sum
	Inter_blk4x4_pred_output_valid,gclk_pred_output,gclk_blk4x4_sum,
	//Deblocking filter
	end_of_MB_DEC,end_of_BS_DEC,DF_duration,
	gclk_end_of_MB_DEC,gclk_DF,
	//memory
	Intra_mbAddrB_RAM_rd,Intra_mbAddrB_RAM_wr,gclk_Intra_mbAddrB_RAM,
	rec_DF_RAM0_cs_n,gclk_rec_DF_RAM0,
	rec_DF_RAM1_cs_n,gclk_rec_DF_RAM1,
	DF_mbAddrA_RF_rd,DF_mbAddrA_RF_wr,gclk_DF_mbAddrA_RF,
	DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr,gclk_DF_mbAddrB_RAM
	);
	input clk;
	//IQIT
	input end_of_NonZeroCoeff_CAVLC;
	input [2:0] OneD_counter;
	input [2:0] TwoD_counter;
	input [2:0] rescale_counter;
	input [2:0] rounding_counter;
	input [3:0] residual_state;
	input [3:0] cavlc_decoder_state;
	output gclk_1D;
	output gclk_2D;
	output gclk_rescale;
	output gclk_rounding;
	//Intra pred
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input NextMB_IsSkip;
	input [3:0] mb_type_general;
	input [4:0] blk4x4_rec_counter;
	input [2:0] blk4x4_sum_counter;
	input [2:0] blk4x4_intra_preload_counter;
	input [3:0] blk4x4_intra_precompute_counter;
	input [2:0] blk4x4_intra_calculate_counter;
	input [3:0] Intra4x4_predmode;
	input [1:0] Intra16x16_predmode;
	input [1:0] Intra_chroma_predmode;
	output gclk_intra_mbAddrA_luma;
	output gclk_intra_mbAddrA_Cb;
	output gclk_intra_mbAddrA_Cr;
	output gclk_intra_mbAddrB; 
	output gclk_intra_mbAddrC_luma;	
	output gclk_intra_mbAddrD;
	output gclk_seed;
	//Inter pred
	input [5:0] blk4x4_inter_preload_counter;
	output gclk_Inter_ref_rf;
	//sum
	input [1:0] Inter_blk4x4_pred_output_valid;
	output gclk_pred_output;
	output gclk_blk4x4_sum;
	//DF
	input end_of_MB_DEC;
	input end_of_BS_DEC;
	input DF_duration;
	output gclk_end_of_MB_DEC;
	output gclk_DF;
	//memory
	input Intra_mbAddrB_RAM_rd;
	input Intra_mbAddrB_RAM_wr;
	output gclk_Intra_mbAddrB_RAM;
	input rec_DF_RAM0_cs_n;
	output gclk_rec_DF_RAM0;
	input rec_DF_RAM1_cs_n;
	output gclk_rec_DF_RAM1;
	input DF_mbAddrA_RF_rd,DF_mbAddrA_RF_wr;
	output gclk_DF_mbAddrA_RF;
	input DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr;
	output gclk_DF_mbAddrB_RAM;
	
	parameter rst_residual		    = 4'b0000;
	parameter Intra16x16DCLevel_s	= 4'b0001;
	parameter Intra16x16ACLevel_s	= 4'b0011;
	parameter Intra16x16ACLevel_0_s = 4'b0010;
	parameter LumaLevel_s			= 4'b0110;
	parameter LumaLevel_0_s		    = 4'b0111;
	parameter ChromaDCLevel_Cb_s    = 4'b0101;
	parameter ChromaDCLevel_Cr_s	= 4'b0100;
	parameter ChromaACLevel_Cb_s	= 4'b1100;
	parameter ChromaACLevel_Cr_s	= 4'b1101;
	
	parameter Intra4x4_Vertical 			= 4'b0000;
	parameter Intra4x4_Horizontal 			= 4'b0001;
	parameter Intra4x4_DC 					= 4'b0010;
	parameter Intra4x4_Diagonal_Down_Left 	= 4'b0011;
	parameter Intra4x4_Diagonal_Down_Right 	= 4'b0100;
	parameter Intra4x4_Vertical_Right 		= 4'b0101;
	parameter Intra4x4_Horizontal_Down 		= 4'b0110;
	parameter Intra4x4_Vertical_Left 		= 4'b0111;
	parameter Intra4x4_Horizontal_Up 		= 4'b1000;
	
	parameter Intra16x16_Plane 			= 2'b11;
	parameter Intra_chroma_Plane		= 2'b11;
	
	parameter NumCoeffTrailingOnes_LUT = 4'b0010;
	//-------------------------------------------------
	//IQIT
	//-------------------------------------------------
	//gclk_end_of_one_residual_block
	//reg l_end_of_one_residual_block;
	//wire gclk_end_of_one_residual_block;
	//always @ (clk or end_of_one_residual_block)
	//	if (!clk) l_end_of_one_residual_block <= end_of_one_residual_block;
	//assign gclk_end_of_one_residual_block = clk & l_end_of_one_residual_block;
	
	//gclk_endof1NonZeroCoeffResBlk
	//reg l_end_of_NonZeroCoeff_CAVLC;
	//wire gclk_endof1NonZeroCoeffResBlk;
	//always @ (clk or end_of_NonZeroCoeff_CAVLC)
	//	if (!clk) l_end_of_NonZeroCoeff_CAVLC <= end_of_NonZeroCoeff_CAVLC;
	//assign gclk_endof1NonZeroCoeffResBlk = clk & l_end_of_NonZeroCoeff_CAVLC;
	
	//gclk_1D
	wire OneD_en;
	reg l_OneD_en;
	wire gclk_1D;
	assign OneD_en = (
	//	trap DC case after CAVLC:residual_state is still available now 
	(end_of_NonZeroCoeff_CAVLC == 1'b1 && cavlc_decoder_state != `NumCoeffTrailingOnes_LUT &&
	(residual_state == `Intra16x16DCLevel_s || residual_state == `ChromaDCLevel_Cb_s || 
	residual_state == `ChromaDCLevel_Cr_s)) ||  
    //	trap AC case after rescale:residual_state is still available now
	((residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s || residual_state == `ChromaACLevel_Cb_s ||
	residual_state == `ChromaACLevel_Cr_s) && rescale_counter == 3'b100)	||
	//	trap internal loop
	OneD_counter != 0);
	always @ (clk or OneD_en)
		if (!clk) l_OneD_en <= OneD_en;
	assign gclk_1D = clk & l_OneD_en; 
	
	//gclk_2D
	wire TwoD_en;
	reg l_TwoD_en;
	wire gclk_2D;
	assign TwoD_en = ((OneD_counter == 3'b001 && residual_state != `ChromaDCLevel_Cb_s && residual_state != `ChromaDCLevel_Cr_s) 
					|| TwoD_counter != 0);
	always @ (clk or TwoD_en)
		if (!clk) l_TwoD_en <= TwoD_en;
	assign gclk_2D = clk & l_TwoD_en;
	
	//gclk_rescale
	wire rescale_en;
	reg l_rescale_en;
	wire gclk_rescale;
	assign rescale_en = (
	//trap AC after CAVLC except all zero coeffs case
   	(end_of_NonZeroCoeff_CAVLC == 1'b1 && cavlc_decoder_state != `NumCoeffTrailingOnes_LUT && (
   	residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s || 
   	residual_state == `ChromaACLevel_Cb_s  || residual_state == `ChromaACLevel_Cr_s)) || 
   	//trap DC case after IDCT,chromaDC:after 1D-IDCT,lumaDC:after 2D-IDCT
	((residual_state == `Intra16x16DCLevel_s && TwoD_counter == 3'b100) ||
	((residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s) && OneD_counter == 3'b001)) ||
	//trap internal loop
	rescale_counter != 0);
	always @ (clk or rescale_en)
		if (!clk) l_rescale_en <= rescale_en;
	and gc_rescale (gclk_rescale,clk,l_rescale_en);
	
	//gclk_rounding
	wire rounding_en;
	reg l_rounding_en;
	wire gclk_rounding;
	assign rounding_en = (((residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s ||
	residual_state == `ChromaACLevel_Cb_s || residual_state == `ChromaACLevel_Cr_s) && TwoD_counter == 3'b100)
	|| rounding_counter !=0)?1'b1:1'b0;
	always @ (clk or rounding_en)
		if (!clk) l_rounding_en <= rounding_en;
	assign gclk_rounding = clk & l_rounding_en;
	//-------------------------------------------------
	//Intra pred
	//-------------------------------------------------
	//1.gclk_intra_mbAddrA_luma @ Intra_pred_reg_ctrl.v
	//  For intra pred,update after every blk4x4 is summed
	//  For inter pred,update after blk4x4 5,7,13,15 is summed
	wire intra_mbAddrA_luma_ena;
	reg l_intra_mbAddrA_luma_ena;
	wire gclk_intra_mbAddrA_luma;
	wire Is_LumaRightMostBlk4x4;
	
	assign Is_LumaRightMostBlk4x4 = (blk4x4_rec_counter == 5 || blk4x4_rec_counter == 7 || 
									blk4x4_rec_counter == 13 || blk4x4_rec_counter == 15);
	
	assign intra_mbAddrA_luma_ena = (blk4x4_rec_counter < 16 &&	blk4x4_sum_counter == 3'd3 && (
	//Intra4x4:update when every blk4x4 summed
	(mb_type_general[3:2] == 2'b11 && !(mb_num_h == 10 && Is_LumaRightMostBlk4x4)) ||
	//Intra16x16 && Inter (including skip MB):update when blk4x4 5/7/13/15 is summed 
	//and NextMB_IsSkip is false
	(mb_type_general[3:2] != 2'b11 && mb_num_h != 10 && Is_LumaRightMostBlk4x4 && !NextMB_IsSkip)));
	always @ (clk or intra_mbAddrA_luma_ena)
		if (!clk) l_intra_mbAddrA_luma_ena <= intra_mbAddrA_luma_ena;
	assign gclk_intra_mbAddrA_luma = l_intra_mbAddrA_luma_ena & clk;
	
	//2.gclk_intra_mbAddrA_Cb	@ Intra_pred_reg_ctrl.v
	wire intra_mbAddrA_Cb_ena;
	reg l_intra_mbAddrA_Cb_ena;
	wire gclk_intra_mbAddrA_Cb;	
	wire Is_CbRightMostBlk4x4; 
	assign Is_CbRightMostBlk4x4 = (blk4x4_rec_counter == 17 || blk4x4_rec_counter == 19);
	
	assign intra_mbAddrA_Cb_ena = (blk4x4_sum_counter == 3'd3 && (
	//Intra4x4
	(mb_type_general[3:2] == 2'b11 && mb_num_h != 10 && Is_CbRightMostBlk4x4) ||
	//Intra16x16 && Inter (including skip MB)
	(mb_type_general[3:2] != 2'b11 && mb_num_h != 10 && Is_CbRightMostBlk4x4 && !NextMB_IsSkip)));
	always @ (clk or intra_mbAddrA_Cb_ena)
		if (!clk) l_intra_mbAddrA_Cb_ena <= intra_mbAddrA_Cb_ena;
	assign gclk_intra_mbAddrA_Cb = l_intra_mbAddrA_Cb_ena & clk;
	
	//3.gclk_intra_mbAddrA_Cr	@ Intra_pred_reg_ctrl.v 
	wire intra_mbAddrA_Cr_ena;
	reg l_intra_mbAddrA_Cr_ena;
	wire gclk_intra_mbAddrA_Cr;
	wire Is_CrRightMostBlk4x4;
	assign Is_CrRightMostBlk4x4 = (blk4x4_rec_counter == 21 || blk4x4_rec_counter == 23);
	assign intra_mbAddrA_Cr_ena = (blk4x4_sum_counter == 3'd3 && (
	//Intra4x4
	(mb_type_general[3:2] == 2'b11 && mb_num_h != 10 && Is_CrRightMostBlk4x4) ||
	//Intra16x16 && Inter (including skip MB)
	(mb_type_general[3:2] != 2'b11 && mb_num_h != 10 && Is_CrRightMostBlk4x4 && !NextMB_IsSkip)));
	always @ (clk or intra_mbAddrA_Cr_ena)
		if (!clk) l_intra_mbAddrA_Cr_ena <= intra_mbAddrA_Cr_ena;
	assign gclk_intra_mbAddrA_Cr = l_intra_mbAddrA_Cr_ena & clk;
	
	//4.gclk_intra_mbAddrB		@ Intra_pred_reg_ctrl.v
	//  Control the write of Intra_mbAddrB_reg0 ~ reg 15
	wire intra_mbAddrB_ena;
	reg l_intra_mbAddrB_ena;
	wire gclk_intra_mbAddrB;
	assign intra_mbAddrB_ena = (
	//	Intra4x4
	(mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16 &&
	(blk4x4_intra_preload_counter == 1 || blk4x4_sum_counter[2] != 1'b1)) || 
	//	Intra16x16
	(mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16 && blk4x4_intra_preload_counter !=0) ||
	//	Intra chroma
	(mb_type_general[3] == 1'b1    && blk4x4_rec_counter > 15 && blk4x4_intra_preload_counter !=0));
	always @ (clk or intra_mbAddrB_ena)
		if (!clk) l_intra_mbAddrB_ena <= intra_mbAddrB_ena;
	assign gclk_intra_mbAddrB = l_intra_mbAddrB_ena & clk;
	
	//5.gclk_intra_mbAddrC_luma	@ Intra_pred_reg_ctrl.v
	//1)For blkIdx=0/1/4/5,Intra_mbAddrC_reg are loaded from Intra_mbAddrB_RAM
	//2)For blkIdx other than 0/1/4/5,Intra_mbAddrC_reg directly obtained from Intra_mbAddrB_reg
	wire intra_mbAddrC_luma_ena;
	reg  l_intra_mbAddrC_luma_ena;
	wire gclk_intra_mbAddrC_luma;
	assign intra_mbAddrC_luma_ena = (mb_type_general[3:2] == 2'b11 && (Intra4x4_predmode == Intra4x4_Diagonal_Down_Left 
	|| Intra4x4_predmode == Intra4x4_Vertical_Left) && blk4x4_intra_preload_counter == 3'b010);
	always @ (clk or intra_mbAddrC_luma_ena)
		if (!clk) l_intra_mbAddrC_luma_ena <= intra_mbAddrC_luma_ena;
	assign gclk_intra_mbAddrC_luma = l_intra_mbAddrC_luma_ena & clk;
	
	//6.gclk_intra_mbAddrD	@ Intra_pred_reg_ctrl.v
	//1)For Intra4x4 blkIdx=1/4/5 or Intra16x16 & Chrom plane mode,Intra mbAddrD regs are loaded from 
	//  Intra_mbAddrB_RAM.  
	//2)For blkIdx other than 1/4/5,Intra mbAddrD reg are updated during sum
	wire intra_mbAddrD_ena;
	reg  l_intra_mbAddrD_ena;
	wire gclk_intra_mbAddrD;
	assign intra_mbAddrD_ena = (
	//1.Update when blkIdx = 15,19,23,from Intra_mbAddrB_RAM
	//  In reality,sum_counter = 0/1/2/3 are all OK for update,we choose sum_counter = 0 here 
	(blk4x4_sum_counter == 3'd1 && mb_num_h != 10 && mb_num_v != 0 && !NextMB_IsSkip &&  
	(blk4x4_rec_counter == 15 || blk4x4_rec_counter == 19 || blk4x4_rec_counter == 23)) ||
	(mb_type_general[3:2] == 2'b11 && (
	//2.For blk4x4 1/4/5 mbAddrD reg update from Intra_mbAddrB_RAM
	(blk4x4_intra_preload_counter == 3'b010 && 
	(Intra4x4_predmode == Intra4x4_Diagonal_Down_Right || Intra4x4_predmode == Intra4x4_Vertical_Right 
	|| Intra4x4_predmode == Intra4x4_Horizontal_Down)) ||
	//3.For other blk4x4 mbAddrD reg update from sum output
	(blk4x4_sum_counter == 3'd3 && (
	blk4x4_rec_counter == 0	|| blk4x4_rec_counter == 1 || blk4x4_rec_counter == 4 ||
	blk4x4_rec_counter == 2	|| blk4x4_rec_counter == 3 || blk4x4_rec_counter == 6 ||
	blk4x4_rec_counter == 8	|| blk4x4_rec_counter == 9 || blk4x4_rec_counter == 12)))));
	always @ (clk or intra_mbAddrD_ena)
		if (!clk) l_intra_mbAddrD_ena <= intra_mbAddrD_ena;
	assign gclk_intra_mbAddrD = l_intra_mbAddrD_ena & clk;
	
	//7.gclk_seed				@ Intra_pred_reg_ctrl.v
	wire seed_ena;
	reg  l_seed_ena;
	wire gclk_seed;
	//assign seed_ena = (blk4x4_intra_precompute_counter == 1 || ((Intra16x16_predmode == Intra16x16_Plane ||
	//Intra_chroma_predmode == Intra_chroma_Plane) && blk4x4_intra_calculate_counter == 3));
	
	assign seed_ena = (blk4x4_intra_precompute_counter == 1 || (
	(Intra16x16_predmode == Intra16x16_Plane && ( 
		((blk4x4_rec_counter == 0 || blk4x4_rec_counter == 2 || blk4x4_rec_counter == 8) && 
		blk4x4_intra_calculate_counter == 3'b100)		||
		((blk4x4_rec_counter == 1 || blk4x4_rec_counter == 3 || blk4x4_rec_counter == 9 ||
		blk4x4_rec_counter == 11) && blk4x4_intra_calculate_counter == 3'b001))) ||
	(Intra_chroma_predmode == Intra_chroma_Plane && (
		(blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20) && blk4x4_intra_calculate_counter == 3'b100))));
	
	always @ (clk or seed_ena)
		if (!clk) l_seed_ena <= seed_ena;
	assign gclk_seed = l_seed_ena & clk; 
	
	//-------------------------------------------------
	//Inter pred
	//-------------------------------------------------	
	wire Inter_ref_rf_ena;
	reg l_Inter_ref_rf_ena;
	wire gclk_Inter_ref_rf; 
	assign Inter_ref_rf_ena = (blk4x4_inter_preload_counter == 0)? 1'b0:1'b1;
	always @ (clk or Inter_ref_rf_ena)
		if (!clk) l_Inter_ref_rf_ena <= Inter_ref_rf_ena;
	assign gclk_Inter_ref_rf = l_Inter_ref_rf_ena & clk;
	
	//-------------------------------------------------
	//sum 
	//-------------------------------------------------
	//1.gclk_pred_output
	wire pred_output_ena;
	reg l_pred_output_ena;
	wire gclk_pred_output;
	assign pred_output_ena = (blk4x4_intra_calculate_counter != 0 || Inter_blk4x4_pred_output_valid != 0)? 1'b1:1'b0;
	always @ (clk or pred_output_ena)
		if (!clk) l_pred_output_ena <= pred_output_ena;
	assign gclk_pred_output = l_pred_output_ena & clk;
	
	//2.gclk_blk4x4_sum
	wire blk4x4_sum_ena;
	reg l_blk4x4_sum_ena;
	wire gclk_blk4x4_sum;
	assign blk4x4_sum_ena = (blk4x4_sum_counter[2] != 1'b1);
	always @ (clk or blk4x4_sum_ena)
		if (!clk)	l_blk4x4_sum_ena <= blk4x4_sum_ena;
	assign gclk_blk4x4_sum = l_blk4x4_sum_ena & clk; 
	
	//-------------------------------------------------
	//deblocking filter 
	//-------------------------------------------------	
	//1.gclk_end_of_MB_DEC
	reg l_end_of_MB_DEC;
	wire gclk_end_of_MB_DEC;
	always @ (clk or end_of_MB_DEC)
		if (!clk) l_end_of_MB_DEC <= end_of_MB_DEC;
	assign gclk_end_of_MB_DEC = l_end_of_MB_DEC & clk;
	//2.gclk_DF
	wire DF_ena;
	reg l_DF_ena;
	assign DF_ena = DF_duration | end_of_BS_DEC;
	always @ (clk or DF_ena)
		if (!clk)	l_DF_ena <= DF_ena;
	assign gclk_DF = l_DF_ena & clk;
	
	//-------------------------------------------------
	//memory 
	//-------------------------------------------------
	//gclk_Intra_mbAddrB_RAM
	wire Intra_mbAddrB_RAM_ena; 
	reg l_Intra_mbAddrB_RAM_ena;
	wire gclk_Intra_mbAddrB_RAM;
	assign Intra_mbAddrB_RAM_ena = Intra_mbAddrB_RAM_rd | Intra_mbAddrB_RAM_wr;
	always @ (clk or Intra_mbAddrB_RAM_ena)
		if (!clk) l_Intra_mbAddrB_RAM_ena <= Intra_mbAddrB_RAM_ena;
	assign gclk_Intra_mbAddrB_RAM = clk & l_Intra_mbAddrB_RAM_ena;
	
	//gclk_rec_DF_RAM0
	reg l_rec_DF_RAM0_ena;
	wire gclk_rec_DF_RAM0;
	always @ (clk or rec_DF_RAM0_cs_n)
		if (!clk) l_rec_DF_RAM0_ena <= !rec_DF_RAM0_cs_n;
	assign gclk_rec_DF_RAM0 = clk & l_rec_DF_RAM0_ena;
	
	//gclk_rec_DF_RAM1
	reg l_rec_DF_RAM1_ena;
	wire gclk_rec_DF_RAM1;
	always @ (clk or rec_DF_RAM1_cs_n)
		if (!clk) l_rec_DF_RAM1_ena <= !rec_DF_RAM1_cs_n;
	assign gclk_rec_DF_RAM1 = clk & l_rec_DF_RAM1_ena;
	
	//gclk_DF_mbAddrA_RF
	wire DF_mbAddrA_RF_ena;
	reg l_DF_mbAddrA_RF_ena;
	wire gclk_DF_mbAddrA_RF;
	assign DF_mbAddrA_RF_ena = DF_mbAddrA_RF_rd | DF_mbAddrA_RF_wr;
	always @ (clk or DF_mbAddrA_RF_ena)
		if (!clk) l_DF_mbAddrA_RF_ena <= DF_mbAddrA_RF_ena;
	assign gclk_DF_mbAddrA_RF = clk & l_DF_mbAddrA_RF_ena;
	
	//gclk_DF_mbAddrB_RAM
	wire DF_mbAddrB_RAM_ena;
	reg l_DF_mbAddrB_RAM_ena;
	wire gclk_DF_mbAddrB_RAM;
	assign DF_mbAddrB_RAM_ena = DF_mbAddrB_RAM_rd | DF_mbAddrB_RAM_wr; 
	always @ (clk or DF_mbAddrB_RAM_ena)
		if (!clk) l_DF_mbAddrB_RAM_ena <= DF_mbAddrB_RAM_ena;
	assign gclk_DF_mbAddrB_RAM = clk & l_DF_mbAddrB_RAM_ena;
	
		
endmodule
	
	