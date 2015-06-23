// Port MD5 Testbench

`timescale 1ns / 100ps

module port_sha1_tb;

// Input stimulus:
reg	clk;
reg	rst;
reg	en;
reg	[7:0]	in_data;
reg	in_sof;
reg	in_eof;
reg	in_src_rdy;
reg	out_dst_rdy;

// Output connections:
wire	[7:0]	out_data;
wire	out_sof;
wire	out_eof;
wire	out_src_rdy;
wire	in_dst_rdy;


//Instantiate the DUT (device under test):
port_sha1 DUT (
	// Inputs:
	.clk ( clk ),
	.rst ( rst ),
	.wen ( en ),
	.ren ( en ),
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
	en = 1'b0;
	in_data = 8'b0;
	in_sof = 1'b0;
	in_eof = 1'b0;
	in_src_rdy = 1'b1;
	out_dst_rdy = 1'b0;

	//
	//--- INSERT YOUR INPUT STIMULUS DESCRIPTION HERE ---
	//

	@(posedge clk);
	rst = 1;
	@(posedge clk);
	rst = 0;
	@(posedge clk);
	en = 0;
	in_sof = 1;
	in_src_rdy = 1;
	in_data = "s";
	#1 en = 1;
	wait (in_dst_rdy);
	@(posedge clk);
	in_sof = 0;
	in_data = "u";
	@(posedge clk);
	in_data = "b";
	@(posedge clk);
	in_data = "a";
	@(posedge clk);
	in_data = "r";
	@(posedge clk);
	in_data = "u";
	@(posedge clk);
	in_data = 8'h80;
	@(posedge clk);
	in_data = 8'h0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	in_src_rdy = 0;
	en = 0;
	@(posedge clk);
	in_src_rdy = 1;
	en = 1;
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	//in_data = 8'h80;
	@(posedge clk);
	//in_data = 8'h00;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	//in_data = 8'h03;
	@(posedge clk);
	in_eof = 1;
	in_data = 8'h30;
	@(posedge clk);
	in_eof = 0;
	in_src_rdy = 0;
	wait (out_src_rdy);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	$stop;
	
end

	// Template for master clock. Uncomment and modify signal name as needed.
	// Remember to set the initial value of 'Clock' in the 'initial' block above.
always #5 clk = ~clk;
always @(posedge clk)
	out_dst_rdy = ~out_dst_rdy;

endmodule
