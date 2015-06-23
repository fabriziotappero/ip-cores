`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:47:26 03/26/2009
// Design Name:   board_move
// Module Name:   E:/Projects/Diplom/Othello/test_board_move.v
// Project Name:  Othello
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: board_move
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_board_move_v;

	// Inputs
	reg clk;
	reg [63:0] B;
	reg [63:0] R;
	reg [2:0] X;
	reg [2:0] Y;
	reg player;
	reg RST;

	// Outputs
	wire [63:0] MB;
	wire [63:0] MR;	

	// Instantiate the Unit Under Test (UUT)

	initial begin
		// Initialize Inputs
		clk = 0;
		B = 64'b00000100_00000100_00000100_00000100_00000100_00000100_10000100_10000001;
		R = 64'b00000010_00000000_00000000_00000000_00000000_00000000_01110000_01110110;		
		X = 3;
		Y = 0;
		player = 0;
		RST = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		#100 RST = 1;
		#200 RST = 0;
        
		// Add stimulus here

	end
	
	always #100 clk = ~clk;

	board_move uut (
		.clk(clk), 
		.B(B), 
		.R(R), 
		.X(X), 
		.Y(Y), 
		.player(player), 
		.MB(MB), 
		.MR(MR), 		
		.RST(RST)
	);
      
endmodule

