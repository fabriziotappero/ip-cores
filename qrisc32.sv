//////////////////////////////////////////////////////////////////////////////////////////////
//    Project Qrisc32 is risc cpu implementation, purpose is studying
//    Digital System Design course at Kyoung Hee University during my PhD earning
//    Copyright (C) 2010  Vinogradov Viacheslav
// 
//    This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//
//////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Title       : qrisc32
// Design      : qrisc32
// Author      : vinogradov@opencores.org
//5 stages risc cpu
//with 3 avalon interfaces:
// - Data Read Avalon interface
// - Data Write Avalon interface
// - Instruction Read Avalon interface
//--------------------------------------------------------------------------------------------

`timescale 1 ns / 1 ns

module qrisc32(
	input				clk,reset,
	
	//avalon master port only for  reading instructions
	input[31:0]			avm_instructions_data,
	output[31:0]		avm_instructions_addr,
	output 				avm_instructions_rd,
	input				avm_instructions_wait_req,
	
	//avalon master port only for  reading data avm_data_read
	input[31:0]			avm_datar_data,
	output[31:0]		avm_datar_addr,
	output				avm_datar_rd,
	input				avm_datar_wait_req,

	//avalon master port only for  writing data
	output[31:0]		avm_dataw_data,
	output[31:0]		avm_dataw_addr,
	output				avm_dataw_wr,
	input				avm_dataw_wait_req,
	
	input				verbose//for simlation

	);
	
import risc_pack::*;

	avalon_port	avm_instructions(),avm_data_read(),avm_data_write();
	
	//Instruction read port
	assign 	avm_instructions.data_r		=	avm_instructions_data;
	assign	avm_instructions_addr	 	=	avm_instructions.address_r;
	assign	avm_instructions_rd			=	avm_instructions.rd;
	assign	avm_instructions.wait_req	=	avm_instructions_wait_req;
	
	//Data read port
	assign 	avm_data_read.data_r		=	avm_datar_data;
	assign	avm_datar_addr	 			=	avm_data_read.address_r;
	assign	avm_datar_rd				=	avm_data_read.rd;
	assign	avm_data_read.wait_req		=	avm_datar_wait_req;

	//Data write port
	assign 	avm_dataw_data				=	avm_data_write.data_w;
	assign	avm_dataw_addr	 			=	avm_data_write.address_r;
	assign	avm_dataw_wr				=	avm_data_write.wr;
	assign	avm_data_write.wait_req		=	avm_dataw_wait_req;
	
	
	pipe_struct	    //     I decode        -             Ex           -     MEM access      
					pipe_id_out,pipe_ex_out,pipe_mem_out;

	wire[31:0]	instruction,pc;
	wire		new_address_valid_ex;
	wire[31:0]	new_address_ex;

	wire		new_address_valid_mem;
	wire[31:0]	new_address_mem;

	
	wire		pipe_stall;
	
	qrisc32_IF	qrisc32_IF(
		.clk(clk),
		.reset(reset),
		.pipe_stall(pipe_stall),
		.avm_instructions(avm_instructions),
		.new_address_valid(new_address_valid_ex),
		.new_address(new_address_ex),

		.instruction(instruction),
		.pc(pc)
	);

	qrisc32_ID	qrisc32_ID(
		.clk(clk),
		.reset(reset),
		.pipe_stall(pipe_stall),
		.instruction(instruction),
		.pc(pc),
		.pipe_wb_mem(pipe_mem_out),//for memory read 
		.pipe_wb_ex(pipe_ex_out),//for R2 register and ALU operations only
		.pipe_id_out(pipe_id_out),
		.verbose(verbose)
	);
	
	qrisc32_EX	qrisc32_EX(
		.clk(clk),
		.reset(reset),
		.pipe_stall(pipe_stall),
		.pipe_ex_in(pipe_id_out),
		.pipe_ex_out(pipe_ex_out),
		.new_address_valid(new_address_valid_ex),
		.new_address(new_address_ex)
	);
	
	qrisc32_MEM	qrisc32_MEM(
		.clk(clk),
		.reset(reset),
		.pipe_mem_in(pipe_ex_out),
		.avm_data_read(avm_data_read),
		.avm_data_write(avm_data_write),
		.pipe_mem_out(pipe_mem_out),
		.pipe_stall(pipe_stall),
		.verbose(verbose)
	);



endmodule
