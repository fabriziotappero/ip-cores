////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// VGA controller					 		////
////									////
//// TODO:								////
//// - Feed the controller with data					////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module test_top(reset_n, clk_50, SW, VGA_R, VGA_G, VGA_B, LEDR, VGA_VS, VGA_HS);

input reset_n;
input clk_50;
input [8:0] SW;
output [3:0] VGA_R;
output [3:0] VGA_G;
output [3:0] VGA_B;
output [9:0] LEDR;
output VGA_VS;
output VGA_HS;

wire [2:0] pixel;
wire [10:0] read_addr;
wire [10:0] write_addr;
wire [2:0] read_data;
wire [2:0] write_data;
wire write_enable_n;
wire clk_358;

	vga_controller vga_controller (
		.reset_n(reset_n),
		.clk_50(clk_50),
		.pixel(pixel),
		.SW(SW),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.LEDR(LEDR),
		.VGA_VS(VGA_VS),
		.VGA_HS(VGA_HS),
		.read_addr(read_addr),
		.read_data(read_data)
	);

	controller_test controller_test (
		.reset_n(reset_n),
		.clk_50(clk_50),
		.pixel(pixel),
		.write_addr(write_addr),
		.write_data(write_data),
		.write_enable_n(write_enable_n),
		.clk_358(clk_358)
	);

	video_mem video_mem (
		.clk_358(clk_358),
		.reset_n(reset_n),
		.write_addr(write_addr),
		.write_enable_n(write_enable_n),
		.read_addr(read_addr),
		.write_data(write_data),
		.read_data(read_data)
	);

endmodule
