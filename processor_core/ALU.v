`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:05:06 05/02/2012 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [7:0] a,
    input [7:0] b,
    output [7:0] result,
    input [2:0] opalu,
	 output zero, carry
    );

reg [7:0] resu;

always@*
	case (opalu)
		0: resu <= ~a;
		1: resu <= a & b;
		2: resu <= a ^ b;
		3: resu <= a | b;
		4: resu <= a;
		5: resu <= a + b;
		6: resu <= a - b;
		default: resu <= a + 1;
	endcase
	
assign zero=(resu==0);
assign result=resu;
assign carry=(a<b);
		

endmodule

