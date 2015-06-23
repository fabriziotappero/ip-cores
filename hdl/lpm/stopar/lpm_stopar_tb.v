// Serial to Parallel Shift Register
// Author: Peter Lieber
//

module lpm_stopar_tb;

reg clk;
reg rst;
reg [7:0] sin;
reg en;
wire [15:0] pout;

lpm_stopar
#(
	.WIDTH(8),
	.DEPTH(2)
) dut (
	.clk(clk),
	.rst(rst),
	.sin(sin),
	.en(en),
	.pout(pout)
);

always #10 clk = ~clk;

initial
begin
	clk = 0;
	rst = 1;
	sin = 0;
	en = 0;
	@(posedge clk);
	rst = 0;
	@(posedge clk);
	sin = 5;
	@(posedge clk);
	en = 1;
	@(posedge clk);
	sin = 9;
	@(posedge clk);
	en = 0;
	@(posedge clk);
	@(posedge clk);
	en = 1;
	@(posedge clk);
	en = 0;
	@(posedge clk);
	rst = 1;
	@(posedge clk);
	rst = 0;
	@(posedge clk);
	#5	$stop;
end

endmodule

