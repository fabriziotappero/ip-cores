//-----------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : DF_mem_ctrl.v
// Generated : Nov 27,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// controller for DF_mbAddrA_RAM & DF_mbAddrB_RAM & dis_frame_RAM
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module DF_mem_ctrl (clk,reset_n,gclk_end_of_MB_DEC,disable_DF,mb_num_h,mb_num_v,
	bs_curr_MR,bs_curr_MW,blk4x4_sum_counter,blk4x4_rec_counter_2_raster_order,
	DF_edge_counter_MR,DF_edge_counter_MW,one_edge_counter_MR,one_edge_counter_MW,
	blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	p3_MW,p2_MW,p1_MW,p0_MW,q3_MW,q2_MW,q1_MW,q0_MW,
	buf0_0,buf0_1,buf0_2,buf0_3,
	buf2_0,buf2_1,buf2_2,buf2_3,buf3_0,buf3_1,buf3_2,buf3_3,
	t0_0,t0_1,t0_2,t0_3,t1_0,t1_1,t1_2,t1_3,t2_0,t2_1,t2_2,t2_3,
	
	mb_num_h_DF,mb_num_v_DF,end_of_MB_DF,end_of_lastMB_DF,
	DF_mbAddrA_RF_rd,DF_mbAddrA_RF_wr,DF_mbAddrA_RF_rd_addr,DF_mbAddrA_RF_wr_addr,DF_mbAddrA_RF_din,
	DF_mbAddrB_RAM_rd,DF_mbAddrB_RAM_wr,DF_mbAddrB_RAM_addr,DF_mbAddrB_RAM_din,
	dis_frame_RAM_wr,dis_frame_RAM_wr_addr,dis_frame_RAM_din);
	input clk,reset_n;
	input disable_DF;
	input gclk_end_of_MB_DEC;
	input [3:0] mb_num_h;
	input [3:0] mb_num_v;
	input [2:0] bs_curr_MR,bs_curr_MW;
	input [2:0] blk4x4_sum_counter;
	input [4:0] blk4x4_rec_counter_2_raster_order;
	input [5:0] DF_edge_counter_MR,DF_edge_counter_MW;
	input [1:0]	one_edge_counter_MR,one_edge_counter_MW;
	input [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	input [7:0] p3_MW,p2_MW,p1_MW,p0_MW;
	input [7:0] q3_MW,q2_MW,q1_MW,q0_MW;
	input [31:0] buf0_0,buf0_1,buf0_2,buf0_3;
	input [31:0] buf2_0,buf2_1,buf2_2,buf2_3;
	input [31:0] buf3_0,buf3_1,buf3_2,buf3_3;
	input [31:0] t0_0,t0_1,t0_2,t0_3;
	input [31:0] t1_0,t1_1,t1_2,t1_3;
	input [31:0] t2_0,t2_1,t2_2,t2_3;
	
	output [3:0] mb_num_h_DF;
	output [3:0] mb_num_v_DF;
	output end_of_MB_DF; 
	output end_of_lastMB_DF;
	output DF_mbAddrA_RF_rd;
	output DF_mbAddrA_RF_wr;
	output [4:0] DF_mbAddrA_RF_rd_addr;
	output [4:0] DF_mbAddrA_RF_wr_addr;
	output [31:0] DF_mbAddrA_RF_din;
	
	output DF_mbAddrB_RAM_rd;
	output DF_mbAddrB_RAM_wr;
	output [8:0] DF_mbAddrB_RAM_addr;
	output [31:0] DF_mbAddrB_RAM_din;
	
	output dis_frame_RAM_wr;
	output [13:0] dis_frame_RAM_wr_addr;
	output [31:0] dis_frame_RAM_din;
	
	wire Is_mbAddrA_wr;
	wire Is_mbAddrA_real_wr;
	wire Is_mbAddrA_virtual_wr;
	wire Is_mbAddrB_wr;
	wire Is_currMB_wr;
	wire Is_12cycles_wr;
	wire dis_frame_RAM_wr_tmp;
	
	reg [3:0] mb_num_h_DF;
	reg [3:0] mb_num_v_DF;
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 1'b0)
			begin	mb_num_h_DF <= 0;			mb_num_v_DF <= 0;			end
		else if (!disable_DF)
			begin	mb_num_h_DF <= mb_num_h;	mb_num_v_DF <= mb_num_v;	end
		
	
	reg [3:0] DF_12_cycles; 
	always @ (posedge clk)
		if (reset_n == 1'b0)
			DF_12_cycles <= 4'd12;
		else if (!disable_DF && DF_edge_counter_MW == 6'd47 && one_edge_counter_MW == 2'd3)
			DF_12_cycles <= 0;
		else if (DF_12_cycles != 4'd12)
			DF_12_cycles <= DF_12_cycles + 1;
	
	reg end_of_MB_DF;
	reg end_of_lastMB_DF;//end of MB_DF of 98th MB of one frame.Does not need to rise MB_rec_DF_align since there is only
                       //DF and no reconstruction.So dispart end_of_lastMB_DF from end_of_MB_DF
							
	always @ (posedge clk)
		if (reset_n == 1'b0)
			begin
				end_of_MB_DF 	 <= 1'b0;
				end_of_lastMB_DF <= 1'b0;
			end	
		else if (DF_12_cycles == 4'd11)
			begin
				end_of_MB_DF 	   <= (!(mb_num_h_DF == 10 && mb_num_v_DF == 8))? 1'b1:1'b0;
				end_of_lastMB_DF <=   (mb_num_h_DF == 10 && mb_num_v_DF == 8)?  1'b1:1'b0;
			end
		else
			begin
				end_of_MB_DF 	   <= 1'b0;
				end_of_lastMB_DF <= 1'b0;
			end
			
	wire [1:0] write_0to3_cycle; 
	assign write_0to3_cycle = (DF_12_cycles == 4'd12)? one_edge_counter_MW:DF_12_cycles[1:0];
	//-------------------------------------------------------------------
	//DF_mbAddrA_RF control
	//-------------------------------------------------------------------
	
	//For edge 18,34,42,it will update mbAddrB of left MB.So no matter bs_curr_MR is equal to 0 or not,
	//mbAddrA should be read out for writing to mbAddrB of left MB.Otherwise,the value written to left
	//mbAddrB will be a wrong value.
	assign DF_mbAddrA_RF_rd = (mb_num_h_DF != 0 && (((
	DF_edge_counter_MR == 6'd0  || DF_edge_counter_MR == 6'd2  || DF_edge_counter_MR == 6'd16 || 
	DF_edge_counter_MR == 6'd32 || DF_edge_counter_MR == 6'd40) && bs_curr_MR != 0) || (
	DF_edge_counter_MR == 6'd18 || DF_edge_counter_MR == 6'd34 || DF_edge_counter_MR == 6'd42)));
	
	assign DF_mbAddrA_RF_wr = 	  (DF_edge_counter_MW == 6'd16 || DF_edge_counter_MW == 6'd30 ||
	DF_edge_counter_MW == 6'd32 || DF_edge_counter_MW == 6'd33 || DF_edge_counter_MW == 6'd40 ||
	DF_edge_counter_MW == 6'd41 || DF_12_cycles[3:2] == 2'b01  || DF_12_cycles[3:2] == 2'b10);
	//DF_mbAddrA_RF_rd_addr
	reg [2:0] DF_mbAddrA_RF_rd_addr_blk4x4;
	always @ (DF_mbAddrA_RF_rd or DF_edge_counter_MR)
		if (DF_mbAddrA_RF_rd)
			case (DF_edge_counter_MR)
				6'd0 :DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd0;	//mbAddrA0
				6'd2 :DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd1;	//mbAddrA1
				6'd16:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd2;	//mbAddrA2
				6'd18:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd3;	//mbAddrA3
				6'd32:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd4;	//mbAddrA4
				6'd34:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd5;	//mbAddrA5
				6'd40:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd6;	//mbAddrA6
				6'd42:DF_mbAddrA_RF_rd_addr_blk4x4 <= 3'd7;	//mbAddrA7
				default:DF_mbAddrA_RF_rd_addr_blk4x4 <= 0;
			endcase
		else
			DF_mbAddrA_RF_rd_addr_blk4x4 <= 0;
	assign DF_mbAddrA_RF_rd_addr = {5{DF_mbAddrA_RF_rd}} & 
									({DF_mbAddrA_RF_rd_addr_blk4x4,2'b0} + one_edge_counter_MR); 
	//DF_mbAddrA_RF_wr_addr
	reg [2:0] DF_mbAddrA_RF_wr_addr_blk4x4;
	always @ (DF_mbAddrA_RF_wr or DF_edge_counter_MW or DF_12_cycles[3:2])
		if (DF_mbAddrA_RF_wr)
			begin
				if (DF_edge_counter_MW != 6'd48)
					case (DF_edge_counter_MW)
						6'd16:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd0;	//mbAddrA0
						6'd30:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd1;	//mbAddrA1
						6'd32:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd2;	//mbAddrA2
						6'd33:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd3;	//mbAddrA3
						6'd40:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd4;	//mbAddrA4
						6'd41:DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd5;	//mbAddrA5
						default:DF_mbAddrA_RF_wr_addr_blk4x4 <= 0;
					endcase
				else if (DF_12_cycles[3:2] == 2'b01)
					DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd6;
				else
					DF_mbAddrA_RF_wr_addr_blk4x4 <= 3'd7;
			end
		else
			DF_mbAddrA_RF_wr_addr_blk4x4 <= 0;
				
	assign DF_mbAddrA_RF_wr_addr = {5{DF_mbAddrA_RF_wr}} & 
									({DF_mbAddrA_RF_wr_addr_blk4x4,2'b0} + write_0to3_cycle); 
	
	//DF_mbAddrA_RF_din
	wire Is_mbAddrA_t1; 
	assign Is_mbAddrA_t1 = (DF_edge_counter_MW == 6'd30 || DF_edge_counter_MW == 6'd33 || 
							DF_edge_counter_MW == 6'd41 || DF_12_cycles[3:2] == 2'b10);
	
	reg [31:0] DF_mbAddrA_RF_din; 
	always @ (DF_mbAddrA_RF_wr or Is_mbAddrA_t1 or write_0to3_cycle or 
		t0_0 or t0_1 or t0_2 or t0_3 or t1_0 or t1_1 or t1_2 or t1_3)
		if (DF_mbAddrA_RF_wr)
			begin 
				if (Is_mbAddrA_t1)
					case (write_0to3_cycle)
						2'd0:DF_mbAddrA_RF_din <= t1_0;
						2'd1:DF_mbAddrA_RF_din <= t1_1;
						2'd2:DF_mbAddrA_RF_din <= t1_2;
						2'd3:DF_mbAddrA_RF_din <= t1_3;
					endcase
				else
					case (write_0to3_cycle)
						2'd0:DF_mbAddrA_RF_din <= t0_0;
						2'd1:DF_mbAddrA_RF_din <= t0_1;
						2'd2:DF_mbAddrA_RF_din <= t0_2;
						2'd3:DF_mbAddrA_RF_din <= t0_3;
					endcase
			end
		else
			DF_mbAddrA_RF_din <= 0;
	//-------------------------------------------------------------------
	//DF_mbAddrB_RAM control
	//-------------------------------------------------------------------
	assign DF_mbAddrB_RAM_rd = (((
	DF_edge_counter_MR == 6'd4  || DF_edge_counter_MR == 6'd8  || DF_edge_counter_MR == 6'd12 || 
	DF_edge_counter_MR == 6'd13	|| DF_edge_counter_MR == 6'd36 || DF_edge_counter_MR == 6'd37 || 
	DF_edge_counter_MR == 6'd44 || DF_edge_counter_MR == 6'd45) && mb_num_v_DF != 0) || 
	DF_edge_counter_MR == 6'd20 || DF_edge_counter_MR == 6'd24 || DF_edge_counter_MR == 6'd28 || 
	DF_edge_counter_MR == 6'd29); 
	
	wire DF_mbAddrB_RAM_wr_curr;
	assign DF_mbAddrB_RAM_wr_curr = (((
	DF_edge_counter_MW == 6'd21 || DF_edge_counter_MW == 6'd25 || DF_edge_counter_MW == 6'd30 || 
	DF_edge_counter_MW == 6'd31 || DF_edge_counter_MW == 6'd38 || DF_edge_counter_MW == 6'd39 || 
	DF_edge_counter_MW == 6'd46 || DF_edge_counter_MW == 6'd47) && mb_num_v_DF != 4'd8) || 
	DF_edge_counter_MW == 6'd5  || DF_edge_counter_MW == 6'd9  || DF_edge_counter_MW == 6'd14 || 
	DF_edge_counter_MW == 6'd15); 
	
	wire DF_mbAddrB_RAM_wr_leftMB;
	assign DF_mbAddrB_RAM_wr_leftMB = (mb_num_h_DF != 0 && mb_num_v_DF != 4'd8 && ( 
	DF_edge_counter_MW == 6'd20 || DF_edge_counter_MW == 6'd37 || DF_edge_counter_MW == 6'd45));
	
	assign DF_mbAddrB_RAM_wr = DF_mbAddrB_RAM_wr_curr | DF_mbAddrB_RAM_wr_leftMB;
	
	reg [2:0] DF_mbAddrB_RAM_addr_blk4x4;
	always @ (DF_mbAddrB_RAM_rd or DF_edge_counter_MR or DF_mbAddrB_RAM_wr_curr 
		or DF_mbAddrB_RAM_wr_leftMB or DF_edge_counter_MW)
		if (DF_mbAddrB_RAM_rd)
			case (DF_edge_counter_MR)
				6'd4, 6'd20:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd0;
				6'd8, 6'd24:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd1;
				6'd12,6'd28:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd2;
				6'd13,6'd29:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd3;
				6'd36	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd4;
				6'd37	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd5;
				6'd44	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd6;
				6'd45	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd7;
				default	   :DF_mbAddrB_RAM_addr_blk4x4 <= 0;
			endcase
		else if (DF_mbAddrB_RAM_wr_curr)
			case (DF_edge_counter_MW)
				6'd5, 6'd21:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd0;
				6'd9, 6'd25:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd1;
				6'd14,6'd30:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd2;
				6'd15,6'd31:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd3;
				6'd38	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd4;
				6'd39	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd5;
				6'd46	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd6;
				6'd47	   :DF_mbAddrB_RAM_addr_blk4x4 <= 3'd7;
				default	   :DF_mbAddrB_RAM_addr_blk4x4 <= 0;
			endcase
		else if (DF_mbAddrB_RAM_wr_leftMB)
			case (DF_edge_counter_MW)
				6'd20:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd3;
				6'd37:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd5;
				default:DF_mbAddrB_RAM_addr_blk4x4 <= 3'd7;
			endcase
		else
			DF_mbAddrB_RAM_addr_blk4x4 <= 0;	
	
	reg [1:0] DF_mbAddrB_RAM_addr_offset;
	always @ (DF_mbAddrB_RAM_rd or one_edge_counter_MR or DF_mbAddrB_RAM_wr or one_edge_counter_MW)
		if 		  (DF_mbAddrB_RAM_rd)	DF_mbAddrB_RAM_addr_offset <= one_edge_counter_MR;
		else if (DF_mbAddrB_RAM_wr)	DF_mbAddrB_RAM_addr_offset <= one_edge_counter_MW;
		else						            DF_mbAddrB_RAM_addr_offset <= 0;
	
	wire [3:0] mb_num_h_DF_m1;
	assign mb_num_h_DF_m1 = {4{Is_mbAddrA_wr | DF_mbAddrB_RAM_wr_leftMB}} & (mb_num_h_DF - 1);
	
	wire [8:0] mb_num_h_DF_x32;
	assign mb_num_h_DF_x32 = (DF_mbAddrB_RAM_wr_leftMB)? {mb_num_h_DF_m1,5'b0}:{mb_num_h_DF,5'b0};
	assign DF_mbAddrB_RAM_addr = mb_num_h_DF_x32 + {DF_mbAddrB_RAM_addr_blk4x4,2'b0} + DF_mbAddrB_RAM_addr_offset;
	
	reg [31:0] DF_mbAddrB_RAM_din; 
	always @ (DF_mbAddrB_RAM_wr_curr or DF_mbAddrB_RAM_wr_leftMB or one_edge_counter_MW
		or q0_MW or q1_MW or q2_MW or q3_MW or t2_0 or t2_1 or t2_2 or t2_3)
		if (DF_mbAddrB_RAM_wr_curr)
			DF_mbAddrB_RAM_din <= {q3_MW,q2_MW,q1_MW,q0_MW};
		else if (DF_mbAddrB_RAM_wr_leftMB)
			case (one_edge_counter_MW)
				2'd0:DF_mbAddrB_RAM_din <= t2_0;
				2'd1:DF_mbAddrB_RAM_din <= t2_1;
				2'd2:DF_mbAddrB_RAM_din <= t2_2;
				2'd3:DF_mbAddrB_RAM_din <= t2_3;
			endcase
		else
			DF_mbAddrB_RAM_din <= 0;
	//-------------------------------------------------------------------
	//dis_frame_RAM write control
	//-------------------------------------------------------------------
	//dis_frame_RAM_wr
	assign Is_mbAddrA_wr = (mb_num_h_DF != 0 && (
	DF_edge_counter_MW == 6'd0  || DF_edge_counter_MW == 6'd2  || DF_edge_counter_MW == 6'd16 ||
	DF_edge_counter_MW == 6'd18 || DF_edge_counter_MW == 6'd32 || DF_edge_counter_MW == 6'd34 ||
	DF_edge_counter_MW == 6'd40 || DF_edge_counter_MW == 6'd42));
	assign Is_mbAddrA_real_wr    = (Is_mbAddrA_wr && bs_curr_MW != 0);
	assign Is_mbAddrA_virtual_wr = (Is_mbAddrA_wr && bs_curr_MW == 0);
	
	assign Is_mbAddrB_wr = (mb_num_v_DF != 0 && (
	DF_edge_counter_MW == 6'd5  || DF_edge_counter_MW == 6'd9  || DF_edge_counter_MW == 6'd13 ||
	DF_edge_counter_MW == 6'd14 || DF_edge_counter_MW == 6'd37 || DF_edge_counter_MW == 6'd38 || 
	DF_edge_counter_MW == 6'd45 || DF_edge_counter_MW == 6'd46));
	assign Is_currMB_wr = ((
	DF_edge_counter_MW == 6'd6  || DF_edge_counter_MW == 6'd10 || DF_edge_counter_MW == 6'd15 ||
	DF_edge_counter_MW == 6'd17 || DF_edge_counter_MW == 6'd21 || DF_edge_counter_MW == 6'd22 ||
	DF_edge_counter_MW == 6'd23 || DF_edge_counter_MW == 6'd25 || DF_edge_counter_MW == 6'd26 ||
	DF_edge_counter_MW == 6'd27 || DF_edge_counter_MW == 6'd29 || DF_edge_counter_MW == 6'd30 || 
	DF_edge_counter_MW == 6'd31 || DF_edge_counter_MW == 6'd33 || DF_edge_counter_MW == 6'd35 ||
	DF_edge_counter_MW == 6'd36 || DF_edge_counter_MW == 6'd39 || DF_edge_counter_MW == 6'd41 || 
	DF_edge_counter_MW == 6'd43 || DF_edge_counter_MW == 6'd44 || DF_edge_counter_MW == 6'd47) &&
	one_edge_counter_MW != 3'd4);
	assign Is_12cycles_wr = (DF_12_cycles != 4'd12); 
	
	assign dis_frame_RAM_wr_tmp = 
	( disable_DF && blk4x4_sum_counter[2] != 1'b1) || 
	(!disable_DF && (Is_mbAddrA_wr || Is_mbAddrB_wr || Is_currMB_wr || Is_12cycles_wr));
	assign dis_frame_RAM_wr = (dis_frame_RAM_wr_tmp & (~Is_mbAddrA_virtual_wr));
	
	wire Is_luma_wr;
	wire Is_chroma_wr;
	wire Is_1st_cycle_wr;	//if it is the position of first line of a 4x4 block,for both DF disable & enable 
	wire Is_MB_LeftTop_wr;	//if it is the position of most left-top for a whole MB,only for DF is disabled
	assign Is_luma_wr = (dis_frame_RAM_wr_tmp && (
	(disable_DF  && blk4x4_rec_counter_2_raster_order[4] == 1'b0) || 
	(!disable_DF && (((Is_mbAddrA_wr || Is_mbAddrB_wr) && !DF_edge_counter_MW[5]) ||
					 (Is_currMB_wr && DF_edge_counter_MW < 6'd39)))))? 1'b1:1'b0;
	
	assign Is_chroma_wr = (dis_frame_RAM_wr_tmp && !Is_luma_wr)? 1'b1:1'b0;
	
	assign Is_1st_cycle_wr = (
	( disable_DF && blk4x4_sum_counter == 0) || 
	(!disable_DF && (one_edge_counter_MW == 0 && (Is_mbAddrA_wr || Is_mbAddrB_wr || Is_currMB_wr)) || 
	(DF_12_cycles[1:0] == 2'b00 && DF_12_cycles[3:2] != 2'b11)))? 1'b1:1'b0;
	
	assign Is_MB_LeftTop_wr = (disable_DF && blk4x4_sum_counter == 0 && ( 
	(blk4x4_rec_counter_2_raster_order[4] == 1'b0 && blk4x4_rec_counter_2_raster_order[3:0] == 4'b0) || 
	(blk4x4_rec_counter_2_raster_order[4] == 1'b1 && blk4x4_rec_counter_2_raster_order[1:0] == 2'b0))) ? 1'b1:1'b0;
	
	//---------------------------------------------------------------------------------
	// dis_frame_RAM_wr_addr_base
	// Only updated at first write cycle(during 2,3,4 write cycle,it remains unchanged)
	// Luma:0	Cb:6336		Cr:7920
	//---------------------------------------------------------------------------------
	reg [12:0] dis_frame_RAM_wr_addr_base;
	always @ (disable_DF or Is_MB_LeftTop_wr or Is_1st_cycle_wr or Is_luma_wr or Is_12cycles_wr
		or blk4x4_rec_counter_2_raster_order[2] or DF_edge_counter_MW)
		if (disable_DF)
			begin
				if (Is_MB_LeftTop_wr)
					begin
						if (Is_luma_wr)											//luma			
							dis_frame_RAM_wr_addr_base <= 13'd0;
						else if (blk4x4_rec_counter_2_raster_order[2] == 1'b0)	//Cb
							dis_frame_RAM_wr_addr_base <= 13'd6336;
						else													//Cr
							dis_frame_RAM_wr_addr_base <= 13'd7920;
					end
				else
					dis_frame_RAM_wr_addr_base <= 13'd0;
			end
		else
			begin
				if (Is_1st_cycle_wr)	//update only @ 1st write cycle
					begin
						if (Is_luma_wr)								//luma	
							dis_frame_RAM_wr_addr_base <= 13'd0;
						else if (DF_edge_counter_MW < 6'd45 && DF_edge_counter_MW != 40 && DF_edge_counter_MW != 42) //Cb
							dis_frame_RAM_wr_addr_base <= 13'd6336;	
						else										//Cr
							dis_frame_RAM_wr_addr_base <= 13'd7920;
					end
				else
					dis_frame_RAM_wr_addr_base <= 0;
			end
	//---------------------------------------------------------------------------------
	// dis_frame_RAM_wr_addr_x
	// Only updated at first write cycle(during 2,3,4 write cycle,it remains unchanged)
	// x position inside a frame,since every 4 horizontal pixels have been combined as 
	// a single 32bit word,thus 0 ~ 43 for luma and 0 ~ 21 for chroma
	//---------------------------------------------------------------------------------
	wire [3:0] mb_num_v_DF_m1; 
	assign mb_num_v_DF_m1 = {4{Is_mbAddrB_wr}} & (mb_num_v_DF - 1);				 
	
	reg [1:0] blk4x4_xoffset;	//0 ~ 3,xoffset for blk4x4 inside a MB 
	always @ (Is_luma_wr or Is_mbAddrA_wr or Is_mbAddrB_wr or Is_currMB_wr or DF_12_cycles or DF_edge_counter_MW)
		case ({Is_mbAddrA_wr,Is_mbAddrB_wr,Is_currMB_wr})
			3'b100:	//Is_mbAddrA_wr
			if (Is_luma_wr)	blk4x4_xoffset <= 2'd3;
			else			blk4x4_xoffset <= 2'd1;
			3'b010:	//Is_mbAddrB_wr
			case (DF_edge_counter_MW)
				6'd5,6'd37,6'd45:blk4x4_xoffset <= 2'd0;
				6'd9,6'd38,6'd46:blk4x4_xoffset <= 2'd1;
				6'd13			:blk4x4_xoffset <= 2'd2;
				6'd14			:blk4x4_xoffset <= 2'd3;
				default			:blk4x4_xoffset <= 0;
			endcase
			3'b001:	//Is_currMB_wr
			case (DF_edge_counter_MW)
				//6'd6,6'd21,6'd23,6'd22,6'd39,6'd41,6'd47:blk4x4_xoffset <= 0;
				6'd10,6'd25,6'd27,6'd26,6'd43,6'd44	:blk4x4_xoffset <= 2'd1;
				6'd15,6'd29,6'd31,6'd33				      :blk4x4_xoffset <= 2'd2;
				6'd17,6'd30,6'd35,6'd36				      :blk4x4_xoffset <= 2'd3;
				default								              :blk4x4_xoffset <= 0;
			endcase
			default:
			if (DF_12_cycles != 4'd12)
				case (DF_12_cycles[3:2])
					2'b00		    :blk4x4_xoffset <= 0;		//buf2 -> blk22
					2'b01,2'b10	:blk4x4_xoffset <= 2'd1;	//T0 -> blk21,T1 -> blk23
					default		  :blk4x4_xoffset <= 0;
				endcase
			else
				blk4x4_xoffset <= 0;
		endcase
	
	reg [5:0] dis_frame_RAM_wr_addr_x;
	
	always @ (disable_DF or Is_MB_LeftTop_wr or Is_1st_cycle_wr or Is_luma_wr or Is_mbAddrA_wr 
		or Is_mbAddrB_wr or Is_currMB_wr or blk4x4_rec_counter_2_raster_order[1:0]
		or mb_num_h or mb_num_h_DF_m1 or mb_num_h_DF or blk4x4_xoffset)
		if (disable_DF)
			begin
				if (Is_MB_LeftTop_wr)
					dis_frame_RAM_wr_addr_x	<= (Is_luma_wr)? ({mb_num_h,2'b0} 	  + blk4x4_rec_counter_2_raster_order[1:0]):({1'b0,mb_num_h,1'b0} + blk4x4_rec_counter_2_raster_order[0]);
				else
					dis_frame_RAM_wr_addr_x <= 0;
			end
		else
			begin
				if (Is_1st_cycle_wr)
					case ({Is_mbAddrA_wr,Is_mbAddrB_wr,Is_currMB_wr})
						3'b100:	//Is_mbAddrA_wr
						dis_frame_RAM_wr_addr_x	<= (Is_luma_wr)? ({mb_num_h_DF_m1,2'b0} + blk4x4_xoffset):({1'b0,mb_num_h_DF_m1,1'b0} + blk4x4_xoffset);
						3'b010,3'b001:	//Is_mbAddrB_wr,Is_currMB_wr
						dis_frame_RAM_wr_addr_x	<= (Is_luma_wr)? ({mb_num_h_DF,2'b0}    + blk4x4_xoffset):({1'b0,mb_num_h_DF,1'b0}    + blk4x4_xoffset);
						
						default:		//for DF_12_cycles != 4'd12
						dis_frame_RAM_wr_addr_x <= {1'b0,mb_num_h_DF,1'b0} + blk4x4_xoffset;
					endcase
				else
					dis_frame_RAM_wr_addr_x <= 0;
			end
	//---------------------------------------------------------------------------------
	// dis_frame_RAM_wr_addr_y
	// a)Only updated at first write cycle(during 2,3,4 write cycle,it remains unchanged)
	// b)For 2,3,4 write cycles,dis_frame_RAM_wr_addr is directly +44/+22 instead of 
	//   changing dis_frame_RAM_wr_addr_y
	// c)y addr increase 1 means +44 for luma or +22 for choma
	//---------------------------------------------------------------------------------		
	reg [1:0] blk4x4_yoffset;	//0 ~ 3,yoffset for blk4x4 inside a MB 		
	always @ (Is_mbAddrA_wr or Is_currMB_wr or DF_12_cycles or DF_edge_counter_MW)
		if (Is_mbAddrA_wr)
			case (DF_edge_counter_MW)
				6'd0,6'd32,6'd40:blk4x4_yoffset <= 2'd0;
				6'd2,6'd34,6'd42:blk4x4_yoffset <= 2'd1;
				6'd16			      :blk4x4_yoffset <= 2'd2;
				6'd18			      :blk4x4_yoffset <= 2'd3;
				default			    :blk4x4_yoffset <= 0;
			endcase
		else if (Is_currMB_wr)
			case (DF_edge_counter_MW)
				//6'd6,6'd10,6'd15,6'd17,6'd39,6'd43,6'd47:blk4x4_yoffset <= 0;
				6'd21,6'd25,6'd29,6'd30,6'd41,6'd44	:blk4x4_yoffset <= 2'd1;
				6'd23,6'd27,6'd31,6'd35				      :blk4x4_yoffset <= 2'd2;
				6'd22,6'd26,6'd33,6'd36             :blk4x4_yoffset <= 2'd3;
				default								              :blk4x4_yoffset <= 0;
			endcase
		else if (DF_12_cycles != 4'd12)
			case (DF_12_cycles[2])
				1'b0:blk4x4_yoffset <= 2'd1;	// 0 ~ 3:buf2->22; 8 ~ 11:T1->23
				1'b1:blk4x4_yoffset <= 0;		// 4 ~ 7:T0->21
			endcase	
		else
			blk4x4_yoffset <= 0;
	
	reg [7:0] dis_frame_RAM_wr_addr_y;	//y position inside a frame,0 ~ 143 for luma & 0 ~ 71 for chroma 
	always @ (disable_DF or Is_MB_LeftTop_wr or Is_1st_cycle_wr or Is_luma_wr 
		or Is_mbAddrA_wr or Is_mbAddrB_wr or Is_mbAddrB_wr or  Is_currMB_wr
		or blk4x4_sum_counter[1:0] or blk4x4_rec_counter_2_raster_order[4:1] 
		or mb_num_v	or mb_num_v_DF or mb_num_v_DF_m1
		or one_edge_counter_MW or blk4x4_yoffset or DF_12_cycles)
		if (disable_DF)
			begin
				if (Is_MB_LeftTop_wr)
					dis_frame_RAM_wr_addr_y <= (Is_luma_wr)?
					({mb_num_v,4'b0} 	  + {blk4x4_rec_counter_2_raster_order[3:2],2'b00} + blk4x4_sum_counter[1:0]):
					({1'b0,mb_num_v,3'b0} + {blk4x4_rec_counter_2_raster_order[1],  2'b00} + blk4x4_sum_counter[1:0]);
				else
					dis_frame_RAM_wr_addr_y <= 0;
			end
		else
			begin
				if (Is_1st_cycle_wr)
					case ({Is_mbAddrA_wr,Is_mbAddrB_wr,Is_currMB_wr})
						3'b100:	//Is_mbAddrA_wr
						dis_frame_RAM_wr_addr_y <= (Is_luma_wr)?			//luma or chroma
						(({mb_num_v_DF,4'b0}      + {2'b00,blk4x4_yoffset,2'b00}) + one_edge_counter_MW):
						(({1'b0,mb_num_v_DF,3'b0} + {2'b00,blk4x4_yoffset,2'b00}) + one_edge_counter_MW);
						3'b010:	//Is_mbAddrB_wr
						dis_frame_RAM_wr_addr_y <= (Is_luma_wr)?			//luma or chroma
						(({mb_num_v_DF_m1,4'b0}      + 4'd12) + one_edge_counter_MW):
						(({1'b0,mb_num_v_DF_m1,3'b0} + 4'd4 ) + one_edge_counter_MW);
						3'b001:	//Is_currMB_wr
						dis_frame_RAM_wr_addr_y <= (Is_luma_wr)?			//luma or chroma
						(({mb_num_v_DF,4'b0} 	  + {blk4x4_yoffset,2'b0}) + one_edge_counter_MW):
						(({1'b0,mb_num_v_DF,3'b0} + {blk4x4_yoffset,2'b0}) + one_edge_counter_MW);
						default:
						if (DF_12_cycles != 4'd12)
							dis_frame_RAM_wr_addr_y <= {mb_num_v_DF,3'b0} + {blk4x4_yoffset,2'b0} + DF_12_cycles[1:0];
						else
							dis_frame_RAM_wr_addr_y <= 0;
					endcase
				else
					dis_frame_RAM_wr_addr_y <= 0;
			end
	
	
	wire [12:0] dis_frame_RAM_wr_addr_y_ext;	//every "y" increase will increase 44(luma) or 22(chroma) for
												//dis_frame_RAM address
	
	assign dis_frame_RAM_wr_addr_y_ext =  (Is_luma_wr)?
			//luma,  x44 = x32 + x8 + x4
			(	  {dis_frame_RAM_wr_addr_y,5'b0} + {2'b0,dis_frame_RAM_wr_addr_y,3'b0} + {3'b0,dis_frame_RAM_wr_addr_y,2'b0}):
			//chroma,x22 = x16 + x4 + x2
			({1'b0,dis_frame_RAM_wr_addr_y,4'b0} + {3'b0,dis_frame_RAM_wr_addr_y,2'b0} + {4'b0,dis_frame_RAM_wr_addr_y,1'b0});
	
	wire [13:0] dis_frame_RAM_wr_addr_tmp;
	reg [13:0] dis_frame_RAM_wr_addr_LeftTop_reg;
	reg [13:0] dis_frame_RAM_wr_addr_reg;
	reg [13:0] dis_frame_RAM_wr_addr;
	
	assign dis_frame_RAM_wr_addr_tmp = dis_frame_RAM_wr_addr_base + dis_frame_RAM_wr_addr_y_ext + dis_frame_RAM_wr_addr_x;
	always @ (posedge clk)
		if (reset_n == 1'b0)
			dis_frame_RAM_wr_addr_LeftTop_reg <= 0;
		else if (Is_MB_LeftTop_wr)
			dis_frame_RAM_wr_addr_LeftTop_reg <= dis_frame_RAM_wr_addr_tmp;
	
	always @ (disable_DF or Is_MB_LeftTop_wr or Is_1st_cycle_wr or Is_luma_wr or Is_chroma_wr or dis_frame_RAM_wr_addr_tmp 
		or dis_frame_RAM_wr_addr_reg or blk4x4_rec_counter_2_raster_order or dis_frame_RAM_wr_addr_LeftTop_reg)
		if (disable_DF)
			begin
				if (Is_MB_LeftTop_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_tmp;
				else if (Is_1st_cycle_wr)
					case (blk4x4_rec_counter_2_raster_order[4])
						1'b0:
						case (blk4x4_rec_counter_2_raster_order[3:2])
							2'b00:dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_LeftTop_reg + blk4x4_rec_counter_2_raster_order[1:0];
							2'b01:dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_LeftTop_reg + blk4x4_rec_counter_2_raster_order[1:0] + 176;
							2'b10:dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_LeftTop_reg + blk4x4_rec_counter_2_raster_order[1:0] + 352;
							2'b11:dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_LeftTop_reg + blk4x4_rec_counter_2_raster_order[1:0] + 528;
						endcase
						1'b1:
						dis_frame_RAM_wr_addr <= (blk4x4_rec_counter_2_raster_order[1])?
						(dis_frame_RAM_wr_addr_LeftTop_reg + 88 + blk4x4_rec_counter_2_raster_order[0]):
						(dis_frame_RAM_wr_addr_LeftTop_reg + blk4x4_rec_counter_2_raster_order[0]);
					endcase
				else if (Is_luma_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_reg + 44;
				else if (Is_chroma_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_reg + 22;
				else
					dis_frame_RAM_wr_addr <= 0;
			end
		else
			begin
				if (Is_1st_cycle_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_tmp;
				else if (Is_luma_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_reg + 44;
				else if (Is_chroma_wr)
					dis_frame_RAM_wr_addr <= dis_frame_RAM_wr_addr_reg + 22;
				else
					dis_frame_RAM_wr_addr <= 0;	
			end
			
	always @ (posedge clk)
		if (reset_n == 1'b0)
			dis_frame_RAM_wr_addr_reg <= 0;
		else if (dis_frame_RAM_wr_tmp)
			dis_frame_RAM_wr_addr_reg <= dis_frame_RAM_wr_addr;

	//dis_frame_RAM_din
	wire Is_mbAddrB_t1;
	wire Is_currMB_buf0;
	wire Is_currMB_buf2;
	wire Is_currMB_buf3;
	wire Is_currMB_t1;
	assign Is_mbAddrB_t1  = (DF_edge_counter_MW == 6'd14 || DF_edge_counter_MW == 6'd38 || 
							 DF_edge_counter_MW == 6'd46);
	assign Is_currMB_buf0 = (DF_edge_counter_MW == 6'd6  || DF_edge_counter_MW == 6'd15 || 
							 DF_edge_counter_MW == 6'd31 || DF_edge_counter_MW == 6'd39 ||
							 DF_edge_counter_MW == 6'd47);
	assign Is_currMB_buf2 = (DF_edge_counter_MW == 6'd22 || DF_edge_counter_MW == 6'd33 || 
							 DF_edge_counter_MW == 6'd41);
	assign Is_currMB_buf3 = (DF_edge_counter_MW == 6'd26);
	assign Is_currMB_t1   = (DF_edge_counter_MW == 6'd10 || DF_edge_counter_MW == 6'd23 || 
							 DF_edge_counter_MW == 6'd27 || DF_edge_counter_MW == 6'd30 || 
							 DF_edge_counter_MW == 6'd36 || DF_edge_counter_MW == 6'd44); 
					
	reg [31:0] dis_frame_RAM_din; 
	always @ (disable_DF or dis_frame_RAM_wr or blk4x4_sum_counter or one_edge_counter_MW or 
		DF_12_cycles or Is_mbAddrA_real_wr or Is_mbAddrB_wr or Is_mbAddrB_t1 or Is_currMB_buf0 or 
		Is_currMB_buf2 or Is_currMB_buf3 or Is_currMB_t1 or Is_currMB_wr or 
		blk4x4_sum_PE0_out or blk4x4_sum_PE1_out or blk4x4_sum_PE2_out or blk4x4_sum_PE3_out or
		p0_MW or p1_MW or p2_MW or p3_MW or 
		buf0_0 or buf0_1 or buf0_2 or buf0_3 or  
		buf2_0 or buf2_1 or buf2_2 or buf2_3 or buf3_0 or buf3_1 or buf3_2 or buf3_3 or 
		t0_0 or t0_1 or t0_2 or t0_3 or t1_0 or t1_1 or t1_2 or t1_3)
		if (disable_DF && dis_frame_RAM_wr)
			begin
				if (blk4x4_sum_counter[2] == 1'b0)
					dis_frame_RAM_din <= {blk4x4_sum_PE3_out,blk4x4_sum_PE2_out,blk4x4_sum_PE1_out,blk4x4_sum_PE0_out};
				else
					dis_frame_RAM_din <= 0;
			end
		else if (!disable_DF && dis_frame_RAM_wr)
			case ({Is_mbAddrA_real_wr,Is_mbAddrB_wr,Is_currMB_wr})
				3'b100:	//Is_mbAddrA_wr
				dis_frame_RAM_din <= {p0_MW,p1_MW,p2_MW,p3_MW};
				3'b010:	//Is_mbAddrB_wr
				begin
					if (Is_mbAddrB_t1)		//T1 -> mbAddrB
						case (one_edge_counter_MW)
							2'd0:dis_frame_RAM_din <= t1_0;
							2'd1:dis_frame_RAM_din <= t1_1;
							2'd2:dis_frame_RAM_din <= t1_2;
							2'd3:dis_frame_RAM_din <= t1_3;
						endcase
					else 					//T0 -> mbAddrB
						case (one_edge_counter_MW)
							2'd0:dis_frame_RAM_din <= t0_0;
							2'd1:dis_frame_RAM_din <= t0_1;
							2'd2:dis_frame_RAM_din <= t0_2;
							2'd3:dis_frame_RAM_din <= t0_3;
						endcase
				end
				3'b001:	//Is_currMB_wr
				case ({Is_currMB_buf0,Is_currMB_buf2,Is_currMB_buf3,Is_currMB_t1})
					4'b1000:	//Is_currMB_buf0
					case (one_edge_counter_MW)
						2'd0:dis_frame_RAM_din <= buf0_0;
						2'd1:dis_frame_RAM_din <= buf0_1;
						2'd2:dis_frame_RAM_din <= buf0_2;
						2'd3:dis_frame_RAM_din <= buf0_3;
					endcase
					4'b0100:	//Is_currMB_buf2
					case (one_edge_counter_MW)
						2'd0:dis_frame_RAM_din <= buf2_0;
						2'd1:dis_frame_RAM_din <= buf2_1;
						2'd2:dis_frame_RAM_din <= buf2_2;
						2'd3:dis_frame_RAM_din <= buf2_3;
					endcase
					4'b0010:	//Is_currMB_buf3
					case (one_edge_counter_MW)
						2'd0:dis_frame_RAM_din <= buf3_0;
						2'd1:dis_frame_RAM_din <= buf3_1;
						2'd2:dis_frame_RAM_din <= buf3_2;
						2'd3:dis_frame_RAM_din <= buf3_3;
					endcase
					4'b0001:	//Is_currMB_t1
					case (one_edge_counter_MW)
						2'd0:dis_frame_RAM_din <= t1_0;
						2'd1:dis_frame_RAM_din <= t1_1;
						2'd2:dis_frame_RAM_din <= t1_2;
						2'd3:dis_frame_RAM_din <= t1_3;
					endcase
					default:	//Is_currMB_t0
					case (one_edge_counter_MW)
						2'd0:dis_frame_RAM_din <= t0_0;
						2'd1:dis_frame_RAM_din <= t0_1;
						2'd2:dis_frame_RAM_din <= t0_2;
						2'd3:dis_frame_RAM_din <= t0_3;
					endcase
				endcase
				default://additional 12 cycles
				case (DF_12_cycles[3:2])
					2'b00:	//0 ~ 3,buf2 -> blk22
					case (DF_12_cycles[1:0])
						2'd0:dis_frame_RAM_din <= buf2_0;
						2'd1:dis_frame_RAM_din <= buf2_1;
						2'd2:dis_frame_RAM_din <= buf2_2;
						2'd3:dis_frame_RAM_din <= buf2_3;
					endcase
					2'b01:	//4 ~ 7,T0	-> blk21
					case (DF_12_cycles[1:0])
						2'd0:dis_frame_RAM_din <= t0_0;
						2'd1:dis_frame_RAM_din <= t0_1;
						2'd2:dis_frame_RAM_din <= t0_2;
						2'd3:dis_frame_RAM_din <= t0_3;
					endcase
					default://8 ~ 11,T1 -> blk23
					case (DF_12_cycles[1:0])
						2'd0:dis_frame_RAM_din <= t1_0;
						2'd1:dis_frame_RAM_din <= t1_1;
						2'd2:dis_frame_RAM_din <= t1_2;
						2'd3:dis_frame_RAM_din <= t1_3;
					endcase
				endcase
			endcase
		else
			dis_frame_RAM_din <= 0;
endmodule
			
			
					
							
							
					
							
					
						
										
	
					
					
					
				
	
	
	
	  
	
	
	
	
	
	
			
	
	

	