/*********************************************************************
							
	File: aeMB_IP.v 
	
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
	SoC with one aeMB processor, wishbone bus,ni,ext_int, gpio and timer
	

	Info: monemi@fkegraduate.utm.my

****************************************************************/



`include "../define.v"


`timescale  1ns/1ps
module aeMB_IP #(
	parameter NI_CTRL_SIMULATION			=	"aeMB", 
	parameter AEMB_RAM_WIDTH_IN_WORD		=	`AEMB_RAM_WIDTH_IN_WORD_DEF,
	parameter RAM_EN							=	1,
	parameter NOC_EN							=	0,
	parameter GPIO_EN							=	1,
	parameter EXT_INT_EN						=	1,
	parameter TIMER_EN						=	1,
	parameter INT_CTRL_EN					=	1,
	
//wishbone bus parameters
	parameter DATA_WIDTH						=	32,	// maximum data width
	parameter ADDR_WIDTH						=	32,
	parameter SEL_WIDTH						=	4,
	parameter TAG_WIDTH						=	3,    // CTI
	
	//external int parameters
	parameter EXT_INT_NUM					=	3,//max 32
	parameter EXT_INT_ADDR_WIDTH			=	3,

//timet parameters
	parameter TIMER_ADDR_WIDTH				=3,
	parameter TIMER_INT_NUM					=1,

//int_ctrl parameters 
	parameter INT_CTRL_INT_NUM				=3, //ext_int,timer,ni  
	parameter INT_CTRL_ADDR_WIDTH			=3,
	
//gpio parameters 
	parameter IO_EN							=	0,
	parameter I_EN								=	0,
	parameter O_EN								=	1,
	
	parameter IO_PORT_WIDTH					=	"0",
	parameter I_PORT_WIDTH					=	"0",
	parameter O_PORT_WIDTH					=	"7,7,7,7,7,7,7,7",
	
	parameter IO_WIDTH						=(IO_EN)? 		sum_of_all(IO_PORT_WIDTH)	: 1,
	parameter I_WIDTH							=(I_EN )? 		sum_of_all(I_PORT_WIDTH)	: 1,
	parameter O_WIDTH							=(O_EN )? 		sum_of_all(O_PORT_WIDTH)	: 1,
	parameter EXT_INT_WIDTH					=(EXT_INT_EN)?	EXT_INT_NUM						: 1,
	
	parameter GPIO_ADDR_WIDTH				=	15,
	

	
// noc parameter
	parameter TOPOLOGY				=	"TORUS", // "MESH" or "TORUS"  
	parameter ROUTE_ALGRMT			=	"XY",		//"XY" or "MINIMAL"
	parameter VC_NUM_PER_PORT 		=	2,
	parameter PYLD_WIDTH 			=	32,
	parameter BUFFER_NUM_PER_VC	=	16,
	parameter PORT_NUM				=	5,
	parameter X_NODE_NUM				=	4,
	parameter Y_NODE_NUM				=	3,
	parameter SW_X_ADDR				=	0,
	parameter SW_Y_ADDR				=	0,
	parameter NOC_S_ADDR_WIDTH		=	3,
	parameter CORE_NUMBER			=	`CORE_NUM(SW_X_ADDR,SW_Y_ADDR),	
	parameter NIC_CONNECT_PORT		=	0, // 0:Local  1:East, 2:North, 3:West, 4:South 
	parameter FLIT_TYPE_WIDTH		=	2,
	parameter VC_ID_WIDTH			=	VC_NUM_PER_PORT,
	parameter FLIT_WIDTH				=	PYLD_WIDTH+FLIT_TYPE_WIDTH+VC_ID_WIDTH,
	parameter CONGESTION_WIDTH		=	8,
	
//aeMB parameters
	parameter AEMB_IWB = 32, ///< INST bus width
   parameter AEMB_DWB = 32, ///< DATA bus width
   parameter AEMB_XWB = 7, ///< XCEL bus width

   // CACHE PARAMETERS
   parameter AEMB_ICH = 11, ///< instruction cache size
   parameter AEMB_IDX = 6,///< cache index size

   // OPTIONAL HARDWARE
   parameter AEMB_BSF = 1, ///< optional barrel shift
   parameter AEMB_MUL = 1 ///< optional multiplier
	
)(
	input 	clk,reset_in,sys_ena_i,
	
	input		[EXT_INT_WIDTH-1			:0]	ext_int_i,
	inout 	[IO_WIDTH-1					:0]	gpio_io,
	input		[I_WIDTH-1					:0]	gpio_i,
	output	[O_WIDTH-1					:0]	gpio_o,
	
	
	// NOC interfaces
	output	[FLIT_WIDTH-1				:0] 	flit_out,     
	output 		    			   				flit_out_wr,   
	input 	[VC_NUM_PER_PORT-1		:0]	credit_in,
	input 	[CONGESTION_WIDTH-1		:0]	congestion_cmp_i,
	
	input		[FLIT_WIDTH-1				:0] 	flit_in,     // Data in
	input 	    			   					flit_in_wr,   // Write enable
	output 	[VC_NUM_PER_PORT-1		:0]	credit_out
	
	//synthesis translate_off 
	//In case we want to handle NI interface using testbench not aeMB 
	,
	input 	[AEMB_DWB-1					:2] 	cpu_adr_i,
   input											 	cpu_cyc_i,		
   input 	[31							:0] 	cpu_dat_i,		
   input 	[3								:0] 	cpu_sel_i,		
   input											 	cpu_stb_i,		
   input											 	cpu_wre_i,	
	
	output											cpu_ack_o,		
   output 	[31							:0]	cpu_dat_o		
	
	
	
	//synthesis translate_on

	
	
);

`define		ADD_BUS_LOCALPARAM	1
`include 	"../parameter.v"

`define ADD_FUNCTION 		1
`include "../my_functions.v"

//synthesis translate_off 
	`define 	SIMULATION_CODE		1
//synthesis translate_on
	
	`LOG2
	
	`ifdef SIMULATION_CODE	
		localparam	CPU_EN	= 	(NI_CTRL_SIMULATION		==	"aeMB") ?	1 : 0 ;
	`else 
		localparam	CPU_EN	= 	1;
	`endif
	

	localparam SLAVE_DATA_ARRAY_WIDTH		=	DATA_WIDTH * SLAVE_NUM	;
	localparam SLAVE_ADDR_ARRAY_WIDTH		=	ADDR_WIDTH * SLAVE_NUM	;
	localparam SLAVE_SEL_ARRAY_WIDTH			=	SEL_WIDTH  * SLAVE_NUM	;
	localparam SLAVE_TAG_ARRAY_WIDTH			=	TAG_WIDTH  * SLAVE_NUM	;
	localparam MASTER_DATA_ARRAY_WIDTH		=	DATA_WIDTH * MASTER_NUM	;
	localparam MASTER_ADDR_ARRAY_WIDTH		=	ADDR_WIDTH * MASTER_NUM	;
	localparam MASTER_SEL_ARRAY_WIDTH		=	SEL_WIDTH  * MASTER_NUM ;
	localparam MASTER_TAG_ARRAY_WIDTH		=	TAG_WIDTH  * MASTER_NUM ;
	
	

	
	
	//intrrupts signals
	wire 														sys_int_i,timer_irq,ni_irq,ext_int_irq;
	
	wire  [INT_CTRL_INT_NUM-1				:	0	]	int_ctrl_in;
	
	wire  [SLAVE_ADDR_ARRAY_WIDTH-1		:	0	]	bus_slave_adr_o;
	wire	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	bus_slave_dat_o;
	wire	[SLAVE_SEL_ARRAY_WIDTH-1		:	0	]	bus_slave_sel_o;
	wire	[SLAVE_TAG_ARRAY_WIDTH-1		:	0	]	bus_slave_tag_o;
	
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_we_o;
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_cyc_o;
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_stb_o;
	
	wire 	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	bus_slave_dat_i;
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_ack_i;
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_err_i;
	wire	[SLAVE_NUM-1						:	0	]	bus_slave_rty_i;
	
	
	//masters interface
	wire	[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	bus_master_dat_o;
	wire	[MASTER_NUM-1						:	0	]	bus_master_ack_o;
	wire	[MASTER_NUM-1						:	0	]	bus_master_err_o;
	wire	[MASTER_NUM-1						:	0	]	bus_master_rty_o;
	
	
	wire	[MASTER_ADDR_ARRAY_WIDTH-1		:	0	]	bus_master_adr_i;
	wire	[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	bus_master_dat_i;
	wire	[MASTER_SEL_ARRAY_WIDTH-1		:	0	]	bus_master_sel_i;
	wire	[MASTER_TAG_ARRAY_WIDTH-1		:	0	]	bus_master_tag_i;
	wire	[MASTER_NUM-1						:	0	]	bus_master_we_i;
	wire	[MASTER_NUM-1						:	0	]	bus_master_stb_i;
	wire	[MASTER_NUM-1						:	0	]	bus_master_cyc_i;


	
	wire [MASTER_NUM-1:	0] master_ack_i, master_err_i,master_rty_i, master_cyc_o,	master_stb_o, master_wre_o;
	wire [SEL_WIDTH-1:	0]	master_sel_o 	[MASTER_NUM-1	:	0];
	wire [TAG_WIDTH-1:	0]	master_tag_o	[MASTER_NUM-1	:	0];
	wire [ADDR_WIDTH-1:	0]	master_adr_o	[MASTER_NUM-1	:	0];
	wire [DATA_WIDTH-1:	0]	master_dat_i	[MASTER_NUM-1	:	0];
	wire [DATA_WIDTH-1:	0]	master_dat_o	[MASTER_NUM-1	:	0];
	
	
	

	wire		[DATA_WIDTH-1		:	0]		slave_dat_i		[SLAVE_NUM-1	:	0];
	wire		[ADDR_WIDTH-1		:	0] 	slave_addr_i	[SLAVE_NUM-1	:	0];
	wire		[DATA_WIDTH-1		:	0]		slave_dat_o		[SLAVE_NUM-1	:	0];
	wire		[SEL_WIDTH-1		:	0]		slave_sel_i		[SLAVE_NUM-1	:	0];
	wire		[TAG_WIDTH-1		:	0]		slave_tag_i		[SLAVE_NUM-1	:	0];
	wire		[SLAVE_NUM-1		:	0]		slave_stb_i,slave_we_i, slave_ack_o;
	
	wire 											reset;
	
	altera_reset_synchronizer	the_synchronizer
	(
		.reset_in	(reset_in) /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,
		.clk			(clk),
		.reset_out	(reset)
	);

	
	

generate 
	if(CPU_EN) begin : aeMB_gen
				
			
		aeMB2_edk63 #(
			.AEMB_IWB (AEMB_IWB), ///< INST bus width
			.AEMB_DWB (AEMB_DWB), ///< DATA bus width
			.AEMB_XWB (AEMB_XWB), ///< XCEL bus width
			.AEMB_ICH (AEMB_ICH), ///< instruction cache size
			.AEMB_IDX (AEMB_IDX),///< cache index size
			.AEMB_BSF (AEMB_BSF), ///< optional barrel shift
			.AEMB_MUL (AEMB_MUL) ///< optional multiplier
		
		)
		
		 aeMB2_edk63_inst
		(
			.xwb_wre_o() ,	// 	  xwb_wre_o
			.xwb_tag_o() ,	// 	  xwb_tag_o
			.xwb_stb_o() ,	// 	  xwb_stb_o
			.xwb_sel_o() ,	// 	 [3:0] xwb_sel_o
			.xwb_dat_o() ,	// 	 [31:0] xwb_dat_o
			.xwb_cyc_o() ,	// 	  xwb_cyc_o
			.xwb_adr_o() ,	// 	 [AEMB_XWB-1:2] xwb_adr_o
			.iwb_wre_o(master_wre_o[IWB_ID]) ,	// 	  iwb_wre_o
			.iwb_tag_o() ,	// 	  iwb_tag_o
			.iwb_stb_o(master_stb_o[IWB_ID]) ,	// 	  iwb_stb_o
			.iwb_sel_o(master_sel_o[IWB_ID]) ,	// 	 [3:0] iwb_sel_o
			.iwb_cyc_o(master_cyc_o[IWB_ID]) ,	// 	  iwb_cyc_o
			.iwb_adr_o(master_adr_o [IWB_ID][`AEMB_IWB_ADRR_RANG]) ,	// 	 [AEMB_IWB-1:2] iwb_adr_o
			
			.dwb_wre_o(master_wre_o[DWB_ID]) ,	// 	  dwb_wre_o
			.dwb_tag_o() ,	// 	  dwb_tag_o
			.dwb_stb_o(master_stb_o[DWB_ID]) ,	// 	  dwb_stb_o
			.dwb_sel_o(master_sel_o[DWB_ID]) ,	// 	 [3:0] dwb_sel_o
			.dwb_dat_o(master_dat_o[DWB_ID]) ,	// 	 [31:0] dwb_dat_o
			.dwb_cyc_o(master_cyc_o[DWB_ID]) ,	// 	  dwb_cyc_o
			.dwb_adr_o(master_adr_o [DWB_ID][`AEMB_DWB_ADRR_RANG]) ,	// 	 [AEMB_DWB-1:2] dwb_adr_o
			
			.xwb_dat_i(0) ,	// input [31:0] xwb_dat_i
			.xwb_ack_i(1'b0) ,	// input  xwb_ack_i
			.sys_rst_i(reset		  ) ,	// input  sys_rst_i
			.sys_int_i(sys_int_i) ,	// input  sys_int_i
			.sys_ena_i(sys_ena_i) ,	// input  sys_ena_i
			.sys_clk_i(clk				  ) ,	// input  sys_clk_i
			
			.iwb_dat_i(master_dat_i[IWB_ID]) ,	// input [31:0] iwb_dat_i
			.iwb_ack_i(master_ack_i[IWB_ID]) ,	// input  iwb_ack_i
			.dwb_dat_i(master_dat_i[DWB_ID]) ,	// input [31:0] dwb_dat_i
			.dwb_ack_i(master_ack_i[DWB_ID]) 	// input  dwb_ack_i
		);

		assign master_dat_o[IWB_ID] = 0;
		assign master_tag_o[IWB_ID] = 3'b000;  // clasic wishbone without  burst 
		assign master_tag_o[DWB_ID] = 3'b000;  // clasic wishbone without  burst 
		assign master_adr_o[IWB_ID][31:30]	=	2'b00;
		assign master_adr_o[DWB_ID][31:30]	=	2'b00;
	
	end 
	//synthesis translate_off 
	//In case we want to handle NI interface using testbench not aeMB 
	else begin : ni_int_gen 
		
			assign	master_stb_o[DWB_ID]		=	cpu_stb_i; 	// 	  dwb_stb_o
			assign 	master_sel_o[DWB_ID] 	=	cpu_sel_i;	// 	 [3:0] dwb_sel_o
			assign	master_dat_o[DWB_ID] 	=	cpu_dat_i;	// 	 [31:0] dwb_dat_o
			assign	master_cyc_o[DWB_ID] 	=	cpu_cyc_i;	// 	  dwb_cyc_o
			assign	master_wre_o[DWB_ID]		=	cpu_wre_i;
			assign	master_adr_o[DWB_ID][`AEMB_DWB_ADRR_RANG]		=	cpu_adr_i; 	// 	 [AEMB_DWB-1:2] dwb_adr_o
			assign 	master_tag_o[DWB_ID] 	= 3'b000;  // clasic wishbone without  burst 
		
			assign	cpu_dat_o	=	master_dat_i[DWB_ID];	// input [31:0] dwb_dat_i
			assign 	cpu_ack_o	=	master_ack_i[DWB_ID]; 	// input  dwb_ack_i

			assign	master_stb_o[IWB_ID]		=	1'b0; 	// 	  dwb_stb_o
			assign 	master_sel_o[IWB_ID] 	=	1'b0;	// 	 [3:0] dwb_sel_o
			assign	master_dat_o[IWB_ID] 	=	0;	// 	 [31:0] dwb_dat_o
			assign	master_cyc_o[IWB_ID] 	=	1'b0;	// 	  dwb_cyc_o
			assign	master_wre_o[IWB_ID]		=	1'b0;
			assign	master_adr_o[IWB_ID][`AEMB_IWB_ADRR_RANG]		=	0; 	// 	 [AEMB_DWB-1:2] dwb_adr_o
			assign 	master_tag_o[IWB_ID] 	= 3'b000;  // clasic wishbone without  burst 
				


	end
		//synthesis translate_on
	
	
	if (RAM_EN) begin :ram_gen
	
	 prog_ram #(
		.DATA_WIDTH(32),
		.ADDR_WIDTH(AEMB_RAM_WIDTH_IN_WORD),
		.CORE_NUMBER(CORE_NUMBER),
		.SW_X_ADDR	(SW_X_ADDR),
		.SW_Y_ADDR	(SW_Y_ADDR)

	)
	 the_aemb_ram
	(
		
		.clk				(clk),
		.reset			(reset),
		
	
		//port A
		.sa_dat_i		(slave_dat_i	[RAM_ID]),
		.sa_sel_i		(slave_sel_i	[RAM_ID]),
		.sa_addr_i		(slave_addr_i	[RAM_ID][`RAM_ADDR_RANG]),
		.sa_stb_i		(slave_stb_i	[RAM_ID]),
		.sa_we_i			(slave_we_i		[RAM_ID]),
		.sa_cti_i		(slave_tag_i	[RAM_ID]),
		.sa_dat_o		(slave_dat_o 	[RAM_ID]),
		.sa_ack_o		(slave_ack_o 	[RAM_ID]),
		
		//port B
		.sb_dat_i		(	),
		.sb_sel_i		(	),
		.sb_addr_i		(	),
		.sb_stb_i		(	),
		.sb_we_i			(	),
		.sb_cti_i		(	),
		.sb_dat_o		(	),
		.sb_ack_o		(	)
	);
	end //RAM_EN
	
	if(GPIO_EN) begin : gpio_gen

	
		gpio #(
			.DATA_WIDTH		(DATA_WIDTH),
			.SEL_WIDTH		(SEL_WIDTH),
			.IO_EN			(IO_EN),
			.I_EN				(I_EN),
			.O_EN				(O_EN),
			.IO_PORT_WIDTH	(IO_PORT_WIDTH),
			.I_PORT_WIDTH	(I_PORT_WIDTH),
			.O_PORT_WIDTH	(O_PORT_WIDTH)
		)
		the_gpio
		(
			.clk			(clk),
			.reset		(reset),
			.sa_dat_i	(slave_dat_i	[GPIO_ID]),
			.sa_sel_i	(slave_sel_i	[GPIO_ID]),
			.sa_addr_i	(slave_addr_i	[GPIO_ID][GPIO_ADDR_WIDTH-1	:0]),
			.sa_stb_i	(slave_stb_i	[GPIO_ID]),
			.sa_we_i		(slave_we_i		[GPIO_ID]),
			.sa_ack_o	(slave_ack_o	[GPIO_ID]),
			.sa_dat_o	(slave_dat_o	[GPIO_ID]),
			.gpio_io		(gpio_io),
			.gpio_i		(gpio_i),
			.gpio_o		(gpio_o)
		);
	
	end //GPIO_EN
	else begin 
		assign	gpio_io		= {IO_WIDTH{1'bX}};
		assign	gpio_o		= {O_WIDTH{1'bX}};
	end
	
	
	if(NOC_EN) begin	: noc_gen
	
		ni #(
			.TOPOLOGY				(TOPOLOGY), 
			.ROUTE_ALGRMT			(ROUTE_ALGRMT),
			.VC_NUM_PER_PORT		(VC_NUM_PER_PORT),
			.PYLD_WIDTH 			(PYLD_WIDTH),
			.BUFFER_NUM_PER_VC	(BUFFER_NUM_PER_VC),
			.PORT_NUM				(PORT_NUM),
			.X_NODE_NUM				(X_NODE_NUM),
			.Y_NODE_NUM				(Y_NODE_NUM),
			.SW_X_ADDR				(SW_X_ADDR),
			.SW_Y_ADDR				(SW_Y_ADDR),
			.NIC_CONNECT_PORT		(NIC_CONNECT_PORT),
			.RAM_WIDTH_IN_WORD	(AEMB_RAM_WIDTH_IN_WORD),
			.W_DATA_WIDTH			(DATA_WIDTH	),
			.WS_ADDR_WIDTH			(NOC_S_ADDR_WIDTH)	
		)
		ni_inst
		(
			.reset				(reset),
			.clk					(clk) ,	
			.flit_out			(flit_out) ,	
			.flit_out_wr		(flit_out_wr) ,	
			.credit_in			(credit_in) ,
			.congestion_cmp_i	(congestion_cmp_i),
			.flit_in				(flit_in) ,	
			.flit_in_wr			(flit_in_wr) ,	
			.credit_out			(credit_out) ,	
			
			.s_dat_i				(slave_dat_i	[NOC_S_ID]) ,	
			.s_addr_i			(slave_addr_i	[NOC_S_ID][`NOC_S_ADDR_RANG]) ,
			.s_stb_i				(slave_stb_i 	[NOC_S_ID]) ,	
			.s_we_i				(slave_we_i 	[NOC_S_ID]) ,	
			.s_dat_o				(slave_dat_o 	[NOC_S_ID]) ,	
			.s_ack_o				(slave_ack_o	[NOC_S_ID]) ,	
			
			.m_sel_o				(master_sel_o	[NOC_M_ID]), 
			.m_dat_o				(master_dat_o	[NOC_M_ID]) ,
			.m_addr_o			(master_adr_o	[NOC_M_ID][AEMB_RAM_WIDTH_IN_WORD-1		: 0]) ,	
			.m_cti_o				(master_tag_o	[NOC_M_ID]) ,	
			.m_stb_o				(master_stb_o	[NOC_M_ID]) ,
			.m_cyc_o				(master_cyc_o	[NOC_M_ID]) ,	
			.m_we_o				(master_wre_o	[NOC_M_ID]) ,	
			.m_dat_i				(master_dat_i	[NOC_M_ID]) ,	
			.m_ack_i				(master_ack_i	[NOC_M_ID]) ,
			.irq					(ni_irq)
		);

		assign master_adr_o [NOC_M_ID] [ADDR_WIDTH-1	:	AEMB_RAM_WIDTH_IN_WORD] = {ADDR_WIDTH-AEMB_RAM_WIDTH_IN_WORD{1'b0}};
	end // NOC_EN 
	else begin 
		assign	flit_out		={FLIT_WIDTH{1'bX}};
		assign	flit_out_wr	=	1'bX;
		assign	credit_out	={VC_NUM_PER_PORT{1'bX}};	
		assign	ni_irq		=	1'b0;
	end
	
	if(EXT_INT_EN) begin : ext_in_gen
		
	
		ext_int #(
			.EXT_INT_NUM	(EXT_INT_NUM),//max 32
			.ADDR_WIDTH		(EXT_INT_ADDR_WIDTH)
		)the_ext_int
		(
			.clk			(clk),
			.reset		(reset),
			.sa_dat_i	(slave_dat_i	[EXT_INT_ID][EXT_INT_NUM-1		:0]) ,
			.sa_sel_i	(slave_sel_i	[EXT_INT_ID]),
			.sa_addr_i	(slave_addr_i	[EXT_INT_ID][EXT_INT_ADDR_WIDTH-1	:0]) ,
			.sa_stb_i	(slave_stb_i 	[EXT_INT_ID]) ,	
			.sa_we_i		(slave_we_i 	[EXT_INT_ID]) ,	
			.sa_dat_o	(slave_dat_o 	[EXT_INT_ID][EXT_INT_NUM-1		:0]) ,	
			.sa_ack_o	(slave_ack_o	[EXT_INT_ID]) ,	
						
			.ext_int_i	(ext_int_i),  
			.ext_int_o 	(ext_int_irq)//output to the interrupt controller
		);
	
		assign slave_dat_o [EXT_INT_ID][DATA_WIDTH-1	:EXT_INT_NUM] = {(DATA_WIDTH-EXT_INT_NUM){1'b0}};
	
	end else begin // EXT_INT_EN
		assign ext_int_irq = 1'b0;
	end
	
	if(TIMER_EN) begin :timer_gen
	//	wire 	timer_irq;
		
		timer #(
			.ADDR_WIDTH	(TIMER_ADDR_WIDTH)
		)
		the_timer
		(
			.clk			(clk),
			.reset		(reset),
			.sa_dat_i	(slave_dat_i	[TIMER_ID]) ,
			.sa_sel_i	(slave_sel_i	[TIMER_ID]),
			.sa_addr_i	(slave_addr_i	[TIMER_ID][TIMER_ADDR_WIDTH-1	:0]) ,
			.sa_stb_i	(slave_stb_i 	[TIMER_ID]) ,	
			.sa_we_i		(slave_we_i 	[TIMER_ID]) ,	
			.sa_dat_o	(slave_dat_o 	[TIMER_ID]) ,	
			.sa_ack_o	(slave_ack_o	[TIMER_ID]),
			.irq			(timer_irq)
		);
	
	end else begin //TIMER_EN
		assign timer_irq	= 1'b0;
	end
	
	assign int_ctrl_in	=	{ext_int_irq,timer_irq,ni_irq};	
	
	if(INT_CTRL_EN) begin	: int_ctrl_gen 
		int_ctrl #(
			.NOC_EN			(NOC_EN),
			.EXT_INT_EN		(EXT_INT_EN),
			.TIMER_EN		(TIMER_EN),
			.INT_NUM			(INT_CTRL_INT_NUM),
			.DATA_WIDTH		(DATA_WIDTH),
			.ADDR_WIDTH		(INT_CTRL_ADDR_WIDTH)
		)
		int_ctrl_gen	
		(
			.clk			(clk),
			.reset		(reset),
			.sa_dat_i	(slave_dat_i	[INT_CTRL_ID]) ,
			.sa_sel_i	(slave_sel_i	[INT_CTRL_ID]),
			.sa_addr_i	(slave_addr_i	[INT_CTRL_ID][INT_CTRL_ADDR_WIDTH-1	:0]) ,
			.sa_stb_i	(slave_stb_i 	[INT_CTRL_ID]) ,	
			.sa_we_i		(slave_we_i 	[INT_CTRL_ID]) ,	
			.sa_dat_o	(slave_dat_o 	[INT_CTRL_ID]) ,	
			.sa_ack_o	(slave_ack_o	[INT_CTRL_ID]),
			
			.int_i		(int_ctrl_in),
			.int_o		(sys_int_i)
		);
		 	
		
	end //INT_CTRL_EN
	else begin 
		assign sys_int_i= 1'b0;
	
	end

endgenerate

 wishbone_bus #(
	
	.RAM_EN					(RAM_EN),
	.NOC_EN					(NOC_EN),
	.GPIO_EN					(GPIO_EN),
	.EXT_INT_EN				(EXT_INT_EN),
	.TIMER_EN				(TIMER_EN),
	.INT_CTRL_EN			(INT_CTRL_EN),
	
	.MASTER_NUM_			(MASTER_NUM),
	.SLAVE_NUM_				(SLAVE_NUM),				
	.ADDR_WIDTH				(ADDR_WIDTH),	
	.DATA_WIDTH				(DATA_WIDTH),	// maximum data width
	.SEL_WIDTH				(SEL_WIDTH)

	
	
)
the_bus
(

	.slave_adr_o_array	(bus_slave_adr_o) 			,	// output [ADDR_WIDTH-1:0] slave_adr_o
	.slave_dat_o_array	(bus_slave_dat_o) 			,	// output [DATA_WIDTH-1:0] slave_dat_o
	.slave_sel_o_array	(bus_slave_sel_o) 			,	// output [SEL_WIDTH-1:0] slave_sel_o
	.slave_tag_o_array	(bus_slave_tag_o)	,
	.slave_we_o_array		(bus_slave_we_o) 			,	// output  slave_we_o
	.slave_cyc_o_array	(bus_slave_cyc_o) 			,	// output  slave_cyc_o
	.slave_stb_o_array	(bus_slave_stb_o) 	,	// output [SLAVE_NUM-1:0] slave_stb_o_array
	.slave_dat_i_array	(bus_slave_dat_i) 	,	// input [SLAVE_DATA_ARRAY_WIDTH-1:0] slave_dat_i_array
	.slave_ack_i_array	(bus_slave_ack_i) 	,	// input [SLAVE_NUM-1:0] slave_ack_i_array
	.slave_err_i_array	(bus_slave_err_i) 	,	// input [SLAVE_NUM-1:0] slave_err_i_array
	.slave_rty_i_array	(bus_slave_rty_i) 	,	// input [SLAVE_NUM-1:0] slave_rty_i_array
	.master_dat_o_array	(bus_master_dat_o) 		,	// output [DATA_WIDTH-1:0] master_dat_o
	.master_ack_o_array	(bus_master_ack_o) ,	// output [MASTER_NUM-1:0] master_ack_o_array
	.master_err_o_array	(bus_master_err_o) ,	// output [MASTER_NUM-1:0] master_err_o_array
	.master_rty_o_array	(bus_master_rty_o) ,	// output [MASTER_NUM-1:0] master_rty_o_array
	.master_adr_i_array	(bus_master_adr_i) ,	// input [MASTER_ADDR_ARRAY_WIDTH-1:0] master_adr_i_array
	.master_dat_i_array	(bus_master_dat_i) ,	// input [MASTER_DATA_ARRAY_WIDTH-1:0] master_dat_i_array
	.master_sel_i_array	(bus_master_sel_i) ,	// input [MASTER_SEL_WIDTH_ARRAY-1:0] master_sel_i_array
	.master_tag_i_array	(bus_master_tag_i) ,
	.master_we_i_array	(bus_master_we_i) 	,	// input [MASTER_NUM-1:0] master_we_i_array
	.master_stb_i_array	(bus_master_stb_i) ,	// input [MASTER_NUM-1:0] master_stb_i_array
	.master_cyc_i_array	(bus_master_cyc_i) ,	// input [MASTER_NUM-1:0] master_cyc_i_array
	.clk						(clk) 					,	// input  clk
	.reset					(reset) 						// input  reset
	
);


genvar i;

generate 
	for (i=0;	i<SLAVE_NUM;	i=i+1'b1) begin :slaveloop
		
		assign slave_addr_i		[i]   = bus_slave_adr_o [(i+1)*ADDR_WIDTH-1	:	i*ADDR_WIDTH];
		assign slave_dat_i		[i]	= 	bus_slave_dat_o [((i+1)*DATA_WIDTH)-1	:	i*DATA_WIDTH]; 
		assign slave_we_i			[i]	= 	bus_slave_we_o [i];	
		assign slave_stb_i		[i]	=	bus_slave_stb_o[i];			
		assign slave_sel_i		[i]	=	bus_slave_sel_o [((i+1)*SEL_WIDTH)-1	:	i*SEL_WIDTH]; 
		assign slave_tag_i		[i]	=	bus_slave_tag_o [((i+1)*TAG_WIDTH)-1	:	i*TAG_WIDTH]; 
		
		assign bus_slave_dat_i  [((i+1)*DATA_WIDTH)-1	:	i*DATA_WIDTH] = slave_dat_o [i];
		assign bus_slave_ack_i  [i]	 =	slave_ack_o [i];
	
	end
	for (i=0;	i<MASTER_NUM;	i=i+1'b1) begin :masterloop


		assign master_dat_i		[i] 	 =	bus_master_dat_o [((i+1)*DATA_WIDTH)-1	:	i*DATA_WIDTH];
		assign master_ack_i		[i]	=	bus_master_ack_o 	[i];
		if (ERR_EN_ARRAY&(1<<i))assign master_err_i		[i]	=	bus_master_err_o 	[i];
		if (RTY_EN_ARRAY&(1<<i))assign master_rty_i		[i]	=	bus_master_rty_o	[i];
		assign bus_master_adr_i	[((i+1)*ADDR_WIDTH)-1	:	i*ADDR_WIDTH] = master_adr_o[i];	
		assign bus_master_dat_i	[((i+1)*DATA_WIDTH)-1	:	i*DATA_WIDTH] = master_dat_o[i]; 
		assign bus_master_sel_i	[((i+1)*SEL_WIDTH)-1		:	i*SEL_WIDTH]  = master_sel_o[i];
		assign bus_master_tag_i	[((i+1)*TAG_WIDTH)-1		:	i*TAG_WIDTH]  = master_tag_o[i];
		assign bus_master_we_i	[i] = master_wre_o	[i];		
		assign bus_master_stb_i	[i] = master_stb_o[i];
		assign bus_master_cyc_i	[i] = master_cyc_o[i];
	end
endgenerate





endmodule

