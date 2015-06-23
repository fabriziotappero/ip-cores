//--------------------------------------------------------------------------------------------------
//
// Title       : regfile
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

module regfile(a,a_sel,b,b_sel,clk,d,d_sel,dwe);
	// Inputs
	input	[3:0]	a_sel;
	wire	[3:0]	a_sel;
	input	[3:0]	b_sel;
	wire	[3:0]	b_sel;
	input			clk;
	wire			clk;
	input	[31:0]	d;
	wire	[31:0]	d;
	input	[3:0]	d_sel;
	wire	[3:0]	d_sel;
	input			dwe;
	wire			dwe;
	// Outputs
	output	[31:0]	a;
	reg		[31:0]	a;
	output	[31:0]	b;
	reg		[31:0]	b;
	// Internal
	reg		[31:0]	regs[15:0];

	always @ (clk || a_sel || b_sel)
		if (clk == 1'b0)
			begin
				a = regs[a_sel];
				b = regs[b_sel];
			end

	always @ (clk)
		if (clk == 1'b1)
			if (dwe == 1'b1)
				regs[d_sel] = d;

endmodule
