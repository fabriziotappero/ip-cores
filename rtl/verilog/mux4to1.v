// (C) 2007  Robert T Finch
// All Rights Reserved.
//
// Verilog 1995
//
// Webpack 9.1i  xc3s1000-4ft256
//  slices /  LUTs / MHz

module mux4to1(e, s, i0, i1, i2, i3, z);
	parameter WID=4;
	input e;
	input [1:0] s;
	input [WID:1] i0;
	input [WID:1] i1;
	input [WID:1] i2;
	input [WID:1] i3;
	output [WID:1] z;
	reg [WID:1] z;

	always @(e or s or i0 or i1 or i2 or i3)
		if (!e)
			z <= {WID{1'b0}};
		else begin
			case(s)
			2'b00:	z <= i0;
			2'b01:	z <= i1;
			2'b10:	z <= i2;
			2'b11:	z <= i3;
			endcase
		end

endmodule
