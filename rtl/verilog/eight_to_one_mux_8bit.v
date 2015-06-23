`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K
// 
// Create Date:    10:30:11 12/07/2009 
// Design Name: 
// Module Name:    eight_to_one_mux_8bit 
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
module eight_to_one_mux_8bit(mux_out,mux_in,select);
	output reg[7:0] mux_out;
	input [63:0]mux_in;
	input [2:0]select;
	
	always @(select, mux_in)
			case(select)
				3'b000:mux_out <= mux_in[7:0];
				3'b001:mux_out <= mux_in[15:8];
				3'b010:mux_out <= mux_in[23:16];
				3'b011:mux_out <= mux_in[31:24];
				3'b100:mux_out <= mux_in[39:32];
				3'b101:mux_out <= mux_in[47:40];
				3'b110:mux_out <= mux_in[55:48];
				3'b111:mux_out <= mux_in[63:56];
			endcase
endmodule

