/*********************************************************************
							
	File: testbench.v 
	
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
	A testbench for top-level design. This testbench can be used to simulate 
	a real life application. running the ./run file in sw folder 
	will copy the generated mif files in simulation folder which will be read 
	by modelsim.  However, due to simulating the aemb processors it is slow
	
	Info: monemi@fkegraduate.utm.my
*********************************************************************/





`timescale  1ns/1ps
`include "define.v"

module testbench_mpsoc ();
parameter 	NI_CTRL_SIMULATION		=	"aeMB";
	/*"aeMB" or "testbench". 
		Definig it as " aeMB" will generate the same MPSoC for both simulation and 
		implementation.
		Defining it as "testbench" will remove the processors 
		in simulation. Hence, the simulation time will be decreased. The tasks to control
		NI pins are written in tasks.v file */
	parameter TOPOLOGY					=	`TOPOLOGY_DEF;
	parameter ROUTE_ALGRMT				=	`ROUTE_ALGRMT_DEF;
	parameter X_NODE_NUM					=	`X_NODE_NUM_DEF;
	parameter Y_NODE_NUM					=	`Y_NODE_NUM_DEF;
	parameter PORT_NUM					=	5;
	parameter AEMB_RAM_WIDTH_IN_WORD	=	`AEMB_RAM_WIDTH_IN_WORD_DEF;
	parameter TOTAL_ROUTERS_NUM		=	 X_NODE_NUM		* Y_NODE_NUM;	
	parameter AEMB_DWB					=	`AEMB_DWB_DEF;	
	parameter SDRAM_EN					=	`SDRAM_EN_DEF;//  0 : disabled  1: enabled 
	parameter CPU_ADR_WIDTH 			=	AEMB_DWB-2;
	parameter CPU_ADDR_ARRAY_WIDTH 	=	CPU_ADR_WIDTH * TOTAL_ROUTERS_NUM;
	parameter CPU_DATA_ARRAY_WIDTH	=	32 * TOTAL_ROUTERS_NUM;

	parameter RAM_EN_ARRAY				=	`RAM_EN_ARRAY_DEF;
	parameter NOC_EN_ARRAY				=	`NOC_EN_ARRAY_DEF;
	parameter GPIO_EN_ARRAY				=	`GPIO_EN_ARRAY_DEF;
	parameter EXT_INT_EN_ARRAY			=	`EXT_INT_EN_ARRAY_DEF;
	parameter TIMER_EN_ARRAY			=	`TIMER_EN_ARRAY_DEF;
	parameter INT_CTRL_EN_ARRAY		=	`INT_CTRL_EN_ARRAY_DEF;
	
	//gpio parameters 
	parameter IO_EN_ARRAY				=	`IO_EN_ARRAY_DEF;
	parameter I_EN_ARRAY					=	`I_EN_ARRAY_DEF;
	parameter O_EN_ARRAY					=	`O_EN_ARRAY_DEF;
	parameter EXT_INT_NUM_ARRAY		=	`EXT_INT_NUM_ARRAY_DEF;
	
	parameter IO_PORT_WIDTH_ARRAY		=	`IO_PORT_WIDTH_ARRAY_DEF;
	parameter I_PORT_WIDTH_ARRAY		=	`I_PORT_WIDTH_ARRAY_DEF;
	parameter O_PORT_WIDTH_ARRAY		=	`O_PORT_WIDTH_ARRAY_DEF;
	
	
	localparam X_NODE_NUM_WIDTH		=	log2(X_NODE_NUM);
	localparam Y_NODE_NUM_WIDTH		=	log2(Y_NODE_NUM);
	localparam PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM);
	
	//`define	ADD_BUS_LOCALPARAM			1
	//`include "parameter.v"
	
	`define ADD_FUNCTION 		1
	`include "my_functions.v"
		
	`LOG2

	localparam TOTAL_EXT_INT_NUM		=	end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,EXT_INT_NUM_ARRAY)+1;
	localparam TOTAL_IO_WIDTH			=	end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,IO_PORT_WIDTH_ARRAY)+1;
	localparam TOTAL_I_WIDTH			=  end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,I_PORT_WIDTH_ARRAY)+1;
	localparam TOTAL_O_WIDTH			=  end_loc_in_array(X_NODE_NUM-1,Y_NODE_NUM-1,X_NODE_NUM,O_PORT_WIDTH_ARRAY)+1;	
		
		
	reg 		reset ,clk;
	reg		[TOTAL_EXT_INT_NUM-1				:0]	ext_int_i;
	wire		[TOTAL_IO_WIDTH-1					:0]	gpio_io;
	reg		[TOTAL_I_WIDTH-1					:0]	gpio_i;
	wire		[TOTAL_O_WIDTH-1					:0]	gpio_o;


	
	
		
	

	
	
	
		


		wire  [12								:0] 		sdram_addr;        // sdram_wire.addr
		wire  [1									:0]  		sdram_ba;          //           .ba
		wire         										sdram_cas_n;       //           .cas_n
		wire         										sdram_cke;         //           .cke
		wire         										sdram_cs_n;        //           .cs_n
		wire  [31								:0]		sdram_dq;          //           .dq
		wire  [3									:0] 		sdram_dqm;         //           .dqm
		wire         										sdram_ras_n;       //           .ras_n
		wire         										sdram_we_n;        //           .we_n
		wire         										sdram_clk;		    //  sdram_clk.clk

generate 
	if (SDRAM_EN) begin 
	
		
	
		sdram_sdram_controller_test_component sdram_test_component(
			 // regs:
			.clk			(clk),
			.zs_addr		(sdram_addr),
			.zs_ba		(sdram_ba),
			.zs_cas_n	(sdram_cas_n),
			.zs_cke		(sdram_cke),
			.zs_cs_n		(sdram_cs_n),
			.zs_dqm		(sdram_dqm),
			.zs_ras_n	(sdram_ras_n),
			.zs_we_n		(sdram_we_n),
			// wires:
			.zs_dq		(sdram_dq)
		);
	end
	endgenerate
	
	

aeMB_mpsoc #(
	.NI_CTRL_SIMULATION		(NI_CTRL_SIMULATION),
	.TOPOLOGY					(TOPOLOGY),
	.ROUTE_ALGRMT				(ROUTE_ALGRMT),
	.X_NODE_NUM					(X_NODE_NUM),
	.Y_NODE_NUM					(Y_NODE_NUM),
	.AEMB_RAM_WIDTH_IN_WORD	(AEMB_RAM_WIDTH_IN_WORD),
	.AEMB_DWB					(AEMB_DWB),	
	.SDRAM_EN					(SDRAM_EN),
	.RAM_EN_ARRAY				(RAM_EN_ARRAY),
	.NOC_EN_ARRAY				(NOC_EN_ARRAY),
	.GPIO_EN_ARRAY				(GPIO_EN_ARRAY),
	.EXT_INT_EN_ARRAY			(EXT_INT_EN_ARRAY),
	.TIMER_EN_ARRAY			(TIMER_EN_ARRAY),
	.INT_CTRL_EN_ARRAY		(INT_CTRL_EN_ARRAY),
	.IO_EN_ARRAY				(IO_EN_ARRAY),
	.I_EN_ARRAY					(I_EN_ARRAY),
	.O_EN_ARRAY					(O_EN_ARRAY),
	.EXT_INT_NUM_ARRAY		(EXT_INT_NUM_ARRAY),
	.IO_PORT_WIDTH_ARRAY		(IO_PORT_WIDTH_ARRAY),
	.I_PORT_WIDTH_ARRAY		(I_PORT_WIDTH_ARRAY),
	.O_PORT_WIDTH_ARRAY		(O_PORT_WIDTH_ARRAY)
	
)
	aeMB_mpsoc_inst
(
	.reset						(reset) ,	// reg  
	.clk							(clk) ,	// reg  
	.ext_int_i					(ext_int_i),
	.gpio_io						(gpio_io),
	.gpio_i						(gpio_i),
	.gpio_o						(gpio_o),
		
	.sdram_addr					(sdram_addr) ,	// wire [12:0] sdram_addr
	.sdram_ba					(sdram_ba) ,	// wire [1:0] sdram_ba
	.sdram_cas_n				(sdram_cas_n) ,	// wire  sdram_cas_n
	.sdram_cke					(sdram_cke) ,	// wire  sdram_cke
	.sdram_cs_n					(sdram_cs_n) ,	// wire  sdram_cs_n
	.sdram_dq					(sdram_dq) ,	// inout [31:0] sdram_dq
	.sdram_dqm					(sdram_dqm) ,	// wire [3:0] sdram_dqm
	.sdram_ras_n				(sdram_ras_n) ,	// wire  sdram_ras_n
	.sdram_we_n					(sdram_we_n) ,	// wire  sdram_we_n
	.sdram_clk					(sdram_clk) 	// ou
	
	//synthesis translate_off 
	//In case we want to handle NI interface using testbench not aeMB 
	,
	
	.cpu_adr_i_array			(),
   .cpu_cyc_i					(),		
   .cpu_dat_i_array			(),			
   .cpu_sel_i_array			(),		
   .cpu_stb_i					(),		
   .cpu_wre_i					(),	
	
	.cpu_ack_o					(),		
   .cpu_dat_o_array			()
	
	
		
	//synthesis translate_on
	
	
	
	
);





	
	
	
	

	

initial begin 
	clk = 1'b0;
	forever clk = #10 ~clk;
end

initial begin
	reset=1;
	ext_int_i=0;
	#50
	reset=0;
end


endmodule
