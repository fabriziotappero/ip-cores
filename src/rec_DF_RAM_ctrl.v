//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : rec_DF_RAM_ctrl.v
// Generated : Nov 3, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Controller for rec_DF_RAM0 & rec_DF_RAM1,single port SRAM
// write during reconstruction,read during DF
// assume "_wr" & "_rd" are both high active
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module rec_DF_RAM_ctrl (clk,reset_n,disable_DF,end_of_MB_DEC,
	DF_edge_counter_MR,one_edge_counter_MR,
	blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out,
	blk4x4_sum_counter,blk4x4_rec_counter_2_raster_order,rec_DF_RAM0_dout,rec_DF_RAM1_dout,
	
	rec_DF_RAM_dout,
	rec_DF_RAM0_wr,rec_DF_RAM0_rd,rec_DF_RAM0_addr,rec_DF_RAM0_din,
	rec_DF_RAM1_wr,rec_DF_RAM1_rd,rec_DF_RAM1_addr,rec_DF_RAM1_din);
	input clk,reset_n;
	input disable_DF;
	input end_of_MB_DEC;
	input [5:0] DF_edge_counter_MR;
	input [1:0] one_edge_counter_MR;
	input [7:0] blk4x4_sum_PE0_out,blk4x4_sum_PE1_out,blk4x4_sum_PE2_out,blk4x4_sum_PE3_out;
	input [2:0] blk4x4_sum_counter;
	input [4:0] blk4x4_rec_counter_2_raster_order;
	input [31:0] rec_DF_RAM0_dout,rec_DF_RAM1_dout;
	
	output [31:0] rec_DF_RAM_dout;
	output rec_DF_RAM0_wr;
	output rec_DF_RAM0_rd;
	output [6:0]rec_DF_RAM0_addr;
	output [31:0] rec_DF_RAM0_din;
	output rec_DF_RAM1_wr;
	output rec_DF_RAM1_rd;
	output [6:0]rec_DF_RAM1_addr;
	output [31:0] rec_DF_RAM1_din;
	
	reg rec_DF_RAM0_wr;
	reg rec_DF_RAM0_rd;
	reg [6:0]rec_DF_RAM0_addr;
	reg [31:0] rec_DF_RAM0_din;
	reg rec_DF_RAM1_wr;
	reg rec_DF_RAM1_rd;
	reg [6:0]rec_DF_RAM1_addr;
	reg [31:0] rec_DF_RAM1_din;
	//-----------------------------------------------------------------
	//Write:after reconstruction 
	//-----------------------------------------------------------------	
	wire rec_DF_RAM_wr;
	wire [4:0] rec_DF_RAM_wr_addr_blk4x4;
	wire [1:0] rec_DF_RAM_wr_addr_offset;
	wire [6:0] rec_DF_RAM_wr_addr;
	wire [31:0] rec_DF_RAM_din;
	
	assign rec_DF_RAM_wr = !disable_DF && (blk4x4_sum_counter[2] != 1'b1);
	assign rec_DF_RAM_wr_addr_blk4x4 = {5{rec_DF_RAM_wr}} & blk4x4_rec_counter_2_raster_order;
	assign rec_DF_RAM_wr_addr_offset = {2{rec_DF_RAM_wr}} & blk4x4_sum_counter[1:0];
	assign rec_DF_RAM_wr_addr = {rec_DF_RAM_wr_addr_blk4x4,2'b0} + rec_DF_RAM_wr_addr_offset;
	assign rec_DF_RAM_din = (rec_DF_RAM_wr)? {blk4x4_sum_PE3_out,blk4x4_sum_PE2_out,blk4x4_sum_PE1_out,blk4x4_sum_PE0_out}:0;
	//-----------------------------------------------------------------
	//Read:during deblocking filter
	//-----------------------------------------------------------------	
	wire rec_DF_RAM_rd;
	reg [4:0] rec_DF_RAM_rd_addr_blk4x4;
	wire [1:0] rec_DF_RAM_rd_addr_offset;
	wire [6:0] rec_DF_RAM_rd_addr;
	
	assign rec_DF_RAM_rd = ((DF_edge_counter_MR[5] == 1'b0 && (DF_edge_counter_MR[3:0] == 4'd0 ||
	DF_edge_counter_MR[3:0] == 4'd1     ||  DF_edge_counter_MR[3:0] == 4'd2 || DF_edge_counter_MR[3:0] == 4'd3 ||
	DF_edge_counter_MR[3:0] == 4'd6     ||  DF_edge_counter_MR[3:0] == 4'd7 || DF_edge_counter_MR[3:0] == 4'd10||
	DF_edge_counter_MR[3:0] == 4'd11))  || (DF_edge_counter_MR[5] == 1'b1   && DF_edge_counter_MR[2] == 1'b0));
	
	always @ (rec_DF_RAM_rd or DF_edge_counter_MR)
		if (rec_DF_RAM_rd)
			case (DF_edge_counter_MR)
				6'd0 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd0;
				6'd1 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd1;
				6'd2 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd4;
				6'd3 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd5;
				6'd6 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd2;
				6'd7 :rec_DF_RAM_rd_addr_blk4x4 <= 5'd6;
				6'd10:rec_DF_RAM_rd_addr_blk4x4 <= 5'd3; 
				6'd11:rec_DF_RAM_rd_addr_blk4x4 <= 5'd7; 
				6'd16:rec_DF_RAM_rd_addr_blk4x4 <= 5'd8;
				6'd17:rec_DF_RAM_rd_addr_blk4x4 <= 5'd9;
				6'd18:rec_DF_RAM_rd_addr_blk4x4 <= 5'd12;
				6'd19:rec_DF_RAM_rd_addr_blk4x4 <= 5'd13;
				6'd22:rec_DF_RAM_rd_addr_blk4x4 <= 5'd10;
				6'd23:rec_DF_RAM_rd_addr_blk4x4 <= 5'd14;
				6'd26:rec_DF_RAM_rd_addr_blk4x4 <= 5'd11;
				6'd27:rec_DF_RAM_rd_addr_blk4x4 <= 5'd15;
				6'd32:rec_DF_RAM_rd_addr_blk4x4 <= 5'd16;
				6'd33:rec_DF_RAM_rd_addr_blk4x4 <= 5'd17;
				6'd34:rec_DF_RAM_rd_addr_blk4x4 <= 5'd18;
				6'd35:rec_DF_RAM_rd_addr_blk4x4 <= 5'd19;
				6'd40:rec_DF_RAM_rd_addr_blk4x4 <= 5'd20;
				6'd41:rec_DF_RAM_rd_addr_blk4x4 <= 5'd21;
				6'd42:rec_DF_RAM_rd_addr_blk4x4 <= 5'd22;
				6'd43:rec_DF_RAM_rd_addr_blk4x4 <= 5'd23;
				default:rec_DF_RAM_rd_addr_blk4x4 <= 0;
			endcase
		else 
			rec_DF_RAM_rd_addr_blk4x4 <= 0;
			
	assign rec_DF_RAM_rd_addr_offset = one_edge_counter_MR;
	assign rec_DF_RAM_rd_addr = {rec_DF_RAM_rd_addr_blk4x4,2'b0} + rec_DF_RAM_rd_addr_offset;
	
	//----------------------------------------------------------------------------------
	//Generate control signals for rec_DF_RAM0 & rec_DF_RAM1 
	//---------------------------------------------------------------------------------- 			
	reg rec_DF_RAM_sel;	//0:rec_DF_RAM0 at reconstruction stage			
						//0:rec_DF_RAM1 at DF stage
						//1:rec_DF_RAM0 at DF stage			
						//1:rec_DF_RAM1 at reconstruction stage
	always @ (posedge clk)
		if (reset_n == 1'b0)
			rec_DF_RAM_sel <= 1'b0;
		else if (end_of_MB_DEC)
			rec_DF_RAM_sel <= ~ rec_DF_RAM_sel;	
			
	assign rec_DF_RAM_dout = (rec_DF_RAM_sel == 1'b0)? rec_DF_RAM1_dout:rec_DF_RAM0_dout;
	
	always @ (rec_DF_RAM_sel
		or rec_DF_RAM_wr or rec_DF_RAM_wr_addr or rec_DF_RAM_din
		or rec_DF_RAM_rd or rec_DF_RAM_rd_addr)
		case (rec_DF_RAM_sel)
			1'b0:	//rec_DF_RAM0 at reconstruction stage,rec_DF_RAM1 at DF stage
			begin
				rec_DF_RAM0_wr <= rec_DF_RAM_wr;	
				rec_DF_RAM0_rd <= 1'b0;			  
				rec_DF_RAM0_addr <= rec_DF_RAM_wr_addr;		
				rec_DF_RAM0_din  <= rec_DF_RAM_din;	
				
				rec_DF_RAM1_wr <= 1'b0;	
				rec_DF_RAM1_rd <= rec_DF_RAM_rd;			  
				rec_DF_RAM1_addr <= rec_DF_RAM_rd_addr;		
				rec_DF_RAM1_din  <= 0;
			end
			1'b1:	//rec_DF_RAM0 at DF stage,rec_DF_RAM1 at reconstruction stage
			begin
				rec_DF_RAM0_wr <= 1'b0;	
				rec_DF_RAM0_rd <= rec_DF_RAM_rd;			  
				rec_DF_RAM0_addr <= rec_DF_RAM_rd_addr;		
				rec_DF_RAM0_din  <= 0;
				
				rec_DF_RAM1_wr <= rec_DF_RAM_wr;	
				rec_DF_RAM1_rd <= 1'b0;			  
				rec_DF_RAM1_addr <= rec_DF_RAM_wr_addr;		
				rec_DF_RAM1_din  <= rec_DF_RAM_din;	
			end
		endcase
endmodule


		
	
	
	
	
	
	
	
					