/*
--------------------------------------------------------------------------------

Module : alu_mult_shift

--------------------------------------------------------------------------------

Function:
- Multiply & shift unit for a processor ALU.

Instantiates:
- functions.h (clog2)
- (1x) alu_multiply.v
  - (1x) pipe.v (debug mode only)
- (4x) pipe.v

Notes:
- I/O optionally registered.
- 5 stage pipeline w/ 4 mid registers (not counting I/O registering).
- (pow=0 & shl=0) gives unsigned (sgn=0) and signed (sgn=1) A*B.
- (pow=0 & shl=1) gives A unsigned (sgn=0) and A signed (sgn=1) A<<B.
- (pow=1 & shl=0) gives 1<<B (sign=x).
- (pow=1 & shl=1) and (B>=0) gives 1<<B, (B<0) gives A<<B (A signed & unsigned).
- Debug mode for comparison to native signed multiplication, only use for 
  simulation as it consumes resources and negatively impacts top speed. 

--------------------------------------------------------------------------------
*/

module alu_mult_shift
	#(
	parameter	integer							REGS_IN			= 1,		// in register option
	parameter	integer							REGS_OUT			= 1,		// out register option
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							DEBUG_MODE		= 0		// 1=debug mode; 0=normal mode
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire								shl_i,						// 1=shift left
	input			wire								pow_i,						// 1=power of 2
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
	wire												ext, pow, shl, sgn;
	wire												b_neg;
	wire					[DATA_W-1:0]			b_pow;
	wire					[ZSX_W-1:0]				a_sex, b_sex;
	reg					[ZSX_W-1:0]				a_mux, b_mux;
	reg												ext_mux;
	wire												ext_mux_r;
	wire					[DBL_W-1:0]				res_dbl;
	reg					[DATA_W-1:0]			result;


	/*
	================
	== code start ==
	================
	*/


	// optional input data regs
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( DATA_W+DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_data_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { b_i, a_i } ),
	.data_o		( { b,   a   } )
	);

	
	// optional input control regs
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( 4 ),
	.RESET_VAL	( 0 )
	)
	in_ctrl_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { ext_i, pow_i, shl_i, sgn_i } ),
	.data_o		( { ext,   pow,   shl,   sgn   } )
	);


	// some results pre-mux
	assign a_sex = { a[DATA_W-1], a };
	assign b_sex = { b[DATA_W-1], b };
	assign b_pow = 1'b1 << b[SH_SEL_W-1:0];
	assign b_neg = b[DATA_W-1];


	// mux inputs and extended result selector
	always @ ( * ) begin
		case ( { pow, shl, sgn } )
			'b000 : begin  // unsigned multiply
				a_mux <= a;
				b_mux <= b;
				ext_mux <= ext;
			end
			'b001 : begin  // signed multiply
				a_mux <= a_sex;
				b_mux <= b_sex;
				ext_mux <= ext;
			end
			'b010 : begin  // unsigned shift
				a_mux <= a;
				b_mux <= b_pow;
				ext_mux <= b_neg;
			end
			'b011 : begin  // signed shift
				a_mux <= a_sex;
				b_mux <= b_pow;
				ext_mux <= b_neg;
			end
			'b100, 'b101 : begin  // pow (sign is don't care)
				a_mux <= 1'b1;
				b_mux <= b_pow;
				ext_mux <= 1'b0;  // modulo rather than zero for negative shift values
			end
			'b110 : begin  // pow (0,+b) | unsigned shift (-b)
				a_mux <= ( b_neg ) ? a : 1'b1;
				b_mux <= b_pow;
				ext_mux <= b_neg;
			end
			'b111 : begin  // pow (0,+b) | signed shift (-b)
				a_mux <= ( b_neg ) ? a_sex : 1'b1;
				b_mux <= b_pow;
				ext_mux <= b_neg;
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
	pipe
	#(
	.DEPTH		( 4 ),
	.WIDTH		( 1 ),
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
			'b1     : result <= res_dbl[DBL_W-1:DATA_W];
			default : result <= res_dbl[DATA_W-1:0];
		endcase
	end

	
	// optional output regs
	pipe
	#(
	.DEPTH		( REGS_OUT ),
	.WIDTH		( DATA_W ),
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
