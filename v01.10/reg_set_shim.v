/*
--------------------------------------------------------------------------------

Module: reg_set_shim.v

Function: 
- Shim to interface main memory and internal register set.

Instantiates: 
- (2x) vector_sr.v

Notes:
- Address, data, and control I/O optionally registered.
- Register set is placed at the top of memory space, main mem at bottom.

--------------------------------------------------------------------------------
*/

module reg_set_shim
	#(
	parameter	integer							REGS_IN			= 1,		// register option for inputs
	parameter	integer							REGS_OUT			= 1,		// register option for outputs
	parameter	integer							DATA_W			= 16,		// data width (bits)
	parameter	integer							ADDR_W			= 8,		// address width (bits)
	parameter	integer							REG_ADDR_W		= 4,		// register set address width (bits)
	parameter	integer							IM_ADDR_W		= 4		// immediate address width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire								ext_i,						// 1=extended result
	output		wire	[DATA_W/2-1:0]			wr_data_o,					// write data
	// address I/O
	input			wire	[DATA_W/2-1:0]			b_lo_i,						// operand
	input			wire	[IM_ADDR_W-1:0]		im_addr_i,					// immediate address
	input			wire	[ADDR_W-1:0]			pc_1_i,						// program counter
	output		wire	[ADDR_W-1:0]			addr_o,						// address
	// bus I/O
	input			wire								wr_i,							// data write enable, active high
	input			wire								rd_i,							// data read enable, active high
	output		wire								regs_wr_o,					// data write enable, active high
	output		wire								regs_rd_o,					// data read enable, active high
	output		wire								dm_wr_o						// data write enable, active high
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire					[DATA_W-1:0]			a;
	wire					[DATA_W/2-1:0]			b_lo;
	wire					[IM_ADDR_W-1:0]		im_addr;
	wire												wr, rd, ext;
	wire					[ADDR_W-1:0]			rw_addr, addr;
	wire												regs_en, regs_wr, regs_rd, dm_wr;
	wire					[DATA_W/2-1:0]			wr_data;



	/*
	================
	== code start ==
	================
	*/


	// optional input regs
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( DATA_W+DATA_W/2+IM_ADDR_W+3 ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { a_i, b_lo_i, im_addr_i, wr_i, rd_i, ext_i } ),
	.data_o		( { a,   b_lo,   im_addr,   wr,   rd,   ext   } )
	);


	// read / write address
	assign rw_addr = b_lo + im_addr;

	// decode address
	assign addr = ( rd | wr ) ? rw_addr : pc_1_i;

	// decode register set address space (all upper bits set)
	assign regs_en = &addr[ADDR_W-1:REG_ADDR_W];
	
	// decode regs read & write
	assign regs_wr = wr & regs_en;
	assign regs_rd = rd & regs_en;

	// decode dmem write
	assign dm_wr = wr & ~regs_en;

	// decode write data
	assign wr_data = ( ext ) ? a[DATA_W-1:DATA_W/2] : a[DATA_W/2-1:0];


	// optional output registers
	vector_sr
	#(
	.REGS			( REGS_OUT ),
	.DATA_W		( ADDR_W+DATA_W/2+3 ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { addr,   wr_data,   regs_wr,   regs_rd,   dm_wr   } ),
	.data_o		( { addr_o, wr_data_o, regs_wr_o, regs_rd_o, dm_wr_o } )
	);


endmodule
