// CHECKSUM_TB - testbench
//

`timescale 1ns / 1ns

module checksum_tb;

reg clk, rst, checksum_add, checksum_clear;
reg [15:0] data_in;
wire checksum_check;
wire [15:0] checksum_out;

checksum dut
(
	.clk(clk),
	.rst(rst),
	.checksum_add(checksum_add),
	.checksum_clear(checksum_clear),
	.data_in(data_in),
	.checksum_check(checksum_check),
	.checksum_out(checksum_out)
);

always #10 clk <= ~clk;

initial
begin
	clk = 1;
	rst = 1;
	data_in = 0;
	checksum_add = 0;
	checksum_clear = 0;
	@(posedge clk);
	rst = 0;
	@(posedge clk);
	data_in = 16'hffff;
	@(posedge clk);
	checksum_add = 1;
	@(posedge clk);
	data_in = 1;
	@(posedge clk);
	@(posedge clk);
	checksum_clear = 1;
	@(posedge clk);
	checksum_clear = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
end

endmodule
