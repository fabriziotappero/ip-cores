/*
--------------------------------------------------------------------------------

Module: reg_mem_shim.v

Function: 
- Shim for internal register set and main memory r/w accesses.

Instantiates: 
- (6x) pipe.v

Notes:
- I/O registered.

--------------------------------------------------------------------------------
*/

module reg_mem_shim
	#(
	parameter	integer							DATA_W			= 32,		// data width (bits)
	parameter	integer							ADDR_W			= 16,		// address width (bits)
	parameter	integer							IM_W				= 8		// immediate width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								hgh_i,						// 1=high
	input			wire								lit_i,						// 1=literal data
	//
	input			wire								dm_wr_i,						// 1=write
	input			wire								rg_rd_i,						// 1=read
	input			wire								rg_wr_i,						// 1=write
	//
	output		wire								dm_wr_o,						// 1=write
	output		wire								rg_rd_o,						// 1=read
	output		wire								rg_wr_o,						// 1=write
	// data I/O
	input			wire	[DATA_W-1:0]			a_data_i,					// operand
	output		wire	[DATA_W/2-1:0]			wr_data_o,					// write data
	// address I/O
	input			wire	[ADDR_W-1:0]			b_addr_i,					// b
	input			wire	[IM_W-1:0]				im_i,							// immediate
	input			wire	[ADDR_W-1:0]			pc_1_i,						// program counter
	output		wire	[ADDR_W-1:0]			rg_addr_o,					// address
	output		wire	[ADDR_W-1:0]			dm_addr_o					// address
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												hgh, lit, dm_wr, rg_rd, rg_wr;
	wire					[ADDR_W-1:0]			b_addr, rg_addr, dm_addr;
	wire					[IM_W-1:0]				im;
	wire					[DATA_W-1:0]			a_data, wr_data;



	/*
	================
	== code start ==
	================
	*/


	// input ctrl regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 5 ),
	.RESET_VAL	( 0 )
	)
	in_regs_ctrl
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { hgh_i, lit_i, dm_wr_i, rg_rd_i, rg_wr_i } ),
	.data_o		( { hgh,   lit,   dm_wr,   rg_rd,   rg_wr   } )
	);


	// input addr regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( IM_W+ADDR_W ),
	.RESET_VAL	( 0 )
	)
	in_regs_addr
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { im_i, b_addr_i } ),
	.data_o		( { im,   b_addr   } )
	);


	// input data regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs_data
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( a_data_i ),
	.data_o		( a_data   )
	);


	// decode write data
	assign wr_data = ( hgh ) ? a_data[DATA_W-1:DATA_W/2] : a_data[DATA_W/2-1:0];

	// decode address
	assign rg_addr = b_addr;
	assign dm_addr = ( lit ) ? pc_1_i : b_addr + im;


	// output ctrl regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 3 ),
	.RESET_VAL	( 0 )
	)
	out_regs_ctrl
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { dm_wr,   rg_rd,   rg_wr   } ),
	.data_o		( { dm_wr_o, rg_rd_o, rg_wr_o } )
	);


	// output addr regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( ADDR_W+ADDR_W ),
	.RESET_VAL	( 0 )
	)
	out_regs_addr
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { rg_addr,   dm_addr   } ),
	.data_o		( { rg_addr_o, dm_addr_o } )
	);


	// output data regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( DATA_W/2 ),
	.RESET_VAL	( 0 )
	)
	out_regs_data
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( wr_data   ),
	.data_o		( wr_data_o )
	);


endmodule
