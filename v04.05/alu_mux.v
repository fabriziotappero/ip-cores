/*
--------------------------------------------------------------------------------

Module : alu_mux.v

--------------------------------------------------------------------------------

Function:
- Multiplexer for processor ALU.

Instantiates:
- (5x) pipe.v

Notes:
- Inputs at stage 1, outputs at stage 6.
- Default behavior is pass-thru.

--------------------------------------------------------------------------------
*/

module alu_mux
	#(
	parameter	integer							DATA_W			= 8,		// data width
	parameter	integer							ADDR_W			= 4		// address width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								sgn_1_i,						// 1=signed
	input			wire								hgh_1_i,						// 1=high
	input			wire								as_1_i,						// 1=add/subtract
	input			wire								ms_1_i,						// 1=multiply/shift
	input			wire								rtn_1_i,						// 1=return pc
	input			wire								dm_rd_1_i,					// 1=read
	input			wire								rg_rd_1_i,					// 1=read
	// data I/O
	input			wire	[DATA_W-1:0]			res_lg_2_i,					// logical result
	input			wire	[DATA_W-1:0]			res_as_2_i,					// add/subtract result
	input			wire	[ADDR_W-1:0]			pc_3_i,						// program counter
	input			wire	[DATA_W/2-1:0]			dm_rd_data_4_i,			// dmem read data
	input			wire	[DATA_W/2-1:0]			rg_rd_data_4_i,			// regs read data
	input			wire	[DATA_W-1:0]			res_ms_5_i,					// multiply/shift result
	output		wire	[DATA_W-1:0]			data_6_o						// data out
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												as_2, rtn_2, sgn_2, rg_rd_2, dm_rd_2, hgh_2, ms_2;
	wire												      rtn_3, sgn_3, rg_rd_3, dm_rd_3, hgh_3, ms_3;
	wire												             sgn_4, rg_rd_4, dm_rd_4, hgh_4, ms_4;
	wire												                                             ms_5;
	wire					[DATA_W-1:0]			        data_3, data_4, data_5;
	reg					[DATA_W-1:0]			mux_2,  mux_3,  mux_4,  mux_5;


	/*
	================
	== code start ==
	================
	*/


	// 1 to 2 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 7 ),
	.RESET_VAL	( 0 )
	)
	regs_1_2
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { as_1_i, rtn_1_i, sgn_1_i, rg_rd_1_i, dm_rd_1_i, hgh_1_i, ms_1_i } ),
	.data_o		( { as_2,   rtn_2,   sgn_2,   rg_rd_2,   dm_rd_2,   hgh_2,   ms_2   } )
	);


	// mux 2
	always @ ( * ) begin
		casex ( as_2 )
			'b1     : mux_2 <= res_as_2_i;
			default : mux_2 <= res_lg_2_i;  // default is thru
		endcase
	end


	// 2 to 3 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 6+DATA_W ),
	.RESET_VAL	( 0 )
	)
	regs_2_3
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { rtn_2, sgn_2, rg_rd_2, dm_rd_2, hgh_2, ms_2, mux_2  } ),
	.data_o		( { rtn_3, sgn_3, rg_rd_3, dm_rd_3, hgh_3, ms_3, data_3 } )
	);


	// mux 3
	always @ ( * ) begin
		casex ( rtn_3 )
			'b1     : mux_3 <= pc_3_i;  // unsigned
			default : mux_3 <= data_3;  // default is thru
		endcase
	end


	// 3 to 4 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 5+DATA_W ),
	.RESET_VAL	( 0 )
	)
	regs_3_4
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { sgn_3, rg_rd_3, dm_rd_3, hgh_3, ms_3, mux_3  } ),
	.data_o		( { sgn_4, rg_rd_4, dm_rd_4, hgh_4, ms_4, data_4 } )
	);


	// mux 4
	always @ ( * ) begin
		casex ( { rg_rd_4, dm_rd_4, hgh_4, sgn_4 } )
			'b0100  : mux_4 <= dm_rd_data_4_i;
			'b0101  : mux_4 <= $signed( dm_rd_data_4_i );
			'b011x  : mux_4 <= { dm_rd_data_4_i, data_4[DATA_W/2-1:0] };
			'b1x0x  : mux_4 <= $signed( rg_rd_data_4_i );
			'b1x1x  : mux_4 <= { rg_rd_data_4_i, data_4[DATA_W/2-1:0] };
			default : mux_4 <= data_4;  // default is thru
		endcase
	end


	// 4 to 5 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 1+DATA_W ),
	.RESET_VAL	( 0 )
	)
	regs_4_5
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { ms_4, mux_4  } ),
	.data_o		( { ms_5, data_5 } )
	);


	// mux 5
	always @ ( * ) begin
		casex ( ms_5 )
			'b1     : mux_5 <= res_ms_5_i;
			default : mux_5 <= data_5;  // default is thru
		endcase
	end


	// 5 to 6 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( DATA_W ),
	.RESET_VAL	( 0 )
	)
	d_out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( mux_5 ),
	.data_o		( data_6_o )
	);

	
endmodule
