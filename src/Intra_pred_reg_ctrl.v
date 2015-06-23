//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Intra_pred_reg_ctrl.v
// Generated : Sep 25, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Prepare the appropriate registers for PE0 ~ PE3
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Intra_pred_reg_ctrl (reset_n,gclk_intra_mbAddrA_luma,gclk_intra_mbAddrA_Cb,
	gclk_intra_mbAddrA_Cr,gclk_intra_mbAddrB,gclk_intra_mbAddrC_luma,gclk_intra_mbAddrD,gclk_seed,
	mbAddrA_availability,mbAddrC_availability,blk4x4_rec_counter,blk4x4_sum_counter,
	blk4x4_intra_preload_counter,blk4x4_intra_precompute_counter,blk4x4_intra_calculate_counter,
	mb_type_general,Intra4x4_predmode,Intra16x16_predmode,Intra_chroma_predmode,
	
	Intra_mbAddrB_RAM_dout,sum_right_column_reg,
	blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	main_seed,PE0_sum_out,PE3_sum_out,
	
	Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3,
	Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3,
	Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7,
	Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11,
	Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15,
	
	Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3,
	Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3,
	Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7,
	Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11,
	Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15,
	
	Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3,Intra_mbAddrD_window,
	seed);	
	input reset_n;
	input gclk_intra_mbAddrA_luma;
	input gclk_intra_mbAddrA_Cb;
	input gclk_intra_mbAddrA_Cr;
	input gclk_intra_mbAddrB; 
	input gclk_intra_mbAddrC_luma;	
	input gclk_intra_mbAddrD;
	input gclk_seed;
	input mbAddrA_availability;	
	input mbAddrC_availability;
	input [4:0] blk4x4_rec_counter;
	input [2:0] blk4x4_sum_counter;
	input [2:0] blk4x4_intra_preload_counter;
	input [3:0] blk4x4_intra_precompute_counter;
	input [2:0] blk4x4_intra_calculate_counter;
	input [3:0] mb_type_general;
	input [3:0] Intra4x4_predmode;
	input [1:0] Intra16x16_predmode;
	input [1:0] Intra_chroma_predmode;
	input [31:0] Intra_mbAddrB_RAM_dout;
	input [23:0] sum_right_column_reg;
	input [7:0]  blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	input [15:0] main_seed;
	input [15:0] PE0_sum_out,PE3_sum_out;
	
	output [7:0] Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3;
	output [7:0] Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3;
	output [7:0] Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7;
	output [7:0] Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11;
	output [7:0] Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15;
	
	output [7:0] Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3;
	output [7:0] Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3;
	output [7:0] Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7;
	output [7:0] Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11;
	output [7:0] Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15;
	
	output [7:0] Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3; 
	output [7:0] Intra_mbAddrD_window;
	output [15:0] seed;
	
	reg [7:0] Intra_mbAddrA_luma_reg0, Intra_mbAddrA_luma_reg1, Intra_mbAddrA_luma_reg2, Intra_mbAddrA_luma_reg3;
	reg [7:0] Intra_mbAddrA_luma_reg4, Intra_mbAddrA_luma_reg5, Intra_mbAddrA_luma_reg6, Intra_mbAddrA_luma_reg7;
	reg [7:0] Intra_mbAddrA_luma_reg8, Intra_mbAddrA_luma_reg9, Intra_mbAddrA_luma_reg10,Intra_mbAddrA_luma_reg11;
	reg [7:0] Intra_mbAddrA_luma_reg12,Intra_mbAddrA_luma_reg13,Intra_mbAddrA_luma_reg14,Intra_mbAddrA_luma_reg15;
	reg [7:0] Intra_mbAddrA_Cb_reg0,Intra_mbAddrA_Cb_reg1,Intra_mbAddrA_Cb_reg2,Intra_mbAddrA_Cb_reg3;
	reg [7:0] Intra_mbAddrA_Cb_reg4,Intra_mbAddrA_Cb_reg5,Intra_mbAddrA_Cb_reg6,Intra_mbAddrA_Cb_reg7;
	reg [7:0] Intra_mbAddrA_Cr_reg0,Intra_mbAddrA_Cr_reg1,Intra_mbAddrA_Cr_reg2,Intra_mbAddrA_Cr_reg3;
	reg [7:0] Intra_mbAddrA_Cr_reg4,Intra_mbAddrA_Cr_reg5,Intra_mbAddrA_Cr_reg6,Intra_mbAddrA_Cr_reg7;
	reg [7:0] Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3;
	reg [7:0] Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7;
	reg [7:0] Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11;
	reg [7:0] Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15;
	reg [7:0] Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3;
	
	reg [7:0] Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3;
	reg [7:0] Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7;
	reg [7:0] Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11;
	reg [7:0] Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15;
	reg [7:0] Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3;
	
	reg [7:0] Intra_mbAddrC_reg0,Intra_mbAddrC_reg1,Intra_mbAddrC_reg2,Intra_mbAddrC_reg3; 
	reg [7:0] Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3;
	
	reg [7:0] Intra_mbAddrD_reg0,Intra_mbAddrD_reg1,Intra_mbAddrD_reg2;
	reg [7:0] Intra_mbAddrD_reg3,Intra_mbAddrD_reg4;
	reg [7:0] Intra_mbAddrD_LeftMB_luma_reg,Intra_mbAddrD_LeftMB_Cb_reg,Intra_mbAddrD_LeftMB_Cr_reg;
	reg [7:0] Intra_mbAddrD_window;	
	
	reg [15:0] seed_0,seed_1,seed_2,seed_3;
	reg [15:0] seed;
	//---------------------------------------------------------------------
	//Intra_mbAddrA_luma_reg0 ~ 15
	//Intra_mbAddrA_Cb_reg0 ~ 7
	//Intra_mbAddrA_Cr_reg0 ~ 7
	//---------------------------------------------------------------------
	always @ (posedge gclk_intra_mbAddrA_luma or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				Intra_mbAddrA_luma_reg0  <= 0;	Intra_mbAddrA_luma_reg1  <= 0; Intra_mbAddrA_luma_reg2  <= 0;
				Intra_mbAddrA_luma_reg3  <= 0;	Intra_mbAddrA_luma_reg4  <= 0; Intra_mbAddrA_luma_reg5  <= 0;
				Intra_mbAddrA_luma_reg6  <= 0;	Intra_mbAddrA_luma_reg7  <= 0; Intra_mbAddrA_luma_reg8  <= 0;
				Intra_mbAddrA_luma_reg9  <= 0;	Intra_mbAddrA_luma_reg10 <= 0; Intra_mbAddrA_luma_reg11 <= 0;
				Intra_mbAddrA_luma_reg12 <= 0;	Intra_mbAddrA_luma_reg13 <= 0; Intra_mbAddrA_luma_reg14 <= 0;
				Intra_mbAddrA_luma_reg15 <= 0;	
			end
		else
			case (blk4x4_rec_counter)
				0,1,4,5:
				begin
					Intra_mbAddrA_luma_reg0  <= sum_right_column_reg[7:0];
					Intra_mbAddrA_luma_reg1  <= sum_right_column_reg[15:8];
					Intra_mbAddrA_luma_reg2  <= sum_right_column_reg[23:16];
					Intra_mbAddrA_luma_reg3  <= blk4x4_sum_PE3_out;
				end
				2,3,6,7:
				begin
					Intra_mbAddrA_luma_reg4  <= sum_right_column_reg[7:0];
					Intra_mbAddrA_luma_reg5  <= sum_right_column_reg[15:8];
					Intra_mbAddrA_luma_reg6  <= sum_right_column_reg[23:16];
					Intra_mbAddrA_luma_reg7  <= blk4x4_sum_PE3_out;
				end
				8,9,12,13:
				begin
					Intra_mbAddrA_luma_reg8  <= sum_right_column_reg[7:0];
					Intra_mbAddrA_luma_reg9  <= sum_right_column_reg[15:8];
					Intra_mbAddrA_luma_reg10 <= sum_right_column_reg[23:16];
					Intra_mbAddrA_luma_reg11 <= blk4x4_sum_PE3_out;
				end
				10,11,14,15:
				begin
					Intra_mbAddrA_luma_reg12 <= sum_right_column_reg[7:0];
					Intra_mbAddrA_luma_reg13 <= sum_right_column_reg[15:8];
					Intra_mbAddrA_luma_reg14 <= sum_right_column_reg[23:16];
					Intra_mbAddrA_luma_reg15 <= blk4x4_sum_PE3_out;
				end
			endcase
		
	always @ (posedge gclk_intra_mbAddrA_Cb or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				Intra_mbAddrA_Cb_reg0  <= 0;	Intra_mbAddrA_Cb_reg1  <= 0; Intra_mbAddrA_Cb_reg2  <= 0;
				Intra_mbAddrA_Cb_reg3  <= 0;	Intra_mbAddrA_Cb_reg4  <= 0; Intra_mbAddrA_Cb_reg5  <= 0;
				Intra_mbAddrA_Cb_reg6  <= 0;	Intra_mbAddrA_Cb_reg7  <= 0; 
			end
		else if (blk4x4_rec_counter == 17)
			begin
				Intra_mbAddrA_Cb_reg0 <= sum_right_column_reg[7:0];
				Intra_mbAddrA_Cb_reg1 <= sum_right_column_reg[15:8];
				Intra_mbAddrA_Cb_reg2 <= sum_right_column_reg[23:16];
				Intra_mbAddrA_Cb_reg3 <= blk4x4_sum_PE3_out;
			end
		else
			begin
				Intra_mbAddrA_Cb_reg4 <= sum_right_column_reg[7:0];
				Intra_mbAddrA_Cb_reg5 <= sum_right_column_reg[15:8];
				Intra_mbAddrA_Cb_reg6 <= sum_right_column_reg[23:16];
				Intra_mbAddrA_Cb_reg7 <= blk4x4_sum_PE3_out;
			end	
	
	always @ (posedge gclk_intra_mbAddrA_Cr or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				Intra_mbAddrA_Cr_reg0  <= 0;	Intra_mbAddrA_Cr_reg1  <= 0; Intra_mbAddrA_Cr_reg2  <= 0;
				Intra_mbAddrA_Cr_reg3  <= 0;	Intra_mbAddrA_Cr_reg4  <= 0; Intra_mbAddrA_Cr_reg5  <= 0;
				Intra_mbAddrA_Cr_reg6  <= 0;	Intra_mbAddrA_Cr_reg7  <= 0; 
			end
		else if (blk4x4_rec_counter == 21)
			begin
				Intra_mbAddrA_Cr_reg0 <= sum_right_column_reg[7:0];
				Intra_mbAddrA_Cr_reg1 <= sum_right_column_reg[15:8];
				Intra_mbAddrA_Cr_reg2 <= sum_right_column_reg[23:16];
				Intra_mbAddrA_Cr_reg3 <= blk4x4_sum_PE3_out;
			end
		else
			begin
				Intra_mbAddrA_Cr_reg4 <= sum_right_column_reg[7:0];
				Intra_mbAddrA_Cr_reg5 <= sum_right_column_reg[15:8];
				Intra_mbAddrA_Cr_reg6 <= sum_right_column_reg[23:16];
				Intra_mbAddrA_Cr_reg7 <= blk4x4_sum_PE3_out;
			end
	//---------------------------------------------------------------------
	//Intra_mbAddrB_reg0 ~ 15
	//---------------------------------------------------------------------
	always @ (posedge gclk_intra_mbAddrB or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				Intra_mbAddrB_reg0  <= 0;	Intra_mbAddrB_reg1  <= 0; Intra_mbAddrB_reg2  <= 0;
				Intra_mbAddrB_reg3  <= 0;	Intra_mbAddrB_reg4  <= 0; Intra_mbAddrB_reg5  <= 0;
				Intra_mbAddrB_reg6  <= 0;	Intra_mbAddrB_reg7  <= 0; Intra_mbAddrB_reg8  <= 0;
				Intra_mbAddrB_reg9  <= 0;	Intra_mbAddrB_reg10 <= 0; Intra_mbAddrB_reg11 <= 0;
				Intra_mbAddrB_reg12 <= 0;	Intra_mbAddrB_reg13 <= 0; Intra_mbAddrB_reg14 <= 0;
				Intra_mbAddrB_reg15 <= 0;	
			end
		//Intra4x4
		else if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)
			begin
				//	blk 0,1,4,5,load from RAM
				if (blk4x4_intra_preload_counter == 3'b001)
					case (blk4x4_rec_counter)
						0:
						begin
							Intra_mbAddrB_reg0  <= Intra_mbAddrB_RAM_dout[7:0];
							Intra_mbAddrB_reg1  <= Intra_mbAddrB_RAM_dout[15:8];
							Intra_mbAddrB_reg2  <= Intra_mbAddrB_RAM_dout[23:16];
							Intra_mbAddrB_reg3  <= Intra_mbAddrB_RAM_dout[31:24];
						end
						1:
						begin
							Intra_mbAddrB_reg4  <= Intra_mbAddrB_RAM_dout[7:0];
							Intra_mbAddrB_reg5  <= Intra_mbAddrB_RAM_dout[15:8];
							Intra_mbAddrB_reg6  <= Intra_mbAddrB_RAM_dout[23:16];
							Intra_mbAddrB_reg7  <= Intra_mbAddrB_RAM_dout[31:24];
						end
						4:
						begin
							Intra_mbAddrB_reg8  <= Intra_mbAddrB_RAM_dout[7:0];
							Intra_mbAddrB_reg9  <= Intra_mbAddrB_RAM_dout[15:8];
							Intra_mbAddrB_reg10 <= Intra_mbAddrB_RAM_dout[23:16];
							Intra_mbAddrB_reg11 <= Intra_mbAddrB_RAM_dout[31:24];
						end
						5:
						begin
							Intra_mbAddrB_reg12 <= Intra_mbAddrB_RAM_dout[7:0];
							Intra_mbAddrB_reg13 <= Intra_mbAddrB_RAM_dout[15:8];
							Intra_mbAddrB_reg14 <= Intra_mbAddrB_RAM_dout[23:16];
							Intra_mbAddrB_reg15 <= Intra_mbAddrB_RAM_dout[31:24];
						end
					endcase	
				//other blocks,from blk4x4_sum output
				else if ((blk4x4_rec_counter != 10 || blk4x4_rec_counter != 11 || blk4x4_rec_counter != 14 ||
					blk4x4_rec_counter != 15) && blk4x4_sum_counter == 3'd3)
					case (blk4x4_rec_counter)
						0,2,8:
						begin
							Intra_mbAddrB_reg0  <= blk4x4_sum_PE0_out;
							Intra_mbAddrB_reg1  <= blk4x4_sum_PE1_out;
							Intra_mbAddrB_reg2  <= blk4x4_sum_PE2_out;
							Intra_mbAddrB_reg3  <= blk4x4_sum_PE3_out;
						end
						1,3,9:
						begin
							Intra_mbAddrB_reg4  <= blk4x4_sum_PE0_out;
							Intra_mbAddrB_reg5  <= blk4x4_sum_PE1_out;
							Intra_mbAddrB_reg6  <= blk4x4_sum_PE2_out;
							Intra_mbAddrB_reg7  <= blk4x4_sum_PE3_out;
						end
						4,6,12:
						begin
							Intra_mbAddrB_reg8  <= blk4x4_sum_PE0_out;
							Intra_mbAddrB_reg9  <= blk4x4_sum_PE1_out;
							Intra_mbAddrB_reg10 <= blk4x4_sum_PE2_out;
							Intra_mbAddrB_reg11 <= blk4x4_sum_PE3_out;
						end
						5,7,13:
						begin
							Intra_mbAddrB_reg12 <= blk4x4_sum_PE0_out;
							Intra_mbAddrB_reg13 <= blk4x4_sum_PE1_out;
							Intra_mbAddrB_reg14 <= blk4x4_sum_PE2_out;
							Intra_mbAddrB_reg15 <= blk4x4_sum_PE3_out;
						end
					endcase
			end
		//Intra16x16
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			case (blk4x4_intra_preload_counter)
				3'b100:	
				begin
					Intra_mbAddrB_reg0  <= Intra_mbAddrB_RAM_dout[7:0];
					Intra_mbAddrB_reg1  <= Intra_mbAddrB_RAM_dout[15:8];
					Intra_mbAddrB_reg2  <= Intra_mbAddrB_RAM_dout[23:16];
					Intra_mbAddrB_reg3  <= Intra_mbAddrB_RAM_dout[31:24];
				end
				3'b011:
				begin
					Intra_mbAddrB_reg4  <= Intra_mbAddrB_RAM_dout[7:0];
					Intra_mbAddrB_reg5  <= Intra_mbAddrB_RAM_dout[15:8];
					Intra_mbAddrB_reg6  <= Intra_mbAddrB_RAM_dout[23:16];
					Intra_mbAddrB_reg7  <= Intra_mbAddrB_RAM_dout[31:24];
				end
				3'b010:
				begin
					Intra_mbAddrB_reg8  <= Intra_mbAddrB_RAM_dout[7:0];
					Intra_mbAddrB_reg9  <= Intra_mbAddrB_RAM_dout[15:8];
					Intra_mbAddrB_reg10 <= Intra_mbAddrB_RAM_dout[23:16];
					Intra_mbAddrB_reg11 <= Intra_mbAddrB_RAM_dout[31:24];
				end
				3'b001:
				begin
					Intra_mbAddrB_reg12 <= Intra_mbAddrB_RAM_dout[7:0];
					Intra_mbAddrB_reg13 <= Intra_mbAddrB_RAM_dout[15:8];
					Intra_mbAddrB_reg14 <= Intra_mbAddrB_RAM_dout[23:16];
					Intra_mbAddrB_reg15 <= Intra_mbAddrB_RAM_dout[31:24];
				end
			endcase	
		//Chroma
		else if (mb_type_general[3] == 1'b1 && blk4x4_rec_counter > 15)
			begin
				if (blk4x4_intra_preload_counter == 3'b010)
					begin
						Intra_mbAddrB_reg0  <= Intra_mbAddrB_RAM_dout[7:0];
						Intra_mbAddrB_reg1  <= Intra_mbAddrB_RAM_dout[15:8];
						Intra_mbAddrB_reg2  <= Intra_mbAddrB_RAM_dout[23:16];
						Intra_mbAddrB_reg3  <= Intra_mbAddrB_RAM_dout[31:24];
					end
				else if (blk4x4_intra_preload_counter == 3'b001)
					begin
						Intra_mbAddrB_reg4  <= Intra_mbAddrB_RAM_dout[7:0];
						Intra_mbAddrB_reg5  <= Intra_mbAddrB_RAM_dout[15:8];
						Intra_mbAddrB_reg6  <= Intra_mbAddrB_RAM_dout[23:16];
						Intra_mbAddrB_reg7  <= Intra_mbAddrB_RAM_dout[31:24];
					end	
			end	
	//--------------------------------------------------------
	//Intra_mbAddrC_reg0 ~ 3,only useful for Intra4x4 with
	// blkIdx = 0/1/4/5
	//--------------------------------------------------------

	always @ (posedge gclk_intra_mbAddrC_luma or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				Intra_mbAddrC_reg0  <= 0;	Intra_mbAddrC_reg1  <= 0; 
				Intra_mbAddrC_reg2  <= 0;	Intra_mbAddrC_reg3  <= 0;
			end
		else 
			begin
				Intra_mbAddrC_reg0  <= Intra_mbAddrB_RAM_dout[7:0];
				Intra_mbAddrC_reg1  <= Intra_mbAddrB_RAM_dout[15:8];
				Intra_mbAddrC_reg2  <= Intra_mbAddrB_RAM_dout[23:16];
				Intra_mbAddrC_reg3  <= Intra_mbAddrB_RAM_dout[31:24];
			end
	//--------------------------------------------------------
	//Intra_mbAddrD_reg0 ~ 5
	//Intra_mbAddrD_LeftMB_reg
	//--------------------------------------------------------
	always @ (posedge gclk_intra_mbAddrD or negedge reset_n)
		if (reset_n == 1'b0)
			Intra_mbAddrD_LeftMB_luma_reg <= 0;
		else if (blk4x4_rec_counter == 15)
			Intra_mbAddrD_LeftMB_luma_reg <= Intra_mbAddrB_RAM_dout[31:24];
		else if (mb_type_general[3:2] == 2'b11 && blk4x4_sum_counter == 3'd3)	//Intra4x4
			case (blk4x4_rec_counter)
				0:Intra_mbAddrD_LeftMB_luma_reg <= Intra_mbAddrA_reg3;
				2:Intra_mbAddrD_LeftMB_luma_reg <= Intra_mbAddrA_reg7;
				8:Intra_mbAddrD_LeftMB_luma_reg <= Intra_mbAddrA_reg11;
			endcase

	always @ (posedge gclk_intra_mbAddrD or negedge reset_n)
		if (reset_n == 1'b0)
			Intra_mbAddrD_LeftMB_Cb_reg <= 0;
		else if (blk4x4_rec_counter == 19)
			Intra_mbAddrD_LeftMB_Cb_reg <= Intra_mbAddrB_RAM_dout[31:24];
			
	always @ (posedge gclk_intra_mbAddrD or negedge reset_n)
		if (reset_n == 1'b0)
			Intra_mbAddrD_LeftMB_Cr_reg <= 0;
		else if (blk4x4_rec_counter == 23)
			Intra_mbAddrD_LeftMB_Cr_reg <= Intra_mbAddrB_RAM_dout[31:24];		
			
	always @ (posedge gclk_intra_mbAddrD or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				Intra_mbAddrD_reg0 <= 0; Intra_mbAddrD_reg1 <= 0; Intra_mbAddrD_reg2 <= 0;	
				Intra_mbAddrD_reg3 <= 0; Intra_mbAddrD_reg4 <= 0; 
			end
		else if (mb_type_general[3:2] == 2'b11)
			begin
				//load from Intra_mbAddrB_RAM for blk 1/4/5
				if (blk4x4_intra_preload_counter == 3'b010)
					case (blk4x4_rec_counter)
						1:Intra_mbAddrD_reg1 <= Intra_mbAddrB_RAM_dout[31:24];
						4:Intra_mbAddrD_reg4 <= Intra_mbAddrB_RAM_dout[31:24];
						5:Intra_mbAddrD_reg0 <= Intra_mbAddrB_RAM_dout[31:24];
					endcase
				//update Intra_mbAddrD_reg by pixels already decoded from left up blk4x4
				//After sum of blk0/1/4, update Intra_mbAddrD_reg0/1/2 for blkIdx 3 /6 /7
				//After sum of blk2/3/6, update Intra_mbAddrD_reg3/4/5 for blkIdx 9 /12/13
				//After sum of blk8/9/12,update Intra_mbAddrD_reg0/1/2 for blkIdx 11/14/15
				else
					case (blk4x4_rec_counter)
						0,6 :Intra_mbAddrD_reg0 <= blk4x4_sum_PE3_out;
						1,8 :Intra_mbAddrD_reg1 <= blk4x4_sum_PE3_out;
						2,12:Intra_mbAddrD_reg2 <= blk4x4_sum_PE3_out;
						3   :Intra_mbAddrD_reg3 <= blk4x4_sum_PE3_out;
						4,9	:Intra_mbAddrD_reg4 <= blk4x4_sum_PE3_out;
					endcase
			end
	//---------------------------
	//sliding window output
	//---------------------------
	//Intra_mbAddrA_reg0 ~ 15
	always @ (mb_type_general[3:2] or blk4x4_rec_counter or blk4x4_intra_calculate_counter or 
		blk4x4_intra_precompute_counter or Intra16x16_predmode or Intra_chroma_predmode
		or mbAddrA_availability
		
		or Intra_mbAddrA_luma_reg0  or Intra_mbAddrA_luma_reg1  or Intra_mbAddrA_luma_reg2 
		or Intra_mbAddrA_luma_reg3  or Intra_mbAddrA_luma_reg4  or Intra_mbAddrA_luma_reg5
		or Intra_mbAddrA_luma_reg6  or Intra_mbAddrA_luma_reg7  or Intra_mbAddrA_luma_reg8
		or Intra_mbAddrA_luma_reg9  or Intra_mbAddrA_luma_reg10 or Intra_mbAddrA_luma_reg11
		or Intra_mbAddrA_luma_reg12 or Intra_mbAddrA_luma_reg13 or Intra_mbAddrA_luma_reg14
		or Intra_mbAddrA_luma_reg15
		
		or Intra_mbAddrA_Cb_reg0 or Intra_mbAddrA_Cb_reg1 or Intra_mbAddrA_Cb_reg2
		or Intra_mbAddrA_Cb_reg3 or Intra_mbAddrA_Cb_reg4 or Intra_mbAddrA_Cb_reg5
		or Intra_mbAddrA_Cb_reg6 or Intra_mbAddrA_Cb_reg7
		
		or Intra_mbAddrA_Cr_reg0 or Intra_mbAddrA_Cr_reg1 or Intra_mbAddrA_Cr_reg2
		or Intra_mbAddrA_Cr_reg3 or Intra_mbAddrA_Cr_reg4 or Intra_mbAddrA_Cr_reg5
		or Intra_mbAddrA_Cr_reg6 or Intra_mbAddrA_Cr_reg7)
		if (mb_type_general[3] == 1'b1)
			begin
				//Intra4x4
				//Intra16x16_Horizontal,Intra16x16_DC,Intra16x16_Plane
				if (blk4x4_rec_counter < 16 && 
					(mb_type_general[2] == 1'b1 || (mb_type_general[2] == 1'b0 && (
					(Intra16x16_predmode == `Intra16x16_Horizontal && blk4x4_intra_calculate_counter  != 0) ||
					(Intra16x16_predmode == `Intra16x16_DC 	 	     && blk4x4_intra_calculate_counter  != 0 && mbAddrA_availability == 1'b1) ||
					(Intra16x16_predmode == `Intra16x16_Plane      && blk4x4_intra_precompute_counter != 0)))))
					begin
						Intra_mbAddrA_reg0  <= Intra_mbAddrA_luma_reg0;
						Intra_mbAddrA_reg1  <= Intra_mbAddrA_luma_reg1;
						Intra_mbAddrA_reg2  <= Intra_mbAddrA_luma_reg2;
						Intra_mbAddrA_reg3  <= Intra_mbAddrA_luma_reg3;
						Intra_mbAddrA_reg4  <= Intra_mbAddrA_luma_reg4;
						Intra_mbAddrA_reg5  <= Intra_mbAddrA_luma_reg5;
						Intra_mbAddrA_reg6  <= Intra_mbAddrA_luma_reg6;
						Intra_mbAddrA_reg7  <= Intra_mbAddrA_luma_reg7;
						Intra_mbAddrA_reg8  <= Intra_mbAddrA_luma_reg8;
						Intra_mbAddrA_reg9  <= Intra_mbAddrA_luma_reg9;
						Intra_mbAddrA_reg10 <= Intra_mbAddrA_luma_reg10;
						Intra_mbAddrA_reg11 <= Intra_mbAddrA_luma_reg11;
						Intra_mbAddrA_reg12 <= Intra_mbAddrA_luma_reg12;
						Intra_mbAddrA_reg13 <= Intra_mbAddrA_luma_reg13;
						Intra_mbAddrA_reg14 <= Intra_mbAddrA_luma_reg14;
						Intra_mbAddrA_reg15 <= Intra_mbAddrA_luma_reg15;
					end
				//Chroma Cb
				else if (blk4x4_rec_counter > 15 && blk4x4_rec_counter < 20 && (
					(Intra_chroma_predmode == `Intra_chroma_Horizontal && blk4x4_intra_calculate_counter  != 0) ||
					(Intra_chroma_predmode == `Intra_chroma_DC         && blk4x4_intra_calculate_counter  != 0 && mbAddrA_availability == 1'b1) 														   ||
					(Intra_chroma_predmode == `Intra_chroma_Plane      && blk4x4_intra_precompute_counter != 0)))
					begin
						Intra_mbAddrA_reg0  <= Intra_mbAddrA_Cb_reg0;
						Intra_mbAddrA_reg1  <= Intra_mbAddrA_Cb_reg1;
						Intra_mbAddrA_reg2  <= Intra_mbAddrA_Cb_reg2;
						Intra_mbAddrA_reg3  <= Intra_mbAddrA_Cb_reg3;
						Intra_mbAddrA_reg4  <= Intra_mbAddrA_Cb_reg4;
						Intra_mbAddrA_reg5  <= Intra_mbAddrA_Cb_reg5;
						Intra_mbAddrA_reg6  <= Intra_mbAddrA_Cb_reg6;
						Intra_mbAddrA_reg7  <= Intra_mbAddrA_Cb_reg7;
						Intra_mbAddrA_reg8  <= 0;	Intra_mbAddrA_reg9  <= 0;
						Intra_mbAddrA_reg10 <= 0;	Intra_mbAddrA_reg11 <= 0;
						Intra_mbAddrA_reg12 <= 0;	Intra_mbAddrA_reg13 <= 0;
						Intra_mbAddrA_reg14 <= 0;	Intra_mbAddrA_reg15 <= 0;
					end
				//Chroma Cr
				else if (blk4x4_rec_counter > 19 && blk4x4_rec_counter < 24 && (
					(Intra_chroma_predmode == `Intra_chroma_Horizontal && blk4x4_intra_calculate_counter  != 0) ||
					(Intra_chroma_predmode == `Intra_chroma_DC         && blk4x4_intra_calculate_counter  != 0 && mbAddrA_availability == 1'b1) 														   ||
					(Intra_chroma_predmode == `Intra_chroma_Plane      && blk4x4_intra_precompute_counter != 0)))
					begin
						Intra_mbAddrA_reg0  <= Intra_mbAddrA_Cr_reg0;
						Intra_mbAddrA_reg1  <= Intra_mbAddrA_Cr_reg1;
						Intra_mbAddrA_reg2  <= Intra_mbAddrA_Cr_reg2;
						Intra_mbAddrA_reg3  <= Intra_mbAddrA_Cr_reg3;
						Intra_mbAddrA_reg4  <= Intra_mbAddrA_Cr_reg4;
						Intra_mbAddrA_reg5  <= Intra_mbAddrA_Cr_reg5;
						Intra_mbAddrA_reg6  <= Intra_mbAddrA_Cr_reg6;
						Intra_mbAddrA_reg7  <= Intra_mbAddrA_Cr_reg7;
						Intra_mbAddrA_reg8  <= 0;	Intra_mbAddrA_reg9  <= 0;
						Intra_mbAddrA_reg10 <= 0;	Intra_mbAddrA_reg11 <= 0;
						Intra_mbAddrA_reg12 <= 0;	Intra_mbAddrA_reg13 <= 0;
						Intra_mbAddrA_reg14 <= 0;	Intra_mbAddrA_reg15 <= 0;
					end
				else
					begin
						Intra_mbAddrA_reg0  <= 0;	Intra_mbAddrA_reg1  <= 0;
						Intra_mbAddrA_reg2  <= 0;	Intra_mbAddrA_reg3  <= 0;
						Intra_mbAddrA_reg4  <= 0;	Intra_mbAddrA_reg5  <= 0;
						Intra_mbAddrA_reg6  <= 0;	Intra_mbAddrA_reg7  <= 0;
						Intra_mbAddrA_reg8  <= 0;	Intra_mbAddrA_reg9  <= 0;
						Intra_mbAddrA_reg10 <= 0;	Intra_mbAddrA_reg11 <= 0;
						Intra_mbAddrA_reg12 <= 0;	Intra_mbAddrA_reg13 <= 0;
						Intra_mbAddrA_reg14 <= 0;	Intra_mbAddrA_reg15 <= 0;
					end
			end
		else
			begin
				Intra_mbAddrA_reg0  <= 0;	Intra_mbAddrA_reg1  <= 0;
				Intra_mbAddrA_reg2  <= 0;	Intra_mbAddrA_reg3  <= 0;
				Intra_mbAddrA_reg4  <= 0;	Intra_mbAddrA_reg5  <= 0;
				Intra_mbAddrA_reg6  <= 0;	Intra_mbAddrA_reg7  <= 0;
				Intra_mbAddrA_reg8  <= 0;	Intra_mbAddrA_reg9  <= 0;
				Intra_mbAddrA_reg10 <= 0;	Intra_mbAddrA_reg11 <= 0;
				Intra_mbAddrA_reg12 <= 0;	Intra_mbAddrA_reg13 <= 0;
				Intra_mbAddrA_reg14 <= 0;	Intra_mbAddrA_reg15 <= 0;
			end	
	//Intra_mbAddrA_window0 ~ 3
	always @ (mb_type_general or Intra16x16_predmode or Intra_chroma_predmode
		or blk4x4_intra_calculate_counter or blk4x4_rec_counter or mbAddrA_availability	
		
		or Intra_mbAddrA_reg0  or Intra_mbAddrA_reg1  or Intra_mbAddrA_reg2  or Intra_mbAddrA_reg3  
		or Intra_mbAddrA_reg4  or Intra_mbAddrA_reg5  or Intra_mbAddrA_reg6  or Intra_mbAddrA_reg7  
		or Intra_mbAddrA_reg8  or Intra_mbAddrA_reg9  or Intra_mbAddrA_reg10 or Intra_mbAddrA_reg11
		or Intra_mbAddrA_reg12 or Intra_mbAddrA_reg13 or Intra_mbAddrA_reg14 or Intra_mbAddrA_reg15
		
		or Intra_mbAddrA_Cb_reg0 or Intra_mbAddrA_Cb_reg1 or Intra_mbAddrA_Cb_reg2 or Intra_mbAddrA_Cb_reg3
		or Intra_mbAddrA_Cb_reg4 or Intra_mbAddrA_Cb_reg5 or Intra_mbAddrA_Cb_reg6 or Intra_mbAddrA_Cb_reg7
		or Intra_mbAddrA_Cr_reg0 or Intra_mbAddrA_Cr_reg1 or Intra_mbAddrA_Cr_reg2 or Intra_mbAddrA_Cr_reg3
		or Intra_mbAddrA_Cr_reg4 or Intra_mbAddrA_Cr_reg5 or Intra_mbAddrA_Cr_reg6 or Intra_mbAddrA_Cr_reg7)
		if (mb_type_general[3] == 1'b1)
			begin
				//Intra4x4 && Intra16x16_horizontal
				if (blk4x4_rec_counter < 16 && blk4x4_intra_calculate_counter != 0 && 
					(mb_type_general[2] == 1'b1 || (
					(mb_type_general[2] == 1'b0 && Intra16x16_predmode == `Intra16x16_Horizontal))))
					case (blk4x4_rec_counter)
						0,1,4,5:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_reg0; Intra_mbAddrA_window1 <= Intra_mbAddrA_reg1;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_reg2; Intra_mbAddrA_window3 <= Intra_mbAddrA_reg3;
						end
						2,3,6,7:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_reg4; Intra_mbAddrA_window1 <= Intra_mbAddrA_reg5;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_reg6; Intra_mbAddrA_window3 <= Intra_mbAddrA_reg7;
						end
						8,9,12,13:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_reg8; Intra_mbAddrA_window1 <= Intra_mbAddrA_reg9;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_reg10;Intra_mbAddrA_window3 <= Intra_mbAddrA_reg11;
						end
						10,11,14,15:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_reg12;Intra_mbAddrA_window1 <= Intra_mbAddrA_reg13;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_reg14;Intra_mbAddrA_window3 <= Intra_mbAddrA_reg15;
						end
						default:
						begin
							Intra_mbAddrA_window0 <= 0;Intra_mbAddrA_window1 <= 0;
							Intra_mbAddrA_window2 <= 0;Intra_mbAddrA_window3 <= 0;
						end
					endcase
				//Chroma Cb/Cr Horizontal & DC
				else if (blk4x4_rec_counter > 15 && blk4x4_intra_calculate_counter != 0 &&
					(Intra_chroma_predmode == `Intra_chroma_Horizontal || (Intra_chroma_predmode == `Intra_chroma_DC && mbAddrA_availability)))
					case (blk4x4_rec_counter)
						16,17:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_Cb_reg0;
							Intra_mbAddrA_window1 <= Intra_mbAddrA_Cb_reg1;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_Cb_reg2;
							Intra_mbAddrA_window3 <= Intra_mbAddrA_Cb_reg3;
						end
						18,19:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_Cb_reg4;
							Intra_mbAddrA_window1 <= Intra_mbAddrA_Cb_reg5;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_Cb_reg6;
							Intra_mbAddrA_window3 <= Intra_mbAddrA_Cb_reg7;
						end
						20,21:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_Cr_reg0;
							Intra_mbAddrA_window1 <= Intra_mbAddrA_Cr_reg1;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_Cr_reg2;
							Intra_mbAddrA_window3 <= Intra_mbAddrA_Cr_reg3;
						end
						22,23:
						begin
							Intra_mbAddrA_window0 <= Intra_mbAddrA_Cr_reg4;
							Intra_mbAddrA_window1 <= Intra_mbAddrA_Cr_reg5;
							Intra_mbAddrA_window2 <= Intra_mbAddrA_Cr_reg6;
							Intra_mbAddrA_window3 <= Intra_mbAddrA_Cr_reg7;
						end
						default:
						begin
							Intra_mbAddrA_window0 <= 0;Intra_mbAddrA_window1 <= 0;
							Intra_mbAddrA_window2 <= 0;Intra_mbAddrA_window3 <= 0;
						end
					endcase
				else
					begin
						Intra_mbAddrA_window0 <= 0;Intra_mbAddrA_window1 <= 0;
						Intra_mbAddrA_window2 <= 0;Intra_mbAddrA_window3 <= 0;
					end
			end
		else
			begin
				Intra_mbAddrA_window0 <= 0;Intra_mbAddrA_window1 <= 0;
				Intra_mbAddrA_window2 <= 0;Intra_mbAddrA_window3 <= 0;
			end
			
	
	//Intra_mbAddrB_window0 ~ 3
	always @ (mb_type_general or Intra16x16_predmode or Intra_chroma_predmode
		or blk4x4_intra_calculate_counter or blk4x4_rec_counter	
		or Intra_mbAddrB_reg0  or Intra_mbAddrB_reg1  or Intra_mbAddrB_reg2 
		or Intra_mbAddrB_reg3  or Intra_mbAddrB_reg4  or Intra_mbAddrB_reg5
		or Intra_mbAddrB_reg6  or Intra_mbAddrB_reg7  or Intra_mbAddrB_reg8
		or Intra_mbAddrB_reg9  or Intra_mbAddrB_reg10 or Intra_mbAddrB_reg11
		or Intra_mbAddrB_reg12 or Intra_mbAddrB_reg13 or Intra_mbAddrB_reg14
		or Intra_mbAddrB_reg15)
		if (mb_type_general[3] == 1'b1)
			begin
				//Intra4x4 && Intra16x16_Vertical
				if (blk4x4_rec_counter < 16 && blk4x4_intra_calculate_counter != 0 && 
					(mb_type_general[2] == 1'b1 || (
					(mb_type_general[2] == 1'b0 && Intra16x16_predmode == `Intra16x16_Vertical))))
					case (blk4x4_rec_counter)
						0,2,8,10:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg0;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg1;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg2;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg3;
						end
						1,3,9,11:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg4;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg5;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg6;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg7;
						end
						4,6,12,14:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg8;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg9;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg10;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg11;
						end
						5,7,13,15:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg12;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg13;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg14;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg15;
						end
						default:
						begin
							Intra_mbAddrB_window0 <= 0;Intra_mbAddrB_window1 <= 0;
							Intra_mbAddrB_window2 <= 0;Intra_mbAddrB_window3 <= 0;
						end
					endcase
				//Chroma Cb/Cr Vertical and DC
				else if (blk4x4_rec_counter > 15 && blk4x4_rec_counter < 24 && 
					(Intra_chroma_predmode == `Intra_chroma_Vertical || Intra_chroma_predmode == `Intra_chroma_DC) && blk4x4_intra_calculate_counter != 0)
					case (blk4x4_rec_counter)
						16,18,20,22:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg0;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg1;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg2;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg3;
						end
						17,19,21,23:
						begin
							Intra_mbAddrB_window0 <= Intra_mbAddrB_reg4;
							Intra_mbAddrB_window1 <= Intra_mbAddrB_reg5;
							Intra_mbAddrB_window2 <= Intra_mbAddrB_reg6;
							Intra_mbAddrB_window3 <= Intra_mbAddrB_reg7;
						end
						default:
						begin
							Intra_mbAddrB_window0 <= 0;Intra_mbAddrB_window1 <= 0;
							Intra_mbAddrB_window2 <= 0;Intra_mbAddrB_window3 <= 0;
						end
					endcase
				else
					begin
						Intra_mbAddrB_window0 <= 0;Intra_mbAddrB_window1 <= 0;
						Intra_mbAddrB_window2 <= 0;Intra_mbAddrB_window3 <= 0;
					end
			end
		else
			begin
				Intra_mbAddrB_window0 <= 0;Intra_mbAddrB_window1 <= 0;
				Intra_mbAddrB_window2 <= 0;Intra_mbAddrB_window3 <= 0;
			end
	//Intra_mbAddrC_window0 ~ 3
	always @ (mb_type_general[3:2] or blk4x4_intra_calculate_counter or blk4x4_rec_counter or Intra4x4_predmode 
		or Intra_mbAddrC_reg0  or Intra_mbAddrC_reg1  or Intra_mbAddrC_reg2  or Intra_mbAddrC_reg3
		or Intra_mbAddrB_reg4  or Intra_mbAddrB_reg5  or Intra_mbAddrB_reg6  or Intra_mbAddrB_reg7  
		or Intra_mbAddrB_reg8  or Intra_mbAddrB_reg9  or Intra_mbAddrB_reg10 or Intra_mbAddrB_reg11
		or Intra_mbAddrB_reg12 or Intra_mbAddrB_reg13 or Intra_mbAddrB_reg14 or Intra_mbAddrB_reg15
		or mbAddrC_availability or Intra_mbAddrB_window3)
		if (mb_type_general[3:2] == 2'b11 && blk4x4_intra_calculate_counter != 0 && (
			Intra4x4_predmode == `Intra4x4_Diagonal_Down_Left || Intra4x4_predmode == `Intra4x4_Vertical_Left) && blk4x4_rec_counter < 16)
			case (blk4x4_rec_counter)
				0,1,4:
				begin
					Intra_mbAddrC_window0 <= Intra_mbAddrC_reg0;
					Intra_mbAddrC_window1 <= Intra_mbAddrC_reg1;
					Intra_mbAddrC_window2 <= Intra_mbAddrC_reg2;
					Intra_mbAddrC_window3 <= Intra_mbAddrC_reg3;
				end
				5:
				begin
					Intra_mbAddrC_window0 <= (mbAddrC_availability)? Intra_mbAddrC_reg0:Intra_mbAddrB_reg15;
					Intra_mbAddrC_window1 <= (mbAddrC_availability)? Intra_mbAddrC_reg1:Intra_mbAddrB_reg15;
					Intra_mbAddrC_window2 <= (mbAddrC_availability)? Intra_mbAddrC_reg2:Intra_mbAddrB_reg15;
					Intra_mbAddrC_window3 <= (mbAddrC_availability)? Intra_mbAddrC_reg3:Intra_mbAddrB_reg15;
				end
				2,8,10:
				begin
					Intra_mbAddrC_window0  <= Intra_mbAddrB_reg4;
					Intra_mbAddrC_window1  <= Intra_mbAddrB_reg5;
					Intra_mbAddrC_window2  <= Intra_mbAddrB_reg6;
					Intra_mbAddrC_window3  <= Intra_mbAddrB_reg7;
				end
				9: 
				begin
					Intra_mbAddrC_window0  <= Intra_mbAddrB_reg8;
					Intra_mbAddrC_window1  <= Intra_mbAddrB_reg9;
					Intra_mbAddrC_window2  <= Intra_mbAddrB_reg10;
					Intra_mbAddrC_window3  <= Intra_mbAddrB_reg11;
				end
				6,12,14:
				begin
					Intra_mbAddrC_window0  <= Intra_mbAddrB_reg12;
					Intra_mbAddrC_window1  <= Intra_mbAddrB_reg13;
					Intra_mbAddrC_window2  <= Intra_mbAddrB_reg14;
					Intra_mbAddrC_window3  <= Intra_mbAddrB_reg15;
				end
				3,11,7,13,15:
				begin
					Intra_mbAddrC_window0  <= Intra_mbAddrB_window3;
					Intra_mbAddrC_window1  <= Intra_mbAddrB_window3;
					Intra_mbAddrC_window2  <= Intra_mbAddrB_window3;
					Intra_mbAddrC_window3  <= Intra_mbAddrB_window3;
				end
				default:
				begin
					Intra_mbAddrC_window0  <= 0;	Intra_mbAddrC_window1  <= 0;
					Intra_mbAddrC_window2  <= 0;	Intra_mbAddrC_window3  <= 0;
				end
			endcase
		else
			begin
				Intra_mbAddrC_window0  <= 0;	Intra_mbAddrC_window1  <= 0;
				Intra_mbAddrC_window2  <= 0;	Intra_mbAddrC_window3  <= 0;
			end
	
	//Intra_mbAddrD_window
	always @ (mb_type_general[3:2] or blk4x4_rec_counter 
		or blk4x4_intra_calculate_counter or blk4x4_intra_precompute_counter 
		or Intra4x4_predmode or Intra16x16_predmode or Intra_chroma_predmode
		or Intra_mbAddrD_reg0 or Intra_mbAddrD_reg1 or Intra_mbAddrD_reg2 
		or Intra_mbAddrD_reg3 or Intra_mbAddrD_reg4 
		or Intra_mbAddrD_LeftMB_luma_reg or Intra_mbAddrD_LeftMB_Cb_reg or Intra_mbAddrD_LeftMB_Cr_reg)
		//Intra
		if (mb_type_general[3] == 1'b1 && (blk4x4_intra_calculate_counter != 0 || blk4x4_intra_precompute_counter != 0))
			begin
				//Intra luma
				if (blk4x4_rec_counter[4] == 1'b0)
					begin
						//Intra4x4 luma
						if (mb_type_general[2] == 1'b1 && (Intra4x4_predmode == `Intra4x4_Diagonal_Down_Right || 
                                               Intra4x4_predmode == `Intra4x4_Vertical_Right      || 
                                               Intra4x4_predmode == `Intra4x4_Horizontal_Down))
							case (blk4x4_rec_counter[3:0])
								0,2,8,10:Intra_mbAddrD_window <= Intra_mbAddrD_LeftMB_luma_reg;
								3,5,13	:Intra_mbAddrD_window <= Intra_mbAddrD_reg0;
								1,6,11	:Intra_mbAddrD_window <= Intra_mbAddrD_reg1;
								9,15	:Intra_mbAddrD_window <= Intra_mbAddrD_reg2;
								12 		:Intra_mbAddrD_window <= Intra_mbAddrD_reg3;
								4,7,14	:Intra_mbAddrD_window <= Intra_mbAddrD_reg4;
							endcase
						//Intra16x16
						else 
							Intra_mbAddrD_window <= (Intra16x16_predmode == `Intra16x16_Plane)? Intra_mbAddrD_LeftMB_luma_reg:0;
					end
				//Intra chroma
				else if (blk4x4_rec_counter > 15 && Intra_chroma_predmode == `Intra_chroma_Plane)
					Intra_mbAddrD_window <= (blk4x4_rec_counter < 20)? Intra_mbAddrD_LeftMB_Cb_reg:Intra_mbAddrD_LeftMB_Cr_reg;
				else
					Intra_mbAddrD_window <= 0;
			end
		//Inter
		else
			Intra_mbAddrD_window <= 0;
	
	//seed
	always @ (posedge gclk_seed or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				seed_0 <= 0;	seed_1 <= 0;	seed_2 <= 0;
			end
		else if (blk4x4_intra_precompute_counter == 1)
			seed_0 <= main_seed;
		else
			case (blk4x4_rec_counter)
				0,2,8,16,20	:seed_0 <= PE3_sum_out;
				1,9			:seed_1 <= PE0_sum_out; 
				3,11		:seed_2 <= PE0_sum_out;
			endcase
			
	always @ (mb_type_general[3:2] or Intra16x16_predmode or Intra_chroma_predmode
		or blk4x4_intra_calculate_counter or blk4x4_rec_counter or seed_0 or seed_1 or seed_2)
		if (mb_type_general[3:2] == 2'b10 && Intra16x16_predmode == `Intra16x16_Plane && blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter < 16)
			case (blk4x4_rec_counter)
				0,2,8,10:seed <= seed_0;
				4,12	:seed <= seed_1;
				6,14	:seed <= seed_2;
				default :seed <= 0;
			endcase
		else if (mb_type_general[3] == 1'b1 && Intra_chroma_predmode == `Intra_chroma_Plane && blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter > 15)
			if (blk4x4_rec_counter[0] == 1'b0)	//16,18,20,22
				seed <= seed_0;
			else
				seed <= 0;
		else
			seed <= 0;
		
endmodule
						
		
	