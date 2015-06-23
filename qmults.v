`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:33:36 01/02/2014 
// Design Name: 
// Module Name:    qmults 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module qmults#(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
	input 	[N-1:0]  i_multiplicand,
	input 	[N-1:0]	i_multiplier,
	input 	i_start,
	input 	i_clk,
	output 	[N-1:0] o_result_out,
	output 	o_complete,
	output	o_overflow
	);

	reg [2*N-2:0]	reg_working_result;		//	a place to accumulate our result
	reg [2*N-2:0]	reg_multiplier_temp;		//	a working copy of the multiplier
	reg [N-1:0]		reg_multiplicand_temp;	//	a working copy of the umultiplicand
	
	reg [N-1:0] 			reg_count; 		//	This is obviously a lot bigger than it needs to be, as we only need 
												//		count to N, but computing that number of bits requires a 
												//		logarithm (base 2), and I don't know how to do that in a 
												//		way that will work for every possibility
										 
	reg					reg_done;		//	Computation completed flag
	reg					reg_sign;		//	The result's sign bit
	reg					reg_overflow;	//	Overflow flag
 
	initial reg_done = 1'b1;			//	Initial state is to not be doing anything
	initial reg_overflow = 1'b0;		//		And there should be no woverflow present
	initial reg_sign = 1'b0;			//		And the sign should be positive
	
	assign o_result_out[N-2:0] = reg_working_result[N-2+Q:Q];	//	The multiplication results
	assign o_result_out[N-1] = reg_sign;								//	The sign of the result
	assign o_complete = reg_done;											//	"Done" flag
	assign o_overflow = reg_overflow;									//	Overflow flag
	
	always @( posedge i_clk ) begin
		if( reg_done && i_start ) begin										//	This is our startup condition
			reg_done <= 1'b0;														//	We're not done			
			reg_count <= 0;														//	Reset the count
			reg_working_result <= 0;											//	Clear out the result register
			reg_multiplier_temp <= 0;											//	Clear out the multiplier register 
			reg_multiplicand_temp <= 0;										//	Clear out the multiplicand register 
			reg_overflow <= 1'b0;												//	Clear the overflow register

			reg_multiplicand_temp <= i_multiplicand[N-2:0];				//	Load the multiplicand in its working register and lose the sign bit
			reg_multiplier_temp <= i_multiplier[N-2:0];					//	Load the multiplier into its working register and lose the sign bit

			reg_sign <= i_multiplicand[N-1] ^ i_multiplier[N-1];		//	Set the sign bit
			end 

		else if (!reg_done) begin
			if (reg_multiplicand_temp[reg_count] == 1'b1)								//	if the appropriate multiplicand bit is 1
				reg_working_result <= reg_working_result + reg_multiplier_temp;	//		then add the temp multiplier
	
			reg_multiplier_temp <= reg_multiplier_temp << 1;						//	Do a left-shift on the multiplier
			reg_count <= reg_count + 1;													//	Increment the count

			//stop condition
			if(reg_count == N) begin
				reg_done <= 1'b1;										//	If we're done, it's time to tell the calling process
				if (reg_working_result[2*N-2:N-1+Q] > 0)			// Check for an overflow
					reg_overflow <= 1'b1;
//			else
//				reg_count <= reg_count + 1;													//	Increment the count
				end
			end
		end
endmodule
