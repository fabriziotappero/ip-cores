/*
--------------------------------------------------------------------------------

Module : tst_decode.v

--------------------------------------------------------------------------------

Function:
- Processor test decoding for conditional jumps, etc.

Instantiates:
- (2x) pipe.v
- (1x) tst_encode.h

Notes:
- Parameterized register(s) @ test inputs.
- Parameterized register(s) @ output.

--------------------------------------------------------------------------------
*/

module tst_decode
	#(
	parameter	integer							REGS_TST			= 0,		// reg option input to test
	parameter	integer							REGS_OUT			= 0,		// reg option test to output
	parameter	integer							TST_W				= 4		// test field width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// flags (combinatorial)
	input			wire								flg_nz_i,					//	a != 0
	input			wire								flg_lz_i,					//	a < 0
	input			wire								flg_ne_i,					//	a != b
	input			wire								flg_lt_i,					//	a < b
	// tests (optionally registered)
	input			wire								cnd_i,						// 1=conditional
	input			wire	[TST_W-1:0]				tst_i,						// test field (see tst_encode.h)
	// output (optionally registered)
	output		wire								result_o						// 1=true; 0=false
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "tst_encode.h"
	wire												cnd, zro;
	wire			[TST_W-1:0]						tst;
	reg												res;
	wire												result;
	


	/*
	================
	== code start ==
	================
	*/


	// input to test regs
	pipe
	#(
	.DEPTH		( REGS_TST ),
	.WIDTH		( 1+TST_W ),
	.RESET_VAL	( 0 )
	)
	tst_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { cnd_i, tst_i } ),
	.data_o		( { cnd,   tst   } )
	);


	// mux
	always @ ( * ) begin
		case ( tst )
			`z   : res <= ~flg_nz_i;
			`nz  : res <=  flg_nz_i;
			`lz  : res <=  flg_lz_i;
			`nlz : res <= ~flg_lz_i;
			`e   : res <= ~flg_ne_i;
			`ne  : res <=  flg_ne_i;
			`ls  : res <=  flg_lt_i;
			`nls : res <= ~flg_lt_i;
			`lu  : res <=  flg_lt_i;
			`nlu : res <= ~flg_lt_i;
			default : res <= 1'b1;  // benign default
		endcase
	end

	// output result if conditional, output 1 if not
	assign result = ( cnd ) ? res : 1'b1;
	

	// result to output regs
	pipe
	#(
	.DEPTH		( REGS_OUT ),
	.WIDTH		( 1 ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( result ),
	.data_o		( result_o )
	);


endmodule
