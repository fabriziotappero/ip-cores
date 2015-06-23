/*
--------------------------------------------------------------------------------

Module : alu_logical.v

--------------------------------------------------------------------------------

Function:
- Logic unit for a processor ALU.

Instantiates:
- (4x) vector_sr.v

Notes:
- IN/MID/OUT/FLG optionally registered.
- lg_i / result_o decode:

 lg   result
---   --
 00   a and b
 01   a or b
 10   a xor b
 11   not( b )

 lg   result (ext)
---   -----
 00   and( b ) bit reduction
 01   or( b ) bit reduction
 1x   xor( b ) bit reduction

--------------------------------------------------------------------------------
*/

module alu_logical
	#(
	parameter	integer							REGS_IN			= 1,		// register option for inputs
	parameter	integer							REGS_MID			= 1,		// mid register option
	parameter	integer							REGS_OUT			= 1,		// register option for outputs
	parameter	integer							REGS_FLG			= 1,		// register option for flag outputs
	parameter	integer							DATA_W			= 2,		// data width
	parameter	integer							LG_W				= 2		// operation width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								ext_i,						// 1=extended result
	input			wire	[LG_W-1:0]				lg_i,							// see decode in notes above
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	output		wire	[DATA_W-1:0]			result_o,					// logical result
	// flags
	output		wire								nez_o,						//	a != 0
	output		wire								ne_o							//	a != b
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												ext, ext_r;
	wire					[LG_W-1:0]				lg;
	wire					[DATA_W-1:0]			a, b;
	reg					[DATA_W-1:0]			res;
	wire					[DATA_W-1:0]			res_r;
	reg												res_bit;
	wire												res_bit_r;
	reg					[DATA_W-1:0]			result;
	wire					[DATA_W-1:0]			a_xor_b;
	wire												nez, ne;


	/*
	================
	== code start ==
	================
	*/


	// optional input registers
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( DATA_W+DATA_W+LG_W+1 ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { a_i, b_i, lg_i, ext_i } ),
	.data_o		( { a,   b,   lg,   ext } )
	);


	// some intermediate results
	assign a_xor_b = a ^ b;

	// flags
	assign nez = |a;
	assign ne = |a_xor_b;

	// multiplex results
	always @ ( * ) begin
		case ( lg )
			'b00 : res <= a & b;
			'b01 : res <= a | b;
			'b10 : res <= a_xor_b;
			'b11 : res <= ~b;
		endcase
	end

	// multiplex results
	always @ ( * ) begin
		casex ( lg )
			'b00 : res_bit <= &b;
			'b01 : res_bit <= |b;
			'b1x : res_bit <= ^b;
		endcase
	end


	// optional flag regs
	vector_sr
	#(
	.REGS			( REGS_FLG ),
	.DATA_W		( 2 ),
	.RESET_VAL	( 0 )
	)
	regs_flags
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { nez,   ne } ),
	.data_o		( { nez_o, ne_o } )
	);


	// optional mid regs
	vector_sr
	#(
	.REGS			( REGS_MID ),
	.DATA_W		( DATA_W+2 ),
	.RESET_VAL	( 0 )
	)
	mid_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { res,   res_bit,   ext } ),
	.data_o		( { res_r, res_bit_r, ext_r } )
	);


	// multiplex
	always @ ( * ) begin
		case ( ext_r )
			'b0 : result <= res_r;
			'b1 : result <= { DATA_W{ res_bit_r } };
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
