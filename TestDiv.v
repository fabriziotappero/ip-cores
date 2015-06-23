`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:48:08 12/29/2013
// Design Name:   qdiv
// Module Name:   G:/Tran3005/TestDiv.v
// Project Name:  Trancendental
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: qdiv
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestDiv;

	// Inputs
	reg [31:0] i_dividend;
	reg [31:0] i_divisor;
	reg i_start;
	reg i_clk;

	// Outputs
	wire [31:0] o_quotient_out;
	wire o_complete;
	wire o_overflow;

	// Instantiate the Unit Under Test (UUT)
	qdiv uut (
		.i_dividend(i_dividend), 
		.i_divisor(i_divisor), 
		.i_start(i_start), 
		.i_clk(i_clk), 
		.o_quotient_out(o_quotient_out), 
		.o_complete(o_complete), 
		.o_overflow(o_overflow)
	);

	reg [10:0]	count;

	initial begin
		// Initialize Inputs
		i_dividend = 1;
		i_divisor = 1;
		i_start = 0;
		i_clk = 0;
		
		count <= 0;

		// Wait 100 ns for global reset to finish
		#100;

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
				if ( i_divisor > 32'h1FFFFFFF ) begin
					i_divisor <= 1;
					i_dividend = (i_dividend << 1) + 3;
					end
				else
					i_divisor = (i_divisor << 1) + 1;
				end
			end
			
	always @(posedge o_complete)
		$display ("%b,%b,%b, %b", i_dividend, i_divisor, o_quotient_out, o_overflow);		//	Monitor the stuff we care about

endmodule

