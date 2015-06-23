// Shift Register Test Bench
//

module shiftr_bram_tb;

reg en_in, en_out, clk, rst;
reg [7:0] data_in;
wire [7:0] data_out;
wire empty;

shiftr_bram dut (
	.en_in(en_in),
	.en_out(en_out),
	.clk(clk),
	.rst(rst),
	.empty(empty),
	.data_in(data_in),
	.data_out(data_out)
);

initial
begin
	clk = 1;
	en_in = 0;
	en_out = 0;
	rst = 1;
	data_in = 0;
	@(posedge clk)
		rst = 0;
	@(posedge clk)
		en_in = 1;
		data_in = 1;
	@(posedge clk)
		data_in = 2;
	@(posedge clk)
		data_in = 3;
	@(posedge clk)
		en_out = 1;
		data_in = 4;
	@(posedge clk)
		data_in = 5;
	@(posedge clk)
		en_in = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk)
		en_out = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
end

always
	#100 clk = ~clk;

always @(posedge clk or rst)
	#1 $display("At t=%t : en_in=%h, en_out=%h, data_in=%h, data_out=%h", 
						$time, en_in, en_out, data_in, data_out);

endmodule
