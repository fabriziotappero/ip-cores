//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : nC_decoding.v
// Generated : May 18, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Devive the number of none-zero coeff during nC decoding for TotalCoeff & TrailingOnes LUT
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module nC_decoding (clk,reset_n,gclk_end_of_MB_DEC,
	cavlc_decoder_state,residual_state,slice_data_state,
	mb_num_h,mb_num_v,i8x8,i4x4,i4x4_CbCr,CodedBlockPatternLuma,CodedBlockPatternChroma,
	LumaLevel_mbAddrB_dout,ChromaLevel_Cb_mbAddrB_dout,ChromaLevel_Cr_mbAddrB_dout,
	end_of_one_residual_block,TotalCoeff,
	
	nC,
	Luma_8x8_AllZeroCoeff_mbAddrA,LumaLevel_mbAddrA,
	LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3,
	LumaLevel_mbAddrB_cs_n,LumaLevel_mbAddrB_wr_n,LumaLevel_mbAddrB_rd_addr,
	LumaLevel_mbAddrB_wr_addr,LumaLevel_mbAddrB_din,
	ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_wr_n,ChromaLevel_Cb_mbAddrB_rd_addr,
	ChromaLevel_Cb_mbAddrB_wr_addr,ChromaLevel_Cb_mbAddrB_din,
	ChromaLevel_Cr_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_wr_n,ChromaLevel_Cr_mbAddrB_rd_addr,
	ChromaLevel_Cr_mbAddrB_wr_addr,ChromaLevel_Cr_mbAddrB_din);
	
	input clk,reset_n;
	input gclk_end_of_MB_DEC;
	input [3:0] cavlc_decoder_state;
	input [3:0] residual_state;
	input [3:0] slice_data_state;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [1:0] i8x8,i4x4;
	input [1:0] i4x4_CbCr;
	input [3:0] CodedBlockPatternLuma;
	input [1:0] CodedBlockPatternChroma;
	input [19:0] LumaLevel_mbAddrB_dout;
	input [9:0]  ChromaLevel_Cb_mbAddrB_dout,ChromaLevel_Cr_mbAddrB_dout;
	input end_of_one_residual_block;
	input [4:0] TotalCoeff;
	
	output [4:0] nC;
	output [1:0] Luma_8x8_AllZeroCoeff_mbAddrA;
	output [19:0] LumaLevel_mbAddrA;
	output [19:0] LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3;
	output LumaLevel_mbAddrB_cs_n,LumaLevel_mbAddrB_wr_n;
	output [3:0] LumaLevel_mbAddrB_rd_addr,LumaLevel_mbAddrB_wr_addr;
	output [19:0]LumaLevel_mbAddrB_din;
	output ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_wr_n;
	output [3:0] ChromaLevel_Cb_mbAddrB_rd_addr,ChromaLevel_Cb_mbAddrB_wr_addr;
	output [9:0] ChromaLevel_Cb_mbAddrB_din;
	output ChromaLevel_Cr_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_wr_n;
	output [3:0] ChromaLevel_Cr_mbAddrB_rd_addr,ChromaLevel_Cr_mbAddrB_wr_addr;
	output [9:0] ChromaLevel_Cr_mbAddrB_din;
	
	reg [4:0] nC;
	reg LumaLevel_mbAddrB_cs_n,LumaLevel_mbAddrB_wr_n;
	reg [3:0] LumaLevel_mbAddrB_rd_addr,LumaLevel_mbAddrB_wr_addr;
	reg [19:0]LumaLevel_mbAddrB_din;
	reg ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_wr_n;
	reg [3:0] ChromaLevel_Cb_mbAddrB_rd_addr,ChromaLevel_Cb_mbAddrB_wr_addr;
	reg [9:0] ChromaLevel_Cb_mbAddrB_din;
	reg ChromaLevel_Cr_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_wr_n;
	reg [3:0] ChromaLevel_Cr_mbAddrB_rd_addr,ChromaLevel_Cr_mbAddrB_wr_addr;
	reg [9:0] ChromaLevel_Cr_mbAddrB_din;
		
	reg nA_availability,nB_availability;
	reg nA_availability_reg,nB_availability_reg;
	reg [4:0]  nA,nB;
	reg [19:0] LumaLevel_mbAddrA;
	reg [19:0] LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3;
	reg [19:0] ChromaLevel_Cb_CurrMb;
	reg [9:0]  ChromaLevel_Cb_mbAddrA;
	reg [19:0] ChromaLevel_Cr_CurrMb;
	reg [9:0]  ChromaLevel_Cr_mbAddrA;
	reg [1:0]  Luma_8x8_AllZeroCoeff_mbAddrA;
	reg [0:21] Luma_8x8_AllZeroCoeff_mbAddrB_reg;
	reg [0:1]  Luma_8x8_AllZeroCoeff_mbAddrB;
	reg	Chroma_8x8_AllZeroCoeff_mbAddrA;
	reg [10:0] Chroma_8x8_AllZeroCoeff_mbAddrB_reg;
	reg Chroma_8x8_AllZeroCoeff_mbAddrB;
	
	always @ (mb_num_h or Luma_8x8_AllZeroCoeff_mbAddrB_reg)
		case (mb_num_h)
			0 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[0:1];
			1 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[2:3];
			2 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[4:5];
			3 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[6:7];
			4 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[8:9];
			5 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[10:11];
			6 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[12:13];
			7 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[14:15];
			8 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[16:17];
			9 :Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[18:19];
			10:Luma_8x8_AllZeroCoeff_mbAddrB <= Luma_8x8_AllZeroCoeff_mbAddrB_reg[20:21];
			default:Luma_8x8_AllZeroCoeff_mbAddrB <= 0;
		endcase
	always @ (mb_num_h or Chroma_8x8_AllZeroCoeff_mbAddrB_reg)
		case (mb_num_h)
			0 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[0];
			1 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[1];
			2 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[2];
			3 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[3];
			4 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[4];
			5 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[5];
			6 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[6];
			7 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[7];
			8 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[8];
			9 :Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[9];
			10:Chroma_8x8_AllZeroCoeff_mbAddrB <= Chroma_8x8_AllZeroCoeff_mbAddrB_reg[10];
			default:Chroma_8x8_AllZeroCoeff_mbAddrB <= 0;
		endcase
	//----------------------------
	//Update 8x8_AllZero registers
	//----------------------------
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 0)	
			Luma_8x8_AllZeroCoeff_mbAddrA <= 0;
		else if (slice_data_state == `skip_run_duration)
			Luma_8x8_AllZeroCoeff_mbAddrA <= 0;
		else //update 8x8_AllZero reg when finished one MB residual parsing
			begin
				Luma_8x8_AllZeroCoeff_mbAddrA[0] <= (CodedBlockPatternLuma[1] == 0)? 1'b0:1'b1;
				Luma_8x8_AllZeroCoeff_mbAddrA[1] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
			end
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 0)
			Luma_8x8_AllZeroCoeff_mbAddrB_reg <= 0;
		else if (slice_data_state == `skip_run_duration)
			case (mb_num_h)
				0 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[0:1]   <= 0;
				1 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[2:3]   <= 0;
				2 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[4:5]   <= 0;
				3 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[6:7]   <= 0;
				4 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[8:9]   <= 0;
				5 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[10:11] <= 0;
				6 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[12:13] <= 0;
				7 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[14:15] <= 0;
				8 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[16:17] <= 0;
				9 :Luma_8x8_AllZeroCoeff_mbAddrB_reg[18:19] <= 0;
				10:Luma_8x8_AllZeroCoeff_mbAddrB_reg[20:21] <= 0;
			endcase
		else  //update 8x8_AllZero reg when finished one MB residual parsing
			case (mb_num_h)
				0:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [0] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [1] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				1:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [2] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [3] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				2:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [4] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [5] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				3:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [6] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [7] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				4:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [8] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [9] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				5:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [10] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [11] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				6:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [12] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [13] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				7:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [14] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [15] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				8:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [16] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [17] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				9:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [18] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [19] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
				10:
				begin
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [20] <= (CodedBlockPatternLuma[2] == 0)? 1'b0:1'b1;
					Luma_8x8_AllZeroCoeff_mbAddrB_reg [21] <= (CodedBlockPatternLuma[3] == 0)? 1'b0:1'b1;
				end
			endcase
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 0)	
			Chroma_8x8_AllZeroCoeff_mbAddrA <= 0;
		else if (slice_data_state == `skip_run_duration)
			Chroma_8x8_AllZeroCoeff_mbAddrA <= 0;
		else  //update 8x8_AllZero reg when finished one MB residual parsing
			Chroma_8x8_AllZeroCoeff_mbAddrA <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 0)
			Chroma_8x8_AllZeroCoeff_mbAddrB_reg <= 0;
		else if (slice_data_state == `skip_run_duration)
			case (mb_num_h)
				0 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[0]  <= 0;
				1 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[1]  <= 0;
				2 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[2]  <= 0;
				3 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[3]  <= 0;
				4 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[4]  <= 0;
				5 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[5]  <= 0;
				6 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[6]  <= 0;
				7 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[7]  <= 0;
				8 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[8]  <= 0;
				9 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[9]  <= 0;
				10:Chroma_8x8_AllZeroCoeff_mbAddrB_reg[10] <= 0;
			endcase
		else if (mb_num_v != 8)
			case (mb_num_h)
				0 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[0]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				1 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[1]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				2 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[2]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				3 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[3]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				4 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[4]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				5 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[5]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				6 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[6]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				7 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[7]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				8 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[8]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				9 :Chroma_8x8_AllZeroCoeff_mbAddrB_reg[9]  <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
				10:Chroma_8x8_AllZeroCoeff_mbAddrB_reg[10] <= (CodedBlockPatternChroma != 2 )? 1'b0:1'b1;
			endcase
	//-------------------
	//nA_availability
	//-------------------
	always @ (posedge clk)
		if (reset_n == 0)
			nA_availability_reg <= 0;
		else if (cavlc_decoder_state == `nAnB_decoding_s)
			nA_availability_reg <= nA_availability;
	always @ (reset_n or cavlc_decoder_state or residual_state or mb_num_h or i8x8 or i4x4 or i4x4_CbCr or nA_availability_reg)
		if (reset_n == 1'b0)
			nA_availability <= 1'b0;
		else if (cavlc_decoder_state == `nAnB_decoding_s)
			case (residual_state)
				//luma
				`Intra16x16DCLevel_s:nA_availability <= (mb_num_h == 0)? 1'b0:1'b1;
				`Intra16x16ACLevel_s,`LumaLevel_s:
				if ((i8x8 == 0 || i8x8 == 2) && (i4x4 == 0 || i4x4 == 2))
					nA_availability <= (mb_num_h == 0)? 1'b0:1'b1;
				else 
					nA_availability <= 1'b1;
				//chroma
				`ChromaACLevel_Cb_s,`ChromaACLevel_Cr_s:
				nA_availability <= (mb_num_h == 0 && i4x4_CbCr[0] == 0)? 1'b0:1'b1;
				default:nA_availability <= 1'b0;
			endcase
		else
			nA_availability <= nA_availability_reg;
	//-------------------
	//nB_availability
	//-------------------
	always @ (posedge clk)
		if (reset_n == 0)
			nB_availability_reg <= 0;
		else if (cavlc_decoder_state == `nAnB_decoding_s)
			nB_availability_reg <= nB_availability;
	always @ (reset_n or cavlc_decoder_state or residual_state or mb_num_v or i8x8 or i4x4 or i4x4_CbCr
		or nB_availability_reg)
		if (reset_n == 1'b0)
			nB_availability <= 1'b0;
		else if (cavlc_decoder_state == `nAnB_decoding_s)
			case (residual_state)
				//luma
				`Intra16x16DCLevel_s:nB_availability <= (mb_num_v == 0)? 1'b0:1'b1;
				`Intra16x16ACLevel_s,`LumaLevel_s:
				if ((i8x8 == 0 || i8x8 == 1) && (i4x4 == 0 || i4x4 == 1))
					nB_availability <= (mb_num_v == 0)? 1'b0:1'b1;
				else 
					nB_availability <= 1'b1;
				//chroma
				`ChromaACLevel_Cb_s,`ChromaACLevel_Cr_s:
				nB_availability <= (mb_num_v == 0 && i4x4_CbCr[1] == 0)? 1'b0:1'b1;
				default:nB_availability <= 1'b0;
			endcase
		else 
			nB_availability <= nB_availability_reg;
	//------------
	//Derive nA
	//------------
	always @ (posedge clk)
		if (reset_n == 0)
			nA <= 0;
		else if (cavlc_decoder_state == `nAnB_decoding_s && nA_availability == 1)
			case (residual_state)
				//luma
				`Intra16x16DCLevel_s:nA <= (Luma_8x8_AllZeroCoeff_mbAddrA[0] == 0)? 0:LumaLevel_mbAddrA[4:0];
				`Intra16x16ACLevel_s,`LumaLevel_s:
				case (i8x8)
					0:
					case (i4x4)
						0:nA <= (Luma_8x8_AllZeroCoeff_mbAddrA[0] == 0)? 0:LumaLevel_mbAddrA[4:0];
						1:nA <= LumaLevel_CurrMb0[4:0];
						2:nA <= (Luma_8x8_AllZeroCoeff_mbAddrA[0] == 0)? 0:LumaLevel_mbAddrA[9:5];
						3:nA <= LumaLevel_CurrMb0[14:10];
					endcase
					1:
					case (i4x4)
						0:nA <= (CodedBlockPatternLuma[0] == 0)? 0:LumaLevel_CurrMb0[9:5];
						1:nA <= LumaLevel_CurrMb1[4:0];
						2:nA <= (CodedBlockPatternLuma[0] == 0)? 0:LumaLevel_CurrMb0[19:15];
						3:nA <= LumaLevel_CurrMb1[14:10];
					endcase
					2:
					case (i4x4)
						0:nA <= (Luma_8x8_AllZeroCoeff_mbAddrA[1] == 0)? 0:LumaLevel_mbAddrA[14:10];
						1:nA <= LumaLevel_CurrMb2[4:0];
						2:nA <= (Luma_8x8_AllZeroCoeff_mbAddrA[1] == 0)? 0:LumaLevel_mbAddrA[19:15];
						3:nA <= LumaLevel_CurrMb2[14:10];
					endcase
					3:
					case (i4x4)
						0:nA <= (CodedBlockPatternLuma[2] == 0)? 0:LumaLevel_CurrMb2[9:5];
						1:nA <= LumaLevel_CurrMb3[4:0];
						2:nA <= (CodedBlockPatternLuma[2] == 0)? 0:LumaLevel_CurrMb2[19:15];
						3:nA <= LumaLevel_CurrMb3[14:10];
					endcase
				endcase
				//chroma
				`ChromaACLevel_Cb_s:
				case (i4x4_CbCr)
					2'b00:nA <= (Chroma_8x8_AllZeroCoeff_mbAddrA == 0)? 0:ChromaLevel_Cb_mbAddrA[4:0];
					2'b10:nA <= (Chroma_8x8_AllZeroCoeff_mbAddrA == 0)? 0:ChromaLevel_Cb_mbAddrA[9:5];
					2'b01:nA <= (CodedBlockPatternChroma         != 2)? 0:ChromaLevel_Cb_CurrMb[4:0];
					2'b11:nA <= (CodedBlockPatternChroma         != 2)? 0:ChromaLevel_Cb_CurrMb[14:10];
				endcase
				`ChromaACLevel_Cr_s:
				case (i4x4_CbCr)
					2'b00:nA <= (Chroma_8x8_AllZeroCoeff_mbAddrA == 0)? 0:ChromaLevel_Cr_mbAddrA[4:0];
					2'b10:nA <= (Chroma_8x8_AllZeroCoeff_mbAddrA == 0)? 0:ChromaLevel_Cr_mbAddrA[9:5];
					2'b01:nA <= (CodedBlockPatternChroma         != 2)? 0:ChromaLevel_Cr_CurrMb[4:0];
					2'b11:nA <= (CodedBlockPatternChroma         != 2)? 0:ChromaLevel_Cr_CurrMb[14:10];
				endcase
			endcase
		else if (cavlc_decoder_state == `nAnB_decoding_s && nA_availability == 0)
			nA <= 0;
	//------------
	//Derive nB
	//------------
	always @ (posedge clk)
		if (reset_n == 0)
			nB <= 0;
		else if (cavlc_decoder_state == `nAnB_decoding_s && nB_availability == 1)
			case (residual_state)
				`Intra16x16DCLevel_s:
				nB <= (Luma_8x8_AllZeroCoeff_mbAddrB[0] == 0)? 0:LumaLevel_mbAddrB_dout[19:15];
				`Intra16x16ACLevel_s,`LumaLevel_s:
				case (i8x8)
					0:
					case (i4x4)
						0:nB <= (Luma_8x8_AllZeroCoeff_mbAddrB[0] == 0)? 0:LumaLevel_mbAddrB_dout[19:15];
						1:nB <= (Luma_8x8_AllZeroCoeff_mbAddrB[0] == 0)? 0:LumaLevel_mbAddrB_dout[14:10];
						2:nB <= LumaLevel_CurrMb0[4:0];
						3:nB <= LumaLevel_CurrMb0[9:5];
					endcase
					1:
					case (i4x4)
						0:nB <= (Luma_8x8_AllZeroCoeff_mbAddrB[1] == 0)? 0:LumaLevel_mbAddrB_dout[9:5];
						1:nB <= (Luma_8x8_AllZeroCoeff_mbAddrB[1] == 0)? 0:LumaLevel_mbAddrB_dout[4:0];
						2:nB <= LumaLevel_CurrMb1[4:0];
						3:nB <= LumaLevel_CurrMb1[9:5];
					endcase
					2:
					case (i4x4)
						0:nB <= (CodedBlockPatternLuma[0] == 0)? 0:LumaLevel_CurrMb0[14:10];
						1:nB <= (CodedBlockPatternLuma[0] == 0)? 0:LumaLevel_CurrMb0[19:15];
						2:nB <= LumaLevel_CurrMb2[4:0];
						3:nB <= LumaLevel_CurrMb2[9:5];
					endcase
					3:
					case (i4x4)
						0:nB <= (CodedBlockPatternLuma[1] == 0)? 0:LumaLevel_CurrMb1[14:10];
						1:nB <= (CodedBlockPatternLuma[1] == 0)? 0:LumaLevel_CurrMb1[19:15];
						2:nB <= LumaLevel_CurrMb3[4:0];
						3:nB <= LumaLevel_CurrMb3[9:5];
					endcase
				endcase
				`ChromaACLevel_Cb_s:
				case (i4x4_CbCr)
					0:nB <= (Chroma_8x8_AllZeroCoeff_mbAddrB == 0)? 0:ChromaLevel_Cb_mbAddrB_dout[9:5];
					1:nB <= (Chroma_8x8_AllZeroCoeff_mbAddrB == 0)? 0:ChromaLevel_Cb_mbAddrB_dout[4:0];
					2:nB <= ChromaLevel_Cb_CurrMb[4:0];
					3:nB <= ChromaLevel_Cb_CurrMb[9:5];
				endcase
				`ChromaACLevel_Cr_s:
				case (i4x4_CbCr)
					0:nB <= (Chroma_8x8_AllZeroCoeff_mbAddrB == 0)? 0:ChromaLevel_Cr_mbAddrB_dout[9:5];
					1:nB <= (Chroma_8x8_AllZeroCoeff_mbAddrB == 0)? 0:ChromaLevel_Cr_mbAddrB_dout[4:0];
					2:nB <= ChromaLevel_Cr_CurrMb[4:0];
					3:nB <= ChromaLevel_Cr_CurrMb[9:5];
				endcase
				default: nB <= 0;
			endcase
		else if (cavlc_decoder_state == `nAnB_decoding_s && nB_availability == 0)
			nB <= 0;
	//------------
	//Derive nC
	//------------
	always @ (posedge clk)
		if (reset_n == 0)
			nC <= 0;
		else if (cavlc_decoder_state == `nC_decoding_s)
			begin
				if (residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s)
					nC <= 5'b11111;
				else if (nA_availability == 1 && nB_availability == 1)
					nC <= (nA + nB + 1) >> 1;
				else
					nC <= nA + nB;
			end
	//-----------------------	
	//LumaLevel_CurrMb write 
	//-----------------------
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				LumaLevel_CurrMb0 <= 0;	LumaLevel_CurrMb1 <= 0;	
				LumaLevel_CurrMb2 <= 0; LumaLevel_CurrMb3 <= 0;
			end
		else if (end_of_one_residual_block == 1 && (residual_state == `Intra16x16ACLevel_s || 
			residual_state == `LumaLevel_s))
			case (i8x8)
				0:
				case (i4x4)
					0:LumaLevel_CurrMb0[4:0]   <= TotalCoeff;
					1:LumaLevel_CurrMb0[9:5]   <= TotalCoeff;
					2:LumaLevel_CurrMb0[14:10] <= TotalCoeff;
					3:LumaLevel_CurrMb0[19:15] <= TotalCoeff;
				endcase
				1:
				case (i4x4)
					0:LumaLevel_CurrMb1[4:0]   <= TotalCoeff;
					1:LumaLevel_CurrMb1[9:5]   <= TotalCoeff;
					2:LumaLevel_CurrMb1[14:10] <= TotalCoeff;
					3:LumaLevel_CurrMb1[19:15] <= TotalCoeff;
				endcase
				2:
				case (i4x4)
					0:LumaLevel_CurrMb2[4:0]   <= TotalCoeff;
					1:LumaLevel_CurrMb2[9:5]   <= TotalCoeff;
					2:LumaLevel_CurrMb2[14:10] <= TotalCoeff;
					3:LumaLevel_CurrMb2[19:15] <= TotalCoeff;
				endcase
				3:
				case (i4x4)
					0:LumaLevel_CurrMb3[4:0]   <= TotalCoeff;
					1:LumaLevel_CurrMb3[9:5]   <= TotalCoeff;
					2:LumaLevel_CurrMb3[14:10] <= TotalCoeff;
					3:LumaLevel_CurrMb3[19:15] <= TotalCoeff;
				endcase
			endcase
	//---------------------------	
	//ChromaLevel_Cb_CurrMb write 
	//---------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			ChromaLevel_Cb_CurrMb <= 0;
		else if (end_of_one_residual_block == 1 && residual_state == `ChromaACLevel_Cb_s)
			case (i4x4_CbCr)
				0:ChromaLevel_Cb_CurrMb[4:0]   <= TotalCoeff;
				1:ChromaLevel_Cb_CurrMb[9:5]   <= TotalCoeff;
				2:ChromaLevel_Cb_CurrMb[14:10] <= TotalCoeff;
				3:ChromaLevel_Cb_CurrMb[19:15] <= TotalCoeff;
			endcase
	//---------------------------	
	//ChromaLevel_Cr_CurrMb write 
	//---------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			ChromaLevel_Cr_CurrMb <= 0;
		else if (end_of_one_residual_block == 1 && residual_state == `ChromaACLevel_Cr_s)
			case (i4x4_CbCr)
				0:ChromaLevel_Cr_CurrMb[4:0]   <= TotalCoeff;
				1:ChromaLevel_Cr_CurrMb[9:5]   <= TotalCoeff;
				2:ChromaLevel_Cr_CurrMb[14:10] <= TotalCoeff;
				3:ChromaLevel_Cr_CurrMb[19:15] <= TotalCoeff;
			endcase
	//-----------------------	
	//LumaLevel_mbAddrA write 
	//-----------------------
	always @ (posedge clk)
		if (reset_n == 0)
			LumaLevel_mbAddrA <= 0;
		else if (end_of_one_residual_block == 1 && (residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s) && mb_num_h != 10)
			case (i8x8)
				1:
				case (i4x4)
					1:LumaLevel_mbAddrA[4:0] <= TotalCoeff;
					3:LumaLevel_mbAddrA[9:5] <= TotalCoeff;
				endcase
				3:
				case (i4x4)
					1:LumaLevel_mbAddrA[14:10] <= TotalCoeff;
					3:LumaLevel_mbAddrA[19:15] <= TotalCoeff;
				endcase
			endcase
	//----------------------------	
	//ChromaLevel_Cb_mbAddrA write 
	//----------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			ChromaLevel_Cb_mbAddrA <= 0;
		else if (end_of_one_residual_block == 1 && residual_state == `ChromaACLevel_Cb_s && mb_num_h != 10)
			begin
				if (i4x4_CbCr == 1)
					ChromaLevel_Cb_mbAddrA[4:0] <= TotalCoeff;
				if (i4x4_CbCr == 3)
					ChromaLevel_Cb_mbAddrA[9:5] <= TotalCoeff;
			end
	//----------------------------	
	//ChromaLevel_Cr_mbAddrA write 
	//----------------------------
	always @ (posedge clk)
		if (reset_n == 0)
			ChromaLevel_Cr_mbAddrA <= 0;
		else if (end_of_one_residual_block == 1 && residual_state == `ChromaACLevel_Cr_s && mb_num_h != 10)
			begin
				if (i4x4_CbCr == 1)
					ChromaLevel_Cr_mbAddrA[4:0] <= TotalCoeff;
				if (i4x4_CbCr == 3)
					ChromaLevel_Cr_mbAddrA[9:5] <= TotalCoeff;
			end
	//------------------------------	
	//LumaLevel_mbAddrB read & write 
	//------------------------------
	always @ (reset_n or cavlc_decoder_state or residual_state or nB_availability or 
		Luma_8x8_AllZeroCoeff_mbAddrB or i8x8 or i4x4 or end_of_one_residual_block or 
		mb_num_v or mb_num_h or CodedBlockPatternLuma or LumaLevel_CurrMb2 or LumaLevel_CurrMb3 or TotalCoeff)
		if (reset_n == 0)
			begin
				LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
				LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
				LumaLevel_mbAddrB_din <= 0;
			end
		//--read--
		else if (cavlc_decoder_state == `nAnB_decoding_s && nB_availability == 1) //read
			case (residual_state)
				`Intra16x16DCLevel_s:
				if (Luma_8x8_AllZeroCoeff_mbAddrB == 0)
					begin
						LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
						LumaLevel_mbAddrB_din <= 0;
					end
				else
					begin
						LumaLevel_mbAddrB_cs_n    <= 0;        LumaLevel_mbAddrB_wr_n    <= 1;
						LumaLevel_mbAddrB_rd_addr <= mb_num_h; LumaLevel_mbAddrB_wr_addr <= 0;
						LumaLevel_mbAddrB_din <= 0;
					end
				`Intra16x16ACLevel_s,`LumaLevel_s:
				case (i8x8)
					0:
					if (Luma_8x8_AllZeroCoeff_mbAddrB[0] == 0)
						begin
							LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
							LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
							LumaLevel_mbAddrB_din <= 0;
						end
					else
						begin
							LumaLevel_mbAddrB_cs_n    <= 0;        LumaLevel_mbAddrB_wr_n    <= 1;
							LumaLevel_mbAddrB_rd_addr <= mb_num_h; LumaLevel_mbAddrB_wr_addr <= 0;
							LumaLevel_mbAddrB_din <= 0;
						end
					1:
					if (Luma_8x8_AllZeroCoeff_mbAddrB[1] == 0)
						begin
							LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
							LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
							LumaLevel_mbAddrB_din <= 0;
						end
					else
						begin
							LumaLevel_mbAddrB_cs_n    <= 0;        LumaLevel_mbAddrB_wr_n    <= 1;
							LumaLevel_mbAddrB_rd_addr <= mb_num_h; LumaLevel_mbAddrB_wr_addr <= 0;
							LumaLevel_mbAddrB_din <= 0;
						end
					default:
					begin
						LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
						LumaLevel_mbAddrB_din <= 0;
					end
				endcase
				default:
				begin
					LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
					LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
					LumaLevel_mbAddrB_din <= 0;
				end
			endcase
		//--write--
		else if ((residual_state == `Intra16x16ACLevel_s || residual_state == `LumaLevel_s) && end_of_one_residual_block == 1 && mb_num_v != 8)
			case (CodedBlockPatternLuma[3:2])
				2'b00:
				begin
					LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
					LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
					LumaLevel_mbAddrB_din <= 0;
				end
				2'b10,2'b11:
				if (i8x8 == 3 && i4x4 == 3)
					begin
						LumaLevel_mbAddrB_cs_n    <= 0; LumaLevel_mbAddrB_wr_n    <= 0;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= mb_num_h;
						LumaLevel_mbAddrB_din <= (CodedBlockPatternLuma[3:2] == 2'b10)?
						{10'b0,	LumaLevel_CurrMb3[14:10],TotalCoeff}:
						{LumaLevel_CurrMb2[14:10],LumaLevel_CurrMb2[19:15],LumaLevel_CurrMb3[14:10],TotalCoeff};
					end
				else
					begin
						LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
						LumaLevel_mbAddrB_din <= 0;
					end
				2'b01:
				if (i8x8 == 2 && i4x4 == 3)
					begin
						LumaLevel_mbAddrB_cs_n    <= 0; LumaLevel_mbAddrB_wr_n    <= 0;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= mb_num_h;
						LumaLevel_mbAddrB_din <= {LumaLevel_CurrMb2[14:10],TotalCoeff,10'b0};
					end
				else
					begin
						LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
						LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
						LumaLevel_mbAddrB_din <= 0;
					end
			endcase
		else
			begin
				LumaLevel_mbAddrB_cs_n    <= 1; LumaLevel_mbAddrB_wr_n    <= 1;
				LumaLevel_mbAddrB_rd_addr <= 0; LumaLevel_mbAddrB_wr_addr <= 0;
				LumaLevel_mbAddrB_din <= 0;
			end
	//-----------------------------------	
	//ChromaLevel_Cb_mbAddrB read & write 
	//-----------------------------------
	always @ (reset_n or cavlc_decoder_state or residual_state or nB_availability or i4x4_CbCr or ChromaLevel_Cb_CurrMb 
	  or Chroma_8x8_AllZeroCoeff_mbAddrB or mb_num_h or mb_num_v or TotalCoeff or end_of_one_residual_block)
		if (reset_n == 0)
			begin
				ChromaLevel_Cb_mbAddrB_cs_n    <= 1; ChromaLevel_Cb_mbAddrB_wr_n    <= 1;
				ChromaLevel_Cb_mbAddrB_rd_addr <= 0; ChromaLevel_Cb_mbAddrB_wr_addr <= 0;
				ChromaLevel_Cb_mbAddrB_din <= 0;
			end	
		//--read--
		else if (cavlc_decoder_state == `nAnB_decoding_s && nB_availability == 1 &&	
			residual_state == `ChromaACLevel_Cb_s)	
			begin
				if (i4x4_CbCr[1] == 0 && Chroma_8x8_AllZeroCoeff_mbAddrB == 1)
					begin
						ChromaLevel_Cb_mbAddrB_cs_n    <= 0;        ChromaLevel_Cb_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cb_mbAddrB_rd_addr <= mb_num_h; ChromaLevel_Cb_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cb_mbAddrB_din <= 0;
					end
				else
					begin
						ChromaLevel_Cb_mbAddrB_cs_n    <= 1; ChromaLevel_Cb_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cb_mbAddrB_rd_addr <= 0; ChromaLevel_Cb_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cb_mbAddrB_din <= 0;
					end
			end
		//--write--
		else if (residual_state == `ChromaACLevel_Cb_s && end_of_one_residual_block == 1 && mb_num_v != 8)
			begin
				if (i4x4_CbCr == 3)
					begin
						ChromaLevel_Cb_mbAddrB_cs_n    <= 0; ChromaLevel_Cb_mbAddrB_wr_n    <= 0;
						ChromaLevel_Cb_mbAddrB_rd_addr <= 0; ChromaLevel_Cb_mbAddrB_wr_addr <= mb_num_h;
						ChromaLevel_Cb_mbAddrB_din <= {ChromaLevel_Cb_CurrMb[14:10],TotalCoeff};
					end
				else
					begin
						ChromaLevel_Cb_mbAddrB_cs_n    <= 1; ChromaLevel_Cb_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cb_mbAddrB_rd_addr <= 0; ChromaLevel_Cb_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cb_mbAddrB_din <= 0;
					end
			end
		else
			begin
				ChromaLevel_Cb_mbAddrB_cs_n    <= 1; ChromaLevel_Cb_mbAddrB_wr_n    <= 1;
				ChromaLevel_Cb_mbAddrB_rd_addr <= 0; ChromaLevel_Cb_mbAddrB_wr_addr <= 0;
				ChromaLevel_Cb_mbAddrB_din <= 0;
			end
	//-----------------------------------	
	//ChromaLevel_Cr_mbAddrB read & write 
	//-----------------------------------
	always @ (reset_n or cavlc_decoder_state or residual_state or nB_availability or i4x4_CbCr
		or ChromaLevel_Cr_CurrMb or Chroma_8x8_AllZeroCoeff_mbAddrB or mb_num_h or mb_num_v or TotalCoeff
		or end_of_one_residual_block)
		if (reset_n == 0)
			begin
				ChromaLevel_Cr_mbAddrB_cs_n    <= 1; ChromaLevel_Cr_mbAddrB_wr_n    <= 1;
				ChromaLevel_Cr_mbAddrB_rd_addr <= 0; ChromaLevel_Cr_mbAddrB_wr_addr <= 0;
				ChromaLevel_Cr_mbAddrB_din <= 0;
			end
		//--read--
		else if (cavlc_decoder_state == `nAnB_decoding_s && nB_availability == 1 &&	residual_state == `ChromaACLevel_Cr_s)	//read
			begin
				if (i4x4_CbCr[1] == 0 && Chroma_8x8_AllZeroCoeff_mbAddrB == 1)
					begin
						ChromaLevel_Cr_mbAddrB_cs_n    <= 0;        ChromaLevel_Cr_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cr_mbAddrB_rd_addr <= mb_num_h; ChromaLevel_Cr_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cr_mbAddrB_din <= 0;
					end
				else
					begin
						ChromaLevel_Cr_mbAddrB_cs_n    <= 1; ChromaLevel_Cr_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cr_mbAddrB_rd_addr <= 0; ChromaLevel_Cr_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cr_mbAddrB_din <= 0;
					end
			end
		//--write--
		else if (residual_state == `ChromaACLevel_Cr_s && end_of_one_residual_block == 1 && mb_num_v != 8)
			begin
				if (i4x4_CbCr == 3)
					begin
						ChromaLevel_Cr_mbAddrB_cs_n    <= 0; ChromaLevel_Cr_mbAddrB_wr_n    <= 0;
						ChromaLevel_Cr_mbAddrB_rd_addr <= 0; ChromaLevel_Cr_mbAddrB_wr_addr <= mb_num_h;
						ChromaLevel_Cr_mbAddrB_din <= {ChromaLevel_Cr_CurrMb[14:10],TotalCoeff};
					end
				else
					begin
						ChromaLevel_Cr_mbAddrB_cs_n    <= 1; ChromaLevel_Cr_mbAddrB_wr_n    <= 1;
						ChromaLevel_Cr_mbAddrB_rd_addr <= 0; ChromaLevel_Cr_mbAddrB_wr_addr <= 0;
						ChromaLevel_Cr_mbAddrB_din <= 0;
					end
			end
		else
			begin
				ChromaLevel_Cr_mbAddrB_cs_n    <= 1; ChromaLevel_Cr_mbAddrB_wr_n    <= 1;
				ChromaLevel_Cr_mbAddrB_rd_addr <= 0; ChromaLevel_Cr_mbAddrB_wr_addr <= 0;
				ChromaLevel_Cr_mbAddrB_din <= 0;
			end
endmodule
