`timescale  1ns/1ps
`include "../define.v"

module ip_testbench ();



reg clk,reset,sys_ena_i,sys_int_i;
wire [55:0] seven_segment;

aeMB_IP soc

(

	.clk					(clk),
	.reset_in			(reset),
	.sys_int_i			(sys_int_i),
	.sys_ena_i			(sys_ena_i),
	.gpio					(seven_segment)
);

	initial begin
		clk = 1'b0;
		forever clk = # 10 ~clk;
	end
	
	initial begin 
	reset =1'b0;
	sys_ena_i =1'b1;
	sys_int_i	=	1'b0;
	
	# 50 
	@(posedge clk )  # 1 reset =1'b1;
	
	#500 
	@(posedge clk )  # 1 reset =1'b0;
	
	
	#100000
	 
	//@(posedge clk )  # 1 reset =1'b1;
	
	#10000
	 
	@(posedge clk )  # 1 reset =1'b0;
	
	
	end
	/*
	
	parameter MASTER_NUM						=	4;	//number of master port
	parameter SLAVE_NUM						=	4;		//number of slave port
	parameter DATA_WIDTH						=	32;	// maximum data width
	parameter SEL_WIDTH						=	2;
	
	 //define the slave address width in soc_define
	
		
	parameter ADDR_WIDTH						=	32;
	parameter SLAVE_DATA_ARRAY_WIDTH		=	DATA_WIDTH * SLAVE_NUM	;
	parameter SLAVE_ADDR_ARRAY_WIDTH		=	ADDR_WIDTH * SLAVE_NUM	;
	parameter SLAVE_SEL_ARRAY_WIDTH		=	SEL_WIDTH  * SLAVE_NUM	; 
	parameter MASTER_DATA_ARRAY_WIDTH	=	DATA_WIDTH * MASTER_NUM	;
	parameter MASTER_ADDR_ARRAY_WIDTH	=	ADDR_WIDTH * MASTER_NUM	;
	parameter MASTER_SEL_ARRAY_WIDTH		=	SEL_WIDTH  * MASTER_NUM;
	
	
	wire  	[SLAVE_ADDR_ARRAY_WIDTH-1		:	0	]	slave_adr_o_array;//
	wire	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	slave_dat_o_array;//
	wire	[SLAVE_SEL_ARRAY_WIDTH-1		:	0	]	slave_sel_o_array;//
	wire	[SLAVE_NUM-1						:	0	]	slave_we_o_array;//
	wire	[SLAVE_NUM-1						:	0	]	slave_cyc_o_array;//
	wire	[SLAVE_NUM-1						:	0	]	slave_stb_o_array;
	
	reg 	[SLAVE_DATA_ARRAY_WIDTH-1		:	0	]	slave_dat_i_array;
	reg		[SLAVE_NUM-1						:	0	]	slave_ack_i_array;
	reg		[SLAVE_NUM-1						:	0	]	slave_err_i_array;
	reg		[SLAVE_NUM-1						:	0	]	slave_rty_i_array;
	
	
	//masters interface
	wire	[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	master_dat_o_array;//
	wire	[MASTER_NUM-1						:	0	]	master_ack_o_array;
	wire	[MASTER_NUM-1						:	0	]	master_err_o_array;
	wire	[MASTER_NUM-1						:	0	]	master_rty_o_array;
	
	
	reg		[MASTER_ADDR_ARRAY_WIDTH-1		:	0	]	master_adr_i_array;
	reg		[MASTER_DATA_ARRAY_WIDTH-1		:	0	]	master_dat_i_array;
	reg		[MASTER_SEL_ARRAY_WIDTH-1		:	0	]	master_sel_i_array;
	reg		[MASTER_NUM-1						:	0	]	master_we_i_array;
	reg		[MASTER_NUM-1						:	0	]	master_stb_i_array;
	reg		[MASTER_NUM-1						:	0	]	master_cyc_i_array;
	
	//system signals
	
	reg 														clk;
	reg 														reset;
	
	`LOG2
		
wishbone_bus wishbone_bus_inst
(
	.slave_adr_o_array(slave_adr_o_array) ,	// wire [SLAVE_ADDR_ARRAY_WIDTH-1:0] slave_adr_o_array
	.slave_dat_o_array(slave_dat_o_array) ,	// wire [SLAVE_DATA_ARRAY_WIDTH-1:0] slave_dat_o_array
	.slave_sel_o_array(slave_sel_o_array) ,	// wire [SLAVE_SEL_ARRAY_WIDTH-1:0] slave_sel_o_array
	.slave_we_o_array(slave_we_o_array) ,	// wire [SLAVE_NUM-1:0] slave_we_o_array
	.slave_cyc_o_array(slave_cyc_o_array) ,	// wire [SLAVE_NUM-1:0] slave_cyc_o_array
	.slave_stb_o_array(slave_stb_o_array) ,	// wire [SLAVE_NUM-1:0] slave_stb_o_array
	.slave_dat_i_array(slave_dat_i_array) ,	// reg [SLAVE_DATA_ARRAY_WIDTH-1:0] slave_dat_i_array
	.slave_ack_i_array(slave_ack_i_array) ,	// reg [SLAVE_NUM-1:0] slave_ack_i_array
	.slave_err_i_array(slave_err_i_array) ,	// reg [SLAVE_NUM-1:0] slave_err_i_array
	.slave_rty_i_array(slave_rty_i_array) ,	// reg [SLAVE_NUM-1:0] slave_rty_i_array
	.master_dat_o_array(master_dat_o_array) ,	// wire [MASTER_DATA_ARRAY_WIDTH-1:0] master_dat_o_array
	.master_ack_o_array(master_ack_o_array) ,	// wire [MASTER_NUM-1:0] master_ack_o_array
	.master_err_o_array(master_err_o_array) ,	// wire [MASTER_NUM-1:0] master_err_o_array
	.master_rty_o_array(master_rty_o_array) ,	// wire [MASTER_NUM-1:0] master_rty_o_array
	.master_adr_i_array(master_adr_i_array) ,	// reg [MASTER_ADDR_ARRAY_WIDTH-1:0] master_adr_i_array
	.master_dat_i_array(master_dat_i_array) ,	// reg [MASTER_DATA_ARRAY_WIDTH-1:0] master_dat_i_array
	.master_sel_i_array(master_sel_i_array) ,	// reg [MASTER_SEL_ARRAY_WIDTH-1:0] master_sel_i_array
	.master_we_i_array(master_we_i_array) ,	// reg [MASTER_NUM-1:0] master_we_i_array
	.master_stb_i_array(master_stb_i_array) ,	// reg [MASTER_NUM-1:0] master_stb_i_array
	.master_cyc_i_array(master_cyc_i_array) ,	// reg [MASTER_NUM-1:0] master_cyc_i_array
	.clk(clk) ,	// reg  clk
	.reset(reset) 	// reg  reset
);

defparam wishbone_bus_inst.MASTER_NUM = 4;
defparam wishbone_bus_inst.SLAVE_NUM = 4;
defparam wishbone_bus_inst.DATA_WIDTH = 32;
defparam wishbone_bus_inst.SEL_WIDTH = 2;
	
	
	always @ (posedge clk) begin
	
			slave_ack_i_array <= master_stb_i_array;
	
	end
	
	
	initial begin
		clk = 1'b0;
		forever clk = # 10 ~clk;
	end
	
	initial begin 
	reset =1'b0;

	slave_dat_i_array = 0;
		slave_ack_i_array = 0;
		slave_err_i_array = 0;
		slave_rty_i_array = 0;
		master_adr_i_array = 0;
		master_dat_i_array = 0;
		master_sel_i_array = 0;
		master_we_i_array = 0;
		master_stb_i_array = 0;
		master_cyc_i_array = 0;
	
	# 50 
	@(posedge clk )  # 1 reset =1'b1;
	
	#500 
	@(posedge clk )  # 1 reset =1'b0;
	#100
	
	@(posedge clk ) #1 
		master_stb_i_array = 1;
		master_cyc_i_array = 1;
		master_adr_i_array = 1;
		
		
	@(posedge clk ) #1 
		master_stb_i_array = 3;
		master_cyc_i_array = 3;
		master_adr_i_array = 1;
	
	#500 
	@(posedge clk ) 
		master_stb_i_array = 2;
		master_cyc_i_array = 2;
		master_adr_i_array = 1;
	

	
	end
	
	
	
	
	*/
	
	
	
	
	
	
	
	
	
endmodule	
