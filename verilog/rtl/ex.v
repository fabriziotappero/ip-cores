//--------------------------------------------------------------------------------------------------
//
// Title       : ex
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

module ex(a,b,ex_op,ex_mux,clk,carryin,ex_flush,ex_halt,o,t_out);
	// Inputs
	input	[31:0]	a;
	wire	[31:0]	a;
	input	[31:0]	b;
	wire	[31:0]	b;
	input	[3:0]	ex_op;
	wire	[3:0]	ex_op;
	input	[1:0]	ex_mux;
	wire	[1:0]	ex_mux;
	input			clk;
	wire			clk;
	input			carryin;
	wire			carryin;
	input			ex_flush;
	wire			ex_flush;
	input			ex_halt;
	wire			ex_halt;
	// Outputs
	output	[31:0]	o;
	reg		[31:0]	o;
	output			t_out;
	reg				t_out;
	// Internal
	wire	[31:0]	au_o;
	wire	[31:0]	lu_o;
	wire			testresult;
	wire			carryout;
	wire			testout;
	wire			rndau;
	reg				CARRYSTATE;

	au arith_unit(
		.a(a),
		.b(b),
		.arith_op(ex_op),
		.carry(carryout),
		.o(au_o),
		.rndin(rndau)
	);

	lu logic_unit(
		.a(a),
		.b(b),
		.logic_op(ex_op),
		.o(lu_o)
	);

	cmp compare_unit(
		.a(a),
		.b(b),
		.cmp_op(ex_op),
		.true(testout),
		.c(CARRYSTATE)
	);

	always @ (posedge clk || ex_flush || ex_halt || a || b || testout || carryout)
		if (ex_halt == 1'b0)
			if (ex_flush == 1'b0)
				begin
					case (ex_mux)
						2'b00 : o = au_o;
						2'b01 : o = lu_o;
						2'b10 : o = a;
						2'b11 : o = b;
					endcase
					t_out = testout;
					if (ex_mux == 2'b0)
						CARRYSTATE = carryout;
				end
			else
				begin
					o = 32'b0;
					CARRYSTATE = carryin;
				end

endmodule
