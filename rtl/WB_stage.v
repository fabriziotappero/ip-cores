/***************************************************
 * Module: WB_stage
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     Write back stage
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"
module WB_stage
(
	//input					clk,
	
	// from EX stage
	input		[36:0]		pipeline_reg_in,	//	[36:21],16bits:	ex_alu_result[15:0]
												//	[20:5],16bits:	mem_read_data[15:0]
												//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux, 
	
	// to register file
	output					reg_write_en,
	output		[2:0]		reg_write_dest,
	output		[15:0]		reg_write_data,
	
	output		[2:0]		wb_op_dest
);
	
	wire [15:0]	ex_alu_result = pipeline_reg_in[36:21];
	wire [15:0]	mem_read_data = pipeline_reg_in[20:5];
	wire		write_back_en = pipeline_reg_in[4];
	wire [2:0]	write_back_dest = pipeline_reg_in[3:1];
	wire		write_back_result_mux = pipeline_reg_in[0];
	
	/********************** to register file *********************/
	assign reg_write_en = write_back_en;
	assign reg_write_dest = write_back_dest;
	assign reg_write_data = (write_back_result_mux)? mem_read_data : ex_alu_result;
	
	/********************** to hazard detection unit *********************/
	assign wb_op_dest = pipeline_reg_in[3:1];
	
	
endmodule 