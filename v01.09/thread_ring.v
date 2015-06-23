/*
--------------------------------------------------------------------------------

Module : thread_ring.v

--------------------------------------------------------------------------------

Function:
- Processor thread pipeline.

Instantiates:
- Nothing.

Notes:
- 8 stage pipeline.
- Counter in stage 0 ensures long-term correct operation.

--------------------------------------------------------------------------------
*/

module thread_ring
	#(
	parameter	integer							THRD_W				= 3  // thread width
	)
	(
	// clocks & resets
	input			wire								clk_i,  // clock
	input			wire								rst_i,  // async. reset, active high
	// threads
	output		reg	[THRD_W-1:0]			thrd_0_o,
	output		reg	[THRD_W-1:0]			thrd_1_o,
	output		reg	[THRD_W-1:0]			thrd_2_o,
	output		reg	[THRD_W-1:0]			thrd_3_o,
	output		reg	[THRD_W-1:0]			thrd_4_o,
	output		reg	[THRD_W-1:0]			thrd_5_o,
	output		reg	[THRD_W-1:0]			thrd_6_o,
	output		reg	[THRD_W-1:0]			thrd_7_o
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/


	/*
	================
	== code start ==
	================
	*/


	// pipeline thread
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			thrd_0_o <= 'd5;
			thrd_1_o <= 'd4;
			thrd_2_o <= 'd3;
			thrd_3_o <= 'd2;
			thrd_4_o <= 'd1;
			thrd_5_o <= 'd0;
			thrd_6_o <= 'd7;
			thrd_7_o <= 'd6;
		end else begin
			thrd_0_o <= thrd_0_o + 1'b1;  // note: counter terminus
			thrd_1_o <= thrd_0_o;
			thrd_2_o <= thrd_1_o;
			thrd_3_o <= thrd_2_o;
			thrd_4_o <= thrd_3_o;
			thrd_5_o <= thrd_4_o;
			thrd_6_o <= thrd_5_o;
			thrd_7_o <= thrd_6_o;
		end
	end

	
endmodule
