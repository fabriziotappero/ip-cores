/*
--------------------------------------------------------------------------------

Module: dds_static.v

Function: 
- Forms a simple static DDS source.

Instantiates: 
- Nothing.

Notes:
- Employs phase accumulation, phase increment is multiplication factor.
- clk_o = clk_i * INC_VAL * 2^-ACCUM_W
- Output is roughly square, long-term avg of duty cycle is generally 50/50.
- For correct operation, INC_VAL < 2^(ACCUM_W-1).
    
--------------------------------------------------------------------------------
*/

module dds_static
	#(
	parameter	integer							ACCUM_W			= 8,		// phase accumulator width (bits)
	parameter	[ACCUM_W-1:0]					INC_VAL			= 8		// phase increment value
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async reset, active high
	//
	output		wire								clk_o							// output clock
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	reg					[ACCUM_W-1:0]			accum;



	/*
	================
	== code start ==
	================
	*/

	
	// accumulate
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			accum <= 'b0;
		end else begin
			accum <= accum + INC_VAL;
		end
	end

	// assign output
	assign clk_o = accum[ACCUM_W-1];
	

endmodule
