/*
--------------------------------------------------------------------------------

Module: dq_ram_infer.v

Function: 
- Infers a parameterized simple DQ synchronous RAM.

Instantiates: 
- Nothing (block RAM will most likely be synthesized).

Notes:
- Writes accept data after the address & write enable on the clock.
- Reads present data after the address on the clock.
- Configurable read-during-write mode.
- Optional output data registering (likely an internal BRAM resource).

--------------------------------------------------------------------------------
*/

module dq_ram_infer
	#(
	parameter		integer						REG_OUT			= 1,  // 1=enable output registering
	parameter		integer						DATA_W			= 16,
	parameter		integer						ADDR_W			= 8,
	parameter										RD_MODE 			= "MEM_DATA"  // options here are "MEM_DATA" and "WR_DATA"
	)
	(
	input			wire								clk_i,			// clock
	input			wire	[ADDR_W-1:0]			addr_i,			// address
	input			wire								wr_i,				// write enable, active high
	input			wire	[DATA_W-1:0]			data_i,			// write data
	output		wire	[DATA_W-1:0]			data_o			// read data
	);

	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	localparam		integer						CAPACITY			= 2**ADDR_W;  // total words possible to store
	reg					[DATA_W-1:0]			ram[0:CAPACITY-1];  // memory
	reg					[DATA_W-1:0]			data;	



	/*
	================
	== code start ==
	================
	*/



	// write
	always @ ( posedge clk_i ) begin
		if ( wr_i ) begin
			ram[addr_i] <= data_i;
		end
	end

	// read
	always @ ( posedge clk_i ) begin
		if ( wr_i & RD_MODE == "WR_DATA" ) begin
			data <= data_i;
		end else begin
			data <= ram[addr_i];
		end
	end

	// optional output reg
	generate
		if ( REG_OUT == 1 ) begin
			reg [DATA_W-1:0] data_r;
			always @ ( posedge clk_i ) begin
				data_r <= data;
			end
			assign data_o = data_r;
		end else begin
			assign data_o = data;
		end
	endgenerate


endmodule
