//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : ext_frame_RAM1_wrapper.v
// Generated : April 23,2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// SRAM beha model for external RAM tween reconstruction and deblocking filter (9504x32bit)
// Sync Read,Sync Write
//-------------------------------------------------------------------------------------------------
// Revise log 
// 1.July 23,2006
// Change the ext_frame_RAM1 from async read to sync read.
//
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module ext_frame_RAM1_wrapper (clk,reset_n,ext_frame_RAM1_cs_n,ext_frame_RAM1_wr,ext_frame_RAM1_addr,dis_frame_RAM_din,ext_frame_RAM1_data,
	pic_num,slice_header_s6);
	input clk; 
	input reset_n;
	input ext_frame_RAM1_cs_n;
	input ext_frame_RAM1_wr;
	input [13:0] ext_frame_RAM1_addr;
	input [31:0] dis_frame_RAM_din;
	input [5:0] pic_num;
	input slice_header_s6;
	output [31:0] ext_frame_RAM1_data;
	
	reg [31:0] ext_frame_RAM1 [0:9503];
	reg [31:0] ext_frame_RAM1_data;
	
	always @ (posedge clk)
		if (!ext_frame_RAM1_cs_n && ext_frame_RAM1_wr)
			ext_frame_RAM1[ext_frame_RAM1_addr] <= dis_frame_RAM_din;
	
	//assign ext_frame_RAM1_data = (!ext_frame_RAM1_cs_n && !ext_frame_RAM1_wr)? ext_frame_RAM1[ext_frame_RAM1_addr]:32'bz;
	
	always @ (posedge clk)
		if (!ext_frame_RAM1_cs_n && !ext_frame_RAM1_wr)
			ext_frame_RAM1_data <= ext_frame_RAM1[ext_frame_RAM1_addr];

	// synopsys translate_off
	integer	tracefile_display;
	integer tracefile_verify;
	integer	mb_num;
	integer	j;
	reg [31:0] luma_out0,luma_out1,luma_out2,luma_out3;
	reg [31:0] Cb_out0,Cb_out1;
	reg [31:0] Cr_out0,Cr_out1;
	reg [8:0] pic_num_ext;
	
	parameter display = 1;
	parameter verify  = 1;
	
always @ (negedge reset_n or pic_num)
		if (reset_n == 1'b0)
			pic_num_ext <= 0;
		else
			pic_num_ext <= pic_num_ext + 1;
	
	always @ (posedge clk)
		if (slice_header_s6 == 1'b1 && pic_num[0] == 1'b0 && pic_num_ext != 0)
			begin
				if (display == 1'b1)	//display
					begin
						tracefile_display = $fopen("nova_display.log","a");
						for (j= 0; j < 9504; j= j + 1)
							begin
								$fdisplay (tracefile_display,"%h",ext_frame_RAM1[j]);
							end
						$fclose(tracefile_display);
					end
				if (verify == 1'b1)		//verify
					begin
						tracefile_verify = $fopen("nova_MB_output.log","a");
						for (mb_num = 0;mb_num < 99; mb_num = mb_num + 1)
							begin
								$fdisplay (tracefile_verify,"-------------------------------------------");
								$fdisplay (tracefile_verify," Pic_num = %3d,MB_num = %3d",pic_num_ext - 1,mb_num);
								$fdisplay (tracefile_verify,"-------------------------------------------");
								$fdisplay (tracefile_verify," luma 16x16 block:");
								for (j = 0; j < 16; j = j + 1)
									begin
										luma_out0 = ext_frame_RAM1[(mb_num/11)*704+(mb_num%11)*4+j*44];
										luma_out1 = ext_frame_RAM1[(mb_num/11)*704+(mb_num%11)*4+j*44+1];
										luma_out2 = ext_frame_RAM1[(mb_num/11)*704+(mb_num%11)*4+j*44+2];
										luma_out3 = ext_frame_RAM1[(mb_num/11)*704+(mb_num%11)*4+j*44+3];
										
										$fdisplay (tracefile_verify," %3H %3H %3H %3H | %3H %3H %3H %3H | %3H %3H %3H %3H | %3H %3H %3H %3H",
										luma_out0[7:0],luma_out0[15:8],luma_out0[23:16],luma_out0[31:24],
										luma_out1[7:0],luma_out1[15:8],luma_out1[23:16],luma_out1[31:24],
										luma_out2[7:0],luma_out2[15:8],luma_out2[23:16],luma_out2[31:24],
										luma_out3[7:0],luma_out3[15:8],luma_out3[23:16],luma_out3[31:24]);
										
										if (j == 3 || j == 7 || j == 11)
											$fdisplay (tracefile_verify, "");
									end
								$fdisplay (tracefile_verify," Chroma Cb 8x8 block:");
								for (j = 0; j < 8; j = j + 1)
									begin
										Cb_out0 = ext_frame_RAM1[6336+(mb_num/11)*176+(mb_num%11)*2+j*22];
										Cb_out1 = ext_frame_RAM1[6336+(mb_num/11)*176+(mb_num%11)*2+j*22+1];
										
										$fdisplay (tracefile_verify, " %3H %3H %3H %3H | %3H %3H %3H %3H",
										Cb_out0[7:0],Cb_out0[15:8],Cb_out0[23:16],Cb_out0[31:24],
										Cb_out1[7:0],Cb_out1[15:8],Cb_out1[23:16],Cb_out1[31:24]);
										if (j == 3)
											$fdisplay (tracefile_verify, "");
									end	
								$fdisplay (tracefile_verify," Chroma Cr 8x8 block:");
								for (j = 0; j < 8; j = j + 1)
									begin
										Cr_out0 = ext_frame_RAM1[7920+(mb_num/11)*176+(mb_num%11)*2+j*22];
										Cr_out1 = ext_frame_RAM1[7920+(mb_num/11)*176+(mb_num%11)*2+j*22+1];
										
										$fdisplay (tracefile_verify, " %3H %3H %3H %3H | %3H %3H %3H %3H",
										Cr_out0[7:0],Cr_out0[15:8],Cr_out0[23:16],Cr_out0[31:24],
										Cr_out1[7:0],Cr_out1[15:8],Cr_out1[23:16],Cr_out1[31:24]);
										if (j == 3)
											$fdisplay (tracefile_verify, "");
									end
							end
						$fclose(tracefile_verify);
					end
			end
	// synopsys translate_on
endmodule