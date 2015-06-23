/*
--------------------------------------------------------------------------------

Module : hive_core.v

--------------------------------------------------------------------------------

Function:
- General purpose barrel processor FPGA core with:
  - 8 threads & 8 stage pipeline
  - 8 simple stacks per thread
  - 32 bit data
  - 16 bit opcode
  - 16 bit address

Instantiates (at this level):
- control_ring.v
- data_ring.v
- reg_set.v
- reg_mem_shim.v
- dp_ram_infer.v

--------------------
- Revision History -
--------------------

v04.05 - 2014-01-02
- Note main version jump.
- Branched design back into main line.
- OP_CODE_W is now MEM_DATA_W.

v01.04 - 2014-01-01
- Moved register set and main memory data port one pipeline stage later.
- op_pow is back and is now sign neutral.
- Op renaming: psh_iu => psu_i.
- `_0, `_1, etc. is now `s* in all boot code.
- Added header blocking statements to some *.h files (didn't work for all).
- Use of real rather than integer types in UART calculations for clarity.
- EP3C5E144C: 2662 LEs, 198MHz (w/o DSE, synthesis optimized for speed).
- Passes all boot code verification & functional tests.

v01.03 - 2013-12-23
- Short 4 bit (+7/-8) immediate (A?B) jumps have replaced all following jumps.
- Removed unconditional immediate jump (use op_jmp_ie).
- Immediate (A?0) jumps, data, and add IM value reduced to 6 bits.
- Removed op_pow_i, op_shl_iu is op_psh_iu: combo pow2 and right shift, 
  op_shl_u is strictly unsigned shift.
- UART added to register set.
- Op renaming:
    dat_f* => lit_*
    shl_iu => psh_iu
- Small changes to register set base component parameters & I/O.
- Opcode encode/decode now over full opcode width.
- EP3C5E144C: 2650 LEs, 189MHz (w/o DSE).
- Passes all boot code verification & functional tests.

v01.02 - 2013-12-06
- Following jumps (jmp_f) have replaced all skips.
- Added op_pow & op_pow_i opcodes.
- A odd testing removed (lack of opcode space).
- op_pop now covers all stacks at once via {pb, sb, pa, sa} binary field.
- op_reg_r now signed, added read and write high register ops (_wh is ~free).
- Added op_lit_u to accomodate 16 bit addresses & such.
- Op renaming:
    lit => dat_f
    byt => dat_i
    *_sx => *_xs
    *_ux => *_xu
- Moved PC interrupt & jmp_f address loads to stage 4 of PC pipe.
- op_dat_fh now uses A as source of low data rather than B,
  which is more consistent and allows unrelated pop.
- Register set addresses now defined as 8 bits wide.
- EP3C5E144C: ~2500 LEs, 185MHz (w/o DSE).
- Passes all boot code verification tests.
- Passes boot code functional tests: divide, sqrt, log2, exp2.

v01.01 - 2013-11-19
- Born.  Based on Hive v3.10.  Has 8 stacks per thread.
- Skips are back for A odd and (A?B) testing.
- Removed op_cls as it seems too dangerous.  May put back in register set.
- Lots of op renaming: 
    dat_f => lit
    dat_i => byt
    or_br => bro, etc.
    or => orr
    pc => pgc (to make all op bases 3 letters)
- Reg access now unsigned low with no immediate offset.
- Added register to flag decode output, moved all PC changes to stage 3.
- EP3C5E144C: ~2400 LEs, 178MHz (w/o DSE).
- BROKEN: reg_mem_shim.v has bad decoding for dmem addr.

--------------------------------------------------------------------------------
*/

module hive_core
	#(
	parameter	integer							CLK_HZ	 		= 160000000,	// master clk_i rate (Hz)
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							THREADS			= 8,		// threads (don't change!)
	parameter	[DATA_W/4-1:0]					VER_MAJ			= 'h04,	// core version
	parameter	[DATA_W/4-1:0]					VER_MIN			= 'h05	// core version
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	//
	input			wire	[THREADS-1:0]			intr_req_i,					// event request, active high
	//
	input			wire	[DATA_W-1:0]			io_i,							// gpio
	output		wire	[DATA_W-1:0]			io_o,
	//
	input			wire								uart_rx_i,					// serial data
	output		wire								uart_tx_o					// serial data
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	//
	localparam	integer							ADDR_W			= DATA_W/2;	// address width
	localparam	integer							PNTR_W			= 5;		// stack pointer width
	localparam	integer							MEM_ADDR_W		= 13;		// main memory address width
	localparam	integer							MEM_DATA_W		= DATA_W/2;		// main memory data width
	localparam	[ADDR_W-1:0]					CLR_BASE			= 'h0;	// clear address base (concat)
	localparam	integer							CLR_SPAN			= 2;		// clear address span (2^n)
	localparam	[ADDR_W-1:0]					INTR_BASE		= 'h20;	// interrupt address base (concat)
	localparam	integer							INTR_SPAN		= 2;		// interrupt address span (2^n)
	localparam	integer							THRD_W			= clog2( THREADS );
	localparam	integer							STACKS			= 8;		// number of stacks
	localparam	integer							STK_W				= clog2( STACKS );
	localparam	integer							IM_W				= 6;		// immediate width
	localparam	integer							LG_SEL_W			= 4;
	localparam	integer							REG_ADDR_W		= 4;
	localparam	integer							DM_OFFS_W		= 4;
	localparam	integer							PROT_POP			= 1;		// 1=error protection, 0=none
	localparam	integer							PROT_PUSH		= 1;		// 1=error protection, 0=none
	localparam	integer							UART_DATA_W		= 8;		// uart data width (bits)
	localparam	integer							UART_BAUD_RATE	= 115200;	// uart baud rate (Hz)
	//
	wire					[THREADS-1:0]			clr_req;
	wire					[THREADS-1:0]			intr_en;
	wire					[MEM_DATA_W-1:0]		op_code;
	wire												op_code_er;
	wire					[STK_W-1:0]				data_sel_a, data_sel_b, addr_sel_b;
	wire												imda;
	wire												imad;
	wire												sgn, ext, hgh;
	wire												lg;
	wire					[LG_SEL_W-1:0]			lg_sel;
	wire												add, sub, mul, shl, pow, rtn;
	wire												stk_clr;
	wire					[STACKS-1:0]			pop, push, pop_er_2, push_er_3;
	wire					[DATA_W-1:0]			a_data;
	wire					[ADDR_W-1:0]			b_addr;
	wire					[IM_W-1:0]				im;
	wire												flg_od_2, flg_nz_2, flg_lz_2, flg_ne_2, flg_lt_2;
	wire					[THRD_W-1:0]			thrd_0, thrd_2, thrd_3, thrd_6;
	wire					[ADDR_W-1:0]			pc_1, pc_3, pc_4;
	wire					[MEM_DATA_W-1:0]		dm_rd_data_4, rg_rd_data_4;
	wire					[MEM_DATA_W-1:0]		wr_data_2;
	wire					[ADDR_W-1:0]			dm_addr_2, rg_addr_2;
	wire												dm_rd, dm_wr, rg_rd, rg_wr;
	wire												dm_wr_2, rg_rd_2, rg_wr_2;
	wire												lit;


	/*
	================
	== code start ==
	================
	*/


	// the control ring
	control_ring
	#(
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.THREADS				( THREADS ),
	.THRD_W				( THRD_W ),
	.STACKS				( STACKS ),
	.STK_W				( STK_W ),
	.IM_W					( IM_W ),
	.MEM_DATA_W			( MEM_DATA_W ),
	.LG_SEL_W			( LG_SEL_W ),
	.CLR_BASE			( CLR_BASE ),
	.CLR_SPAN			( CLR_SPAN ),
	.INTR_BASE			( INTR_BASE ),
	.INTR_SPAN			( INTR_SPAN )
	)
	control_ring
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.clr_req_i			( clr_req ),
	.clr_ack_o			(  ),  // unused
	.intr_en_i			( intr_en ),
	.intr_req_i			( intr_req_i ),
	.intr_ack_o			(  ),  // unused
	.op_code_i			( op_code ),
	.op_code_er_o		( op_code_er ),
	.b_addr_i			( b_addr ),
	.im_o					( im ),
	.data_sel_a_o		( data_sel_a ),
	.data_sel_b_o		( data_sel_b ),
	.addr_sel_b_o		( addr_sel_b ),
	.imda_o				( imda ),
	.imad_o				( imad ),
	.sgn_o				( sgn ),
	.hgh_o				( hgh ),
	.ext_o				( ext ),
	.lg_sel_o			( lg_sel ),
	.add_o				( add ),
	.sub_o				( sub ),
	.mul_o				( mul ),
	.shl_o				( shl ),
	.pow_o				( pow ),
	.rtn_o				( rtn ),
	.lit_o				( lit ),
	.dm_rd_o				( dm_rd ),
	.dm_wr_o				( dm_wr ),
	.rg_rd_o				( rg_rd ),
	.rg_wr_o				( rg_wr ),
	.stk_clr_o			( stk_clr ),
	.pop_o				( pop ),
	.push_o				( push ),
	.flg_nz_2_i			( flg_nz_2 ),
	.flg_lz_2_i			( flg_lz_2 ),
	.flg_ne_2_i			( flg_ne_2 ),
	.flg_lt_2_i			( flg_lt_2 ),
	.thrd_0_o			( thrd_0 ),
	.thrd_2_o			( thrd_2 ),
	.thrd_3_o			( thrd_3 ),
	.thrd_6_o			( thrd_6 ),
	.pc_1_o				( pc_1 ),
	.pc_3_o				( pc_3 ),
	.pc_4_o				( pc_4 )
	);


	// the data ring
	data_ring
	#(
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.THREADS				( THREADS ),
	.THRD_W				( THRD_W ),
	.STACKS				( STACKS ),
	.STK_W				( STK_W ),
	.PNTR_W				( PNTR_W ),
	.IM_W					( IM_W ),
	.LG_SEL_W			( LG_SEL_W ),
	.PROT_POP			( PROT_POP ),
	.PROT_PUSH			( PROT_PUSH )
	)
	data_ring
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.data_sel_a_i		( data_sel_a ),
	.data_sel_b_i		( data_sel_b ),
	.addr_sel_b_i		( addr_sel_b ),
	.imda_i				( imda ),
	.imad_i				( imad ),
	.sgn_i				( sgn ),
	.ext_i				( ext ),
	.hgh_i				( hgh ),
	.lg_sel_i			( lg_sel ),
	.add_i				( add ),
	.sub_i				( sub ),
	.mul_i				( mul ),
	.shl_i				( shl ),
	.pow_i				( pow ),
	.rtn_i				( rtn ),
	.dm_rd_i				( dm_rd ),
	.rg_rd_i				( rg_rd ),
	.stk_clr_i			( stk_clr ),
	.pop_i				( pop ),
	.push_i				( push ),
	.thrd_6_i			( thrd_6 ),
	.im_i					( im ),
	.dm_rd_data_4_i	( dm_rd_data_4 ),
	.rg_rd_data_4_i	( rg_rd_data_4 ),
	.pc_3_i				( pc_3 ),
	.a_data_o			( a_data ),
	.b_addr_o			( b_addr ),
	.flg_nz_2_o			( flg_nz_2 ),
	.flg_lz_2_o			( flg_lz_2 ),
	.flg_ne_2_o			( flg_ne_2 ),
	.flg_lt_2_o			( flg_lt_2 ),
	.pop_er_2_o			( pop_er_2 ),
	.push_er_3_o		( push_er_3 )
	);


	// shim for memory and register set access
	reg_mem_shim
	#(
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.IM_W					( DM_OFFS_W )
	)
	reg_mem_shim
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.hgh_i				( hgh ),
	.lit_i				( lit ),
	.dm_wr_i				( dm_wr ),
	.rg_rd_i				( rg_rd ),
	.rg_wr_i				( rg_wr ),
	.dm_wr_o				( dm_wr_2 ),
	.rg_rd_o				( rg_rd_2 ),
	.rg_wr_o				( rg_wr_2 ),
	.a_data_i			( a_data ),
	.wr_data_o			( wr_data_2 ),
	.b_addr_i			( b_addr ),
	.im_i					( im[DM_OFFS_W-1:0] ),
	.pc_1_i				( pc_1 ),
	.rg_addr_o			( rg_addr_2 ),
	.dm_addr_o			( dm_addr_2 )
	);


	// internal register set
	reg_set
	#(
	.REGS_IN				( 1 ),
	.REGS_OUT			( 1 ),
	.DATA_W				( DATA_W/2 ),
	.ADDR_W				( REG_ADDR_W ),
	.THREADS				( THREADS ),
	.THRD_W				( THRD_W ),
	.STACKS				( STACKS ),
	.STK_W				( STK_W ),
	.VER_MAJ				( VER_MAJ ),
	.VER_MIN				( VER_MIN ),
	.UART_DATA_W		( UART_DATA_W ),
	.CLK_HZ	 			( CLK_HZ ),
	.UART_BAUD_RATE	( UART_BAUD_RATE )
	)
	reg_set
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.addr_i				( rg_addr_2[REG_ADDR_W-1:0] ),
	.wr_i					( rg_wr_2 ),
	.rd_i					( rg_rd_2 ),
	.data_i				( wr_data_2 ),
	.data_o				( rg_rd_data_4 ),
	.clr_req_o			( clr_req ),
	.intr_en_o			( intr_en ),
	.thrd_0_i			( thrd_0 ),
	.op_code_er_i		( op_code_er ),
	.thrd_2_i			( thrd_2 ),
	.pop_er_2_i			( pop_er_2 ),
	.thrd_3_i			( thrd_3 ),
	.push_er_3_i		( push_er_3 ),
	.io_lo_i				( io_i[DATA_W/2-1:0] ),
	.io_hi_i				( io_i[DATA_W-1:DATA_W/2] ),
	.io_lo_o				( io_o[DATA_W/2-1:0] ),
	.io_hi_o				( io_o[DATA_W-1:DATA_W/2] ),
	.uart_rx_i			( uart_rx_i ),
	.uart_tx_o			( uart_tx_o )
	);


	// instruction and data memory
	dp_ram_infer
	#(
	.REG_A_OUT			( 1 ),
	.REG_B_OUT			( 1 ),
	.DATA_W				( MEM_DATA_W ),
	.ADDR_W				( MEM_ADDR_W ),
	.MODE 				( "RAW" )  // functional don't care
	)
	main_mem
	(
	.a_clk_i				( clk_i ),
	.a_addr_i			( dm_addr_2 ),
	.a_wr_i				( dm_wr_2 ),
	.a_data_i			( wr_data_2 ),
	.a_data_o			( dm_rd_data_4 ),
	.b_clk_i				( clk_i ),
	.b_addr_i			( pc_4 ),
	.b_wr_i				( 1'b0 ),  // unused
	.b_data_i			(  ),  // unused
	.b_data_o			( op_code )
	);


endmodule
