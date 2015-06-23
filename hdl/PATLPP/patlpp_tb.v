// PATLPP Testbench
//

`timescale 1ns / 100ps

module patlpp_tb;

reg				en; // module enable
reg				clk; // module clock
reg				rst; // module reset

reg				in_sof; // start of frame input
reg				in_eof; // end of frame input
reg				in_src_rdy; // source of input ready
wire				in_dst_rdy; // this module destination ready

wire				out_sof; // start of frame output
wire				out_eof; // end of frame output
wire				out_src_rdy; // this module source ready
reg				out_dst_rdy; // destination of output ready

wire	[7:0]		in_data; // data input
wire	[7:0]		out_data; // data output
wire	[3:0]		port_addr; 

patlpp thepp
(
	.en(en),
	.clk(clk),
	.rst(rst),
	.in_sof(in_sof),
	.in_eof(in_eof),
	.in_src_rdy(in_src_rdy),
	.in_dst_rdy(in_dst_rdy),
	.out_sof(out_sof),
	.out_eof(out_eof),
	.out_src_rdy(out_src_rdy),
	.out_dst_rdy(out_dst_rdy),
	.in_data(in_data),
	.out_data(out_data),
	.port_addr(port_addr)
);

reg [7:0] mem [0:255];
reg [7:0] addr;

assign in_data = mem[addr];

initial $readmemh("inframe.hex", mem);

initial
begin
	clk = 0;
	en = 1;
	rst = 1;
	in_sof = 0;
	in_eof = 0;
	in_src_rdy = 0;
	out_dst_rdy = 1;
	addr = 0;

	@(posedge clk);
	rst = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	in_src_rdy = 1;
	in_sof = 1;
end

always @(posedge clk)
begin
	if (in_src_rdy == 1 && in_dst_rdy == 1) 
	begin
		if (addr == 0)
		begin
			in_sof <= 0;
		end
		if (addr == 56)
		begin
			in_eof <= 1;
		end
		if (addr == 57)
		begin
			in_eof <= 0;
		end
		addr <= addr + 1;
	end
end

always #10 clk = ~clk;

endmodule
