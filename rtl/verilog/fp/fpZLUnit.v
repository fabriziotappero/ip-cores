/* ===============================================================
	(C) 2007  Robert T Finch
	All rights reserved.
	rob@birdcomputer.ca

	fpZLUnit.v
		- zero latency floating point unit
		- instructions can execute in a single cycle without
		  a clock
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

	fabs	- get absolute value of number
	fnabs	- get negative absolute value of number
	fneg	- negate number
	fmov	- copy input to output
	fsign	- get sign of number (set number to +1,0, or -1)
	fman	- get mantissa (set exponent to zero)

	fclt	- less than
	fcle	- less than or equal
	fcgt	- greater than
	fcge	- greater than or equal
	fceq	- equal
	fcne	- not equal
	fcor	- ordered
	fcun	- unordered

	Ref: Webpack 8.1i  Spartan3-4 xc3s1000 4ft256
	160 LUTS / 80 slices / 21 ns
=============================================================== */
`define FABS	6'd0
`define FNABS	6'd1
`define FNEG	6'd2
`define FMOV	6'd3
`define FSIGN	6'd4
`define FMAN	6'd5

module fpZLUnit
#(parameter WID=32)
(
	input [5:0] op,
	input [WID:1] a,
	input [WID:1] b,	// for fcmp
	output reg [WID:1] o,
	output nanx
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

wire az = a[WID-1:1]==0;
wire cmp_o;

fp_cmp_unit #(WID) u1 (.op(op[2:0]), .a(a), .b(b), .o(cmp_o), .nanx(nanx) );

always @(op,a,cmp_o,az)
	case (op)
	`FABS:	o <= {1'b0,a[WID-1:1]};		// fabs
	`FNABS:	o <= {1'b1,a[WID-1:1]};		// fnabs
	`FNEG:	o <= {~a[WID],a[WID-1:1]};	// fneg
	`FMOV:	o <= a;						// fmov
	`FSIGN:	o <= az ? 0 : {a[WID],1'b0,{EMSB{1'b1}},{FMSB+1{1'b0}}};	// fsign
	`FMAN:	o <= {a[WID],1'b0,{EMSB{1'b1}},a[FMSB:1]};	// fman
	default:	o <= cmp_o;
	endcase

endmodule
