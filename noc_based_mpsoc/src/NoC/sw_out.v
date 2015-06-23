/**********************************************************************
	File: switch_out.v 
	
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
	The output switch. Just connects crossbar to the router output port.
	using wire or pipeline registers. note the  the credit counter and OVC 
	status are moved to OVC status module.
	
	Info: monemi@fkegraduate.utm.my
************************************************************************/

module sw_out#(
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter PYLD_WIDTH 				=	32,
	parameter FLIT_TYPE_WIDTH			=	2,
	parameter SW_OUTPUT_REGISTERED	=	0, // 1: registered , 0 not registered
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter VC_ID_WIDTH				=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH					=	PYLD_WIDTH+ FLIT_TYPE_WIDTH+VC_ID_WIDTH
	)
	(
	input in_wr_en,
	input [FLIT_WIDTH-1		:0]	flit_in,
	
	output reg out_wr_en,
	output reg [FLIT_WIDTH-1		:0]	flit_out,
	
	input clk,
	input reset
	);
	
	generate 
		if (SW_OUTPUT_REGISTERED) begin
			always @(posedge clk or posedge reset)begin
				if(reset)begin
					out_wr_en	<=1'b0;
					flit_out		<={FLIT_WIDTH{1'b0}};
				end else begin
					out_wr_en	<=	in_wr_en;
					flit_out		<=	flit_in;
				
				end
			end//always
		end else begin 
		
			always @(*)begin
				out_wr_en	=	in_wr_en;
				flit_out		=	flit_in;
			end//always
		
		end
	endgenerate
	endmodule
	
	