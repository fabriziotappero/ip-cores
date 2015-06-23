//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : ext_frame_RAM1_wrapper.v
// Generated : Nov 28,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Controller for ext_frame_RAM
// Rread  as ref_frame_RAM before Inter Prediction
// Write as dis_frame_RAM after  Deblocking Filter
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module ext_RAM_ctrl (clk,reset_n,end_of_one_frame,ref_frame_RAM_rd,ref_frame_RAM_rd_addr,dis_frame_RAM_wr,
	dis_frame_RAM_wr_addr,ref_frame_RAM_dout,
	ext_frame_RAM0_cs_n,ext_frame_RAM0_wr,ext_frame_RAM0_addr,ext_frame_RAM0_data,
	ext_frame_RAM1_cs_n,ext_frame_RAM1_wr,ext_frame_RAM1_addr,ext_frame_RAM1_data);	
	input clk,reset_n;
	input end_of_one_frame;
	input ref_frame_RAM_rd;
	input [13:0] ref_frame_RAM_rd_addr;
	input dis_frame_RAM_wr;
	input [13:0] dis_frame_RAM_wr_addr;
	//input [31:0] dis_frame_RAM_din;
	input [31:0] ext_frame_RAM0_data;
	input [31:0] ext_frame_RAM1_data;
	
	output [31:0] ref_frame_RAM_dout;
	
	output ext_frame_RAM0_cs_n;
	output ext_frame_RAM0_wr;
	output [13:0] ext_frame_RAM0_addr;
	
	output ext_frame_RAM1_cs_n;
	output ext_frame_RAM1_wr;
	output [13:0] ext_frame_RAM1_addr;
	
	reg ext_frame_RAM_sel;	//0:ext_frame_RAM0 as dis_frame_RAM to be written			
                          //0:ext_frame_RAM1 as ref_frame_RAM to be read
                          //1:ext_frame_RAM0 as ref_frame_RAM to be read			
                          //1:ext_frame_RAM1 as dis_frame_RAM to be written
	always @ (posedge clk)
		if (reset_n == 1'b0)
			ext_frame_RAM_sel <= 1'b0;
		else if (end_of_one_frame)
			ext_frame_RAM_sel <= ~ ext_frame_RAM_sel;
	
	reg [31:0] ref_frame_RAM_dout;
	
	reg ext_frame_RAM0_cs_n;
	reg ext_frame_RAM0_wr;
	reg [13:0] ext_frame_RAM0_addr;
	
	reg ext_frame_RAM1_cs_n;
	reg ext_frame_RAM1_wr;
	reg [13:0] ext_frame_RAM1_addr;
	
	always @ (ext_frame_RAM_sel or 
		ref_frame_RAM_rd or ref_frame_RAM_rd_addr or ext_frame_RAM0_data or ext_frame_RAM1_data or
		dis_frame_RAM_wr or dis_frame_RAM_wr_addr)
		case (ext_frame_RAM_sel)
			1'b0:	
			begin
				//ext_frame_RAM0 as dis_frame_RAM to be written
				ext_frame_RAM0_cs_n <= !dis_frame_RAM_wr;	ext_frame_RAM0_wr <= dis_frame_RAM_wr;			  
				ext_frame_RAM0_addr <= dis_frame_RAM_wr_addr;		
				
				//ext_frame_RAM1 as ref_frame_RAM to be read
				ext_frame_RAM1_cs_n <= !ref_frame_RAM_rd;	ext_frame_RAM1_wr <= 1'b0;			  
				ext_frame_RAM1_addr <= ref_frame_RAM_rd_addr;		
				
				ref_frame_RAM_dout <= ext_frame_RAM1_data; 
			end
			1'b1:	
			begin
				//ext_frame_RAM0 as ref_frame_RAM to be read
				ext_frame_RAM0_cs_n <= !ref_frame_RAM_rd;	ext_frame_RAM0_wr <= 1'b0;			  
				ext_frame_RAM0_addr <= ref_frame_RAM_rd_addr;		
				
				//ext_frame_RAM1 as dis_frame_RAM to be written
				ext_frame_RAM1_cs_n <= !dis_frame_RAM_wr;		ext_frame_RAM1_wr <= dis_frame_RAM_wr;			  
				ext_frame_RAM1_addr <= dis_frame_RAM_wr_addr;		
				
				ref_frame_RAM_dout <= ext_frame_RAM0_data; 
			end
		endcase
	//assign ext_frame_RAM0_data = (!ext_frame_RAM_sel && dis_frame_RAM_wr)? dis_frame_RAM_din:32'bz;
	//assign ext_frame_RAM1_data = ( ext_frame_RAM_sel && dis_frame_RAM_wr)? dis_frame_RAM_din:32'bz;
endmodule
	
	