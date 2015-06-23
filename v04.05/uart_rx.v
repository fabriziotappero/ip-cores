/*
--------------------------------------------------------------------------------

Module: uart_rx.v

Function: 
- Forms the RX side of a DATA_W,n,1 RS232 UART.

Instantiates:
- functions.h

Notes:
- Rising edge of baud_clk_i is employed.
- baud_clk_i / BAUD_OSR = uart baud (bit) rate.
- baud_clk_i must be synchronous to clk_i.
- Serial data is non-inverted; quiescent serial state is high (assumes 
  external inverting buffer).
- Bits are in this order (@ serial port of this module, line s/b inverted): 
  - 1 start bit (low), 
  - DATA_W data bits (LSB first, MSB last), 
  - 1 or more stop bits (high).
- The parallel data interface may be connected to a FIFO or similar.
- Start & stop errors, if presented, are simultaneous with the write pulse so 
  external logic can decide whether or not to accept the data.
- Start & stop errors are an indication of noise on the line / incorrect baud
  rate.
- Bad buffer error happens when external data store doesn't take RX data
  before another byte arrives.
- Parameterized data width.
- Parameterized oversampling rate.

--------------------------------------------------------------------------------
*/

module uart_rx
	#(
	parameter		integer				DATA_W				= 8,		// parallel data width (bits)
	parameter		integer				BAUD_OSR 			= 16		// BAUD oversample rate (3 or larger)
	)
	(
	// clocks & resets
	input		wire							clk_i,							// clock
	input		wire							rst_i,							// async. reset, active hi
	// timing interface
	input		wire							baud_clk_i,						// baud clock
	// parallel interface	
	output	reg	[DATA_W-1:0]		rx_data_o,						// data
	output	reg							rx_rdy_o,						// ready with data, active hi
	input		wire							rx_rd_i,							// data read, active hi
	// serial interface
	input		wire							rx_i,								// serial data
	// debug
	output	reg							rx_bad_start_o,				// bad start bit, active hi
	output	reg							rx_bad_stop_o,					// bad stop bit, active hi
	output	reg							rx_bad_buffer_o				// bad buffering, active hi
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	//
	localparam		integer				BIT_PHASE_W			= clog2( BAUD_OSR );
	localparam		integer				BIT_PHASE_MID 		= BAUD_OSR/2;
	localparam		integer				BIT_PHASE_MAX 		= BAUD_OSR-1;
	localparam		integer				BIT_COUNT_MAX 		= DATA_W+1;
	localparam		integer				BIT_COUNT_W 		= clog2( BIT_COUNT_MAX );
	//
	reg				[1:0]					rx_sr;
	reg										baud_clk_reg;
	wire										baud_flg;
	//
	reg				[BIT_PHASE_W-1:0]	bit_phase;
	wire										bit_sample_flg, bit_done_flg;
	//
	reg				[BIT_COUNT_W-1:0]	bit_count;
	wire										word_done_flg;
	//
	reg				[DATA_W+1:0]		rx_data_sr;
	//
	localparam	integer					STATE_W = 2;	// state width (bits)
	reg				[STATE_W-1:0]		state_sel, state;
	localparam		[STATE_W-1:0]
		st_idle = 0,
		st_data = 1,
		st_load = 2,
		st_wait = 3;


	/*
	================
	== code start ==
	================
	*/


	/*
	-----------
	-- input --
	-----------
	*/
	
	// register rx_i twice to resync
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			rx_sr <= 2'b11;  // note: preset!
		end else begin
			rx_sr <= { rx_sr[0], rx_i };
		end
	end

	// register to detect edges
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			baud_clk_reg <= 'b0;
		end else begin
			baud_clk_reg <= baud_clk_i;
		end
	end

	// decode rising edge
	assign baud_flg = ( ~baud_clk_reg & baud_clk_i );
	

	/*
	--------------
	-- counters --
	--------------
	*/

	// form the bit_phase & bit_count up-counters
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			bit_phase <= 'b0;
			bit_count <= 'b0;
		end else begin
			if ( state_sel != st_data ) begin
				bit_phase <= 'b0;
				bit_count <= 'b0;
			end else if ( bit_done_flg ) begin
				bit_phase <= 'b0;
				bit_count <= bit_count + 1'b1;
			end else if ( baud_flg ) begin
				bit_phase <= bit_phase + 1'b1;
			end
		end
	end

	// decode flags
	assign bit_sample_flg = ( ( bit_phase == BIT_PHASE_MID[BIT_PHASE_W-1:0] ) & baud_flg );
	assign bit_done_flg   = ( ( bit_phase == BIT_PHASE_MAX[BIT_PHASE_W-1:0] ) & baud_flg );
	assign word_done_flg  = ( ( bit_count == BIT_COUNT_MAX[BIT_COUNT_W-1:0] ) & bit_sample_flg );


	/*
	-------------------
	-- state machine --
	-------------------
	*/

	// select next state
	always @ ( * ) begin
		state_sel <= state;  // default: stay in current state
		case ( state )
			st_idle : begin  // idle
				if ( ~rx_sr[1] ) begin
					state_sel <= st_data;  // proceed
				end
			end
			st_data : begin  // data bits
				if ( word_done_flg ) begin
					state_sel <= st_load;  // load
				end
			end
			st_load, st_wait : begin
				if ( rx_sr[1] ) begin
					state_sel <= st_idle;  // done
				end else begin
					state_sel <= st_wait;  // bad stop bit
				end
			end
			default : begin  // for fault tolerance
				state_sel <= st_idle;
			end
		endcase
	end

	// register state
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			state <= st_idle;
		end else begin
			state <= state_sel;
		end
	end


	/*
	---------------------
	-- data conversion --
	---------------------
	*/
	
	// serial => parallel conversion
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			rx_data_sr <= 'b0;
		end else begin
			if ( bit_sample_flg ) begin
				rx_data_sr <= { rx_sr[1], rx_data_sr[DATA_W+1:1] };
			end
		end
	end


	/*
	------------
	-- output --
	------------
	*/

	// register outputs
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			rx_data_o <= 'b0;
			rx_rdy_o <= 'b0;
			rx_bad_start_o <= 'b0;
			rx_bad_stop_o <= 'b0;
			rx_bad_buffer_o <= 'b0;
		end else begin
			if ( state == st_load ) begin
				rx_data_o <= rx_data_sr[DATA_W:1];
				rx_rdy_o <= 'b1;
				rx_bad_start_o <= rx_data_sr[0];
				rx_bad_stop_o <= ~rx_data_sr[DATA_W+1];
				rx_bad_buffer_o <= ( ~rx_rd_i & rx_rdy_o );
			end else begin
				rx_rdy_o <= ~rx_rd_i & rx_rdy_o;
			end
		end
	end

endmodule
