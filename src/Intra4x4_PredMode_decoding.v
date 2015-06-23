//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Intra4x4_PredMode_decoding.v
// Generated : May 31, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding the prediction mode for Intra4x4	
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Intra4x4_PredMode_decoding (clk,reset_n,mb_pred_state,luma4x4BlkIdx,mb_num_h,mb_num_v,
	MBTypeGen_mbAddrA,MBTypeGen_mbAddrB_reg,constrained_intra_pred_flag,
	rem_intra4x4_pred_mode,prev_intra4x4_pred_mode_flag,Intra4x4PredMode_mbAddrB_dout,
	
	Intra4x4PredMode_CurrMb,
	Intra4x4PredMode_mbAddrB_cs_n,Intra4x4PredMode_mbAddrB_wr_n,Intra4x4PredMode_mbAddrB_rd_addr,
	Intra4x4PredMode_mbAddrB_wr_addr,Intra4x4PredMode_mbAddrB_din
	);
	input clk,reset_n;
	input [2:0] mb_pred_state;
	input [3:0] luma4x4BlkIdx;
	input [3:0] mb_num_h,mb_num_v;
	input [1:0] MBTypeGen_mbAddrA;
	input [21:0] MBTypeGen_mbAddrB_reg;
	input constrained_intra_pred_flag;
	input [2:0] rem_intra4x4_pred_mode;
	input prev_intra4x4_pred_mode_flag;
	input [15:0] Intra4x4PredMode_mbAddrB_dout;
	//input [8:0] pic_num;
	
	output [63:0] Intra4x4PredMode_CurrMb;
	output Intra4x4PredMode_mbAddrB_cs_n,Intra4x4PredMode_mbAddrB_wr_n;
	output [3:0] Intra4x4PredMode_mbAddrB_rd_addr,Intra4x4PredMode_mbAddrB_wr_addr;
	output [15:0] Intra4x4PredMode_mbAddrB_din; 
	
	reg Intra4x4PredMode_mbAddrB_cs_n,Intra4x4PredMode_mbAddrB_wr_n;
	reg [3:0] Intra4x4PredMode_mbAddrB_rd_addr,Intra4x4PredMode_mbAddrB_wr_addr;
	reg [15:0] Intra4x4PredMode_mbAddrB_din; 
		
	wire mbAddrA_availability;
	wire mbAddrB_availability; 
	wire mbAddrA;
	wire mbAddrB;
	wire [3:0] predIntra4x4PredMode;	//prediction mode obtained at `prev_intra4x4_pred_mode_flag_s
	reg dcOnlyPredictionFlag;
	reg [15:0] Intra4x4PredMode_mbAddrA;
	reg [63:0] Intra4x4PredMode_CurrMb;
	reg [3:0] Intra4x4PredModeA,Intra4x4PredModeB;
	
	reg [3:0] rem_Intra4x4PredMode;     //prediction mode obtained at `rem_intra4x4_pred_mode_s
	reg [3:0] predIntra4x4PredMode_reg; //the reg value of predIntra4x4PredMode
	
	
	reg [1:0] MBTypeGen_mbAddrB;
	always @ (mb_num_h or MBTypeGen_mbAddrB_reg)
		case (mb_num_h)
			0 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[1:0];
			1 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[3:2];
			2 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[5:4];
			3 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[7:6];
			4 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[9:8];
			5 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[11:10];
			6 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[13:12];
			7 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[15:14];
			8 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[17:16];
			9 :MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[19:18];
			10:MBTypeGen_mbAddrB <= MBTypeGen_mbAddrB_reg[21:20];
			default:MBTypeGen_mbAddrB <= 0;
		endcase

	//neighboring block decoding for Intra4x4 prediction mode,NO mapping from Blk4x4 order --> raster order
	assign mbAddrA_availability = (luma4x4BlkIdx == 0 || luma4x4BlkIdx == 2 
	|| luma4x4BlkIdx == 8 || luma4x4BlkIdx == 10)? ((mb_num_h == 0)? 1'b0:1'b1):1'b1;
	
	assign mbAddrB_availability = (luma4x4BlkIdx == 0 || luma4x4BlkIdx == 1 
	|| luma4x4BlkIdx == 4 || luma4x4BlkIdx == 5)? ((mb_num_v == 0)? 1'b0:1'b1):1'b1;
	
	assign mbAddrA = (luma4x4BlkIdx == 0 || luma4x4BlkIdx == 2 || luma4x4BlkIdx == 8 
	|| luma4x4BlkIdx == 10)? 1'b0:1'b1;	//0:left MB;1:curr MB
	
	assign mbAddrB = (luma4x4BlkIdx == 0 || luma4x4BlkIdx == 1 || luma4x4BlkIdx == 4 
	|| luma4x4BlkIdx == 5)? 1'b0:1'b1;	//0:upper MB;1:curr MB	
	
	//dcOnlyPredictionFlag	
	always @ (mb_pred_state or mbAddrA_availability or mbAddrB_availability or mbAddrA or mbAddrB or 
		MBTypeGen_mbAddrA or MBTypeGen_mbAddrB or constrained_intra_pred_flag)
		if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)
			begin
				if (mbAddrA_availability == 0)
					dcOnlyPredictionFlag <= 1;
				else if (mbAddrB_availability == 0)
					dcOnlyPredictionFlag <= 1;
				else if (mbAddrA == 0 && MBTypeGen_mbAddrA < 2 && constrained_intra_pred_flag == 1)
					dcOnlyPredictionFlag <= 1;
				else if (mbAddrB == 0 && MBTypeGen_mbAddrB < 2 && constrained_intra_pred_flag == 1)
					dcOnlyPredictionFlag <= 1;
				else 
					dcOnlyPredictionFlag <= 0;
			end
		else
			dcOnlyPredictionFlag <= 0;
	//Intra4x4PredModeA		
	always @ (mb_pred_state or dcOnlyPredictionFlag or mbAddrA or mbAddrA_availability or MBTypeGen_mbAddrA 
		or Intra4x4PredMode_mbAddrA or Intra4x4PredMode_CurrMb or luma4x4BlkIdx)
		if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)
			begin
				if (dcOnlyPredictionFlag == 1)
					Intra4x4PredModeA <= 2;
				else if (mbAddrA_availability == 1 && mbAddrA == 0 && MBTypeGen_mbAddrA != `MB_addrA_addrB_Intra4x4)//not coded in Intra4x4
					Intra4x4PredModeA <= 2;
				else
					case (luma4x4BlkIdx)
						0 :Intra4x4PredModeA <= Intra4x4PredMode_mbAddrA[3:0];
						1 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[3:0];
						2 :Intra4x4PredModeA <= Intra4x4PredMode_mbAddrA[7:4];
						3 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[11:8];
						4 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[7:4];
						5 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[19:16];
						6 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[15:12];
						7 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[27:24];
						8 :Intra4x4PredModeA <= Intra4x4PredMode_mbAddrA[11:8];
						9 :Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[35:32];
						10:Intra4x4PredModeA <= Intra4x4PredMode_mbAddrA[15:12];
						11:Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[43:40];
						12:Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[39:36];
						13:Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[51:48];
						14:Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[47:44];
						15:Intra4x4PredModeA <= Intra4x4PredMode_CurrMb[59:56];
					endcase
			end
		else
			Intra4x4PredModeA <= 0;	
	//Intra4x4PredModeB
	always @ (mb_pred_state or dcOnlyPredictionFlag or mbAddrB or mbAddrB_availability or MBTypeGen_mbAddrB 
		or Intra4x4PredMode_mbAddrB_dout or Intra4x4PredMode_CurrMb or luma4x4BlkIdx)
		if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)
			begin
				if (dcOnlyPredictionFlag == 1)
					Intra4x4PredModeB <= 2;
				else if (mbAddrB_availability == 1 && mbAddrB == 0 && MBTypeGen_mbAddrB != `MB_addrA_addrB_Intra4x4)	//not coded in Intra4x4
					Intra4x4PredModeB <= 2;
				else
					case (luma4x4BlkIdx)
						0 :Intra4x4PredModeB <= Intra4x4PredMode_mbAddrB_dout[15:12];
						1 :Intra4x4PredModeB <= Intra4x4PredMode_mbAddrB_dout[11:8];
						2 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[3:0];
						3 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[7:4];
						4 :Intra4x4PredModeB <= Intra4x4PredMode_mbAddrB_dout[7:4];
						5 :Intra4x4PredModeB <= Intra4x4PredMode_mbAddrB_dout[3:0];
						6 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[19:16];
						7 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[23:20];
						8 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[11:8];
						9 :Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[15:12];
						10:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[35:32];
						11:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[39:36];
						12:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[27:24];
						13:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[31:28];
						14:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[51:48];
						15:Intra4x4PredModeB <= Intra4x4PredMode_CurrMb[55:52];
					endcase
			end
		else
			Intra4x4PredModeB <= 0;	
	//obtain prediction mode at prev_intra4x4_pred_mode_flag_s		
	assign predIntra4x4PredMode = (Intra4x4PredModeA < Intra4x4PredModeB)? Intra4x4PredModeA:Intra4x4PredModeB;
	always @ (posedge clk)
		if (reset_n == 0)
			predIntra4x4PredMode_reg <= 0;
		else if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s && prev_intra4x4_pred_mode_flag == 0)
			predIntra4x4PredMode_reg <= predIntra4x4PredMode;
	//obtain prediction mode at rem_intra4x4_pred_mode_s
	always @ (mb_pred_state or rem_intra4x4_pred_mode or predIntra4x4PredMode_reg)	
		if (mb_pred_state == `rem_intra4x4_pred_mode_s)
			rem_Intra4x4PredMode <= ({1'b0,rem_intra4x4_pred_mode} < predIntra4x4PredMode_reg)?
				{1'b0,rem_intra4x4_pred_mode}:(rem_intra4x4_pred_mode + 1);
		else
			rem_Intra4x4PredMode <= 0;
	//-----------------------------
	//Intra4x4PredMode_CurrMb write
	//-----------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			Intra4x4PredMode_CurrMb <= 0;
		else if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s && prev_intra4x4_pred_mode_flag == 1)
			case (luma4x4BlkIdx)
				0 :Intra4x4PredMode_CurrMb[3:0]    <= predIntra4x4PredMode;
				1 :Intra4x4PredMode_CurrMb[7:4]    <= predIntra4x4PredMode;
				2 :Intra4x4PredMode_CurrMb[11:8]   <= predIntra4x4PredMode;
				3 :Intra4x4PredMode_CurrMb[15:12]  <= predIntra4x4PredMode;
				4 :Intra4x4PredMode_CurrMb[19:16]  <= predIntra4x4PredMode;
				5 :Intra4x4PredMode_CurrMb[23:20]  <= predIntra4x4PredMode;
				6 :Intra4x4PredMode_CurrMb[27:24]  <= predIntra4x4PredMode;
				7 :Intra4x4PredMode_CurrMb[31:28]  <= predIntra4x4PredMode;
				8 :Intra4x4PredMode_CurrMb[35:32]  <= predIntra4x4PredMode;
				9 :Intra4x4PredMode_CurrMb[39:36]  <= predIntra4x4PredMode;
				10 :Intra4x4PredMode_CurrMb[43:40] <= predIntra4x4PredMode;
				11 :Intra4x4PredMode_CurrMb[47:44] <= predIntra4x4PredMode;
				12 :Intra4x4PredMode_CurrMb[51:48] <= predIntra4x4PredMode; 
				13 :Intra4x4PredMode_CurrMb[55:52] <= predIntra4x4PredMode;
				14 :Intra4x4PredMode_CurrMb[59:56] <= predIntra4x4PredMode;
				15 :Intra4x4PredMode_CurrMb[63:60] <= predIntra4x4PredMode;
			endcase
		else if (mb_pred_state == `rem_intra4x4_pred_mode_s)
			case (luma4x4BlkIdx)
				0 :Intra4x4PredMode_CurrMb[3:0]    <= rem_Intra4x4PredMode;
				1 :Intra4x4PredMode_CurrMb[7:4]    <= rem_Intra4x4PredMode;
				2 :Intra4x4PredMode_CurrMb[11:8]   <= rem_Intra4x4PredMode;
				3 :Intra4x4PredMode_CurrMb[15:12]  <= rem_Intra4x4PredMode;
				4 :Intra4x4PredMode_CurrMb[19:16]  <= rem_Intra4x4PredMode;
				5 :Intra4x4PredMode_CurrMb[23:20]  <= rem_Intra4x4PredMode;
				6 :Intra4x4PredMode_CurrMb[27:24]  <= rem_Intra4x4PredMode;
				7 :Intra4x4PredMode_CurrMb[31:28]  <= rem_Intra4x4PredMode;
				8 :Intra4x4PredMode_CurrMb[35:32]  <= rem_Intra4x4PredMode;
				9 :Intra4x4PredMode_CurrMb[39:36]  <= rem_Intra4x4PredMode;
				10 :Intra4x4PredMode_CurrMb[43:40] <= rem_Intra4x4PredMode;
				11 :Intra4x4PredMode_CurrMb[47:44] <= rem_Intra4x4PredMode;
				12 :Intra4x4PredMode_CurrMb[51:48] <= rem_Intra4x4PredMode; 
				13 :Intra4x4PredMode_CurrMb[55:52] <= rem_Intra4x4PredMode;
				14 :Intra4x4PredMode_CurrMb[59:56] <= rem_Intra4x4PredMode;
				15 :Intra4x4PredMode_CurrMb[63:60] <= rem_Intra4x4PredMode;
			endcase
	//------------------------------
	//Intra4x4PredMode_mbAddrA write
	//------------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			Intra4x4PredMode_mbAddrA <= 0;
		else if (mb_num_h != 10) //mb_num_h == 10,no need to store mbAddrA
			begin
				if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s && prev_intra4x4_pred_mode_flag == 1)
					case (luma4x4BlkIdx)
						5: Intra4x4PredMode_mbAddrA[3:0]   <= predIntra4x4PredMode;
						7: Intra4x4PredMode_mbAddrA[7:4]   <= predIntra4x4PredMode;
						13:Intra4x4PredMode_mbAddrA[11:8]  <= predIntra4x4PredMode;
						15:Intra4x4PredMode_mbAddrA[15:12] <= predIntra4x4PredMode;
					endcase
				else if (mb_pred_state == `rem_intra4x4_pred_mode_s)
					case (luma4x4BlkIdx)
						5: Intra4x4PredMode_mbAddrA[3:0]   <= rem_Intra4x4PredMode;
						7: Intra4x4PredMode_mbAddrA[7:4]   <= rem_Intra4x4PredMode;
						13:Intra4x4PredMode_mbAddrA[11:8]  <= rem_Intra4x4PredMode;
						15:Intra4x4PredMode_mbAddrA[15:12] <= rem_Intra4x4PredMode;
					endcase
			end
	//----------------------------------------
	//Intra4x4PredMode_mbAddrB RF read & write
	//----------------------------------------
	always @ (reset_n or mb_num_v or mb_num_h or luma4x4BlkIdx or mb_pred_state or prev_intra4x4_pred_mode_flag
		or Intra4x4PredMode_CurrMb or predIntra4x4PredMode or rem_Intra4x4PredMode)
		if (reset_n == 0)
			begin
				Intra4x4PredMode_mbAddrB_cs_n    <= 1;	Intra4x4PredMode_mbAddrB_wr_n     <= 1; 
				Intra4x4PredMode_mbAddrB_rd_addr <= 0;	Intra4x4PredMode_mbAddrB_wr_addr  <= 0;	
				Intra4x4PredMode_mbAddrB_din <= 0;
			end
		else if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s)
			begin
				Intra4x4PredMode_mbAddrB_cs_n    <= 0;		//read is always even if in cases as luma4x4BlkIdx = 2,3,6,7...										  
				Intra4x4PredMode_mbAddrB_rd_addr <= mb_num_h;
				if (prev_intra4x4_pred_mode_flag == 1 && luma4x4BlkIdx == 15 && mb_num_v != 8)//write is conditional when mb_num_v != 8
					begin
						Intra4x4PredMode_mbAddrB_wr_n    <= 0;
						Intra4x4PredMode_mbAddrB_wr_addr <= mb_num_h;
						Intra4x4PredMode_mbAddrB_din     <= {Intra4x4PredMode_CurrMb[43:40],
						Intra4x4PredMode_CurrMb[47:44],Intra4x4PredMode_CurrMb[59:56],predIntra4x4PredMode};
					end
				else
					begin
						Intra4x4PredMode_mbAddrB_wr_n    <= 1;
						Intra4x4PredMode_mbAddrB_wr_addr <= 0;
						Intra4x4PredMode_mbAddrB_din     <= 0;
					end
			end
		else if (mb_pred_state == `rem_intra4x4_pred_mode_s)
			begin
				Intra4x4PredMode_mbAddrB_cs_n    <= 0;		//read is always even if in cases as luma4x4BlkIdx = 2,3,6,7...				
				Intra4x4PredMode_mbAddrB_rd_addr <= mb_num_h;
				if (luma4x4BlkIdx == 15 && mb_num_v != 8)	//write is conditional when mb_num_v != 8
					begin
						Intra4x4PredMode_mbAddrB_wr_n    <= 0;
						Intra4x4PredMode_mbAddrB_wr_addr <= mb_num_h;
						Intra4x4PredMode_mbAddrB_din     <= {Intra4x4PredMode_CurrMb[43:40],
						Intra4x4PredMode_CurrMb[47:44],Intra4x4PredMode_CurrMb[59:56],rem_Intra4x4PredMode};
					end
				else
					begin
						Intra4x4PredMode_mbAddrB_wr_n    <= 1;
						Intra4x4PredMode_mbAddrB_wr_addr <= 0;
						Intra4x4PredMode_mbAddrB_din     <= 0;
					end
			end
		else
			begin
				Intra4x4PredMode_mbAddrB_cs_n    <= 1;	Intra4x4PredMode_mbAddrB_wr_n     <= 1; 
				Intra4x4PredMode_mbAddrB_rd_addr <= 0;	Intra4x4PredMode_mbAddrB_wr_addr  <= 0;	
				Intra4x4PredMode_mbAddrB_din 	 <= 0;
			end
			
	/*
	// synopsys translate_off
	integer	tracefile;
	wire [6:0] mb_num;
	assign mb_num = mb_num_v * 11 + mb_num_h;
	
	initial
		begin
			tracefile = $fopen("intra_4x4_trace.txt");
		end
	always @ (posedge clk)
		if (mb_pred_state == `prev_intra4x4_pred_mode_flag_s && prev_intra4x4_pred_mode_flag == 1)
			begin
				$fdisplay (tracefile," Pic_num = %3d,MB_num = %3d,blkIdx = %3d,Intra4x4PredMode = %3d",
				pic_num,mb_num,luma4x4BlkIdx,predIntra4x4PredMode);
				if (luma4x4BlkIdx == 15)
					$fdisplay (tracefile,"--------------------------------------------------------------------");
			end
		else if (mb_pred_state == `rem_intra4x4_pred_mode_s)
			begin
				$fdisplay (tracefile," Pic_num = %3d,MB_num = %3d,blkIdx = %3d,Intra4x4PredMode = %3d",
				pic_num,mb_num,luma4x4BlkIdx,rem_Intra4x4PredMode);
				if (luma4x4BlkIdx == 15)
					$fdisplay (tracefile,"--------------------------------------------------------------------");
			end
	// synopsys translate_on
	*/
endmodule