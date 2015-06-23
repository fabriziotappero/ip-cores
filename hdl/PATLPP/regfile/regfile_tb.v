// Register file test bench
//

module regfile_tb;

reg clk, rst, wren_low, wren_high;
reg [3:0] addr;
reg [15:0] data_in;
wire [15:0] data_out;

regfile dut (
	.clk(clk),
	.rst(rst),
	.wren_low(wren_low),
	.wren_high(wren_high),
	.address(addr),
	.data_in(data_in),
	.data_out(data_out)
);

initial
begin
	clk = 1;
	rst = 1;
	wren_low = 0;
	wren_high = 0;
	addr = 0;
	data_in = 0;
	@(posedge clk);
	rst = 0;
	wren_low = 1;
	wren_high = 1;
	addr = 3;
	data_in = 16'ha3a3;
	@(posedge clk);
	wren_low = 0;
	addr = 2;
	data_in = 16'ha2a2;
	@(posedge clk);
	wren_low = 1;
	wren_high = 0;
	addr = 1;
	data_in = 16'ha1a1;
	@(posedge clk);
	wren_low = 0;
	addr = 0;
	data_in = 16'ha0a0;
	@(posedge clk);
	addr = 1;
	$display("Addres 0: %h", data_out);
	@(posedge clk);
	addr = 2;
	$display("Addres 1: %h", data_out);
	@(posedge clk);
	addr = 3;
	$display("Addres 2: %h", data_out);
	@(posedge clk);
	$display("Addres 3: %h", data_out);
end

always
	#100 clk = ~clk;

endmodule
