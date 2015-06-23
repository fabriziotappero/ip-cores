/***************************************************
 * Module: instruction_mem
 * Project: mips_16
 * Author: fzy
 * Description: 
 *     a rom
 *
 * Revise history:
 *     
 ***************************************************/
`timescale 1ns/1ps
`include "mips_16_defs.v"
 
`ifdef USE_SIMULATION_CODE
module instruction_mem		// a rtl simulation rom, rom initial code can be found in the testbench
(
	input					clk,		// asynchronized!!
	input	[`PC_WIDTH-1:0]	pc,
	
	output	[15:0]			instruction
);
	
	reg	[15:0] rom [2**`INSTR_MEM_ADDR_WIDTH-1 : 0];
	
	wire [`INSTR_MEM_ADDR_WIDTH-1 : 0] rom_addr = pc[`INSTR_MEM_ADDR_WIDTH-1 : 0];
	
	// always @ (posedge clk) begin
	// always @ (*) begin
	    // instruction = rom[rom_addr];
	// end
	
	assign instruction = rom[rom_addr];
	
	
endmodule 
`endif

`ifndef USE_SIMULATION_CODE		
module instruction_mem		// a synthesisable rom implementation
(
	input					clk,		// asynchronized!!
	input	[`PC_WIDTH-1:0]	pc,
	
	output reg	[15:0]		instruction
);
	
	wire [`INSTR_MEM_ADDR_WIDTH-1 : 0] rom_addr = pc[`INSTR_MEM_ADDR_WIDTH-1 : 0];
	
	// ASM code in rom:
	// L1:	ADDI		R1,R0,8
	// 		ADDI		R2,R1,8
	// 		ADDI		R3,R2,8
	// 		ADD			R4,R2,R3
	// 		ST			R4,R1,2
	// 		LD			R5,R1,2
	// 		SUB			R6,R4,R5
	// 		BZ			R6,L1
	// 		ADDI		R7,R7,1
	always @(*)
		case (rom_addr)
			4'b0000: instruction = 16'b1001001000001000;
			4'b0001: instruction = 16'b1001010001001000;
			4'b0010: instruction = 16'b1001011010001000;
			4'b0011: instruction = 16'b0001100010011000;
			4'b0100: instruction = 16'b1011100001000010;
			4'b0101: instruction = 16'b1010101001000010;
			4'b0110: instruction = 16'b0010110100101000;
			4'b0111: instruction = 16'b1100000110111000;
			4'b1000: instruction = 16'b1001111111000001;
			4'b1001: instruction = 16'b0000000000000000;
			4'b1010: instruction = 16'b0000000000000000;
			4'b1011: instruction = 16'b0000000000000000;
			4'b1100: instruction = 16'b0000000000000000;
			4'b1101: instruction = 16'b0000000000000000;
			4'b1110: instruction = 16'b0000000000000000;
			4'b1111: instruction = 16'b0000000000000000;
			default: instruction = 16'b0000000000000000;
	 endcase
	
endmodule 
`endif