/*
--------------------------------------------------------------------------------

Module : core.v

--------------------------------------------------------------------------------

Function:
- Processor core with 8 stage pipeline, 8 threads, and 4 stacks per thread.

Instantiates:
- control_ring.v
- data_ring.v
- reg_set.v
- reg_set_shim.v
- dp_ram_infer.v


--------------------
- Revision History -
--------------------

v01.10 - 2013-07-06
- Shuffled opcode encoding again:
  - Unused jmp_iz never houses rd_i ops.
  - Unused jmp_i never houses wr_i ops.
  - jmp_i always immediate field reduced to 5 bits for consistency,
    which leaves an unused 32 code gap.
- Edited boot code tests to work with this new encoding.

v01.09 (cont) - 2013-06-25
- Passes boot code verification for:
  - All I/O ops.

v01.09 - 2013-06-24
- First public release.
- Shuffled opcode encoding again:
  - Unused never jmp_i fits read/write perfectly.
  - Unused always jmp_i zero comparison allows for 1 bit immediate field 
    expansion of jmp_i(gle/z).
- Removed all skip instructions (redundant w/ jmp_i).
- All the above allows add_i immediate field expansion to 6 bits.
- Opcode encoding is now more straightforward with fewer immediate field sizes.
- Worked on pc_ring.v and pointer_ring.v, now use simple loops rather than 
  generate, the logic produced better tracks the module paramters.
- Removed "skp" control bit from pc_ring.v, op_decode.v, control_ring.v.
- Removed intr_ack_o from core I/O.
- Renamed "register_set*" => "reg_set*".
- (Considering adding a leading zero count opcode, it doesn't take many LEs.)
- Seeing a write to thread 7 stack 0 memory at startup, don't think it
  means anything due to clearing.  
- Passes boot code verification for:
  - Interrupts.
  - Stack ops, depth, error reporting (all threads).
  - All branch / conditional ops.
  - All logical / arithmetic / shift ops.

v01.08 - 2013-06-14
- Added parameter options for stack pointer error protections & brought them
  to the top level.
- The unsigned restoring division subroutine works!

v01.07 - 2013-06-11
- Changed opcodes to make swapping of (A?B) operands cover all logical needs:
  - op_skp_ul => op_skp_l
  - op_skp_ge => op_skp_uge
  - op_jmp_iul => op_jmp_il
  - op_jmp_ige => op_jmp_iuge
- Changed verification boot code tests to reflect above (passes).

v01.06 - 2013-06-10
- Fixed latency of test fields in op_decode.v (were only registered 1x, s/b 2x).
- Fixed subtle immediate address offset sign issue in pc_ring.v.
- Fixed subtle immediate data sign issue in stacks_mux.v.
- Minor style edits to visually align port names @ vector_sr.v instances.
- The log2 subroutine works!

v01.05 - 2013-06-07
- Put the skip instructions back (for convenience & clarity).
- Changes to op_decode.v, separate immediate data and address decodes, 
  misc. edits to improve speed.
- Renamed "op_codes.h" => "op_encode.h".
- Lots of minor edits at the higher levels.
- Added "copyright.txt" to directory.

v01.04 - 2013-06-06
- Added op_jmp_i (A?B) instructions.
- Removed all skip instructions (redundant).

v01.03 - 2013-06-04
- Changed op_jmp_i to be conditional (A?0).
- Renamed "addr_regs.h" => "register_set_addr.h".
- New boot code does log2.

v01.02 (cont) - 2013-05-23
- Old boot code file renamed: "boot_code.h" => "boot_code_00.h".
- New boot code file tests all op_codes and gives final report. 

v01.02 - 2013-05-22
- Memory writes now work, the fix was to swap pc/op_code ROM side A with 
   data RW side B of main memory "dp_ram_infer.v".  It seems side A is 
   incorrectly used as the master mode for both ports.
- Renamed "alu_input_mux.v" => "stacks_mux.v".
- Removed enable from "register_set.v" and "register_set_shim.v".
- Monkeyed with "register_set_shim.v" a bit.
- Removed async resets from "dp_ram_infer.v" and "dq_ram_infer.v".
- Passes boot code tests 0, 1, 2, 3, 4.

v01.01 - 2013-05-22
- Added clear and interrupt BASE and SPAN parameters.  
- Because BASE is a simple MSB concatenation, for it to be effective
   make BASE >= 2^(THRD_W+SPAN).  BASE LSBs below this point are ignored.
- Individual clear and interrupt address interspacing = 2^SPAN.
- Example: 
   CLR_BASE ='h0 positions thread 0 clear @ 0.
   CLR_SPAN =2 positions thread 1 clear @ 4, thread 2 @ 8, etc.
   INTR_BASE='h20 positions thread 0 interrupt @ 'd32.
   INTR_SPAN=2 positions thread 1 interrupt @ 'd36, thread 2 @ 'd40, etc.
- Moved most core top port parameters to localparam.
- Modified boot code tests accordingly.
- Passes boot code tests 0, 1, 2.
- Memory writes still don't work!

v01.00 - 2013-05-21 - born
- EP3C5E144C8: ~180MHz, ~1785 LEs (34% of logic).
- Fixed immediate value bug (was only registered 1x in op_decode.v, s/b 2x).
- Passes boot code tests 0, 1, 2.
- Memory writes don't work!

--------------------------------------------------------------------------------
*/

module core
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							THREADS			= 8,		// threads
	parameter	[DATA_W/4-1:0]					VER_MAJ			= 'h01,	// core version
	parameter	[DATA_W/4-1:0]					VER_MIN			= 'h10	// core version
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	//
	input			wire	[THREADS-1:0]			intr_req_i,					// event request, active high
	//
	input			wire	[DATA_W-1:0]			io_i,							// gpio
	output		wire	[DATA_W-1:0]			io_o
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	//
	localparam	integer							ADDR_W			= 16;		// address width
	localparam	integer							PNTR_W			= 5;		// stack pointer width
	localparam	integer							MEM_ADDR_W		= 13;		// main memory width
	localparam	[ADDR_W-1:0]					CLR_BASE			= 'h0;	// clear address base (concat)
	localparam	integer							CLR_SPAN			= 2;		// clear address span (2^n)
	localparam	[ADDR_W-1:0]					INTR_BASE		= 'h20;	// interrupt address base (concat)
	localparam	integer							INTR_SPAN		= 2;		// interrupt address span (2^n)
	localparam	integer							THRD_W			= clog2( THREADS );
	localparam	integer							STACKS			= 4;		// number of stacks
	localparam	integer							STK_W				= clog2( STACKS );
	localparam	integer							IM_DATA_W		= 8;		// immediate data width
	localparam	integer							IM_ADDR_W		= 5;		// immediate address width
	localparam	integer							LG_W				= 2;
	localparam	integer							OP_CODE_W		= DATA_W/2;
	localparam	integer							REG_ADDR_W		= 4;
	localparam	integer							IM_RW_W			= 4;
	localparam	integer							POP_PROT			= 1;		// 1=error protection, 0=none
	localparam	integer							PUSH_PROT		= 1;		// 1=error protection, 0=none
	//
	wire					[THREADS-1:0]			clr_req;
	wire					[THREADS-1:0]			intr_en;
	wire					[OP_CODE_W-1:0]		op_code;
	wire												op_code_er;
	wire					[STK_W-1:0]				a_sel, b_sel;
	wire												imda, sgn, ext;
	wire					[LG_W-1:0]				lg;
	wire												add, sub, mul, shl, cpy, dm, rtn, rd, wr;
	wire												stk_clr;
	wire					[STACKS-1:0]			pop, push, pop_er, push_er;
	wire					[DATA_W-1:0]			a, b;
	wire					[IM_DATA_W-1:0]		im_data;
	wire					[IM_ADDR_W-1:0]		im_addr;
	wire												nez, ne, ltz, lt;
	wire					[THRD_W-1:0]			thrd_0, thrd_2, thrd_3, thrd_6;
	wire					[ADDR_W-1:0]			pc_1, pc_3, pc_4;
	wire					[DATA_W/2-1:0]			dm_rd_data;
	wire					[DATA_W/2-1:0]			rd_data, wr_data;
	wire					[ADDR_W-1:0]			addr;
	wire												regs_wr, regs_rd, dm_wr;


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
	.IM_DATA_W			( IM_DATA_W ),
	.IM_ADDR_W			( IM_ADDR_W ),
	.OP_CODE_W			( OP_CODE_W ),
	.LG_W					( LG_W ),
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
	.b_lo_i				( b[DATA_W/2-1:0] ),
	.im_data_o			( im_data ),
	.a_sel_o				( a_sel ),
	.b_sel_o				( b_sel ),
	.imda_o				( imda ),
	.sgn_o				( sgn ),
	.ext_o				( ext ),
	.lg_o					( lg ),
	.add_o				( add ),
	.sub_o				( sub ),
	.mul_o				( mul ),
	.shl_o				( shl ),
	.cpy_o				( cpy ),
	.dm_o					( dm ),
	.rtn_o				( rtn ),
	.rd_o					( rd ),
	.wr_o					( wr ),
	.stk_clr_o			( stk_clr ),
	.pop_o				( pop ),
	.push_o				( push ),
	.nez_i				( nez ),
	.ne_i					( ne ),
	.ltz_i				( ltz ),
	.lt_i					( lt ),
	.thrd_0_o			( thrd_0 ),
	.thrd_2_o			( thrd_2 ),
	.thrd_3_o			( thrd_3 ),
	.thrd_6_o			( thrd_6 ),
	.im_addr_o			( im_addr ),
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
	.IM_DATA_W			( IM_DATA_W ),
	.LG_W					( LG_W ),
	.POP_PROT			( POP_PROT ),
	.PUSH_PROT			( PUSH_PROT )
	)
	data_ring
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.a_sel_i				( a_sel ),
	.b_sel_i				( b_sel ),
	.imda_i				( imda ),
	.sgn_i				( sgn ),
	.ext_i				( ext ),
	.lg_i					( lg ),
	.add_i				( add ),
	.sub_i				( sub ),
	.mul_i				( mul ),
	.shl_i				( shl ),
	.cpy_i				( cpy ),
	.dm_i					( dm ),
	.rtn_i				( rtn ),
	.stk_clr_i			( stk_clr ),
	.pop_i				( pop ),
	.push_i				( push ),
	.thrd_6_i			( thrd_6 ),
	.im_data_i			( im_data ),
	.dm_data_i			( rd_data ),
	.pc_3_i				( pc_3 ),
	.a_o					( a ),
	.b_o					( b ),
	.nez_o				( nez ),
	.ne_o					( ne ),
	.ltz_o				( ltz ),
	.lt_o					( lt ),
	.pop_er_o			( pop_er ),
	.push_er_o			( push_er )
	);


	// shim for memory and register set access
	reg_set_shim
	#(
	.REGS_IN				( 1 ),
	.REGS_OUT			( 1 ),
	.DATA_W				( DATA_W ),
	.ADDR_W				( ADDR_W ),
	.REG_ADDR_W			( REG_ADDR_W ),
	.IM_ADDR_W			( IM_RW_W )
	)
	reg_set_shim
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.a_i					( a ),
	.ext_i				( ext ),
	.wr_data_o			( wr_data ),
	.b_lo_i				( b[DATA_W/2-1:0] ),
	.im_addr_i			( im_addr[IM_RW_W-1:0] ),
	.pc_1_i				( pc_1 ),
	.addr_o				( addr ),
	.wr_i					( wr ),
	.rd_i					( rd ),
	.regs_wr_o			( regs_wr ),
	.regs_rd_o			( regs_rd ),
	.dm_wr_o				( dm_wr )
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
	.VER_MIN				( VER_MIN )
	)
	reg_set
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.addr_i				( addr[REG_ADDR_W-1:0] ),
	.wr_i					( regs_wr ),
	.rd_i					( regs_rd ),
	.data_i				( wr_data ),
	.data_o				( rd_data ),
	.dm_data_i			( dm_rd_data ),
	.clr_req_o			( clr_req ),
	.intr_en_o			( intr_en ),
	.thrd_0_i			( thrd_0 ),
	.op_code_er_i		( op_code_er ),
	.thrd_2_i			( thrd_2 ),
	.pop_er_i			( pop_er ),
	.thrd_3_i			( thrd_3 ),
	.push_er_i			( push_er ),
	.io_lo_i				( io_i[DATA_W/2-1:0] ),
	.io_hi_i				( io_i[DATA_W-1:DATA_W/2] ),
	.io_lo_o				( io_o[DATA_W/2-1:0] ),
	.io_hi_o				( io_o[DATA_W-1:DATA_W/2] )
	);


	// instruction and data memory
	dp_ram_infer
	#(
	.REG_A_OUT			( 1 ),
	.REG_B_OUT			( 1 ),
	.DATA_W				( OP_CODE_W ),
	.ADDR_W				( MEM_ADDR_W ),
	.RD_MODE 			( "WR_DATA" )  // functional don't care
	)
	main_mem
	(
	.a_clk_i				( clk_i ),
	.a_addr_i			( addr ),
	.a_wr_i				( dm_wr ),
	.a_data_i			( wr_data ),
	.a_data_o			( dm_rd_data ),
	.b_clk_i				( clk_i ),
	.b_addr_i			( pc_4 ),
	.b_wr_i				( 1'b0 ),  // unused
	.b_data_i			(  ),  // unused
	.b_data_o			( op_code )
	);


endmodule
