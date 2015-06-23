`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:08:41 10/21/2013 
// Design Name: 
// Module Name:    effective_op 
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
module effective_op(	input sign_a,
							input sign_b,
							input sign_c,
							input sub,
							output reg eff_sub);
	
	wire [2:0] sign_string;

	assign sign_string = {sub, sign_c, sign_a^sign_b};

	always
		@(*)
	begin
		case(sign_string)
			3'b000:	eff_sub = 1'b0;
			3'b001:	eff_sub = 1'b1;
			3'b010:	eff_sub = 1'b1;
			3'b011:	eff_sub = 1'b0;
			3'b100:	eff_sub = 1'b1;
			3'b101:	eff_sub = 1'b0;
			3'b110:	eff_sub = 1'b0;
			3'b111:	eff_sub = 1'b1;
			default:	eff_sub = 1'b0;
		endcase
	end

endmodule