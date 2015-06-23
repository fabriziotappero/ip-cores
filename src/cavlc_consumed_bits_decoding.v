//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : cavlc_consumed_bits_decoding.v
// Generated : June 12,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Calculate the consumed bit length of CAVLC decoder of each clock cycle
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module cavlc_consumed_bits_decoding (cavlc_decoder_state,NumCoeffTrailingOnes_len,TrailingOnes,
	heading_one_pos,levelSuffixSize,total_zeros_len,run_of_zeros_len,cavlc_consumed_bits_len); 
	input [3:0] cavlc_decoder_state;
	input [4:0] NumCoeffTrailingOnes_len;
	input [1:0] TrailingOnes;
	input [3:0] heading_one_pos;
	input [3:0] levelSuffixSize;
	input [3:0] total_zeros_len;
	input [3:0] run_of_zeros_len;
	output [4:0] cavlc_consumed_bits_len;
	reg [4:0] cavlc_consumed_bits_len;
	
	always @ (cavlc_decoder_state or NumCoeffTrailingOnes_len or TrailingOnes or heading_one_pos or 
		levelSuffixSize or total_zeros_len or run_of_zeros_len)
		case (cavlc_decoder_state)
			`NumCoeffTrailingOnes_LUT:cavlc_consumed_bits_len <= NumCoeffTrailingOnes_len;
			`TrailingOnesSignFlag    :cavlc_consumed_bits_len <= TrailingOnes;			 
			`LevelPrefix             :cavlc_consumed_bits_len <= heading_one_pos + 1;
			`LevelSuffix             :cavlc_consumed_bits_len <= levelSuffixSize;		 
			`total_zeros_LUT         :cavlc_consumed_bits_len <= total_zeros_len;		 
			`run_before_LUT			     :cavlc_consumed_bits_len <= run_of_zeros_len;		
			default					         :cavlc_consumed_bits_len <= 0;
		endcase
endmodule

