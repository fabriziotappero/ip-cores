/*
--------------------------------------------------------------------------------

Module : alu_mult_shift

--------------------------------------------------------------------------------

Function:
- Multiply & shift unit for a processor ALU.

Instantiates:
- functions.h (clog2)
- (1x) alu_multiply.v
  - (1x) vector_sr.v (debug mode only)
- (3x) vector_sr.v

Notes:
- I/O optionally registered.
- 5 stage pipeline w/ 4 mid registers (not counting I/O registering).
- Shift left signed uses signed B to shift signed A left (B+) and right (B-).
- Shift left unsigned and B(0,+) gives 2^B (one-hot / power of 2).
- Shift left unsigned and B(-) gives unsigned A shift right.
- Shift takes precedence over multiply.
- Copy takes precedence over shift & multiply.
- Copy unsigned & signed unextended results s/b the same.
- Copy unsigned extended result s/b all zero.
- Copy signed extended result s/b all B sign.
- Debug mode for comparison to native signed multiplication, only use for 
  simulation as it consumes resources and negatively impacts top speed. 

--------------------------------------------------------------------------------
*/

module alu_mult_shift
	#(
	parameter	integer							REGS_IN			= 1,		// in register option
	parameter	integer							REGS_OUT			= 1,		// out register option
	parameter	integer							DATA_W			= 4,		// data width
	parameter	integer							DEBUG_MODE		= 1		// 1=debug mode; 0=normal mode
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire								shl_i,						// 1=shift left
	input			wire								cpy_i,						// 1=copy b
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	output		wire	[DATA_W-1:0]			result_o,					// result
	// debug
	output		wire								debug_o						// 1=bad match
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	localparam	integer							SH_SEL_W			= clog2( DATA_W );
	localparam	integer							ZSX_W				= DATA_W+1;  // +1 extra bit
	localparam	integer							DBL_W				= DATA_W*2;  // double width
	//
	wire					[DATA_W-1:0]			a, b;
	wire												cpy, shl, ext, sgn;
	reg					[DATA_W:0]				a_mux, b_mux;  // +1 extra bit
	reg												ext_mux;
	wire												ext_mux_r;
	wire					[DBL_W-1:0]				res_dbl;
	reg					[DATA_W-1:0]			result;


	/*
	================
	== code start ==
	================
	*/


	// optional input regs
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( DATA_W+DATA_W+4 ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { a_i, b_i, cpy_i, shl_i, ext_i, sgn_i } ),
	.data_o		( { a,   b,   cpy,   shl,   ext,   sgn } )
	);


	// mux inputs and extended result selector
	always @ ( * ) begin
		casex ( { cpy, shl, sgn } )
			'b000 : begin  // unsigned multiply
				a_mux <= a;  // zero extend
				b_mux <= b;  // zero extend
				ext_mux <= ext;  // follow input
			end
			'b001 : begin  // signed multiply
				a_mux <= { a[DATA_W-1], a };  // sign extend
				b_mux <= { b[DATA_W-1], b };  // sign extend
				ext_mux <= ext;  // follow input
			end
			'b010 : begin  // unsigned shift / pow2
				a_mux <= ( b[DATA_W-1] ) ? a : 1'b1;  // a=1 for positive shifts
				b_mux <= 1'b1 << b[SH_SEL_W-1:0];  // pow2
				ext_mux <= b[DATA_W-1];  // sign selects output
			end
			'b011 : begin  // signed shift
				a_mux <= { a[DATA_W-1], a };  // sign extend
				b_mux <= 1'b1 << b[SH_SEL_W-1:0];  // pow2
				ext_mux <= b[DATA_W-1];  // sign selects output
			end
			'b1x0 : begin  // unsigned copy b
				a_mux <= 1'b1;  // a=1
				b_mux <= b;  // zero extend
				ext_mux <= ext;  // follow input
			end
			'b1x1 : begin  // signed copy b
				a_mux <= 1'b1;  // a=1
				b_mux <= { b[DATA_W-1], b };  // sign extend
				ext_mux <= ext;  // follow input
			end
		endcase
	end


	// signed multiplier (4 registers deep)
	alu_multiply
	#(
	.DATA_W			( ZSX_W ),
	.DEBUG_MODE		( DEBUG_MODE )
	)
	alu_multiply
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.a_i				( a_mux ),
	.b_i				( b_mux ),
	.result_o		( res_dbl ),
	.debug_o			( debug_o )
	);


	// pipeline extended result selector to match multiply
	vector_sr
	#(
	.REGS			( 4 ),
	.DATA_W		( 1 ),
	.RESET_VAL	( 0 )
	)
	regs_ext
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( ext_mux ),
	.data_o		( ext_mux_r )
	);


	// multiplex
	always @ ( * ) begin
		case ( ext_mux_r )
			'b0 : result <= res_dbl[DATA_W-1:0];
			'b1 : result <= res_dbl[DBL_W-1:DATA_W];
		endcase
	end

	
	// optional output regs
	vector_sr
	#(
	.REGS			( REGS_OUT ),
	.DATA_W		( DATA_W ),
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
