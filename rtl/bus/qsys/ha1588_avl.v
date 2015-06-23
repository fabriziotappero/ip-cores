/*
 * ha1588_avl.v
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

module ha1588_avl (
  input         rst,clk,
  input         wr_in,rd_in,
  input  [ 7:0] addr_in,
  input  [31:0] data_in,
  output [31:0] data_out,

  input         rtc_clk,
  output [31:0] rtc_time_ptp_ns,
  output [47:0] rtc_time_ptp_sec,
  output        rtc_time_one_pps,

  input       rx_gmii_clk,
  input       rx_gmii_ctrl,
  input [7:0] rx_gmii_data,
  input       rx_giga_mode,

  input       tx_gmii_clk,
  input       tx_gmii_ctrl,
  input [7:0] tx_gmii_data,
  input       tx_giga_mode
);

parameter addr_is_in_word = 1;

ha1588
#(
  .addr_is_in_word(addr_is_in_word)
)
ha1588_inst (
  .rst(rst),
  .clk(clk),
  .wr_in(wr_in),
  .rd_in(rd_in),
  .addr_in(addr_in),
  .data_in(data_in),
  .data_out(data_out),

  .rtc_clk(rtc_clk),
  .rtc_time_ptp_ns(rtc_time_ptp_ns),
  .rtc_time_ptp_sec(rtc_time_ptp_sec),
  .rtc_time_one_pps(rtc_time_one_pps),

  .rx_gmii_clk(rx_gmii_clk),
  .rx_gmii_ctrl(rx_gmii_ctrl),
  .rx_gmii_data(rx_gmii_data),
  .rx_giga_mode(rx_giga_mode),
  .tx_gmii_clk(tx_gmii_clk),
  .tx_gmii_ctrl(tx_gmii_ctrl),
  .tx_gmii_data(tx_gmii_data),
  .tx_giga_mode(tx_giga_mode)
);

endmodule
