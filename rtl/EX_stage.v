/***************************************************
 * Module: EX_stage
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     alu
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"
module EX_stage
(
	input					clk,
	input					rst,
	// from ID_stage
	input		[56:0]		pipeline_reg_in,	//	[56:22],35bits:	ex_alu_cmd[2:0], ex_alu_src1[15:0], ex_alu_src2[15:0]
												//	[21:5],17bits:	mem_write_en, mem_write_data[15:0]
												//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux, 
	
	// to MEM_stage
	output	reg	[37:0]		pipeline_reg_out,	//	[37:22],16bits:	ex_alu_result[15:0];
												//	[21:5],17bits:	mem_write_en, mem_write_data[15:0]
												//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux, 
	
	// to hazard detection unit
	output		[2:0]		ex_op_dest
);
	wire	[2:0]		alu_cmd		= pipeline_reg_in[56:54];				//S2
	wire	[15:0]		alu_src1	= pipeline_reg_in[53:38];
	wire	[15:0]		alu_src2	= pipeline_reg_in[37:22];
	
	wire	[15:0]		ex_alu_result;
	
	/********************** ALU *********************/
	alu alu_inst(
		.a		( alu_src1),
		.b		( alu_src2),
		.cmd	( alu_cmd),
		.r		( ex_alu_result)
	);
	
	
	/********************** singals to MEM_stage *********************/
	always @ (posedge clk) begin
		if(rst) begin
			pipeline_reg_out[37:0] <= 0;
		end
		else begin
			pipeline_reg_out[37:22] <= ex_alu_result;
			pipeline_reg_out[21:0] <= pipeline_reg_in[21:0];
		end
	end
	
	
	/********************** to hazard detection unit *********************/
	assign ex_op_dest = pipeline_reg_in[3:1];
endmodule 
