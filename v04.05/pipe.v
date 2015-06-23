/*
--------------------------------------------------------------------------------

Module: pipe.v

Function: 
- Vector I/O shift register.

Instantiates: 
- Nothing.

Notes:
- Parameters for depth (register stages), data width, and async reset value.
- DEPTH=0 generates a wire.

--------------------------------------------------------------------------------
*/


module pipe
	#(
	parameter	integer					DEPTH					= 4,			// register stages
	parameter	integer					WIDTH					= 2,			// I/O data width
	parameter	[WIDTH-1:0]				RESET_VAL			= 0			// regs async reset value
	)
	(
	// clocks & resets
	input		wire							clk_i,								// clock
	input		wire							rst_i,								// async. reset, active high
	// I/O
	input		wire	[WIDTH-1:0]			data_i,								// data in
	output	wire	[WIDTH-1:0]			data_o								// data out
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
		if ( DEPTH == 0 ) begin
			assign data_o = data_i;
		end else begin
			reg [WIDTH-1:0] stage[0:DEPTH-1];
			for ( i=0; i<DEPTH; i=i+1 ) begin : loop
				always @ ( posedge clk_i or posedge rst_i ) begin
					if ( rst_i ) begin
						stage[i] <= RESET_VAL;
					end else begin
						stage[i] <= ( i == DEPTH-1 ) ? data_i : stage[i+1];
					end
				end
			end  // endfor : loop
			assign data_o = stage[0];
		end
	endgenerate


endmodule
