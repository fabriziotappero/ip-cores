/**********************************************************************
	File: route_compute.v 
	
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

	The conventional and look ahead NoC routing computation modules 
	based on mesh and torus topology. support 3 algorithm:
	
	XY_CLASSIC: The classic xy routing. The packet first forwarded to the
					x dimension until reach to the same destination column then
					forwarded to the y direction to reach the destination.
					
	BALANCE_DOR: The packet always move to the dimension with higher 
					differences value. 
					 
	ADAPTIVE_XY : its an adaptive version of classic xy.  First one dimension in x 
				 and another in y with less number of nodes is selected then the 
				 packet is forwarded to the dimension with less congestion.  
	
	
	
	Info: monemi@fkegraduate.utm.my
	
	*********************************************************************/

`timescale 1ns/1ps
`include "../define.v"

module look_ahead_routing_sync #(
	parameter TOPOLOGY					=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT				=	"XY_CLASSIC",		//"XY_CLASSIC" or "BALANCE_DOR" or "ADAPTIVE_XY"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter SW_X_ADDR					=	2,
	parameter SW_Y_ADDR					=	1,
	parameter CONGESTION_WIDTH			=	8,
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM)
	
	)
	(
	input [X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input [Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out,// one extra bit will be removed by switch_in latter
	input [CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	input [PORT_NUM_BCD_WIDTH-1	:0]   in_port_num_i,
	input 										clk,
	input											reset

	);
	`LOG2
	
	reg [X_NODE_NUM_WIDTH-1			:0]	dest_x_node;
	reg [Y_NODE_NUM_WIDTH-1			:0]	dest_y_node;
	reg [PORT_NUM_BCD_WIDTH-1		:0]   in_port_num_registerted;
	
	
	// routing algorithm
	route_compute  #(
	  	.TOPOLOGY			(TOPOLOGY), 
		.ROUTE_ALGRMT		(ROUTE_ALGRMT),
		.PORT_NUM			(PORT_NUM),
		.X_NODE_NUM			(X_NODE_NUM),
		.Y_NODE_NUM			(Y_NODE_NUM),
		.SW_X_ADDR			(SW_X_ADDR),
		.SW_Y_ADDR			(SW_Y_ADDR)
	
	)
	routing
	(
		.congestion_cmp_i	(congestion_cmp_i),
		.dest_x_node_in	(dest_x_node), 
		.dest_y_node_in	(dest_y_node), 
		.in_port_num_i		(in_port_num_registerted),
		.port_num_out		(port_num_out)
	);
	
	
	

	always @(posedge clk or posedge reset)begin
		if(reset)begin
			dest_x_node	<= {X_NODE_NUM_WIDTH{1'b0}};
			dest_y_node	<= {Y_NODE_NUM_WIDTH{1'b0}};
			in_port_num_registerted	<=  {PORT_NUM_BCD_WIDTH{1'b0}};
		
		end else begin
			dest_x_node	<= dest_x_node_in;
			dest_y_node	<= dest_y_node_in;
			in_port_num_registerted <= in_port_num_i;
		
		end//else reset
	end//always
endmodule








/***************************************************
					normal routing 
	
***************************************************/
module conventional_routing #(
	parameter TOPOLOGY					=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT				=	"BALANCE_DOR",//"XY_CLASSIC" or "BALANCE_DOR" or "ADAPTIVE_XY"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	4,
	parameter SW_X_ADDR					=	2,
	parameter SW_Y_ADDR					=	1,
	parameter CONGESTION_WIDTH			=	4,
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM)
	
	)
	(
	input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by cross bar switch later
	);
	
	`LOG2

	generate 
		if(ROUTE_ALGRMT	==	"XY_CLASSIC") begin : xy_routing_blk
			xy_routing #(
				.TOPOLOGY	(TOPOLOGY),	
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)
			) xy
			(
			.current_router_x_addr			(current_router_x_addr),
			.current_router_y_addr			(current_router_y_addr),
			.dest_x_node_in					(dest_x_node_in),
			.dest_y_node_in					(dest_y_node_in),
			.port_num_out						(port_num_out)// one extra bit will be removed by switch_in latter
			);
		end else if(ROUTE_ALGRMT	==	"BALANCE_DOR") begin : minimal_routing_blk
			bdor_routing #(
				.TOPOLOGY	(TOPOLOGY),
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)
			) bdor
			(
			.current_router_x_addr			(current_router_x_addr),
			.current_router_y_addr			(current_router_y_addr),
			.dest_x_node_in					(dest_x_node_in),
			.dest_y_node_in					(dest_y_node_in),
			.port_num_out						(port_num_out)// one extra bit will be removed by switch_in latter
			);
		
		end else if (ROUTE_ALGRMT	==	"ADAPTIVE_XY") begin : sudo_routing_blk
			ADAPTIVE_XY_routing #(
				.TOPOLOGY	(TOPOLOGY),
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)
			) ADAPTIVE_XY
			(
			.congestion_cmp_i					(congestion_cmp_i),
			.current_router_x_addr			(current_router_x_addr),
			.current_router_y_addr			(current_router_y_addr),
			.dest_x_node_in					(dest_x_node_in),
			.dest_y_node_in					(dest_y_node_in),
			.port_num_out						(port_num_out)// one extra bit will be removed by switch_in latter
			);
		end
	endgenerate

endmodule




/******************************************************

					route_compute

******************************************************/



module route_compute #(
	parameter TOPOLOGY					=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT				=	"BALANCE_DOR",//"XY_CLASSIC" or "BALANCE_DOR" or "ADAPTIVE_XY"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	4,
	parameter SW_X_ADDR					=	2,
	parameter SW_Y_ADDR					=	1,
	parameter CONGESTION_WIDTH			=	8,
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM)
	
	)
	(
	input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	input 	[PORT_NUM_BCD_WIDTH-1	:0]   in_port_num_i,// if local thr routing  is normal otherwise its look ahead
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by cross bar switch later
	);

	`LOG2
	
	reg 	[X_NODE_NUM_WIDTH-1		:0] next_router_x_addr;
	reg 	[Y_NODE_NUM_WIDTH-1		:0] next_router_y_addr;
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4; 
	
	localparam DST_CONGESTION_WIDTH	=	4;
	
	reg [DST_CONGESTION_WIDTH-1		:	0]	dst_congestion;
	
	// just to get rid of Warning (10230): Verilog HDL assignment warning at look_ahead.v(71): truncated value with size 32 to match size of target (2)
	localparam [X_NODE_NUM_WIDTH-1	:	0] CURRENT_X_ADDR =SW_X_ADDR [X_NODE_NUM_WIDTH-1	:	0];
	localparam [Y_NODE_NUM_WIDTH-1	:	0] CURRENT_Y_ADDR =SW_Y_ADDR [Y_NODE_NUM_WIDTH-1	:	0];
	localparam [X_NODE_NUM_WIDTH-1	:	0] LAST_X_ADDR 	=X_NODE_NUM[X_NODE_NUM_WIDTH-1	:	0]-1'b1;
	localparam [Y_NODE_NUM_WIDTH-1	:	0] LAST_Y_ADDR 	=Y_NODE_NUM[Y_NODE_NUM_WIDTH-1	:	0]-1'b1;
		
		
	localparam  W_VS_S	=	3;
	localparam  W_VS_N	=	2;
	localparam  E_VS_N	=	1;
	localparam  E_VS_S	=	0;
	
	
	
	localparam EAST_PORT_E_VS_S 	=	0;
	localparam EAST_PORT_E_VS_N 	=	1;
	localparam NORTH_PORT_E_VS_N 	=	2;
	localparam NORTH_PORT_W_VS_N 	=	3;
	localparam WEST_PORT_W_VS_S 	=	4;
	localparam WEST_PORT_W_VS_N 	=	5;
	localparam SOUTH_PORT_E_VS_S 	=	6;
	localparam SOUTH_PORT_W_VS_S 	=	7;
	
	
	
	
											
	//get next router address 
		always @(*) begin
			case(in_port_num_i) 
				LOCAL :begin 
					next_router_x_addr= CURRENT_X_ADDR;
					next_router_y_addr= CURRENT_Y_ADDR;
					dst_congestion		= {congestion_cmp_i[WEST_PORT_W_VS_S],congestion_cmp_i[WEST_PORT_W_VS_N ],congestion_cmp_i[EAST_PORT_E_VS_N ],congestion_cmp_i[EAST_PORT_E_VS_S]};
				end
					
				EAST:	begin	
					next_router_x_addr= (SW_X_ADDR==LAST_X_ADDR ) ? {X_NODE_NUM_WIDTH{1'b0}} : CURRENT_X_ADDR+1'b1;
					next_router_y_addr=  CURRENT_Y_ADDR;	
					dst_congestion		= {2'b00,congestion_cmp_i[EAST_PORT_E_VS_N],congestion_cmp_i[EAST_PORT_E_VS_S]};
					
				end
				NORTH:	begin	
					next_router_x_addr= CURRENT_X_ADDR;
					next_router_y_addr= (SW_Y_ADDR==0)? LAST_Y_ADDR  : CURRENT_Y_ADDR-1'b1;
					dst_congestion		= {1'b0,congestion_cmp_i[NORTH_PORT_W_VS_N],congestion_cmp_i[NORTH_PORT_E_VS_N],1'b0};
					
				end
				WEST:		begin 
					next_router_x_addr= (SW_X_ADDR==0) ? LAST_X_ADDR  : CURRENT_X_ADDR-1'b1;
					next_router_y_addr=  CURRENT_Y_ADDR;
					dst_congestion		= {congestion_cmp_i[WEST_PORT_W_VS_S],congestion_cmp_i[WEST_PORT_W_VS_N],2'b00};
				end
				SOUTH:	begin
					next_router_x_addr= CURRENT_X_ADDR;
					next_router_y_addr= (SW_Y_ADDR== LAST_Y_ADDR ) ? {Y_NODE_NUM_WIDTH{1'b0}}: CURRENT_Y_ADDR+1'b1;
					dst_congestion		= {congestion_cmp_i[SOUTH_PORT_W_VS_S],2'b00,congestion_cmp_i[SOUTH_PORT_E_VS_S]};
							
				end
				default begin 
					next_router_x_addr= {X_NODE_NUM_WIDTH{1'bX}};
					next_router_y_addr= {Y_NODE_NUM_WIDTH{1'bX}};
					dst_congestion		= {congestion_cmp_i[WEST_PORT_W_VS_S],congestion_cmp_i[WEST_PORT_W_VS_N ],congestion_cmp_i[EAST_PORT_E_VS_N ],congestion_cmp_i[EAST_PORT_E_VS_S]};
				end
			endcase
		end//always
		
		
	conventional_routing #(
		.TOPOLOGY		(TOPOLOGY),	
		.ROUTE_ALGRMT	(ROUTE_ALGRMT),
		.PORT_NUM		(PORT_NUM),
		.X_NODE_NUM		(X_NODE_NUM),
		.Y_NODE_NUM		(Y_NODE_NUM)	
	)conventional_routing
	(
		.congestion_cmp_i			(dst_congestion),
		.current_router_x_addr	(next_router_x_addr),
		.current_router_y_addr	(next_router_y_addr),
		.dest_x_node_in			(dest_x_node_in),
		.dest_y_node_in			(dest_y_node_in),
		.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
	);
		
		
endmodule


/*****************************************************

				xy_mesh_routing

*****************************************************/


module xy_mesh_routing #(
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	
	reg [PORT_NUM_BCD_WIDTH-1			:0]	port_num_next;
	
	
	wire signed [X_NODE_NUM_WIDTH		:0] xc;//current 
	wire signed [X_NODE_NUM_WIDTH		:0] xd;//destination
	wire signed [Y_NODE_NUM_WIDTH		:0] yc;//current 
	wire signed [Y_NODE_NUM_WIDTH		:0] yd;//destination
	wire signed [X_NODE_NUM_WIDTH		:0] xdiff;
	wire signed [Y_NODE_NUM_WIDTH		:0] ydiff; 
	
	
	assign 	xc 	={1'b0, current_router_x_addr [X_NODE_NUM_WIDTH-1		:0]};
	assign 	yc 	={1'b0, current_router_y_addr [Y_NODE_NUM_WIDTH-1		:0]};
	assign	xd		={1'b0, dest_x_node_in};
	assign	yd 	={1'b0, dest_y_node_in};
	assign 	xdiff	= xd-xc;
	assign	ydiff	= yd-yc;
	
		
	assign	port_num_out= port_num_next;
	
	always@(*)begin
			port_num_next	= LOCAL;
			if				(xdiff	> 0)		port_num_next	= EAST;
			else if		(xdiff	< 0)		port_num_next	= WEST;
			else begin
				if			(ydiff	> 0)		port_num_next	= SOUTH;
				else if 	(ydiff	< 0)		port_num_next	= NORTH;
			end
	end
	

endmodule


/*************************************************

				xy _torus_routing 

************************************************/


module xy_torus_routing #(
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	
	reg  [PORT_NUM_BCD_WIDTH-1				:0]	port_num_next;
	wire [X_NODE_NUM_WIDTH-1				:0]	x_addr_low,x_addr_high,x_addr_diff_f,x_addr_diff_b;
	wire													x_des_bigger;
	
	wire [Y_NODE_NUM_WIDTH-1				:0]	y_addr_low,y_addr_high,y_addr_diff_f,y_addr_diff_b;
	wire 													y_des_bigger;
	
	assign x_des_bigger 	=(dest_x_node_in > current_router_x_addr);
	assign x_addr_low	  	=(x_des_bigger)?	current_router_x_addr	: 	dest_x_node_in;
	assign x_addr_high  	=(x_des_bigger)?	dest_x_node_in 			:	current_router_x_addr;
	assign x_addr_diff_f	= x_addr_high - x_addr_low; 
	assign x_addr_diff_b = x_addr_low + X_NODE_NUM[X_NODE_NUM_WIDTH-1				:0] -  x_addr_high;
	
	assign y_des_bigger 	=(dest_y_node_in > current_router_y_addr);
	assign y_addr_low	  	=(y_des_bigger)?	current_router_y_addr	: 	dest_y_node_in ;
	assign y_addr_high  	=(y_des_bigger)?	dest_y_node_in 			: 	current_router_y_addr;
	assign y_addr_diff_f	= y_addr_high - y_addr_low; 
	assign y_addr_diff_b = y_addr_low + Y_NODE_NUM[Y_NODE_NUM_WIDTH-1				:0] -  y_addr_high;
	
		
	assign	port_num_out= port_num_next;
	
	always@(*)begin
			port_num_next	= LOCAL;
			if			(x_addr_diff_f > 0 ) begin 
				if		(x_addr_diff_f	<= x_addr_diff_b )			 port_num_next	= (x_des_bigger)? EAST: WEST;
				else 	port_num_next	= (x_des_bigger)? WEST: EAST;
			end
			else if	(y_addr_diff_f > 0 ) begin 
				if		(y_addr_diff_f	<= y_addr_diff_b )			 port_num_next	= (y_des_bigger)? SOUTH: NORTH;
				else 	port_num_next	= (y_des_bigger)? NORTH: SOUTH;
			end
	end
		
endmodule
	
	
	
/*************************************************

				xy _routing 

************************************************/


module xy_routing #(
	parameter TOPOLOGY					=	"MESH",//"TORUS"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	`LOG2
	generate 
		if(TOPOLOGY == "MESH") begin : mesh
			xy_mesh_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)xy_mesh
			(
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
	
		end else if(TOPOLOGY == "TORUS") begin : torus
			xy_torus_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)xy_torus
			(
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
		
		
		end
	
	endgenerate
	endmodule
	
	
	
	
/*****************************************************

				bdor_mesh_routing
			balanced dimension-order routing

*****************************************************/


module bdor_mesh_routing #(
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	
	reg  [PORT_NUM_BCD_WIDTH-1				:0]	port_num_next;
	wire [X_NODE_NUM_WIDTH-1				:0]	x_addr_low,x_addr_high,x_addr_diff_f;
	wire													x_des_bigger;
	
	wire [Y_NODE_NUM_WIDTH-1				:0]	y_addr_low,y_addr_high,y_addr_diff_f;
	wire 													y_des_bigger;
	
	assign x_des_bigger 	=(dest_x_node_in > current_router_x_addr);
	assign x_addr_low	  	=(x_des_bigger)?	current_router_x_addr	: 	dest_x_node_in;
	assign x_addr_high  	=(x_des_bigger)?	dest_x_node_in 			:	current_router_x_addr;
	assign x_addr_diff_f	= x_addr_high - x_addr_low; 
	
	
	assign y_des_bigger 	=(dest_y_node_in > current_router_y_addr);
	assign y_addr_low	  	=(y_des_bigger)?	current_router_y_addr	: 	dest_y_node_in ;
	assign y_addr_high  	=(y_des_bigger)?	dest_y_node_in 			: 	current_router_y_addr;
	assign y_addr_diff_f	= y_addr_high - y_addr_low; 
	
	
		
	assign	port_num_out= port_num_next;
	
	always@(*)begin
			port_num_next	= LOCAL;
			if			(x_addr_diff_f==0 && y_addr_diff_f==0 )	 port_num_next	= LOCAL;
			else  if	(x_addr_diff_f	>y_addr_diff_f )  			 port_num_next	= (x_des_bigger)? EAST: WEST;
			else 	if (x_addr_diff_f	<= y_addr_diff_f )	  		 port_num_next	= (y_des_bigger)? SOUTH: NORTH;
	end
		
endmodule


/*************************************************

				bdor _torus_routing 
			balanced dimension-order routing
************************************************/


module bdor_torus_routing #(
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	
	reg  [PORT_NUM_BCD_WIDTH-1				:0]	port_num_next;
	wire [X_NODE_NUM_WIDTH-1				:0]	x_addr_low,x_addr_high,x_addr_diff_f,x_addr_diff_b,x_min_of_b_f;
	wire													x_des_bigger;
	
	wire [Y_NODE_NUM_WIDTH-1				:0]	y_addr_low,y_addr_high,y_addr_diff_f,y_addr_diff_b,y_min_of_b_f;
	wire 													y_des_bigger;
	
	assign x_des_bigger 	=(dest_x_node_in > current_router_x_addr);
	assign x_addr_low	  	=(x_des_bigger)?	current_router_x_addr	: 	dest_x_node_in;
	assign x_addr_high  	=(x_des_bigger)?	dest_x_node_in 			:	current_router_x_addr;
	assign x_addr_diff_f	= x_addr_high - x_addr_low; 
	assign x_addr_diff_b = x_addr_low + X_NODE_NUM[X_NODE_NUM_WIDTH-1				:0] -  x_addr_high;
	assign x_min_of_b_f	= (x_addr_diff_f >  x_addr_diff_b )? x_addr_diff_b : x_addr_diff_f;
	
	assign y_des_bigger 	=(dest_y_node_in > current_router_y_addr);
	assign y_addr_low	  	=(y_des_bigger)?	current_router_y_addr	: 	dest_y_node_in ;
	assign y_addr_high  	=(y_des_bigger)?	dest_y_node_in 			: 	current_router_y_addr;
	assign y_addr_diff_f	= y_addr_high - y_addr_low; 
	assign y_addr_diff_b = y_addr_low + Y_NODE_NUM[Y_NODE_NUM_WIDTH-1				:0] -  y_addr_high;
	assign y_min_of_b_f	= (y_addr_diff_f >  y_addr_diff_b )? y_addr_diff_b : y_addr_diff_f;
	
		
	assign	port_num_out= port_num_next;
	
	always@(*)begin
			port_num_next	= LOCAL;
			if( x_min_of_b_f ==0 && y_min_of_b_f==0) port_num_next	= LOCAL;
			else begin   
				if(x_min_of_b_f > y_min_of_b_f) begin
					if		(x_addr_diff_f	<= x_addr_diff_b )			 port_num_next	= (x_des_bigger)? EAST: WEST;
					else 	port_num_next	= (x_des_bigger)? WEST: EAST;
				end else if(x_min_of_b_f <= y_min_of_b_f ) begin
					if		(y_addr_diff_f	<= y_addr_diff_b )			 port_num_next	= (y_des_bigger)? SOUTH: NORTH;
					else 	port_num_next	= (y_des_bigger)? NORTH: SOUTH;
				end
			end
	end//always
		
	endmodule
	

	
	
/*************************************************

							bdor_routing 
				balanced dimension-order routing

************************************************/


module bdor_routing #(
	parameter TOPOLOGY					=	"MESH",//"TORUS"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	`LOG2
	generate 
		if(TOPOLOGY == "MESH") begin 
			bdor_mesh_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)bdor_mesh
			(
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
	
		end else if(TOPOLOGY == "TORUS") begin
			bdor_torus_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)bdor
			(
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
		
		
		end
	
	endgenerate
	endmodule
	
	/********************************
	
				ADAPTIVE_XY 
	
	
	********************************/
	
	module ADAPTIVE_XY_routing #(
	parameter TOPOLOGY					=	"MESH",//"TORUS"
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter CONGESTION_WIDTH			=	4,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input		[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	`LOG2
	generate
	if(TOPOLOGY == "MESH") begin 
			ADAPTIVE_XY_mesh_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)ADAPTIVE_XY_mesh
			(
				.congestion_cmp_i			(congestion_cmp_i),
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
	
		end else if(TOPOLOGY == "TORUS") begin
			ADAPTIVE_XY_torus_routing #(
				.PORT_NUM	(PORT_NUM),
				.X_NODE_NUM	(X_NODE_NUM),
				.Y_NODE_NUM	(Y_NODE_NUM)	
			)ADAPTIVE_XY_mesh
			(
				.congestion_cmp_i			(congestion_cmp_i),
				.current_router_x_addr	(current_router_x_addr),
				.current_router_y_addr	(current_router_y_addr),
				.dest_x_node_in			(dest_x_node_in),
				.dest_y_node_in			(dest_y_node_in),
				.port_num_out				(port_num_out)// one extra bit will be removed by switch_in latter
			);
		end
	
	endgenerate
	
	endmodule 
	
	/********************************
	
				ADAPTIVE_XY_mesh_routing
	
	
	********************************/
	
	
	module ADAPTIVE_XY_mesh_routing #(
		parameter TOPOLOGY					=	"TORUS", // "MESH" or "TORUS"  
		parameter PORT_NUM					=	5,
		parameter X_NODE_NUM					=	4,
		parameter Y_NODE_NUM					=	4,
		parameter SW_X_ADDR					=	2,
		parameter SW_Y_ADDR					=	1,
		parameter CONGESTION_WIDTH			=	4,
		parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
		parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
		parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM)
	)
	(
		input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
		input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
		input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
		input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
		input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
		output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by cross bar switch later
	);

		
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	localparam  W_VS_S	=	3;
	localparam  W_VS_N	=	2;
	localparam  E_VS_N	=	1;
	localparam  E_VS_S	=	0;
	
	reg [PORT_NUM_BCD_WIDTH-1			:0]	port_num_next;
	
	
	wire signed [X_NODE_NUM_WIDTH		:0] xc;//current 
	wire signed [X_NODE_NUM_WIDTH		:0] xd;//destination
	wire signed [Y_NODE_NUM_WIDTH		:0] yc;//current 
	wire signed [Y_NODE_NUM_WIDTH		:0] yd;//destination
	wire signed [X_NODE_NUM_WIDTH		:0] xdiff;
	wire signed [Y_NODE_NUM_WIDTH		:0] ydiff; 
	
	
	assign 	xc 	={1'b0, current_router_x_addr [X_NODE_NUM_WIDTH-1		:0]};
	assign 	yc 	={1'b0, current_router_y_addr [Y_NODE_NUM_WIDTH-1		:0]};
	assign	xd		={1'b0, dest_x_node_in};
	assign	yd 	={1'b0, dest_y_node_in};
	assign 	xdiff	= xd-xc;
	assign	ydiff	= yd-yc;
	
		
	assign	port_num_out= port_num_next;
	
	always@(*) begin
			port_num_next	= LOCAL;
			if	(xdiff > 0) begin 
				if(ydiff > 0) begin // E_S
					if( congestion_cmp_i[E_VS_S])	port_num_next	= EAST; 
					else 									port_num_next	= SOUTH;
				end
				else if(ydiff < 0) begin  // E_N
					if( congestion_cmp_i[E_VS_N])	port_num_next	= EAST; 
					else 									port_num_next	= NORTH;
				end
				else port_num_next	= EAST; //ydiff ==0
			end 
			
			
			else if (xdiff < 0) begin 
				if( ydiff > 0) begin // W_S
					if( congestion_cmp_i	[W_VS_S])	port_num_next	= WEST; 
					else 										port_num_next	= SOUTH;
				end
				else if(ydiff < 0) begin // W_N
					if( congestion_cmp_i[W_VS_N])		port_num_next	= WEST; 
					else 										port_num_next	= NORTH;
				end
				else port_num_next	= WEST; //ydiff ==0
			end
			
			else begin //xdiff==0
				if 	 (ydiff <0)	port_num_next	= SOUTH;
				else if(ydiff >0)	port_num_next	= NORTH;
				else 					port_num_next	= LOCAL;
			end
		end
	
	endmodule

	/**********************************
	
		ADAPTIVE_XY_torus_routing
	
	***********************************/
	
	
module ADAPTIVE_XY_torus_routing #(
	parameter PORT_NUM					=	5,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter CONGESTION_WIDTH			=	4,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1//assum that no port whants to send a packet to itself!
	
	)
	(
	input		[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	input 	[X_NODE_NUM_WIDTH-1		:0]	current_router_x_addr,
	input		[Y_NODE_NUM_WIDTH-1		:0]	current_router_y_addr,
	input 	[X_NODE_NUM_WIDTH-1		:0]	dest_x_node_in,
	input		[Y_NODE_NUM_WIDTH-1		:0]	dest_y_node_in,
	output	[PORT_NUM_BCD_WIDTH-1	:0]	port_num_out// one extra bit will be removed by switch_in latter
	);
	
	`LOG2
	
	
	localparam LOCAL	=		3'd0;  
	localparam EAST	=		3'd1; 
	localparam NORTH	=		3'd2;  
	localparam WEST	=		3'd3;  
	localparam SOUTH	=		3'd4;  
	
	localparam  W_VS_S	=	3;
	localparam  W_VS_N	=	2;
	localparam  E_VS_N	=	1;
	localparam  E_VS_S	=	0;
	
	reg  [PORT_NUM_BCD_WIDTH-1				:0]	port_num_next,E_W_sel,N_S_sel;
	wire [X_NODE_NUM_WIDTH-1				:0]	x_addr_low,x_addr_high,x_addr_diff_f,x_addr_diff_b;
	wire													x_des_bigger;
	
	wire [Y_NODE_NUM_WIDTH-1				:0]	y_addr_low,y_addr_high,y_addr_diff_f,y_addr_diff_b;
	wire 													y_des_bigger;
	
	assign x_des_bigger 	=(dest_x_node_in > current_router_x_addr);
	assign x_addr_low	  	=(x_des_bigger)?	current_router_x_addr	: 	dest_x_node_in;
	assign x_addr_high  	=(x_des_bigger)?	dest_x_node_in 			:	current_router_x_addr;
	assign x_addr_diff_f	= x_addr_high - x_addr_low; 
	assign x_addr_diff_b = x_addr_low + X_NODE_NUM[X_NODE_NUM_WIDTH-1				:0] -  x_addr_high;
	
	assign y_des_bigger 	=(dest_y_node_in > current_router_y_addr);
	assign y_addr_low	  	=(y_des_bigger)?	current_router_y_addr	: 	dest_y_node_in ;
	assign y_addr_high  	=(y_des_bigger)?	dest_y_node_in 			: 	current_router_y_addr;
	assign y_addr_diff_f	= y_addr_high - y_addr_low; 
	assign y_addr_diff_b = y_addr_low + Y_NODE_NUM[Y_NODE_NUM_WIDTH-1				:0] -  y_addr_high;
	
		
	assign	port_num_out= port_num_next;
	
	
	always@(*)begin
			E_W_sel	= LOCAL;
			N_S_sel	= LOCAL;
			
			if			(x_addr_diff_f > 0 ) begin 
				if		(x_addr_diff_f	<= x_addr_diff_b )			 E_W_sel	= (x_des_bigger)? EAST: WEST;
				else 	E_W_sel	= (x_des_bigger)? WEST: EAST;
			end
			if	(y_addr_diff_f > 0 ) begin 
				if		(y_addr_diff_f	<= y_addr_diff_b )			 N_S_sel	= (y_des_bigger)? SOUTH: NORTH;
				else 	N_S_sel	= (y_des_bigger)? NORTH: SOUTH;
			end
	end
		
	always@(*)begin
		port_num_next = LOCAL;
		if     (E_W_sel == EAST && N_S_sel == SOUTH) port_num_next	=(congestion_cmp_i[E_VS_S])? EAST :  SOUTH;
		else if(E_W_sel == EAST && N_S_sel == NORTH) port_num_next	=(congestion_cmp_i[E_VS_N])? EAST :  NORTH;
		else if(E_W_sel == WEST && N_S_sel == SOUTH) port_num_next	=(congestion_cmp_i[W_VS_S])? WEST :  SOUTH;
		else if(E_W_sel == WEST && N_S_sel == NORTH) port_num_next	=(congestion_cmp_i[W_VS_N])? WEST :  NORTH;
		else if(E_W_sel == LOCAL) port_num_next = N_S_sel;
		else if(N_S_sel == LOCAL) port_num_next = E_W_sel;
	end
		
		
endmodule
	
	
	
	
	
