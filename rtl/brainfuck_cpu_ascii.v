`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Aleksander Kaminski
// 
// Create Date:    01:23:37 07/08/2014 
// Design Name: 	Braindfuck CPU
// Module Name:    brainfuck_cpu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// 0x3C = <
// 0x3E = >
// 0x2B = +
// 0x2D = -
// 0x2C = ,
// 0x2E = .
// 0x5B = [
// 0x5D = ]
//////////////////////////////////////////////////////////////////////////////////
module brainfuck_cpu #(parameter DATA_ADDR_WIDTH = 8, ROM_ADDR_WIDTH = 12, STACK_DEPTH = 4)
	(
	input clk,
	input rst,
	input [7:0] data_i,
	output [7:0] data_o,
	input [6:0] rom_i,
	output [DATA_ADDR_WIDTH-1:0] data_addr_o,
	output [ROM_ADDR_WIDTH-1:0] rom_addr_o,
	output reg rd,
	output reg wr,
	output reg mreq,
	output reg ioreq,
	input ready
	);
	
// FSM states

	localparam 	RAM_CLEAR = 3'b001,
					RUN = 3'b010,
					UPDATE_DATA = 3'b100,
					INSTANT_ZERO_EXEPTION_RECOVERY = 3'b101,
					JUMP_RECOVERY = 3'b110;

// Declarations
	
	reg [6:0] ir;
	reg [7:0] data_reg;
	reg [ROM_ADDR_WIDTH-1:0] pc;
	reg [DATA_ADDR_WIDTH-1:0] pointer;
	reg [clogb2(STACK_DEPTH)-1:0] sp;
	reg [ROM_ADDR_WIDTH-1:0] stack [0:STACK_DEPTH-1];
	
	reg [2:0] fsm_state;
	reg [2:0] fsm_next;
	
	reg ir_load;
	
	reg data_reg_load;
	reg data_reg_inc;
	reg data_reg_dec;
	
	reg stack_load;
	reg sp_inc;
	reg sp_dec;
	
	reg pc_inc;
	reg pc_load;
	
	reg pointer_inc;
	reg pointer_dec;
	
	integer i;
	
//	Instruction fetching
	
	always @(posedge clk, posedge rst) begin
		if(rst)
			ir <= 0;
		else if(ir_load)
			ir <= rom_i;
	end
	
// Current data register

	always @(posedge clk, posedge rst) begin
		if(rst)
			data_reg <= 0;
		else begin
			if(data_reg_inc)
				data_reg <= data_reg + 1;
			else if(data_reg_dec)
				data_reg <= data_reg - 1;
			else if(data_reg_load)
				data_reg <= data_i;
		end
	end
	
	assign data_o = data_reg;
	
// Stack

	always @(posedge clk) begin
		for( i=0 ; i<STACK_DEPTH ; i=i+1 )
			stack[i] <= stack[i];
		if(stack_load)
			stack[sp] <= pc;
	end
			
//	Stack pointer

	always @(posedge clk, posedge rst) begin
		if(rst)
			sp <= 0;
		else if(sp_inc)
			sp <= sp + 1'b1;
		else if(sp_dec)
			sp <= sp - 1'b1;
	end
	
// Program counter

	always @(posedge clk, posedge rst) begin
		if(rst)
			pc <= 0;
		else if(pc_inc)
			pc <= pc + 1;
		else if(pc_load)
			pc <= stack[sp-1];
	end
	
	assign rom_addr_o = pc;
	
// Pointer

	always @(posedge clk, posedge rst) begin
		if(rst)
			pointer <= 0;
		else if(pointer_inc)
			pointer <= pointer + 1;
		else if(pointer_dec)
			pointer <= pointer - 1;
	end
	
	assign data_addr_o = pointer;
	
// FSM

	always @(posedge clk, posedge rst) begin
		if(rst)
			fsm_state <= RAM_CLEAR;
		else
			fsm_state <= fsm_next;
	end
	
	always @(*) begin
		ir_load <= 1'b0;
		data_reg_load <= 1'b0;
		data_reg_inc <= 1'b0;
		data_reg_dec <= 1'b0;
		stack_load <= 1'b0;
		sp_inc <= 1'b0;
		sp_dec <= 1'b0;
		pc_inc <= 1'b0;
		pc_load <= 1'b0;
		pointer_inc <= 1'b0;
		pointer_dec <= 1'b0;
		wr <= 1'b0;
		rd <= 1'b0;
		mreq <= 1'b0;
		ioreq <= 1'b0;
		
		case(fsm_state)
			RAM_CLEAR: begin
				wr <= 1'b1;
				mreq <= 1'b1;
				fsm_next <= RAM_CLEAR;
	
				if(ready) begin
					pointer_inc <= 1'b1;
					if(&pointer) begin
						ir_load <= 1'b1;
						pc_inc <= 1'b1;
						fsm_next <= RUN;
					end
				end
			end
			
			RUN: begin
				case(ir)
					3'b0111100: begin		//<
						wr <= 1'b1;
						mreq <= 1'b1;
						
						if(ready) begin
							pointer_dec <= 1'b1;
							ir_load <= 1'b1;
							pc_inc <= 1'b1;
							fsm_next <= UPDATE_DATA;
						end
						else
							fsm_next <= RUN;
					end
				
					3'b011110: begin		//>
						wr <= 1'b1;
						mreq <= 1'b1;
						
						if(ready) begin
							pointer_inc <= 1'b1;
							ir_load <= 1'b1;
							pc_inc <= 1'b1;
							fsm_next <= UPDATE_DATA;
						end
						else
							fsm_next <= RUN;
					end
					
					3'b0101011: begin		//+
						ir_load <= 1'b1;
						pc_inc <= 1'b1;
						data_reg_inc <= 1'b1;
						fsm_next <= RUN;
					end
						
					3'b0101101: begin		//-
						ir_load <= 1'b1;
						pc_inc <= 1'b1;
						data_reg_dec <= 1'b1;
						fsm_next <= RUN;
					end
						
					3'b0101100: begin		//,
						rd <= 1'b1;
						ioreq <= 1'b1;
						fsm_next <= RUN;
						
						if(ready) begin
							data_reg_load <= 1'b1;
							ir_load <= 1'b1;
							pc_inc <= 1'b1;
						end
					end

					3'b0101110: begin		//.
						wr <= 1'b1;
						ioreq <= 1'b1;
						fsm_next <= RUN;
						
						if(ready) begin
							ir_load <= 1'b1;
							pc_inc <= 1'b1;
						end
					end
					
					3'b1011011: begin		//[
						ir_load <= 1'b1;
						pc_inc <= 1'b1;
						
						if(data_reg == 7'b0)
							fsm_next <= INSTANT_ZERO_EXEPTION_RECOVERY;
						else begin
							sp_inc <= 1'b1;
							stack_load <= 1'b1;
							fsm_next <= RUN;
						end
					end
					
					3'b1011101: begin		//]
						if(~(data_reg == 7'b0)) begin
							pc_load <= 1'b1;
							fsm_next <= JUMP_RECOVERY;
						end
						else begin
							ir_load <= 1'b1;
							pc_inc <= 1'b1;
							sp_dec <= 1'b1;
							fsm_next <= RUN;
						end
					end
					
					default: begin		//illegal opcode, ignoring (NOP)
						fsm_next <= RUN;
						ir_load <= 1'b1;
						pc_inc <= 1'b1;
					end
					
				endcase
				
			end
			
			UPDATE_DATA: begin
				rd <= 1'b1;
				mreq <= 1'b1;
				
				if(ready) begin
					data_reg_load <= 1'b1;
					fsm_next <= RUN;
				end
				else
					fsm_next <= UPDATE_DATA;
			end
			
			INSTANT_ZERO_EXEPTION_RECOVERY: begin
				ir_load <= 1'b1;
				pc_inc <= 1'b1;
				
				if(ir == 3'b1011101)
					fsm_next <= RUN;
				else
					fsm_next <= INSTANT_ZERO_EXEPTION_RECOVERY;
			end
			
			JUMP_RECOVERY: begin
				ir_load <= 1'b1;
				pc_inc <= 1'b1;
				fsm_next <= RUN;
			end
			
			default: fsm_next <= RAM_CLEAR;
			
		endcase
	end

//	Function clogb2
	
	function integer clogb2;
		input [31:0] value;
		integer 	i;
		begin
			clogb2 = 0;
			for(i = 0; 2**i < value; i = i + 1)
				clogb2 = i + 1;
		end
	endfunction

endmodule
