//------------------------------------------------------------------------------
// Title      : FCS Block for the MII Physical Interface
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : emac0_fcs_blk_mii.v
// Version    : 4.8
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//------------------------------------------------------------------------------
// Description: This file assures proper frame transmission by suppressing
//              duplicate FCS bytes should they occur.
//              This file operates with the MII physical interface and the
//              standard clocking scheme only.
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module emac0_fcs_blk_mii (

    // Global signals
    input        reset,

    // PHY-side input signals
    input        tx_phy_clk,
    input  [3:0] txd_from_mac,
    input        tx_en_from_mac,
    input        tx_er_from_mac,

    // Client-side signals
    input        tx_client_clk,
    input        tx_stats_byte_valid,
    input        tx_collision,
    input        speed_is_10_100,

    // PHY outputs
    output [3:0] txd,
    output       tx_en,
    output       tx_er
);

  // Pipeline registers
  reg [3:0] txd_r1;
  reg [3:0] txd_r2;
  reg       tx_en_r1;
  reg       tx_en_r2;
  reg       tx_er_r1;
  reg       tx_er_r2;

  // For detecting frame end
  reg       tx_stats_byte_valid_r;

  // Counters
  reg [2:0] tx_en_count;
  reg [1:0] tx_byte_count;
  reg [1:0] tx_byte_count_r;

  // Suppression control signals
  (* ASYNC_REG = "TRUE" *)
  reg       collision_r;
  wire      tx_en_suppress;
  reg       tx_en_suppress_r;
  (* ASYNC_REG = "TRUE" *)
  reg       speed_is_10_100_r;

  // Create a two-stage pipeline of PHY output signals in preparation for extra
  // FCS byte determination and TX_EN suppression if one is present.
  always @(posedge tx_phy_clk, posedge reset)
  begin
    if (reset == 1'b1)
    begin
      txd_r1   <= 4'b0;
      txd_r2   <= 4'b0;
      tx_en_r1 <= 1'b0;
      tx_en_r2 <= 1'b0;
      tx_er_r1 <= 1'b0;
      tx_er_r2 <= 1'b0;
    end
    else
    begin
      txd_r1   <= txd_from_mac;
      txd_r2   <= txd_r1;
      tx_en_r1 <= tx_en_from_mac;
      tx_en_r2 <= tx_en_r1;
      tx_er_r1 <= tx_er_from_mac;
      tx_er_r2 <= tx_er_r1;
    end
  end

  // On the PHY-side clock, count the number of cycles that TX_EN remains
  // asserted for. Only 3 bits are needed for comparison.
  always @(posedge tx_phy_clk)
  begin
    if (tx_en_from_mac == 1'b1)
      tx_en_count <= tx_en_count + 3'b1;
    else
      tx_en_count <= 3'b0;
  end

  // On the client-side clock, count the number of cycles that the stats byte
  // valid signal remains asserted for. Only 2 bits are needed for comparison.
  always @(posedge tx_client_clk)
  begin
    tx_stats_byte_valid_r <= tx_stats_byte_valid;
    speed_is_10_100_r     <= speed_is_10_100;
    if (tx_stats_byte_valid == 1'b1)
      tx_byte_count <= tx_byte_count + 2'b1;
    else
      tx_byte_count <= 2'b0;
  end

  // Capture the final stats byte valid count for the frame.
  always @(posedge tx_client_clk)
  begin
    if ((tx_stats_byte_valid_r == 1'b1) && (tx_stats_byte_valid == 1'b0))
      tx_byte_count_r <= tx_byte_count;
  end

  // Generate a signal to suppress TX_EN if the two counts don't match.
  // (Both counters will be stable when this comparison happens, so clock
  // domain crossing is not a concern.)
  // Since the standard clocking scheme is in use, the PHY counter is twice the
  // frequency of the client counter, so use bits 2 and 1 to divide it by two.
  assign tx_en_suppress = (((tx_en_from_mac == 1'b0) && (tx_en_r1 == 1'b1)) &&
                            (tx_en_count[2:1] != tx_byte_count_r)) ? 1'b1 : 1'b0;

  // Register the signal as TX_EN needs to be suppressed over two nibbles. Also
  // register tx_collision for use in the suppression logic.
  always @(posedge tx_phy_clk)
  begin
    tx_en_suppress_r <= tx_en_suppress;
    if (tx_collision == 1'b1)
      collision_r <= 1'b1;
    else
    begin
      if (tx_en_r2 == 1'b0)
        collision_r <= 1'b0;
    end
  end

  // Multiplex output signals. When operating at 1 Gbps, bypass this logic
  // entirely. Otherwise, assign TXD and TX_ER to their pipelined outputs.
  // If a collision has occurred, assign TX_EN directly so as to maintain a
  // jam sequence of 32 bits. Suppress TX_EN if an extra FCS byte is present.
  assign txd   =  (speed_is_10_100_r == 1'b0) ? txd_from_mac   : txd_r2;
  assign tx_er =  (speed_is_10_100_r == 1'b0) ? tx_er_from_mac : tx_er_r2;
  assign tx_en = ((speed_is_10_100_r == 1'b0) || (collision_r == 1'b1)) ?
                 tx_en_from_mac : (tx_en_r2 && ~(tx_en_suppress || tx_en_suppress_r));

endmodule

