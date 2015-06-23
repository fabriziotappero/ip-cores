//--------------------------------------------------------------------------------------------------
//
// Title       : cmp
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

// Left to simplify decodeing
//`define		CMP_J		4'b0000
//`define		CMP_JR		4'b0001
`define		CMP_EQ		4'b0010
`define		CMP_NE		4'b0011
`define		CMP_C		4'b0100
`define		CMP_NC		4'b0101
`define		CMP_Z		4'b0110
`define		CMP_NZ		4'b0111
`define		CMP_LT		4'b1000
`define		CMP_NLT		4'b1001
`define		CMP_LTS		4'b1010
`define		CMP_NLTS	4'b1011
`define		CMP_GT		4'b1100
`define		CMP_NGT		4'b1101
`define		CMP_GTS		4'b1110
`define		CMP_NGTS	4'b1111

module cmp(a,b,cmp_op,true,c);
	// Inputs
	input	[31:0]	a;
	wire	[31:0]	a;
	input	[31:0]	b;
	wire	[31:0]	b;
	input	[3:0]	cmp_op;
	wire	[3:0]	cmp_op;
	input			c;
	wire			c;
	// Outputs
	output			true;
	reg				true;
	// Internal
	reg				eq;
	reg				lt;
	reg				gt;
	reg				lts;
	reg				gts;
	reg				z;

	always @ (a || b)
		begin
			if (a == b)
				eq = 1'b1;
			else
				eq = 1'b0;
			if (a < b)
				lt = 1'b1;
			else
				lt = 1'b0;
			if ((a[30:0] < b[30]) && a[31] && b[31])
				lts = 1'b1;
			else if (a[31] == 1'b1 && b[31] == 1'b0)
				lts = 1'b1;
			else
				lts = 1'b0;
			if (a > b)
				gt = 1'b1;
			else
				gt = 1'b0;
			if ((a[30:0] > b[30]) && a[31] && b[31])
				gts = 1'b1;
			else if (a[31] == 1'b0 && b[31] == 1'b1)
				gts = 1'b1;
			else
				gts = 1'b0;
			if (a == 32'b0)
				z = 1'b1;
			else
				z = 1'b0;
		end

	always @ (cmp_op || eq || z || c || lt || gt)
		case (cmp_op)
			//`CMP_J : true = 1'b1; // Taken care of in decoder
			//`CMP_JR : true = 1'b1; // Taken care of in decoder
			`CMP_EQ : true = eq;
			`CMP_NE : true = !(eq);
			`CMP_Z : true = z;
			`CMP_NZ : true = !(z);
			`CMP_C : true = c;
			`CMP_NC : true = !(c);
			`CMP_LT : true = lts;
			`CMP_NLT : true = !(lts);
			`CMP_LTS : true = lt;
			`CMP_NLTS : true = !(lt);
			`CMP_GT : true = gts;
			`CMP_NGT : true = !(gts);
			`CMP_GTS : true = gt;
			`CMP_NGTS : true = !(gt);
		endcase

endmodule
