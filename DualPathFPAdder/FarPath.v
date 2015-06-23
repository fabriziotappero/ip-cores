`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    00:31:57 11/19/2013 
// Design Name: 
// Module Name:    FarPath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A ± B when |Ea-Eb| >= 2
//
// Dependencies: 	rounding.v
//					shifter.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FarPath	#(	parameter size_in_mantissa			= 24, 	//1.M
					parameter size_out_mantissa			= 24,
					parameter size_exponent 			= 8,
					parameter pipeline					= 0,
					parameter pipeline_pos				= 0,	// 8 bits
					parameter size_counter				= 5,	//log2(size_in_mantissa) + 1 = 5)
					parameter double_size_in_mantissa   = size_in_mantissa + size_in_mantissa)
				(	input [size_in_mantissa	- 1	: 0] m_a_number,
					input [size_in_mantissa - 1 : 0] m_b_number,
					input eff_op,
					input [size_exponent		: 0] exp_inter,
					input [size_exponent - 1 : 0] exp_difference,
					output[size_out_mantissa- 1 : 0] resulted_m_o,
					output[size_exponent - 1	: 0] resulted_e_o);

	wire [size_exponent - 1	: 0] adjust_mantissa;
	wire [size_exponent - 1 : 0] unadjusted_exponent;
	wire [double_size_in_mantissa:0] normalized_mantissa;
	
	wire [size_in_mantissa - 1	: 0] shifted_m_b;
	wire [size_in_mantissa + 2	: 0] adder_mantissa;
	wire [size_in_mantissa + 1	: 0] unnormalized_mantissa;
	
	wire [size_in_mantissa - 1 : 0] initial_rounding_bits;
	wire [size_in_mantissa - 2 : 0] inter_rounding_bits;
	
	wire dummy_bit;
	wire dummy_ovf, negation_cond, correction;
	
	//shift m_b_number				
	shifter #(	.INPUT_SIZE(size_in_mantissa),
				.SHIFT_SIZE(size_exponent),
				.OUTPUT_SIZE(double_size_in_mantissa),
				.DIRECTION(1'b0), //0=right, 1=left
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		m_b_shifter_instance(	.a(m_b_number),//mantissa
								.arith(1'b0),//logical shift
								.shft(exp_difference),
								.shifted_a({shifted_m_b, initial_rounding_bits}));
													
	
	//compute addition
	assign adder_mantissa = (eff_op)? 	({1'b0, m_a_number, 1'b0} - {1'b0, shifted_m_b, initial_rounding_bits[size_in_mantissa - 1]}) : 
										({1'b0, m_a_number, 1'b0} + {1'b0, shifted_m_b, initial_rounding_bits[size_in_mantissa - 1]});
	
	//compute unnormalized_mantissa
	assign unnormalized_mantissa = (adder_mantissa[size_in_mantissa + 2])? ~adder_mantissa[size_in_mantissa + 1 : 0] : adder_mantissa[size_in_mantissa + 1 : 0];
	
	assign inter_rounding_bits = ((eff_op)? ((|initial_rounding_bits[size_in_mantissa - 2 : 0])?~initial_rounding_bits[size_in_mantissa - 2 : 0] : initial_rounding_bits[size_in_mantissa - 2 : 0]) : initial_rounding_bits[size_in_mantissa - 2 : 0]);
	
	
	assign adjust_mantissa = unnormalized_mantissa[size_in_mantissa + 1]? 2'd0 :
										unnormalized_mantissa[size_in_mantissa]? 2'd1 : 2'd2;							
										
	//compute shifting over unnormalized_mantissa
	shifter #(	.INPUT_SIZE(double_size_in_mantissa+1),
					.SHIFT_SIZE(size_exponent),
					.OUTPUT_SIZE(double_size_in_mantissa+2),
					.DIRECTION(1'b1),
					.PIPELINE(pipeline),
					.POSITION(pipeline_pos))
		unnormalized_no_shifter_instance(.a({unnormalized_mantissa, inter_rounding_bits}),
													.arith(inter_rounding_bits[0]),
													.shft(adjust_mantissa),
													.shifted_a({normalized_mantissa, dummy_bit}));
	
	assign correction = eff_op? ((|initial_rounding_bits[size_in_mantissa - 2 : 0])? 
								((adder_mantissa[0] | ((~adder_mantissa[0]) & (~adder_mantissa[size_in_mantissa]) & (~initial_rounding_bits[size_in_mantissa - 1]) 
										& (~(&{normalized_mantissa[size_in_mantissa-1 : 0],dummy_bit}))))? 1'b1 : 1'b0) : 1'b0) : 1'b0;
	
	
	//instantiate rounding_component
	rounding #(	.SIZE_MOST_S_MANTISSA(size_out_mantissa),
					.SIZE_LEAST_S_MANTISSA(size_out_mantissa + 2'd1))
		rounding_instance(	.unrounded_mantissa(normalized_mantissa[double_size_in_mantissa : double_size_in_mantissa - size_out_mantissa + 1]),
									.dummy_bits(normalized_mantissa[double_size_in_mantissa - size_out_mantissa: 0]),
									.correction(correction),
									.rounded_mantissa(resulted_m_o));
	
	assign unadjusted_exponent = exp_inter - adjust_mantissa;	
	assign resulted_e_o = unadjusted_exponent + 1'b1;
	
endmodule
