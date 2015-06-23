`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:20 08/24/2011 
// Design Name: 
// Module Name:    twosComp 
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
module qtwosComp(
    input [N-2:0] a,
    output [2*N-1:0] b
    );
	reg [2*N-1:0] data;
	reg [2*N-1:0] flip;
	reg [2*N-1:0] out;
	
	//Parameterized values
	parameter Q = 15;
	parameter N = 32;
	
	assign b = out;
	
	always @(a)
	begin
		data <= a;		//if you dont put the value into a 64b register, when you flip the bits it wont work right
	end
	
	always @(data)
	begin
		flip <= ~a;
	end
	
	always @(flip)
	begin
		out <= flip + 1;
	end

endmodule
