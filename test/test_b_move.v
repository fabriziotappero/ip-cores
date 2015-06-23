`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:39:43 04/05/2009
// Design Name:   b_move
// Module Name:   E:/Projects/Diplom/Othello/test_b_move.v
// Project Name:  Othello
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: b_move
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_b_move;

	// Inputs
	reg clk;
	reg [63:0] R;
	reg [63:0] B;
	reg [2:0] X;
	reg [2:0] Y;
	reg RST;

	// Outputs
	wire [63:0] R_OUT;
	wire [63:0] B_OUT;

	
	initial begin
		// Initialize Inputs
		clk = 0;
//		B = 64'b01000001_00000000_00000000_00000000_00000000_00000000_00000001_10000000;
//		R = 64'b00000000_00100010_00011100_00010100_00011100_00100010_01000000_00000000;		

		B = 64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000110;
		R = 64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001;		
		
		X = 3'd3;
		Y = 3'd0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#100 RST = 1;
		#200 RST = 0;		

	end
	
	
	always #100 clk = ~clk;


	// Instantiate the Unit Under Test (UUT)
	b_move uut (
		.clk(clk), 
		.RST(RST),
		.player(1),
		.R_(R), 
		.B_(B), 
		.X(X), 
		.Y(Y), 
		.R_OUT(R_OUT), 
		.B_OUT(B_OUT)
	);

endmodule

