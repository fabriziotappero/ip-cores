//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : dependent_variable_decoding.v
// Generated : June 6,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// for u(v) decoding as frame_num,pic_order_cnt_lsb
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module dependent_variable_decoding (slice_header_state,log2_max_frame_num_minus4,
	log2_max_pic_order_cnt_lsb_minus4,BitStream_buffer_output,
	dependent_variable_len,dependent_variable_decoding_output);
	input [3:0] slice_header_state;
	input [3:0] log2_max_frame_num_minus4;
	input [3:0] log2_max_pic_order_cnt_lsb_minus4;
	input [15:0] BitStream_buffer_output;
	output [3:0] dependent_variable_len;
	output [9:0] dependent_variable_decoding_output;
	reg [3:0] dependent_variable_len;
	reg [9:0] dependent_variable_decoding_output;
		
	always @ (slice_header_state or log2_max_frame_num_minus4 or log2_max_pic_order_cnt_lsb_minus4)
		if (slice_header_state == `frame_num_s)
			dependent_variable_len <= log2_max_frame_num_minus4 + 4;
		else if (slice_header_state == `pic_order_cnt_lsb_s)
			dependent_variable_len <= log2_max_pic_order_cnt_lsb_minus4 + 4;
		else
			dependent_variable_len <= 0;
	
	always @ (slice_header_state or dependent_variable_len or BitStream_buffer_output) 
		if (slice_header_state == `frame_num_s || slice_header_state == `pic_order_cnt_lsb_s)
			case (dependent_variable_len)
				4 :dependent_variable_decoding_output <= {6'b0,BitStream_buffer_output[15:12]};
				5 :dependent_variable_decoding_output <= {5'b0,BitStream_buffer_output[15:11]};
				6 :dependent_variable_decoding_output <= {4'b0,BitStream_buffer_output[15:10]};
				7 :dependent_variable_decoding_output <= {3'b0,BitStream_buffer_output[15:9]};
				8 :dependent_variable_decoding_output <= {2'b0,BitStream_buffer_output[15:8]};
				9 :dependent_variable_decoding_output <= {1'b0,BitStream_buffer_output[15:7]};
				10:dependent_variable_decoding_output <= BitStream_buffer_output[15:6];
				default:dependent_variable_decoding_output <= 0;
			endcase
		else
			dependent_variable_decoding_output <= 0;
endmodule
			
			
				
