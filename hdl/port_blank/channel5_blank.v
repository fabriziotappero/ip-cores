// 32 bit Port Register

`timescale 1ns/100ps

module channel5(
	input					clk,
	input					rst,
	input					wen,
	input					ren,
	input					in_sof,
	input					in_eof,
	input					in_src_rdy,
	output				in_dst_rdy,
	input		[7:0]		in_data,
	
	output	reg		out_sof,
	output	reg		out_eof,
	input					out_dst_rdy,
	output				out_src_rdy,
	output	reg [7:0]		out_data
);

endmodule
