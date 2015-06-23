`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:39:57 05/02/2009
// Design Name:   heuristics
// Module Name:   E:/Projects/Diplom/Othello/test_heur.v
// Project Name:  Othello
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: heuristics
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_heur;

	// Inputs
	reg clk;
	reg RST;
	reg [63:0] R;
	reg [63:0] B;
	reg [63:0] M;

	// Outputs
	wire signed [19:0] value;
   wire signed [4:0] dbg1;

	initial begin
		// Initialize Inputs
		clk = 0;
		RST = 1;
		R = 64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001;
		B = 64'b11111111_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
		M = 64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;

		// Wait 100 ns for global reset to finish
		#100;
		RST = 0;
        
		// Add stimulus here

	end
	

	always #100 clk = ~clk;
	// Instantiate the Unit Under Test (UUT)
	heuristics uut(
		.clk(clk), 
		.RST(RST), 
		.R(R), 
		.B(B), 	
		.M(M),
		.value(value)
//		.pattern_dbg1(dbg1)
	);


      
endmodule

