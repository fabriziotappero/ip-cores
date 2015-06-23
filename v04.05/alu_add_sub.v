/*
--------------------------------------------------------------------------------

Module : alu_add_sub.v

--------------------------------------------------------------------------------

Function:
- Add & subtract unit for a processor ALU.

Instantiates:
- (4x) pipe.v

Notes:
- IN/MID/OUT/FLG optionally registered.

--------------------------------------------------------------------------------
*/

module alu_add_sub
	#(
	parameter	integer							REGS_IN			= 1,		// in register option
	parameter	integer							REGS_MID			= 1,		// mid register option
	parameter	integer							REGS_OUT			= 1,		// out register option
	parameter	integer							REGS_FLG			= 1,		// flag register option
	parameter	integer							DATA_W			= 3		// data width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire								sub_i,						// 1=subtract; 0=add
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	output		wire	[DATA_W-1:0]			result_o,					// = ( a +/- b )
	// flags
	output		wire								flg_ne_o,					//	a != b
	output		wire								flg_lt_o						//	a < b
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam	integer							ZSX_W				= DATA_W+1;  // +1 extra bit
	localparam	integer							ADD_SUB_W		= DATA_W+2;  // +2 extra bits
	localparam	integer							DBL_W				= DATA_W*2;  // double width
	//
	wire												sgn, sub, ext, sub_m, ext_m;
	wire	signed		[DATA_W-1:0]			a, b;
	wire	signed		[ZSX_W-1:0]				a_zsx, b_zsx;
	wire	signed		[ADD_SUB_W-1:0]		ab_add, ab_sub, ab_add_m, ab_sub_m;
	reg	signed		[DBL_W-1:0]				res_dbl;
	reg	signed		[DATA_W-1:0]			result;
	wire												flg_ne, flg_lt;


	/*
	================
	== code start ==
	================
	*/


	// optional input regs
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( 3+DATA_W+DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { sub_i, ext_i, sgn_i, b_i, a_i } ),
	.data_o		( { sub,   ext,   sgn,   b,   a   } )
	);

	
	// zero|sign extend results
	assign a_zsx = { ( sgn & a[DATA_W-1] ), a };
	assign b_zsx = { ( sgn & b[DATA_W-1] ), b };

	// arithmetic results (signed)
	assign ab_add = a_zsx + b_zsx;
	assign ab_sub = a_zsx - b_zsx;
	
	// flags
	assign flg_ne = ( a != b );
	assign flg_lt = ab_sub[ZSX_W-1];


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
	.data_i		( { flg_ne,   flg_lt   } ),
	.data_o		( { flg_ne_o, flg_lt_o } )
	);


	// optional mid regs
	pipe
	#(
	.DEPTH		( REGS_MID ),
	.WIDTH		( 2+ADD_SUB_W+ADD_SUB_W ),
	.RESET_VAL	( 0 )
	)
	mid_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { sub,   ext,   ab_sub,   ab_add   } ),
	.data_o		( { sub_m, ext_m, ab_sub_m, ab_add_m } )
	);


	// multiplex
	always @ ( * ) begin
		case ( sub_m )
			'b1     : res_dbl <= ab_sub_m;
			default : res_dbl <= ab_add_m;
		endcase
	end

	// multiplex & extend
	always @ ( * ) begin
		case ( ext_m )
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
