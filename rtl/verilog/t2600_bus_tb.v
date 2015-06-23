////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Bus controller testbench				 		////
////									////
//// TODO:								////
//// - Nothing								////
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
module t2600_bus_tb();
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;
	localparam [3:0] RIOT_ADDR_SIZE_ = 4'd6;
	localparam [3:0] TIA_ADDR_SIZE_ = 4'd5;

	// these 3 registers are kind of drivers/wrappers for the tristate ones
	reg [DATA_SIZE_:0] riot_data_drvr; 
	reg [DATA_SIZE_:0] rom_data_drvr; 
	reg [DATA_SIZE_:0] tia_data_drvr; 

	// list of all the inputs/outputs of the bus controller
	reg [ADDR_SIZE_:0] address;
	reg [DATA_SIZE_:0] data_from_cpu;
	reg cpu_rw_mem;
	tri [DATA_SIZE_:0] riot_data = riot_data_drvr;
	tri [DATA_SIZE_:0] rom_data = rom_data_drvr;
	tri [DATA_SIZE_:0] tia_data = tia_data_drvr;
	wire [RIOT_ADDR_SIZE_:0] address_riot;
	wire [ADDR_SIZE_:0] address_rom;
	wire [TIA_ADDR_SIZE_:0] address_tia;
	wire[DATA_SIZE_:0] data_to_cpu;
	wire enable_riot;
	wire enable_rom;
	wire enable_tia;
	wire rw_mem;

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

	always @(*) begin
		if (cpu_rw_mem == 1'b1) begin
			tia_data_drvr = 8'hZ;
			riot_data_drvr = 8'hZ;
			rom_data_drvr = 8'hZ;
		end
	end 

	// this block is clockless so I cannot use @(negedge clk)
	initial begin
		address = 13'b0;
		data_from_cpu = 8'h01;
		cpu_rw_mem = 1'b0; // READ
	
		#10;
		address = 13'd8; // this is a TIA adress

		#10;
		address = 13'd128; // this is a RIOT adress

		#10;
		address = 13'd4096; // this is a ROM adress

		#10;
		cpu_rw_mem = 1'b1; // from now on I will be writing
		riot_data_drvr = 8'h02;
		rom_data_drvr = 8'h03;
		tia_data_drvr = 8'h04;
		address = 13'd8; // this is a TIA adress

		#10;
		address = 13'd128; // this is a RIOT adress

		#10;
		address = 13'd4096; // this is a ROM adress
		
		#10;
		$finish();
	end
endmodule
