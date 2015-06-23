// Empty module for cacheless Simply RISC S1 Core

module bw_r_idct(rdtag_w0_y, rdtag_w1_y, rdtag_w2_y, rdtag_w3_y, so, rclk, se, 
	si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x, 
	dec_wrway_x, rdreq_x, wrreq_x, wrtag_w0_y, wrtag_w1_y, wrtag_w2_y, 
	wrtag_w3_y, adj);

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input			rst_tri_en;
	input	[6:0]		index0_x;
	input	[6:0]		index1_x;
	input			index_sel_x;
	input	[3:0]		dec_wrway_x;
	input			rdreq_x;
	input			wrreq_x;
	input	[32:0]		wrtag_w0_y;
	input	[32:0]		wrtag_w1_y;
	input	[32:0]		wrtag_w2_y;
	input	[32:0]		wrtag_w3_y;
	input	[3:0]		adj;
	output	[32:0]		rdtag_w0_y;
	output	[32:0]		rdtag_w1_y;
	output	[32:0]		rdtag_w2_y;
	output	[32:0]		rdtag_w3_y;
	output			so;
   
endmodule

