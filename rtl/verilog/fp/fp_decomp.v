/* ============================================================================
	(C) 2006, 2007  Robert T Finch
	All rights reserved.
	rob@birdcomputer.ca

	fp_decomp.v
		- decompose floating point value
		- parameterized width


	Verilog 1995

	This source code is free for use and modification for non-commercial or
	evaluation purposes, provided this copyright statement and disclaimer
	remains present in the file.

	If the code is modified, please state the origin and note that the code
	has been modified.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
	Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
	INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
	THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
	LOSSES RELATING TO SUCH UNAUTHORIZED USE.


	Ref: Webpack 8.1i Spartan3-4 xc3s1000 4ft256
	10 slices / 20 LUTs / 12 ns  (32 bits)

============================================================================ */

module fp_decomp(i, sgn, exp, man, fract, xz, mz, vz, inf, xinf, qnan, snan, nan);

parameter WID=32;

localparam MSB  = WID-1;
localparam EMSB = WID==80 ? 14 :
                  WID==64 ? 10 :
				  WID==52 ? 10 :
				  WID==48 ? 10 :
				  WID==44 ? 10 :
				  WID==42 ? 10 :
				  WID==40 ?  9 :
				  WID==32 ?  7 :
				  WID==24 ?  6 : 4;
localparam FMSB = WID==80 ? 63 :
                  WID==64 ? 51 :
				  WID==52 ? 39 :
				  WID==48 ? 35 :
				  WID==44 ? 31 :
				  WID==42 ? 29 :
				  WID==40 ? 28 :
				  WID==32 ? 22 :
				  WID==24 ? 15 : 9;

input [MSB:0] i;

output sgn;
output [EMSB:0] exp;
output [FMSB:0] man;
output [FMSB+1:0] fract;	// mantissa with hidden bit recovered
output xz;		// denormalized - exponent is zero
output mz;		// mantissa is zero
output vz;		// value is zero (both exponent and mantissa are zero)
output inf;		// all ones exponent, zero mantissa
output xinf;	// all ones exponent
output qnan;	// nan
output snan;	// signalling nan
output nan;

// Decompose input
assign sgn = i[MSB];
assign exp = i[MSB-1:FMSB+1];
assign man = i[FMSB:0];
assign xz = !(|exp);	// denormalized - exponent is zero
assign mz = !(|man);	// mantissa is zero
assign vz = xz & mz;	// value is zero (both exponent and mantissa are zero)
assign inf = &exp & mz;	// all ones exponent, zero mantissa
assign xinf = &exp;
assign qnan = &exp &  man[FMSB];
assign snan = &exp & !man[FMSB] & !mz;
assign nan = &exp & !mz;
assign fract = {!xz,i[FMSB:0]};

endmodule


