`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:53:05 10/15/2013 
// Design Name: 
// Module Name:    Multiply_AccumulateConversion
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: C ± A*B with mapped conversions, conversion applies to C number
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Multiply_AccumulateConversion #(	parameter size_mantissa = 24,	//mantissa bits(1.M)
										parameter size_exponent = 8,	//exponent bits
										parameter size_counter	= 5,	//log2(size_mantissa) + 1 = 5
										parameter size_exception_field = 2,	// zero/normal numbers/infinity/NaN
										parameter [size_exception_field - 1 : 0] zero			= 00, //00
										parameter [size_exception_field - 1 : 0] normal_number 	= 01, //01
										parameter [size_exception_field - 1 : 0] infinity		= 10, //10
										parameter [size_exception_field - 1 : 0] NaN			= 11, //11
										parameter size_integer			= 32,
										parameter counter_integer		= 6, //log2(size_integer) + 1 = 6)
										parameter [1 : 0] FP_operation 	= 0, //00 
										parameter [1 : 0] FP_to_int		= 1, //01 
										parameter [1 : 0] int_to_FP		= 2, //10 
										parameter pipeline		= 0,
										parameter pipeline_pos	= 0,  //8 bits
								
										parameter size = size_exponent + size_mantissa + size_exception_field)
									(	input [1 : 0] conversion,
										input [size - 1:0] c_number_i,
										input [size - 1:0] a_number_i,
										input [size - 1:0] b_number_i,
										input sub,
										output[size - 1:0] resulting_number_o);
	
	parameter size_mul_mantissa = size_mantissa + size_mantissa;
	parameter size_mul_counter 	= size_counter + 1;
	parameter max_size 			= (size_integer > size_mantissa)? size_integer : size_mantissa;
	parameter max_counter		= (counter_integer > size_counter)? counter_integer : size_counter;
	parameter size_diff_i_m 	= (size_integer > size_mantissa)? (size_integer - size_mantissa) : (size_mantissa - size_integer);
	parameter bias 				= {1'b0,{(size_exponent-1){1'b1}}};
	parameter exp_biased 		= bias + size_mantissa;
	parameter exponent			= (size_mul_mantissa - max_size) + exp_biased;
	parameter subtr				= max_size -2'd2;
	
	parameter bias_0_bits 		= size_exponent - 1;
	parameter shift_mantissa_0_bits = size_mantissa-1'b1;
	
	
	wire [size_exception_field - 1 : 0] sp_case_a_number, sp_case_b_number, sp_case_c_number;
	wire [size_mantissa - 1 : 0] m_a_number, m_b_number, m_c_number;
	wire [size_exponent - 1 : 0] e_a_number, e_b_number, e_c_number;
	wire s_a_number, s_b_number, s_c_number;
	
	wire [size_exponent     : 0] ab_greater_exponent, c_greater_exponent;
	
	wire [size_exponent - 1 : 0] exp_difference;
	wire [size_exponent     : 0] exp_inter;
	
	wire [size_mantissa - 2	: 0] mul_mantissa;
	wire [size_mul_mantissa - 1	: 0] m_ab_mantissa, c_mantissa;
	wire [size_exponent			: 0] e_ab_number_inter, e_ab_number;
	wire [size_mul_counter - 1	: 0] lz_mul;
	
	wire zero_flag;
	wire sign_res, sign_inter;
	wire eff_op;
	
	wire [size_mantissa - 1 	: 0] initial_rounding_bits, inter_rounding_bits, final_rounding_bits, max_inter_rounding_bits;
	wire [size_mul_mantissa + 1 : 0] normalized_mantissa, adder_mantissa;
	wire [size_mul_mantissa		: 0] unnormalized_mantissa;
	wire [size_mul_mantissa - 1 : 0] shifted_m_ab, convert_neg_mantissa, mantissa_to_shift;
	wire [size_mul_mantissa - 1 : 0] m_c, m_ab;
	
	wire [size_exception_field - 1 : 0] sp_case_mul_result_o;
	
	wire [size_exception_field - 1 : 0] sp_case_o, sp_case_result_o;
	wire [size_mantissa - 2 : 0] final_mantissa;
	wire [size_exponent - 1 : 0] final_exponent;
	wire [size_mantissa : 0] rounded_mantissa;
	
	wire [max_size - 1 : 0]	entity_to_round;
	wire [size_mul_mantissa + 1 : 0] dummy_to_round, inter_dummy_to_round;
	wire [max_size - size_mantissa - 2 : 0] dummy_out;
	
	wire [size_mantissa - 1	: 0] resulted_mantissa;
	wire [size_exponent - 1 : 0] resulted_exponent;
	
	wire [size_exponent  : 0] subtracter;
	
	wire [size_mul_mantissa-max_size : 0] max_entityINT_FP_msb;
	wire [size_exponent     : 0] shift_value_when_positive_exponent, shift_value_when_negative_exponent;
	wire [size_exponent - 1 : 0] shift_value, shft_val;
	wire [size_exponent - 1 : 0] max_unadjusted_exponent, max_adjust_exponent, adjust;
	wire [size_exponent - 1 : 0] max_exp_selection;
	wire [size_exponent - 1	: 0] max_resulted_e_o;
	wire [max_size - 1 : 0] max_entityINT_FP, max_entityFP_INT;
	wire lsb_shft_bit;
	wire arith_shift;
	wire max_ovf;

	wire do_conversion;
	
	assign do_conversion = |conversion; //let me know if there is a conversion
	
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
	
	assign subtracter =  e_c_number - bias;
	assign shift_value_when_positive_exponent = subtr - subtracter[size_exponent-1 : 0];
	assign shift_value_when_negative_exponent = max_size + (~subtracter[size_exponent-1 : 0]);
	assign shift_value = (subtracter[size_exponent])? shift_value_when_negative_exponent[size_exponent - 1 : 0] :
	                     (shift_value_when_positive_exponent[size_exponent])? (~shift_value_when_positive_exponent[size_exponent - 1 : 0]): 
	                                                                           shift_value_when_positive_exponent[size_exponent - 1 : 0];
	assign shft_val = do_conversion? shift_value : exp_difference;
	assign convert_neg_mantissa = {{(size_mantissa){1'b1}}, 1'b0, ~c_number_i[size_mantissa-2 : 0]};
	assign mantissa_to_shift = conversion[0]? 	(s_c_number? {{size_mantissa{1'b1}}, convert_neg_mantissa + 1'b1} : {{size_mantissa{1'b0}}, 1'b1, c_number_i[size_mantissa-2 : 0]}) :
								m_ab;
	assign arith_shift = conversion[0]? s_c_number : 1'b0;
	
	//shift m_ab_number				
	shifter #(	.INPUT_SIZE(size_mul_mantissa),
				.SHIFT_SIZE(size_exponent),
				.OUTPUT_SIZE(size_mul_mantissa + size_mantissa),
				.DIRECTION(1'b0), //0=right, 1=left
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		m_b_shifter_instance(	.a(mantissa_to_shift),//mantissa
								.arith(arith_shift),//logical shift
								.shft(shft_val),
								.shifted_a({shifted_m_ab, initial_rounding_bits}));
	
	assign max_entityFP_INT = {s_c_number, shifted_m_ab[max_size - size_diff_i_m - 1 : 0], initial_rounding_bits[size_mantissa - 1 : size_mantissa - size_diff_i_m + 1]};
	
	
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
	assign 	unnormalized_mantissa =
				(adder_mantissa[size_mul_mantissa + 1])?	(~adder_mantissa[size_mul_mantissa : 0]) : adder_mantissa[size_mul_mantissa 	: 0];
	assign 	inter_rounding_bits = conversion[0]? {initial_rounding_bits[size_mantissa - size_diff_i_m : 0], {(size_diff_i_m - 1){initial_rounding_bits[0]}}} : 
									conversion[1]? 	{size_mantissa{1'b0}} : 
													((adder_mantissa[size_mul_mantissa + 1])? ~initial_rounding_bits : initial_rounding_bits);
												
	assign max_entityINT_FP = do_conversion? (c_number_i[size_integer - 1]? (~c_number_i[max_size-1 : 0]) :  c_number_i[max_size-1 : 0]) : 
													unnormalized_mantissa[max_size-1 : 0];
	assign max_entityINT_FP_msb = do_conversion? {(size_mul_mantissa-max_size+1){1'b0}} : unnormalized_mantissa[size_mul_mantissa : max_size];
	
	assign lsb_shft_bit = do_conversion? 	conversion[0]? s_c_number : c_number_i[size_integer-1] : max_entityINT_FP[0];
	
	assign max_ovf = do_conversion? 1'b0 : unnormalized_mantissa[size_mul_mantissa];
	
	//instantiate leading_zeros component
	leading_zeros #(.SIZE_INT(size_mul_mantissa + 1'b1),
					.SIZE_COUNTER(size_mul_counter),
					.PIPELINE(pipeline))
		leading_zeros_instance(	.a({max_entityINT_FP_msb, max_entityINT_FP}),
								.ovf(max_ovf), 
								.lz(lz_mul));
	
	assign max_inter_rounding_bits = conversion[1]? {size_mantissa{c_number_i[size_integer-1]}} : {inter_rounding_bits, inter_rounding_bits[0]};
	
	//instantiate shifter component
	shifter #(	.INPUT_SIZE(size_mul_mantissa + size_mantissa + 1),
				.SHIFT_SIZE(size_mul_counter),
				.OUTPUT_SIZE(size_mul_mantissa + size_mantissa + 2),
				.DIRECTION(1'b1), 
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		shifter_instance(	.a( {max_entityINT_FP_msb, max_entityINT_FP, max_inter_rounding_bits}),
							.arith(lsb_shft_bit),
							.shft(lz_mul),
							.shifted_a({normalized_mantissa, final_rounding_bits}));
	
	assign inter_dummy_to_round = {normalized_mantissa[size_mantissa + 1 : 0], final_rounding_bits};
	
	assign entity_to_round 	= conversion[0]? max_entityFP_INT : {{(max_size - size_mantissa){1'b0}}, normalized_mantissa[size_mul_mantissa+1 : size_mantissa + 2]};
	assign dummy_to_round	= conversion[0]? {inter_rounding_bits, {(size_mantissa + 2){1'b0}}} :  
								(conversion[1] & (&{normalized_mantissa[size_mantissa : 0], final_rounding_bits}) & (~normalized_mantissa[size_mantissa+1]))? 
									(c_number_i[size_integer-1]? 	~inter_dummy_to_round : inter_dummy_to_round) :
								{normalized_mantissa[size_mantissa + 1 : 0], final_rounding_bits};
								
	//instantiate rounding_component
	rounding #(	.SIZE_MOST_S_MANTISSA(max_size),
				.SIZE_LEAST_S_MANTISSA(size_mul_mantissa+2))
		rounding_instance(	.unrounded_mantissa(entity_to_round ),
		                    .dummy_bits(dummy_to_round),
		                    .rounded_mantissa({dummy_out, rounded_mantissa}));

							
	assign max_exp_selection = do_conversion? exponent : exp_inter;
	assign max_adjust_exponent = max_exp_selection - lz_mul;
	assign adjust = do_conversion? size_diff_i_m : 2'd2;
	assign max_unadjusted_exponent = max_adjust_exponent + adjust;
	assign max_resulted_e_o = (do_conversion & ~(|{max_entityINT_FP_msb, max_entityINT_FP}))? bias : max_unadjusted_exponent + rounded_mantissa[size_mantissa];
	
	assign resulted_exponent = conversion[0]? 	max_entityFP_INT[size_mantissa+size_exponent-2 : size_mantissa-1] : max_resulted_e_o;
	assign resulted_mantissa = conversion[0]?	rounded_mantissa/*max_entityFP_INT[size_mantissa-1 : 0]*/ :
												(rounded_mantissa[size_mantissa])? 	(rounded_mantissa[size_mantissa : 1]) : 
																						(rounded_mantissa[size_mantissa-1 : 0]);
							
	//instantiate special_cases_mul_acc component
	special_cases_mul_acc	#(	.size_exception_field(size_exception_field),
								.zero(zero),
								.normal_number(normal_number),
								.infinity(infinity),
								.NaN(NaN))
		special_cases_mul_acc_instance	(	.sp_case_a_number(sp_case_a_number),
											.sp_case_b_number(sp_case_b_number),
											.sp_case_c_number(sp_case_c_number),
											.sp_case_result_o(sp_case_o));
											
	special_cases_mul	#(	.size_exception_field(size_exception_field),
							.zero(zero),
							.normal_number(normal_number),
							.infinity(infinity),
							.NaN(NaN))
		special_cases_mul_instance(	.sp_case_a_number(sp_case_a_number),
									.sp_case_b_number(sp_case_b_number),
									.sp_case_result_o(sp_case_mul_result_o));
	
	assign sp_case_result_o = conversion[0]? 2'd0 : 
								conversion[1]? normal_number : sp_case_o;
	
	//set zero_flag in case of equal numbers
	assign zero_flag = ~(|(rounded_mantissa));
	
	//compute resulted_sign
	sign_computation sign_computation_instance(	.eff_op					(eff_op),
												.s_a_number				(s_c_number),
												.s_b_number				(s_a_number ^ s_b_number),
												.a_greater_exponent		(c_greater_exponent[size_exponent]),
												.b_greater_exponent		(ab_greater_exponent[size_exponent]),
												.adder_mantissa_ovf		(adder_mantissa[size_mul_mantissa]),
												.sign					(sign_inter));
	
	assign sign_res = 	conversion[0]? 1'b0 :
						conversion[1]? c_number_i[size_integer-1] : 
						sign_inter;
						//((eff_op)?	(!c_greater_exponent[size_exponent]? 
						//				(!ab_greater_exponent[size_exponent]? ~adder_mantissa[size_mul_mantissa+1] : s_c_number) : ~(s_b_number^s_a_number)) : s_c_number);
													
	assign final_mantissa = resulted_mantissa;
	
	assign final_exponent = resulted_exponent;
	assign resulting_number_o = (zero_flag)? {size{1'b0}} : 
								((!(|sp_case_a_number) || !(|sp_case_b_number)) & (~do_conversion))? {c_number_i[size-1 : size-size_exception_field], s_c_number, c_number_i[size-1-size_exception_field-1 : 0]} :
									((!(|sp_case_c_number)) & (~do_conversion) )? 
										(sub?
											{sp_case_mul_result_o, ~(s_a_number^s_b_number), e_ab_number[size_exponent-1 : 0], mul_mantissa} :
											{sp_case_mul_result_o, s_a_number^s_b_number, e_ab_number[size_exponent-1 : 0], mul_mantissa}) :
												{sp_case_result_o, sign_res, final_exponent, final_mantissa};
endmodule
