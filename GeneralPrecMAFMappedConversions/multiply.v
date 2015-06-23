`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:58:54 10/15/2013 
// Design Name: 
// Module Name:    multiply 
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
//
//////////////////////////////////////////////////////////////////////////////////
module multiply #(	parameter size_mantissa = 24,	//mantissa bits
							parameter size_counter	= 5,	//log2(size_mantissa) + 1 = 5
							parameter size_mul_mantissa = size_mantissa + size_mantissa)
						(	input [size_mantissa - 1:0] a_mantissa_i,
							input [size_mantissa - 1:0] b_mantissa_i,
							output [size_mul_mantissa-1:0] mul_mantissa);

	assign mul_mantissa = a_mantissa_i * b_mantissa_i;

endmodule
