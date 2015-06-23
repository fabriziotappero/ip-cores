/*
--------------------------------------------------------------------------------

Module : cond_test.v

--------------------------------------------------------------------------------

Function:
- Processor tests for conditional jumps, etc.

Instantiates:
- (2x) vector_sr.v

Notes:
- Parameterized register(s) test inputs.
- Parameterized register(s) @ output.

--------------------------------------------------------------------------------
*/

module cond_test
	#(
	parameter	integer							REGS_TST			= 0,		// reg option input to test
	parameter	integer							REGS_OUT			= 0		// reg option test to output
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// flags (combinatorial)
	input			wire								nez_i,						//	a != 0
	input			wire								ne_i,							//	a != b
	input			wire								ltz_i,						//	a < 0
	input			wire								lt_i,							//	a < b
	// tests (optionally registered)
	input			wire								tst_gt_i,					// > test
	input			wire								tst_lt_i,					// < test
	input			wire								tst_eq_i,					// = test
	input			wire								tst_ab_i,					// 1=a/b test; 0=a/z test
	// output (optionally registered)
	output		wire								tst_o							// 1=true; 0=false
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												tst_ab, tst_gt, tst_lt, tst_eq;
	wire												eqz, gtz;
	wire												eq, gt;
	wire					[2:0]						t_cat, az_cat, ab_cat;
	wire												res_az, res_ab, tst;
	


	/*
	================
	== code start ==
	================
	*/


	// input to test regs
	vector_sr
	#(
	.REGS			( REGS_TST ),
	.DATA_W		( 4 ),
	.RESET_VAL	( 0 )
	)
	tst_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { tst_ab_i, tst_gt_i, tst_lt_i, tst_eq_i } ),
	.data_o		( { tst_ab,   tst_gt,   tst_lt,   tst_eq } )
	);

	
	// concat tests
	assign t_cat = { tst_gt, tst_lt, tst_eq };

	// decode conditionals, & mask, | bit reduction => results
	assign eqz = ~nez_i;
	assign gtz = ~( ltz_i | eqz );
	assign az_cat = { gtz, ltz_i, eqz };
	assign res_az = |( t_cat & az_cat );
	//
	assign eq = ~ne_i;
	assign gt = ~( lt_i | eq );
	assign ab_cat = { gt, lt_i, eq };
	assign res_ab = |( t_cat & ab_cat );

	// select result
	assign tst = ( tst_ab ) ? res_ab : res_az;


	// result to output regs
	vector_sr
	#(
	.REGS			( REGS_OUT ),
	.DATA_W		( 1 ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( tst ),
	.data_o		( tst_o )
	);


endmodule
