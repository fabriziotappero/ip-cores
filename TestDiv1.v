`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:06:24 05/25/2014
// Design Name:   qdiv
// Module Name:   D:/temp/TestDiv1/TestDiv.v
// Project Name:  TestDiv1
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
	reg [63:0] i_dividend;
	reg [63:0] i_divisor;
	reg i_start;
	reg i_clk;
	
	reg	[13:0]	count;
	reg	[8:0]		temp_divisor;
	reg	[8:0]		temp_dividend;

	// Outputs
	wire [63:0] o_quotient_out;
	wire o_complete;
	wire o_overflow;

	// Instantiate the Unit Under Test (UUT)
	qdiv #(32,64) uut (
		.i_dividend(i_dividend), 
		.i_divisor(i_divisor), 
		.i_start(i_start), 
		.i_clk(i_clk), 
		.o_quotient_out(o_quotient_out), 
		.o_complete(o_complete), 
		.o_overflow(o_overflow)
	);

	initial begin
		// Initialize Inputs
		i_dividend = 0;
		i_divisor = 0;
		i_start = 0;
		i_clk = 0;
		
		count = 0;
		temp_divisor = 0;
		temp_dividend = 0;
		

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

		forever begin
			#1		i_clk = ~i_clk;
			end
		end
	
		always @(posedge i_clk) begin
			if (count == 1) begin
				i_start <= 1;
				end
				
			if (count == 3) begin
				i_start <= 0;
				end
				
			if (count == 220) begin
				count = 0;					//	reset the count
				
				if (temp_divisor > 255)	begin					//	if divisor maxed;
					temp_divisor <= 0;							//		reset to zero
					temp_dividend <= temp_dividend + 1;		//		and increment dividend
					end 
				else begin
					temp_divisor <= temp_divisor + 1;		//	otherwise, increment divisor
					end
					
				i_dividend <= temp_dividend << 32;			//		Set i_dividend
				i_divisor <= temp_divisor  << 32;			//		Set i_dividor
				
				end

			count <= count + 1;								//	Update count
			end
			
		always @(posedge o_complete) begin
			$display ("%b,%b,%b,%b", i_dividend, i_divisor, o_quotient_out, o_overflow);
			end
      
endmodule

