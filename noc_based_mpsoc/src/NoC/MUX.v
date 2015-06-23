/**********************************************************************
	File: MUX.v 
	
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
		one hot multiplexer and demux
		conventional multiplexer (bcd sel)
		one hot to bcd converter and vise versa
		the P-1: 1 or gate for OVC status modul 
		and more small modules used in the design
		
		
	Info: monemi@fkegraduate.utm.my		

	
	***********************************************************************/


`include "../define.v"
module one_hot_mux #(
		parameter	IN_WIDTH	  =	20,
		parameter	SEL_WIDTH =   5, 
		parameter	OUT_WIDTH =	IN_WIDTH/SEL_WIDTH

	)
	(
		input [IN_WIDTH-1		:0]	mux_in,
		output[OUT_WIDTH-1	:0]	mux_out,
		input[SEL_WIDTH-1	:0]	sel

	);

	wire [IN_WIDTH-1	:0]	mask;
	wire [IN_WIDTH-1	:0]	masked_mux_in;
	wire [SEL_WIDTH-1:0]  	mux_out_gen [OUT_WIDTH-1:0]; 
	
	genvar i,j;
	
	//first selector masking
	generate 	// first_mask = {sel[0],sel[0],sel[0],....,sel[n],sel[n],sel[n]}
		for(i=0; i<SEL_WIDTH; i=i+1) begin : mask_loop
			assign mask[(i+1)*OUT_WIDTH-1 : (i)*OUT_WIDTH]	=	{OUT_WIDTH{sel[i]} };
		end
		
		assign masked_mux_in	= mux_in & mask;
		
		for(i=0; i<OUT_WIDTH; i=i+1) begin : lp1
			for(j=0; j<SEL_WIDTH; j=j+1) begin : lp2
				assign mux_out_gen [i][j]	=	masked_mux_in[i+OUT_WIDTH*j];
			end
			assign mux_out[i] = | mux_out_gen [i];
		end
	endgenerate
	
endmodule
	





module one_hot_2sel_mux #(
		parameter	IN_WIDTH	  =	16,
		parameter	SEL1_WIDTH =   4, //PORT_NUM
		parameter	SEL2_WIDTH =	4//VC_NUM_PER_PORT

	)
	(
		input [IN_WIDTH-1	:0]	mux_in,
		output						mux_out,
		input[SEL1_WIDTH-1:0]	sel1,
		input[SEL2_WIDTH-1:0]	sel2
	
	);

	wire [IN_WIDTH-1	:0]	first_mask;
	wire [IN_WIDTH-1	:0]	anded_level1;
	wire [SEL2_WIDTH-1:0] 	vcs_of_selected_port;
	wire [SEL1_WIDTH-1:0]  	same_vc_array [SEL2_WIDTH-1:0]; 
	
	genvar i,j;
	
	//first selector masking
	generate 	// first_mask = {sel[0],sel[0],sel[0],....,sel[n],sel[n],sel[n]}
		for(i=0; i<SEL1_WIDTH; i=i+1) begin : mask_loop
			assign first_mask[(i+1)*SEL2_WIDTH-1 : (i)*SEL2_WIDTH]	=	{SEL2_WIDTH{sel1[i]} };
		end
		
		assign anded_level1	= mux_in & first_mask;
		
		for(i=0; i<SEL2_WIDTH; i=i+1) begin : lp1
			for(j=0; j<SEL1_WIDTH; j=j+1) begin : lp2
				assign same_vc_array[i][j]	=	anded_level1[i+SEL2_WIDTH*j];
			end
			assign vcs_of_selected_port[i] = | same_vc_array[i];
		end
	endgenerate
	
	//second selector masking
	
	wire [SEL2_WIDTH-1:0]	anded_level2;
	assign   anded_level2	=   vcs_of_selected_port & sel2;
	assign	mux_out 			= | anded_level2;
	

	
endmodule



module one_hot_demux	#(
		parameter IN_WIDTH=5,
		parameter SEL_WIDTH=4,
		parameter OUT_WIDTH=IN_WIDTH*SEL_WIDTH
	)
	(
		input 	[SEL_WIDTH-1		:	0] demux_sel,//selectore
		input 	[IN_WIDTH-1			:	0] demux_in,//repeated
		output 	[OUT_WIDTH-1		:	0]	demux_out
	);

	genvar i,j;
	generate 
	for(i=0;i<SEL_WIDTH;i=i+1)begin :loop1
		for(j=0;j<IN_WIDTH;j=j+1)begin :loop2
				assign demux_out[i*IN_WIDTH+j] =	 demux_sel[i]	&	demux_in[j];
		end//for j
	end//for i
	endgenerate

	

endmodule
	
//parametrizable one hot to bcd

module one_hot_to_bcd #(
	parameter ONE_HOT_WIDTH	=	4,
	parameter BCD_WIDTH		=	log2(ONE_HOT_WIDTH)
)
(
	input 	[ONE_HOT_WIDTH-1		:	0] one_hot_code,
	output 	[BCD_WIDTH-1			:	0]	bcd_code

);

`LOG2
localparam MUX_IN_WIDTH	=	BCD_WIDTH* ONE_HOT_WIDTH;

wire [MUX_IN_WIDTH-1		:	0]	bcd_temp ;

genvar i;
generate 
	for(i=0; i<ONE_HOT_WIDTH; i=i+1) begin :mux_in_gen_loop
			assign bcd_temp[(i+1)*BCD_WIDTH-1 : i*BCD_WIDTH] =  i[BCD_WIDTH-1:0];
	end
endgenerate

 one_hot_mux #(
		.IN_WIDTH	(MUX_IN_WIDTH),
		.SEL_WIDTH	(ONE_HOT_WIDTH)
		
	)
	one_hot_to_bcd_mux
	(
		.mux_in		(bcd_temp),
		.mux_out		(bcd_code),
		.sel			(one_hot_code)

	);



endmodule



/*
module one_hot_in_bcd_out_mux#(
	parameter	IN_WIDTH	  		=	16,
	parameter	SEL_WIDTH 		=   4, 
	parameter	OUT_WIDTH 		=	(IN_WIDTH/SEL_WIDTH),
	parameter	OUT_WIDTH_BCD	=	log2(OUT_WIDTH)
)
(
		input [IN_WIDTH-1		:0]	mux_in,
		output[OUT_WIDTH_BCD-1	:0]	mux_out,
		input[SEL_WIDTH-1		:0]	sel

	);
`LOG2
	wire [OUT_WIDTH-1:0] mux_hot_out;
	
hot_mux #(
		.IN_WIDTH	(IN_WIDTH),
		.SEL_WIDTH 	(SEL_WIDTH)		
	)
	mux
	(
		.mux_in	(mux_in),
		.mux_out	(mux_hot_out),
		.sel		(sel)

	);

one_hot_to_bcd #(
	.ONE_HOT_WIDTH	(OUT_WIDTH)
)
conv
(
	.one_hot_code	(mux_hot_out),
	.bcd_code		(mux_out)

);
endmodule

*/


module one_hot_in_bcd_out_mux#(
	parameter	IN_WIDTH	  		=	16,
	parameter	SEL_WIDTH 		=   4, 
	parameter	OUT_WIDTH 		=	(IN_WIDTH/SEL_WIDTH),
	parameter	OUT_WIDTH_BCD	=	log2(OUT_WIDTH)
)
(
		input [IN_WIDTH-1		:0]	mux_in,
		output[OUT_WIDTH_BCD-1	:0]	mux_out,
		input[SEL_WIDTH-1		:0]	sel

	);
`LOG2
localparam MUX_HOT_IN_WIDTH	= SEL_WIDTH*OUT_WIDTH_BCD;
	wire [MUX_HOT_IN_WIDTH-1:0] mux_hot_in;
	genvar i;
	generate 
		for (i=0;	i<SEL_WIDTH;	i=i+1'b1) begin	:conv_loop
		one_hot_to_bcd #(
			.ONE_HOT_WIDTH	(OUT_WIDTH)
		)
		conv
		(
		.one_hot_code	(mux_in[(i+1)*OUT_WIDTH-1 : i*OUT_WIDTH]),
		.bcd_code		(mux_hot_in[(i+1)*OUT_WIDTH_BCD-1 : i*OUT_WIDTH_BCD])
		);
		end
	endgenerate
	
	
	
	
	one_hot_mux #(
		.IN_WIDTH	(MUX_HOT_IN_WIDTH),
		.SEL_WIDTH 	(SEL_WIDTH)		
	)
	mux
	(
		.mux_in	(mux_hot_in),
		.mux_out	(mux_out),
		.sel		(sel)

	);


endmodule



module bcd_in_one_hot_out_mux #(
	parameter	IN_BCD_WIDTH	  		=	8,
	parameter	SEL_BCD_WIDTH 			=  2, 
	parameter   SEL_WIDTH				=	2**SEL_BCD_WIDTH,
	parameter	OUT_BCD_WIDTH 			=	IN_BCD_WIDTH/SEL_WIDTH,
	parameter	OUT_WIDTH				=	2**OUT_BCD_WIDTH
)
(
	input [IN_BCD_WIDTH-1		:	0]	mux_in,
	output[OUT_WIDTH-1			:	0]	mux_out,
	input	[SEL_BCD_WIDTH-1		:	0]	sel

	);

	wire [OUT_BCD_WIDTH-1		:	0]	mux_out_bcd;
	
bcd_mux #(
		.IN_WIDTH			(IN_BCD_WIDTH),
		.OUT_WIDTH  		(OUT_BCD_WIDTH)
	)
	the_bcd_mux
	(
		.mux_in				(mux_in),
		.mux_out				(mux_out_bcd),
		.sel					(sel)

	);
	
	bcd_to_one_hot #(
	.BCD_WIDTH		(OUT_BCD_WIDTH),
	.ONE_HOT_WIDTH	(OUT_WIDTH)
	)
	conv
	(
	.bcd_code		(mux_out_bcd),
	.one_hot_code	(mux_out)
	);
endmodule


//parametrizable bcd to one hot

module bcd_to_one_hot #(
	parameter BCD_WIDTH		=	2,
	parameter ONE_HOT_WIDTH	=	2**BCD_WIDTH
	
)
(
	input 	[BCD_WIDTH-1			:	0]	bcd_code,
	output 	[ONE_HOT_WIDTH-1		:	0] one_hot_code
 );

	genvar i;
	generate 
		for(i=0; i<ONE_HOT_WIDTH; i=i+1) begin :one_hot_gen_loop
				assign one_hot_code[i] = bcd_code == i[BCD_WIDTH-1			:	0];
		end
	endgenerate
 
endmodule
	
	
module port_sel_correction #(
	parameter PORT_NUM	=	5,
	parameter SWITCH_LOCATION = 0,
	parameter PORT_NUM_BCD_WIDTH	=	log2(PORT_NUM),
	parameter PORT_SEL_BCD_WIDTH	=	log2(PORT_NUM-1)
)
(
	input [PORT_NUM_BCD_WIDTH-1		:	0] port_num_bcd,
	output[PORT_SEL_BCD_WIDTH-1		:	0] port_sel_bcd
);

	`LOG2
	localparam PORT_SEL_WIDTH = PORT_NUM-1;
	
	wire [PORT_NUM-1			:	0] port_num_one_hot;
	wire [PORT_SEL_WIDTH-1	:	0]	port_sel_one_hot;
	
	bcd_to_one_hot #(
		.BCD_WIDTH		(PORT_NUM_BCD_WIDTH),
		.ONE_HOT_WIDTH	(PORT_NUM)
	)
	conv1
	(
		.bcd_code		(port_num_bcd),
		.one_hot_code	(port_num_one_hot)
	);
 
	genvar i;	
	generate 
	//remove one extra bit from port num
	for(i=0;i<PORT_NUM;i=i+1)begin :port_loop
		if	(i>SWITCH_LOCATION)		assign port_sel_one_hot[i-1]		=	port_num_one_hot[i];
		else if(i<SWITCH_LOCATION)	assign port_sel_one_hot[i]			=	port_num_one_hot[i];
	end//for	
	endgenerate
	
	one_hot_to_bcd #(
		.ONE_HOT_WIDTH (PORT_SEL_WIDTH)
	)
	conv2
	(
		.one_hot_code	(port_sel_one_hot),
		.bcd_code		(port_sel_bcd)

	);

endmodule




module two_sel_mux #(
		parameter	IN_WIDTH	  =	16,
		parameter	SEL1_WIDTH =   4, //PORT_NUM
		parameter	SEL2_WIDTH =	4,//VC_NUM_PER_PORT
		parameter	SEL1_BCD_WIDTH = log2(SEL1_WIDTH),
		parameter	SEL2_BCD_WIDTH = log2(SEL2_WIDTH)
		

	)
	(
		input [IN_WIDTH-1	:0]	mux_in,
		output						mux_out,
		input[SEL1_BCD_WIDTH-1:0]	sel1,
		input[SEL2_BCD_WIDTH-1:0]	sel2
	
	);
	`LOG2
	wire [SEL2_WIDTH-1:0] 	mux1_in [SEL1_WIDTH-1:0] ;
	wire [SEL2_WIDTH-1:0]   mux1_out;
	genvar i; 
	generate
		for(i=0;i<SEL1_WIDTH; i=i+1'b1) begin : an
			assign mux1_in [i] = mux_in[((i+1)*SEL2_WIDTH)-1	:	i*SEL2_WIDTH];
		end
	endgenerate
	assign mux1_out = mux1_in [sel1];
	assign mux_out  = mux1_out[sel2];
	
	

	
endmodule



module bcd_mux #(
		parameter	IN_WIDTH	  		=	20,
		parameter	OUT_WIDTH  		=	5,
		parameter	IN_NUM	  		=	IN_WIDTH/OUT_WIDTH,
		parameter	SEL_WIDTH_BCD 	=  log2(IN_NUM) 
		

	)
	(
		input 	[IN_WIDTH-1			:0]	mux_in,
		output	[OUT_WIDTH-1		:0]	mux_out,
		input		[SEL_WIDTH_BCD-1	:0]	sel

	);
	`LOG2
	wire [OUT_WIDTH-1		:0] mux_in_2d [IN_NUM -1	:0];
	genvar i;
	generate 
		for (i=0; i< IN_NUM; i=i+1'b1) begin : loop
			assign mux_in_2d[i]	=mux_in[((i+1)*OUT_WIDTH)-1	:	i*OUT_WIDTH];	
		end
	endgenerate
	
	assign mux_out = mux_in_2d[sel];
	
endmodule



module ovc_st_mux #(
		parameter	IN_WIDTH	  				=	16,
		parameter	PORT_SEL_NUM			=	4, 
		parameter	VC_NUM_PER_PORT	 	=	4,
		parameter	PORT_SEL_BCD_WIDTH	=  log2	(PORT_SEL_NUM),
		parameter	VC_BCD_WIDTH 		 	=	log2	(VC_NUM_PER_PORT)	

	)
	(
		input [IN_WIDTH-1				:0]	mux_in,
		output									mux_out,
		input[PORT_SEL_BCD_WIDTH-1	:0]	port_sel_bcd,
		input[VC_BCD_WIDTH -1		:0]	vc_num_bcd
	
	);
	`LOG2
	
	wire [VC_NUM_PER_PORT -1:0] 	mux1_in [PORT_SEL_NUM-1:0] ;
	wire [VC_NUM_PER_PORT -1:0]  mux1_out;
	genvar i; 
	generate
		for(i=0;i<PORT_SEL_NUM; i=i+1'b1) begin : lp
			assign mux1_in [i] = mux_in[((i+1)*VC_NUM_PER_PORT )-1	:	i*VC_NUM_PER_PORT ];
		end
	endgenerate
	assign mux1_out = mux1_in [port_sel_bcd];
	assign mux_out  = mux1_out [vc_num_bcd];
	
endmodule	



module ovc_st_mux_hyb #(
		parameter	IN_WIDTH	  				 =	16,
		parameter	PORT_SEL_BCD_WIDTH	 =  2,
		parameter	PORT_SEL_ONE_HOT_WIDTH=  4,
		parameter	VC_ONE_HOT_WIDTH 		 =	 4

	)
	(
		input [IN_WIDTH-1				:0]	mux_in,
		output									mux_out,
		input[PORT_SEL_BCD_WIDTH-1	:0]	port_sel_bcd,
		input[VC_ONE_HOT_WIDTH-1	:0]	vc_one_hot
	
	);
	`LOG2
	
	wire [VC_ONE_HOT_WIDTH -1:0] 	mux1_in [PORT_SEL_ONE_HOT_WIDTH-1:0] ;
	wire [VC_ONE_HOT_WIDTH -1:0]  mux1_out;
	genvar i; 
	generate
		for(i=0;i<PORT_SEL_ONE_HOT_WIDTH; i=i+1'b1) begin : lp
			assign mux1_in [i] = mux_in[((i+1)*VC_ONE_HOT_WIDTH )-1	:	i*VC_ONE_HOT_WIDTH ];
		end
	endgenerate
	assign mux1_out = mux1_in [port_sel_bcd];
	
	
	
	//second selector masking
	
	wire [VC_ONE_HOT_WIDTH -1:0]	anded_input;
	assign   anded_input		=   mux1_out & vc_one_hot;
	assign	mux_out 			= | anded_input;
	

	
endmodule	


module set_bits_counter #(
	parameter IN_WIDTH =2,
	parameter OUT_WIDTH = log2(IN_WIDTH+1)
	)
	(
	input 	[IN_WIDTH-1 		:	0]	in,
	output 	[OUT_WIDTH-1		:	0]	out
	
);
	`LOG2
	
	wire 	[IN_WIDTH-2 		:	0]	addrin2;
	wire  [OUT_WIDTH-1	:	0]	addrout [IN_WIDTH-2 		:	0]	;
	wire  [OUT_WIDTH-1	:	0]	addrin1 [IN_WIDTH-1 		:	0];
	
	assign addrin1[0] = {{(OUT_WIDTH-1){1'b0}},in[0]};
	assign out 			= addrin1 [IN_WIDTH-1];
	
	genvar i;
	generate 
		for (i=0; i<IN_WIDTH-1; i=i+1) begin : loop
					assign addrin1[i+1] 	= addrout[i];
					assign addrin2[i] 	= in[i+1];
					assign addrout[i]		= addrin1[i] + addrin2 [i];
		end
	endgenerate
endmodule


module wide_or #(
	parameter IN_ARRAY_WIDTH =80,
	parameter IN_NUM	 =5,
	parameter IN_WIDTH	=	IN_ARRAY_WIDTH/IN_NUM,
	parameter CMP_VAL	=	IN_WIDTH/(IN_NUM-1),
	parameter OUT_WIDTH = (IN_ARRAY_WIDTH/IN_NUM)+CMP_VAL
	
	)
	(
	input 	[IN_ARRAY_WIDTH-1 		:	0]	in,
	output 	[OUT_WIDTH-1				:	0]	out
);
	
	genvar i,j;
	wire [IN_WIDTH-1		:	0]		in_sep	[IN_NUM-1		:	0];
	wire [IN_NUM-2			:	0]		gen 		[OUT_WIDTH-1	:	0];
	generate 
		for(i=0;i<IN_NUM; i=i+1'b1		) begin : lp
			assign in_sep[i]  = in[(IN_WIDTH*(i+1))-1	: IN_WIDTH*i];
		end
		for (j=0;j<IN_NUM-1;j=j+1)begin : loop1
				for(i=0;i<OUT_WIDTH; i=i+1	)begin : loop2
					if(i>=CMP_VAL*(j+1))begin : if1
						assign gen[i][j] = in_sep[j][i-CMP_VAL];
					end 
					else if( i< CMP_VAL*(j+1) && i>= (CMP_VAL*j)) begin 
						assign gen[i][j] = in_sep[IN_NUM-1][i];
					end
					else	begin 
						assign gen[i][j] = in_sep[j][i];
					end
				end// for i
			end// for j
		for(i=0;i<OUT_WIDTH; i=i+1'b1		) begin : lp2
			assign out[i]				= |  gen[i];
		end
	endgenerate
endmodule
	
