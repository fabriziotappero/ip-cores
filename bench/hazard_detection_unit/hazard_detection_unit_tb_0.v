`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:54:44 02/09/2012
// Design Name:   hazard_detection_unit
// Module Name:   F:/Projects/My_MIPS/mips_16/bench/hazard_detection_unit/hazard_detection_unit_tb_0.v
// Project Name:  mips_16
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hazard_detection_unit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hazard_detection_unit_tb_0_v;

	// Inputs
	reg [2:0] decoding_op_src1;
	reg [2:0] decoding_op_src2;
	reg [2:0] ex_op_dest;
	reg [2:0] mem_op_dest;
	reg [2:0] wb_op_dest;

	// Outputs
	wire pipeline_stall_n;

	// Instantiate the Unit Under Test (UUT)
	hazard_detection_unit uut (
		.decoding_op_src1(decoding_op_src1), 
		.decoding_op_src2(decoding_op_src2), 
		.ex_op_dest(ex_op_dest), 
		.mem_op_dest(mem_op_dest), 
		.wb_op_dest(wb_op_dest), 
		.pipeline_stall_n(pipeline_stall_n)
	);

	initial begin
		// Initialize Inputs
		decoding_op_src1 = 0;
		decoding_op_src2 = 0;
		ex_op_dest = 0;
		mem_op_dest = 0;
		wb_op_dest = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#10
		decoding_op_src1 = 0;
		decoding_op_src2 = 0;
		ex_op_dest = 1;
		mem_op_dest = 2;
		wb_op_dest = 3;
		#10
		if(pipeline_stall_n == 1)
			$display("ok1");
		else
			$display("error1");
		
		#10
		decoding_op_src1 = 5;
		decoding_op_src2 = 0;
		ex_op_dest = 5;
		mem_op_dest = 5;
		wb_op_dest = 3;
		#10
		if(pipeline_stall_n == 0)
			$display("ok2");
		else
			$display("error2");
		
		
		#10
		decoding_op_src1 = 5;
		decoding_op_src2 = 5;
		ex_op_dest = 5;
		mem_op_dest = 5;
		wb_op_dest = 0;
		#10
		if(pipeline_stall_n == 0)
			$display("ok3");
		else
			$display("error3");
		
		#10
		decoding_op_src1 = 5;
		decoding_op_src2 = 5;
		ex_op_dest = 7;
		mem_op_dest = 5;
		wb_op_dest = 0;
		#10
		if(pipeline_stall_n == 0)
			$display("ok4");
		else
			$display("error4");
		
		#10
		decoding_op_src1 = 5;
		decoding_op_src2 = 5;
		ex_op_dest = 0;
		mem_op_dest = 0;
		wb_op_dest = 0;
		#10
		if(pipeline_stall_n == 1)
			$display("ok5");
		else
			$display("error5");
			
			
		#100
		$stop;
	end
      
endmodule

