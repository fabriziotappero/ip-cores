`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    16:09:49 11/04/2013 
// Design Name: 
// Module Name:    rounding 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A ± B rounding
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
					input correction,
					input eff_op,
					output[SIZE_MOST_S_MANTISSA - 1 : 0] rounded_mantissa);
		
	wire g,r, sticky, round_dec;
		
	assign g 		= dummy_bits[SIZE_LEAST_S_MANTISSA - 1];
	assign sticky 	= (|(dummy_bits[SIZE_LEAST_S_MANTISSA - 3 : 0]));
	assign round 	= dummy_bits[SIZE_LEAST_S_MANTISSA - 2];
		
	assign round_dec 		= (g & (unrounded_mantissa[0] | sticky | round));
	assign rounded_mantissa = (correction? (round_dec? unrounded_mantissa : unrounded_mantissa - 1'b1) : (round_dec? unrounded_mantissa + 1 : unrounded_mantissa));
	
endmodule