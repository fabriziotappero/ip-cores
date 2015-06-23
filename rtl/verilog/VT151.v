// (C) 2007  Robert T Finch
// All Rights Reserved.
//
// 74LS151 mux
// 8-to-1 mux with enable
//
// Webpack 9.1i  xc3s1000-4ft256
//  slices /  LUTs / MHz

module VT151(e_n, s, i0, i1, i2, i3, i4, i5, i6, i7, z, z_n);
	parameter WID=1;
	input e_n;
	input [2:0] s;
	input [WID:1] i0;
	input [WID:1] i1;
	input [WID:1] i2;
	input [WID:1] i3;
	input [WID:1] i4;
	input [WID:1] i5;
	input [WID:1] i6;
	input [WID:1] i7;
	output [WID:1] z;
	output [WID:1] z_n;

	reg [WID:1] z;

	always @(e_n or s or i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7)
		case({e_n,s})
		4'b0000:	z <= i0;
		4'b0001:	z <= i1;
		4'b0010:	z <= i2;
		4'b0011:	z <= i3;
		4'b0100:	z <= i4;
		4'b0101:	z <= i5;
		4'b0110:	z <= i6;
		4'b0111:	z <= i7;
		default:	z <= {WID{1'b0}};
		endcase

	assign z_n = !z;

endmodule
