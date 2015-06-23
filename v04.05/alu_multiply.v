/*
--------------------------------------------------------------------------------

Module : alu_multiply

--------------------------------------------------------------------------------

Function:
- Signed multiply unit for a processor ALU.

Instantiates:
- (1x) pipe.v (debug mode only)

Notes:
- 3 stage 4 register pipeline.
- Multiply stage I/O registers are likely free (part of multiplier fabric).
- Debug mode for comparison to native signed multiplication, only use for 
  simulation / verification as it consumes resources and negatively impacts 
  top speed. 

--------------------------------------------------------------------------------
*/

module alu_multiply
	#(
	parameter	integer							DATA_W			= 33,		// data width
	parameter	integer							DEBUG_MODE		= 0		// 1=debug mode; 0=normal mode
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// data I/O
	input			wire	[DATA_W-1:0]			a_i,							// operand
	input			wire	[DATA_W-1:0]			b_i,							// operand
	output		reg	[DATA_W*2-1:0]			result_o,					// = ( a_i * b_i )
	// debug
	output		wire								debug_o						// 1=bad match
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam	integer							HI_W				= DATA_W/2;		// 16
	localparam	integer							LO_W				= DATA_W-HI_W;	// 17
	localparam	integer							MULT_W			= LO_W*2;		// 34
	localparam	integer							DBL_W				= DATA_W*2;		// 66
	//
	reg	signed		[DATA_W-1:0]			a, b;
	wire	signed		[HI_W-1:0]				a_hi, b_hi;
	wire	signed		[LO_W:0]					a_lo_ze, b_lo_ze;  // 35 (extra zero MSB)
	reg	signed		[MULT_W-1:0]			mult_hi_hi, mult_hi_lo, mult_lo_hi, mult_lo_lo;
	reg	signed		[DBL_W-1:0]				inner_sum, outer_cat;


	/*
	================
	== code start ==
	================
	*/


	// input registering (likely free)
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			a <= 'b0;
			b <= 'b0;
		end else begin
			a <= a_i;
			b <= b_i;
		end
	end
	
	// select & extend inputs
	assign a_hi = a[DATA_W-1:LO_W];
	assign b_hi = b[DATA_W-1:LO_W];
	assign a_lo_ze = { 1'b0, a[LO_W-1:0] };
	assign b_lo_ze = { 1'b0, b[LO_W-1:0] };

	// do all multiplies & register (registers are likely free)
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			mult_hi_hi <= 'b0;
			mult_hi_lo <= 'b0;
			mult_lo_hi <= 'b0;
			mult_lo_lo <= 'b0;
		end else begin
			mult_hi_hi <= a_hi * b_hi;
			mult_hi_lo <= a_hi * b_lo_ze;
			mult_lo_hi <= a_lo_ze * b_hi;
			mult_lo_lo <= a_lo_ze * b_lo_ze;
		end
	end

	// add and shift inner terms, concatenate outer terms, register
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			inner_sum <= 'b0;
			outer_cat <= 'b0;
		end else begin
			inner_sum <= ( mult_hi_lo + mult_lo_hi ) << LO_W;
			outer_cat <= { mult_hi_hi[HI_W*2-1:0], mult_lo_lo };
		end
	end

	// final add & register
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			result_o <= 'b0;
		end else begin
			result_o <= outer_cat + inner_sum;
		end
	end


	// optional debug mode
	generate
		if ( DEBUG_MODE ) begin
			wire signed [DBL_W-1:0] debug_mult, debug_mult_r;
			reg debug;
			assign debug_mult = a * b;
			// delay regs
			pipe
			#(
			.REGS			( 3 ),
			.DATA_W		( DBL_W ),
			.RESET_VAL	( 0 )
			)
			regs_debug
			(
			.clk_i		( clk_i ),
			.rst_i		( rst_i ),
			.data_i		( debug_mult ),
			.data_o		( debug_mult_r )
			);
			// compare & register
			always @ ( posedge clk_i or posedge rst_i ) begin
				if ( rst_i ) begin
					debug <= 'b0;
				end else begin
					debug <= ( debug_mult_r != result_o );
				end
			end
			//
			assign debug_o = debug;
		end else begin
			assign debug_o = 'b0;
		end
	endgenerate


endmodule
