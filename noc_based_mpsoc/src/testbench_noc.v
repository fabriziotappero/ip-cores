/*********************************************************************
							
	File: testbench_noc.v 
	
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
	testing the NoC itself. The NoC NI control signals are controlled by 
	testbench file. Hence, the processors are not included in simulation. 
	In this example  four cores are sending packets to the one core. 
	
	Info: monemi@fkegraduate.utm.my
*********************************************************************/






`timescale  1ns/1ps
`include "define.v"

module testbench_noc ();
	parameter 	NI_CTRL_SIMULATION		=	"testbench"; //"aeMB";
	/*"aeMB" or "testbench". 
		Definig it as " aeMB" will generate the same MPSoC for both simulation and 
		implementation.
		Defining it as "testbench" will remove the processors 
		in simulation. Hence, the simulation time will be decreased. The tasks to control
		NI pins are written in tasks.V file */
	parameter TOPOLOGY				   =	`TOPOLOGY_DEF; //"MESH" or "TORUS"
	parameter ROUTE_ALGRMT			=	`ROUTE_ALGRMT_DEF;
	parameter X_NODE_NUM					=	4;//`X_NODE_NUM_DEF;
	parameter Y_NODE_NUM					=	4;//`Y_NODE_NUM_DEF;
	parameter PORT_NUM					=	5;
	parameter AEMB_RAM_WIDTH_IN_WORD	=	`AEMB_RAM_WIDTH_IN_WORD_DEF;
	parameter TOTAL_ROUTERS_NUM		=	 X_NODE_NUM		* Y_NODE_NUM;	
	parameter AEMB_DWB					=	`AEMB_DWB_DEF;	
	parameter SDRAM_EN					=	`SDRAM_EN_DEF;//  0 : disabled  1: enabled 
	parameter CPU_ADR_WIDTH 			=	AEMB_DWB-2;
	parameter CPU_ADDR_ARRAY_WIDTH 	=	CPU_ADR_WIDTH * TOTAL_ROUTERS_NUM;
	parameter CPU_DATA_ARRAY_WIDTH	=	32 * TOTAL_ROUTERS_NUM;
	
	parameter RAM_EN_ARRAY				=	"Def:1";
	parameter NOC_EN_ARRAY				=	"Def:1";
	parameter GPIO_EN_ARRAY				=	"Def:1";
	parameter EXT_INT_EN_ARRAY			=	"IP0_0:1;Def:0";
	parameter TIMER_EN_ARRAY			=	"IP0_0:1;Def:0";
	parameter INT_CTRL_EN_ARRAY		=	"IP0_0:1;Def:0";
	
	//gpio parameters 
	parameter IO_EN_ARRAY				=	"Def:0";
	parameter I_EN_ARRAY					=	"Def:0";
	parameter O_EN_ARRAY					=	"IP0_1:0;Def:1";
	parameter EXT_INT_NUM_ARRAY		=	"IP0_0:3;Def:0";//max 32
	
	parameter IO_PORT_WIDTH_ARRAY		=	"Def:1";
	parameter I_PORT_WIDTH_ARRAY		=	"Def:0";
	parameter O_PORT_WIDTH_ARRAY		=	"IP0_0:7,7,7,7,7,7,7,7;IP0_1:0;Def:1";
	
	
	
	localparam X_NODE_NUM_WIDTH		=	log2(X_NODE_NUM);
	localparam Y_NODE_NUM_WIDTH		=	log2(Y_NODE_NUM);
	localparam PORT_NUM_BCD_WIDTH		=	log2(PORT_NUM);
	
	//generate the base addresses
	`define	ADD_BUS_LOCALPARAM			1
	localparam 	RAM_EN			=			1;
	localparam 	NOC_EN			=			1;
	localparam 	GPIO_EN			=			1;
	localparam 	EXT_INT_EN		=			1;
	localparam 	TIMER_EN			=			1;
	localparam 	INT_CTRL_EN		=			1;
	
	
	`include "parameter.v"
	
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

	
	
	wire 	[CPU_ADDR_ARRAY_WIDTH-1		:0] 		cpu_adr_i_array;
   reg	[TOTAL_ROUTERS_NUM-1			:0]		cpu_cyc_i;		
   wire 	[CPU_DATA_ARRAY_WIDTH-1		:0] 		cpu_dat_i_array;		
   wire 	[TOTAL_ROUTERS_NUM*4-1		:0] 		cpu_sel_i_array;		
   reg	[TOTAL_ROUTERS_NUM-1			:0]		cpu_stb_i;		
   reg	[TOTAL_ROUTERS_NUM-1			:0]		cpu_wre_i;	
	
	wire	[TOTAL_ROUTERS_NUM-1			:0]		cpu_ack_o;		
   wire 	[CPU_DATA_ARRAY_WIDTH-1		:0]		cpu_dat_o_array;		
	
	reg	[AEMB_DWB-1						:2] 		cpu_adr_i	[TOTAL_ROUTERS_NUM-1			:0];	
   reg	[31								:0] 		cpu_dat_i	[TOTAL_ROUTERS_NUM-1			:0];			
   reg 	[3									:0] 		cpu_sel_i	[TOTAL_ROUTERS_NUM-1			:0];			
	wire 	[31								:0]		cpu_dat_o	[TOTAL_ROUTERS_NUM-1			:0];			
	

	
	`include "NoC/tasks.v"
	
		
genvar x,y;
generate 
	for	(x=0;	x<X_NODE_NUM; x=x+1) begin :x_loop1
		for	(y=0;	y<Y_NODE_NUM;	y=y+1) begin: y_loop1
			
				assign cpu_adr_i_array 	[(`CORE_NUM(x,y)+1)*(CPU_ADR_WIDTH)-1			: `CORE_NUM(x,y)*CPU_ADR_WIDTH] = cpu_adr_i	 			[`CORE_NUM(x,y)];
				assign cpu_dat_i_array [(`CORE_NUM(x,y)+1)*32-1			: `CORE_NUM(x,y)*32	] = cpu_dat_i				[`CORE_NUM(x,y)];
				assign cpu_sel_i_array [(`CORE_NUM(x,y)+1)*4-1			: `CORE_NUM(x,y)*4	] = cpu_sel_i				[`CORE_NUM(x,y)];
				assign cpu_dat_o	[`CORE_NUM(x,y)] = cpu_dat_o_array		[(`CORE_NUM(x,y)+1)*32-1	: `CORE_NUM(x,y)*32] ;
			
		end
	end
endgenerate

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
	.reset						(reset),	// reg  
	.clk							(clk),	// reg 
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
	
	.cpu_adr_i_array			(cpu_adr_i_array),
   .cpu_cyc_i					(cpu_cyc_i),		
   .cpu_dat_i_array			(cpu_dat_i_array),			
   .cpu_sel_i_array			(cpu_sel_i_array),		
   .cpu_stb_i					(cpu_stb_i),		
   .cpu_wre_i					(cpu_wre_i),	
	
	.cpu_ack_o					(cpu_ack_o),		
   .cpu_dat_o_array			(cpu_dat_o_array)
	
	
		
	//synthesis translate_on
	
	
	
	
);





	
	
	
	genvar i;
	generate 
	for(i=0; i< TOTAL_ROUTERS_NUM; i=i+1) begin : ll
		initial begin
			cpu_sel_i		 [i]	= 4'b1111;
			cpu_adr_i		 [i]	= 0; 
			cpu_stb_i		 [i]	=	1'b0;
			cpu_cyc_i		 [i]	=	1'b0;
			cpu_wre_i		 [i]	=	1'b0;	
			cpu_dat_i		 [i]	= 0;
		end
	end
	endgenerate


	

initial begin 
	clk = 1'b0;
	forever clk = #10 ~clk;
end

initial begin
	reset=1;
	#50
	reset=0;
end

//injecting packets 
integer	counter1;
	initial begin
		
	# 200
	
	for(counter1 = 0; counter1 <100; counter1 =counter1 +1'b1) begin
	  #20
	send_pck( 0,2,3,2,20,counter1* 21*4);	

	
	
	end
	
	end
	
	
	integer	counter3;
	initial begin
		
	# 200
	
	for(counter3 = 0; counter3 <100; counter3 =counter3 +1'b1) begin
	  #20
	send_pck( 1,2,3,2,20,counter3* 21*4);	

	
	
	end
	
	end
	
	integer	counter4;
	initial begin
		
	# 200
	
	for(counter4 = 0; counter4 <100; counter4 =counter4 +1'b1) begin
	  #20
	send_pck( 1,3,3,2,20,counter4* 21*4);	

	
	
	end
	
	end
	
	
	integer	counter5;
	initial begin
		
	# 200
	
	for(counter5 = 0; counter5 <100; counter5 =counter5 +1'b1) begin
	  #20
	send_pck( 2,2,3,2,20,counter5* 21*4);	

	
	
	end
	
	end
	
//sinking pakets
	
	integer	counter2;
	initial begin
		# 300
		for(counter2 = 0; counter2 <400; counter2 =counter2 +1'b1) begin
			
			recive_pck(3,2,200,counter2 *21*4);
			
			$display("total of %d pcks has been recieved",counter2+1);
			
		end
	end
	



endmodule
