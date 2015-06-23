/*
--------------------------------------------------------------------------------

Module : alu_mux.v

--------------------------------------------------------------------------------

Function:
- Multiplexer for processor ALU.

Instantiates:
- (4x) vector_sr.v

Notes:
- I/M/O optionally registered.

--------------------------------------------------------------------------------
*/

module alu_mux
	#(
	parameter	integer							REGS_IN_A		= 0,		// reg option input to mux a
	parameter	integer							REGS_A_B			= 0,		// reg option mux a to mux b
	parameter	integer							REGS_B_C			= 0,		// reg option mux b to mux c
	parameter	integer							REGS_C_D			= 0,		// reg option mux c to mux d
	parameter	integer							REGS_D_OUT		= 0,		// reg option mux d to output
	parameter	integer							DATA_W			= 8,		// data width
	parameter	integer							ADDR_W			= 4		// address width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended
	input			wire								as_i,							// 1=add/subtract
	input			wire								dm_i,							// 1=read data
	input			wire								rtn_i,						// 1=return pc
	input			wire								ms_i,							// 1=multiply
	// data I/O
	input			wire	[DATA_W/2-1:0]			a_lo_i,						// operand
	input			wire	[DATA_W-1:0]			res_lg_i,					// logical result
	input			wire	[DATA_W-1:0]			res_as_i,					// add/subtract result
	input			wire	[DATA_W-1:0]			res_ms_i,					// multiply/shift result
	input			wire	[DATA_W/2-1:0]			dm_data_i,					// dmem read data
	input			wire	[ADDR_W-1:0]			pc_i,							// program counter
	output		wire	[DATA_W-1:0]			result_o						// selected result
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												ms_a, rtn_a, dm_a, as_a, ext_a, sgn_a;
	wire												ms_b, rtn_b, dm_b, as_b, ext_b, sgn_b;
	wire												ms_c, dm_c, as_c, ext_c, sgn_c;
	wire												ms_d;
	wire					[DATA_W/2-1:0]			a_lo_a;
	reg					[DATA_W-1:0]			mux_a, mux_b, mux_c, mux_d;
	wire					[DATA_W-1:0]			mux_a_b, mux_b_c, mux_c_d;


	/*
	================
	== code start ==
	================
	*/


	// input to mux a regs
	vector_sr
	#(
	.REGS			( REGS_IN_A ),
	.DATA_W		( DATA_W/2+6 ),
	.RESET_VAL	( 0 )
	)
	in_a_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { a_lo_i, ms_i, rtn_i, dm_i, as_i, ext_i, sgn_i } ),
	.data_o		( { a_lo_a, ms_a, rtn_a, dm_a, as_a, ext_a, sgn_a } )
	);


	// mux a
	always @ ( * ) begin
		casex ( { dm_a, as_a } )
			'b00 : mux_a <= res_lg_i;
			'b01 : mux_a <= res_as_i;
			'b1x : mux_a <= a_lo_a;
		endcase
	end


	// mux a to mux b regs
	vector_sr
	#(
	.REGS			( REGS_A_B ),
	.DATA_W		( DATA_W+5 ),
	.RESET_VAL	( 0 )
	)
	a_b_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { mux_a,   ms_a, rtn_a, dm_a, ext_a, sgn_a } ),
	.data_o		( { mux_a_b, ms_b, rtn_b, dm_b, ext_b, sgn_b } )
	);


	// mux b
	always @ ( * ) begin
		case ( rtn_b )
			'b0 : mux_b <= mux_a_b;
			'b1 : mux_b <= pc_i;
		endcase
	end

	
	// mux b to mux c regs
	vector_sr
	#(
	.REGS			( REGS_B_C ),
	.DATA_W		( DATA_W+4 ),
	.RESET_VAL	( 0 )
	)
	b_c_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { mux_b,   ms_b, dm_b, ext_b, sgn_b } ),
	.data_o		( { mux_b_c, ms_c, dm_c, ext_c, sgn_c } )
	);


	// mux c
	always @ ( * ) begin
		casex ( { dm_c, ext_c, sgn_c } )
			'b0xx : mux_c <= mux_b_c;
			'b100 : mux_c <= dm_data_i;
			'b101 : mux_c <= $signed( dm_data_i );
			'b11x : mux_c <= { dm_data_i, mux_b_c[DATA_W/2-1:0] };
		endcase
	end


	// mux c to mux d regs
	vector_sr
	#(
	.REGS			( REGS_C_D ),
	.DATA_W		( DATA_W+1 ),
	.RESET_VAL	( 0 )
	)
	c_d_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { mux_c,   ms_c } ),
	.data_o		( { mux_c_d, ms_d } )
	);


	// mux c
	always @ ( * ) begin
		case ( ms_d )
			'b0 : mux_d <= mux_c_d;
			'b1 : mux_d <= res_ms_i;
		endcase
	end


	// mux d to output regs
	vector_sr
	#(
	.REGS			( REGS_D_OUT ),
	.DATA_W		( DATA_W ),
	.RESET_VAL	( 0 )
	)
	d_out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( mux_d ),
	.data_o		( result_o )
	);


endmodule
