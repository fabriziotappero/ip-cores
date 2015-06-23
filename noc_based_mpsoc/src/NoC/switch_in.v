/**********************************************************************
	File: switch_in.v 
	
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
	The Input port module. 
	
	Info: monemi@fkegraduate.utm.my

********************************************************************/


`define 			PORT_SEL_BUFF_NUM				4
`timescale 1ns / 1ps
`include "../define.v"
module switch_in #(
	parameter SWITCH_LOCATION			=	0,//0 to 4
	parameter VC_NUM_PER_PORT			=	4,
	parameter PORT_NUM					=	5,
	parameter PYLD_WIDTH 				=	32,
	parameter BUFFER_NUM_PER_VC		=	4,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter SW_X_ADDR					=	2,
	parameter SW_Y_ADDR					=	1,
	parameter FLIT_TYPE_WIDTH			=	2,
	parameter ENABLE_MIN_DEPTH_OUT	=	0, // if 1 then the VC with minimum depth is merged with vc_not_empty as output of fifo buffer
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter VC_ID_WIDTH				=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH					=	PYLD_WIDTH+ FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter TOTAL_VC_NUM				=	VC_NUM_PER_PORT		*	PORT_NUM,
	parameter VC_NUM_BCD_WIDTH			=	log2(VC_NUM_PER_PORT),
	parameter OVCS_WIDTH					=	VC_NUM_PER_PORT		*	VC_NUM_PER_PORT,
	parameter OVCS_BCD_WIDTH			=	VC_NUM_BCD_WIDTH		*	VC_NUM_PER_PORT,
	parameter CANDIDATE_OVCS_WIDTH	=	VC_NUM_PER_PORT		*	PORT_SEL_WIDTH,
	parameter CAND_OVCS_BCD_WIDTH		=	VC_NUM_BCD_WIDTH		*	PORT_SEL_WIDTH,
	parameter PORT_SEL_BCD_WIDTH		=	log2(PORT_SEL_WIDTH),
	parameter OUTPUTPORT_SEL_WIDTH	=	VC_NUM_PER_PORT		*	PORT_SEL_BCD_WIDTH,
	parameter X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM),
	parameter Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM),
	parameter OVC_WR_WIDTH				=	CANDIDATE_OVCS_WIDTH,
	parameter OVC_RLS_WIDTH				=	CANDIDATE_OVCS_WIDTH,
	parameter OVC_ALOC_WIDTH			=	CANDIDATE_OVCS_WIDTH,
	parameter STATUS_ARRAY_WIDTH		=	VC_NUM_PER_PORT 		* 	2,
	parameter VC_FULL_WIDTH				=  (ENABLE_MIN_DEPTH_OUT) ? VC_NUM_PER_PORT*2 : VC_NUM_PER_PORT,
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM)

	)
	(
	//interface to naibour router
	input		[FLIT_WIDTH-1					:0] 	flit_in,   
	input													wr_in_en,
	output	[VC_NUM_PER_PORT-1			:0]	credit_out,
	
		
	//interface to cross bar
	output 	[FLIT_WIDTH-1					:0] 	flit_out,
	output 	[PORT_NUM_BCD_WIDTH-1		:0]	look_ahead_port_sel_out,	
	output 	[VC_NUM_BCD_WIDTH-1			:0]	ovc,
	
	//interface to OVC status 
	input		[STATUS_ARRAY_WIDTH-1		:0]	assigned_ovcs_status,
	//input 	[CANDIDATE_OVCS_WIDTH-1		:0] 	candidate_ovcs,
	input 	[CAND_OVCS_BCD_WIDTH-1		:0] 	candidate_bcd_ovcs,
	output	[OVCS_BCD_WIDTH-1				:0]	ovcs,
	input		[PORT_SEL_WIDTH-1				:0]	ovc_available,
	output 	[OVC_RLS_WIDTH-1				:0]	ovc_released,
	output	[OVC_WR_WIDTH-1				:0]	ovc_write_granted,
	output	[OVC_ALOC_WIDTH-1				:0]	ovc_allocated,
	output   [PORT_SEL_WIDTH-1				:0]	ovc_alloc_in_port,
	
	//interface to switch allocator
	output	[VC_NUM_PER_PORT-1			:0]	ivc_request,
	input		[VC_NUM_PER_PORT-1			:0]	ivc_granted,
	output	[OUTPUTPORT_SEL_WIDTH-1		:0]	out_port_select,
	input 	[VC_NUM_PER_PORT-1			:0]	candidate_ivc,
	//input	[PORT_SEL_WIDTH-1				:0]	candidate_port,
	input		[PORT_SEL_WIDTH-1				:0]	granted_port,											
	input													any_vc_granted,
	
	//interface to look over head routing module
	output 	[X_NODE_NUM_WIDTH-1			:0]	dest_x_addr,
	output	[Y_NODE_NUM_WIDTH-1			:0]	dest_y_addr,
	output	[PORT_NUM_BCD_WIDTH-1		:0]	in_port_num,
	input		[PORT_NUM_BCD_WIDTH-1		:0]	look_ahead_port_sel_in,	
		
	//global
	input													reset,
	input 												clk
	);
	
	`LOG2
	
	localparam OVC_MUX_IN_WIDTH			=	CANDIDATE_OVCS_WIDTH*VC_NUM_PER_PORT;
	localparam MAX_PCK_NUM_IN_VC			=	((BUFFER_NUM_PER_VC/2) > `PORT_SEL_BUFF_NUM )? `PORT_SEL_BUFF_NUM : BUFFER_NUM_PER_VC/2;
	localparam ALL_LK_PORT_NUM_WIDTH		=	PORT_NUM_BCD_WIDTH * VC_NUM_PER_PORT;	
	
	
	
	wire 													header_flag;//if set flit is header
	wire 													tail_flag;//if set flit is tail
	wire 		[VC_NUM_PER_PORT-1			:0]	in_vc_num;
	wire 		[PORT_SEL_WIDTH-1				:0]	in_port_select;
	wire		[PORT_SEL_BCD_WIDTH-1		:0]	in_port_select_bcd;
	wire		[VC_NUM_PER_PORT-1			:0]	candidate_ovc_mux_out;
	wire		[VC_NUM_BCD_WIDTH-1			:0]	candidate_ovc_bcd_mux_out [VC_NUM_PER_PORT-1		:0];
	
	wire 		[VC_NUM_PER_PORT-1			:0]	port_sel_wr_en;
	reg 		[VC_NUM_PER_PORT-1			:0]	port_sel_wr_en_reg;
	wire		[VC_NUM_PER_PORT-1			:0]	port_sel_rd_en;
	reg 		[VC_NUM_PER_PORT-1			:0]	port_sel_rd_en_reg;
	reg		[VC_NUM_BCD_WIDTH-1			:0]	candidate_ivc_bcd_reg;
	wire		[VC_NUM_BCD_WIDTH-1			:0]	candidate_ivc_bcd;
	reg 		[VC_NUM_PER_PORT-1			:0]	ovc_not_assigned;
	//reg 	[VC_NUM_PER_PORT-1			:0]	ovc_reg			[VC_NUM_PER_PORT-1		:0];
	reg 		[VC_NUM_BCD_WIDTH-1			:0]	ovc_bcd_reg		[VC_NUM_PER_PORT-1		:0];
	wire 		[VC_NUM_PER_PORT-1			:0]	ovc_p				[VC_NUM_PER_PORT-1		:0];
	wire 		[VC_NUM_BCD_WIDTH-1			:0]	ovc_p_bcd		[VC_NUM_PER_PORT-1		:0];
	wire 		[VC_NUM_PER_PORT-1			:0]	ovc_p_candidate;	
	wire		[VC_NUM_PER_PORT-1			:0]	tail_ivc_candidate,not_assigned_ivc_candidate;
	wire													tail_candidate,not_assigned_candidate;
	wire 		[VC_NUM_PER_PORT-1			:0]	ovc_reg_next				[VC_NUM_PER_PORT-1		:0];
	
	wire 		[VC_NUM_PER_PORT-1			:0]	tail_flit_in;
	wire 		[VC_NUM_PER_PORT-1			:0]	tail_flit_out;
	wire 		[VC_NUM_PER_PORT-1			:0]	port_sel_buff_wr_in_en;
	wire 		[VC_NUM_PER_PORT-1			:0]	ivc_not_empty;
	//wire		[VC_NUM_PER_PORT-1			:0]	ivc_recieved_more_than_one;
	wire 		[VC_NUM_PER_PORT-1			:0]	vc_not_assigned_req;
	wire 		[VC_NUM_PER_PORT-1			:0]	vc_assigned_reg;
	wire 		[VC_NUM_PER_PORT-1			:0]	assign_ovc_en;
	wire 		[VC_NUM_PER_PORT-1			:0]	tail_is_passed;
	//wire 	[PORT_SEL_WIDTH-1				:0]	port_sel_buff_dout		[VC_NUM_PER_PORT-1		:0];
	wire 		[PORT_SEL_BCD_WIDTH-1		:0]	port_sel_buff_bcd_dout	[VC_NUM_PER_PORT-1		:0];
	//wire 	[PORT_SEL_WIDTH-1				:0]	vc_alloc_req				[VC_NUM_PER_PORT-1		:0];
	wire		[PORT_NUM_BCD_WIDTH-1		:0]	look_ahead_port_sel_all	[VC_NUM_PER_PORT-1		:0];
	wire		[CANDIDATE_OVCS_WIDTH-1		:0]	candidate_ovc_released,candidate_ovc_alloc_granted;
	wire		[ALL_LK_PORT_NUM_WIDTH-1	:0]	look_ahead_mux_in;
	//wire 	[CANDIDATE_OVCS_WIDTH-1		:0]	vc_alloc_req_array;
	
	//wire 		[OVCS_WIDTH-1					:0]	all_ovcs;
	wire 		[OVCS_BCD_WIDTH-1				:0]	all_ovcs_bcd;
	wire		[VC_NUM_PER_PORT-1			:0]	tail_fifo_wr;
	reg 		[VC_NUM_PER_PORT-1			:0]	ivc_granted_reg;
	//wire		[OVC_WR_WIDTH-1				:0]	ovc_write_candidate;
	
	//wire		[PORT_SEL_WIDTH-1				:0]	ovc_alloc_candidate;
	wire		[PORT_SEL_WIDTH-1				:0]	ovc_alloc_grant_gen;
	wire													not_assigned_mux_out;
	//wire		[CND_OVCS_BCD_WIDTH-1		:0]	candidate_ovcs_bcd;
	
	genvar i;
	
	
	
	assign header_flag				=	flit_in[`FLIT_HDR_FLG_LOC		];
	assign tail_flag					=	flit_in[`FLIT_TAIL_FLAG_LOC	];
	assign in_vc_num					=  flit_in[`FLIT_IN_VC_LOC			];
	assign in_port_num				=	flit_in[`FLIT_IN_PORT_SEL_LOC	];
	assign dest_x_addr				=	flit_in[`FLIT_IN_X_DES_LOC		];
	assign dest_y_addr				=	flit_in[`FLIT_IN_Y_DES_LOC		];
	assign port_sel_rd_en			=	tail_is_passed;
	assign ovc_released				=	ovc_write_granted  	&	{CANDIDATE_OVCS_WIDTH{tail_candidate}};
	assign ovc_allocated		 		=	ovc_write_granted 	&	{CANDIDATE_OVCS_WIDTH{not_assigned_candidate}};
	assign ovc_alloc_in_port  		= 	granted_port 			& 	{PORT_SEL_WIDTH{not_assigned_candidate}};
	assign not_assigned_candidate =	ovc_not_assigned [candidate_ivc_bcd];	
	assign tail_candidate			=	tail_flit_out	[candidate_ivc_bcd];
	
	
	
	
	wire [1	: 0]	ovcs_status	[VC_NUM_PER_PORT-1		:0];
	
	generate
			for(i=0;i<VC_NUM_PER_PORT;i=i+1)begin : state_loop
				assign	ovcs_status[i]	=	{assigned_ovcs_status[VC_NUM_PER_PORT+i],assigned_ovcs_status[i]};
			end
	endgenerate
	
		
	//candidate_ovc_mux
/*	
	one_hot_mux #(
				.IN_WIDTH			(CANDIDATE_OVCS_WIDTH),
				.SEL_WIDTH			(PORT_SEL_WIDTH)
			)
			candidate_ovc_mux
			(
				.mux_in				(candidate_ovcs),
				.mux_out				(candidate_ovc_mux_out),
				.sel					(candidate_port)
		
			);
*/

/*
	one_hot_in_bcd_out_mux#(
			.IN_WIDTH			(CANDIDATE_OVCS_WIDTH),
			.SEL_WIDTH			(PORT_SEL_WIDTH)
	)
	candidate_ovc_mux
	(
			.mux_in				(candidate_ovcs),
			.mux_out				(candidate_ovc_bcd_mux_out),
			.sel					(candidate_port)
	);

*/	
	//input buffer	
	fifo_buffer #(
		.VC_NUM_PER_PORT		(VC_NUM_PER_PORT),
		.PORT_NUM				(PORT_NUM),
		.PYLD_WIDTH 			(PYLD_WIDTH),
		.BUFFER_NUM_PER_VC	(BUFFER_NUM_PER_VC),
		.FLIT_TYPE_WIDTH		(FLIT_TYPE_WIDTH),
		.ENABLE_MIN_DEPTH_OUT(0)
		
	)
	flit_buffer
	(
		.din						(flit_in),     
		.vc_num_wr				(in_vc_num),
		.vc_num_rd				(candidate_ivc),				
		.wr_en					(wr_in_en),   
		.rd_en					(any_vc_granted),   
		.dout						(flit_out),    
		.vc_nearly_full		(),
		.vc_not_empty			(),
		.reset					(reset),
		.clk						(clk)
	);

	
	
	/*
	//vc allocation mux
	one_hot_mux #(
		.IN_WIDTH			(CANDIDATE_OVCS_WIDTH),
		.SEL_WIDTH			(VC_NUM_PER_PORT)
	)
	vc_alloc_mux
	(
		.mux_in				(vc_alloc_req_array),
		.mux_out				(ovc_alloc_candidate),
		.sel					(candidate_ivc)

	);
	*/
	
	//look_aheadport_sel_mux
	/*
	one_hot_mux #(
		.IN_WIDTH			(ALL_LK_PORT_NUM_WIDTH),
		.SEL_WIDTH			(VC_NUM_PER_PORT)
	)
	look_ahead_port_sel_mux
	(
		.mux_in				(look_ahead_mux_in),
		.mux_out				(look_ahead_port_sel_out),
		.sel					(candidate_ivc_reg)

	);
	*/
	
	bcd_mux #(
		.IN_WIDTH			(ALL_LK_PORT_NUM_WIDTH),
		.SEL_WIDTH_BCD 	(VC_NUM_BCD_WIDTH), 
		.OUT_WIDTH 			(PORT_NUM_BCD_WIDTH)
	)
	look_ahead_port_sel_mux
	(
		.mux_in				(look_ahead_mux_in),
		.mux_out				(look_ahead_port_sel_out),
		.sel					(candidate_ivc_bcd_reg)

	);
	
	//ovc_mux
	/*
	one_hot_mux #(
		.IN_WIDTH			(OVCS_WIDTH),
		.SEL_WIDTH			(VC_NUM_PER_PORT)
	)
	ovc_mux
	(
		.mux_in				(all_ovcs),
		.mux_out				(ovc),
		.sel					(candidate_ivc_reg)

	);
	*/
	
	bcd_mux #(
		.IN_WIDTH			(OVCS_BCD_WIDTH),
		.SEL_WIDTH_BCD 	(VC_NUM_BCD_WIDTH), 
		.OUT_WIDTH 			(VC_NUM_BCD_WIDTH)
	)
	ovc_mux
	(
		.mux_in				(all_ovcs_bcd),
		.mux_out				(ovc),
		.sel					(candidate_ivc_bcd_reg)

	);
	
	

	//ovc_p_mux
	/*
	one_hot_mux #(
		.IN_WIDTH			(OVCS_WIDTH),
		.SEL_WIDTH			(VC_NUM_PER_PORT)
	)
	ovc_p_mux
	(
		.mux_in				(ovcs),
		.mux_out				(ovc_p_candidate),
		.sel					(candidate_ivc)

	);
	*/
	bcd_in_one_hot_out_mux #(
		.IN_BCD_WIDTH		(OVCS_BCD_WIDTH),
		.SEL_BCD_WIDTH 	(VC_NUM_BCD_WIDTH)  
	)
	ovc_p_mux
	(
		.mux_in				(ovcs),
		.mux_out				(ovc_p_candidate),
		.sel					(candidate_ivc_bcd)
	);
	/*
	bcd_mux #(
		.IN_WIDTH			(OVCS_BCD_WIDTH),
		.SEL_WIDTH_BCD 	(VC_NUM_BCD_WIDTH), 
		.OUT_WIDTH 			(VC_NUM_BCD_WIDTH)
	)
	ovc_p_mux
	(
		.mux_in				(ovcs),
		.mux_out				(ovc_p_candidate),
		.sel					(candidate_ivc_bcd)

	);
	*/
	
	
	
	//one_hot_demux
	one_hot_demux	#(
		.IN_WIDTH		(VC_NUM_PER_PORT),
		.SEL_WIDTH		(PORT_SEL_WIDTH)
		
	)
	ovc_wr_demux
	(
		.demux_sel		(granted_port),//selectore
		.demux_in		(ovc_p_candidate),//repeated
		.demux_out		(ovc_write_granted)
	);

	

	
	port_sel_correction #(
		.PORT_NUM 			(PORT_NUM),
		.SWITCH_LOCATION 	(SWITCH_LOCATION)
	)
	the_port_sel_correction
	(
		.port_num_bcd (in_port_num),
		.port_sel_bcd (in_port_select_bcd)
	);
	
	
	one_hot_to_bcd #(
		.ONE_HOT_WIDTH	(VC_NUM_PER_PORT),
		.BCD_WIDTH		(VC_NUM_BCD_WIDTH)
	)
	ivc_bcd_conv
	(
		.one_hot_code 	(candidate_ivc),
		.bcd_code		(candidate_ivc_bcd)
	);
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			candidate_ivc_bcd_reg	<= {VC_NUM_BCD_WIDTH{1'b0}};
		end else begin
			candidate_ivc_bcd_reg		<=	candidate_ivc_bcd;
		
		end
	
	
	end
	
	/*
	assign in_port_select_bcd = in_port_num;
	
	generate 
	//remove one extra bit from port num
	for(i=0;i<PORT_NUM;i=i+1)begin :port_loop
		if	(i>SWITCH_LOCATION)		assign in_port_select[i-1]		=	in_port_num[i];
		else if(i<SWITCH_LOCATION)	assign in_port_select[i]		=	in_port_num[i];
	end//for
	*/
	
	
	generate 
	
	for(i=0;i<VC_NUM_PER_PORT;i=i+1) begin :vc_loop
		
		assign out_port_select		[(i+1)*PORT_SEL_BCD_WIDTH-1	:		i*PORT_SEL_BCD_WIDTH]			=	port_sel_buff_bcd_dout[i];
	//	assign vc_alloc_req_array	[(i+1)*PORT_SEL_WIDTH-1	:		i*PORT_SEL_WIDTH]			=	vc_alloc_req[i];
//		assign all_ovcs				[(i+1)*VC_NUM_PER_PORT-1:		i*VC_NUM_PER_PORT]		=	ovc_reg[i];
		assign all_ovcs_bcd			[(i+1)*VC_NUM_BCD_WIDTH-1:		i*VC_NUM_BCD_WIDTH]		=	ovc_bcd_reg[i];
//		assign ovcs						[(i+1)*VC_NUM_PER_PORT-1:		i*VC_NUM_PER_PORT]		=	ovc_p[i];
		assign ovcs						[(i+1)*VC_NUM_BCD_WIDTH-1:		i*VC_NUM_BCD_WIDTH]		=	ovc_p_bcd[i];

//		assign ovc_p[i]	=	(ovc_not_assigned[i])? 		candidate_ovc_mux_out	:	ovc_reg[i];
		assign ovc_p_bcd[i]	=	(ovc_not_assigned[i])? 		candidate_ovc_bcd_mux_out[i]	:	ovc_bcd_reg[i];
		assign look_ahead_mux_in	[(i+1)*PORT_NUM_BCD_WIDTH-1			:		i*PORT_NUM_BCD_WIDTH]					=  look_ahead_port_sel_all[i];
		assign tail_flit_in[i]					=	in_vc_num[i]	& tail_flag;
		assign port_sel_wr_en[i]				=  in_vc_num[i]	& wr_in_en & header_flag;
		assign assign_ovc_en[i]					=	ivc_granted[i]	& ovc_not_assigned[i];
		assign tail_is_passed[i]				=	ivc_granted[i]	& tail_flit_out[i];
		//assign vc_alloc_req[i]					=	port_sel_buff_dout[i]	&{PORT_SEL_WIDTH{ovc_not_assigned[i]}};
		assign tail_fifo_wr[i]					=	wr_in_en & in_vc_num[i];
		assign credit_out[i]						=	ivc_granted_reg[i];
		
		
		bcd_mux#(
			.IN_WIDTH			(CAND_OVCS_BCD_WIDTH),
			.OUT_WIDTH			(VC_NUM_BCD_WIDTH)
		)
		candidate_ovc_mux
		(
			.mux_in				(candidate_bcd_ovcs),
			.mux_out				(candidate_ovc_bcd_mux_out[i]),
			.sel					(port_sel_buff_bcd_dout[i])
		);
	
	
		
		
		
		//port_sel_fifo	
		fwft_fifo #(
			.WIDTH					(PORT_SEL_BCD_WIDTH),//one bit for tail detection
			.MAX_DEPTH_BITS		(MAX_PCK_NUM_IN_VC)
		)
		port_sel_buff
		(
			.din						(in_port_select_bcd),     // Data in
			.wr_en					(port_sel_wr_en[i]),   // Write enable
			.rd_en					(port_sel_rd_en[i]),   // Read the next word
			.dout						(port_sel_buff_bcd_dout[i]),    // Data out
			.full						(),
			.nearly_full			(),
			.recieve_more_than_0	(),
			.recieve_more_than_1	(),
			.reset					(reset),
			.clk						(clk)
	
		);
		
	/*	
	bcd_to_one_hot #(
		.BCD_WIDTH(PORT_SEL_BCD_WIDTH)
	)
	port_sel_one_hot
	(
		.bcd_code	(port_sel_buff_bcd_dout[i]),
		.one_hot_code (port_sel_buff_dout[i])
	);
	*/	
		
		//tail_detect_fifo
		fwft_fifo #(
			.WIDTH					(1),//one bit for tail detection
			.MAX_DEPTH_BITS		(BUFFER_NUM_PER_VC)
		)
		tail_detect_buff
		(
			.din						(tail_flit_in[i]),     // Data in
			.wr_en					(tail_fifo_wr[i]),   // Write enable
			.rd_en					(ivc_granted[i]),   // Read the next word
			.dout						(tail_flit_out[i]),    // Data out
			.full						(),
			.nearly_full			(),
			.recieve_more_than_0	(ivc_not_empty[i]),
			.recieve_more_than_1	(),
			.reset					(reset),
			.clk						(clk)
	
		);
		
		
		
		
	
		//look_ahead_port_sel_fifo
		fwft_fifo #(
			.WIDTH					(PORT_NUM_BCD_WIDTH),
			.MAX_DEPTH_BITS		(MAX_PCK_NUM_IN_VC)
		)
		look_ahead_port_sel_buff
		(
			.din						(look_ahead_port_sel_in),     // Data in
			.wr_en					(port_sel_wr_en_reg[i]),   // Write enable
			.rd_en					(port_sel_rd_en_reg[i]),   // Read the next word
			.dout						(look_ahead_port_sel_all[i]),    // Data out
			.full						(),
			.nearly_full			(),
			.recieve_more_than_0	(),
			.recieve_more_than_1	(),
			.reset					(reset),
			.clk						(clk)
	
		);
	
	//ivc filter	
		ivc_request_mask #(
			.PORT_NUM					(PORT_NUM)
		)
		ivc_mask
		(
			.ovc_available							(ovc_available),
			.port_sel_bcd							(port_sel_buff_bcd_dout[i]),
			.ovc_not_assigned						(ovc_not_assigned[i]),
			.tail_flit								(tail_flit_out[i]),
			.ivc_not_empty							(ivc_not_empty[i]),	
			//.ivc_recieved_more_than_one_flit	(ivc_recieved_more_than_one[i]),
			.ovc_status								(ovcs_status[i]),
			.ivc_granted							(ivc_granted[i]),
			.ivc_request							(ivc_request[i]),
			.clk										(clk),
			.reset									(reset)
		);
		
		
 
		
		
		
	
		always @(posedge clk or posedge reset)begin
			if(reset) begin
				ovc_not_assigned[i]		<=	1'b1;
				port_sel_rd_en_reg[i]	<=	1'b0;
				port_sel_wr_en_reg[i]	<=	1'b0;
//				candidate_ivc_reg[i]		<=	1'b0;
				ivc_granted_reg[i]		<=	1'b0;
//				ovc_reg[i]					<={VC_NUM_PER_PORT{1'b0}};
				ovc_bcd_reg[i]				<={VC_NUM_BCD_WIDTH{1'b0}};
				
				
				
				
			end else begin
				port_sel_rd_en_reg[i]	<=	port_sel_rd_en[i];
				port_sel_wr_en_reg[i]	<=	port_sel_wr_en[i];
	//			candidate_ivc_reg[i]		<=	candidate_ivc[i];
				ivc_granted_reg[i]		<=	ivc_granted[i];
				
				if(assign_ovc_en[i])	begin 
//					ovc_reg[i]				<=	candidate_ovc_mux_out;
					ovc_bcd_reg[i]			<= candidate_ovc_bcd_mux_out[i];
					ovc_not_assigned[i]	<=	1'b0;
				end
				if(tail_is_passed[i])begin
					ovc_not_assigned[i]	<=	1'b1;
				end
			end//else
	end//always
	
	//ovc release loop
	
	//assign ovc_release_demux_sel[i]	=  (tail_flit_out[i])? port_sel_buff_dout[i]	: {PORT_SEL_WIDTH{1'b0}};
	//assign ovc_release_mux_in[(i+1)*CANDIDATE_OVCS_WIDTH-1		:	i*CANDIDATE_OVCS_WIDTH]=ovc_release_demux_out[i];

/*
	one_hot_demux	#(
		.IN_WIDTH		(VC_NUM_PER_PORT),
		.SEL_WIDTH		(PORT_SEL_WIDTH)
		
	)
	ovc_release_demux
	(
		.demux_sel		(ovc_release_demux_sel[i]),//selectore
		.demux_in		(ovc_reg[i]),//repeated
		.demux_out		(ovc_release_demux_out[i])
	);

*/	
	
	
	end//vc_loop
	/*
	//convert candidate OVCs from one hot to bcd code
	for (i=0;	i<PORT_SEL_WIDTH;	i=i+1'b1) begin	:port_sel_loop
		one_hot_to_bcd #(
			.ONE_HOT_WIDTH	(VC_NUM_PER_PORT)
		)
		cnd_ovc_conv
		(
		.one_hot_code	(candidate_ovcs		[(i+1)*VC_NUM_PER_PORT-1 	: i*VC_NUM_PER_PORT]	),
		.bcd_code		(candidate_ovcs_bcd	[(i+1)*VC_NUM_BCD_WIDTH-1 	: i*VC_NUM_BCD_WIDTH])
		);
	end
	*/
	
	
	endgenerate
	
	
	
	
	
	//synthesis translate_off
always @(*) begin

//interface to naibour router
	
if(wr_in_en && (flit_in[`FLIT_IN_VC_LOC]=={VC_NUM_PER_PORT{1'b0}})) $display ("%d,\t   Error: a packet has been recived with no assigned VC %m",$time);

end
//synthesis translate_on
	
	
	
endmodule

