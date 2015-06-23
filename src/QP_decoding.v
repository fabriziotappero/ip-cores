//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : QP_decoding.v
// Generated : June 7, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// QPy:the luma quantisation parameter
// QPi:the intermediate quantisation parameter derived from QPy
// QPc:the chroma quantisation parameter derived from QPi on Table 8-13,Page136
//-------------------------------------------------------------------------------------------------
// Revise log  
// 1. March 21,2006
// Input signals slice_qp_delta and mb_qp_delta are removed, using 
// exp_golomb_decoding_output_5to0 instead since these two signals are latched at clock
// rising edge which is too late for computation. So use exp_golomb_decoding_output_5to0 directly
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module QP_decoding (clk,reset_n,slice_header_state,slice_data_state,pic_init_qp_minus26,
	exp_golomb_decoding_output_5to0,chroma_qp_index_offset,QPy,QPc); 
	input clk,reset_n;
	input [3:0] slice_header_state;
	input [3:0] slice_data_state;
	input [5:0] pic_init_qp_minus26;
	input [5:0] exp_golomb_decoding_output_5to0;
	input [4:0] chroma_qp_index_offset;
	output [5:0] QPy,QPc;
	reg [5:0] QPy,QPc;
	
	always @ (posedge clk)
		if (reset_n == 0)
			QPy <= 0;
		else if (slice_header_state == `slice_qp_delta_s)
			QPy <= 26 + pic_init_qp_minus26 + exp_golomb_decoding_output_5to0;
		else if (slice_data_state == `mb_qp_delta_s)
			QPy <= QPy + exp_golomb_decoding_output_5to0;
			
	wire [5:0] QPi;
	assign QPi = QPy + {1'b0,chroma_qp_index_offset};
	always @ (posedge clk)
		if (reset_n == 0)
			QPc <= 0;
		else
			begin
				if (QPi < 30)
					QPc <= QPi;
				else
					case (QPi)
						30      :QPc <= 29;
						31      :QPc <= 30;
						32      :QPc <= 31;
						33,34   :QPc <= 32;
						35      :QPc <= 33;
						36,37   :QPc <= 34;
						38,39   :QPc <= 35;
						40,41   :QPc <= 36;
						42,43,44:QPc <= 37;
						45,46,47:QPc <= 38;
						default :QPc <= 39;
					endcase
			end
endmodule
						