//----------------------------------------------------------------------
// Title      : Media Independent Interface (MII) Physical Interface
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : mii_if.v
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
//----------------------------------------------------------------------
// Description:  This module creates a Media Independent Interface (MII)
//               by instantiating Input/Output buffers and Input/Output 
//               flip-flops as required.
//
//               This interface is used to connect the Ethernet MAC to
//               an external 10Mb/s and 100Mb/s Ethernet PHY.
//----------------------------------------------------------------------
//

`timescale 1 ps / 1 ps

module mii_if (
        RESET,
        // MII Interface
        MII_TXD,
        MII_TX_EN,
        MII_TX_ER,
        MII_RXD,
        MII_RX_DV,
        MII_RX_ER,
        MII_COL,
        MII_CRS,
        // MAC Interface
        TXD_FROM_MAC,
        TX_EN_FROM_MAC,
        TX_ER_FROM_MAC,
        TX_CLK,
        RXD_TO_MAC,
        RX_DV_TO_MAC,
        RX_ER_TO_MAC,
        RX_CLK,
        MII_COL_TO_MAC,
        MII_CRS_TO_MAC);

  input RESET;
  output [3:0] MII_TXD;
  output MII_TX_EN;
  output MII_TX_ER;
  input  [3:0] MII_RXD;
  input  MII_RX_DV;
  input  MII_RX_ER;
  input  MII_COL;
  input  MII_CRS;
  input  [3:0] TXD_FROM_MAC;
  input  TX_EN_FROM_MAC;
  input  TX_ER_FROM_MAC;
  input  TX_CLK;
  output [3:0] RXD_TO_MAC;
  output RX_DV_TO_MAC;
  output RX_ER_TO_MAC;
  input  RX_CLK;
  output MII_COL_TO_MAC;
  output MII_CRS_TO_MAC;

  reg  mii_tx_en_r;
  reg  mii_tx_er_r;
  reg  [3:0] mii_txd_r;

  wire mii_rx_dv_i;
  wire mii_rx_er_i;
  wire [3:0] mii_rxd_i;

  wire mii_col_i;
  wire mii_crs_i;
  wire mii_tx_clk_i;
  reg  reg_mii_col;
  reg  reg_reg_mii_col;

  reg  [3:0] RXD_TO_MAC;
  reg  RX_DV_TO_MAC;
  reg  RX_ER_TO_MAC;

  //------------------------------------------------------------------------
  // MII Transmitter Logic : Drive TX signals through IOBs onto MII
  // interface
  //------------------------------------------------------------------------
  // Infer IOB Output flip-flops.
  always @(posedge TX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          mii_tx_en_r <= 1'b0;
          mii_tx_er_r <= 1'b0;
          mii_txd_r   <= 8'h00;
      end
      else
      begin
          mii_tx_en_r <= TX_EN_FROM_MAC;
          mii_tx_er_r <= TX_ER_FROM_MAC;
          mii_txd_r   <= TXD_FROM_MAC;
      end
  end

  // Drive MII TX signals through Output Buffers and onto PADS
  OBUF mii_tx_en_obuf (.I(mii_tx_en_r), .O(MII_TX_EN));
  OBUF mii_tx_er_obuf (.I(mii_tx_er_r), .O(MII_TX_ER));

  OBUF mii_txd0_obuf (.I(mii_txd_r[0]),	.O(MII_TXD[0]));
  OBUF mii_txd1_obuf (.I(mii_txd_r[1]),	.O(MII_TXD[1]));
  OBUF mii_txd2_obuf (.I(mii_txd_r[2]),	.O(MII_TXD[2]));
  OBUF mii_txd3_obuf (.I(mii_txd_r[3]),	.O(MII_TXD[3]));

  //------------------------------------------------------------------------
  // MII Receiver Logic : Receive RX signals through IOBs from MII
  // interface
  //------------------------------------------------------------------------
  // Drive input MII Rx signals from PADS through Input Buffers and then 
  // use IDELAYs to provide Zero-Hold Time Delay 
  IBUF mii_rx_dv_ibuf (.I(MII_RX_DV), .O(mii_rx_dv_i));

  IBUF mii_rx_er_ibuf (.I(MII_RX_ER), .O(mii_rx_er_i));

  IBUF mii_rxd0_ibuf (.I(MII_RXD[0]),	.O(mii_rxd_i[0]));

  IBUF mii_rxd1_ibuf (.I(MII_RXD[1]),	.O(mii_rxd_i[1]));

  IBUF mii_rxd2_ibuf (.I(MII_RXD[2]),	.O(mii_rxd_i[2]));

  IBUF mii_rxd3_ibuf (.I(MII_RXD[3]),	.O(mii_rxd_i[3]));

  // Infer IOB Input flip-flops
  always @ (posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          RX_DV_TO_MAC <= 1'b0;
          RX_ER_TO_MAC <= 1'b0;
          RXD_TO_MAC   <= 4'h0;
      end
      else
      begin
          RX_DV_TO_MAC <= mii_rx_dv_i;
          RX_ER_TO_MAC <= mii_rx_er_i;
          RXD_TO_MAC   <= mii_rxd_i;
      end
  end

  // Half Duplex signals
  IBUF mii_col_obuf (.I(MII_COL), .O(mii_col_i));
  IBUF mii_crs_obuf (.I(MII_CRS), .O(mii_crs_i));

  always @(posedge RESET, posedge TX_CLK)
  begin
    if (RESET == 1'b1)
    begin
       reg_mii_col <= 1'b0;
       reg_reg_mii_col <= 1'b0;
    end
    else
    begin
       reg_mii_col     <= mii_col_i;
       reg_reg_mii_col <= reg_mii_col;
    end
  end

  assign MII_COL_TO_MAC = mii_col_i | reg_mii_col | reg_reg_mii_col;
  assign MII_CRS_TO_MAC = mii_crs_i;
 
endmodule
