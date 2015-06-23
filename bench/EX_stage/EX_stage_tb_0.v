////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:27:50 02/08/2012
// Design Name:   EX_stage
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/EX_stage/EX_stage_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: EX_stage
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
module EX_stage_tb_0_v;

	// Inputs
	reg clk;
	reg rst;
	reg [56:0] pipeline_reg_in;

	// Outputs
	wire [37:0] pipeline_reg_out;
	wire [2:0] ex_op_dest;

	// Instantiate the Unit Under Test (UUT)
	EX_stage uut (
		.clk(clk), 
		.rst(rst), 
		.pipeline_reg_in(pipeline_reg_in), 
		.pipeline_reg_out(pipeline_reg_out), 
		.ex_op_dest(ex_op_dest)
	);
	
	parameter CLK_PERIOD = 10;
	always #(CLK_PERIOD /2) 
		clk =~clk;
	
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
		pipeline_reg_in = {`ALU_ADD, 16'd12345, 16'd12345, 22'hcad28};
		
		#(CLK_PERIOD*0.5)
		if (ex_op_dest == 3'b100)
			$display("ok1 ");
		else
			$display("error1, %x ", ex_op_dest);
			
		#(CLK_PERIOD*0.5)
		if( pipeline_reg_out == {16'd24690, 22'hcad28} )
			$display("ok2 ");
		else
			$display("error2, %x ", pipeline_reg_out);
			
		#(CLK_PERIOD*10)
		$stop;
	end
      
endmodule

