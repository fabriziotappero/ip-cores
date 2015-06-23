/*
 * ha1588_wb.v
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

module ha1588_wb (
  // reg_interface
  input         rst_i,clk_i,
  input         stb_i,we_i,
  output        ack_o,
  input  [31:0] adr_i,  // in byte
  input  [31:0] dat_i,
  output [31:0] dat_o,
  // rtc_interface
  input         rtc_clk,
  output [31:0] rtc_time_ptp_ns,
  output [47:0] rtc_time_ptp_sec,
  output        rtc_time_one_pps,
  // tsu_interface
  input       rx_gmii_clk,
  input       rx_gmii_ctrl,
  input [7:0] rx_gmii_data,
  input       rx_giga_mode,
  input       tx_gmii_clk,
  input       tx_gmii_ctrl,
  input [7:0] tx_gmii_data,
  input       tx_giga_mode
);

wire rst, up_clk;
wire up_wr, up_rd;
wire [ 7:0] up_addr;
wire [31:0] up_data_wr, up_data_rd;

wb_slv_wrapper wb_slv(
  // wishbone side
  .rst_i(rst_i),
  .clk_i(clk_i),
  .stb_i(stb_i),
  .we_i(we_i),
  .ack_o(ack_o),
  .adr_i(adr_i),  // in byte
  .dat_i(dat_i),
  .dat_o(dat_o),
  // localbus side
  .rst(rst),
  .clk(up_clk),
  .wr_out(up_wr),
  .rd_out(up_rd),
  .addr_out(up_addr),  // in byte
  .data_out(up_data_wr),
  .data_in(up_data_rd)
);

ha1588 ha1588_inst (
  .rst(rst),
  .clk(up_clk),
  .wr_in(up_wr),
  .rd_in(up_rd),
  .addr_in(up_addr),
  .data_in(up_data_wr),
  .data_out(up_data_rd),

  .rtc_clk(rtc_clk),
  .rtc_time_ptp_ns(rtc_time_ptp_ns),
  .rtc_time_ptp_sec(rtc_time_ptp_sec),
  .rtc_time_one_pps(rtc_time_one_pps),

  .rx_gmii_clk(rx_gmii_clk),
  .rx_gmii_ctrl(rx_gmii_ctrl),
  .rx_gmii_data(rx_gmii_data),
  .rx_giga_mode(giga_mode),
  .tx_gmii_clk(tx_gmii_clk),
  .tx_gmii_ctrl(tx_gmii_ctrl),
  .tx_gmii_data(tx_gmii_data),
  .tx_giga_mode(giga_mode)
);

endmodule

