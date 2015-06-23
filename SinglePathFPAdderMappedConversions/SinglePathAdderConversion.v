`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    16:09:49 11/04/2013 
// Design Name: 

// Module Name:    SinglePathAdderConversion 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A ± B with mapped conversions
//				//do not take into consideration cases for which the operation generates a NaN or Infinity exception (with corresponding sign) when initial "special cases" are not such exceptions
//
// Dependencies: 	effective_op.v
//					leading_zeros.v
//					rounding.v
//					shifter.v
//					special_cases.v: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SinglePathAdderConversion #(	parameter size_mantissa 	= 24, //calculate the size containing the hiden bit 1.M
							parameter size_exponent 			= 8,
							parameter size_exception_field		= 2,
							parameter size_counter				= 5,	//log2(size_mantissa) + 1 = 5)
							parameter [size_exception_field - 1 : 0] zero			= 0, //00
							parameter [size_exception_field - 1 : 0] normal_number	= 1, //01
							parameter [size_exception_field - 1 : 0] infinity		= 2, //10
							parameter [size_exception_field - 1 : 0] NaN			= 3, //11
							parameter size_integer			= 32,
							parameter counter_integer		= 6,//log2(size_integer) + 1 = 6)
							parameter [1 : 0] FP_operation 	= 0, //00 
							parameter [1 : 0] FP_to_int		= 1, //01 
							parameter [1 : 0] int_to_FP		= 2, //10 
							parameter pipeline				= 0,
							parameter pipeline_pos			= 0,	// 8 bits
							parameter size	= size_mantissa + size_exponent + size_exception_field
							)			
							(	input [1:0] conversion,
								input sub,
								input [size - 1 : 0] a_number_i,
								input [size - 1 : 0] b_number_i,
								output[size - 1 : 0] resulted_number_o);
	
	parameter double_size_mantissa	= size_mantissa + size_mantissa;
	parameter double_size_counter	= size_counter + 1;
	parameter max_size 				= (size_integer > size_mantissa)? size_integer : size_mantissa;
	parameter max_counter			= (counter_integer > size_counter)? counter_integer : size_counter;
	parameter size_diff_i_m 		= (size_integer > size_mantissa)? (size_integer - size_mantissa) : (size_mantissa - size_integer);
	parameter bias 					= {1'b0,{(size_exponent-1){1'b1}}};
	parameter exp_biased 			= bias + size_mantissa;
	parameter exponent				= exp_biased - 1'b1;
	parameter subtr					= max_size -2'd2;
	
	
	wire [size_exception_field - 1 : 0] sp_case_a_number, sp_case_b_number; 
	wire [size_mantissa - 1 : 0] m_a_number, m_b_number;
	wire [size_exponent - 1 : 0] e_a_number, e_b_number;
	wire s_a_number, s_b_number;
	
	wire [size_exponent     : 0] a_greater_exponent, b_greater_exponent;
	
	wire [size_exponent - 1 : 0] exp_difference;
	wire [size_exponent     : 0] exp_inter;
	wire [size_mantissa - 1 : 0] shifted_m_b, convert_neg_mantissa, mantissa_to_shift;
	
	wire [size_mantissa - 1 : 0] initial_rounding_bits, final_rounding_bits;
	wire [size_mantissa - 2 : 0] inter_rounding_bits;
	wire eff_op;
	
	wire [size_mantissa + 2	: 0] adder_mantissa;
	wire [size_mantissa + 1	: 0] unnormalized_mantissa;
	
	wire [size_exception_field - 1 : 0] sp_case_o, resulted_exception_field;
	wire [size_mantissa - 1	: 0] resulted_mantissa;
	wire [size_exponent - 1 : 0] resulted_exponent;
	wire resulted_sign;
	
	wire zero_flag;
	
	wire [size_exponent  : 0] subtracter;
	
	wire [max_size  : 0] dummy_bits;
	wire [size_exponent     : 0] shift_value_when_positive_exponent, shift_value_when_negative_exponent;
	wire [size_exponent - 1 : 0] shift_value, shft_val;
	wire lsb_shft_bit;
	
	wire [size_exponent - 1	: 0] max_resulted_e_o;
	wire [size_exponent - 1 : 0] max_unadjusted_exponent, max_adjust_exponent;
	wire [size_exponent - 1 : 0] max_exp_selection;
	wire [size_mantissa - 1 : 0] r_mantissa;
	wire [max_size 	: 0] max_rounded_mantissa;
	wire [max_counter - 1 : 0] max_lzs;
	wire [max_size - 1 : 0] max_entityINT_FP;
	wire [max_size - 1 : 0] init_entityFP_INT, max_entityFP_INT;
	wire arith_shift;
	wire max_ovf;
	
	reg intermediar_sign;
	wire [4:0] sign_cases;
	wire do_conversion;

	wire dummy_ovf, correction, negation_cond;
	
	assign do_conversion = |conversion; //let me know if there is a conversion
	
	assign e_a_number	= a_number_i[size_mantissa + size_exponent - 1 : size_mantissa - 1];
	assign e_b_number = b_number_i[size_mantissa + size_exponent - 1 : size_mantissa - 1];
	assign s_a_number = a_number_i[size - size_exception_field - 1];
	assign s_b_number = b_number_i[size - size_exception_field - 1];
	assign sp_case_a_number = a_number_i[size - 1 : size - size_exception_field];
	assign sp_case_b_number = b_number_i[size - 1 : size - size_exception_field];
	
	
	//find the greater exponent
	assign a_greater_exponent = e_a_number - e_b_number;
	assign b_greater_exponent = e_b_number - e_a_number;
	
	//find the difference between exponents
	assign exp_difference 	= (a_greater_exponent[size_exponent])? b_greater_exponent[size_exponent - 1 : 0] : a_greater_exponent[size_exponent - 1 : 0];
	assign exp_inter 		= (b_greater_exponent[size_exponent])? {1'b0, e_a_number} : {1'b0, e_b_number};
	
	//set shifter always on m_b_number
	assign {m_a_number, m_b_number} = (b_greater_exponent[size_exponent])? 
													{{1'b1, a_number_i[size_mantissa - 2 :0]}, {1'b1, b_number_i[size_mantissa - 2 :0]}} : 
													{{1'b1, b_number_i[size_mantissa - 2 :0]}, {1'b1, a_number_i[size_mantissa - 2 :0]}};
	
	assign subtracter =  e_a_number - bias;
	assign shift_value_when_positive_exponent = subtr - subtracter[size_exponent-1 : 0];
	assign shift_value_when_negative_exponent = max_size + (~subtracter[size_exponent-1 : 0]);
	assign shift_value = (subtracter[size_exponent])? shift_value_when_negative_exponent[size_exponent - 1 : 0] :
	                     (shift_value_when_positive_exponent[size_exponent])? (~shift_value_when_positive_exponent[size_exponent - 1 : 0]): 
	                                                                           shift_value_when_positive_exponent[size_exponent - 1 : 0];
	assign shft_val = do_conversion? shift_value : exp_difference;
	
	assign convert_neg_mantissa = {1'b0, ~a_number_i[size_mantissa-2 : 0]};
	
	assign mantissa_to_shift = conversion[0]? (s_a_number? convert_neg_mantissa + 1'b1 : {1'b1, a_number_i[size_mantissa-2 : 0]}) : m_b_number;
	assign arith_shift = conversion[0]? s_a_number : 1'b0;
	
	//shift m_b_number				
	shifter #(	.INPUT_SIZE(size_mantissa),
				.SHIFT_SIZE(size_exponent),
				.OUTPUT_SIZE(double_size_mantissa),
				.DIRECTION(1'b0), //0=right, 1=left
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		m_b_shifter_instance(	.a(mantissa_to_shift),//mantissa
								.arith(arith_shift),//logical shift
								.shft(shft_val),
								.shifted_a({shifted_m_b, initial_rounding_bits}));
		
	//istantiate effective_operation_component
	effective_op effective_op_instance( .a_sign(s_a_number), .b_sign(s_b_number), .sub(sub), .eff_op(eff_op));
			
	///compute addition
	assign adder_mantissa = (eff_op)? 	({1'b0, m_a_number, 1'b0} - {1'b0, shifted_m_b, initial_rounding_bits[size_mantissa - 1]}) : 


										({1'b0, m_a_number, 1'b0} + {1'b0, shifted_m_b, initial_rounding_bits[size_mantissa - 1]});
	
	//compute unnormalized_mantissa
	assign unnormalized_mantissa = (adder_mantissa[size_mantissa + 2])? ~adder_mantissa[size_mantissa + 1 : 0] : adder_mantissa[size_mantissa + 1 : 0];
	assign inter_rounding_bits = (~(|exp_difference[size_exponent - 1 : 1]))?
											((adder_mantissa[size_mantissa + 2]? ~initial_rounding_bits[size_mantissa - 2 : 0] : initial_rounding_bits[size_mantissa - 2 : 0])) : 
											((eff_op)? ((|initial_rounding_bits[size_mantissa - 2 : 0])?~initial_rounding_bits[size_mantissa - 2 : 0] : initial_rounding_bits[size_mantissa - 2 : 0]) : initial_rounding_bits[size_mantissa - 2 : 0]);
						
	assign max_entityINT_FP = do_conversion? (a_number_i[size_integer-1]? (~a_number_i[max_size-1 : 0]) : a_number_i[max_size-1 : 0]) : 
																	{{(max_size-size_mantissa-2){1'b0}}, unnormalized_mantissa[size_mantissa + 1 : 0]};
	assign lsb_shft_bit = (do_conversion)? (conversion[0]? s_a_number : a_number_i[size_integer-1]) : inter_rounding_bits[0];
	
	
	//compute leading_zeros over unnormalized mantissa
	leading_zeros #(	.SIZE_INT(max_size), .SIZE_COUNTER(max_counter), .PIPELINE(pipeline))
		leading_zeros_instance (.a(max_entityINT_FP), 
								.ovf(1'b0), 
								.lz(max_lzs));

	assign final_rounding_bits = conversion[1]? {size_mantissa{a_number_i[size_integer-1]}} : {inter_rounding_bits, inter_rounding_bits[0]};	
							
	//compute shifting over unnormalized_mantissa
	shifter #(	.INPUT_SIZE(max_size + size_mantissa),
				.SHIFT_SIZE(max_counter),
				.OUTPUT_SIZE(max_size + size_mantissa + 1),
				.DIRECTION(1'b1), //0=right, 1=left
				.PIPELINE(pipeline),
				.POSITION(pipeline_pos))
		shifter_instance(	.a({max_entityINT_FP, final_rounding_bits}),//mantissa
							.arith(lsb_shft_bit),//logical shift
							.shft(max_lzs),
							.shifted_a({r_mantissa, dummy_bits}));
	
	wire [max_size - 1 : 0] entity_to_shift;
	wire [max_size : 0] dummy_entity;
	assign entity_to_shift = conversion[0]? {shifted_m_b, initial_rounding_bits[size_mantissa-1 : size_mantissa - size_diff_i_m + 1]} : {{size_diff_i_m{1'b0}},r_mantissa};
	assign dummy_entity = conversion[0]? {initial_rounding_bits[size_mantissa - size_diff_i_m : 0], {(max_size + size_diff_i_m - size_mantissa){1'b0}}} : 
												((conversion[1] & (&dummy_bits[max_size-1:0]) & (~dummy_bits[max_size]))? (a_number_i[size_integer-1]? ~dummy_bits : dummy_bits) : dummy_bits);
	
	assign correction = ~(|exp_difference[size_exponent - 1 : 1])? 	1'b0 : 
							(eff_op? ((|initial_rounding_bits[size_mantissa - 2 : 0])? 
								((adder_mantissa[0] | ((~adder_mantissa[0]) & (~adder_mantissa[size_mantissa]) & (~initial_rounding_bits[size_mantissa - 1]) 
										& (~(&final_rounding_bits[size_mantissa-2 : 0]))))? 1'b1 : 1'b0) : 1'b0) : 1'b0);
	
	//instantiate rounding_component
	rounding #(	.SIZE_MOST_S_MANTISSA(max_size + 1),
				.SIZE_LEAST_S_MANTISSA(max_size + 1))
		rounding_instance(	.unrounded_mantissa({1'b0,entity_to_shift}),
		                    .dummy_bits(dummy_entity),
							.correction(correction),
		                    .rounded_mantissa(max_rounded_mantissa));
	
	assign max_entityFP_INT = {s_a_number, max_rounded_mantissa[max_size - 2 : 0]};
	
	assign max_exp_selection = do_conversion? exponent : exp_inter-1'b1;
	assign max_adjust_exponent = max_exp_selection - max_lzs;
	assign max_unadjusted_exponent = max_adjust_exponent + size_diff_i_m;
	assign max_resulted_e_o = (do_conversion & ~(|max_entityINT_FP))? bias : max_unadjusted_exponent + max_rounded_mantissa[size_mantissa];
	
	assign resulted_exponent = conversion[0]? 	max_entityFP_INT[size_mantissa+size_exponent-2 : size_mantissa-1] : max_resulted_e_o;
	assign resulted_mantissa = conversion[0]?	max_entityFP_INT[size_mantissa-1 : 0] :
												(max_rounded_mantissa[size_mantissa])? 	(max_rounded_mantissa[size_mantissa : 1]) : 
																						(max_rounded_mantissa[size_mantissa-1 : 0]);
																						
	
	//compute exception_field
	special_cases	#(	.size_exception_field(size_exception_field),
						.zero(zero), 
						.normal_number(normal_number),
						.infinity(infinity),
						.NaN(NaN))
		special_cases_instance( .sp_case_a_number(sp_case_a_number),
								.sp_case_b_number(sp_case_b_number),
								.sp_case_result_o(sp_case_o)); 
								
	//compute special case
	assign resulted_exception_field = conversion[0]? 2'd0:
										conversion[1]? normal_number : sp_case_o;
	
	//set zero_flag in case of equal numbers
	assign zero_flag = ~((|{resulted_mantissa,sp_case_o[1]}) & (|sp_case_o));
	
	assign sign_cases = {eff_op, s_a_number, s_b_number, a_greater_exponent[size_exponent], b_greater_exponent[size_exponent]};
	
	always 
		@(*)
	begin
		case (sign_cases)
			5'b00000:	intermediar_sign = 1'b0;
			5'b00001:	intermediar_sign = 1'b0;
			5'b00010:	intermediar_sign = 1'b0;
			
			5'b10000:	intermediar_sign = ~adder_mantissa[size_mantissa+1];
			5'b10001:	intermediar_sign = 1'b0;
			5'b10010:	intermediar_sign = 1'b1;
			
			5'b10100:	intermediar_sign = ~adder_mantissa[size_mantissa+1];
			5'b10101:	intermediar_sign = 1'b0;
			5'b10110:	intermediar_sign = 1'b1;
			
			5'b00100:	intermediar_sign = 1'b0;
			5'b00101:	intermediar_sign = 1'b0;
			5'b00110:	intermediar_sign = 1'b0;
			
			5'b11000:	intermediar_sign = adder_mantissa[size_mantissa+1];
			5'b11001:	intermediar_sign = 1'b1;
			5'b11010:	intermediar_sign = 1'b0;
		
			5'b01000:	intermediar_sign = 1'b1;
			5'b01001:	intermediar_sign = 1'b1;
			5'b01010:	intermediar_sign = 1'b1;
			 
			5'b01100:	intermediar_sign = 1'b1;
			5'b01101:	intermediar_sign = 1'b1;
			5'b01110:	intermediar_sign = 1'b1;
			
			5'b11100:	intermediar_sign = adder_mantissa[size_mantissa+1];
			5'b11101:	intermediar_sign = 1'b1;
			5'b11110:	intermediar_sign = 1'b0;
			
			default: intermediar_sign = 1'b1;
		endcase
	end
	
	assign resulted_sign = conversion[0]? 1'b0 : 
								conversion[1]? a_number_i[size_integer-1] : intermediar_sign;
																		
	assign resulted_number_o =  do_conversion? {resulted_exception_field, resulted_sign, resulted_exponent, resulted_mantissa[size_mantissa - 2 : 0]} :
								(zero_flag | (~(|resulted_exception_field)))? {size{1'b0}} :
									(&(resulted_exception_field))? {resulted_exception_field, resulted_sign,{(size-1-size_exception_field){1'b0}}} :
									(resulted_exception_field[1])? {resulted_exception_field, {(size-size_exception_field){1'b0}}} :
									(!sp_case_a_number)? {b_number_i[size-1 : size-size_exception_field], resulted_sign, b_number_i[size-1-size_exception_field-1 : 0]} :
									(!sp_case_b_number)? {a_number_i[size-1 : size-size_exception_field], resulted_sign, a_number_i[size-1-size_exception_field-1 : 0]} :
									{resulted_exception_field, resulted_sign, resulted_exponent, resulted_mantissa[size_mantissa - 2 : 0]};
	
endmodule
