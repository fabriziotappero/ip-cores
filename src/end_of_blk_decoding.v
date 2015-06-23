//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : end_of_blk_decoding.v
// Generated : June 12, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding end_of_one_residual_block signal for 1 cycle duration
// 1)for BitStream_parser_FSM to update signals such as i4x4 and direct state switch
// 2)for nC_decoding to update LumaLevel/ChromaLevel CurrMb,mbAddrA,mbAddrB
// Decoding end_of_residual signal for 1 cycle duration
// 1)for nC_decoding to update general control regs such as Luma_8x8_AllZeroCoeff_mbAddrA,Luma_8x8_AllZeroCoeff_mbAddrB_reg,Chroma_8x8_AllZeroCoeff_mbAddrA,Chroma_8x8_AllZeroCoeff_mbAddrB_reg
// 2)Note:for P_skip MBs,their general control regs as *8x8_ALLZeroCoeff* are directly controlled by the state instead of end_of_residual signal
//-------------------------------------------------------------------------------------------------
// Revise log
// 1. March 24,2006
// Add signal end_of_NonZeroCoeff_CAVLC for IQIT to update res_AC/res_DC/... signals.
// end_of_NonZeroCoeff_CAVLC:combinational logic,active one cycle at the end of CAVLC decoding of one non zero coefficient residual.
// 2. March 29,2006
// Add signal lumaDC_IsAllZero,ChromaDC_Cb_IsAllZero,ChromaDC_Cr_IsAllZero to deal with special case:zero DC coeff,but non-zero AC coeff
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module end_of_blk_decoding (reset_n,cavlc_decoder_state,
	TotalCoeff,i_TotalCoeff,end_of_one_residual_block,end_of_NonZeroCoeff_CAVLC
   	);
	input reset_n;
	input [3:0] cavlc_decoder_state;
	input [4:0] TotalCoeff;
	input [3:0] i_TotalCoeff;
	output end_of_one_residual_block;
	output end_of_NonZeroCoeff_CAVLC;
	
	reg end_of_one_residual_block;
	reg end_of_NonZeroCoeff_CAVLC;
	reg lumaDC_IsAllZero;
	reg ChromaDC_Cb_IsAllZero;
	reg ChromaDC_Cr_IsAllZero;
		
	always @ (reset_n or cavlc_decoder_state or TotalCoeff or i_TotalCoeff)
		if (reset_n == 0)
			end_of_one_residual_block <= 0;
		else if (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && TotalCoeff == 0)
			end_of_one_residual_block <= 1;
		else if (cavlc_decoder_state == `LevelRunCombination && i_TotalCoeff == 0)
			end_of_one_residual_block <= 1;
		else
			end_of_one_residual_block <= 0;
			
	always @ (reset_n or cavlc_decoder_state or i_TotalCoeff)
		if (reset_n == 0)
			end_of_NonZeroCoeff_CAVLC <= 0;
		else if (cavlc_decoder_state == `LevelRunCombination && i_TotalCoeff == 0)
			end_of_NonZeroCoeff_CAVLC <= 1;
		else
			end_of_NonZeroCoeff_CAVLC <= 0;		
			      		
endmodule