/**********************************************************************
	File:sw_sep_alloc.v 
	
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
	The switch first in rateable allocator
	
	Info: monemi@fkegraduate.utm.my

********************************************************/


`include "../define.v"
module sw_sep_alloc #(
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assumed that no port request for itself!
	parameter PORT_SEL_BCD_WIDTH		=	log2(PORT_SEL_WIDTH),
	parameter TOTAL_VC_NUM				=	VC_NUM_PER_PORT*PORT_NUM,
	parameter PORT_SEL_ARRAY_WIDTH	=	TOTAL_VC_NUM * PORT_SEL_BCD_WIDTH,
	parameter PORT_CAND_ARRAY_WIDTH	=	PORT_SEL_WIDTH*	PORT_NUM,
	parameter ALL_VC_NUM					=	VC_NUM_PER_PORT*	PORT_NUM
)

(
	input 		[PORT_SEL_ARRAY_WIDTH-1		: 0]  port_selects_array,
	input			[ALL_VC_NUM-1					: 0]	in_vc_requests_array,
	output		[ALL_VC_NUM-1					: 0]	candidate_in_vc_array,
	output		[PORT_CAND_ARRAY_WIDTH-1	: 0]	candidate_port_array,
	output		[ALL_VC_NUM-1					: 0]	in_vc_granted_array,
	output		[PORT_NUM-1						: 0]	any_vc_granted_array,
	output reg 	[PORT_CAND_ARRAY_WIDTH-1	: 0]	crossbar_granted_port_array,
	output	 	[PORT_CAND_ARRAY_WIDTH-1	: 0] 	isw_granted_port_array,
	output reg 	[PORT_NUM-1						: 0]	out_port_wr_en_array,
	input														clk,
	input														reset
	
);
`LOG2
localparam	FIRST_ARBITER_PORT_SEL_WIDTH		=	VC_NUM_PER_PORT	*	PORT_SEL_BCD_WIDTH;


wire	[PORT_NUM-1								:	0]	any_grants;
wire	[PORT_CAND_ARRAY_WIDTH-1			:	0]	candidate_port_wire;


 
assign candidate_port_array = candidate_port_wire; 
 
genvar i,j;
generate 
	
	
	for(i=0;i< PORT_NUM;i=i+1) begin :first_arbitter_loop
	//first arbiters
	
	
		sw_alloc_first_arbiter#(
			.VC_NUM_PER_PORT			(VC_NUM_PER_PORT),
			.PORT_NUM					(PORT_NUM)
			
		)
		the_sw_alloc_first_arbiter
		(
			.port_selects			(port_selects_array		[(i+1)*FIRST_ARBITER_PORT_SEL_WIDTH-1	:i*FIRST_ARBITER_PORT_SEL_WIDTH]),
			.in_vc_requests		(in_vc_requests_array	[(i+1)*VC_NUM_PER_PORT-1					:i*VC_NUM_PER_PORT	]),
			.port_granted			(isw_granted_port_array		[(i+1)*PORT_SEL_WIDTH-1						:i*PORT_SEL_WIDTH		]),
			.candidate_in_vc		(candidate_in_vc_array	[(i+1)*VC_NUM_PER_PORT-1					:i*VC_NUM_PER_PORT	]),
			.candidate_port		(candidate_port_wire		[(i+1)*PORT_SEL_WIDTH-1						:i*PORT_SEL_WIDTH		]),
			.in_vc_granted			(in_vc_granted_array		[(i+1)*VC_NUM_PER_PORT-1					:i*VC_NUM_PER_PORT	]),
			.any_vc_granted		(any_vc_granted_array	[i]),
			.clk						(clk),
			.reset					(reset)
		);
		
		
		
		
	end//for
endgenerate


//second arbiters	
sw_alloc_second_arbiter #(
	.VC_NUM_PER_PORT		(VC_NUM_PER_PORT),
	.PORT_NUM				(PORT_NUM)	
)
the_sw_alloc_second_arbiter
(

	.port_requests		(candidate_port_wire),
	.port_granted		(isw_granted_port_array),
	.any_grants			(any_grants),
	.clk					(clk),
	.reset				(reset)
	
);
	
	always @(posedge clk or posedge reset)begin
		if (reset) begin
			crossbar_granted_port_array	<= {PORT_CAND_ARRAY_WIDTH{1'b0}};
			out_port_wr_en_array				<=	{PORT_NUM{1'b0}};
		end else begin
			crossbar_granted_port_array	<= isw_granted_port_array;
			out_port_wr_en_array				<=	any_grants;

		end
	end//always
	
endmodule
