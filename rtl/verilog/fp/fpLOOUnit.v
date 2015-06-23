/* ===============================================================
	(C) 2006  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	fpLOOUnit.v
		- 'latency of one' floating point unit
		- instructions can execute using a single cycle
		- issue rate is one per clock cycle
		- latency is one clock cycle
		- parameterized width
		- IEEE 754 representation

	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If the code is modified, please state the origin and
	note that the code has been modified.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.


	i2f - convert integer to floating point
	f2i - convert floating point to integer

	Ref: Webpack 8.1i  Spartan3-4 xc3s1000 4ft256
	61 LUTS / 34 slices / 16 ns
=============================================================== */

module fpLOOUnit
#(parameter WID=32)
(
	input clk,
	input ce,
	input [1:0] rm,
	input [5:0] op,
	input [WID:1] a,
	output reg [WID:1] o,
	output done
);
localparam MSB = WID-1;
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

wire [WID:1] i2f_o;
wire [WID:1] f2i_o;

delay1 u1 (.clk(clk), .ce(ce), .i(op==6'd13||op==6'd14), .o(done) );
i2f  i2f0 (.clk(clk), .ce(ce), .rm(rm), .i(a), .o(i2f_o) );
f2i  f2i0 (.clk(clk), .ce(ce), .i(a), .o(f2i_o) );

always @(op,a,i2f_o,f2i_o)
	case (op)
	6'd13:	o <= i2f_o;
	6'd14:	o <= f2i_o;
	default:	o <= 0;
	endcase

endmodule
