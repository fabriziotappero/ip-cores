//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_mv_decoding.v
// Generated : May 25, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding the motion vector x and motion vector y for Inter prediction and P_skip
// SearchRange = 16pix -> 64 -> -64 ~ + 64 -> mvd[7:0], mv[7:0], mvp[7:0]
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_mv_decoding (clk,reset_n,Is_skip_run_entry,Is_skip_run_end,
	slice_data_state,mb_pred_state,sub_mb_pred_state,mvd,
	mb_num,mb_num_h,mb_num_v,mb_type_general,sub_mb_type,end_of_MB_DEC,mbPartIdx,subMbPartIdx,compIdx,
	MBTypeGen_mbAddrA,MBTypeGen_mbAddrB_reg,MBTypeGen_mbAddrD,
	mvx_mbAddrB_dout,mvy_mbAddrB_dout,mvx_mbAddrC_dout,mvy_mbAddrC_dout,mv_mbAddrB_rd_for_DF,
	
	skip_mv_calc,Is_skipMB_mv_calc,mvx_mbAddrA,mvy_mbAddrA,
	mvx_mbAddrB_cs_n,mvx_mbAddrB_wr_n,mvx_mbAddrB_rd_addr,mvx_mbAddrB_wr_addr,mvx_mbAddrB_din,
	mvy_mbAddrB_cs_n,mvy_mbAddrB_wr_n,mvy_mbAddrB_rd_addr,mvy_mbAddrB_wr_addr,mvy_mbAddrB_din,
	mvx_mbAddrC_cs_n,mvx_mbAddrC_wr_n,mvx_mbAddrC_rd_addr,mvx_mbAddrC_wr_addr,mvx_mbAddrC_din,
	mvy_mbAddrC_cs_n,mvy_mbAddrC_wr_n,mvy_mbAddrC_rd_addr,mvy_mbAddrC_wr_addr,mvy_mbAddrC_din,
	mv_is16x16,
	mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3,
	mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3);
	input clk,reset_n;
	input Is_skip_run_entry;
	input Is_skip_run_end;
	input [3:0] slice_data_state;
	input [2:0] mb_pred_state;
	input [1:0] sub_mb_pred_state; 
	input [7:0] mvd;
	input [6:0] mb_num;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [3:0] mb_type_general;
	input [1:0] sub_mb_type;
	input end_of_MB_DEC;
	input [1:0] mbPartIdx,subMbPartIdx;
	input compIdx;
	input [1:0] MBTypeGen_mbAddrA;
	input MBTypeGen_mbAddrD;
	input [21:0] MBTypeGen_mbAddrB_reg;
	input [31:0] mvx_mbAddrB_dout,mvy_mbAddrB_dout;
	input [7:0]  mvx_mbAddrC_dout,mvy_mbAddrC_dout;
	input mv_mbAddrB_rd_for_DF;
	
	output skip_mv_calc;
	output Is_skipMB_mv_calc;
	output [31:0] mvx_mbAddrA,mvy_mbAddrA;
	output mvx_mbAddrB_cs_n,mvy_mbAddrB_cs_n,mvx_mbAddrC_cs_n,mvy_mbAddrC_cs_n;
	output mvx_mbAddrB_wr_n,mvy_mbAddrB_wr_n,mvx_mbAddrC_wr_n,mvy_mbAddrC_wr_n;
	output [3:0] mvx_mbAddrB_rd_addr,mvy_mbAddrB_rd_addr,mvx_mbAddrC_rd_addr,mvy_mbAddrC_rd_addr;
	output [3:0] mvx_mbAddrB_wr_addr,mvy_mbAddrB_wr_addr,mvx_mbAddrC_wr_addr,mvy_mbAddrC_wr_addr;
	output [31:0] mvx_mbAddrB_din,mvy_mbAddrB_din;
	output [7:0] mvx_mbAddrC_din,mvy_mbAddrC_din;
	output mv_is16x16;
	output [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	output [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	reg mvx_mbAddrB_cs_n,mvy_mbAddrB_cs_n,mvx_mbAddrC_cs_n,mvy_mbAddrC_cs_n;
	reg mvx_mbAddrB_wr_n,mvy_mbAddrB_wr_n,mvx_mbAddrC_wr_n,mvy_mbAddrC_wr_n;
	reg [3:0] mvx_mbAddrB_rd_addr,mvy_mbAddrB_rd_addr,mvx_mbAddrC_rd_addr,mvy_mbAddrC_rd_addr;
	reg [3:0] mvx_mbAddrB_wr_addr,mvy_mbAddrB_wr_addr,mvx_mbAddrC_wr_addr,mvy_mbAddrC_wr_addr;
	reg [31:0] mvx_mbAddrB_din,mvy_mbAddrB_din;
	reg [7:0] mvx_mbAddrC_din,mvy_mbAddrC_din;
	reg mv_is16x16;
	reg [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	reg [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
		
	reg [7:0] mvpAx,mvpAy,mvpBx,mvpBy,mvpCx,mvpCy;
	reg [31:0] mvx_mbAddrA,mvy_mbAddrA;
	wire [7:0] mvx_mbAddrD,mvy_mbAddrD;
	reg [7:0] mvpx,mvpy,mvx,mvy;
	
	reg skip_mv_calc; //This signal is of reg type and is active for one cycle after end_of_MB_DEC and before 
					  //trigger_blk4x4_inter_pred.It is used to direct motion vector prediction for skipped MB
	always @ (posedge clk)
		if (reset_n == 1'b0)
			skip_mv_calc <= 1'b0;
		else if (slice_data_state == `skip_run_duration && end_of_MB_DEC && !Is_skip_run_end)
			skip_mv_calc <= 1'b1;
		else
			skip_mv_calc <= 1'b0; 
	
	wire Is_skipMB_mv_calc;
	assign Is_skipMB_mv_calc = Is_skip_run_entry | skip_mv_calc;
	
	reg [1:0] MBTypeGen_mbAddrB;
	reg [1:0] MBTypeGen_mbAddrC;
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
	always @ (mb_num_h or MBTypeGen_mbAddrB_reg)
		case (mb_num_h)
			0:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[3:2];
			1:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[5:4];
			2:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[7:6];
			3:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[9:8];
			4:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[11:10];
			5:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[13:12];
			6:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[15:14];
			7:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[17:16];
			8:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[19:18];
			9:MBTypeGen_mbAddrC <= MBTypeGen_mbAddrB_reg[21:20];
			default:MBTypeGen_mbAddrC <= 0;
		endcase	  
	
	wire refIdxL0_A; //Here refIdxL0_A == 1'b1 is equal to refIdxL0_A == -1 in Page122 of H.264 2003.5 standard
	wire refIdxL0_B; //Here refIdxL0_B == 1'b1 is equal to refIdxL0_B == -1 in Page122 of H.264 2003.5 standard
	reg  refIdxL0_C; //Here refIdxL0_C == 1'b1 is equal to refIdxL0_C == -1 in Page122 of H.264 2003.5 standard
	
	assign refIdxL0_A = (
	//P_skip
	(Is_skipMB_mv_calc ||
	//Inter16x16,Inter16x8,Inter8x16 left blk
	(mb_pred_state == `mvd_l0_s && (mb_type_general == `MB_Inter16x16 || mb_type_general == `MB_Inter16x8 || (mb_type_general == `MB_Inter8x16 && mbPartIdx == 0))) ||
	//Inter8x8,left most blk
	(sub_mb_pred_state == `sub_mvd_l0_s && (mbPartIdx == 0 || mbPartIdx == 2) && (
				sub_mb_type == 0 || 
				sub_mb_type == 1 || 
				(sub_mb_type == 2 && subMbPartIdx == 0) || 
				(sub_mb_type == 3 && (subMbPartIdx == 0 || subMbPartIdx == 2))))) &&
	(mb_num_h == 0 || MBTypeGen_mbAddrA[1] == 1))? 1'b1:1'b0; 
	
	assign refIdxL0_B = (
	//P_skip
	(Is_skipMB_mv_calc ||
	//Inter16x16,Inter16x8 upper blk,Inter8x16
	(mb_pred_state == `mvd_l0_s && (mb_type_general == `MB_Inter16x16 || (mb_type_general == `MB_Inter16x8 && mbPartIdx == 0) || mb_type_general == `MB_Inter8x16)) ||
	//Inter8x8,left most blk
	(sub_mb_pred_state == `sub_mvd_l0_s && (mbPartIdx == 0 || mbPartIdx == 1) && (
				sub_mb_type == 0 || 
				sub_mb_type == 2 || 
				(sub_mb_type == 1 && subMbPartIdx == 0) || 
				(sub_mb_type == 3 && (subMbPartIdx == 0 || subMbPartIdx == 1))))) &&
	(mb_num_v == 0 || MBTypeGen_mbAddrB[1] == 1))? 1'b1:1'b0; 
	
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state or mb_type_general or mb_num_v or mb_num_h
		or sub_mb_type or mbPartIdx or subMbPartIdx or MBTypeGen_mbAddrC[1] or MBTypeGen_mbAddrD
		or refIdxL0_A or refIdxL0_B)
		//P_skip,Inter16x16
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16))
			begin
				if 		(mb_num_v == 0)		refIdxL0_C <= 1'b1;
				else if (mb_num_h == 10)	refIdxL0_C <= (MBTypeGen_mbAddrD    == `MB_addrD_Intra)? 1'b1:1'b0;
				else						refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8)
			begin 
				if (mbPartIdx == 0)	//upper blk
					begin
						if 		(mb_num_v == 0)		refIdxL0_C <= 1'b1;
						else if (mb_num_h == 10)	refIdxL0_C <= (MBTypeGen_mbAddrD    == `MB_addrD_Intra)? 1'b1:1'b0;
						else						refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
					end
				else 				//bottom blk
					refIdxL0_C <= refIdxL0_A;
			end
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16)
			begin
				if (mbPartIdx == 0)	//left blk
					refIdxL0_C <= refIdxL0_B;
				else				//right blk
					begin
						if (mb_num_v == 0 || mb_num_h == 10)	refIdxL0_C <= refIdxL0_B;
						else									refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
					end
			end
		//Inter8x8 and below
		else if (sub_mb_pred_state == `sub_mvd_l0_s)
			case (mbPartIdx)
				2'b00:	//left-top 8x8 blk
				case (sub_mb_type)
					0:refIdxL0_C <= refIdxL0_B;
					1:refIdxL0_C <= (subMbPartIdx == 0)? refIdxL0_B:refIdxL0_A;	
					2:refIdxL0_C <= refIdxL0_B;
					3:
					case (subMbPartIdx)
						0,1:refIdxL0_C <= refIdxL0_B;
						2,3:refIdxL0_C <= 1'b0;
					endcase
				endcase
				2'b01:	//right-top 8x8 blk
				case (sub_mb_type)
					0:	//8x8
					if 		(mb_num_v == 0)	 refIdxL0_C <= 1'b1;
					else if (mb_num_h == 10) refIdxL0_C <= refIdxL0_B;
					else					 refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
					1:	//8x4
					if (subMbPartIdx == 0)
						begin
							if 		(mb_num_v == 0)	 refIdxL0_C <= 1'b1;
							else if (mb_num_h == 10) refIdxL0_C <= refIdxL0_B;
							else					 refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
						end
					else
						refIdxL0_C <= 1'b0;
					2:	//4x8
					if (subMbPartIdx == 0)	refIdxL0_C <= refIdxL0_B;
					else
						begin
							if 		(mb_num_v == 0)	 refIdxL0_C <= 1'b1;
							else if (mb_num_h == 10) refIdxL0_C <= refIdxL0_B;
							else					 refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
						end
					3:	//4x4
					case (subMbPartIdx)
						0:refIdxL0_C <= refIdxL0_B;
						1:
						begin
							if 		(mb_num_v == 0)	 refIdxL0_C <= 1'b1;
							else if (mb_num_h == 10) refIdxL0_C <= refIdxL0_B;
							else					 refIdxL0_C <= (MBTypeGen_mbAddrC[1] == 1'b1)? 1'b1:1'b0;
						end
						2,3:refIdxL0_C <= 1'b0;
					endcase
				endcase
				2'b10:	//left-bottom 8x8 blk
				case (sub_mb_type)
					0:refIdxL0_C <= 1'b0;
					1:refIdxL0_C <= (subMbPartIdx == 0)? 1'b0:refIdxL0_A;	
					2:refIdxL0_C <= 1'b0;
					3:refIdxL0_C <= 1'b0;
				endcase
				2'b11:	//right-bottom 8x8 blk
				refIdxL0_C <= 1'b0;
			endcase
		else
			refIdxL0_C <= 1'b0;
	
	//-------------
	//mvpAx
	//-------------
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state 
		or mb_type_general or sub_mb_type or mbPartIdx or subMbPartIdx or compIdx 
		or mvx_mbAddrA or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)	
		//P_skip or Inter16x16
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0))
			mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[7:0];
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0) 
			begin
				if (mbPartIdx == 0)
					mvpAx <= {8{refIdxL0_B}} & mvx_mbAddrA[7:0];
				else
					mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[23:16]; 
			end
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 0)
			begin
				if (mbPartIdx == 0)
					mvpAx <= {8{~refIdxL0_A}}  & mvx_mbAddrA[7:0];
				else
					mvpAx <= {8{refIdxL0_C}} & mvx_CurrMb0[15:8];
			end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	//sub_mb_pred
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[7:0];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[7:0];
						1:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[15:8];
						default:mvpAx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[7:0]; 
						1:mvpAx <= mvx_CurrMb0[7:0];
						default:mvpAx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[7:0];
						1:mvpAx <= mvx_CurrMb0[7:0];
						2:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[15:8];
						3:mvpAx <= mvx_CurrMb0[23:16]; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvpAx <= mvx_CurrMb0[15:8];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb0[15:8];	1:mvpAx <= mvx_CurrMb0[31:24];
						default:mvpAx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb0[15:8];	1:mvpAx <= mvx_CurrMb1[7:0];
						default:mvpAx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb0[15:8] ;	1:mvpAx <= mvx_CurrMb1[7:0];
						2:mvpAx <= mvx_CurrMb0[31:24];	3:mvpAx <= mvx_CurrMb1[23:16];	
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[23:16];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[23:16];
						1:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[31:24];
						default:mvpAx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[23:16];
						1:mvpAx <= mvx_CurrMb2[7:0];
						default:mvpAx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[23:16];
						1:mvpAx <= mvx_CurrMb2[7:0];
						2:mvpAx <= {8{~refIdxL0_A}} & mvx_mbAddrA[31:24];
						3:mvpAx <= mvx_CurrMb2[23:16]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpAx <= mvx_CurrMb2[15:8];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb2[15:8];	1:mvpAx <= mvx_CurrMb2[31:24];
						default:mvpAx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb2[15:8];	1:mvpAx <= mvx_CurrMb3[7:0];
						default:mvpAx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAx <= mvx_CurrMb2[15:8];	1:mvpAx <= mvx_CurrMb3[7:0];
						2:mvpAx <= mvx_CurrMb2[31:24];	3:mvpAx <= mvx_CurrMb3[23:16];	
					endcase
				endcase
			endcase
		else
			mvpAx <= 0;
	
	//-------------
	//mvpAy
	//-------------
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state 
		or mb_type_general or sub_mb_type or mbPartIdx or subMbPartIdx or compIdx 
		or mvy_mbAddrA or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)	
		//P_skip or Inter16x16
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1))
			mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0];
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
			begin
				if (mbPartIdx == 0)
					mvpAy <= {8{refIdxL0_B}} & mvy_mbAddrA[7:0];
				else
					mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[23:16]; 
			end 
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 1)
			begin
				if (mbPartIdx == 0)
					mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0];
				else
					mvpAy <= {8{refIdxL0_C}} & mvy_CurrMb0[15:8];
			end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	//sub_mb_pred
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0];
						1:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[15:8];
						default:mvpAy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0]; 
						1:mvpAy <= mvy_CurrMb0[7:0];
						default:mvpAy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[7:0];
						1:mvpAy <= mvy_CurrMb0[7:0];
						2:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[15:8];
						3:mvpAy <= mvy_CurrMb0[23:16]; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvpAy <= mvy_CurrMb0[15:8];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb0[15:8];	1:mvpAy <= mvy_CurrMb0[31:24];
						default:mvpAy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb0[15:8];	1:mvpAy <= mvy_CurrMb1[7:0];
						default:mvpAy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb0[15:8] ;	1:mvpAy <= mvy_CurrMb1[7:0];
						2:mvpAy <= mvy_CurrMb0[31:24];	3:mvpAy <= mvy_CurrMb1[23:16];	
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[23:16];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[23:16];
						1:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[31:24];
						default:mvpAy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[23:16];
						1:mvpAy <= mvy_CurrMb2[7:0];
						default:mvpAy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[23:16];
						1:mvpAy <= mvy_CurrMb2[7:0];
						2:mvpAy <= {8{~refIdxL0_A}} & mvy_mbAddrA[31:24];
						3:mvpAy <= mvy_CurrMb2[23:16]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpAy <= mvy_CurrMb2[15:8];
					1:	//8x4
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb2[15:8];	1:mvpAy <= mvy_CurrMb2[31:24];
						default:mvpAy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb2[15:8];	1:mvpAy <= mvy_CurrMb3[7:0];
						default:mvpAy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpAy <= mvy_CurrMb2[15:8];	1:mvpAy <= mvy_CurrMb3[7:0];
						2:mvpAy <= mvy_CurrMb2[31:24];	3:mvpAy <= mvy_CurrMb3[23:16];	
					endcase
				endcase
			endcase
		else
			mvpAy <= 0;
	//-------------
	//mvpBx 
	//-------------
	//if B is not available,it can be predicted from A when both B and C are not available
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state or mb_type_general or sub_mb_type 
		or mb_num or mb_num_v or mbPartIdx or subMbPartIdx or compIdx or MBTypeGen_mbAddrA[1] or MBTypeGen_mbAddrB[1] 
		or mvx_mbAddrA or mvx_mbAddrB_dout or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)
		//P_skip or Inter16x16 
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0))
			begin
				if      (mb_num == 0)	mvpBx <= 0;
				else if (mb_num_v == 0)	mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
				else 					mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0)
			begin
				if (mbPartIdx == 0)
					begin
						if      (mb_num == 0)	mvpBx <= 0;
						else if (mb_num_v == 0)	mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
						else 					mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];
					end
				else	//for bottom 8x8 block when mbAddrA is not available
					mvpBx <= (!refIdxL0_A)? 0:mvx_CurrMb0[23:16];
			end
		//Inter8x16:for left 8x8 block when mbAddrA is not available
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 0)
			begin
				if (mbPartIdx == 0)	//left blk
					mvpBx <= (refIdxL0_A && !refIdxL0_B)? mvx_mbAddrB_dout[31:24]:0;
				else				//right blk
					case (!refIdxL0_C)
						1'b1:mvpBx <= 0;
						1'b0:
						if (mb_num_v == 0)
							mvpBx <= mvx_CurrMb0[7:0];
						else
							mvpBx <= (!refIdxL0_B)? mvx_mbAddrB_dout[15:8]:0;
					endcase
			end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:if      (mb_num == 0)	  mvpBx <= 0;
					  else if (mb_num_v == 0) mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					  else 					  mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];	
					1:  //8x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpBx <= 0;
					  	  else if (mb_num_v == 0) mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					  	  else 					  mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];	
						1:mvpBx <= mvx_CurrMb0[7:0];  
						default:mvpBx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpBx <= 0;
					  	  else if (mb_num_v == 0) mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					  	  else 				      mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];
						1:if      (mb_num_v == 0) mvpBx <= mvx_CurrMb0[7:0];
						  else 					  mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];	
						default:mvpBx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpBx <= 0;
					  	  else if (mb_num_v == 0) mvpBx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					  	  else 					  mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[31:24];
						1:if      (mb_num_v == 0) mvpBx <= mvx_CurrMb0[7:0];
						  else 					  mvpBx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
						2:mvpBx <= mvx_CurrMb0[7:0];
						3:mvpBx <= mvx_CurrMb0[15:8]; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvpBx <= (mb_num_v == 0)? mvx_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8]); 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBx <= (mb_num_v == 0)? mvx_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8]);
						1:mvpBx <= mvx_CurrMb1[7:0];
						default:mvpBx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBx <= (mb_num_v == 0)? mvx_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8]);
						1:mvpBx <= (mb_num_v == 0)? mvx_CurrMb1[7:0] :((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[7:0]);
						default:mvpBx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBx <= (mb_num_v == 0)? mvx_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8]);
						1:mvpBx <= (mb_num_v == 0)? mvx_CurrMb1[7:0] :((MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[7:0]);
						2:mvpBx <= mvx_CurrMb1[7:0];
						3:mvpBx <= mvx_CurrMb1[15:8]; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpBx <= mvx_CurrMb0[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb0[23:16];	1:mvpBx <= mvx_CurrMb2[7:0];	default:mvpBx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb0[23:16];	1:mvpBx <= mvx_CurrMb0[31:24];	default:mvpBx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb0[23:16];	1:mvpBx <= mvx_CurrMb0[31:24];
						2:mvpBx <= mvx_CurrMb2[7:0];	3:mvpBx <= mvx_CurrMb2[15:8]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpBx <= mvx_CurrMb1[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb1[23:16];	1:mvpBx <= mvx_CurrMb3[7:0];	default:mvpBx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb1[23:16];	1:mvpBx <= mvx_CurrMb1[31:24];	default:mvpBx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBx <= mvx_CurrMb1[23:16];	1:mvpBx <= mvx_CurrMb1[31:24];
						2:mvpBx <= mvx_CurrMb3[7:0];	3:mvpBx <= mvx_CurrMb3[15:8]; 
					endcase
				endcase
			endcase
		else
			mvpBx <= 0;
	//-------------
	//mvpBy 
	//-------------
	//if B is not available,it can be predicted from A when both B and C are not available
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state or mb_type_general or sub_mb_type 
		or mb_num or mb_num_v or mbPartIdx or subMbPartIdx or compIdx or MBTypeGen_mbAddrA[1] or MBTypeGen_mbAddrB[1] 
		or mvy_mbAddrA or mvy_mbAddrB_dout or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)
		//P_skip or Inter16x16 
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1))
			begin
				if      (mb_num == 0)	mvpBy <= 0;
				else if (mb_num_v == 0)	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
				else 					mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
			begin
				if (mbPartIdx == 0) //upper 8x8 block
					begin
						if      (mb_num == 0)	mvpBy <= 0;
						else if (mb_num_v == 0)	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
						else 					mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];
					end
				else	//for bottom 8x8 block when mbAddrA is not available
					mvpBy <= (!refIdxL0_A)? 0:mvy_CurrMb0[23:16];
			end
		//Inter8x16:for left 8x8 block when mbAddrA is not available
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 1)
			begin
				if (mbPartIdx == 0)	//left blk
					mvpBy <= (refIdxL0_A && !refIdxL0_B)? mvy_mbAddrB_dout[31:24]:0;
				else				//right blk
					case (!refIdxL0_C)
						1'b1:mvpBy <= 0;
						1'b0:
						if (mb_num_v == 0)
							mvpBy <= mvy_CurrMb0[7:0];
						else
							mvpBy <= (!refIdxL0_B)? mvy_mbAddrB_dout[15:8]:0;
					endcase
			end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:if      (mb_num == 0)		mvpBy <= 0;
					  else if (mb_num_v == 0) 	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];	
					1:  //8x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)		mvpBy <= 0;
					  	  else if (mb_num_v == 0) 	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					  	  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];	
						1:mvpBy <= mvy_CurrMb0[7:0];  
						default:mvpBy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if      (mb_num == 0)		mvpBy <= 0;
					  	  else if (mb_num_v == 0) 	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					  	  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];
						1:if      (mb_num_v == 0) 	mvpBy <= mvy_CurrMb0[7:0];
						  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];	
						default:mvpBy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)		mvpBy <= 0;
					  	  else if (mb_num_v == 0) 	mvpBy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					  	  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[31:24];
						1:if      (mb_num_v == 0) 	mvpBy <= mvy_CurrMb0[7:0];
						  else 						mvpBy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
						2:mvpBy <= mvy_CurrMb0[7:0];
						3:mvpBy <= mvy_CurrMb0[15:8]; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvpBy <= (mb_num_v == 0)? mvy_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8]); 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBy <= (mb_num_v == 0)? mvy_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8]);
						1:mvpBy <= mvy_CurrMb1[7:0];
						default:mvpBy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBy <= (mb_num_v == 0)? mvy_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8]);
						1:mvpBy <= (mb_num_v == 0)? mvy_CurrMb1[7:0] :((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[7:0]);
						default:mvpBy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBy <= (mb_num_v == 0)? mvy_CurrMb0[15:8]:((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8]);
						1:mvpBy <= (mb_num_v == 0)? mvy_CurrMb1[7:0] :((MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[7:0]);
						2:mvpBy <= mvy_CurrMb1[7:0];
						3:mvpBy <= mvy_CurrMb1[15:8]; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpBy <= mvy_CurrMb0[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb0[23:16];	1:mvpBy <= mvy_CurrMb2[7:0];	default:mvpBy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb0[23:16];	1:mvpBy <= mvy_CurrMb0[31:24];	default:mvpBy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb0[23:16];	1:mvpBy <= mvy_CurrMb0[31:24];
						2:mvpBy <= mvy_CurrMb2[7:0];	3:mvpBy <= mvy_CurrMb2[15:8]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpBy <= mvy_CurrMb1[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb1[23:16];	1:mvpBy <= mvy_CurrMb3[7:0];	default:mvpBy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb1[23:16];	1:mvpBy <= mvy_CurrMb1[31:24];	default:mvpBy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpBy <= mvy_CurrMb1[23:16];	1:mvpBy <= mvy_CurrMb1[31:24];
						2:mvpBy <= mvy_CurrMb3[7:0];	3:mvpBy <= mvy_CurrMb3[15:8]; 
					endcase
				endcase
			endcase
		else
			mvpBy <= 0;	 
	//-------------
	//mvpCx
	//-------------
	//if C is not available,it can be predicted from D,then from A
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state or mb_num or mb_num_h or mb_num_v 
		or mb_type_general or sub_mb_type or mbPartIdx or subMbPartIdx or compIdx 
		or MBTypeGen_mbAddrA[1] or MBTypeGen_mbAddrB[1] or MBTypeGen_mbAddrC[1] or MBTypeGen_mbAddrD 
		or mvx_mbAddrA or mvx_mbAddrB_dout or mvx_mbAddrC_dout or mvx_mbAddrD 
		or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3 
		or refIdxL0_A or refIdxL0_B or refIdxL0_C) 
		//P_skip,Inter16x16
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0))
			begin
				if      (mb_num == 0)	 mvpCx <= 0;
				else if (mb_num_v == 0)	 mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
				else if (mb_num_h == 10) mvpCx <= (MBTypeGen_mbAddrD    == 1)? 0:mvx_mbAddrD;
				else					 mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout;
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0)
			begin
				if (mbPartIdx == 0)	
					mvpCx <= (refIdxL0_B && !refIdxL0_C)? ((mb_num_h == 10)? mvx_mbAddrD:mvx_mbAddrC_dout):0;
				else
					mvpCx <= 0;
			end
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 0)
			begin
				//when mbAddrA is not available,Inter8x16 left blk needs to have its mbAddrC (= mbAddrB of upper line) derived
				if (mbPartIdx == 0)	//left blk	
					mvpCx <= (refIdxL0_A && !refIdxL0_B)? mvx_mbAddrB_dout[15:8]:0;
				else				//right blk
					begin
						if      (mb_num == 0)	 mvpCx <= 0;
						else if (mb_num_v == 0)	 mvpCx <= mvx_CurrMb0[15:8];
						else if (mb_num_h == 10) mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
						else					 mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout;
					end
		  	end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:if      (mb_num == 0)	  mvpCx <= 0;
					  else if (mb_num_v == 0) mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					  else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];
					1:  //8x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCx <= 0;
					      else if (mb_num_v == 0) mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					      else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];
						1:if (mb_num_h == 0)      mvpCx <= 0;
						  else					  mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrD;
						default:mvpCx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCx <= 0;
					      else if (mb_num_v == 0) mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					      else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
						1:if      (mb_num_v == 0) mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_CurrMb0[7:0];
						  else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];	
						default:mvpCx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCx <= 0;
					      else if (mb_num_v == 0) mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrA[7:0];
					      else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
						1:if      (mb_num_v == 0) mvpCx <= mvx_CurrMb0[7:0];
						  else 					  mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];	
						2:mvpCx <= mvx_CurrMb0[15:8]; //always available
						3:mvpCx <= mvx_CurrMb0[7:0];  //always from D
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb0[15:8];
					  else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
											mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
					  else					mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout; 
					1:	//8x4
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb0[15:8];
					      else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
							  					mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[23:16];
					  	  else					mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout;
						1:mvpCx <= mvx_CurrMb0[15:8]; //C is always unavailable,D is always available
						default:mvpCx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb0[15:8];
						  else 					mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[7:0]; 
						1:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb1[7:0];
					      else if (mb_num_h == 10) //predicted from D,but lies in mbAddrB
												mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];
					  	  else					mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout;
						default:mvpCx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb0[15:8];
						  else 					mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[7:0]; 
						1:if (mb_num_v == 0)	mvpCx <= mvx_CurrMb1[7:0];
					      else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
												mvpCx <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvx_mbAddrB_dout[15:8];
					  	  else					mvpCx <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvx_mbAddrC_dout;	
						2:mvpCx <= mvx_CurrMb1[15:8];
						3:mvpCx <= mvx_CurrMb1[7:0]; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpCx <= mvx_CurrMb1[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb1[23:16];	
						1:if (mb_num_h == 0)	mvpCx <= 0;
						  else 					mvpCx <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvx_mbAddrD;
						default:mvpCx <= 0;
					endcase	
					2:	//4x8
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb0[31:24];	1:mvpCx <= mvx_CurrMb1[23:16];	default:mvpCx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb0[31:24];	1:mvpCx <= mvx_CurrMb1[23:16];
						2:mvpCx <= mvx_CurrMb2[15:8];	3:mvpCx <= mvx_CurrMb2[7:0]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpCx <= mvx_CurrMb0[31:24]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb0[31:24];	1:mvpCx <= mvx_CurrMb2[15:8];	default:mvpCx <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb1[31:24];	1:mvpCx <= mvx_CurrMb1[23:16];	default:mvpCx <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpCx <= mvx_CurrMb1[31:24];	1:mvpCx <= mvx_CurrMb1[23:16];
						2:mvpCx <= mvx_CurrMb3[15:8];	3:mvpCx <= mvx_CurrMb3[7:0]; 
					endcase
				endcase
			endcase
		else
			mvpCx <= 0;	
	//-------------
	//mvpCy
	//-------------
	//if C is not available,it can be predicted from D,then from A
	always @ (Is_skipMB_mv_calc or mb_pred_state or sub_mb_pred_state or mb_num or mb_num_h or mb_num_v 
		or mb_type_general or sub_mb_type or mbPartIdx or subMbPartIdx or compIdx 
		or MBTypeGen_mbAddrA[1] or MBTypeGen_mbAddrB[1] or MBTypeGen_mbAddrC[1] or MBTypeGen_mbAddrD 
		or mvy_mbAddrA or mvy_mbAddrB_dout or mvy_mbAddrC_dout or mvy_mbAddrD 
		or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)
		//P_skip,Inter16x16
		if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1))
			begin
				if      (mb_num == 0)	 mvpCy <= 0;
				else if (mb_num_v == 0)	 mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
				else if (mb_num_h == 10) mvpCy <= (MBTypeGen_mbAddrD    == 1)? 0:mvy_mbAddrD;
				else					 mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout;
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
			begin
				if (mbPartIdx == 0)	
					mvpCy <= (refIdxL0_B && !refIdxL0_C)? ((mb_num_h == 10)? mvy_mbAddrD:mvy_mbAddrC_dout):0;
				else
					mvpCy <= 0;
			end
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 1)
			begin
				//when mbAddrA is not available,Inter8x16 left blk needs to have its mbAddrC (= mbAddrB of upper line) derived
				if (mbPartIdx == 0)	//left blk	
					mvpCy <= (refIdxL0_A && !refIdxL0_B)? mvy_mbAddrB_dout[15:8]:0;
				else				//right blk
					begin
						if      (mb_num == 0)	 mvpCy <= 0;
						else if (mb_num_v == 0)	 mvpCy <= mvy_CurrMb0[15:8];
						else if (mb_num_h == 10) mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
						else					 mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout;
					end
		  	end
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:if      (mb_num == 0)	  mvpCy <= 0;
					  else if (mb_num_v == 0) mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					  else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];
					1:  //8x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCy <= 0;
					      else if (mb_num_v == 0) mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					      else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];
						1:if (mb_num_h == 0)      mvpCy <= 0;
						  else					  mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrD;
						default:mvpCy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCy <= 0;
					      else if (mb_num_v == 0) mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					      else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
						1:if      (mb_num_v == 0) mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_CurrMb0[7:0];
						  else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];	
						default:mvpCy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if      (mb_num == 0)	  mvpCy <= 0;
					      else if (mb_num_v == 0) mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrA[7:0];
					      else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
						1:if      (mb_num_v == 0) mvpCy <= mvy_CurrMb0[7:0];
						  else 					  mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];	
						2:mvpCy <= mvy_CurrMb0[15:8]; //always available
						3:mvpCy <= mvy_CurrMb0[7:0];  //always from D
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb0[15:8];
					  else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
											mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
					  else					mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout; 
					1:	//8x4
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb0[15:8];
					      else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
							  					mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[23:16];
					  	  else					mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout;
						1:mvpCy <= mvy_CurrMb0[15:8]; //C is always unavailable,D is always available
						default:mvpCy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb0[15:8];
						  else 					mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[7:0]; 
						1:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb1[7:0];
					      else if (mb_num_h == 10) //predicted from D,but lies in mbAddrB
												mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];
					  	  else					mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout;
						default:mvpCy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb0[15:8];
						  else 					mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[7:0]; 
						1:if (mb_num_v == 0)	mvpCy <= mvy_CurrMb1[7:0];
					      else if (mb_num_h == 10) //predicted from D,but lies initial mbAddrB
												mvpCy <= (MBTypeGen_mbAddrB[1] == 1)? 0:mvy_mbAddrB_dout[15:8];
					  	  else					mvpCy <= (MBTypeGen_mbAddrC[1] == 1)? 0:mvy_mbAddrC_dout;	
						2:mvpCy <= mvy_CurrMb1[15:8];
						3:mvpCy <= mvy_CurrMb1[7:0]; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvpCy <= mvy_CurrMb1[23:16]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb1[23:16];	
						1:if (mb_num_h == 0)	mvpCy <= 0;
						  else 					mvpCy <= (MBTypeGen_mbAddrA[1] == 1)? 0:mvy_mbAddrD;
						default:mvpCy <= 0;
					endcase	
					2:	//4x8
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb0[31:24];	1:mvpCy <= mvy_CurrMb1[23:16];	default:mvpCy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb0[31:24];	1:mvpCy <= mvy_CurrMb1[23:16];
						2:mvpCy <= mvy_CurrMb2[15:8];	3:mvpCy <= mvy_CurrMb2[7:0]; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvpCy <= mvy_CurrMb0[31:24]; 
					1:	//8x4
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb0[31:24];	1:mvpCy <= mvy_CurrMb2[15:8];	default:mvpCy <= 0;
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb1[31:24];	1:mvpCy <= mvy_CurrMb1[23:16];	default:mvpCy <= 0;
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvpCy <= mvy_CurrMb1[31:24];	1:mvpCy <= mvy_CurrMb1[23:16];
						2:mvpCy <= mvy_CurrMb3[15:8];	3:mvpCy <= mvy_CurrMb3[7:0]; 
					endcase
				endcase
			endcase
		else
			mvpCy <= 0;	
	//------------------------------------------------		
	//obtain motion vector prediction for current Blk
	//------------------------------------------------
	wire [8:0] sub_ABx,sub_ACx,sub_BCx;
	wire flag_ABx,flag_ACx,flag_BCx; 
	assign sub_ABx = {mvpAx[7],mvpAx[7:0]} - {mvpBx[7],mvpBx[7:0]};
	assign sub_ACx = {mvpAx[7],mvpAx[7:0]} - {mvpCx[7],mvpCx[7:0]};
	assign sub_BCx = {mvpBx[7],mvpBx[7:0]} - {mvpCx[7],mvpCx[7:0]};
	assign flag_ABx = sub_ABx[8];
	assign flag_ACx = sub_ACx[8];
	assign flag_BCx = sub_BCx[8];
	
	reg [7:0] mvpx_median;
	always @ (flag_ABx or flag_ACx or flag_BCx or mvpAx or mvpBx or mvpCx)
		if (((flag_ABx == 1'b1) && (flag_ACx == 1'b0)) || ((flag_ABx == 1'b0) && (flag_ACx == 1'b1))) 
			mvpx_median <= mvpAx;
		else if (((flag_ABx == 1'b0) && (flag_BCx == 1'b0)) || ((flag_ABx == 1'b1) && (flag_BCx == 1'b1))) 
			mvpx_median <= mvpBx;
		else 
			mvpx_median <= mvpCx;
			
	always @ (refIdxL0_A or refIdxL0_B or refIdxL0_C or mvpAx or mvpBx or mvpCx or mvpx_median)
		case ({refIdxL0_A,refIdxL0_B,refIdxL0_C})
			3'b011:mvpx <= mvpAx;
			3'b101:mvpx <= mvpBx;
			3'b110:mvpx <= mvpCx;
			default:mvpx <= mvpx_median;
		endcase
	
	wire [8:0] sub_ABy,sub_ACy,sub_BCy;
	wire flag_ABy,flag_ACy,flag_BCy; 
	assign sub_ABy = {mvpAy[7],mvpAy[7:0]} - {mvpBy[7],mvpBy[7:0]};
	assign sub_ACy = {mvpAy[7],mvpAy[7:0]} - {mvpCy[7],mvpCy[7:0]};
	assign sub_BCy = {mvpBy[7],mvpBy[7:0]} - {mvpCy[7],mvpCy[7:0]};
	assign flag_ABy = sub_ABy[8];
	assign flag_ACy = sub_ACy[8];
	assign flag_BCy = sub_BCy[8];
	
	reg [7:0] mvpy_median;
	always @ (flag_ABy or flag_ACy or flag_BCy or mvpAy or mvpBy or mvpCy)
		if (((flag_ABy == 1'b1) && (flag_ACy == 1'b0)) || ((flag_ABy == 1'b0) && (flag_ACy == 1'b1))) 
			mvpy_median <= mvpAy;
		else if (((flag_ABy == 1'b0) && (flag_BCy == 1'b0)) || ((flag_ABy == 1'b1) && (flag_BCy == 1'b1))) 
			mvpy_median <= mvpBy;
		else 
			mvpy_median <= mvpCy;
			
	always @ (refIdxL0_A or refIdxL0_B or refIdxL0_C or mvpAy or mvpBy or mvpCy or mvpy_median)
		case ({refIdxL0_A,refIdxL0_B,refIdxL0_C})
			3'b011:mvpy <= mvpAy;
			3'b101:mvpy <= mvpBy;
			3'b110:mvpy <= mvpCy;
			default:mvpy <= mvpy_median;
		endcase
		
	always @ (Is_skipMB_mv_calc or mb_num_h or mb_num_v or mb_pred_state or sub_mb_pred_state or compIdx or mvpx or mvpy 
		or mvd or mvpAx or mvpBx or mvpCx or mvpAy or mvpBy or mvpCy or mb_type_general or mbPartIdx 
		or refIdxL0_A or refIdxL0_B or refIdxL0_C)
		if (Is_skipMB_mv_calc)
			begin
				//Refer to Page113,section 8.4.1.1 of H.264/AVC 2003.05 standard
				if (mb_num_h == 0 || mb_num_v == 0 || (refIdxL0_A == 0 && mvpAx == 0 && mvpAy == 0) || 
					(refIdxL0_B == 0 && mvpBx == 0 && mvpBy == 0))
					begin mvx <= 0;		mvy <= 0;		end
				else
					begin mvx <= mvpx;	mvy <= mvpy;	end
			end
		else if (mb_pred_state == `mvd_l0_s || sub_mb_pred_state == `sub_mvd_l0_s)
			begin
				if (mb_type_general == `MB_Inter16x8)		//16x8
					case (mbPartIdx)
						2'b00:					//upper blk
						if (!refIdxL0_B)
							begin
								mvx <= (compIdx == 0)? (mvpBx + mvd):0;
								mvy <= (compIdx == 1)? (mvpBy + mvd):0;
							end
						else
							begin
								mvx <= (compIdx == 0)? (mvpx + mvd):0;
								mvy <= (compIdx == 1)? (mvpy + mvd):0;
							end
						default:				//bottom blk
						if (!refIdxL0_A)
							begin
								mvx <= (compIdx == 0)? (mvpAx + mvd):0;
								mvy <= (compIdx == 1)? (mvpAy + mvd):0;
							end
						else
							begin
								mvx <= (compIdx == 0)? (mvpx + mvd):0;
								mvy <= (compIdx == 1)? (mvpy + mvd):0;
							end
					endcase
				else if (mb_type_general == `MB_Inter8x16)	//8x16
					case (mbPartIdx)
						2'b00:					//left blk
						if (!refIdxL0_A)
							begin
								mvx <= (compIdx == 0)? (mvpAx + mvd):0;
								mvy <= (compIdx == 1)? (mvpAy + mvd):0;
							end
						else
							begin
								mvx <= (compIdx == 0)? (mvpx + mvd):0;
								mvy <= (compIdx == 1)? (mvpy + mvd):0;
							end
						default:				//right blk
						//if mbAddrC is not available but mbAddrB (= mbAddrD) is INTER available (not only available,but also inter
						//available),it still predicted from mbAddrC <- mbAddrD
						if (!refIdxL0_C || (mb_num_h == 10 && !refIdxL0_B)) 
							begin													
								mvx <= (compIdx == 0)? (mvpCx + mvd):0;				 
								mvy <= (compIdx == 1)? (mvpCy + mvd):0;
							end
						else
							begin
								mvx <= (compIdx == 0)? (mvpx + mvd):0;
								mvy <= (compIdx == 1)? (mvpy + mvd):0;
							end
					endcase
				else
					begin
						mvx <= (compIdx == 0)? (mvpx + mvd):0;
						mvy <= (compIdx == 1)? (mvpy + mvd):0;
					end
			end		
		else
			begin
				mvx <= 0;	mvy <= 0;
			end
	//-----------------------------------------------------		
	//Current MB write --> CurrMb0,CurrMb1,CurrMb2,CurrMb3
	//-----------------------------------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			mv_is16x16 <= 0;
		else if (mb_type_general == `MB_Inter16x16 || mb_type_general == `MB_P_skip)
			mv_is16x16 <= 1;
		else 
			mv_is16x16 <= 0;
	
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				mvx_CurrMb0 <= 0;	mvx_CurrMb1 <= 0;	mvx_CurrMb2 <= 0;	mvx_CurrMb3 <= 0;
			end
		//Inter16x16 or P_skip
		else if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0)) 
			mvx_CurrMb0[7:0] <= mvx;
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0)
			case (mbPartIdx)
				0:begin	mvx_CurrMb0 <= {mvx,mvx,mvx,mvx};	mvx_CurrMb1 <= {mvx,mvx,mvx,mvx};	end
				1:begin	mvx_CurrMb2 <= {mvx,mvx,mvx,mvx};	mvx_CurrMb3 <= {mvx,mvx,mvx,mvx};	end
			endcase
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16  && compIdx == 0)
			case (mbPartIdx)
				0:begin	mvx_CurrMb0 <= {mvx,mvx,mvx,mvx};	mvx_CurrMb2 <= {mvx,mvx,mvx,mvx};	end
				1:begin	mvx_CurrMb1 <= {mvx,mvx,mvx,mvx};	mvx_CurrMb3 <= {mvx,mvx,mvx,mvx};	end
			endcase
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:mvx_CurrMb0 <= {mvx,mvx,mvx,mvx};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvx_CurrMb0[7:0]   <= mvx;	mvx_CurrMb0[15:8]  <= mvx;	end
						1:begin	mvx_CurrMb0[23:16] <= mvx;	mvx_CurrMb0[31:24] <= mvx;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvx_CurrMb0[7:0]  <= mvx;	mvx_CurrMb0[23:16] <= mvx;	end
						1:begin	mvx_CurrMb0[15:8] <= mvx;	mvx_CurrMb0[31:24] <= mvx;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvx_CurrMb0[7:0]   <= mvx;
						1:mvx_CurrMb0[15:8]  <= mvx;
						2:mvx_CurrMb0[23:16] <= mvx;
						3:mvx_CurrMb0[31:24] <= mvx; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvx_CurrMb1 <= {mvx,mvx,mvx,mvx};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvx_CurrMb1[7:0]   <= mvx;	mvx_CurrMb1[15:8]  <= mvx;	end
						1:begin	mvx_CurrMb1[23:16] <= mvx;	mvx_CurrMb1[31:24] <= mvx;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvx_CurrMb1[7:0]  <= mvx;	mvx_CurrMb1[23:16] <= mvx;	end
						1:begin	mvx_CurrMb1[15:8] <= mvx;	mvx_CurrMb1[31:24] <= mvx;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvx_CurrMb1[7:0]   <= mvx;
						1:mvx_CurrMb1[15:8]  <= mvx;
						2:mvx_CurrMb1[23:16] <= mvx;
						3:mvx_CurrMb1[31:24] <= mvx; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvx_CurrMb2 <= {mvx,mvx,mvx,mvx};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvx_CurrMb2[7:0]   <= mvx;	mvx_CurrMb2[15:8]  <= mvx;	end
						1:begin	mvx_CurrMb2[23:16] <= mvx;	mvx_CurrMb2[31:24] <= mvx;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvx_CurrMb2[7:0]  <= mvx;	mvx_CurrMb2[23:16] <= mvx;	end
						1:begin	mvx_CurrMb2[15:8] <= mvx;	mvx_CurrMb2[31:24] <= mvx;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvx_CurrMb2[7:0]   <= mvx;
						1:mvx_CurrMb2[15:8]  <= mvx;
						2:mvx_CurrMb2[23:16] <= mvx;
						3:mvx_CurrMb2[31:24] <= mvx; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvx_CurrMb3 <= {mvx,mvx,mvx,mvx};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvx_CurrMb3[7:0]   <= mvx;	mvx_CurrMb3[15:8]  <= mvx;	end
						1:begin	mvx_CurrMb3[23:16] <= mvx;	mvx_CurrMb3[31:24] <= mvx;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvx_CurrMb3[7:0]  <= mvx;	mvx_CurrMb3[23:16] <= mvx;	end
						1:begin	mvx_CurrMb3[15:8] <= mvx;	mvx_CurrMb3[31:24] <= mvx;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvx_CurrMb3[7:0]   <= mvx;
						1:mvx_CurrMb3[15:8]  <= mvx;
						2:mvx_CurrMb3[23:16] <= mvx;
						3:mvx_CurrMb3[31:24] <= mvx; 
					endcase
				endcase
			endcase	
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				mvy_CurrMb0 <= 0;	mvy_CurrMb1 <= 0;	mvy_CurrMb2 <= 0;	mvy_CurrMb3 <= 0;
			end
		//Inter16x16 or P_skip
		else if (Is_skipMB_mv_calc || (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1)) 
			begin 
				mvy_CurrMb0[7:0] <= mvy;
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
			case (mbPartIdx)
				0:begin	mvy_CurrMb0 <= {mvy,mvy,mvy,mvy};	mvy_CurrMb1 <= {mvy,mvy,mvy,mvy};	end
				1:begin	mvy_CurrMb2 <= {mvy,mvy,mvy,mvy};	mvy_CurrMb3 <= {mvy,mvy,mvy,mvy};	end
			endcase
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16  && compIdx == 1)
			case (mbPartIdx)
				0:begin	mvy_CurrMb0 <= {mvy,mvy,mvy,mvy};	mvy_CurrMb2 <= {mvy,mvy,mvy,mvy};	end
				1:begin	mvy_CurrMb1 <= {mvy,mvy,mvy,mvy};	mvy_CurrMb3 <= {mvy,mvy,mvy,mvy};	end
			endcase
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	
			case (mbPartIdx)
				0:
				case (sub_mb_type)
					0:mvy_CurrMb0 <= {mvy,mvy,mvy,mvy};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvy_CurrMb0[7:0]   <= mvy;	mvy_CurrMb0[15:8]  <= mvy;	end
						1:begin	mvy_CurrMb0[23:16] <= mvy;	mvy_CurrMb0[31:24] <= mvy;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvy_CurrMb0[7:0]  <= mvy;	mvy_CurrMb0[23:16] <= mvy;	end
						1:begin	mvy_CurrMb0[15:8] <= mvy;	mvy_CurrMb0[31:24] <= mvy;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvy_CurrMb0[7:0]   <= mvy;
						1:mvy_CurrMb0[15:8]  <= mvy;
						2:mvy_CurrMb0[23:16] <= mvy;
						3:mvy_CurrMb0[31:24] <= mvy; 
					endcase
				endcase
				1:
				case (sub_mb_type)
					0:mvy_CurrMb1 <= {mvy,mvy,mvy,mvy};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvy_CurrMb1[7:0]   <= mvy;	mvy_CurrMb1[15:8]  <= mvy;	end
						1:begin	mvy_CurrMb1[23:16] <= mvy;	mvy_CurrMb1[31:24] <= mvy;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvy_CurrMb1[7:0]  <= mvy;	mvy_CurrMb1[23:16] <= mvy;	end
						1:begin	mvy_CurrMb1[15:8] <= mvy;	mvy_CurrMb1[31:24] <= mvy;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvy_CurrMb1[7:0]   <= mvy;
						1:mvy_CurrMb1[15:8]  <= mvy;
						2:mvy_CurrMb1[23:16] <= mvy;
						3:mvy_CurrMb1[31:24] <= mvy; 
					endcase
				endcase
				2:
				case (sub_mb_type)
					0:mvy_CurrMb2 <= {mvy,mvy,mvy,mvy};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvy_CurrMb2[7:0]   <= mvy;	mvy_CurrMb2[15:8]  <= mvy;	end
						1:begin	mvy_CurrMb2[23:16] <= mvy;	mvy_CurrMb2[31:24] <= mvy;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvy_CurrMb2[7:0]  <= mvy;	mvy_CurrMb2[23:16] <= mvy;	end
						1:begin	mvy_CurrMb2[15:8] <= mvy;	mvy_CurrMb2[31:24] <= mvy;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvy_CurrMb2[7:0]   <= mvy;
						1:mvy_CurrMb2[15:8]  <= mvy;
						2:mvy_CurrMb2[23:16] <= mvy;
						3:mvy_CurrMb2[31:24] <= mvy; 
					endcase
				endcase
				3:
				case (sub_mb_type)
					0:mvy_CurrMb3 <= {mvy,mvy,mvy,mvy};
					1:	//8x4
					case (subMbPartIdx)
						0:begin	mvy_CurrMb3[7:0]   <= mvy;	mvy_CurrMb3[15:8]  <= mvy;	end
						1:begin	mvy_CurrMb3[23:16] <= mvy;	mvy_CurrMb3[31:24] <= mvy;	end
					endcase
					2:	//4x8
					case (subMbPartIdx)
						0:begin	mvy_CurrMb3[7:0]  <= mvy;	mvy_CurrMb3[23:16] <= mvy;	end
						1:begin	mvy_CurrMb3[15:8] <= mvy;	mvy_CurrMb3[31:24] <= mvy;	end
					endcase
					3:	//4x4
					case (subMbPartIdx)
						0:mvy_CurrMb3[7:0]   <= mvy;
						1:mvy_CurrMb3[15:8]  <= mvy;
						2:mvy_CurrMb3[23:16] <= mvy;
						3:mvy_CurrMb3[31:24] <= mvy; 
					endcase
				endcase
			endcase
	//----------------------------		
	//mbAddrA write --> mvx_mbAddrA
	//----------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			mvx_mbAddrA <= 0;
		else if (mb_num_h != 10)//if mb_num_h == 10,mvx_mbAddrA will be no use 
			begin
				//P_skip
				if (slice_data_state == `skip_run_duration && end_of_MB_DEC)
					mvx_mbAddrA <= {mvx_CurrMb0[7:0],mvx_CurrMb0[7:0],mvx_CurrMb0[7:0],mvx_CurrMb0[7:0]};
				//Inter16x16
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0)
					mvx_mbAddrA <= {mvx,mvx,mvx,mvx};
				//Inter16x8
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0)
					case (mbPartIdx)
						0:begin	mvx_mbAddrA[15:8]  <= mvx;	mvx_mbAddrA[7:0]   <= mvx;	end
						1:begin	mvx_mbAddrA[23:16] <= mvx;	mvx_mbAddrA[31:24] <= mvx;	end
					endcase
				//Inter8x16
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && mbPartIdx == 1 && compIdx == 0)
					mvx_mbAddrA <= {mvx,mvx,mvx,mvx};
				//Inter8x8
				else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)
					case (mbPartIdx)
						1:
						case (sub_mb_type)
							0:begin	mvx_mbAddrA[15:8] <= mvx;	mvx_mbAddrA[7:0] <= mvx;	end
							1:if (subMbPartIdx == 0) mvx_mbAddrA[7:0]  <= mvx; 
							  else					 mvx_mbAddrA[15:8] <= mvx;
							2:if (subMbPartIdx == 1) begin	mvx_mbAddrA[15:8] <= mvx; mvx_mbAddrA[7:0] <= mvx;end
							3:if (subMbPartIdx == 1)	  mvx_mbAddrA[7:0]  <= mvx;
							  else if (subMbPartIdx == 3) mvx_mbAddrA[15:8] <= mvx;
						endcase
						3:
						case (sub_mb_type)
							0:begin	mvx_mbAddrA[23:16] <= mvx;	mvx_mbAddrA[31:24] <= mvx;	end
							1:if (subMbPartIdx == 0) mvx_mbAddrA[23:16]  <= mvx; 
							  else					 mvx_mbAddrA[31:24]  <= mvx;
							2:if (subMbPartIdx == 1) begin	mvx_mbAddrA[23:16] <= mvx; mvx_mbAddrA[31:24] <= mvx;end
							3:if (subMbPartIdx == 1)	  mvx_mbAddrA[23:16] <= mvx;
							  else if (subMbPartIdx == 3) mvx_mbAddrA[31:24] <= mvx;
						endcase
					endcase
			end
	always @ (posedge clk)
		if (reset_n == 0)
			mvy_mbAddrA <= 0;
		else if (mb_num_h != 10)//if mb_num_h == 10,mvy_mbAddrA will be no use 
			begin
				//P_skip 
				if (slice_data_state == `skip_run_duration && end_of_MB_DEC)
					mvy_mbAddrA <= {mvy_CurrMb0[7:0],mvy_CurrMb0[7:0],mvy_CurrMb0[7:0],mvy_CurrMb0[7:0]};
				//Inter16x16
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1)
					mvy_mbAddrA <= {mvy,mvy,mvy,mvy};
				//Inter16x8
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
					case (mbPartIdx)
						0:begin	mvy_mbAddrA[15:8]  <= mvy;	mvy_mbAddrA[7:0]   <= mvy;	end
						1:begin	mvy_mbAddrA[23:16] <= mvy;	mvy_mbAddrA[31:24] <= mvy;	end
					endcase
				//Inter8x16
				else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && mbPartIdx == 1 && compIdx == 1)
					mvy_mbAddrA <= {mvy,mvy,mvy,mvy};
				//Inter8x8
				else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)
					case (mbPartIdx)
						1:
						case (sub_mb_type)
							0:begin	mvy_mbAddrA[15:8] <= mvy;	mvy_mbAddrA[7:0] <= mvy;	end
							1:if (subMbPartIdx == 0) mvy_mbAddrA[7:0]  <= mvy; 
							  else					 mvy_mbAddrA[15:8] <= mvy;
							2:if (subMbPartIdx == 1) begin	mvy_mbAddrA[15:8] <= mvy; mvy_mbAddrA[7:0] <= mvy;end
							3:if (subMbPartIdx == 1)	  mvy_mbAddrA[7:0]  <= mvy;
							  else if (subMbPartIdx == 3) mvy_mbAddrA[15:8] <= mvy;
						endcase
						3:
						case (sub_mb_type)
							0:begin	mvy_mbAddrA[23:16] <= mvy;	mvy_mbAddrA[31:24] <= mvy;	end
							1:if (subMbPartIdx == 0) mvy_mbAddrA[23:16]  <= mvy; 
							  else					 mvy_mbAddrA[31:24]  <= mvy;
							2:if (subMbPartIdx == 1) begin	mvy_mbAddrA[23:16] <= mvy; mvy_mbAddrA[31:24] <= mvy;end
							3:if (subMbPartIdx == 1)	  mvy_mbAddrA[23:16] <= mvy;
							  else if (subMbPartIdx == 3) mvy_mbAddrA[31:24] <= mvy;
						endcase
					endcase
			end
	//-----------------------------------------		
	//mbAddrB RF read and write --> mvx_mbAddrB
	//-----------------------------------------
	always @ (reset_n or slice_data_state or mb_pred_state or sub_mb_pred_state or mv_mbAddrB_rd_for_DF 
		or Is_skipMB_mv_calc or end_of_MB_DEC or mb_type_general or sub_mb_type or mb_num_h or mb_num_v 
		or mbPartIdx or subMbPartIdx or compIdx or mvx or mvx_CurrMb0[7:0] or mvx_CurrMb2 or mvx_CurrMb3
		or refIdxL0_A or refIdxL0_C)
		if (reset_n == 0)
			begin
				mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
				mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
				mvx_mbAddrB_din     <= 0;			
			end
		//read for DF boundary strength decoding
		else if (mv_mbAddrB_rd_for_DF) 
			begin
				mvx_mbAddrB_cs_n <= 0;	mvx_mbAddrB_rd_addr <= mb_num_h;
				mvx_mbAddrB_wr_n <= 1;	mvx_mbAddrB_wr_addr <= 0;
				mvx_mbAddrB_din	 <= 0;
			end
		//P_skip
		else if (slice_data_state == `skip_run_duration)
			begin
				if (Is_skipMB_mv_calc)		//read
					begin
						if (mb_num_v == 0)
							begin mvx_mbAddrB_cs_n <= 1;mvx_mbAddrB_rd_addr <= 0;		end
						else
							begin mvx_mbAddrB_cs_n <= 0;mvx_mbAddrB_rd_addr <= mb_num_h;end
						mvx_mbAddrB_wr_n    <= 1;
						mvx_mbAddrB_wr_addr	<= 0;
						mvx_mbAddrB_din 	<= 0;
					end
				else if (end_of_MB_DEC)	//write
					begin
						if (mb_num_v == 8)
							begin
								mvx_mbAddrB_cs_n <= 1;		mvx_mbAddrB_wr_n <= 1;
								mvx_mbAddrB_wr_addr	<= 0;	mvx_mbAddrB_din  <= 0;
							end
						else
							begin
								mvx_mbAddrB_cs_n <= 0;		mvx_mbAddrB_wr_n <= 0;
								mvx_mbAddrB_wr_addr	<= mb_num_h;
								mvx_mbAddrB_din  <= {mvx_CurrMb0[7:0],mvx_CurrMb0[7:0],mvx_CurrMb0[7:0],mvx_CurrMb0[7:0]};
							end
						mvx_mbAddrB_rd_addr <= 0;
					end
				else
					begin
						mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din     <= 0;	
					end
			end		
		//Inter16x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0) 
			begin
				if (mb_num_v == 0)		//!read,write
					begin
						mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_wr_n     <= 0; 
						mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
						mvx_mbAddrB_din     <= {mvx,mvx,mvx,mvx};	
					end
				else if (mb_num_v == 8)	//read,!write
					begin
						mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_rd_addr  <= mb_num_h;
						mvx_mbAddrB_wr_n    <= 1;   mvx_mbAddrB_wr_addr  <= 0;
						mvx_mbAddrB_din 	<= 0;
					end
				else					//read,write
					begin
						mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_rd_addr  <= mb_num_h;
						mvx_mbAddrB_wr_n  	<= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;
						mvx_mbAddrB_din     <= {mvx,mvx,mvx,mvx};
					end
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0) 
			case (mbPartIdx)
				0:	//read,!write
				begin
					if (mb_num_v == 0)	//!read,!write
						begin
							mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
							mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
							mvx_mbAddrB_din     <= 0;	
						end
					else				//read,!write
						begin
							mvx_mbAddrB_cs_n    <= 0;			mvx_mbAddrB_wr_n     <= 1; 
							mvx_mbAddrB_rd_addr <= mb_num_h;	mvx_mbAddrB_wr_addr  <= 0;	
							mvx_mbAddrB_din     <= 0;	
						end
				end
				1:	//!read,write
				begin
					if (mb_num_v == 8)	//!read,!write
						begin
							mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_rd_addr <= mb_num_h;
							mvx_mbAddrB_wr_n    <= 1;   mvx_mbAddrB_wr_addr  <= 0;
							mvx_mbAddrB_din 	<= 0;
						end
					else				//!read,write
						begin
							mvx_mbAddrB_cs_n    <= 0;			mvx_mbAddrB_wr_n     <= 0; 
							mvx_mbAddrB_rd_addr <= mb_num_h;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
							mvx_mbAddrB_din     <= {mvx,mvx,mvx,mvx};
						end
				end
				default:
				begin
					mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
					mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
					mvx_mbAddrB_din 	<= 0;			
				end
			endcase
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 0)
			case (mbPartIdx)
				0:	//read when mbAddrA is not available for inter pred,!write
				if (refIdxL0_A == 1'b1)
					begin
						mvx_mbAddrB_cs_n    <= 0;		mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= mb_num_h;mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din 	<= 0;	
					end
				else		
					begin
						mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din 	<= 0;	
					end
				1:	//need read :mb_num_h == 10 && mb_num_v != 0
					//need write:mb_num_v != 8
				begin
					mvx_mbAddrB_cs_n <= ((mb_num_v != 8 || mb_num_h == 10) || (refIdxL0_C && mb_num_v != 0))? 1'b0:1'b1;
					mvx_mbAddrB_wr_n <= (mb_num_v == 8)? 1'b1:1'b0;
					mvx_mbAddrB_rd_addr <= mb_num_h;
					mvx_mbAddrB_wr_addr <= mb_num_h;
					mvx_mbAddrB_din <=  {mvx_CurrMb2[23:16],mvx_CurrMb2[31:24],mvx,mvx};
				end
				default:
				begin
					mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
					mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
					mvx_mbAddrB_din     <= 0;			
				end
			endcase
		//8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	
			case (mbPartIdx)
				0,1:	//read,!write
				if (mb_num_v == 0)	//!read,!write
					begin
						mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din     <= 0;	
					end
				else				//read,!write
					begin
						mvx_mbAddrB_cs_n    <= 0;			mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= mb_num_h;	mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din     <= 0;	
					end
				2:		//!read,!write
				begin
					mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
					mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
					mvx_mbAddrB_din     <= 0;			
				end
				3:		//!read,write
				if (mb_num_v == 8)	//!read,!write
					begin
						mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
						mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
						mvx_mbAddrB_din 	<= 0;			
					end
				else
					case (sub_mb_type)
						0:	//8x8
						begin
							mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_wr_n     <= 0; 
							mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
							mvx_mbAddrB_din     <= {mvx_CurrMb2[23:16],mvx_CurrMb2[31:24],mvx,mvx};		
						end
						1: 	//8x4
						case (subMbPartIdx)
							1:
							begin
								mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_wr_n     <= 0; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
								mvx_mbAddrB_din     <= {mvx_CurrMb2[23:16],mvx_CurrMb2[31:24],mvx,mvx};			
							end
							default:
							begin
								mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
								mvx_mbAddrB_din 	<= 0;			
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							1:
							begin
								mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_wr_n     <= 0; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
								mvx_mbAddrB_din <= {mvx_CurrMb2[23:16],mvx_CurrMb2[31:24],mvx_CurrMb3[23:16],mvx};			
							end
							default:
							begin
								mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
								mvx_mbAddrB_din 	<= 0;			
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							3:
							begin
								mvx_mbAddrB_cs_n    <= 0;	mvx_mbAddrB_wr_n     <= 0; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= mb_num_h;	
								mvx_mbAddrB_din 	<= {mvx_CurrMb2[23:16],mvx_CurrMb2[31:24],
														mvx_CurrMb3[23:16],mvx};			
							end
							default:
							begin
								mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
								mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
								mvx_mbAddrB_din <= 0;			
							end
						endcase
					endcase
			endcase
		else
			begin
				mvx_mbAddrB_cs_n    <= 1;	mvx_mbAddrB_wr_n     <= 1; 
				mvx_mbAddrB_rd_addr <= 0;	mvx_mbAddrB_wr_addr  <= 0;	
				mvx_mbAddrB_din <= 0;			
			end
			
	always @ (reset_n or slice_data_state or mb_pred_state or sub_mb_pred_state or mv_mbAddrB_rd_for_DF 
		or Is_skipMB_mv_calc or end_of_MB_DEC or mb_type_general or sub_mb_type or mb_num_h or mb_num_v 
		or mbPartIdx or subMbPartIdx or compIdx or mvy or mvy_CurrMb0[7:0] or mvy_CurrMb2 or mvy_CurrMb3
		or refIdxL0_A or refIdxL0_C)
		if (reset_n == 0)
			begin
				mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
				mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
				mvy_mbAddrB_din     <= 0;			
			end
		//read for DF boundary strength decoding
		else if (mv_mbAddrB_rd_for_DF) 
			begin
				mvy_mbAddrB_cs_n <= 0;	mvy_mbAddrB_rd_addr <= mb_num_h;
				mvy_mbAddrB_wr_n <= 1;	mvy_mbAddrB_wr_addr <= 0;
				mvy_mbAddrB_din	 <= 0;
			end
		//P_skip
		else if (slice_data_state == `skip_run_duration)
			begin
				if (Is_skipMB_mv_calc)		//read
					begin
						if (mb_num_v == 0)
							begin mvy_mbAddrB_cs_n <= 1;mvy_mbAddrB_rd_addr <= 0;		end
						else
							begin mvy_mbAddrB_cs_n <= 0;mvy_mbAddrB_rd_addr <= mb_num_h;end
						mvy_mbAddrB_wr_n    <= 1;
						mvy_mbAddrB_wr_addr	<= 0;
						mvy_mbAddrB_din 	<= 0;
					end
				else if (end_of_MB_DEC)	//write
					begin
						if (mb_num_v == 8)
							begin
								mvy_mbAddrB_cs_n <= 1;		mvy_mbAddrB_wr_n <= 1;
								mvy_mbAddrB_wr_addr	<= 0;	mvy_mbAddrB_din  <= 0;
							end
						else
							begin
								mvy_mbAddrB_cs_n <= 0;		mvy_mbAddrB_wr_n <= 0;
								mvy_mbAddrB_wr_addr	<= mb_num_h;
								mvy_mbAddrB_din  <= {mvy_CurrMb0[7:0],mvy_CurrMb0[7:0],mvy_CurrMb0[7:0],mvy_CurrMb0[7:0]};
							end
						mvy_mbAddrB_rd_addr <= 0;
					end
				else
					begin
						mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din     <= 0;	
					end
			end
		//Inter16x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1) 
			begin
				if (mb_num_v == 0)		//!read,write
					begin
						mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_wr_n     <= 0; 
						mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
						mvy_mbAddrB_din     <= {mvy,mvy,mvy,mvy};	
					end
				else if (mb_num_v == 8)	//read,!write
					begin
						mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_rd_addr  <= mb_num_h;
						mvy_mbAddrB_wr_n    <= 1;   mvy_mbAddrB_wr_addr  <= 0;
						mvy_mbAddrB_din 	<= 0;
					end
				else					//read,write
					begin
						mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_rd_addr  <= mb_num_h;
						mvy_mbAddrB_wr_n  	<= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;
						mvy_mbAddrB_din     <= {mvy,mvy,mvy,mvy};
					end
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1) 
			case (mbPartIdx)
				0:	//read,!write
				begin
					if (mb_num_v == 0)	//!read,!write
						begin
							mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
							mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
							mvy_mbAddrB_din     <= 0;	
						end
					else				//read,!write
						begin
							mvy_mbAddrB_cs_n    <= 0;			mvy_mbAddrB_wr_n     <= 1; 
							mvy_mbAddrB_rd_addr <= mb_num_h;	mvy_mbAddrB_wr_addr  <= 0;	
							mvy_mbAddrB_din     <= 0;	
						end
				end
				1:	//!read,write
				begin
					if (mb_num_v == 8)	//!read,!write
						begin
							mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_rd_addr <= mb_num_h;
							mvy_mbAddrB_wr_n    <= 1;   mvy_mbAddrB_wr_addr  <= 0;
							mvy_mbAddrB_din 	<= 0;
						end
					else				//!read,write
						begin
							mvy_mbAddrB_cs_n    <= 0;			mvy_mbAddrB_wr_n     <= 0; 
							mvy_mbAddrB_rd_addr <= mb_num_h;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
							mvy_mbAddrB_din     <= {mvy,mvy,mvy,mvy};
						end
				end
				default:
				begin
					mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
					mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
					mvy_mbAddrB_din 	<= 0;			
				end
			endcase
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 1)
			case (mbPartIdx)
				0:	//read when mbAddrA is not available for inter pred,!write
				if (refIdxL0_A == 1'b1)
					begin
						mvy_mbAddrB_cs_n    <= 0;		mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= mb_num_h;mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din 	<= 0;	
					end
				else		
					begin
						mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din 	<= 0;	
					end
				1:	//need read :mb_num_h == 10 && mb_num_v != 0
					//need write:mb_num_v != 8
				begin
					mvy_mbAddrB_cs_n <= ((mb_num_v != 8 || mb_num_h == 10) || (refIdxL0_C && mb_num_v != 0))? 1'b0:1'b1;
					mvy_mbAddrB_wr_n <= (mb_num_v == 8)? 1'b1:1'b0;
					mvy_mbAddrB_rd_addr <= mb_num_h;
					mvy_mbAddrB_wr_addr <= mb_num_h;
					mvy_mbAddrB_din <=  {mvy_CurrMb2[23:16],mvy_CurrMb2[31:24],mvy,mvy};
				end
				default:
				begin
					mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
					mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
					mvy_mbAddrB_din     <= 0;			
				end
			endcase
		//8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	
			case (mbPartIdx)
				0,1:	//read,!write
				if (mb_num_v == 0)	//!read,!write
					begin
						mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din     <= 0;	
					end
				else				//read,!write
					begin
						mvy_mbAddrB_cs_n    <= 0;			mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= mb_num_h;	mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din     <= 0;	
					end
				2:		//!read,!write
				begin
					mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
					mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
					mvy_mbAddrB_din     <= 0;			
				end
				3:		//!read,write
				if (mb_num_v == 8)	//!read,!write
					begin
						mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
						mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
						mvy_mbAddrB_din 	<= 0;			
					end
				else
					case (sub_mb_type)
						0:	//8x8
						begin
							mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_wr_n     <= 0; 
							mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
							mvy_mbAddrB_din     <= {mvy_CurrMb2[23:16],mvy_CurrMb2[31:24],mvy,mvy};		
						end
						1: 	//8x4
						case (subMbPartIdx)
							1:
							begin
								mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_wr_n     <= 0; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
								mvy_mbAddrB_din     <= {mvy_CurrMb2[23:16],mvy_CurrMb2[31:24],mvy,mvy};			
							end
							default:
							begin
								mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
								mvy_mbAddrB_din 	<= 0;			
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							1:
							begin
								mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_wr_n     <= 0; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
								mvy_mbAddrB_din <= {mvy_CurrMb2[23:16],mvy_CurrMb2[31:24],mvy_CurrMb3[23:16],mvy};			
							end
							default:
							begin
								mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
								mvy_mbAddrB_din 	<= 0;			
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							3:
							begin
								mvy_mbAddrB_cs_n    <= 0;	mvy_mbAddrB_wr_n     <= 0; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= mb_num_h;	
								mvy_mbAddrB_din 	<= {mvy_CurrMb2[23:16],mvy_CurrMb2[31:24],
														mvy_CurrMb3[23:16],mvy};			
							end
							default:
							begin
								mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
								mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
								mvy_mbAddrB_din <= 0;			
							end
						endcase
					endcase
			endcase
		else
			begin
				mvy_mbAddrB_cs_n    <= 1;	mvy_mbAddrB_wr_n     <= 1; 
				mvy_mbAddrB_rd_addr <= 0;	mvy_mbAddrB_wr_addr  <= 0;	
				mvy_mbAddrB_din <= 0;			
			end
	//-----------------------------------------		
	//mbAddrC RF read and write --> mvx_mbAddrC
	//-----------------------------------------
	always @ (reset_n or slice_data_state or Is_skipMB_mv_calc or end_of_MB_DEC or mb_pred_state or sub_mb_type or sub_mb_pred_state 
		or mb_type_general or mb_num or mb_num_h or mb_num_v or mbPartIdx or subMbPartIdx or compIdx or mvx or mvx_CurrMb0[7:0]
		or refIdxL0_B or refIdxL0_C)
		if (reset_n == 0)
			begin
				mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
				mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
				mvx_mbAddrC_din     <= 0;
			end
		//P_skip
		else if (slice_data_state == `skip_run_duration)
			begin
				if (Is_skipMB_mv_calc)		//read
					begin
						if (mb_num_v == 0 || mb_num_h == 10)//!read,!write
							begin	mvx_mbAddrC_cs_n <= 1; mvx_mbAddrC_rd_addr <= 0;		end
						else
							begin	mvx_mbAddrC_cs_n <= 0; mvx_mbAddrC_rd_addr <= mb_num_h;	end
						mvx_mbAddrC_wr_n 	<= 1; 
						mvx_mbAddrC_wr_addr <= 0; 
						mvx_mbAddrC_din 	<= 0;
					end
				else if (end_of_MB_DEC)	//write
					begin
						if (mb_num_v == 8 || mb_num_h == 0)	//!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;	
							end
						else								//write
							begin
								mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvx_mbAddrC_din     <= mvx_CurrMb0[7:0];	
							end
					end
				else
					begin
						mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;	
					end
			end
		//Inter16x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 0) 
			begin
				if (mb_num == 0)//!read,!write
					begin
						mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;
					end
				else if (mb_num_v == 0)//!read,write
					begin
						mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvx_mbAddrC_din     <= mvx;
					end
				else if (mb_num_h == 0 || mb_num_v == 8) //read,!write
					begin
						mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;
					end
				else	//read,write
					begin
						mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 0; 
						mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvx_mbAddrC_din     <= mvx;
					end
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 0)
			begin
				if (mbPartIdx == 0) //upper blk,may read,no write
					begin
						if (refIdxL0_B && !refIdxL0_C)	//read,!write
							begin	
								mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						else							//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
					end
				else 				//bottom blk,may write,no read
					begin
						if (mb_num_h != 0)	//!read,write
							begin	
								mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvx_mbAddrC_din 	<= mvx;
							end
						else			  	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
					end
			end			
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 0)
			case (mbPartIdx)
				0:	//!read,write
				if (mb_num_v == 8)
					begin	
						mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;
					end
				else
					begin	
						mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvx_mbAddrC_din 	<= mvx;
					end
				default: //read,!write
				begin
					if (mb_num_v == 0 || mb_num_h == 10)	//!read,!write
						begin
							mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
							mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
							mvx_mbAddrC_din 	<= 0;
						end
					else	//read,!write
						begin	
							mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
							mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
							mvx_mbAddrC_din 	<= 0;
						end
				end
			endcase
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 0)	
			case (mbPartIdx)
				1:	//read,!write
				if (mb_num_v == 0 || mb_num_h == 10)	//!read,!write
					begin
						mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;
					end
				else	//read,!write
					case (sub_mb_type)
						0:	//8x8
						begin	
							mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
							mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
							mvx_mbAddrC_din 	<= mvx;
						end
						1:	//8x4
						case (subMbPartIdx)
							0:	//read,!write
							begin	
								mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din     <= mvx;
							end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din     <= 0;
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							1:	//read,!write
							begin	
								mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din     <= mvx;
							end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							1:	//read,!write
							begin	
								mvx_mbAddrC_cs_n    <= 0;			mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= mb_num_h;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= mvx;
							end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						endcase
					endcase
				2:	//!read,write
				if (mb_num_h == 0 || mb_num_v == 8)	//!read,!write
					begin
						mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
						mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
						mvx_mbAddrC_din 	<= 0;
					end
				else	//!read,write
					case (sub_mb_type)
						0:	//8x8
						begin	
							mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
							mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
							mvx_mbAddrC_din 	<= mvx;
						end
						1:	//8x4
						case (subMbPartIdx)
							1:	//!read,write
							begin	
								mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvx_mbAddrC_din 	<= mvx;
								end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							0:	//!read,write
							begin	
								mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvx_mbAddrC_din 	<= mvx;
							end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							2:	//!read,write
							begin	
								mvx_mbAddrC_cs_n    <= 0;	mvx_mbAddrC_wr_n     <= 0; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvx_mbAddrC_din 	<= mvx;
							end
							default:	//!read,!write
							begin
								mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
								mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
								mvx_mbAddrC_din 	<= 0;
							end
						endcase
					endcase
				default:
				begin
					mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
					mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
					mvx_mbAddrC_din 	<= 0;
				end
			endcase
		else
			begin
				mvx_mbAddrC_cs_n    <= 1;	mvx_mbAddrC_wr_n     <= 1; 
				mvx_mbAddrC_rd_addr <= 0;	mvx_mbAddrC_wr_addr  <= 0;	
				mvx_mbAddrC_din 	<= 0;
			end
			
	always @ (reset_n or slice_data_state or Is_skipMB_mv_calc or end_of_MB_DEC or mb_pred_state or sub_mb_type or sub_mb_pred_state 
		or mb_type_general or mb_num or mb_num_h or mb_num_v or mbPartIdx or subMbPartIdx or compIdx or mvy or mvy_CurrMb0[7:0]
		or refIdxL0_B or refIdxL0_C)
		if (reset_n == 0)
			begin
				mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
				mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
				mvy_mbAddrC_din     <= 0;
			end
		//P_skip
		else if (slice_data_state == `skip_run_duration)
			begin
				if (Is_skipMB_mv_calc)		//read
					begin
						if (mb_num_v == 0 || mb_num_h == 10)//!read,!write
							begin	mvy_mbAddrC_cs_n <= 1; mvy_mbAddrC_rd_addr <= 0;		end
						else
							begin	mvy_mbAddrC_cs_n <= 0; mvy_mbAddrC_rd_addr <= mb_num_h;	end
						mvy_mbAddrC_wr_n 	<= 1; 
						mvy_mbAddrC_wr_addr <= 0; 
						mvy_mbAddrC_din 	<= 0;
					end
				else if (end_of_MB_DEC)	//write
					begin
						if (mb_num_v == 8 || mb_num_h == 0)	//!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;	
							end
						else								//write
							begin
								mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvy_mbAddrC_din     <= mvy_CurrMb0[7:0];	
							end
					end
				else
					begin
						mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;	
					end
			end
		//Inter16x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x16 && compIdx == 1) 
			begin
				if (mb_num == 0)//!read,!write
					begin
						mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;
					end
				else if (mb_num_v == 0)//!read,write
					begin
						mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvy_mbAddrC_din     <= mvy;
					end
				else if (mb_num_h == 0 || mb_num_v == 8) //read,!write
					begin
						mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;
					end
				else	//read,write
					begin
						mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 0; 
						mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvy_mbAddrC_din     <= mvy;
					end
			end
		//Inter16x8
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter16x8 && compIdx == 1)
			begin
				if (mbPartIdx == 0) //upper blk,may read,no write
					begin
						if (refIdxL0_B && !refIdxL0_C)	//read,!write
							begin	
								mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						else							//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
					end
				else 				//bottom blk,may write,no read
					begin
						if (mb_num_h != 0)	//!read,write
							begin	
								mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvy_mbAddrC_din 	<= mvy;
							end
						else			  	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
					end
			end
		//Inter8x16
		else if (mb_pred_state == `mvd_l0_s && mb_type_general == `MB_Inter8x16 && compIdx == 1)
			case (mbPartIdx)
				0:	//!read,write
				if (mb_num_v == 8)
					begin	
						mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;
					end
				else
					begin	
						mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
						mvy_mbAddrC_din 	<= mvy;
					end
				default: //read,!write
				begin
					if (mb_num_v == 0 || mb_num_h == 10)	//!read,!write
						begin
							mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
							mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
							mvy_mbAddrC_din 	<= 0;
						end
					else	//read,!write
						begin	
							mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
							mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
							mvy_mbAddrC_din 	<= 0;
						end
				end
			endcase
		//Inter8x8
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx == 1)	
			case (mbPartIdx)
				1:	//read,!write
				if (mb_num_v == 0 || mb_num_h == 10)	//!read,!write
					begin
						mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;
					end
				else	//read,!write
					case (sub_mb_type)
						0:	//8x8
						begin	
							mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
							mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
							mvy_mbAddrC_din 	<= mvy;
						end
						1:	//8x4
						case (subMbPartIdx)
							0:	//read,!write
							begin	
								mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din     <= mvy;
							end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din     <= 0;
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							1:	//read,!write
							begin	
								mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din     <= mvy;
							end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							1:	//read,!write
							begin	
								mvy_mbAddrC_cs_n    <= 0;			mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= mb_num_h;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= mvy;
							end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						endcase
					endcase
				2:	//!read,write
				if (mb_num_h == 0 || mb_num_v == 8)	//!read,!write
					begin
						mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
						mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
						mvy_mbAddrC_din 	<= 0;
					end
				else	//!read,write
					case (sub_mb_type)
						0:	//8x8
						begin	
							mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
							mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
							mvy_mbAddrC_din 	<= mvy;
						end
						1:	//8x4
						case (subMbPartIdx)
							1:	//!read,write
							begin	
								mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvy_mbAddrC_din 	<= mvy;
								end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						endcase
						2:	//4x8
						case (subMbPartIdx)
							0:	//!read,write
							begin	
								mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvy_mbAddrC_din 	<= mvy;
							end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						endcase
						3:	//4x4
						case (subMbPartIdx)
							2:	//!read,write
							begin	
								mvy_mbAddrC_cs_n    <= 0;	mvy_mbAddrC_wr_n     <= 0; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= mb_num_h - 1;	
								mvy_mbAddrC_din 	<= mvy;
							end
							default:	//!read,!write
							begin
								mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
								mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
								mvy_mbAddrC_din 	<= 0;
							end
						endcase
					endcase
				default:
				begin
					mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
					mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
					mvy_mbAddrC_din 	<= 0;
				end
			endcase
		else
			begin
				mvy_mbAddrC_cs_n    <= 1;	mvy_mbAddrC_wr_n     <= 1; 
				mvy_mbAddrC_rd_addr <= 0;	mvy_mbAddrC_wr_addr  <= 0;	
				mvy_mbAddrC_din 	<= 0;
			end
			
	//-------------------------------		
	//mbAddrD write --> mvx_mbAddrD
	//-------------------------------
	//mvx_mbAddrD
	reg [7:0] mvx_mbAddrD_subMB;
	reg [7:0] mvx_mbAddrD_MB,mvx_mbAddrD_MB_tmp;
	always @ (posedge clk)
		if (reset_n == 0)
			mvx_mbAddrD_subMB <= 0;
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx ==  0)
			case (mbPartIdx)
				0:if (sub_mb_type == 1 && subMbPartIdx == 0)	//8x4 UpperBlk
					mvx_mbAddrD_subMB <= mvx_mbAddrA[7:0];
				2:if (sub_mb_type == 1 && subMbPartIdx == 0)	//8x4 UpperBlk
					mvx_mbAddrD_subMB <= mvx_mbAddrA[23:16];
			endcase
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mvx_mbAddrD_MB_tmp <= 0;
		else if (end_of_MB_DEC && mb_num_v != 8 && mb_num_h == 9 && mb_type_general[3] == 0)
			mvx_mbAddrD_MB_tmp <= (mv_is16x16)? mvx_CurrMb0[7:0]:mvx_CurrMb3[31:24];
			
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mvx_mbAddrD_MB <= 0;
		else if (end_of_MB_DEC && mb_num_h == 10)
			mvx_mbAddrD_MB <= mvx_mbAddrD_MB_tmp;
			
	assign mvx_mbAddrD = ((mbPartIdx == 0 || mbPartIdx == 2) && sub_mb_type == 1 && subMbPartIdx == 1)? mvx_mbAddrD_subMB:mvx_mbAddrD_MB;
	
	//mvy_mbAddrD
	reg [7:0] mvy_mbAddrD_subMB;
	reg [7:0] mvy_mbAddrD_MB,mvy_mbAddrD_MB_tmp;
	always @ (posedge clk)
		if (reset_n == 0)
			mvy_mbAddrD_subMB <= 0;
		else if (sub_mb_pred_state == `sub_mvd_l0_s && compIdx ==  0)
			case (mbPartIdx)
				0:if (sub_mb_type == 1 && subMbPartIdx == 0)	//8x4 UpperBlk
					mvy_mbAddrD_subMB <= mvy_mbAddrA[7:0];
				2:if (sub_mb_type == 1 && subMbPartIdx == 0)	//8x4 UpperBlk
					mvy_mbAddrD_subMB <= mvy_mbAddrA[23:16];
			endcase
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mvy_mbAddrD_MB_tmp <= 0;
		else if (end_of_MB_DEC && mb_num_v != 8 && mb_num_h == 9 && mb_type_general[3] == 0)
			mvy_mbAddrD_MB_tmp <= (mv_is16x16)? mvy_CurrMb0[7:0]:mvy_CurrMb3[31:24];
			
	always @ (posedge clk)
		if (reset_n == 1'b0)
			mvy_mbAddrD_MB <= 0;
		else if (end_of_MB_DEC && mb_num_h == 10)
			mvy_mbAddrD_MB <= mvy_mbAddrD_MB_tmp;
			
	assign mvy_mbAddrD = ((mbPartIdx == 0 || mbPartIdx == 2) && sub_mb_type == 1 && subMbPartIdx == 1)? mvy_mbAddrD_subMB:mvy_mbAddrD_MB;		
				
endmodule