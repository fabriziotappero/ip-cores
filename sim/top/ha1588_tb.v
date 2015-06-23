/*
 * ha1588_tb.v
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

module ha1588_tb ();

parameter giga_mode = 1'b1;

reg up_clk;
wire up_wr, up_rd;
wire [ 7:0] up_addr;
wire [31:0] up_data_wr, up_data_rd;
initial begin
             up_clk = 1'b0;
  forever #5 up_clk = !up_clk;
end

reg rtc_clk;
initial begin
             rtc_clk = 1'b0;
  forever #4 rtc_clk = !rtc_clk;
end

reg rst;
initial begin
      rst = 1'b1;
  #10 rst = 1'b0;
end

wire        rx_gmii_clk;
wire        rx_gmii_ctrl;
wire [ 7:0] rx_gmii_data;
wire        tx_gmii_clk;
wire        tx_gmii_ctrl;
wire [ 7:0] tx_gmii_data;

gmii_rx_bfm NIC_DRV_RX_BFM (
  .gmii_rxclk(rx_gmii_clk),
  .gmii_rxctrl(rx_gmii_ctrl),
  .gmii_rxdata(rx_gmii_data)
);
defparam NIC_DRV_RX_BFM.giga_mode = giga_mode;

gmii_tx_bfm NIC_DRV_TX_BFM (
  .gmii_txclk(tx_gmii_clk),
  .gmii_txctrl(tx_gmii_ctrl),
  .gmii_txdata(tx_gmii_data)
);
defparam NIC_DRV_TX_BFM.giga_mode = giga_mode;

ptp_drv_bfm_sv PTP_DRV_BFM (
  .up_clk(up_clk),
  .up_wr(up_wr),
  .up_rd(up_rd),
  .up_addr(up_addr),
  .up_data_wr(up_data_wr),
  .up_data_rd(up_data_rd)
);

ha1588 PTP_HA_DUT (
  .rst(rst),
  .clk(up_clk),
  .wr_in(up_wr),
  .rd_in(up_rd),
  .addr_in(up_addr),
  .data_in(up_data_wr),
  .data_out(up_data_rd),

  .rtc_clk(rtc_clk),
  .rtc_time_ptp_ns(),
  .rtc_time_ptp_sec(),
  .rtc_time_one_pps(),

  .rx_gmii_clk(rx_gmii_clk),
  .rx_gmii_ctrl(rx_gmii_ctrl),
  .rx_gmii_data(rx_gmii_data),
  .rx_giga_mode(giga_mode),
  .tx_gmii_clk(tx_gmii_clk),
  .tx_gmii_ctrl(tx_gmii_ctrl),
  .tx_gmii_data(tx_gmii_data),
  .tx_giga_mode(giga_mode)
);

initial begin
    ha1588_tb.PTP_DRV_BFM.up_start = 1;
    #100000000 $stop;
end

endmodule
