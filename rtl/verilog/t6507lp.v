////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
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

//`include  "T6507LP_ALU.v" 
//`include  "t6507lp_fsm.v"

module t6507lp(clk, reset_n, data_in, rw_mem, data_out, address);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'b0001;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'b0001;

	// note: in the top level inputs are just inputs, outputs are just outputs and the internal signals are wired.
	input                 clk;
	input                 reset_n;
	input  [DATA_SIZE_:0] data_in;
	output                rw_mem;
	output [DATA_SIZE_:0] data_out;
	output [ADDR_SIZE_:0] address;

	wire [DATA_SIZE_:0] alu_result;
	wire [DATA_SIZE_:0] alu_status;
	wire [DATA_SIZE_:0] alu_x;
	wire [DATA_SIZE_:0] alu_y;
	wire [DATA_SIZE_:0] alu_opcode;
	wire [DATA_SIZE_:0] alu_a;
	wire alu_enable;

	// `include  "T6507LP_Package.v"
	//TODO change rw_mem to mem_rw
	t6507lp_fsm #(DATA_SIZE, ADDR_SIZE) t6507lp_fsm(
		.clk		(clk),
		.reset_n	(reset_n),
		.alu_result	(alu_result),
		.alu_status	(alu_status),
		.data_in	(data_in),
		.alu_x		(alu_x),
		.alu_y		(alu_y),
		.address	(address),
		.rw_mem		(rw_mem),
		.data_out	(data_out),
		.alu_opcode	(alu_opcode),
		.alu_a		(alu_a),
		.alu_enable	(alu_enable)
	);

	t6507lp_alu t6507lp_alu (
		.clk		(clk),
		.reset_n  	(reset_n),
		.alu_enable	(alu_enable),
		.alu_result	(alu_result),
		.alu_status	(alu_status),
		.alu_opcode	(alu_opcode),
		.alu_a		(alu_a),
		.alu_x		(alu_x),
		.alu_y		(alu_y)
	);
endmodule
