//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : total_zeros_decoding.v
// Generated : June 9, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding total_zeros from Table9-7,Table9-8,Table9-9 of H.264/AVC standard 2003
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module total_zeros_decoding (clk,reset_n,residual_state,cavlc_decoder_state,TotalCoeff_3to0,heading_one_pos,
	BitStream_buffer_output,maxNumCoeff,total_zeros,total_zeros_len);
	input clk,reset_n;
	input [3:0] residual_state;
	input [3:0] cavlc_decoder_state;
	input [3:0] TotalCoeff_3to0;
	input [3:0] heading_one_pos;
	input [15:0] BitStream_buffer_output;
	output [4:0] maxNumCoeff;
	output [3:0] total_zeros;
	output [3:0] total_zeros_len;
	reg [4:0] maxNumCoeff;
	reg [3:0] total_zeros;
	reg [3:0] total_zeros_len;
	
	reg [3:0] total_zeros_reg;
	always @ (posedge clk)
		if (reset_n == 0)
			maxNumCoeff <= 0;
		else
			case (residual_state)
				`Intra16x16DCLevel_s:maxNumCoeff <= 5'd16;
				`Intra16x16ACLevel_s:maxNumCoeff <= 15;
				`LumaLevel_s        :maxNumCoeff <= 5'd16;
				`ChromaDCLevel_Cb_s :maxNumCoeff <= 4;
				`ChromaDCLevel_Cr_s :maxNumCoeff <= 4;
				`ChromaACLevel_Cb_s :maxNumCoeff <= 15;
				`ChromaACLevel_Cr_s :maxNumCoeff <= 15;
			endcase	
			
	//total_zeros_len
	always @ (cavlc_decoder_state or maxNumCoeff or TotalCoeff_3to0 or heading_one_pos or BitStream_buffer_output) 
		if (cavlc_decoder_state == `total_zeros_LUT)
			begin
				if (maxNumCoeff == 4)
					case (TotalCoeff_3to0)
						1:if      (heading_one_pos == 0) total_zeros_len <= 1;
						  else if (heading_one_pos == 1) total_zeros_len <= 2;
						  else                           total_zeros_len <= 3;
						2:if      (heading_one_pos == 0) total_zeros_len <= 1;
						  else                           total_zeros_len <= 2;
						3:                               total_zeros_len <= 1;
						default:                         total_zeros_len <= 0;
					endcase
				else
					case (TotalCoeff_3to0)
						1:if      (heading_one_pos == 0)	total_zeros_len <= 1;
						  else if (heading_one_pos == 8)	total_zeros_len <= 4'd9;
						  else                            total_zeros_len <= heading_one_pos + 2;
						2:if      (heading_one_pos == 0)	total_zeros_len <= 4'd3;
						  else if (heading_one_pos == 1)	
							total_zeros_len <= (BitStream_buffer_output[13] == 1'b1)? 4'd3:4'd4;
						  else if (heading_one_pos == 2)	total_zeros_len <= 4;
						  else if (heading_one_pos == 3)	total_zeros_len <= 5;
						  else if (heading_one_pos == 4)	total_zeros_len <= 6;
						  else                            total_zeros_len <= 6;
						3:if      (heading_one_pos == 0)	total_zeros_len <= 4'd3;
						  else if (heading_one_pos == 1)
							total_zeros_len <= (BitStream_buffer_output[13] == 1'b1)? 4'd3:4'd4;
						  else if (heading_one_pos == 2)	total_zeros_len <= 4;
						  else if (heading_one_pos == 3)	total_zeros_len <= 5;
						  else if (heading_one_pos == 4)	total_zeros_len <= 5;
						  else                            total_zeros_len <= 4'd6;
						4:if      (heading_one_pos == 0)	total_zeros_len <= 3;
						  else if (heading_one_pos == 1) 
							total_zeros_len <= (BitStream_buffer_output[13] == 1'b1)? 4'd3:4'd4;
						  else if (heading_one_pos == 2)	total_zeros_len <= 4;
						  else if (heading_one_pos == 3)	total_zeros_len <= 5;
						  else                            total_zeros_len <= 5;
						5:if (heading_one_pos == 0)       total_zeros_len <= 4'd3;
						  else if (heading_one_pos == 1) 
							total_zeros_len <= (BitStream_buffer_output[13] == 1'b1)? 4'd3:4'd4;
						  else if (heading_one_pos == 2)	total_zeros_len <= 4;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else								total_zeros_len <= 5;
						6:if (heading_one_pos == 0 || heading_one_pos == 1 || heading_one_pos ==2)
                                              total_zeros_len <= 3;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else if (heading_one_pos == 4)	total_zeros_len <= 5;
		    			else                            total_zeros_len <= 6;
						7:if (heading_one_pos == 0 && BitStream_buffer_output[14] == 1)
                                              total_zeros_len <= 2;
						  else if (heading_one_pos == 0 || heading_one_pos == 1 || heading_one_pos == 2)
                                              total_zeros_len <= 3;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else if (heading_one_pos == 4)	total_zeros_len <= 5;
						  else                            total_zeros_len <= 6;
						8:if (heading_one_pos == 0)       total_zeros_len <= 2;
						  else if (heading_one_pos == 1 || heading_one_pos == 2)
							total_zeros_len <= 3;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else if (heading_one_pos == 4)	total_zeros_len <= 5;
						  else                            total_zeros_len <= 6;
						9:if (heading_one_pos == 0 || heading_one_pos == 1)
							total_zeros_len <= 2;
						  else if (heading_one_pos == 2)	total_zeros_len <= 3;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else if (heading_one_pos == 4)	total_zeros_len <= 5;
						  else 								total_zeros_len <= 6;
						10:if (heading_one_pos == 0 || heading_one_pos == 1)
							total_zeros_len <= 2;
						  else if (heading_one_pos == 2)	total_zeros_len <= 3;
						  else if (heading_one_pos == 3)	total_zeros_len <= 4;
						  else                            total_zeros_len <= 5;
						11:if (heading_one_pos == 0)      total_zeros_len <= 1;
						  else if (heading_one_pos == 1 || heading_one_pos == 2)
							                                total_zeros_len <= 3;
						  else                            total_zeros_len <= 4;
						12:if (heading_one_pos == 0 || heading_one_pos == 1 || heading_one_pos == 2 || heading_one_pos == 3)
							total_zeros_len <= heading_one_pos + 1;
						  else	total_zeros_len <= 4;
						13:if (heading_one_pos == 0 || heading_one_pos == 1 || heading_one_pos == 2)
							total_zeros_len <= heading_one_pos + 1;
						  else								total_zeros_len <= 3;
						14:if (heading_one_pos == 0) 		total_zeros_len <= 1;
						  else 								total_zeros_len <= 2;
						15:total_zeros_len <= 1;
						default:total_zeros_len <= 0;
					endcase
			end
		else
			total_zeros_len <= 0;
			
	//total_zeros
	wire total_zeros_t0,total_zeros_t1;
	assign total_zeros_t0 = (cavlc_decoder_state == `total_zeros_LUT && maxNumCoeff != 4); //Table 9-7,9-8
	assign total_zeros_t1 = (cavlc_decoder_state == `total_zeros_LUT && maxNumCoeff == 4); //Table 9-9
	always	@ (total_zeros_t0 or total_zeros_t1 or TotalCoeff_3to0 or heading_one_pos 
		or BitStream_buffer_output or total_zeros_reg)
		if (total_zeros_t0)
			case (TotalCoeff_3to0)
				1:
				if (heading_one_pos == 4'd0)	
					total_zeros <= 4'd0;
				else if (heading_one_pos == 4'd1)
					total_zeros <= (BitStream_buffer_output[13])? 4'd1:4'd2;
				else if (heading_one_pos == 4'd2)
					total_zeros <= (BitStream_buffer_output[12])? 4'd3:4'd4;
				else if (heading_one_pos == 4'd3)
					total_zeros <= (BitStream_buffer_output[11])? 4'd5:4'd6;
				else if (heading_one_pos == 4'd4)
					total_zeros <= (BitStream_buffer_output[10])? 4'd7:4'd8;
				else if (heading_one_pos == 4'd5)
					total_zeros <= (BitStream_buffer_output[9])? 4'd9:4'd10;
				else if (heading_one_pos == 4'd6)
					total_zeros <= (BitStream_buffer_output[8])? 4'd11:4'd12;
				else if (heading_one_pos == 4'd7)
					total_zeros <= (BitStream_buffer_output[7])? 4'd13:4'd14;
				else
					total_zeros <= 4'd15;
				2:
				if (heading_one_pos == 4'd0)
					total_zeros <= {2'b0,~BitStream_buffer_output[14:13]};
				else if (heading_one_pos == 4'd1)
					case (BitStream_buffer_output[13:12])
						2'b01:total_zeros <= 4'd5;
						2'b00:total_zeros <= 4'd6;
						default:total_zeros <= 4'd4;
					endcase
				else if (heading_one_pos == 4'd2)
					total_zeros <= (BitStream_buffer_output[12])? 4'd7:4'd8; 
				else if (heading_one_pos == 4'd3)
					total_zeros <= (BitStream_buffer_output[11])? 4'd9:4'd10;
				else if (heading_one_pos == 4'd4)
					total_zeros <= (BitStream_buffer_output[10])? 4'd11:4'd12;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd13;
				else
					total_zeros <= 4'd14;
				3:
				if (heading_one_pos == 4'd0)
					case (BitStream_buffer_output[14:13])
						2'b00:total_zeros <= 4'd6;
						2'b01:total_zeros <= 4'd3;
						2'b10:total_zeros <= 4'd2;
						2'b11:total_zeros <= 4'd1;
					endcase
				else if (heading_one_pos == 4'd1)
					case (BitStream_buffer_output[13:12])
						2'b00:total_zeros <= 4'd4;
						2'b01:total_zeros <= 4'd0;
						default:total_zeros <= 4'd7;
					endcase 
				else if (heading_one_pos == 4'd2)
					total_zeros <= (BitStream_buffer_output[12])? 4'd5:4'd8;
				else if (heading_one_pos == 4'd3)
					total_zeros <= (BitStream_buffer_output[11])? 4'd9:4'd10;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd12;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd11;
				else
					total_zeros <= 4'd13;
				4:
				if (heading_one_pos == 4'd0)
					case (BitStream_buffer_output[14:13])
						2'b00:total_zeros <= 4'd6;
						2'b01:total_zeros <= 4'd5;
						2'b10:total_zeros <= 4'd4;
						2'b11:total_zeros <= 4'd1;
					endcase
				else if (heading_one_pos == 4'd1)
					case (BitStream_buffer_output[13:12])
						2'b00:total_zeros <= 4'd3;
						2'b01:total_zeros <= 4'd2;
						default:total_zeros <= 4'd8;
					endcase 
				else if (heading_one_pos == 4'd2)
					total_zeros <= (BitStream_buffer_output[12])? 4'd7:4'd9;
				else if (heading_one_pos == 4'd3)
					total_zeros <= (BitStream_buffer_output[11])? 4'd0:4'd10;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd11;
				else
					total_zeros <= 4'd12;
				5:
				if (heading_one_pos == 4'd0)
					case (BitStream_buffer_output[14:13])
						2'b00:total_zeros <= 4'd6;
						2'b01:total_zeros <= 4'd5;
						2'b10:total_zeros <= 4'd4;
						2'b11:total_zeros <= 4'd3;
					endcase
				else if (heading_one_pos == 4'd1)
					case (BitStream_buffer_output[13:12])
						2'b00:total_zeros <= 4'd1;
						2'b01:total_zeros <= 4'd0;
						default:total_zeros <= 4'd7;
					endcase 
				else if (heading_one_pos == 4'd2)
					total_zeros <= (BitStream_buffer_output[12])? 4'd2:4'd8;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd10;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd9;
				else
					total_zeros <= 4'd11;
				6:
				if (heading_one_pos == 4'd0)
					case (BitStream_buffer_output[14:13])
						2'b00:total_zeros <= 4'd5;
						2'b01:total_zeros <= 4'd4;
						2'b10:total_zeros <= 4'd3;
						2'b11:total_zeros <= 4'd2;
					endcase
				else if (heading_one_pos == 4'd1)
					total_zeros <= (BitStream_buffer_output[13])? 4'd6:4'd7; 
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd9;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd8;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd1;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd0;
				else
					total_zeros <= 4'd10; 
				7:
				if (heading_one_pos == 4'd0)
					case (BitStream_buffer_output[14:13])
						2'b00:total_zeros <= 4'd3;
						2'b01:total_zeros <= 4'd2;
						default:total_zeros <= 4'd5;
					endcase
				else if (heading_one_pos == 4'd1)
					total_zeros <= (BitStream_buffer_output[13])? 4'd4:4'd6; 
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd8;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd7;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd1;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd0;
				else
					total_zeros <= 4'd9; 
				8:
				if (heading_one_pos == 4'd0)
					total_zeros <= (BitStream_buffer_output[14])? 4'd4:4'd5;
				else if (heading_one_pos == 4'd1)
					total_zeros <= (BitStream_buffer_output[13])? 4'd3:4'd6; 
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd7;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd1;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd0;
				else
					total_zeros <= 4'd8;
				9:
				if (heading_one_pos == 4'd0)
					total_zeros <= (BitStream_buffer_output[14])? 4'd3:4'd4;
				else if (heading_one_pos == 4'd1)
					total_zeros <= 4'd6;
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd5;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd7;
				else if (heading_one_pos == 4'd5)
					total_zeros <= 4'd0;
				else
					total_zeros <= 4'd1;
				10:
				if (heading_one_pos == 4'd0)
					total_zeros <= (BitStream_buffer_output[14])? 4'd3:4'd4;
				else if (heading_one_pos == 4'd1)
					total_zeros <= 4'd5;
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd6;
				else if (heading_one_pos == 4'd4)
					total_zeros <= 4'd0;
				else
					total_zeros <= 4'd1;
				11:
				if (heading_one_pos == 4'd0)
					total_zeros <= 4'd4;
				else if (heading_one_pos == 4'd1)
					total_zeros <= (BitStream_buffer_output[13])? 4'd5:4'd3;
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd1;
				else
					total_zeros <= 4'd0;
				12:
				if (heading_one_pos == 4'd0)
					total_zeros <= 4'd3;
				else if (heading_one_pos == 4'd1)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd4;
				else if (heading_one_pos == 4'd3)
					total_zeros <= 4'd1;
				else
					total_zeros <= 4'd0;					
				13:
				if (heading_one_pos == 4'd0)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd1)
					total_zeros <= 4'd3;
				else if (heading_one_pos == 4'd2)
					total_zeros <= 4'd1;
				else
					total_zeros <= 4'd0;	
				14:
				if (heading_one_pos == 4'd0)
					total_zeros <= 4'd2;
				else if (heading_one_pos == 4'd1)
					total_zeros <= 4'd1;
				else
					total_zeros <= 4'd0;
				default:total_zeros <= (heading_one_pos == 4'd0)? 4'd1:4'd0;
			endcase	
		else if (total_zeros_t1)
			case (TotalCoeff_3to0)
				1:if 	  (heading_one_pos == 4'd0)   total_zeros <= 4'd0;
				  else if (heading_one_pos == 4'd1)	total_zeros <= 4'd1;
				  else if (heading_one_pos == 4'd2)	total_zeros <= 4'd2;
				  else                              total_zeros <= 4'd3;
				2:if 	  (heading_one_pos == 4'd0)   total_zeros <= 4'd0;
				  else if (heading_one_pos == 4'd1)	total_zeros <= 4'd1;
				  else                              total_zeros <= 4'd2;
				3:total_zeros <= {3'b0,~BitStream_buffer_output[15]};
				default:total_zeros <= 0;
			endcase
		else
			total_zeros <= total_zeros_reg;
			
	always @ (posedge clk)
		if (reset_n == 0)
			total_zeros_reg <= 0;
		else if (cavlc_decoder_state == `total_zeros_LUT)
			total_zeros_reg <= total_zeros;
			
endmodule
					
	
