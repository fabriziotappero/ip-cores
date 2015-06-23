`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:35:03 06/30/2013
// Design Name:   qadd
// Module Name:   I:/Projects/xilinx/FPInterface/Tester/Tran3005/Tes_add.v
// Project Name:  Trancendental
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: qadd
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Test_add;

	// Inputs
	reg [31:0] a;
	reg [31:0] b;

	// Outputs
	wire [31:0] c;

	// Instantiate the Unit Under Test (UUT)
	qadd #(19,32) uut (
		.a(a), 
		.b(b), 
		.c(c)
	);

	//	These are to monitor the values...
	wire	[30:0]	c_out;
	wire	[30:0]	a_in;
	wire	[30:0]	b_in;
	wire				a_sign;
	wire				b_sign;
	wire				c_sign;
	
	
	assign	a_in = a[30:0];
	assign	b_in = b[30:0];
	assign	c_out = c[30:0];
	assign	a_sign = a[31];
	assign	b_sign = b[31];
	assign	c_sign = c[31];
	
	
	initial begin
		// Initialize Inputs
		a[30:0] = 0;
		a[31] = 0;
		b[31] = 1;
		b[30:0] = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		forever begin
			#1 a = a+5179347;			//	why not?
			a[31] = 0;					//	a is negative...
			b[31] = 1;
			
			
			if (a[30:0] > 2.1E9)			//	input will always be "positive"
				begin
					a = 0;
					b[31] = 1;				//	b is negative...
					b[30:0] = b[30:0] + 3779351;
				end
		end

	end
      
endmodule

