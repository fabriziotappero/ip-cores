`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:59:10 10/15/2013 
// Design Name: 
// Module Name:    accumulate 
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
module accumulate #(	parameter size_mul_mantissa  = 48)	//mantissa bits)
						(	input [size_mul_mantissa - 1:0] m_a,
							input [size_mul_mantissa - 1:0] m_b,
							input eff_op,
							output[size_mul_mantissa + 1 : 0] adder_mantissa);

assign adder_mantissa = (eff_op)? ({1'b0, m_a} - {1'b0, m_b}) : ({1'b0, m_a} + {1'b0, m_b});

endmodule
