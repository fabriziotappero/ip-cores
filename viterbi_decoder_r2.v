`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:50:45 12/03/2010 
// Design Name: 
// Module Name:    vitdec
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module viterbi_decoder_r2(clk, rst, frame_rst, en, in1, in2, out_dc);

input clk, rst, frame_rst, en, in1, in2;
output out_dc;

wire [0:63] branch_metric_w;

	acs uut_acs (
		.clk(clk), 
		.rst(rst), 
		.frame_rst(frame_rst), 
		.en(en), 
		.in1(in1), 
		.in2(in2), 
		.out(branch_metric_w)
	);

	tb_ram #(
		64, //state
		6, //nu
		128, //tb_length
		7, //tb_length_log
		1) //radix
		
	uut_tb (
		.rst(rst), 
		.clk(clk), 
		.frame_rst(frame_rst), 
		.en(en), 
		.in1(branch_metric_w), 
		.in2(), 
		.in3(), 
		.in4(), 
		.out_tb(), 
		.out_dc(out_dc)
	);

endmodule
