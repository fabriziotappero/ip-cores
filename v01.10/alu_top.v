/*
--------------------------------------------------------------------------------

Module : alu_top.v

--------------------------------------------------------------------------------

Function:
- Processor ALU top level.

Instantiates:
- (2x) vector_sr.v
- (1x) alu_logical.v
  - (4x) vector_sr.v
- (1x) alu_add_sub.v
  - (4x) vector_sr.v
- (1x) alu_mult_shift.v
  - (3x) vector_sr.v
  - (1x) alu_multiply.v
    - (1x) vector_sr.v (debug mode only)
- (1x) alu_mux.v
  - (4x) vector_sr.v

Notes:
- I/O optionally registered.
- 5 stage pipeline w/ 4 mid registers (not counting I/O registering).

--------------------------------------------------------------------------------
*/

module alu_top
	#(
	parameter	integer							REGS_IN			= 1,		// register option for control and a & b inputs
	parameter	integer							REGS_OUT			= 1,		// register option for outputs
	parameter	integer							REGS_FLG			= 1,		// register option for flag outputs
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							LG_W				= 2		// operation width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire	[LG_W-1:0]				lg_i,							// see decode in notes above
	input			wire								add_i,						// 1=add
	input			wire								sub_i,						// 1=subtract
	input			wire								mul_i,						// 1=multiply
	input			wire								shl_i,						// 1=shift left
	input			wire								cpy_i,						// 1=copy b
	input			wire								dm_i,							// 1=data mem
	input			wire								rtn_i,						// 1=return pc
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	input			wire	[DATA_W/2-1:0]			dm_data_i,					// dmem read data
	input			wire	[ADDR_W-1:0]			pc_3_i,						// program counter
	output		wire	[DATA_W-1:0]			result_o,					// result
	// flags
	output		wire								nez_o,						//	a != 0
	output		wire								ne_o,							//	a != b
	output		wire								ltz_o,						//	a < 0
	output		wire								lt_o							//	a < b
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												rtn, dm, cpy, shl, mul, sub, add, ext, sgn;
	wire					[LG_W-1:0]				lg;
	wire					[DATA_W-1:0]			a, b;
	wire					[DATA_W-1:0]			res_lg, res_as, res_mid, res_ms;


	/*
	================
	== code start ==
	================
	*/


	// optional input regs
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( DATA_W+DATA_W+7+LG_W+2 ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { a_i, b_i, rtn_i, dm_i, cpy_i, shl_i, mul_i, sub_i, add_i, lg_i, ext_i, sgn_i } ),
	.data_o		( { a,   b,   rtn,   dm,   cpy,   shl,   mul,   sub,   add,   lg,   ext,   sgn } )
	);


	// logical unit
	alu_logical
	#(
	.REGS_IN			( 0 ),
	.REGS_MID		( 1 ),
	.REGS_OUT		( 0 ),
	.REGS_FLG		( REGS_FLG ),
	.DATA_W			( DATA_W ),
	.LG_W				( LG_W )
	)
	alu_logical
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.ext_i			( ext ),
	.lg_i				( lg ),
	.a_i				( a ),
	.b_i				( b ),
	.result_o		( res_lg ),
	.nez_o			( nez_o ),
	.ne_o				( ne_o )
	);


	// add & subtract unit
	alu_add_sub
	#(
	.REGS_IN			( 0 ),
	.REGS_MID		( 1 ),
	.REGS_OUT		( 0 ),
	.REGS_FLG		( REGS_FLG ),
	.DATA_W			( DATA_W )
	)
	alu_add_sub
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.sgn_i			( sgn ),
	.ext_i			( ext ),
	.sub_i			( sub ),
	.a_i				( a ),
	.b_i				( b ),
	.result_o		( res_as ),
	.ltz_o			( ltz_o ),
	.lt_o				( lt_o )
	);


	// multiply & shift unit
	alu_mult_shift
	#(
	.REGS_IN			( 0 ),
	.REGS_OUT		( 0 ),
	.DATA_W			( DATA_W )
	)
	alu_mult_shift
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.sgn_i			( sgn ),
	.ext_i			( ext ),
	.shl_i			( shl ),
	.cpy_i			( cpy ),
	.a_i				( a ),
	.b_i				( b ),
	.result_o		( res_ms )
	);


	// multiplexer
	alu_mux
	#(
	.REGS_IN_A		( 1 ),
	.REGS_A_B		( 1 ),
	.REGS_B_C		( 1 ),
	.REGS_C_D		( 1 ),
	.REGS_D_OUT		( REGS_OUT ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W )
	)
	alu_mux
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.sgn_i			( sgn ),
	.ext_i			( ext ),
	.as_i				( sub | add ),
	.dm_i				( dm ),
	.rtn_i			( rtn ),
	.ms_i				( cpy | shl | mul ),
	.a_lo_i			( a[DATA_W/2-1:0] ),
	.res_ms_i		( res_ms ),
	.res_lg_i		( res_lg ),
	.res_as_i		( res_as ),
	.dm_data_i		( dm_data_i ),
	.pc_i				( pc_3_i ),
	.result_o		( result_o )
	);

	
endmodule
