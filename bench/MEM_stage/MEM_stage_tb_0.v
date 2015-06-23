////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:00:04 02/09/2012
// Design Name:   MEM_stage
// Module Name:   F:/Projects/My_MIPS/mips_16/backend/Xilinx/mips_16/MEM_stage_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MEM_stage
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

module MEM_stage_tb_0_v;

	// Inputs
	reg clk;
	reg rst;
	reg [37:0] pipeline_reg_in;

	// Outputs
	wire [36:0] pipeline_reg_out;
	wire [2:0] mem_op_dest;
	
	parameter CLK_PERIOD = 10;
	always #(CLK_PERIOD /2) 
		clk =~clk;
		
	// Instantiate the Unit Under Test (UUT)
	MEM_stage uut (
		.clk(clk), 
		.rst(rst), 
		.pipeline_reg_in(pipeline_reg_in), 
		.pipeline_reg_out(pipeline_reg_out), 
		.mem_op_dest(mem_op_dest)
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		pipeline_reg_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#(CLK_PERIOD/2)
		#1
		#(CLK_PERIOD*1) rst = 1;
		#(CLK_PERIOD*1) rst = 0;
		
		#(CLK_PERIOD*10)
		
		uut.dmem.ram[128] = 16'h69fe;
		pipeline_reg_in = {16'd128, 1'b1, 16'h69fe, 5'b10101};
		
		#(CLK_PERIOD*0.5)
		if (mem_op_dest == 3'b010)
			$display("ok1 ");
		else
			$display("error1, %x ", mem_op_dest);
			
		#(CLK_PERIOD*0.5)
		if( pipeline_reg_out == {16'd128, 16'h69fe, 5'b10101} )
			$display("ok2 ");
		else
			$display("error2, %x ", pipeline_reg_out);
			
		#(CLK_PERIOD*10)
		$stop;
	end
      
endmodule

