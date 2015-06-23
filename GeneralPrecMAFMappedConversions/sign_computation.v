`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:10:41 02/26/2014 
// Design Name: 
// Module Name:    sign_computation 
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
module sign_computation(	input eff_op,
							input s_a_number,
                            input s_b_number,
                            input a_greater_exponent,
							input b_greater_exponent,
							input adder_mantissa_ovf,
							output sign);
							
	wire [4:0] sign_cases;
	reg intermediar_sign;
	
	assign sign_cases = {eff_op, s_a_number, s_b_number, a_greater_exponent, b_greater_exponent};

	always 
		@(*)
	begin
		case (sign_cases)
			5'b00000:	intermediar_sign = 1'b0;
			5'b00001:	intermediar_sign = 1'b0;
			5'b00010:	intermediar_sign = 1'b0;
			
			5'b10000:	intermediar_sign = ~adder_mantissa_ovf;
			5'b10001:	intermediar_sign = 1'b0;
			5'b10010:	intermediar_sign = 1'b1;
			
			5'b10100:	intermediar_sign = ~adder_mantissa_ovf;
			5'b10101:	intermediar_sign = 1'b0;
			5'b10110:	intermediar_sign = 1'b1;
			
			5'b00100:	intermediar_sign = 1'b0;
			5'b00101:	intermediar_sign = 1'b0;
			5'b00110:	intermediar_sign = 1'b0;
			
			5'b11000:	intermediar_sign = adder_mantissa_ovf;
			5'b11001:	intermediar_sign = 1'b1;
			5'b11010:	intermediar_sign = 1'b0;
		
			5'b01000:	intermediar_sign = 1'b1;
			5'b01001:	intermediar_sign = 1'b1;
			5'b01010:	intermediar_sign = 1'b1;
			 
			5'b01100:	intermediar_sign = 1'b1;
			5'b01101:	intermediar_sign = 1'b1;
			5'b01110:	intermediar_sign = 1'b1;
			
			5'b11100:	intermediar_sign = adder_mantissa_ovf;
			5'b11101:	intermediar_sign = 1'b1;
			5'b11110:	intermediar_sign = 1'b0;
			
			default: intermediar_sign = 1'b1;
		endcase
	end	

	assign sign = intermediar_sign;

endmodule
