/*
 * reg.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module rgs (
  // generic bus interface
  input         rst,clk,
  input         wr_in,rd_in,
  input  [ 7:0] addr_in,
  input  [31:0] data_in,
  output [31:0] data_out,
  // rtc interface
  input         rtc_clk_in,
  output        rtc_rst_out,
  output        time_ld_out,
  output [37:0] time_reg_ns_out,
  output [47:0] time_reg_sec_out,
  output        period_ld_out,
  output [39:0] period_out,
  output        adj_ld_out,
  output [31:0] adj_ld_data_out,
  output [39:0] period_adj_out,
  input         adj_ld_done_in,
  input  [37:0] time_reg_ns_in,
  input  [47:0] time_reg_sec_in,
  // rx tsu interface
  output         rx_q_rst_out,
  output         rx_q_rd_clk_out,
  output         rx_q_rd_en_out,
  output [  7:0] rx_q_ptp_msgid_mask_out,
  input  [  7:0] rx_q_stat_in,
  input  [127:0] rx_q_data_in,
  // tx tsu interface
  output         tx_q_rst_out,
  output         tx_q_rd_clk_out,
  output         tx_q_rd_en_out,
  output [  7:0] tx_q_ptp_msgid_mask_out,
  input  [  7:0] tx_q_stat_in,
  input  [127:0] tx_q_data_in
);

parameter const_00 = 8'h00;
parameter const_04 = 8'h04;
parameter const_08 = 8'h08;
parameter const_0c = 8'h0C;
parameter const_10 = 8'h10;
parameter const_14 = 8'h14;
parameter const_18 = 8'h18;
parameter const_1c = 8'h1C;
parameter const_20 = 8'h20;
parameter const_24 = 8'h24;
parameter const_28 = 8'h28;
parameter const_2c = 8'h2C;
parameter const_30 = 8'h30;
parameter const_34 = 8'h34;
parameter const_38 = 8'h38;
parameter const_3c = 8'h3C;
parameter const_40 = 8'h40;
parameter const_44 = 8'h44;
parameter const_48 = 8'h48;
parameter const_4c = 8'h4C;
parameter const_50 = 8'h50;
parameter const_54 = 8'h54;
parameter const_58 = 8'h58;
parameter const_5c = 8'h5C;
parameter const_60 = 8'h60;
parameter const_64 = 8'h64;
parameter const_68 = 8'h68;
parameter const_6c = 8'h6C;
parameter const_70 = 8'h70;
parameter const_74 = 8'h74;
parameter const_78 = 8'h78;
parameter const_7c = 8'h7C;

wire cs_00 = (addr_in[7:2]==const_00[7:2])? 1'b1: 1'b0;
wire cs_04 = (addr_in[7:2]==const_04[7:2])? 1'b1: 1'b0;
wire cs_08 = (addr_in[7:2]==const_08[7:2])? 1'b1: 1'b0;
wire cs_0c = (addr_in[7:2]==const_0c[7:2])? 1'b1: 1'b0;
wire cs_10 = (addr_in[7:2]==const_10[7:2])? 1'b1: 1'b0;
wire cs_14 = (addr_in[7:2]==const_14[7:2])? 1'b1: 1'b0;
wire cs_18 = (addr_in[7:2]==const_18[7:2])? 1'b1: 1'b0;
wire cs_1c = (addr_in[7:2]==const_1c[7:2])? 1'b1: 1'b0;
wire cs_20 = (addr_in[7:2]==const_20[7:2])? 1'b1: 1'b0;
wire cs_24 = (addr_in[7:2]==const_24[7:2])? 1'b1: 1'b0;
wire cs_28 = (addr_in[7:2]==const_28[7:2])? 1'b1: 1'b0;
wire cs_2c = (addr_in[7:2]==const_2c[7:2])? 1'b1: 1'b0;
wire cs_30 = (addr_in[7:2]==const_30[7:2])? 1'b1: 1'b0;
wire cs_34 = (addr_in[7:2]==const_34[7:2])? 1'b1: 1'b0;
wire cs_38 = (addr_in[7:2]==const_38[7:2])? 1'b1: 1'b0;
wire cs_3c = (addr_in[7:2]==const_3c[7:2])? 1'b1: 1'b0;
wire cs_40 = (addr_in[7:2]==const_40[7:2])? 1'b1: 1'b0;
wire cs_44 = (addr_in[7:2]==const_44[7:2])? 1'b1: 1'b0;
wire cs_48 = (addr_in[7:2]==const_48[7:2])? 1'b1: 1'b0;
wire cs_4c = (addr_in[7:2]==const_4c[7:2])? 1'b1: 1'b0;
wire cs_50 = (addr_in[7:2]==const_50[7:2])? 1'b1: 1'b0;
wire cs_54 = (addr_in[7:2]==const_54[7:2])? 1'b1: 1'b0;
wire cs_58 = (addr_in[7:2]==const_58[7:2])? 1'b1: 1'b0;
wire cs_5c = (addr_in[7:2]==const_5c[7:2])? 1'b1: 1'b0;
wire cs_60 = (addr_in[7:2]==const_60[7:2])? 1'b1: 1'b0;
wire cs_64 = (addr_in[7:2]==const_64[7:2])? 1'b1: 1'b0;
wire cs_68 = (addr_in[7:2]==const_68[7:2])? 1'b1: 1'b0;
wire cs_6c = (addr_in[7:2]==const_6c[7:2])? 1'b1: 1'b0;
wire cs_70 = (addr_in[7:2]==const_70[7:2])? 1'b1: 1'b0;
wire cs_74 = (addr_in[7:2]==const_74[7:2])? 1'b1: 1'b0;
wire cs_78 = (addr_in[7:2]==const_78[7:2])? 1'b1: 1'b0;
wire cs_7c = (addr_in[7:2]==const_7c[7:2])? 1'b1: 1'b0;

reg [31:0] reg_00;  // ctrl 5 bit
reg [31:0] reg_04;  // scratch reg
reg [31:0] reg_08;  // null
reg [31:0] reg_0c;  // null
reg [31:0] reg_10;  // time 16 bit s
reg [31:0] reg_14;  // time 32 bit s
reg [31:0] reg_18;  // time 30 bit ns
reg [31:0] reg_1c;  // time  8 bit nsf
reg [31:0] reg_20;  // peri  8 bit ns
reg [31:0] reg_24;  // peri 32 bit nsf
reg [31:0] reg_28;  // ajpr  8 bit ns
reg [31:0] reg_2c;  // ajpr 32 bit nsf
reg [31:0] reg_30;  // ajld 32 bit
reg [31:0] reg_34;  // null
reg [31:0] reg_38;  // null
reg [31:0] reg_3c;  // null
reg [31:0] reg_40;  // ctrl  2 bit
reg [31:0] reg_44;  // qsta  8 bit
reg [31:0] reg_48;  // null
reg [31:0] reg_4c;  // null
reg [31:0] reg_50;  // rxqu 32 bit
reg [31:0] reg_54;  // rxqu 32 bit
reg [31:0] reg_58;  // rxqu 32 bit
reg [31:0] reg_5c;  // rxqu 32 bit
reg [31:0] reg_60;  // ctrl  2 bit
reg [31:0] reg_64;  // qsta  8 bit
reg [31:0] reg_68;  // null
reg [31:0] reg_6c;  // null
reg [31:0] reg_70;  // txqu 32 bit
reg [31:0] reg_74;  // txqu 32 bit
reg [31:0] reg_78;  // txqu 32 bit
reg [31:0] reg_7c;  // txqu 32 bit

// write registers
always @(posedge clk) begin
  if (wr_in && cs_00) reg_00 <= data_in;
  if (wr_in && cs_04) reg_04 <= data_in;
  if (wr_in && cs_08) reg_08 <= data_in;
  if (wr_in && cs_0c) reg_0c <= data_in;
  if (wr_in && cs_10) reg_10 <= data_in;
  if (wr_in && cs_14) reg_14 <= data_in;
  if (wr_in && cs_18) reg_18 <= data_in;
  if (wr_in && cs_1c) reg_1c <= data_in;
  if (wr_in && cs_20) reg_20 <= data_in;
  if (wr_in && cs_24) reg_24 <= data_in;
  if (wr_in && cs_28) reg_28 <= data_in;
  if (wr_in && cs_2c) reg_2c <= data_in;
  if (wr_in && cs_30) reg_30 <= data_in;
  if (wr_in && cs_34) reg_34 <= data_in;
  if (wr_in && cs_38) reg_38 <= data_in;
  if (wr_in && cs_3c) reg_3c <= data_in;
  if (wr_in && cs_40) reg_40 <= data_in;
  if (wr_in && cs_44) reg_44 <= data_in;
  if (wr_in && cs_48) reg_48 <= data_in;
  if (wr_in && cs_4c) reg_4c <= data_in;
  if (wr_in && cs_50) reg_50 <= data_in;
  if (wr_in && cs_54) reg_54 <= data_in;
  if (wr_in && cs_58) reg_58 <= data_in;
  if (wr_in && cs_5c) reg_5c <= data_in;
  if (wr_in && cs_60) reg_60 <= data_in;
  if (wr_in && cs_64) reg_64 <= data_in;
  if (wr_in && cs_68) reg_68 <= data_in;
  if (wr_in && cs_6c) reg_6c <= data_in;
  if (wr_in && cs_70) reg_70 <= data_in;
  if (wr_in && cs_74) reg_74 <= data_in;
  if (wr_in && cs_78) reg_78 <= data_in;
  if (wr_in && cs_7c) reg_7c <= data_in;
end

// read registers
reg  [37:0] time_reg_ns_int;
reg  [47:0] time_reg_sec_int;
reg  [127:0] rx_q_data_int;
reg  [  7:0] rx_q_stat_int;
reg  [127:0] tx_q_data_int;
reg  [  7:0] tx_q_stat_int;
reg         time_ok;
reg         rxqu_ok;
reg         txqu_ok;

reg  [31:0] data_out_reg;
always @(posedge clk) begin
  // register mapping: RTC
  if (rd_in && cs_00) data_out_reg <= {27'd0, reg_00[ 4: 2], adj_ld_done_in, time_ok};
  if (rd_in && cs_04) data_out_reg <= reg_04;
  if (rd_in && cs_08) data_out_reg <= 32'd0;
  if (rd_in && cs_0c) data_out_reg <= 32'd0;
  if (rd_in && cs_10) data_out_reg <= {16'd0, time_reg_sec_int[47:32]};
  if (rd_in && cs_14) data_out_reg <=         time_reg_sec_int[31: 0] ;
  if (rd_in && cs_18) data_out_reg <= { 2'd0, time_reg_ns_int [37: 8]};
  if (rd_in && cs_1c) data_out_reg <= {24'd0, time_reg_ns_int [ 7: 0]};
  if (rd_in && cs_20) data_out_reg <= {24'd0, reg_20[ 7: 0]};
  if (rd_in && cs_24) data_out_reg <= reg_24;
  if (rd_in && cs_28) data_out_reg <= {24'd0, reg_28[ 7: 0]};
  if (rd_in && cs_2c) data_out_reg <= reg_2c;
  if (rd_in && cs_30) data_out_reg <= reg_30;
  if (rd_in && cs_34) data_out_reg <= 32'd0;
  if (rd_in && cs_38) data_out_reg <= 32'd0;
  if (rd_in && cs_3c) data_out_reg <= 32'd0;
  // register mapping: TSU RX
  if (rd_in && cs_40) data_out_reg <= {30'd0, reg_40[ 1], rxqu_ok};
  if (rd_in && cs_44) data_out_reg <= {reg_44[31:24], 16'd0, rx_q_stat_int[ 7: 0]};
  if (rd_in && cs_48) data_out_reg <= 32'd0;
  if (rd_in && cs_4c) data_out_reg <= 32'd0;
  if (rd_in && cs_50) data_out_reg <= rx_q_data_int[127: 96];
  if (rd_in && cs_54) data_out_reg <= rx_q_data_int[ 95: 64];
  if (rd_in && cs_58) data_out_reg <= rx_q_data_int[ 63: 32];
  if (rd_in && cs_5c) data_out_reg <= rx_q_data_int[ 31:  0];
  // register mapping: TSU TX
  if (rd_in && cs_60) data_out_reg <= {30'd0, reg_60[ 1], txqu_ok}; 
  if (rd_in && cs_64) data_out_reg <= {reg_64[31:24], 16'd0, tx_q_stat_int[ 7: 0]};
  if (rd_in && cs_68) data_out_reg <= 32'd0;
  if (rd_in && cs_6c) data_out_reg <= 32'd0;
  if (rd_in && cs_70) data_out_reg <= tx_q_data_int[127: 96];
  if (rd_in && cs_74) data_out_reg <= tx_q_data_int[ 95: 64];
  if (rd_in && cs_78) data_out_reg <= tx_q_data_int[ 63: 32];
  if (rd_in && cs_7c) data_out_reg <= tx_q_data_int[ 31:  0];
end
assign data_out = data_out_reg;

// register mapping: RTC
//wire       = reg_00[ 7];
//wire       = reg_00[ 6];
//wire       = reg_00[ 5];
wire rtc_rst = reg_00[ 4];
wire time_ld = reg_00[ 3];
wire perd_ld = reg_00[ 2];
wire adjt_ld = reg_00[ 1];
wire time_rd = reg_00[ 0];
assign time_reg_sec_out [47:0] = {reg_10[15: 0], reg_14[31: 0]};
assign time_reg_ns_out  [37:0] = {reg_18[29: 0], reg_1c[ 7: 0]};
assign period_out       [39:0] = {reg_20[ 7: 0], reg_24[31: 0]};
assign period_adj_out   [39:0] = {reg_28[ 7: 0], reg_2c[31: 0]};
assign adj_ld_data_out  [31:0] =  reg_30[31: 0];

// register mapping: TSU RX
//wire       = reg_40[ 7];
//wire       = reg_40[ 6];
//wire       = reg_40[ 5];
//wire       = reg_40[ 4];
//wire       = reg_40[ 3];
//wire       = reg_40[ 2];
wire rxq_rst = reg_40[ 1];
wire rxqu_rd = reg_40[ 0];
assign rx_q_ptp_msgid_mask_out [7:0] = reg_44[31:24];

// register mapping: TSU TX
//wire       = reg_60[ 7];
//wire       = reg_60[ 6];
//wire       = reg_60[ 5];
//wire       = reg_60[ 4];
//wire       = reg_60[ 3];
//wire       = reg_60[ 2];
wire txq_rst = reg_60[ 1];
wire txqu_rd = reg_60[ 0];
assign tx_q_ptp_msgid_mask_out [7:0] = reg_64[31:24];
// TODO: add configurable VLANTPID values

// real time clock
reg rtc_rst_s1, rtc_rst_s2, rtc_rst_s3;
assign rtc_rst_out = rtc_rst_s2 && !rtc_rst_s3;
always @(posedge rtc_clk_in) begin
  rtc_rst_s1 <= rtc_rst;
  rtc_rst_s2 <= rtc_rst_s1;
  rtc_rst_s3 <= rtc_rst_s2;
end

reg time_ld_s1, time_ld_s2, time_ld_s3;
assign time_ld_out = time_ld_s2 && !time_ld_s3;
always @(posedge rtc_clk_in) begin
  time_ld_s1 <= time_ld;
  time_ld_s2 <= time_ld_s1;
  time_ld_s3 <= time_ld_s2;
end

reg perd_ld_s1, perd_ld_s2, perd_ld_s3;
assign period_ld_out  = perd_ld_s2 && !perd_ld_s3;
always @(posedge rtc_clk_in) begin
  perd_ld_s1 <= perd_ld;
  perd_ld_s2 <= perd_ld_s1;
  perd_ld_s3 <= perd_ld_s2;
end

reg adjt_ld_s1, adjt_ld_s2, adjt_ld_s3;
assign adj_ld_out = adjt_ld_s2 && !adjt_ld_s3;
always @(posedge rtc_clk_in) begin
  adjt_ld_s1 <= adjt_ld;
  adjt_ld_s2 <= adjt_ld_s1;
  adjt_ld_s3 <= adjt_ld_s2;
end

// RTC time read CDC hand-shaking
reg time_rd_s1, time_rd_s2, time_rd_s3;
wire time_rd_ack = time_rd_s2 && !time_rd_s3;
always @(posedge rtc_clk_in) begin
  time_rd_s1 <= time_rd;
  time_rd_s2 <= time_rd_s1;
  time_rd_s3 <= time_rd_s2;
end

always @(posedge rtc_clk_in) begin
  if (time_rd_ack) begin
    time_reg_ns_int  <= time_reg_ns_in;
    time_reg_sec_int <= time_reg_sec_in;	  
  end
end

reg time_rd_d1;
wire time_rd_req = time_rd && !time_rd_d1;
always @(posedge clk) begin
  time_rd_d1 <= time_rd;
end

always @(posedge clk or posedge time_rd_ack) begin
  if (time_rd_ack)
    time_ok <= 1'b1;
  else if (time_rd_req)
    time_ok <= 1'b0;
end

// rx time stamp queue
assign rx_q_rd_clk_out = clk;

reg rxq_rst_d1, rxq_rst_d2, rxq_rst_d3;
assign rx_q_rst_out = rxq_rst_d2 && !rxq_rst_d3;
always @(posedge clk) begin
  rxq_rst_d1 <= rxq_rst;
  rxq_rst_d2 <= rxq_rst_d1;
  rxq_rst_d3 <= rxq_rst_d2;
end

reg rxqu_rd_d1, rxqu_rd_d2, rxqu_rd_d3, rxqu_rd_d4, rxqu_rd_d5;
assign rx_q_rd_en_out = rxqu_rd_d2 && !rxqu_rd_d3;
wire   rx_q_rd_req    = rxqu_rd_d2 && !rxqu_rd_d3;
wire   rx_q_rd_ack    = rxqu_rd_d4 && !rxqu_rd_d5;
always @(posedge clk) begin
  rxqu_rd_d1 <= rxqu_rd;
  rxqu_rd_d2 <= rxqu_rd_d1;
  rxqu_rd_d3 <= rxqu_rd_d2;
  rxqu_rd_d4 <= rxqu_rd_d3;
  rxqu_rd_d5 <= rxqu_rd_d4;
end

always @(posedge clk) begin
  if (rx_q_rd_ack)
    rxqu_ok <= 1'b1;
  else if (rx_q_rd_req)
    rxqu_ok <= 1'b0;
end

always @(posedge clk) begin
  rx_q_data_int <= rx_q_data_in;
  rx_q_stat_int <= rx_q_stat_in;
end

// tx time stamp queue
assign tx_q_rd_clk_out = clk;

reg txq_rst_d1, txq_rst_d2, txq_rst_d3;
assign tx_q_rst_out = txq_rst_d2 && !txq_rst_d3;
always @(posedge clk) begin
  txq_rst_d1 <= txq_rst;
  txq_rst_d2 <= txq_rst_d1;
  txq_rst_d3 <= txq_rst_d2;
end

reg txqu_rd_d1, txqu_rd_d2, txqu_rd_d3, txqu_rd_d4, txqu_rd_d5;
assign tx_q_rd_en_out = txqu_rd_d2 && !txqu_rd_d3;
wire   tx_q_rd_req    = txqu_rd_d2 && !txqu_rd_d3;
wire   tx_q_rd_ack    = txqu_rd_d4 && !txqu_rd_d5;
always @(posedge clk) begin
  txqu_rd_d1 <= txqu_rd;
  txqu_rd_d2 <= txqu_rd_d1;
  txqu_rd_d3 <= txqu_rd_d2;
  txqu_rd_d4 <= txqu_rd_d3;
  txqu_rd_d5 <= txqu_rd_d4;
end

always @(posedge clk) begin
  if (tx_q_rd_ack)
    txqu_ok <= 1'b1;
  else if (tx_q_rd_req)
    txqu_ok <= 1'b0;
end

always @(posedge clk) begin
  tx_q_data_int <= tx_q_data_in;
  tx_q_stat_int <= tx_q_stat_in;
end

endmodule
