/**********************************************************************
 * File  : mtx_trps_8x8_dpsram.v
 * Author: Ivan Rezki
 * email : irezki@gmail.com
 * Topic : RTL Core
 * 		  2-Dimensional Fast Hartley Transform
 *
 *
 * Matrix Transpose 8x8
 * DPSRAM-based Double Buffer
 * Buffer size is 64*2 words, each word is 16 bits
 *
 * Matrix Transpose -> 64 clk delay
 *			- Double Buffer Solution:
 *
 * RIGHT TO USE: This code example, or any portion thereof, may be
 * used and distributed without restriction, provided that this entire
 * comment block is included with the example.
 *
 * DISCLAIMER: THIS CODE EXAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
 * TO WARRANTIES OF MERCHANTABILITY, FITNESS OR CORRECTNESS. IN NO
 * EVENT SHALL THE AUTHOR OR AUTHORS BE LIABLE FOR ANY DAMAGES,
 * INCLUDING INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE
 * USE OF THIS CODE.
 **********************************************************************/

module mtx_trps_8x8_dpsram (
	rstn,
	sclk,
	
	// Input
	inp_valid,
	inp_data,
	
	// Output
	mem_data,
	mem_valid
);
parameter N = 8;

input			rstn;
input			sclk;

input			inp_valid;
input	[N-1:0]	inp_data;
	
output	[N-1:0]	mem_data;
output			mem_valid;

reg [6:0]	cnt128d_wr;				// Write Mode Counter
wire		indicator;				// 64 words written - Indication(pos. or neg. edge)
reg			indicator_1d;			// Indication 1 clock delay
wire		indicator_pos_edge;		// positive edge
wire		indicator_neg_edge;		// negative edge
reg	[6:0]	cnt128d_rd;				// Read Counter
wire		cnt128d_rd_valid_start;	// Counter start increment
wire		cnt128d_rd_valid_stop;	// Counter stop increment
reg			cnt128d_rd_valid;		// valid time for cnt128d_rd counter
reg			mem_valid;				// 1 clock delay after reading

// DPSRAM Memory Signal Description
wire [15:0] wr_DATA;
wire [ 6:0] wr_ADDR;
wire		wr_CSN;
wire		wr_WEN;

wire [ 6:0] rd_ADDR;
wire		rd_CSN;

`ifdef USE_FPGA_SPSRAM
	wire [15:0] rd_DATA;
	dpsram_128x16 u_dpsram(
		.addra	(wr_ADDR),
		.addrb	(rd_ADDR),
		.clka	(sclk),
		.clkb	(sclk),
		.dina	(wr_DATA),
		.dinb	({16{1'b0}}),
		.douta	(/* OPEN */),
		.doutb	(rd_DATA),
		.ena	(wr_CSN),
		.enb	(rd_CSN),
		.wea	(wr_WEN),
		.web	(1'b1)
	);
`endif

`ifdef USE_ASIC_SPSRAM
	reg [15:0] rd_DATA = 16'd0;
	reg	[15:0] sram[0:127];
	always @(posedge sclk)
		if (~wr_WEN && ~wr_CSN) sram[wr_ADDR] <= wr_DATA;	// Write
	always @(posedge sclk)
		if (  1'b1  && ~rd_CSN) rd_DATA <= sram[rd_ADDR];	// Read
`endif

always @(posedge sclk or negedge rstn)
if		(!rstn)		cnt128d_wr <= #1 0;
else if (inp_valid)	cnt128d_wr <= #1 cnt128d_wr + 1;

assign wr_DATA = {{16-N{1'b0}},inp_data};
assign wr_ADDR = cnt128d_wr;
assign wr_CSN  = ~inp_valid;
assign wr_WEN  = ~inp_valid;

// Start Reading After fisrt 64 words had been written
assign indicator = cnt128d_wr[6];
always @(posedge sclk or negedge rstn)
if	(!rstn)	indicator_1d <= #1 1'b0;
else		indicator_1d <= #1 indicator;

assign indicator_pos_edge =  indicator & ~indicator_1d;
assign indicator_neg_edge = ~indicator &  indicator_1d;

assign cnt128d_rd_valid_start = indicator_pos_edge | indicator_neg_edge;
assign cnt128d_rd_valid_stop  = (cnt128d_rd[5:0] == 63) ? 1'b1 : 1'b0;

always @(posedge sclk or negedge rstn)
if		(!rstn)					cnt128d_rd_valid <= #1 1'b0;
else if (cnt128d_rd_valid_start)cnt128d_rd_valid <= #1 1'b1;
else if (cnt128d_rd_valid_stop)	cnt128d_rd_valid <= #1 1'b0;

// Read Mode Counter
always @(posedge sclk or negedge rstn)
if		(!rstn)				cnt128d_rd <= #1 1'b0;
else if (cnt128d_rd_valid)	cnt128d_rd <= #1 cnt128d_rd + 1;

assign rd_ADDR = {cnt128d_rd[6],cnt128d_rd[2:0],cnt128d_rd[5:3]};
assign rd_CSN  = ~cnt128d_rd_valid;

// Output
always @(posedge sclk or negedge rstn)
if	(!rstn)	mem_valid <= #1 1'b0;
else		mem_valid <= #1 cnt128d_rd_valid;

assign #1 mem_data = rd_DATA[N-1:0];

// synopsys translate_off
// <<<------------- DUMP Section
/*
// 2D FHT OUTPUT DUMP DATA 
parameter MEM_TRPS_DPSRAM_FILE = "./result/mem_trps_dpsram.txt";
integer mem_trps_dpsram_dump;
initial mem_trps_dpsram_dump = $fopen(MEM_TRPS_DPSRAM_FILE);

always @(posedge sclk)
if (mem_valid) $fdisplay(mem_trps_dpsram_dump,"%h",mem_data);
*/
// synopsys translate_on
endmodule
