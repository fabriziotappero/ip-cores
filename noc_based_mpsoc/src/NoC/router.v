/**********************************************************************
	File: router.v 
	
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
	The NoC router  

	Info: monemi@fkegraduate.utm.my

******************************************************/


`include "../define.v"



module router#(
	parameter TOPOLOGY					=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT				=	"XY",		//"XY" or "MINIMAL"
	parameter VC_NUM_PER_PORT			=	2,
	parameter BUFFER_NUM_PER_VC		=	4,
	parameter PORT_NUM					=	5,
	parameter PYLD_WIDTH 				=	32,
	parameter FLIT_TYPE_WIDTH			=	2,
	parameter X_NODE_NUM					=	4,
	parameter Y_NODE_NUM					=	3,
	parameter SW_X_ADDR					=	2,
	parameter SW_Y_ADDR					=	1,
	parameter SW_OUTPUT_REGISTERED	=	0,// 1: registered , 0 not registered
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter VC_ID_WIDTH				=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH					=	PYLD_WIDTH+ FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter FLIT_ARRAY_WIDTH			=	FLIT_WIDTH 			*	PORT_NUM,
	parameter CREDIT_ARRAY_WIDTH		=	VC_NUM_PER_PORT	*	PORT_NUM,
	parameter VC_FULL_WIDTH				=  VC_NUM_PER_PORT	*	2,
	parameter CONGESTION_WIDTH			=	8

	
	)
	(
	input	[PORT_NUM-1					:	0]		wr_in_en_array,
	input [FLIT_ARRAY_WIDTH-1		:	0]		flit_in_array,
	output[CREDIT_ARRAY_WIDTH-1	:	0]		credit_out_array,
	output[PORT_NUM-1					:	0]		wr_out_en_array,
	output[FLIT_ARRAY_WIDTH-1		:	0]		flit_out_array,
	input [CREDIT_ARRAY_WIDTH-1	:	0]		credit_in_array,
	output[CONGESTION_WIDTH-1		:	0]		congestion_cmp_o,
	input [CONGESTION_WIDTH-1		:	0]		congestion_cmp_i,
	input												clk,
	input												reset
	);

	`LOG2
	localparam PORT_SEL_BCD_WIDTH				=	log2(PORT_SEL_WIDTH);
	localparam PORT_NUM_BCD_WIDTH				= 	log2(PORT_NUM);
	localparam VC_NUM_BCD_WIDTH				=	log2(VC_NUM_PER_PORT);
	localparam LOCAL_PORT_NUM					=	0;
	localparam X_NODE_NUM_WIDTH				=	log2(X_NODE_NUM);
	localparam Y_NODE_NUM_WIDTH				=	log2(Y_NODE_NUM);
	localparam TOTAL_VC_NUM						=	VC_NUM_PER_PORT		*	PORT_NUM;
	localparam CANDIDATE_OVCS_WIDTH			=	VC_NUM_PER_PORT		*	PORT_SEL_WIDTH;
	localparam OUTPUTPORT_SEL_WIDTH			=	VC_NUM_PER_PORT		*	PORT_SEL_BCD_WIDTH;
	localparam ALLOC_PORT_CAND_WIDTH			=	PORT_SEL_WIDTH			*	PORT_NUM;
	localparam OVCS_WIDTH						=	VC_NUM_PER_PORT		*	VC_NUM_PER_PORT;
	localparam PORT_ARRAY_SELECT_WIDTH		=	TOTAL_VC_NUM			*	PORT_SEL_BCD_WIDTH;
	//localparam VC_ARRAY_SELECT_WIDTH			=	TOTAL_VC_NUM			*	VC_NUM_PER_PORT;
	localparam VC_BCD_ARRAY_WIDTH				=	TOTAL_VC_NUM			*	VC_NUM_BCD_WIDTH;
	
	localparam LOOK_AHEAD_ARRAY_WIDTH		=	PORT_NUM_BCD_WIDTH	*	PORT_NUM;
	localparam PORT_SEL_ARRAY_WIDTH			=	PORT_SEL_WIDTH			*	PORT_NUM;
	localparam OVC_WR_WIDTH						=	CANDIDATE_OVCS_WIDTH	;
	localparam OVC_WR_ARRAY_WIDTH				=	OVC_WR_WIDTH			*	PORT_NUM;
	localparam OVC_RLS_WIDTH					=	CANDIDATE_OVCS_WIDTH	;
	localparam OVC_RLS_ARRAY_WIDTH			=	OVC_RLS_WIDTH			*	PORT_NUM;
	localparam OVC_ALOC_WIDTH					=	CANDIDATE_OVCS_WIDTH;
	localparam OVC_ALLOC_ARRAY_WIDTH			=	OVC_ALOC_WIDTH			*	PORT_NUM;
	localparam STATUS_WIDTH_PER_SW			=	VC_NUM_PER_PORT		*	2;
	localparam STATUS_ARRAY_WIDTH				=	TOTAL_VC_NUM 			*	2;
	localparam OVCS_BCD_WIDTH					=	VC_NUM_BCD_WIDTH		*	VC_NUM_PER_PORT;
	localparam ST_CAND_OVCS_BCD_WIDTH		=	VC_NUM_BCD_WIDTH		*	PORT_NUM;
	localparam SW_CAND_OVCS_BCD_WIDTH		=	VC_NUM_BCD_WIDTH		*	PORT_SEL_WIDTH;
	
	wire [PORT_NUM-1							:0]	sw_wr_in_en;
	wire [PORT_NUM-1							:0]	sw_any_vc_granted;
	wire [X_NODE_NUM_WIDTH-1				:0]	sw_dest_x_addr					[PORT_NUM-1					:	0];
	wire [Y_NODE_NUM_WIDTH-1				:0]	sw_dest_y_addr					[PORT_NUM-1					:	0];
	wire [PORT_NUM_BCD_WIDTH-1				:0]	sw_in_port_num					[PORT_NUM-1					:	0];
	wire [FLIT_WIDTH-1						:0]	sw_flit_in						[PORT_NUM-1					:	0];
	wire [VC_NUM_PER_PORT-1					:0]	sw_credit_out					[PORT_NUM-1					:	0];
	wire [FLIT_WIDTH-1						:0]	sw_flit_out						[PORT_NUM-1					:	0];
	wire [VC_NUM_PER_PORT-1					:0]	sw_ovc							[PORT_NUM-1					:	0];
	wire [VC_NUM_BCD_WIDTH-1				:0]	sw_ovc_bcd						[PORT_NUM-1					:	0];
	wire [OUTPUTPORT_SEL_WIDTH-1			:0]	sw_out_port_select			[PORT_NUM-1					:	0];
	wire [PORT_NUM_BCD_WIDTH-1				:0]	sw_look_ahead_port_sel_out [PORT_NUM-1					:	0];	
	wire [PORT_NUM_BCD_WIDTH-1				:0]	sw_look_ahead_port_sel_in	[PORT_NUM-1					:	0];	
	wire [VC_NUM_PER_PORT-1					:0]	sw_ivc_request					[PORT_NUM-1					:	0];	
	wire [VC_NUM_PER_PORT-1					:0]	sw_ivc_granted					[PORT_NUM-1					:	0];	
	wire [VC_NUM_PER_PORT-1					:0]	sw_candidate_ivc				[PORT_NUM-1					:	0];
	//wire [PORT_SEL_WIDTH-1				:0]	sw_candidate_port				[PORT_NUM-1					:	0];
	wire [VC_NUM_PER_PORT-1					:0]	sw_assigned_ovc_not_full	[PORT_NUM-1					:	0];
	//wire [CANDIDATE_OVCS_WIDTH-1		:0] 	sw_candidate_ovcs				[PORT_NUM-1					:	0];
	wire [SW_CAND_OVCS_BCD_WIDTH-1		:0] 	sw_candidate_bcd_ovcs		[PORT_NUM-1					:	0];
	wire [OVCS_BCD_WIDTH-1					:0]	sw_ovcs							[PORT_NUM-1					:	0];	
	wire [PORT_SEL_WIDTH-1					:0]	sw_ovc_available				[PORT_NUM-1					:	0];
	wire [OVC_RLS_WIDTH-1					:0]	sw_ovc_released				[PORT_NUM-1					:	0];
	wire [OVC_WR_WIDTH-1						:0]	sw_ovc_write					[PORT_NUM-1					:	0];
	wire [OVC_ALOC_WIDTH-1					:0]	sw_vc_alloc						[PORT_NUM-1					:	0];
	wire [VC_NUM_PER_PORT-1					:0]	sw_assigned_ovcs_status1	[PORT_NUM-1					:	0];
	wire [STATUS_WIDTH_PER_SW-1			:0]	sw_assigned_ovcs_status		[PORT_NUM-1					:	0];
	wire [PORT_SEL_WIDTH-1					:0]	sw_granted_port 				[PORT_NUM-1					:	0];
	wire [PORT_SEL_WIDTH-1					:0]	sw_ovc_alloc_in_port			[PORT_NUM-1					:	0];

	wire [X_NODE_NUM_WIDTH-1				:0]	lk_dest_x_addr					[PORT_NUM-1					:	0];
	wire [Y_NODE_NUM_WIDTH-1				:0]	lk_dest_y_addr					[PORT_NUM-1					:	0];
	wire [PORT_NUM_BCD_WIDTH-1				:0]	lk_port_sel_out				[PORT_NUM-1					:	0];	
	wire [CONGESTION_WIDTH-1				:0]	lk_congestion_cmp				[PORT_NUM-1					:	0];	
	wire [PORT_NUM_BCD_WIDTH-1				:0]	lk_in_port_num					[PORT_NUM-1					:	0];	
	
	wire [FLIT_WIDTH-1						:0]	ou_flit_in						[PORT_NUM-1					:	0];
	wire [FLIT_WIDTH-1						:0]	ou_flit_out						[PORT_NUM-1					:	0];
	wire [PORT_NUM-1							:0]	ou_in_wr_en;
	wire [PORT_NUM-1							:0]	ou_out_wr_en;
	
	wire [PORT_ARRAY_SELECT_WIDTH-1		:0]	al_port_selects_array;
	wire [TOTAL_VC_NUM-1						:0]	al_ivc_reguest;
	wire [TOTAL_VC_NUM-1						:0]	al_ivc_granted;
	wire [TOTAL_VC_NUM-1						:0]	al_candidate_ivc;
	//wire [ALLOC_PORT_CAND_WIDTH-1			:0]	al_candidate_port;
	wire [PORT_NUM-1							:0]	al_any_vc_granted_array;
	wire [ALLOC_PORT_CAND_WIDTH-1			:0]	al_crossbar_granted_port_array,al_isw_granted_port_array;
	wire [PORT_NUM-1							:0]	al_out_port_wr_en_array;

	wire [TOTAL_VC_NUM-1						:0]	st_credit_in;
	wire [PORT_ARRAY_SELECT_WIDTH-1		:0]	st_port_selectors;
	wire [VC_BCD_ARRAY_WIDTH-1				:0] 	st_ovcs_array;
	wire [STATUS_ARRAY_WIDTH-1				:0]	st_assigned_ovcs_status;
//	wire [TOTAL_VC_NUM-1						:0]	st_candidate_ovc_array;
	wire [ST_CAND_OVCS_BCD_WIDTH-1		:0]	st_candidate_bcd_ovc_array;
	wire [PORT_NUM-1							:0]	st_ovc_available_array;
	wire [OVC_RLS_ARRAY_WIDTH-1			:0]	st_ovc_released_array;
	wire [OVC_WR_ARRAY_WIDTH-1				:0]	st_ovc_write_array;
	wire [OVC_ALLOC_ARRAY_WIDTH-1			:0]	st_vc_alloc_array;
	wire [PORT_SEL_ARRAY_WIDTH-1			:0]	st_ovc_alloc_in_port_array;
	wire [3										:0]	st_congestion_cmp;
	
	wire [LOOK_AHEAD_ARRAY_WIDTH-1		:0]	cr_look_ahead_port_sel_array;
	wire [PORT_SEL_ARRAY_WIDTH-1			:0]	cr_port_sel_array;
	wire [FLIT_ARRAY_WIDTH-1				:0]	cr_flit_in_array;
	wire [TOTAL_VC_NUM-1						:0]	cr_ovc_array;
	wire [FLIT_ARRAY_WIDTH-1				:0]	cr_flit_out_array;
	wire [VC_NUM_PER_PORT-1					:0]	sw_assigned_ovcs_status2	[PORT_NUM-1					:	0];
	
	
	//switch allocatore
	sw_sep_alloc #(
		.VC_NUM_PER_PORT				(VC_NUM_PER_PORT),
		.PORT_NUM						(PORT_NUM)
		
	)
	switch_allocatore
	(
		.port_selects_array				(al_port_selects_array),
		.in_vc_requests_array			(al_ivc_reguest),
		.candidate_in_vc_array			(al_candidate_ivc),
		.candidate_port_array			(),
		.in_vc_granted_array				(al_ivc_granted),
		.any_vc_granted_array			(al_any_vc_granted_array),
		.crossbar_granted_port_array	(al_crossbar_granted_port_array),
		.isw_granted_port_array			(al_isw_granted_port_array),
		.out_port_wr_en_array			(al_out_port_wr_en_array),
		.clk									(clk),
		.reset								(reset)
	);

	// ovc_status
	ovc_status#(
		.VC_NUM_PER_PORT				(VC_NUM_PER_PORT),
		.PORT_NUM						(PORT_NUM),
		.BUFFER_NUM_PER_VC			(BUFFER_NUM_PER_VC)
		
	)
	output_VC_status
	(
		.credit_in						(st_credit_in),
		.port_selectors				(st_port_selectors),
		.ovcs_array						(st_ovcs_array),
		.assigned_ovcs_status		(st_assigned_ovcs_status),
		.ovc_released_array			(st_ovc_released_array),
		.ovc_write_array				(st_ovc_write_array),
		.ovc_alloc_array				(st_vc_alloc_array),
		//.candidate_ovc_array			(st_candidate_ovc_array),
		.candidate_bcd_ovc_array	(st_candidate_bcd_ovc_array),
		.ovc_available_array			(st_ovc_available_array),
		.ovc_alloc_in_port_array	(st_ovc_alloc_in_port_array),
		.congestion_cmp				(st_congestion_cmp),
		.clk								(clk),
		.reset							(reset)
	);
	
	//cross_bar 
	cross_bar #(
		.VC_NUM_PER_PORT				(VC_NUM_PER_PORT),
		.X_NODE_NUM						(X_NODE_NUM),
		.Y_NODE_NUM						(Y_NODE_NUM),
		.PORT_NUM						(PORT_NUM),
		.PYLD_WIDTH 					(PYLD_WIDTH),
		.FLIT_TYPE_WIDTH				(FLIT_TYPE_WIDTH)
	)
	the_cross_bar
	(
		.look_ahead_port_sel_array	(cr_look_ahead_port_sel_array),
		.port_sel_array				(cr_port_sel_array),
		.flit_in_array					(cr_flit_in_array),
		.ovc_array						(cr_ovc_array),
		.flit_out_array				(cr_flit_out_array)
	);	

	assign sw_wr_in_en					=	wr_in_en_array;
	assign st_credit_in					=  credit_in_array;
	assign cr_port_sel_array			= 	al_crossbar_granted_port_array;
	assign ou_in_wr_en					=	al_out_port_wr_en_array;
	assign wr_out_en_array				=	ou_out_wr_en;
	assign sw_any_vc_granted   		=	al_any_vc_granted_array;
	
	genvar i,j;
	generate 
	for(i=0;i< PORT_NUM; i=i+1) begin : port_loop
		
		assign sw_flit_in			[i]			=	flit_in_array					[(i+1)*FLIT_WIDTH-1			:	i*FLIT_WIDTH		];
		assign sw_ivc_granted	[i]			=	al_ivc_granted 				[(i+1)*VC_NUM_PER_PORT-1	:	i*VC_NUM_PER_PORT	];
		assign sw_candidate_ivc	[i]			=  al_candidate_ivc				[(i+1)*VC_NUM_PER_PORT-1	:	i*VC_NUM_PER_PORT	];
		//assign sw_candidate_port[i]			=  al_candidate_port				[(i+1)*PORT_SEL_WIDTH-1		:	i*PORT_SEL_WIDTH	];
		assign sw_assigned_ovcs_status1[i]	=	st_assigned_ovcs_status		[(i+1)*VC_NUM_PER_PORT-1	:	i*VC_NUM_PER_PORT	];
		assign sw_look_ahead_port_sel_in[i] = 	lk_port_sel_out[i];
		assign sw_granted_port[i]				=  al_isw_granted_port_array  [(i+1)*PORT_SEL_WIDTH-1		:	i*PORT_SEL_WIDTH	];
		
		assign lk_dest_x_addr[i]				=	sw_dest_x_addr[i];
		assign lk_dest_y_addr[i]				=	sw_dest_y_addr[i];
		assign lk_congestion_cmp[i]			=	congestion_cmp_i;
		assign lk_in_port_num[i]				=	sw_in_port_num[i];
		assign ou_flit_in[i]						=	cr_flit_out_array				[(i+1)*FLIT_WIDTH-1			:	i*FLIT_WIDTH];
		
		assign credit_out_array					[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT			]	= 	sw_credit_out		[i];
		assign al_port_selects_array			[(i+1)*OUTPUTPORT_SEL_WIDTH-1		:	i*OUTPUTPORT_SEL_WIDTH	]	=	sw_out_port_select[i];
		assign al_ivc_reguest					[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT		 	]	=	sw_ivc_request		[i];
		
		assign st_port_selectors				[(i+1)*OUTPUTPORT_SEL_WIDTH-1		:	i*OUTPUTPORT_SEL_WIDTH	]	=	sw_out_port_select[i];
		assign st_ovcs_array						[(i+1)*OVCS_BCD_WIDTH-1				:	i*OVCS_BCD_WIDTH			]	=	sw_ovcs[i];
		assign st_ovc_released_array			[(i+1)*OVC_RLS_WIDTH-1				:	i*OVC_RLS_WIDTH			]	=	sw_ovc_released[i];
		assign st_ovc_write_array				[(i+1)*OVC_WR_WIDTH-1				:	i*OVC_WR_WIDTH				]	=	sw_ovc_write[i];
		assign st_vc_alloc_array				[(i+1)*OVC_ALOC_WIDTH-1				:	i*OVC_ALOC_WIDTH			]	=	sw_vc_alloc[i];
		assign st_ovc_alloc_in_port_array	[(i+1)*PORT_SEL_WIDTH-1				:	i*PORT_SEL_WIDTH			]	=	sw_ovc_alloc_in_port[i];
		
		assign cr_ovc_array						[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT			]	=	sw_ovc[i];
		assign cr_look_ahead_port_sel_array	[(i+1)*PORT_NUM_BCD_WIDTH-1		:	i*PORT_NUM_BCD_WIDTH		]	=	sw_look_ahead_port_sel_out[i];
		assign cr_flit_in_array					[(i+1)*FLIT_WIDTH-1					:	i*FLIT_WIDTH				]	=	sw_flit_out[i];
		assign flit_out_array					[(i+1)*FLIT_WIDTH-1					:	i*FLIT_WIDTH				]	=	ou_flit_out[i];
		
		
		assign sw_assigned_ovcs_status2[i]	=	st_assigned_ovcs_status		[TOTAL_VC_NUM+((i+1)*VC_NUM_PER_PORT)-1	:	TOTAL_VC_NUM+(i*VC_NUM_PER_PORT)];
		assign sw_assigned_ovcs_status[i]	=	{sw_assigned_ovcs_status2[i],sw_assigned_ovcs_status1[i]};	
		
		
		
			switch_in #(
				.SWITCH_LOCATION			(i),
				.VC_NUM_PER_PORT			(VC_NUM_PER_PORT),
				.PORT_NUM					(PORT_NUM),	
				.PYLD_WIDTH 				(PYLD_WIDTH),
				.BUFFER_NUM_PER_VC		(BUFFER_NUM_PER_VC),
				.FLIT_TYPE_WIDTH			(FLIT_TYPE_WIDTH),
				.X_NODE_NUM					(X_NODE_NUM),
				.Y_NODE_NUM					(Y_NODE_NUM),
				.SW_X_ADDR					(SW_X_ADDR),
				.SW_Y_ADDR					(SW_Y_ADDR),
				.ENABLE_MIN_DEPTH_OUT	(0)
			)
			the_switch_in
			(
			//interface to the naibour router
				.flit_in						(sw_flit_in[i]),   
				.wr_in_en					(sw_wr_in_en[i]),
				.credit_out					(sw_credit_out[i]),
					
			//interface to the cross bar
				.flit_out					(sw_flit_out[i]),
				.ovc							(sw_ovc_bcd[i]),
				.look_ahead_port_sel_out(sw_look_ahead_port_sel_out[i]),	
			
			//interface to OVC status
				.assigned_ovcs_status	(sw_assigned_ovcs_status[i]),
				//.candidate_ovcs			(sw_candidate_ovcs[i]),
				.candidate_bcd_ovcs		(sw_candidate_bcd_ovcs[i]),
				.ovc_allocated				(sw_vc_alloc[i]),
				.ovcs							(sw_ovcs[i]),
				.ovc_available				(sw_ovc_available[i]),
				.ovc_released				(sw_ovc_released[i]),
				.ovc_write_granted		(sw_ovc_write[i]),
				.ovc_alloc_in_port		(sw_ovc_alloc_in_port[i]),
			
			//interface to switch allocator
				.ivc_request				(sw_ivc_request[i]),
				.ivc_granted				(sw_ivc_granted[i]),
				.out_port_select			(sw_out_port_select[i]),
				.candidate_ivc				(sw_candidate_ivc[i]),
				//.candidate_port			(sw_candidate_port[i]),
				.any_vc_granted			(sw_any_vc_granted[i]),
				.granted_port				(sw_granted_port[i]),
			
			//interface to look over head routing module
				.dest_x_addr				(sw_dest_x_addr[i]),
				.dest_y_addr				(sw_dest_y_addr[i]),
				.in_port_num				(sw_in_port_num[i]),
				.look_ahead_port_sel_in	(sw_look_ahead_port_sel_in[i]),	
			
			//global
				.reset						(reset),
				.clk							(clk)
			
			);
	
		
		//look ahead routing module
		look_ahead_routing_sync #(
			.TOPOLOGY					(TOPOLOGY),
			.ROUTE_ALGRMT				(ROUTE_ALGRMT),	
			.PORT_NUM					(PORT_NUM),
			.X_NODE_NUM					(X_NODE_NUM),
			.Y_NODE_NUM					(Y_NODE_NUM),	
			.SW_X_ADDR					(SW_X_ADDR),
			.SW_Y_ADDR					(SW_Y_ADDR)
		
		)
		the_look_ahead_routing
		(
			.congestion_cmp_i			(lk_congestion_cmp[i]),
			.dest_x_node_in			(lk_dest_x_addr[i]),
			.dest_y_node_in			(lk_dest_y_addr[i]),
			.in_port_num_i				(lk_in_port_num[i]),
			.port_num_out				(lk_port_sel_out[i]),
			.clk							(clk),
			.reset						(reset)
		);
	
		//switch_out	
		sw_out#(
			.VC_NUM_PER_PORT			(VC_NUM_PER_PORT),
			.PORT_NUM					(PORT_NUM),
			.PYLD_WIDTH 				(PYLD_WIDTH),
			.FLIT_TYPE_WIDTH			(FLIT_TYPE_WIDTH),
			.SW_OUTPUT_REGISTERED	(SW_OUTPUT_REGISTERED) // 1: registered , 0 not registered
		)
		switch_out
		(
			.in_wr_en					(ou_in_wr_en[i]),
			.flit_in						(ou_flit_in[i]),
			.out_wr_en					(ou_out_wr_en[i]),
			.flit_out					(ou_flit_out[i]),
			.clk							(clk),
			.reset						(reset)
		);
		
	bcd_to_one_hot #(
		.BCD_WIDTH			(VC_NUM_BCD_WIDTH),
		.ONE_HOT_WIDTH		(VC_NUM_PER_PORT)	
	)
	conv
	(
		.bcd_code		(sw_ovc_bcd[i]),
		.one_hot_code	(sw_ovc[i])
	 );
	
	localparam  W_VS_S	=	3;
	localparam  W_VS_N	=	2;
	localparam  E_VS_N	=	1;
	localparam  E_VS_S	=	0;
	
		assign congestion_cmp_o = {st_congestion_cmp[W_VS_N],st_congestion_cmp[E_VS_N], //to the S
											st_congestion_cmp[E_VS_N],st_congestion_cmp[E_VS_S], //to the W
											st_congestion_cmp[W_VS_S],st_congestion_cmp[E_VS_S], //to the N
											st_congestion_cmp[W_VS_N],st_congestion_cmp[W_VS_S]  //to the E
											};
											
											
		
		
		
		for(j=0;j<PORT_NUM;j=j+1)begin : port_loop2
			if(i>j)begin 
			//	assign sw_candidate_ovcs		[i][(j+1)*VC_NUM_PER_PORT-1		:	j*VC_NUM_PER_PORT]		= st_candidate_ovc_array		[(j+1)*VC_NUM_PER_PORT-1		:	j*VC_NUM_PER_PORT	];
				assign sw_candidate_bcd_ovcs	[i][(j+1)*VC_NUM_BCD_WIDTH-1		:	j*VC_NUM_BCD_WIDTH]		= st_candidate_bcd_ovc_array	[(j+1)*VC_NUM_BCD_WIDTH-1		:	j*VC_NUM_BCD_WIDTH];
				
				assign sw_ovc_available[i][j]	=	st_ovc_available_array[j];
			end
			else if(i<j)begin 
			//	assign sw_candidate_ovcs		[i][j*VC_NUM_PER_PORT-1			:	(j-1)*VC_NUM_PER_PORT]	= st_candidate_ovc_array			[(j+1)*VC_NUM_PER_PORT-1		:	j*VC_NUM_PER_PORT	];
				assign sw_candidate_bcd_ovcs	[i][j*VC_NUM_BCD_WIDTH-1		:	(j-1)*VC_NUM_BCD_WIDTH]	= st_candidate_bcd_ovc_array		[(j+1)*VC_NUM_BCD_WIDTH-1		:	j*VC_NUM_BCD_WIDTH];
				assign sw_ovc_available[i][j-1]	=	st_ovc_available_array[j];
			end
		end//for j
			
	end//for i

	endgenerate

	
endmodule
