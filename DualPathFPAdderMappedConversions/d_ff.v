`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UPT
// Engineer: 	Constantina-Elena Gavriliu
// 
// Create Date:    09:39:58 02/04/2013 
// Design Name: 
// Module Name:    d_ff
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: D flip-flop
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 / File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module d_ff (clk, rst, d, q);
	parameter SIZE = 24;
	input clk;
	input rst;
	input [SIZE-1 : 0] d;
	output reg [SIZE-1 : 0] q;
	
	always
		@(posedge clk, posedge rst)
	begin
		if (rst)	
			q <= {SIZE{1'b0}};
		else
			q <= d;
	end
endmodule