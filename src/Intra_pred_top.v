//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Intra_pred_top.v
// Generated : Sep 30,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Top module of Intra prediction
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Intra_pred_top (clk,reset_n,
	gclk_intra_mbAddrA_luma,gclk_intra_mbAddrA_Cb,gclk_intra_mbAddrA_Cr,gclk_intra_mbAddrB,
	gclk_intra_mbAddrC_luma,gclk_intra_mbAddrD,gclk_seed,gclk_Intra_mbAddrB_RAM,
	mb_num_h,mb_num_v,mb_type_general,NextMB_IsSkip,
	Intra16x16_predmode,Intra4x4_predmode_CurrMb,Intra_chroma_predmode,
	blk4x4_rec_counter,trigger_blk4x4_intra_pred,blk4x4_sum_counter,
	sum_right_column_reg,blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2,
	blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6,
	blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10,
	blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14,
	Intra_mbAddrB_RAM_wr,Intra_mbAddrB_RAM_wr_addr,Intra_mbAddrB_RAM_din,
	
	PE0_out,PE1_out,PE2_out,PE3_out,Intra4x4_predmode,
	blk4x4_intra_preload_counter,blk4x4_intra_precompute_counter,blk4x4_intra_calculate_counter,
	end_of_one_blk4x4_intra,Intra_mbAddrB_RAM_rd
	);
	input clk,reset_n;
	input gclk_intra_mbAddrA_luma;
	input gclk_intra_mbAddrA_Cb;
	input gclk_intra_mbAddrA_Cr;
	input gclk_intra_mbAddrB; 
	input gclk_intra_mbAddrC_luma;	
	input gclk_intra_mbAddrD;
	input gclk_seed;
	input gclk_Intra_mbAddrB_RAM;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [3:0] mb_type_general;
	input NextMB_IsSkip;
	input [1:0] Intra16x16_predmode;
	input [63:0] Intra4x4_predmode_CurrMb;
	input [1:0] Intra_chroma_predmode;
	input [4:0] blk4x4_rec_counter;
	input trigger_blk4x4_intra_pred;
	input [2:0] blk4x4_sum_counter;
	input [23:0] sum_right_column_reg;
	input [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	input [7:0] blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2;
	input [7:0] blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6;
	input [7:0] blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10;
	input [7:0] blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14;
	input Intra_mbAddrB_RAM_wr;
	input [6:0] Intra_mbAddrB_RAM_wr_addr;
	input [31:0] Intra_mbAddrB_RAM_din;
	
	output [7:0] PE0_out;
	output [7:0] PE1_out;
	output [7:0] PE2_out;
	output [7:0] PE3_out;
	output [3:0] Intra4x4_predmode;
	output [2:0] blk4x4_intra_preload_counter;
	output [3:0] blk4x4_intra_precompute_counter;
	output [2:0] blk4x4_intra_calculate_counter;
	output end_of_one_blk4x4_intra;
	output Intra_mbAddrB_RAM_rd;
		
	wire blkAddrA_availability,blkAddrB_availability;
	wire mbAddrA_availability,mbAddrB_availability,mbAddrC_availability;
	wire [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	wire [15:0] PE0_sum_out,PE3_sum_out;
	wire Intra_mbAddrB_RAM_rd;
	wire [6:0] Intra_mbAddrB_RAM_rd_addr;
	wire [31:0]	Intra_mbAddrB_RAM_dout;
	
	wire [7:0] Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3;
	wire [7:0] Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3;
	wire [7:0] Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7;
	wire [7:0] Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11;
	wire [7:0] Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15;
	
	wire [7:0] Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3;
	wire [7:0] Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3;
	wire [7:0] Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7;
	wire [7:0] Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11;
	wire [7:0] Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15;
	
	wire [7:0] Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3; 
	wire [7:0] Intra_mbAddrD_window;
	wire [15:0] main_seed,seed;
	wire [11:0] plane_b_reg,plane_c_reg;
	
	Intra_pred_pipeline Intra_pred_pipeline (
		.clk(clk),
		.reset_n(reset_n),
		.mb_type_general(mb_type_general),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.trigger_blk4x4_intra_pred(trigger_blk4x4_intra_pred),
		.mb_num_v(mb_num_v),
		.mb_num_h(mb_num_h),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.NextMB_IsSkip(NextMB_IsSkip),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra4x4_predmode_CurrMb(Intra4x4_predmode_CurrMb),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.Intra_mbAddrA_reg0(Intra_mbAddrA_reg0), 
		.Intra_mbAddrA_reg1(Intra_mbAddrA_reg1), 
		.Intra_mbAddrA_reg2(Intra_mbAddrA_reg2), 
		.Intra_mbAddrA_reg3(Intra_mbAddrA_reg3),
		.Intra_mbAddrA_reg4(Intra_mbAddrA_reg4), 
		.Intra_mbAddrA_reg5(Intra_mbAddrA_reg5), 
		.Intra_mbAddrA_reg6(Intra_mbAddrA_reg6), 
		.Intra_mbAddrA_reg7(Intra_mbAddrA_reg7),
		.Intra_mbAddrA_reg8(Intra_mbAddrA_reg8), 
		.Intra_mbAddrA_reg9(Intra_mbAddrA_reg9), 
		.Intra_mbAddrA_reg10(Intra_mbAddrA_reg10),
		.Intra_mbAddrA_reg11(Intra_mbAddrA_reg11),
		.Intra_mbAddrA_reg12(Intra_mbAddrA_reg12),
		.Intra_mbAddrA_reg13(Intra_mbAddrA_reg13),
		.Intra_mbAddrA_reg14(Intra_mbAddrA_reg14),
		.Intra_mbAddrA_reg15(Intra_mbAddrA_reg15),
		.Intra_mbAddrB_reg0(Intra_mbAddrB_reg0), 
		.Intra_mbAddrB_reg1(Intra_mbAddrB_reg1), 
		.Intra_mbAddrB_reg2(Intra_mbAddrB_reg2), 
		.Intra_mbAddrB_reg3(Intra_mbAddrB_reg3),
		.Intra_mbAddrB_reg4(Intra_mbAddrB_reg4), 
		.Intra_mbAddrB_reg5(Intra_mbAddrB_reg5), 
		.Intra_mbAddrB_reg6(Intra_mbAddrB_reg6), 
		.Intra_mbAddrB_reg7(Intra_mbAddrB_reg7),
		.Intra_mbAddrB_reg8(Intra_mbAddrB_reg8), 
		.Intra_mbAddrB_reg9(Intra_mbAddrB_reg9), 
		.Intra_mbAddrB_reg10(Intra_mbAddrB_reg10),
		.Intra_mbAddrB_reg11(Intra_mbAddrB_reg11),
		.Intra_mbAddrB_reg12(Intra_mbAddrB_reg12),
		.Intra_mbAddrB_reg13(Intra_mbAddrB_reg13),
		.Intra_mbAddrB_reg14(Intra_mbAddrB_reg14),
		.Intra_mbAddrB_reg15(Intra_mbAddrB_reg15),
		.Intra_mbAddrD_window(Intra_mbAddrD_window),
		
		.Intra4x4_predmode(Intra4x4_predmode),
		.blk4x4_intra_preload_counter(blk4x4_intra_preload_counter),
		.blk4x4_intra_precompute_counter(blk4x4_intra_precompute_counter),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.end_of_one_blk4x4_intra(end_of_one_blk4x4_intra),
		.blkAddrA_availability(blkAddrA_availability),
		.blkAddrB_availability(blkAddrB_availability),
		.mbAddrA_availability(mbAddrA_availability),
		.mbAddrB_availability(mbAddrB_availability),
		.mbAddrC_availability(mbAddrC_availability),
		.main_seed(main_seed),
		.plane_b_reg(plane_b_reg),
		.plane_c_reg(plane_c_reg),
		.Intra_mbAddrB_RAM_rd(Intra_mbAddrB_RAM_rd),
		.Intra_mbAddrB_RAM_rd_addr(Intra_mbAddrB_RAM_rd_addr)
		);
		
	Intra_pred_reg_ctrl Intra_pred_reg_ctrl (
		.reset_n(reset_n),
		.gclk_intra_mbAddrA_luma(gclk_intra_mbAddrA_luma),
	 	.gclk_intra_mbAddrA_Cb(gclk_intra_mbAddrA_Cb),
	 	.gclk_intra_mbAddrA_Cr(gclk_intra_mbAddrA_Cr),
	 	.gclk_intra_mbAddrB(gclk_intra_mbAddrB), 
	 	.gclk_intra_mbAddrC_luma(gclk_intra_mbAddrC_luma),	
	 	.gclk_intra_mbAddrD(gclk_intra_mbAddrD),
	 	.gclk_seed(gclk_seed),
		.mbAddrA_availability(mbAddrA_availability),
		.mbAddrC_availability(mbAddrC_availability),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_intra_preload_counter(blk4x4_intra_preload_counter),
		.blk4x4_intra_precompute_counter(blk4x4_intra_precompute_counter),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.mb_type_general(mb_type_general),
		.Intra4x4_predmode(Intra4x4_predmode),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.Intra_mbAddrB_RAM_dout(Intra_mbAddrB_RAM_dout),
		.sum_right_column_reg(sum_right_column_reg),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		.main_seed(main_seed),
		.PE0_sum_out(PE0_sum_out),
		.PE3_sum_out(PE3_sum_out),
		
		.Intra_mbAddrA_window0(Intra_mbAddrA_window0),
		.Intra_mbAddrA_window1(Intra_mbAddrA_window1),
		.Intra_mbAddrA_window2(Intra_mbAddrA_window2),
		.Intra_mbAddrA_window3(Intra_mbAddrA_window3),
		.Intra_mbAddrA_reg0(Intra_mbAddrA_reg0), 
		.Intra_mbAddrA_reg1(Intra_mbAddrA_reg1), 
		.Intra_mbAddrA_reg2(Intra_mbAddrA_reg2), 
		.Intra_mbAddrA_reg3(Intra_mbAddrA_reg3),
		.Intra_mbAddrA_reg4(Intra_mbAddrA_reg4), 
		.Intra_mbAddrA_reg5(Intra_mbAddrA_reg5), 
		.Intra_mbAddrA_reg6(Intra_mbAddrA_reg6), 
		.Intra_mbAddrA_reg7(Intra_mbAddrA_reg7),
		.Intra_mbAddrA_reg8(Intra_mbAddrA_reg8), 
		.Intra_mbAddrA_reg9(Intra_mbAddrA_reg9), 
		.Intra_mbAddrA_reg10(Intra_mbAddrA_reg10),
		.Intra_mbAddrA_reg11(Intra_mbAddrA_reg11),
		.Intra_mbAddrA_reg12(Intra_mbAddrA_reg12),
		.Intra_mbAddrA_reg13(Intra_mbAddrA_reg13),
		.Intra_mbAddrA_reg14(Intra_mbAddrA_reg14),
		.Intra_mbAddrA_reg15(Intra_mbAddrA_reg15),
		.Intra_mbAddrB_window0(Intra_mbAddrB_window0),
		.Intra_mbAddrB_window1(Intra_mbAddrB_window1),
		.Intra_mbAddrB_window2(Intra_mbAddrB_window2),
		.Intra_mbAddrB_window3(Intra_mbAddrB_window3),
		.Intra_mbAddrB_reg0(Intra_mbAddrB_reg0), 
		.Intra_mbAddrB_reg1(Intra_mbAddrB_reg1), 
		.Intra_mbAddrB_reg2(Intra_mbAddrB_reg2), 
		.Intra_mbAddrB_reg3(Intra_mbAddrB_reg3),
		.Intra_mbAddrB_reg4(Intra_mbAddrB_reg4), 
		.Intra_mbAddrB_reg5(Intra_mbAddrB_reg5), 
		.Intra_mbAddrB_reg6(Intra_mbAddrB_reg6), 
		.Intra_mbAddrB_reg7(Intra_mbAddrB_reg7),
		.Intra_mbAddrB_reg8(Intra_mbAddrB_reg8), 
		.Intra_mbAddrB_reg9(Intra_mbAddrB_reg9), 
		.Intra_mbAddrB_reg10(Intra_mbAddrB_reg10),
		.Intra_mbAddrB_reg11(Intra_mbAddrB_reg11),
		.Intra_mbAddrB_reg12(Intra_mbAddrB_reg12),
		.Intra_mbAddrB_reg13(Intra_mbAddrB_reg13),
		.Intra_mbAddrB_reg14(Intra_mbAddrB_reg14),
		.Intra_mbAddrB_reg15(Intra_mbAddrB_reg15),
		.Intra_mbAddrC_window0(Intra_mbAddrC_window0),
		.Intra_mbAddrC_window1(Intra_mbAddrC_window1),
		.Intra_mbAddrC_window2(Intra_mbAddrC_window2),
		.Intra_mbAddrC_window3(Intra_mbAddrC_window3),
		.Intra_mbAddrD_window(Intra_mbAddrD_window),
		.seed(seed)
		); 
	
	Intra_pred_PE Intra_pred_PE (
		.clk(clk),
		.reset_n(reset_n),
		.mb_type_general(mb_type_general),
		.blk4x4_rec_counter(blk4x4_rec_counter),
		.blk4x4_intra_calculate_counter(blk4x4_intra_calculate_counter),
		.Intra4x4_predmode(Intra4x4_predmode),
		.Intra16x16_predmode(Intra16x16_predmode),
		.Intra_chroma_predmode(Intra_chroma_predmode),
		.blkAddrA_availability(blkAddrA_availability),
		.blkAddrB_availability(blkAddrB_availability),
		.mbAddrA_availability(mbAddrA_availability),
		.mbAddrB_availability(mbAddrB_availability), 
		.Intra_mbAddrA_window0({8'b0,Intra_mbAddrA_window0}),
		.Intra_mbAddrA_window1({8'b0,Intra_mbAddrA_window1}),
		.Intra_mbAddrA_window2({8'b0,Intra_mbAddrA_window2}),
		.Intra_mbAddrA_window3({8'b0,Intra_mbAddrA_window3}),
		.Intra_mbAddrB_window0({8'b0,Intra_mbAddrB_window0}),
		.Intra_mbAddrB_window1({8'b0,Intra_mbAddrB_window1}),
		.Intra_mbAddrB_window2({8'b0,Intra_mbAddrB_window2}),
		.Intra_mbAddrB_window3({8'b0,Intra_mbAddrB_window3}),
		.Intra_mbAddrC_window0({8'b0,Intra_mbAddrC_window0}),
		.Intra_mbAddrC_window1({8'b0,Intra_mbAddrC_window1}),
		.Intra_mbAddrC_window2({8'b0,Intra_mbAddrC_window2}),
		.Intra_mbAddrC_window3({8'b0,Intra_mbAddrC_window3}),
		.Intra_mbAddrD_window({8'b0,Intra_mbAddrD_window}),
		.Intra_mbAddrA_reg0({8'b0,Intra_mbAddrA_reg0}), 
		.Intra_mbAddrA_reg1({8'b0,Intra_mbAddrA_reg1}), 
		.Intra_mbAddrA_reg2({8'b0,Intra_mbAddrA_reg2}), 
		.Intra_mbAddrA_reg3({8'b0,Intra_mbAddrA_reg3}),
		.Intra_mbAddrA_reg4({8'b0,Intra_mbAddrA_reg4}), 
		.Intra_mbAddrA_reg5({8'b0,Intra_mbAddrA_reg5}), 
		.Intra_mbAddrA_reg6({8'b0,Intra_mbAddrA_reg6}), 
		.Intra_mbAddrA_reg7({8'b0,Intra_mbAddrA_reg7}),
		.Intra_mbAddrA_reg8({8'b0,Intra_mbAddrA_reg8}), 
		.Intra_mbAddrA_reg9({8'b0,Intra_mbAddrA_reg9}), 
		.Intra_mbAddrA_reg10({8'b0,Intra_mbAddrA_reg10}),
		.Intra_mbAddrA_reg11({8'b0,Intra_mbAddrA_reg11}),
		.Intra_mbAddrA_reg12({8'b0,Intra_mbAddrA_reg12}),
		.Intra_mbAddrA_reg13({8'b0,Intra_mbAddrA_reg13}),
		.Intra_mbAddrA_reg14({8'b0,Intra_mbAddrA_reg14}),
		.Intra_mbAddrA_reg15({8'b0,Intra_mbAddrA_reg15}),
		.Intra_mbAddrB_reg0({8'b0,Intra_mbAddrB_reg0}), 
		.Intra_mbAddrB_reg1({8'b0,Intra_mbAddrB_reg1}), 
		.Intra_mbAddrB_reg2({8'b0,Intra_mbAddrB_reg2}), 
		.Intra_mbAddrB_reg3({8'b0,Intra_mbAddrB_reg3}),
		.Intra_mbAddrB_reg4({8'b0,Intra_mbAddrB_reg4}), 
		.Intra_mbAddrB_reg5({8'b0,Intra_mbAddrB_reg5}), 
		.Intra_mbAddrB_reg6({8'b0,Intra_mbAddrB_reg6}), 
		.Intra_mbAddrB_reg7({8'b0,Intra_mbAddrB_reg7}),
		.Intra_mbAddrB_reg8({8'b0,Intra_mbAddrB_reg8}), 
		.Intra_mbAddrB_reg9({8'b0,Intra_mbAddrB_reg9}), 
		.Intra_mbAddrB_reg10({8'b0,Intra_mbAddrB_reg10}),
		.Intra_mbAddrB_reg11({8'b0,Intra_mbAddrB_reg11}),
		.Intra_mbAddrB_reg12({8'b0,Intra_mbAddrB_reg12}),
		.Intra_mbAddrB_reg13({8'b0,Intra_mbAddrB_reg13}),
		.Intra_mbAddrB_reg14({8'b0,Intra_mbAddrB_reg14}),
		.Intra_mbAddrB_reg15({8'b0,Intra_mbAddrB_reg15}),
		.blk4x4_pred_output0({8'b0,blk4x4_pred_output0}), 
		.blk4x4_pred_output1({8'b0,blk4x4_pred_output1}), 
		.blk4x4_pred_output2({8'b0,blk4x4_pred_output2}),
		.blk4x4_pred_output4({8'b0,blk4x4_pred_output4}), 
		.blk4x4_pred_output5({8'b0,blk4x4_pred_output5}), 
		.blk4x4_pred_output6({8'b0,blk4x4_pred_output6}),
		.blk4x4_pred_output8({8'b0,blk4x4_pred_output8}), 
		.blk4x4_pred_output9({8'b0,blk4x4_pred_output9}), 
		.blk4x4_pred_output10({8'b0,blk4x4_pred_output10}),
		.blk4x4_pred_output12({8'b0,blk4x4_pred_output12}),
		.blk4x4_pred_output13({8'b0,blk4x4_pred_output13}),
		.blk4x4_pred_output14({8'b0,blk4x4_pred_output14}),
		.seed(seed),
		.b(plane_b_reg),
		.c(plane_c_reg),  
		
		.PE0_out(PE0_out),
		.PE1_out(PE1_out),
		.PE2_out(PE2_out),
		.PE3_out(PE3_out),
		.PE0_sum_out(PE0_sum_out),
		.PE3_sum_out(PE3_sum_out)
		); 
	ram_sync_1r_sync_1w #(`Intra_mbAddrB_RAM_data_width,`Intra_mbAddrB_RAM_data_depth)
	Intra_mbAddrB_RAM (
		.clk(gclk_Intra_mbAddrB_RAM),
		.rst_n(reset_n),
		.wr_n(~Intra_mbAddrB_RAM_wr),
		.rd_n(~Intra_mbAddrB_RAM_rd),
		.wr_addr(Intra_mbAddrB_RAM_wr_addr),
		.rd_addr(Intra_mbAddrB_RAM_rd_addr),
		.data_in(Intra_mbAddrB_RAM_din),
		.data_out(Intra_mbAddrB_RAM_dout)
		); 
endmodule