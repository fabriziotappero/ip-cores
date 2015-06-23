/*
--------------------------------------------------------------------------------

Module : control_ring.v

--------------------------------------------------------------------------------

Function:
- Processor control path.

Instantiates:
- (1x) thread_ring.v
- (2x) event_ctrl.v
- (1x) cond_test.v
- (1x) op_decode.v
- (1x) pc_ring.v

Notes:
- 8 stage data pipeline consisting of several storage rings.

--------------------------------------------------------------------------------
*/

module control_ring
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread width
	parameter	integer							STACKS			= 4,		// number of stacks
	parameter	integer							STK_W				= 2,		// stack selector width
	parameter	integer							IM_DATA_W		= 8,		// immediate data width
	parameter	integer							IM_ADDR_W		= 5,		// immediate address width
	parameter	integer							OP_CODE_W		= 16,		// opcode width
	parameter	integer							LG_W				= 2,		// logical operation width
	parameter	[ADDR_W-1:0]					CLR_BASE			= 'h0,	// clear address base (concat)
	parameter	integer							CLR_SPAN			= 0,		// clear address span (2^n)
	parameter	[ADDR_W-1:0]					INTR_BASE		= 'h8,	// interrupt address base (concat)
	parameter	integer							INTR_SPAN		= 0		// interrupt address span (2^n)
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire	[THREADS-1:0]			clr_req_i,					// clear request, active high
	output		wire	[THREADS-1:0]			clr_ack_o,					// clear ack, active high until serviced
	input			wire	[THREADS-1:0]			intr_en_i,					// interrupt enable, active high
	input			wire	[THREADS-1:0]			intr_req_i,					// interrupt request, active high
	output		wire	[THREADS-1:0]			intr_ack_o,					// interrupt ack, active high until serviced
	input			wire	[OP_CODE_W-1:0]		op_code_i,					// opcode
	output		wire								op_code_er_o,				// 1=illegal op code encountered
	// ALU I/O
	input			wire	[DATA_W/2-1:0]			b_lo_i,						// b_lo
	output		wire	[IM_DATA_W-1:0]		im_data_o,					// immediate data
	output		wire	[STK_W-1:0]				a_sel_o,						// stack selector
	output		wire	[STK_W-1:0]				b_sel_o,						// stack selector
	output		wire								imda_o,						// 1=immediate data
	output		wire								sgn_o,						// 1=signed
	output		wire								ext_o,						// 1=extended
	output		wire	[LG_W-1:0]				lg_o,							// see decode in notes
	output		wire								add_o,						// 1=add
	output		wire								sub_o,						// 1=subtract
	output		wire								mul_o,						// 1=multiply
	output		wire								shl_o,						// 1=shift left
	output		wire								cpy_o,						// 1=copy b
	output		wire								dm_o,							// 1=data mem
	output		wire								rtn_o,						// 1=return pc
	output		wire								rd_o,							// 1=read
	output		wire								wr_o,							// 1=write
	// stack I/O
	output		wire								stk_clr_o,					// stacks clear
	output		wire	[STACKS-1:0]			pop_o,						// stacks pop
	output		wire	[STACKS-1:0]			push_o,						// stacks push
	// flags
	input			wire								nez_i,						//	a != 0
	input			wire								ne_i,							//	a != b
	input			wire								ltz_i,						//	a < 0
	input			wire								lt_i,							//	a < b
	// threads
	output		wire	[THRD_W-1:0]			thrd_0_o,
	output		wire	[THRD_W-1:0]			thrd_2_o,
	output		wire	[THRD_W-1:0]			thrd_3_o,
	output		wire	[THRD_W-1:0]			thrd_6_o,
	// addresses
	output		wire	[IM_ADDR_W-1:0]		im_addr_o,					// immediate address (offset)
	output		wire	[ADDR_W-1:0]			pc_1_o,
	output		wire	[ADDR_W-1:0]			pc_3_o,
	output		wire	[ADDR_W-1:0]			pc_4_o
	);


	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												pc_clr, lit, jmp, gto, intr, imad, tst_2;
	wire												stk_clr;
	wire					[STACKS-1:0]			pop, push;
	wire												tst_eq, tst_lt, tst_gt, tst_ab;
	wire												thrd_clr, thrd_intr;
	wire					[THRD_W-1:0]			thrd_5;



	/*
	================
	== code start ==
	================
	*/


	// establish threads
	thread_ring
	#(
	.THRD_W			( THRD_W )
	)
	thread_ring
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_0_o		( thrd_0_o ),
	.thrd_1_o		(  ),
	.thrd_2_o		( thrd_2_o ),
	.thrd_3_o		( thrd_3_o ),
	.thrd_4_o		(  ),
	.thrd_5_o		( thrd_5 ),
	.thrd_6_o		( thrd_6_o ),
	.thrd_7_o		(  )
	);


	// handle external thread clear requests
	event_ctrl
	#(
	.REGS_REQ		( 0 ),  // don't resync
	.EDGE_REQ		( 1 ),  // edge sensitive
	.RESET_VAL		( { THREADS{ 1'b1 } } ),  // clear threads @ power-up
	.THREADS			( THREADS ),
	.THRD_W			( THRD_W )
	)
	clr_event_ctrl
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_i			( thrd_5 ),
	.en_i				( { THREADS{ 1'b1 } } ),  // always enable
	.req_i			( clr_req_i ),
	.ack_o			( clr_ack_o ),
	.event_o			( thrd_clr )
	);


	// handle external thread interrupt requests
	event_ctrl
	#(
	.REGS_REQ		( 2 ),  // resync
	.EDGE_REQ		( 1 ),  // edge sensitive
	.RESET_VAL		( 0 ),
	.THREADS			( THREADS ),
	.THRD_W			( THRD_W )
	)
	intr_event_ctrl
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_i			( thrd_5 ),
	.en_i				( intr_en_i ),
	.req_i			( intr_req_i ),
	.ack_o			( intr_ack_o ),
	.event_o			( thrd_intr )
	);


	// conditional jump etc. testing
	cond_test
	#(
	.REGS_TST		( 2 ),
	.REGS_OUT		( 0 )
	)
	cond_test
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.nez_i			( nez_i ),
	.ne_i				( ne_i ),
	.ltz_i			( ltz_i ),
	.lt_i				( lt_i ),
	.tst_eq_i		( tst_eq ),
	.tst_lt_i		( tst_lt ),
	.tst_gt_i		( tst_gt ),
	.tst_ab_i		( tst_ab ),
	.tst_o			( tst_2 )
	);


	// op_code decoding
	op_decode
	#(
	.REGS_IN			( 0 ),
	.REGS_OUT		( 1 ),
	.STACKS			( STACKS ),
	.STK_W			( STK_W ),
	.DATA_W			( DATA_W ),
	.IM_DATA_W		( IM_DATA_W ),
	.IM_ADDR_W		( IM_ADDR_W ),
	.OP_CODE_W		( OP_CODE_W ),
	.LG_W				( LG_W )
	)
	op_decode
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_clr_i		( thrd_clr ),
	.thrd_intr_i	( thrd_intr ),
	.op_code_i		( op_code_i ),
	.op_code_er_o 	( op_code_er_o ),
	.im_data_o		( im_data_o ),
	.im_addr_o		( im_addr_o ),
	.pc_clr_o		( pc_clr ),
	.lit_o			( lit ),
	.jmp_o			( jmp ),
	.gto_o			( gto ),
	.intr_o			( intr ),
	.tst_eq_o		( tst_eq ),
	.tst_lt_o		( tst_lt ),
	.tst_gt_o		( tst_gt ),
	.tst_ab_o		( tst_ab ),
	.stk_clr_o		( stk_clr_o ),
	.pop_o			( pop_o ),
	.push_o			( push_o ),
	.a_sel_o			( a_sel_o ),
	.b_sel_o			( b_sel_o ),
	.imda_o			( imda_o ),
	.imad_o			( imad ),
	.sgn_o			( sgn_o ),
	.ext_o			( ext_o ),
	.lg_o				( lg_o ),
	.add_o			( add_o ),
	.sub_o			( sub_o ),
	.mul_o			( mul_o ),
	.shl_o			( shl_o ),
	.cpy_o			( cpy_o ),
	.dm_o				( dm_o ),
	.rtn_o			( rtn_o ),
	.rd_o				( rd_o ),
	.wr_o				( wr_o )
	);


	// pc generation & storage
	pc_ring
	#(
	.THREADS			( THREADS ),
	.THRD_W			( THRD_W ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.IM_ADDR_W		( IM_ADDR_W ),
	.CLR_BASE		( CLR_BASE ),
	.CLR_SPAN		( CLR_SPAN ),
	.INTR_BASE		( INTR_BASE ),
	.INTR_SPAN		( INTR_SPAN )
	)
	pc_ring
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_0_i		( thrd_0_o ),
	.thrd_3_i		( thrd_3_o ),
	.clr_i			( pc_clr ),
	.lit_i			( lit ),
	.jmp_i			( jmp ),
	.gto_i			( gto ),
	.intr_i			( intr ),
	.imad_i			( imad ),
	.tst_2_i			( tst_2 ),
	.b_lo_i			( b_lo_i ),
	.im_addr_i		( im_addr_o ),
	.pc_0_o			(  ),
	.pc_1_o			( pc_1_o ),
	.pc_2_o			(  ),
	.pc_3_o			( pc_3_o ),
	.pc_4_o			( pc_4_o ),
	.pc_5_o			(  ),
	.pc_6_o			(  ),
	.pc_7_o			(  )
	);


endmodule
