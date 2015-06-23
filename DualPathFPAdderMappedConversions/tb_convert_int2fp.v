`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    16:09:49 02/07/2014 
// Design Name: 
// Module Name:    tb_convert_int2fp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: TestBench - conversion from INTEGER to Floating Point
//				
// Dependencies: 	SinglePathAdderConversion
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define input_file "test_int2fp.input"

module tb_convert_int2fp;

	parameter [1:0] add = 2'd0;
	parameter [1:0] fp2int = 2'd1;
	parameter [1:0] int2fp = 2'd2;

	reg clk, rst, start;
	reg [34:0] a_number_i_next;
	reg [34:0] b_number_i_next;
	reg unnecessary;
	reg [34:0] result_next;
	wire [34:0] resulting_number_o;
	integer f;
	integer i;
	real correct_cases, incorrect_cases;
	integer statusI, statusJ;
	
	wire correct;
	
	initial
		begin
			i = 0;
			correct_cases = 0;
			incorrect_cases = 0;
			clk = 1;
			rst = 0;
			f = $fopen(`input_file, "r");	
			while (!$feof(f)) 
				begin
					statusI = $fscanf(f,"%32b\n",a_number_i_next);
					statusJ = $fscanf(f,"%1b %35b\n",unnecessary,result_next);
					i = i + 1;
					@(posedge clk);
					@(posedge clk);
					@(posedge clk);
					if (correct)
						correct_cases = correct_cases + 1;
					else
						begin
							incorrect_cases = incorrect_cases + 1;
							$display("Error occured at index #%d \n \tExpDiff = %d\n",i, a_number_i_next[31:24] - b_number_i_next[31:24]);
						end
			end	
			$display("percentage = %f ", correct_cases/200.00);
			$stop();
      end
		
	assign correct = (result_next[34:0] == resulting_number_o[34:0])? 1 : 0;
	
	
	always #2	clk = ~clk;
	
	DualPathAdderConversion #(
						.size_mantissa  (25),
						.size_integer(32))
		DualPathAdderConversion_instance (	
										.conversion         (int2fp         ),
										.a_number_i         (a_number_i_next         ),
										.b_number_i					(a_number_i_next ),
										.sub                (1'b0               ),
										.resulted_number_o (resulting_number_o ));
endmodule
