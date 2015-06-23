/*************************************************************************
	File : fifo_buffer.v	
	
	Copyright (C) 2013  Alireza Monemi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	
	Purpose:
	merge all input ports VC buffers in one dual port memory ram
	
	Info: monemi@fkegraduate.utm.my
*************************************************************************/
`timescale 1ns / 1ps

`include "../define.v"

module fifo_buffer #(
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter PYLD_WIDTH 				=	32,
	parameter BUFFER_NUM_PER_VC		=	4,
	parameter FLIT_TYPE_WIDTH			=	2,
	parameter ENABLE_MIN_DEPTH_OUT	=	0, // if 1 then the VC with minimum depth is merged with vc_nearly_full as output
	
	parameter VC_ID_WIDTH				=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH					=	PYLD_WIDTH+ FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter VC_FULL_WIDTH				=  (ENABLE_MIN_DEPTH_OUT) ? VC_NUM_PER_PORT*2 : VC_NUM_PER_PORT		
	)	
	(
	input 		[FLIT_WIDTH-1				:0] 	din,     // Data in
	input			[VC_NUM_PER_PORT-1		:0]	vc_num_wr,//write vertual channel 	
	input			[VC_NUM_PER_PORT-1		:0]	vc_num_rd,//read vertual channel 	
	input       			   						wr_en,   // Write enable
	input       	   								rd_en,   // Read the next word
	output		[FLIT_WIDTH-1				:0]	dout,    // Data out
	output 		[VC_FULL_WIDTH	-1			:0]	vc_nearly_full,
	output		[VC_NUM_PER_PORT-1		:0]	vc_not_empty,
	
		
	input          									reset,
	input          									clk
	);

	`LOG2
	localparam	BUFFER_NUM 			=	BUFFER_NUM_PER_VC	*	VC_NUM_PER_PORT;
	localparam  BUFFER_WIDTH		=	log2(BUFFER_NUM);
	localparam	PTR_WIDTH			=	log2(BUFFER_NUM_PER_VC);
	localparam  DEPTH_WIDTH			=	PTR_WIDTH+1;
	localparam	PTR_ARRAY_WIDTH	=	PTR_WIDTH *	VC_NUM_PER_PORT;
	localparam	VC_SELECT_WIDTH	=	BUFFER_WIDTH-PTR_WIDTH;
	
	
//	reg [FLIT_WIDTH-1			:	0] queue [BUFFER_NUM-1				:0];
	
	reg [PTR_WIDTH- 1 		: 	0] rd_ptr [VC_NUM_PER_PORT-1			:0];
	reg [PTR_WIDTH- 1 		: 	0] wr_ptr [VC_NUM_PER_PORT-1			:0];
	reg [DEPTH_WIDTH-1		: 	0] depth	[VC_NUM_PER_PORT-1			:0];
	
	wire[PTR_WIDTH				: 	0] wr		[VC_NUM_PER_PORT-1			:0];
	wire[PTR_WIDTH				:	0] rd		[VC_NUM_PER_PORT-1			:0];
	
	wire [PTR_ARRAY_WIDTH-1	:	0]	rd_ptr_array;
	wire [PTR_ARRAY_WIDTH-1	:	0]	wr_ptr_array;
	wire [PTR_WIDTH-1			:	0]	vc_wr_addr;
	wire [PTR_WIDTH-1			:	0]	vc_rd_addr;	
	wire [VC_SELECT_WIDTH-1	:	0]	wr_select_addr;
	wire [VC_SELECT_WIDTH-1	:	0]	rd_select_addr;	
	wire [BUFFER_WIDTH- 1	: 	0] wr_addr;
	wire [BUFFER_WIDTH- 1	: 	0] rd_addr;
	
	genvar i;
	
	generate
	for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :loop0
		assign	wr[i]	=	(wr_en & vc_num_wr[i] );
		assign	rd[i]	=	(rd_en & vc_num_rd[i] );
		assign 	wr_ptr_array[(i+1)*PTR_WIDTH- 1 		: 	i*PTR_WIDTH]	=		wr_ptr[i];
		assign 	rd_ptr_array[(i+1)*PTR_WIDTH- 1 		: 	i*PTR_WIDTH]	=		rd_ptr[i];
		assign 	vc_nearly_full[i] = (depth[i] >= BUFFER_NUM_PER_VC-1);
		assign 	vc_not_empty	[i] =	(depth[i] >	0);
	
	end
	endgenerate
	
	
	assign wr_addr	=	{wr_select_addr,vc_wr_addr};
	assign rd_addr	=	{rd_select_addr,vc_rd_addr};
	
	
	
	one_hot_mux #(
		.IN_WIDTH		(PTR_ARRAY_WIDTH),
		.SEL_WIDTH 		(VC_NUM_PER_PORT) 
	)
	wr_ptr_mux
	(
		.mux_in			(wr_ptr_array),
		.mux_out			(vc_wr_addr),
		.sel				(vc_num_wr)
	);
	
	
	
	
	one_hot_mux #(
		.IN_WIDTH		(PTR_ARRAY_WIDTH),
		.SEL_WIDTH 		(VC_NUM_PER_PORT) 
	)
	rd_ptr_mux
	(
		.mux_in			(rd_ptr_array),
		.mux_out			(vc_rd_addr),
		.sel				(vc_num_rd)
	);
	
	
	
	/*
	dual_port_ram 	#(
		.DATA_WIDTH	(FLIT_WIDTH),
		.ADDR_WIDTH	(BUFFER_WIDTH )
	)
	queue
	(
		.data_a		(din), 
		.data_b		(),
		.addr_a		(wr_addr),
		.addr_b		(rd_addr),
		.we_a			(wr_en), 
		.we_b			(1'b0), 
		.clk			(clk),
		.q_a			(),
		.q_b			(q_b)
	);	
	*/
	
	localparam RAM_WIDTH  = FLIT_WIDTH - VC_NUM_PER_PORT;
	wire 	[RAM_WIDTH-1		:	0]		fifo_ram_din;
	wire  [RAM_WIDTH-1		:	0]		fifo_ram_dout;
	
	assign fifo_ram_din = {din[`FLIT_IN_TYPE_LOC],din[PYLD_WIDTH-1		:	0]};
	assign dout = {fifo_ram_dout[PYLD_WIDTH+1:PYLD_WIDTH],{VC_NUM_PER_PORT{1'bX}},fifo_ram_dout[PYLD_WIDTH-1		:	0]};
	
	
	fifo_ram 	#(
		.DATA_WIDTH	(RAM_WIDTH),
		.ADDR_WIDTH	(BUFFER_WIDTH )
	)
	queue
	(
		.wr_data		(fifo_ram_din), 
		.wr_addr		(wr_addr),
		.rd_addr		(rd_addr),
		.wr_en		(wr_en),
		.rd_en		(rd_en),
		.clk			(clk),
		.rd_data		(fifo_ram_dout)
	);	
	
	
	
	
	
	
	one_hot_to_bcd #(
	.ONE_HOT_WIDTH	(VC_NUM_PER_PORT)
	
	)
	wr_vc_start_addr
	(
	.one_hot_code	(vc_num_wr),
	.bcd_code		(wr_select_addr)

	);
	
	one_hot_to_bcd #(
	.ONE_HOT_WIDTH	(VC_NUM_PER_PORT)
	
	)
	rd_vc_start_addr
	(
	.one_hot_code	(vc_num_rd),
	.bcd_code		(rd_select_addr)

	);
	/*
	// Sample the data
	always @(posedge clk)
	begin
   if (wr_en)
      queue[wr_addr]<= din;
   if (rd_en)
      dout <=
	      // synthesis translate_off
	      #1
	      // synthesis translate_on
	      queue[rd_addr];
	end
*/


	generate
	for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :ptr_loop
		always @(posedge clk or posedge reset)
		begin
			if (reset) begin
				rd_ptr 	[i]	<= {PTR_WIDTH{1'b0}};
				wr_ptr	[i] 	<= {PTR_WIDTH{1'b0}};
				depth		[i]  	<= {DEPTH_WIDTH{1'b0}};
			end
			else begin
				if (wr[i] ) wr_ptr[i] <= wr_ptr [i]+ 1'h1;
				if (rd[i] ) rd_ptr [i]<= rd_ptr [i]+ 1'h1;
				if (wr[i] & ~rd[i]) depth [i]<=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth[i] + 1'h1;
				else if (~wr[i] & rd[i]) depth [i]<=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth[i] - 1'h1;
			end//else
		end//always
	end//for
	endgenerate

	

	// synthesis translate_off
	generate
	for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :loop3
	 always @(posedge clk)
	 begin
		if (wr[i] && depth[i] == BUFFER_NUM_PER_VC && !rd[i])
			$display($time, " ERROR: Attempt to write to full FIFO: %m");
		if (rd[i] && depth[i] == 'h0)
			$display($time, " ERROR: Attempt to read an empty FIFO: %m");
		
		
			
		//if (wr_en)       $display($time, " %h is written on fifo ",din);
	 end//always
	end//for
	endgenerate
	
	always @(posedge clk) begin
		if(wr_en && vc_num_wr == 'h0)
				$display($time, " ERROR: Attempt to write when no wr VC is asserted: %m");
		if(rd_en && vc_num_rd == 'h0)
				$display($time, " ERROR: Attempt to read when no rd VC is asserted: %m");
	end	
	
// synthesis translate_on

//Add min depth detection
generate 
if(ENABLE_MIN_DEPTH_OUT)begin
	wire [(VC_NUM_PER_PORT*DEPTH_WIDTH)-1	:	0]depth_array;
	for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :depth_loop
		assign depth_array[((i+1)*(DEPTH_WIDTH))-1		: i*DEPTH_WIDTH]=depth[i];
	end //for
	fast_minimum_number#(
		.NUM_OF_INPUTS		(VC_NUM_PER_PORT),
		.DATA_WIDTH			(DEPTH_WIDTH)
		
	)
	the_min_depth
	(
		.in_array			(depth_array),
		.min_out				(vc_nearly_full[VC_FULL_WIDTH-1	:	VC_NUM_PER_PORT])
	);
		
end
endgenerate

endmodule 



	


