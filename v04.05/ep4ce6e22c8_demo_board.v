/*
--------------------------------------------------------------------------------

Module : ep4ce6e22c8_demo_board.v

--------------------------------------------------------------------------------

Function:
- Processor core with PLL & LED outputs.

Instantiates:
- hive_core.v
- pll.v

Notes:


--------------------------------------------------------------------------------
*/

module ep4ce6e22c8_demo_board
	#(
	parameter	integer							LED_W			= 4
	)
	(
	// clocks & resets
	input			wire								clk_50m_i,					// clock
	input			wire								rstn_i,						// async. reset, active low
	//
	output		wire	[LED_W-1:0]				led_o							// LEDs, active low
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire					[31:0]					io_o;
	wire												clk_pll;


	/*
	================
	== code start ==
	================
	*/


	pll	pll_inst (
	.inclk0				( clk_50m_i ),
	.c0					( clk_pll )
	);

	
	hive_core hive_core_inst
	(
	.clk_i				( clk_pll ),
	.rst_i				( ~rstn_i ),
	.intr_req_i			(  ),  // unused
	.io_i					(  ),  // unused
	.io_o					( io_o )
	);

	
	// the LEDs are active low
	assign led_o = ~io_o[3:0];


endmodule
