//**************************************************************
// Module             : up_monitor_wrapper.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1
// Place and Route    : QuartusII 10.1 sp1
// Targets device     : Cyclone III
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : Common CPU interface to pipelined access
//                      interface converter.
//                      @Note: Implementation dependent.
//**************************************************************

`timescale 1ns/1ns

module up_monitor_wrapper (up_clk,up_wbe,up_csn,up_addr,up_data_io);

// common CPU bus interface
input        up_clk;
input        up_wbe,up_csn;  // negative logic
input [31:0] up_addr;
input [31:0] up_data_io;

// filter out glitches on the line with extra 4 clocks
reg up_wbe_d1, up_wbe_d2, up_wbe_d3, up_wbe_d4;
reg up_csn_d1, up_csn_d2, up_csn_d3, up_csn_d4;
always @(posedge up_clk) begin
	up_wbe_d1 <= up_wbe;
	up_wbe_d2 <= up_wbe_d1;
	up_wbe_d3 <= up_wbe_d2;
	up_wbe_d4 <= up_wbe_d3;
	up_csn_d1 <= up_csn;
	up_csn_d2 <= up_csn_d1;
	up_csn_d3 <= up_csn_d2;
	up_csn_d4 <= up_csn_d3;
end
reg wr_en_filtered, wr_en_filtered_d1;
always @(posedge up_clk) begin
	// negative logic changed to positive logic, with filter
	wr_en_filtered    <= (!up_wbe_d2 & !up_wbe_d3 & !up_wbe_d4) & (!up_csn_d2 & !up_csn_d3 & !up_csn_d4);
	wr_en_filtered_d1 <= wr_en_filtered;
end
reg rd_en_filtered, rd_en_filtered_d1;
always @(posedge up_clk) begin
	// negative logic changed to positive logic, with filter
	rd_en_filtered    <= (up_wbe_d2 & up_wbe_d3 & up_wbe_d4) & (!up_csn_d2 & !up_csn_d3 & !up_csn_d4);
	rd_en_filtered_d1 <= rd_en_filtered;
end

// latch the data at rising edge of up_csn(negative logic)
reg [31:0] up_addr_latch;
reg [31:0] up_data_latch;
always @(posedge up_csn) begin
	up_addr_latch <= up_addr;
	up_data_latch <= up_data_io;
end

// map to pipelined access interface
wire        clk     = up_clk;
wire        wr_en   = !wr_en_filtered & wr_en_filtered_d1;  // falling edge of write_enable(positive logic)
wire        rd_en   = !rd_en_filtered & rd_en_filtered_d1;  // falling edge of read_enable(positive logic)
wire [31:0] addr_in = up_addr_latch;
wire [31:0] data_in = up_data_latch;

up_monitor inst (
	.clk(clk),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr_in(addr_in),
	.data_in(data_in)
);

endmodule
