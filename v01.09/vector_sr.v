/*
--------------------------------------------------------------------------------

Module: vector_sr.v

Function: 
- Vector I/O shift register.

Instantiates: 
- Nothing.

Notes:
- Parameters for regs depth, data width, and async reset value.
- REGS=0 generates a wire.

--------------------------------------------------------------------------------
*/


module vector_sr
	#(
	parameter	integer					REGS					= 4,			// number of registers
	parameter	integer					DATA_W				= 2,			// I/O data width
	parameter	[DATA_W-1:0]			RESET_VAL			= 0			// regs async reset value
	)
	(
	// clocks & resets
	input		wire							clk_i,								// clock
	input		wire							rst_i,								// async. reset, active high
	// I/O
	input		wire	[DATA_W-1:0]		data_i,								// data in
	output	wire	[DATA_W-1:0]		data_o								// data out
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	genvar									i;


	/*
	================
	== code start ==
	================
	*/


	// generate regs pipeline
	generate
		if ( REGS == 0 ) begin
			assign data_o = data_i;
		end else begin
			reg [DATA_W-1:0] stage[0:REGS-1];
			for ( i=0; i<REGS; i=i+1 ) begin : loop
				always @ ( posedge clk_i or posedge rst_i ) begin
					if ( rst_i ) begin
						stage[i] <= RESET_VAL;
					end else begin
						stage[i] <= ( i == REGS-1 ) ? data_i : stage[i+1];
					end
				end
			end  // endfor : loop
			assign data_o = stage[0];
		end
	endgenerate


endmodule
