//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : sum.v
// Generated : Oct 29, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Sum module for residual + prediction
// Including output transpose and Intra_mbAddrB_RAM write control
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module sum (clk,reset_n,slice_data_state,residual_state,TotalCoeff,curr_CBPLuma_IsZero,CodedBlockPatternChroma,
	curr_DC_IsZero,curr_DC_scaled,gclk_pred_output,gclk_blk4x4_sum,trigger_blk4x4_rec_sum,
	IQIT_output_0, IQIT_output_1, IQIT_output_2, IQIT_output_3,
	IQIT_output_4, IQIT_output_5, IQIT_output_6, IQIT_output_7,
	IQIT_output_8, IQIT_output_9, IQIT_output_10,IQIT_output_11,
	IQIT_output_12,IQIT_output_13,IQIT_output_14,IQIT_output_15,
	mb_type_general,Intra4x4_predmode,Intra16x16_predmode,Intra_chroma_predmode,
	Intra_pred_PE0_out,Intra_pred_PE1_out,Intra_pred_PE2_out,Intra_pred_PE3_out,blk4x4_intra_calculate_counter,
	Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3,blk4x4_inter_calculate_counter,Inter_chroma2x2_counter,
	Inter_blk4x4_pred_output_valid,mv_below8x8_curr,pos_FracL,mb_num_v,mb_num_h,LowerMB_IsSkip,
	
	end_of_one_blk4x4_sum,blk4x4_sum_counter,blk4x4_rec_counter,
	blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	sum_right_column_reg,blk4x4_rec_counter_2_raster_order,
	blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2,
	blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6,
	blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10,
	blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14,
	Intra_mbAddrB_RAM_wr,Intra_mbAddrB_RAM_wr_addr,Intra_mbAddrB_RAM_din
	);
	input clk,reset_n;
	input [3:0] slice_data_state;
	input [3:0] residual_state;
	input [4:0] TotalCoeff;
	input curr_CBPLuma_IsZero;
	input [1:0] CodedBlockPatternChroma;
	input curr_DC_IsZero;
	input [8:0] curr_DC_scaled;
	input gclk_pred_output;
	input gclk_blk4x4_sum;
	input trigger_blk4x4_rec_sum;
	//residual from IQIT
	input [8:0] IQIT_output_0, IQIT_output_1, IQIT_output_2, IQIT_output_3;
	input [8:0] IQIT_output_4, IQIT_output_5, IQIT_output_6, IQIT_output_7;
	input [8:0] IQIT_output_8, IQIT_output_9, IQIT_output_10,IQIT_output_11;
	input [8:0] IQIT_output_12,IQIT_output_13,IQIT_output_14,IQIT_output_15;
	//Intra prediction output
	input [3:0] mb_type_general;
	input [3:0]	Intra4x4_predmode;
	input [1:0] Intra16x16_predmode;
	input [1:0] Intra_chroma_predmode;
	input [7:0] Intra_pred_PE0_out,Intra_pred_PE1_out,Intra_pred_PE2_out,Intra_pred_PE3_out;
	input [2:0] blk4x4_intra_calculate_counter;
	//Inter prediction output
	input [7:0] Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3;
	input [1:0] Inter_blk4x4_pred_output_valid;
	input mv_below8x8_curr;
	input [3:0] pos_FracL;
	input [3:0] blk4x4_inter_calculate_counter;
	input [1:0] Inter_chroma2x2_counter;
	input [3:0] mb_num_h,mb_num_v;
	input LowerMB_IsSkip;
	
	output end_of_one_blk4x4_sum;
	output [2:0] blk4x4_sum_counter;
	output [4:0] blk4x4_rec_counter;
	output [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	output [23:0] sum_right_column_reg;
	output [4:0] blk4x4_rec_counter_2_raster_order;
	output [7:0] blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2;
	output [7:0] blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6;
	output [7:0] blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10;
	output [7:0] blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14;
	output Intra_mbAddrB_RAM_wr;
	output [6:0] Intra_mbAddrB_RAM_wr_addr;
	output [31:0] Intra_mbAddrB_RAM_din; 
		
	reg [2:0] blk4x4_sum_counter;
	reg [4:0] blk4x4_rec_counter;
	reg [4:0] blk4x4_rec_counter_2_raster_order;
	reg [23:0] sum_right_column_reg;
		
	reg [7:0] blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2, blk4x4_pred_output3;
	reg [7:0] blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6, blk4x4_pred_output7;
	reg [7:0] blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10,blk4x4_pred_output11;
	reg [7:0] blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14,blk4x4_pred_output15;
	

	always @ (posedge gclk_pred_output or negedge reset_n)
		if (reset_n == 1'b0)
			begin blk4x4_pred_output0  <= 0; blk4x4_pred_output1 <= 0; blk4x4_pred_output2  <= 0; blk4x4_pred_output3  <= 0; 
				  blk4x4_pred_output4  <= 0; blk4x4_pred_output5 <= 0; blk4x4_pred_output6  <= 0; blk4x4_pred_output7  <= 0; 
				  blk4x4_pred_output8  <= 0; blk4x4_pred_output9 <= 0; blk4x4_pred_output10 <= 0; blk4x4_pred_output11 <= 0;
				  blk4x4_pred_output12 <= 0; blk4x4_pred_output13<= 0; blk4x4_pred_output14 <= 0; blk4x4_pred_output15 <= 0; end
		else if (blk4x4_intra_calculate_counter != 0)
			begin
				//Intra4x4DC or chromaDC intra prediction:output valid only at cycle3 by PE0
				if ((mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16 && Intra4x4_predmode == `Intra4x4_DC) ||
            (mb_type_general[3]   == 1'b1  && blk4x4_rec_counter > 15 && Intra_chroma_predmode == `Intra_chroma_DC))
					begin 
						if (blk4x4_intra_calculate_counter == 3'd3) //Intra4x4DC or chromaDC completes calculation at cycle3 by PE0
							begin
								blk4x4_pred_output0  <= Intra_pred_PE0_out; blk4x4_pred_output1  <= Intra_pred_PE0_out;
								blk4x4_pred_output2  <= Intra_pred_PE0_out; blk4x4_pred_output3  <= Intra_pred_PE0_out;
								blk4x4_pred_output4  <= Intra_pred_PE0_out; blk4x4_pred_output5  <= Intra_pred_PE0_out;
								blk4x4_pred_output6  <= Intra_pred_PE0_out; blk4x4_pred_output7  <= Intra_pred_PE0_out;
								blk4x4_pred_output8  <= Intra_pred_PE0_out; blk4x4_pred_output9  <= Intra_pred_PE0_out;
								blk4x4_pred_output10 <= Intra_pred_PE0_out; blk4x4_pred_output11 <= Intra_pred_PE0_out;
								blk4x4_pred_output12 <= Intra_pred_PE0_out; blk4x4_pred_output13 <= Intra_pred_PE0_out;
								blk4x4_pred_output14 <= Intra_pred_PE0_out; blk4x4_pred_output15 <= Intra_pred_PE0_out;
							end
					end
				//Intra16x16DC intra prediction:output valid only at cycle1 by PE0
				else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16 && Intra16x16_predmode == `Intra16x16_DC)
					begin 
						if (blk4x4_rec_counter == 0 && blk4x4_intra_calculate_counter == 3'd1) 
							begin
								blk4x4_pred_output0  <= Intra_pred_PE0_out; blk4x4_pred_output1  <= Intra_pred_PE0_out;
								blk4x4_pred_output2  <= Intra_pred_PE0_out; blk4x4_pred_output3  <= Intra_pred_PE0_out;
								blk4x4_pred_output4  <= Intra_pred_PE0_out; blk4x4_pred_output5  <= Intra_pred_PE0_out;
								blk4x4_pred_output6  <= Intra_pred_PE0_out; blk4x4_pred_output7  <= Intra_pred_PE0_out;
								blk4x4_pred_output8  <= Intra_pred_PE0_out; blk4x4_pred_output9  <= Intra_pred_PE0_out;
								blk4x4_pred_output10 <= Intra_pred_PE0_out; blk4x4_pred_output11 <= Intra_pred_PE0_out;
								blk4x4_pred_output12 <= Intra_pred_PE0_out; blk4x4_pred_output13 <= Intra_pred_PE0_out;
								blk4x4_pred_output14 <= Intra_pred_PE0_out; blk4x4_pred_output15 <= Intra_pred_PE0_out;
							end
					end
				//Besides above DC intra prediction case,other intra prediction modes output valid from cycle4 ~ cycle1
				else
					case (blk4x4_intra_calculate_counter)
						3'd4:begin	blk4x4_pred_output0  <= Intra_pred_PE0_out; blk4x4_pred_output4  <= Intra_pred_PE1_out; 
									blk4x4_pred_output8  <= Intra_pred_PE2_out; blk4x4_pred_output12 <= Intra_pred_PE3_out;	end
						3'd3:begin	blk4x4_pred_output1  <= Intra_pred_PE0_out; blk4x4_pred_output5  <= Intra_pred_PE1_out; 
									blk4x4_pred_output9  <= Intra_pred_PE2_out; blk4x4_pred_output13 <= Intra_pred_PE3_out;	end
						3'd2:begin	blk4x4_pred_output2  <= Intra_pred_PE0_out; blk4x4_pred_output6  <= Intra_pred_PE1_out; 
									blk4x4_pred_output10 <= Intra_pred_PE2_out; blk4x4_pred_output14 <= Intra_pred_PE3_out;	end
						3'd1:begin	blk4x4_pred_output3  <= Intra_pred_PE0_out; blk4x4_pred_output7  <= Intra_pred_PE1_out; 
									blk4x4_pred_output11 <= Intra_pred_PE2_out; blk4x4_pred_output15 <= Intra_pred_PE3_out;	end
				   	endcase
			end
		//Inter luma prediction output store
		else if (Inter_blk4x4_pred_output_valid == 2'b01)
			begin
				if (pos_FracL == `pos_i || pos_FracL == `pos_k)
					case (blk4x4_inter_calculate_counter)
						4'd7:begin	blk4x4_pred_output0  <= Inter_pred_out0; blk4x4_pred_output4  <= Inter_pred_out1; 
									blk4x4_pred_output8  <= Inter_pred_out2; blk4x4_pred_output12 <= Inter_pred_out3;	end
						4'd5:begin	blk4x4_pred_output1  <= Inter_pred_out0; blk4x4_pred_output5  <= Inter_pred_out1; 
									blk4x4_pred_output9  <= Inter_pred_out2; blk4x4_pred_output13 <= Inter_pred_out3;	end
						4'd3:begin	blk4x4_pred_output2  <= Inter_pred_out0; blk4x4_pred_output6  <= Inter_pred_out1; 
									blk4x4_pred_output10 <= Inter_pred_out2; blk4x4_pred_output14 <= Inter_pred_out3;	end
						4'd1:begin	blk4x4_pred_output3  <= Inter_pred_out0; blk4x4_pred_output7  <= Inter_pred_out1; 
									blk4x4_pred_output11 <= Inter_pred_out2; blk4x4_pred_output15 <= Inter_pred_out3;	end
					endcase
				else
					case (blk4x4_inter_calculate_counter)
						4'd4:begin	blk4x4_pred_output0  <= Inter_pred_out0; blk4x4_pred_output4  <= Inter_pred_out1; 
									blk4x4_pred_output8  <= Inter_pred_out2; blk4x4_pred_output12 <= Inter_pred_out3;	end
						4'd3:begin	blk4x4_pred_output1  <= Inter_pred_out0; blk4x4_pred_output5  <= Inter_pred_out1; 
									blk4x4_pred_output9  <= Inter_pred_out2; blk4x4_pred_output13 <= Inter_pred_out3;	end
						4'd2:begin	blk4x4_pred_output2  <= Inter_pred_out0; blk4x4_pred_output6  <= Inter_pred_out1; 
									blk4x4_pred_output10 <= Inter_pred_out2; blk4x4_pred_output14 <= Inter_pred_out3;	end
						4'd1:begin	blk4x4_pred_output3  <= Inter_pred_out0; blk4x4_pred_output7  <= Inter_pred_out1; 
									blk4x4_pred_output11 <= Inter_pred_out2; blk4x4_pred_output15 <= Inter_pred_out3;	end
					endcase
			end
		//Inter chroma prediction output store
		else if (Inter_blk4x4_pred_output_valid == 2'b10)	
			case (mv_below8x8_curr)
				1'b1:
				case (Inter_chroma2x2_counter)
					2'b11:
					begin
						blk4x4_pred_output0 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out0:0;
						blk4x4_pred_output1 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out1:0;
						blk4x4_pred_output4 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out2:0;
						blk4x4_pred_output5 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out3:0;
					end
					2'b10:
					begin
						blk4x4_pred_output2 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out0:0;
						blk4x4_pred_output3 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out1:0;
						blk4x4_pred_output6 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out2:0;
						blk4x4_pred_output7 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out3:0;
					end
					2'b01:
					begin
						blk4x4_pred_output8  <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out0:0;
						blk4x4_pred_output9  <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out1:0;
						blk4x4_pred_output12 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out2:0;
						blk4x4_pred_output13 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out3:0;
					end
					2'b00:
					begin
						blk4x4_pred_output10 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out0:0;
						blk4x4_pred_output11 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out1:0;
						blk4x4_pred_output14 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out2:0;
						blk4x4_pred_output15 <= (blk4x4_inter_calculate_counter != 0)? Inter_pred_out3:0;
					end
				endcase
				1'b0:
				case (blk4x4_inter_calculate_counter)
					4'd4:begin	blk4x4_pred_output0  <= Inter_pred_out0; blk4x4_pred_output1  <= Inter_pred_out1;
								blk4x4_pred_output4  <= Inter_pred_out2; blk4x4_pred_output5  <= Inter_pred_out3;	end
					4'd3:begin	blk4x4_pred_output2  <= Inter_pred_out0; blk4x4_pred_output3  <= Inter_pred_out1;
								blk4x4_pred_output6  <= Inter_pred_out2; blk4x4_pred_output7  <= Inter_pred_out3;	end
					4'd2:begin	blk4x4_pred_output8  <= Inter_pred_out0; blk4x4_pred_output9  <= Inter_pred_out1;
								blk4x4_pred_output12 <= Inter_pred_out2; blk4x4_pred_output13 <= Inter_pred_out3;	end
					4'd1:begin	blk4x4_pred_output10 <= Inter_pred_out0; blk4x4_pred_output11 <= Inter_pred_out1;
								blk4x4_pred_output14 <= Inter_pred_out2; blk4x4_pred_output15 <= Inter_pred_out3;	end
				endcase
			endcase
			
	//------------------------------------------------------
	//blk4x4_sum_counter
	//------------------------------------------------------
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_sum_counter <= 3'd4;
		else if (trigger_blk4x4_rec_sum == 1'b1)
			blk4x4_sum_counter <= 3'd0;
		else if (blk4x4_sum_counter != 3'd4)
			blk4x4_sum_counter <= blk4x4_sum_counter + 1;
	
	assign end_of_one_blk4x4_sum = (blk4x4_sum_counter == 3'd3)? 1'b1:1'b0;
	//------------------------------------------------------
	//blk4x4_rec_counter
	//------------------------------------------------------		
	always	@ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_rec_counter <= 0;
		else if (blk4x4_sum_counter == 3'd3)
			blk4x4_rec_counter <= (blk4x4_rec_counter == 5'd23)? 5'd0:(blk4x4_rec_counter + 1);
	//------------------------------------------------------
	//reconstruction sum
	//------------------------------------------------------
	
	//Note:since res_blk4x4_IsAllZero has a higer priority over res_blk4x4_OnlyDC,the conditions
	//to assign res_blk4x4_OnlyDC is NOT complete (but when take current assigned res_blk4x4_IsAllZero
	//value into account, res_blk4x4_OnlyDC is correct!) 
	
	//res_blk4x4_IsAllZero:curr_DC_IsZero? curr_CBPLuma_IsZero? TotalCoeff is zero? CBPChroma is zero or one?
	
	reg res_blk4x4_IsAllZero;
	reg res_blk4x4_onlyDC;
	always @ (slice_data_state or residual_state or curr_DC_IsZero or TotalCoeff 
		or curr_DC_IsZero or curr_CBPLuma_IsZero or CodedBlockPatternChroma)
		if (slice_data_state == `skip_run_duration)
			begin
				res_blk4x4_IsAllZero <= 1'b1;
				res_blk4x4_onlyDC    <= 1'b0;
			end
		else
			case (residual_state)
				`Intra16x16ACLevel_0_s:	
				begin	
					res_blk4x4_IsAllZero <= (curr_DC_IsZero)? 1'b1:1'b0;
					res_blk4x4_onlyDC	 <= (curr_DC_IsZero)? 1'b0:1'b1;
				end
				`Intra16x16ACLevel_s,`ChromaACLevel_Cb_s,`ChromaACLevel_Cr_s:
				begin
					res_blk4x4_IsAllZero <= (TotalCoeff == 0 && curr_DC_IsZero)? 1'b1:1'b0;
					res_blk4x4_onlyDC    <= (TotalCoeff == 0)? 1'b1:1'b0;
				end
				`LumaLevel_0_s:
				begin
					res_blk4x4_IsAllZero <= 1'b1;
					res_blk4x4_onlyDC	 <= 1'b0;	
				end
				`LumaLevel_s:
				begin
					res_blk4x4_IsAllZero <= (TotalCoeff == 0 || curr_CBPLuma_IsZero)? 1'b1:1'b0;
					res_blk4x4_onlyDC	 <= 1'b0;
				end
				`ChromaACLevel_0_s:					//CodedBlockPatternChroma == 0 or 1
				if (CodedBlockPatternChroma == 0)	//CodedBlockPatternChroma == 0
					begin
						res_blk4x4_IsAllZero <= 1'b1;
						res_blk4x4_onlyDC	 <= 1'b0;
					end
				else 								//CodedBlockPatternChroma == 1
					begin
						res_blk4x4_IsAllZero <= (curr_DC_IsZero)? 1'b1:1'b0;
						res_blk4x4_onlyDC	 <= (curr_DC_IsZero)? 1'b0:1'b1;
					end
				default:
				begin
					res_blk4x4_IsAllZero <= 1'b0;
					res_blk4x4_onlyDC    <= 1'b0;
				end
			endcase
		
	reg [8:0] sum_PE0_a,sum_PE1_a,sum_PE2_a,sum_PE3_a;
	reg [7:0] sum_PE0_b,sum_PE1_b,sum_PE2_b,sum_PE3_b;
	wire sum_PE_bypass; //only one bypass signal for all sum_PE0 ~ sum_PE3
	assign sum_PE_bypass = (blk4x4_sum_counter != 3'd4 && !res_blk4x4_IsAllZero)? 1'b0:1'b1;
	
	sum_PE sum_PE0 (
		.a(sum_PE0_a),
		.b(sum_PE0_b),
		.bypass(sum_PE_bypass),
		.c(blk4x4_sum_PE0_out)
		);	
	sum_PE sum_PE1 (
		.a(sum_PE1_a),
		.b(sum_PE1_b),
		.bypass(sum_PE_bypass),
		.c(blk4x4_sum_PE1_out)
		);
	sum_PE sum_PE2 (
		.a(sum_PE2_a),
		.b(sum_PE2_b),
		.bypass(sum_PE_bypass),
		.c(blk4x4_sum_PE2_out)
		);
	sum_PE sum_PE3 (
		.a(sum_PE3_a),
		.b(sum_PE3_b),
		.bypass(sum_PE_bypass),
		.c(blk4x4_sum_PE3_out)
		);
	
	// only for statistical purpose
	// synopsys translate_off
	integer	number_of_IsAllZero;
	integer number_of_onlyDC;
	initial
		begin
			number_of_IsAllZero = 0;
			number_of_onlyDC = 0;
		end
	always @ (blk4x4_sum_counter)
		if (blk4x4_sum_counter == 3'd2)
			begin
				if (res_blk4x4_IsAllZero == 1'b1)	number_of_IsAllZero <= number_of_IsAllZero + 1;
				else if (res_blk4x4_onlyDC == 1'b1)	number_of_onlyDC 	<= number_of_onlyDC + 1;
			end
	// synopsys translate_on
		
	always @ (blk4x4_sum_counter or res_blk4x4_IsAllZero or res_blk4x4_onlyDC or curr_DC_scaled or
		IQIT_output_0  or IQIT_output_1  or IQIT_output_2  or IQIT_output_3  or 
		IQIT_output_4  or IQIT_output_5  or IQIT_output_6  or IQIT_output_7  or 
		IQIT_output_8  or IQIT_output_9  or IQIT_output_10 or IQIT_output_11 or 
		IQIT_output_12 or IQIT_output_13 or IQIT_output_14 or IQIT_output_15)
		if (res_blk4x4_IsAllZero)
			begin 	sum_PE0_a <= 0; sum_PE1_a <= 0; sum_PE2_a <= 0; sum_PE3_a <= 0;	end
		else if (res_blk4x4_onlyDC)
			begin 	sum_PE0_a <= curr_DC_scaled; sum_PE1_a <= curr_DC_scaled; 
					sum_PE2_a <= curr_DC_scaled; sum_PE3_a <= curr_DC_scaled;	end
		else 
			case (blk4x4_sum_counter)
				0:begin	sum_PE0_a <= IQIT_output_0; sum_PE1_a <= IQIT_output_1;		
						sum_PE2_a <= IQIT_output_2;	sum_PE3_a <= IQIT_output_3; end
				1:begin	sum_PE0_a <= IQIT_output_4;	sum_PE1_a <= IQIT_output_5;		
						sum_PE2_a <= IQIT_output_6;	sum_PE3_a <= IQIT_output_7; end
				2:begin	sum_PE0_a <= IQIT_output_8;	sum_PE1_a <= IQIT_output_9;		
						sum_PE2_a <= IQIT_output_10;sum_PE3_a <= IQIT_output_11; end
				3:begin	sum_PE0_a <= IQIT_output_12;sum_PE1_a <= IQIT_output_13;		
						sum_PE2_a <= IQIT_output_14;sum_PE3_a <= IQIT_output_15; end
				default:begin sum_PE0_a <= 0; sum_PE1_a <= 0; sum_PE2_a <= 0; sum_PE3_a <= 0; end
			endcase
	always @ (blk4x4_sum_counter or 
		blk4x4_pred_output0  or blk4x4_pred_output1  or blk4x4_pred_output2  or blk4x4_pred_output3  or 
		blk4x4_pred_output4  or blk4x4_pred_output5  or blk4x4_pred_output6  or blk4x4_pred_output7  or 
		blk4x4_pred_output8  or blk4x4_pred_output9  or blk4x4_pred_output10 or blk4x4_pred_output11 or 
		blk4x4_pred_output12 or blk4x4_pred_output13 or blk4x4_pred_output14 or blk4x4_pred_output15)
		case (blk4x4_sum_counter)
			0:begin	sum_PE0_b <= blk4x4_pred_output0; sum_PE1_b <= blk4x4_pred_output1;	
					sum_PE2_b <= blk4x4_pred_output2; sum_PE3_b <= blk4x4_pred_output3; end
			1:begin	sum_PE0_b <= blk4x4_pred_output4; sum_PE1_b <= blk4x4_pred_output5;	
					sum_PE2_b <= blk4x4_pred_output6; sum_PE3_b <= blk4x4_pred_output7; end
			2:begin	sum_PE0_b <= blk4x4_pred_output8; sum_PE1_b <= blk4x4_pred_output9;	
					sum_PE2_b <= blk4x4_pred_output10;sum_PE3_b <= blk4x4_pred_output11; end
			3:begin	sum_PE0_b <= blk4x4_pred_output12;sum_PE1_b <= blk4x4_pred_output13;	
					sum_PE2_b <= blk4x4_pred_output14;sum_PE3_b <= blk4x4_pred_output15; end
			default:begin sum_PE0_b <= 0; sum_PE1_b <= 0; sum_PE2_b <= 0; sum_PE3_b <= 0; end
		endcase
	//----------------------------------------------------------------------
	//sum right most column latch for Intra mbAddrA
	//----------------------------------------------------------------------
	//sum_right_column_reg:
	always @ (posedge gclk_blk4x4_sum or negedge reset_n)
		if (reset_n == 0)
			sum_right_column_reg <= 0;
		else 
			case (blk4x4_sum_counter)
				3'd0:sum_right_column_reg[7:0]   <= blk4x4_sum_PE3_out;
				3'd1:sum_right_column_reg[15:8]  <= blk4x4_sum_PE3_out;
				3'd2:sum_right_column_reg[23:16] <= blk4x4_sum_PE3_out;
			endcase
			
	//blk4x4_rec_counter_2_raster_order:
	//change from double-z order to raster order
	always @ (blk4x4_rec_counter)
		case (blk4x4_rec_counter)
			5'd2 :blk4x4_rec_counter_2_raster_order <= 5'd4;
			5'd3 :blk4x4_rec_counter_2_raster_order <= 5'd5;
			5'd4 :blk4x4_rec_counter_2_raster_order <= 5'd2;
			5'd5 :blk4x4_rec_counter_2_raster_order <= 5'd3;
			5'd10:blk4x4_rec_counter_2_raster_order <= 5'd12;
			5'd11:blk4x4_rec_counter_2_raster_order <= 5'd13;
			5'd12:blk4x4_rec_counter_2_raster_order <= 5'd10;
			5'd13:blk4x4_rec_counter_2_raster_order <= 5'd11;
			default:blk4x4_rec_counter_2_raster_order <= blk4x4_rec_counter;
		endcase
	//----------------------------------------------------------------------
	//Intra_mbAddrB_RAM write control
	//----------------------------------------------------------------------
	wire Is_blk4x4_rec_bottom;
	assign Is_blk4x4_rec_bottom = (blk4x4_rec_counter == 5'd10 || blk4x4_rec_counter == 5'd11 ||
	blk4x4_rec_counter == 5'd14 || blk4x4_rec_counter == 5'd15 || blk4x4_rec_counter == 5'd18 || 
	blk4x4_rec_counter == 5'd19 || blk4x4_rec_counter == 5'd22 || blk4x4_rec_counter == 5'd23);
	
	assign Intra_mbAddrB_RAM_wr = (mb_num_v != 4'd8 && blk4x4_sum_counter == 3'd3 && Is_blk4x4_rec_bottom && !LowerMB_IsSkip);
	assign Intra_mbAddrB_RAM_din = (Intra_mbAddrB_RAM_wr)? {blk4x4_sum_PE3_out,blk4x4_sum_PE2_out,blk4x4_sum_PE1_out,blk4x4_sum_PE0_out}:0; 
	
	//	base pointer, [43:0] luma, [65:44] Chroma Cb, [87:66] Chroma Cr
	reg [6:0] Intra_mbAddrB_RAM_addr_bp;
	always @ (Intra_mbAddrB_RAM_wr or blk4x4_rec_counter[4] or blk4x4_rec_counter[2])
		if (Intra_mbAddrB_RAM_wr)
			begin
				if (blk4x4_rec_counter[4] == 1'b0)		Intra_mbAddrB_RAM_addr_bp <= 0;
				else if (blk4x4_rec_counter[2] == 1'b0)	Intra_mbAddrB_RAM_addr_bp <= 7'd44;
				else									Intra_mbAddrB_RAM_addr_bp <= 7'd66;
			end
		else											Intra_mbAddrB_RAM_addr_bp <= 0;
			
	//	shift pointer,x2 for chroma,x4 for luma
	wire [5:0] Intra_mbAddrB_RAM_addr_sp;
	assign Intra_mbAddrB_RAM_addr_sp = (Intra_mbAddrB_RAM_wr && blk4x4_rec_counter[4] == 1'b1)? 
										{1'b0,mb_num_h,1'b0}:{mb_num_h,2'b0};
	//	pointer for relative address of each 4x4 block inside a MB
	reg [1:0] Intra_mbAddrB_RAM_addr_ip;
	always @ (Intra_mbAddrB_RAM_wr or blk4x4_rec_counter[4] or blk4x4_rec_counter[2:0])	
		if (Intra_mbAddrB_RAM_wr)
			begin
				if (blk4x4_rec_counter[4] == 1'b0)
					case (blk4x4_rec_counter[2:0])
						3'b010:Intra_mbAddrB_RAM_addr_ip <= 2'd0;
						3'b011:Intra_mbAddrB_RAM_addr_ip <= 2'd1;
						3'b110:Intra_mbAddrB_RAM_addr_ip <= 2'd2;
						3'b111:Intra_mbAddrB_RAM_addr_ip <= 2'd3;
						default:Intra_mbAddrB_RAM_addr_ip <= 0;
					endcase
				else
					Intra_mbAddrB_RAM_addr_ip <= {1'b0,blk4x4_rec_counter[0]};
			end
		else
			Intra_mbAddrB_RAM_addr_ip <= 0;
			
	assign Intra_mbAddrB_RAM_wr_addr = Intra_mbAddrB_RAM_addr_bp + Intra_mbAddrB_RAM_addr_sp + Intra_mbAddrB_RAM_addr_ip;		
	
	/*
	// synopsys translate_off
	integer	tracefile; 
	initial
		begin
			tracefile = $fopen("nova_sum_output.log");
		end
		
	wire [6:0] mb_num;
	assign mb_num = mb_num_v * 11 + mb_num_h;
	
	wire [1:0] blk4x4_rec_counter_M4;
	assign blk4x4_rec_counter_M4 = blk4x4_rec_counter[1:0];
	
	reg [8:0] pic_num;
	always @ (reset_n or mb_num)
		if (reset_n == 1'b0)
			pic_num <= 9'b111111111;
		else if (mb_num == 0)
			pic_num <= pic_num + 1;
	
	always @ (posedge clk)
		if (blk4x4_sum_counter == 0)
			begin
				$fdisplay (tracefile,"------------------------ Pic = %3d, MB = %3d -------------------------",pic_num,mb_num);
				if (blk4x4_rec_counter < 16)
  					$fdisplay (tracefile," [Luma]   blk4x4Idx = %2d",blk4x4_rec_counter);
  				else
  					$fdisplay (tracefile," [Chroma] blk4x4Idx = %2d",blk4x4_rec_counter_M4);
				$fdisplay (tracefile," Sum  output: %8d %8d %8d %8d",blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out);
			end
		else if (blk4x4_sum_counter != 3'd4)
  			$fdisplay (tracefile,"              %8d %8d %8d %8d",blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out);
	// synopsys translate_on
	*/
	
endmodule

module sum_PE (a,b,bypass,c);
	input [8:0] a;	//for residual from IQIT
	input [7:0] b;	//for prediction from intra or inter
	input bypass;
	output [7:0] c;
	
	wire [9:0] sum;
	
	assign sum = (bypass)? 0:({2'b0,b} + {a[8],a});
	assign c   = (bypass)? b:((sum[9] == 1'b1)? 0:((sum[8] == 1'b1)? 8'd255:sum[7:0]));
endmodule
	