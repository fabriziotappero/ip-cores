/***************************************************
 * Module: IF_stage
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     PC, IMEM, 
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"


module IF_stage
(
	input							clk,
	input							rst,				//active high
	input							instruction_fetch_en,
	
	input	[5:0]					branch_offset_imm,
	input							branch_taken,
	
	output	reg	[`PC_WIDTH-1:0]		pc,
	output	[15:0]					instruction
);
    
	// pc control
	always @ (posedge clk or posedge rst) begin
	    if (rst) begin
	        pc <= `PC_WIDTH'b0;
	    end 
		else begin
			if(instruction_fetch_en) begin
				if(branch_taken)
					//don't forget sign bit expansion
					pc <= pc + {{(`PC_WIDTH-6){branch_offset_imm[5]}}, branch_offset_imm[5:0]};	
				else
					pc <= pc + `PC_WIDTH'd1;
			end
		end
	end
	
	// instruction memory, or rom
	instruction_mem imem(
		.clk				(clk),
		.pc					(pc),
		
		.instruction		(instruction)
	);
	
	
endmodule 



