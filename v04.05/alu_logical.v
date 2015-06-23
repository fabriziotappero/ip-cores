/*
--------------------------------------------------------------------------------

Module : alu_logical.v

--------------------------------------------------------------------------------

Function:
- Logic unit for a processor ALU.

Instantiates:
- (4x) pipe.v
- (1x) lg_sel_encode.h

Notes:
- IN/MID/OUT/FLG optionally registered.
- Default path through is copy.

--------------------------------------------------------------------------------
*/

module alu_logical
	#(
	parameter	integer							REGS_IN			= 1,		// register option for inputs
	parameter	integer							REGS_MID			= 1,		// mid register option
	parameter	integer							REGS_OUT			= 1,		// register option for outputs
	parameter	integer							REGS_FLG			= 1,		// register option for flag outputs
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							LG_SEL_W			= 4		// operation width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire	[LG_SEL_W-1:0]			lg_sel_i,					// operation (see lg_sel_encode.h)
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	output		wire	[DATA_W-1:0]			result_o,					// logical result
	// flags
	output		wire								flg_nz_o,					//	a != 0
	output		wire								flg_lz_o						//	a < 0
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "lg_sel_encode.h"
	`include "functions.h"  // for clog2(), flip_32(), lzc_32()
	localparam	integer							LZC_W			= clog2( DATA_W ) + 1;
	//
	wire					[LG_SEL_W-1:0]			lg_sel, lg_sel_m;
	wire					[DATA_W-1:0]			a, b;
	reg					[DATA_W-1:0]			res_1op, res_2op;
	wire					[DATA_W-1:0]			res_1op_m, res_2op_m;
	reg												res_br;
	wire												res_br_m;
	reg					[DATA_W-1:0]			result;
	wire												flg_nz, flg_lz;


	/*
	================
	== code start ==
	================
	*/


	// optional input registers
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( LG_SEL_W+DATA_W+DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { lg_sel_i, b_i, a_i,  } ),
	.data_o		( { lg_sel,   b,   a     } )
	);


	// flags
	assign flg_nz = |a;
	assign flg_lz = a[DATA_W-1];

	// multiplex one operand results
	always @ ( * ) begin
		case ( lg_sel )
			`lg_nsg : res_1op <= { ~b[DATA_W-1], b[DATA_W-2:0] };
			`lg_not : res_1op <= ~b;
			`lg_flp : res_1op <= flip_32( b );
			`lg_lzc : res_1op <= lzc_32( b );
			default : res_1op <= b;  // default is copy
		endcase
	end

	// multiplex one operand bit reduction results
	always @ ( * ) begin
		case ( lg_sel )
			`lg_bro : res_br <= |b;
			`lg_brx : res_br <= ^b;
			default : res_br <= &b;
		endcase
	end

	// multiplex two operand results
	always @ ( * ) begin
		case ( lg_sel )
			`lg_orr : res_2op <= a | b;
			`lg_xor : res_2op <= a ^ b;
			default : res_2op <= a & b;
		endcase
	end


	// optional flag regs
	pipe
	#(
	.DEPTH		( REGS_FLG ),
	.WIDTH		( 2 ),
	.RESET_VAL	( 0 )
	)
	regs_flags
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { flg_nz,   flg_lz,  } ),
	.data_o		( { flg_nz_o, flg_lz_o } )
	);


	// optional mid regs
	pipe
	#(
	.DEPTH		( REGS_MID ),
	.WIDTH		( LG_SEL_W+1+DATA_W+DATA_W ),
	.RESET_VAL	( 0 )
	)
	mid_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { lg_sel,   res_br,   res_2op,   res_1op   } ),
	.data_o		( { lg_sel_m, res_br_m, res_2op_m, res_1op_m } )
	);


	// multiplex
	always @ ( * ) begin
		case ( lg_sel_m )
			`lg_bra, `lg_bro, `lg_brx : result <= { DATA_W{ res_br_m } };
			`lg_and, `lg_orr, `lg_xor : result <= res_2op_m;
			default                   : result <= res_1op_m;  // default is copy
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
