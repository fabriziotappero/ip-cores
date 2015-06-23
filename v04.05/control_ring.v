/*
--------------------------------------------------------------------------------

Module : control_ring.v

--------------------------------------------------------------------------------

Function:
- Processor control path.

Instantiates:
- (1x) thread_ring.v
- (2x) event_ctrl.v
- (1x) tst_decode.v
- (1x) op_decode.v
- (1x) pc_ring.v

Notes:
- 8 stage pipeline consisting of several storage rings.

--------------------------------------------------------------------------------
*/

module control_ring
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread width
	parameter	integer							STACKS			= 8,		// number of stacks
	parameter	integer							STK_W				= 3,		// stack selector width
	parameter	integer							IM_W				= 6,		// immediate width
	parameter	integer							MEM_DATA_W		= 16,		// opcode width
	parameter	integer							LG_SEL_W			= 4,		// logical operation width
	parameter	[ADDR_W-1:0]					CLR_BASE			= 'h0,	// clear address base (concat)
	parameter	integer							CLR_SPAN			= 2,		// clear address span (2^n)
	parameter	[ADDR_W-1:0]					INTR_BASE		= 'h20,	// interrupt address base (concat)
	parameter	integer							INTR_SPAN		= 2		// interrupt address span (2^n)
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
	input			wire	[MEM_DATA_W-1:0]		op_code_i,					// opcode
	output		wire								op_code_er_o,				// 1=illegal op code encountered
	// ALU I/O
	input			wire	[ADDR_W-1:0]			b_addr_i,					// b | im
	output		wire	[IM_W-1:0]				im_o,							// immediate
	output		wire	[STK_W-1:0]				data_sel_a_o,				// stack selector
	output		wire	[STK_W-1:0]				data_sel_b_o,				// stack selector
	output		wire	[STK_W-1:0]				addr_sel_b_o,				// b stack selector
	output		wire								imda_o,						// 1=immediate data
	output		wire								imad_o,						// 1=immediate address
	output		wire								sgn_o,						// 1=signed
	output		wire								ext_o,						// 1=extended
	output		wire								hgh_o,						// 1=high
	output		wire	[LG_SEL_W-1:0]			lg_sel_o,					// see decode in notes
	output		wire								add_o,						// 1=add
	output		wire								sub_o,						// 1=subtract
	output		wire								mul_o,						// 1=multiply
	output		wire								shl_o,						// 1=shift left
	output		wire								pow_o,						// 1=power of 2
	output		wire								rtn_o,						// 1=return pc
	output		wire								lit_o,						// 1=literal data
	output		wire								dm_rd_o,						// 1=read
	output		wire								dm_wr_o,						// 1=write
	output		wire								rg_rd_o,						// 1=read
	output		wire								rg_wr_o,						// 1=write
	// stack I/O
	output		wire								stk_clr_o,					// stacks clear
	output		wire	[STACKS-1:0]			pop_o,						// stacks pop
	output		wire	[STACKS-1:0]			push_o,						// stacks push
	// flags
	input			wire								flg_nz_2_i,					//	a != 0
	input			wire								flg_lz_2_i,					//	a < 0
	input			wire								flg_ne_2_i,					//	a != b
	input			wire								flg_lt_2_i,					//	a < b
	// threads
	output		wire	[THRD_W-1:0]			thrd_0_o,
	output		wire	[THRD_W-1:0]			thrd_2_o,
	output		wire	[THRD_W-1:0]			thrd_3_o,
	output		wire	[THRD_W-1:0]			thrd_6_o,
	// addresses
	output		wire	[ADDR_W-1:0]			pc_1_o,
	output		wire	[ADDR_W-1:0]			pc_3_o,
	output		wire	[ADDR_W-1:0]			pc_4_o
	);


	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam			integer					TST_W = 4;
	//
	wire												pc_clr, cnd, zro, jmp, gto, intr, res_tst_3;
	wire												stk_clr;
	wire					[STACKS-1:0]			pop, push;
	wire					[TST_W-1:0]				tst;
	wire												thrd_clr, thrd_intr;
	wire					[THRD_W-1:0]			thrd_4, thrd_5;



	/*
	================
	== code start ==
	================
	*/


	// establish threads
	thread_ring
	#(
	.THREADS			( THREADS ),
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
	.thrd_4_o		( thrd_4 ),
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
	tst_decode
	#(
	.REGS_TST		( 2 ),
	.REGS_OUT		( 1 ),
	.TST_W			( TST_W )
	)
	tst_decode
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.flg_nz_i		( flg_nz_2_i ),
	.flg_lz_i		( flg_lz_2_i ),
	.flg_ne_i		( flg_ne_2_i ),
	.flg_lt_i		( flg_lt_2_i ),
	.cnd_i			( cnd ),
	.tst_i			( tst ),
	.result_o		( res_tst_3 )
	);


	// op_code decoding
	op_decode
	#(
	.REGS_IN			( 0 ),
	.REGS_OUT		( 1 ),
	.STACKS			( STACKS ),
	.STK_W			( STK_W ),
	.DATA_W			( DATA_W ),
	.IM_W				( IM_W ),
	.MEM_DATA_W		( MEM_DATA_W ),
	.LG_SEL_W		( LG_SEL_W ),
	.TST_W			( TST_W )
	)
	op_decode
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.thrd_clr_i		( thrd_clr ),
	.thrd_intr_i	( thrd_intr ),
	.op_code_i		( op_code_i ),
	.op_code_er_o 	( op_code_er_o ),
	.im_o				( im_o ),
	.pc_clr_o		( pc_clr ),
	.cnd_o			( cnd ),
	.lit_o			( lit_o ),
	.jmp_o			( jmp ),
	.gto_o			( gto ),
	.intr_o			( intr ),
	.tst_o			( tst ),
	.stk_clr_o		( stk_clr_o ),
	.pop_o			( pop_o ),
	.push_o			( push_o ),
	.data_sel_a_o	( data_sel_a_o ),
	.data_sel_b_o	( data_sel_b_o ),
	.addr_sel_b_o	( addr_sel_b_o ),
	.imda_o			( imda_o ),
	.imad_o			( imad_o ),
	.sgn_o			( sgn_o ),
	.ext_o			( ext_o ),
	.hgh_o			( hgh_o ),
	.lg_sel_o		( lg_sel_o ),
	.add_o			( add_o ),
	.sub_o			( sub_o ),
	.mul_o			( mul_o ),
	.shl_o			( shl_o ),
	.pow_o			( pow_o ),
	.rtn_o			( rtn_o ),
	.dm_rd_o			( dm_rd_o ),
	.dm_wr_o			( dm_wr_o ),
	.rg_rd_o			( rg_rd_o ),
	.rg_wr_o			( rg_wr_o )
	);


	// pc generation & storage
	pc_ring
	#(
	.THREADS				( THREADS ),
	.THRD_W				( THRD_W ),
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.CLR_BASE			( CLR_BASE ),
	.CLR_SPAN			( CLR_SPAN ),
	.INTR_BASE			( INTR_BASE ),
	.INTR_SPAN			( INTR_SPAN )
	)
	pc_ring
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.thrd_0_i			( thrd_0_o ),
	.thrd_4_i			( thrd_4 ),
	.clr_i				( pc_clr ),
	.lit_i				( lit_o ),
	.jmp_i				( jmp ),
	.gto_i				( gto ),
	.intr_i				( intr ),
	.res_tst_3_i		( res_tst_3 ),
	.b_addr_i			( b_addr_i ),
	.pc_0_o				(  ),
	.pc_1_o				( pc_1_o ),
	.pc_2_o				(  ),
	.pc_3_o				( pc_3_o ),
	.pc_4_o				( pc_4_o ),
	.pc_5_o				(  ),
	.pc_6_o				(  ),
	.pc_7_o				(  )
	);


endmodule
