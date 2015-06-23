/*
--------------------------------------------------------------------------------

Module: reg_set.v

Function: 
- Internal register set for a processor.

Instantiates: 
- (8x) reg_base.v
- (2x) pipe.v


Notes:
- Processor bus IN/OUT optionally registered.

Decode:
- 0x0 : Core version register - ver_reg
- 0x1 : Thread ID register - thrd_id_reg
- 0x2 : Clear register - clr_reg
- 0x3 : Interrupt enable register - intr_en_reg
- 0x4 : Opcode error register - op_er_reg
- 0x5 : Stack error register - stk_er_reg
- 0x6 - 0x7 : UNUSED
- 0x8 : I/O low register - io_lo_reg
- 0x9 : I/O high register - io_hi_reg
- 0xA - 0xB : UNUSED
- 0xC : UART RX register - uart_rx_reg
- 0xD : UART TX register - uart_tx_reg
- 0xE - 0xF : UNUSED


================================================================================
- 0x0 : Core version register - ver_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  ver_min[7:0]         minor version info
 15-8  ver_maj[7:0]         major version info

Notes: 
- Read-only.
- Nibbles S/B BCD (0-9; no A-F) to be easily human readable, 
  and to eliminate confusion between decimal and hex here.
- Major version changes when op_code binary decode changes (incompatibilty).

================================================================================
- 0x1 : Thread ID register - thrd_id_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  2-0  thrd_id[2:0]         thread ID
 15-3  -                    0000000000000

Notes: 
- Read-only.
- Threads can read this to discover their thread ID.

================================================================================
- 0x2 : Clear register - clr_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  clr[7:0]             0=>1 clear thread; 1=>0 no effect;
 15-8  -                    00000000

Notes:
- Read / write.
- Per thread clearing.
- All bits cleared on async reset.

================================================================================
- 0x3 : Interrupt enable register - intr_en_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  intr_en[7:0]         1=thread interrupt enable; 0=disable
 15-8  -                    00000000

Notes:
- Read / write.
- Per thread enabling of interrupts.
- All bits cleared on async reset.

================================================================================
- 0x4 : Opcode error register - op_er_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  op_er[7:0]           1=opcode error; 0=OK
 15-8  -                    00000000

Notes:
- Clear on write one.
- Per thread opcode error reporting.

================================================================================
- 0x5 : Stack error register - stk_er_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  pop_er[7:0]          1=lifo pop when empty; 0=OK
 15-8  push_er[7:0]         1=lifo push when full; 0=OK

Notes:
- Clear on write one.
- Per thread LIFO stack error reporting.

================================================================================
- 0x6 - 0x7 : UNUSED
================================================================================
- 0x8 : I/O low register - io_lo_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
 15-0  io_lo[15:0]          I/O data

Notes: 
- Separate read / write.
- Reads of io_lo_reg freeze data in io_hi_reg, so read io_lo_reg first then 
  read io_hi_reg for contiguous wide (32 bit) data reads.
- Writes function normally.

================================================================================
- 0x9 : I/O high register - io_hi_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
 15-0  io_hi[15:0]          I/O data

Notes: 
- Separate read / write.
- Reads of io_lo_reg freeze data in io_hi_reg, so read io_lo_reg first then 
  read io_hi_reg for contiguous wide (32 bit) data reads.
- Writes function normally.

================================================================================
- 0xA - 0xB : UNUSED
================================================================================
- 0xC : UART RX register - uart_rx_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  uart_rx_data[7:0]    RX UART data
    8  rx_rdy               1=RX UART ready (has new data); 0=not ready
 15-9  -                    0000000

Notes: 
- Reads from this register pop data from the RX UART.
- To avoid RX data loss, read soon after RX UART is ready.
- UART ready bit will self clear after associated register operation.

================================================================================
- 0xD : UART TX register - uart_tx_reg
--------------------------------------------------------------------------------

  bit  name                 description
-----  ----                 -----------
  7-0  uart_tx_data[7:0]    TX UART data
    8  tx_rdy               1=TX UART ready (for new data); 0=not ready
 15-9  -                    0000000

Notes: 
- Writes to this register push data to the TX UART.
- To avoid TX data loss, restrict writes to when TX UART is ready.
- UART ready bit will self clear after associated register operation.

================================================================================
- 0xE - 0xF : UNUSED
================================================================================
*/

module reg_set
	#(
	parameter	integer							REGS_IN			= 1,		// bus in register option
	parameter	integer							REGS_OUT			= 1,		// bus out register option
	parameter	integer							DATA_W			= 16,		// data width (bits)
	parameter	integer							ADDR_W			= 4,		// address width (bits)
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread selector width
	parameter	integer							STACKS			= 8,		// stacks
	parameter	integer							STK_W				= 3,		// stack selector width
	//
	parameter	[DATA_W/2-1:0]					VER_MAJ			= 'h1,	// core version
	parameter	[DATA_W/2-1:0]					VER_MIN			= 'h0,
	//
	parameter	integer							UART_DATA_W		= 8,		// uart data width (bits)
	parameter	integer							CLK_HZ	 		= 160000000,	// master clk_i rate (Hz)
	parameter	integer							UART_BAUD_RATE	= 115200	// uart baud rate (Hz)
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// bus interface
	input			wire	[ADDR_W-1:0]			addr_i,						// address
	input			wire								wr_i,							// data write enable, active high
	input			wire								rd_i,							// data read enable, active high
	input			wire	[DATA_W-1:0]			data_i,						// write data
	output		wire	[DATA_W-1:0]			data_o,						// read data
	// clear
	output		wire	[THREADS-1:0]			clr_req_o,					// clr request, active high
	// interrupt
	output		wire	[THREADS-1:0]			intr_en_o,					// interrupt enable, active high
	// errors
	input			wire	[THRD_W-1:0]			thrd_0_i,					// thread
	input			wire								op_code_er_i,				// 1=illegal op code encountered
	input			wire	[THRD_W-1:0]			thrd_2_i,					// thread
	input			wire	[STACKS-1:0]			pop_er_2_i,					// pop when empty, active high 
	input			wire	[THRD_W-1:0]			thrd_3_i,					// thread
	input			wire	[STACKS-1:0]			push_er_3_i,				// push when full, active high
	// I/O
	input			wire	[DATA_W-1:0]			io_lo_i,						// gpio linked to io_hi_i
	input			wire	[DATA_W-1:0]			io_hi_i,
	output		wire	[DATA_W-1:0]			io_lo_o,						// unlinked gpio
	output		wire	[DATA_W-1:0]			io_hi_o,
	// serial interface
	input			wire								uart_rx_i,					// serial data
	output		wire								uart_tx_o					// serial data
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "reg_set_addr.h"
	//
	wire					[ADDR_W-1:0]			addr;
	wire												reg_en, wr, rd;
	wire					[DATA_W-1:0]			rd_data, wr_data, reg_rd_data;
	wire					[DATA_W-1:0]			ver_rd_data,
														thrd_id_rd_data,
														clr_rd_data,
														intr_en_rd_data,
														op_er_rd_data,
														stk_er_data,
														io_lo_rd_data,
														io_hi_rd_data,
														uart_rx_rd_data,
														uart_tx_rd_data;
	//
	wire												io_lo_reg_rd;
	wire					[THREADS-1:0]			op_code_errors, push_errors, pop_errors;
	wire					[UART_DATA_W-1:0]		uart_tx_data, uart_rx_data;
	wire												uart_tx_rdy, uart_rx_rdy;
	wire												uart_tx_wr, uart_rx_rd;



	/*
	================
	== code start ==
	================
	*/



	// optional bus input regs
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( 2+ADDR_W+DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { wr_i, rd_i, addr_i, data_i } ),
	.data_o		( { wr,   rd,   addr,   wr_data } )
	);


	// big ORing of read data
	assign rd_data = 
		ver_rd_data | 
		thrd_id_rd_data | 
		clr_rd_data | 
		intr_en_rd_data |
		op_er_rd_data |
		stk_er_data |
		io_lo_rd_data |
		io_hi_rd_data |
		uart_rx_rd_data |
		uart_tx_rd_data;


	// optional output regs
	pipe
	#(
	.DEPTH		( REGS_OUT ),
	.WIDTH		( DATA_W ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( rd_data ),
	.data_o		( data_o )
	);


	
	/*
	-------------
	-- ver_reg --
	-------------
	*/

	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( VER_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "ZERO" ),
	.READ_MODE		( "THRU" )
	)
	ver_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( ver_rd_data ),
	.reg_data_i		( { VER_MAJ, VER_MIN } )
	);


	/*
	-----------------
	-- thrd_id_reg --
	-----------------
	*/

	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( THRD_ID_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "ZERO" ),
	.READ_MODE		( "THRU" ),
	.LIVE_MASK		( { THRD_W{ 1'b1 } } )
	)
	thrd_id_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( thrd_id_rd_data ),
	.reg_data_i		( thrd_3_i )
	);


	/*
	-------------
	-- clr_reg --
	-------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( CLR_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "LTCH" ),
	.READ_MODE		( "LOOP" ),
	.LIVE_MASK		( { THREADS{ 1'b1 } } )
	)
	clr_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( clr_rd_data ),
	.reg_data_o		( clr_req_o )
	);

	
	/*
	-----------------
	-- intr_en_reg --
	-----------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( INTR_EN_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "LTCH" ),
	.READ_MODE		( "LOOP" ),
	.LIVE_MASK		( { THREADS{ 1'b1 } } )
	)
	intr_en_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( intr_en_rd_data ),
	.reg_data_o		( intr_en_o )
	);
	

	/*
	---------------
	-- op_er_reg --
	---------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( OP_ER_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "ZERO" ),
	.READ_MODE		( "COW1" ),
	.LIVE_MASK		( { THREADS{ 1'b1 } } )
	)
	op_er_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( op_er_rd_data ),
	.reg_data_i		( op_code_errors )
	);

	// decode errors
	assign op_code_errors = op_code_er_i << thrd_0_i;


	/*
	----------------
	-- stk_er_reg --
	----------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( STK_ER_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "ZERO" ),
	.READ_MODE		( "COW1" ),
	.LIVE_MASK		( { (THREADS+THREADS){ 1'b1 } } )
	)
	stk_er_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( stk_er_data ),
	.reg_data_i		( { push_errors, pop_errors } )
	);

	// decode errors
	assign push_errors = |push_er_3_i << thrd_3_i;
	assign pop_errors = |pop_er_2_i << thrd_2_i;

	
	/*
	---------------
	-- io_lo_reg --
	---------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( IO_LO_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "LTCH" ),
	.READ_MODE		( "THRU" )
	)
	io_lo_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( io_lo_rd_data ),
	.reg_rd_o		( io_lo_reg_rd ),
	.reg_data_i		( io_lo_i ),
	.reg_data_o		( io_lo_o )
	);


	/*
	---------------
	-- io_hi_reg --
	---------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( IO_HI_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "LTCH" ),
	.READ_MODE		( "DFFE" )
	)
	io_hi_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( io_hi_rd_data ),
	.reg_en_i		( io_lo_reg_rd ),  // enable on lo read
	.reg_data_i		( io_hi_i ),
	.reg_data_o		( io_hi_o )
	);


	/*
	-----------------
	-- uart_rx_reg --
	-----------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( UART_RX_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "ZERO" ),
	.READ_MODE		( "THRU" ),
	.LIVE_MASK		( { 1+UART_DATA_W{ 1'b1 } } )
	)
	uart_rx_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( uart_rx_rd_data ),
	.reg_rd_o		( uart_rx_rd ),
	.reg_data_i		( { uart_rx_rdy, uart_rx_data } ),
	.reg_data_o		(  )
	);


	/*
	-----------------
	-- uart_tx_reg --
	-----------------
	*/
	reg_base
	#(
	.DATA_W			( DATA_W ),
	.ADDR_W			( ADDR_W ),
	.ADDRESS			( UART_TX_ADDR[ADDR_W-1:0] ),
	.OUT_MODE		( "THRU" ),
	.READ_MODE		( "THRU" ),
	.LIVE_MASK		( { 1+UART_DATA_W{ 1'b1 } } )
	)
	uart_tx_reg
	(
	.clk_i			( clk_i ),
	.rst_i			( rst_i ),
	.addr_i			( addr ),
	.wr_i				( wr ),
	.rd_i				( rd ),
	.wr_data_i		( wr_data ),
	.rd_data_o		( uart_tx_rd_data ),
	.reg_wr_o		( uart_tx_wr ),
	.reg_data_i		( { uart_tx_rdy, { UART_DATA_W{ 1'b0 } } } ),
	.reg_data_o		( uart_tx_data )
	);


	uart_core
	#(
	.CLK_HZ	 			( CLK_HZ ),
	.BAUD_RATE	 		( UART_BAUD_RATE ),
	.DATA_W				( UART_DATA_W )
	)
	uart_core_inst
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.tx_data_i			( uart_tx_data ),
	.tx_rdy_o			( uart_tx_rdy ),
	.tx_wr_i				( uart_tx_wr ),
	.rx_data_o			( uart_rx_data ),
	.rx_rdy_o			( uart_rx_rdy ),
	.rx_rd_i				( uart_rx_rd ),
	.tx_o					( uart_tx_o ),
	.rx_i					( uart_rx_i ),
	.loop_i				( 1'b0 ),  // unused
	.rx_error_o			(  ),  // unused
	.rx_bad_buffer_o	(  ),  // unused
	.baud_clk_o			(  )  // unused
	);


endmodule
