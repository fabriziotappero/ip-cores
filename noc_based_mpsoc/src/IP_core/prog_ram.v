/*********************************************************************
							
	File: prog_ram.v 
	
	Copyright (C) 2014  Alireza Monemi

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
	program ram. The ram is assigned with a ram id and can be programed 
	using quartus in system memory contents  editor in order to program the chip

	Info: monemi@fkegraduate.utm.my

****************************************************************/


`timescale 1ns / 1ps
`include "../define.v"


module prog_ram #(
	parameter MODE			= "SINGLE_PORT",
	parameter DATA_WIDTH	=32, 
	parameter ADDR_WIDTH	=10,	
	parameter TAG_WIDTH	=3,
	parameter PORT_SEL	=4,
	parameter SW_X_ADDR	=2,
	parameter SW_Y_ADDR	=1,
	parameter CORE_NUMBER=0
	)
	(
	input 										clk,
	input											reset,
	
	input		[DATA_WIDTH-1		:	0]		sa_dat_i, sb_dat_i,
	input		[PORT_SEL-1			:	0]		sa_sel_i,sb_sel_i,
	input		[ADDR_WIDTH-1		:	0] 	sa_addr_i, sb_addr_i,
	input		[TAG_WIDTH-1		:	0]		sa_cti_i, sb_cti_i,
	input											sa_stb_i,sb_stb_i,
	input											sa_we_i,sb_we_i,

	output	[DATA_WIDTH-1		:	0]		sa_dat_o, sb_dat_o,
	output										sa_ack_o,sb_ack_o
	);

	
	
	
	wire	[(DATA_WIDTH-1)	:0] data_a, data_b;
	wire	[(ADDR_WIDTH-1)	:0] addr_a, addr_b;
	wire								 we_a, we_b;
	wire	[(DATA_WIDTH-1)	:0] q_a, q_b;
	reg 								 sa_ack_classic, sb_ack_classic,sa_ack_classic_next,sb_ack_classic_next;
	wire								 sa_ack_burst,sb_ack_burst;
	
	assign sa_dat_o		=	q_a;
	assign data_a			=	sa_dat_i ;
	assign addr_a			=	sa_addr_i;
	assign we_a				=	sa_stb_i &  sa_we_i;
	assign sa_ack_burst	=  sa_stb_i ; //the ack is registerd inside the master in burst mode 
	
	
	assign sa_ack_o = (sa_cti_i == 3'b000 ) ? sa_ack_classic : sa_ack_burst;

	
	
	
	always @(*) begin
		sa_ack_classic_next	=  (~sa_ack_o) & sa_stb_i;
	end
	
	always @(posedge clk ) begin
		if(reset) begin 
			sa_ack_classic	<= 1'b0;
		end else begin 
			sa_ack_classic	<= sa_ack_classic_next;
		end 	
	end
	localparam	 RAM_ID = {"ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=",i2s(SW_X_ADDR),i2s(SW_Y_ADDR)};

	
generate 
	if(MODE			== "SINGLE_PORT") begin :single_port
	assign sb_dat_o	=	{DATA_WIDTH{1'b0}};		
	assign sb_ack_o	=	1'b0;
	altsyncram ram_inst(
		.clock0			(clk),
		.address_a		(addr_a),
		.wren_a			(we_a),
		.data_a			(data_a),
		.q_a				(q_a),
		 
		.wren_b			(	 ),
		.rden_a			( 	 ),
		.rden_b			( 	 ),
		.data_b			( 	 ),
		.address_b		(	 ),
		.clock1			( 	 ),
		.clocken0		( 	 ),
		.clocken1		( 	 ),
		.clocken2		( 	 ),
		.clocken3		( 	 ),
		.aclr0			( 	 ),
		.aclr1			( 	 ),
		.byteena_a		( 	 ),
		.byteena_b		( 	 ),
		.addressstall_a( 	 ),
		.addressstall_b( 	 ),
		.q_b				( 	 ),
		.eccstatus		( 	 )
	);
	defparam 
		ram_inst.operation_mode 							= "SINGLE_PORT",
		ram_inst.width_a 									= DATA_WIDTH,
		ram_inst.lpm_hint 									= RAM_ID,
		ram_inst.read_during_write_mode_mixed_ports = "DONT_CARE",
		ram_inst.widthad_a 									= ADDR_WIDTH,
		ram_inst.init_file  								= {"sw/ram/cpu",i2s(SW_X_ADDR),"_",i2s(SW_Y_ADDR),".mif"};
		
		
	end else begin : dual_port
	
	
	
	
	assign sb_dat_o		=	q_b;
	assign data_b			=	sb_dat_i ;
	assign addr_b			=	sb_addr_i;
	assign we_b				=	sb_stb_i &  sb_we_i;
	assign sb_ack_burst	=  sb_stb_i ;
	assign sb_ack_o = (sb_cti_i == 3'b000 ) ? sb_ack_classic : sb_ack_burst;
	
	
	
	always @(*) begin
		sb_ack_classic_next	=  (~sb_ack_o) & sb_stb_i;
	end
	
	always @(posedge clk ) begin
		if(reset) begin 
			sb_ack_classic <= 1'b0;
		end else begin 
			sb_ack_classic <= sb_ack_classic_next;		
		end 	
	end
	
	
	 dual_port_ram
	#( 
		.DATA_WIDTH	(DATA_WIDTH),
		.ADDR_WIDTH	(ADDR_WIDTH),
		.CORE_NUMBER(CORE_NUMBER)
	)
	ram
	(
		.data_a		(data_a), 
		.data_b		(data_b),
		.addr_a		(addr_a),
		.addr_b		(addr_b),
		.we_a			(we_a),
		.we_b			(we_b),
		.clk			(clk),
		.q_a			(q_a),
		.q_b			(q_b));



	end
	endgenerate
	 
	function   [23:0]i3s; 	
		input	integer	c;	integer i;	integer tmp; begin 
			tmp =0; 
			for (i=0; i<3; i=i+1'b1) begin 
			tmp	=  tmp +	(((c % 10)   + 6'd48) << i*8); 
				c		=	c/10; 
			end 
			i3s = tmp[23:0];
		end 	
   endfunction 
	
	 
	function   [15:0]i2s; 	
		input	integer	c;	integer i;	integer tmp; begin 
			tmp =0; 
			for (i=0; i<2; i=i+1'b1) begin 
			tmp	=  tmp +	(((c % 10)   + 6'd48) << i*8); 
				c		=	c/10; 
			end 
			i2s = tmp[15:0];
		end 	
   endfunction 
	 
	 
	 
endmodule
