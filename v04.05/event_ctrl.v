/*
--------------------------------------------------------------------------------

Module: event_ctrl.v

Function: 
- Event (clear & interrupt) controller for multi-threaded processor.

Instantiates: 
- (1x) pipe.v

Notes:
- Request is latched and acked until serviced.
- Event output is valid for the stage following this one.
- Optional req regs & resync.
- Optional req level / edge operation.
- For automatic clearing @ async reset, set RESET_VAL to 1.

--------------------------------------------------------------------------------
*/

module event_ctrl
	#(
	parameter	integer							REGS_REQ			= 2,		// input registers option
	parameter	integer							EDGE_REQ			= 0,		// edge/level input option
	parameter	integer							RESET_VAL		= 1,		// async reset value option
	parameter	integer							THREADS			= 4,		// number of threads
	parameter	integer							THRD_W			= 2		// thread width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// I/O
	input			wire		[THRD_W-1:0]		thrd_i,						// thread
	input			wire		[THREADS-1:0]		en_i,							// event enable, active high
	input			wire		[THREADS-1:0]		req_i,						// event request, active high
	output		reg		[THREADS-1:0]		ack_o,						// event ack, active high until serviced
	output		reg								event_o						// event, active high for one clock
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire			[THREADS-1:0]					req_0, req_2, thread_flag;



	/*
	================
	== code start ==
	================
	*/


	// optional input req regs
	pipe
	#(
	.DEPTH		( REGS_REQ ),
	.WIDTH		( THREADS ),
	.RESET_VAL	( 0 )
	)
	req_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( req_i ),
	.data_o		( req_0 )
	);


	// optional input req edge detect
	generate
		if ( EDGE_REQ ) begin
			reg [THREADS-1:0] req_1;
			always @ ( posedge clk_i or posedge rst_i ) begin
				if ( rst_i ) begin
					req_1 <= 'b0;
				end else begin
					req_1 <= req_0;
				end
			end
			assign req_2 = req_0 & ~req_1;
		end else begin
			assign req_2 = req_0;
		end
	endgenerate

	// decode thread flags (one hot)
	assign thread_flag = 1'b1 << thrd_i;

	// register & latch events
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			ack_o <= { THREADS{ RESET_VAL[0] } };
		end else begin
			ack_o <= ( en_i & req_2 ) | ( ack_o & ~thread_flag );
		end
	end

	// output event (use in following stage)
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			event_o <= 'b0;
		end else begin
			event_o <= |( ack_o & thread_flag );
		end
	end


endmodule
