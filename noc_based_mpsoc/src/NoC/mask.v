/**********************************************************************
	File: mask.v 
	
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
		masking the input port requests in following conditions:
			1-  the request is from the IVC which has been assigned to an
			OVC but there is no empty place on the assigned OVC  
			2- the request is from the IVC which has not yet been assigned
			any OVC and the destination port has no empty VC 
		
	Info: monemi@fkegraduate.utm.my

********************************************************************/


`include "../define.v"
module ivc_request_mask #(
	parameter PORT_NUM					=	5,
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter PORT_SEL_BCD_WIDTH		= log2(PORT_SEL_WIDTH)
	)
(
	input		[PORT_SEL_WIDTH-1				:0]	ovc_available,
	input		[PORT_SEL_BCD_WIDTH-1		:0]	port_sel_bcd,
	input													ovc_not_assigned,
	input													tail_flit,
	input													ivc_not_empty,
	//input													ivc_recieved_more_than_one_flit,
	input		[1									:0]	ovc_status,
	input													ivc_granted,
	output												ivc_request,
	input													clk,
	input													reset
);

	`LOG2

	wire [PORT_SEL_WIDTH-1		:	0]	port_sel_available;
	wire 										not_assigned_req_allowed;
	wire										assigned_reg_allowed;
	wire										not_assigned_request;
	wire										assigned_request;
	wire										not_assigned_request_exsist;
	wire 										assigned_request_exsist;
	wire 										request1;
	wire 										request2;
	wire 										request;
	reg 										full;
	reg 										nearlly_full;
	reg 										has_two_empty_place;
	reg 										sent_one_or_two_request;
	reg 										sent_two_requests;
	wire 										assigned_not_allowed1;
	wire 										assigned_not_allowed2;
	wire 										assigned_not_allowed3;
	reg										ivc_granted_reg;
	reg 	 									has_less_than_2;
	
	//assign port_sel_available				= 	port_sel & ovc_available;
	//assign not_assigned_req_allowed		=	| port_sel_available;
	assign not_assigned_req_allowed		=	ovc_available[port_sel_bcd];
	assign not_assigned_request_exsist	=	request									& ovc_not_assigned;
	assign not_assigned_request			=	not_assigned_request_exsist		& not_assigned_req_allowed;	
	assign assigned_request_exsist		=	request									& ~ovc_not_assigned;
	assign assigned_request					=	assigned_request_exsist				& assigned_reg_allowed;
	assign ivc_request						=	assigned_request						| not_assigned_request;
	assign request 							=	ivc_not_empty ;
	assign assigned_not_allowed1			=	full;
	assign assigned_not_allowed2			=	nearlly_full		& ivc_granted_reg;
	assign assigned_reg_allowed			=	~(assigned_not_allowed1 | assigned_not_allowed2 );
		
	always @(posedge clk or posedge reset)begin
		if(reset) begin
				full							<=	1'b0;
				nearlly_full				<=	1'b0;
				ivc_granted_reg			<=	1'b0;
		end else begin
				full							<=	ovc_status[1];
				nearlly_full				<=	ovc_status[0];
				ivc_granted_reg			<=	ivc_granted;
		end
	end//always
endmodule
