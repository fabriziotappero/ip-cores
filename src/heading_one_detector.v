//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : heading_one_detector.v
// Generated : June 6, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Priority based heading one detection
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module heading_one_detector (heading_one_en,BitStream_buffer_output,heading_one_pos);
	input heading_one_en;
	input [15:0] BitStream_buffer_output;
	output [3:0] heading_one_pos;
	reg [3:0] heading_one_pos;
	
	always @ (heading_one_en or BitStream_buffer_output) 
		if (heading_one_en == 1'b0)
			begin
				if (BitStream_buffer_output[15] == 1'b1 || BitStream_buffer_output[14] == 1'b1)
					begin
						if (BitStream_buffer_output[15] == 1'b1)	heading_one_pos <= 0;
						else                                      heading_one_pos <= 4'd1; 
					end
				else if (BitStream_buffer_output[13] == 1'b1 || BitStream_buffer_output[12] == 1'b1 || 
                 BitStream_buffer_output[11] == 1'b1 || BitStream_buffer_output[10] == 1'b1)
					begin
						if      (BitStream_buffer_output[13] == 1'b1)	heading_one_pos <= 4'd2;
						else if (BitStream_buffer_output[12] == 1'b1)	heading_one_pos <= 4'd3;
						else if (BitStream_buffer_output[11] == 1'b1)	heading_one_pos <= 4'd4;
						else                                          heading_one_pos <= 4'd5;
					end
				else
					begin
						if      (BitStream_buffer_output[9] == 1'b1)	heading_one_pos <= 4'd6;
						else if (BitStream_buffer_output[8] == 1'b1)	heading_one_pos <= 4'd7;
						else if (BitStream_buffer_output[7] == 1'b1)	heading_one_pos <= 4'd8;
						else if (BitStream_buffer_output[6] == 1'b1)	heading_one_pos <= 4'd9;
						else if (BitStream_buffer_output[5] == 1'b1)	heading_one_pos <= 4'd10; 
						else if (BitStream_buffer_output[4] == 1'b1)	heading_one_pos <= 4'd11;
						else if (BitStream_buffer_output[3] == 1'b1)	heading_one_pos <= 4'd12;
						else if (BitStream_buffer_output[2] == 1'b1)	heading_one_pos <= 4'd13;
						else if (BitStream_buffer_output[1] == 1'b1)	heading_one_pos <= 4'd14;
						else                                          heading_one_pos <= 4'd15;
					end
			end
		else
			heading_one_pos <= 0;
endmodule
			
		
					
						