// CHECKSUM - a checksum unit for the PATLPP processor
//

`timescale 1ns / 100ps

module checksum
(
	input		wire				clk,
	input		wire				rst,

	input		wire	[15:0]	data_in,
	input		wire				checksum_add,
	input		wire				checksum_clear,
	
	output	wire				checksum_check,
	output	wire	[15:0]	checksum_out
);

wire	[16:0]	wide_res;
reg	[15:0]	result;

assign wide_res = result + data_in; // compute the addition w/carry
assign checksum_out = ~result; // compute the 1's compliment
assign checksum_check = (result == 0);

always @(posedge clk)
begin
	if (rst)
	begin
		result <= 0;
	end
	else if (checksum_clear)
	begin
		result <= 0;
	end
	else if (checksum_add)
	begin
		result <= wide_res[15:0] + { 15'd0, wide_res[16] }; // add carry to result
	end
end

endmodule
