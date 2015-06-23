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
- (8x) dq_ram_infer.v

Notes:
- 8 stage data pipeline beginning and ending on 8 BRAM based LIFOs.

--------------------------------------------------------------------------------
*/

module data_ring
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread selector width
	parameter	integer							STACKS			= 8,		// stacks
	parameter	integer							STK_W				= 3,		// stack selector width
	parameter	integer							PNTR_W			= 5,		// stack pointer width
	parameter	integer							IM_W				= 6,		// immediate width
	parameter	integer							LG_SEL_W			= 4,		// operation width
	parameter	integer							PROT_POP			= 1,		// 1=error protection, 0=none
	parameter	integer							PROT_PUSH		= 1		// 1=error protection, 0=none
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire	[STK_W-1:0]				data_sel_a_i,				// stack selector
	input			wire	[STK_W-1:0]				data_sel_b_i,				// stack selector
	input			wire	[STK_W-1:0]				addr_sel_b_i,				// stack selector
	input			wire								imda_i,						// 1=immediate data
	input			wire								imad_i,						// 1=immediate address
	input			wire								sgn_i,						// 1=signed
	input			wire								ext_i,						// 1=extended result
	input			wire								hgh_i,						// 1=high
	input			wire	[LG_SEL_W-1:0]			lg_sel_i,					// logic operation (see lg_sel_encode.h)
	input			wire								add_i,						// 1=add
	input			wire								sub_i,						// 1=subtract
	input			wire								mul_i,						// 1=multiply
	input			wire								shl_i,						// 1=shift left
	input			wire								pow_i,						// 1=power of 2
	input			wire								rtn_i,						// 1=return pc
	input			wire								dm_rd_i,						// 1=read
	input			wire								rg_rd_i,						// 1=read
	// stack I/O
	input			wire								stk_clr_i,					// stacks clear
	input			wire	[STACKS-1:0]			pop_i,						// stacks pop
	input			wire	[STACKS-1:0]			push_i,						// stacks push
	input			wire	[THRD_W-1:0]			thrd_6_i,					// thread
	// data I/O
	input			wire	[IM_W-1:0]				im_i,							// immediate
	input			wire	[DATA_W/2-1:0]			dm_rd_data_4_i,			// dmem read data
	input			wire	[DATA_W/2-1:0]			rg_rd_data_4_i,			// regs read data
	input			wire	[ADDR_W-1:0]			pc_3_i,						// program counter
	output		wire	[DATA_W-1:0]			a_data_o,					// a
	output		wire	[ADDR_W-1:0]			b_addr_o,					// b 
	// flags
	output		wire								flg_nz_2_o,					//	a != 0
	output		wire								flg_lz_2_o,					//	a < 0
	output		wire								flg_ne_2_o,					//	a != b
	output		wire								flg_lt_2_o,					//	a < b
	// errors
	output		wire	[STACKS-1:0]			pop_er_2_o,					// pop when empty, active high 
	output		wire	[STACKS-1:0]			push_er_3_o					// push when full, active high
	);


	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire					[DATA_W-1:0]			b_data;
	wire					[DATA_W-1:0]			pop_data0, pop_data1, pop_data2, pop_data3, pop_data4, pop_data5, pop_data6, pop_data7, push_data_6;
	wire					[PNTR_W-1:0]			pntr0_6, pntr1_6, pntr2_6, pntr3_6, pntr4_6, pntr5_6, pntr6_6, pntr7_6;
	wire					[STACKS-1:0]			stk_wr_6;



	/*
	================
	== code start ==
	================
	*/



	// stacks output mux
	stacks_mux
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.IM_W				( IM_W ),
	.STK_W			( STK_W )
	)
	stacks_mux
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.data_sel_a_i	( data_sel_a_i ),
	.data_sel_b_i	( data_sel_b_i ),
	.addr_sel_b_i	( addr_sel_b_i ),
	.imda_i			( imda_i ),
	.imad_i			( imad_i ),
	.pop_data0_i	( pop_data0 ),
	.pop_data1_i	( pop_data1 ),
	.pop_data2_i	( pop_data2 ),
	.pop_data3_i	( pop_data3 ),
	.pop_data4_i	( pop_data4 ),
	.pop_data5_i	( pop_data5 ),
	.pop_data6_i	( pop_data6 ),
	.pop_data7_i	( pop_data7 ),
	.im_i				( im_i ),
	.a_data_o		( a_data_o ),
	.b_data_o		( b_data ),
	.b_addr_o		( b_addr_o )
	);


	// ALU
	alu_top
	#(
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.LG_SEL_W			( LG_SEL_W )
	)
	alu_top
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.sgn_i				( sgn_i ),
	.ext_i				( ext_i ),
	.hgh_i				( hgh_i ),
	.lg_sel_i			( lg_sel_i ),
	.add_i				( add_i ),
	.sub_i				( sub_i ),
	.mul_i				( mul_i ),
	.shl_i				( shl_i ),
	.pow_i				( pow_i ),
	.rtn_i				( rtn_i ),
	.dm_rd_i				( dm_rd_i ),
	.rg_rd_i				( rg_rd_i ),
	.a_i					( a_data_o ),
	.b_i					( b_data ),
	.dm_rd_data_4_i	( dm_rd_data_4_i ),
	.rg_rd_data_4_i	( rg_rd_data_4_i ),
	.pc_3_i				( pc_3_i ),
	.result_6_o			( push_data_6 ),
	.flg_nz_2_o			( flg_nz_2_o ),
	.flg_lz_2_o			( flg_lz_2_o ),
	.flg_ne_2_o			( flg_ne_2_o ),
	.flg_lt_2_o			( flg_lt_2_o )
	);


	// stack pointer generation & storage
	pointer_ring
	#(
	.THREADS			( THREADS ),
	.STACKS			( STACKS ),
	.PNTR_W			( PNTR_W ),
	.PROT_POP		( PROT_POP ),
	.PROT_PUSH		( PROT_PUSH )
	)
	pointer_ring
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.clr_i			( stk_clr_i ),
	.pop_i			( pop_i ),
	.push_i			( push_i ),
	.pntr0_6_o		( pntr0_6 ),
	.pntr1_6_o		( pntr1_6 ),
	.pntr2_6_o		( pntr2_6 ),
	.pntr3_6_o		( pntr3_6 ),
	.pntr4_6_o		( pntr4_6 ),
	.pntr5_6_o		( pntr5_6 ),
	.pntr6_6_o		( pntr6_6 ),
	.pntr7_6_o		( pntr7_6 ),
	.wr_6_o			( stk_wr_6 ),
	.pop_er_2_o		( pop_er_2_o ),
	.push_er_3_o	( push_er_3_o )
	);


	// LIFO stacks memory
	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack0_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr0_6 } ),
	.wr_i				( stk_wr_6[0] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data0 )
	);

	
	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack1_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr1_6 } ),
	.wr_i				( stk_wr_6[1] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data1 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack2_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr2_6 } ),
	.wr_i				( stk_wr_6[2] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data2 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack3_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr3_6 } ),
	.wr_i				( stk_wr_6[3] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data3 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack4_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr4_6 } ),
	.wr_i				( stk_wr_6[4] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data4 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack5_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr5_6 } ),
	.wr_i				( stk_wr_6[5] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data5 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack6_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr6_6 } ),
	.wr_i				( stk_wr_6[6] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data6 )
	);


	dq_ram_infer
	#(
	.REG_OUT			( 1 ),
	.DATA_W			( DATA_W ),
	.ADDR_W			( THRD_W+PNTR_W ),
	.MODE 			( "RAW" )
	)
	stack7_dq_ram
	(
	.clk_i			( clk_i ),
	.addr_i			( { thrd_6_i, pntr7_6 } ),
	.wr_i				( stk_wr_6[7] ),
	.data_i			( push_data_6 ),
	.data_o			( pop_data7 )
	);


endmodule
