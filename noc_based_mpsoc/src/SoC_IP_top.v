/*********************************************************************
							
	File: SoC_IP_top.v 
	
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
	The top module for SoC with one aeMB processor, wishbone bus, gpio 
	and timer
	

	Info: monemi@fkegraduate.utm.my

****************************************************************/


module SoC_IP_top (
	input 												CLOCK_50,
	input		[3								:	0]		KEY,
	output	[3								:	0]		LEDG,
	output	[6								:	0]		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7


);


	
	parameter SEVEN_SEG_NUM		=	8;
	
	parameter AEMB_RAM_WIDTH_IN_WORD		=	`AEMB_RAM_WIDTH_IN_WORD_DEF;
	parameter RAM_EN							=	1;
	parameter GPIO_EN							=	1;
	parameter EXT_INT_EN						=	1;
	parameter TIMER_EN						=	1;
	parameter INT_CTRL_EN					=	1;
		
	
//gpio parameters 
	parameter IO_EN							=	0;
	parameter I_EN								=	0;
	parameter O_EN								=	1;
	
	parameter IO_PORT_WIDTH					=	"0";
	parameter I_PORT_WIDTH					=	"0";
	parameter O_PORT_WIDTH					=	"7,7,7,7,7,7,7,7";
	
		
//external int parameters
	parameter EXT_INT_NUM					=	3;//max 32
	


	wire	[(SEVEN_SEG_NUM	*7)-1		:0] seven_segment;
	wire 	[2									:0] ext_int_i;
	wire											 reset,reset_in,sys_en,sys_en_n;
	wire											 clk;
	
	
	assign	sys_en	= ~ sys_en_n;
	assign 	clk		=	CLOCK_50;
	assign	LEDG[0]	=	reset;
	assign	LEDG[3:1]=	ext_int_i;
	assign	{HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} = seven_segment;
	assign	reset_in		=	~KEY[0];
	assign	ext_int_i	=	~KEY[3:1];
	
	
	signal_holder #(
		.DELAY_COUNT(1000)
	)
	hold_reset
	(
		.reset_in	(reset_in),
		.clk			(clk),
		.reset_out	(reset)
	);
	
	signal_holder #(
		.DELAY_COUNT(100)
	)
	hold_en
	(
		.reset_in	(reset),
		.clk			(clk),
		.reset_out	(sys_en_n)
	);
	
	
	aeMB_IP #(
		.AEMB_RAM_WIDTH_IN_WORD		(AEMB_RAM_WIDTH_IN_WORD	),
		.RAM_EN							(RAM_EN),						
		.NOC_EN							(0),
		.GPIO_EN							(GPIO_EN),
		.EXT_INT_EN						(EXT_INT_EN),
		.TIMER_EN						(TIMER_EN),
		.INT_CTRL_EN					(INT_CTRL_EN),
		.IO_EN							(IO_EN),
		.I_EN								(I_EN),
		.O_EN								(O_EN),
		.IO_PORT_WIDTH					(IO_PORT_WIDTH),
		.I_PORT_WIDTH					(I_PORT_WIDTH),
		.O_PORT_WIDTH					(O_PORT_WIDTH),
		.EXT_INT_NUM					(EXT_INT_NUM),
		.SW_X_ADDR(0),
		.SW_Y_ADDR(0)
	)IP
	(
		.clk (clk),
		.reset_in(reset),
		.sys_ena_i(sys_en),
		.ext_int_i(ext_int_i),
		.gpio_io(),
		.gpio_i(),
		.gpio_o(seven_segment)
);

	

	
	
	



endmodule
