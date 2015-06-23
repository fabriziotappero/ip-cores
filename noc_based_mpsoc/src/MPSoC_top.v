/*********************************************************************
							
	File: MPSoC_top.v 
	
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
	The NoC based MPSoC top module for DE2-115 Altra board. The global 
	parameters for NoC are defined in "define.v" file. 

	Info: monemi@fkegraduate.utm.my

****************************************************************/



`include "define.v"
module MPSoC_top #(
	parameter NI_CTRL_SIMULATION		=	"aeMB", 
	/*"aeMB" or "testbench". 
		Definig it as " aeMB" will generate the same MPSoC for both simulation and 
		implementation.
		Defining it as "testbench" will remove the processors 
		in simulation. Hence, the simulation time will be decreased. The tasks to control
		NI pins are written in tasks.V file */
	//noc parameter 
	parameter TOPOLOGY					=	`TOPOLOGY_DEF,
	parameter ROUTE_ALGRMT				=	`ROUTE_ALGRMT_DEF, //"XY_CLASSIC" or "BALANCE_DOR" or "ADAPTIVE_XY"
	parameter VC_NUM_PER_PORT 			=	`VC_NUM_PER_PORT_DEF ,
	parameter PYLD_WIDTH 				=	`PYLD_WIDTH_DEF,
	parameter BUFFER_NUM_PER_VC		=	`BUFFER_NUM_PER_VC_DEF,
	parameter X_NODE_NUM					=	`X_NODE_NUM_DEF,
	parameter Y_NODE_NUM					=	`Y_NODE_NUM_DEF,
	parameter AEMB_RAM_WIDTH_IN_WORD	=	`AEMB_RAM_WIDTH_IN_WORD_DEF,
	parameter NOC_S_ADDR_WIDTH			=	`NOC_S_ADDR_WIDTH_DEF,
	parameter SW_OUTPUT_REGISTERED	=	0,// 1: registered , 0 not registered
	
	// external sdram parameter
	parameter SDRAM_EN					=	`SDRAM_EN_DEF,//  0 : disabled  1: enabled 
	parameter SDRAM_SW_X_ADDR			=	`SDRAM_SW_X_ADDR_DEF,
	parameter SDRAM_SW_Y_ADDR			=	`SDRAM_SW_Y_ADDR_DEF,
	parameter SDRAM_NI_CONNECT_PORT	=	`SDRAM_NI_CONNECT_PORT_DEF, 
	parameter SDRAM_ADDR_WIDTH			=	`SDRAM_ADDR_WIDTH_DEF,
	parameter CAND_VC_SEL_MODE			=	0,
	
	// processors parameter
	//parameter DEV_EN_ARRAY	="IPn:[the specefic value for nth IP];Def:[default value for the rest of IPs]"
	parameter RAM_EN_ARRAY				=	`RAM_EN_ARRAY_DEF,
	parameter NOC_EN_ARRAY				=	`NOC_EN_ARRAY_DEF,
	parameter GPIO_EN_ARRAY				=	`GPIO_EN_ARRAY_DEF,
	parameter EXT_INT_EN_ARRAY			=	`EXT_INT_EN_ARRAY_DEF,
	parameter TIMER_EN_ARRAY			=	`TIMER_EN_ARRAY_DEF,
	parameter INT_CTRL_EN_ARRAY		=	`INT_CTRL_EN_ARRAY_DEF,
	
	//gpio parameters 
	parameter IO_EN_ARRAY				=	`IO_EN_ARRAY_DEF,
	parameter I_EN_ARRAY					=	`I_EN_ARRAY_DEF,
	parameter O_EN_ARRAY					=	`O_EN_ARRAY_DEF,
	parameter EXT_INT_NUM_ARRAY		=	`EXT_INT_NUM_ARRAY_DEF,
	
	parameter IO_PORT_WIDTH_ARRAY		=	`IO_PORT_WIDTH_ARRAY_DEF,
	parameter I_PORT_WIDTH_ARRAY		=	`I_PORT_WIDTH_ARRAY_DEF,
	parameter O_PORT_WIDTH_ARRAY		=	`O_PORT_WIDTH_ARRAY_DEF,
	
	parameter TOTAL_EXT_INT_NUM		=	end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,EXT_INT_NUM_ARRAY)+1,
	parameter TOTAL_IO_WIDTH			=	end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,IO_PORT_WIDTH_ARRAY)+1,
	parameter TOTAL_I_WIDTH				=  end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,I_PORT_WIDTH_ARRAY)+1,
	parameter TOTAL_O_WIDTH				=  end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,O_PORT_WIDTH_ARRAY)+1,
	parameter TOTAL_ROUTERS_NUM		=	X_NODE_NUM * Y_NODE_NUM	
	
	
		
)
(


		input 												CLOCK_50,
		input		[3								:	0]		KEY,
		output	[1								:	0]		LEDG,
		output	[TOTAL_ROUTERS_NUM-2		:	0]		LEDR,
		output	[6								:	0]		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,
		
		// DRAM interface
		output 	[12							:	0]		DRAM_ADDR,
		output	[1								:	0]		DRAM_BA,
		output												DRAM_CAS_N,
		output												DRAM_CKE,
		output												DRAM_CLK,
		output												DRAM_CS_N,
		inout		[31							:	0]		DRAM_DQ,
		output	[3								:	0]		DRAM_DQM,		
		output												DRAM_RAS_N,
		output												DRAM_WE_N
);
	
	`define ADD_FUNCTION 		1
	`include "my_functions.v"


	wire													reset;
	wire													clk;
	wire	[TOTAL_ROUTERS_NUM-2			:0]		led;
	wire 	[3									:0]		ext_int_i;
	wire  												jtag_reset;
	

	assign 	clk		=	CLOCK_50;
	assign 	LEDR		=	led;
	assign	LEDG[0]	=	reset;
	assign 	LEDG[1]	=	jtag_reset;
	assign	reset		=	~KEY[0];
	assign	ext_int_i=	~KEY[3:1];
	
 aeMB_mpsoc the_mpsoc
(
	.reset						(reset | jtag_reset),
	.clk							(clk),
	.ext_int_i					(ext_int_i),
	.gpio_io						(	),
	.gpio_i						(	),
	.gpio_o						({led,HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}	),
	
	.sdram_addr					(DRAM_ADDR),        // sdram_wire.addr
	.sdram_ba					(DRAM_BA),          //           .ba
	.sdram_cas_n				(DRAM_CAS_N),       //           .cas_n
	.sdram_cke					(DRAM_CKE),         //           .cke
	.sdram_cs_n					(DRAM_CS_N),        //           .cs_n
	.sdram_dq					(DRAM_DQ),          //           .dq
	.sdram_dqm					(DRAM_DQM),         //           .dqm
	.sdram_ras_n				(DRAM_RAS_N),       //           .ras_n
	.sdram_we_n					(DRAM_WE_N),        //           .we_n
	.sdram_clk					(DRAM_CLK)		    	//  sdram_clk.clk
	
);


reset_jtag the_reset(
	.probe(),
	.source(jtag_reset)
);



endmodule
