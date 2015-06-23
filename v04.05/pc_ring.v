/*
--------------------------------------------------------------------------------

Module : pc_ring.v

--------------------------------------------------------------------------------

Function:
- Processor PC storage ring.

Instantiates:
- (2x) pipe.v

Notes:
- 8 stages.
- Loop feedback, so PC interstage pipe registering forms a storage ring.

--------------------------------------------------------------------------------
*/

module pc_ring
	#(
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 3,		// thread width
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
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
	input			wire	[THRD_W-1:0]			thrd_0_i,					// thread
	input			wire	[THRD_W-1:0]			thrd_4_i,					// thread
	input			wire								clr_i,						// 1=pc clear
	input			wire								lit_i,						// 1 : pc=pc++ for literal data
	input			wire								jmp_i,						// 1 : pc=pc+B|I for jump (cond)
	input			wire								gto_i,						// 1 : pc=B for goto | gosub (cond)
	input			wire								intr_i,						// 1 : pc=int
	input			wire								res_tst_3_i,				// 1=true (or disabled); 0=false
	// address I/O
	input			wire	[ADDR_W-1:0]			b_addr_i,					// b | im
	output		wire	[ADDR_W-1:0]			pc_0_o,
	output		wire	[ADDR_W-1:0]			pc_1_o,
	output		wire	[ADDR_W-1:0]			pc_2_o,
	output		wire	[ADDR_W-1:0]			pc_3_o,
	output		wire	[ADDR_W-1:0]			pc_4_o,
	output		wire	[ADDR_W-1:0]			pc_5_o,
	output		wire	[ADDR_W-1:0]			pc_6_o,
	output		wire	[ADDR_W-1:0]			pc_7_o
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	reg					[ADDR_W-1:0]			pc[0:THREADS-1];
	//
	wire					[ADDR_W-1:0]			clr_addr_0, intr_addr_4;
	wire												intr_2, gto_2, jmp_2, lit_2;
	wire												intr_3, gto_3, jmp_3;
	wire												intr_4;
	wire	signed		[ADDR_W-1:0]			b_addr_2, b_addr_3;
	reg					[ADDR_W-1:0]			mux_0, mux_2, mux_3, mux_4;


	/*
	================
	== code start ==
	================
	*/

	// form the clear address
	assign clr_addr_0[ADDR_W-1:THRD_W+CLR_SPAN] = CLR_BASE[ADDR_W-1:THRD_W+CLR_SPAN];
	assign clr_addr_0[THRD_W+CLR_SPAN-1:0] = thrd_0_i << CLR_SPAN;

	// mux for clear, next instruction
	always @ ( * ) begin
		casex ( { clr_i, intr_i } )
			'b01    : mux_0 <= pc[0];  // no change for int
			'b1x    : mux_0 <= clr_addr_0;  // clear
			default : mux_0 <= pc[0] + 1'b1;  // inc for next
		endcase
	end
	

	// 0 to 2 regs
	pipe
	#(
	.DEPTH		( 2 ),
	.WIDTH		( 4+ADDR_W ),
	.RESET_VAL	( 0 )
	)
	regs_0_2
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { lit_i, jmp_i, gto_i, intr_i, b_addr_i } ),
	.data_o		( { lit_2, jmp_2, gto_2, intr_2, b_addr_2 } )
	);


	// mux for literal data
	always @ ( * ) begin
		casex ( lit_2 )
			'b1     : mux_2 <= pc[2] + 1'b1;  // literal data
			default : mux_2 <= pc[2];  // no change
		endcase
	end


	// 2 to 3 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 3+ADDR_W ),
	.RESET_VAL	( 0 )
	)
	regs_2_3
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { jmp_2, gto_2, intr_2, b_addr_2 } ),
	.data_o		( { jmp_3, gto_3, intr_3, b_addr_3 } )
	);


	// mux for jmp, gto, gsb
	always @ ( * ) begin
		casex ( { res_tst_3_i, gto_3, jmp_3 } )
			'b101   : mux_3 <= pc[3] + b_addr_3;  // jmp | jmp_i
			'b11x   : mux_3 <= b_addr_3;  // gto | gsb
			default : mux_3 <= pc[3];  // no change
		endcase
	end


	// 3 to 4 regs
	pipe
	#(
	.DEPTH		( 1 ),
	.WIDTH		( 1 ),
	.RESET_VAL	( 0 )
	)
	regs_3_4
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( intr_3 ),
	.data_o		( intr_4 )
	);


	// form the interrupt address
	assign intr_addr_4[ADDR_W-1:THRD_W+INTR_SPAN] = INTR_BASE[ADDR_W-1:THRD_W+INTR_SPAN];
	assign intr_addr_4[THRD_W+INTR_SPAN-1:0] = thrd_4_i << INTR_SPAN;

	// mux for interrupt
	always @ ( * ) begin
		casex ( intr_4 )
			'b1     : mux_4 <= intr_addr_4;  // interrupt
			default : mux_4 <= pc[4];  // no change
		endcase
	end

	// pc storage ring
	integer j;
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			for ( j = 0; j < THREADS; j = j + 1 ) begin 
				pc[j] <= 'b0;
			end
		end else begin
			for ( j = 0; j < THREADS; j = j + 1 ) begin 
				if ( j == 0 ) pc[j] <= pc[THREADS-1];  // wrap around
				else if ( j == 1 ) pc[j] <= mux_0;
				else if ( j == 3 ) pc[j] <= mux_2;
				else if ( j == 4 ) pc[j] <= mux_3;
				else if ( j == 5 ) pc[j] <= mux_4;
				else pc[j] <= pc[j-1];
			end
		end
	end

	// output pc
	assign pc_0_o = pc[0];
	assign pc_1_o = pc[1];
	assign pc_2_o = pc[2];
	assign pc_3_o = pc[3];
	assign pc_4_o = mux_4;  // note: async!
	assign pc_5_o = pc[5];
	assign pc_6_o = pc[6];
	assign pc_7_o = pc[7];


endmodule
