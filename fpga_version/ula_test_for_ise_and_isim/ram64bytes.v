`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:57:11 04/29/2012 
// Design Name: 
// Module Name:    ram64bytes 
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
module ram64bytes(
    input clk,
    input [5:0] a,
    input [7:0] din,
    output [7:0] dout,
    input we
    );
	 
	 reg [7:0] mem[0:63];
	 assign dout = mem[a];	//non registered address. Ugly, but works :(

	 integer i;
	 initial begin
		for (i=0;i<=63;i=i+1)
			mem[i] = i/8;
	 end
	 
	 always @(posedge clk) begin
		if (we)
			mem[a] <= din;
	 end
endmodule
