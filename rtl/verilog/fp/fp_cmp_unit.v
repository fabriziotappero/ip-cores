/* ============================================================================
	(C) 2007  Robert T Finch
	All rights reserved.
	rob@birdcomputer.ca

	fp_cmp_unit.v
		- floating point comparison unit
		- parameterized width
		- IEEE 754 representation

	Verilog 2001

	Notice of Confidentiality

	http://en.wikipedia.org/wiki/IEEE_754

	Ref: Webpack 8.1i Spartan3-4 xc3s1000-4ft256
	111 LUTS / 58 slices / 16 ns
	Ref: Webpack 8.1i Spartan3-4 xc3s1000-4ft256
	109 LUTS / 58 slices / 16.4 ns

============================================================================ */

`define FCLT		3'd0
`define FCGE		3'd1
`define FCLE		3'd2
`define FCGT		3'd3
`define FCEQ		3'd4
`define FCNE		3'd5
`define FCUN		3'd6
`define FCOR		3'd7

module fp_cmp_unit(op, a, b, o, nanx);
parameter WID = 32;
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

input [2:0] op;
input [WID-1:0] a, b;
output o;
reg o;
output nanx;

// Decompose the operands
wire sa;
wire sb;
wire [EMSB:0] xa;
wire [EMSB:0] xb;
wire [FMSB:0] ma;
wire [FMSB:0] mb;
wire az, bz;
wire nan_a, nan_b;

fp_decomp #(WID) u1(.i(a), .sgn(sa), .exp(xa), .man(ma), .vz(az), .qnan(), .snan(), .nan(nan_a) );
fp_decomp #(WID) u2(.i(b), .sgn(sb), .exp(xb), .man(mb), .vz(bz), .qnan(), .snan(), .nan(nan_b) );

wire unordered = nan_a | nan_b;

wire eq = (az & bz) || (a==b);	// special test for zero, ugh!
wire gt1 = {xa,ma} > {xb,mb};
wire lt1 = {xa,ma} < {xb,mb};

wire lt = sa ^ sb ? sa & !(az & bz): sa ? gt1 : lt1;

always @(op or unordered or eq or lt)
	case (op)	// synopsys full_case parallel_case
	`FCOR:	o = !unordered;
	`FCUN:	o =  unordered;
	`FCEQ:	o =  eq;
	`FCNE:	o = !eq;
	`FCLT:	o =  lt;
	`FCGE:	o = !lt;
	`FCLE:	o =  lt | eq;
	`FCGT:	o = !(lt | eq);
	endcase

// an unorder comparison will signal a nan exception
assign nanx = op!=`FCOR && op!=`FCUN && unordered;

endmodule
