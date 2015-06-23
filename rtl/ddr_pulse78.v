//----------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------
`include "ddr_include.v"

module ddr_pulse78 #(
	parameter    clk_freq = 50000000
) (
	input        clk,
	input        reset,
	//
	output   reg pulse78
);

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
`define PULSE78_RNG  10:0

parameter pulse78_init = 78 * (clk_freq/10000000);

reg [`PULSE78_RNG] counter;

always @(posedge clk)
begin
	if (reset) begin
		counter <= pulse78_init;
		pulse78 <= 0;
	end else begin
		if (counter == 0) begin
			counter <= pulse78_init;
			pulse78 <= 1'b1;
		end else begin
			counter <= counter - 1;
			pulse78 <= 0;
		end
	end
end

endmodule

