//----- Testbench -----

// Timescale: one time unit = 1ns (e.g., delay specification of #42 means 42ns of time), and
// simulator resolution is 0.1 ns
`timescale 1ns / 100ps

module port_fifo_tb;

// Input stimulus:
reg	clk;
wire	out_clk;
reg	rst;
reg	wen, ren;
reg	[7:0]	in_data;
reg	in_sof;
reg	in_eof;
reg	in_src_rdy;
reg	out_dst_rdy;
reg	out_clk_en;

// Output connections:
wire	[7:0]	out_data;
wire	out_sof;
wire	out_eof;
wire	out_src_rdy;
wire	in_dst_rdy;


//Instantiate the DUT (device under test):
port_fifo DUT (
	// Inputs:
	.in_clk ( clk ),
	.out_clk ( out_clk ),
	.rst ( rst ),
	.in_data ( in_data ),	// Input
	.in_sof ( in_sof ),	// Input
	.in_eof ( in_eof ),	// Input
	.in_src_rdy ( in_src_rdy ),	// Input
	.out_dst_rdy ( out_dst_rdy ),	// Output

	// Outputs:
	.out_data ( out_data ),	// Output
	.out_sof ( out_sof ),	// Output
	.out_eof ( out_eof ),	// Output
	.out_src_rdy ( out_src_rdy ),	// Output
	.in_dst_rdy ( in_dst_rdy )	// Input
);

	// Specify input stimulus:

initial begin

	// Initial values for input stimulus:
	clk = 1;
	rst = 1'b0;
	in_data = 8'b0;
	in_sof = 1'b0;
	in_eof = 1'b0;
	in_src_rdy = 1'b0;
	out_dst_rdy = 1'b0;
	out_clk_en = 0;

	//
	//--- INSERT YOUR INPUT STIMULUS DESCRIPTION HERE ---
	//

	@(posedge clk);
	rst = 1;
	out_clk_en = 1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	out_clk_en = 0;
	rst = 0;
	@(posedge clk);
	in_sof = 1;
	in_data = 8'h01;
	@(posedge clk);
	in_src_rdy = 1;
	@(posedge clk);
	in_sof = 0;
	in_data = 8'h02;
	@(posedge clk);
	in_data = 8'h03;
	@(posedge clk);
	in_eof = 1;
	in_data = 4;
	@(posedge clk);
	in_src_rdy = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	out_dst_rdy = 1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	out_clk_en = 1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
end

	// Template for master clock. Uncomment and modify signal name as needed.
	// Remember to set the initial value of 'Clock' in the 'initial' block above.
always #10 clk = ~clk;

assign out_clk = clk & out_clk_en;


endmodule
