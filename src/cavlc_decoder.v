//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : cavlc_decoder.v
// Generated : June 12,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// cavlc_decoder top module
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module cavlc_decoder (clk,reset_n,gclk_end_of_MB_DEC,
	gclk_LumaLevel_mbAddrB_RF,gclk_ChromaLevel_Cb_mbAddrB_RF,gclk_ChromaLevel_Cr_mbAddrB_RF,
	slice_data_state,residual_state,cavlc_decoder_state,mb_num_h,mb_num_v,i8x8,i4x4,i4x4_CbCr,
	i_level,i_run,i_TotalCoeff,coeffNum,
	heading_one_pos,BitStream_buffer_output,
	CodedBlockPatternLuma,CodedBlockPatternChroma,suffix_length_initialized,IsRunLoop,
	
	Luma_8x8_AllZeroCoeff_mbAddrA,LumaLevel_mbAddrA,LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3,
	LumaLevel_mbAddrB_dout,LumaLevel_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_cs_n,
	end_of_one_residual_block,end_of_NonZeroCoeff_CAVLC,
	cavlc_consumed_bits_len,TotalCoeff,TrailingOnes,maxNumCoeff,zerosLeft,run,
	coeffLevel_0,coeffLevel_1,coeffLevel_2, coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6, coeffLevel_7,
	coeffLevel_8,coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15);
	input clk,reset_n;
	input gclk_end_of_MB_DEC;
	input gclk_LumaLevel_mbAddrB_RF;
	input gclk_ChromaLevel_Cb_mbAddrB_RF;
	input gclk_ChromaLevel_Cr_mbAddrB_RF;
	input [3:0] slice_data_state;
	input [3:0] residual_state;
	input [3:0] cavlc_decoder_state;
	input [3:0]	mb_num_h;
	input [3:0] mb_num_v;
	input [1:0] i8x8;
	input [1:0] i4x4;
	input [1:0] i4x4_CbCr;
	input [3:0] i_level;
	input [3:0] i_run;
	input [3:0] i_TotalCoeff;
	input [3:0] coeffNum;
	input [3:0] heading_one_pos;
	input [15:0] BitStream_buffer_output; 
	input [3:0] CodedBlockPatternLuma;
	input [1:0] CodedBlockPatternChroma;
	input suffix_length_initialized;
	input IsRunLoop;
	
	output [1:0] Luma_8x8_AllZeroCoeff_mbAddrA;
	output [19:0] LumaLevel_mbAddrA;
	output [19:0] LumaLevel_CurrMb0,LumaLevel_CurrMb1,LumaLevel_CurrMb2,LumaLevel_CurrMb3;
	output [19:0] LumaLevel_mbAddrB_dout;
	output LumaLevel_mbAddrB_cs_n;
	output ChromaLevel_Cb_mbAddrB_cs_n;
	output ChromaLevel_Cr_mbAddrB_cs_n;
	output end_of_one_residual_block;
	output end_of_NonZeroCoeff_CAVLC;
	output [4:0] cavlc_consumed_bits_len;
	output [4:0] TotalCoeff;
	output [1:0] TrailingOnes;
	output [4:0] maxNumCoeff;
	output [3:0] zerosLeft;
	output [3:0] run;
	output [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6;
	output [8:0] coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13;
	output [8:0] coeffLevel_14,coeffLevel_15;
	
	wire LumaLevel_mbAddrB_cs_n,LumaLevel_mbAddrB_wr_n;
	wire [3:0] LumaLevel_mbAddrB_rd_addr,LumaLevel_mbAddrB_wr_addr;
	wire [19:0] LumaLevel_mbAddrB_din;
	wire [19:0] LumaLevel_mbAddrB_dout;
	wire ChromaLevel_Cb_mbAddrB_cs_n,ChromaLevel_Cb_mbAddrB_wr_n;
	wire [3:0] ChromaLevel_Cb_mbAddrB_rd_addr,ChromaLevel_Cb_mbAddrB_wr_addr;
	wire [9:0] ChromaLevel_Cb_mbAddrB_din;
	wire [9:0] ChromaLevel_Cb_mbAddrB_dout;
	wire ChromaLevel_Cr_mbAddrB_cs_n,ChromaLevel_Cr_mbAddrB_wr_n;
	wire [3:0] ChromaLevel_Cr_mbAddrB_rd_addr,ChromaLevel_Cr_mbAddrB_wr_addr;
	wire [9:0] ChromaLevel_Cr_mbAddrB_din;
	wire [9:0] ChromaLevel_Cr_mbAddrB_dout;
	wire [4:0] nC;
	wire [4:0] NumCoeffTrailingOnes_len;
	wire [3:0] levelSuffixSize;
	wire [8:0] level_0,level_1,level_2, level_3, level_4, level_5, level_6, level_7;
	wire [8:0] level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15;
	wire [3:0] total_zeros;
	wire [3:0] total_zeros_len;
	wire [3:0] run_of_zeros_len;
	
	nC_decoding nC_decoding (
		.clk(clk),
		.reset_n(reset_n),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.cavlc_decoder_state(cavlc_decoder_state),
		.residual_state(residual_state),
		.slice_data_state(slice_data_state),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.i8x8(i8x8),
		.i4x4(i4x4),
		.i4x4_CbCr(i4x4_CbCr),
		.CodedBlockPatternLuma(CodedBlockPatternLuma),
		.CodedBlockPatternChroma(CodedBlockPatternChroma),
		.LumaLevel_mbAddrB_dout(LumaLevel_mbAddrB_dout),
		.ChromaLevel_Cb_mbAddrB_dout(ChromaLevel_Cb_mbAddrB_dout),
		.ChromaLevel_Cr_mbAddrB_dout(ChromaLevel_Cr_mbAddrB_dout),
		.end_of_one_residual_block(end_of_one_residual_block),
		.TotalCoeff(TotalCoeff), 
	
		.nC(nC),
		.Luma_8x8_AllZeroCoeff_mbAddrA(Luma_8x8_AllZeroCoeff_mbAddrA),
		.LumaLevel_mbAddrA(LumaLevel_mbAddrA),
		.LumaLevel_CurrMb0(LumaLevel_CurrMb0),
		.LumaLevel_CurrMb1(LumaLevel_CurrMb1),
		.LumaLevel_CurrMb2(LumaLevel_CurrMb2),
		.LumaLevel_CurrMb3(LumaLevel_CurrMb3),
		.LumaLevel_mbAddrB_cs_n(LumaLevel_mbAddrB_cs_n),
		.LumaLevel_mbAddrB_wr_n(LumaLevel_mbAddrB_wr_n),
		.LumaLevel_mbAddrB_rd_addr(LumaLevel_mbAddrB_rd_addr),
		.LumaLevel_mbAddrB_wr_addr(LumaLevel_mbAddrB_wr_addr),
		.LumaLevel_mbAddrB_din(LumaLevel_mbAddrB_din),
		.ChromaLevel_Cb_mbAddrB_cs_n(ChromaLevel_Cb_mbAddrB_cs_n),
		.ChromaLevel_Cb_mbAddrB_wr_n(ChromaLevel_Cb_mbAddrB_wr_n),
		.ChromaLevel_Cb_mbAddrB_rd_addr(ChromaLevel_Cb_mbAddrB_rd_addr),
		.ChromaLevel_Cb_mbAddrB_wr_addr(ChromaLevel_Cb_mbAddrB_wr_addr),
		.ChromaLevel_Cb_mbAddrB_din(ChromaLevel_Cb_mbAddrB_din),
		.ChromaLevel_Cr_mbAddrB_cs_n(ChromaLevel_Cr_mbAddrB_cs_n),
		.ChromaLevel_Cr_mbAddrB_wr_n(ChromaLevel_Cr_mbAddrB_wr_n),
		.ChromaLevel_Cr_mbAddrB_rd_addr(ChromaLevel_Cr_mbAddrB_rd_addr),
		.ChromaLevel_Cr_mbAddrB_wr_addr(ChromaLevel_Cr_mbAddrB_wr_addr),
		.ChromaLevel_Cr_mbAddrB_din(ChromaLevel_Cr_mbAddrB_din)
		);
	ram_async_1r_sync_1w # (`LumaLevel_mbAddrB_RF_data_width,`LumaLevel_mbAddrB_RF_data_depth)
	LumaLevel_mbAddrB_RF(
		.clk(gclk_LumaLevel_mbAddrB_RF), 
		.rst_n(reset_n),
		.cs_n(LumaLevel_mbAddrB_cs_n),
		.wr_n(LumaLevel_mbAddrB_wr_n),
		.rd_addr(LumaLevel_mbAddrB_rd_addr),
		.wr_addr(LumaLevel_mbAddrB_wr_addr),
		.data_in(LumaLevel_mbAddrB_din),
		.data_out(LumaLevel_mbAddrB_dout)
		);
	ram_async_1r_sync_1w # (`ChromaLevel_Cb_mbAddrB_RF_data_width,`ChromaLevel_Cb_mbAddrB_RF_data_depth)
		ChromaLevel_Cb_mbAddrB_RF(
		.clk(gclk_ChromaLevel_Cb_mbAddrB_RF),
		.rst_n(reset_n),
		.cs_n(ChromaLevel_Cb_mbAddrB_cs_n),
		.wr_n(ChromaLevel_Cb_mbAddrB_wr_n),
		.rd_addr(ChromaLevel_Cb_mbAddrB_rd_addr),
		.wr_addr(ChromaLevel_Cb_mbAddrB_wr_addr),
		.data_in(ChromaLevel_Cb_mbAddrB_din),
		.data_out(ChromaLevel_Cb_mbAddrB_dout)
		);
	ram_async_1r_sync_1w # (`ChromaLevel_Cr_mbAddrB_RF_data_width,`ChromaLevel_Cr_mbAddrB_RF_data_depth)
		ChromaLevel_Cr_mbAddrB_RF(
		.clk(gclk_ChromaLevel_Cr_mbAddrB_RF),
		.rst_n(reset_n),
		.cs_n(ChromaLevel_Cr_mbAddrB_cs_n),
		.wr_n(ChromaLevel_Cr_mbAddrB_wr_n),
		.rd_addr(ChromaLevel_Cr_mbAddrB_rd_addr),
		.wr_addr(ChromaLevel_Cr_mbAddrB_wr_addr),
		.data_in(ChromaLevel_Cr_mbAddrB_din),
		.data_out(ChromaLevel_Cr_mbAddrB_dout)
		);
	NumCoeffTrailingOnes_decoding NumCoeffTrailingOnes_decoding(
		.clk(clk),
		.reset_n(reset_n),
		.cavlc_decoder_state(cavlc_decoder_state),
		.heading_one_pos(heading_one_pos),
		.BitStream_buffer_output(BitStream_buffer_output),
		.nC(nC),
		.TrailingOnes(TrailingOnes),
		.TotalCoeff(TotalCoeff),
		.NumCoeffTrailingOnes_len(NumCoeffTrailingOnes_len)
		);
	level_decoding level_decoding(
		.clk(clk),
		.reset_n(reset_n),
		.cavlc_decoder_state(cavlc_decoder_state),
		.heading_one_pos(heading_one_pos),
		.suffix_length_initialized(suffix_length_initialized),
		.i_level(i_level),
		.TotalCoeff(TotalCoeff),
		.TrailingOnes(TrailingOnes),
		.BitStream_buffer_output(BitStream_buffer_output),
		.levelSuffixSize(levelSuffixSize),
		.level_0(level_0),
		.level_1(level_1),
		.level_2(level_2),
		.level_3(level_3),
		.level_4(level_4),
		.level_5(level_5),
		.level_6(level_6),
		.level_7(level_7),
		.level_8(level_8),
		.level_9(level_9),
		.level_10(level_10),
		.level_11(level_11),
		.level_12(level_12),
		.level_13(level_13),
		.level_14(level_14),
		.level_15(level_15)
		);
	total_zeros_decoding total_zeros_decoding(
		.clk(clk),
		.reset_n(reset_n),
		.residual_state(residual_state),
		.cavlc_decoder_state(cavlc_decoder_state),
		.TotalCoeff_3to0(TotalCoeff[3:0]),
		.heading_one_pos(heading_one_pos),
		.BitStream_buffer_output(BitStream_buffer_output),
		.maxNumCoeff(maxNumCoeff),
		.total_zeros(total_zeros),
		.total_zeros_len(total_zeros_len)
		);
	run_decoding run_decoding(
		.clk(clk),
		.reset_n(reset_n),
		.cavlc_decoder_state(cavlc_decoder_state),
		.BitStream_buffer_output(BitStream_buffer_output),
		.total_zeros(total_zeros),
		.level_0(level_0),
		.level_1(level_1),
		.level_2(level_2),
		.level_3(level_3),
		.level_4(level_4),
		.level_5(level_5),
		.level_6(level_6),
		.level_7(level_7),
		.level_8(level_8),
		.level_9(level_9),
		.level_10(level_10),
		.level_11(level_11),
		.level_12(level_12),
		.level_13(level_13),
		.level_14(level_14),
		.level_15(level_15),
		.TotalCoeff(TotalCoeff),
		.i_run(i_run),
		.i_TotalCoeff(i_TotalCoeff),
		.coeffNum(coeffNum),
		.IsRunLoop(IsRunLoop),
		
		.run_of_zeros_len(run_of_zeros_len),
		.zerosLeft(zerosLeft),
		.run(run),
		.coeffLevel_0(coeffLevel_0),
		.coeffLevel_1(coeffLevel_1),
		.coeffLevel_2(coeffLevel_2), 
		.coeffLevel_3(coeffLevel_3),
		.coeffLevel_4(coeffLevel_4), 
		.coeffLevel_5(coeffLevel_5), 
		.coeffLevel_6(coeffLevel_6),
		.coeffLevel_7(coeffLevel_7),
		.coeffLevel_8(coeffLevel_8),
		.coeffLevel_9(coeffLevel_9),
		.coeffLevel_10(coeffLevel_10),
		.coeffLevel_11(coeffLevel_11),
		.coeffLevel_12(coeffLevel_12),
		.coeffLevel_13(coeffLevel_13),
		.coeffLevel_14(coeffLevel_14),
		.coeffLevel_15(coeffLevel_15)
		);
	end_of_blk_decoding end_of_blk_decoding(
		.reset_n(reset_n),
		.cavlc_decoder_state(cavlc_decoder_state),
		.TotalCoeff(TotalCoeff),
		.i_TotalCoeff(i_TotalCoeff),
		.end_of_one_residual_block(end_of_one_residual_block),
		.end_of_NonZeroCoeff_CAVLC(end_of_NonZeroCoeff_CAVLC)
		);
	cavlc_consumed_bits_decoding cavlc_consumed_bits_decoding(
		.cavlc_decoder_state(cavlc_decoder_state),
		.NumCoeffTrailingOnes_len(NumCoeffTrailingOnes_len),
		.TrailingOnes(TrailingOnes),
		.heading_one_pos(heading_one_pos),
		.levelSuffixSize(levelSuffixSize),
		.total_zeros_len(total_zeros_len),
		.run_of_zeros_len(run_of_zeros_len),
		.cavlc_consumed_bits_len(cavlc_consumed_bits_len)
		);
endmodule