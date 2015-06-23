/*
--------------------------------------------------------------------------------

Module : stacks_mux.v

--------------------------------------------------------------------------------

Function:
- Output multiplexer for processor stacks.

Instantiates:
- (1x) vector_sr.v

Notes:
- Purely combinatorial.

--------------------------------------------------------------------------------
*/

module stacks_mux
	#(
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							STK_W				= 2,		// stack selector width
	parameter	integer							IM_DATA_W		= 8		// immediate data width
	)
	(
	// control I/O
	input			wire	[STK_W-1:0]				a_sel_i,						// stack selector
	input			wire	[STK_W-1:0]				b_sel_i,						// stack selector
	input			wire								imda_i,						// 1=immediate data
	// data I/O
	input			wire	[DATA_W-1:0]			pop_data0_i,				// stack data
	input			wire	[DATA_W-1:0]			pop_data1_i,				// stack data
	input			wire	[DATA_W-1:0]			pop_data2_i,				// stack data
	input			wire	[DATA_W-1:0]			pop_data3_i,				// stack data
	input			wire	[IM_DATA_W-1:0]		im_data_i,					// immediate data
	//
	output		wire	[DATA_W-1:0]			a_o,						// results
	output		wire	[DATA_W-1:0]			b_o,
	output		wire	[DATA_W-1:0]			b_alu_o
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	reg					[DATA_W-1:0]			a, b;


	/*
	================
	== code start ==
	================
	*/


	// mux stack read data
	always @ ( * ) begin
		case ( a_sel_i )
			'b00 : a <= pop_data0_i;
			'b01 : a <= pop_data1_i;
			'b10 : a <= pop_data2_i;
			'b11 : a <= pop_data3_i;
		endcase
	end
	
	// mux stack read data
	always @ ( * ) begin
		case ( b_sel_i )
			'b00 : b <= pop_data0_i;
			'b01 : b <= pop_data1_i;
			'b10 : b <= pop_data2_i;
			'b11 : b <= pop_data3_i;
		endcase
	end
	
	// output
	assign a_o = a;
	assign b_o = b;
	assign b_alu_o = ( imda_i ) ? $signed( im_data_i ) : $signed( b );


endmodule
