/*********************************************************************
							
	File: wishbone_bus.v 
	
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
	generating the wishbone bus. 

	Info: monemi@fkegraduate.utm.my

****************************************************************/




`timescale  1ns/1ps

`include "../define.v"
module wishbone_bus #(
	parameter RAM_EN							=	1,
	parameter NOC_EN							=	0,
	parameter GPIO_EN							=	1,
	parameter EXT_INT_EN						=	1,
	parameter TIMER_EN						=	1,
	parameter INT_CTRL_EN					=	1,
	
	parameter GPIO_WIDTH						=	56,
	parameter MASTER_NUM_					=	4,		//number of master port
	parameter SLAVE_NUM_						=	4,		//number of slave port
	parameter DATA_WIDTH						=	32,	// maximum data width
	parameter ADDR_WIDTH						=	32,
	parameter SEL_WIDTH						=	2,
	parameter TAG_WIDTH						=	3,    //merged  {tga,tgb,tgc}
	
	
	 //define the slave address width in soc_define
	
	
	parameter SLAVE_DATA_ARRAY_WIDTH		=	DATA_WIDTH 	* SLAVE_NUM_	,
	parameter SLAVE_ADDR_ARRAY_WIDTH		=	ADDR_WIDTH 	* SLAVE_NUM_	,
	parameter SLAVE_SEL_ARRAY_WIDTH		=	SEL_WIDTH  	* SLAVE_NUM_	, 
	parameter SLAVE_TAG_ARRAY_WIDTH		=	TAG_WIDTH  	* SLAVE_NUM_	,
	parameter MASTER_DATA_ARRAY_WIDTH	=	DATA_WIDTH 	* MASTER_NUM_,
	parameter MASTER_ADDR_ARRAY_WIDTH	=	ADDR_WIDTH 	* MASTER_NUM_,
	parameter MASTER_SEL_ARRAY_WIDTH		=	SEL_WIDTH  	* MASTER_NUM_,
	parameter MASTER_TAG_ARRAY_WIDTH		=	TAG_WIDTH  	* MASTER_NUM_

	
	
)
(
	//slaves interface
	output  	[SLAVE_ADDR_ARRAY_WIDTH-1		:	0	]	slave_adr_o_array,//
	output	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	slave_dat_o_array,//
	output	[SLAVE_SEL_ARRAY_WIDTH-1		:	0	]	slave_sel_o_array,//
	output	[SLAVE_TAG_ARRAY_WIDTH-1		:	0	]	slave_tag_o_array,
	output	[SLAVE_NUM_-1						:	0	]	slave_we_o_array,//
	output	[SLAVE_NUM_-1						:	0	]	slave_cyc_o_array,//
	output	[SLAVE_NUM_-1						:	0	]	slave_stb_o_array,
	
	
	input 	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	slave_dat_i_array,
	input		[SLAVE_NUM_-1						:	0	]	slave_ack_i_array,
	input		[SLAVE_NUM_-1						:	0	]	slave_err_i_array,
	input		[SLAVE_NUM_-1						:	0	]	slave_rty_i_array,
									
	
	//masters interface
	output	[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	master_dat_o_array,//
	output	[MASTER_NUM_-1						:	0	]	master_ack_o_array,
	output	[MASTER_NUM_-1						:	0	]	master_err_o_array,
	output	[MASTER_NUM_-1						:	0	]	master_rty_o_array,
	
	
	input		[MASTER_ADDR_ARRAY_WIDTH-1		:	0	]	master_adr_i_array,
	input		[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	master_dat_i_array,
	input		[MASTER_SEL_ARRAY_WIDTH-1		:	0	]	master_sel_i_array,
	input		[MASTER_TAG_ARRAY_WIDTH-1		:	0	]	master_tag_i_array,
	input		[MASTER_NUM_-1						:	0	]	master_we_i_array,
	input		[MASTER_NUM_-1						:	0	]	master_stb_i_array,
	input		[MASTER_NUM_-1						:	0	]	master_cyc_i_array,
	
	
	//system signals
	
	input 														clk,
	input 														reset
	
);

	`LOG2



	

`define		ADD_BUS_LOCALPARAM	1
`include 	"../parameter.v"

	genvar i;
	
	
	
	
	
localparam	MASTER_NUM_BCD_WIDTH		=	log2(MASTER_NUM);
localparam 	SLAVE_NUM_BCD_WIDTH		=	log2(SLAVE_NUM);

wire	any_slave_ack,any_slave_err,any_slave_rty;
wire	master_grant_we,master_grant_stb,master_grant_cyc;
wire	[ADDR_WIDTH-1											:	0]	master_grant_addr;
wire	[DATA_WIDTH-1											:	0]	master_grant_dat,slave_read_dat;
wire	[SEL_WIDTH-1											:	0]	master_grant_sel;
wire	[TAG_WIDTH-1											:	0]	master_grant_tag;

wire	[SLAVE_NUM-1											:	0]	slave_sel_one_hot;
wire	[SLAVE_NUM_BCD_WIDTH-1								:	0]	slave_sel_bcd;
wire	[MASTER_NUM-1											:	0]	master_grant_onehot;
wire	[MASTER_NUM_BCD_WIDTH-1								:	0]	master_grant_bcd;

wire 	[ADDR_WIDTH-1											:	0]	slave_adr_o;
wire	[DATA_WIDTH-1											:	0]	slave_dat_o;
wire	[SEL_WIDTH-1											:	0]	slave_sel_o;
wire	[TAG_WIDTH-1											:	0]	slave_tag_o;
wire																		slave_we_o;
wire																		slave_cyc_o;
wire	[DATA_WIDTH-1											:	0]	master_dat_o;


assign	slave_adr_o_array	=	{SLAVE_NUM{slave_adr_o}};
assign	slave_dat_o_array	=	{SLAVE_NUM{slave_dat_o}};
assign	slave_sel_o_array	=	{SLAVE_NUM{slave_sel_o}};
assign	slave_tag_o_array	=	{SLAVE_NUM{slave_tag_o}};
assign	slave_we_o_array	=	{SLAVE_NUM{slave_we_o}};
assign	slave_cyc_o_array	=	{SLAVE_NUM{slave_cyc_o}};
assign	master_dat_o_array=	{MASTER_NUM{master_dat_o}};

assign 	any_slave_ack		=|	slave_ack_i_array;
assign 	any_slave_err		=|	slave_err_i_array;
assign 	any_slave_rty		=|	slave_rty_i_array;

assign 	slave_adr_o			=	master_grant_addr;
assign 	slave_dat_o			=	master_grant_dat;
assign 	slave_sel_o			=	master_grant_sel;
assign	slave_tag_o			=	master_grant_tag;
assign 	slave_we_o			=	master_grant_we;
assign 	slave_cyc_o			=	master_grant_cyc;
assign 	slave_stb_o_array	=	slave_sel_one_hot & {SLAVE_NUM{master_grant_stb & master_grant_cyc}};








wire	[ADDR_PERFIX-1		:	0]	master_perfix_addr;
assign master_perfix_addr		=	master_grant_addr[ADDR_WIDTH-3	:	ADDR_WIDTH-ADDR_PERFIX-2];


bus_addr_cmp #(
	.RAM_EN			(RAM_EN),
	.NOC_EN			(NOC_EN),
	.GPIO_EN			(GPIO_EN),
	.EXT_INT_EN		(EXT_INT_EN),
	.TIMER_EN		(TIMER_EN),
	.INT_CTRL_EN	(INT_CTRL_EN),
	
	.ADDR_PERFIX_	(ADDR_PERFIX),
	.SLAVE_NUM_		(SLAVE_NUM)	 
	)
	addr_cmp
	(
		.addr_in		(master_perfix_addr),
		.cmp_out		(slave_sel_one_hot)
	);



assign  	master_dat_o			= 	slave_read_dat;
assign	master_ack_o_array	=	master_grant_onehot	& {MASTER_NUM{any_slave_ack}};	
assign	master_err_o_array	=	master_grant_onehot	& {MASTER_NUM{any_slave_err}}; 
assign	master_rty_o_array	=	master_grant_onehot	& {MASTER_NUM{any_slave_rty}};


		
//convert one hot to bcd 
one_hot_to_bcd #(
	.ONE_HOT_WIDTH	(SLAVE_NUM)
)
slave_sel_conv
(
	.one_hot_code	(slave_sel_one_hot),
	.bcd_code		(slave_sel_bcd)
);

one_hot_to_bcd #(
	.ONE_HOT_WIDTH	(MASTER_NUM)
)
master_grant_conv
(
	.one_hot_code	(master_grant_onehot),
	.bcd_code		(master_grant_bcd)
);



//slave multiplexer 
bcd_mux #( 
	.IN_WIDTH 	(SLAVE_DATA_ARRAY_WIDTH),	
	.OUT_WIDTH 	(DATA_WIDTH)
)
 slave_read_data_mux
(
	.mux_in		(slave_dat_i_array),
	.mux_out		(slave_read_dat),
	.sel			(slave_sel_bcd)

);


//master ports multiplexers

bcd_mux #( 
	.IN_WIDTH 	(MASTER_ADDR_ARRAY_WIDTH),	
	.OUT_WIDTH 	(ADDR_WIDTH)
)
 master_adr_mux
(
	.mux_in		(master_adr_i_array),
	.mux_out		(master_grant_addr),
	.sel			(master_grant_bcd)

);



bcd_mux #( 
	.IN_WIDTH 	(MASTER_DATA_ARRAY_WIDTH),	
	.OUT_WIDTH 	(DATA_WIDTH)
)
 master_data_mux
(
	.mux_in		(master_dat_i_array),
	.mux_out		(master_grant_dat),
	.sel			(master_grant_bcd)

);



bcd_mux #( 
	.IN_WIDTH 	(MASTER_SEL_ARRAY_WIDTH),	
	.OUT_WIDTH 	(SEL_WIDTH)
)
 master_sel_mux
(
	.mux_in		(master_sel_i_array),
	.mux_out		(master_grant_sel),
	.sel			(master_grant_bcd)

);



bcd_mux #( 
	.IN_WIDTH 	(MASTER_TAG_ARRAY_WIDTH),	
	.OUT_WIDTH 	(TAG_WIDTH)
)
 master_tag_mux
(
	.mux_in		(master_tag_i_array),
	.mux_out		(master_grant_tag),
	.sel			(master_grant_bcd)

);


bcd_mux #( 
	.IN_WIDTH 	(MASTER_NUM),	
	.OUT_WIDTH 	(1)
)
 master_we_mux
(
	.mux_in		(master_we_i_array),
	.mux_out		(master_grant_we),
	.sel			(master_grant_bcd)

);



bcd_mux #( 
	.IN_WIDTH 	(MASTER_NUM),	
	.OUT_WIDTH 	(1)
)
 master_stb_mux
(
	.mux_in		(master_stb_i_array),
	.mux_out		(master_grant_stb),
	.sel			(master_grant_bcd)

);



bcd_mux #( 
	.IN_WIDTH 	(MASTER_NUM),	
	.OUT_WIDTH 	(1)
)
 master_cyc_mux
(
	.mux_in		(master_cyc_i_array),
	.mux_out		(master_grant_cyc),
	.sel			(master_grant_bcd)

);

generate
	if(MASTER_NUM > 1) begin
		// round roubin arbiter
		bus_arbiter # (
			.MASTER_NUM	(MASTER_NUM)
		)
		arbiter
		(
			.request	(master_cyc_i_array),
			.grant	(master_grant_onehot),
			.clk		(clk),
			.reset	(reset)
		);
	end else begin // if we have just one master there is no needs for arbitration
		assign master_grant_onehot = master_cyc_i_array;
	end
endgenerate



endmodule



module bus_arbiter # (
	parameter MASTER_NUM = 4
)
(
	input 	[MASTER_NUM-1	:		0]	request,
	output	[MASTER_NUM-1	:		0]	grant,
	input 									clk,reset
);


wire 								comreq,grnt_enb;
wire 	[MASTER_NUM-1	:	0]	one_hot_arb_req, one_hot_arb_grant;
reg	[MASTER_NUM-1	:	0]	grant_registered;

assign 	one_hot_arb_req	=	request  & {MASTER_NUM{~comreq}};
assign	grant					=	grant_registered;

assign comreq	=	|(grant & request);

always @ (posedge clk or posedge reset) begin 
	if (reset) begin 
		grant_registered	<= {MASTER_NUM{1'b0}};
	end else begin
		if(~comreq)	grant_registered	<=	one_hot_arb_grant;		
	end
end//always






one_hot_arbiter #(
	.ARBITER_WIDTH	(MASTER_NUM )
)
the_combinational_arbiter
(
	.request		(one_hot_arb_req),
	.grant		(one_hot_arb_grant),
	.any_grant	(),
	.clk			(clk),
	.reset		(reset)
);




endmodule
