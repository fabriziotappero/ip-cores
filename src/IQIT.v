//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : IQIT.v
// Generated : June 18, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding the residual information
// 1.The res_mb_bypass | DConly | allzero signals should be decoded first
// 2.For DC coefficients,IDCT    --> rescale
// 3.For AC coefficients,rescale --> IDCT   --> rounding
// 4.coeffLevel:zig-zag order
//   OneD_output,TwoD_output,DC_output,rescale_output,rounding_output:raster-scan order
// 5.Input coeffLevel_ext_0 ~ 15 are 2's complement,but with zig-zag order
//-------------------------------------------------------------------------------------------------
// Revise log 
// 1.March 27,2006
// DC_output: 0 ~ 15:for luma DC, 0 ~ 3:for Chroma Cb DC, 4 ~ 7:for Chroma Cr DC
// 2.March 28,2006
// 1)For Intra16x16ACLevel and chroma AC,the first coeff of IDCT is DC value, the following coeffLevel_ext_0 ~ 14 should be moved backward 1 space and coeffLevel_ext_15 is abandoned
// 2)There are some blocks which have zero DC coeff but non-zero AC coeff. Additional signals as res_LumaDCBlk_IsZero,res_ChromaDCBlk_Cb_IsZero,res_ChromaDCBlk_Cr_IsZero are added to deal with such special case  
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module IQIT (clk,reset_n,TotalCoeff,blk4x4_rec_counter,
	gclk_1D,gclk_2D,gclk_rescale,gclk_rounding,
	residual_state,cavlc_decoder_state,
	end_of_one_residual_block,end_of_NonZeroCoeff_CAVLC,
	QPy,QPc,i4x4_CbCr,
	coeffLevel_ext_0, coeffLevel_ext_1, coeffLevel_ext_2, coeffLevel_ext_3, 
	coeffLevel_ext_4, coeffLevel_ext_5, coeffLevel_ext_6, coeffLevel_ext_7,
	coeffLevel_ext_8, coeffLevel_ext_9, coeffLevel_ext_10,coeffLevel_ext_11,
	coeffLevel_ext_12,coeffLevel_ext_13,coeffLevel_ext_14,coeffLevel_ext_15,
	
	OneD_counter,TwoD_counter,rescale_counter,rounding_counter,
	curr_DC_IsZero,curr_DC_scaled,
	rounding_output_0,rounding_output_1,rounding_output_2,rounding_output_3,
	rounding_output_4,rounding_output_5,rounding_output_6,rounding_output_7,
	rounding_output_8,rounding_output_9,rounding_output_10,rounding_output_11,
	rounding_output_12,rounding_output_13,rounding_output_14,rounding_output_15,
	end_of_ACBlk4x4_IQIT,end_of_DCBlk_IQIT
	);
	input clk,reset_n;
	input [4:0] TotalCoeff;
	input [4:0] blk4x4_rec_counter;
	input gclk_1D;
	input gclk_2D;
	input gclk_rescale;
	input gclk_rounding;
	input [3:0] residual_state;
	input [3:0] cavlc_decoder_state;
	input end_of_one_residual_block;
	input end_of_NonZeroCoeff_CAVLC;
	input [5:0] QPy;
	input [5:0] QPc;
	input [1:0] i4x4_CbCr;
	input [15:0] coeffLevel_ext_0, coeffLevel_ext_1, coeffLevel_ext_2, coeffLevel_ext_3;
	input [15:0] coeffLevel_ext_4, coeffLevel_ext_5, coeffLevel_ext_6, coeffLevel_ext_7; 
	input [15:0] coeffLevel_ext_8, coeffLevel_ext_9, coeffLevel_ext_10,coeffLevel_ext_11;
	input [15:0] coeffLevel_ext_12,coeffLevel_ext_13,coeffLevel_ext_14,coeffLevel_ext_15; 
	
	
	output [2:0] OneD_counter;
	output [2:0] TwoD_counter;
	output [2:0] rescale_counter;
	output [2:0] rounding_counter;
	output curr_DC_IsZero;
	output [8:0] curr_DC_scaled;
	output [8:0] rounding_output_0, rounding_output_1, rounding_output_2, rounding_output_3;
	output [8:0] rounding_output_4, rounding_output_5, rounding_output_6, rounding_output_7;
	output [8:0] rounding_output_8, rounding_output_9, rounding_output_10,rounding_output_11;
	output [8:0] rounding_output_12,rounding_output_13,rounding_output_14,rounding_output_15;
	output end_of_ACBlk4x4_IQIT;	//end of IQIT of one blk4x4 AC
	output end_of_DCBlk_IQIT; 		//end of IQIT of one blk4x4/blk2x2 DC
	
	reg [8:0] rounding_output_0, rounding_output_1, rounding_output_2, rounding_output_3;
	reg [8:0] rounding_output_4, rounding_output_5, rounding_output_6, rounding_output_7;
	reg [8:0] rounding_output_8, rounding_output_9, rounding_output_10,rounding_output_11;
	reg [8:0] rounding_output_12,rounding_output_13,rounding_output_14,rounding_output_15;
	
	reg [2:0] OneD_counter;
	reg [2:0] TwoD_counter;
	reg [2:0] rescale_counter;
	reg [2:0] rounding_counter;
	reg [4:0] LevelScale_DC;
	reg [4:0] LevelScale_AC [3:0];
	reg [15:0] butterfly_D0,butterfly_D1,butterfly_D2,butterfly_D3;
	reg [15:0] mult0_a,mult1_a,mult2_a,mult3_a;
	reg IsLeftShift;
	reg [3:0] shift_len;
	reg [15:0] OneD_output [15:0];
	reg [15:0] TwoD_output [3:0];
	reg [15:0] rescale_output [3:0];
	reg [15:0] DC_output [15:0];
		
	wire IsHadamard;
	wire [5:0] QP;
	wire [2:0] QPmod6;
	wire [3:0] QPdiv6;
	wire [15:0] butterfly_F0,butterfly_F1,butterfly_F2,butterfly_F3;
	wire [4:0] LevelScale [3:0];
	wire [15:0] product0,product1,product2,product3;
	wire [15:0] shift_output0,shift_output1,shift_output2,shift_output3;
	wire [15:0] before_rounding0,before_rounding1,before_rounding2,before_rounding3;
	wire [9:0] rounding_sum0,rounding_sum1,rounding_sum2,rounding_sum3;	
	
	//-----------------------------------------------------------------------------------
	// Zero-block-aware decoding
	//-----------------------------------------------------------------------------------
	//Whether DC block is zero
	reg res_LumaDCBlk_IsZero;      
	reg res_ChromaDCBlk_Cb_IsZero; 
	reg res_ChromaDCBlk_Cr_IsZero;
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
	         	res_LumaDCBlk_IsZero      <= 1'b0;
	         	res_ChromaDCBlk_Cb_IsZero <= 1'b0;
	         	res_ChromaDCBlk_Cr_IsZero <= 1'b0;
			end
		else if (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT)
	    	begin
				if (residual_state == `Intra16x16DCLevel_s)	     
					res_LumaDCBlk_IsZero <= (TotalCoeff == 0)? 1'b1:1'b0;
	      if (residual_state == `ChromaDCLevel_Cb_s)	
					res_ChromaDCBlk_Cb_IsZero <= (TotalCoeff == 0)? 1'b1:1'b0;
				if (residual_state == `ChromaDCLevel_Cr_s)	
					res_ChromaDCBlk_Cr_IsZero <= (TotalCoeff == 0)? 1'b1:1'b0;
	      	end
			  
	//Whether current DC from DC_output[15:0] is zero
	//If whole DC block are all zeros or current single DC is zero,curr_DC is assigned 0
	//If current blk4x4 doesn't need DC (e.g. LumaLevel_s), curr_DC is also assigned 0
	reg [15:0] curr_DC;
	reg [15:0] curr_DC_reg;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			curr_DC_reg <= 0;
		else 
			curr_DC_reg <= curr_DC;
			
	always @ (residual_state or TotalCoeff or blk4x4_rec_counter or end_of_one_residual_block
		or res_LumaDCBlk_IsZero or res_ChromaDCBlk_Cb_IsZero or res_ChromaDCBlk_Cr_IsZero or curr_DC_reg  
		or DC_output[0]  or DC_output[1]  or DC_output[2]  or DC_output[3] 
		or DC_output[4]  or DC_output[5]  or DC_output[6]  or DC_output[7]
		or DC_output[8]  or DC_output[9]  or DC_output[10] or DC_output[11]
		or DC_output[12] or DC_output[13] or DC_output[14] or DC_output[15])
		if (residual_state == `Intra16x16ACLevel_0_s || (residual_state == `Intra16x16ACLevel_s && (end_of_one_residual_block && TotalCoeff == 0)))
			begin
				if (res_LumaDCBlk_IsZero == 1)	
					curr_DC <= 0;
				else
					case (blk4x4_rec_counter)
						0 :curr_DC <= DC_output[0];	1 :curr_DC <= DC_output[1];
						2 :curr_DC <= DC_output[2];	3 :curr_DC <= DC_output[3];
						4 :curr_DC <= DC_output[4];	5 :curr_DC <= DC_output[5];
						6 :curr_DC <= DC_output[6];	7 :curr_DC <= DC_output[7];
						8 :curr_DC <= DC_output[8];	9 :curr_DC <= DC_output[9];
						10:curr_DC <= DC_output[10];11:curr_DC <= DC_output[11];
						12:curr_DC <= DC_output[12];13:curr_DC <= DC_output[13];
						14:curr_DC <= DC_output[14];15:curr_DC <= DC_output[15];
						default:curr_DC <= curr_DC_reg;
					endcase
			end
		else if (residual_state == `ChromaACLevel_0_s || ((residual_state == `ChromaACLevel_Cb_s 
			|| residual_state == `ChromaACLevel_Cr_s) && (end_of_one_residual_block && TotalCoeff == 0)))
			begin
				if (blk4x4_rec_counter < 20)	//Cb
					begin
						if (res_ChromaDCBlk_Cb_IsZero == 1'b1)	
							curr_DC <= 0;
						else 
							case (blk4x4_rec_counter)
								16:curr_DC <= DC_output[0];17:curr_DC <= DC_output[1];
								18:curr_DC <= DC_output[2];19:curr_DC <= DC_output[3];
								default:curr_DC <= curr_DC_reg;
							endcase
					end
				else 							//Cr
					begin
						if (res_ChromaDCBlk_Cr_IsZero == 1'b1)	
							curr_DC <= 0;
						else 
							case (blk4x4_rec_counter)
								20:curr_DC <= DC_output[4];21:curr_DC <= DC_output[5];
								22:curr_DC <= DC_output[6];23:curr_DC <= DC_output[7];
								default:curr_DC <= curr_DC_reg;
							endcase
					end
			end
		else
			curr_DC <= curr_DC_reg;
	
	wire curr_DC_IsZero;
	assign curr_DC_IsZero = (curr_DC == 0);
	
	wire [15:0] curr_DC_tmp;
	wire [8:0]  curr_DC_scaled;
	assign curr_DC_tmp = curr_DC + 32;
	assign curr_DC_scaled = curr_DC_tmp[14:6];
	
	//-----------------------------------------------------------------------------------
	//residual type indicator
	//-----------------------------------------------------------------------------------
	wire res_DC;
	wire res_AC;
	wire res_luma;
	
	assign res_DC = (residual_state == `Intra16x16DCLevel_s || residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s); 
	assign res_AC = (residual_state != `rst_residual && !res_DC);
	assign res_luma   =	(residual_state == `Intra16x16DCLevel_s   || residual_state == `Intra16x16ACLevel_s ||
                       residual_state == `Intra16x16ACLevel_0_s || residual_state == `LumaLevel_s || residual_state == `LumaLevel_0_s);
	
	//1.OneD_counter:control the step of 1D in IDCT,4 cycles
	//	For ChromaDC IDCT,we combine the original 2x2 2D IDCT into a 4x4-like 1D IDCT
	//	ChromaDC: 1 cycle
	//	Others  : 4 cycles
	always @ (posedge gclk_1D or negedge reset_n)
		if (reset_n == 0)
			OneD_counter <= 0;
		else if (OneD_counter == 0)
			OneD_counter <= (residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s)? 3'b001:3'b100;
		else
			OneD_counter <= OneD_counter - 1;
			
	//2.TwoD_counter:control the step of 2D in IDCT,4 cycles
	//	ChromaDC: 0 cycle (All ChromDC transform done at 1D-DCT)
	//	Others  : 4 cycles
	always @ (posedge gclk_2D or negedge reset_n)
		if (reset_n == 0)
			TwoD_counter <= 0;
		else
			TwoD_counter <= (TwoD_counter == 0)? 3'b100:TwoD_counter - 1;
	
	//3.rescale_counter:control the step of rescale
	//	ChromaDC: 1 cycle (only 4 ChromDC coefficients)
	//	Others  : 4 cycles(16 coefficients)
	always @ (posedge gclk_rescale or negedge reset_n)
		if (reset_n == 0)
			rescale_counter <= 0;
		else if (rescale_counter != 0)
		   rescale_counter <= rescale_counter - 1;   
		else if (end_of_NonZeroCoeff_CAVLC == 1'b1)	//	AC
			rescale_counter <= 3'b100;
		else if (OneD_counter == 3'b001 && (residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s))  //ChromaDC
		   rescale_counter <= 3'b001;
		else if (TwoD_counter == 3'b100 && residual_state == `Intra16x16DCLevel_s)               //LumaDC
		   rescale_counter <= 3'b100;
					
	//4.rounding_counter
	always @ (posedge gclk_rounding or negedge reset_n)
		if (reset_n == 0)
			rounding_counter <= 0;
		else 
			rounding_counter <= (rounding_counter == 0)? 3'b100:(rounding_counter - 1);
	
	//-----------------------------------------------------------------------------------
	//rescale
	//-----------------------------------------------------------------------------------
	
	//butterfly IDCT
	//1D	DC:from coeffLevel
	//		Intra16x16 :(0,0) :from DC_output
	//					others:from rescale_output
	//		ChromaAC_Cb:(0,0) :from DC_output
	//					others:from rescale_output
	//		ChromaAC_Cr:(0,0) :from DC_output
	//					others:from rescale_output
	//		others     :from rescale_output
	//
	//2D	All from OneD_output
	assign IsHadamard = (res_DC == 1'b1 && (OneD_counter != 0 || TwoD_counter != 0))? 1'b1:1'b0;
	
	butterfly butterfly (
		.D0(butterfly_D0),
		.D1(butterfly_D1),
		.D2(butterfly_D2),
		.D3(butterfly_D3),
		.F0(butterfly_F0),
		.F1(butterfly_F1),
		.F2(butterfly_F2),
		.F3(butterfly_F3),
		.IsHadamard(IsHadamard)
		); 
	
	always @ (i4x4_CbCr or OneD_counter or TwoD_counter or blk4x4_rec_counter[3:0] or residual_state or res_AC 
		or res_LumaDCBlk_IsZero or res_ChromaDCBlk_Cb_IsZero or res_ChromaDCBlk_Cr_IsZero
		or DC_output[0]  or DC_output[1]  or DC_output[2]  or DC_output[3] 
		or DC_output[4]  or DC_output[5]  or DC_output[6]  or DC_output[7]
		or DC_output[8]  or DC_output[9]  or DC_output[10] or DC_output[11]
		or DC_output[12] or DC_output[13] or DC_output[14] or DC_output[15]
		or coeffLevel_ext_0  or coeffLevel_ext_1  or coeffLevel_ext_2  or coeffLevel_ext_3  
		or coeffLevel_ext_4  or coeffLevel_ext_5  or coeffLevel_ext_6  or coeffLevel_ext_7  
		or coeffLevel_ext_8  or coeffLevel_ext_9  or coeffLevel_ext_10 or coeffLevel_ext_11 
		or coeffLevel_ext_12 or coeffLevel_ext_13 or coeffLevel_ext_14 or coeffLevel_ext_15
		or OneD_output[0]  or OneD_output[1]  or OneD_output[2]  or OneD_output[3] 
		or OneD_output[4]  or OneD_output[5]  or OneD_output[6]  or OneD_output[7]
		or OneD_output[8]  or OneD_output[9]  or OneD_output[10] or OneD_output[11]
		or OneD_output[12] or OneD_output[13] or OneD_output[14] or OneD_output[15]
		or rescale_output[0]  or rescale_output[1]  or rescale_output[2]  or rescale_output[3])
		if (OneD_counter != 0)
			case (OneD_counter)
				3'b100:
				begin
					case (residual_state)
						`Intra16x16ACLevel_s:
						if (res_LumaDCBlk_IsZero == 1'b1)
              butterfly_D0 <= 0;
					  else
						  case (blk4x4_rec_counter[3:0])
							  4'b0000: butterfly_D0 <= DC_output[0];
                4'b0001: butterfly_D0 <= DC_output[1];
                4'b0010: butterfly_D0 <= DC_output[2];
                4'b0011: butterfly_D0 <= DC_output[3];
                4'b0100: butterfly_D0 <= DC_output[4];
                4'b0101: butterfly_D0 <= DC_output[5];
                4'b0110: butterfly_D0 <= DC_output[6];
                4'b0111: butterfly_D0 <= DC_output[7];
                4'b1000: butterfly_D0 <= DC_output[8];
                4'b1001: butterfly_D0 <= DC_output[9];
                4'b1010: butterfly_D0 <= DC_output[10];
                4'b1011: butterfly_D0 <= DC_output[11];
                4'b1100: butterfly_D0 <= DC_output[12];
                4'b1101: butterfly_D0 <= DC_output[13];
                4'b1110: butterfly_D0 <= DC_output[14];
                4'b1111: butterfly_D0 <= DC_output[15];
              endcase
            `ChromaACLevel_Cb_s:
						if(res_ChromaDCBlk_Cb_IsZero)
              butterfly_D0 <= 0;
            else   
              case (i4x4_CbCr)
                2'b00:butterfly_D0 <= DC_output[0];
                2'b01:butterfly_D0 <= DC_output[1];
                2'b10:butterfly_D0 <= DC_output[2];
                2'b11:butterfly_D0 <= DC_output[3];
              endcase
						`ChromaACLevel_Cr_s:
						if(res_ChromaDCBlk_Cr_IsZero)
              butterfly_D0 <= 0;
					  else   
					  	case (i4x4_CbCr)
								2'b00:butterfly_D0 <= DC_output[4];
						    2'b01:butterfly_D0 <= DC_output[5];
						    2'b10:butterfly_D0 <= DC_output[6];
						    2'b11:butterfly_D0 <= DC_output[7];
					    endcase
						default:	//luma DC,chroma DC,luma4x4 AC
						butterfly_D0 <= (res_AC == 1'b1)? rescale_output[0]:coeffLevel_ext_0;
					endcase
					butterfly_D1 <= (res_AC == 1'b1)? rescale_output[1]:coeffLevel_ext_1;
					butterfly_D2 <= (res_AC == 1'b1)? rescale_output[2]:coeffLevel_ext_5;
					butterfly_D3 <= (res_AC == 1'b1)? rescale_output[3]:coeffLevel_ext_6;
				end
				3'b011:
				begin
					butterfly_D0 <= (res_AC == 1'b1)? rescale_output[0]:coeffLevel_ext_2;
					butterfly_D1 <= (res_AC == 1'b1)? rescale_output[1]:coeffLevel_ext_4;
					butterfly_D2 <= (res_AC == 1'b1)? rescale_output[2]:coeffLevel_ext_7;
					butterfly_D3 <= (res_AC == 1'b1)? rescale_output[3]:coeffLevel_ext_12;
				end
				3'b010:
				begin
					butterfly_D0 <= (res_AC == 1'b1)? rescale_output[0]:coeffLevel_ext_3;
					butterfly_D1 <= (res_AC == 1'b1)? rescale_output[1]:coeffLevel_ext_8;
					butterfly_D2 <= (res_AC == 1'b1)? rescale_output[2]:coeffLevel_ext_11;
					butterfly_D3 <= (res_AC == 1'b1)? rescale_output[3]:coeffLevel_ext_13;
				end
				3'b001:
				begin
				   //luma DC
				   if (residual_state == `Intra16x16DCLevel_s)
				      begin
				         butterfly_D0 <= coeffLevel_ext_9;  butterfly_D1 <= coeffLevel_ext_10;
				         butterfly_D2 <= coeffLevel_ext_14; butterfly_D3 <= coeffLevel_ext_15;
				      end
				   //chroma DC
					else if (residual_state == `ChromaDCLevel_Cb_s || residual_state == `ChromaDCLevel_Cr_s)
					   begin
				         butterfly_D0 <= coeffLevel_ext_0; butterfly_D1 <= coeffLevel_ext_1;
				         butterfly_D2 <= coeffLevel_ext_2; butterfly_D3 <= coeffLevel_ext_3;
				      end
				   //AC
				   else
				      begin
				         butterfly_D0 <= rescale_output[0]; butterfly_D1 <= rescale_output[1];
				         butterfly_D2 <= rescale_output[2]; butterfly_D3 <= rescale_output[3];
				      end
				end
				default:
				   begin
					   butterfly_D0 <= 0; butterfly_D1 <= 0;
					   butterfly_D2 <= 0; butterfly_D3 <= 0;
				   end
			endcase
		else if (TwoD_counter != 0)
			case (TwoD_counter)
				3'b100:
				begin
					butterfly_D0 <= OneD_output[0];butterfly_D1 <= OneD_output[4];
					butterfly_D2 <= OneD_output[8];butterfly_D3 <= OneD_output[12];
				end
				3'b011:
				begin
					butterfly_D0 <= OneD_output[1];butterfly_D1 <= OneD_output[5];
					butterfly_D2 <= OneD_output[9];butterfly_D3 <= OneD_output[13];
				end
				3'b010:
				begin
					butterfly_D0 <= OneD_output[2]; butterfly_D1 <= OneD_output[6];
					butterfly_D2 <= OneD_output[10];butterfly_D3 <= OneD_output[14];
				end
				3'b001:
				begin
					butterfly_D0 <= OneD_output[3]; butterfly_D1 <= OneD_output[7];
					butterfly_D2 <= OneD_output[11];butterfly_D3 <= OneD_output[15];
				end
				default:
				begin
					butterfly_D0 <= 0; butterfly_D1 <= 0;
					butterfly_D2 <= 0; butterfly_D3 <= 0;
				end
			endcase
		else
			begin
				butterfly_D0 <= 0; butterfly_D1 <= 0;
				butterfly_D2 <= 0; butterfly_D3 <= 0;
			end
	
	assign QP = (res_luma == 1'b1)? QPy:QPc;
	mod6 mod6 (
		.qp(QP),
		.mod(QPmod6)
		);
	
	//	Specify LevelScale parameter: LevelScale_DC & LevelScale_AC 
	always @ (rescale_counter or res_DC or QPmod6)
		if (rescale_counter != 0 && res_DC == 1'b1)
			case (QPmod6)
				0:LevelScale_DC <= 10;
				1:LevelScale_DC <= 11;
				2:LevelScale_DC <= 13;
				3:LevelScale_DC <= 14;
				4:LevelScale_DC <= 16;
				5:LevelScale_DC <= 18;
				default:LevelScale_DC <= 0;
			endcase
		else
			LevelScale_DC <= 0; 
			
	always @ (rescale_counter or res_AC or QPmod6)
		if (rescale_counter != 0 && res_AC == 1'b1)
			case (rescale_counter)
        3'b100,3'b010:	//1 & 3 row
				case (QPmod6)
					3'b000:begin	LevelScale_AC[0] <= 10; LevelScale_AC[1] <= 13; LevelScale_AC[2] <= 10; LevelScale_AC[3] <= 13;	end	
					3'b001:begin	LevelScale_AC[0] <= 11; LevelScale_AC[1] <= 14; LevelScale_AC[2] <= 11; LevelScale_AC[3] <= 14;	end
					3'b010:begin	LevelScale_AC[0] <= 13; LevelScale_AC[1] <= 16; LevelScale_AC[2] <= 13; LevelScale_AC[3] <= 16;	end
					3'b011:begin	LevelScale_AC[0] <= 14; LevelScale_AC[1] <= 18; LevelScale_AC[2] <= 14; LevelScale_AC[3] <= 18;	end
					3'b100:begin	LevelScale_AC[0] <= 16; LevelScale_AC[1] <= 20; LevelScale_AC[2] <= 16; LevelScale_AC[3] <= 20;	end
					3'b101:begin	LevelScale_AC[0] <= 18; LevelScale_AC[1] <= 23; LevelScale_AC[2] <= 18; LevelScale_AC[3] <= 23;	end
					default:begin	LevelScale_AC[0] <= 0;  LevelScale_AC[1] <= 0;  LevelScale_AC[2] <= 0;  LevelScale_AC[3] <= 0;	 end
				endcase
        3'b011,3'b001:	//2 & 4 row
				case (QPmod6)
					3'b000:begin	LevelScale_AC[0] <= 13; LevelScale_AC[1] <= 16; LevelScale_AC[2] <= 13; LevelScale_AC[3] <= 16;	end	
					3'b001:begin	LevelScale_AC[0] <= 14; LevelScale_AC[1] <= 18; LevelScale_AC[2] <= 14; LevelScale_AC[3] <= 18;	end
					3'b010:begin	LevelScale_AC[0] <= 16; LevelScale_AC[1] <= 20; LevelScale_AC[2] <= 16; LevelScale_AC[3] <= 20;	end
					3'b011:begin	LevelScale_AC[0] <= 18; LevelScale_AC[1] <= 23; LevelScale_AC[2] <= 18; LevelScale_AC[3] <= 23;	end
					3'b100:begin	LevelScale_AC[0] <= 20; LevelScale_AC[1] <= 25; LevelScale_AC[2] <= 20; LevelScale_AC[3] <= 25;	end
					3'b101:begin	LevelScale_AC[0] <= 23; LevelScale_AC[1] <= 29; LevelScale_AC[2] <= 23; LevelScale_AC[3] <= 29;	end
					default:begin	LevelScale_AC[0] <= 0;  LevelScale_AC[1] <= 0;  LevelScale_AC[2] <= 0;  LevelScale_AC[3] <= 0;	end
				endcase
				default:begin	LevelScale_AC[0] <= 0; LevelScale_AC[1] <= 0; LevelScale_AC[2] <= 0; LevelScale_AC[3] <= 0;	end
      endcase
		else
			begin
				LevelScale_AC[0] <= 0; LevelScale_AC[1] <= 0;
				LevelScale_AC[2] <= 0; LevelScale_AC[3] <= 0;
			end
			
	assign LevelScale[0] = (rescale_counter == 0)? 0:((res_AC == 1)? LevelScale_AC[0]:LevelScale_DC);
	assign LevelScale[1] = (rescale_counter == 0)? 0:((res_AC == 1)? LevelScale_AC[1]:LevelScale_DC);
	assign LevelScale[2] = (rescale_counter == 0)? 0:((res_AC == 1)? LevelScale_AC[2]:LevelScale_DC);
	assign LevelScale[3] = (rescale_counter == 0)? 0:((res_AC == 1)? LevelScale_AC[3]:LevelScale_DC);
	
	//	Specify rescale multiplier input 
	always @ (residual_state or res_DC or rescale_counter 
		or OneD_output[0]  or OneD_output[1]  or OneD_output[2]  or OneD_output[3] 
		or OneD_output[4]  or OneD_output[5]  or OneD_output[6]  or OneD_output[7]
		or OneD_output[8]  or OneD_output[9]  or OneD_output[10] or OneD_output[11]
		or OneD_output[12] or OneD_output[13] or OneD_output[14] or OneD_output[15]
		or TwoD_output[0]  or TwoD_output[1]  or TwoD_output[2]  or TwoD_output[3] 
		or coeffLevel_ext_0  or coeffLevel_ext_1  or coeffLevel_ext_2  or coeffLevel_ext_3  
		or coeffLevel_ext_4  or coeffLevel_ext_5  or coeffLevel_ext_6  or coeffLevel_ext_7  
		or coeffLevel_ext_8  or coeffLevel_ext_9  or coeffLevel_ext_10 or coeffLevel_ext_11 
		or coeffLevel_ext_12 or coeffLevel_ext_13 or coeffLevel_ext_14 or coeffLevel_ext_15)
		if (residual_state == `Intra16x16DCLevel_s && rescale_counter != 0) 	//Intra16x16DC
		   begin
				mult0_a <= TwoD_output[0]; mult1_a <= TwoD_output[1];
				mult2_a <= TwoD_output[2]; mult3_a <= TwoD_output[3];
			end
		else if (res_DC == 1'b1 && rescale_counter != 0)	//ChromaDC
			begin
				mult0_a <= OneD_output[12]; mult1_a <= OneD_output[15];
				mult2_a <= OneD_output[13]; mult3_a <= OneD_output[14];
			end
		else if (rescale_counter != 0)						             //AC
			case (rescale_counter)
				3'b100:	
				begin
					mult0_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_0:0; 
					mult1_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_1:coeffLevel_ext_0;
					mult2_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_5:coeffLevel_ext_4; 
					mult3_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_6:coeffLevel_ext_5;
				end
				3'b011:
				begin
					mult0_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_2:coeffLevel_ext_1; 
					mult1_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_4:coeffLevel_ext_3;
					mult2_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_7:coeffLevel_ext_6; 
					mult3_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_12:coeffLevel_ext_11;
				end
				3'b010:
				begin
					mult0_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_3:coeffLevel_ext_2;   
					mult1_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_8:coeffLevel_ext_7;
					mult2_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_11:coeffLevel_ext_10;  
					mult3_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_13:coeffLevel_ext_12;
				end
				3'b001:
				begin
					mult0_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_9:coeffLevel_ext_8;  
					mult1_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_10:coeffLevel_ext_9;
					mult2_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_14:coeffLevel_ext_13; 
					mult3_a <= (residual_state == `LumaLevel_s)? coeffLevel_ext_15:coeffLevel_ext_14;
				end
				default:
				begin
					mult0_a <= 0; mult1_a <= 0;
					mult2_a <= 0; mult3_a <= 0;
				end
			endcase
		else 
			begin
				mult0_a <= 0; mult1_a <= 0;
				mult2_a <= 0; mult3_a <= 0;
			end
	
	//rescale multiplier 
	assign product0 = (rescale_counter == 0)? 0:mult0_a * {1'b0,LevelScale[0]};
	assign product1 = (rescale_counter == 0)? 0:mult1_a * {1'b0,LevelScale[1]};
	assign product2 = (rescale_counter == 0)? 0:mult2_a * {1'b0,LevelScale[2]};
	assign product3 = (rescale_counter == 0)? 0:mult3_a * {1'b0,LevelScale[3]};
	
	always @ (res_AC or res_luma or QPy or QPc)
		if (res_AC == 1'b1)
			IsLeftShift <= 1'b1;
		else if (res_luma == 1'b1)
			IsLeftShift <= (QPy < 12)? 1'b0:1'b1;
		else
			IsLeftShift <= (QPc < 6)? 1'b0:1'b1;
				
	div6 div6 (
		.qp(QP),
		.div(QPdiv6)
		);
		
	always @ (residual_state or res_DC or QPdiv6)
		if (residual_state == `Intra16x16DCLevel_s) //Intra16x16DC
			case (QPdiv6)
				4'b0000:shift_len <= 2;	
				4'b0001:shift_len <= 1;	
				default:shift_len <= QPdiv6 - 2;
			endcase
		else if (res_DC)						//ChromaDC
			case (QPdiv6)
				4'b0000:shift_len <= 1;
				default:shift_len <= QPdiv6 - 1;
			endcase
		else                             //AC
			shift_len <= QPdiv6;
			
	rescale_shift rescale_shift0 (
		.IsLeftShift(IsLeftShift),
		.shift_input(product0),
		.shift_len(shift_len),
		.shift_output(shift_output0)
		);
	rescale_shift rescale_shift1 (
		.IsLeftShift(IsLeftShift),
		.shift_input(product1),
		.shift_len(shift_len),
		.shift_output(shift_output1)
		);
	rescale_shift rescale_shift2 (
		.IsLeftShift(IsLeftShift),
		.shift_input(product2),
		.shift_len(shift_len),
		.shift_output(shift_output2)
		);
	rescale_shift rescale_shift3 (
		.IsLeftShift(IsLeftShift),
		.shift_input(product3),
		.shift_len(shift_len),
		.shift_output(shift_output3)
		);
	//-----------------------------------------------------------------------
	//rounding 
	//-----------------------------------------------------------------------
	assign before_rounding0 = (rounding_counter != 0)? TwoD_output[0]:0;
	assign before_rounding1 = (rounding_counter != 0)? TwoD_output[1]:0;
	assign before_rounding2 = (rounding_counter != 0)? TwoD_output[2]:0;
	assign before_rounding3 = (rounding_counter != 0)? TwoD_output[3]:0;
							   
	assign rounding_sum0 = before_rounding0[14:5] + 1;
	assign rounding_sum1 = before_rounding1[14:5] + 1;
	assign rounding_sum2 = before_rounding2[14:5] + 1;
	assign rounding_sum3 = before_rounding3[14:5] + 1; 
	
	//-----------------------------------------------------------------------
	// Strore results 
	//-----------------------------------------------------------------------
	//1.	Store OneD_output
	integer	i;	
	always @ (posedge gclk_1D or negedge reset_n)
		if (reset_n == 0)
			for (i=0;i<16;i=i+1)
				OneD_output[i] <= 0;
		else if (OneD_counter != 0)
			case (OneD_counter)
				3'b100:
				begin
					OneD_output[0] <= butterfly_F0;OneD_output[1] <= butterfly_F1;
					OneD_output[2] <= butterfly_F2;OneD_output[3] <= butterfly_F3;
				end
				3'b011:
				begin
					OneD_output[4] <= butterfly_F0;OneD_output[5] <= butterfly_F1;
					OneD_output[6] <= butterfly_F2;OneD_output[7] <= butterfly_F3;
				end
				3'b010:
				begin
					OneD_output[8]  <= butterfly_F0;OneD_output[9]  <= butterfly_F1;
					OneD_output[10] <= butterfly_F2;OneD_output[11] <= butterfly_F3;
				end
				3'b001:
				begin
					OneD_output[12] <= butterfly_F0;OneD_output[13] <= butterfly_F1;
					OneD_output[14] <= butterfly_F2;OneD_output[15] <= butterfly_F3;
				end
			endcase
	
	//2.	Store TwoD_output
	integer	j;
	always @ (posedge gclk_2D or negedge reset_n)
		if (reset_n == 0)
			for (j=0;j<4;j=j+1)
				TwoD_output[j] <= 0;
		else if (TwoD_counter != 0)
		   begin
				TwoD_output[0] <= butterfly_F0; TwoD_output[1] <= butterfly_F1;
				TwoD_output[2] <= butterfly_F2; TwoD_output[3] <= butterfly_F3;
			end
		   			
	//3.1	Store rescale_output as DC_output
	integer m;
	always @ (posedge gclk_rescale or negedge reset_n)
		if (reset_n == 1'b0)
			for (m=0;m<16;m=m+1)
				DC_output[m] <= 0;
		else if (res_DC == 1'b1) 
			case (rescale_counter)
				3'b100:
				begin
					DC_output[0] <= shift_output0;	DC_output[2]  <= shift_output1;
					DC_output[8] <= shift_output2;	DC_output[10] <= shift_output3;
				end
				3'b011:
				begin
					DC_output[1] <= shift_output0;	DC_output[3]  <= shift_output1;
					DC_output[9] <= shift_output2;	DC_output[11] <= shift_output3;
				end
				3'b010:
				begin
					DC_output[4]  <= shift_output0;	DC_output[6]  <= shift_output1;
					DC_output[12] <= shift_output2;	DC_output[14] <= shift_output3;
				end
				3'b001:
				if (residual_state == `ChromaDCLevel_Cb_s)
				   begin
					   DC_output[0] <= shift_output0;	DC_output[1] <= shift_output1;
					   DC_output[2] <= shift_output2;	DC_output[3] <= shift_output3;
				   end
				else if (residual_state == `ChromaDCLevel_Cr_s)
				   begin
					   DC_output[4] <= shift_output0;	DC_output[5] <= shift_output1;
					   DC_output[6] <= shift_output2;	DC_output[7] <= shift_output3;
				   end  
				else       
				   begin
					   DC_output[5]  <= shift_output0;	DC_output[7]  <= shift_output1;
					   DC_output[13] <= shift_output2;	DC_output[15] <= shift_output3;
				   end
			endcase	  
			
	//3.2	Store rescale_output as AC_output
	integer	n;
	always @ (posedge gclk_rescale or negedge reset_n)
		if (reset_n == 1'b0)
			for (n=0;n<4;n=n+1)
				rescale_output[n] <= 0;
		else if (res_AC == 1'b1 && rescale_counter != 0)
		   begin
				rescale_output[0] <= shift_output0;	rescale_output[1] <= shift_output1;
				rescale_output[2] <= shift_output2;	rescale_output[3] <= shift_output3;
			end 
	
	//4.	Store rounding_output
	always @ (posedge gclk_rounding or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				rounding_output_0  <= 0;rounding_output_1  <= 0;rounding_output_2  <= 0;rounding_output_3  <= 0;
				rounding_output_4  <= 0;rounding_output_5  <= 0;rounding_output_6  <= 0;rounding_output_7  <= 0;
				rounding_output_8  <= 0;rounding_output_9  <= 0;rounding_output_10 <= 0;rounding_output_11 <= 0;
				rounding_output_12 <= 0;rounding_output_13 <= 0;rounding_output_14 <= 0;rounding_output_15 <= 0;
			end
		else
			case (rounding_counter)
				3'b100:
				begin 
					rounding_output_0  <= rounding_sum0[9:1];
					rounding_output_4  <= rounding_sum1[9:1];
					rounding_output_8  <= rounding_sum2[9:1];
					rounding_output_12 <= rounding_sum3[9:1];
				end
				3'b011:
				begin 
					rounding_output_1  <= rounding_sum0[9:1];
					rounding_output_5  <= rounding_sum1[9:1];
					rounding_output_9  <= rounding_sum2[9:1];
					rounding_output_13 <= rounding_sum3[9:1];
				end
				3'b010:
				begin 
					rounding_output_2  <= rounding_sum0[9:1];
					rounding_output_6  <= rounding_sum1[9:1];
					rounding_output_10 <= rounding_sum2[9:1];
					rounding_output_14 <= rounding_sum3[9:1];
				end
				3'b001:
				begin 
					rounding_output_3  <= rounding_sum0[9:1];
					rounding_output_7  <= rounding_sum1[9:1];
					rounding_output_11 <= rounding_sum2[9:1];
					rounding_output_15 <= rounding_sum3[9:1];
				end
			endcase
	assign end_of_ACBlk4x4_IQIT = (rounding_counter == 3'b001)? 1'b1:1'b0;
	assign end_of_DCBlk_IQIT  = ((residual_state == `Intra16x16DCLevel_s || residual_state == `ChromaDCLevel_Cb_s || 
                                residual_state == `ChromaDCLevel_Cr_s) && rescale_counter == 3'b001)? 1'b1:1'b0;
endmodule
	
module butterfly (D0,D1,D2,D3,F0,F1,F2,F3,IsHadamard);
	input [15:0] D0,D1,D2,D3;
	input IsHadamard;
	output [15:0] F0,F1,F2,F3;
	
	wire [15:0] T0,T1,T2,T3;
	wire [15:0] D1_scale,D3_scale;
	
	assign D1_scale = (IsHadamard == 1'b1)? D1:{D1[15],D1[15:1]};
	assign D3_scale = (IsHadamard == 1'b1)? D3:{D3[15],D3[15:1]};
	
	assign T0 = D0 + D2;
	assign T1 = D0 - D2;
	assign T2 = D1_scale - D3;
	assign T3 = D1 + D3_scale;
	
	assign F0 = T0 + T3;
	assign F1 = T1 + T2;
	assign F2 = T1 - T2;
	assign F3 = T0 - T3;
endmodule

module mod6 (qp,mod);
	input [5:0] qp;
	output [2:0] mod;
	reg [2:0] mod;
	always @ (qp)
		case (qp)
			0, 6,12,18,24,30,36,42,48:mod <= 3'b000;
			1, 7,13,19,25,31,37,43,49:mod <= 3'b001;
			2, 8,14,20,26,32,38,44,50:mod <= 3'b010;
			3, 9,15,21,27,33,39,45,51:mod <= 3'b011;
			4,10,16,22,28,34,40,46   :mod <= 3'b100;
			5,11,17,23,29,35,41,47   :mod <= 3'b101;
			default                  :mod <= 3'b000;
		endcase
endmodule

module div6 (qp,div);
	input [5:0] qp;
	output [3:0] div;
	reg [3:0] div;
	always @ (qp)
		case (qp)
			0, 1, 2, 3, 4, 5 :div <= 4'b0000;
			6, 7, 8, 9, 10,11:div <= 4'b0001;
			12,13,14,15,16,17:div <= 4'b0010;
			18,19,20,21,22,23:div <= 4'b0011;
			24,25,26,27,28,29:div <= 4'b0100;
			30,31,32,33,34,35:div <= 4'b0101;
			36,37,38,39,40,41:div <= 4'b0110;
			42,43,44,45,46,47:div <= 4'b0111;
			48,49,50,51      :div <= 4'b1000;
			default          :div <= 0;
		endcase
endmodule

module rescale_shift (IsLeftShift,shift_input,shift_len,shift_output);
	input IsLeftShift;
	input signed [15:0] shift_input;
	input [3:0] shift_len;
	output signed [15:0] shift_output;
	
	assign shift_output = (IsLeftShift == 1'b1)? (shift_input <<< shift_len):(shift_input >>> shift_len);
endmodule
			
	
	
					
				
			
	
			
		
		
			
			
			
			
	