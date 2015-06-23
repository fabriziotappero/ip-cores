`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:36:47 08/24/2011
// Design Name:   q15_add
// Module Name:   C:/Documents and Settings/samskalicky/Desktop/PLE/q_15_add_tf.v
// Project Name:  PLE
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: q15_add
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module qadd_tf;

	// Inputs
	reg [31:0] a;
	reg [31:0] b;

	// Outputs
	wire [31:0] c;

	// Instantiate the Unit Under Test (UUT)
	qadd #(23,32) uut (a, b, c);

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;

		#100;
		
		a = 1;
		b = 0;
		
		#100;
		
		a = 0;
		b = 1;
		
		#100;
		
		a = 1;
		b = 1;
		
		#100;
		
		a[31:23] = 64;
		a[22:0] = 125;
		b[31:23] = 0;
		b[22:0] = 75;
		
		#100;
		
		a[30]=0;
		a[30:23] = 64;
		a[22:0] = 1048576;
		b[31]=1;
		b[30:23] = 0;	//-1
		b[22:0] = 6291456;
        
		// Add stimulus here
		#100;
	end
      
endmodule

