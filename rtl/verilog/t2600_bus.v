////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Bus controller for linking the t6507, t6532 and txxx. TODO		////
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
module t2600_bus(address, data_from_cpu, cpu_rw_mem, riot_data, rom_data, tia_data, address_riot, address_rom, address_tia, data_to_cpu, enable_riot, enable_rom, enable_tia, rw_mem);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;
	localparam [3:0] RIOT_ADDR_SIZE_ = 4'd6;
	localparam [3:0] TIA_ADDR_SIZE_ = 4'd5;

	input [ADDR_SIZE_:0] address;
	input [DATA_SIZE_:0] data_from_cpu;
	input cpu_rw_mem;
	inout [DATA_SIZE_:0] riot_data;
	inout [DATA_SIZE_:0] rom_data;
	inout [DATA_SIZE_:0] tia_data;
	output reg [RIOT_ADDR_SIZE_:0] address_riot;
	output reg [ADDR_SIZE_:0] address_rom;
	output reg [TIA_ADDR_SIZE_:0] address_tia;
	output reg[DATA_SIZE_:0] data_to_cpu;
	output reg enable_riot;
	output reg enable_rom;
	output reg enable_tia;
	output reg rw_mem;

	assign riot_data = (rw_mem) ? data_from_cpu : 8'bZ; // if i am writing the bus receives the data from cpu  
	assign rom_data = (rw_mem) ? data_from_cpu : 8'bZ; // if i am writing the bus receives the data from cpu  
	assign tia_data = (rw_mem) ? data_from_cpu : 8'bZ; // if i am writing the bus receives the data from cpu  

	always @(*) begin
		enable_riot = 1'b0;
		enable_rom = 1'b0;
		enable_tia = 1'b0;
		
		rw_mem = cpu_rw_mem;
		address_tia = address[5:0];
		address_riot = address[6:0];
		address_rom = address;

		if (address[12]) begin
			data_to_cpu = rom_data;
			enable_rom = 1'b1; 
		end
		else if (address[7]) begin
			data_to_cpu = riot_data;
			enable_riot = 1'b1;
		end
		else begin
			data_to_cpu = tia_data;
			enable_tia = 1'b1;
		end
	end
endmodule
