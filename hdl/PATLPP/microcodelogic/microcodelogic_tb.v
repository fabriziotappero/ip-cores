// Microcode logic testbench
// Author: Peter Lieber
//
`timescale 1ns / 100ps

module microcodelogic_tb;

// Input stimulus:
reg	clk;
reg	rst;
reg	sof_in;
reg	eof_in;
reg	src_rdy_in;
reg	dst_rdy_out;
reg	comp_res;

// Output connections:
wire	dst_rdy_in;
wire	sof_out;
wire	eof_out;
wire	src_rdy_out;
wire	comp_mux_a_s;
wire	comp_mux_b_s;
wire	[15:0]	inst_constant;
wire	sr1_in_en;
wire	sr2_in_en;
wire	sr1_out_en;
wire	sr2_out_en;
wire	[3:0]	reg_addr;
wire	reg_wen_high;
wire	reg_wen_low;
wire	[2:0]	mux_data_out_s;


//Instantiate the DUT (device under test):
microcodelogic DUT (
	// Inputs:
	.clk ( clk ),	// Clock
	.rst ( rst ),	// Reset
	.sof_in ( sof_in ),	// Input Stream Start of Frame
	.eof_in ( eof_in ),	// Input Stream End of Frame
	.src_rdy_in ( src_rdy_in ),	// Input Stream Source Ready
	.dst_rdy_out ( dst_rdy_out ),	// Output Stream Destination Ready
	.comp_res ( comp_res ),	// Comparator Result

	// Outputs:
	.dst_rdy_in ( dst_rdy_in ),	// Input Stream Destination Ready
	.sof_out ( sof_out ),	// Output Stream Start of Frame
	.eof_out ( eof_out ),	// Output Stream End of Frame
	.src_rdy_out ( src_rdy_out ),	// Output Stream Source Ready
	.comp_mux_a_s ( comp_mux_a_s ),	// Comparator Mux A Select
	.comp_mux_b_s ( comp_mux_b_s ),	// Comparator Mux B Select
	.inst_constant ( inst_constant ),	// Instruction Constant
	.sr1_in_en ( sr1_in_en ),	// Shift Register 1 Input Enable
	.sr2_in_en ( sr2_in_en ),	// Shift Register 2 Input Enable
	.sr1_out_en ( sr1_out_en ),	// Shift Register 1 Output Enable
	.sr2_out_en ( sr2_out_en ),	// Shift Register 2 Output Enable
	.reg_addr ( reg_addr ),	// Register File Address
	.reg_wen_high ( reg_wen_high ),	// Register File High Byte Enable
	.reg_wen_low ( reg_wen_low ),	// Register File Low Byte Enable
	.mux_data_out_s ( mux_data_out_s )	// Data Output Mux Select
);

	// Specify input stimulus:

initial begin

	// Initial values for input stimulus:
	clk = 1'b0;
	rst = 1'b1;
	sof_in = 1'b0;
	eof_in = 1'b0;
	src_rdy_in = 1'b0;
	dst_rdy_out = 1'b0;
	comp_res = 1'b0;

	@(posedge clk);
	rst = 0;
	@(posedge clk);
	@(posedge clk);
	dst_rdy_out = 1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	src_rdy_in = 1;
	dst_rdy_out = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	src_rdy_in = 0;
	@(posedge clk);
	@(posedge clk);
	src_rdy_in = 1;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	src_rdy_in = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	#10 $stop;
end

	// Template for master clock. Uncomment and modify signal name as needed.
	// Remember to set the initial value of 'Clock' in the 'initial' block above.
always #10 clk = ~clk;


endmodule

