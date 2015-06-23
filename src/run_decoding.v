//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : run_decoding.v
// Generated : June 11, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding the all the remaining syntax for CAVLC
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module run_decoding (clk,reset_n,cavlc_decoder_state,BitStream_buffer_output,total_zeros,
	level_0,level_1,level_2,level_3,level_4,level_5,level_6,level_7,
	level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15,
	TotalCoeff,i_run,i_TotalCoeff,coeffNum,IsRunLoop,
	
	run_of_zeros_len,zerosLeft,run,
	coeffLevel_0,coeffLevel_1,coeffLevel_2, coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6, coeffLevel_7,
	coeffLevel_8,coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13,coeffLevel_14,coeffLevel_15);
	input clk,reset_n;
	input [3:0] cavlc_decoder_state;
	input [15:0] BitStream_buffer_output;
	input [3:0] total_zeros;
	input [8:0] level_0,level_1,level_2,level_3,level_4,level_5,level_6,level_7;
	input [8:0] level_8,level_9,level_10,level_11,level_12,level_13,level_14,level_15;
	input [4:0] TotalCoeff;
	input [3:0] i_run;
	input [3:0] i_TotalCoeff;
	input [3:0] coeffNum;
	input IsRunLoop;
	output [3:0] run_of_zeros_len;
	output [3:0] zerosLeft;
	output [3:0] run;
	output [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6;
	output [8:0] coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13;
	output [8:0] coeffLevel_14,coeffLevel_15;
	
	reg [3:0] run_of_zeros_len;
	reg [3:0] zerosLeft;
	reg [3:0] run;
	reg [8:0] coeffLevel_0, coeffLevel_1, coeffLevel_2,coeffLevel_3, coeffLevel_4, coeffLevel_5, coeffLevel_6;
	reg [8:0] coeffLevel_7, coeffLevel_8, coeffLevel_9,coeffLevel_10,coeffLevel_11,coeffLevel_12,coeffLevel_13;
	reg [8:0] coeffLevel_14,coeffLevel_15;
	
	reg [3:0] run_before;
	reg [3:0] zerosLeft_reg;
	reg [3:0] run_0,run_1,run_2,run_3,run_4,run_5,run_6,run_7;
	reg [3:0] run_8,run_9,run_10,run_11,run_12,run_13,run_14,run_15;
	reg [8:0] level_output;
	
	//decoding Table 9-10
	always @ (cavlc_decoder_state or zerosLeft or BitStream_buffer_output) 
		if (cavlc_decoder_state == `run_before_LUT)
			case (zerosLeft)
				0:run_of_zeros_len <= 0;//special case added for "total_zeros==0"
				1:run_of_zeros_len <= 1;
				2:run_of_zeros_len <= (BitStream_buffer_output[15] == 1)? 4'd1:4'd2;
				3:run_of_zeros_len <= 2;
				4:run_of_zeros_len <= (BitStream_buffer_output[15:14] == 2'b00)? 4'd3:4'd2;
				5:run_of_zeros_len <= (BitStream_buffer_output[15] == 1)? 4'd2:4'd3;
				6:run_of_zeros_len <= (BitStream_buffer_output[15:14] == 2'b11)? 4'd2:4'd3;
				default:
				if (BitStream_buffer_output[15] == 1 || BitStream_buffer_output[14] == 1 || BitStream_buffer_output[13] == 1)			
                                                      run_of_zeros_len <= 3;
				else if (BitStream_buffer_output[15:12] == 1)	run_of_zeros_len <= 4;
				else if (BitStream_buffer_output[15:11] == 1)	run_of_zeros_len <= 5;
				else if (BitStream_buffer_output[15:10] == 1)	run_of_zeros_len <= 6;
				else if (BitStream_buffer_output[15:9]  == 1)	run_of_zeros_len <= 7;
				else if (BitStream_buffer_output[15:8]  == 1)	run_of_zeros_len <= 4'd8;
				else if (BitStream_buffer_output[15:7]  == 1)	run_of_zeros_len <= 4'd9;
				else if (BitStream_buffer_output[15:6]  == 1)	run_of_zeros_len <= 4'd10;
				else if (BitStream_buffer_output[15:5]  == 1)	run_of_zeros_len <= 4'd11;
				else                                          run_of_zeros_len <= 0;
			endcase
		else
			run_of_zeros_len <= 0; 
			
	always @ (posedge clk)
		if (reset_n == 0)
			run_before <= 0;
		else if (cavlc_decoder_state == `run_before_LUT)
			case (zerosLeft)
				0:run_before <= 0;//special case added for "total_zeros==0"
				1:run_before <= (BitStream_buffer_output[15] == 0)? 4'd1:4'd0;
				2:if      (BitStream_buffer_output[15] == 1)        run_before <= 0;					
				  else if (BitStream_buffer_output[15:14] == 2'b01)	run_before <= 1;
				  else                                              run_before <= 2;	
				3:case (BitStream_buffer_output[15:14])
					2'b00:run_before <= 3;
					2'b01:run_before <= 2;
					2'b10:run_before <= 1;
					2'b11:run_before <= 0;
				  endcase
				4:case (BitStream_buffer_output[15:14])
					2'b00:run_before <= (BitStream_buffer_output[13] == 1)? 4'd3:4'd4;
					2'b01:run_before <= 2;
					2'b10:run_before <= 1;
					2'b11:run_before <= 0;
				  endcase
				5:case (BitStream_buffer_output[15:14])
					2'b00:run_before <= (BitStream_buffer_output[13] == 1)? 4'd4:4'd5;
					2'b01:run_before <= (BitStream_buffer_output[13] == 1)? 4'd2:4'd3;
					2'b10:run_before <= 1;
					2'b11:run_before <= 0;
				  endcase
				6:casex (BitStream_buffer_output[15:13])
					3'b11x:run_before <= 0;
					3'b000:run_before <= 1;
					3'b001:run_before <= 2;
					3'b011:run_before <= 3;
					3'b010:run_before <= 4;
					3'b101:run_before <= 5;
					3'b100:run_before <= 6;
				  endcase
				default:
				case (BitStream_buffer_output[15:13])
					3'b000:run_before <= run_of_zeros_len + 3;
					3'b111:run_before <= 0;
					3'b110:run_before <= 1;
					3'b101:run_before <= 2;
					3'b100:run_before <= 3;
					3'b011:run_before <= 4;
					3'b010:run_before <= 5;
					3'b001:run_before <= 6;
				endcase
			endcase
			
	always @ (cavlc_decoder_state or total_zeros or run_before or zerosLeft_reg or IsRunLoop)
		if (cavlc_decoder_state == `run_before_LUT)
			zerosLeft <= (IsRunLoop == 0)? total_zeros:zerosLeft_reg; 
		else if (cavlc_decoder_state == `RunOfZeros)
			zerosLeft <= zerosLeft_reg - run_before;
		else 
			zerosLeft <= 0;
			
	always @ (posedge clk)
		if (reset_n == 0)
			zerosLeft_reg <= 0;
		else if (cavlc_decoder_state == `run_before_LUT || cavlc_decoder_state == `RunOfZeros)
			zerosLeft_reg <= zerosLeft;
	
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				run_0  <= 0;	run_1  <= 0;	run_2  <= 0;	run_3  <= 0;	
				run_4  <= 0;	run_5  <= 0;	run_6  <= 0;	run_7  <= 0;
				run_8  <= 0;	run_9  <= 0;	run_10 <= 0;	run_11 <= 0;
				run_12 <= 0;	run_13 <= 0;	run_14 <= 0;	run_15 <= 0;
			end
		//reset run0 ~ run15 for each 4x4 CAVLC as early as nAnB_decoding_s stage
		else if (cavlc_decoder_state == `nAnB_decoding_s)
		   begin
				run_0  <= 0;	run_1  <= 0;	run_2  <= 0;	run_3  <= 0;	
				run_4  <= 0;	run_5  <= 0;	run_6  <= 0;	run_7  <= 0;
				run_8  <= 0;	run_9  <= 0;	run_10 <= 0;	run_11 <= 0;
				run_12 <= 0;	run_13 <= 0;	run_14 <= 0;	run_15 <= 0;
			end
		else if (cavlc_decoder_state == `RunOfZeros)
			begin
				if (TotalCoeff == 1)
					run_0 <= total_zeros;
				else if (total_zeros == 0)
					begin
						run_0  <= 0;	run_1  <= 0;	run_2  <= 0;	run_3  <= 0;	
						run_4  <= 0;	run_5  <= 0;	run_6  <= 0;	run_7  <= 0;
						run_8  <= 0;	run_9  <= 0;	run_10 <= 0;	run_11 <= 0;
						run_12 <= 0;	run_13 <= 0;	run_14 <= 0;	run_15 <= 0;
					end
				else if ({1'b0,i_run} == TotalCoeff - 2)
					case (i_run)
						0 :begin	run_0 <= run_before;	run_1 <= zerosLeft;	end
						1 :begin	run_1 <= run_before;	run_2 <= zerosLeft;	end
						2 :begin	run_2 <= run_before;	run_3 <= zerosLeft;	end
						3 :begin	run_3 <= run_before;	run_4 <= zerosLeft;	end
						4 :begin	run_4 <= run_before;	run_5 <= zerosLeft;	end
						5 :begin	run_5 <= run_before;	run_6 <= zerosLeft;	end
						6 :begin	run_6 <= run_before;	run_7 <= zerosLeft;	end
						7 :begin	run_7 <= run_before;	run_8 <= zerosLeft;	end
						8 :begin	run_8 <= run_before;	run_9 <= zerosLeft;	end
						9 :begin	run_9 <= run_before;	run_10<= zerosLeft;	end
						10:begin	run_10<= run_before;	run_11<= zerosLeft;	end
						11:begin	run_11<= run_before;	run_12<= zerosLeft;	end
						12:begin	run_12<= run_before;	run_13<= zerosLeft;	end
						13:begin	run_13<= run_before;	run_14<= zerosLeft;	end
					endcase
				else
					case (i_run)
						0 :run_0 <= run_before;
						1 :run_1 <= run_before;
						2 :run_2 <= run_before;
						3 :run_3 <= run_before;
						4 :run_4 <= run_before;
						5 :run_5 <= run_before;
						6 :run_6 <= run_before;
						7 :run_7 <= run_before;
						8 :run_8 <= run_before;
						9 :run_9 <= run_before;
						10:run_10<= run_before;
						11:run_11<= run_before;
						12:run_12<= run_before; 
						13:run_13<= run_before;
					endcase
			end
	always @ (cavlc_decoder_state or i_TotalCoeff or run_0 or run_1 or run_2 or run_3 or run_4 or 
		run_5 or run_6 or run_7 or run_8 or run_9 or run_10 or run_11 or run_12 or run_13 or run_14)
		if (cavlc_decoder_state == `LevelRunCombination)
			case (i_TotalCoeff)		//coeffNum = coeffNum + run[i_TotalCoeff-1] + 1;
				0 :run <= run_0;
				1 :run <= run_1;
				2 :run <= run_2;
				3 :run <= run_3;
				4 :run <= run_4;
				5 :run <= run_5;
				6 :run <= run_6;
				7 :run <= run_7;
				8 :run <= run_8;
				9 :run <= run_9;
				10:run <= run_10;
				11:run <= run_11;
				12:run <= run_12;
				13:run <= run_13;
				14:run <= run_14;
				default:run <= 0;
			endcase
		else
			run <= 0;
		
	always @ (i_TotalCoeff or level_0 or level_1 or level_2 or level_3 or level_4 or level_5 or level_6 or 
		level_7 or level_8 or level_9 or level_10 or level_11 or level_12 or level_13 or level_14 or level_15)
		case (i_TotalCoeff)
			0 :level_output <= level_0;
			1 :level_output <= level_1;
			2 :level_output <= level_2;
			3 :level_output <= level_3;
			4 :level_output <= level_4;
			5 :level_output <= level_5;
			6 :level_output <= level_6;
			7 :level_output <= level_7;
			8 :level_output <= level_8;
			9 :level_output <= level_9;
			10:level_output <= level_10;
			11:level_output <= level_11;
			12:level_output <= level_12;
			13:level_output <= level_13;
			14:level_output <= level_14;
			15:level_output <= level_15;
		endcase
	
			
	always @ (posedge clk)
		if (reset_n == 0)
			begin
				coeffLevel_0  <= 0;	coeffLevel_1  <= 0;	coeffLevel_2  <= 0;	coeffLevel_3  <= 0;	
				coeffLevel_4  <= 0;	coeffLevel_5  <= 0;	coeffLevel_6  <= 0;	coeffLevel_7  <= 0;
				coeffLevel_8  <= 0;	coeffLevel_9  <= 0;	coeffLevel_10 <= 0;	coeffLevel_11 <= 0;
				coeffLevel_12 <= 0;	coeffLevel_13 <= 0;	coeffLevel_14 <= 0;	coeffLevel_15 <= 0;
			end
		//Revise log: March 24,2006
		//change reset coeffLevel_0 ~ 14 at total_zeros_LUT stage
		//else if (cavlc_decoder_state == RunOfZeros &&		//reset coeffLevel_0 ~ 14 only at last RunOfZeros 
		//	(i_run == TotalCoeff - 1 || i_run == TotalCoeff - 2 || zerosLeft == 0)) 
		else if (cavlc_decoder_state == `total_zeros_LUT)
			begin
				coeffLevel_0  <= 0;	coeffLevel_1  <= 0;	coeffLevel_2  <= 0;	coeffLevel_3  <= 0;	
				coeffLevel_4  <= 0;	coeffLevel_5  <= 0;	coeffLevel_6  <= 0;	coeffLevel_7  <= 0;
				coeffLevel_8  <= 0;	coeffLevel_9  <= 0;	coeffLevel_10 <= 0;	coeffLevel_11 <= 0;
				coeffLevel_12 <= 0;	coeffLevel_13 <= 0;	coeffLevel_14 <= 0;	coeffLevel_15 <= 0;
			end
		else if (cavlc_decoder_state == `LevelRunCombination)
			begin
				case (coeffNum)
					0 :coeffLevel_0 <= level_output;
					1 :coeffLevel_1 <= level_output;
					2 :coeffLevel_2 <= level_output;
					3 :coeffLevel_3 <= level_output; 
					4 :coeffLevel_4 <= level_output;
					5 :coeffLevel_5 <= level_output;
					6 :coeffLevel_6 <= level_output;
					7 :coeffLevel_7 <= level_output;
					8 :coeffLevel_8 <= level_output;
					9 :coeffLevel_9 <= level_output;
					10:coeffLevel_10<= level_output;
					11:coeffLevel_11<= level_output;
					12:coeffLevel_12<= level_output;
					13:coeffLevel_13<= level_output;
					14:coeffLevel_14<= level_output;
					15:coeffLevel_15<= level_output;
				endcase
			end
	endmodule

			
	