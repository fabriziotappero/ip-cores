//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : CodedBlockPattern_decoding.v
// Generated : June 5,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding CodedBlockPatternLuma & CodedBlockPatternChroma (Table9-4 Page156 of H.264/AVC standard 2003)
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module CodedBlockPattern_decoding (clk,reset_n,slice_data_state,slice_type,mb_type,mb_type_general,
	exp_golomb_decoding_output_5to0,CodedBlockPatternLuma,CodedBlockPatternChroma);
	input clk,reset_n;
	input [3:0] slice_data_state;
	input [2:0] slice_type;
	input [4:0] mb_type;
	input [3:0] mb_type_general;
	input [5:0] exp_golomb_decoding_output_5to0;
	output [3:0] CodedBlockPatternLuma;
	output [1:0] CodedBlockPatternChroma;
	reg [3:0] CodedBlockPatternLuma;
	reg [1:0] CodedBlockPatternChroma;
	
	reg [3:0] CodedBlockPatternLuma_reg;
	reg [1:0] CodedBlockPatternChroma_reg;
	
	always @ (posedge clk)
		CodedBlockPatternLuma_reg <= (reset_n == 0)? 0:CodedBlockPatternLuma;
	always @ (posedge clk)
		CodedBlockPatternChroma_reg <= (reset_n == 0)? 0:CodedBlockPatternChroma; 
	
	always @ (slice_data_state or mb_type_general or slice_type or mb_type or exp_golomb_decoding_output_5to0
		or CodedBlockPatternLuma_reg)
		if (mb_type_general[3:2] == 2'b10)//Intra16x16
			begin
				if (slice_type == 0 || slice_type == 5) //P_slice
					CodedBlockPatternLuma <= (mb_type < 18)? 4'd0:4'd15;
				else	//I_slice
					CodedBlockPatternLuma <= (mb_type < 13)? 4'd0:4'd15;
			end
		else if (slice_data_state == `coded_block_pattern_s)
			case (mb_type_general[3])
				1'b0:	//Inter
				if (exp_golomb_decoding_output_5to0 < 2)	//CBP = 0,16
					CodedBlockPatternLuma <= 0;
				else if (exp_golomb_decoding_output_5to0 < 6) //CBP =1,2,4,8
					case (exp_golomb_decoding_output_5to0[2:0])
						3'b010:CodedBlockPatternLuma <= 4'd1;
						3'b011:CodedBlockPatternLuma <= 4'd2;
						3'b100:CodedBlockPatternLuma <= 4'd4;
						3'b101:CodedBlockPatternLuma <= 4'd8;
						default:CodedBlockPatternLuma <= CodedBlockPatternLuma_reg;
					endcase
				else
					case (exp_golomb_decoding_output_5to0)
						6       :CodedBlockPatternLuma <= 4'd0;
						24,32   :CodedBlockPatternLuma <= 4'd1;
						25,33   :CodedBlockPatternLuma <= 4'd2;
						7,20,36 :CodedBlockPatternLuma <= 4'd3;
						26,34   :CodedBlockPatternLuma <= 4'd4;
						8,21,37 :CodedBlockPatternLuma <= 4'd5;
						17,44,46:CodedBlockPatternLuma <= 4'd6;
						13,28,40:CodedBlockPatternLuma <= 4'd7;
						27,35   :CodedBlockPatternLuma <= 4'd8;
						18,45,47:CodedBlockPatternLuma <= 4'd9;
						9,22,38 :CodedBlockPatternLuma <= 4'd10;
						14,29,41:CodedBlockPatternLuma <= 4'd11;
						10,23,39:CodedBlockPatternLuma <= 4'd12;
						15,30,42:CodedBlockPatternLuma <= 4'd13;
						16,31,43:CodedBlockPatternLuma <= 4'd14;
						11,12,19:CodedBlockPatternLuma <= 4'd15;
						default :CodedBlockPatternLuma <= CodedBlockPatternLuma_reg;
					endcase
				1'b1:	//Intra4x4
				if (exp_golomb_decoding_output_5to0 < 3)	//CBP = 47,31,15
					CodedBlockPatternLuma <= 4'd15;
				else 
					case (exp_golomb_decoding_output_5to0)
						3,16,41 :CodedBlockPatternLuma <= 4'd0;
						29,33,42:CodedBlockPatternLuma <= 4'd1;
						30,34,43:CodedBlockPatternLuma <= 4'd2;
						17,21,25:CodedBlockPatternLuma <= 4'd3;
						31,35,44:CodedBlockPatternLuma <= 4'd4;
						18,22,26:CodedBlockPatternLuma <= 4'd5;
						37,39,46:CodedBlockPatternLuma <= 4'd6;
						4,8,12  :CodedBlockPatternLuma <= 4'd7;
						32,36,45:CodedBlockPatternLuma <= 4'd8;
						38,40,47:CodedBlockPatternLuma <= 4'd9;
						19,23,27:CodedBlockPatternLuma <= 4'd10;
						5,9,13  :CodedBlockPatternLuma <= 4'd11;
						20,24,28:CodedBlockPatternLuma <= 4'd12;
						6,10,14 :CodedBlockPatternLuma <= 4'd13;
						7,11,15 :CodedBlockPatternLuma <= 4'd14;
						default :CodedBlockPatternLuma <= CodedBlockPatternLuma_reg;
					endcase
			endcase
		else
			CodedBlockPatternLuma <= CodedBlockPatternLuma_reg;
			
	
	always @ (slice_data_state or mb_type_general or exp_golomb_decoding_output_5to0 or CodedBlockPatternChroma_reg)
		if (mb_type_general[3:2] == 2'b10)//Intra16x16
			CodedBlockPatternChroma <= mb_type_general[1:0];
		else if (slice_data_state == `coded_block_pattern_s)
			case (mb_type_general[3])
				1'b0:	//Inter	
				if (exp_golomb_decoding_output_5to0 < 2)	//CBP = 0,16
					CodedBlockPatternChroma <= {1'b0,exp_golomb_decoding_output_5to0[0]};
				else if (exp_golomb_decoding_output_5to0 < 6) //CBP =1,2,4,8
					CodedBlockPatternChroma <= 2'd0;
				else
					case (exp_golomb_decoding_output_5to0)
						7,8,9,10,11,13,14,15,16,17,18               :CodedBlockPatternChroma <= 2'd0;
						19,32,33,34,35,36,37,38,39,40,41,42,43,44,45:CodedBlockPatternChroma <= 2'd1;
						default                                     :CodedBlockPatternChroma <= 2'd2;
					endcase
				1'b1:	//Intra4x4
				if (exp_golomb_decoding_output_5to0 < 3)	//CBP = 47,31,15
					case (exp_golomb_decoding_output_5to0[1:0])
						2'b00  :CodedBlockPatternChroma <= 2'd2;
						2'b01  :CodedBlockPatternChroma <= 2'd1;
						default:CodedBlockPatternChroma <= 2'd0;
					endcase
				else 
					case (exp_golomb_decoding_output_5to0)
						3,8,9,10,11,17,18,19,20,29,30,31,32,37,38:CodedBlockPatternChroma <= 2'd0;
						4,5,6,7,16,21,22,23,24,33,34,35,36,39,40 :CodedBlockPatternChroma <= 2'd1;
						default									 :CodedBlockPatternChroma <= 2'd2;
					endcase
			endcase
		else
			CodedBlockPatternChroma <= CodedBlockPatternChroma_reg;
			
endmodule
						
				
				
		
		
					
						
						
					
				
				
						
							
					
			
			