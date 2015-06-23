`timescale 1ns/1ns

module up_bfm_sv
(
	input         up_clk,
	output        up_wbe,
	output        up_csn,
	output [15:2] up_addr,
	inout  [31:0] up_data_io
);

import "DPI-C" context task up_bfm_c
(
	input real fw_delay
);

reg  [15:0] up_addr_o;
reg  [31:0] up_data_o;
wire [31:0] up_data_i;
reg         up_wbe_o;
reg         up_csn_o;

export "DPI-C" task cpu_wr;
task cpu_wr(input int addr, input int data);
	integer i;
	//$display("wr %08x %08x", addr, data);
	for (i=0; i<2; i=i+1) @(posedge up_clk);
	up_addr_o = addr;
	up_data_o = data;
	up_wbe_o  = 1'b0;
	up_csn_o  = 1'b0;
	for (i=0; i<20; i=i+1) @(posedge up_clk);
	up_csn_o  = 1'b1;
	for (i=0; i<1; i=i+1) @(posedge up_clk);
	up_addr_o = addr;
	up_data_o = data;
	up_wbe_o  = 1'b1;
	up_csn_o  = 1'b1;
	for (i=0; i<2; i=i+1) @(posedge up_clk);
endtask

export "DPI-C" task cpu_rd;
task cpu_rd(input int addr, output int data);
	integer i;
	for (i=0; i<2; i=i+1) @(posedge up_clk);
	up_addr_o = addr;
	up_wbe_o  = 1'b1;
	up_csn_o  = 1'b0;
	for (i=0; i<20; i=i+1) @(posedge up_clk);
	data      = up_data_i;
	for (i=0; i<1; i=i+1) @(posedge up_clk);
	up_addr_o = addr;
	up_wbe_o  = 1'b1;
	up_csn_o  = 1'b1;
	for (i=0; i<2; i=i+1) @(posedge up_clk);
	//$display("rd %08x %08x", addr, data);
endtask

export "DPI-C" task cpu_hd;
task cpu_hd(input int t);
	integer i;
	//$display("#%d",t);
	for (i=0; i<=t; i=i+1) @(posedge up_clk);
endtask

assign up_wbe     = up_wbe_o;
assign up_csn     = up_csn_o;
assign up_addr    = up_addr_o[15:2];
assign up_data_io = !up_wbe_o? up_data_o : 32'bzzzzzzzz;
assign up_data_i  = up_data_io;



// start cpu bfm C model
reg up_start;
initial begin
	up_wbe_o  = 1'b1;
	up_csn_o  = 1'b1;
	up_addr_o = 'd0;
	up_data_o = 'd0;

	@(posedge up_start);
	#100 up_bfm_c(5);
end

endmodule
