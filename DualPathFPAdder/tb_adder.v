`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    16:09:49 02/07/2014 
// Design Name: 
// Module Name:    tb_adder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: TestBench
//				//do not take into consideration cases for which the operation generates a NaN or Infinity exception (with corresponding sign) when initial "special cases" are not such exceptions
// Dependencies: 	DualPathFPAdder
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define input_file "test_add.input"

module tb_adder;

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
					statusI = $fscanf(f,"%35b %35b\n",a_number_i_next,b_number_i_next);
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
			$display("Correct cases: %d \nIncorrect cases: %d", correct_cases, incorrect_cases);
			$display("\tPercentage = %f ", correct_cases/200.07);
			$stop();
      end
		
	assign correct = (result_next[31:0] == resulting_number_o[31:0] || result_next[31:0] == 32'd0)? 1 : 0;
	
	always #2	clk = ~clk;
	
	DualPathFPAdder #(
						.size_mantissa  (25))
		DualPathFPAdder_instance (	
										.a_number_i         (a_number_i_next	),
										.b_number_i         (b_number_i_next	),
										.sub                (1'b0               ),
										.resulted_number_o 	(resulting_number_o ));
endmodule