//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, wishbone stuff                           ////
////                                                              ////
////  Description                                                 ////
////  Wishbone compliant modules                                  ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`ifdef WB_ADR_INC
`timescale 1ns/1ns
`define MODULE wb_adr_inc
module `BASE`MODULE ( cyc_i, stb_i, cti_i, bte_i, adr_i, we_i, ack_o, adr_o, clk, rst);
`undef MODULE
parameter adr_width = 10;
parameter max_burst_width = 4;
input cyc_i, stb_i, we_i;
input [2:0] cti_i;
input [1:0] bte_i;
input [adr_width-1:0] adr_i;
output [adr_width-1:0] adr_o;
output ack_o;
input clk, rst;

reg [adr_width-1:0] adr;
wire [max_burst_width-1:0] to_adr;
reg [max_burst_width-1:0] last_adr;
reg last_cycle;
localparam idle_or_eoc = 1'b0;
localparam cyc_or_ws   = 1'b1;

always @ (posedge clk or posedge rst)
if (rst)
    last_adr <= {max_burst_width{1'b0}};
else
    if (stb_i)
        last_adr <=adr_o[max_burst_width-1:0];

generate
if (max_burst_width==0) begin : inst_0   

        reg ack_o;
        assign adr_o = adr_i;
        always @ (posedge clk or posedge rst)
        if (rst)
            ack_o <= 1'b0;
        else
            ack_o <= cyc_i & stb_i & !ack_o;

end else begin

    always @ (posedge clk or posedge rst)
    if (rst)
        last_cycle <= idle_or_eoc;
    else
        last_cycle <= (!cyc_i) ? idle_or_eoc : //idle
                      (cyc_i & ack_o & (cti_i==3'b000 | cti_i==3'b111)) ? idle_or_eoc : // eoc
                      (cyc_i & !stb_i) ? cyc_or_ws : //ws
                      cyc_or_ws; // cyc
    assign to_adr = (last_cycle==idle_or_eoc) ? adr_i[max_burst_width-1:0] : adr[max_burst_width-1:0];
    assign adr_o[max_burst_width-1:0] = (we_i) ? adr_i[max_burst_width-1:0] :
                                        (!stb_i) ? last_adr :
                                        (last_cycle==idle_or_eoc) ? adr_i[max_burst_width-1:0] :
                                        adr[max_burst_width-1:0];
    assign ack_o = (last_cycle==cyc_or_ws) & stb_i;

end
endgenerate

generate
if (max_burst_width==2) begin : inst_2
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 2'h0;
    else
        if (cyc_i & stb_i)
            adr[1:0] <= to_adr[1:0] + 2'd1;
        else
            adr <= to_adr[1:0];
end
endgenerate

generate
if (max_burst_width==3) begin : inst_3    
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 3'h0;
    else
        if (cyc_i & stb_i)
            case (bte_i)
            2'b01: adr[2:0] <= {to_adr[2],to_adr[1:0] + 2'd1};
            default: adr[3:0] <= to_adr[2:0] + 3'd1;
            endcase
        else
            adr <= to_adr[2:0];
end
endgenerate

generate
if (max_burst_width==4) begin : inst_4    
    always @ (posedge clk or posedge rst)
    if (rst)
        adr <= 4'h0;
    else
        if (stb_i) // | (!stb_i & last_cycle!=ws)) // for !stb_i restart with adr_i +1, only inc once
            case (bte_i)
            2'b01: adr[3:0] <= {to_adr[3:2],to_adr[1:0] + 2'd1};
            2'b10: adr[3:0] <= {to_adr[3],to_adr[2:0] + 3'd1};
            default: adr[3:0] <= to_adr + 4'd1;
            endcase
        else
            adr <= to_adr[3:0];
end
endgenerate

generate
if (adr_width > max_burst_width) begin : pass_through
    assign adr_o[adr_width-1:max_burst_width] = adr_i[adr_width-1:max_burst_width];
end
endgenerate

endmodule
`endif

`ifdef WB_B4_EOC
`define MODULE wb_b4_eoc
module `BASE`MODULE ( cyc_i, stb_i, stall_o, ack_o, busy, eoc, clk, rst);
`undef MODULE
input cyc_i, stb_i, ack_o;
output busy, eoc;
input clk, rst;

`define MODULE cnt_bin_ce_rew_zq_l1
`BASE`MODULE # ( .length(4), level1_value(1))
cnt0 (
    .cke(), .rew(), .zq(), .level1(), .rst(), clk);
`undef MODULE

endmodule
`endif

`ifdef WB3WB3_BRIDGE
// async wb3 - wb3 bridge
`timescale 1ns/1ns
`define MODULE wb3wb3_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// wishbone master side
	wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_bte_o, wbm_cti_o, wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_dat_i, wbm_ack_i, wbm_clk, wbm_rst);

parameter style = "FIFO"; // valid: simple, FIFO
parameter addr_width = 4;

input [31:0] wbs_dat_i;
input [31:2] wbs_adr_i;
input [3:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i, wbs_cyc_i, wbs_stb_i;
output [31:0] wbs_dat_o;
output wbs_ack_o;
input wbs_clk, wbs_rst;

output [31:0] wbm_dat_o;
output reg [31:2] wbm_adr_o;
output [3:0]  wbm_sel_o;
output reg [1:0]  wbm_bte_o;
output reg [2:0]  wbm_cti_o;
output reg wbm_we_o;
output wbm_cyc_o;
output wbm_stb_o;
input [31:0]  wbm_dat_i;
input wbm_ack_i;
input wbm_clk, wbm_rst;

// bte
parameter linear       = 2'b00;
parameter wrap4        = 2'b01;
parameter wrap8        = 2'b10;
parameter wrap16       = 2'b11;
// cti
parameter classic      = 3'b000;
parameter incburst     = 3'b010;
parameter endofburst   = 3'b111;

localparam wbs_adr  = 1'b0;
localparam wbs_data = 1'b1;

localparam wbm_adr0      = 2'b00;
localparam wbm_adr1      = 2'b01;
localparam wbm_data      = 2'b10;
localparam wbm_data_wait = 2'b11;

reg [1:0] wbs_bte_reg;
reg wbs;
wire wbs_eoc_alert, wbm_eoc_alert;
reg wbs_eoc, wbm_eoc;
reg [1:0] wbm;

wire [1:16] wbs_count, wbm_count;

wire [35:0] a_d, a_q, b_d, b_q;
wire a_wr, a_rd, a_fifo_full, a_fifo_empty, b_wr, b_rd, b_fifo_full, b_fifo_empty;
reg a_rd_reg;
wire b_rd_adr, b_rd_data;
wire b_rd_data_reg;
wire [35:0] temp;

`define WE 5
`define BTE 4:3
`define CTI 2:0  

assign wbs_eoc_alert = (wbs_bte_reg==wrap4 & wbs_count[3]) | (wbs_bte_reg==wrap8 & wbs_count[7]) | (wbs_bte_reg==wrap16 & wbs_count[15]);
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs_eoc <= 1'b0;
else
	if (wbs==wbs_adr & wbs_stb_i & !a_fifo_full)
		wbs_eoc <= (wbs_bte_i==linear) | (wbs_cti_i==3'b111);
	else if (wbs_eoc_alert & (a_rd | a_wr))
		wbs_eoc <= 1'b1;

`define MODULE cnt_shreg_ce_clear
`BASE`MODULE # ( .length(16))
`undef MODULE
    cnt0 (
        .cke(wbs_ack_o),
        .clear(wbs_eoc),
        .q(wbs_count),
        .rst(wbs_rst),
        .clk(wbs_clk));

always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs <= wbs_adr;
else
	if ((wbs==wbs_adr) & wbs_cyc_i & wbs_stb_i & a_fifo_empty)
		wbs <= wbs_data;
	else if (wbs_eoc & wbs_ack_o)
		wbs <= wbs_adr;

// wbs FIFO
assign a_d = (wbs==wbs_adr) ? {wbs_adr_i[31:2],wbs_we_i,((wbs_cti_i==3'b111) ? {2'b00,3'b000} : {wbs_bte_i,wbs_cti_i})} : {wbs_dat_i,wbs_sel_i};
assign a_wr = (wbs==wbs_adr)  ? wbs_cyc_i & wbs_stb_i & a_fifo_empty :
              (wbs==wbs_data) ? wbs_we_i  & wbs_stb_i & !a_fifo_full :
              1'b0;
assign a_rd = !a_fifo_empty;
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	a_rd_reg <= 1'b0;
else
	a_rd_reg <= a_rd;
assign wbs_ack_o = a_rd_reg | (a_wr & wbs==wbs_data);

assign wbs_dat_o = a_q[35:4];
	
always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
	wbs_bte_reg <= 2'b00;
else
	wbs_bte_reg <= wbs_bte_i;

// wbm FIFO
assign wbm_eoc_alert = (wbm_bte_o==wrap4 & wbm_count[3]) | (wbm_bte_o==wrap8 & wbm_count[7]) | (wbm_bte_o==wrap16 & wbm_count[15]);
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	wbm_eoc <= 1'b0;
else
	if (wbm==wbm_adr0 & !b_fifo_empty)
		wbm_eoc <= b_q[`BTE] == linear;
	else if (wbm_eoc_alert & wbm_ack_i)
		wbm_eoc <= 1'b1;
	
always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	wbm <= wbm_adr0;
else
/*
    if ((wbm==wbm_adr0 & !b_fifo_empty) |
        (wbm==wbm_adr1 & !b_fifo_empty & wbm_we_o) |
        (wbm==wbm_adr1 & !wbm_we_o) |
        (wbm==wbm_data & wbm_ack_i & wbm_eoc))
        wbm <= {wbm[0],!(wbm[1] ^ wbm[0])};  // count sequence 00,01,10
*/
    case (wbm)
    wbm_adr0:
        if (!b_fifo_empty)
            wbm <= wbm_adr1;
    wbm_adr1:
        if (!wbm_we_o | (!b_fifo_empty & wbm_we_o))
            wbm <= wbm_data;
    wbm_data:
        if (wbm_ack_i & wbm_eoc)
            wbm <= wbm_adr0;
        else if (b_fifo_empty & wbm_we_o & wbm_ack_i)
            wbm <= wbm_data_wait;
    wbm_data_wait:
        if (!b_fifo_empty)
            wbm <= wbm_data;
    endcase

assign b_d = {wbm_dat_i,4'b1111};
assign b_wr = !wbm_we_o & wbm_ack_i;
assign b_rd_adr  = (wbm==wbm_adr0 & !b_fifo_empty);
assign b_rd_data = (wbm==wbm_adr1 & !b_fifo_empty & wbm_we_o) ? 1'b1 : // b_q[`WE]
                   (wbm==wbm_data & !b_fifo_empty & wbm_we_o & wbm_ack_i & !wbm_eoc) ? 1'b1 :
                   (wbm==wbm_data_wait & !b_fifo_empty) ? 1'b1 : 
                   1'b0;
assign b_rd = b_rd_adr | b_rd_data;

`define MODULE dff
`BASE`MODULE dff1 ( .d(b_rd_data), .q(b_rd_data_reg), .clk(wbm_clk), .rst(wbm_rst));
`undef MODULE
`define MODULE dff_ce
`BASE`MODULE # ( .width(36)) dff2 ( .d(b_q), .ce(b_rd_data_reg), .q(temp), .clk(wbm_clk), .rst(wbm_rst));
`undef MODULE

assign {wbm_dat_o,wbm_sel_o} = (b_rd_data_reg) ? b_q : temp;

`define MODULE cnt_shreg_ce_clear
`BASE`MODULE # ( .length(16))
`undef MODULE
    cnt1 (
        .cke(wbm_ack_i),
        .clear(wbm_eoc),
        .q(wbm_count),
        .rst(wbm_rst),
        .clk(wbm_clk));

assign wbm_cyc_o = (wbm==wbm_data | wbm==wbm_data_wait);
assign wbm_stb_o = (wbm==wbm_data);

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
	{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= {30'h0,1'b0,linear,classic};
else begin
	if (wbm==wbm_adr0 & !b_fifo_empty)
		{wbm_adr_o,wbm_we_o,wbm_bte_o,wbm_cti_o} <= b_q;
	else if (wbm_eoc_alert & wbm_ack_i)
		wbm_cti_o <= endofburst;
end	

//async_fifo_dw_simplex_top
`define MODULE fifo_2r2w_async_simplex
`BASE`MODULE
`undef MODULE
# ( .data_width(36), .addr_width(addr_width))
fifo (
    // a side
    .a_d(a_d), 
    .a_wr(a_wr), 
    .a_fifo_full(a_fifo_full),
    .a_q(a_q),
    .a_rd(a_rd),
    .a_fifo_empty(a_fifo_empty), 
    .a_clk(wbs_clk), 
    .a_rst(wbs_rst),
    // b side
    .b_d(b_d), 
    .b_wr(b_wr), 
    .b_fifo_full(b_fifo_full),
    .b_q(b_q), 
    .b_rd(b_rd), 
    .b_fifo_empty(b_fifo_empty), 
    .b_clk(wbm_clk), 
    .b_rst(wbm_rst)	
    );
    
endmodule
`undef WE
`undef BTE
`undef CTI
`endif

`ifdef WB3AVALON_BRIDGE
`define MODULE wb3avalon_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// avalon master side
	readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer, clk, rst);

parameter linewrapburst = 1'b0;

input [31:0] wbs_dat_i;
input [31:2] wbs_adr_i;
input [3:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i;
input wbs_cyc_i;
input wbs_stb_i;
output [31:0] wbs_dat_o;
output wbs_ack_o;
input wbs_clk, wbs_rst;

input [31:0] readdata;
output [31:0] writedata;
output [31:2] address;
output [3:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input readdatavalid;
input waitrequest;
input clk;
input rst;

wire [1:0] wbm_bte_o;
wire [2:0] wbm_cti_o;
wire wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_ack_i;
reg last_cyc;
reg [3:0] counter;
reg read_busy;

always @ (posedge clk or posedge rst)
if (rst)
    last_cyc <= 1'b0;
else
    last_cyc <= wbm_cyc_o;

always @ (posedge clk or posedge rst)
if (rst)
    read_busy <= 1'b0;
else
    if (read & !waitrequest)
        read_busy <= 1'b1;
    else if (wbm_ack_i & wbm_cti_o!=3'b010)
        read_busy <= 1'b0;
assign read = wbm_cyc_o & wbm_stb_o & !wbm_we_o & !read_busy;

assign beginbursttransfer = (!last_cyc & wbm_cyc_o) & wbm_cti_o==3'b010;
assign burstcount = (wbm_bte_o==2'b01) ? 4'd4 :
                    (wbm_bte_o==2'b10) ? 4'd8 :
                    (wbm_bte_o==2'b11) ? 4'd16:
                    4'd1;
assign wbm_ack_i = (readdatavalid) | (write & !waitrequest);

always @ (posedge clk or posedge rst)
if (rst) begin
    counter <= 4'd0;
end else
    if (wbm_we_o) begin
        if (!waitrequest & !last_cyc & wbm_cyc_o) begin
            counter <= burstcount -4'd1;
        end else if (waitrequest & !last_cyc & wbm_cyc_o) begin
            counter <= burstcount;
        end else if (!waitrequest & wbm_stb_o) begin
            counter <= counter - 4'd1;
        end
    end 
assign write = wbm_cyc_o & wbm_stb_o & wbm_we_o & counter!=4'd0;

`define MODULE wb3wb3_bridge
`BASE`MODULE wbwb3inst (
`undef MODULE
    // wishbone slave side
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_we_i(wbs_we_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_clk(wbs_clk),
    .wbs_rst(wbs_rst),
    // wishbone master side
    .wbm_dat_o(writedata),
    .wbm_adr_o(address),
    .wbm_sel_o(be),
    .wbm_bte_o(wbm_bte_o),
    .wbm_cti_o(wbm_cti_o),
    .wbm_we_o(wbm_we_o),
    .wbm_cyc_o(wbm_cyc_o),
    .wbm_stb_o(wbm_stb_o),
    .wbm_dat_i(readdata),
    .wbm_ack_i(wbm_ack_i),
    .wbm_clk(clk),
    .wbm_rst(rst));


endmodule
`endif

`ifdef WB_ARBITER
`define MODULE wb_arbiter
module `BASE`MODULE (
`undef MODULE
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o,
    wbm_dat_i, wbm_stall_i, wbm_ack_i, wbm_err_i, wbm_rty_i,
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i,
    wbs_dat_o, wbs_stall_o, wbs_ack_o, wbs_err_o, wbs_rty_o,
    wb_clk, wb_rst
);

parameter nr_of_ports = 3;
parameter adr_size = 26;
parameter adr_lo   = 2;
parameter dat_size = 32;
parameter sel_size = dat_size/8;

localparam aw = (adr_size - adr_lo) * nr_of_ports;
localparam dw = dat_size * nr_of_ports;
localparam sw = sel_size * nr_of_ports;
localparam cw = 3 * nr_of_ports;
localparam bw = 2 * nr_of_ports;

input  [dw-1:0] wbm_dat_o;
input  [aw-1:0] wbm_adr_o;
input  [sw-1:0] wbm_sel_o;
input  [cw-1:0] wbm_cti_o;
input  [bw-1:0] wbm_bte_o;
input  [nr_of_ports-1:0] wbm_we_o, wbm_stb_o, wbm_cyc_o;
output [dw-1:0] wbm_dat_i;
output [nr_of_ports-1:0] wbm_stall_o, wbm_ack_i, wbm_err_i, wbm_rty_i;

output [dat_size-1:0] wbs_dat_i;
output [adr_size-1:adr_lo] wbs_adr_i;
output [sel_size-1:0] wbs_sel_i;
output [2:0] wbs_cti_i;
output [1:0] wbs_bte_i;
output wbs_we_i, wbs_stb_i, wbs_cyc_i;
input  [dat_size-1:0] wbs_dat_o;
input  wbs_stall_o, wbs_ack_o, wbs_err_o, wbs_rty_o;

input wb_clk, wb_rst;

reg  [nr_of_ports-1:0] select;
wire [nr_of_ports-1:0] state;
wire [nr_of_ports-1:0] eoc; // end-of-cycle
wire [nr_of_ports-1:0] sel;
wire idle;

genvar i;

assign idle = !(|state);

generate
if (nr_of_ports == 2) begin

    wire [2:0] wbm1_cti_o, wbm0_cti_o;

    assign {wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[1],!wbm_cyc_o[1] & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        2'b1x : select = 2'b10;
        2'b01 : select = 2'b01;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
        
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 3) begin

    wire [2:0] wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        3'b1xx : select = 3'b100;
        3'b01x : select = 3'b010;
        3'b001 : select = 3'b001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};

//    assign select = (idle) ? {wbm_cyc_o[2],!wbm_cyc_o[2] & wbm_cyc_o[1],wbm_cyc_o[2:1]==2'b00 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 4) begin

    wire [2:0] wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        4'b1xxx : select = 4'b1000;
        4'b01xx : select = 4'b0100;
        4'b001x : select = 4'b0010;
        4'b0001 : select = 4'b0001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 5) begin

    wire [2:0] wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        5'b1xxxx : select = 5'b10000;
        5'b01xxx : select = 5'b01000;
        5'b001xx : select = 5'b00100;
        5'b0001x : select = 5'b00010;
        5'b00001 : select = 5'b00001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 6) begin

    wire [2:0] wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        6'b1xxxxx : select = 6'b100000;
        6'b01xxxx : select = 6'b010000;
        6'b001xxx : select = 6'b001000;
        6'b0001xx : select = 6'b000100;
        6'b00001x : select = 6'b000010;
        6'b000001 : select = 6'b000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 7) begin

    wire [2:0] wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        7'b1xxxxxx : select = 7'b1000000;
        7'b01xxxxx : select = 7'b0100000;
        7'b001xxxx : select = 7'b0010000;
        7'b0001xxx : select = 7'b0001000;
        7'b00001xx : select = 7'b0000100;
        7'b000001x : select = 7'b0000010;
        7'b0000001 : select = 7'b0000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[6] = (wbm_ack_i[6] & (wbm6_cti_o == 3'b000 | wbm6_cti_o == 3'b111)) | !wbm_cyc_o[6];
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
if (nr_of_ports == 8) begin

    wire [2:0] wbm7_cti_o, wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o, wbm1_cti_o, wbm0_cti_o;

    assign {wbm7_cti_o, wbm6_cti_o, wbm5_cti_o, wbm4_cti_o, wbm3_cti_o, wbm2_cti_o,wbm1_cti_o,wbm0_cti_o} = wbm_cti_o;
    
    //assign select = (idle) ? {wbm_cyc_o[3],!wbm_cyc_o[3] & wbm_cyc_o[2],wbm_cyc_o[3:2]==2'b00 & wbm_cyc_o[1],wbm_cyc_o[3:1]==3'b000 & wbm_cyc_o[0]} : {nr_of_ports{1'b0}};
    
    always @ (idle or wbm_cyc_o)
    if (idle)
        casex (wbm_cyc_o)
        8'b1xxxxxxx : select = 8'b10000000;
        8'b01xxxxxx : select = 8'b01000000;
        8'b001xxxxx : select = 8'b00100000;
        8'b0001xxxx : select = 8'b00010000;
        8'b00001xxx : select = 8'b00001000;
        8'b000001xx : select = 8'b00000100;
        8'b0000001x : select = 8'b00000010;
        8'b00000001 : select = 8'b00000001;
        default : select = {nr_of_ports{1'b0}};
        endcase
    else
        select = {nr_of_ports{1'b0}};
    
    assign eoc[7] = (wbm_ack_i[7] & (wbm7_cti_o == 3'b000 | wbm7_cti_o == 3'b111)) | !wbm_cyc_o[7];
    assign eoc[6] = (wbm_ack_i[6] & (wbm6_cti_o == 3'b000 | wbm6_cti_o == 3'b111)) | !wbm_cyc_o[6];
    assign eoc[5] = (wbm_ack_i[5] & (wbm5_cti_o == 3'b000 | wbm5_cti_o == 3'b111)) | !wbm_cyc_o[5];
    assign eoc[4] = (wbm_ack_i[4] & (wbm4_cti_o == 3'b000 | wbm4_cti_o == 3'b111)) | !wbm_cyc_o[4];
    assign eoc[3] = (wbm_ack_i[3] & (wbm3_cti_o == 3'b000 | wbm3_cti_o == 3'b111)) | !wbm_cyc_o[3];
    assign eoc[2] = (wbm_ack_i[2] & (wbm2_cti_o == 3'b000 | wbm2_cti_o == 3'b111)) | !wbm_cyc_o[2];
    assign eoc[1] = (wbm_ack_i[1] & (wbm1_cti_o == 3'b000 | wbm1_cti_o == 3'b111)) | !wbm_cyc_o[1];
    assign eoc[0] = (wbm_ack_i[0] & (wbm0_cti_o == 3'b000 | wbm0_cti_o == 3'b111)) | !wbm_cyc_o[0];
    
end
endgenerate

generate
for (i=0;i<nr_of_ports;i=i+1) begin : spr0
`define MODULE spr
    `BASE`MODULE sr0( .sp(select[i]), .r(eoc[i]), .q(state[i]), .clk(wb_clk), .rst(wb_rst));
`undef MODULE
end
endgenerate

    assign sel = select | state;

`define MODULE mux_andor
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(32)) mux0 ( .a(wbm_dat_o), .sel(sel), .dout(wbs_dat_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(adr_size-adr_lo)) mux1 ( .a(wbm_adr_o), .sel(sel), .dout(wbs_adr_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(sel_size)) mux2 ( .a(wbm_sel_o), .sel(sel), .dout(wbs_sel_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(3)) mux3 ( .a(wbm_cti_o), .sel(sel), .dout(wbs_cti_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(2)) mux4 ( .a(wbm_bte_o), .sel(sel), .dout(wbs_bte_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(1)) mux5 ( .a(wbm_we_o), .sel(sel), .dout(wbs_we_i));
    `BASE`MODULE # ( .nr_of_ports(nr_of_ports), .width(1)) mux6 ( .a(wbm_stb_o), .sel(sel), .dout(wbs_stb_i));
`undef MODULE
    assign wbs_cyc_i = |sel;
    
    assign wbm_dat_i = {nr_of_ports{wbs_dat_o}};
    assign wbm_ack_i = {nr_of_ports{wbs_ack_o}} & sel;
    assign wbm_err_i = {nr_of_ports{wbs_err_o}} & sel;
    assign wbm_rty_i = {nr_of_ports{wbs_rty_o}} & sel;

endmodule
`endif

`ifdef WB_RAM
// WB RAM with byte enable
`define MODULE wb_ram
module `BASE`MODULE (
`undef MODULE
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o, wb_clk, wb_rst);

parameter adr_width = 16;
parameter mem_size = 1<<adr_width;
parameter dat_width = 32;
parameter max_burst_width = 4; // only used for B3
parameter mode = "B3"; // valid options: B3, B4
parameter memory_init = 1;
parameter memory_file = "vl_ram.vmem";

input [dat_width-1:0] wbs_dat_i;
input [adr_width-1:0] wbs_adr_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input [dat_width/8-1:0] wbs_sel_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wb_clk, wb_rst;

wire [adr_width-1:0] adr;
wire we;

generate
if (mode=="B3") begin : B3_inst
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(adr_width), .max_burst_width(max_burst_width)) adr_inc0 (
    .cyc_i(wbs_cyc_i),
    .stb_i(wbs_stb_i),
    .cti_i(wbs_cti_i),
    .bte_i(wbs_bte_i),
    .adr_i(wbs_adr_i),
    .we_i(wbs_we_i),
    .ack_o(wbs_ack_o),
    .adr_o(adr),
    .clk(wb_clk),
    .rst(wb_rst));
`undef MODULE
assign we = wbs_we_i & wbs_ack_o;
end else if (mode=="B4") begin : B4_inst
reg wbs_ack_o_reg;
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wbs_ack_o_reg <= 1'b0;
    else
        wbs_ack_o_reg <= wbs_stb_i & wbs_cyc_i;
assign wbs_ack_o = wbs_ack_o_reg;
assign wbs_stall_o = 1'b0;
assign adr = wbs_adr_i;
assign we = wbs_we_i & wbs_cyc_i & wbs_stb_i;
end
endgenerate

`define MODULE ram_be
`BASE`MODULE # (
    .data_width(dat_width),
    .addr_width(adr_width),
    .mem_size(mem_size),
    .memory_init(memory_init),
    .memory_file(memory_file))
ram0(
`undef MODULE
    .d(wbs_dat_i),
    .adr(adr),
    .be(wbs_sel_i),
    .we(we),
    .q(wbs_dat_o),
    .clk(wb_clk)
);

endmodule
`endif

`ifdef WB_SHADOW_RAM
// A wishbone compliant RAM module that can be placed in front of other memory controllers
`define MODULE wb_shadow_ram
module `BASE`MODULE (
`undef MODULE
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o,
    wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o, wbm_cyc_o, 
    wbm_dat_i, wbm_ack_i, wbm_stall_i,
    wb_clk, wb_rst);

parameter dat_width = 32;
parameter mode = "B4";
parameter max_burst_width = 4; // only used for B3

parameter shadow_mem_adr_width = 10;
parameter shadow_mem_size = 1024;
parameter shadow_mem_init = 2;
parameter shadow_mem_file = "vl_ram.v";

parameter main_mem_adr_width = 24;

input [dat_width-1:0] wbs_dat_i;
input [main_mem_adr_width-1:0] wbs_adr_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input [dat_width/8-1:0] wbs_sel_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;

output [dat_width-1:0] wbm_dat_o;
output [main_mem_adr_width-1:0] wbm_adr_o;
output [2:0] wbm_cti_o;
output [1:0] wbm_bte_o;
output [dat_width/8-1:0] wbm_sel_o;
output wbm_we_o, wbm_stb_o, wbm_cyc_o;
input [dat_width-1:0] wbm_dat_i;
input wbm_ack_i, wbm_stall_i;

input wb_clk, wb_rst;

generate
if (shadow_mem_size>0) begin : shadow_ram_inst

wire cyc;
wire [dat_width-1:0] dat;
wire stall, ack;

assign cyc = wbs_cyc_i & (wbs_adr_i<=shadow_mem_size);
`define MODULE wb_ram
`BASE`MODULE # (
    .dat_width(dat_width),
    .adr_width(shadow_mem_adr_width),
    .mem_size(shadow_mem_size),
    .memory_init(shadow_mem_init),
    .memory_file(shadow_mem_file),
    .mode(mode))
shadow_mem0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i[shadow_mem_adr_width-1:0]),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i (wbs_we_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(cyc), 
    .wbs_dat_o(dat),
    .wbs_stall_o(stall),
    .wbs_ack_o(ack),
    .wb_clk(wb_clk),
    .wb_rst(wb_rst));
`undef MODULE

assign {wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o} =
       {wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i};
assign wbm_cyc_o = wbs_cyc_i & (wbs_adr_i>shadow_mem_size);

assign wbs_dat_o = (dat & {dat_width{cyc}}) | (wbm_dat_i & {dat_width{wbm_cyc_o}});
assign wbs_ack_o = (ack & cyc) | (wbm_ack_i & wbm_cyc_o);
assign wbs_stall_o = (stall & cyc) | (wbm_stall_i & wbm_cyc_o);

end else begin : no_shadow_ram_inst

assign {wbm_dat_o, wbm_adr_o, wbm_cti_o, wbm_bte_o, wbm_sel_o, wbm_we_o, wbm_stb_o, wbm_cyc_o} =
       {wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i};
assign {wbs_dat_o, wbs_ack_o, wbs_stall_o} = {wbm_dat_i, wbm_ack_i, wbm_stall_i};

end
endgenerate

endmodule
`endif

`ifdef WB_B4_ROM
// WB ROM
`define MODULE wb_b4_rom
module `BASE`MODULE (
`undef MODULE
    wb_adr_i, wb_stb_i, wb_cyc_i, 
    wb_dat_o, stall_o, wb_ack_o, wb_clk, wb_rst);

    parameter dat_width = 32;
    parameter dat_default = 32'h15000000;
    parameter adr_width = 32;

/*
//E2_ifndef ROM
//E2_define ROM "rom.v"
//E2_endif
*/   
    input [adr_width-1:2]   wb_adr_i;
    input 		    wb_stb_i;
    input 		    wb_cyc_i;
    output [dat_width-1:0]  wb_dat_o;
    reg [dat_width-1:0]     wb_dat_o;
    output  		    wb_ack_o;
    reg                     wb_ack_o;
    output                  stall_o;
    input 		    wb_clk;
    input 		    wb_rst;

always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_dat_o <= {dat_width{1'b0}};
    else
	 case (wb_adr_i[adr_width-1:2])
//E2_ifdef ROM
//E2_include `ROM
//E2_endif
	   default:
	     wb_dat_o <= dat_default;
	     
	 endcase // case (wb_adr_i)

   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_ack_o <= 1'b0;
    else
        wb_ack_o <= wb_stb_i & wb_cyc_i;

assign stall_o = 1'b0;

endmodule
`endif


`ifdef WB_BOOT_ROM
// WB ROM
`define MODULE wb_boot_rom
module `BASE`MODULE (
`undef MODULE
    wb_adr_i, wb_stb_i, wb_cyc_i, 
    wb_dat_o, wb_ack_o, hit_o, wb_clk, wb_rst);

    parameter adr_hi = 31;
    parameter adr_lo = 28;
    parameter adr_sel = 4'hf;
    parameter addr_width = 5;
/*
//E2_ifndef BOOT_ROM
//E2_define BOOT_ROM "boot_rom.v"
//E2_endif
*/   
    input [adr_hi:2]    wb_adr_i;
    input 		wb_stb_i;
    input 		wb_cyc_i;
    output [31:0] 	wb_dat_o;
    output  		wb_ack_o;
    output              hit_o;
    input 		wb_clk;
    input 		wb_rst;

    wire hit;
    reg [31:0] wb_dat;
    reg wb_ack;
    
assign hit = wb_adr_i[adr_hi:adr_lo] == adr_sel;
   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_dat <= 32'h15000000;
    else
	 case (wb_adr_i[addr_width-1:2])
//E2_ifdef BOOT_ROM
//E2_include `BOOT_ROM
//E2_endif
	   /*	 
	    // Zero r0 and jump to 0x00000100
	    0 : wb_dat <= 32'h18000000;
	    1 : wb_dat <= 32'hA8200000;
	    2 : wb_dat <= 32'hA8C00100;
	    3 : wb_dat <= 32'h44003000;
	    4 : wb_dat <= 32'h15000000;
	    */
	   default:
	     wb_dat <= 32'h00000000;
	     
	 endcase // case (wb_adr_i)

   
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_ack <= 1'b0;
    else
        wb_ack <= wb_stb_i & wb_cyc_i & hit & !wb_ack;

assign hit_o = hit;
assign wb_dat_o = wb_dat & {32{wb_ack}};
assign wb_ack_o = wb_ack;

endmodule
`endif

`ifdef WB_DPRAM
`define MODULE wb_dpram
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side a
	wbsa_dat_i, wbsa_adr_i, wbsa_sel_i, wbsa_cti_i, wbsa_bte_i, wbsa_we_i, wbsa_cyc_i, wbsa_stb_i, wbsa_dat_o, wbsa_ack_o, wbsa_stall_o,
        wbsa_clk, wbsa_rst,
	// wishbone slave side b
	wbsb_dat_i, wbsb_adr_i, wbsb_sel_i, wbsb_cti_i, wbsb_bte_i, wbsb_we_i, wbsb_cyc_i, wbsb_stb_i, wbsb_dat_o, wbsb_ack_o, wbsb_stall_o,
        wbsb_clk, wbsb_rst);

parameter data_width_a = 32;
parameter data_width_b = data_width_a;
parameter addr_width_a = 8;
localparam addr_width_b = data_width_a * addr_width_a / data_width_b;
parameter mem_size = (addr_width_a>addr_width_b) ? (1<<addr_width_a) : (1<<addr_width_b);
parameter max_burst_width_a = 4;
parameter max_burst_width_b = max_burst_width_a;
parameter mode = "B3";
parameter memory_init = 0;
parameter memory_file = "vl_ram.v";
parameter debug = 0;
input [data_width_a-1:0] wbsa_dat_i;
input [addr_width_a-1:0] wbsa_adr_i;
input [data_width_a/8-1:0] wbsa_sel_i;
input [2:0] wbsa_cti_i;
input [1:0] wbsa_bte_i;
input wbsa_we_i, wbsa_cyc_i, wbsa_stb_i;
output [data_width_a-1:0] wbsa_dat_o;
output wbsa_ack_o;
output wbsa_stall_o;
input wbsa_clk, wbsa_rst;

input [data_width_b-1:0] wbsb_dat_i;
input [addr_width_b-1:0] wbsb_adr_i;
input [data_width_b/8-1:0] wbsb_sel_i;
input [2:0] wbsb_cti_i;
input [1:0] wbsb_bte_i;
input wbsb_we_i, wbsb_cyc_i, wbsb_stb_i;
output [data_width_b-1:0] wbsb_dat_o;
output wbsb_ack_o;
output wbsb_stall_o;
input wbsb_clk, wbsb_rst;

wire [addr_width_a-1:0] adr_a;
wire [addr_width_b-1:0] adr_b;
wire we_a, we_b;
generate
if (mode=="B3") begin : b3_inst
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(addr_width_a), .max_burst_width(max_burst_width_a)) adr_inc0 (
    .cyc_i(wbsa_cyc_i),
    .stb_i(wbsa_stb_i),
    .cti_i(wbsa_cti_i),
    .bte_i(wbsa_bte_i),
    .adr_i(wbsa_adr_i),
    .we_i(wbsa_we_i),
    .ack_o(wbsa_ack_o),
    .adr_o(adr_a),
    .clk(wbsa_clk),
    .rst(wbsa_rst));
assign we_a = wbsa_we_i & wbsa_ack_o;
`BASE`MODULE # ( .adr_width(addr_width_b), .max_burst_width(max_burst_width_b)) adr_inc1 (
    .cyc_i(wbsb_cyc_i),
    .stb_i(wbsb_stb_i),
    .cti_i(wbsb_cti_i),
    .bte_i(wbsb_bte_i),
    .adr_i(wbsb_adr_i),
    .we_i(wbsb_we_i),
    .ack_o(wbsb_ack_o),
    .adr_o(adr_b),
    .clk(wbsb_clk),
    .rst(wbsb_rst));
`undef MODULE
assign we_b = wbsb_we_i & wbsb_ack_o;
end else if (mode=="B4") begin : b4_inst
assign adr_a = wbsa_adr_i;
`define MODULE dff
`BASE`MODULE dffacka ( .d(wbsa_stb_i & wbsa_cyc_i), .q(wbsa_ack_o), .clk(wbsa_clk), .rst(wbsa_rst));
assign wbsa_stall_o = 1'b0;
assign we_a = wbsa_we_i & wbsa_cyc_i & wbsa_stb_i;
assign adr_b = wbsb_adr_i;
`BASE`MODULE dffackb ( .d(wbsb_stb_i & wbsb_cyc_i), .q(wbsb_ack_o), .clk(wbsb_clk), .rst(wbsb_rst));
`undef MODULE
assign wbsb_stall_o = 1'b0;
assign we_b = wbsb_we_i & wbsb_cyc_i & wbsb_stb_i;
end
endgenerate

`define MODULE dpram_be_2r2w
`BASE`MODULE # ( .a_data_width(data_width_a), .a_addr_width(addr_width_a), .mem_size(mem_size),
                 .b_data_width(data_width_b),
                 .memory_init(memory_init), .memory_file(memory_file),
                 .debug(debug))
`undef MODULE
ram_i (
    .d_a(wbsa_dat_i),
    .q_a(wbsa_dat_o),
    .adr_a(adr_a),
    .be_a(wbsa_sel_i),
    .we_a(we_a),
    .clk_a(wbsa_clk),
    .d_b(wbsb_dat_i),
    .q_b(wbsb_dat_o),
    .adr_b(adr_b),
    .be_b(wbsb_sel_i),
    .we_b(we_b),
    .clk_b(wbsb_clk) );

endmodule
`endif

`ifdef WB_CACHE
`define MODULE wb_cache
module `BASE`MODULE (
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, wbs_dat_o, wbs_ack_o, wbs_stall_o, wbs_clk, wbs_rst,
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o, wbm_dat_i, wbm_ack_i, wbm_stall_i, wbm_clk, wbm_rst
);
`undef MODULE

parameter dw_s = 32;
parameter aw_s = 24;
parameter dw_m = dw_s;
//localparam aw_m = dw_s * aw_s / dw_m;
localparam aw_m = 
	(dw_s==dw_m) ? aw_s : 
	(dw_s==dw_m*2) ? aw_s+1 : 
	(dw_s==dw_m*4) ? aw_s+2 : 
	(dw_s==dw_m*8) ? aw_s+3 : 
	(dw_s==dw_m*16) ? aw_s+4 : 
	(dw_s==dw_m*32) ? aw_s+5 : 
	(dw_s==dw_m/2) ? aw_s-1 : 
	(dw_s==dw_m/4) ? aw_s-2 : 
	(dw_s==dw_m/8) ? aw_s-3 : 
	(dw_s==dw_m/16) ? aw_s-4 : 
	(dw_s==dw_m/32) ? aw_s-5 : 0;

parameter wbs_max_burst_width = 4;
parameter wbs_mode = "B3";

parameter async = 1; // wbs_clk != wbm_clk

parameter nr_of_ways = 1;
parameter aw_offset = 4; // 4 => 16 words per cache line
parameter aw_slot = 10;

parameter valid_mem = 0;
parameter debug = 0;

localparam aw_b_offset = aw_offset * dw_s / dw_m;
localparam aw_tag = aw_s - aw_slot - aw_offset;
parameter wbm_burst_size = 4; // valid options 4,8,16
localparam bte = (wbm_burst_size==4) ? 2'b01 : (wbm_burst_size==8) ? 2'b10 : 2'b11;
`define SIZE2WIDTH wbm_burst_size
localparam wbm_burst_width `SIZE2WIDTH_EXPR
`undef SIZE2WIDTH
localparam nr_of_wbm_burst = ((1<<aw_offset)/wbm_burst_size) * dw_s / dw_m; 
`define SIZE2WIDTH nr_of_wbm_burst
localparam nr_of_wbm_burst_width `SIZE2WIDTH_EXPR
`undef SIZE2WIDTH

input [dw_s-1:0] wbs_dat_i;
input [aw_s-1:0] wbs_adr_i; // dont include a1,a0
input [dw_s/8-1:0] wbs_sel_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [dw_s-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wbs_clk, wbs_rst;

output [dw_m-1:0] wbm_dat_o;
output [aw_m-1:0] wbm_adr_o;
output [dw_m/8-1:0] wbm_sel_o;
output [2:0] wbm_cti_o;
output [1:0] wbm_bte_o;
output wbm_stb_o, wbm_cyc_o, wbm_we_o;
input [dw_m-1:0] wbm_dat_i;
input wbm_ack_i;
input wbm_stall_i;
input wbm_clk, wbm_rst;

wire valid, dirty, hit;
wire [aw_tag-1:0] tag;
wire tag_mem_we;
wire [aw_tag-1:0] wbs_adr_tag;
wire [aw_slot-1:0] wbs_adr_slot;
wire [aw_offset-1:0] wbs_adr_word;
wire [aw_s-1:0] wbs_adr;

reg [1:0] state;
localparam idle = 2'h0;
localparam rdwr = 2'h1;
localparam push = 2'h2;
localparam pull = 2'h3;
wire eoc;
wire we;

// cdc
wire done, mem_alert, mem_done;

// wbm side
reg [aw_m-1:0] wbm_radr;
reg [aw_m-1:0] wbm_wadr;
//wire [aw_slot-1:0] wbm_adr;
wire [aw_m-1:0] wbm_adr;
wire wbm_radr_cke, wbm_wadr_cke;

reg [2:0] phase;
// phase = {we,stb,cyc}
localparam wbm_wait     = 3'b000;
localparam wbm_wr       = 3'b111;
localparam wbm_wr_drain = 3'b101;
localparam wbm_rd       = 3'b011;
localparam wbm_rd_drain = 3'b001;

assign {wbs_adr_tag, wbs_adr_slot, wbs_adr_word} = wbs_adr_i;

generate
if (valid_mem==0) begin : no_valid_mem
assign valid = 1'b1;
end else begin : valid_mem_inst
`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(1), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    valid_mem ( .d_a(1'b1), .adr_a(wbs_adr_slot), .we_a(mem_done), .clk_a(wbm_clk),
                .q_b(valid), .adr_b(wbs_adr_slot), .clk_b(wbs_clk));
`undef MODULE
end
endgenerate

`define MODULE dpram_1r1w
`BASE`MODULE
    # ( .data_width(aw_tag), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    tag_mem ( .d_a(wbs_adr_tag), .adr_a(wbs_adr_slot), .we_a(mem_done), .clk_a(wbm_clk),
              .q_b(tag), .adr_b(wbs_adr_slot), .clk_b(wbs_clk));
assign hit = wbs_adr_tag == tag;
`undef MODULE

`define MODULE dpram_1r2w
`BASE`MODULE
    # ( .data_width(1), .addr_width(aw_slot), .memory_init(2), .debug(debug))
    dirty_mem (
        .d_a(1'b1), .q_a(dirty), .adr_a(wbs_adr_slot), .we_a(wbs_cyc_i & wbs_we_i & wbs_ack_o), .clk_a(wbs_clk),
        .d_b(1'b0), .adr_b(wbs_adr_slot), .we_b(mem_done), .clk_b(wbm_clk));
`undef MODULE

generate
if (wbs_mode=="B3") begin : inst_b3
`define MODULE wb_adr_inc 
`BASE`MODULE # ( .adr_width(aw_s), .max_burst_width(wbs_max_burst_width)) adr_inc0 (
    .cyc_i(wbs_cyc_i & (state==rdwr) & hit & valid),
    .stb_i(wbs_stb_i & (state==rdwr) & hit & valid), // throttle depending on valid
    .cti_i(wbs_cti_i),
    .bte_i(wbs_bte_i),
    .adr_i(wbs_adr_i),
    .we_i (wbs_we_i),
    .ack_o(wbs_ack_o),
    .adr_o(wbs_adr),
    .clk(wbs_clk),
    .rst(wbs_rst));
`undef MODULE
assign eoc = (wbs_cti_i==3'b000 | wbs_cti_i==3'b111) & wbs_ack_o;
assign we = wbs_cyc_i &  wbs_we_i & wbs_ack_o;
end else if (wbs_mode=="B4") begin : inst_b4
end

endgenerate
localparam cache_mem_b_aw =
    (dw_s==dw_m) ? aw_slot+aw_offset :
    (dw_s==dw_m/2) ? aw_slot+aw_offset-1 :
    (dw_s==dw_m/4) ? aw_slot+aw_offset-2 :
    (dw_s==dw_m/8) ? aw_slot+aw_offset-3 :
    (dw_s==dw_m/16) ? aw_slot+aw_offset-4 :
    (dw_s==dw_m*2) ? aw_slot+aw_offset+1 :
    (dw_s==dw_m*4) ? aw_slot+aw_offset+2 :
    (dw_s==dw_m*8) ? aw_slot+aw_offset+3 :
    (dw_s==dw_m*16) ? aw_slot+aw_offset+4 : 0;

`define MODULE dpram_be_2r2w
`BASE`MODULE
    # ( .a_data_width(dw_s), .a_addr_width(aw_slot+aw_offset), .b_data_width(dw_m), .debug(debug))
    cache_mem ( .d_a(wbs_dat_i), .adr_a(wbs_adr[aw_slot+aw_offset-1:0]),   .be_a(wbs_sel_i), .we_a(we), .q_a(wbs_dat_o), .clk_a(wbs_clk),
                .d_b(wbm_dat_i), .adr_b(wbm_adr[cache_mem_b_aw-1:0]), .be_b(wbm_sel_o), .we_b(wbm_cyc_o & !wbm_we_o & wbm_ack_i), .q_b(wbm_dat_o), .clk_b(wbm_clk));
`undef MODULE    

always @ (posedge wbs_clk or posedge wbs_rst)
if (wbs_rst)
    state <= idle;
else
    case (state)
    idle:
        if (wbs_cyc_i)
            state <= rdwr;
    rdwr:
        casex ({valid, hit, dirty, eoc})
        4'b0xxx: state <= pull;
        4'b11x1: state <= idle;
        4'b101x: state <= push;
        4'b100x: state <= pull;
        endcase
    push:
        if (done)
            state <= rdwr;
    pull:
        if (done)
            state <= rdwr;
    default: state <= idle;
    endcase

// cdc
generate
if (async==1) begin : cdc0
`define MODULE cdc
`BASE`MODULE cdc0 ( .start_pl(state==rdwr & (!valid | !hit)), .take_it_pl(mem_alert), .take_it_grant_pl(mem_done), .got_it_pl(done), .clk_src(wbs_clk), .rst_src(wbs_rst), .clk_dst(wbm_clk), .rst_dst(wbm_rst));
`undef MODULE
end
else begin : nocdc
    assign mem_alert = state==rdwr & (!valid | !hit);
    assign done = mem_done;
end
endgenerate

// FSM generating a number of bursts 4 cycles
// actual number depends on data width ratio
// nr_of_wbm_burst
reg [nr_of_wbm_burst_width+wbm_burst_width-1:0]       cnt_rw, cnt_ack;

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    cnt_rw <= {wbm_burst_width{1'b0}};
else
    if (wbm_cyc_o & wbm_stb_o & !wbm_stall_i)
        cnt_rw <= cnt_rw + 1;

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    cnt_ack <= {wbm_burst_width{1'b0}};
else
    if (wbm_ack_i)
        cnt_ack <= cnt_ack + 1;

generate
if (nr_of_wbm_burst==1) begin : one_burst

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    phase <= wbm_wait;
else
    case (phase)
    wbm_wait:
        if (mem_alert)
            if (state==push)
                phase <= wbm_wr;
            else
                phase <= wbm_rd;
    wbm_wr:
        if (&cnt_rw)
            phase <= wbm_wr_drain;
    wbm_wr_drain:
        if (&cnt_ack)
            phase <= wbm_rd;
    wbm_rd:
        if (&cnt_rw)
            phase <= wbm_rd_drain;
    wbm_rd_drain:
        if (&cnt_ack)
            phase <= wbm_wait;
    default: phase <= wbm_wait;
    endcase

end else begin : multiple_burst

always @ (posedge wbm_clk or posedge wbm_rst)
if (wbm_rst)
    phase <= wbm_wait;
else
    case (phase)
    wbm_wait:
        if (mem_alert)
            if (state==push)
                phase <= wbm_wr;
            else
                phase <= wbm_rd;
    wbm_wr:
        if (&cnt_rw[wbm_burst_width-1:0])
            phase <= wbm_wr_drain;
    wbm_wr_drain:
        if (&cnt_ack)
            phase <= wbm_rd;
        else if (&cnt_ack[wbm_burst_width-1:0])
            phase <= wbm_wr;
    wbm_rd:
        if (&cnt_rw[wbm_burst_width-1:0])
            phase <= wbm_rd_drain;
    wbm_rd_drain:
        if (&cnt_ack)
            phase <= wbm_wait;
        else if (&cnt_ack[wbm_burst_width-1:0])
            phase <= wbm_rd;
    default: phase <= wbm_wait;
    endcase


end
endgenerate

assign mem_done = phase==wbm_rd_drain & (&cnt_ack) & wbm_ack_i;

assign wbm_adr_o = (phase[2]) ? {tag, wbs_adr_slot, cnt_rw} : {wbs_adr_tag, wbs_adr_slot, cnt_rw};
assign wbm_adr   = (phase[2]) ? {wbs_adr_slot, cnt_rw} : {wbs_adr_slot, cnt_ack};
assign wbm_sel_o = {dw_m/8{1'b1}};
assign wbm_cti_o = (&cnt_rw | !wbm_stb_o) ? 3'b111 : 3'b010;
assign wbm_bte_o = bte;
assign {wbm_we_o, wbm_stb_o, wbm_cyc_o}  = phase;

endmodule
`endif

`ifdef WB_AVALON_BRIDGE
// Wishbone to avalon bridge supporting one type of burst transfer only
// intended use is together with cache above
// WB B4 -> pipelined avalon
`define MODULE wb_avalon_bridge
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_stall_o,
	// avalon master side
	readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer,
        init_done,
        // common
        clk, rst);

parameter adr_width = 30;
parameter dat_width = 32;
parameter burst_size = 4;

input [dat_width-1:0] wbs_dat_i;
input [adr_width-1:0] wbs_adr_i;
input [dat_width/8-1:0]  wbs_sel_i;
input [1:0]  wbs_bte_i;
input [2:0]  wbs_cti_i;
input wbs_we_i;
input wbs_cyc_i;
input wbs_stb_i;
output [dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;

input [dat_width-1:0] readdata;
input readdatavalid;
output [dat_width-1:0] writedata;
output [adr_width-1:0] address;
output [dat_width/8-1:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input waitrequest;
input init_done;
input clk, rst;

// cnt1 - initiated read or writes
// cnt2 - # of read or writes in pipeline
reg [3:0] cnt1;
reg [3:0] cnt2;

reg next_state, state;
localparam s0 = 1'b0;
localparam s1 = 1'b1;

wire eoc;

always @ *
begin
    case (state)
    s0: if (init_done & wbs_cyc_i) next_state <= s1;
    s1: 
    default: next_state <= state;
    end
end

always @ (posedge clk or posedge rst)
if (rst)
    state <= s0;
else
    state <= next_state;

assign eoc = state==s1 & !(read | write) & (& !waitrequest & cnt2=;
always @ (posedge clk or posedge rst)
if (rst)
    cnt1 <= 4'h0;
else
    if (read & !waitrequest & init_done)
        cnt1 <= burst_size - 1;
    else if (write & !waitrequest & init_done)
        cnt1 <= cnt1 + 4'h1;
    else if (next_state==idle)
        cnt1 <= 4'h0;

always @ (posedge clk or posedge rst)
if (rst)
    cnt2 <= 4'h0;
else
    if (read & !waitrequest & init_done)
        cnt2 <= burst_size - 1;
    else if (write & !waitrequest & init_done & )
        cnt2 <= cnt1 + 4'h1;
    else if (next_state==idle)
        cnt2 <= 4'h0;

reg wr_ack;
always @ (posedge clk or posedge rst)
if (rst)
    wr_ack <= 1'b0;
else
    wr_ack <=  (wbs_we_i & wbs_cyc_i & wbs_stb_i & !wbs_stall_o);

// to avalon
assign writedata = wbs_dat_i;
assign address = wbs_adr_i;
assign be = wbs_sel_i;
assign write = cnt!=4'h0 & wbs_cyc_i &  wbs_we_i;
assign read  = cnt!=4'h0 & wbs_cyc_i & !wbs_we_i;
assign beginbursttransfer = state==s0 & next_state==s1;
assign burstcount = burst_size;

// to wishbone
assign wbs_dat_o = readdata;
assign wbs_ack_o = wr_ack | readdatavalid;
assign wbs_stall_o = waitrequest;

endmodule
`endif

`ifdef WB_AVALON_MEM_CACHE
`define MODULE wb_avalon_mem_cache
module `BASE`MODULE (
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, wbs_dat_o, wbs_ack_o, wbs_stall_o, wbs_clk, wbs_rst,
    readdata, readdatavalid, address, read, be, write, burstcount, writedata, waitrequest, beginbursttransfer, clk, rst
);
`undef MODULE

// wishbone
parameter wb_dat_width = 32;
parameter wb_adr_width = 22;
parameter wb_max_burst_width = 4;
parameter wb_mode = "B4";
// avalon
parameter avalon_dat_width = 32;
//localparam avalon_adr_width = wb_dat_width * wb_adr_width / avalon_dat_width;
localparam avalon_adr_width = 
	(wb_dat_width==avalon_dat_width) ? wb_adr_width : 
	(wb_dat_width==avalon_dat_width*2) ? wb_adr_width+1 : 
	(wb_dat_width==avalon_dat_width*4) ? wb_adr_width+2 : 
	(wb_dat_width==avalon_dat_width*8) ? wb_adr_width+3 : 
	(wb_dat_width==avalon_dat_width*16) ? wb_adr_width+4 : 
	(wb_dat_width==avalon_dat_width*32) ? wb_adr_width+5 : 
	(wb_dat_width==avalon_dat_width/2) ? wb_adr_width-1 : 
	(wb_dat_width==avalon_dat_width/4) ? wb_adr_width-2 : 
	(wb_dat_width==avalon_dat_width/8) ? wb_adr_width-3 : 
	(wb_dat_width==avalon_dat_width/16) ? wb_adr_width-4 : 
	(wb_dat_width==avalon_dat_width/32) ? wb_adr_width-5 : 0;
parameter avalon_burst_size = 4;
// cache
parameter async = 1;
parameter nr_of_ways = 1;
parameter aw_offset = 4;
parameter aw_slot = 10;
parameter valid_mem = 1;
// shadow RAM
parameter shadow_ram = 0;
parameter shadow_ram_adr_width = 10;
parameter shadow_ram_size = 1024;
parameter shadow_ram_init = 2; // 0: no init, 1: from file, 2: with zero
parameter shadow_ram_file = "vl_ram.v";

input [wb_dat_width-1:0] wbs_dat_i;
input [wb_adr_width-1:0] wbs_adr_i; // dont include a1,a0
input [wb_dat_width/8-1:0] wbs_sel_i;
input [2:0] wbs_cti_i;
input [1:0] wbs_bte_i;
input wbs_we_i, wbs_stb_i, wbs_cyc_i;
output [wb_dat_width-1:0] wbs_dat_o;
output wbs_ack_o;
output wbs_stall_o;
input wbs_clk, wbs_rst;

input [avalon_dat_width-1:0] readdata;
input readdatavalid;
output [avalon_dat_width-1:0] writedata;
output [avalon_adr_width-1:0] address;
output [avalon_dat_width/8-1:0]  be;
output write;
output read;
output beginbursttransfer;
output [3:0] burstcount;
input waitrequest;
input clk, rst;

`define DAT_WIDTH wb_dat_width
`define ADR_WIDTH wb_adr_width
`define WB wb1
`include "wb_wires.v"
`undef DAT_WIDTH
`undef ADR_WIDTH
`define DAT_WIDTH avalon_dat_width
`define ADR_WIDTH avalon_adr_width
`define WB wb2
`include "wb_wires.v"
`undef DAT_WIDTH
`undef ADR_WIDTH

`define MODULE wb_shadow_ram
`BASE`MODULE # ( .dat_width(wb_dat_width), .mode(wb_mode), .max_burst_width(wb_max_burst_width),
                 .shadow_mem_adr_width(shadow_ram_adr_width), .shadow_mem_size(shadow_ram_size), .shadow_mem_init(shadow_ram_init), .shadow_mem_file(shadow_ram_file),
                 .main_mem_adr_width(wb_adr_width))
shadow_ram0 (
    .wbs_dat_i(wbs_dat_i), .wbs_adr_i(wbs_adr_i), .wbs_cti_i(wbs_cti_i), .wbs_bte_i(wbs_bte_i), .wbs_sel_i(wbs_sel_i), .wbs_we_i(wbs_we_i), .wbs_stb_i(wbs_stb_i), .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o), .wbs_ack_o(wbs_ack_o), .wbs_stall_o(wbs_stall_o),
    .wbm_dat_o(wb1_dat_o), .wbm_adr_o(wb1_adr_o), .wbm_cti_o(wb1_cti_o), .wbm_bte_o(wb1_bte_o), .wbm_sel_o(wb1_sel_o), .wbm_we_o(wb1_we_o), .wbm_stb_o(wb1_stb_o), .wbm_cyc_o(wb1_cyc_o), 
    .wbm_dat_i(wb1_dat_i), .wbm_ack_i(wb1_ack_i), .wbm_stall_i(wb1_stall_i),
    .wb_clk(wbs_clk), .wb_rst(wbs_rst));
`undef MODULE

`define MODULE wb_cache
`BASE`MODULE
# ( .dw_s(wb_dat_width), .aw_s(wb_adr_width), .dw_m(avalon_dat_width), .wbs_mode(wb_mode), .wbs_max_burst_width(wb_max_burst_width), .async(async), .nr_of_ways(nr_of_ways), .aw_offset(aw_offset), .aw_slot(aw_slot), .valid_mem(valid_mem))
cache0 (
    .wbs_dat_i(wb1_dat_o), .wbs_adr_i(wb1_adr_o), .wbs_sel_i(wb1_sel_o), .wbs_cti_i(wb1_cti_o), .wbs_bte_i(wb1_bte_o), .wbs_we_i(wb1_we_o), .wbs_stb_i(wb1_stb_o), .wbs_cyc_i(wb1_cyc_o),
    .wbs_dat_o(wb1_dat_i), .wbs_ack_o(wb1_ack_i), .wbs_stall_o(wb1_stall_i), .wbs_clk(wbs_clk), .wbs_rst(wbs_rst),
    .wbm_dat_o(wb2_dat_o), .wbm_adr_o(wb2_adr_o), .wbm_sel_o(wb2_sel_o), .wbm_cti_o(wb2_cti_o), .wbm_bte_o(wb2_bte_o), .wbm_we_o(wb2_we_o), .wbm_stb_o(wb2_stb_o), .wbm_cyc_o(wb2_cyc_o),
    .wbm_dat_i(wb2_dat_i), .wbm_ack_i(wb2_ack_i), .wbm_stall_i(wb2_stall_i), .wbm_clk(clk), .wbm_rst(rst));
`undef MODULE

`define MODULE wb_avalon_bridge
`BASE`MODULE # ( .adr_width(avalon_adr_width), .dat_width(avalon_dat_width), .burst_size(avalon_burst_size))
bridge0 ( 
	// wishbone slave side
	.wbs_dat_i(wb2_dat_o), .wbs_adr_i(wb2_adr_o), .wbs_sel_i(wb2_sel_o), .wbs_bte_i(wb2_bte_o), .wbs_cti_i(wb2_cti_o), .wbs_we_i(wb2_we_o), .wbs_cyc_i(wb2_cyc_o), .wbs_stb_i(wb2_stb_o),
        .wbs_dat_o(wb2_dat_i), .wbs_ack_o(wb2_ack_i), .wbs_stall_o(wb2_stall_i),
	// avalon master side
	.readdata(readdata), .readdatavalid(readdatavalid), .address(address), .read(read), .be(be), .write(write), .burstcount(burstcount), .writedata(writedata), .waitrequest(waitrequest), .beginbursttransfer(beginbursttransfer),
        // common
        .clk(clk), .rst(rst));
`undef MODULE

endmodule
`endif

`ifdef WB_SDR_SDRAM
`define MODULE wb_sdr_sdram
module `BASE`MODULE (
`undef MODULE
    // wisbone i/f
    dat_i, adr_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o, stall_o,
    // SDR SDRAM
    ba, a, cmd, cke, cs_n, dqm, dq_i, dq_o, dq_oe,
    // system
    clk, rst);

    // external data bus size
    parameter dat_size = 16;
    // memory geometry parameters
    parameter ba_size  = 2;   
    parameter row_size = 13;
    parameter col_size = 9;
    parameter cl = 2;
    // memory timing parameters
    parameter tRFC = 9;
    parameter tRP  = 2;
    parameter tRCD = 2;
    parameter tMRD = 2;
   
    // LMR
    // [12:10] reserved
    // [9]     WB, write burst; 0 - programmed burst length, 1 - single location
    // [8:7]   OP Mode, 2'b00
    // [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
    // [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
    // [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
    localparam init_wb = 1'b1;
    localparam init_cl = (cl==2) ? 3'b010 : 3'b011;
    localparam init_bt = 1'b0;
    localparam init_bl = 3'b000;
	
    input [dat_size-1:0] dat_i;
    input [ba_size+col_size+row_size-1:0] adr_i;
    input [dat_size/8-1:0] sel_i;
    input we_i, cyc_i, stb_i;
    output [dat_size-1:0] dat_o;
    output ack_o;
    output reg stall_o;
    
    output [ba_size-1:0]    ba;
    output reg [12:0]   a;
    output reg [2:0]    cmd; // {ras,cas,we}
    output cke, cs_n;
    output reg [dat_size/8-1:0]    dqm;
    output [dat_size-1:0]       dq_o;
    output reg          dq_oe;
    input  [dat_size-1:0]       dq_i;

    input clk, rst;

    wire [ba_size-1:0] 	bank;
    wire [row_size-1:0] row;
    wire [col_size-1:0] col;
    wire [0:31] 	shreg; 
    wire 		ref_cnt_zero;
    reg                 refresh_req; 

    wire ack_rd, rd_ack_emptyflag;
    wire ack_wr;

    // to keep track of open rows per bank
    reg [row_size-1:0] 	open_row[0:3];
    reg [0:3] 		open_ba;
    reg 		current_bank_closed, current_row_open;  

    parameter rfr_length = 10;
    parameter rfr_wrap_value = 1010;

    parameter [2:0] cmd_nop = 3'b111,
                    cmd_act = 3'b011,
                    cmd_rd  = 3'b101,
                    cmd_wr  = 3'b100,
                    cmd_pch = 3'b010,
                    cmd_rfr = 3'b001,
                    cmd_lmr = 3'b000;

// ctrl FSM
`define FSM_INIT 3'b000
`define FSM_IDLE 3'b001
`define FSM_RFR  3'b010
`define FSM_ADR  3'b011
`define FSM_PCH  3'b100
`define FSM_ACT  3'b101
`define FSM_RW   3'b111

    assign cke = 1'b1;
    assign cs_n = 1'b0;
	   
    reg [2:0] state, next;

    function [12:0] a10_fix;
        input [col_size-1:0] a;
        integer i;
    begin
	for (i=0;i<13;i=i+1) begin
            if (i<10)
              if (i<col_size)
                a10_fix[i] = a[i];
              else
                a10_fix[i] = 1'b0;
            else if (i==10)
              a10_fix[i] = 1'b0;
            else
              if (i<col_size)
                a10_fix[i] = a[i-1];
              else
                a10_fix[i] = 1'b0;
	end
    end
    endfunction

    assign {bank,row,col} = adr_i;

    always @ (posedge clk or posedge rst)
    if (rst)
       state <= `FSM_INIT;
    else
       state <= next;
   
    always @*
    begin
	next = state;
	case (state)
	`FSM_INIT:
            if (shreg[3+tRP+tRFC+tRFC+tMRD]) next = `FSM_IDLE;
        `FSM_IDLE:   
	    if (refresh_req) next = `FSM_RFR;
            else if (cyc_i & stb_i & rd_ack_emptyflag) next = `FSM_ADR;
        `FSM_RFR: 
            if (shreg[tRP+tRFC-2]) next = `FSM_IDLE; // take away two cycles because no cmd will be issued in idle and adr
	`FSM_ADR:
            if (current_bank_closed) next = `FSM_ACT;
	    else if (current_row_open) next = `FSM_RW;
	    else next = `FSM_PCH;
	`FSM_PCH: 
            if (shreg[tRP]) next = `FSM_ACT;
	`FSM_ACT:
            if (shreg[tRCD]) next = `FSM_RW;
	`FSM_RW:
            if (!stb_i) next = `FSM_IDLE;
	endcase
    end

    // counter
`define MODULE cnt_shreg_clear 
    `BASE`MODULE # ( .length(32))
`undef MODULE
        cnt0 (
            .clear(state!=next),
            .q(shreg),
            .rst(rst),
            .clk(clk));

    // ba, a, cmd
    // outputs dependent on state vector
    always @ (*)
        begin
   	    {a,cmd} = {13'd0,cmd_nop};
            dqm = 2'b11;
            dq_oe = 1'b0;
            stall_o = 1'b1;
            case (state)
            `FSM_INIT:
                if (shreg[3]) begin
                    {a,cmd} = {13'b0010000000000, cmd_pch};
                end else if (shreg[3+tRP] | shreg[3+tRP+tRFC])
                    {a,cmd} = {13'd0, cmd_rfr};
                else if (shreg[3+tRP+tRFC+tRFC])
                    {a,cmd} = {3'b000,init_wb,2'b00,init_cl,init_bt,init_bl,cmd_lmr};
            `FSM_RFR:
        	if (shreg[0])
                    {a,cmd} = {13'b0010000000000, cmd_pch};
        	else if (shreg[tRP])
                    {a,cmd} = {13'd0, cmd_rfr};
	    `FSM_PCH:
        	if (shreg[0])
                    {a,cmd} = {13'd0,cmd_pch};
            `FSM_ACT:
                if (shreg[0])
                    {a[row_size-1:0],cmd} = {row,cmd_act};
            `FSM_RW:
                begin
                    if (we_i)
                        cmd = cmd_wr;
                    else
                        cmd = cmd_rd;
                    if (we_i)
                        dqm = ~sel_i;
                    else
                        dqm = 2'b00;
                    if (we_i)
                        dq_oe = 1'b1;
                    a = a10_fix(col);
                    stall_o = 1'b0;
                end
            endcase
        end

    assign ba = bank;
    
    // precharge individual bank A10=0
    // precharge all bank A10=1
    genvar i;
    generate
    for (i=0;i<2<<ba_size-1;i=i+1) begin : open_ba_logic
    
        always @ (posedge clk or posedge rst)
        if (rst)
            {open_ba[i],open_row[i]} <= {1'b0,{row_size{1'b0}}};
        else
            if (cmd==cmd_pch & (a[10] | bank==i))
                open_ba[i] <= 1'b0;
            else if (cmd==cmd_act & bank==i)
                {open_ba[i],open_row[i]} <= {1'b1,row};

    end
    endgenerate

    // bank and row open ?
    always @ (posedge clk or posedge rst)
    if (rst)
       {current_bank_closed, current_row_open} <= {1'b1, 1'b0};
    else
       {current_bank_closed, current_row_open} <= {!(open_ba[bank]), open_row[bank]==row};

    // refresh counter
`define MODULE cnt_lfsr_zq  
    `BASE`MODULE # ( .length(rfr_length), .wrap_value (rfr_wrap_value)) ref_counter0( .zq(ref_cnt_zero), .rst(rst), .clk(clk));
`undef MODULE

    always @ (posedge clk or posedge rst)
    if (rst)
    	refresh_req <= 1'b0;
    else
    	if (ref_cnt_zero)
            refresh_req <= 1'b1;
       	else if (state==`FSM_RFR)
            refresh_req <= 1'b0;

    assign dat_o = dq_i;
    
    assign ack_wr = (state==`FSM_RW & we_i);
`define MODULE delay_emptyflag  
    `BASE`MODULE # ( .depth(cl+2)) delay0 ( .d(state==`FSM_RW & stb_i & !we_i), .q(ack_rd), .emptyflag(rd_ack_emptyflag), .clk(clk), .rst(rst));
`undef MODULE
    assign ack_o = ack_rd | ack_wr;

    assign dq_o = dat_i;

endmodule
`endif

`ifdef WB_SDR_SDRAM_CTRL
`define MODULE wb_sdr_sdram_ctrl
module `BASE`MODULE (
    // WB i/f
    wbs_dat_i, wbs_adr_i, wbs_cti_i, wbs_bte_i, wbs_sel_i, wbs_we_i, wbs_stb_i, wbs_cyc_i, 
    wbs_dat_o, wbs_ack_o, wbs_stall_o,
    // SDR SDRAM
    mem_ba, mem_a, mem_cmd, mem_cke, mem_cs_n, mem_dqm, mem_dq_i, mem_dq_o, mem_dq_oe,
    // system
    wb_clk, wb_rst, mem_clk, mem_rst);
`undef MODULE

    // WB slave
    parameter wbs_dat_width = 32;
    parameter wbs_adr_width = 24;
    parameter wbs_mode = "B3";
    parameter wbs_max_burst_width = 4;

    // Shadow RAM
    parameter shadow_mem_adr_width = 10;
    parameter shadow_mem_size = 1024;
    parameter shadow_mem_init = 2;
    parameter shadow_mem_file = "vl_ram.v";

    // Cache
    parameter cache_async = 1; // wbs_clk != wbm_clk
    parameter cache_nr_of_ways = 1;
    parameter cache_aw_offset = 4; // 4 => 16 words per cache line
    parameter cache_aw_slot = 10;
    parameter cache_valid_mem = 0;
    parameter cache_debug = 0;
    
    // SDRAM parameters
    parameter mem_dat_size = 16;
    parameter mem_ba_size  = 2;   
    parameter mem_row_size = 13;
    parameter mem_col_size = 9;
    parameter mem_cl = 2;
    parameter mem_tRFC = 9;
    parameter mem_tRP  = 2;
    parameter mem_tRCD = 2;
    parameter mem_tMRD = 2;
    parameter mem_rfr_length = 10;
    parameter mem_rfr_wrap_value = 1010;

    input [wbs_dat_width-1:0] wbs_dat_i;
    input [wbs_adr_width-1:0] wbs_adr_i;
    input [2:0] wbs_cti_i;
    input [1:0] wbs_bte_i;
    input [wbs_dat_width/8-1:0] wbs_sel_i;
    input wbs_we_i, wbs_stb_i, wbs_cyc_i;
    output [wbs_dat_width-1:0] wbs_dat_o;
    output wbs_ack_o;
    output wbs_stall_o;
    
    output [mem_ba_size-1:0]    mem_ba;
    output reg [12:0]           mem_a;
    output reg [2:0]            mem_cmd; // {ras,cas,we}
    output                      mem_cke, mem_cs_n;
    output reg [mem_dat_size/8-1:0] mem_dqm;
    output [mem_dat_size-1:0]       mem_dq_o;
    output reg                  mem_dq_oe;
    input  [mem_dat_size-1:0]       mem_dq_i;

    input wb_clk, wb_rst, mem_clk, mem_rst;

    // wbm1
    wire [wbs_dat_width-1:0] wbm1_dat_o;
    wire [wbs_adr_width-1:0] wbm1_adr_o;
    wire [2:0] wbm1_cti_o;
    wire [1:0] wbm1_bte_o;
    wire [wbs_dat_width/8-1:0] wbm1_sel_o;
    wire wbm1_we_o, wbm1_stb_o, wbm1_cyc_o;
    wire [wbs_dat_width-1:0] wbm1_dat_i;
    wire wbm1_ack_i, wbm1_stall_i;
    // wbm2
    wire [mem_dat_size-1:0] wbm2_dat_o;
    wire [mem_ba_size+mem_row_size+mem_col_size-1:0] wbm2_adr_o;
    wire [2:0] wbm2_cti_o;
    wire [1:0] wbm2_bte_o;
    wire [mem_dat_size/8-1:0] wbm2_sel_o;
    wire wbm2_we_o, wbm2_stb_o, wbm2_cyc_o;
    wire [mem_dat_size-1:0] wbm2_dat_i;
    wire wbm2_ack_i, wbm2_stall_i;

`define MODULE wb_shadow_ram
`BASE`MODULE # (
    .shadow_mem_adr_width(shadow_mem_adr_width), .shadow_mem_size(shadow_mem_size), .shadow_mem_init(shadow_mem_init), .shadow_mem_file(shadow_mem_file), .main_mem_adr_width(wbs_adr_width), .dat_width(wbs_dat_width), .mode(wbs_mode), .max_burst_width(wbs_max_burst_width) )
shadow_ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i (wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_stall_o(wbs_stall_o),
    .wbm_dat_o(wbm1_dat_o),
    .wbm_adr_o(wbm1_adr_o),
    .wbm_cti_o(wbm1_cti_o),
    .wbm_bte_o(wbm1_bte_o),
    .wbm_sel_o(wbm1_sel_o),
    .wbm_we_o(wbm1_we_o),
    .wbm_stb_o(wbm1_stb_o),
    .wbm_cyc_o(wbm1_cyc_o), 
    .wbm_dat_i(wbm1_dat_i),
    .wbm_ack_i(wbm1_ack_i),
    .wbm_stall_i(wbm1_stall_i),
    .wb_clk(wb_clk),
    .wb_rst(wb_rst) );
`undef MODULE

`define MODULE wb_cache
`BASE`MODULE # (
    .dw_s(wbs_dat_width), .aw_s(wbs_adr_width), .dw_m(mem_dat_size), .wbs_max_burst_width(cache_aw_offset), .wbs_mode(wbs_mode), .async(cache_async), .nr_of_ways(cache_nr_of_ways), .aw_offset(cache_aw_offset), .aw_slot(cache_aw_slot), .valid_mem(cache_valid_mem) )
cache0 (
    .wbs_dat_i(wbm1_dat_o),
    .wbs_adr_i(wbm1_adr_o),
    .wbs_sel_i(wbm1_sel_o),
    .wbs_cti_i(wbm1_cti_o),
    .wbs_bte_i(wbm1_bte_o),
    .wbs_we_i (wbm1_we_o),
    .wbs_stb_i(wbm1_stb_o),
    .wbs_cyc_i(wbm1_cyc_o),
    .wbs_dat_o(wbm1_dat_i),
    .wbs_ack_o(wbm1_ack_i),
    .wbs_stall_o(wbm1_stall_i),
    .wbs_clk(wb_clk),
    .wbs_rst(wb_rst),
    .wbm_dat_o(wbm2_dat_o),
    .wbm_adr_o(wbm2_adr_o),
    .wbm_sel_o(wbm2_sel_o),
    .wbm_cti_o(wbm2_cti_o),
    .wbm_bte_o(wbm2_bte_o),
    .wbm_we_o (wbm2_we_o),
    .wbm_stb_o(wbm2_stb_o),
    .wbm_cyc_o(wbm2_cyc_o),
    .wbm_dat_i(wbm2_dat_i),
    .wbm_ack_i(wbm2_ack_i),
    .wbm_stall_i(wbm2_stall_i),
    .wbm_clk(mem_clk),
    .wbm_rst(mem_rst) );
`undef MODULE

`define MODULE wb_sdr_sdram
`BASE`MODULE # (
    .dat_size(mem_dat_size), .ba_size(mem_ba_size), .row_size(mem_row_size), .col_size(mem_col_size), .cl(mem_cl), .tRFC(mem_tRFC), .tRP(mem_tRP), .tRCD(mem_tRCD), .tMRD(mem_tMRD), .rfr_length(mem_rfr_length), .rfr_wrap_value(mem_rfr_wrap_value) )
ctrl0(
    // wisbone i/f
    .dat_i(wbm2_dat_o),
    .adr_i(wbm2_adr_o),
    .sel_i(wbm2_sel_o),
    .we_i (wbm2_we_o),
    .cyc_i(wbm2_cyc_o),
    .stb_i(wbm2_stb_o),
    .dat_o(wbm2_dat_i),
    .ack_o(wbm2_ack_i),
    .stall_o(wbm2_stall_i),
    // SDR SDRAM
    .ba(mem_ba),
    .a(mem_a),
    .cmd(mem_cmd),
    .cke(mem_cke),
    .cs_n(mem_cs_n),
    .dqm(mem_dqm),
    .dq_i(mem_dq_i),
    .dq_o(mem_dq_o),
    .dq_oe(mem_dq_oe),
    // system
    .clk(mem_clk),
    .rst(mem_rst) );
`undef MODULE

endmodule
`endif
