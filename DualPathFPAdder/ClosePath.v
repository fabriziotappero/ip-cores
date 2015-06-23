`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    00:32:10 11/19/2013 
// Design Name: 
// Module Name:    ClosePath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A ± B when |Ea-Eb| < 2
//
// Dependencies: 	leading_zeros.v
//					shifter.v			
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ClosePath	#(	parameter size_in_mantissa			= 24, //1.M
							parameter size_out_mantissa		= 24,
							parameter size_exponent 			= 8,
							parameter pipeline					= 0,
							parameter pipeline_pos				= 0,	// 8 bits
							parameter size_counter				= 5,	//log2(size_in_mantissa) + 1 = 5)
							parameter double_size_in_mantissa   = size_in_mantissa + size_in_mantissa)
											
						(	input [size_in_mantissa	- 1	: 0] m_a_number,
							input [size_in_mantissa - 1 : 0] m_b_number,
							input [size_exponent     : 0] exp_inter,
							input exp_difference,
							output[size_out_mantissa-1:0] resulted_m_o,
							output[size_exponent - 1 : 0] resulted_e_o,
							output ovf);

	wire [size_counter - 1 : 0] lzs;
	wire [size_exponent- 1 : 0] unadjusted_exponent;
	wire [1 : 0] adjust_exponent;
	wire [2 : 0] dummy_bits;
	wire init_shft_bit, shft_bit;
		
	wire [size_in_mantissa-1: 0] shifted_m_b;
	wire [size_in_mantissa+2: 0] adder_mantissa;
	wire [size_in_mantissa+1: 0] unnormalized_mantissa;
	wire [size_in_mantissa 	: 0] rounded_mantissa;
	wire [size_in_mantissa-1: 0] r_mantissa;
	wire [size_in_mantissa  : 0] aux_r_mantissa;
	
	assign {shifted_m_b, init_shft_bit} = (exp_difference)? {1'b0, m_b_number[size_in_mantissa-1:0]} : {m_b_number, 1'b0};
		
	//compute unnormalized_mantissa
	assign adder_mantissa = {1'b0, m_a_number, 1'b0} - {1'b0, shifted_m_b, init_shft_bit};
	assign unnormalized_mantissa = adder_mantissa[size_in_mantissa + 1]? ~adder_mantissa : adder_mantissa;	
		
	//compute leading_zeros over unnormalized mantissa
	leading_zeros #(	.SIZE_INT(size_in_mantissa + 2), .SIZE_COUNTER(size_counter), .PIPELINE(pipeline))
		leading_zeros_instance (.a(unnormalized_mantissa[size_in_mantissa+1 : 0]), 
										.ovf(unnormalized_mantissa[size_in_mantissa+1]), 
										.lz(lzs));
										
	//compute shifting over unnormalized_mantissa
	shifter #(	.INPUT_SIZE(size_in_mantissa + 2),
					.SHIFT_SIZE(size_counter),
					.OUTPUT_SIZE(size_in_mantissa + 3),
					.DIRECTION(1'b1), //0=right, 1=left
					.PIPELINE(pipeline),
					.POSITION(pipeline_pos))
		shifter_instance(	.a({unnormalized_mantissa}),//mantissa
								.arith(adder_mantissa[size_in_mantissa+2]),//logical shift
								.shft(lzs),
								.shifted_a({r_mantissa, dummy_bits}));
								
	
	//assign aux_r_mantissa = {1'b0, r_mantissa} + 1'b1;
	assign rounded_mantissa = (r_mantissa[0] & (dummy_bits[2]))? {1'b0, r_mantissa} + 1'b1 : {1'b0, r_mantissa};
	assign resulted_m_o = (rounded_mantissa[size_in_mantissa])? rounded_mantissa[size_in_mantissa : 1] :
																rounded_mantissa[size_in_mantissa-1:0];
	                      
	assign adjust_exponent = rounded_mantissa[size_in_mantissa]? 2'd2 : 2'd1;
	
	assign ovf = adder_mantissa[size_in_mantissa+1];
	assign unadjusted_exponent = exp_inter - lzs;
	assign resulted_e_o =  unadjusted_exponent + adjust_exponent;
		
endmodule
