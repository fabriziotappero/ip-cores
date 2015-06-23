/*
--------------------------------------------------------------------------------

Module : data_ring.v

--------------------------------------------------------------------------------

Function:
- Processor data path & data stacks.

Instantiates:
- (1x) stacks_mux.v
- (1x) alu_top.v
- (1x) pointer_ring.v
- (4x) dq_ram_infer.v

Notes:
- 8 stage data pipeline beginning and ending on four BRAM based LIFOs.

--------------------------------------------------------------------------------
*/

module data_ring
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread selector width
	parameter	integer							STACKS			= 4,		// stacks
	parameter	integer							STK_W				= 2,		// stack selector width
	parameter	integer							PNTR_W			= 5,		// stack pointer width
	parameter	integer							IM_DATA_W		= 8,		// immediate data width
	parameter	integer							LG_W				= 2,		// operation width
	parameter	integer							POP_PROT			= 1,		// 1=error protection, 0=none
	parameter	integer							PUSH_PROT		= 1		// 1=error protection, 0=none
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire	[STK_W-1:0]				a_sel_i,						// stack selector
	input			wire	[STK_W-1:0]				b_sel_i,						// stack selector
	input			wire								imda_i,						// 1=immediate data
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
	// stack I/O
	input			wire								stk_clr_i,					// stacks clear
	input			wire	[STACKS-1:0]			pop_i,						// stacks pop
	input			wire	[STACKS-1:0]			push_i,						// stacks push
	input			wire	[THRD_W-1:0]			thrd_6_i,					// thread
	// data I/O
	input			wire	[IM_DATA_W-1:0]		im_data_i,					// immediate data
	input			wire	[DATA_W/2-1:0]			dm_data_i,					// dmem read data
	input			wire	[ADDR_W-1:0]			pc_3_i,						// program counter
	output		wire	[DATA_W-1:0]			a_o,							// a
	output		wire	[DATA_W-1:0]			b_o,							// b
	// flags
	output		wire								nez_o,						//	a != 0
	output		wire								ne_o,							//	a != b
	output		wire								ltz_o,						//	a < 0
	output		wire								lt_o,							//	a < b
	// errors
	output		wire	[STACKS-1:0]			pop_er_o,					// pop when empty, active high 
	output		wire	[STACKS-1:0]			push_er_o					// push when full, active high
	);


	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire					[DATA_W-1:0]			b_alu;
	wire					[DATA_W-1:0]			pop_data0, pop_data1, pop_data2, pop_data3, push_data;
	wire					[PNTR_W-1:0]			pntr0, pntr1, pntr2, pntr3;
	wire					[STACKS-1:0]			stk_wr;



	/*
	================
	== code start ==
	================
	*/



	// stacks output mux
	stacks_mux
	#(
	.DATA_W			( DATA_W ),
	.STK_W			( STK_W ),
	.IM_DATA_W		( IM_DATA_W )
	)
	stacks_mux
	(
	.a_sel_i			( a_sel_i ),
	.b_sel_i			( b_sel_i ),
	.imda_i			( imda_i ),
	.pop_data0_i	( pop_data0 ),
	.pop_data1_i	( pop_data1 ),
	.pop_data2_i	( pop_data2 ),
	.pop_data3_i	( pop_data3 ),
	.im_data_i		( im_data_i ),
	.a_o				( a_o ),
	.b_o				( b_o ),
	.b_alu_o			( b_alu )
	);


	// ALU
	alu_top
	#(
	.REGS_IN			( 1 ),
	.REGS_OUT		( 1 ),
	.REGS_FLG		( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.LG_W				( LG_W )
	)
	alu_top
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.sgn_i			( sgn_i ),
	.ext_i			( ext_i ),
	.lg_i				( lg_i ),
	.add_i			( add_i ),
	.sub_i			( sub_i ),
	.mul_i			( mul_i ),
	.shl_i			( shl_i ),
	.cpy_i			( cpy_i ),
	.dm_i				( dm_i ),
	.rtn_i			( rtn_i ),
	.a_i				( a_o ),
	.b_i				( b_alu ),
	.dm_data_i		( dm_data_i ),
	.pc_3_i			( pc_3_i ),
	.result_o		( push_data ),
	.nez_o			( nez_o ),
	.ne_o				( ne_o ),
	.ltz_o			( ltz_o ),
	.lt_o				( lt_o )
	);


	// stack pointer generation & storage
	pointer_ring
	#(
	.THREADS			( THREADS ),
	.STACKS			( STACKS ),
	.PNTR_W			( PNTR_W ),
	.POP_PROT		( POP_PROT ),
	.PUSH_PROT		( PUSH_PROT )
	)
	pointer_ring
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.clr_i			( stk_clr_i ),
	.pop_i			( pop_i ),
	.push_i			( push_i ),
	.pntr0_o			( pntr0 ),
	.pntr1_o			( pntr1 ),
	.pntr2_o			( pntr2 ),
	.pntr3_o			( pntr3 ),
	.wr_o				( stk_wr ),
	.pop_er_o		( pop_er_o ),
	.push_er_o		( push_er_o )
	);


	// LIFO stacks memory
	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.RD_MODE 		( "WR_DATA" )
	)
	stack0_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr0 } ),
	.wr_i				( stk_wr[0] ),
	.data_i			( push_data ),
	.data_o			( pop_data0 )
	);

	
	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.RD_MODE 		( "WR_DATA" )
	)
	stack1_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr1 } ),
	.wr_i				( stk_wr[1] ),
	.data_i			( push_data ),
	.data_o			( pop_data1 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.RD_MODE 		( "WR_DATA" )
	)
	stack2_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr2 } ),
	.wr_i				( stk_wr[2] ),
	.data_i			( push_data ),
	.data_o			( pop_data2 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.RD_MODE 		( "WR_DATA" )
	)
	stack3_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr3 } ),
	.wr_i				( stk_wr[3] ),
	.data_i			( push_data ),
	.data_o			( pop_data3 )
	);

endmodule
