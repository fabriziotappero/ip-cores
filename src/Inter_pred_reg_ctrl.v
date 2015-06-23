//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Inter_pred_reg_ctrl.v
// Generated : Oct 17, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Prepare the appropriate registers for Inter prediction (luma & chroma) 
// Including padding
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Inter_pred_reg_ctrl (gclk_Inter_ref_rf,reset_n,blk4x4_inter_preload_counter,ref_frame_RAM_dout,
	IsInterLuma,IsInterChroma,xInt_addr_unclip,xInt_org_unclip_1to0,pos_FracL,xFracC,yFracC,mv_below8x8_curr,
		
	Inter_ref_00_00,Inter_ref_01_00,Inter_ref_02_00,Inter_ref_03_00,Inter_ref_04_00,Inter_ref_05_00,
	Inter_ref_06_00,Inter_ref_07_00,Inter_ref_08_00,Inter_ref_09_00,Inter_ref_10_00,Inter_ref_11_00,Inter_ref_12_00,
	Inter_ref_00_01,Inter_ref_01_01,Inter_ref_02_01,Inter_ref_03_01,Inter_ref_04_01,Inter_ref_05_01,
	Inter_ref_06_01,Inter_ref_07_01,Inter_ref_08_01,Inter_ref_09_01,Inter_ref_10_01,Inter_ref_11_01,Inter_ref_12_01,
	Inter_ref_00_02,Inter_ref_01_02,Inter_ref_02_02,Inter_ref_03_02,Inter_ref_04_02,Inter_ref_05_02,
	Inter_ref_06_02,Inter_ref_07_02,Inter_ref_08_02,Inter_ref_09_02,Inter_ref_10_02,Inter_ref_11_02,Inter_ref_12_02,
	Inter_ref_00_03,Inter_ref_01_03,Inter_ref_02_03,Inter_ref_03_03,Inter_ref_04_03,Inter_ref_05_03,
	Inter_ref_06_03,Inter_ref_07_03,Inter_ref_08_03,Inter_ref_09_03,Inter_ref_10_03,Inter_ref_11_03,Inter_ref_12_03,
	Inter_ref_00_04,Inter_ref_01_04,Inter_ref_02_04,Inter_ref_03_04,Inter_ref_04_04,Inter_ref_05_04,
	Inter_ref_06_04,Inter_ref_07_04,Inter_ref_08_04,Inter_ref_09_04,Inter_ref_10_04,Inter_ref_11_04,Inter_ref_12_04,
	Inter_ref_00_05,Inter_ref_01_05,Inter_ref_02_05,Inter_ref_03_05,Inter_ref_04_05,Inter_ref_05_05,
	Inter_ref_06_05,Inter_ref_07_05,Inter_ref_08_05,Inter_ref_09_05,Inter_ref_10_05,Inter_ref_11_05,Inter_ref_12_05,
	Inter_ref_00_06,Inter_ref_01_06,Inter_ref_02_06,Inter_ref_03_06,Inter_ref_04_06,Inter_ref_05_06,
	Inter_ref_06_06,Inter_ref_07_06,Inter_ref_08_06,Inter_ref_09_06,Inter_ref_10_06,Inter_ref_11_06,Inter_ref_12_06,
	Inter_ref_00_07,Inter_ref_01_07,Inter_ref_02_07,Inter_ref_03_07,Inter_ref_04_07,Inter_ref_05_07,
	Inter_ref_06_07,Inter_ref_07_07,Inter_ref_08_07,Inter_ref_09_07,Inter_ref_10_07,Inter_ref_11_07,Inter_ref_12_07,
	Inter_ref_00_08,Inter_ref_01_08,Inter_ref_02_08,Inter_ref_03_08,Inter_ref_04_08,Inter_ref_05_08,
	Inter_ref_06_08,Inter_ref_07_08,Inter_ref_08_08,Inter_ref_09_08,Inter_ref_10_08,Inter_ref_11_08,Inter_ref_12_08,
	Inter_ref_00_09,Inter_ref_01_09,Inter_ref_02_09,Inter_ref_03_09,Inter_ref_04_09,Inter_ref_05_09,
	Inter_ref_06_09,Inter_ref_07_09,Inter_ref_08_09,Inter_ref_09_09,Inter_ref_10_09,Inter_ref_11_09,Inter_ref_12_09,
	Inter_ref_00_10,Inter_ref_01_10,Inter_ref_02_10,Inter_ref_03_10,Inter_ref_04_10,Inter_ref_05_10,
	Inter_ref_06_10,Inter_ref_07_10,Inter_ref_08_10,Inter_ref_09_10,Inter_ref_10_10,Inter_ref_11_10,Inter_ref_12_10,
	Inter_ref_00_11,Inter_ref_01_11,Inter_ref_02_11,Inter_ref_03_11,Inter_ref_04_11,Inter_ref_05_11,
	Inter_ref_06_11,Inter_ref_07_11,Inter_ref_08_11,Inter_ref_09_11,Inter_ref_10_11,Inter_ref_11_11,Inter_ref_12_11,
	Inter_ref_00_12,Inter_ref_01_12,Inter_ref_02_12,Inter_ref_03_12,Inter_ref_04_12,Inter_ref_05_12,
	Inter_ref_06_12,Inter_ref_07_12,Inter_ref_08_12,Inter_ref_09_12,Inter_ref_10_12,Inter_ref_11_12,Inter_ref_12_12);
	
	input gclk_Inter_ref_rf;
	input reset_n;
	input [5:0] blk4x4_inter_preload_counter;
	input [31:0] ref_frame_RAM_dout;
	input IsInterLuma,IsInterChroma;
	input [8:0] xInt_addr_unclip;
	input [1:0] xInt_org_unclip_1to0;
	input [3:0] pos_FracL;
	input [2:0] xFracC,yFracC;
	input mv_below8x8_curr;
		
	output [7:0] Inter_ref_00_00,Inter_ref_01_00,Inter_ref_02_00,Inter_ref_03_00,Inter_ref_04_00,Inter_ref_05_00;
	output [7:0] Inter_ref_06_00,Inter_ref_07_00,Inter_ref_08_00,Inter_ref_09_00,Inter_ref_10_00,Inter_ref_11_00,Inter_ref_12_00;
	output [7:0] Inter_ref_00_01,Inter_ref_01_01,Inter_ref_02_01,Inter_ref_03_01,Inter_ref_04_01,Inter_ref_05_01;
	output [7:0] Inter_ref_06_01,Inter_ref_07_01,Inter_ref_08_01,Inter_ref_09_01,Inter_ref_10_01,Inter_ref_11_01,Inter_ref_12_01;
	output [7:0] Inter_ref_00_02,Inter_ref_01_02,Inter_ref_02_02,Inter_ref_03_02,Inter_ref_04_02,Inter_ref_05_02;
	output [7:0] Inter_ref_06_02,Inter_ref_07_02,Inter_ref_08_02,Inter_ref_09_02,Inter_ref_10_02,Inter_ref_11_02,Inter_ref_12_02;
	output [7:0] Inter_ref_00_03,Inter_ref_01_03,Inter_ref_02_03,Inter_ref_03_03,Inter_ref_04_03,Inter_ref_05_03;
	output [7:0] Inter_ref_06_03,Inter_ref_07_03,Inter_ref_08_03,Inter_ref_09_03,Inter_ref_10_03,Inter_ref_11_03,Inter_ref_12_03;
	output [7:0] Inter_ref_00_04,Inter_ref_01_04,Inter_ref_02_04,Inter_ref_03_04,Inter_ref_04_04,Inter_ref_05_04;
	output [7:0] Inter_ref_06_04,Inter_ref_07_04,Inter_ref_08_04,Inter_ref_09_04,Inter_ref_10_04,Inter_ref_11_04,Inter_ref_12_04;
	output [7:0] Inter_ref_00_05,Inter_ref_01_05,Inter_ref_02_05,Inter_ref_03_05,Inter_ref_04_05,Inter_ref_05_05;
	output [7:0] Inter_ref_06_05,Inter_ref_07_05,Inter_ref_08_05,Inter_ref_09_05,Inter_ref_10_05,Inter_ref_11_05,Inter_ref_12_05;
	output [7:0] Inter_ref_00_06,Inter_ref_01_06,Inter_ref_02_06,Inter_ref_03_06,Inter_ref_04_06,Inter_ref_05_06;
	output [7:0] Inter_ref_06_06,Inter_ref_07_06,Inter_ref_08_06,Inter_ref_09_06,Inter_ref_10_06,Inter_ref_11_06,Inter_ref_12_06;
	output [7:0] Inter_ref_00_07,Inter_ref_01_07,Inter_ref_02_07,Inter_ref_03_07,Inter_ref_04_07,Inter_ref_05_07;
	output [7:0] Inter_ref_06_07,Inter_ref_07_07,Inter_ref_08_07,Inter_ref_09_07,Inter_ref_10_07,Inter_ref_11_07,Inter_ref_12_07;
	output [7:0] Inter_ref_00_08,Inter_ref_01_08,Inter_ref_02_08,Inter_ref_03_08,Inter_ref_04_08,Inter_ref_05_08;
	output [7:0] Inter_ref_06_08,Inter_ref_07_08,Inter_ref_08_08,Inter_ref_09_08,Inter_ref_10_08,Inter_ref_11_08,Inter_ref_12_08;
	output [7:0] Inter_ref_00_09,Inter_ref_01_09,Inter_ref_02_09,Inter_ref_03_09,Inter_ref_04_09,Inter_ref_05_09;
	output [7:0] Inter_ref_06_09,Inter_ref_07_09,Inter_ref_08_09,Inter_ref_09_09,Inter_ref_10_09,Inter_ref_11_09,Inter_ref_12_09;
	output [7:0] Inter_ref_00_10,Inter_ref_01_10,Inter_ref_02_10,Inter_ref_03_10,Inter_ref_04_10,Inter_ref_05_10;
	output [7:0] Inter_ref_06_10,Inter_ref_07_10,Inter_ref_08_10,Inter_ref_09_10,Inter_ref_10_10,Inter_ref_11_10,Inter_ref_12_10;
	output [7:0] Inter_ref_00_11,Inter_ref_01_11,Inter_ref_02_11,Inter_ref_03_11,Inter_ref_04_11,Inter_ref_05_11;
	output [7:0] Inter_ref_06_11,Inter_ref_07_11,Inter_ref_08_11,Inter_ref_09_11,Inter_ref_10_11,Inter_ref_11_11,Inter_ref_12_11;
	output [7:0] Inter_ref_00_12,Inter_ref_01_12,Inter_ref_02_12,Inter_ref_03_12,Inter_ref_04_12,Inter_ref_05_12;
	output [7:0] Inter_ref_06_12,Inter_ref_07_12,Inter_ref_08_12,Inter_ref_09_12,Inter_ref_10_12,Inter_ref_11_12,Inter_ref_12_12;
	
	reg [7:0] Inter_ref_00_00,Inter_ref_01_00,Inter_ref_02_00,Inter_ref_03_00,Inter_ref_04_00,Inter_ref_05_00;
	reg [7:0] Inter_ref_06_00,Inter_ref_07_00,Inter_ref_08_00,Inter_ref_09_00,Inter_ref_10_00,Inter_ref_11_00,Inter_ref_12_00;
	reg [7:0] Inter_ref_00_01,Inter_ref_01_01,Inter_ref_02_01,Inter_ref_03_01,Inter_ref_04_01,Inter_ref_05_01;
	reg [7:0] Inter_ref_06_01,Inter_ref_07_01,Inter_ref_08_01,Inter_ref_09_01,Inter_ref_10_01,Inter_ref_11_01,Inter_ref_12_01;
	reg [7:0] Inter_ref_00_02,Inter_ref_01_02,Inter_ref_02_02,Inter_ref_03_02,Inter_ref_04_02,Inter_ref_05_02;
	reg [7:0] Inter_ref_06_02,Inter_ref_07_02,Inter_ref_08_02,Inter_ref_09_02,Inter_ref_10_02,Inter_ref_11_02,Inter_ref_12_02;
	reg [7:0] Inter_ref_00_03,Inter_ref_01_03,Inter_ref_02_03,Inter_ref_03_03,Inter_ref_04_03,Inter_ref_05_03;
	reg [7:0] Inter_ref_06_03,Inter_ref_07_03,Inter_ref_08_03,Inter_ref_09_03,Inter_ref_10_03,Inter_ref_11_03,Inter_ref_12_03;
	reg [7:0] Inter_ref_00_04,Inter_ref_01_04,Inter_ref_02_04,Inter_ref_03_04,Inter_ref_04_04,Inter_ref_05_04;
	reg [7:0] Inter_ref_06_04,Inter_ref_07_04,Inter_ref_08_04,Inter_ref_09_04,Inter_ref_10_04,Inter_ref_11_04,Inter_ref_12_04;
	reg [7:0] Inter_ref_00_05,Inter_ref_01_05,Inter_ref_02_05,Inter_ref_03_05,Inter_ref_04_05,Inter_ref_05_05;
	reg [7:0] Inter_ref_06_05,Inter_ref_07_05,Inter_ref_08_05,Inter_ref_09_05,Inter_ref_10_05,Inter_ref_11_05,Inter_ref_12_05;
	reg [7:0] Inter_ref_00_06,Inter_ref_01_06,Inter_ref_02_06,Inter_ref_03_06,Inter_ref_04_06,Inter_ref_05_06;
	reg [7:0] Inter_ref_06_06,Inter_ref_07_06,Inter_ref_08_06,Inter_ref_09_06,Inter_ref_10_06,Inter_ref_11_06,Inter_ref_12_06;
	reg [7:0] Inter_ref_00_07,Inter_ref_01_07,Inter_ref_02_07,Inter_ref_03_07,Inter_ref_04_07,Inter_ref_05_07;
	reg [7:0] Inter_ref_06_07,Inter_ref_07_07,Inter_ref_08_07,Inter_ref_09_07,Inter_ref_10_07,Inter_ref_11_07,Inter_ref_12_07;
	reg [7:0] Inter_ref_00_08,Inter_ref_01_08,Inter_ref_02_08,Inter_ref_03_08,Inter_ref_04_08,Inter_ref_05_08;
	reg [7:0] Inter_ref_06_08,Inter_ref_07_08,Inter_ref_08_08,Inter_ref_09_08,Inter_ref_10_08,Inter_ref_11_08,Inter_ref_12_08;
	reg [7:0] Inter_ref_00_09,Inter_ref_01_09,Inter_ref_02_09,Inter_ref_03_09,Inter_ref_04_09,Inter_ref_05_09;
	reg [7:0] Inter_ref_06_09,Inter_ref_07_09,Inter_ref_08_09,Inter_ref_09_09,Inter_ref_10_09,Inter_ref_11_09,Inter_ref_12_09;
	reg [7:0] Inter_ref_00_10,Inter_ref_01_10,Inter_ref_02_10,Inter_ref_03_10,Inter_ref_04_10,Inter_ref_05_10;
	reg [7:0] Inter_ref_06_10,Inter_ref_07_10,Inter_ref_08_10,Inter_ref_09_10,Inter_ref_10_10,Inter_ref_11_10,Inter_ref_12_10;
	reg [7:0] Inter_ref_00_11,Inter_ref_01_11,Inter_ref_02_11,Inter_ref_03_11,Inter_ref_04_11,Inter_ref_05_11;
	reg [7:0] Inter_ref_06_11,Inter_ref_07_11,Inter_ref_08_11,Inter_ref_09_11,Inter_ref_10_11,Inter_ref_11_11,Inter_ref_12_11;
	reg [7:0] Inter_ref_00_12,Inter_ref_01_12,Inter_ref_02_12,Inter_ref_03_12,Inter_ref_04_12,Inter_ref_05_12;
	reg [7:0] Inter_ref_06_12,Inter_ref_07_12,Inter_ref_08_12,Inter_ref_09_12,Inter_ref_10_12,Inter_ref_11_12,Inter_ref_12_12;
		
	//-------------------------------------------------------------------------
	//out of bound padding
	//-------------------------------------------------------------------------
	//In original version where ext_frame_RAM is read async,no need to latch xInt_addr_unclip
	//since it is used here in the same cycle as it is generated in Inter_pred_pipeline module.
	//However,when ext_frame_RAM is changed to sync read,xInt_addr_unclip will be used one cyle later. 
	reg [8:0] xInt_addr_unclip_reg;
	always @ (posedge gclk_Inter_ref_rf or negedge reset_n)
		if (reset_n == 1'b0)
			xInt_addr_unclip_reg <= 0;
		else
			xInt_addr_unclip_reg <= xInt_addr_unclip;
			
	reg [31:0] RefFrameOutPadding; 
	always @ (xInt_addr_unclip_reg or ref_frame_RAM_dout or IsInterLuma or IsInterChroma)
		if (xInt_addr_unclip_reg[8] == 1'b1)									//out of left bound
			RefFrameOutPadding <= {ref_frame_RAM_dout[7:0],ref_frame_RAM_dout[7:0],
								   ref_frame_RAM_dout[7:0],ref_frame_RAM_dout[7:0]};
		else 
			begin
				if ((IsInterLuma   && xInt_addr_unclip_reg[7:2] > 6'b101011) ||  //out of right bound
					(IsInterChroma && xInt_addr_unclip_reg[7:2] > 6'b010101))
					RefFrameOutPadding <= {ref_frame_RAM_dout[31:24],ref_frame_RAM_dout[31:24],
								   		   ref_frame_RAM_dout[31:24],ref_frame_RAM_dout[31:24]};
				else
					RefFrameOutPadding <= ref_frame_RAM_dout; 
			end
	//-------------------------------------------------------------------------
	//Inter_ref_00_00 ~ Inter_ref_12_12
	//-------------------------------------------------------------------------
	always @ (posedge gclk_Inter_ref_rf or negedge reset_n)
		if (reset_n == 0)
			begin
				Inter_ref_00_00 <= 0;Inter_ref_01_00 <= 0;Inter_ref_02_00 <= 0;Inter_ref_03_00 <= 0;
				Inter_ref_04_00 <= 0;Inter_ref_05_00 <= 0;Inter_ref_06_00 <= 0;Inter_ref_07_00 <= 0;
				Inter_ref_08_00 <= 0;Inter_ref_09_00 <= 0;Inter_ref_10_00 <= 0;Inter_ref_11_00 <= 0;Inter_ref_12_00 <= 0;
				Inter_ref_00_01 <= 0;Inter_ref_01_01 <= 0;Inter_ref_02_01 <= 0;Inter_ref_03_01 <= 0;
				Inter_ref_04_01 <= 0;Inter_ref_05_01 <= 0;Inter_ref_06_01 <= 0;Inter_ref_07_01 <= 0;
				Inter_ref_08_01 <= 0;Inter_ref_09_01 <= 0;Inter_ref_10_01 <= 0;Inter_ref_11_01 <= 0;Inter_ref_12_01 <= 0;
				Inter_ref_00_02 <= 0;Inter_ref_01_02 <= 0;Inter_ref_02_02 <= 0;Inter_ref_03_02 <= 0;
				Inter_ref_04_02 <= 0;Inter_ref_05_02 <= 0;Inter_ref_06_02 <= 0;Inter_ref_07_02 <= 0;
				Inter_ref_08_02 <= 0;Inter_ref_09_02 <= 0;Inter_ref_10_02 <= 0;Inter_ref_11_02 <= 0;Inter_ref_12_02 <= 0;
				Inter_ref_00_03 <= 0;Inter_ref_01_03 <= 0;Inter_ref_02_03 <= 0;Inter_ref_03_03 <= 0;
				Inter_ref_04_03 <= 0;Inter_ref_05_03 <= 0;Inter_ref_06_03 <= 0;Inter_ref_07_03 <= 0;
				Inter_ref_08_03 <= 0;Inter_ref_09_03 <= 0;Inter_ref_10_03 <= 0;Inter_ref_11_03 <= 0;Inter_ref_12_03 <= 0;
				Inter_ref_00_04 <= 0;Inter_ref_01_04 <= 0;Inter_ref_02_04 <= 0;Inter_ref_03_04 <= 0;
				Inter_ref_04_04 <= 0;Inter_ref_05_04 <= 0;Inter_ref_06_04 <= 0;Inter_ref_07_04 <= 0;
				Inter_ref_08_04 <= 0;Inter_ref_09_04 <= 0;Inter_ref_10_04 <= 0;Inter_ref_11_04 <= 0;Inter_ref_12_04 <= 0;
				Inter_ref_00_05 <= 0;Inter_ref_01_05 <= 0;Inter_ref_02_05 <= 0;Inter_ref_03_05 <= 0;
				Inter_ref_04_05 <= 0;Inter_ref_05_05 <= 0;Inter_ref_06_05 <= 0;Inter_ref_07_05 <= 0;
				Inter_ref_08_05 <= 0;Inter_ref_09_05 <= 0;Inter_ref_10_05 <= 0;Inter_ref_11_05 <= 0;Inter_ref_12_05 <= 0;
				Inter_ref_00_06 <= 0;Inter_ref_01_06 <= 0;Inter_ref_02_06 <= 0;Inter_ref_03_06 <= 0;
				Inter_ref_04_06 <= 0;Inter_ref_05_06 <= 0;Inter_ref_06_06 <= 0;Inter_ref_07_06 <= 0;
				Inter_ref_08_06 <= 0;Inter_ref_09_06 <= 0;Inter_ref_10_06 <= 0;Inter_ref_11_06 <= 0;Inter_ref_12_06 <= 0;
				Inter_ref_00_07 <= 0;Inter_ref_01_07 <= 0;Inter_ref_02_07 <= 0;Inter_ref_03_07 <= 0;
				Inter_ref_04_07 <= 0;Inter_ref_05_07 <= 0;Inter_ref_06_07 <= 0;Inter_ref_07_07 <= 0;
				Inter_ref_08_07 <= 0;Inter_ref_09_07 <= 0;Inter_ref_10_07 <= 0;Inter_ref_11_07 <= 0;Inter_ref_12_07 <= 0;
				Inter_ref_00_08 <= 0;Inter_ref_01_08 <= 0;Inter_ref_02_08 <= 0;Inter_ref_03_08 <= 0;
				Inter_ref_04_08 <= 0;Inter_ref_05_08 <= 0;Inter_ref_06_08 <= 0;Inter_ref_07_08 <= 0;
				Inter_ref_08_08 <= 0;Inter_ref_09_08 <= 0;Inter_ref_10_08 <= 0;Inter_ref_11_08 <= 0;Inter_ref_12_08 <= 0;
				Inter_ref_00_09 <= 0;Inter_ref_01_09 <= 0;Inter_ref_02_09 <= 0;Inter_ref_03_09 <= 0;
				Inter_ref_04_09 <= 0;Inter_ref_05_09 <= 0;Inter_ref_06_09 <= 0;Inter_ref_07_09 <= 0;
				Inter_ref_08_09 <= 0;Inter_ref_09_09 <= 0;Inter_ref_10_09 <= 0;Inter_ref_11_09 <= 0;Inter_ref_12_09 <= 0;
				Inter_ref_00_10 <= 0;Inter_ref_01_10 <= 0;Inter_ref_02_10 <= 0;Inter_ref_03_10 <= 0;
				Inter_ref_04_10 <= 0;Inter_ref_05_10 <= 0;Inter_ref_06_10 <= 0;Inter_ref_07_10 <= 0;
				Inter_ref_08_10 <= 0;Inter_ref_09_10 <= 0;Inter_ref_10_10 <= 0;Inter_ref_11_10 <= 0;Inter_ref_12_10 <= 0;
				Inter_ref_00_11 <= 0;Inter_ref_01_11 <= 0;Inter_ref_02_11 <= 0;Inter_ref_03_11 <= 0;
				Inter_ref_04_11 <= 0;Inter_ref_05_11 <= 0;Inter_ref_06_11 <= 0;Inter_ref_07_11 <= 0;
				Inter_ref_08_11 <= 0;Inter_ref_09_11 <= 0;Inter_ref_10_11 <= 0;Inter_ref_11_11 <= 0;Inter_ref_12_11 <= 0;
				Inter_ref_00_12 <= 0;Inter_ref_01_12 <= 0;Inter_ref_02_12 <= 0;Inter_ref_03_12 <= 0;
				Inter_ref_04_12 <= 0;Inter_ref_05_12 <= 0;Inter_ref_06_12 <= 0;Inter_ref_07_12 <= 0;
				Inter_ref_08_12 <= 0;Inter_ref_09_12 <= 0;Inter_ref_10_12 <= 0;Inter_ref_11_12 <= 0;Inter_ref_12_12 <= 0;
			end
		else if (IsInterLuma && blk4x4_inter_preload_counter != 0)
			case (mv_below8x8_curr)
				1'b0:
				case (pos_FracL)
					`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd52:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
							6'd51:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding;
							6'd50:{Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00} <= RefFrameOutPadding;
							6'd49:{Inter_ref_12_00,Inter_ref_11_00,Inter_ref_10_00} 				<= RefFrameOutPadding[23:0];
							6'd48:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
							6'd47:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding;
							6'd46:{Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01} <= RefFrameOutPadding;
							6'd45:{Inter_ref_12_01,Inter_ref_11_01,Inter_ref_10_01} 				<= RefFrameOutPadding[23:0];
							6'd44:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
							6'd43:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd42:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding;
							6'd41:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02} 				<= RefFrameOutPadding[23:0];
							6'd40:{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
							6'd39:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd38:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding;
							6'd37:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03} 				<= RefFrameOutPadding[23:0];
							6'd36:{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];
							6'd35:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd34:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding;
							6'd33:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04} 				<= RefFrameOutPadding[23:0];
							6'd32:{Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:16];
							6'd31:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd30:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding;
							6'd29:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05} 				<= RefFrameOutPadding[23:0];
							6'd28:{Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:16];
							6'd27:{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd26:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding;
							6'd25:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06} 				<= RefFrameOutPadding[23:0];
							6'd24:{Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:16];
							6'd23:{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding;
							6'd21:{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07} 				<= RefFrameOutPadding[23:0];
							6'd20:{Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:16];
							6'd19:{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
							6'd18:{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding;
							6'd17:{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08} 				<= RefFrameOutPadding[23:0];
							6'd16:{Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding[31:16];
							6'd15:{Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding;
							6'd14:{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09} <= RefFrameOutPadding;
							6'd13:{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09} 				<= RefFrameOutPadding[23:0];
							6'd12:{Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_12_10,Inter_ref_11_10,Inter_ref_10_10} 				<= RefFrameOutPadding[23:0];
							6'd8 :{Inter_ref_01_11,Inter_ref_00_11} <= RefFrameOutPadding[31:16];
							6'd7 :{Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_12_11,Inter_ref_11_11,Inter_ref_10_11} 				<= RefFrameOutPadding[23:0];
							6'd4 :{Inter_ref_01_12,Inter_ref_00_12} <= RefFrameOutPadding[31:16];
							6'd3 :{Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_12_12,Inter_ref_11_12,Inter_ref_10_12} 				<= RefFrameOutPadding[23:0];
						endcase
					 	2'b01:
						case (blk4x4_inter_preload_counter)
							6'd52:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
							6'd51:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00} <= RefFrameOutPadding;
							6'd50:{Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00} <= RefFrameOutPadding;
							6'd49:{Inter_ref_12_00,Inter_ref_11_00,Inter_ref_10_00,Inter_ref_09_00} <= RefFrameOutPadding;
						 	6'd48:Inter_ref_00_01 <= RefFrameOutPadding[31:24];
							6'd47:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01} <= RefFrameOutPadding;
							6'd46:{Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01} <= RefFrameOutPadding;
							6'd45:{Inter_ref_12_01,Inter_ref_11_01,Inter_ref_10_01,Inter_ref_09_01} <= RefFrameOutPadding;
							6'd44:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd43:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd42:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd41:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02} <= RefFrameOutPadding;
							6'd40:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd39:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd38:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd37:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03} <= RefFrameOutPadding;
							6'd36:Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd35:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd34:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd33:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04} <= RefFrameOutPadding;
							6'd32:Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd31:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd30:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd29:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05} <= RefFrameOutPadding;
							6'd28:Inter_ref_00_06 <= RefFrameOutPadding[31:24];
							6'd27:{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06} <= RefFrameOutPadding;
							6'd26:{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd25:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06} <= RefFrameOutPadding;
							6'd24:Inter_ref_00_07 <= RefFrameOutPadding[31:24];
							6'd23:{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07} <= RefFrameOutPadding;
							6'd22:{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd21:{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07} <= RefFrameOutPadding;
							6'd20:Inter_ref_00_08 <= RefFrameOutPadding[31:24];
							6'd19:{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08} <= RefFrameOutPadding;
							6'd18:{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
							6'd17:{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08} <= RefFrameOutPadding;
							6'd16:Inter_ref_00_09 <= RefFrameOutPadding[31:24];
							6'd15:{Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09} <= RefFrameOutPadding;
							6'd14:{Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09} <= RefFrameOutPadding;
							6'd13:{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09} <= RefFrameOutPadding;
							6'd12:Inter_ref_00_10 <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10,Inter_ref_01_10} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_12_10,Inter_ref_11_10,Inter_ref_10_10,Inter_ref_09_10} <= RefFrameOutPadding;
							6'd8 :Inter_ref_00_11 <= RefFrameOutPadding[31:24];
							6'd7 :{Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11,Inter_ref_01_11} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_12_11,Inter_ref_11_11,Inter_ref_10_11,Inter_ref_09_11} <= RefFrameOutPadding;
							6'd4 :Inter_ref_00_12 <= RefFrameOutPadding[31:24];
							6'd3 :{Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12,Inter_ref_01_12} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_12_12,Inter_ref_11_12,Inter_ref_10_12,Inter_ref_09_12} <= RefFrameOutPadding;
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd52:{Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding;
							6'd51:{Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding;
							6'd50:{Inter_ref_11_00,Inter_ref_10_00,Inter_ref_09_00,Inter_ref_08_00} <= RefFrameOutPadding;
							6'd49:Inter_ref_12_00 <= RefFrameOutPadding[7:0];
							6'd48:{Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding;
							6'd47:{Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding;
							6'd46:{Inter_ref_11_01,Inter_ref_10_01,Inter_ref_09_01,Inter_ref_08_01} <= RefFrameOutPadding;
							6'd45:Inter_ref_12_01 <= RefFrameOutPadding[7:0];
							6'd44:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd43:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd42:{Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02} <= RefFrameOutPadding;
							6'd41:Inter_ref_12_02 <= RefFrameOutPadding[7:0];
							6'd40:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd39:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd38:{Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03} <= RefFrameOutPadding;
							6'd37:Inter_ref_12_03 <= RefFrameOutPadding[7:0];
							6'd36:{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd35:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd34:{Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04} <= RefFrameOutPadding;
							6'd33:Inter_ref_12_04 <= RefFrameOutPadding[7:0];
							6'd32:{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd31:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd30:{Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05} <= RefFrameOutPadding;
							6'd29:Inter_ref_12_05 <= RefFrameOutPadding[7:0];
							6'd28:{Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding;
							6'd27:{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd26:{Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06} <= RefFrameOutPadding;
							6'd25:Inter_ref_12_06 <= RefFrameOutPadding[7:0];
							6'd24:{Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding;
							6'd23:{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd22:{Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07} <= RefFrameOutPadding;
							6'd21:Inter_ref_12_07 <= RefFrameOutPadding[7:0];
							6'd20:{Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding;
							6'd19:{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd18:{Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08} <= RefFrameOutPadding;
							6'd17:Inter_ref_12_08 <= RefFrameOutPadding[7:0];
							6'd16:{Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding;
							6'd15:{Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09} <= RefFrameOutPadding;
							6'd14:{Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09} <= RefFrameOutPadding;
							6'd13:Inter_ref_12_09 <= RefFrameOutPadding[7:0];
							6'd12:{Inter_ref_03_10,Inter_ref_02_10,Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding;
							6'd11:{Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10} <= RefFrameOutPadding;
							6'd10:{Inter_ref_11_10,Inter_ref_10_10,Inter_ref_09_10,Inter_ref_08_10} <= RefFrameOutPadding;
							6'd9 :Inter_ref_12_10 <= RefFrameOutPadding[7:0];
							6'd8 :{Inter_ref_03_11,Inter_ref_02_11,Inter_ref_01_11,Inter_ref_00_11} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_11_11,Inter_ref_10_11,Inter_ref_09_11,Inter_ref_08_11} <= RefFrameOutPadding;
							6'd5 :Inter_ref_12_11 <= RefFrameOutPadding[7:0];
							6'd4 :{Inter_ref_03_12,Inter_ref_02_12,Inter_ref_01_12,Inter_ref_00_12} <= RefFrameOutPadding;
							6'd3 :{Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_11_12,Inter_ref_10_12,Inter_ref_09_12,Inter_ref_08_12} <= RefFrameOutPadding;
							6'd1 :Inter_ref_12_12 <= RefFrameOutPadding[7:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd52:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:8];
							6'd51:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding;
							6'd50:{Inter_ref_10_00,Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00} <= RefFrameOutPadding;
							6'd49:{Inter_ref_12_00,Inter_ref_11_00} <= RefFrameOutPadding[15:0];
							6'd48:{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:8];
							6'd47:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding;
							6'd46:{Inter_ref_10_01,Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01} <= RefFrameOutPadding;
							6'd45:{Inter_ref_12_01,Inter_ref_11_01} <= RefFrameOutPadding[15:0];
							6'd44:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd43:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd42:{Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding;
							6'd41:{Inter_ref_12_02,Inter_ref_11_02} <= RefFrameOutPadding[15:0];
							6'd40:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd39:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd38:{Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding;
							6'd37:{Inter_ref_12_03,Inter_ref_11_03} <= RefFrameOutPadding[15:0];
							6'd36:{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd35:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd34:{Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding;
							6'd33:{Inter_ref_12_04,Inter_ref_11_04} <= RefFrameOutPadding[15:0];
							6'd32:{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd31:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd30:{Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding;
							6'd29:{Inter_ref_12_05,Inter_ref_11_05} <= RefFrameOutPadding[15:0];
							6'd28:{Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:8];
							6'd27:{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd26:{Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding;
							6'd25:{Inter_ref_12_06,Inter_ref_11_06} <= RefFrameOutPadding[15:0];
							6'd24:{Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:8];
							6'd23:{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd22:{Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding;
							6'd21:{Inter_ref_12_07,Inter_ref_11_07} <= RefFrameOutPadding[15:0];
							6'd20:{Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:8];
							6'd19:{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd18:{Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding;
							6'd17:{Inter_ref_12_08,Inter_ref_11_08} <= RefFrameOutPadding[15:0];
							6'd16:{Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding[31:8];
							6'd15:{Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09} <= RefFrameOutPadding;
							6'd14:{Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09} <= RefFrameOutPadding;
							6'd13:{Inter_ref_12_09,Inter_ref_11_09} <= RefFrameOutPadding[15:0];
							6'd12:{Inter_ref_02_10,Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10} <= RefFrameOutPadding;
							6'd10:{Inter_ref_10_10,Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_12_10,Inter_ref_11_10} <= RefFrameOutPadding[15:0];
							6'd8 :{Inter_ref_02_11,Inter_ref_01_11,Inter_ref_00_11} <= RefFrameOutPadding[31:8];
							6'd7 :{Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_10_11,Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_12_11,Inter_ref_11_11} <= RefFrameOutPadding[15:0];
							6'd4 :{Inter_ref_02_12,Inter_ref_01_12,Inter_ref_00_12} <= RefFrameOutPadding[31:8];
							6'd3 :{Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_10_12,Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_12_12,Inter_ref_11_12} <= RefFrameOutPadding[15:0];
						endcase	
					endcase
					`pos_d,`pos_h,`pos_n:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)	
							6'd26:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00}	<= RefFrameOutPadding;
							6'd25:{Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00} <= RefFrameOutPadding;
							6'd24:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01}	<= RefFrameOutPadding;
							6'd23:{Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01} <= RefFrameOutPadding;
							6'd22:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02}	<= RefFrameOutPadding;
							6'd21:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding;
							6'd20:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03}	<= RefFrameOutPadding;
							6'd19:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding;
							6'd18:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04}	<= RefFrameOutPadding;
							6'd17:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding;
							6'd16:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05}	<= RefFrameOutPadding;
							6'd15:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding;
							6'd14:{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06}	<= RefFrameOutPadding;
							6'd13:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding;
							6'd12:{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07}	<= RefFrameOutPadding;
							6'd11:{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding;
							6'd10:{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08}	<= RefFrameOutPadding;
							6'd9 :{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09}	<= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10}	<= RefFrameOutPadding;
							6'd5 :{Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11}	<= RefFrameOutPadding;
							6'd3 :{Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12}	<= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12} <= RefFrameOutPadding;
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd39:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:8];
							6'd38:{Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00} <= RefFrameOutPadding;
							6'd37:Inter_ref_09_00 <= RefFrameOutPadding[7:0]; 
							6'd36:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:8];
							6'd35:{Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01} <= RefFrameOutPadding;
							6'd34:Inter_ref_09_01 <= RefFrameOutPadding[7:0];
							6'd33:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:8];
							6'd32:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd31:Inter_ref_09_02 <= RefFrameOutPadding[7:0];
							6'd30:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:8];
							6'd29:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd28:Inter_ref_09_03 <= RefFrameOutPadding[7:0];
							6'd27:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:8];
							6'd26:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd25:Inter_ref_09_04 <= RefFrameOutPadding[7:0];
							6'd24:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:8];
							6'd23:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd22:Inter_ref_09_05 <= RefFrameOutPadding[7:0];
							6'd21:{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:8];
							6'd20:{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd19:Inter_ref_09_06 <= RefFrameOutPadding[7:0];
							6'd18:{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:8];
							6'd17:{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd16:Inter_ref_09_07 <= RefFrameOutPadding[7:0];
							6'd15:{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:8];
							6'd14:{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
							6'd13:Inter_ref_09_08 <= RefFrameOutPadding[7:0];
							6'd12:{Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09} <= RefFrameOutPadding;
							6'd10:Inter_ref_09_09 <= RefFrameOutPadding[7:0];
							6'd9 :{Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10} <= RefFrameOutPadding[31:8];
							6'd8 :{Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10} <= RefFrameOutPadding;
							6'd7 :Inter_ref_09_10 <= RefFrameOutPadding[7:0];
							6'd6 :{Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding[31:8];
							6'd5 :{Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11} <= RefFrameOutPadding;
							6'd4 :Inter_ref_09_11 <= RefFrameOutPadding[7:0];
							6'd3 :{Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding[31:8];
							6'd2 :{Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12} <= RefFrameOutPadding;
							6'd1 :Inter_ref_09_12 <= RefFrameOutPadding[7:0];
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd39:{Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:16];
							6'd38:{Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding;
							6'd37:{Inter_ref_09_00,Inter_ref_08_00} <= RefFrameOutPadding[15:0]; 
							6'd36:{Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:16];
							6'd35:{Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding;
							6'd34:{Inter_ref_09_01,Inter_ref_08_01} <= RefFrameOutPadding[15:0];
							6'd33:{Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:16];
							6'd32:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd31:{Inter_ref_09_02,Inter_ref_08_02} <= RefFrameOutPadding[15:0];
							6'd30:{Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:16];
							6'd29:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd28:{Inter_ref_09_03,Inter_ref_08_03} <= RefFrameOutPadding[15:0];
							6'd27:{Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:16];
							6'd26:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd25:{Inter_ref_09_04,Inter_ref_08_04} <= RefFrameOutPadding[15:0];
							6'd24:{Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:16];
							6'd23:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_05,Inter_ref_08_05} <= RefFrameOutPadding[15:0];
							6'd21:{Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:16];
							6'd20:{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd19:{Inter_ref_09_06,Inter_ref_08_06} <= RefFrameOutPadding[15:0];
							6'd18:{Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:16];
							6'd17:{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd16:{Inter_ref_09_07,Inter_ref_08_07} <= RefFrameOutPadding[15:0];
							6'd15:{Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:16];
							6'd14:{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd13:{Inter_ref_09_08,Inter_ref_08_08} <= RefFrameOutPadding[15:0];
							6'd12:{Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_09,Inter_ref_08_09} <= RefFrameOutPadding[15:0];
							6'd9 :{Inter_ref_03_10,Inter_ref_02_10} <= RefFrameOutPadding[31:16];
							6'd8 :{Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_10,Inter_ref_08_10} <= RefFrameOutPadding[15:0];
							6'd6 :{Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_09_11,Inter_ref_08_11} <= RefFrameOutPadding[15:0];
							6'd3 :{Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding[31:16];
							6'd2 :{Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_12,Inter_ref_08_12} <= RefFrameOutPadding[15:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd39:{Inter_ref_02_00} <= RefFrameOutPadding[31:24];
							6'd38:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding;
							6'd37:{Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00} <= RefFrameOutPadding[23:0];
							6'd36:{Inter_ref_02_01} <= RefFrameOutPadding[31:24];
							6'd35:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding;
							6'd34:{Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01} <= RefFrameOutPadding[23:0]; 
							6'd33:{Inter_ref_02_02} <= RefFrameOutPadding[31:24];
							6'd32:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd31:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding[23:0]; 
							6'd30:{Inter_ref_02_03} <= RefFrameOutPadding[31:24];
							6'd29:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd28:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding[23:0]; 
							6'd27:{Inter_ref_02_04} <= RefFrameOutPadding[31:24];
							6'd26:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd25:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding[23:0]; 
							6'd24:{Inter_ref_02_05} <= RefFrameOutPadding[31:24];
							6'd23:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding[23:0]; 
							6'd21:{Inter_ref_02_06} <= RefFrameOutPadding[31:24];
							6'd20:{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd19:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding[23:0]; 
							6'd18:{Inter_ref_02_07} <= RefFrameOutPadding[31:24];
							6'd17:{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd16:{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding[23:0]; 
							6'd15:{Inter_ref_02_08} <= RefFrameOutPadding[31:24];
							6'd14:{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd13:{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding[23:0]; 
							6'd12:{Inter_ref_02_09} <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09} <= RefFrameOutPadding[23:0]; 
							6'd9 :{Inter_ref_02_10} <= RefFrameOutPadding[31:24];
							6'd8 :{Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10} <= RefFrameOutPadding[23:0]; 
							6'd6 :{Inter_ref_02_11} <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11} <= RefFrameOutPadding[23:0]; 
							6'd3 :{Inter_ref_02_12} <= RefFrameOutPadding[31:24];
							6'd2 :{Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12} <= RefFrameOutPadding[23:0]; 
						endcase
					endcase
					`pos_a,`pos_b,`pos_c:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)	
							6'd32:{Inter_ref_01_02,Inter_ref_00_02}	<= RefFrameOutPadding[31:16];
							6'd31:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd30:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding;
							6'd29:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02} <= RefFrameOutPadding[23:0];
							6'd28:{Inter_ref_01_03,Inter_ref_00_03}	<= RefFrameOutPadding[31:16];
							6'd27:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd26:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding;
							6'd25:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03} <= RefFrameOutPadding[23:0];
							6'd24:{Inter_ref_01_04,Inter_ref_00_04}	<= RefFrameOutPadding[31:16];
							6'd23:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding;
							6'd21:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04} <= RefFrameOutPadding[23:0];
							6'd20:{Inter_ref_01_05,Inter_ref_00_05}	<= RefFrameOutPadding[31:16];
							6'd19:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd18:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding;
							6'd17:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05} <= RefFrameOutPadding[23:0];
							6'd16:{Inter_ref_01_06,Inter_ref_00_06}	<= RefFrameOutPadding[31:16];
							6'd15:{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd14:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding;
							6'd13:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06} <= RefFrameOutPadding[23:0];
							6'd12:{Inter_ref_01_07,Inter_ref_00_07}	<= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07} <= RefFrameOutPadding[23:0];
							6'd8 :{Inter_ref_01_08,Inter_ref_00_08}	<= RefFrameOutPadding[31:16];
							6'd7 :{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08} <= RefFrameOutPadding[23:0];
							6'd4 :{Inter_ref_01_09,Inter_ref_00_09}	<= RefFrameOutPadding[31:16];
							6'd3 :{Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09} <= RefFrameOutPadding[23:0];
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)	
							6'd32:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd31:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd30:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd29:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02} <= RefFrameOutPadding;
							6'd28:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd27:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd26:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd25:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03} <= RefFrameOutPadding;
							6'd24:Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd23:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd22:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd21:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04} <= RefFrameOutPadding;
							6'd20:Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd19:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd18:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd17:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05} <= RefFrameOutPadding;
							6'd16:Inter_ref_00_06 <= RefFrameOutPadding[31:24];
							6'd15:{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06} <= RefFrameOutPadding;
							6'd14:{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd13:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06} <= RefFrameOutPadding;
							6'd12:Inter_ref_00_07 <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07} <= RefFrameOutPadding;
							6'd8 :Inter_ref_00_08 <= RefFrameOutPadding[31:24];
							6'd7 :{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08} <= RefFrameOutPadding;
							6'd4 :Inter_ref_00_09 <= RefFrameOutPadding[31:24];
							6'd3 :{Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09} <= RefFrameOutPadding;
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)	
							6'd32:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd31:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd30:{Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02} <= RefFrameOutPadding;	
							6'd29:Inter_ref_12_02 <= RefFrameOutPadding[7:0];
							6'd28:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd27:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd26:{Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03} <= RefFrameOutPadding;	
							6'd25:Inter_ref_12_03 <= RefFrameOutPadding[7:0];
							6'd24:{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd23:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd22:{Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04} <= RefFrameOutPadding;	
							6'd21:Inter_ref_12_04 <= RefFrameOutPadding[7:0];
							6'd20:{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd19:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd18:{Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05} <= RefFrameOutPadding;	
							6'd17:Inter_ref_12_05 <= RefFrameOutPadding[7:0];
							6'd16:{Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding;
							6'd15:{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd14:{Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06} <= RefFrameOutPadding;	
							6'd13:Inter_ref_12_06 <= RefFrameOutPadding[7:0];
							6'd12:{Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding;
							6'd11:{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd10:{Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07} <= RefFrameOutPadding;	
							6'd9 :Inter_ref_12_07 <= RefFrameOutPadding[7:0];
							6'd8 :{Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08} <= RefFrameOutPadding;	
							6'd5 :Inter_ref_12_08 <= RefFrameOutPadding[7:0];
							6'd4 :{Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding;
							6'd3 :{Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09} <= RefFrameOutPadding;	
							6'd1 :Inter_ref_12_09 <= RefFrameOutPadding[7:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd32:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd31:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd30:{Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding;	
							6'd29:{Inter_ref_12_02,Inter_ref_11_02} <= RefFrameOutPadding[15:0];
							6'd28:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd27:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd26:{Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding;	
							6'd25:{Inter_ref_12_03,Inter_ref_11_03} <= RefFrameOutPadding[15:0];
							6'd24:{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd23:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd22:{Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding;	
							6'd21:{Inter_ref_12_04,Inter_ref_11_04} <= RefFrameOutPadding[15:0];
							6'd20:{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd19:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd18:{Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding;	
							6'd17:{Inter_ref_12_05,Inter_ref_11_05} <= RefFrameOutPadding[15:0];
							6'd16:{Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:8];
							6'd15:{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd14:{Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding;	
							6'd13:{Inter_ref_12_06,Inter_ref_11_06} <= RefFrameOutPadding[15:0];
							6'd12:{Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd10:{Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding;	
							6'd9 :{Inter_ref_12_07,Inter_ref_11_07} <= RefFrameOutPadding[15:0];
							6'd8 :{Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:8];
							6'd7 :{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding;	
							6'd5 :{Inter_ref_12_08,Inter_ref_11_08} <= RefFrameOutPadding[15:0];
							6'd4 :{Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding[31:8];
							6'd3 :{Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09} <= RefFrameOutPadding;	
							6'd1 :{Inter_ref_12_09,Inter_ref_11_09} <= RefFrameOutPadding[15:0];
						endcase
					endcase
					`pos_Int:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)	
							6'd16:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02}	<= RefFrameOutPadding;
							6'd15:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding;
							6'd14:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03}	<= RefFrameOutPadding;
							6'd13:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding;
							6'd12:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04}	<= RefFrameOutPadding;
							6'd11:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding;
							6'd10:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05}	<= RefFrameOutPadding;
							6'd9 :{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06}	<= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07}	<= RefFrameOutPadding;
							6'd5 :{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08}	<= RefFrameOutPadding;
							6'd3 :{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09}	<= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09} <= RefFrameOutPadding;
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd24:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:8];
							6'd23:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd22:Inter_ref_09_02 <= RefFrameOutPadding[7:0]; 
							6'd21:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:8];
							6'd20:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd19:Inter_ref_09_03 <= RefFrameOutPadding[7:0];
							6'd18:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:8];
							6'd17:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd16:Inter_ref_09_04 <= RefFrameOutPadding[7:0];
							6'd15:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:8];
							6'd14:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd13:Inter_ref_09_05 <= RefFrameOutPadding[7:0];
							6'd12:{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd10:Inter_ref_09_06 <= RefFrameOutPadding[7:0];
							6'd9 :{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:8];
							6'd8 :{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd7 :Inter_ref_09_07 <= RefFrameOutPadding[7:0];
							6'd6 :{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:8];
							6'd5 :{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
							6'd4 :Inter_ref_09_08 <= RefFrameOutPadding[7:0];
							6'd3 :{Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding[31:8];
							6'd2 :{Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09} <= RefFrameOutPadding;
							6'd1 :Inter_ref_09_09 <= RefFrameOutPadding[7:0];
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd24:{Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:16];
							6'd23:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_02,Inter_ref_08_02} <= RefFrameOutPadding[15:0];
							6'd21:{Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:16];
							6'd20:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd19:{Inter_ref_09_03,Inter_ref_08_03} <= RefFrameOutPadding[15:0];
							6'd18:{Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:16];
							6'd17:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd16:{Inter_ref_09_04,Inter_ref_08_04} <= RefFrameOutPadding[15:0];
							6'd15:{Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:16];
							6'd14:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd13:{Inter_ref_09_05,Inter_ref_08_05} <= RefFrameOutPadding[15:0];
							6'd12:{Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_06,Inter_ref_08_06} <= RefFrameOutPadding[15:0];
							6'd9 :{Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:16];
							6'd8 :{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_07,Inter_ref_08_07} <= RefFrameOutPadding[15:0];
							6'd6 :{Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_09_08,Inter_ref_08_08} <= RefFrameOutPadding[15:0];
							6'd3 :{Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding[31:16];
							6'd2 :{Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_09,Inter_ref_08_09} <= RefFrameOutPadding[15:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd24:{Inter_ref_02_02} <= RefFrameOutPadding[31:24];
							6'd23:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd22:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding[23:0];
							6'd21:{Inter_ref_02_03} <= RefFrameOutPadding[31:24];
							6'd20:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd19:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding[23:0];
							6'd18:{Inter_ref_02_04} <= RefFrameOutPadding[31:24];
							6'd17:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd16:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding[23:0];
							6'd15:{Inter_ref_02_05} <= RefFrameOutPadding[31:24];
							6'd14:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd13:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding[23:0];
							6'd12:{Inter_ref_02_06} <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd10:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding[23:0];
							6'd9 :{Inter_ref_02_07} <= RefFrameOutPadding[31:24];
							6'd8 :{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding[23:0];
							6'd6 :{Inter_ref_02_08} <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding[23:0];
							6'd3 :{Inter_ref_02_09} <= RefFrameOutPadding[31:24];
							6'd2 :{Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09} <= RefFrameOutPadding[23:0];
						endcase
					endcase
					`pos_e,`pos_g,`pos_p,`pos_r:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd48:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding;
							6'd47:{Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00} <= RefFrameOutPadding;
							6'd46:Inter_ref_10_00 <= RefFrameOutPadding[7:0];
							6'd45:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding;
							6'd44:{Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01} <= RefFrameOutPadding;
							6'd43:Inter_ref_10_01 <= RefFrameOutPadding[7:0];
							
							6'd42:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
							6'd41:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd40:{Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding;
							6'd39:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02} 				<= RefFrameOutPadding[23:0];
							6'd38:{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
							6'd37:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd36:{Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding;
							6'd35:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03} 				<= RefFrameOutPadding[23:0];
							6'd34:{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];
							6'd33:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd32:{Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding;
							6'd31:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04} 				<= RefFrameOutPadding[23:0];
							6'd30:{Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:16];
							6'd29:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd28:{Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding;
							6'd27:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05} 				<= RefFrameOutPadding[23:0];
							6'd26:{Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:16];
							6'd25:{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd24:{Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding;
							6'd23:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06} 				<= RefFrameOutPadding[23:0];
							6'd22:{Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:16];
							6'd21:{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd20:{Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding;
							6'd19:{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07} 				<= RefFrameOutPadding[23:0];
							6'd18:{Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:16];
							6'd17:{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
							6'd16:{Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding;
							6'd15:{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08} 				<= RefFrameOutPadding[23:0];
							6'd14:{Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding[31:16];
							6'd13:{Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09} <= RefFrameOutPadding;
							6'd12:{Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09} <= RefFrameOutPadding;
							6'd11:{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09} 				<= RefFrameOutPadding[23:0];
							6'd10:{Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding[31:16];
							6'd9 :{Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_12_10,Inter_ref_11_10,Inter_ref_10_10} 				<= RefFrameOutPadding[23:0];
							
							6'd6 :{Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11} <= RefFrameOutPadding;
							6'd4 :Inter_ref_10_11 <= RefFrameOutPadding[7:0];
							6'd3 :{Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12} <= RefFrameOutPadding;
							6'd1 :Inter_ref_10_12 <= RefFrameOutPadding[7:0];
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd48:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:8];
							6'd47:{Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00} <= RefFrameOutPadding;
							6'd46:{Inter_ref_10_00,Inter_ref_09_00} <= RefFrameOutPadding[15:0];
							6'd45:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:8];
							6'd44:{Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01} <= RefFrameOutPadding;
							6'd43:{Inter_ref_10_01,Inter_ref_09_01} <= RefFrameOutPadding[15:0];
							
							6'd42:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd41:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd40:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd39:{Inter_ref_12_02,Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02} <= RefFrameOutPadding;
							6'd38:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd37:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd36:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd35:{Inter_ref_12_03,Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03} <= RefFrameOutPadding;
							6'd34:Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd33:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd32:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd31:{Inter_ref_12_04,Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04} <= RefFrameOutPadding;
							6'd30:Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd29:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd28:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd27:{Inter_ref_12_05,Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05} <= RefFrameOutPadding;
							6'd26:Inter_ref_00_06 <= RefFrameOutPadding[31:24];
							6'd25:{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06} <= RefFrameOutPadding;
							6'd24:{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd23:{Inter_ref_12_06,Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06} <= RefFrameOutPadding;
							6'd22:Inter_ref_00_07 <= RefFrameOutPadding[31:24];
							6'd21:{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07} <= RefFrameOutPadding;
							6'd20:{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd19:{Inter_ref_12_07,Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07} <= RefFrameOutPadding;
							6'd18:Inter_ref_00_08 <= RefFrameOutPadding[31:24];
							6'd17:{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08} <= RefFrameOutPadding;
							6'd16:{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
							6'd15:{Inter_ref_12_08,Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08} <= RefFrameOutPadding;
							6'd14:Inter_ref_00_09 <= RefFrameOutPadding[31:24];
							6'd13:{Inter_ref_04_09,Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09} <= RefFrameOutPadding;
							6'd12:{Inter_ref_08_09,Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09} <= RefFrameOutPadding;
							6'd11:{Inter_ref_12_09,Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09} <= RefFrameOutPadding;
							6'd10:Inter_ref_00_10 <= RefFrameOutPadding[31:24];
							6'd9 :{Inter_ref_04_10,Inter_ref_03_10,Inter_ref_02_10,Inter_ref_01_10} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_08_10,Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_12_10,Inter_ref_11_10,Inter_ref_10_10,Inter_ref_09_10} <= RefFrameOutPadding;
							
							6'd6 :{Inter_ref_04_11,Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding[31:8];
							6'd5 :{Inter_ref_08_11,Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_10_11,Inter_ref_09_11} <= RefFrameOutPadding[15:0];
							6'd3 :{Inter_ref_04_12,Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding[31:8];
							6'd2 :{Inter_ref_08_12,Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_10_12,Inter_ref_09_12} <= RefFrameOutPadding[15:0]; 
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd48:{Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:16];
							6'd47:{Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding;
							6'd46:{Inter_ref_10_00,Inter_ref_09_00,Inter_ref_08_00} <= RefFrameOutPadding[23:0];
							6'd45:{Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:16];
							6'd44:{Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding;
							6'd43:{Inter_ref_10_01,Inter_ref_09_01,Inter_ref_08_01} <= RefFrameOutPadding[23:0]; 
							
							6'd42:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd41:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd40:{Inter_ref_11_02,Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02} <= RefFrameOutPadding;
							6'd39:Inter_ref_12_02 <= RefFrameOutPadding[7:0];
							6'd38:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd37:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd36:{Inter_ref_11_03,Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03} <= RefFrameOutPadding;
							6'd35:Inter_ref_12_03 <= RefFrameOutPadding[7:0];
							6'd34:{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd33:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd32:{Inter_ref_11_04,Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04} <= RefFrameOutPadding;
							6'd31:Inter_ref_12_04 <= RefFrameOutPadding[7:0];
							6'd30:{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd29:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd28:{Inter_ref_11_05,Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05} <= RefFrameOutPadding;
							6'd27:Inter_ref_12_05 <= RefFrameOutPadding[7:0];
							6'd26:{Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding;
							6'd25:{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd24:{Inter_ref_11_06,Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06} <= RefFrameOutPadding;
							6'd23:Inter_ref_12_06 <= RefFrameOutPadding[7:0];
							6'd22:{Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding;
							6'd21:{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd20:{Inter_ref_11_07,Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07} <= RefFrameOutPadding;
							6'd19:Inter_ref_12_07 <= RefFrameOutPadding[7:0];
							6'd18:{Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding;
							6'd17:{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd16:{Inter_ref_11_08,Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08} <= RefFrameOutPadding;
							6'd15:Inter_ref_12_08 <= RefFrameOutPadding[7:0];
							6'd14:{Inter_ref_03_09,Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding;
							6'd13:{Inter_ref_07_09,Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09} <= RefFrameOutPadding;
							6'd12:{Inter_ref_11_09,Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09} <= RefFrameOutPadding;
							6'd11:Inter_ref_12_09 <= RefFrameOutPadding[7:0];
							6'd10:{Inter_ref_03_10,Inter_ref_02_10,Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_07_10,Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_11_10,Inter_ref_10_10,Inter_ref_09_10,Inter_ref_08_10} <= RefFrameOutPadding;
							6'd7 :Inter_ref_12_10 <= RefFrameOutPadding[7:0];
							
							6'd6 :{Inter_ref_03_11,Inter_ref_02_11} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_07_11,Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_10_11,Inter_ref_09_11,Inter_ref_08_11} <= RefFrameOutPadding[23:0];
							6'd3 :{Inter_ref_03_12,Inter_ref_02_12} <= RefFrameOutPadding[31:16];
							6'd2 :{Inter_ref_07_12,Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_10_12,Inter_ref_09_12,Inter_ref_08_12} <= RefFrameOutPadding[23:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd48:{Inter_ref_02_00} <= RefFrameOutPadding[31:24];
							6'd47:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding;
							6'd46:{Inter_ref_10_00,Inter_ref_09_00,Inter_ref_08_00,Inter_ref_07_00} <= RefFrameOutPadding;
							6'd45:{Inter_ref_02_01} <= RefFrameOutPadding[31:24];
							6'd44:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding;
							6'd43:{Inter_ref_10_01,Inter_ref_09_01,Inter_ref_08_01,Inter_ref_07_01} <= RefFrameOutPadding;
							
							6'd42:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd41:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd40:{Inter_ref_10_02,Inter_ref_09_02,Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding;
							6'd39:{Inter_ref_12_02,Inter_ref_11_02} <= RefFrameOutPadding[15:0];
							6'd38:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd37:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd36:{Inter_ref_10_03,Inter_ref_09_03,Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding;
							6'd35:{Inter_ref_12_03,Inter_ref_11_03} <= RefFrameOutPadding[15:0];
							6'd34:{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd33:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd32:{Inter_ref_10_04,Inter_ref_09_04,Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding;
							6'd31:{Inter_ref_12_04,Inter_ref_11_04} <= RefFrameOutPadding[15:0];
							6'd30:{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd29:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd28:{Inter_ref_10_05,Inter_ref_09_05,Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding;
							6'd27:{Inter_ref_12_05,Inter_ref_11_05} <= RefFrameOutPadding[15:0];
							6'd26:{Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:8];
							6'd25:{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd24:{Inter_ref_10_06,Inter_ref_09_06,Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding;
							6'd23:{Inter_ref_12_06,Inter_ref_11_06} <= RefFrameOutPadding[15:0];
							6'd22:{Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:8];
							6'd21:{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd20:{Inter_ref_10_07,Inter_ref_09_07,Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding;
							6'd19:{Inter_ref_12_07,Inter_ref_11_07} <= RefFrameOutPadding[15:0];
							6'd18:{Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:8];
							6'd17:{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd16:{Inter_ref_10_08,Inter_ref_09_08,Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding;
							6'd15:{Inter_ref_12_08,Inter_ref_11_08} <= RefFrameOutPadding[15:0];
							6'd14:{Inter_ref_02_09,Inter_ref_01_09,Inter_ref_00_09} <= RefFrameOutPadding[31:8];
							6'd13:{Inter_ref_06_09,Inter_ref_05_09,Inter_ref_04_09,Inter_ref_03_09} <= RefFrameOutPadding;
							6'd12:{Inter_ref_10_09,Inter_ref_09_09,Inter_ref_08_09,Inter_ref_07_09} <= RefFrameOutPadding;
							6'd11:{Inter_ref_12_09,Inter_ref_11_09} <= RefFrameOutPadding[15:0];
							6'd10:{Inter_ref_02_10,Inter_ref_01_10,Inter_ref_00_10} <= RefFrameOutPadding[31:8];
							6'd9 :{Inter_ref_06_10,Inter_ref_05_10,Inter_ref_04_10,Inter_ref_03_10} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_10_10,Inter_ref_09_10,Inter_ref_08_10,Inter_ref_07_10} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_12_10,Inter_ref_11_10} <= RefFrameOutPadding[15:0];
							
							6'd6 :{Inter_ref_02_11} <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_06_11,Inter_ref_05_11,Inter_ref_04_11,Inter_ref_03_11} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_10_11,Inter_ref_09_11,Inter_ref_08_11,Inter_ref_07_11} <= RefFrameOutPadding;
							6'd3 :{Inter_ref_02_12} <= RefFrameOutPadding[31:24];
							6'd2 :{Inter_ref_06_12,Inter_ref_05_12,Inter_ref_04_12,Inter_ref_03_12} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_10_12,Inter_ref_09_12,Inter_ref_08_12,Inter_ref_07_12} <= RefFrameOutPadding;
						endcase
					endcase
				endcase
				1'b1:	//mv_below8x8_curr == 1'b1
				case (pos_FracL)
					`pos_f,`pos_q,`pos_i,`pos_k,`pos_j:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd27:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
							6'd26:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding;
							6'd25:{Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00} <= RefFrameOutPadding[23:0];
							6'd24:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
							6'd23:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding;
							6'd22:{Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01} <= RefFrameOutPadding[23:0];
							6'd21:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
							6'd20:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd19:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding[23:0];
							6'd18:{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
							6'd17:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd16:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding[23:0];
							6'd15:{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];
							6'd14:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd13:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding[23:0];	
							6'd12:{Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding[23:0];
							6'd9 :{Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:16];
							6'd8 :{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding[23:0];
							6'd6 :{Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07} <= RefFrameOutPadding[23:0];
							6'd3 :{Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:16];
							6'd2 :{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08} <= RefFrameOutPadding[23:0];
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd27:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
							6'd26:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00} <= RefFrameOutPadding;
							6'd25:{Inter_ref_08_00,Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00} <= RefFrameOutPadding;
							6'd24:Inter_ref_00_01 <= RefFrameOutPadding[31:24];
							6'd23:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01} <= RefFrameOutPadding;
							6'd22:{Inter_ref_08_01,Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01} <= RefFrameOutPadding;
							6'd21:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd20:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd19:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd18:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd17:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd16:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd15:Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd14:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd13:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd12:Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd9 :Inter_ref_00_06 <= RefFrameOutPadding[31:24];
							6'd8 :{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							6'd6 :Inter_ref_00_07 <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_07,Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding;
							6'd3 :Inter_ref_00_08 <= RefFrameOutPadding[31:24];
							6'd2 :{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_08,Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding;
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd27:{Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding;
							6'd26:{Inter_ref_07_00,Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding;
							6'd25:Inter_ref_08_00 <= RefFrameOutPadding[7:0];
							6'd24:{Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding;
							6'd23:{Inter_ref_07_01,Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding;
							6'd22:Inter_ref_08_01 <= RefFrameOutPadding[7:0];
							6'd21:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd20:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd19:Inter_ref_08_02 <= RefFrameOutPadding[7:0]; 
							6'd18:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd17:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd16:Inter_ref_08_03 <= RefFrameOutPadding[7:0];
							6'd15:{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd14:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd13:Inter_ref_08_04 <= RefFrameOutPadding[7:0];
							6'd12:{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd11:{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd10:Inter_ref_08_05 <= RefFrameOutPadding[7:0];
							6'd9 :{Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd7 :Inter_ref_08_06 <= RefFrameOutPadding[7:0];
							6'd6 :{Inter_ref_03_07,Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_07_07,Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding;
							6'd4 :Inter_ref_08_07 <= RefFrameOutPadding[7:0];
							6'd3 :{Inter_ref_03_08,Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_07_08,Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding;
							6'd1 :Inter_ref_08_08 <= RefFrameOutPadding[7:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd27:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:8];
							6'd26:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding;
							6'd25:{Inter_ref_08_00,Inter_ref_07_00} <= RefFrameOutPadding[15:0];
							
							6'd24:{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:8];
							6'd23:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding;
							6'd22:{Inter_ref_08_01,Inter_ref_07_01} <= RefFrameOutPadding[15:0]; 
							
							6'd21:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd20:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd19:{Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding[15:0];
							
							6'd18:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd17:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd16:{Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding[15:0];
							
							6'd15:{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd14:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd13:{Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding[15:0];
							
							6'd12:{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding[15:0]; 
							
							6'd9 :{Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:8];
							6'd8 :{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding[15:0];
							
							6'd6 :{Inter_ref_02_07,Inter_ref_01_07,Inter_ref_00_07} <= RefFrameOutPadding[31:8];
							6'd5 :{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_07,Inter_ref_07_07} <= RefFrameOutPadding[15:0];
							
							6'd3 :{Inter_ref_02_08,Inter_ref_01_08,Inter_ref_00_08} <= RefFrameOutPadding[31:8];
							6'd2 :{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_08,Inter_ref_07_08} <= RefFrameOutPadding[15:0];
						endcase
					endcase
					`pos_d,`pos_h,`pos_n:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd9:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding;
							6'd8:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding;
							6'd7:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd6:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd5:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd4:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd3:{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd2:{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd1:{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd18:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:8];
							6'd17:Inter_ref_05_00 <= RefFrameOutPadding[7:0];
							
							6'd16:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:8];
							6'd15:Inter_ref_05_01 <= RefFrameOutPadding[7:0];
							
							6'd14:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:8];
							6'd13:Inter_ref_05_02 <= RefFrameOutPadding[7:0];
							
							6'd12:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:8];
							6'd11:Inter_ref_05_03 <= RefFrameOutPadding[7:0];
							
							6'd10:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:8];
							6'd9 :Inter_ref_05_04 <= RefFrameOutPadding[7:0];
							
							6'd8 :{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:8];
							6'd7 :Inter_ref_05_05 <= RefFrameOutPadding[7:0];
							
							6'd6 :{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:8];
							6'd5 :Inter_ref_05_06 <= RefFrameOutPadding[7:0];
							
							6'd4 :{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:8];
							6'd3 :Inter_ref_05_07 <= RefFrameOutPadding[7:0];
							
							6'd2 :{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:8];
							6'd1 :Inter_ref_05_08 <= RefFrameOutPadding[7:0];
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd18:{Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:16];
							6'd17:{Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding[15:0];
							
							6'd16:{Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:16];
							6'd15:{Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding[15:0];
							
							6'd14:{Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:16];
							6'd13:{Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding[15:0];
							
							6'd12:{Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding[15:0];
							
							6'd10:{Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:16];
							6'd9 :{Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding[15:0];
							
							6'd8 :{Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:16];
							6'd7 :{Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding[15:0];
							
							6'd6 :{Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding[15:0];
							
							6'd4 :{Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:16];
							6'd3 :{Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding[15:0];
							
							6'd2 :{Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:16];
							6'd1 :{Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding[15:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd18:Inter_ref_02_00 <= RefFrameOutPadding[31:24];
							6'd17:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding[23:0];
							
							6'd16:Inter_ref_02_01 <= RefFrameOutPadding[31:24];
							6'd15:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding[23:0];
							
							6'd14:Inter_ref_02_02 <= RefFrameOutPadding[31:24];
							6'd13:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding[23:0];
							
							6'd12:Inter_ref_02_03 <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding[23:0];
							
							6'd10:Inter_ref_02_04 <= RefFrameOutPadding[31:24];
							6'd9 :{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding[23:0];
							
							6'd8 :Inter_ref_02_05 <= RefFrameOutPadding[31:24];
							6'd7 :{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding[23:0];
							
							6'd6 :Inter_ref_02_06 <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding[23:0];
							
							6'd4 :Inter_ref_02_07 <= RefFrameOutPadding[31:24];
							6'd3 :{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding[23:0];
							
							6'd2 :Inter_ref_02_08 <= RefFrameOutPadding[31:24];
							6'd1 :{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding[23:0];
						endcase
					endcase
					`pos_a,`pos_b,`pos_c:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd12:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
							6'd11:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding[23:0];
							
							6'd9 :{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
							6'd8 :{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding[23:0];
							
							6'd6 :{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];
							6'd5 :{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding[23:0];	
							
							6'd3 :{Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:16];
							6'd2 :{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding[23:0];
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd12:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd11:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							
							6'd9 :Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd8 :{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							
							6'd6 :Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd5 :{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							
							6'd3 :Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd2 :{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd12:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd11:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd10:Inter_ref_08_02 <= RefFrameOutPadding[7:0]; 
							
							6'd9 :{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd7 :Inter_ref_08_03 <= RefFrameOutPadding[7:0]; 
							
							6'd6 :{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd4 :Inter_ref_08_04 <= RefFrameOutPadding[7:0];
							
							6'd3 :{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd2 :{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd1 :Inter_ref_08_05 <= RefFrameOutPadding[7:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd12:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd11:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd10:{Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding[15:0];
							
							6'd9 :{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd8 :{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd7 :{Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding[15:0];
							
							6'd6 :{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd5 :{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd4 :{Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding[15:0];
							
							6'd3 :{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd2 :{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd1 :{Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding[15:0];	
						endcase
					endcase
					`pos_Int:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd4:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd3:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd2:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd1:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd8:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:8];
							6'd7:Inter_ref_05_02 <= RefFrameOutPadding[7:0];
							
							6'd6:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:8];
							6'd5:Inter_ref_05_03 <= RefFrameOutPadding[7:0];
							
							6'd4:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:8];
							6'd3:Inter_ref_05_04 <= RefFrameOutPadding[7:0];
							
							6'd2:{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:8];
							6'd1:Inter_ref_05_05 <= RefFrameOutPadding[7:0];
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd8:{Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[31:16];
							6'd7:{Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding[15:0];
							
							6'd6:{Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[31:16];
							6'd5:{Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding[15:0];
							
							6'd4:{Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[31:16];
							6'd3:{Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding[15:0];
							
							6'd2:{Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding[31:16];
							6'd1:{Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding[15:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)
							6'd8:Inter_ref_02_02 <= RefFrameOutPadding[31:24];
							6'd7:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding[23:0];
							
							6'd6:Inter_ref_02_03 <= RefFrameOutPadding[31:24];
							6'd5:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding[23:0];
							
							6'd4:Inter_ref_02_04 <= RefFrameOutPadding[31:24];
							6'd3:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding[23:0];
							
							6'd2:Inter_ref_02_05 <= RefFrameOutPadding[31:24];
							6'd1:{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding[23:0];
						endcase
					endcase
					`pos_e,`pos_g,`pos_p,`pos_r:
					case (xInt_org_unclip_1to0)
						2'b00:
						case (blk4x4_inter_preload_counter)
							6'd23:{Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding;
							6'd22:Inter_ref_06_00 <= RefFrameOutPadding[7:0];
							6'd21:{Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding;
							6'd20:Inter_ref_06_01 <= RefFrameOutPadding[7:0];
							
							6'd19:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
							6'd18:{Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding;
							6'd17:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02} <= RefFrameOutPadding[23:0];
							6'd16:{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];                          
							6'd15:{Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding;
							6'd14:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03} <= RefFrameOutPadding[23:0];          
							6'd13:{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];                          
							6'd12:{Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding;
							6'd11:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04} <= RefFrameOutPadding[23:0];          
							6'd10:{Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:16];                          
							6'd9 :{Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05} <= RefFrameOutPadding[23:0];          
							6'd7 :{Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:16];                          
							6'd6 :{Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06} <= RefFrameOutPadding[23:0];          
							
							6'd4 :{Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding;
							6'd3 :Inter_ref_06_07 <= RefFrameOutPadding[7:0];
							6'd2 :{Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding;
							6'd1 :Inter_ref_06_08 <= RefFrameOutPadding[7:0];
						endcase
						2'b01:
						case (blk4x4_inter_preload_counter)
							6'd23:{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:8];
							6'd22:{Inter_ref_06_00,Inter_ref_05_00} <= RefFrameOutPadding[15:0];
							6'd21:{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:8];
							6'd20:{Inter_ref_06_01,Inter_ref_05_01} <= RefFrameOutPadding[15:0];
							
							6'd19:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
							6'd18:{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
							6'd17:{Inter_ref_08_02,Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02} <= RefFrameOutPadding;
							6'd16:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
							6'd15:{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
							6'd14:{Inter_ref_08_03,Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03} <= RefFrameOutPadding;
							6'd13:Inter_ref_00_04 <= RefFrameOutPadding[31:24];
							6'd12:{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
							6'd11:{Inter_ref_08_04,Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04} <= RefFrameOutPadding;
							6'd10:Inter_ref_00_05 <= RefFrameOutPadding[31:24];
							6'd9 :{Inter_ref_04_05,Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_08_05,Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05} <= RefFrameOutPadding;
							6'd7 :Inter_ref_00_06 <= RefFrameOutPadding[31:24];
							6'd6 :{Inter_ref_04_06,Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_08_06,Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06} <= RefFrameOutPadding;
							
							6'd4 :{Inter_ref_04_07,Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:8];
							6'd3 :{Inter_ref_06_07,Inter_ref_05_07} <= RefFrameOutPadding[15:0];
							6'd2 :{Inter_ref_04_08,Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:8];
							6'd1 :{Inter_ref_06_08,Inter_ref_05_08} <= RefFrameOutPadding[15:0];
						endcase
						2'b10:
						case (blk4x4_inter_preload_counter)
							6'd23:{Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[31:16];
							6'd22:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00} <= RefFrameOutPadding[23:0];
							6'd21:{Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[31:16];
							6'd20:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01} <= RefFrameOutPadding[23:0];	
							
							6'd19:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
							6'd18:{Inter_ref_07_02,Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02} <= RefFrameOutPadding;
							6'd17:Inter_ref_08_02 <= RefFrameOutPadding[7:0]; 
							6'd16:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
							6'd15:{Inter_ref_07_03,Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03} <= RefFrameOutPadding;
							6'd14:Inter_ref_08_03 <= RefFrameOutPadding[7:0]; 
							6'd13:{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
							6'd12:{Inter_ref_07_04,Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04} <= RefFrameOutPadding;
							6'd11:Inter_ref_08_04 <= RefFrameOutPadding[7:0];
							6'd10:{Inter_ref_03_05,Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding;
							6'd9 :{Inter_ref_07_05,Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05} <= RefFrameOutPadding;
							6'd8 :Inter_ref_08_05 <= RefFrameOutPadding[7:0];
							6'd7 :{Inter_ref_03_06,Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding;
							6'd6 :{Inter_ref_07_06,Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06} <= RefFrameOutPadding;
							6'd5 :Inter_ref_08_06 <= RefFrameOutPadding[7:0];
							
							6'd4 :{Inter_ref_03_07,Inter_ref_02_07} <= RefFrameOutPadding[31:16];
							6'd3 :{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07} <= RefFrameOutPadding[23:0];
							6'd2 :{Inter_ref_03_08,Inter_ref_02_08} <= RefFrameOutPadding[31:16];
							6'd1 :{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08} <= RefFrameOutPadding[23:0];
						endcase
						2'b11:
						case (blk4x4_inter_preload_counter)	
							6'd23:Inter_ref_02_00 <= RefFrameOutPadding[31:24];
							6'd22:{Inter_ref_06_00,Inter_ref_05_00,Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding;
							6'd21:Inter_ref_02_01 <= RefFrameOutPadding[31:24];
							6'd20:{Inter_ref_06_01,Inter_ref_05_01,Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding;
							
							6'd19:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
							6'd18:{Inter_ref_06_02,Inter_ref_05_02,Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding;
							6'd17:{Inter_ref_08_02,Inter_ref_07_02} <= RefFrameOutPadding[15:0];
							6'd16:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
							6'd15:{Inter_ref_06_03,Inter_ref_05_03,Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding;
							6'd14:{Inter_ref_08_03,Inter_ref_07_03} <= RefFrameOutPadding[15:0];
							6'd13:{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
							6'd12:{Inter_ref_06_04,Inter_ref_05_04,Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding;
							6'd11:{Inter_ref_08_04,Inter_ref_07_04} <= RefFrameOutPadding[15:0];
							6'd10:{Inter_ref_02_05,Inter_ref_01_05,Inter_ref_00_05} <= RefFrameOutPadding[31:8];
							6'd9 :{Inter_ref_06_05,Inter_ref_05_05,Inter_ref_04_05,Inter_ref_03_05} <= RefFrameOutPadding;
							6'd8 :{Inter_ref_08_05,Inter_ref_07_05} <= RefFrameOutPadding[15:0];	
							6'd7 :{Inter_ref_02_06,Inter_ref_01_06,Inter_ref_00_06} <= RefFrameOutPadding[31:8];
							6'd6 :{Inter_ref_06_06,Inter_ref_05_06,Inter_ref_04_06,Inter_ref_03_06} <= RefFrameOutPadding;
							6'd5 :{Inter_ref_08_06,Inter_ref_07_06} <= RefFrameOutPadding[15:0];
							
							6'd4 :Inter_ref_02_07 <= RefFrameOutPadding[31:24];
							6'd3 :{Inter_ref_06_07,Inter_ref_05_07,Inter_ref_04_07,Inter_ref_03_07} <= RefFrameOutPadding;
							6'd2 :Inter_ref_02_08 <= RefFrameOutPadding[31:24];
							6'd1 :{Inter_ref_06_08,Inter_ref_05_08,Inter_ref_04_08,Inter_ref_03_08} <= RefFrameOutPadding;
						endcase
					endcase
				endcase
			endcase
		else if (IsInterChroma && blk4x4_inter_preload_counter != 0)
			begin
				if (mv_below8x8_curr == 1'b0)
					begin
						if (xFracC == 0 && yFracC == 0)	// 8 or 4 cycles
							case (xInt_org_unclip_1to0)
								2'b00:
								case (blk4x4_inter_preload_counter)
									6'd4:{Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding;
									6'd3:{Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding;
									6'd2:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
									6'd1:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
								endcase
								2'b01:
								case (blk4x4_inter_preload_counter)
									6'd8:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:8];
									6'd7:Inter_ref_03_00 <= RefFrameOutPadding[7:0];
									6'd6:{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:8];
									6'd5:Inter_ref_03_01 <= RefFrameOutPadding[7:0];
									6'd4:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
									6'd3:Inter_ref_03_02 <= RefFrameOutPadding[7:0];
									6'd2:{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
									6'd1:Inter_ref_03_03 <= RefFrameOutPadding[7:0];
								endcase
								2'b10:
								case (blk4x4_inter_preload_counter)
									6'd8:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
									6'd7:{Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[15:0];
									6'd6:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
									6'd5:{Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[15:0];
									6'd4:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
									6'd3:{Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[15:0];
									6'd2:{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
									6'd1:{Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[15:0];
								endcase
								2'b11:
								case (blk4x4_inter_preload_counter)
									6'd8:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
									6'd7:{Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00} <= RefFrameOutPadding[23:0];
									6'd6:Inter_ref_00_01 <= RefFrameOutPadding[31:24];
									6'd5:{Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01} <= RefFrameOutPadding[23:0];
									6'd4:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
									6'd3:{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding[23:0];
									6'd2:Inter_ref_00_03 <= RefFrameOutPadding[31:24];
									6'd1:{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding[23:0];
								endcase
							endcase
						else
							case (xInt_org_unclip_1to0)
								2'b00:
								case(blk4x4_inter_preload_counter)
									6'd10:{Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding;
									6'd9 :Inter_ref_04_00 <= RefFrameOutPadding[7:0];
									6'd8 :{Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding;
									6'd7 :Inter_ref_04_01 <= RefFrameOutPadding[7:0];
									6'd6 :{Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding;
									6'd5 :Inter_ref_04_02 <= RefFrameOutPadding[7:0];
									6'd4 :{Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding;
									6'd3 :Inter_ref_04_03 <= RefFrameOutPadding[7:0];
									6'd2 :{Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding;
									6'd1 :Inter_ref_04_04 <= RefFrameOutPadding[7:0];
								endcase
								2'b01:
								case (blk4x4_inter_preload_counter)
									6'd10:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:8];
									6'd9 :{Inter_ref_04_00,Inter_ref_03_00} <= RefFrameOutPadding[15:0];
									6'd8 :{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:8];
									6'd7 :{Inter_ref_04_01,Inter_ref_03_01} <= RefFrameOutPadding[15:0];
									6'd6 :{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
									6'd5 :{Inter_ref_04_02,Inter_ref_03_02} <= RefFrameOutPadding[15:0];
									6'd4 :{Inter_ref_02_03,Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:8];
									6'd3 :{Inter_ref_04_03,Inter_ref_03_03} <= RefFrameOutPadding[15:0];
									6'd2 :{Inter_ref_02_04,Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:8];
									6'd1 :{Inter_ref_04_04,Inter_ref_03_04} <= RefFrameOutPadding[15:0];
								endcase
								2'b10:
								case (blk4x4_inter_preload_counter)
									6'd10:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
									6'd9 :{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00} <= RefFrameOutPadding[23:0];
									6'd8 :{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
									6'd7 :{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01} <= RefFrameOutPadding[23:0];
									6'd6 :{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
									6'd5 :{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02} <= RefFrameOutPadding[23:0];
									6'd4 :{Inter_ref_01_03,Inter_ref_00_03} <= RefFrameOutPadding[31:16];
									6'd3 :{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03} <= RefFrameOutPadding[23:0];
									6'd2 :{Inter_ref_01_04,Inter_ref_00_04} <= RefFrameOutPadding[31:16];
									6'd1 :{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04} <= RefFrameOutPadding[23:0];
								endcase
								2'b11:
								case (blk4x4_inter_preload_counter)
									6'd10:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
									6'd9 :{Inter_ref_04_00,Inter_ref_03_00,Inter_ref_02_00,Inter_ref_01_00} <= RefFrameOutPadding;
									6'd8 :Inter_ref_00_01 <= RefFrameOutPadding[31:24];
									6'd7 :{Inter_ref_04_01,Inter_ref_03_01,Inter_ref_02_01,Inter_ref_01_01} <= RefFrameOutPadding;
									6'd6 :Inter_ref_00_02 <= RefFrameOutPadding[31:24];
									6'd5 :{Inter_ref_04_02,Inter_ref_03_02,Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding;
									6'd4 :Inter_ref_00_03 <= RefFrameOutPadding[31:24];
									6'd3 :{Inter_ref_04_03,Inter_ref_03_03,Inter_ref_02_03,Inter_ref_01_03} <= RefFrameOutPadding;
									6'd2 :Inter_ref_00_04 <= RefFrameOutPadding[31:24];
									6'd1 :{Inter_ref_04_04,Inter_ref_03_04,Inter_ref_02_04,Inter_ref_01_04} <= RefFrameOutPadding;
								endcase
							endcase
					end
				else	// mv_below8x8_curr == 1'b1
					begin
						if (xFracC == 0 && yFracC == 0)	// 4 or 2 cycles
							case (xInt_org_unclip_1to0)
								2'b00:
								case (blk4x4_inter_preload_counter)
									6'd2:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[15:0];
									6'd1:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[15:0];
								endcase
								2'b01:
								case (blk4x4_inter_preload_counter)
									6'd2:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[23:8];
									6'd1:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[23:8];
								endcase
								2'b10:
								case (blk4x4_inter_preload_counter)
									6'd2:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
									6'd1:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
								endcase
								2'b11:
								case (blk4x4_inter_preload_counter)
									6'd4:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
									6'd3:Inter_ref_01_00 <= RefFrameOutPadding[7:0];
									6'd2:Inter_ref_00_01 <= RefFrameOutPadding[31:24];
									6'd1:Inter_ref_01_01 <= RefFrameOutPadding[7:0];
								endcase
							endcase
						else	// 6 or 3 cycles
							case (xInt_org_unclip_1to0)
								2'b00:
								case (blk4x4_inter_preload_counter)
									6'd3:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[23:0];
									6'd2:{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[23:0];
									6'd1:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[23:0];
								endcase
								2'b01:
								case (blk4x4_inter_preload_counter)
									6'd3:{Inter_ref_02_00,Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:8];
									6'd2:{Inter_ref_02_01,Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:8];
									6'd1:{Inter_ref_02_02,Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:8];
								endcase
								2'b10:
								case (blk4x4_inter_preload_counter)
									6'd6:{Inter_ref_01_00,Inter_ref_00_00} <= RefFrameOutPadding[31:16];
									6'd5:Inter_ref_02_00 <= RefFrameOutPadding[7:0];
									6'd4:{Inter_ref_01_01,Inter_ref_00_01} <= RefFrameOutPadding[31:16];
									6'd3:Inter_ref_02_01 <= RefFrameOutPadding[7:0];
									6'd2:{Inter_ref_01_02,Inter_ref_00_02} <= RefFrameOutPadding[31:16];
									6'd1:Inter_ref_02_02 <= RefFrameOutPadding[7:0];
								endcase
								2'b11:
								case (blk4x4_inter_preload_counter)
									6'd6:Inter_ref_00_00 <= RefFrameOutPadding[31:24];
									6'd5:{Inter_ref_02_00,Inter_ref_01_00} <= RefFrameOutPadding[15:0];
									6'd4:Inter_ref_00_01 <= RefFrameOutPadding[31:24];
									6'd3:{Inter_ref_02_01,Inter_ref_01_01} <= RefFrameOutPadding[15:0];
									6'd2:Inter_ref_00_02 <= RefFrameOutPadding[31:24];
									6'd1:{Inter_ref_02_02,Inter_ref_01_02} <= RefFrameOutPadding[15:0];
								endcase
							endcase
					end
			end
			
endmodule
			
	
			
				
			
				
			
			
			
						
				
				

			
			
				
	
	
	
	