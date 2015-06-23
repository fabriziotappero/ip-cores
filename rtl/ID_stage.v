/***************************************************
 * Module: ID_stage
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     IR, and instruction decoding
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"

module ID_stage
(
	input					clk,
	input					rst,
	input					instruction_decode_en,
	//input					insert_bubble,
	
	
	// to EX_stage
	output	reg	[56:0]		pipeline_reg_out,	//	[56:22],35bits:	ex_alu_cmd[2:0], ex_alu_src1[15:0], ex_alu_src2[15:0]
												//	[21:5],17bits:	mem_write_en, mem_write_data[15:0]
												//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux, 
	
	// to IF_stage
	input		[15:0]		instruction,
	output		[5:0]		branch_offset_imm,
	output	reg				branch_taken,
	
	// to register file
	output		[2:0]		reg_read_addr_1,	// register file read port 1 address
	output		[2:0]		reg_read_addr_2,	// register file read port 2 address
	input		[15:0]		reg_read_data_1,	// register file read port 1 data
	input		[15:0]		reg_read_data_2,	// register file read port 2 data
	
	// to hazard detection unit
	output		[2:0]		decoding_op_src1,		//source_1 register number
	output		[2:0]		decoding_op_src2		//source_2 register number
	
);
    
	/********************** internal wires ***********************************/
	//----------------- Instruction Register signals --------------------//
	reg		[15:0]		instruction_reg;
	wire	[3:0]		ir_op_code;		//operation code
	wire	[2:0]		ir_dest;		//destination register number
	wire	[2:0]		ir_src1;		//source_1 register number
	wire	[2:0]		ir_src2;		//source_2 register number
	wire	[5:0]		ir_imm;			//immediate number carried by the instruction
	
	//---------------- data path control signals --------------------------//
	// write back stage signals
	reg					write_back_en;			// S3
	wire	[2:0]		write_back_dest;		// dest
	reg					write_back_result_mux;	// S1
	// mem stage signals
	wire				mem_write_en;		
	wire	[15:0]		mem_write_data;
	// ex stage signals
	reg		[2:0]		ex_alu_cmd;				//S2
	wire	[15:0]		ex_alu_src1;
	wire	[15:0]		ex_alu_src2;
	// instruction decode stage signals
	reg					alu_src2_mux;			// S4
	wire				decoding_op_is_branch;	//S5
	wire				decoding_op_is_store;	//S6
	wire	[3:0]		ir_op_code_with_bubble;
	wire	[2:0]		ir_dest_with_bubble;
	//reg					branch_condition_satisfied;
	
	
	/********************** Instruction Register *********************/
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			instruction_reg <= 0;
		end
		else begin
			if(instruction_decode_en) begin
				instruction_reg <= instruction;
			end
		end
	end
	assign ir_op_code = instruction_reg[15:12];
	assign ir_dest = instruction_reg[11: 9];
	assign ir_src1 = instruction_reg[ 8: 6];
	assign ir_src2 = (decoding_op_is_store)? instruction_reg[11: 9] : instruction_reg[ 5: 3];
	assign ir_imm  = instruction_reg[ 5: 0];
	
	/********************** pipeline bubble insertion *********************/
	// if instrcution decode is frozen, insert bubble operations into the pipeline
	assign ir_op_code_with_bubble = ( instruction_decode_en )?  ir_op_code : 0;
	// if instrcution decode is frozen, force destination reg number to 0, 
	// this operation is to prevent pipeline stall.
	assign ir_dest_with_bubble = ( instruction_decode_en )?  ir_dest : 0;
	
	/********************** Data path control logic *********************/
	always @ (*) begin
		if(rst) begin
			write_back_en			= 0;	// S3
			write_back_result_mux	= 0;	// S1
			ex_alu_cmd				= 0;	// S2
			alu_src2_mux			= 0;	// S4
		end
		else begin
			case( ir_op_code_with_bubble )
				`OP_NOP	:
					begin
						write_back_en			= 0;		// S3
						write_back_result_mux	= 1'bx;		// S1
						ex_alu_cmd				= `ALU_NC;	// S2
						alu_src2_mux			= 1'bx;		// S4
					end
				`OP_ADD	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_ADD;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_SUB	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_SUB;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_AND	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_AND;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_OR	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_OR;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_XOR	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_XOR;	// S2
						alu_src2_mux			= 1'bx;		// S4
					end
				`OP_SL	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_SL;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_SR	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_SR;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_SRU	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_SRU;	// S2
						alu_src2_mux			= 0;		// S4
					end
				`OP_ADDI:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 0;		// S1
						ex_alu_cmd				= `ALU_ADD;	// S2
						alu_src2_mux			= 1;		// S4
					end
				`OP_LD	:
					begin
						write_back_en			= 1;		// S3
						write_back_result_mux	= 1;		// S1
						ex_alu_cmd				= `ALU_ADD;	// S2
						alu_src2_mux			= 1;		// S4
					end
				`OP_ST	:
					begin
						write_back_en			= 0;		// S3
						write_back_result_mux	= 1'bx;		// S1
						ex_alu_cmd				= `ALU_ADD;	// S2
						alu_src2_mux			= 1;		// S4
					end
				`OP_BZ	:
					begin
						write_back_en			= 0;		// S3
						write_back_result_mux	= 1'bx;		// S1
						ex_alu_cmd				= `ALU_NC;	// S2
						alu_src2_mux			= 1;		// S4
					end
				default	:
					begin
						write_back_en			= 0;		// S3
						write_back_result_mux	= 1'bx;		// S1
						ex_alu_cmd				= `ALU_NC;	// S2
						alu_src2_mux			= 1'bx;		// S4
`ifndef CODE_FOR_SYNTHESIS
						$display("ERROR: Unknown Instruction: %b", ir_op_code_with_bubble);
						//$stop;
`endif
					end
			endcase
		end
	end
	
	assign decoding_op_is_branch = ( ir_op_code == `OP_BZ )? 1 : 0;	// S5
	assign decoding_op_is_store	= ( ir_op_code == `OP_ST )? 1 : 0;	// S6
	
	/********************** singals to EX_stage *********************/
	assign mem_write_data = reg_read_data_2;
	assign mem_write_en = decoding_op_is_store;
	assign write_back_dest = ir_dest_with_bubble;
	assign ex_alu_src1 = reg_read_data_1;
	assign ex_alu_src2 = (alu_src2_mux)? {{10{ir_imm[5]}},ir_imm} : reg_read_data_2;
	
	//	pipeline_reg_out:
	//	[56:22],35bits:	ex_alu_cmd[2:0], ex_alu_src1[15:0], ex_alu_src2[15:0],
	//	[21:5],17bits:	mem_write_en, mem_write_data[15:0],
	//	[4:0],5bits:	write_back_en, write_back_dest[2:0], write_back_result_mux,
	
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			pipeline_reg_out[56:0] <= 0;
		end
		else begin
			pipeline_reg_out[56:0] <= {
				ex_alu_cmd[2:0],		// pipeline_reg_out[56:54]	//S2
				ex_alu_src1[15:0],		// pipeline_reg_out[53:38]
				ex_alu_src2[15:0],		// pipeline_reg_out[37:22]	
				mem_write_en, 			// pipeline_reg_out[21]		//
				mem_write_data[15:0],	// pipeline_reg_out[20:5]	//
				write_back_en, 			// pipeline_reg_out[4]		//S3
				write_back_dest[2:0], 	// pipeline_reg_out[3:1]	//dest
				write_back_result_mux 	// pipeline_reg_out[0]		//S1
				};
		end
	end
	
			 
	/********************** interface with register file *********************/
	assign reg_read_addr_1 = ir_src1;
	assign reg_read_addr_2 = ir_src2;
	
	/********************** branch signals generate *********************/
	always @ (*) begin
		if(decoding_op_is_branch) begin
			case( ir_dest_with_bubble )
				`BRANCH_Z	:
					begin
						if(reg_read_data_1 == 0)
							branch_taken = 1;
						else
							branch_taken = 0;
					end
					
				default:
					begin
						branch_taken = 0;
`ifndef CODE_FOR_SYNTHESIS
						$display("ERROR: Unknown branch condition %b, in branch instruction %b \n", ir_dest_with_bubble, ir_op_code_with_bubble);
						//$stop;
`endif					
					end
			endcase
		end
		else begin
			branch_taken = 0;
		end
	end
	assign branch_offset_imm = ir_imm;
	//assign branch_taken = decoding_op_is_branch & branch_condition_satisfied ;
	
	/********************** to hazard detection unit *********************/
	assign decoding_op_src1 = ir_src1;
	assign decoding_op_src2 = (
					ir_op_code == `OP_NOP 	||
					ir_op_code == `OP_ADDI 	||
					ir_op_code == `OP_LD 	||
					ir_op_code == `OP_BZ 	
					)?
					3'b000 : ir_src2;
	
endmodule 