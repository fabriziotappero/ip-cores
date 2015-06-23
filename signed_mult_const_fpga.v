/**********************************************************************
 * File  : signed_mult_const_fpga.v
 * Author: Ivan Rezki
 * email : irezki@gmail.com
 * Topic : RTL Core
 * 		  2-Dimensional Fast Hartley Transform
 *
 *
 * Function: Signed Multiplier - constant sqrt(2) = 1.41421
 *
 * 8 bit accuracy:
 * 1.41421*a = (256*1.41421)*a/256 = 362.03776*a/256 = 362*a/256
 * product = 362*a/2^8
 * wire [8:0] mult_constant = 9'd362;
 *
 * 15 bit accuracy:
 * 1.41421*a = (32768*1.41421)*a/32768 = 46340.95*a/32768
 * product = 46341*a/2^15
 * wire [15:0] mult_constant = 16'd46341;
 *
 * 16 bit accuracy:
 * 1.41421*a = (65536*1.41421)*a/65536 = 92681*a/65536
 * product = 92681*a/2^16
 * wire [16:0] mult_constant = 17'd92681;
 *
 * RIGHT TO USE: This code example, or any portion thereof, may be
 * used and distributed without restriction, provided that this entire
 * comment block is included with the example.
 *
 * DISCLAIMER: THIS CODE EXAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
 * TO WARRANTIES OF MERCHANTABILITY, FITNESS OR CORRECTNESS. IN NO
 * EVENT SHALL THE AUTHOR OR AUTHORS BE LIABLE FOR ANY DAMAGES,
 * INCLUDING INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE
 * USE OF THIS CODE.
 **********************************************************************/

module signed_mult_const_fpga (
	rstn,
	clk,
	valid,
	a,
	p
);

parameter		N = 8;
input			rstn;
input			clk;
input			valid;
input  signed [N-1:0] a; // variable - positive/negative
output signed [N  :0] p; // product output

// FHT constant
// wire [8:0] mult_constant; // always positive
// assign mult_constant = 9'd362;

//wire signed [17:0] mult_constant; // always positive
//assign mult_constant = {1'b0, 17'd92681};
parameter mult_constant = {1'b0, 17'd92681};

reg signed [N-1:0] a_FF;
always @(posedge clk)
if		(!rstn) a_FF <= #1 0;
else if (valid)	a_FF <= #1 a;

wire signed [(16+1)+N-1:0] p_tmp = $signed(a_FF) * $signed(mult_constant);

//assign p = p_tmp[(16+1)+N-1:16];// >> 16;
assign p = p_tmp >> 16;

endmodule

// Update Log:
// 27 Jul. 2011
// wire [17:0] mult_constant replaced by parameter
