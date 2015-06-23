/*
 * tsu_queue_tb.v
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

module tsu_queue_tb; 

parameter giga_mode = 1'b1;

reg         rst;
wire        gmii_rxclk;
wire        gmii_rxctrl;
wire [ 7:0] gmii_rxdata;
wire        gmii_txclk;
wire        gmii_txctrl;
wire [ 7:0] gmii_txdata;
reg         rtc_timer_clk;
reg  [79:0] rtc_timer_in;
reg          q_rd_clk;
reg          q_rd_en;
wire [  7:0] q_rd_stat;
wire [127:0] q_rd_data;

initial begin
  // emulate the hardware behavior when power-up
  DUT_RX.ts_ack = 1'b0;
  DUT_TX.ts_ack = 1'b0;

      rst = 1'b0;
  #10 rst = 1'b1;
  #20 rst = 1'b0;
end

initial begin
             q_rd_clk = 1'b0;
  forever #5 q_rd_clk = !q_rd_clk;
end

initial begin
             rtc_timer_clk = 1'b0;
  forever #4 rtc_timer_clk = !rtc_timer_clk;
end

initial begin
                                   rtc_timer_in = 80'd0;
  forever @(posedge rtc_timer_clk) rtc_timer_in = rtc_timer_in +1;
end

tsu DUT_RX
  (
    .rst(rst),

    .gmii_clk(gmii_rxclk),
    .gmii_ctrl(gmii_rxctrl),
    .gmii_data(gmii_rxdata),
    .giga_mode(giga_mode),

    .ptp_msgid_mask(8'b11111111),

    .rtc_timer_clk(rtc_timer_clk),
    .rtc_timer_in(rtc_timer_in),

    .q_rst(rst),
    .q_rd_clk(q_rd_clk),
    .q_rd_en(q_rd_en),
    .q_rd_stat(q_rd_stat),
    .q_rd_data(q_rd_data)
  );

gmii_rx_bfm BFM_RX
  (
    .gmii_rxclk(gmii_rxclk),
    .gmii_rxctrl(gmii_rxctrl),
    .gmii_rxdata(gmii_rxdata)
  );
defparam BFM_RX.giga_mode = giga_mode;


tsu DUT_TX
  (
    .rst(rst),

    .gmii_clk(gmii_txclk),
    .gmii_ctrl(gmii_txctrl),
    .gmii_data(gmii_txdata),
    .giga_mode(giga_mode),

    .ptp_msgid_mask(8'b11111111),

    .rtc_timer_clk(rtc_timer_clk),
    .rtc_timer_in(rtc_timer_in),

    .q_rst(rst),
    .q_rd_clk(q_rd_clk),
    .q_rd_en(),
    .q_rd_stat(),
    .q_rd_data()
  );

gmii_tx_bfm BFM_TX
  (
    .gmii_txclk(gmii_txclk),
    .gmii_txctrl(gmii_txctrl),
    .gmii_txdata(gmii_txdata)
  );
defparam BFM_TX.giga_mode = giga_mode;

integer rx_ptp_event_cnt, rx_ptp_mismatch_cnt;
integer ref_file_handle_rx, return_fscanf_rx, ref_num_rx;
initial begin
  rx_ptp_event_cnt = 0;
  rx_ptp_mismatch_cnt = 0;
  ref_file_handle_rx = $fopen("ptpdv2_rx.txt","r");
  forever @(posedge DUT_RX.q_wr_en) begin
    rx_ptp_event_cnt = rx_ptp_event_cnt + 1;
    return_fscanf_rx = $fscanf(ref_file_handle_rx, "%d", ref_num_rx);
    if (BFM_RX.num_rx != ref_num_rx) begin
      $warning("%d %d", BFM_RX.num_rx, ref_num_rx);
      rx_ptp_mismatch_cnt = rx_ptp_mismatch_cnt + 1;
    end
  end
  $fclose(ref_file_handle_rx);
end

integer tx_ptp_event_cnt, tx_ptp_mismatch_cnt;
integer ref_file_handle_tx, return_fscanf_tx, ref_num_tx;
initial begin
  tx_ptp_event_cnt = 0;
  tx_ptp_mismatch_cnt = 0;
  ref_file_handle_tx = $fopen("ptpdv2_tx.txt","r");
  forever @(posedge DUT_TX.q_wr_en) begin
    tx_ptp_event_cnt = tx_ptp_event_cnt + 1;
    return_fscanf_tx = $fscanf(ref_file_handle_tx, "%d", ref_num_tx);
    if (BFM_TX.num_tx != ref_num_tx) begin
      $warning("%d %d", BFM_TX.num_tx, ref_num_tx);
      tx_ptp_mismatch_cnt = tx_ptp_mismatch_cnt + 1;
    end
  end
  $fclose(ref_file_handle_tx);
end

initial begin
  fork
    @(posedge BFM_RX.eof_rx);
    @(posedge BFM_TX.eof_tx);
  join

  if (rx_ptp_event_cnt == 0)
    $display("RX Parser Test Fail: found 0 PTP-EVENT!\n");
  if (tx_ptp_event_cnt == 0)
    $display("TX Parser Test Fail: found 0 PTP-EVENT!\n");
  if (rx_ptp_mismatch_cnt > 0)
    $display("Rx Parser Mismatch Found: RX-PTP-EVENT-MISMATCH = %d\n", rx_ptp_mismatch_cnt);
  if (tx_ptp_mismatch_cnt > 0)
    $display("Tx Parser Mismatch Found: TX-PTP-EVENT-MISMATCH = %d\n", tx_ptp_mismatch_cnt);

  if (rx_ptp_event_cnt > 0 && rx_ptp_mismatch_cnt == 0)
    $display("RX Parser Test Pass: RX-PTP-EVENT = %d\n", rx_ptp_event_cnt);
  if (tx_ptp_event_cnt > 0 && tx_ptp_mismatch_cnt == 0)
    $display("TX Parser Test Pass: TX-PTP-EVENT = %d\n", tx_ptp_event_cnt);

  #100 $stop;
end

endmodule

