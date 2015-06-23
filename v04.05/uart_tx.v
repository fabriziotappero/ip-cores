/*
--------------------------------------------------------------------------------

Module: uart_tx.v

Function: 
- Forms the TX side of a DATA_W,n,STOP_BITS RS232 UART.

Instantiates:
- functions.h

Notes:
- Rising edge of baud_clk_i is employed.
- baud_clk_i / BAUD_OSR = uart baud (bit) rate.
- baud_clk_i mist be synchronous to clk_i.
- Serial data is non-inverted; quiescent serial state is high (assumes 
  external inverting buffer).
- Bits are in this order (@ serial port of this module, line s/b inverted): 
  - 1 start bit (low), 
  - DATA_W data bits (LSB first, MSB last), 
  - 1 or more stop bits (high).
- The parallel data interface may be connected to a FIFO or similar.
- Parameterized data width.
- Parameterized oversampling rate.
- Parameterized stop bits.

--------------------------------------------------------------------------------
*/

module uart_tx
	#(
	parameter		integer				DATA_W				= 8,		// parallel data width (bits)
	parameter		integer				BAUD_OSR 			= 16,		// BAUD clock oversample rate (3 or larger)
	parameter		integer				STOP_BITS 			= 1		// number of stop bits
	)
	(
	// clocks & resets
	input		wire							clk_i,							// clock
	input		wire							rst_i,							// async. reset, active hi
	// timing interface
	input		wire							baud_clk_i,						// baud clock
	// parallel interface	
	input		wire	[DATA_W-1:0]		tx_data_i,						// data
	output	reg							tx_rdy_o,						// ready for data, active hi
	input		wire							tx_wr_i,							// data write, active high
	// serial interface
	output	wire							tx_o								// serial data
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "functions.h"  // for clog2()
	//
	localparam		integer				BIT_PHASE_W			= clog2( BAUD_OSR );
	localparam		integer				BIT_PHASE_MAX 		= BAUD_OSR-1;
	localparam		integer				BIT_COUNT_MAX 		= DATA_W+STOP_BITS;
	localparam		integer				BIT_COUNT_W 		= clog2( BIT_COUNT_MAX );
	//
	reg										baud_clk_reg;
	wire										baud_flg;
	reg				[DATA_W-1:0]		tx_data_reg;
	//
	reg				[BIT_PHASE_W-1:0]	bit_phase;
	wire										bit_done_flg;
	//
	reg				[BIT_COUNT_W-1:0]	bit_count;
	wire										word_done_flg;
	//
	reg				[DATA_W:0]			tx_data_sr;
	wire										load_flg;
	//
	localparam	integer					STATE_W = 2;	// state width (bits)
	reg				[STATE_W-1:0]		state_sel, state;
	localparam		[STATE_W-1:0]
		st_idle = 0,
		st_wait = 1,
		st_load = 2,
		st_data = 3;


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
	
	// register parallel data
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			tx_data_reg <= 'b0;
			tx_rdy_o <= 'b1;
		end else begin
			if ( tx_wr_i ) begin
				tx_data_reg <= tx_data_i;
				tx_rdy_o <= 'b0;
			end else if ( load_flg ) begin
				tx_rdy_o <= 'b1;
			end
		end
	end


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
	assign bit_done_flg   = ( ( bit_phase == BIT_PHASE_MAX[BIT_PHASE_W-1:0] ) & baud_flg );
	assign word_done_flg  = ( ( bit_count == BIT_COUNT_MAX[BIT_COUNT_W-1:0] ) & bit_done_flg );


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
				if ( ~tx_rdy_o ) begin
					state_sel <= st_wait;  // proceed
				end
			end
			st_wait : begin  // wait for baud sync
				if ( baud_flg ) begin
					state_sel <= st_load;  // proceed
				end
			end
			st_load : begin  // load
				state_sel <= st_data;  // proceed
			end
			st_data : begin  // data bits
				if ( word_done_flg ) begin
					if ( ~tx_rdy_o ) begin
						state_sel <= st_load;  // do again
					end else begin
						state_sel <= st_idle;  // done
					end
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
	
	// decode flags
	assign load_flg = ( state_sel == st_load );


	/*
	---------------------
	-- data conversion --
	---------------------
	*/
	
	// parallel => serial conversion
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			tx_data_sr <= { (DATA_W+1){1'b1} };
		end else begin
			if ( load_flg ) begin
				tx_data_sr <= { tx_data_reg, 1'b0 };
			end else if ( bit_done_flg ) begin
				tx_data_sr <= { 1'b1, tx_data_sr[DATA_W:1] };
			end
		end
	end


	/*
	------------
	-- output --
	------------
	*/

	// outputs
	assign tx_o = tx_data_sr[0];


endmodule
