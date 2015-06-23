`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:53 02/11/2009 
// Design Name: 
// Module Name:    test_moves_map 
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
module test_moves_map();
reg [63:0] R;
reg [63:0] B;
wire [63:0] M;
reg player;
reg clk;

initial begin
  R = 64'h0000001008000000;
  B = 64'h0000000810000000;
  player = 1'b0;
  clk = 0;
 // M = 64'b0;
end

always #100 clk = ~clk;

always @(posedge clk) 
   begin
	   R <= R + 1;
		B <= B - 1;
	end

moves_map MM(B, R, player, M);	

endmodule
