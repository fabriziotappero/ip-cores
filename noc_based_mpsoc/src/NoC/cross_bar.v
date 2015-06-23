/*********************************************************************
							
	File: cross_bar.v 
	
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
	A simple 5 x 5 crossbar switch. Each input port can be connected to one
	of 4 other output ports using its sel pin

	Info: monemi@fkegraduate.utm.my
**************************************/
`include "../define.v"



module cross_bar #(
	parameter VC_NUM_PER_PORT			=	4,
	parameter X_NODE_NUM					=	3,
	parameter Y_NODE_NUM					=	3,
	parameter PORT_NUM					=	5,
	parameter PYLD_WIDTH 				=	32,
	parameter FLIT_TYPE_WIDTH			=	2,
	parameter PORT_SEL_WIDTH			=	PORT_NUM-1,//assum that no port whants to send a packet to itself!
	parameter VC_ID_WIDTH				=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH					=	PYLD_WIDTH+ FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM),	
	parameter LOOK_AHEAD_ARRAY_WIDTH	=	PORT_NUM_BCD_WIDTH	*	PORT_NUM,
	parameter PORT_SEL_ARRAY_WIDTH	=	PORT_SEL_WIDTH	*	PORT_NUM,
	parameter FLIT_ARRAY_WIDTH			=	FLIT_WIDTH		*	PORT_NUM,
	parameter OVC_ARRAY_WIDTH			=	VC_NUM_PER_PORT*	PORT_NUM
	
	
)
(
	input [LOOK_AHEAD_ARRAY_WIDTH-1	:	0]		look_ahead_port_sel_array,
	input [PORT_SEL_ARRAY_WIDTH-1		:	0]		port_sel_array,
	input [FLIT_ARRAY_WIDTH-1			:	0]		flit_in_array,
	input [OVC_ARRAY_WIDTH-1			:	0]		ovc_array,
	output[FLIT_ARRAY_WIDTH-1			:	0]		flit_out_array
);	
	`LOG2
	localparam	MUX_IN_WIDTH				=	FLIT_ARRAY_WIDTH-FLIT_WIDTH;
	localparam	PORT_SEL_BCD_WIDTH		=	log2(PORT_SEL_WIDTH);
	localparam  X_NODE_NUM_WIDTH			=	log2(X_NODE_NUM);
	localparam  Y_NODE_NUM_WIDTH			=	log2(Y_NODE_NUM);
	
	wire [MUX_IN_WIDTH-1					:	0]		flit_in_mux_array 	[PORT_NUM-1		:	0];	
	wire [PORT_NUM-1						:	0]		header_flit;
	wire [FLIT_TYPE_WIDTH-1				:	0]		flit_type				[PORT_NUM-1		:	0];	
	wire [PYLD_WIDTH-1					:	0]		pyld						[PORT_NUM-1		:	0];	
	wire [PYLD_WIDTH-PORT_NUM_BCD_WIDTH-1		:	0]		hdr_pyld_no_port_sel	[PORT_NUM-1		:	0];	
	
	wire	[FLIT_WIDTH-1					:	0]		flit_in					[PORT_NUM-1		:	0];	
	wire	[VC_NUM_PER_PORT-1			:	0]		ovc						[PORT_NUM-1		:	0];	
	wire	[PORT_NUM_BCD_WIDTH-1		:	0]		look_ahead_port_sel	[PORT_NUM-1		:	0];
	wire	[PORT_SEL_WIDTH-1				:	0]		port_sel					[PORT_NUM-1		:	0];
	wire	[PORT_SEL_WIDTH-1				:	0]		mux_sel					[PORT_NUM-1		:	0];
	wire	[PORT_SEL_BCD_WIDTH-1		:	0]		mux_sel_bcd				[PORT_NUM-1		:	0];
	wire	[FLIT_WIDTH-1					:	0]		updated_flit_in		[PORT_NUM-1		:	0];
	wire	[FLIT_WIDTH-1					:	0]		flit_out					[PORT_NUM-1		:	0];					
	
	
	genvar i,j;
	generate
	for(i=0;i<PORT_NUM;i=i+1)begin : port_loop
		assign flit_in					[i]	=	flit_in_array 					[(i+1)*FLIT_WIDTH-1			:	i*FLIT_WIDTH];
		assign ovc						[i]	=	ovc_array						[(i+1)*VC_NUM_PER_PORT-1	:	i*VC_NUM_PER_PORT];
		assign look_ahead_port_sel	[i]	=	look_ahead_port_sel_array	[(i+1)*PORT_NUM_BCD_WIDTH-1:	i*PORT_NUM_BCD_WIDTH];
		assign port_sel				[i]	=	port_sel_array					[(i+1)*PORT_SEL_WIDTH-1		:	i*PORT_SEL_WIDTH];
		assign header_flit			[i]	=	flit_in[i][`FLIT_HDR_FLG_LOC];
		assign flit_type				[i]	=	flit_in[i][`FLIT_IN_TYPE_LOC];
		assign pyld						[i]	=	flit_in[i][`FLIT_IN_PYLD_LOC];
		assign hdr_pyld_no_port_sel[i]	=	flit_in[i][`FLIT_IN_AFTER_PORT_LOC];
		assign flit_out_array		[(i+1)*FLIT_WIDTH-1		:	i*FLIT_WIDTH]	= flit_out[i];
		assign updated_flit_in		[i]	=	(header_flit[i])?	
						{flit_type[i],ovc[i],look_ahead_port_sel[i],hdr_pyld_no_port_sel[i]}:
						{flit_type[i],ovc[i],pyld[i]};
		/*			
		one_hot_mux #(
			.IN_WIDTH			(MUX_IN_WIDTH),
			.SEL_WIDTH			(PORT_SEL_WIDTH)
		)
		cross_mux
		(
			.mux_in				(flit_in_mux_array[i]),
			.mux_out				(flit_out[i]),
			.sel					(mux_sel[i])

		);
	*/
		one_hot_to_bcd #(
			.ONE_HOT_WIDTH		(PORT_SEL_WIDTH)
		)cross_sel
		(
			.one_hot_code		(mux_sel[i]),
			.bcd_code			(mux_sel_bcd[i])
		);
		
		
		bcd_mux #(
			.IN_WIDTH			(MUX_IN_WIDTH),
			.SEL_WIDTH_BCD		(PORT_SEL_BCD_WIDTH),
			.OUT_WIDTH 			(FLIT_WIDTH)

		)
		cross_mux
		(
			.mux_in				(flit_in_mux_array[i]),
			.mux_out				(flit_out[i]),
			.sel					(mux_sel_bcd[i])

		);
	
	
		
		for(j=0;j<PORT_NUM;j=j+1)begin : port_loop2  //remove sender port flit from flit list
			if(i>j)	begin	:if1
				assign flit_in_mux_array[i][(j+1)*FLIT_WIDTH-1	:	j*FLIT_WIDTH]= 	updated_flit_in[j];
				assign mux_sel[i][j] =	port_sel[j][i-1];
			end
			else if(i<j) begin :if2
				assign flit_in_mux_array[i][j*FLIT_WIDTH-1	:	(j-1)*FLIT_WIDTH]= 	updated_flit_in[j];
				assign mux_sel[i][j-1] =	port_sel[j][i];
			end
		end//fior j
	
	end//for i
	endgenerate
	
endmodule


/*
module mux_4to_1 #(
	parameter	data_width=32
	)
	(
	input	[3					:	0]	sel,
	input	[data_width-1	:	0]	in1,
	input	[data_width-1	:	0]	in2,
	input	[data_width-1	:	0]	in3,
	input	[data_width-1	:	0]	in4,
	output  [data_width-1	:	0]	out
	);
	
//assign	out	=	({data_width{sel[0]}}	&	in1)  |
//						({data_width{sel[1]}}	&	in2)  |
//						({data_width{sel[2]}}	&	in3)  |
//						({data_width{sel[3]}}	&  in4);


wire  [data_width-1	:	0]	out0,out1,out2,out3;
assign out0		=	{data_width{sel[0]}}& in1;  
assign out1		=	{data_width{sel[1]}}& in2;
assign out2		=	{data_width{sel[2]}}& in3; 
assign out3		=	{data_width{sel[3]}}& in4;
						
assign out		= 	out0 | out1	| out2 | out3;					


assign	out	=	(sel[0])? in1:
						(sel[1])? in2:
						(sel[2])? in3:
						(sel[3])? in4:
						{data_width{1'bx}};
						
						
always @(*)		begin
	case(sel)
		4'b0001	: out= in1;
		4'b0010	: out= in2;
		4'b0100	: out= in3;
		4'b1000	: out= in4;
		default	: out= {data_width{1'bx}};
	endcase
end

	
endmodule
							
*/							