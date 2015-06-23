`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:21:32 02/09/2012
// Design Name:   WB_stage
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/WB_stage/WB_stage_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: WB_stage
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module WB_stage_tb_0_v;

	// Inputs
	reg [36:0] pipeline_reg_in;

	// Outputs
	wire reg_write_en;
	wire [2:0] reg_write_dest;
	wire [15:0] reg_write_data;
	wire [2:0] wb_op_dest;

	// Instantiate the Unit Under Test (UUT)
	WB_stage uut (
		.pipeline_reg_in(pipeline_reg_in), 
		.reg_write_en(reg_write_en), 
		.reg_write_dest(reg_write_dest), 
		.reg_write_data(reg_write_data), 
		.wb_op_dest(wb_op_dest)
	);

	initial begin
		// Initialize Inputs
		pipeline_reg_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		pipeline_reg_in = {16'hf421, 16'h69fe, 5'b10101};
		#10
		if(	
			 reg_write_en	==	1		&&
			 reg_write_dest	==	3'b010	&&
			 wb_op_dest		==	3'b010	&&
			 reg_write_data	==	16'h69fe
		)
			$display("ok1");
		else
			$display("error1");
			
		pipeline_reg_in = {16'hf421, 16'h69fe, 5'b11100};
		#10
		if(	
			 reg_write_en	==	1		&&
			 reg_write_dest	==	3'b110	&&
			 wb_op_dest		==	3'b110	&&
			 reg_write_data	==	16'hf421
		)
			$display("ok1");
		else
			$display("error1");
		#100
		$stop;
	end
      
endmodule

