`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:01:19 01/02/2014
// Design Name:   qmults
// Module Name:   F:/FixedPoint/TestMultS.v
// Project Name:  FixedPoint
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: qmults
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestMultS;

	// Inputs
	reg [31:0] i_multiplicand;
	reg [31:0] i_multiplier;
	reg i_start;
	reg i_clk;

	// Outputs
	wire [31:0] o_result_out;
	wire o_complete;
	wire o_overflow;

	// Instantiate the Unit Under Test (UUT)
	qmults uut (
		.i_multiplicand(i_multiplicand), 
		.i_multiplier(i_multiplier), 
		.i_start(i_start), 
		.i_clk(i_clk), 
		.o_result_out(o_result_out), 
		.o_complete(o_complete), 
		.o_overflow(o_overflow)
	);

	reg [10:0]	count;

	initial begin
		// Initialize Inputs
		i_multiplicand = 0;
		i_multiplier = 0;
		i_start = 0;
		i_clk = 0;
		
		count = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		// Add stimulus here
		forever #2 i_clk = ~i_clk;
		end
        
		always @(posedge i_clk) begin
			if (count == 47) begin
				count <= 0;
				i_start <= 1'b1;
				end
			else begin				
				count <= count + 1;
				i_start <= 1'b0;
				end
			end

		always @(count) begin
			if (count == 47) begin
				if ( i_multiplier > 32'h1FFFFFFF ) begin
					i_multiplier <= 1;
					i_multiplicand = (i_multiplicand << 1) + 3;
					end
				else
					i_multiplier = (i_multiplier << 1) + 1;
				end
			end
			
	always @(posedge o_complete)
		$display ("%b,%b,%b,%b", i_multiplicand, i_multiplier, o_result_out, o_overflow);		//	Monitor the stuff we care about


     
endmodule

