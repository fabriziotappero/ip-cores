/*
--------------------------------------------------------------------------------

Module: uart_core.v

Function: 
- TX/RX DATA_W,n,1 RS232 UART.

Instantiates:
- (1x) dds_static.v
- (1x) uart_tx.v
- (1x) uart_rx.v

Notes:
- See individual components for details.
- Serial loopback does not disconnect serial TX interface.
- Baud rate is fixed, baud clock is calculated from the input parameters.
- Common baud rates are 2400, 3600, and 2x multiples of these:
  - 2400, 4800, 9600, 19200, 38400, 76800, 153600
  - 3600, 7200, 14400, 28800, 57600, 115200

--------------------------------------------------------------------------------
*/

module uart_core
	#(
	parameter		integer				CLK_HZ	 			= 160000000,	// clk_i rate (Hz)
	parameter		integer				BAUD_RATE	 		= 115200,	// baud rate (Hz)
	parameter		integer				DATA_W				= 8		// parallel data width (bits)
	)
	(
	// clocks & resets
	input		wire							clk_i,							// clock
	input		wire							rst_i,							// async. reset, active hi
	// parallel interface	
	input		wire	[DATA_W-1:0]		tx_data_i,						// data
	output	wire							tx_rdy_o,						// ready for data, active hi
	input		wire							tx_wr_i,							// data write, active high
	//
	output	wire	[DATA_W-1:0]		rx_data_o,						// data
	output	wire							rx_rdy_o,						// ready with data, active hi
	input		wire							rx_rd_i,							// data read, active hi
	// serial interface
	output	wire							tx_o,								// serial data
	input		wire							rx_i,								// serial data
	// debug
	input		wire							loop_i,							// serial loopback enable, active hi
	output	wire							rx_error_o,						// 1=bad start/stop bit; 0=OK
	output	wire							rx_bad_buffer_o,				// bad rx buffering, active hi
	output	wire							baud_clk_o						// baud clock
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/	
	`include "functions.h"  // for clog2()
	//
	localparam		integer				STOP_BITS 			= 1;		// Number of stop bits (1 or larger)
	localparam		integer				BAUD_OSR 			= 16;		// baud oversample rate (3 or larger)
	//
	// calculations to set DDS parameters
	//
	localparam		integer				INC_W					= 8;  // sets maximum error
	localparam		real					BAUD_HZ				= BAUD_RATE*BAUD_OSR;
	localparam		real					N						= CLK_HZ/BAUD_HZ;
	localparam		integer				ACCUM_W				= clog2(N)+INC_W-1;
	localparam		integer				INC_VAL				= (2**ACCUM_W)/N;
	//
	wire										rx_bad_start, rx_bad_stop;


	
	/*
	================
	== code start ==
	================
	*/


	dds_static
	#(
	.ACCUM_W				( ACCUM_W ),
	.INC_VAL				( INC_VAL )
	)
	dds_static_inst
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.clk_o				( baud_clk_o )
	);


	uart_tx
	#(
	.DATA_W				( DATA_W ),
	.BAUD_OSR 			( BAUD_OSR ),
	.STOP_BITS			( STOP_BITS )
	)
	uart_tx_inst
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.baud_clk_i			( baud_clk_o ),
	.tx_data_i			( tx_data_i ),
	.tx_rdy_o			( tx_rdy_o ),
	.tx_wr_i				( tx_wr_i ),
	.tx_o					( tx_o )
	);


	uart_rx
	#(
	.DATA_W				( DATA_W ),
	.BAUD_OSR 			( BAUD_OSR )
	)
	uart_rx_inst
	(
	.clk_i				( clk_i ),
	.rst_i				( rst_i ),
	.baud_clk_i			( baud_clk_o ),
	.rx_data_o			( rx_data_o ),
	.rx_rdy_o			( rx_rdy_o ),
	.rx_rd_i				( rx_rd_i ),
	.rx_i					( loop_i ? tx_o : rx_i ),
	.rx_bad_start_o	( rx_bad_start ),
	.rx_bad_stop_o		( rx_bad_stop ),
	.rx_bad_buffer_o	( rx_bad_buffer_o )
	);

	
	// combine errors
	assign rx_error_o = ( rx_bad_start | rx_bad_stop );

	
endmodule
