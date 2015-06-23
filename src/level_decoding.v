//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : level_decoding.v
// Generated : June 9, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Devive the level_prefix,level_suffix,suffixLength,levelSuffixSize,levelCode
// In systemC,levelSuffixSize is decoded @LevelPrefix,in RTL,now changed to @LevelSuffix
// level_suffix[7:0],levelCode[7:0],level[8:0]
// 1. level_abs_tmp[8:0]:|levelCode+2| or |-levelCode-1|                                   | reg
// 2. level_abs    [7:0]:level_abs_tmp >> 1 and latched, used for suffixLength calculation | wire
// 3. level_tmp    [8:0]:2's complement, equals (levelCode+2)>>1 or (-levelCode-1)>>1      | wire
// 4. level_0 ~ level_15:According to i_level,level_tmp is assigned to level_[i_level]     | reg
//    level_0 ~ level_15 are 2's complement
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module level_decoding (clk,reset_n,cavlc_decoder_state,heading_one_pos,suffix_length_initialized,i_level,
	TotalCoeff,TrailingOnes,BitStream_buffer_output,
	levelSuffixSize,
	level_0,level_1,level_2, level_3, level_4, level_5, level_6, level_7,
	level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15);
	input clk,reset_n;
	input [3:0] cavlc_decoder_state; 
	input [3:0] heading_one_pos;
	input suffix_length_initialized;
	input [3:0] i_level;
	input [4:0] TotalCoeff;
	input [1:0] TrailingOnes;
	input [15:0] BitStream_buffer_output;
	output [3:0] levelSuffixSize;
	output [8:0] level_0,level_1,level_2,level_3,level_4,level_5,level_6,level_7;
	output [8:0] level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15;
	
	reg [3:0] levelSuffixSize;
	reg [8:0] level_0,level_1,level_2,level_3,level_4,level_5,level_6,level_7;
	reg [8:0] level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15;
	
	reg [3:0] level_prefix;
	reg [3:0] suffixLength;
	reg [11:0] level_suffix;
	reg [8:0] levelCode;
	reg [8:0] level_tmp;
	reg [7:0] level_abs;
	
	wire [8:0] levelCode_tmp;
	
	//@LevelPrefix,latch the result
	always @ (posedge clk)
		if (reset_n == 0)
			level_prefix <= 0;
		else if (cavlc_decoder_state == `LevelPrefix)
			level_prefix <= heading_one_pos;
	//@LevelPrefix,latch the result		
	always @ (posedge clk)
		if (reset_n == 0)
			suffixLength <= 0;
		else if (cavlc_decoder_state == `LevelPrefix)
			begin
				if (suffix_length_initialized == 1'b0)
					suffixLength <= (TotalCoeff > 10 && TrailingOnes < 3)? 4'd1:4'd0;
				//Revise log:March 26,2006
				//else if (suffixLength == 0 && ((level_abs > (8'd3 << (suffixLength - 1))) && suffixLength < 6))
				else if (suffixLength == 0 && level_abs > 8'd3)
					suffixLength <= 4'd2;
				else if (suffixLength == 0)
					suffixLength <= 4'd1;
				else if ((level_abs > (8'd3 << (suffixLength - 1))) && suffixLength < 6)
					suffixLength <= suffixLength + 1;
			end
	//@LevelSuffix,temporary result
	always @ (cavlc_decoder_state or level_prefix or suffixLength)
		if (cavlc_decoder_state == `LevelSuffix)
			begin
				if (level_prefix == 14 && suffixLength == 0)
					levelSuffixSize <= 4;
				else if (level_prefix == 4'd15)
					levelSuffixSize <= 4'd12;
				else 
					levelSuffixSize <= suffixLength;
			end
		else
			levelSuffixSize <= 0;
	//@LevelSuffix,temporay result
	always	@ (cavlc_decoder_state or levelSuffixSize or BitStream_buffer_output)
		if (cavlc_decoder_state == `LevelSuffix)
			begin
				if (levelSuffixSize == 0)
					level_suffix <= 0;
				else
					case (levelSuffixSize)
						1 :level_suffix <= {11'b0,BitStream_buffer_output[15]};
						2 :level_suffix <= {10'b0,BitStream_buffer_output[15:14]};
						3 :level_suffix <= {9'b0,BitStream_buffer_output[15:13]};
						4 :level_suffix <= {8'b0,BitStream_buffer_output[15:12]};
						5 :level_suffix <= {7'b0,BitStream_buffer_output[15:11]};
						6 :level_suffix <= {6'b0,BitStream_buffer_output[15:10]};
						7 :level_suffix <= {5'b0,BitStream_buffer_output[15:9]};
						8 :level_suffix <= {4'b0,BitStream_buffer_output[15:8]};
						9 :level_suffix <= {3'b0,BitStream_buffer_output[15:7]};
						10:level_suffix <= {2'b0,BitStream_buffer_output[15:6]};
						11:level_suffix <= {1'b0,BitStream_buffer_output[15:5]};
						12:level_suffix <= BitStream_buffer_output[15:4];
						default:level_suffix <= 0;
					endcase
			end
		else
			level_suffix <= 0;
	
	assign levelCode_tmp = (cavlc_decoder_state == `LevelSuffix)? ((level_prefix << suffixLength) + level_suffix):0;
	
	always @ (cavlc_decoder_state or level_prefix or suffixLength or i_level or TrailingOnes or levelCode_tmp)
		if (cavlc_decoder_state == `LevelSuffix)
			begin
				if (level_prefix == 15 && suffixLength == 0 && i_level == {2'b0,TrailingOnes} && TrailingOnes < 3)
					levelCode <= levelCode_tmp + 17;
				else if (level_prefix == 15 && suffixLength == 0)
					levelCode <= levelCode_tmp + 15;
				else if (i_level == {2'b0,TrailingOnes} && TrailingOnes < 3)
					levelCode <= levelCode_tmp + 2;
				else 
					levelCode <= levelCode_tmp;
			end
		else
			levelCode <= 0;	
	//We need an additional "level_abs" signal here in order to upgrade suffixLength for next codeword,but for 
	//trailingones,no need to do so since abs(+1/-1) will never greater than (3<<(suffixLength-1)).
	
	//level_abs_tmp:absolute value of level
	reg [8:0] level_abs_tmp;
	always @ (cavlc_decoder_state or levelCode)
	   if (cavlc_decoder_state == `LevelSuffix)
			begin 
				if (levelCode[0] == 1'b0) //even
					level_abs_tmp <= levelCode + 2;
				else
					level_abs_tmp <= levelCode + 1;
			end
		else
			level_abs_tmp <= 0;
	
	//level_abs:latched absolute value of level,for upgrading of suffixLength
	always @ (posedge clk)
		if (reset_n == 0)
			level_abs <= 0;
		else if (cavlc_decoder_state == `LevelSuffix)
			level_abs <= level_abs_tmp[8:1];
			
	always @ (cavlc_decoder_state or levelCode or level_abs_tmp)
		if (cavlc_decoder_state == `LevelSuffix)
			begin 
				if (levelCode[0] == 1'b0) //even
					level_tmp <= {1'b0,level_abs_tmp[8:1]};
				else
					level_tmp <= {1'b1,~levelCode[8:1]};
			end
		else
			level_tmp <= 0;
	
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				level_0 <= 0;	level_1 <= 0;	level_2 <= 0;	level_3 <= 0;
				level_4 <= 0;	level_5 <= 0;	level_6 <= 0;	level_7 <= 0;
				level_8 <= 0;	level_9 <= 0;	level_10<= 0;	level_11<= 0;
				level_12<= 0;	level_13<= 0;	level_14<= 0;	level_15<= 0;
			end
		else if (cavlc_decoder_state == `TrailingOnesSignFlag)
			begin
				level_0 <= (BitStream_buffer_output[15] == 0)? 9'b000000001:9'b111111111;
				if (TrailingOnes > 1)
					level_1 <= (BitStream_buffer_output[14] == 0)? 9'b000000001:9'b111111111;
				if (TrailingOnes == 3)
					level_2 <= (BitStream_buffer_output[13] == 0)? 9'b000000001:9'b111111111;
			end
		else if (cavlc_decoder_state == `LevelSuffix)
			case (i_level)
				0 :level_0 <= level_tmp;
				1 :level_1 <= level_tmp;
				2 :level_2 <= level_tmp;
				3 :level_3 <= level_tmp;
				4 :level_4 <= level_tmp;
				5 :level_5 <= level_tmp;
				6 :level_6 <= level_tmp;
				7 :level_7 <= level_tmp;
				8 :level_8 <= level_tmp;
				9 :level_9 <= level_tmp;
				10:level_10<= level_tmp;
				11:level_11<= level_tmp;
				12:level_12<= level_tmp;
				13:level_13<= level_tmp;
				14:level_14<= level_tmp;
				15:level_15<= level_tmp;
			endcase
endmodule					
		

			
	
