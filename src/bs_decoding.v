//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : bs_decoding.v
// Generated : Nov 17,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Deblocking Filter Boundary Strength decoding
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module bs_decoding (clk,reset_n,gclk_bs_dec,gclk_end_of_MB_DEC,end_of_MB_DEC,end_of_one_blk4x4_sum,mb_num_h,mb_num_v,
	disable_DF,blk4x4_rec_counter,CodedBlockPatternLuma,mb_type_general,slice_data_state,residual_state,
	MBTypeGen_mbAddrA,MBTypeGen_mbAddrB_reg,end_of_one_residual_block,TotalCoeff,
	curr_DC_IsZero,Is_skipMB_mv_calc,
	mvx_mbAddrA,mvy_mbAddrA,mvx_mbAddrB_dout,mvy_mbAddrB_dout,
	mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3,mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3,
	
	bs_dec_counter,end_of_BS_DEC,mv_mbAddrB_rd_for_DF,
	bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3
	);
	input clk;
	input reset_n;
	input gclk_bs_dec;
	input gclk_end_of_MB_DEC;
	input end_of_MB_DEC;
	input end_of_one_blk4x4_sum;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [4:0] blk4x4_rec_counter;
	input disable_DF;
	input [3:0] CodedBlockPatternLuma;
	input [3:0] mb_type_general;
	input [3:0] slice_data_state;
	input [3:0] residual_state;
	input [1:0]  MBTypeGen_mbAddrA;
	input [21:0] MBTypeGen_mbAddrB_reg;
	input end_of_one_residual_block;
	input [4:0] TotalCoeff;
	input curr_DC_IsZero;
	input Is_skipMB_mv_calc;
	input [31:0] mvx_mbAddrA,mvy_mbAddrA,mvx_mbAddrB_dout,mvy_mbAddrB_dout;
	input [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	input [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	
	output [1:0] bs_dec_counter;
	output end_of_BS_DEC;
	output mv_mbAddrB_rd_for_DF;
	output [11:0] bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3;
	
	reg [11:0] bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3;
		
	//-------------------------------------------
	//mb_type_general needs to be latched for DF
	//-------------------------------------------
	reg [3:0] mb_type_general_DF;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mb_type_general_DF <= 4'b0;
		else if (!disable_DF && end_of_one_blk4x4_sum && blk4x4_rec_counter == 5'd22)
			mb_type_general_DF <= mb_type_general;
				
	reg [1:0] MB_inter_size;		
	always @ (mb_type_general_DF)	
		if (mb_type_general_DF[3] == 1'b0)
			case (mb_type_general_DF[2:0])
				3'b000,3'b101:MB_inter_size <= `I16x16;
				3'b001		 :MB_inter_size <= `I16x8;
				3'b010		 :MB_inter_size <= `I8x16;
				default		 :MB_inter_size <= `I8x8;
			endcase
		else //Although it should be Intra,but we have no other choice
			MB_inter_size <= `I8x8;
				
	reg [1:0] MBTypeGen_mbAddrB;		
	always @ (mb_num_h or MBTypeGen_mbAddrB_reg)
		case (mb_num_h)
			0: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[1:0];
			1: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[3:2];
			2: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[5:4];
			3: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[7:6];
			4: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[9:8];
			5: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[11:10];
			6: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[13:12];
			7: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[15:14];
			8: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[17:16];
			9: MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[19:18];
			10:MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[21:20];
			default:MBTypeGen_mbAddrB <= 0;
		endcase	
		
	reg [1:0] bs_dec_counter;
	always @ (posedge gclk_bs_dec or negedge reset_n)
		if (reset_n == 1'b0)
			bs_dec_counter <= 0;
		else 
			bs_dec_counter <= bs_dec_counter - 1;
	
	assign end_of_BS_DEC = (bs_dec_counter == 2'd1)? 1'b1:1'b0;
	
	wire mvx_V0_diff_GE4,mvx_V1_diff_GE4,mvx_V2_diff_GE4,mvx_V3_diff_GE4;
	wire mvy_V0_diff_GE4,mvy_V1_diff_GE4,mvy_V2_diff_GE4,mvy_V3_diff_GE4;
	wire mvx_H0_diff_GE4,mvx_H1_diff_GE4,mvx_H2_diff_GE4,mvx_H3_diff_GE4;
	wire mvy_H0_diff_GE4,mvy_H1_diff_GE4,mvy_H2_diff_GE4,mvy_H3_diff_GE4;
	
	
	//--------------------------------------------------------------------
	//If current MB is Inter,derive current MB non-zero coeff information
	//No need to do this for P_skip or Intra.No need for chroma,either.
	//--------------------------------------------------------------------
	reg [15:0] currMB_coeff;//whether each 4x4blk of current MB has at least one non-zero transform coeff
							//currMB_coeff is organized in zig-zag order,according to blk4x4_rec_counter
							//= 1'b1:this 4x4blk has at least one non-zero transform coeff
							//= 1'b0:this 4x4blk has all 16 zero transform coeff
							//only useful for Inter (excluding P_skip) MB
	always @ (posedge clk)
		if (reset_n == 1'b0)
			currMB_coeff <= 16'd0;
		else if (!disable_DF)
			begin
				//need to be reset evey MB
				//Since only Inter MB needs currMB_coeff,we can use "coded_block_pattern_s" state as timing slot
				if (slice_data_state == `coded_block_pattern_s)
					currMB_coeff <= 16'd0;
				else if (mb_type_general[3] == 1'b0 && mb_type_general[2:0] != 3'b101)	//Inter but not P_skip
					case (residual_state)
						`Intra16x16ACLevel_s:
						if (end_of_one_residual_block)
							case (blk4x4_rec_counter[3:0])
								4'd0 :currMB_coeff[0]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd1 :currMB_coeff[1]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd2 :currMB_coeff[2]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd3 :currMB_coeff[3]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd4 :currMB_coeff[4]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd5 :currMB_coeff[5]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd6 :currMB_coeff[6]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd7 :currMB_coeff[7]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd8 :currMB_coeff[8]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd9 :currMB_coeff[9]  <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd10:currMB_coeff[10] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd11:currMB_coeff[11] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd12:currMB_coeff[12] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd13:currMB_coeff[13] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd14:currMB_coeff[14] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
								4'd15:currMB_coeff[15] <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b0:1'b1;
							endcase		
						`Intra16x16ACLevel_0_s:
						case (blk4x4_rec_counter[3:0])
							4'd0:currMB_coeff[0]   <= ~curr_DC_IsZero;
							4'd1:currMB_coeff[1]   <= ~curr_DC_IsZero;
							4'd2:currMB_coeff[2]   <= ~curr_DC_IsZero;
							4'd3:currMB_coeff[3]   <= ~curr_DC_IsZero;
							4'd4:currMB_coeff[4]   <= ~curr_DC_IsZero;
							4'd5:currMB_coeff[5]   <= ~curr_DC_IsZero;
							4'd6:currMB_coeff[6]   <= ~curr_DC_IsZero;
							4'd7:currMB_coeff[7]   <= ~curr_DC_IsZero;
							4'd8:currMB_coeff[8]   <= ~curr_DC_IsZero;
							4'd9:currMB_coeff[9]   <= ~curr_DC_IsZero;
							4'd10:currMB_coeff[10] <= ~curr_DC_IsZero;
							4'd11:currMB_coeff[11] <= ~curr_DC_IsZero;
							4'd12:currMB_coeff[12] <= ~curr_DC_IsZero;
							4'd13:currMB_coeff[13] <= ~curr_DC_IsZero;
							4'd14:currMB_coeff[14] <= ~curr_DC_IsZero;
							4'd15:currMB_coeff[15] <= ~curr_DC_IsZero;
						endcase
						`LumaLevel_s:
						case (blk4x4_rec_counter[3:0])
							4'd0 :if (CodedBlockPatternLuma[0] == 1'b0) currMB_coeff[0]  <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[0]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd1 :if (CodedBlockPatternLuma[0] == 1'b0) currMB_coeff[1] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[1]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd2 :if (CodedBlockPatternLuma[0] == 1'b0) currMB_coeff[2] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[2]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd3 :if (CodedBlockPatternLuma[0] == 1'b0) currMB_coeff[3] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[3]  <= (TotalCoeff == 0)? 1'b0:1'b1;
							4'd4 :if (CodedBlockPatternLuma[1] == 1'b0) currMB_coeff[4] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[4]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd5 :if (CodedBlockPatternLuma[1] == 1'b0) currMB_coeff[5] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[5]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd6 :if (CodedBlockPatternLuma[1] == 1'b0) currMB_coeff[6] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[6]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd7 :if (CodedBlockPatternLuma[1] == 1'b0) currMB_coeff[7] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[7]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd8 :if (CodedBlockPatternLuma[2] == 1'b0) currMB_coeff[8] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[8]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd9 :if (CodedBlockPatternLuma[2] == 1'b0) currMB_coeff[9] 	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[9]  <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd10:if (CodedBlockPatternLuma[2] == 1'b0) currMB_coeff[10]	<= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[10] <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd11:if (CodedBlockPatternLuma[2] == 1'b0) currMB_coeff[11] <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[11] <= (TotalCoeff == 0)? 1'b0:1'b1;
							4'd12:if (CodedBlockPatternLuma[3] == 1'b0) currMB_coeff[12] <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[12] <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd13:if (CodedBlockPatternLuma[3] == 1'b0) currMB_coeff[13] <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[13] <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd14:if (CodedBlockPatternLuma[3] == 1'b0) currMB_coeff[14] <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[14] <= (TotalCoeff == 0)? 1'b0:1'b1;	
							4'd15:if (CodedBlockPatternLuma[3] == 1'b0) currMB_coeff[15] <= 1'b0;
								  else if (end_of_one_residual_block)	currMB_coeff[15] <= (TotalCoeff == 0)? 1'b0:1'b1;		  
						endcase			  
					  	`LumaLevel_0_s:currMB_coeff <= 16'd0;
					endcase
			end
			
	//whether each 4x4blk of MB at mbAddrB has at least one non-zero transform coeff
	reg [43:0] mbAddrB_coeff_reg;
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 1'b0)
			mbAddrB_coeff_reg <= 44'd0;
		else if (!disable_DF && mb_type_general[3] == 1'b0 && mb_type_general[2:0] != 3'b101 && mb_num_v != 8) //Inter but not P_skip
			case (mb_num_h)
				4'd0 :mbAddrB_coeff_reg[3:0]   <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd1 :mbAddrB_coeff_reg[7:4]   <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd2 :mbAddrB_coeff_reg[11:8]  <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd3 :mbAddrB_coeff_reg[15:12] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd4 :mbAddrB_coeff_reg[19:16] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd5 :mbAddrB_coeff_reg[23:20] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd6 :mbAddrB_coeff_reg[27:24] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd7 :mbAddrB_coeff_reg[31:28] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd8 :mbAddrB_coeff_reg[35:32] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd9 :mbAddrB_coeff_reg[39:36] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
				4'd10:mbAddrB_coeff_reg[43:40] <= {currMB_coeff[15],currMB_coeff[14],currMB_coeff[11],currMB_coeff[10]};
			endcase
	//-------------------------------------------------
	//backup mbAddrA coding information to derive bs_V0
	//-------------------------------------------------
	reg [3:0] mbAddrA_coeff;
	reg [31:0] mbAddrA_mvx;
	reg [31:0] mbAddrA_mvy;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				mbAddrA_coeff <= 4'b0;
				mbAddrA_mvx	 <= 32'b0;
				mbAddrA_mvy  <= 32'b0;
			end
		else if (!disable_DF && mb_num_h != 0 && 
			((mb_type_general == `MB_P_skip && Is_skipMB_mv_calc && MBTypeGen_mbAddrA[1] == 1'b0) //Current MB is P_skip 
			|| (slice_data_state == `mb_type_s && mb_type_general[3] == 1'b0)))				//Current MB is Inter
			begin
				mbAddrA_mvx <= mvx_mbAddrA;	mbAddrA_mvy <= mvy_mbAddrA;
				//if mbAddrA is Inter (not P_skip),back up non-zero residual coeff information
				if (MBTypeGen_mbAddrA[0] == 1'b0)	mbAddrA_coeff <= {currMB_coeff[15],currMB_coeff[13],currMB_coeff[7],currMB_coeff[5]};
			end
	//-------------------------------------------------
	//backup mbAddrB coding information to derive bs_H0
	//-------------------------------------------------
	
	//1)For P_skip,at "Is_skipMB_mv_calc", no matter DF is enabled or not,mvx_mbAddrB/mvy_mbAddrB should be read to 
	//	derive current motion vector
	//2)For Inter other than P_skip, mvx_mbAddrB/mvy_mbAddrB are read at mb_pred or sub_mb_pred state.So we add a new
	//	signal "mv_mbAddrB_rd_for_DF" at "slice_data_state == `mb_type_s"
	assign mv_mbAddrB_rd_for_DF = (!disable_DF && slice_data_state == `mb_type_s && mb_type_general[3] == 1'b0 && mb_num_v != 0);
	reg [3:0] mbAddrB_coeff;
	reg [31:0] mbAddrB_mvx;
	reg [31:0] mbAddrB_mvy;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				mbAddrB_coeff <= 4'b0;
				mbAddrB_mvx	 <= 32'b0;
				mbAddrB_mvy  <= 32'b0;
			end
		else if (!disable_DF && mb_num_v != 0 && 
			((mb_type_general == `MB_P_skip && Is_skipMB_mv_calc && MBTypeGen_mbAddrB[1] == 1'b0)	//Current MB is P_skip 
			|| (slice_data_state == `mb_type_s && mb_type_general[3] == 1'b0)))				//Current MB is Inter
			begin
				mbAddrB_mvx <= mvx_mbAddrB_dout;	mbAddrB_mvy <= mvy_mbAddrB_dout;
				//if mbAddrB is Inter (not P_skip),back up non-zero residual coeff information
				if (MBTypeGen_mbAddrB[0] == 1'b0)
					case (mb_num_h)
						4'd0 :mbAddrB_coeff <= mbAddrB_coeff_reg[3:0];
						4'd1 :mbAddrB_coeff <= mbAddrB_coeff_reg[7:4];
						4'd2 :mbAddrB_coeff <= mbAddrB_coeff_reg[11:8];
						4'd3 :mbAddrB_coeff <= mbAddrB_coeff_reg[15:12];
						4'd4 :mbAddrB_coeff <= mbAddrB_coeff_reg[19:16];
						4'd5 :mbAddrB_coeff <= mbAddrB_coeff_reg[23:20];
						4'd6 :mbAddrB_coeff <= mbAddrB_coeff_reg[27:24];
						4'd7 :mbAddrB_coeff <= mbAddrB_coeff_reg[31:28];
						4'd8 :mbAddrB_coeff <= mbAddrB_coeff_reg[35:32];
						4'd9 :mbAddrB_coeff <= mbAddrB_coeff_reg[39:36];
						4'd10:mbAddrB_coeff <= mbAddrB_coeff_reg[43:40];
					endcase
			end
	
	always @ (posedge gclk_bs_dec or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				bs_V0 <= 0;	bs_V1 <= 0;	bs_V2 <= 0;	bs_V3 <= 0;
				bs_H0 <= 0;	bs_H1 <= 0;	bs_H2 <= 0;	bs_H3 <= 0;
			end
		//-----------------------
		//Current MB is P_skip
		//-----------------------
		else if (mb_type_general_DF == `MB_P_skip)
			case (bs_dec_counter)
				2'b00:
				begin
					//V0
					if (mb_num_h == 0) 						//edge of frame,bs = 0
						bs_V0 <= 12'b0;
					else if (MBTypeGen_mbAddrA[1] == 1'b1) 	//mbAddrA is Intra,bs = 4
						bs_V0 <= 12'b100100100100;
					else if (MBTypeGen_mbAddrA    == `MB_addrA_addrB_P_skip)	//mbAddrA is P_skip
						bs_V0 <= (mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 12'b001001001001:12'b0;
					else 									//mbAddrA is Inter
						begin 
							bs_V0[2:0]  <= (mbAddrA_coeff[0])? 3'd2:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;
							bs_V0[5:3]  <= (mbAddrA_coeff[1])? 3'd2:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;	
							bs_V0[8:6]  <= (mbAddrA_coeff[2])? 3'd2:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;	
							bs_V0[11:9] <= (mbAddrA_coeff[3])? 3'd2:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;	
						end
					//H0
					if (mb_num_v == 0)						//edge of frame,bs = 0
						bs_H0 <= 12'b0;
					else if (MBTypeGen_mbAddrB[1] == 1'b1)	//mbAddrB is Intra,bs=4
						bs_H0 <= 12'b100100100100;
					else if (MBTypeGen_mbAddrB == `MB_addrA_addrB_P_skip)	//mbAddrB is P_skip
						bs_H0 <= (mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 12'b001001001001:12'b0;
					else
						begin 
							bs_H0[2:0]  <= (mbAddrB_coeff[0])? 3'd2:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;
							bs_H0[5:3]  <= (mbAddrB_coeff[1])? 3'd2:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;	
							bs_H0[8:6]  <= (mbAddrB_coeff[2])? 3'd2:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;	
							bs_H0[11:9] <= (mbAddrB_coeff[3])? 3'd2:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;	
						end
				end
				2'b11:begin	bs_V1 <= 0;	bs_H1 <= 0;	end
				2'b10:begin	bs_V2 <= 0;	bs_H2 <= 0;	end
				2'b01:begin	bs_V3 <= 0;	bs_H3 <= 0;	end
			endcase
			//--------------------
			//Current MB is Intra
			//-----------------------
			else if (mb_type_general_DF[3] == 1'b1)
				case (bs_dec_counter)
					2'b00:
					begin
						bs_V0 <= (mb_num_h == 0)? 12'b0:12'b100100100100; 
						bs_H0 <= (mb_num_v == 0)? 12'b0:12'b100100100100;
					end
					2'b11:begin bs_V1 <= 12'b011011011011;	bs_H1 <= 12'b011011011011; end 
					2'b10:begin bs_V2 <= 12'b011011011011;	bs_H2 <= 12'b011011011011; end 
					2'b01:begin	bs_V3 <= 12'b011011011011; 	bs_H3 <= 12'b011011011011; end
				endcase
			//-----------------------
			//Current MB is Inter
			//-----------------------
			else 
				case (bs_dec_counter)
					2'b00:	//V0,H0
					begin
						//V0
						if (mb_num_h == 0) 						//edge of frame,bs = 0
							bs_V0 <= 12'b0;
						else if (MBTypeGen_mbAddrA[1] == 1'b1) 	//mbAddrA is Intra,bs = 4
							bs_V0 <= 12'b100100100100;
						else if (MBTypeGen_mbAddrA    == `MB_addrA_addrB_P_skip)	//mbAddrA is P_skip
							begin
								bs_V0[2:0]  <= (currMB_coeff[0])?  3'd2:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;
								bs_V0[5:3]  <= (currMB_coeff[2])?  3'd2:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;
								bs_V0[8:6]  <= (currMB_coeff[8])?  3'd2:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;
								bs_V0[11:9] <= (currMB_coeff[10])? 3'd2:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;
							end
						else 									//mbAddrA is Inter
							begin 
								bs_V0[2:0]  <= (mbAddrA_coeff[0] || currMB_coeff[0])?  3'd2:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;
								bs_V0[5:3]  <= (mbAddrA_coeff[1] || currMB_coeff[2])?  3'd2:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;	
								bs_V0[8:6]  <= (mbAddrA_coeff[2] || currMB_coeff[8])?  3'd2:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;	
								bs_V0[11:9] <= (mbAddrA_coeff[3] || currMB_coeff[10])? 3'd2:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;	
							end
						//H0
						if (mb_num_v == 0) 						//edge of frame,bs = 0
							bs_H0 <= 12'b0;
						else if (MBTypeGen_mbAddrB[1] == 1'b1) 	//mbAddrB is Intra,bs = 4
							bs_H0 <= 12'b100100100100;
						else if (MBTypeGen_mbAddrB == `MB_addrA_addrB_P_skip)	//mbAddrB is P_skip
							begin
								bs_H0[2:0]  <= (currMB_coeff[0])? 3'd2:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;
								bs_H0[5:3]  <= (currMB_coeff[1])? 3'd2:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;
								bs_H0[8:6]  <= (currMB_coeff[4])? 3'd2:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;
								bs_H0[11:9] <= (currMB_coeff[5])? 3'd2:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;
							end
						else 										//mbAddrB is Inter
							begin 
								bs_H0[2:0]  <= (mbAddrB_coeff[0] || currMB_coeff[0])? 3'd2:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;
								bs_H0[5:3]  <= (mbAddrB_coeff[1] || currMB_coeff[1])? 3'd2:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;	
								bs_H0[8:6]  <= (mbAddrB_coeff[2] || currMB_coeff[4])? 3'd2:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;	
								bs_H0[11:9] <= (mbAddrB_coeff[3] || currMB_coeff[5])? 3'd2:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;	
							end
					end
					2'b11://V1,H1
					begin
						bs_V1[2:0]  <= (currMB_coeff[0]  || currMB_coeff[1])?  3'd2:(MB_inter_size != `I8x8)? 
										0:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;	  
						
						bs_V1[5:3]  <= (currMB_coeff[2]  || currMB_coeff[3])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;	
						
						bs_V1[8:6]  <= (currMB_coeff[8]  || currMB_coeff[9])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;
						
						bs_V1[11:9] <= (currMB_coeff[10] || currMB_coeff[11])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;
						
						bs_H1[2:0]  <= (currMB_coeff[0]  || currMB_coeff[2])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;
						
						bs_H1[5:3]  <= (currMB_coeff[1]  || currMB_coeff[3])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;
						
						bs_H1[8:6]  <= (currMB_coeff[4]  || currMB_coeff[6])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;					
						bs_H1[11:9] <= (currMB_coeff[5]  || currMB_coeff[7])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;
					end
					2'b10://V2,H2
					begin
						bs_V2[2:0]  <= (currMB_coeff[1]  || currMB_coeff[4])?  3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I16x8)?
										0:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;	
										
						bs_V2[5:3]  <= (currMB_coeff[3]  || currMB_coeff[6])?  3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I16x8)?
										0:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;	 
										
						bs_V2[8:6]  <= (currMB_coeff[9]  || currMB_coeff[12])? 3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I16x8)?
										0:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;	
										
						bs_V2[11:9] <= (currMB_coeff[11] || currMB_coeff[14])? 3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I16x8)?
										0:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;	
										
						bs_H2[2:0]  <= (currMB_coeff[2]  || currMB_coeff[8])?  3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I8x16)?
										0:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;	
										
						bs_H2[5:3]  <= (currMB_coeff[3]  || currMB_coeff[9])?  3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I8x16)?
										0:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;
										
						bs_H2[8:6]  <= (currMB_coeff[6]  || currMB_coeff[12])? 3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I8x16)?
										0:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;					
										
						bs_H2[11:9] <= (currMB_coeff[7]  || currMB_coeff[13])? 3'd2:(MB_inter_size == `I16x16 || MB_inter_size == `I8x16)?
										0:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;
					end
					2'b01://V3,H3
					begin
						bs_V3[2:0]  <= (currMB_coeff[4]  || currMB_coeff[5])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V0_diff_GE4 || mvy_V0_diff_GE4)? 3'd1:3'd0;
						
						bs_V3[5:3]  <= (currMB_coeff[6]  || currMB_coeff[7])?  3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V1_diff_GE4 || mvy_V1_diff_GE4)? 3'd1:3'd0;
						
						bs_V3[8:6]  <= (currMB_coeff[12] || currMB_coeff[13])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V2_diff_GE4 || mvy_V2_diff_GE4)? 3'd1:3'd0;					
						
						bs_V3[11:9] <= (currMB_coeff[14] || currMB_coeff[15])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_V3_diff_GE4 || mvy_V3_diff_GE4)? 3'd1:3'd0;					
						
						bs_H3[2:0]  <= (currMB_coeff[8]  || currMB_coeff[10])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H0_diff_GE4 || mvy_H0_diff_GE4)? 3'd1:3'd0;
						
						bs_H3[5:3]  <= (currMB_coeff[9]  || currMB_coeff[11])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H1_diff_GE4 || mvy_H1_diff_GE4)? 3'd1:3'd0;
						
						bs_H3[8:6]  <= (currMB_coeff[12] || currMB_coeff[14])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H2_diff_GE4 || mvy_H2_diff_GE4)? 3'd1:3'd0;					
						
						bs_H3[11:9]  <= (currMB_coeff[13] || currMB_coeff[15])? 3'd2:(MB_inter_size != `I8x8)?
										0:(mvx_H3_diff_GE4 || mvy_H3_diff_GE4)? 3'd1:3'd0;
					end
				endcase
				
	reg [7:0] mvx_V0_diff_a,mvx_V0_diff_b;
	reg [7:0] mvx_V1_diff_a,mvx_V1_diff_b;
	reg [7:0] mvx_V2_diff_a,mvx_V2_diff_b;
	reg [7:0] mvx_V3_diff_a,mvx_V3_diff_b;
	reg [7:0] mvy_V0_diff_a,mvy_V0_diff_b;
	reg [7:0] mvy_V1_diff_a,mvy_V1_diff_b;
	reg [7:0] mvy_V2_diff_a,mvy_V2_diff_b;
	reg [7:0] mvy_V3_diff_a,mvy_V3_diff_b;
	
	reg [7:0] mvx_H0_diff_a,mvx_H0_diff_b;
	reg [7:0] mvx_H1_diff_a,mvx_H1_diff_b;
	reg [7:0] mvx_H2_diff_a,mvx_H2_diff_b;
	reg [7:0] mvx_H3_diff_a,mvx_H3_diff_b;
	reg [7:0] mvy_H0_diff_a,mvy_H0_diff_b;
	reg [7:0] mvy_H1_diff_a,mvy_H1_diff_b;
	reg [7:0] mvy_H2_diff_a,mvy_H2_diff_b;
	reg [7:0] mvy_H3_diff_a,mvy_H3_diff_b;
	
	mv_diff_GE4 mvx_V0_diff (.mv_a(mvx_V0_diff_a),.mv_b(mvx_V0_diff_b),.diff_GE4(mvx_V0_diff_GE4));
	mv_diff_GE4 mvx_V1_diff (.mv_a(mvx_V1_diff_a),.mv_b(mvx_V1_diff_b),.diff_GE4(mvx_V1_diff_GE4));
	mv_diff_GE4 mvx_V2_diff (.mv_a(mvx_V2_diff_a),.mv_b(mvx_V2_diff_b),.diff_GE4(mvx_V2_diff_GE4));
	mv_diff_GE4 mvx_V3_diff (.mv_a(mvx_V3_diff_a),.mv_b(mvx_V3_diff_b),.diff_GE4(mvx_V3_diff_GE4));
	mv_diff_GE4 mvy_V0_diff (.mv_a(mvy_V0_diff_a),.mv_b(mvy_V0_diff_b),.diff_GE4(mvy_V0_diff_GE4));
	mv_diff_GE4 mvy_V1_diff (.mv_a(mvy_V1_diff_a),.mv_b(mvy_V1_diff_b),.diff_GE4(mvy_V1_diff_GE4));
	mv_diff_GE4 mvy_V2_diff (.mv_a(mvy_V2_diff_a),.mv_b(mvy_V2_diff_b),.diff_GE4(mvy_V2_diff_GE4));
	mv_diff_GE4 mvy_V3_diff (.mv_a(mvy_V3_diff_a),.mv_b(mvy_V3_diff_b),.diff_GE4(mvy_V3_diff_GE4));
	
	mv_diff_GE4 mvx_H0_diff (.mv_a(mvx_H0_diff_a),.mv_b(mvx_H0_diff_b),.diff_GE4(mvx_H0_diff_GE4));
	mv_diff_GE4 mvx_H1_diff (.mv_a(mvx_H1_diff_a),.mv_b(mvx_H1_diff_b),.diff_GE4(mvx_H1_diff_GE4));
	mv_diff_GE4 mvx_H2_diff (.mv_a(mvx_H2_diff_a),.mv_b(mvx_H2_diff_b),.diff_GE4(mvx_H2_diff_GE4));
	mv_diff_GE4 mvx_H3_diff (.mv_a(mvx_H3_diff_a),.mv_b(mvx_H3_diff_b),.diff_GE4(mvx_H3_diff_GE4));
	mv_diff_GE4 mvy_H0_diff (.mv_a(mvy_H0_diff_a),.mv_b(mvy_H0_diff_b),.diff_GE4(mvy_H0_diff_GE4));
	mv_diff_GE4 mvy_H1_diff (.mv_a(mvy_H1_diff_a),.mv_b(mvy_H1_diff_b),.diff_GE4(mvy_H1_diff_GE4));
	mv_diff_GE4 mvy_H2_diff (.mv_a(mvy_H2_diff_a),.mv_b(mvy_H2_diff_b),.diff_GE4(mvy_H2_diff_GE4));
	mv_diff_GE4 mvy_H3_diff (.mv_a(mvy_H3_diff_a),.mv_b(mvy_H3_diff_b),.diff_GE4(mvy_H3_diff_GE4));
	
	always @ (end_of_MB_DEC or disable_DF or bs_dec_counter or mb_type_general_DF
		or mb_num_h or MB_inter_size or MBTypeGen_mbAddrA 
		or mbAddrA_mvx or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3
		or mbAddrA_mvy or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3)
		if ((end_of_MB_DEC && disable_DF == 1'b0) || bs_dec_counter != 0)
			begin
				//-----------------------
				//Current MB is P_skip
				//-----------------------
				if (mb_type_general_DF == `MB_P_skip && bs_dec_counter == 2'b00)//V0
					begin
						if (mb_num_h != 0 && MBTypeGen_mbAddrA == `MB_addrA_addrB_P_skip)		//mbAddrA is P_skip
							begin 
								mvx_V0_diff_a <= mbAddrA_mvx[7:0]; mvx_V0_diff_b <= mvx_CurrMb0[7:0];
								mvx_V1_diff_a <= 0; mvx_V1_diff_b <= 0;	 
								mvx_V2_diff_a <= 0; mvx_V2_diff_b <= 0;
								mvx_V3_diff_a <= 0; mvx_V3_diff_b <= 0;	
								mvy_V0_diff_a <= mbAddrA_mvy[7:0]; mvy_V0_diff_b <= mvy_CurrMb0[7:0];
								mvy_V1_diff_a <= 0; mvy_V1_diff_b <= 0;	 
								mvy_V2_diff_a <= 0; mvy_V2_diff_b <= 0;
								mvy_V3_diff_a <= 0; mvy_V3_diff_b <= 0;
							end 
						else if (mb_num_h != 0 && MBTypeGen_mbAddrA == `MB_addrA_addrB_Inter)	//mbAddrA is Inter
							begin
								mvx_V0_diff_a <= mbAddrA_mvx[7:0];  mvx_V0_diff_b <= mvx_CurrMb0[7:0];
								mvx_V1_diff_a <= mbAddrA_mvx[15:8]; mvx_V1_diff_b <= mvx_CurrMb0[7:0];
								mvx_V2_diff_a <= mbAddrA_mvx[23:16];mvx_V2_diff_b <= mvx_CurrMb0[7:0];
								mvx_V3_diff_a <= mbAddrA_mvx[31:24];mvx_V3_diff_b <= mvx_CurrMb0[7:0];
								mvy_V0_diff_a <= mbAddrA_mvy[7:0];  mvy_V0_diff_b <= mvy_CurrMb0[7:0];
								mvy_V1_diff_a <= mbAddrA_mvy[15:8]; mvy_V1_diff_b <= mvy_CurrMb0[7:0];
								mvy_V2_diff_a <= mbAddrA_mvy[23:16];mvy_V2_diff_b <= mvy_CurrMb0[7:0];
								mvy_V3_diff_a <= mbAddrA_mvy[31:24];mvy_V3_diff_b <= mvy_CurrMb0[7:0];
							end
						else	
							begin 
								mvx_V0_diff_a <= 0; mvx_V0_diff_b <= 0;
								mvx_V1_diff_a <= 0; mvx_V1_diff_b <= 0;	 
								mvx_V2_diff_a <= 0; mvx_V2_diff_b <= 0;
								mvx_V3_diff_a <= 0; mvx_V3_diff_b <= 0;	
								mvy_V0_diff_a <= 0; mvy_V0_diff_b <= 0;
								mvy_V1_diff_a <= 0; mvy_V1_diff_b <= 0;	 
								mvy_V2_diff_a <= 0; mvy_V2_diff_b <= 0;
								mvy_V3_diff_a <= 0; mvy_V3_diff_b <= 0;
							end
					end	
				//-----------------------
				//Current MB is Inter
				//-----------------------
				else if (mb_type_general_DF[3] == 1'b0)
					case (bs_dec_counter)
						2'b00:	//V0
						if (mb_num_h != 0 && (MBTypeGen_mbAddrA[1] == 1'b0)) //mbAddrA is P_skip or Inter		
							begin
								mvx_V0_diff_a <= mbAddrA_mvx[7:0];  mvx_V0_diff_b <= mvx_CurrMb0[7:0];
								
								mvx_V1_diff_a <= mbAddrA_mvx[15:8]; 
								mvx_V1_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb0[23:16]; 
								
								mvx_V2_diff_a <= mbAddrA_mvx[23:16];
								mvx_V2_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb2[7:0];
								
								mvx_V3_diff_a <= mbAddrA_mvx[31:24];
								mvx_V3_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb2[23:16];
								
								mvy_V0_diff_a <= mbAddrA_mvy[7:0];  mvy_V0_diff_b <= mvy_CurrMb0[7:0];
								
								mvy_V1_diff_a <= mbAddrA_mvy[15:8]; 
								mvy_V1_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb0[23:16];
								
								mvy_V2_diff_a <= mbAddrA_mvy[23:16];
								mvy_V2_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb2[7:0];
								
								mvy_V3_diff_a <= mbAddrA_mvy[31:24];
								mvy_V3_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb2[23:16];
							end
						else
							begin 
								mvx_V0_diff_a <= 0; mvx_V0_diff_b <= 0;
								mvx_V1_diff_a <= 0; mvx_V1_diff_b <= 0;	 
								mvx_V2_diff_a <= 0; mvx_V2_diff_b <= 0;
								mvx_V3_diff_a <= 0; mvx_V3_diff_b <= 0;	
								mvy_V0_diff_a <= 0; mvy_V0_diff_b <= 0;
								mvy_V1_diff_a <= 0; mvy_V1_diff_b <= 0;	 
								mvy_V2_diff_a <= 0; mvy_V2_diff_b <= 0;
								mvy_V3_diff_a <= 0; mvy_V3_diff_b <= 0;
							end
						2'b11:	//V1
						begin
							mvx_V0_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[7:0];  
							mvx_V0_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[15:8];
							mvx_V1_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[23:16]; 
							mvx_V1_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[31:24];
							mvx_V2_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[7:0];
							mvx_V2_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[15:8];
							mvx_V3_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[23:16];
							mvx_V3_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[31:24];	
							
							mvy_V0_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[7:0];  
							mvy_V0_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[15:8];
							mvy_V1_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[23:16]; 
							mvy_V1_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[31:24];
							mvy_V2_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[7:0];
							mvy_V2_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[15:8];
							mvy_V3_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[23:16];
							mvy_V3_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[31:24];
						end
						2'b10:	//V2
						begin
							mvx_V0_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb0[15:8];  
							mvx_V0_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb1[7:0];
							mvx_V1_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb0[31:24]; 
							mvx_V1_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb1[23:16];
							mvx_V2_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb2[15:8];
							mvx_V2_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb3[7:0];
							mvx_V3_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb2[31:24];
							mvx_V3_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvx_CurrMb3[23:16];
							mvy_V0_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb0[15:8];  
							mvy_V0_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb1[7:0];
							mvy_V1_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb0[31:24]; 
							mvy_V1_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb1[23:16];
							mvy_V2_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb2[15:8];
							mvy_V2_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb3[7:0];
							mvy_V3_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb2[31:24];
							mvy_V3_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I16x8)? 0:mvy_CurrMb3[23:16];
						end
						2'b01:	//V3
						begin
							mvx_V0_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[7:0];  
							mvx_V0_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[15:8];
							mvx_V1_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[23:16]; 
							mvx_V1_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[31:24];
							mvx_V2_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[7:0];
							mvx_V2_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[15:8];
							mvx_V3_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[23:16];
							mvx_V3_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[31:24];
							
							mvy_V0_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[7:0];  
							mvy_V0_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[15:8];
							mvy_V1_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[23:16]; 
							mvy_V1_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[31:24];
							mvy_V2_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[7:0];
							mvy_V2_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[15:8];
							mvy_V3_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[23:16];
							mvy_V3_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[31:24];
						end	
					endcase
				else
					begin 
						mvx_V0_diff_a <= 0; mvx_V0_diff_b <= 0;
						mvx_V1_diff_a <= 0; mvx_V1_diff_b <= 0;	 
						mvx_V2_diff_a <= 0; mvx_V2_diff_b <= 0;
						mvx_V3_diff_a <= 0; mvx_V3_diff_b <= 0;
						mvy_V0_diff_a <= 0; mvy_V0_diff_b <= 0;
						mvy_V1_diff_a <= 0; mvy_V1_diff_b <= 0;	 
						mvy_V2_diff_a <= 0; mvy_V2_diff_b <= 0;
						mvy_V3_diff_a <= 0; mvy_V3_diff_b <= 0;
					end
			end
		else
			begin 
				mvx_V0_diff_a <= 0; mvx_V0_diff_b <= 0;
				mvx_V1_diff_a <= 0; mvx_V1_diff_b <= 0;	 
				mvx_V2_diff_a <= 0; mvx_V2_diff_b <= 0;
				mvx_V3_diff_a <= 0; mvx_V3_diff_b <= 0;
				mvy_V0_diff_a <= 0; mvy_V0_diff_b <= 0;
				mvy_V1_diff_a <= 0; mvy_V1_diff_b <= 0;	 
				mvy_V2_diff_a <= 0; mvy_V2_diff_b <= 0;
				mvy_V3_diff_a <= 0; mvy_V3_diff_b <= 0;
			end
			
					
	always @ (end_of_MB_DEC or disable_DF or bs_dec_counter or mb_type_general_DF
		or mb_num_v or MBTypeGen_mbAddrB or MB_inter_size 
		or mbAddrB_mvx or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3
		or mbAddrB_mvy or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3)
		if ((end_of_MB_DEC && disable_DF == 1'b0) || bs_dec_counter != 0)
			begin
				//-----------------------
				//Current MB is P_skip
				//-----------------------
				if (mb_type_general_DF == `MB_P_skip && bs_dec_counter == 2'b00)	//H0
					begin
						if (mb_num_v != 0 && MBTypeGen_mbAddrB == `MB_addrA_addrB_P_skip)		//mbAddrB is P_skip
							begin 
								mvx_H0_diff_a <= mbAddrB_mvx[31:24]; mvx_H0_diff_b <= mvx_CurrMb0[7:0];
								mvx_H1_diff_a <= 0; mvx_H1_diff_b <= 0;	 
								mvx_H2_diff_a <= 0; mvx_H2_diff_b <= 0;
								mvx_H3_diff_a <= 0; mvx_H3_diff_b <= 0;	
								mvy_H0_diff_a <= mbAddrB_mvy[31:24]; mvy_H0_diff_b <= mvy_CurrMb0[7:0];
								mvy_H1_diff_a <= 0; mvy_H1_diff_b <= 0;	 
								mvy_H2_diff_a <= 0; mvy_H2_diff_b <= 0;
								mvy_H3_diff_a <= 0; mvy_H3_diff_b <= 0;
							end 
						else if (mb_num_v != 0 && MBTypeGen_mbAddrB == 2'b00)	//mbAddrB is Inter
							begin
								mvx_H0_diff_a <= mbAddrB_mvx[31:24]; mvx_H0_diff_b <= mvx_CurrMb0[7:0];
								mvx_H1_diff_a <= mbAddrB_mvx[23:16]; mvx_H1_diff_b <= mvx_CurrMb0[7:0];
								mvx_H2_diff_a <= mbAddrB_mvx[15:8];  mvx_H2_diff_b <= mvx_CurrMb0[7:0];
								mvx_H3_diff_a <= mbAddrB_mvx[7:0];   mvx_H3_diff_b <= mvx_CurrMb0[7:0];
								mvy_H0_diff_a <= mbAddrB_mvy[31:24]; mvy_H0_diff_b <= mvy_CurrMb0[7:0];
								mvy_H1_diff_a <= mbAddrB_mvy[23:16]; mvy_H1_diff_b <= mvy_CurrMb0[7:0];
								mvy_H2_diff_a <= mbAddrB_mvy[15:8];  mvy_H2_diff_b <= mvy_CurrMb0[7:0];
								mvy_H3_diff_a <= mbAddrB_mvy[7:0];   mvy_H3_diff_b <= mvy_CurrMb0[7:0];
							end
						else	
							begin 
								mvx_H0_diff_a <= 0; mvx_H0_diff_b <= 0;
								mvx_H1_diff_a <= 0; mvx_H1_diff_b <= 0;	 
								mvx_H2_diff_a <= 0; mvx_H2_diff_b <= 0;
								mvx_H3_diff_a <= 0; mvx_H3_diff_b <= 0;	
								mvy_H0_diff_a <= 0; mvy_H0_diff_b <= 0;
								mvy_H1_diff_a <= 0; mvy_H1_diff_b <= 0;	 
								mvy_H2_diff_a <= 0; mvy_H2_diff_b <= 0;
								mvy_H3_diff_a <= 0; mvy_H3_diff_b <= 0;
							end
					end	
				//-----------------------
				//Current MB is Inter
				//-----------------------
				else if (mb_type_general_DF[3] == 1'b0)
					case (bs_dec_counter)
						2'b00:	//H0
						if (mb_num_v != 0 && (MBTypeGen_mbAddrB[1] == 1'b0))//mbAddrB is P_skip or Inter
							begin
								mvx_H0_diff_a <= mbAddrB_mvx[31:24]; mvx_H0_diff_b <= mvx_CurrMb0[7:0];
								
								mvx_H1_diff_a <= mbAddrB_mvx[23:16]; 
								mvx_H1_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb0[15:8];
								
								mvx_H2_diff_a <= mbAddrB_mvx[15:8];  
								mvx_H2_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb1[7:0];
								
								mvx_H3_diff_a <= mbAddrB_mvx[7:0];   
								mvx_H3_diff_b <= (MB_inter_size == `I16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb1[15:8];
								
								mvy_H0_diff_a <= mbAddrB_mvy[31:24]; mvy_H0_diff_b <= mvy_CurrMb0[7:0];
								
								mvy_H1_diff_a <= mbAddrB_mvy[23:16]; 
								mvy_H1_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb0[15:8];
								
								mvy_H2_diff_a <= mbAddrB_mvy[15:8];  
								mvy_H2_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb1[7:0];
								
								mvy_H3_diff_a <= mbAddrB_mvy[7:0];   
								mvy_H3_diff_b <= (MB_inter_size == `I16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb1[15:8];
							end
						else
							begin 
								mvx_H0_diff_a <= 0; mvx_H0_diff_b <= 0;
								mvx_H1_diff_a <= 0; mvx_H1_diff_b <= 0;	 
								mvx_H2_diff_a <= 0; mvx_H2_diff_b <= 0;
								mvx_H3_diff_a <= 0; mvx_H3_diff_b <= 0;	
								mvy_H0_diff_a <= 0; mvy_H0_diff_b <= 0;
								mvy_H1_diff_a <= 0; mvy_H1_diff_b <= 0;	 
								mvy_H2_diff_a <= 0; mvy_H2_diff_b <= 0;
								mvy_H3_diff_a <= 0; mvy_H3_diff_b <= 0;
							end
						2'b11:	//H1
						begin
							mvx_H0_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[7:0];  
							mvx_H0_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[23:16];
							mvx_H1_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[15:8]; 
							mvx_H1_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb0[31:24];
							mvx_H2_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[7:0];
							mvx_H2_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[23:16];
							mvx_H3_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[15:8];
							mvx_H3_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb1[31:24];	
							
							mvy_H0_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[7:0];  
							mvy_H0_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[23:16];
							mvy_H1_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[15:8]; 
							mvy_H1_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb0[31:24];
							mvy_H2_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[7:0];
							mvy_H2_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[23:16];
							mvy_H3_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[15:8];
							mvy_H3_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb1[31:24];	
						end
						2'b10:	//H2
						begin
							mvx_H0_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb0[23:16];  
							mvx_H0_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb2[7:0];
							mvx_H1_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb0[31:24]; 
							mvx_H1_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb2[15:8];
							mvx_H2_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb1[23:16];
							mvx_H2_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb3[7:0];
							mvx_H3_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb1[31:24];
							mvx_H3_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvx_CurrMb3[15:8]; 
							
							mvy_H0_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb0[23:16];  
							mvy_H0_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb2[7:0];
							mvy_H1_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb0[31:24]; 
							mvy_H1_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb2[15:8];
							mvy_H2_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb1[23:16];
							mvy_H2_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb3[7:0];
							mvy_H3_diff_a <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb1[31:24];
							mvy_H3_diff_b <= (MB_inter_size == `I16x16 || MB_inter_size == `I8x16)? 0:mvy_CurrMb3[15:8]; 
							
						end
						2'b01:	//H3
						begin
							mvx_H0_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[7:0];  
							mvx_H0_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[23:16];
							mvx_H1_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[15:8]; 
							mvx_H1_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb2[31:24];
							mvx_H2_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[7:0];
							mvx_H2_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[23:16];
							mvx_H3_diff_a <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[15:8];
							mvx_H3_diff_b <= (MB_inter_size != `I8x8)? 0:mvx_CurrMb3[31:24];
							
							mvy_H0_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[7:0];  
							mvy_H0_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[23:16];
							mvy_H1_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[15:8]; 
							mvy_H1_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb2[31:24];
							mvy_H2_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[7:0];
							mvy_H2_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[23:16];
							mvy_H3_diff_a <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[15:8];
							mvy_H3_diff_b <= (MB_inter_size != `I8x8)? 0:mvy_CurrMb3[31:24];
						end	
					endcase
				else
					begin 
						mvx_H0_diff_a <= 0; mvx_H0_diff_b <= 0;
						mvx_H1_diff_a <= 0; mvx_H1_diff_b <= 0;	 
						mvx_H2_diff_a <= 0; mvx_H2_diff_b <= 0;
						mvx_H3_diff_a <= 0; mvx_H3_diff_b <= 0;
						mvy_H0_diff_a <= 0; mvy_H0_diff_b <= 0;
						mvy_H1_diff_a <= 0; mvy_H1_diff_b <= 0;	 
						mvy_H2_diff_a <= 0; mvy_H2_diff_b <= 0;
						mvy_H3_diff_a <= 0; mvy_H3_diff_b <= 0;
					end
			end
		else
			begin 
				mvx_H0_diff_a <= 0; mvx_H0_diff_b <= 0;
				mvx_H1_diff_a <= 0; mvx_H1_diff_b <= 0;	 
				mvx_H2_diff_a <= 0; mvx_H2_diff_b <= 0;
				mvx_H3_diff_a <= 0; mvx_H3_diff_b <= 0;
				mvy_H0_diff_a <= 0; mvy_H0_diff_b <= 0;
				mvy_H1_diff_a <= 0; mvy_H1_diff_b <= 0;	 
				mvy_H2_diff_a <= 0; mvy_H2_diff_b <= 0;
				mvy_H3_diff_a <= 0; mvy_H3_diff_b <= 0;
			end
	/*		
	// synopsys translate_off
	integer	tracefile;
	integer pic_num;
	wire [6:0] mb_num;
	assign mb_num = mb_num_v * 11 + mb_num_h;
	
	initial
		begin
			tracefile = $fopen("bs_trace.txt");
		end
	reg bs_dec_will_end;
	always @ (posedge clk)
		if (bs_dec_counter == 2'b01)
			bs_dec_will_end <= 1'b1;
		else
			bs_dec_will_end <= 1'b0;
	always @ (posedge clk or negedge reset_n)
		if (reset_n == 1'b0)
			pic_num <= 0;
		else if (bs_dec_will_end)
			begin
				$fdisplay (tracefile, "-------------------------------");
				if (mb_num == 0)
					$fdisplay (tracefile, " Pic_num = %3d,MB_num =  98",(pic_num - 1));
				else
					$fdisplay (tracefile, " Pic_num = %3d,MB_num = %3d",pic_num,(mb_num - 1));
				$fdisplay (tracefile, " Vertical   Edge 0:Bs = %d,%d,%d,%d",bs_V0[2:0],bs_V0[5:3],bs_V0[8:6],bs_V0[11:9]);
				$fdisplay (tracefile, " Vertical   Edge 1:Bs = %d,%d,%d,%d",bs_V1[2:0],bs_V1[5:3],bs_V1[8:6],bs_V1[11:9]);
				$fdisplay (tracefile, " Vertical   Edge 2:Bs = %d,%d,%d,%d",bs_V2[2:0],bs_V2[5:3],bs_V2[8:6],bs_V2[11:9]);
				$fdisplay (tracefile, " Vertical   Edge 3:Bs = %d,%d,%d,%d",bs_V3[2:0],bs_V3[5:3],bs_V3[8:6],bs_V3[11:9]);
				$fdisplay (tracefile, " Horizontal Edge 0:Bs = %d,%d,%d,%d",bs_H0[2:0],bs_H0[5:3],bs_H0[8:6],bs_H0[11:9]);
				$fdisplay (tracefile, " Horizontal Edge 1:Bs = %d,%d,%d,%d",bs_H1[2:0],bs_H1[5:3],bs_H1[8:6],bs_H1[11:9]);
				$fdisplay (tracefile, " Horizontal Edge 2:Bs = %d,%d,%d,%d",bs_H2[2:0],bs_H2[5:3],bs_H2[8:6],bs_H2[11:9]);
				$fdisplay (tracefile, " Horizontal Edge 3:Bs = %d,%d,%d,%d",bs_H3[2:0],bs_H3[5:3],bs_H3[8:6],bs_H3[11:9]);
				if (mb_num == 98)
					pic_num <= pic_num + 1;
			end
	// synopsys translate_on
	*/
endmodule			

module mv_diff_GE4 (mv_a,mv_b,diff_GE4);
	input [7:0] mv_a,mv_b;
	output diff_GE4;
	wire [7:0] diff_tmp;
	wire [6:0] diff;
	assign diff_tmp = mv_a + ~ mv_b + 1;
	assign diff	= (diff_tmp[7] == 1'b1)? (~diff_tmp[6:0] + 1):diff_tmp[6:0];
	assign diff_GE4 = (diff[6:2] != 0)? 1'b1:1'b0;
endmodule
						