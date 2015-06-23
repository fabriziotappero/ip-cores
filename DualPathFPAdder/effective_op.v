`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    17:41:11 11/04/2013 
// Design Name: 
// Module Name:    effective_op 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Compute effective operation 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module effective_op(	input a_sign,
						input b_sign,
						input sub,
						output reg eff_op);
	
	always
		@(*)
	begin
		case ({sub,a_sign, b_sign})
			3'b000:	eff_op = 0;
			3'b001:	eff_op = 1;
			3'b010:	eff_op = 1;
			3'b011:	eff_op = 0;
			3'b100:	eff_op = 1;
			3'b101:	eff_op = 0;
			3'b110:	eff_op = 0;
			3'b111:	eff_op = 1;
		endcase
	end
endmodule
