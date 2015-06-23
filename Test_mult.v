`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:36:55 06/27/2013
// Design Name:   qmult
// Module Name:   I:/Projects/xilinx/FPInterface/Tester/Tran3005/Test_mult.v
// Project Name:  Trancendental
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: qmult
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module Test_mult;

	// Inputs
	reg [31:0] i_multiplicand;
	reg [31:0] i_multiplier;

	// Outputs
	wire [31:0] o_result;
	wire			ovr;
	
	// Instantiate the Unit Under Test (UUT)
	qmult #(19,32) uut (
		.i_multiplicand(i_multiplicand), 
		.i_multiplier(i_multiplier), 
		.o_result(o_result),
		.ovr(ovr)
	);

	initial begin
		$monitor ("%b,%b,%b,%b", i_multiplicand, i_multiplier, o_result, ovr);		//	Monitor the stuff we care about
		
		// Initialize Inputs
 		i_multiplicand = 32'b00000000000110010010000111111011;	//pi = 3.141592
		i_multiplicand[31] = 0;												//	i_multiplicand sign
		i_multiplier[31] = 0;												//	i_multiplier sign
		i_multiplier[30:0] = 0;

		// Wait 100 ns for global reset to finish
		#100;
		#100 i_multiplier[0] = 1;		//	1.91E-6
  	end

	// Add stimulus here
	always begin
		#10 i_multiplier[30:0] = (i_multiplier[30:0] << 1) + 1;		//	Why not??
	end
      
endmodule

