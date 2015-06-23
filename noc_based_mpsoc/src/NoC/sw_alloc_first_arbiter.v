/**********************************************************************
	File: sw_alloc_first_arbiter.v 
	
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
	The first arbitartion stage in switch allocator
	
	Info: monemi@fkegraduate.utm.my
	
********************************************************************/



`include "../define.v"
module sw_alloc_first_arbiter#(
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assumed that no port request for itself!
	parameter PORT_SEL_BCD_WIDTH		=	log2(PORT_SEL_WIDTH),
	parameter TOTAL_VC_NUM				=	VC_NUM_PER_PORT*PORT_NUM,
	parameter PORT_SEL_ARRAY_WIDTH	=	VC_NUM_PER_PORT * PORT_SEL_BCD_WIDTH,
	parameter PORT_CAND_ARRAY_WIDTH	=	PORT_SEL_WIDTH*	PORT_NUM,
	parameter ALL_VC_NUM					=	VC_NUM_PER_PORT*	PORT_NUM
		
	
)

(

	input [PORT_SEL_ARRAY_WIDTH-1	:		0] port_selects,
	input	[VC_NUM_PER_PORT-1		:		0]	in_vc_requests,
	input [PORT_SEL_WIDTH-1			:		0] port_granted,
	
	output[VC_NUM_PER_PORT-1		:		0]	candidate_in_vc,
	output[PORT_SEL_WIDTH-1			:		0]	candidate_port,
	output[VC_NUM_PER_PORT-1		:		0]	in_vc_granted,
	output											any_vc_granted,
	
	input												clk,
	input												reset
	
);
	`LOG2
	localparam 	PORT_SEL_HOT_ARRAY_WIDTH	=	VC_NUM_PER_PORT * PORT_SEL_WIDTH;
	
	
	wire  [PORT_SEL_HOT_ARRAY_WIDTH-1	:0]	port_sel_hot_array;
	
	genvar i;
	generate 
		for(i=0;i<VC_NUM_PER_PORT;i=i+1'b1) begin :bcd_to_hot_loop
			bcd_to_one_hot #(
				.BCD_WIDTH		(PORT_SEL_BCD_WIDTH),
				.ONE_HOT_WIDTH	(PORT_SEL_WIDTH)
			)
			the_bcd_to_one_hot
			(
				.bcd_code		(port_selects[(i+1)*PORT_SEL_BCD_WIDTH-1	:i*PORT_SEL_BCD_WIDTH]),
				.one_hot_code	(port_sel_hot_array[(i+1)*PORT_SEL_WIDTH-1	:i*PORT_SEL_WIDTH])
			);
		end  //for i
		
	endgenerate
	

	assign any_vc_granted	= | port_granted;
	assign in_vc_granted		=	candidate_in_vc &{VC_NUM_PER_PORT{any_vc_granted}};


	one_hot_arbiter #(
		.ARBITER_WIDTH(VC_NUM_PER_PORT)
		)
		the_sw_alloc_first_arbiter
		(
			.clk(clk), 
			.reset(reset), 
			.request(in_vc_requests), 
			.grant(candidate_in_vc),
			.any_grant()
		);
		
		
	one_hot_mux #(
		.IN_WIDTH(PORT_SEL_HOT_ARRAY_WIDTH),
		.SEL_WIDTH(VC_NUM_PER_PORT)
		

	)
	port_sel_mux
	(
		.mux_in(port_sel_hot_array),
		.mux_out(candidate_port),
		.sel(candidate_in_vc)

	);

endmodule
