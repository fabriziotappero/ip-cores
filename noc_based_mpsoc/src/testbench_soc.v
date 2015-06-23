/*********************************************************************
							
	File: testbench_soc.v 
	
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
	a real life application. running the ./soc_run file in sw folder 
	will copy the generated mif file in simulation folder which will be read 
	by modelsim.  
	
	Info: monemi@fkegraduate.utm.my
*********************************************************************/

`timescale  1ns/1ps


module testbench_soc ();
	reg clk,reset;
	wire		[3								:	0]		KEY;
	wire		[3								:	0]		LEDG;
	wire		[6								:	0]		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	reg		[2:				0] ext_int;

	
	
SoC_IP_top IP(
	.CLOCK_50	(clk),
	.KEY			(KEY),
	.LEDG			(LEDG),
	.HEX0			(HEX0),
	.HEX1			(HEX1),
	.HEX2			(HEX2),
	.HEX3			(HEX3),
	.HEX4			(HEX4),
	.HEX5			(HEX5),
	.HEX6			(HEX6),
	.HEX7			(HEX7)
	
);

assign 	KEY=			{ext_int,~reset};
	

	

initial begin 
	clk = 1'b0;
	forever clk = #10 ~clk;
end

initial begin
ext_int=0;
	reset=1;
	#50
	reset=0;
	
	#300000
	ext_int = 1;
	#50
	ext_int = 0;
	
end


endmodule
