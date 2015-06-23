/*
--------------------------------------------------------------------------------

Module : alu_top.v

--------------------------------------------------------------------------------

Function:
- Processor ALU top level.

Instantiates:
- (2x) pipe.v
- (1x) alu_logical.v
  - (4x) pipe.v
- (1x) alu_add_sub.v
  - (4x) pipe.v
- (1x) alu_mult_shift.v
  - (3x) pipe.v
  - (1x) alu_multiply.v
    - (1x) pipe.v (debug mode only)
- (1x) alu_mux.v
  - (4x) pipe.v

Notes:
- I/O registered.
- Multi-stage pipeline w/ 5 mid registers.

--------------------------------------------------------------------------------
*/

module alu_top
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							LG_SEL_W			= 4		// operation width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire								hgh_i,						// 1=high
	input			wire	[LG_SEL_W-1:0]			lg_sel_i,					// logic operation (see lg_sel_encode.h)
	input			wire								add_i,						// 1=add
	input			wire								sub_i,						// 1=subtract
	input			wire								mul_i,						// 1=multiply
	input			wire								shl_i,						// 1=shift left
	input			wire								pow_i,						// 1=power of 2
	input			wire								rtn_i,						// 1=return pc
	input			wire								dm_rd_i,						// 1=read
	input			wire								rg_rd_i,						// 1=read
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	input			wire	[DATA_W/2-1:0]			dm_rd_data_4_i,			// dmem read data
	input			wire	[DATA_W/2-1:0]			rg_rd_data_4_i,			// regs read data
	input			wire	[ADDR_W-1:0]			pc_3_i,						// program counter
	output		wire	[DATA_W-1:0]			result_6_o,					// result
	// flags
	output		wire								flg_nz_2_o,					//	a != 0
	output		wire								flg_lz_2_o,					//	a < 0
	output		wire								flg_ne_2_o,					//	a != b
	output		wire								flg_lt_2_o					//	a < b
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												rg_rd_1, dm_rd_1, rtn_1, pow_1, shl_1, mul_1, sub_1, add_1, hgh_1, ext_1, sgn_1;
	wire					[LG_SEL_W-1:0]			lg_sel_1;
	wire					[DATA_W-1:0]			a_1, b_1;
	wire					[DATA_W-1:0]			res_lg_2, res_as_2, res_ms_5;


	/*
	================
	== code start ==
	================
	*/


	// input ctrl regs
	pipe
	#(
	.DEPTH				( 1 ),
	.WIDTH				( 11+LG_SEL_W ),
	.RESET_VAL			( 0 )
	)
	in_regs_ctrl
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.data_i				( { rg_rd_i, dm_rd_i, rtn_i, pow_i, shl_i, mul_i, sub_i, add_i, hgh_i, ext_i, sgn_i, lg_sel_i } ),
	.data_o				( { rg_rd_1, dm_rd_1, rtn_1, pow_1, shl_1, mul_1, sub_1, add_1, hgh_1, ext_1, sgn_1, lg_sel_1 } )
	);


	// input data regs
	pipe
	#(
	.DEPTH				( 1 ),
	.WIDTH				( DATA_W+DATA_W ),
	.RESET_VAL			( 0 )
	)
	in_regs_data
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.data_i				( { b_i, a_i } ),
	.data_o				( { b_1, a_1 } )
	);


	// logical unit
	alu_logical
	#(
	.REGS_IN				( 0 ),
	.REGS_MID			( 1 ),
	.REGS_OUT			( 0 ),
	.REGS_FLG			( 1 ),
	.DATA_W				( DATA_W ),
	.LG_SEL_W			( LG_SEL_W )
	)
	alu_logical
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.lg_sel_i			( lg_sel_1 ),
	.a_i					( a_1 ),
	.b_i					( b_1 ),
	.result_o			( res_lg_2 ),
	.flg_nz_o			( flg_nz_2_o ),
	.flg_lz_o			( flg_lz_2_o )
	);


	// add & subtract unit
	alu_add_sub
	#(
	.REGS_IN				( 0 ),
	.REGS_MID			( 1 ),
	.REGS_OUT			( 0 ),
	.REGS_FLG			( 1 ),
	.DATA_W				( DATA_W )
	)
	alu_add_sub
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.sgn_i				( sgn_1 ),
	.ext_i				( ext_1 ),
	.sub_i				( sub_1 ),
	.a_i					( a_1 ),
	.b_i					( b_1 ),
	.result_o			( res_as_2 ),
	.flg_ne_o			( flg_ne_2_o ),
	.flg_lt_o			( flg_lt_2_o )
	);


	// multiply & shift unit
	alu_mult_shift
	#(
	.REGS_IN				( 0 ),
	.REGS_OUT			( 0 ),
	.DATA_W				( DATA_W ),
	.DEBUG_MODE			( 0 )
	)
	alu_mult_shift
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.sgn_i				( sgn_1 ),
	.ext_i				( ext_1 ),
	.shl_i				( shl_1 ),
	.pow_i				( pow_1 ),
	.a_i					( a_1 ),
	.b_i					( b_1 ),
	.result_o			( res_ms_5 )
	);


	// multiplexer
	alu_mux
	#(
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W )
	)
	alu_mux
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.sgn_1_i				( sgn_1 ),
	.hgh_1_i				( hgh_1 ),
	.as_1_i				( add_1 | sub_1 ),
	.ms_1_i				( mul_1 | shl_1 | pow_1 ),
	.rtn_1_i				( rtn_1 ),
	.dm_rd_1_i			( dm_rd_1 ),
	.rg_rd_1_i			( rg_rd_1 ),
	.res_lg_2_i			( res_lg_2 ),
	.res_as_2_i			( res_as_2 ),
	.pc_3_i				( pc_3_i ),
	.dm_rd_data_4_i	( dm_rd_data_4_i ),
	.rg_rd_data_4_i	( rg_rd_data_4_i ),
	.res_ms_5_i			( res_ms_5 ),
	.data_6_o			( result_6_o )
	);


endmodule
