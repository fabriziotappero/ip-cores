/*
--------------------------------------------------------------------------------

Module : pointer_ring.v

--------------------------------------------------------------------------------

Function:
- Processor stack pointer storage ring.

Instantiates:
- (1x) pipe.v

Notes:
- 8 stage pointer storage ring for 8 BRAM based LIFOs:
  0 : clear applied (& all inputs)
  1 : pop applied
  2 : push applied; pop errors output
  3 : push errors output
  6 : pointers & writes output
- Logic assumes pop | push will not be issued simultaneously with clear.
- Externally concatenate thread 6 & pointers to form stack memory addresses.
- Level width is PTR_W+1 to accomodate 0 to 2^n levels (1 + 2n states).
- Empty push is to address 1, full push is to address 0.
- Combo pop/push is accomodated with no net fullness/pointer change.
- Pop when empty is a pop error.
- Push when full is a push error.
- Pop/push when full is NOT an error.
- Pop/push when empty is a pop error ONLY.
- Parameterized stack error handling.  If the associated protection is turned on 
  then pop/push errors are reported but otherwise not acted upon, i.e. errors 
  will not corrupt fullness/pointers.  If the associated protection is turned 
  off then errors are still reported, but fullness/pointers will be corrupted.

--------------------------------------------------------------------------------
*/

module pointer_ring
	#(
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							STACKS			= 8,		// stacks
	parameter	integer							PNTR_W			= 5,		// stack pointer width
	parameter	integer							PROT_POP			= 1,		// 1=error protection, 0=none
	parameter	integer							PROT_PUSH		= 1		// 1=error protection, 0=none
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire								clr_i,						// stacks clear
	input			wire	[STACKS-1:0]			pop_i,						// stacks pop
	input			wire	[STACKS-1:0]			push_i,						// stacks push
	// pointers
	output		wire	[PNTR_W-1:0]			pntr0_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr1_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr2_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr3_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr4_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr5_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr6_6_o,					// stack pointer
	output		wire	[PNTR_W-1:0]			pntr7_6_o,					// stack pointer
	// write enables
	output		wire	[STACKS-1:0]			wr_6_o,						// write enables
	// errors
	output		wire	[STACKS-1:0]			pop_er_2_o,					// pop when empty, active high 
	output		wire	[STACKS-1:0]			push_er_3_o					// push when full, active high
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam	integer							LEVEL_W			= PNTR_W+1;  // +1 extra bit
	localparam	[LEVEL_W-1:0]					EMPTY_VAL		= 'b0;  // empty value
	localparam	[LEVEL_W-1:0]					FULL_VAL			= 1'b1 << PNTR_W;  // full value
	//
	integer											s, t;
	//
	reg					[LEVEL_W-1:0]			level[0:STACKS-1][0:THREADS-1];
	//
	reg					[STACKS-1:0]			pop_1, push_1, push_2;
	reg					[STACKS-1:0]			empty_1, full_2;
	wire					[STACKS-1:0]			dec_1, inc_2;
	wire					[STACKS-1:0]			pop_er_1, push_er_2;


	/*
	================
	== code start ==
	================
	*/


	// pipeline control signals
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			pop_1 <= 'b0;
			push_1 <= 'b0;
			push_2 <= 'b0;
		end else begin
			pop_1 <= pop_i;
			push_1 <= push_i;
			push_2 <= push_1;
		end
	end

	// decode watermarks
	always @ ( * ) begin
		for ( s=0; s<STACKS; s=s+1 ) begin
			empty_1[s] <= ( level[s][1] == EMPTY_VAL );
			full_2[s] <= ( level[s][2] == FULL_VAL );
		end
	end
	
	// prohibit pointer changes @ errors if configured to do so
	assign dec_1 = ( PROT_POP ) ? pop_1 & ~empty_1 : pop_1;
	assign inc_2 = ( PROT_PUSH ) ? push_2 & ~full_2 : push_2;

	// decode errors - pop when empty, push when full
	assign pop_er_1 = pop_1 & empty_1;
	assign push_er_2 = push_2 & full_2;

	// decode & pipeline levels
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			for ( s=0; s<STACKS; s=s+1 ) begin 
				for ( t=0; t<THREADS; t=t+1 ) begin 
					level[s][t] <= 'b0;
				end
			end
		end else begin
			for ( s=0; s<STACKS; s=s+1 ) begin 
				for ( t=0; t<THREADS; t=t+1 ) begin 
					if ( t == 0 ) level[s][t] <= level[s][THREADS-1];  // wrap around
					else if ( t == 1 ) level[s][t] <= ( clr_i ) ? 1'b0 : level[s][t-1];  // clear
					else if ( t == 2 ) level[s][t] <= ( dec_1[s] ) ? level[s][t-1] - 1'b1 : level[s][t-1];  // pop
					else if ( t == 3 ) level[s][t] <= ( inc_2[s] ) ? level[s][t-1] + 1'b1 : level[s][t-1];  // push
					else level[s][t] <= level[s][t-1];
				end
			end
		end
	end


	// decode & pipeline write enables
	pipe
	#(
	.DEPTH		( 4 ),
	.WIDTH		( STACKS ),
	.RESET_VAL	( 0 )
	)
	wr_pipe
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( inc_2 ),
	.data_o		( wr_6_o )
	);


	// register output errors
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( STACKS+STACKS ),
	.RESET_VAL	( 0 )
	)
	reg_errors
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { pop_er_1,   push_er_2   } ),
	.data_o		( { pop_er_2_o, push_er_3_o } )
	);


	// output pointers
	assign pntr0_6_o = level[0][6][PNTR_W-1:0];
	assign pntr1_6_o = level[1][6][PNTR_W-1:0];
	assign pntr2_6_o = level[2][6][PNTR_W-1:0];
	assign pntr3_6_o = level[3][6][PNTR_W-1:0];
	assign pntr4_6_o = level[4][6][PNTR_W-1:0];
	assign pntr5_6_o = level[5][6][PNTR_W-1:0];
	assign pntr6_6_o = level[6][6][PNTR_W-1:0];
	assign pntr7_6_o = level[7][6][PNTR_W-1:0];

	
endmodule
