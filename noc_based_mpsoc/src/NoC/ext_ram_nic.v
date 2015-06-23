/**********************************************************************
	File: ext_ram_nic.v 
	
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
	
	
	Purpose: The NI for connecting external SDRAM to the NoC router
	
	Info: monemi@fkegraduate.utm.my
********************************************************************/
`include "../define.v"

module ext_ram_nic #(
	parameter TOPOLOGY				=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT			=	"XY",		//"XY" or "MINIMAL"
	parameter VC_NUM_PER_PORT 		=	2,
	parameter PYLD_WIDTH 			=	32,
	parameter BUFFER_NUM_PER_VC	=	16,
	parameter FLIT_TYPE_WIDTH		=	2,
	parameter PORT_NUM				=	5,
	parameter X_NODE_NUM				=	4,
	parameter Y_NODE_NUM				=	3,
	parameter SW_X_ADDR				=	2,
	parameter SW_Y_ADDR				=	1,
	parameter NIC_CONNECT_PORT		=	0, // 0:Local  1:East, 2:North, 3:West, 4:South 
	parameter RAM_ADDR_WIDTH		=	25,
	parameter CAND_VC_SEL_MODE		=	0, // 0: use arbieration between not full vcs, 1: select the vc with the most availble free space
	parameter CONGESTION_WIDTH		=	8,
	parameter VC_ID_WIDTH			=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH				=	PYLD_WIDTH+FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter CORE_NUMBER			=	`CORE_NUM(SW_X_ADDR,SW_Y_ADDR)

	)
	(
		input					 							clk,                
		input  				 							reset,   
				
		// NOC interfaces
		output	[FLIT_WIDTH-1				:0] 	flit_out,     
		output 			  			   				flit_out_wr,   
		input 	[VC_NUM_PER_PORT-1		:0]	credit_in,
		input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
		input		[FLIT_WIDTH-1				:0] 	flit_in,     
		input 	    			   					flit_in_wr,   
		output 	[VC_NUM_PER_PORT-1		:0]	credit_out,
		
		// ram controller interface
		output [RAM_ADDR_WIDTH-1		:	0] 	ram_address,       
		output [3							:	0]		ram_byteenable_n,  
		output	reg									ram_chipselect,
		output [31							:	0]		ram_writedata,
		output  											ram_read_n,
		output											ram_write_n,
		input	[31							:	0]		ram_readdata,
		input												ram_readdatavalid,
		input 											ram_waitrequest
	);

	`LOG2
	localparam PORT_NUM_BCD_WIDTH			=	log2(PORT_NUM);
	localparam X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM);
	localparam Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM);
	localparam HDR_ZERO_NUM					=	(32 - (4*`X_Y_ADDR_WIDTH_IN_HDR) - PORT_NUM_BCD_WIDTH);
	
	localparam STATUSE_NUM					=	8;
	localparam IDEAL							=	1;
	localparam READ_HDR						=	2;
	localparam CAPTURE_START_ADDR			=	4;
	localparam CAPTURE_PCK_SIZE			=	8;
	localparam RD_ST							=	16;
	localparam WR_ST							=	32;
	localparam SEND_ACK_HDR					=	64;
	localparam SEND_ACK_TAIL				=	128;
					
	
	
	
	
	
	wire	[PORT_NUM_BCD_WIDTH-1		: 0]	port_num_next;
	reg	[PORT_NUM_BCD_WIDTH-1		: 0]	port_num;
	wire	[FLIT_TYPE_WIDTH-1			: 0]	flit_type;
	reg												ram_write,ram_read;
	wire 	[VC_NUM_PER_PORT-1			:0]	in_vc_num;
	wire 	[VC_NUM_PER_PORT-1			:0]	fifo_not_empty;
	wire	[FLIT_WIDTH-1					:0] 	fifo_flit_out;
	//wire	[VC_NUM_PER_PORT-1			:0]	fifo_vc_num;
	wire												fifo_hdr_flg,fifo_tail_flg;
	reg												fifo_rd;
	reg	[VC_NUM_PER_PORT-1			:0]	ivc_free;
	reg 	[RAM_ADDR_WIDTH-1				:0]	addr_counter,addr_counter_next,pck_size , pck_size_next;
	reg												src_en,addr_capture_en, pck_size_en,pck_size_dec;
	reg	[X_NODE_NUM_WIDTH-1			:0]	dest_x_addr,dest_x_addr_next;
	reg 	[Y_NODE_NUM_WIDTH-1			:0]	dest_y_addr,dest_y_addr_next;
	wire	[`X_Y_ADDR_WIDTH_IN_HDR-1	:0]	dest_x_addr_hdr,dest_y_addr_hdr;
	reg												wr_reg,wr_reg_next;	// 1 : write, 0 : read
	reg												ack_reg,ack_reg_next; // 1: ack required 0: no need 
	reg												ovc_wr;
	reg												wr_hdr,wr_hdr_next,wr_tail,wr_tail_next;
	reg 	[3									:0]	rd_valid_counter,rd_valid_counter_next;
	
	reg	[STATUSE_NUM-1					:0]	ps,ns;
	reg	[VC_NUM_PER_PORT-1			:0]	candidate_ivc;
	wire												cand_ivc_selected;
	reg												cand_ivc_en,cand_ovc_en;
	wire												cand_ivc_n_empty;
	wire	[VC_NUM_PER_PORT-1			:0]	ivc_arbiter_req;
	wire	[VC_NUM_PER_PORT-1			:0]	ivc_arbiter_grant;
	wire	[VC_NUM_PER_PORT-1			:0]	ovc_wr_in;
	wire	[VC_NUM_PER_PORT-1			:0]	cand_ovc,full_ovc;
	wire												cand_ovc_full;
	wire												all_ovc_full;
	reg												rd_busy,rd_busy_set,rd_busy_next;
	reg												addr_inc_next,addr_inc;
	
	
	assign ovc_wr_in	= (ovc_wr ) ?  cand_ovc : {VC_NUM_PER_PORT{1'b0}};
	assign ram_write_n				=	~ ram_write;
	assign ram_read_n					= 	~ ram_read;
	assign ram_writedata				=  fifo_flit_out	[31:			0];
	
	assign in_vc_num					=  flit_in			[`FLIT_IN_VC_LOC			];
	//assign fifo_vc_num				=	fifo_flit_out	[`FLIT_IN_VC_LOC			];
	//assign fifo_hdr_flg			=	fifo_flit_out	[`FLIT_HDR_FLG_LOC		];
	assign fifo_tail_flg				=	fifo_flit_out	[`FLIT_TAIL_FLAG_LOC		];
	
	assign cand_ivc_selected		=	|candidate_ivc;
	assign cand_ivc_n_empty			=	|(candidate_ivc	& fifo_not_empty);
	assign ivc_arbiter_req			=	(cand_ivc_en) ? fifo_not_empty : {VC_NUM_PER_PORT{1'b0}};
	assign all_ovc_full				=	& full_ovc;
	assign cand_ovc_full				=	|(full_ovc & cand_ovc) ;
	assign flit_out_wr				=	(ram_readdatavalid | wr_hdr | wr_tail);
	assign flit_out					=	(wr_hdr) ? {`HDR_FLIT,cand_ovc,port_num,dest_x_addr_hdr,dest_y_addr_hdr,SW_X_ADDR[`X_Y_ADDR_WIDTH_IN_HDR-1 : 0],SW_Y_ADDR[`X_Y_ADDR_WIDTH_IN_HDR-1 : 0],{HDR_ZERO_NUM	{1'b0}}}: 
															  {flit_type,cand_ovc,ram_readdata};
	assign flit_type					= (wr_tail ||(rd_valid_counter == 1 && rd_busy)) ?	`TAIL_FLIT	: `BODY_FLIT;									  
	assign ram_address				= addr_counter;
	assign credit_out					=(fifo_rd) ? 	candidate_ivc : {VC_NUM_PER_PORT{1'b0}};
	assign ram_byteenable_n			= 4'd0;	
	
	generate 
		if(X_NODE_NUM_WIDTH == `X_Y_ADDR_WIDTH_IN_HDR) assign dest_x_addr_hdr = dest_x_addr;
		else 		assign dest_x_addr_hdr = {{(`X_Y_ADDR_WIDTH_IN_HDR-X_NODE_NUM_WIDTH){1'b0}},dest_x_addr};
	
		if(Y_NODE_NUM_WIDTH == `X_Y_ADDR_WIDTH_IN_HDR) assign dest_y_addr_hdr = dest_y_addr;
		else 		assign dest_y_addr_hdr = {{(`X_Y_ADDR_WIDTH_IN_HDR-Y_NODE_NUM_WIDTH){1'b0}},dest_y_addr};
	endgenerate
	

	//assign fifo_not_empty & ~ivc_busy;
	
	fifo_buffer #(
		.VC_NUM_PER_PORT 			(VC_NUM_PER_PORT),
		.PORT_NUM					(PORT_NUM),
		.PYLD_WIDTH					(PYLD_WIDTH),
		.BUFFER_NUM_PER_VC		(BUFFER_NUM_PER_VC),
		.FLIT_TYPE_WIDTH			(FLIT_TYPE_WIDTH),
		.ENABLE_MIN_DEPTH_OUT	(0)
	)	
	flit_in_buffer
	(
		.din						(flit_in),     
		.vc_num_wr				(in_vc_num),
		.vc_num_rd				(candidate_ivc),				
		.wr_en					(flit_in_wr),   
		.rd_en					(fifo_rd),   
		.dout						(fifo_flit_out),    
		.vc_nearly_full		(),
		.vc_not_empty			(fifo_not_empty),
		.reset					(reset),
		.clk						(clk)
	);
	
	
	arbiter #(
		.ARBITER_WIDTH		(VC_NUM_PER_PORT),
		.CHOISE 				(1)  
	)
	ivc_arbiter
	(	
	.clk			(clk), 
   .reset 		(reset), 
   .request		(ivc_arbiter_req), 
   .grant		(ivc_arbiter_grant),
	.anyGrant	()
	);

	output_vc_status #(
		.VC_NUM_PER_PORT		(VC_NUM_PER_PORT),
		.BUFFER_NUM_PER_VC	(BUFFER_NUM_PER_VC),
		.CAND_VC_SEL_MODE		(CAND_VC_SEL_MODE)	
	)
	ram_ovc_status
	(
	.wr_in						(ovc_wr_in),   
	.credit_in					(credit_in),
	.full_vc						(full_ovc),
	.cand_vc						(cand_ovc),
	.cand_wr_vc_en				(cand_ovc_en),
	.clk							(clk),
	.reset						(reset)
	);


 route_compute  #(
	.TOPOLOGY					(TOPOLOGY),
	.ROUTE_ALGRMT				(ROUTE_ALGRMT),
	.PORT_NUM					(PORT_NUM),
	.X_NODE_NUM					(X_NODE_NUM),
	.Y_NODE_NUM					(Y_NODE_NUM),
	.SW_X_ADDR					(SW_X_ADDR),
	.SW_Y_ADDR					(SW_Y_ADDR)
	)
	the_normal_routting
	(
	.congestion_cmp_i			(congestion_cmp_i),
	.dest_x_node_in			(dest_x_addr),
	.dest_y_node_in			(dest_y_addr),
	.in_port_num_i				({PORT_NUM_BCD_WIDTH{1'b0}}), //conventional routing
	.port_num_out				(port_num_next)
	);
	

	
	always @(*)begin
	ns						=	ps;
	ram_write			=	1'b0;
	ram_read				=	1'b0;
	fifo_rd 				=	1'b0;
	src_en				=  1'b0;
	addr_capture_en	=	1'b0;
	pck_size_en			=	1'b0;
	cand_ivc_en			=	1'b0;
	cand_ovc_en			=	1'b0;
	ovc_wr				=	1'b0;
	pck_size_dec		=	1'b0;
	wr_hdr_next			=  1'b0;
	wr_tail_next		=	1'b0;
	rd_busy_set			=  1'b0;
	ram_chipselect		= 	1'b1;
	addr_inc				=	1'b0;
	
	
	
	case(ps) 
		IDEAL: begin
			ram_chipselect	= 	1'b0;
			if(cand_ivc_selected)begin
				ns = READ_HDR;
				fifo_rd	= 1'b1;
				//synthesis translate_off
					$display($time,"sdram has recived a packet");
				//synthesis translate_on
			end else begin
				cand_ivc_en	= 1'b1;
			end
		end //IDEAL
		
		READ_HDR: begin 
			src_en	= 1'b1;
			if(cand_ivc_n_empty) begin
				fifo_rd	= 1'b1;
				ns = CAPTURE_START_ADDR;
			end		
		end//READ_HDR
		
		CAPTURE_START_ADDR: begin
			addr_capture_en	= 1'b1;
			if(cand_ivc_n_empty ) begin
				fifo_rd	= 1'b1;
				ns = (wr_reg) ?  WR_ST: CAPTURE_PCK_SIZE; 
			end		
		end//CAPTURE_START_ADDR	
		
		WR_ST : begin
			if ( ram_waitrequest) ram_write		=	1'b1;
			else begin 
				if(cand_ivc_n_empty && (! fifo_tail_flg) ) begin 
					ram_write			=	1'b1;
					fifo_rd				=	1'b1;
					addr_inc				=	1'b1;
				end
				if(fifo_tail_flg	&& (~all_ovc_full) && ~rd_busy) begin 
					ram_write			=	1'b1;
					cand_ivc_en			=	1'b1;
					if(ack_reg) begin 	
						ns						=	SEND_ACK_HDR;
						wr_hdr_next			=	1'b1;
						cand_ovc_en			=	1'b1;
					end else ns				= 	IDEAL;
				end
			end
		end //WR_ST
		
		SEND_ACK_HDR: begin
			if(!cand_ovc_full) begin
				ns = SEND_ACK_TAIL;
				wr_tail_next		=	1'b1;
				ovc_wr				=	1'b1;
			end
		end //SEND_ACK_HDR
		
		SEND_ACK_TAIL: begin
			if(!cand_ovc_full) begin
				ns = IDEAL;
				ovc_wr				=	1'b1;
			end
		end// SEND_ACK_TAIL
		
		CAPTURE_PCK_SIZE: begin
			pck_size_en	= 1'b1;
			if(~all_ovc_full && ~rd_busy) begin
				cand_ovc_en			=	1'b1;
				wr_hdr_next			=	1'b1;
				ovc_wr				=	1'b1;
				ns 					=	RD_ST; 
			end		
		end // CAPTURE_PCK_SIZE
	
		RD_ST: begin 
			if ( ram_waitrequest) ram_read	=	1'b1;
			else begin
				if(pck_size>0 )begin
					if(~cand_ovc_full) begin 
						ovc_wr				=	1'b1;
						ram_read			=	1'b1;
						pck_size_dec		=	1'b1;
						addr_inc				=	1'b1;
						if( pck_size== 24'd1) rd_busy_set		=	1'b1;
					end
				end else begin 
					cand_ivc_en	=	1'b1;
					ns= IDEAL;
				end
			end//else
		end// RD_ST
	endcase
	end	
		
		
	always @(posedge clk ) begin
		if(reset) begin
			ps						<= IDEAL;
			candidate_ivc		<= {VC_NUM_PER_PORT{1'b0}};
			dest_x_addr			<= {X_NODE_NUM_WIDTH{1'b0}};
			dest_y_addr			<= {Y_NODE_NUM_WIDTH{1'b0}};
			addr_counter		<=	{RAM_ADDR_WIDTH{1'b0}};
			pck_size				<=	{RAM_ADDR_WIDTH{1'b0}};	
			port_num				<=	{PORT_NUM_BCD_WIDTH{1'b0}};
			wr_reg				<=	1'b0;
			ack_reg				<= 1'b0;
			wr_hdr				<= 1'b0;
			wr_tail				<= 1'b0;
			rd_valid_counter	<=	4'd0;
			rd_busy				<= 1'b0;
		
	
		end else begin 
			if(cand_ivc_en) 	candidate_ivc <= ivc_arbiter_grant;
			ps						<=	ns;
			dest_x_addr			<= dest_x_addr_next;
			dest_y_addr			<= dest_y_addr_next;
			wr_reg				<=	wr_reg_next;
			ack_reg				<= ack_reg_next;
			addr_counter		<=	addr_counter_next;
			pck_size				<=	pck_size_next;	
			port_num				<=	port_num_next;
			wr_hdr				<= wr_hdr_next;
			rd_valid_counter	<=	rd_valid_counter_next;
			rd_busy				<= rd_busy_next;
			wr_tail				<= wr_tail_next;
		
		
		end
	end
	
	always @(*) begin
		addr_counter_next			=	addr_counter;
		pck_size_next				=	pck_size;
		rd_valid_counter_next	=	rd_valid_counter;
		rd_busy_next				=  rd_busy;
		dest_x_addr_next			=	dest_x_addr;
		dest_y_addr_next			=	dest_y_addr;
		wr_reg_next					=	wr_reg;
		ack_reg_next				=	ack_reg;
		
		if			(src_en)	begin 
			dest_x_addr_next 	=	fifo_flit_out [`FLIT_IN_X_SRC_LOC];
			dest_y_addr_next 	= 	fifo_flit_out [`FLIT_IN_Y_SRC_LOC];
			wr_reg_next		  	=	fifo_flit_out [`FLIT_IN_WR_RAM_LOC];
			ack_reg_next		=	fifo_flit_out [`FLIT_IN_ACK_REQ_LOC];
		end
		
		if			(addr_capture_en) addr_counter_next		=	fifo_flit_out [RAM_ADDR_WIDTH-1	:0];
		else if	(addr_inc		 ) addr_counter_next		=	addr_counter +1'b1;
		
		if 		(pck_size_en	) 	pck_size_next	=	fifo_flit_out [RAM_ADDR_WIDTH-1	:0];
		else if	(pck_size_dec	)	pck_size_next	=	pck_size -1'b1;
		
		if			( (ram_read & ~ram_waitrequest)   && ! ram_readdatavalid) rd_valid_counter_next	= rd_valid_counter +1'b1;
		else if 	(!(ram_read & ~ram_waitrequest)    &&  ram_readdatavalid) rd_valid_counter_next	= rd_valid_counter -1'b1;
		
		if			(rd_busy_set	) 			rd_busy_next = 1'b1; 
		else if	(rd_valid_counter == 0) rd_busy_next = 1'b0; 
		
	
		
	
	end
	
	
endmodule


/*
WR_ST:


cand_ivc_n_empty		ram_waitrequest		fifo_tail_flg	all_ovc_full	|		fifo_rd	ram_write_next 	ns	
------------------------------------------------------------------------------------------------------------				
	1							0								0				x				|			1				1				ps
	x							1								x				x				|			0		  ram_write		ps
	0							0								0				x				|			0				0				ps
	x							0								1				1				|			0				0				ps
	x							0								1				0				|			0				0				ACK


	
	cand_ivc_n_empty		ram_waitrequest		fifo_tail_flg	all_ovc_full	|		fifo_rd	ram_write_next 	ns	
------------------------------------------------------------------------------------------------------------				
	1							0								0				x				|			1				1				
	x							1								x				x				|					  		ram_write
	0							0								0				x				|											
	x							0								1				1				|										
	x							0								1				0				|											ACK


	
	cand_ivc_n_empty		fifo_tail_flg	all_ovc_full	|		fifo_rd	ram_write_next 	ns	
----------------------------------------------------------------------------------------------				
	1									0				x				|			1				1				
	x									1				0				|											ACK


*/


