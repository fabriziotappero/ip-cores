/*********************************************************************
							
	File: gpio.v 
	
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
	a simple wishbone compatible output/input port 
	each port has three registers. 
	
	  addr
		0	DIR_REG							
		1	WRITE_REG	port 0 					
		2	READ_REG		
		
		32	DIR_REG		
		33	WRITE_REG	port 1
		34	READ_REG	
		.
		.
		.
		
	Info: monemi@fkegraduate.utm.my

****************************************************************/


	`include "../define.v"

	`define PORT_WIDTH(PORT,i)				 	 extract_value(PORT,i)
	`define PORT_LOC_START(PORT,i)			 start_loc(PORT,i)
	`define PORT_LOC_END(PORT,i)				`PORT_LOC_START(PORT,i)+ `PORT_WIDTH(PORT,i) -1'b1
	`define PORT_LOC(PORT,i)					`PORT_LOC_END(PORT,i)	: `PORT_LOC_START(PORT,i)
	

module gpio #(
	parameter DATA_WIDTH					=	32,
	parameter SEL_WIDTH					=	4,
	
	parameter IO_EN						=	0,
	parameter I_EN							=	0,
	parameter O_EN							=	1,
	// port(n-1) ... port0
	parameter IO_PORT_WIDTH				=	"17,4,10,30",
	parameter I_PORT_WIDTH				=	"17,4",
	parameter O_PORT_WIDTH				=	"10",

	
	parameter ADDR_TYPE_WIDTH			=	5,
	parameter ADDR_PORT_WIDTH			=	5,
	parameter ADDR_REG_WIDTH			=	5,
	
	
	parameter IO_WIDTH					=(IO_EN)? 	sum_of_all(IO_PORT_WIDTH)	: 1,
	parameter I_WIDTH						=(I_EN )? 	sum_of_all(I_PORT_WIDTH)	: 1,
	parameter O_WIDTH						=(O_EN )? 	sum_of_all(O_PORT_WIDTH)	: 1,
	
	
	
	parameter ADDR_WIDTH					=	ADDR_TYPE_WIDTH+ADDR_PORT_WIDTH+ADDR_REG_WIDTH
	
	
	
	
)
(
	input 										clk,
	input											reset,
	
	input		[DATA_WIDTH-1		:	0]		sa_dat_i,
	input		[SEL_WIDTH-1		:	0]		sa_sel_i,
	input		[ADDR_WIDTH-1		:	0]		sa_addr_i,	
	input											sa_stb_i,
	input											sa_we_i,
	output	[DATA_WIDTH-1		:	0]		sa_dat_o,
	output 	reg								sa_ack_o,
	
	inout 	[IO_WIDTH-1		:	0]			gpio_io,
	input		[I_WIDTH-1		:	0]			gpio_i,
	output	[O_WIDTH-1		:	0]			gpio_o
	
	
);
	`LOG2 
	`define ADD_FUNCTION 		1
	`include "../my_functions.v"
	
	//port type
	localparam GPIO_TYPE_NUM					=3;
	localparam IO_ADDR_NUM						=0;
	localparam I_ADDR_NUM						=1;
	localparam O_ADDR_NUM						=2;
	
	

	
	
	//register per port
	localparam DIR_REG							=0;
	localparam WRITE_REG							=1;
	localparam READ_REG							=2;
	
	
	
	
	
	localparam IO_PORT_NUM						=number_of_port(IO_PORT_WIDTH);
	localparam I_PORT_NUM						=number_of_port(I_PORT_WIDTH);
	localparam O_PORT_NUM						=number_of_port(O_PORT_WIDTH);
	localparam IO_REG_PER_PORT					=3;//dir write read
	localparam O_REG_PER_PORT					=1;//write
	localparam I_REG_PER_PORT					=1;//read	
	localparam IO_ADDR_WIDTH					=log2(IO_PORT_NUM*IO_REG_PER_PORT	);
	localparam I_ADDR_WIDTH						=log2(O_PORT_NUM*I_REG_PER_PORT	);
	localparam O_ADDR_WIDTH						=log2(I_PORT_NUM*O_REG_PER_PORT	);
	
	
	wire	[DATA_WIDTH-1			:	0]		read_mux_in	[GPIO_TYPE_NUM-1	:0];
	wire 	[ADDR_TYPE_WIDTH-1	:	0]		addr_gpio_type;
	wire	[ADDR_PORT_WIDTH-1	:	0]		addr_gpio_port;
	wire	[ADDR_REG_WIDTH-1		:	0]		addr_gpio_reg;
	
	assign {addr_gpio_type,addr_gpio_port,addr_gpio_reg} = sa_addr_i;
	genvar i,j;
	generate
	/**********************************
					GPIO
	*********************************/

	if(IO_EN)begin : gpio_gen_blk
	
		reg	[IO_WIDTH-1			:	0] 	io_dir;
		reg	[IO_WIDTH-1			:	0]		io_write;
		wire  [DATA_WIDTH-1		:	0]		io_read_mux_in [IO_PORT_NUM-1	:0][IO_REG_PER_PORT-1	:	0];
		wire	io_addr;
		
		assign io_addr	=	addr_gpio_type	==	IO_ADDR_NUM;
	
		for(i=0; i<IO_PORT_NUM ; i=i+1'b1) begin : internal_reg_blk0
			if(`PORT_WIDTH(IO_PORT_WIDTH,i)) begin
				always @ (posedge clk or posedge reset) begin
					if(reset) begin 
						io_dir	[`PORT_LOC(IO_PORT_WIDTH,i)]	<= {`PORT_WIDTH(IO_PORT_WIDTH,i){1'b0}};
						io_write	[`PORT_LOC(IO_PORT_WIDTH,i)]	<=	{`PORT_WIDTH(IO_PORT_WIDTH,i){1'b0}};	
					end else begin 
						if(sa_stb_i && sa_we_i && io_addr) begin 
							if( addr_gpio_port == i) begin 
								if( addr_gpio_reg 	== DIR_REG   ) io_dir	[`PORT_LOC(IO_PORT_WIDTH,i)]	<=  sa_dat_i[`PORT_WIDTH(IO_PORT_WIDTH,i)-1'b1		:	0];
								if( addr_gpio_reg 	== WRITE_REG ) io_write	[`PORT_LOC(IO_PORT_WIDTH,i)]	<=  sa_dat_i[`PORT_WIDTH(IO_PORT_WIDTH,i)-1'b1		:	0];
							end
						end //sa_stb_i && sa_we_i
					end //reset
				end//always
				
				assign io_read_mux_in[i][DIR_REG]	= {{(DATA_WIDTH-`PORT_WIDTH(IO_PORT_WIDTH,i)){1'b0}},io_dir		[`PORT_LOC(IO_PORT_WIDTH,i)]};
				assign io_read_mux_in[i][WRITE_REG] = {{(DATA_WIDTH-`PORT_WIDTH(IO_PORT_WIDTH,i)){1'b0}},io_write	[`PORT_LOC(IO_PORT_WIDTH,i)]};
				assign io_read_mux_in[i][READ_REG]  = {{(DATA_WIDTH-`PORT_WIDTH(IO_PORT_WIDTH,i)){1'b0}},gpio_io	[`PORT_LOC(IO_PORT_WIDTH,i)]};	
				
				for(j=0;j<`PORT_WIDTH(IO_PORT_WIDTH,i); j=j+1'b1) begin: out_pin_assign0
					assign gpio_io[`PORT_LOC_START(IO_PORT_WIDTH,i)+j]	=	(io_dir[`PORT_LOC_START(IO_PORT_WIDTH,i)+j])	? 	io_write	[`PORT_LOC_START(IO_PORT_WIDTH,i)+j]	:	1'bZ;
				end
			end//if
		end//for
		
		assign read_mux_in[IO_ADDR_NUM]		=	io_read_mux_in[addr_gpio_port ][addr_gpio_reg];
		
		
	end // GPIO_EN
	else assign read_mux_in[IO_ADDR_NUM]	=	'hX;
	
	/**********************************
					GPI
	*********************************/
	
	if(I_EN) begin : gpi_gen_blk
		wire  [DATA_WIDTH-1		:	0]		i_read_mux_in [I_PORT_NUM-1	:	0];
	
		for(i=0; i<I_PORT_NUM ; i=i+1'b1) begin : internal_reg_blk1
				assign i_read_mux_in[i] = {{(DATA_WIDTH-`PORT_WIDTH(I_PORT_WIDTH,i)){1'b0}},gpio_i			[`PORT_LOC(I_PORT_WIDTH,i)]};	
		end//for
		 
		assign read_mux_in[I_ADDR_NUM]		=	i_read_mux_in[addr_gpio_port];
		
	end//GPI_EN
	else assign read_mux_in[I_ADDR_NUM]		=	'hX;
	
	/**********************************
					GPO
	*********************************/

	if(O_EN)begin : gpo_gen_blk
		
		wire  [DATA_WIDTH-1		:	0]		o_read_mux_in [O_PORT_NUM-1	:	0];
		wire 	o_addr;
		reg	[O_WIDTH-1			:	0]		o_write;
		assign o_addr	=	addr_gpio_type==O_ADDR_NUM	;
	
		for(i=0; i<O_PORT_NUM ; i=i+1'b1) begin : internal_reg_blk2
			if(`PORT_WIDTH(O_PORT_WIDTH,i)) begin
				always @ (posedge clk or posedge reset) begin
					if(reset) begin 
						o_write	[`PORT_LOC(O_PORT_WIDTH,i)]	<=	{`PORT_WIDTH(O_PORT_WIDTH,i){1'b0}};	
					end else begin 
						if(sa_stb_i && sa_we_i && o_addr) begin 
							if( addr_gpio_port == i &&  addr_gpio_reg 	== WRITE_REG ) o_write	[`PORT_LOC(O_PORT_WIDTH,i)]	<=  sa_dat_i[`PORT_WIDTH(O_PORT_WIDTH,i)-1'b1		:	0];
						end //sa_stb_i && sa_we_i
					end //reset
				end//always
				
				
				assign o_read_mux_in[i]= {{(DATA_WIDTH-`PORT_WIDTH(O_PORT_WIDTH,i)){1'b0}},o_write	[`PORT_LOC(O_PORT_WIDTH,i)]};
			
				
				for(j=0;j<`PORT_WIDTH(O_PORT_WIDTH,i); j=j+1'b1) begin: out_pin_assign2
					assign gpio_o[`PORT_LOC_START(O_PORT_WIDTH,i)+j]	=	o_write	[`PORT_LOC_START(O_PORT_WIDTH,i)+j];
				end
			end//if		
		end//for
		
		assign read_mux_in[O_ADDR_NUM]		=	o_read_mux_in[addr_gpio_port  ];
		
	end // GPIO_EN
	else assign read_mux_in[O_ADDR_NUM]		=	'hX;
	
	
	
	
	endgenerate
		
		
	
		
	reg [DATA_WIDTH-1		:	0] read_reg;
	always @(posedge clk) begin
		if(reset)begin 
			read_reg	<= {DATA_WIDTH{1'b0}};
			sa_ack_o		<=	1'b0;
		end else begin 
			if(sa_stb_i && ~sa_we_i)  read_reg  <=  read_mux_in[addr_gpio_type];
			sa_ack_o	<=	 sa_stb_i && ~sa_ack_o;
		end
	end
	
	assign sa_dat_o = read_reg;
	
	
	
	
endmodule
