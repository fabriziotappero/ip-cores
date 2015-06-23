/**********************************************************************
	File: sw_alloc_second_arbiter.v 
	
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
	The second arbitartion stage in switch allocator
	
	Info: monemi@fkegraduate.utm.my
	
************************************************************************/

module sw_alloc_second_arbiter #(
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter ARBITER_WIDTH				=	PORT_NUM-1,//assumed that no port request for itself!
	parameter PORT_REQ_WIDTH			=	PORT_NUM* ARBITER_WIDTH	
)

(

	input [PORT_REQ_WIDTH-1			:		0] port_requests,
	output[PORT_REQ_WIDTH-1			:		0] port_granted,
	output[PORT_NUM-1					:		0]	any_grants,
	input												clk,
	input												reset
	
);

	wire	[ARBITER_WIDTH	-1					:		0]	request	[PORT_NUM-1					:		0]	;
	wire	[ARBITER_WIDTH	-1					:		0]	grant		[PORT_NUM-1					:		0]	;



	genvar i,j;
	generate 
	for(i=0;i<PORT_NUM;i=i+1)begin : arbiter_loop
	
		
		one_hot_arbiter #(
		.ARBITER_WIDTH(ARBITER_WIDTH)
		)
		round_robin_arbiter
		(
			.clk(clk), 
			.reset(reset), 
			.request(request[i]), 
			.grant(grant[i]),
			.any_grant(any_grants[i])
		);
		for(j=0;j<PORT_NUM;	j=j+1)begin: assignment_loop
			if(i<j)begin: jj
				assign request[i][j-1]	= port_requests[(j*ARBITER_WIDTH	)+i]	;
				assign port_granted[(j*ARBITER_WIDTH)+i]	= grant	[i][j-1]	;
			end else if(i>j)begin: hh
				assign request[i][j]	= port_requests[(j*ARBITER_WIDTH	)+i-1]	;
				assign port_granted[(j*ARBITER_WIDTH)+i-1]	= grant	[i][j]	;
			end
			//if(i==j) wires are left disconnected  
		
		end


	end//for
	endgenerate





endmodule
