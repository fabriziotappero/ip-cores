`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:29:56 05/14/2013
// Design Name:   bcdadd
// Module Name:   /home/alw/projects/vtachspartan/bcdadd_tb.v
// Project Name:  vtachspartan
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bcdadd
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module bcdadd_tb;

	// Inputs
	reg [16:0] a;
	reg [12:0] b;

	// Outputs
	wire [16:0] z;

	// Instantiate the Unit Under Test (UUT)
	bcdadd uut (
		.a(a), 
		.b(b), 
		.z(z)
	);

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		a=17'h10001;
		b=13'h0001;
		#20 a=17'h10002;
		b=13'h1;
		#10 b=13'h0;

	end
      
endmodule

