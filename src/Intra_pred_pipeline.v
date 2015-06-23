//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Intra_pred_pipeline.v
// Generated : Aug 4, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Intra16x16,Intra4x4 prediction pipeline
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Intra_pred_pipeline (clk,reset_n,mb_type_general,blk4x4_rec_counter,
	trigger_blk4x4_intra_pred,mb_num_v,mb_num_h,blk4x4_sum_counter,NextMB_IsSkip,
	Intra16x16_predmode,Intra4x4_predmode_CurrMb,Intra_chroma_predmode,
	
	Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3,
	Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7,
	Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11,
	Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15,
	
	Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3,
	Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7,
	Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11,
	Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15,
	Intra_mbAddrD_window,
		
	Intra4x4_predmode,blk4x4_intra_preload_counter,blk4x4_intra_precompute_counter,
	blk4x4_intra_calculate_counter,end_of_one_blk4x4_intra,
	blkAddrA_availability,blkAddrB_availability,mbAddrA_availability,mbAddrB_availability,mbAddrC_availability,
	main_seed,plane_b_reg,plane_c_reg,
	Intra_mbAddrB_RAM_rd,Intra_mbAddrB_RAM_rd_addr
	);
	input clk,reset_n;
	input [3:0] mb_type_general;
	input [4:0] blk4x4_rec_counter;
	input trigger_blk4x4_intra_pred;
	input [3:0] mb_num_v,mb_num_h;
	input [2:0] blk4x4_sum_counter;
	input NextMB_IsSkip;
	input [1:0] Intra16x16_predmode;
	input [63:0] Intra4x4_predmode_CurrMb;
	input [1:0] Intra_chroma_predmode;
	
	input [7:0] Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3;
	input [7:0] Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7;
	input [7:0] Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11;
	input [7:0] Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15;
	
	input [7:0] Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3;
	input [7:0] Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7;
	input [7:0] Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11;
	input [7:0] Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15;
	input [7:0] Intra_mbAddrD_window;
	
	output [3:0] Intra4x4_predmode;
	output [2:0] blk4x4_intra_preload_counter;
	output [3:0] blk4x4_intra_precompute_counter;
	output [2:0] blk4x4_intra_calculate_counter;
	output end_of_one_blk4x4_intra;
	output blkAddrA_availability,blkAddrB_availability;
	output mbAddrA_availability,mbAddrB_availability,mbAddrC_availability;
	output [15:0] main_seed;
	output [11:0] plane_b_reg,plane_c_reg;
	output Intra_mbAddrB_RAM_rd;
	output [6:0] Intra_mbAddrB_RAM_rd_addr;
	
	reg [3:0] Intra4x4_predmode;
	reg [2:0] blk4x4_intra_preload_counter;
	reg [3:0] blk4x4_intra_precompute_counter;
	reg [2:0] blk4x4_intra_calculate_counter;
	
	reg [11:0] plane_b_reg,plane_c_reg;
	wire Intra_mbAddrB_RAM_rd;
	wire [6:0] Intra_mbAddrB_RAM_rd_addr;
	wire end_of_one_blk4x4_intra;
	wire blkAddrA_availability,blkAddrB_availability;
	wire mbAddrA_availability,mbAddrB_availability;
	
	//----------------------------------------------------------------------------------------
	//Intra4x4 prediction mode for current 4x4 block
	//----------------------------------------------------------------------------------------
	always @ (Intra4x4_predmode_CurrMb or blk4x4_rec_counter or mb_type_general)
		if (mb_type_general == `MB_Intra4x4)
			case (blk4x4_rec_counter)
				0 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[3:0]; 
				1 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[7:4];
				2 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[11:8];
				3 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[15:12];
				4 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[19:16];
				5 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[23:20];
				6 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[27:24];
				7 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[31:28];
				8 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[35:32];
				9 :Intra4x4_predmode <= Intra4x4_predmode_CurrMb[39:36];
				10:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[43:40];
				11:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[47:44];
				12:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[51:48];
				13:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[55:52];
				14:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[59:56];
				15:Intra4x4_predmode <= Intra4x4_predmode_CurrMb[63:60];
				default:Intra4x4_predmode <= 4'b1111;	
			endcase
		else
			Intra4x4_predmode <= 4'b1111;
	
	//availability for intra4x4 predmode = Intra4x4_DC only
	assign blkAddrA_availability = (mb_type_general == `MB_Intra4x4 && Intra4x4_predmode == `Intra4x4_DC && 
	blk4x4_rec_counter < 16 && ((blk4x4_rec_counter == 0 || blk4x4_rec_counter == 2 || blk4x4_rec_counter == 8 ||
	blk4x4_rec_counter == 10) && mb_num_h == 0))? 1'b0:1'b1;
	
	assign blkAddrB_availability = (mb_type_general == `MB_Intra4x4 && Intra4x4_predmode == `Intra4x4_DC && 
	blk4x4_rec_counter < 16 && ((blk4x4_rec_counter == 0 || blk4x4_rec_counter == 1 || blk4x4_rec_counter == 4 || 
	blk4x4_rec_counter == 5) && mb_num_v == 0))? 1'b0:1'b1; 
	
	//availability for whole intra predicted MB (both intra16x16 & intra4x4)
	//assign mbAddrA_availability = (mb_type_general[3] && mb_num_h != 0)? 1'b1:1'b0;
	//assign mbAddrB_availability = (mb_type_general[3] && mb_num_v != 0)? 1'b1:1'b0;
	assign mbAddrA_availability = (mb_type_general[3] && mb_num_h != 0)? 1'b1:1'b0;
	assign mbAddrB_availability = (mb_type_general[3] && mb_num_v != 0)? 1'b1:1'b0;
	assign mbAddrC_availability = (mb_type_general[3] && mb_num_v != 0 && mb_num_h != 10)? 1'b1:1'b0;
	
	//----------------------------------------------------------------------------------------
	//Intra prediction step control counter
	//---------------------------------------------------------------------------------------- 
	//1.Preload upper pels counter
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_intra_preload_counter <= 0;
		else if (trigger_blk4x4_intra_pred)
			begin
				//Chroma
				if (mb_type_general[3] == 1'b1 && (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20))
					case (Intra_chroma_predmode)
						`Intra_chroma_DC			  :blk4x4_intra_preload_counter <= (mbAddrB_availability)? 3'b011:3'b000;
						`Intra_chroma_Horizontal:blk4x4_intra_preload_counter <= 3'b000;	
						`Intra_chroma_Vertical  :blk4x4_intra_preload_counter <= 3'b011;	
						`Intra_chroma_Plane     :blk4x4_intra_preload_counter <= 3'b011;	
					endcase
				//Luma
				//	Intra16x16
				else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter == 0)
					case (Intra16x16_predmode)
						`Intra16x16_Vertical  :blk4x4_intra_preload_counter <= 3'b101;
						`Intra16x16_Horizontal:blk4x4_intra_preload_counter <= 3'b000;	
						`Intra16x16_DC        :blk4x4_intra_preload_counter <= (mbAddrB_availability)? 3'b101:3'b000;
						`Intra16x16_Plane     :blk4x4_intra_preload_counter <= 3'b101;	
					endcase
				//	Intra4x4
				else if (mb_type_general[3:2] == 2'b11 && (blk4x4_rec_counter == 0 || blk4x4_rec_counter == 1
					|| blk4x4_rec_counter == 4 || blk4x4_rec_counter == 5))	
					case (Intra4x4_predmode)
						`Intra4x4_Vertical           :blk4x4_intra_preload_counter <= 3'b010;		
						`Intra4x4_Horizontal         :blk4x4_intra_preload_counter <= 3'b000;		
						`Intra4x4_DC                 :blk4x4_intra_preload_counter <= (mbAddrB_availability)? 3'b010:3'b000;
						`Intra4x4_Diagonal_Down_Left :blk4x4_intra_preload_counter <= 3'b011;	//need mbAddrC			
						`Intra4x4_Diagonal_Down_Right:blk4x4_intra_preload_counter <= (blk4x4_rec_counter == 0)? 3'b010:3'b011;//need mbAddrD	
						`Intra4x4_Vertical_Right     :blk4x4_intra_preload_counter <= (blk4x4_rec_counter == 0)? 3'b010:3'b011;//need mbAddrD	
						`Intra4x4_Horizontal_Down    :blk4x4_intra_preload_counter <= (blk4x4_rec_counter == 0)? 3'b010:3'b011;//need mbAddrD	
						`Intra4x4_Vertical_Left      :blk4x4_intra_preload_counter <= 3'b011;	//need mbAddrC	
						`Intra4x4_Horizontal_Up      :blk4x4_intra_preload_counter <= 3'b000;		
					endcase
			end
		else if (blk4x4_intra_preload_counter != 0)
			blk4x4_intra_preload_counter <= blk4x4_intra_preload_counter - 1;
		
	//2.Precomputation for plane mode counter
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_intra_precompute_counter <= 0;
		//Intra16x16 plane mode: 10 cycle + 1 cycle (seed)
		else if (mb_type_general[2] == 1'b0 && blk4x4_rec_counter == 0 && Intra16x16_predmode == `Intra16x16_Plane && blk4x4_intra_preload_counter == 3'b001)
			blk4x4_intra_precompute_counter <= 4'b1011;
		//Chroma8x8 plane mode: 6 cycle + 1 cycle (seed)
		else if ((blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20) && Intra_chroma_predmode == `Intra_chroma_Plane && blk4x4_intra_preload_counter == 3'b001)
			blk4x4_intra_precompute_counter <= 4'b0111;
		else if (blk4x4_intra_precompute_counter != 0)
			blk4x4_intra_precompute_counter <= blk4x4_intra_precompute_counter - 1;
	
	//3.Intra prediction calculation counter
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_intra_calculate_counter <= 0;
		//Intra16x16 Luma
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			begin
				if (blk4x4_rec_counter == 0)
					case (Intra16x16_predmode)
						`Intra16x16_Vertical:	
						if (blk4x4_intra_preload_counter == 3'b001)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
						`Intra16x16_Horizontal:	
						if (trigger_blk4x4_intra_pred)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;	
						`Intra16x16_DC:
						if (mbAddrB_availability && blk4x4_intra_preload_counter == 3'b001)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (!mbAddrB_availability && trigger_blk4x4_intra_pred)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
						`Intra16x16_Plane:
						if (blk4x4_intra_precompute_counter == 4'b0001)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
					endcase
				else
					begin
						if (trigger_blk4x4_intra_pred)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
					end
			end
		//Intra4x4 Luma
		else if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)
			begin
				if (blk4x4_rec_counter == 0 || blk4x4_rec_counter == 1 || 
					blk4x4_rec_counter == 4 || blk4x4_rec_counter == 5)
					case (Intra4x4_predmode)
						`Intra4x4_Horizontal,`Intra4x4_Horizontal_Up://Intra4x4 prediction modes do NOT need preload
						if (trigger_blk4x4_intra_pred)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
						`Intra4x4_DC:	//Intra4x4 prediction modes may or may NOT need preload
						if (mbAddrB_availability == 1'b1)	//need reload
							begin
								if (blk4x4_intra_preload_counter == 3'b001)
									blk4x4_intra_calculate_counter <= 3'b100;
								else if (blk4x4_intra_calculate_counter != 0)
									blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
							end
						else								//do not need reload
							begin
								if (trigger_blk4x4_intra_pred)
									blk4x4_intra_calculate_counter <= 3'b100;
								else if (blk4x4_intra_calculate_counter != 0)
									blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
							end
						default:			//other Intra4x4 prediction modes that needs preload
						if (blk4x4_intra_preload_counter == 3'b001)
							blk4x4_intra_calculate_counter <= 3'b100;
						else if (blk4x4_intra_calculate_counter != 0)
							blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
					endcase
				else if (trigger_blk4x4_intra_pred)
					blk4x4_intra_calculate_counter <= 3'b100;
				else if (blk4x4_intra_calculate_counter != 0)
					blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
			end
		//Chroma
		else if (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20)
			case (Intra_chroma_predmode)
				`Intra_chroma_DC:
				if ((mbAddrB_availability && blk4x4_intra_preload_counter == 3'b001) || (!mbAddrB_availability && trigger_blk4x4_intra_pred))
					blk4x4_intra_calculate_counter <= 3'b100;
				else if (blk4x4_intra_calculate_counter != 0)
					blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
				`Intra_chroma_Horizontal:
					if (trigger_blk4x4_intra_pred)
						blk4x4_intra_calculate_counter <= 3'b100;
					else if (blk4x4_intra_calculate_counter != 0)
						blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
				`Intra_chroma_Vertical:
					if (blk4x4_intra_preload_counter == 3'b001)
						blk4x4_intra_calculate_counter <= 3'b100;
					else if (blk4x4_intra_calculate_counter != 0)
						blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
				`Intra_chroma_Plane:	//plane
					if (blk4x4_intra_precompute_counter == 4'b0001)
						blk4x4_intra_calculate_counter <= 3'b100;
					else if (blk4x4_intra_calculate_counter != 0)
						blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
			endcase
		else 
			begin
				if (trigger_blk4x4_intra_pred)
					blk4x4_intra_calculate_counter <= 3'b100;
				else if (blk4x4_intra_calculate_counter != 0)
					blk4x4_intra_calculate_counter <= blk4x4_intra_calculate_counter - 1;
			end
			
	assign end_of_one_blk4x4_intra = (blk4x4_intra_calculate_counter == 3'd1)? 1'b1:1'b0;
	//----------------------------------------------------------------------------------------
	//1.Preload
	//  For intra4x4,preload_counter == 3'b010 means preload mbAddrC or mbAddrD
	//				 preload_counter == 3'b001 means preload mbAddrB
	//----------------------------------------------------------------------------------------
	wire [6:0] Intra_mbAddrB_RAM_addr_bp;
	reg [5:0] Intra_mbAddrB_RAM_addr_sp;
	reg [1:0] Intra_mbAddrB_RAM_addr_ip;
	
	wire Intra_mbAddrB_RAM_rd_for_mbAddrD;
	assign Intra_mbAddrB_RAM_rd_for_mbAddrD = (blk4x4_sum_counter == 3'b0 && 
	(blk4x4_rec_counter == 15 || blk4x4_rec_counter == 19 || blk4x4_rec_counter == 23) &&
	mb_num_h != 10 && mb_num_v != 0 && !NextMB_IsSkip)? 1'b1:1'b0;
	
	assign Intra_mbAddrB_RAM_rd = ((blk4x4_intra_preload_counter != 0 && blk4x4_intra_preload_counter != 1) || Intra_mbAddrB_RAM_rd_for_mbAddrD)? 1'b1:1'b0;
	
	//	base pointer, [43:0] luma, [65:44] Chroma Cb, [87:66] Chroma Cr
	assign Intra_mbAddrB_RAM_addr_bp = (Intra_mbAddrB_RAM_rd)? ((blk4x4_rec_counter > 15)? ((blk4x4_rec_counter > 19)? 7'd66:7'd44):0):0;
	
	//	shift pointer,x2 for chroma,x4 for luma
	always @ (Intra_mbAddrB_RAM_rd_for_mbAddrD or Intra_mbAddrB_RAM_rd or mb_num_h or 
		blk4x4_rec_counter or Intra4x4_predmode or blk4x4_intra_preload_counter)
		if (Intra_mbAddrB_RAM_rd_for_mbAddrD)
			Intra_mbAddrB_RAM_addr_sp <= (blk4x4_rec_counter < 16)? {mb_num_h,2'b0}:{1'b0,mb_num_h,1'b0};
		else if (Intra_mbAddrB_RAM_rd)
			begin
				if (blk4x4_rec_counter < 16)
					Intra_mbAddrB_RAM_addr_sp <= ((Intra4x4_predmode == `Intra4x4_Diagonal_Down_Left 
					|| Intra4x4_predmode == `Intra4x4_Vertical_Left) && blk4x4_rec_counter == 5 
					&& blk4x4_intra_preload_counter == 3'b011)?	//read for mbAddrC
						{(mb_num_h + 1),2'b0}:{mb_num_h,2'b0};	
				else
					Intra_mbAddrB_RAM_addr_sp <= {1'b0,mb_num_h,1'b0};
			end
		else
			Intra_mbAddrB_RAM_addr_sp <= 0;
			
	//	pointer for relative address of each 4x4 block inside a MB
	always @ (Intra_mbAddrB_RAM_rd or blk4x4_rec_counter or blk4x4_intra_preload_counter or 
		mb_type_general[3:2] or Intra4x4_predmode or Intra_mbAddrB_RAM_rd_for_mbAddrD)
		if (blk4x4_rec_counter < 16 && Intra_mbAddrB_RAM_rd)	//luma
			begin 
				if (blk4x4_intra_preload_counter != 0 && blk4x4_intra_preload_counter != 1)
					begin 
						if (mb_type_general[3:2] == 2'b10)	//Intra16x16
							case (blk4x4_intra_preload_counter)
								3'b101:Intra_mbAddrB_RAM_addr_ip <= 0;
								3'b100:Intra_mbAddrB_RAM_addr_ip <= 2'b01;
								3'b011:Intra_mbAddrB_RAM_addr_ip <= 2'b10;
								3'b010:Intra_mbAddrB_RAM_addr_ip <= 2'b11;
								default:Intra_mbAddrB_RAM_addr_ip <= 0;
							endcase
						else								//Intra4x4
							begin 
								if (blk4x4_intra_preload_counter == 3'b010)			//For mbAddrB
									case (blk4x4_rec_counter)
										0:Intra_mbAddrB_RAM_addr_ip <= 0;
										1:Intra_mbAddrB_RAM_addr_ip <= 2'b01;
										4:Intra_mbAddrB_RAM_addr_ip <= 2'b10;
										5:Intra_mbAddrB_RAM_addr_ip <= 2'b11;
										default:Intra_mbAddrB_RAM_addr_ip <= 0;
									endcase
								else if (Intra4x4_predmode == `Intra4x4_Diagonal_Down_Left 
									|| Intra4x4_predmode == `Intra4x4_Vertical_Left)	//For mbAddrC
									case (blk4x4_rec_counter)
										0:Intra_mbAddrB_RAM_addr_ip <= 2'b01;
										1:Intra_mbAddrB_RAM_addr_ip <= 2'b10;
										4:Intra_mbAddrB_RAM_addr_ip <= 2'b11;
										5:Intra_mbAddrB_RAM_addr_ip <= 2'b00;
										default:Intra_mbAddrB_RAM_addr_ip <= 0;
									endcase
								else												//For mbAddrD
									case (blk4x4_rec_counter)
										1:Intra_mbAddrB_RAM_addr_ip <= 2'b00;
										4:Intra_mbAddrB_RAM_addr_ip <= 2'b01;
										5:Intra_mbAddrB_RAM_addr_ip <= 2'b10;
										default:Intra_mbAddrB_RAM_addr_ip <= 0;
									endcase
							end
					end
				else if (Intra_mbAddrB_RAM_rd_for_mbAddrD)
					Intra_mbAddrB_RAM_addr_ip <= 2'b11;
				else
					Intra_mbAddrB_RAM_addr_ip <= 0;
			end
		else if (Intra_mbAddrB_RAM_rd)							//chroma
			Intra_mbAddrB_RAM_addr_ip <= (blk4x4_intra_preload_counter != 0 && blk4x4_intra_preload_counter != 1)? {1'b0,~blk4x4_intra_preload_counter[0]}:2'b01; 
		else	
			Intra_mbAddrB_RAM_addr_ip <= 0;
	
	//	pointer for each 4x4 block
	assign Intra_mbAddrB_RAM_rd_addr  = Intra_mbAddrB_RAM_addr_bp + Intra_mbAddrB_RAM_addr_sp + Intra_mbAddrB_RAM_addr_ip;
	
	//----------------------------------------------------------------------------------------	
	//2.Precomputation
	// 			 For Intra16x16 Luma Plane								
	//	cycle11: x1 + x3  |							
	//  cycle10: x2 + x5  |
	//  cycle9 : x4 + x6  |
	//  cycle8 : x8 + x7  | Vertical,V				    For Intra Chroma Plane
	//  cycle7 : calculate c					   cycle7: x1 + x3  |
	//	cycle6 : x1 + x3  |						   cycle6: x2 + x4	| Vertical,V
	//  cycle5 : x2 + x5  |						   cycle5: calculate c
	//  cycle4 : x4 + x6  |						   cycle4: x1 + x3	|
	//  cycle3 : x8 + x7  | Horizontal,H	   	   cycle3: x2 + x4	| Horizontal,H
	//  cycle2 : calculate a & b				   cycle2 : calculate a & b
	//  cycle1 : seed							   cycle1 : seed
	//----------------------------------------------------------------------------------------
	//	2.1 precomputation for HV:
	reg [14:0] plane_HV_prev_in;
	reg [7:0] plane_HV_A1,plane_HV_A2,plane_HV_B1,plane_HV_B2;
	reg [1:0] plane_HV_shifter1_len,plane_HV_shifter2_len;
	reg plane_HV_mux1_sel,plane_HV_mux2_sel;
	reg plane_HV_Is7;
	wire [14:0] plane_HV_out;
	reg [14:0] plane_HV_out_reg;
	
	plane_HV_precomputation plane_HV_precomputation (
		.prev_in(plane_HV_prev_in),
		.A1(plane_HV_A1),
		.A2(plane_HV_A2),
		.B1(plane_HV_B1),
		.B2(plane_HV_B2),
		.shifter1_len(plane_HV_shifter1_len),
		.shifter2_len(plane_HV_shifter2_len),
		.mux1_sel(plane_HV_mux1_sel),
		.mux2_sel(plane_HV_mux2_sel),
		.Is7(plane_HV_Is7),
		.HV_out(plane_HV_out)
		);
	always @ (blk4x4_intra_precompute_counter or mb_type_general[2] or blk4x4_rec_counter or plane_HV_out_reg 
		or Intra_mbAddrA_reg0  or Intra_mbAddrA_reg1  or Intra_mbAddrA_reg2  or Intra_mbAddrA_reg3  
		or Intra_mbAddrA_reg4  or Intra_mbAddrA_reg5  or Intra_mbAddrA_reg6  or Intra_mbAddrA_reg7 
		or Intra_mbAddrA_reg8  or Intra_mbAddrA_reg9  or Intra_mbAddrA_reg10 or Intra_mbAddrA_reg11 
		or Intra_mbAddrA_reg12 or Intra_mbAddrA_reg13 or Intra_mbAddrA_reg14 or Intra_mbAddrA_reg15
		or Intra_mbAddrB_reg0  or Intra_mbAddrB_reg1  or Intra_mbAddrB_reg2  or Intra_mbAddrB_reg3  
		or Intra_mbAddrB_reg4  or Intra_mbAddrB_reg5  or Intra_mbAddrB_reg6  or Intra_mbAddrB_reg7 
		or Intra_mbAddrB_reg8  or Intra_mbAddrB_reg9  or Intra_mbAddrB_reg10 or Intra_mbAddrB_reg11 
		or Intra_mbAddrB_reg12 or Intra_mbAddrB_reg13 or Intra_mbAddrB_reg14 or Intra_mbAddrB_reg15
		or Intra_mbAddrD_window)
		//Intra16x16 plane
		if (mb_type_general[2] == 1'b0 && blk4x4_rec_counter == 0)
			case (blk4x4_intra_precompute_counter)
				11,6:	// x1,x3
				begin
					plane_HV_prev_in <= 0;		plane_HV_Is7 <= 1'b0;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 11)? Intra_mbAddrA_reg8 :Intra_mbAddrB_reg8;
					plane_HV_A2 <= (blk4x4_intra_precompute_counter == 11)? Intra_mbAddrA_reg6 :Intra_mbAddrB_reg6;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 11)? Intra_mbAddrA_reg10:Intra_mbAddrB_reg10;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 11)? Intra_mbAddrA_reg4 :Intra_mbAddrB_reg4;
					plane_HV_shifter1_len <= 0;	plane_HV_shifter2_len <= 2'b01;
					plane_HV_mux1_sel <= 1'b0;	plane_HV_mux2_sel <= 1'b0;
				end	
				10,5 :	// x2,x5
				begin
					plane_HV_prev_in <= plane_HV_out_reg;	plane_HV_Is7 <= 1'b0;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 10)? Intra_mbAddrA_reg9 :Intra_mbAddrB_reg9;		
					plane_HV_A2 <= (blk4x4_intra_precompute_counter == 10)? Intra_mbAddrA_reg5 :Intra_mbAddrB_reg5;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 10)? Intra_mbAddrA_reg12:Intra_mbAddrB_reg12;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 10)? Intra_mbAddrA_reg2 :Intra_mbAddrB_reg2;
					plane_HV_shifter1_len <= 2'b01; plane_HV_shifter2_len <= 2'b10;
					plane_HV_mux1_sel <= 1'b1;      plane_HV_mux2_sel <= 1'b0;
				end
				9,4 :	// x4,x6
				begin
					plane_HV_prev_in <= plane_HV_out_reg;	plane_HV_Is7 <= 1'b0;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 9)? Intra_mbAddrA_reg11:Intra_mbAddrB_reg11;	
					plane_HV_A2 <= (blk4x4_intra_precompute_counter == 9)? Intra_mbAddrA_reg3 :Intra_mbAddrB_reg3;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 9)? Intra_mbAddrA_reg13:Intra_mbAddrB_reg13;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 9)? Intra_mbAddrA_reg1 :Intra_mbAddrB_reg1;
					plane_HV_shifter1_len <= 2'b10; plane_HV_shifter2_len <= 2'b10;
					plane_HV_mux1_sel <= 1'b1;      plane_HV_mux2_sel <= 1'b1;
				end
				8,3 :	// x8,x7
				begin
					plane_HV_prev_in <= plane_HV_out_reg;		plane_HV_Is7 <= 1'b1;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 8)? Intra_mbAddrA_reg15:Intra_mbAddrB_reg15;	
					plane_HV_A2 <= Intra_mbAddrD_window;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 8)? Intra_mbAddrA_reg14:Intra_mbAddrB_reg14;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 8)? Intra_mbAddrA_reg0 :Intra_mbAddrB_reg0;
					plane_HV_shifter1_len <= 2'b11; plane_HV_shifter2_len <= 2'b11;
					plane_HV_mux1_sel <= 1'b1;      plane_HV_mux2_sel <= 1'b0;
				end
				default:
				begin
					plane_HV_prev_in <= 0;	plane_HV_Is7 <= 0;
					plane_HV_A1 <= 0;	plane_HV_A2 <= 0;	plane_HV_B1 <= 0;	plane_HV_B2 <= 0;
					plane_HV_shifter1_len <= 0;	plane_HV_shifter2_len <= 0;
					plane_HV_mux1_sel <= 0;     plane_HV_mux2_sel <= 0;
				end
			endcase						 
		//Chroma Cb/Cr plane
		else if (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20)
			case (blk4x4_intra_precompute_counter)
				7,4:	//x1,x3
				begin
					plane_HV_prev_in <= 0;		plane_HV_Is7 <= 1'b0;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 7)? Intra_mbAddrA_reg4:Intra_mbAddrB_reg4;
					plane_HV_A2 <= (blk4x4_intra_precompute_counter == 7)? Intra_mbAddrA_reg2:Intra_mbAddrB_reg2;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 7)? Intra_mbAddrA_reg6:Intra_mbAddrB_reg6;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 7)? Intra_mbAddrA_reg0:Intra_mbAddrB_reg0;
					plane_HV_shifter1_len <= 0;	plane_HV_shifter2_len <= 2'b01;
					plane_HV_mux1_sel <= 1'b0;	plane_HV_mux2_sel <= 1'b0;
				end
				6,3:	//x2,x4
				begin
					plane_HV_prev_in <= plane_HV_out_reg;	plane_HV_Is7 <= 1'b0;
					plane_HV_A1 <= (blk4x4_intra_precompute_counter == 6)? Intra_mbAddrA_reg5:Intra_mbAddrB_reg5;		
					plane_HV_A2 <= (blk4x4_intra_precompute_counter == 6)? Intra_mbAddrA_reg1:Intra_mbAddrB_reg1;
					plane_HV_B1 <= (blk4x4_intra_precompute_counter == 6)? Intra_mbAddrA_reg7:Intra_mbAddrB_reg7;	
					plane_HV_B2 <= (blk4x4_intra_precompute_counter == 6)? Intra_mbAddrD_window :Intra_mbAddrD_window;
					plane_HV_shifter1_len <= 2'b01; plane_HV_shifter2_len <= 2'b01;
					plane_HV_mux1_sel <= 1'b1;      plane_HV_mux2_sel <= 1'b1;
				end
				default:
				begin
					plane_HV_prev_in <= 0;	plane_HV_Is7 <= 0;
					plane_HV_A1 <= 0;	plane_HV_A2 <= 0;	plane_HV_B1 <= 0;	plane_HV_B2 <= 0;
					plane_HV_shifter1_len <= 0;	plane_HV_shifter2_len <= 0;
					plane_HV_mux1_sel <= 0;     plane_HV_mux2_sel <= 0;
				end
			endcase
		else
			begin
				plane_HV_prev_in <= 0;	plane_HV_Is7 <= 0;
				plane_HV_A1 <= 0;	plane_HV_A2 <= 0;	plane_HV_B1 <= 0;	plane_HV_B2 <= 0;
				plane_HV_shifter1_len <= 0;	plane_HV_shifter2_len <= 0;
				plane_HV_mux1_sel <= 0;     plane_HV_mux2_sel <= 0;
			end
			
	wire Is_HV_latch;
	assign Is_HV_latch = ((blk4x4_rec_counter == 0 && blk4x4_intra_precompute_counter != 7 && blk4x4_intra_precompute_counter != 2 && 
		blk4x4_intra_precompute_counter != 1 && blk4x4_intra_precompute_counter != 0) || (
		(blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20) && (blk4x4_intra_precompute_counter != 5 && 
		blk4x4_intra_precompute_counter != 2 && blk4x4_intra_precompute_counter != 1 && blk4x4_intra_precompute_counter != 0)));
	always @ (posedge clk)
		if (reset_n == 1'b0)
			plane_HV_out_reg <= 0;
		else if (Is_HV_latch)
			plane_HV_out_reg <= plane_HV_out;
	
	//	2.2 precomputation for b,c
	reg [14:0] plane_bc_in;
	reg plane_bc_IsLuma;
	wire [11:0] plane_bc;
	plane_bc_precomputation plane_bc_precomputation (
		.HV_in(plane_bc_in),
		.IsLuma(plane_bc_IsLuma),
		.bc_out(plane_bc)
		);
	always @ (mb_type_general[3:2] or Intra16x16_predmode or blk4x4_rec_counter or blk4x4_intra_precompute_counter or plane_HV_out_reg)
		//Intra16x16 plane
		if (mb_type_general[3:2] == 2'b10 && Intra16x16_predmode == `Intra16x16_Plane && blk4x4_rec_counter == 0)
			case (blk4x4_intra_precompute_counter)
				7,2    :begin	plane_bc_in <= plane_HV_out_reg;	plane_bc_IsLuma <= 1'b1;	end
				default:begin	plane_bc_in <= 0;                 plane_bc_IsLuma <= 1'b0;	end
			endcase
		//Chroma Cb,Cr plane
		else if (mb_type_general[3] == 1'b1 && (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20))
			case (blk4x4_intra_precompute_counter)
				5,2    :begin	plane_bc_in <= plane_HV_out_reg; plane_bc_IsLuma <= 1'b0;	end
				default:begin	plane_bc_in <= 0;                plane_bc_IsLuma <= 1'b0;	end
			endcase
		else
			begin	plane_bc_in <= 0;					plane_bc_IsLuma <= 1'b0;	end
	
	wire c_latch_ena;
	assign c_latch_ena = ((blk4x4_rec_counter == 0 && blk4x4_intra_precompute_counter == 7) || 
		((blk4x4_rec_counter == 16 || blk4x4_rec_counter == 20) && blk4x4_intra_precompute_counter == 5));
	always @ (posedge clk)
		if (reset_n == 0)
			plane_c_reg <= 0;
		else if (c_latch_ena) 
			plane_c_reg <= plane_bc;
	//	2.3 precomputation for a,and latch a & b at the same time at cycle 2
	reg [7:0] plane_a_pix_in1,plane_a_pix_in2;
	wire [13:0] plane_a;
	reg [13:0] plane_a_reg;
	
	plane_a_precomputation plane_a_precomputation(
	.pix_in1(plane_a_pix_in1),
	.pix_in2(plane_a_pix_in2),
	.a_out(plane_a)
	);
	always @ (blk4x4_rec_counter or blk4x4_intra_precompute_counter or Intra_mbAddrA_reg15 
		or Intra_mbAddrB_reg15 or Intra_mbAddrA_reg7 or Intra_mbAddrB_reg7)
		//Intra16x16
		if (blk4x4_rec_counter == 0 && blk4x4_intra_precompute_counter == 2)
			begin	
				plane_a_pix_in1 <= Intra_mbAddrA_reg15;	
				plane_a_pix_in2 <= Intra_mbAddrB_reg15;	
			end
		//Chroma 
		else if((blk4x4_rec_counter == 16  || blk4x4_rec_counter == 20) && blk4x4_intra_precompute_counter == 2)
			begin
				plane_a_pix_in1 <= Intra_mbAddrA_reg7;	
				plane_a_pix_in2 <= Intra_mbAddrB_reg7;	
			end
		else
			begin
				plane_a_pix_in1 <= 0;
				plane_a_pix_in2 <= 0;
			end	
			
	wire ab_latch_ena;
	assign ab_latch_ena = (blk4x4_intra_precompute_counter == 2);
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				plane_a_reg <= 0;
				plane_b_reg <= 0;
			end
		else if (ab_latch_ena)
			begin
				plane_a_reg <= plane_a;
				plane_b_reg <= plane_bc;
			end
	//	2.4 precomputation for main seed @ blk4x4_intra_precompute_counter == 1
	wire [13:0] main_seed_a;
	wire [11:0] main_seed_b,main_seed_c;
	wire main_seed_IsIntra16x16;
	
	main_seed_precomputation main_seed_precomputation (
		.a(main_seed_a),
		.b(main_seed_b),
		.c(main_seed_c),
		.IsIntra16x16(main_seed_IsIntra16x16),
		.main_seed(main_seed)
		); 
	assign main_seed_a = (blk4x4_intra_precompute_counter == 1)? plane_a_reg:0;
	assign main_seed_b = (blk4x4_intra_precompute_counter == 1)? plane_b_reg:0;
	assign main_seed_c = (blk4x4_intra_precompute_counter == 1)? plane_c_reg:0;
	assign main_seed_IsIntra16x16 = (blk4x4_intra_precompute_counter == 1)? ((blk4x4_rec_counter == 0)? 1'b1:1'b0):1'b0;
	 
	//----------------------------------------------------------------------------------------	
	//3.calculation: by Intra_pred_PE.v 
	//----------------------------------------------------------------------------------------
	
endmodule

module plane_a_precomputation (pix_in1,pix_in2,a_out);
	input [7:0] pix_in1,pix_in2;
	output [13:0] a_out;
	
	wire [8:0] sum;
	assign sum = pix_in1 + pix_in2;
	assign a_out = {1'b0,sum,4'b0};
endmodule

module plane_bc_precomputation (HV_in,IsLuma,bc_out);
	input [14:0] HV_in;
	input IsLuma;
	output [11:0] bc_out;
	
	wire [16:0] multiply_4or16;
	wire [16:0] product;
	wire [5:0] addend;
	wire [16:0] sum;
	
	assign multiply_4or16 = (IsLuma)? {HV_in,2'b0}:{HV_in[12:0],4'b0};
	assign product = multiply_4or16 + {{2{HV_in[14]}},HV_in};
	assign addend = (IsLuma)? 6'b100000:6'b010000;	//32 for luma,16 for chroma
	assign sum = product + addend;
	assign bc_out = (IsLuma)? {sum[16],sum[16:6]}:sum[16:5];  
	
endmodule

module plane_HV_precomputation (prev_in,A1,A2,B1,B2,shifter1_len,shifter2_len,mux1_sel,mux2_sel,Is7,HV_out);
	input [14:0] prev_in;
	input [7:0] A1,A2,B1,B2;
	input [1:0] shifter1_len,shifter2_len;
	input mux1_sel,mux2_sel;
	input Is7;
	output [14:0] HV_out;
	
	wire [7:0] neg_A2;
	wire signed [8:0] A1_minus_A2;
	wire signed [11:0] shifter1_out;
	wire [11:0] mux1_out;
	wire [14:0] adder1_out;
	wire [7:0] neg_B2;
	wire signed [8:0] B1_minus_B2;
	wire signed [11:0] shifter2_out;
	wire [9:0] mux2_out;
	wire [9:0] neg_mux2_out;
	wire [11:0] adder2_out;
	//Left part,multiply by 1,2,4,8
	assign neg_A2 = ~A2;
	assign A1_minus_A2 = {1'b0,A1} + {1'b1,neg_A2} + 1;	
	assign shifter1_out = A1_minus_A2 <<< shifter1_len;
	assign mux1_out = (mux1_sel == 1'b0)? {{3{A1_minus_A2[8]}},A1_minus_A2}:shifter1_out;
	assign adder1_out = prev_in + {{3{mux1_out[11]}},mux1_out};
	//Right part,multiply by 3,5,6,7
	assign neg_B2 = ~B2;
	assign B1_minus_B2 = {1'b0,B1} + {1'b1,neg_B2} + 1;
	assign shifter2_out = B1_minus_B2 <<< shifter2_len;
	assign mux2_out = (mux2_sel == 1'b0)? {B1_minus_B2[8],B1_minus_B2}:{B1_minus_B2,1'b0};
	assign neg_mux2_out = (Is7 == 1'b1)? (~mux2_out + 1):mux2_out;
	assign adder2_out = shifter2_out + {{2{neg_mux2_out[9]}},neg_mux2_out};
	assign HV_out = adder1_out + {{3{adder2_out[11]}},adder2_out};
endmodule

module main_seed_precomputation (a,b,c,IsIntra16x16,main_seed);
	input [13:0] a;
	input [11:0] b,c;
	input IsIntra16x16;
	output [15:0] main_seed;
	
	wire [14:0]	b_x8_or_x4;
	wire [14:0] c_x8_or_x4;
	wire [11:0] neg_b;
	wire [14:0] b_x7_or_x3;
	wire [15:0] neg_b_x7_or_x3;
	wire [15:0] neg_c_x8_or_x4;
		
	assign b_x8_or_x4 = (IsIntra16x16)? {b[11:0],3'b0}:{b[11],b[11:0],2'b0};
	assign c_x8_or_x4 = (IsIntra16x16)? {c[11:0],3'b0}:{c[11],c[11:0],2'b0};
	assign neg_b = ~ b;
	assign b_x7_or_x3 = b_x8_or_x4 + {{3{neg_b[11]}},neg_b} + 1;
	assign neg_b_x7_or_x3 = {~b_x7_or_x3[14],~b_x7_or_x3} + 1;
	assign neg_c_x8_or_x4 = {~c_x8_or_x4[14],~c_x8_or_x4} + 1;
	assign main_seed = {a[13],a[13],a} + (neg_c_x8_or_x4 + neg_b_x7_or_x3);
endmodule
	
	
	
	
	





















