`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:57:25 08/24/2011
// Design Name:   q15_mult
// Module Name:   C:/Documents and Settings/samskalicky/Desktop/PLE/q15_mult_tf.v
// Project Name:  PLE
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: q15_mult
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module qmult_tf;

	// Inputs
	reg [31:0] a;
	reg [31:0] b;

	// Outputs
	wire [31:0] c;

	// Instantiate the Unit Under Test (UUT)
	//module Params Name Signals
	qmult #(23,32) uut (a, b, c);

	initial begin
		// Initialize Inputs
		a[31] = 0;
		a[30:23] = 64;
		a[22:0] = 1048576;//1048576;//4096;
		
		b[31] = 1;
		b[30:23] = 0;
		b[22:0] = 6291456;//6291456;//24576;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

