////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:51:48 02/06/2012
// Design Name:   IF_stage
// Module Name:   F:/Projects/My_MIPS/mips_16/sim/IF_stage/IF_stage_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: IF_stage
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "mips_16_defs.v"

module IF_stage_tb_0_v;

	// Inputs
	reg clk;
	reg rst;
	reg instruction_fetch_en;
	reg [5:0] branch_offset_imm;
	reg branch_taken;

	// Outputs
	wire [`PC_WIDTH-1:0] pc;
	wire [15:0] instruction;
	
	parameter CLK_PERIOD = 10;
	integer test;
	
	// Instantiate the Unit Under Test (UUT)
	IF_stage uut (
		.clk(clk), 
		.rst(rst), 
		.instruction_fetch_en(instruction_fetch_en),
		.branch_offset_imm(branch_offset_imm), 
		.branch_taken(branch_taken), 
		.pc(pc),
		.instruction(instruction)
	);
	
	always #(CLK_PERIOD /2) 
		clk =~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		instruction_fetch_en = 0;
		branch_offset_imm = 0;
		branch_taken = 0;
		test = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
        display_debug_message;
		#(CLK_PERIOD/2)
		test1;
		test2;
		$stop;
		
		$finish;
		
	end
	
	task display_debug_message;
		begin
			$display("\n***************************");
			$display("IF_stage test");
			$display("***************************\n");
		end
	endtask
	
	task sys_reset;
		begin
			rst = 0;
			#(CLK_PERIOD*1) rst = 1;
			#(CLK_PERIOD*1) rst = 0;
		end
	endtask
	
	task test1;
		begin
			$readmemh("../bench/IF_stage/test1.prog",uut.imem.rom);
			$display("rom load successfully\n");
			
			sys_reset;
			#1
			instruction_fetch_en = 1;
			#(CLK_PERIOD) test = 1;
			
			#(CLK_PERIOD*5)
			sys_reset;
			
			#(CLK_PERIOD*100) test = 0;
			sys_reset;
			
		end
	endtask
	
	task test2;
		begin
			$readmemh("../bench/IF_stage/test1.prog",uut.imem.rom);
			$display("rom load successfully\n");
			
			sys_reset;
			instruction_fetch_en = 1;
			#1
			#(CLK_PERIOD) test = 2;
			
			#(CLK_PERIOD*20)
			instruction_fetch_en = 0;
			branch_taken = 1;
			branch_offset_imm = -30;
			
			#(CLK_PERIOD*3) 
			instruction_fetch_en = 1;
			#(CLK_PERIOD*1) 
			branch_taken = 0;
			branch_offset_imm = 0;
			
			#(CLK_PERIOD*100) test = 0;
			sys_reset;
			
		end
	endtask
	
 	always @ (test) begin
	    case(test)
			1: begin
			    $display("running test1\n");
				 while(test == 1) begin
				    @(uut.pc)
					$display("current pc : %d",uut.pc);
					if(uut.pc == 40) begin
						#1
					    branch_taken = 1;
						branch_offset_imm = -30;
						#(CLK_PERIOD*1) 
						branch_taken =0;
						branch_offset_imm = 0;
					end
				 end
			end
			
			2: begin
			    $display("running test2\n");
				 while(test == 2) begin
				    @(uut.pc)
					$display("current pc : %d",uut.pc);
				 end
			end
			
		endcase
	end
	
endmodule

