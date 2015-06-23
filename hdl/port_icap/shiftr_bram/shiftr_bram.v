// Shift Register
// Author: Peter Lieber
//

module shiftr_bram
(
	input				en_in,
	input				en_out,
	input				clk,
	input				rst,
	output			empty,
	output			full,

	input		[7:0]	data_in,
	output	[7:0] data_out
);

//wire rst_n, en_in_n, en_out_n;
//assign rst_n = ~rst;
//assign en_in_n = ~en_in;
//assign en_out_n = ~en_out;

/* V5 Primitive */
FIFO18 #(
	.FIRST_WORD_FALL_THROUGH("TRUE"),
	.DO_REG(1),
	.DATA_WIDTH(9)
	) FIFO18_inst (
	.DI(data_in),
	.DIP(1'b0),
	.WREN(en_in),
	.WRCLK(clk),
	.RDEN(en_out),
	.RDCLK(clk),
	.RST(rst),
	.DO(data_out),
	.FULL(full),
	.EMPTY(empty)
	);
/**/

/* V4 Primitive
FIFO16 #(
	.FIRST_WORD_FALL_THROUGH("TRUE"),
	//.DO_REG(1),
	.DATA_WIDTH(9)
	) FIFO16_inst (
	.DI(data_in),
	.DIP(1'b0),
	.WREN(en_in),
	.WRCLK(clk),
	.RDEN(en_out),
	.RDCLK(clk),
	.RST(rst),
	.DO(data_out),
	.FULL(full),
	.EMPTY(empty)
	);
*/

endmodule
