///////////////////////////////////////////////////////////////////
//
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//

`include "ddr_include.v"

module ddr_pulse78 (
	input     clk,
	input     reset,
	//
	output    pulse78
);

`define PULSE78_RNG  8:0
`define PULSE78_INIT 389

reg [`PULSE78_RNG] counter;
reg            pulse78_reg;

assign pulse78 = pulse78_reg;

always @(posedge clk)
begin
	if (reset) begin
		counter     <= `PULSE78_INIT;
		pulse78_reg <= 0;
	end else begin
		if (counter == 0) begin
			counter     <= `PULSE78_INIT;
			pulse78_reg <= 1'b1;
		end else begin
			counter     <= counter - 1;
			pulse78_reg <= 0;
		end
	end
end


endmodule

// vim: set ts=4
