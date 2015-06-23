module port_fifo (
// Clock control module for PATLPP port interface

	// Inputs:
	in_clk,
	out_clk,
	rst,
	in_data,			// Input Data
	in_sof,			// Input Start of Frame
	in_eof,			// Input End of Frame
	in_src_rdy,		// Input Source Ready
	out_dst_rdy,	// Output Destination Ready

	// Outputs:
	out_data,		// Output Data
	out_sof,			// Output Start of Frame
	out_eof,			// Output End of Frame
	out_src_rdy,	// Output Source Ready
	in_dst_rdy		// Input Destination Ready
);

// Port mode declarations:
	// Inputs:
input	in_clk;
input	out_clk;
input	rst;
input	[7:0]	in_data;
input	in_sof;
input	in_eof;
input	in_src_rdy;
input	out_dst_rdy;

	// Outputs:
output	[7:0]	out_data;
output	out_sof;
output	out_eof;
output	out_src_rdy;
output	in_dst_rdy;


wire	[15:0]		fifo_datain;
wire	[15:0]		fifo_dataout;
wire				fifo_wren;
wire				fifo_wrclk;
wire				fifo_rden;
wire				fifo_rdclk;
wire				fifo_rst;
wire				fifo_full;
wire				fifo_empty;

assign fifo_datain = {6'd0, in_sof, in_eof, in_data};
assign {out_sof, out_eof, out_data} = fifo_dataout[9:0];
assign fifo_wren = in_src_rdy & in_dst_rdy;
assign fifo_rden = out_src_rdy & out_dst_rdy;
assign in_dst_rdy = ~fifo_full;
assign out_src_rdy = ~fifo_empty;
assign fifo_rdclk = out_clk;
assign fifo_wrclk = in_clk;
assign fifo_rst = rst;


/* V5 Primitive */
FIFO18 #(
	.FIRST_WORD_FALL_THROUGH("TRUE"),
	.DO_REG(1),
	.DATA_WIDTH(18)
	) FIFO18_inst (
	.DI(fifo_datain),
	.DIP(2'd0),
	.WREN(fifo_wren),
	.WRCLK(fifo_wrclk),
	.RDEN(fifo_rden),
	.RDCLK(fifo_rdclk),
	.RST(fifo_rst),
	.DO(fifo_dataout),
	.FULL(fifo_full),
	.EMPTY(fifo_empty)
	);
/**/

/* V4 Primitive
FIFO16 #(
	.FIRST_WORD_FALL_THROUGH("TRUE"),
	//.DO_REG(1),
	.DATA_WIDTH(18)
	) FIFO16_inst (
	.DI(fifo_datain),
	.DIP(2'd0),
	.WREN(fifo_wren),
	.WRCLK(fifo_wrclk),
	.RDEN(fifo_rden),
	.RDCLK(fifo_rdclk),
	.RST(fifo_rst),
	.DO(fifo_dataout),
	.FULL(fifo_full),
	.EMPTY(fifo_empty)
	);
*/


endmodule
