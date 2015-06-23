/*
--------------------------------------------------------------------------------

Module : pc_ring.v

--------------------------------------------------------------------------------

Function:
- Processor PC storage ring.

Instantiates:
- (2x) vector_sr.v

Notes:
- 8 stages.
- Loop feedback, so PC interstage pipe registering forms a storage ring.

--------------------------------------------------------------------------------
*/

module pc_ring
	#(
	parameter	integer							THREADS			= 8,		// threads
	parameter	integer							THRD_W			= 2,		// thread width
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							ADDR_W			= 16,		// address width
	parameter	integer							IM_ADDR_W		= 5,		// immediate data width
	parameter	[ADDR_W-1:0]					CLR_BASE			= 'h8,	// clear address base (concat)
	parameter	integer							CLR_SPAN			= 0,		// clear address span (2^n)
	parameter	[ADDR_W-1:0]					INTR_BASE		= 'h0,	// interrupt address base (concat)
	parameter	integer							INTR_SPAN		= 0		// interrupt address span (2^n)
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// control I/O
	input			wire	[THRD_W-1:0]			thrd_0_i,					// thread
	input			wire	[THRD_W-1:0]			thrd_3_i,					// thread
	input			wire								clr_i,						// 1=pc clear
	input			wire								lit_i,						// 1 : pc=pc++ for lit
	input			wire								jmp_i,						// 1 : pc=pc+B for jump (cond)
	input			wire								gto_i,						// 1 : pc=B for goto / gosub (cond)
	input			wire								intr_i,						// 1 : pc=int
	input			wire								imad_i,						// 1=immediate address
	input			wire								tst_2_i,						// 1=true; 0=false
	// data I/O
	input			wire	[DATA_W/2-1:0]			b_lo_i,						// b_lo
	// address I/O
	input			wire	[IM_ADDR_W-1:0]		im_addr_i,					// immediate address (offset)
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
	wire					[ADDR_W-1:0]			clr_addr, intr_addr;
	wire												intr_2, gto_2, jmp_2, lit_2;
	wire												intr_3, gto_3;
	wire												tst_3;
	wire	signed		[DATA_W/2-1:0]			b_im, b_im_2, b_im_3;
	reg					[ADDR_W-1:0]			pc_1_mux, pc_3_mux, pc_4_mux;



	/*
	================
	== code start ==
	================
	*/


	// form the clear address
	assign clr_addr[ADDR_W-1:THRD_W+CLR_SPAN] = CLR_BASE[ADDR_W-1:THRD_W+CLR_SPAN];
	assign clr_addr[THRD_W+CLR_SPAN-1:0] = thrd_0_i << CLR_SPAN;

	// mux for clear, next
	always @ ( * ) begin
		casex ( { clr_i, intr_i } )
			'b00 : pc_1_mux <= pc[0] + 1'b1;  // inc for next
			'b01 : pc_1_mux <= pc[0];  // no change for int
			'b1x : pc_1_mux <= clr_addr;  // clear
		endcase
	end
	
	// decode immediate offset
	assign b_im = ( imad_i ) ? $signed( im_addr_i ) : $signed( b_lo_i );


	// in to 2 regs
	vector_sr
	#(
	.REGS			( 2 ),
	.DATA_W		( DATA_W/2+4 ),
	.RESET_VAL	( 0 )
	)
	regs_in_2
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { b_im,   intr_i, gto_i, jmp_i, lit_i } ),
	.data_o		( { b_im_2, intr_2, gto_2, jmp_2, lit_2 } )
	);


	// mux for lit, jump
	always @ ( * ) begin
		casex ( { jmp_2, lit_2 } )
			3'b00 : pc_3_mux <= pc[2];  // no change
			3'b01 : pc_3_mux <= pc[2] + 1'b1;  // inc for lit
			3'b1x : pc_3_mux <= ( tst_2_i ) ? pc[2] + b_im_2 : pc[2];  // offset for jump
		endcase
	end


	// 2 to 3 regs
	vector_sr
	#(
	.REGS			( 1 ),
	.DATA_W		( DATA_W/2+3 ),
	.RESET_VAL	( 0 )
	)
	regs_2_3
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { b_im_2, intr_2, gto_2, tst_2_i } ),
	.data_o		( { b_im_3, intr_3, gto_3, tst_3 } )
	);


	// form the interrupt address
	assign intr_addr[ADDR_W-1:THRD_W+INTR_SPAN] = INTR_BASE[ADDR_W-1:THRD_W+INTR_SPAN];
	assign intr_addr[THRD_W+INTR_SPAN-1:0] = thrd_3_i << INTR_SPAN;

	// mux for goto, gosub, interrupt
	always @ ( * ) begin
		casex ( { intr_3, gto_3 } )
			'b00 : pc_4_mux <= pc[3];  // no change
			'b01 : pc_4_mux <= ( tst_3 ) ? b_im_3 : pc[3];  // absolute goto / gosub
			'b1x : pc_4_mux <= intr_addr;  // interrupt address
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
				else if ( j == 1 ) pc[j] <= pc_1_mux;
				else if ( j == 3 ) pc[j] <= pc_3_mux;
				else if ( j == 4 ) pc[j] <= pc_4_mux;
				else pc[j] <= pc[j-1];
			end
		end
	end

	// output pc
	assign pc_0_o = pc[0];
	assign pc_1_o = pc[1];
	assign pc_2_o = pc[2];
	assign pc_3_o = pc[3];
	assign pc_4_o = pc[4];
	assign pc_5_o = pc[5];
	assign pc_6_o = pc[6];
	assign pc_7_o = pc[7];


endmodule
