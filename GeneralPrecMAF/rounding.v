`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:49 11/04/2013 
// Design Name: 
// Module Name:    rounding 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A ± B
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module rounding #(	parameter SIZE_MOST_S_MANTISSA = 24,
					parameter SIZE_LEAST_S_MANTISSA= 25)
				(	input [SIZE_MOST_S_MANTISSA - 1 : 0] unrounded_mantissa,
					input [SIZE_LEAST_S_MANTISSA- 1 : 0] dummy_bits,
					output[SIZE_MOST_S_MANTISSA - 1 : 0] rounded_mantissa);
	
	wire g, sticky, round_dec;
	
	assign g = dummy_bits[SIZE_LEAST_S_MANTISSA - 1];
	assign sticky = |(dummy_bits[SIZE_LEAST_S_MANTISSA - 2 : 0]);
	assign round_dec = g & (unrounded_mantissa[0] | sticky);
	assign rounded_mantissa = unrounded_mantissa + round_dec;
	
endmodule