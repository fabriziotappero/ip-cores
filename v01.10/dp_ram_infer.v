/*
--------------------------------------------------------------------------------

Module: dp_ram_infer.v

Function: 
- Infers a parameterized dual port synchronous RAM.

Instantiates: 
- Nothing (block RAM will most likely be synthesized).

Notes:
- A & B sides are separate clock domains.
- Writes accept data after the address & write enable on the clock.
- Reads present data after the address on the clock.
- Configurable read-during-write mode (for the same port).
- Optional output data registering (likely an internal BRAM resource).

--------------------------------------------------------------------------------
*/

module dp_ram_infer
	#(
	parameter		integer						REG_A_OUT		= 1,  // 1=enable A output registering
	parameter		integer						REG_B_OUT		= 1,  // 1=enable B output registering
	parameter		integer						DATA_W			= 16,
	parameter		integer						ADDR_W			= 8,
	parameter										RD_MODE 			= "WR_DATA"  // options here are "MEM_DATA" and "WR_DATA"
	)
	(
	// A side
	input			wire								a_clk_i,				// A clock
	input			wire	[ADDR_W-1:0]			a_addr_i,			// A address
	input			wire								a_wr_i,				// A write enable, active high
	input			wire	[DATA_W-1:0]			a_data_i,			// A write data
	output		wire	[DATA_W-1:0]			a_data_o,			// A read data
	// B side
	input			wire								b_clk_i,				// B clock
	input			wire	[ADDR_W-1:0]			b_addr_i,			// B address
	input			wire								b_wr_i,				// B write enable, active high
	input			wire	[DATA_W-1:0]			b_data_i,			// B write data
	output		wire	[DATA_W-1:0]			b_data_o				// B read data
	);

	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam		integer						CAPACITY			= 2**ADDR_W;	// total words possible to store
	reg					[DATA_W-1:0]			ram[0:CAPACITY-1];  // memory
	reg					[DATA_W-1:0]			a_data, b_data;
	`include "boot_code.h"



	/*
	================
	== code start ==
	================
	*/



	/*
	------------
	-- side A --
	------------
	*/

	// write
	always @ ( posedge a_clk_i ) begin
		if ( a_wr_i ) begin
			ram[a_addr_i] <= a_data_i;
		end
	end

	// read
	always @ ( posedge a_clk_i ) begin
		if ( a_wr_i & RD_MODE == "WR_DATA" ) begin
			a_data <= a_data_i;
		end else begin
			a_data <= ram[a_addr_i];
		end
	end

	// optional output reg
	generate
		if ( REG_A_OUT ) begin
			reg [DATA_W-1:0] a_data_r;
			always @ ( posedge a_clk_i ) begin
				a_data_r <= a_data;
			end
			assign a_data_o = a_data_r;
		end else begin
			assign a_data_o = a_data;
		end
	endgenerate


	/*
	------------
	-- side B --
	------------
	*/

	// write
	always @ ( posedge b_clk_i ) begin
		if ( b_wr_i ) begin
			ram[b_addr_i] <= b_data_i;
		end
	end

	// read
	always @ ( posedge b_clk_i ) begin
		if ( b_wr_i & RD_MODE == "WR_DATA" ) begin
			b_data <= b_data_i;
		end else begin
			b_data <= ram[b_addr_i];
		end
	end

	// optional output reg
	generate
		if ( REG_B_OUT ) begin
			reg [DATA_W-1:0] b_data_r;
			always @ ( posedge b_clk_i ) begin
				b_data_r <= b_data;
			end
			assign b_data_o = b_data_r;
		end else begin
			assign b_data_o = b_data;
		end
	endgenerate


endmodule
