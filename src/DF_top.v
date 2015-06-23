//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : DF_top.v
// Generated : Dec 30, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Top module of deblocking filter
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module DF_top (clk,reset_n,gclk_DF,gclk_end_of_MB_DEC,gclk_DF_mbAddrA_RF,gclk_DF_mbAddrB_RAM,
	end_of_BS_DEC,disable_DF,mb_num_h,mb_num_v,
	bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3,
	QPy,QPc,slice_alpha_c0_offset_div2,slice_beta_offset_div2,
	blk4x4_sum_counter,blk4x4_rec_counter_2_raster_order,rec_DF_RAM_dout,
	blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	
	DF_duration,end_of_MB_DF,DF_edge_counter_MR,one_edge_counter_MR,
	DF_mbAddrA_RF_rd,DF_mbAddrA_RF_wr,DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr,
	dis_frame_RAM_wr,dis_frame_RAM_wr_addr,dis_frame_RAM_din);
	input clk;
	input gclk_DF;
	input gclk_end_of_MB_DEC;
	input gclk_DF_mbAddrA_RF;
	input gclk_DF_mbAddrB_RAM;
	input reset_n;
	input end_of_BS_DEC;
	input disable_DF;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	input [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	input [5:0] QPy,QPc;
	input [3:0] slice_alpha_c0_offset_div2;
	input [3:0]	slice_beta_offset_div2;
	input [31:0] rec_DF_RAM_dout;
	input [2:0] blk4x4_sum_counter;
	input [4:0] blk4x4_rec_counter_2_raster_order;
	input [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	
	output DF_duration;
	output end_of_MB_DF;
	output [5:0] DF_edge_counter_MR;
	output [1:0] one_edge_counter_MR;
	output DF_mbAddrA_RF_rd,DF_mbAddrA_RF_wr;
	output DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr;
	output dis_frame_RAM_wr;
	output [13:0] dis_frame_RAM_wr_addr;
	output [31:0] dis_frame_RAM_din;
	
	wire end_of_MB_DF;
	wire end_of_lastMB_DF;
	wire [3:0] mb_num_h_DF;
	wire [3:0] mb_num_v_DF;
	wire [5:0] DF_edge_counter_MR,DF_edge_counter_MW;
	wire [1:0] one_edge_counter_MR,one_edge_counter_MW;
	wire [2:0] bs_curr_MR,bs_curr_MW;
	wire [7:0] q0_MW,q1_MW,q2_MW,q3_MW;
	wire [7:0] p0_MW,p1_MW,p2_MW,p3_MW;
	wire [31:0] buf0_0,buf0_1,buf0_2,buf0_3;
	wire [31:0] buf1_0,buf1_1,buf1_2,buf1_3;
	wire [31:0] buf2_0,buf2_1,buf2_2,buf2_3;
	wire [31:0] buf3_0,buf3_1,buf3_2,buf3_3;
	wire [31:0] t0_0,t0_1,t0_2,t0_3;
	wire [31:0] t1_0,t1_1,t1_2,t1_3;
	wire [31:0] t2_0,t2_1,t2_2,t2_3;
	wire DF_mbAddrA_RF_rd;
	wire DF_mbAddrA_RF_wr;
	wire [4:0] DF_mbAddrA_RF_rd_addr;
	wire [4:0] DF_mbAddrA_RF_wr_addr;
	wire [31:0] DF_mbAddrA_RF_din;
	wire [31:0] DF_mbAddrA_RF_dout;
	wire DF_mbAddrB_RAM_rd;
	wire DF_mbAddrB_RAM_wr;
	wire [8:0] DF_mbAddrB_RAM_addr;
	wire [31:0] DF_mbAddrB_RAM_din;
	wire [31:0] DF_mbAddrB_RAM_dout;
		
	DF_pipeline DF_pipeline (
		.clk(clk),
		.gclk_DF(gclk_DF),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.reset_n(reset_n),
		.disable_DF(disable_DF),
		.end_of_BS_DEC(end_of_BS_DEC), 
		.end_of_MB_DF(end_of_MB_DF),
		.end_of_lastMB_DF(end_of_lastMB_DF),
		.bs_V0(bs_V0),.bs_V1(bs_V1),.bs_V2(bs_V2),.bs_V3(bs_V3),
		.bs_H0(bs_H0),.bs_H1(bs_H1),.bs_H2(bs_H2),.bs_H3(bs_H3),
		.QPy(QPy),
		.QPc(QPc),
		.slice_alpha_c0_offset_div2(slice_alpha_c0_offset_div2),
		.slice_beta_offset_div2(slice_beta_offset_div2),
		.DF_mbAddrA_RF_dout(DF_mbAddrA_RF_dout),
		.DF_mbAddrB_RAM_dout(DF_mbAddrB_RAM_dout),
		.rec_DF_RAM_dout(rec_DF_RAM_dout),
		.buf0_0(buf0_0),.buf0_1(buf0_1),.buf0_2(buf0_2),.buf0_3(buf0_3),
		.buf1_0(buf1_0),.buf1_1(buf1_1),.buf1_2(buf1_2),.buf1_3(buf1_3),
		.buf2_0(buf2_0),.buf2_1(buf2_1),.buf2_2(buf2_2),.buf2_3(buf2_3),
		.buf3_0(buf3_0),.buf3_1(buf3_1),.buf3_2(buf3_2),.buf3_3(buf3_3),
		
		.DF_duration(DF_duration),
		.DF_edge_counter_MR(DF_edge_counter_MR),
		.DF_edge_counter_MW(DF_edge_counter_MW),
		.one_edge_counter_MR(one_edge_counter_MR),
		.one_edge_counter_MW(one_edge_counter_MW),
		.bs_curr_MR(bs_curr_MR),
		.bs_curr_MW(bs_curr_MW),
		.q0_MW(q0_MW),.q1_MW(q1_MW),.q2_MW(q2_MW),.q3_MW(q3_MW),
		.p0_MW(p0_MW),.p1_MW(p1_MW),.p2_MW(p2_MW),.p3_MW(p3_MW)
		); 
	DF_reg_ctrl DF_reg_ctrl (
		.gclk_DF(gclk_DF),
		.reset_n(reset_n),
		.DF_edge_counter_MW(DF_edge_counter_MW),
		.one_edge_counter_MW(one_edge_counter_MW),
		.mb_num_h_DF(mb_num_h_DF),
		.mb_num_v_DF(mb_num_v_DF),
		
		.q0_MW(q0_MW),.q1_MW(q1_MW),.q2_MW(q2_MW),.q3_MW(q3_MW),
		.p0_MW(p0_MW),.p1_MW(p1_MW),.p2_MW(p2_MW),.p3_MW(p3_MW),
		.buf0_0(buf0_0),.buf0_1(buf0_1),.buf0_2(buf0_2),.buf0_3(buf0_3),
		.buf1_0(buf1_0),.buf1_1(buf1_1),.buf1_2(buf1_2),.buf1_3(buf1_3),
		.buf2_0(buf2_0),.buf2_1(buf2_1),.buf2_2(buf2_2),.buf2_3(buf2_3),
		.buf3_0(buf3_0),.buf3_1(buf3_1),.buf3_2(buf3_2),.buf3_3(buf3_3),
		.t0_0(t0_0),.t0_1(t0_1),.t0_2(t0_2),.t0_3(t0_3),
		.t1_0(t1_0),.t1_1(t1_1),.t1_2(t1_2),.t1_3(t1_3),
		.t2_0(t2_0),.t2_1(t2_1),.t2_2(t2_2),.t2_3(t2_3)
		);
		
	DF_mem_ctrl DF_mem_ctrl (
		.clk(clk),
		.reset_n(reset_n),
		.gclk_end_of_MB_DEC(gclk_end_of_MB_DEC),
		.disable_DF(disable_DF),
		.mb_num_h(mb_num_h),
		.mb_num_v(mb_num_v),
		.bs_curr_MR(bs_curr_MR),
		.bs_curr_MW(bs_curr_MW),
		.blk4x4_sum_counter(blk4x4_sum_counter),
		.blk4x4_rec_counter_2_raster_order(blk4x4_rec_counter_2_raster_order),
		.DF_edge_counter_MR(DF_edge_counter_MR),
		.DF_edge_counter_MW(DF_edge_counter_MW),
		.one_edge_counter_MR(one_edge_counter_MR),
		.one_edge_counter_MW(one_edge_counter_MW),
		.blk4x4_sum_PE0_out(blk4x4_sum_PE0_out),
		.blk4x4_sum_PE1_out(blk4x4_sum_PE1_out),
		.blk4x4_sum_PE2_out(blk4x4_sum_PE2_out),
		.blk4x4_sum_PE3_out(blk4x4_sum_PE3_out),
		.q0_MW(q0_MW),.q1_MW(q1_MW),.q2_MW(q2_MW),.q3_MW(q3_MW),
		.p0_MW(p0_MW),.p1_MW(p1_MW),.p2_MW(p2_MW),.p3_MW(p3_MW),
		.buf0_0(buf0_0),.buf0_1(buf0_1),.buf0_2(buf0_2),.buf0_3(buf0_3),
		.buf2_0(buf2_0),.buf2_1(buf2_1),.buf2_2(buf2_2),.buf2_3(buf2_3),
		.buf3_0(buf3_0),.buf3_1(buf3_1),.buf3_2(buf3_2),.buf3_3(buf3_3),
		.t0_0(t0_0),.t0_1(t0_1),.t0_2(t0_2),.t0_3(t0_3),
		.t1_0(t1_0),.t1_1(t1_1),.t1_2(t1_2),.t1_3(t1_3),
		.t2_0(t2_0),.t2_1(t2_1),.t2_2(t2_2),.t2_3(t2_3),
		
		.mb_num_h_DF(mb_num_h_DF),
		.mb_num_v_DF(mb_num_v_DF),
		.end_of_MB_DF(end_of_MB_DF),
		.end_of_lastMB_DF(end_of_lastMB_DF),
	  .DF_mbAddrA_RF_rd(DF_mbAddrA_RF_rd),
		.DF_mbAddrA_RF_wr(DF_mbAddrA_RF_wr),
		.DF_mbAddrA_RF_rd_addr(DF_mbAddrA_RF_rd_addr),
		.DF_mbAddrA_RF_wr_addr(DF_mbAddrA_RF_wr_addr),
		.DF_mbAddrA_RF_din(DF_mbAddrA_RF_din),
		.DF_mbAddrB_RAM_rd(DF_mbAddrB_RAM_rd),
		.DF_mbAddrB_RAM_wr(DF_mbAddrB_RAM_wr),
		.DF_mbAddrB_RAM_addr(DF_mbAddrB_RAM_addr),
		.DF_mbAddrB_RAM_din(DF_mbAddrB_RAM_din),
		.dis_frame_RAM_wr(dis_frame_RAM_wr),
		.dis_frame_RAM_wr_addr(dis_frame_RAM_wr_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din)
		);
	ram_sync_1r_sync_1w # (`DF_mbAddrA_RAM_data_width,`DF_mbAddrA_RAM_data_depth)
	DF_mbAddrA_RAM (
		.clk(gclk_DF_mbAddrA_RF),
		.rst_n(reset_n),
		.wr_n(~DF_mbAddrA_RF_wr),
		.rd_n(~DF_mbAddrA_RF_rd),
		.wr_addr(DF_mbAddrA_RF_wr_addr),
		.rd_addr(DF_mbAddrA_RF_rd_addr),
		.data_in(DF_mbAddrA_RF_din),
		.data_out(DF_mbAddrA_RF_dout)
		);
	ram_sync_1r_sync_1w # (`DF_mbAddrB_RAM_data_width,`DF_mbAddrB_RAM_data_depth)
	DF_mbAddrB_RAM (
		.clk(gclk_DF_mbAddrB_RAM),
		.rst_n(reset_n),
		.wr_n(~DF_mbAddrB_RAM_wr),
		.rd_n(~DF_mbAddrB_RAM_rd),
		.wr_addr(DF_mbAddrB_RAM_addr),
		.rd_addr(DF_mbAddrB_RAM_addr),
		.data_in(DF_mbAddrB_RAM_din),
		.data_out(DF_mbAddrB_RAM_dout)
		);
endmodule