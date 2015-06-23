/*
--------------------------------------------------------------------------------

Module : clz.v

--------------------------------------------------------------------------------

Function:
- Count leading zeros.

Instantiates:
- (2x) vector_sr.v

Notes:
- IN/OUT optionally registered.

--------------------------------------------------------------------------------
*/

module clz
	#(
	parameter	integer							REGS_IN			= 1,		// in register option
	parameter	integer							REGS_OUT			= 1,		// out register option
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							CLZ_W				= 6		// s/b clog2( DATA_W ) + 1;
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// data I/O
	input			wire	[DATA_W-1:0]			data_i,						// input
	output		wire	[CLZ_W-1:0]				clz_o							// result
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	//
	localparam	integer							LOG2_W			= clog2( DATA_W );
	//
	wire					[DATA_W-1:0]			data;
	reg												all_0;
	reg					[LOG2_W-1:0]			hi_1;
	wire					[CLZ_W-1:0]				clz;


	/*
	================
	== code start ==
	================
	*/


	// optional input regs
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( data_i ),
	.data_o		( data )
	);


	// looped priority encoder
	integer j;
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			hi_1 <= { LOG2_W{ 1'b1 } };
			all_0 <= 'b1;
		end else begin
			hi_1 <= { LOG2_W{ 1'b1 } };
			all_0 <= 'b1;
			for ( j = 0; j < DATA_W; j = j + 1 ) begin 
				if ( data[j] ) begin
					hi_1 <= j[LOG2_W-1:0]; 
					all_0 <= 'b0;
				end
			end
		end
	end
	
	// invert & concat to get zero count
	assign clz = { all_0, ~hi_1 };


	// optional output regs
	vector_sr
	#(
	.REGS			( REGS_OUT ),
	.DATA_W		( CLZ_W ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( clz ),
	.data_o		( clz_o )
	);


endmodule
