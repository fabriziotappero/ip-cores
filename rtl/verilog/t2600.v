////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Top level for the entire system					////
////									////
//// TODO:								////
//// - Instantiate all modules						////
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

module t2600(clk, reset_n);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;
	localparam [3:0] RIOT_ADDR_SIZE = 4'd7;
	localparam [3:0] TIA_ADDR_SIZE = 4'd6;

	input clk;
	input reset_n;

	t6507lp #(DATA_SIZE, ADDR_SIZE) t6507lp (
		.clk		(clk),
		.reset_n	(reset_n),
		.data_in	(data_in),
		.rw_mem		(rw_mem),
		.data_out	(data_out),
		.address	(address)
	);
	
	t6532 #(DATA_SIZE, RIOT_ADDR_SIZE) t6532 (
		.clk		(clk),
		.io_lines	(io_lines),
		.enable		(enable),
		.address	(address),
		.data		(data)
	);

	t2600_bus t2600_bus (
		.address	(address),
		.data_from_cpu	(data_from_cpu),
		.cpu_rw_mem	(cpu_rw_mem),
		.riot_data	(riot_data),
		.rom_data	(rom_data),
		.tia_data	(tia_data),
		.address_riot	(address_riot),
		.address_rom	(address_rom),
		.address_tia	(address_tia),
		.data_to_cpu	(data_to_cpu),
		.enable_riot	(enable_riot),
		.enable_rom	(enable_rom),
		.enable_tia	(enable_tia),
		.rw_mem		(rw_mem)
	);

	T2600_KB T2600_KB (
		.CLK		(clk),
		.RST		(reset_n),
		.io_lines	(io_lines),
		.KC		(kc),
		.KD		(kd)
	);

	video video (

	);


// VIDEO

endmodule

