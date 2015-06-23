`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:53:05 10/15/2013 
// Design Name: 
// Module Name:    Multiply_Accumulate 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: C ± A*B
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Multiply_Accumulate #(	parameter size_mantissa = 24,			//mantissa bits(1.M)
										parameter size_exponent = 8,	//exponent bits
										parameter size_counter	= 5,	//log2(size_mantissa) + 1 = 5
										parameter size_exception_field 	= 2,	// zero/normal numbers/infinity/NaN
										parameter zero					= 00, 	//00
										parameter normal_number 		= 01, 	//01
										parameter infinity				= 10, 	//10
										parameter NaN					= 11, 	//11
										parameter pipeline		= 0,
										parameter pipeline_pos	= 0,  //8 bits
								
										parameter size = size_exponent + size_mantissa + size_exception_field,
										parameter size_mul_mantissa = size_mantissa + size_mantissa,
										parameter size_mul_counter = size_counter + 1)
									(	input [size - 1:0] a_number_i,
										input [size - 1:0] b_number_i,
										input [size - 1:0] c_number_i,
										input sub,
										output[size - 1:0] resulting_number_o);
		
	parameter bias_0_bits = size_exponent - 1;
	parameter shift_mantissa_0_bits = size_mantissa-1'b1;
	
	wire [size_exception_field - 1 : 0] sp_case_a_number, sp_case_b_number, sp_case_c_number;
	wire [size_mantissa - 1 : 0] m_a_number, m_b_number, m_c_number;
	wire [size_exponent - 1 : 0] e_a_number, e_b_number, e_c_number;
	wire s_a_number, s_b_number, s_c_number;
	
	wire [size_exponent     : 0] ab_greater_exponent, c_greater_exponent;
	
	wire [size_exponent - 1 : 0] exp_difference;
	wire [size_exponent - 1 : 0] unadjusted_exponent;
	wire [size_exponent     : 0] exp_inter;
	
	wire [size_mantissa - 2	: 0] mul_mantissa;
	
	wire [size_mul_mantissa - 1	: 0] m_ab_mantissa, c_mantissa;
	wire [size_exponent			: 0] e_ab_number_inter, e_ab_number;
	wire [size_mul_counter - 1	: 0] lz_mul;
	
	wire zero_flag;
	wire sign_res;
	wire eff_op;
	
	wire [size_mantissa - 1 	: 0] initial_rounding_bits, inter_rounding_bits, final_rounding_bits;
	wire [size_mul_mantissa + 1 : 0] normalized_mantissa, adder_mantissa;
	wire [size_mul_mantissa		: 0] unnormalized_mantissa;
	wire [size_mul_mantissa - 1 : 0] shifted_m_ab;
	wire [size_mul_mantissa - 1 : 0] m_c, m_ab;
	
	wire [size_exception_field - 1 : 0] sp_case_mul_result_o;
	
	wire [size_exception_field - 1 : 0] sp_case_result_o;
	wire [size_mantissa - 2 : 0] final_mantissa;
	wire [size_exponent - 1 : 0] final_exponent;
	wire [size_mantissa : 0] rounded_mantissa;
	

	assign m_a_number 			= {1'b1, a_number_i[size_mantissa - 2 :0]};
	assign m_b_number			= {1'b1, b_number_i[size_mantissa - 2 :0]};
	assign m_c_number			= {1'b1, c_number_i[size_mantissa - 2 :0]};
	assign e_a_number			= a_number_i[size_mantissa + size_exponent - 1 : size_mantissa - 1];
	assign e_b_number			= b_number_i[size_mantissa + size_exponent - 1 : size_mantissa - 1];
	assign e_c_number			= c_number_i[size_mantissa + size_exponent - 1 : size_mantissa - 1];
	assign s_a_number			= a_number_i[size - size_exception_field - 1];
	assign s_b_number			= b_number_i[size - size_exception_field - 1];
	assign s_c_number			= c_number_i[size - size_exception_field - 1];
	assign sp_case_a_number	= a_number_i[size - 1 : size - size_exception_field];
	assign sp_case_b_number	= b_number_i[size - 1 : size - size_exception_field];
	assign sp_case_c_number	= c_number_i[size - 1 : size - size_exception_field];
	
	
	//instantiate multiply component
	multiply #(	.size_mantissa(size_mantissa),
					.size_counter(size_counter),
					.size_mul_mantissa(size_mul_mantissa))
		multiply_instance (	.a_mantissa_i(m_a_number),
									.b_mantissa_i(m_b_number),
									.mul_mantissa(m_ab_mantissa));
									
	assign mul_mantissa = m_ab_mantissa[size_mul_mantissa-1]? 	m_ab_mantissa[size_mul_mantissa-2 : size_mul_mantissa - size_mantissa] : 
																m_ab_mantissa[size_mul_mantissa-3 : size_mul_mantissa - size_mantissa - 1];
	
	assign c_mantissa	= {1'b0,m_c_number, {(shift_mantissa_0_bits){1'b0}}};
	assign e_ab_number_inter = e_a_number + e_b_number;
	assign e_ab_number = e_ab_number_inter  - {(bias_0_bits){1'b1}};
	
	//find the greater exponent
	assign ab_greater_exponent = e_ab_number - e_c_number;
	assign c_greater_exponent = e_c_number - e_ab_number;
	
	//find the difference between exponents
	assign exp_difference 	= (ab_greater_exponent[size_exponent])? c_greater_exponent[size_exponent - 1 : 0] : ab_greater_exponent[size_exponent - 1 : 0];
	assign exp_inter 		= (c_greater_exponent[size_exponent])? {1'b0, e_ab_number} : {1'b0, e_c_number};
	
	//set shifter always on m_ab_number
	assign {m_c, m_ab} = (ab_greater_exponent[size_exponent])? {c_mantissa, m_ab_mantissa} : 
							{m_ab_mantissa, c_mantissa};
	
	//shift m_ab_number				
	shifter #(	.INPUT_SIZE(size_mul_mantissa),
				.SHIFT_SIZE(size_exponent),
				.OUTPUT_SIZE(size_mul_mantissa + size_mantissa),
				.DIRECTION(1'b0), //0=right, 1=left
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		m_b_shifter_instance(	.a(m_ab),//mantissa
								.arith(1'b0),//logical shift
								.shft(exp_difference),
								.shifted_a({shifted_m_ab, initial_rounding_bits}));
	
	
	//instantiate effective_op component
	effective_op effective_op_instance(	.sign_a(s_a_number),
													.sign_b(s_b_number),
													.sign_c(s_c_number),
													.sub(sub),
													.eff_sub(eff_op));
	
	//instantiate accumulate component
	accumulate #(.size_mul_mantissa(size_mul_mantissa))
		accumulate_instance (	.m_a(m_c),
								.m_b(shifted_m_ab),
								.eff_op(eff_op),
								.adder_mantissa(adder_mantissa));
	
	//compute unnormalized_mantissa
	assign {unnormalized_mantissa, inter_rounding_bits} = 
				(adder_mantissa[size_mul_mantissa + 1])?	({~adder_mantissa[size_mul_mantissa : 0], ~initial_rounding_bits}) :
															({adder_mantissa[size_mul_mantissa 	: 0], initial_rounding_bits});
																		
	//instantiate leading_zeros component
	leading_zeros #(	.SIZE_INT(size_mul_mantissa + 1'b1),
							.SIZE_COUNTER(size_mul_counter),
							.PIPELINE(pipeline))
		leading_zeros_instance(	.a(unnormalized_mantissa[size_mul_mantissa : 0]),
										.ovf(unnormalized_mantissa[size_mul_mantissa]), 
										.lz(lz_mul));
	
	//instantiate shifter component
	shifter #(	.INPUT_SIZE(size_mul_mantissa + size_mantissa + 1),
					.SHIFT_SIZE(size_mul_counter),
					.OUTPUT_SIZE(size_mul_mantissa + size_mantissa + 2),
					.DIRECTION(1'b1), 
					.PIPELINE(pipeline),
					.POSITION(pipeline_pos))
		shifter_instance(	.a({unnormalized_mantissa, inter_rounding_bits}),
								.arith(1'b0),
								.shft(lz_mul),
								.shifted_a({normalized_mantissa, final_rounding_bits}));
												
	//instantiate rounding_component
	rounding #(	.SIZE_MOST_S_MANTISSA(size_mantissa+1),
				.SIZE_LEAST_S_MANTISSA(size_mul_mantissa+2))
		rounding_instance(	.unrounded_mantissa({1'b0, normalized_mantissa[size_mul_mantissa+1 : size_mantissa + 2]}),
		                    .dummy_bits({normalized_mantissa[size_mantissa + 1 : 0],final_rounding_bits}),
		                    .rounded_mantissa(rounded_mantissa));
		
	//instantiate special_cases_mul and special_cases_mul_acc components
	special_cases_mul_acc	#(	.size_exception_field(size_exception_field),
								.zero(zero),
								.normal_number(normal_number),
								.infinity(infinity),
								.NaN(NaN))
		special_cases_mul_acc_instance	(	.sp_case_a_number(sp_case_a_number),
											.sp_case_b_number(sp_case_b_number),
											.sp_case_c_number(sp_case_c_number),
											.sp_case_result_o(sp_case_result_o));
														
	special_cases_mul	#(	.size_exception_field(size_exception_field),
							.zero(zero),
							.normal_number(normal_number),
							.infinity(infinity),
							.NaN(NaN))
		special_cases_mul_instance(	.sp_case_a_number(sp_case_a_number),
									.sp_case_b_number(sp_case_b_number),
									.sp_case_result_o(sp_case_mul_result_o));
				
	//set zero_flag in case of equal numbers
	assign zero_flag = ~(|(rounded_mantissa));
	
	//compute resulted_sign
	assign sign_res = 	(eff_op)?	(!c_greater_exponent[size_exponent]? 
										(!ab_greater_exponent[size_exponent]? ~adder_mantissa[size_mul_mantissa+1] : s_c_number) : ~(s_b_number^s_a_number)) : s_c_number;
													
	assign final_mantissa = (rounded_mantissa[size_mantissa])? 
									(rounded_mantissa[size_mantissa : 1]) : 
									(rounded_mantissa[size_mantissa-1: 0]);
	
	assign unadjusted_exponent = exp_inter - lz_mul;
	assign final_exponent = unadjusted_exponent + 2'd2;
	assign resulting_number_o = (zero_flag)? {size{1'b0}} :
								(!sp_case_a_number || !sp_case_b_number)? {c_number_i[size-1 : size-size_exception_field], s_c_number, c_number_i[size-1-size_exception_field-1 : 0]} :
								(!sp_case_c_number)? 
									(eff_op?
										{sp_case_mul_result_o, ~(s_a_number^s_b_number), e_ab_number[size_exponent-1 : 0], mul_mantissa} :
										{sp_case_mul_result_o, s_a_number^s_b_number, e_ab_number[size_exponent-1 : 0], mul_mantissa}) :
											{sp_case_result_o, sign_res, final_exponent, final_mantissa};
endmodule
