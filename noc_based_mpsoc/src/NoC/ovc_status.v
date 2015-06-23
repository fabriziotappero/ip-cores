/**********************************************************************
	File: ovc_status.v 
	
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
	The OVC status module. provide information about out put VC (input VC 
	located in neighboring routers) for input ports
	
	Info: monemi@fkegraduate.utm.my
	
	*********************************************************************/


`include "../define.v"

module ovc_status#(
	parameter VC_NUM_PER_PORT				=	4,
	parameter PORT_NUM						=	5,
	parameter BUFFER_NUM_PER_VC			=	4,
	parameter PORT_SEL_WIDTH				=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter PORT_SEL_BCD_WIDTH			=	log2(PORT_SEL_WIDTH),
	parameter VC_NUM_BCD_WIDTH				=	log2(VC_NUM_PER_PORT),
	parameter TOTAL_VC_NUM					=	VC_NUM_PER_PORT*	PORT_NUM,
	parameter PORT_ARRAY_SELECT_WIDTH	=	TOTAL_VC_NUM	*	PORT_SEL_BCD_WIDTH,
	parameter VC_ARRAY_SELECT_WIDTH		=	TOTAL_VC_NUM	*	VC_NUM_PER_PORT,
	parameter VC_BCD_ARRAY_WIDTH			=	TOTAL_VC_NUM	*	VC_NUM_BCD_WIDTH,
	parameter CANDIDATE_OVCS_WIDTH		=	VC_NUM_PER_PORT*	PORT_SEL_WIDTH,
	parameter OVC_WR_WIDTH					=	CANDIDATE_OVCS_WIDTH	,
	parameter OVC_WR_ARRAY_WIDTH			=	OVC_WR_WIDTH	*	PORT_NUM,
	parameter OVC_RLS_WIDTH					=	CANDIDATE_OVCS_WIDTH	,
	parameter OVC_RLS_ARRAY_WIDTH			=	OVC_RLS_WIDTH	*	PORT_NUM,
	parameter OVC_ALOC_WIDTH				=	CANDIDATE_OVCS_WIDTH,
	parameter OVC_ALLOC_ARRAY_WIDTH		=	OVC_ALOC_WIDTH	*	PORT_NUM,
	parameter STATUS_ARRAY_WIDTH			=	TOTAL_VC_NUM 	* 	2,
	parameter PORT_SEL_ARRAY_WIDTH		=	PORT_SEL_WIDTH	*	PORT_NUM,
	parameter CANDIDATE_OVCS_BCD_WIDTH	=	VC_NUM_BCD_WIDTH*PORT_NUM
	

)
(
	input 		[TOTAL_VC_NUM-1				:		0]	credit_in,
	input 		[PORT_ARRAY_SELECT_WIDTH-1	:		0]	port_selectors,
	input			[VC_BCD_ARRAY_WIDTH-1		:		0] ovcs_array,
	output 	 	[STATUS_ARRAY_WIDTH-1		:		0]	assigned_ovcs_status,
	input			[OVC_RLS_ARRAY_WIDTH-1		:		0]	ovc_released_array,
	input			[OVC_WR_ARRAY_WIDTH-1		:		0] ovc_write_array,
	input			[OVC_ALLOC_ARRAY_WIDTH-1	:		0]	ovc_alloc_array,
	//output		[TOTAL_VC_NUM-1				:		0]	candidate_ovc_array,
	output		[CANDIDATE_OVCS_BCD_WIDTH-1:		0]	candidate_bcd_ovc_array,
   output  reg	[PORT_NUM-1						:		0]	ovc_available_array,
	input 		[PORT_SEL_ARRAY_WIDTH-1		:		0]	ovc_alloc_in_port_array,
	output		[3									:		0]	congestion_cmp,
	input															clk,
	input															reset
);
	
	`LOG2
	//check if assigned ovc is full or not
	localparam	MUX_IN_WIDTH			=	VC_NUM_PER_PORT	*PORT_SEL_WIDTH;
	localparam	ACCUM_WIDTH				=	log2(VC_NUM_PER_PORT+1);
	
	localparam  W_VS_S	=	3;
	localparam  W_VS_N	=	2;
	localparam  E_VS_N	=	1;
	localparam  E_VS_S	=	0;
	
	
		
	
	
	wire [PORT_SEL_BCD_WIDTH-1			:	0]	port_sel_bcd	[TOTAL_VC_NUM-1	:0];
	//wire [VC_NUM_PER_PORT-1				:	0]	vc_sel	[TOTAL_VC_NUM-1	:0];
	wire [VC_NUM_BCD_WIDTH-1			:	0]	vc_sel_bcd	[TOTAL_VC_NUM-1	:0];
	wire [MUX_IN_WIDTH-1					:	0]	mux_in1	[PORT_NUM-1			:0];
	wire [TOTAL_VC_NUM-1					:	0]	full,nearly_full,has_atleast_two;
	wire [TOTAL_VC_NUM-1					:	0]	assigned_full,assigned_nearly_full;
	wire [TOTAL_VC_NUM-1					:	0]	credit_wr_en;
	wire [PORT_NUM-1						:	0]	ovc_available_array_next;
	wire [STATUS_ARRAY_WIDTH-1			:	0]	ovcs_space_status;
	wire [MUX_IN_WIDTH-1					:	0]	mux_in2	[PORT_NUM-1			:0];
	


	
	reg 	[TOTAL_VC_NUM-1			:	0] ovc_status_reg;
	wire	[TOTAL_VC_NUM-1			:	0] ovc_status_reg_next;
	wire 	[TOTAL_VC_NUM-1			:	0]	ovc_status_set;
	wire 	[TOTAL_VC_NUM-1			:	0]	ovc_status_reset;
	wire 	[TOTAL_VC_NUM-1			:	0]	free_ovcs_has_atleast_one,free_ovcs_has_atleast_two;
	wire 	[VC_NUM_PER_PORT-1		:	0] free_ovcs_has_atleast_one_per_port			[PORT_NUM-1					:0];
	wire 	[VC_NUM_PER_PORT-1		:	0] free_ovcs_has_atleast_two_per_port			[PORT_NUM-1					:0];
//	wire 	[TOTAL_VC_NUM-1			:	0]	free_ovcs_next;
	//reg 	[TOTAL_VC_NUM-1			:	0]	free_ovcs;

	//wire  [OVC_RLS_WIDTH-1			:	0] ovc_released					[PORT_NUM-1					:0];
	//wire  [CANDIDATE_OVCS_WIDTH-1	:	0] ovc_write						[PORT_NUM-1					:0];	
	//wire	[PORT_SEL_WIDTH-1			:	0] ovc_status_reset_gen			[TOTAL_VC_NUM-1			:0];
	//wire	[PORT_SEL_WIDTH-1			:	0] ovc_status_set_gen				[TOTAL_VC_NUM-1			:0];
	//wire	[PORT_SEL_WIDTH-1			:	0] credit_wr_en_gen				[TOTAL_VC_NUM-1			:0];
//	wire 	[VC_NUM_PER_PORT-1		:	0] free_ovcs_per_port			[PORT_NUM-1					:0];
	reg 	[PORT_NUM-1					:	0] available_vcs_per_port;
	wire 	[VC_NUM_PER_PORT-1		:	0] available_vcs_gen_per_port1[PORT_NUM-1					:0];
	//wire 	[VC_NUM_PER_PORT-1		:	0] available_vcs_gen_per_port2[PORT_NUM-1					:0];
	wire	[ACCUM_WIDTH-1				:	0] number_of_avb_vc				[PORT_NUM-1					:0];
	wire 	[VC_NUM_PER_PORT-1		:	0] candidate_ovc_per_port		[PORT_NUM-1					:0];
	wire 	[VC_NUM_BCD_WIDTH-1		:	0] candidate_bcd_ovc_per_port	[PORT_NUM-1					:0];
	//wire	[PORT_NUM-1					:	0] ovc_is_used;
	//wire	[PORT_SEL_WIDTH-1			:	0] ovc_is_used_gen 			[PORT_NUM-1					:0];
	//wire  [OVC_RLS_WIDTH-1			:	0]	ovc_alloc_granted				[PORT_NUM-1					:0];
	//wire	[VC_NUM_PER_PORT-1		:	0] ovc_status_set_per_port		[PORT_NUM-1					:0];
	
	wire	[PORT_SEL_WIDTH-1			:	0]	ovc_alloc_candidate			[PORT_NUM-1					:0];
	wire	[VC_NUM_PER_PORT-1		:	0] mask_candidate_per_port		[PORT_NUM-1					:0];
	wire	[PORT_NUM-1					:	0] ovc_is_candidated;
	wire	[PORT_SEL_WIDTH-1			:	0] ovc_is_cand_gen 				[PORT_NUM-1					:0];
	wire	[PORT_SEL_WIDTH-1			:	0] ovc_alloc_in_port 			[PORT_NUM-1					:0];
	wire	[PORT_NUM-1					:	0]	ovc_used_in_port;
	wire	[PORT_SEL_WIDTH-1			:	0] ovc_used_in_port_gen			[PORT_NUM-1					:0];
	wire	[PORT_NUM-1					:	0]	port_has_no_avb_vc;
	wire	[PORT_NUM-1					:	0]	port_has_one_avb_vc;
	
	
	
	assign assigned_ovcs_status						= {assigned_full,assigned_nearly_full};
	
	
	genvar i,j;
	integer k;
	generate 
		
		for(i=0;i<TOTAL_VC_NUM; i=i+1	)begin :loop1
			assign port_sel_bcd[i]	= port_selectors [(i+1)*PORT_SEL_BCD_WIDTH-1 : (i)*PORT_SEL_BCD_WIDTH];
			assign vc_sel_bcd[i]		= ovcs_array  [(i+1)*VC_NUM_BCD_WIDTH-1 : (i)*VC_NUM_BCD_WIDTH];
			/*
			ovc_st_mux #(
				.IN_WIDTH						(MUX_IN_WIDTH),
				.PORT_SEL_BCD_WIDTH	 		(PORT_SEL_BCD_WIDTH),
				.PORT_SEL_ONE_HOT_WIDTH		(PORT_SEL_WIDTH),
				.VC_ONE_HOT_WIDTH 			(VC_NUM_PER_PORT)
			)
			the_ovc_status_mux1
			(
				.mux_in			(mux_in1[(i/VC_NUM_PER_PORT)]),
				.mux_out			(assigned_full[i]),
				.port_sel_bcd	(port_sel_bcd[i]),
				.vc_one_hot		(vc_sel[i])
			);
			
			*/
		
	ovc_st_mux #(
		.IN_WIDTH			(MUX_IN_WIDTH),
		.PORT_SEL_NUM		(PORT_SEL_WIDTH), 
		.VC_NUM_PER_PORT	(VC_NUM_PER_PORT)
	)
	the_ovc_status_mux1
	(
		.mux_in			(mux_in1[(i/VC_NUM_PER_PORT)]),
		.mux_out			(assigned_full[i]),
		.port_sel_bcd	(port_sel_bcd[i]),
		.vc_num_bcd	(vc_sel_bcd[i])
	
	);
		
		
			/*
			ovc_st_mux #(
				.IN_WIDTH						(MUX_IN_WIDTH),
				.PORT_SEL_BCD_WIDTH	 		(PORT_SEL_BCD_WIDTH),
				.PORT_SEL_ONE_HOT_WIDTH		(PORT_SEL_WIDTH),
				.VC_ONE_HOT_WIDTH 			(VC_NUM_PER_PORT)
			)
			the_ovc_status_mux2
			(
				.mux_in			(mux_in2[(i/VC_NUM_PER_PORT)]),
				.mux_out			(assigned_nearly_full[i]),
				.port_sel_bcd	(port_sel_bcd[i]),
				.vc_one_hot		(vc_sel[i])
			);
		*/
		
	ovc_st_mux #(
		.IN_WIDTH			(MUX_IN_WIDTH),
		.PORT_SEL_NUM		(PORT_SEL_WIDTH), 
		.VC_NUM_PER_PORT	(VC_NUM_PER_PORT)
	)
	the_ovc_status_mux2
	(
		.mux_in			(mux_in2[(i/VC_NUM_PER_PORT)]),
		.mux_out			(assigned_nearly_full[i]),
		.port_sel_bcd	(port_sel_bcd[i]),
		.vc_num_bcd		(vc_sel_bcd[i])
	
	);
		
		
		/*
		one_hot_2sel_mux #(
			.IN_WIDTH	(MUX_IN_WIDTH),
			.SEL1_WIDTH (PORT_SEL_WIDTH), 
			.SEL2_WIDTH (VC_NUM_PER_PORT)
		)
		the_ovc_status_mux1
		(
			.mux_in	(mux_in1[(i/VC_NUM_PER_PORT)]),
			.mux_out	(assigned_full[i]),
			.sel1		(port_sel[i]),
			.sel2		(vc_sel[i])
		);
	
		if(STATUS_WIDTH==2)begin
			one_hot_2sel_mux #(
				.IN_WIDTH	(MUX_IN_WIDTH),
				.SEL1_WIDTH (PORT_SEL_WIDTH), 
				.SEL2_WIDTH (VC_NUM_PER_PORT)
			)
			the_ovc_status_mux2
			(
				.mux_in	(mux_in2[(i/VC_NUM_PER_PORT)]),
				.mux_out	(assigned_nearly_full[i]),
				.sel1		(port_sel[i]),
				.sel2		(vc_sel[i])
			);
		
	*/
	
	end//for i
	
	
	
	for(i=0;i<PORT_NUM;i=i+1)begin : loop2
			for(j=0;j<PORT_NUM;j=j+1)begin : loop3
				if(i>j)begin
						assign mux_in1[i][(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT]			= full[(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT];
						assign mux_in2[i][(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT]			= nearly_full[(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT];
				end else if(i<j) begin 
						assign mux_in1[i][(j)*VC_NUM_PER_PORT-1	:	(j-1)*VC_NUM_PER_PORT]		= full[(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT];
						assign mux_in2[i][(j)*VC_NUM_PER_PORT-1	:	(j-1)*VC_NUM_PER_PORT]		= nearly_full[(j+1)*VC_NUM_PER_PORT-1	:	j*VC_NUM_PER_PORT];
				end
			end//for j
	end//for i
	endgenerate
	
	//ovc_credit_check
	ovc_credit_check #(
		.VC_NUM_PER_PORT			(VC_NUM_PER_PORT),
		.PORT_NUM					(PORT_NUM),
		.BUFFER_NUM_PER_VC		(BUFFER_NUM_PER_VC)
	)
	credit_checker
	(
		.credit_in					(credit_in),
		.credit_write_en			(credit_wr_en),
		.full							(full),
		.nearly_full				(nearly_full),
		.has_atleast_two			(has_atleast_two),
		.clk							(clk),
		.reset						(reset)
	);
	
	//vc allocation
	
	assign free_ovcs_has_atleast_one		=	(~ovc_status_reg    &	~nearly_full);
	assign free_ovcs_has_atleast_two		=	(~ovc_status_reg 	  &	has_atleast_two);
	
	
	
	
	
	generate
		
			
		
		
		for(i=0;i<PORT_NUM; i=i+1	)begin : total_vc_loop3_2
			//assign available_vcs_per_port[i]			=	available_vcs_gen_per_port2[i] == 0
				/*
				always @(*)begin 
					for(k=0;k<VC_NUM_PER_PORT;k=k+1'b1) begin 
						if(k==0)	 	number_of_avb_vc[i] 	=	available_vcs_gen_per_port2[i][0];
						else 			number_of_avb_vc[i]	=	number_of_avb_vc[i]	+	available_vcs_gen_per_port2[i][k];
					end
				end
				*/
				
				//always @(*)  number_of_avb_vc[i]	=	available_vcs_gen_per_port2[i][0]+available_vcs_gen_per_port2[i][1]+available_vcs_gen_per_port2[i][2]+available_vcs_gen_per_port2[i][3];
				
				set_bits_counter #(
					.IN_WIDTH (VC_NUM_PER_PORT)
				) adder
				(
					.in	(free_ovcs_has_atleast_two_per_port[i]),
					.out	(number_of_avb_vc[i])
				);
				
				
				
				assign port_has_no_avb_vc[i]			=	number_of_avb_vc[i] == 0;
				assign port_has_one_avb_vc[i]			=	number_of_avb_vc[i] == 1;
				
			
				
			always @(*)begin
				available_vcs_per_port[i]		=1'b1;
				if(port_has_no_avb_vc[i]) 	  available_vcs_per_port[i]= 1'b0;
				if(port_has_one_avb_vc[i])   available_vcs_per_port[i]= !ovc_used_in_port[i];
			end	
		
		end
		
	
		
		
	endgenerate
	
	   
		assign congestion_cmp[W_VS_S] = number_of_avb_vc[`WEST_PORT] >= number_of_avb_vc[`SOUTH_PORT]; 
		assign congestion_cmp[W_VS_N] = number_of_avb_vc[`WEST_PORT] >= number_of_avb_vc[`NORTH_PORT];
		assign congestion_cmp[E_VS_N] = number_of_avb_vc[`EAST_PORT] >= number_of_avb_vc[`NORTH_PORT];
		assign congestion_cmp[E_VS_S] = number_of_avb_vc[`EAST_PORT] >= number_of_avb_vc[`SOUTH_PORT];
		
	
	wide_or #(
		.IN_ARRAY_WIDTH 	(OVC_RLS_ARRAY_WIDTH), 
		.IN_NUM	 			(PORT_NUM)
	)
	busy_reset
	(
		.in	(ovc_released_array),
		.out	(ovc_status_reset)
	);
	
	wide_or #(
		.IN_ARRAY_WIDTH 	(OVC_WR_ARRAY_WIDTH),
		.IN_NUM	 			(PORT_NUM)
	)
	credit_wr
	(
		.in	(ovc_write_array),
		.out	(credit_wr_en)
	);
	
	
	wide_or #(
		.IN_ARRAY_WIDTH 	(OVC_ALLOC_ARRAY_WIDTH),
		.IN_NUM	 			(PORT_NUM)
	)
	 busy_set
	(
		.in	(ovc_alloc_array),
		.out	(ovc_status_set)
	);
	
	
	wide_or #(
		.IN_ARRAY_WIDTH 	(PORT_SEL_ARRAY_WIDTH),
		.IN_NUM	 			(PORT_NUM)
	)
	 ovc_alloc_in_port_gen
	(
		.in	(ovc_alloc_in_port_array),
		.out	(ovc_used_in_port)
	);
	
	
	generate 
		
	
		for(i=0;i<TOTAL_VC_NUM; i=i+1	)begin :TOTAL_VC_NUM_loop
			//assign ovc_status_reg_next[i]	=	(ovc_status_reg[i] | ovc_status_set [i]) & ~ovc_status_reset[i];
			assign ovc_status_reg_next[i]	=	(ovc_status_set [i])? 1'b1: (ovc_status_reset[i])? 1'b0 : (ovc_status_reg[i]) ;
			always@(posedge clk or posedge reset)begin
				if(reset)begin
					ovc_status_reg[i]	<=1'b0;
					//free_ovcs[i]		<= 1'b0;               
				end else begin
					ovc_status_reg[i]			<=	ovc_status_reg_next[i];
				//	free_ovcs[i]				<= free_ovcs_next[i];
				end//reset
			end//always
		end //for
		
			
		
		
		for(i=0;i<PORT_NUM; i=i+1	)begin : port_loop
			//assign ovc_released[i] 				= ovc_released_array			[(i+1)*CANDIDATE_OVCS_WIDTH-1		:	i*CANDIDATE_OVCS_WIDTH]	;
			//assign ovc_write[i]					= ovc_write_array				[(i+1)*CANDIDATE_OVCS_WIDTH-1		:	i*CANDIDATE_OVCS_WIDTH]	;
			assign free_ovcs_has_atleast_one_per_port[i] 		= free_ovcs_has_atleast_one						[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT];
			assign free_ovcs_has_atleast_two_per_port[i] 		= free_ovcs_has_atleast_two						[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT];
			//assign ovc_status_set_per_port[i]	= ovc_status_set 				[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT];	
			//assign ovc_alloc_in_port[i]		= ovc_alloc_in_port_array	[(i+1)*PORT_SEL_WIDTH-1				:	i*PORT_SEL_WIDTH];
			
			//assign available_vcs_gen_per_port1[i] = free_ovcs_gen		[(i+1)*VC_NUM_PER_PORT-1			:	i*VC_NUM_PER_PORT];
			//assign ovc_available_array_next[i]  = |available_vcs_per_port[i];
			//assign candidate_ovc_array			[(i+1)*VC_NUM_PER_PORT-1		:	i*VC_NUM_PER_PORT]	= candidate_ovc_per_port[i];
			assign candidate_bcd_ovc_array	[(i+1)*VC_NUM_BCD_WIDTH-1		:	i*VC_NUM_BCD_WIDTH]	= candidate_bcd_ovc_per_port[i];
			
			//assign ovc_is_used[i]	= |  ovc_is_used_gen[i];	
			
			
			
			always@(posedge clk or posedge reset)begin
				if(reset)begin
					ovc_available_array[i]	<=	1'b0;
				end else begin
					ovc_available_array[i]	<=	available_vcs_per_port[i];
				
				end//reset
			end//always
		
			//bcd round robin arbiter
	bcd_arbiter #(
		.ARBITER_WIDTH	(VC_NUM_PER_PORT)
	)
	free_ovc_arbiter
	(
		.request 		(free_ovcs_has_atleast_one_per_port[i]),
		.grant			(candidate_bcd_ovc_per_port[i]),
		.any_grant		(),
		.clk				(clk),
		.reset			(reset)
	);
			
	/*		
			fixed_arbiter#(
				.ARBITER_WIDTH		(VC_NUM_PER_PORT)
			)
			free_vc_arbiter
			(
				.request				(free_ovcs_has_atleast_one_per_port[i]), 
				.grant				(candidate_ovc_per_port[i])
			);
		*/
		end 
		
		
		
	endgenerate
	
endmodule



/***********************************************

			ovc_credit_check 
	
***********************************************/

module ovc_credit_check #(
	parameter VC_NUM_PER_PORT				=	4,
	parameter PORT_NUM						=	5,
	parameter BUFFER_NUM_PER_VC			=	4,
	parameter PORT_SEL_WIDTH				=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter TOTAL_VC_NUM					=	VC_NUM_PER_PORT*PORT_NUM,
	parameter STATUS_ARRAY_WIDTH			=	TOTAL_VC_NUM * 2
)
(
	input 		[TOTAL_VC_NUM-1				:		0]	credit_in,
	input			[TOTAL_VC_NUM-1				:		0] credit_write_en,
	output reg	[TOTAL_VC_NUM-1				:		0] full,
	output reg	[TOTAL_VC_NUM-1				:		0] nearly_full,
	output reg	[TOTAL_VC_NUM-1				:		0] has_atleast_two,
	input															clk,
	input															reset
);

	`LOG2
	localparam 	BUFF_WIDTH	=	log2(BUFFER_NUM_PER_VC);
	reg 	[BUFF_WIDTH				:	0]	depth 		[TOTAL_VC_NUM-1	:	0];
	reg 	[BUFF_WIDTH				:	0]	depth_next 	[TOTAL_VC_NUM-1	:	0];
	reg	[TOTAL_VC_NUM-1		:	0]	full_next,nearly_full_next,has_atleast_two_next;
	
	genvar i;
	generate 
	for(i=0;i<TOTAL_VC_NUM;i=i+1) begin : totalvc_loop
		always@(*)begin
			depth_next[i] = depth[i];
			if(  credit_write_en[i]	&& ~credit_in[i])	depth_next[i] = depth[i]+1'b1;
			if( ~credit_write_en[i]	&&  credit_in[i])	depth_next[i] = depth[i]-1'b1;
		end//always
	
		always@(*)begin
			full_next[i] 			= (depth_next[i] 	== BUFFER_NUM_PER_VC		)	?  1'b1 :1'b0; 
			nearly_full_next[i] = ((depth_next[i] == BUFFER_NUM_PER_VC-1)| full_next[i])	?	1'b1 :1'b0; 
			has_atleast_two_next[i]= (depth_next[i] < BUFFER_NUM_PER_VC-1	)? 1'b1 :1'b0; 
		end
		
		always@(posedge clk or posedge reset)begin
			if(reset)begin
				depth	[i]				<={(BUFF_WIDTH+1){1'b0}};
				full	[i] 				<= 1'b0;
				nearly_full[i] 		<=	1'b0; 
				has_atleast_two[i]	<= 1'b1;
			end else begin
				depth	[i]				<=	depth_next[i];
				full	[i] 				<= full_next[i];
				nearly_full[i] 		<=	nearly_full_next[i]; 
				has_atleast_two[i]	<= has_atleast_two_next[i];
			end //reset
		end//always
	end//for
	
		
	endgenerate
		
	// synthesis translate_off
	generate
	for(i=0;i<TOTAL_VC_NUM;i=i+1) begin :test_bench_loop
	 always @(posedge clk )
	 begin
		if (credit_write_en[i] && depth[i] == BUFFER_NUM_PER_VC && !credit_in[i])
			$display($time, " ERROR: Attempt to send flit to full ovc: %m");
		if (credit_in[i] && depth[i] == 'h0)
			$display($time, " ERROR: unexpected credit recived for empty ovc: %m");
	 end//always
	end//for
	endgenerate
	// synthesis translate_on
	
endmodule








 
