//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_pred_pipeline.v
// Generated : Oct 4, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Inter prediction pipeline
//-------------------------------------------------------------------------------------------------
// Revise log 
// 1.July 23,2006
// Change the ext_frame_RAM from async read to sync read.Therefore,blk4x4_inter_preload_counter has to +1 for all the cases
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_pred_pipeline (clk,reset_n,
	mb_num_h,mb_num_v,trigger_blk4x4_inter_pred,blk4x4_rec_counter,mb_type_general_bit3,
	mv_is16x16,mv_below8x8,
	mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3,
	mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3,
	Inter_pix_copy0,Inter_pix_copy1,Inter_pix_copy2,Inter_pix_copy3,
	LPE0_out,LPE1_out,LPE2_out,LPE3_out,
	CPE0_out,CPE1_out,CPE2_out,CPE3_out,
	
	mv_below8x8_curr,blk4x4_inter_preload_counter,blk4x4_inter_calculate_counter,Inter_chroma2x2_counter,
	end_of_one_blk4x4_inter,IsInterLuma,IsInterChroma,Is_InterChromaCopy,
	xInt_addr_unclip,xInt_org_unclip_1to0,pos_FracL,xFracC,yFracC,
	Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3,Inter_blk4x4_pred_output_valid,
	ref_frame_RAM_rd,ref_frame_RAM_rd_addr);
	input clk;
	input reset_n;
	input [3:0] mb_num_h,mb_num_v;
	input trigger_blk4x4_inter_pred;
	input [4:0] blk4x4_rec_counter;
	input mb_type_general_bit3;
	input mv_is16x16;
	input [3:0] mv_below8x8;
	input [31:0] mvx_CurrMb0,mvx_CurrMb1,mvx_CurrMb2,mvx_CurrMb3;
	input [31:0] mvy_CurrMb0,mvy_CurrMb1,mvy_CurrMb2,mvy_CurrMb3;
	input [7:0] Inter_pix_copy0,Inter_pix_copy1,Inter_pix_copy2,Inter_pix_copy3;
	input [7:0] LPE0_out,LPE1_out,LPE2_out,LPE3_out;
	input [7:0] CPE0_out,CPE1_out,CPE2_out,CPE3_out;
	
	output mv_below8x8_curr;
	output [5:0] blk4x4_inter_preload_counter;
	output [3:0] blk4x4_inter_calculate_counter;
	output [1:0] Inter_chroma2x2_counter;
	output end_of_one_blk4x4_inter;
	output IsInterLuma,IsInterChroma;
	output Is_InterChromaCopy;
	output [8:0] xInt_addr_unclip;
	output [1:0] xInt_org_unclip_1to0;
	output [3:0] pos_FracL;
	output [2:0] xFracC,yFracC;
	output [7:0] Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3;
	output [1:0] Inter_blk4x4_pred_output_valid;	//2'b01:luma output valid	2'b10:chroma output valid
	output ref_frame_RAM_rd;
	output [13:0] ref_frame_RAM_rd_addr;
	
	reg [5:0] blk4x4_inter_preload_counter;
	reg [3:0] blk4x4_inter_calculate_counter;
	reg mv_below8x8_curr;
	reg [7:0] Inter_pred_out0,Inter_pred_out1,Inter_pred_out2,Inter_pred_out3;
	reg [1:0] Inter_blk4x4_pred_output_valid;
	wire ref_frame_RAM_rd; 
	wire IsInterLuma;
	wire IsInterChroma;
	wire [1:0] xFracL;
	wire [1:0] yFracL;
	wire [2:0] xFracC;
	wire [2:0] yFracC;
	wire [13:0] ref_frame_RAM_rd_addr;
		
	assign IsInterLuma   = (!mb_type_general_bit3 && blk4x4_rec_counter < 16)? 1'b1:1'b0;
	assign IsInterChroma = (!mb_type_general_bit3 && blk4x4_rec_counter > 15)? 1'b1:1'b0;
	//-------------------------------------------------------------------------
	//mv_below8x8_curr for each 2x2 Inter Chroma prediction
	//-------------------------------------------------------------------------	
	always @ (IsInterLuma or IsInterChroma or blk4x4_rec_counter[3:0] or mv_below8x8)
		if (IsInterLuma)
			case (blk4x4_rec_counter[3:2])
				2'b00:mv_below8x8_curr <= mv_below8x8[0];
				2'b01:mv_below8x8_curr <= mv_below8x8[1];
				2'b10:mv_below8x8_curr <= mv_below8x8[2];
				2'b11:mv_below8x8_curr <= mv_below8x8[3];
			endcase
		else if (IsInterChroma)
			case (blk4x4_rec_counter[1:0])
				2'b00:mv_below8x8_curr <= mv_below8x8[0];
				2'b01:mv_below8x8_curr <= mv_below8x8[1];
				2'b10:mv_below8x8_curr <= mv_below8x8[2];
				2'b11:mv_below8x8_curr <= mv_below8x8[3];
			endcase
		else
			mv_below8x8_curr <= 0;
	//----------------------------------------------------------------------------------------
	//Inter_chroma2x2_counter to guide the prediction of 2x2 chroma blocks
	//2'b11 -> 2'b10 -> 2'b01 -> 2'b00
	//----------------------------------------------------------------------------------------
	reg [1:0] Inter_chroma2x2_counter;		
	always @ (posedge clk)
		if (reset_n == 1'b0)
			Inter_chroma2x2_counter <= 0;
		//mv_below8x8_curr == 1'b1 includes the condition that "blk4x4_rec_counter > 15"
		else if (IsInterChroma && trigger_blk4x4_inter_pred && mv_below8x8_curr)
			Inter_chroma2x2_counter <= 2'b11;
		else if	(blk4x4_inter_calculate_counter == 4'd1 && Inter_chroma2x2_counter != 0)
			Inter_chroma2x2_counter <= Inter_chroma2x2_counter - 1;
	
	//----------------------------------------------------------------------------------------
	//trigger_blk2x2_inter_pred:only for chroma 2x2 decoding
	//We introduce this additional signal since we need Inter_chroma2x2_counter to update 
	//one cycle before blk4x4_inter_calculate_counter
	//----------------------------------------------------------------------------------------
	reg trigger_blk2x2_inter_pred;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			trigger_blk2x2_inter_pred <= 0;
		else if ((IsInterChroma && trigger_blk4x4_inter_pred && mv_below8x8_curr) || 
			(blk4x4_inter_calculate_counter == 4'd1 && Inter_chroma2x2_counter != 0))
			trigger_blk2x2_inter_pred <= 1'b1;
		else
			trigger_blk2x2_inter_pred <= 1'b0; 
	//----------------------------------------------------------------------------------------
	//Inter motion vector for current 4x4 luma/chroma block or 2x2 chroma block
	//	Inter_blk_mvx,Inter_blk_mvy
	//----------------------------------------------------------------------------------------
	reg [7:0] Inter_blk_mvx,Inter_blk_mvy;
	always @ (blk4x4_rec_counter or mv_below8x8_curr or Inter_chroma2x2_counter 
	   	or IsInterLuma or IsInterChroma or mv_is16x16  
		or mvx_CurrMb0 or mvx_CurrMb1 or mvx_CurrMb2 or mvx_CurrMb3
		or mvy_CurrMb0 or mvy_CurrMb1 or mvy_CurrMb2 or mvy_CurrMb3)
		//Inter luma
		if (IsInterLuma)
			begin
				if (mv_is16x16)
					begin	Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0]; end
				else
					case (mv_below8x8_curr)
						1'b0:
						case (blk4x4_rec_counter[3:2])
							2'b00:begin	Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0]; end
							2'b01:begin	Inter_blk_mvx <= mvx_CurrMb1[7:0];  Inter_blk_mvy <= mvy_CurrMb1[7:0]; end
							2'b10:begin	Inter_blk_mvx <= mvx_CurrMb2[7:0];  Inter_blk_mvy <= mvy_CurrMb2[7:0]; end
							2'b11:begin	Inter_blk_mvx <= mvx_CurrMb3[7:0];  Inter_blk_mvy <= mvy_CurrMb3[7:0]; end
						 endcase
						 1'b1:
						case (blk4x4_rec_counter)
							0 :begin Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0];   end
							1 :begin Inter_blk_mvx <= mvx_CurrMb0[15:8]; Inter_blk_mvy <= mvy_CurrMb0[15:8];  end
							2 :begin Inter_blk_mvx <= mvx_CurrMb0[23:16];Inter_blk_mvy <= mvy_CurrMb0[23:16]; end
							3 :begin Inter_blk_mvx <= mvx_CurrMb0[31:24];Inter_blk_mvy <= mvy_CurrMb0[31:24]; end
							4 :begin Inter_blk_mvx <= mvx_CurrMb1[7:0];  Inter_blk_mvy <= mvy_CurrMb1[7:0];   end
							5 :begin Inter_blk_mvx <= mvx_CurrMb1[15:8]; Inter_blk_mvy <= mvy_CurrMb1[15:8];  end
							6 :begin Inter_blk_mvx <= mvx_CurrMb1[23:16];Inter_blk_mvy <= mvy_CurrMb1[23:16]; end
							7 :begin Inter_blk_mvx <= mvx_CurrMb1[31:24];Inter_blk_mvy <= mvy_CurrMb1[31:24]; end
							8 :begin Inter_blk_mvx <= mvx_CurrMb2[7:0];  Inter_blk_mvy <= mvy_CurrMb2[7:0];   end
							9 :begin Inter_blk_mvx <= mvx_CurrMb2[15:8]; Inter_blk_mvy <= mvy_CurrMb2[15:8];  end
							10:begin Inter_blk_mvx <= mvx_CurrMb2[23:16];Inter_blk_mvy <= mvy_CurrMb2[23:16]; end
							11:begin Inter_blk_mvx <= mvx_CurrMb2[31:24];Inter_blk_mvy <= mvy_CurrMb2[31:24]; end
							12:begin Inter_blk_mvx <= mvx_CurrMb3[7:0];  Inter_blk_mvy <= mvy_CurrMb3[7:0];   end
							13:begin Inter_blk_mvx <= mvx_CurrMb3[15:8]; Inter_blk_mvy <= mvy_CurrMb3[15:8];  end
							14:begin Inter_blk_mvx <= mvx_CurrMb3[23:16];Inter_blk_mvy <= mvy_CurrMb3[23:16]; end
							15:begin Inter_blk_mvx <= mvx_CurrMb3[31:24];Inter_blk_mvy <= mvy_CurrMb3[31:24]; end
							default:begin Inter_blk_mvx <= 0;Inter_blk_mvy <= 0; end
						endcase
					endcase
			end
		//Inter chroma
		else if (IsInterChroma)
			begin
				if (mv_is16x16)
					begin	Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0]; end
				else	
					case (blk4x4_rec_counter[1:0])
						2'b00:
						if (mv_below8x8_curr)	//chroma2x2 prediction
							case (Inter_chroma2x2_counter)
								3:begin Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0];   end
								2:begin Inter_blk_mvx <= mvx_CurrMb0[15:8]; Inter_blk_mvy <= mvy_CurrMb0[15:8];  end
								1:begin Inter_blk_mvx <= mvx_CurrMb0[23:16];Inter_blk_mvy <= mvy_CurrMb0[23:16]; end
								0:begin Inter_blk_mvx <= mvx_CurrMb0[31:24];Inter_blk_mvy <= mvy_CurrMb0[31:24]; end
							endcase
						else 				//chroma 4x4 prediction
							begin Inter_blk_mvx <= mvx_CurrMb0[7:0];  Inter_blk_mvy <= mvy_CurrMb0[7:0];   end
						2'b01:
						if (mv_below8x8_curr)	//need chroma2x2 prediction
							case (Inter_chroma2x2_counter)
								3:begin Inter_blk_mvx <= mvx_CurrMb1[7:0];  Inter_blk_mvy <= mvy_CurrMb1[7:0];   end
								2:begin Inter_blk_mvx <= mvx_CurrMb1[15:8]; Inter_blk_mvy <= mvy_CurrMb1[15:8];  end
								1:begin Inter_blk_mvx <= mvx_CurrMb1[23:16];Inter_blk_mvy <= mvy_CurrMb1[23:16]; end
								0:begin Inter_blk_mvx <= mvx_CurrMb1[31:24];Inter_blk_mvy <= mvy_CurrMb1[31:24]; end
							endcase
						else 				//chroma 4x4 prediction
							begin Inter_blk_mvx <= mvx_CurrMb1[7:0];  Inter_blk_mvy <= mvy_CurrMb1[7:0];   end
						2'b10:
						if (mv_below8x8_curr)	//chroma2x2 prediction
							case (Inter_chroma2x2_counter)
								3:begin Inter_blk_mvx <= mvx_CurrMb2[7:0];  Inter_blk_mvy <= mvy_CurrMb2[7:0];   end
								2:begin Inter_blk_mvx <= mvx_CurrMb2[15:8]; Inter_blk_mvy <= mvy_CurrMb2[15:8];  end
								1:begin Inter_blk_mvx <= mvx_CurrMb2[23:16];Inter_blk_mvy <= mvy_CurrMb2[23:16]; end
								0:begin Inter_blk_mvx <= mvx_CurrMb2[31:24];Inter_blk_mvy <= mvy_CurrMb2[31:24]; end
							endcase
						else 				//chroma 4x4 prediction
							begin Inter_blk_mvx <= mvx_CurrMb2[7:0];  Inter_blk_mvy <= mvy_CurrMb2[7:0];   end
						2'b11:
						if (mv_below8x8_curr)	//chroma2x2 prediction
							case (Inter_chroma2x2_counter)
								3:begin Inter_blk_mvx <= mvx_CurrMb3[7:0];  Inter_blk_mvy <= mvy_CurrMb3[7:0];   end
								2:begin Inter_blk_mvx <= mvx_CurrMb3[15:8]; Inter_blk_mvy <= mvy_CurrMb3[15:8];  end
								1:begin Inter_blk_mvx <= mvx_CurrMb3[23:16];Inter_blk_mvy <= mvy_CurrMb3[23:16]; end
								0:begin Inter_blk_mvx <= mvx_CurrMb3[31:24];Inter_blk_mvy <= mvy_CurrMb3[31:24]; end
							endcase
						else 				//chroma 4x4 prediction
							begin Inter_blk_mvx <= mvx_CurrMb3[7:0];  Inter_blk_mvy <= mvy_CurrMb3[7:0];   end
					endcase
			end
		else
			begin Inter_blk_mvx <= 0;  Inter_blk_mvy <= 0;   end
	//----------------------------------------------------------------------------------------
	//Describes the offset of each blk4x4 inside a MB
	//----------------------------------------------------------------------------------------
	// xOffset = 0  for 0,2,8, 10	yOffset = 0  for 0, 1, 4, 5
	// xOffset = 4  for 1,3,9, 11	yOffset = 4  for 2, 3, 6, 7
	// xOffset = 8  for 4,6,12,14	yOffset = 8  for 8, 9, 12,13
	// xOffset = 12 for 5,7,13,15	yOffset = 12 for 10,11,14,15
	reg [3:0] xOffsetL,yOffsetL;
	always @ (IsInterLuma or mv_below8x8_curr or blk4x4_rec_counter[2] or blk4x4_rec_counter[0])
		if (IsInterLuma)
			begin
				if (!mv_below8x8_curr)
					xOffsetL <= (blk4x4_rec_counter[2])? 4'd8:4'd0;
				else
					case ({blk4x4_rec_counter[2],blk4x4_rec_counter[0]})
						2'b00:xOffsetL <= 4'd0;
						2'b01:xOffsetL <= 4'd4;
						2'b10:xOffsetL <= 4'd8;
						2'b11:xOffsetL <= 4'd12;
					endcase
			end
		else
			xOffsetL <= 0;
			
	always @ (IsInterLuma or mv_below8x8_curr or blk4x4_rec_counter[3] or blk4x4_rec_counter[1])
		if (IsInterLuma)
			begin
				if (!mv_below8x8_curr)
					yOffsetL <= (blk4x4_rec_counter[3])? 4'd8:4'd0;
				else
					case ({blk4x4_rec_counter[3],blk4x4_rec_counter[1]})
						2'b00:yOffsetL <= 4'd0;
						2'b01:yOffsetL <= 4'd4;
						2'b10:yOffsetL <= 4'd8;
						2'b11:yOffsetL <= 4'd12;
					endcase
			end
		else
			yOffsetL <= 0;
	
	reg [2:0] xOffsetC,yOffsetC;
	always @ (IsInterChroma or mv_below8x8_curr or blk4x4_rec_counter[0] or Inter_chroma2x2_counter[0])
		if (IsInterChroma)
			begin
				if (mv_below8x8_curr == 1'b0)
					xOffsetC <= (blk4x4_rec_counter[0] == 1'b0)? 3'd0:3'd4;
				else 
					case (blk4x4_rec_counter[0])
						1'b0:xOffsetC <= (Inter_chroma2x2_counter[0] == 1'b1)? 3'd0:3'd2;
						1'b1:xOffsetC <= (Inter_chroma2x2_counter[0] == 1'b1)? 3'd4:3'd6;
					endcase
			end
		else
			xOffsetC <= 0; 
			
	always @ (IsInterChroma or mv_below8x8_curr or blk4x4_rec_counter[1] or Inter_chroma2x2_counter[1])
		if (IsInterChroma)
			begin
				if (mv_below8x8_curr == 1'b0)
					yOffsetC <= (blk4x4_rec_counter[1] == 1'b0)? 3'd0:3'd4;
				else 
					case (blk4x4_rec_counter[1])
						1'b0:yOffsetC <= (Inter_chroma2x2_counter[1] == 1'b1)? 3'd0:3'd2;
						1'b1:yOffsetC <= (Inter_chroma2x2_counter[1] == 1'b1)? 3'd4:3'd6;
					endcase
			end
		else
			yOffsetC <= 3'd0;
	//----------------------------------------------------------------------------------------
	//Integer position of each left-up-most pixel  of a 8x8/4x4/2x2 blk
	//----------------------------------------------------------------------------------------		
	wire [8:0] xIntL_unclip,yIntL_unclip;	// 2's complement,bit[8] is the sign bit
	wire [7:0] xIntC_unclip,yIntC_unclip;	// 2's complement,bit[7] is the sign bit
	assign xIntL_unclip = (IsInterLuma)?   ({1'b0,mb_num_h,4'b0} + xOffsetL + {{3{Inter_blk_mvx[7]}},Inter_blk_mvx[7:2]}):0;
	assign yIntL_unclip = (IsInterLuma)?   ({1'b0,mb_num_v,4'b0} + yOffsetL + {{3{Inter_blk_mvy[7]}},Inter_blk_mvy[7:2]}):0;
	assign xIntC_unclip = (IsInterChroma)? ({1'b0,mb_num_h,3'b0} + xOffsetC + {{3{Inter_blk_mvx[7]}},Inter_blk_mvx[7:3]}):0;
	assign yIntC_unclip = (IsInterChroma)? ({1'b0,mb_num_v,3'b0} + yOffsetC + {{3{Inter_blk_mvy[7]}},Inter_blk_mvy[7:3]}):0; 
	
	wire [8:0] xInt_org_unclip;
	wire [8:0] yInt_org_unclip;
	assign xInt_org_unclip = (IsInterLuma)? xIntL_unclip:{xIntC_unclip[7],xIntC_unclip};
	assign yInt_org_unclip = (IsInterLuma)? yIntL_unclip:{yIntC_unclip[7],yIntC_unclip};
	assign xInt_org_unclip_1to0 = xInt_org_unclip[1:0];
	//----------------------------------------------------------------------------------------
	//Fractional motion vector for both luma and chroma
	//----------------------------------------------------------------------------------------		
	wire [3:0] pos_FracL;
	wire Is_InterChromaCopy;//If chroma is predicted by direct copy,calculate cycle would reduce
							//from 16 cycles to 4 cycles
	
	assign xFracL = (IsInterLuma)?   Inter_blk_mvx[1:0]:0;
	assign yFracL = (IsInterLuma)?   Inter_blk_mvy[1:0]:0;
	assign xFracC = (IsInterChroma)? Inter_blk_mvx[2:0]:0;
	assign yFracC = (IsInterChroma)? Inter_blk_mvy[2:0]:0;
	assign pos_FracL = {xFracL,yFracL};
	assign Is_InterChromaCopy = (IsInterChroma && xFracC == 0 && yFracC == 0)? 1'b1:1'b0;
	
	//----------------------------------------------------------------------------------------
	//Inter prediction step control counter
	//---------------------------------------------------------------------------------------- 
	//1.Preload integer pels counter
	//	If block partition equals 8x8 or above,preload only at first 4x4 block of each 8x8block
	//  If block partition is 8x4,4x8 or 4x4,  preload at each 4x4 block
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_inter_preload_counter <= 0;
		//luma
		else if (trigger_blk4x4_inter_pred && IsInterLuma)
			begin
				if (!mv_below8x8_curr && blk4x4_rec_counter[1:0] == 2'b00)
					case (pos_FracL)
						`pos_Int                          :blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b00)? 6'd17:6'd25;
						`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:blk4x4_inter_preload_counter <= 6'd53;
						`pos_d,`pos_h,`pos_n              :blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b00)? 6'd27:6'd40;
						`pos_a,`pos_b,`pos_c              :blk4x4_inter_preload_counter <= 6'd33;
						`pos_e,`pos_g,`pos_p,`pos_r       :blk4x4_inter_preload_counter <= 6'd49;
					endcase
				else if (mv_below8x8_curr)	//partition below 8x8block
					case (pos_FracL)
						`pos_Int						              :blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b00)? 6'd5:6'd9;
						`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:blk4x4_inter_preload_counter <= 6'd28;
						`pos_d,`pos_h,`pos_n			        :blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b00)? 6'd10:6'd19;
						`pos_a,`pos_b,`pos_c			        :blk4x4_inter_preload_counter <= 6'd13;
						`pos_e,`pos_g,`pos_p,`pos_r		    :blk4x4_inter_preload_counter <= 6'd24;
					endcase	
			end
		//chroma
		else if (trigger_blk4x4_inter_pred && IsInterChroma && mv_below8x8_curr == 1'b0)
			begin
				if (xFracC == 0 && yFracC == 0)
					blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b00)? 6'd5:6'd9;
				else
					blk4x4_inter_preload_counter <= 6'd11;
			end
		else if (trigger_blk2x2_inter_pred && IsInterChroma && mv_below8x8_curr == 1'b1)
			begin
				if (xFracC == 0 && yFracC == 0)
					blk4x4_inter_preload_counter <= (xInt_org_unclip[1:0] == 2'b11)? 6'd5:6'd3;
				else
					blk4x4_inter_preload_counter <= (xInt_org_unclip[1]   == 1'b0 )? 6'd4:6'd7;
			end
		else if (blk4x4_inter_preload_counter != 0)
			blk4x4_inter_preload_counter <= blk4x4_inter_preload_counter - 1;
		
	//2.Calculate counter
	always @ (posedge clk)
		if (reset_n == 1'b0)
			blk4x4_inter_calculate_counter <= 0;
		//luma
		else if (IsInterLuma && ((!mv_below8x8_curr && (
										(blk4x4_rec_counter[1:0] == 2'b00 && blk4x4_inter_preload_counter == 1) || 
										(blk4x4_rec_counter[1:0] != 2'b00 && trigger_blk4x4_inter_pred))) ||
								(mv_below8x8_curr && blk4x4_inter_preload_counter == 1))) 
			case (pos_FracL)
				`pos_j,`pos_f,`pos_q:blk4x4_inter_calculate_counter <= 4'd5;
				`pos_i,`pos_k       :blk4x4_inter_calculate_counter <= 4'd8;
				default             :blk4x4_inter_calculate_counter <= 4'd4;
			endcase
		//chroma
		else if (blk4x4_inter_preload_counter == 1 && IsInterChroma == 1'b1)
			case (mv_below8x8_curr)
				1'b0:blk4x4_inter_calculate_counter <= 4'd4;
				1'b1:blk4x4_inter_calculate_counter <= 4'd1;
			endcase
		else if (blk4x4_inter_calculate_counter != 0)
			blk4x4_inter_calculate_counter <= blk4x4_inter_calculate_counter - 1;
	
	assign end_of_one_blk4x4_inter = (blk4x4_inter_calculate_counter == 4'd1 &&
	((IsInterChroma && mv_below8x8_curr && Inter_chroma2x2_counter == 2'b00) ||
	!(IsInterChroma && mv_below8x8_curr)));
	//----------------------------------------------------------------------------------------
	//Inter prediction reference frame RAM read control
	//----------------------------------------------------------------------------------------
	assign ref_frame_RAM_rd = ((IsInterLuma || IsInterChroma) && blk4x4_inter_preload_counter != 6'd0 && blk4x4_inter_preload_counter != 6'd1);
	
	//compared with blk4x4_inter_preload_counter,blk4x4_inter_preload_counter_m2 has some advantages
	//during some pos_FracL for vertical memory address decoding
	wire [5:0] blk4x4_inter_preload_counter_m2;	
	assign blk4x4_inter_preload_counter_m2 = (blk4x4_inter_preload_counter == 6'd0 || blk4x4_inter_preload_counter == 6'd1)?
												6'd0:(blk4x4_inter_preload_counter - 2);
				
	//xInt_curr_offset: offset from the left-upper most pixel of current block,ranging -2 ~ +10.
	//After each preload cycle,xInt_curr_offset will increase 4
	reg [4:0] xInt_curr_offset;
	always @ (IsInterLuma or mv_below8x8_curr or pos_FracL or xFracC or yFracC 
		or xInt_org_unclip[1:0] or blk4x4_inter_preload_counter_m2 or blk4x4_inter_preload_counter)
		if (blk4x4_inter_preload_counter != 6'd0 && blk4x4_inter_preload_counter != 6'd1)
			begin
				if (IsInterLuma)
					begin
						if (!mv_below8x8_curr)
							case (pos_FracL)
								`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
								case (blk4x4_inter_preload_counter_m2[1:0])
									2'b00:xInt_curr_offset <= 5'b01010; //+10
									2'b01:xInt_curr_offset <= 5'b00110; //+6
									2'b10:xInt_curr_offset <= 5'b00010; //+2
									2'b11:xInt_curr_offset <= 5'b11110; //-2
								endcase
								`pos_d,`pos_h,`pos_n:
								if (xInt_org_unclip[1:0] == 2'b00)
									xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0])? 4'b0:4'b0100; //+0 or +4
								else
									case (blk4x4_inter_preload_counter_m2)
										6'd38,6'd35,6'd32,6'd29,6'd26,6'd23,6'd20,6'd17,6'd14,6'd11,6'd8,6'd5,6'd2:
										xInt_curr_offset <= 5'b0; 			//+0
										6'd37,6'd34,6'd31,6'd28,6'd25,6'd22,6'd19,6'd16,6'd13,6'd10,6'd7,6'd4,6'd1:
										xInt_curr_offset <= 5'b00100;		//+4
										default:xInt_curr_offset <= 5'b01000;//+8
									endcase
								`pos_a,`pos_b,`pos_c:
								case (blk4x4_inter_preload_counter_m2[1:0])
									2'b00:xInt_curr_offset <= 5'b01010; //+10
									2'b01:xInt_curr_offset <= 5'b00110; //+6
									2'b10:xInt_curr_offset <= 5'b00010; //+2
									2'b11:xInt_curr_offset <= 5'b11110; //-2
								endcase
								`pos_Int:
								if (xInt_org_unclip[1:0] == 2'b00)
									xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0])? 5'b0:5'b0100; //+0 or +4
								else
									case (blk4x4_inter_preload_counter_m2)
										6'd23,6'd20,6'd17,6'd14,6'd11,6'd8,6'd5,6'd2:
										xInt_curr_offset <= 5'b00000;	   	//+0
										6'd22,6'd19,6'd16,6'd13,6'd10,6'd7,6'd4,6'd1:
										xInt_curr_offset <= 5'b00100;	   	//+4
										default:xInt_curr_offset <= 5'b01000;//+8
									endcase
								`pos_e,`pos_g,`pos_p,`pos_r:
								case (blk4x4_inter_preload_counter_m2)
									6'd47,6'd44,6'd5,6'd2:
									xInt_curr_offset <= 5'b00000;	//+0
									6'd46,6'd43,6'd4,6'd1:
									xInt_curr_offset <= 5'b00100;	//+4
									6'd45,6'd42,6'd3,6'd0:
									xInt_curr_offset <= 5'b01000;	//+8
									default:
									case (blk4x4_inter_preload_counter_m2[1:0])
										2'b00:xInt_curr_offset <= 5'b00010; //+2
										2'b01:xInt_curr_offset <= 5'b11110; //-2
										2'b10:xInt_curr_offset <= 5'b01010; //+10
										2'b11:xInt_curr_offset <= 5'b00110; //+6
									endcase
								endcase
							endcase
						else		//block partition below 8x8
							case (pos_FracL)
								`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
								case (blk4x4_inter_preload_counter_m2)
									6'd26,6'd23,6'd20,6'd17,6'd14,6'd11,6'd8,6'd5,6'd2:xInt_curr_offset <= 5'b11110;//-2
									6'd25,6'd22,6'd19,6'd16,6'd13,6'd10,6'd7,6'd4,6'd1:xInt_curr_offset <= 5'b00010;//+2
									default:xInt_curr_offset <= 5'b00110;											//+6
								endcase
								`pos_d,`pos_h,`pos_n:
								if (xInt_org_unclip[1:0] == 2'b00)
									xInt_curr_offset <= 5'b0;	//+0
								else
									xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0])? 5'b0:5'b00100;//+0 or +4
								`pos_a,`pos_b,`pos_c:
								case (blk4x4_inter_preload_counter_m2)
									6'd11,6'd8,6'd5,6'd2:xInt_curr_offset <= 5'b11110;	//-2
									6'd10,6'd7,6'd4,6'd1:xInt_curr_offset <= 5'b00010;	//+2
									default:xInt_curr_offset <= 5'b00110;				//+6
								endcase
								`pos_Int:
								if (xInt_org_unclip[1:0] == 2'b00)
									xInt_curr_offset <= 5'b0;	//+0
								else
									xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0])? 5'b0:5'b00100;	//+0 or +4
								`pos_e,`pos_g,`pos_p,`pos_r:
								case (blk4x4_inter_preload_counter_m2)
									6'd22,6'd20,6'd3,6'd1:xInt_curr_offset <= 5'b0;			//+0	
									6'd21,6'd19,6'd2,6'd0:xInt_curr_offset <= 5'b00100;		//+4 
									6'd18,6'd15,6'd12,6'd9,6'd6:xInt_curr_offset <= 5'b11110;//-2
									6'd17,6'd14,6'd11,6'd8,6'd5:xInt_curr_offset <= 5'b00010;//+2
									6'd16,6'd13,6'd10,6'd7,6'd4:xInt_curr_offset <= 5'b00110;//+6
									default:xInt_curr_offset <= 5'b0;
								endcase
							endcase
					end
				else	//IsInterChroma
					begin
						if (!mv_below8x8_curr)
							begin
								if (xFracC == 0 && yFracC == 0)
									begin
										if (xInt_org_unclip[1:0] == 2'b00)
											xInt_curr_offset <= 5'b0;
										else
											xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0] == 1'b1)? 5'b0:5'b0100;
									end
								else
									xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0] == 1'b1)? 5'b0:5'b0100;
							end
						else //mv_below8x8_curr == 1'b1
							begin
								if (xFracC == 0 && yFracC == 0)
									begin
										if (xInt_org_unclip[1:0] == 2'b11)	// 4 preload cycles
											xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0] == 1'b1)? 5'b0:5'b0100;
										else
											xInt_curr_offset <= 0;
									end
								else
									begin
										if (xInt_org_unclip[1] == 1'b0)
											xInt_curr_offset <= 0;
										else
											xInt_curr_offset <= (blk4x4_inter_preload_counter_m2[0] == 1'b1)? 5'b0:5'b0100;
									end
							end
					end
			end
		else	//blk4x4_inter_preload_counter == 0 || blk4x4_inter_preload_counter == 1 
			xInt_curr_offset <= 5'b0; 
	
	//Derive unclipped x pos for each preload cycle
	wire [8:0] xInt_addr_unclip;
	assign xInt_addr_unclip = xInt_org_unclip + {{4{xInt_curr_offset[4]}},xInt_curr_offset};
	
	//x addr clipped:x address in pixels
	reg [7:0] xInt_addr;
	always @ (xInt_addr_unclip or IsInterLuma or IsInterChroma)
		if (xInt_addr_unclip[8] == 1'b1)	//negative
			xInt_addr <= 0;
		else if (IsInterLuma)
			xInt_addr <= (xInt_addr_unclip[7:0] > (`pic_width - 4))? 8'd172:xInt_addr_unclip[7:0];
		else if (IsInterChroma)
			xInt_addr <= (xInt_addr_unclip[7:0] > (`half_pic_width - 4))? 8'd84:xInt_addr_unclip[7:0];
		else
			xInt_addr <= 0;
			
	//yInt_p1:when loading from Xth line to (X-1)th line,yInt_p1 is set to 1'b1 at the last
	//loading cycle of current Xth line
	reg yInt_p1;
	always @ (IsInterLuma or mv_below8x8_curr or pos_FracL or xFracC or yFracC 
		or blk4x4_inter_preload_counter or blk4x4_inter_preload_counter_m2 or xInt_org_unclip[1:0] or xInt_org_unclip[1])
		if (blk4x4_inter_preload_counter != 6'd0 && blk4x4_inter_preload_counter != 6'd1)
			begin
				if (IsInterLuma)
					case (mv_below8x8_curr)
						1'b0:
						case (pos_FracL)
							`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
							yInt_p1 <= (blk4x4_inter_preload_counter_m2[1:0] == 2'b00)? 1'b1:1'b0;
							`pos_d,`pos_h,`pos_n:
							if (xInt_org_unclip[1:0] == 2'b00)
								yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							else
								case (blk4x4_inter_preload_counter_m2)
									6'd36,6'd33,6'd30,6'd27,6'd24,6'd21,6'd18,6'd15,6'd12,6'd9,6'd6,6'd3,6'd0:
									yInt_p1 <= 1'b1;
									default:yInt_p1 <= 1'b0;
								endcase
							`pos_a,`pos_b,`pos_c:
							yInt_p1 <= (blk4x4_inter_preload_counter_m2[1:0] == 2'b00)? 1'b1:1'b0;
							`pos_Int:
							if (xInt_org_unclip[1:0] == 2'b00)
								yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							else
								case (blk4x4_inter_preload_counter_m2)
									6'd21,6'd18,6'd15,6'd12,6'd9,6'd6,6'd3,6'd0:yInt_p1 <= 1'b1;
									default:									yInt_p1 <= 1'b0;
								endcase
							`pos_e,`pos_g,`pos_p,`pos_r:
							case (blk4x4_inter_preload_counter_m2)
								6'd45,6'd42,6'd3,6'd0:yInt_p1 <= 1'b1;
								6'd6,6'd10,6'd14,6'd18,6'd22,6'd26,6'd30,6'd34,6'd38:yInt_p1 <= 1'b1;
								default:yInt_p1 <= 1'b0;
							endcase
						endcase
						1'b1:		//block partition below 8x8
						case (pos_FracL)
							`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
							case (blk4x4_inter_preload_counter_m2)
								6'd24,6'd21,6'd18,6'd15,6'd12,6'd9,6'd6,6'd3,6'd0:yInt_p1 <= 1'b1;
								default:yInt_p1 <= 1'b0;
							endcase
							`pos_d,`pos_h,`pos_n:
							if (xInt_org_unclip[1:0] == 2'b00)
								yInt_p1 <= 1'b1;	
							else
								yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							`pos_a,`pos_b,`pos_c:
							case (blk4x4_inter_preload_counter_m2)
								5'd9,5'd6,5'd3,5'd0	:yInt_p1 <= 1'b1;
								default				:yInt_p1 <= 1'b0;
							endcase
							`pos_Int:
							if (xInt_org_unclip[1:0] == 2'b00)
								yInt_p1 <= 1'b1;
							else
								yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							`pos_e,`pos_g,`pos_p,`pos_r:
							case (blk4x4_inter_preload_counter_m2)
								6'd21,6'd19,6'd2,6'd0		:yInt_p1 <= 1'b1;
								6'd4,6'd7,6'd10,6'd13,6'd16	:yInt_p1 <= 1'b1;
								default						:yInt_p1 <= 1'b0;
							endcase
						endcase
					endcase
				else	//IsInterChroma
					case (mv_below8x8_curr)
						1'b0:
						if (xFracC == 0 && yFracC == 0)
							begin
								if (xInt_org_unclip[1:0] == 2'b00)
									yInt_p1 <= 1'b1;
								else
									yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							end
						else
							yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
						1'b1:
						if (xFracC == 0 && yFracC == 0)
							begin
								if (xInt_org_unclip[1:0] != 2'b11)
									yInt_p1 <= 1'b1;
								else
									yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							end
						else
							begin
								if (xInt_org_unclip[1] == 1'b0)
									yInt_p1 <= 1'b1;
								else 
									yInt_p1 <= (blk4x4_inter_preload_counter_m2[0] == 1'b0)? 1'b1:1'b0;
							end
					endcase
			end
		else	// blk4x4_inter_preload_counter == 0 || blk4x4_inter_preload_counter == 1			
			yInt_p1 <= 1'b0; 
	
	//Derive unclipped y pos for each preload cycle
	reg [8:0] yInt_addr_unclip;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			yInt_addr_unclip <= 0;
		else if ((IsInterLuma && (trigger_blk4x4_inter_pred && (mv_below8x8_curr ||
			(!mv_below8x8_curr && blk4x4_rec_counter[1:0] == 2'b00)))) ||
			(IsInterChroma && (!mv_below8x8_curr && trigger_blk4x4_inter_pred) ||
							   (mv_below8x8_curr && trigger_blk2x2_inter_pred)))
			begin
				if (IsInterLuma)	//Luma
					case (pos_FracL)
						`pos_a,`pos_b,`pos_c,`pos_Int:
						yInt_addr_unclip <= yInt_org_unclip;
						default:				//need -2 here
						yInt_addr_unclip <= yInt_org_unclip + 9'b111111110;
					endcase
				else			   //Chroma
					yInt_addr_unclip <= yInt_org_unclip;
			end
		else if (blk4x4_inter_preload_counter_m2 != 0 && yInt_p1 == 1'b1)
			yInt_addr_unclip <= yInt_addr_unclip + 1;
		
	//y addr clipped
	reg [7:0] yInt_addr;
	always @ (yInt_addr_unclip or IsInterLuma or IsInterChroma)
		if (yInt_addr_unclip[8] == 1'b1)	//negative
			yInt_addr <= 0;
		else if (IsInterLuma)
			yInt_addr <= (yInt_addr_unclip[7:0] > (`pic_height - 1))? 8'd143:yInt_addr_unclip[7:0];
		else if (IsInterChroma)
			yInt_addr <= (yInt_addr_unclip[7:0] > (`half_pic_height - 1))? 8'd71:yInt_addr_unclip[7:0];
		else
			yInt_addr <= 0;
		
	wire [12:0] offset_constant;
	wire [10:0] yInt_addr_x11;
	wire [12:0]	offset_yInt_addr;
	assign offset_constant = (IsInterLuma)? 0:((IsInterChroma)? ((blk4x4_rec_counter < 5'd20)? 13'd6336:13'd7920):0); 
	assign yInt_addr_x11 = {yInt_addr,3'b0} + {2'b0,yInt_addr,1'b0} + {3'b0,yInt_addr};
	assign offset_yInt_addr = (IsInterLuma)? {yInt_addr_x11,2'b0}:{1'b0,yInt_addr_x11,1'b0};
	assign ref_frame_RAM_rd_addr = (offset_constant + {8'b0,xInt_addr[7:2]}) + {1'b0,offset_yInt_addr};
	
	//----------------------------------------------------------------------------------------
	//Inter prediction output control: from LPE or from CPE
	//----------------------------------------------------------------------------------------
	always @ (IsInterLuma or IsInterChroma or Is_InterChromaCopy 
		or blk4x4_inter_calculate_counter or pos_FracL
		or Inter_pix_copy0 or Inter_pix_copy1 or Inter_pix_copy2 or Inter_pix_copy3
		or LPE0_out or LPE1_out or LPE2_out or LPE3_out
		or CPE0_out or CPE1_out or CPE2_out or CPE3_out) 
		if (IsInterLuma && blk4x4_inter_calculate_counter != 0)
			begin
				Inter_blk4x4_pred_output_valid <= 2'b01;
				case (pos_FracL)
					`pos_Int:
					begin
						Inter_pred_out0 <= Inter_pix_copy0;Inter_pred_out1 <= Inter_pix_copy1;
						Inter_pred_out2 <= Inter_pix_copy2;Inter_pred_out3 <= Inter_pix_copy3;
					end
					`pos_i,`pos_k:
					if (blk4x4_inter_calculate_counter == 4'd7 || blk4x4_inter_calculate_counter == 4'd5 || 
						blk4x4_inter_calculate_counter == 4'd3 || blk4x4_inter_calculate_counter == 4'd1)
						begin
							Inter_pred_out0 <= LPE0_out;Inter_pred_out1 <= LPE1_out;
							Inter_pred_out2 <= LPE2_out;Inter_pred_out3 <= LPE3_out;
						end
					else
						begin
							Inter_pred_out0 <= 0;Inter_pred_out1 <= 0;Inter_pred_out2 <= 0;Inter_pred_out3 <= 0;
						end
					default:
					if (blk4x4_inter_calculate_counter == 4'd4 || blk4x4_inter_calculate_counter == 4'd3 || 
						blk4x4_inter_calculate_counter == 4'd2 || blk4x4_inter_calculate_counter == 4'd1)
						begin
							Inter_pred_out0 <= LPE0_out;Inter_pred_out1 <= LPE1_out;
							Inter_pred_out2 <= LPE2_out;Inter_pred_out3 <= LPE3_out;
						end
					else
						begin
							Inter_pred_out0 <= 0;Inter_pred_out1 <= 0;Inter_pred_out2 <= 0;Inter_pred_out3 <= 0;
						end
				endcase
			end
		else if (IsInterChroma && blk4x4_inter_calculate_counter != 0)
			begin
				Inter_pred_out0 <= (Is_InterChromaCopy)? Inter_pix_copy0:CPE0_out;
				Inter_pred_out1 <= (Is_InterChromaCopy)? Inter_pix_copy1:CPE1_out;
				Inter_pred_out2 <= (Is_InterChromaCopy)? Inter_pix_copy2:CPE2_out;
				Inter_pred_out3 <= (Is_InterChromaCopy)? Inter_pix_copy3:CPE3_out;
				Inter_blk4x4_pred_output_valid <= 2'b10;
			end
		else
			begin
				Inter_pred_out0 <= 0;Inter_pred_out1 <= 0;Inter_pred_out2 <= 0;Inter_pred_out3 <= 0;
				Inter_blk4x4_pred_output_valid <= 2'b00;
			end
endmodule						

			

	
	
			
			

			
			
			
					
			
			
	
	
	
			
			
				
					
			
					
			
	
			