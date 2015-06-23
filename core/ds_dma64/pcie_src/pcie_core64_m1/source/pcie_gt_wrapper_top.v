
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
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
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : pcie_gt_wrapper_top.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
//  Description : Top-level wrapper for Rocket IO Transceivers that
//  instantiates GTP/GTX transceivers based upon the Virtex-5 family chosen
//
//-----------------------------------------------------------------------------  

module pcie_gt_wrapper_top #
(
    parameter NO_OF_LANES = 1,
    parameter SIM = 0,
    parameter USE_V5FXT = 0,
    parameter REF_CLK_FREQ = 1, // use 0 or 1
    parameter TXDIFFBOOST = "FALSE",
    parameter GTDEBUGPORTS = 0

)

(

output  wire   [7:0]                gt_rx_elec_idle,
output  wire   [23:0]               gt_rx_status,
output  wire   [63:0]               gt_rx_data,
output  wire   [7:0]                gt_rx_phy_status,
output  wire   [7:0]                gt_rx_data_k,
output  wire   [7:0]                gt_rx_valid,
output  wire   [7:0]                gt_rx_chanisaligned,
input   wire   [NO_OF_LANES-1:0]    gt_rx_n,
input   wire   [NO_OF_LANES-1:0]    gt_rx_p,

output  wire   [NO_OF_LANES-1:0]    gt_tx_n,
output  wire   [NO_OF_LANES-1:0]    gt_tx_p,
input   wire   [63:0]               gt_tx_data,
input   wire   [7:0]                gt_tx_data_k,
input   wire   [7:0]                gt_tx_elec_idle,
input   wire   [7:0]                gt_tx_detect_rx_loopback,
input   wire   [7:0]                gt_tx_compliance,
input   wire   [7:0]                gt_rx_polarity,
input   wire   [15:0]               gt_power_down,
input   wire   [7:0]                gt_deskew_lanes,
input   wire   [7:0]                gt_pipe_reset,
input   wire   [7:0]                gt_rx_present,

input   wire                        gsr,
input   wire                        gtreset,
input   wire                        refclk,
output  wire                        refclkout_bufg,
output  wire                        gtclk_bufg,
output  wire  [7:0]                 resetdone,
output  wire  [3:0]                 plllkdet_out,
input   wire                        gt_usrclk,
input   wire                        gt_usrclk2,
input   wire                        txsync_clk,
output  wire  [7:0]                 rxbyteisaligned,
output  wire  [7:0]                 rxchanbondseq,

output  wire                        pcie_reset,
input   wire                        clock_lock,
input   wire                        trn_lnk_up_n,

// GTP register ports

input   wire                        gt_dclk,
input   wire   [NO_OF_LANES*7-1:0]  gt_daddr,
input   wire   [NO_OF_LANES-1:0]    gt_den,
input   wire   [NO_OF_LANES-1:0]    gt_dwen,
input   wire   [NO_OF_LANES*16-1:0] gt_di,
output  wire   [NO_OF_LANES*16-1:0] gt_do,
output  wire   [NO_OF_LANES-1:0]    gt_drdy,

input   wire  [2:0]                 gt_txdiffctrl_0,     
input   wire  [2:0]                 gt_txdiffctrl_1,      
input   wire  [2:0]                 gt_txbuffctrl_0,    
input   wire  [2:0]                 gt_txbuffctrl_1,  
input   wire  [2:0]                 gt_txpreemphesis_0,    
input   wire  [2:0]                 gt_txpreemphesis_1      

);


generate 

// Instantiate wrapper for Rocket IO GTX transceivers if V5 FXT is used, 
// else instantiate wrapper for Rocket IO GTP transceivers  
	
  if (USE_V5FXT == 0) begin

       pcie_gt_wrapper#
        (
              .NO_OF_LANES(NO_OF_LANES),
              .SIM(SIM),
              // REF_CLK_FREQ is 0 for 100 MHz, 1 for 250 MHz
              .PLL_DIVSEL_FB(REF_CLK_FREQ ? 1 : 5), 
              .PLL_DIVSEL_REF(REF_CLK_FREQ ? 1 : 2),
              .CLK25_DIVIDER(REF_CLK_FREQ ? 10 : 4),
              .TXDIFFBOOST(TXDIFFBOOST)
        )

        pcie_gt_wrapper_i
        (
              .gt_rx_elec_idle         (gt_rx_elec_idle),
              .gt_rx_status            (gt_rx_status),
              .gt_rx_data              (gt_rx_data),
              .gt_rx_phy_status        (gt_rx_phy_status),
              .gt_rx_data_k            (gt_rx_data_k),
              .gt_rx_valid             (gt_rx_valid),
              .gt_rx_chanisaligned     (gt_rx_chanisaligned),
              
              .gt_rx_n                 (gt_rx_n),     
              .gt_rx_p                 (gt_rx_p),     
              .gt_tx_n                 (gt_tx_n),     
              .gt_tx_p                 (gt_tx_p),    
              
              .gt_tx_data              (gt_tx_data),
              .gt_tx_data_k            (gt_tx_data_k),
              .gt_tx_elec_idle         (gt_tx_elec_idle),
              .gt_tx_detect_rx_loopback(gt_tx_detect_rx_loopback),
              .gt_tx_compliance        (gt_tx_compliance),
              .gt_rx_polarity          (gt_rx_polarity),
              .gt_power_down           (gt_power_down),
              .gt_deskew_lanes         (gt_deskew_lanes),
              .gt_pipe_reset           (gt_pipe_reset),
              .gt_rx_present           (gt_rx_present),

              .gsr                     (gsr),
              .gtreset                 (gtreset),
              .refclk                  (refclk),
              .refclkout_bufg          (refclkout_bufg),
              .gtclk_bufg              (gtclk_bufg), 
              .plllkdet_out            (plllkdet_out),
              .resetdone               (resetdone),
              .gt_usrclk               (gt_usrclk2),
              .rxbyteisaligned         (rxbyteisaligned), 
              .rxchanbondseq           (rxchanbondseq), 

              .pcie_reset              (pcie_reset),
              .clock_lock              (clock_lock), 
              
              // GTP register ports
              .gt_dclk                 (gt_dclk),
              .gt_daddr                (gt_daddr),
              .gt_den                  (gt_den),
              .gt_dwen                 (gt_dwen),
              .gt_di                   (gt_di),
              .gt_do                   (gt_do),
              .gt_drdy                 (gt_drdy),

              .gt_txdiffctrl_0         (gt_txdiffctrl_0),
              .gt_txdiffctrl_1         (gt_txdiffctrl_1),
              .gt_txbuffctrl_0         (gt_txbuffctrl_0),
              .gt_txbuffctrl_1         (gt_txbuffctrl_1),
              .gt_txpreemphesis_0      (gt_txpreemphesis_0),
              .gt_txpreemphesis_1      (gt_txpreemphesis_1)
        );

  end else begin

       pcie_gtx_wrapper#
        (
              .NO_OF_LANES(NO_OF_LANES),
              .SIM(SIM),
              .PLL_DIVSEL_FB(REF_CLK_FREQ ? 2 : 5),  // REF_CLK_FREQ is 0 for 100 MHz, 1 for 250 MHz
              .PLL_DIVSEL_REF(REF_CLK_FREQ ? 1 : 1),
              .CLK25_DIVIDER(REF_CLK_FREQ ? 10 : 4),
              .TXDIFFBOOST(TXDIFFBOOST),
              .GTDEBUGPORTS(GTDEBUGPORTS)
        )

        pcie_gt_wrapper_i
        (
              .gt_rx_elec_idle         (gt_rx_elec_idle),
              .gt_rx_status            (gt_rx_status),
              .gt_rx_data              (gt_rx_data),
              .gt_rx_phy_status        (gt_rx_phy_status),
              .gt_rx_data_k            (gt_rx_data_k),
              .gt_rx_valid             (gt_rx_valid),
              .gt_rx_chanisaligned     (gt_rx_chanisaligned),
              
              .gt_rx_n                 (gt_rx_n),     
              .gt_rx_p                 (gt_rx_p),     
              .gt_tx_n                 (gt_tx_n),     
              .gt_tx_p                 (gt_tx_p),    
              
              .gt_tx_data              (gt_tx_data),
              .gt_tx_data_k            (gt_tx_data_k),
              .gt_tx_elec_idle         (gt_tx_elec_idle),
              .gt_tx_detect_rx_loopback(gt_tx_detect_rx_loopback),
              .gt_tx_compliance        (gt_tx_compliance),
              .gt_rx_polarity          (gt_rx_polarity),
              .gt_power_down           (gt_power_down),
              .gt_deskew_lanes         (gt_deskew_lanes),
              .gt_pipe_reset           (gt_pipe_reset),
              .gt_rx_present           (gt_rx_present),

              .gsr                     (gsr),
              .gtreset                 (gtreset),
              .refclk                  (refclk),
              .refclkout_bufg          (refclkout_bufg),
              .gtclk_bufg              (gtclk_bufg), 
              .plllkdet_out            (plllkdet_out),
              .resetdone               (resetdone),
              .gt_usrclk               (gt_usrclk),
              .gt_usrclk2              (gt_usrclk2),
              .txsync_clk              (txsync_clk),
              .rxbyteisaligned         (rxbyteisaligned), 
              .rxchanbondseq           (rxchanbondseq), 

              .pcie_reset              (pcie_reset),
              .clock_lock              (clock_lock), 
              .trn_lnk_up_n            (trn_lnk_up_n),
              
              // GTP register ports
              .gt_dclk                 (gt_dclk),
              .gt_daddr                (gt_daddr),
              .gt_den                  (gt_den),
              .gt_dwen                 (gt_dwen),
              .gt_di                   (gt_di),
              .gt_do                   (gt_do),
              .gt_drdy                 (gt_drdy),

              .gt_txdiffctrl_0         (gt_txdiffctrl_0),
              .gt_txdiffctrl_1         (gt_txdiffctrl_1),
              .gt_txbuffctrl_0         (gt_txbuffctrl_0),
              .gt_txbuffctrl_1         (gt_txbuffctrl_1),
              .gt_txpreemphesis_0      (gt_txpreemphesis_0),
              .gt_txpreemphesis_1      (gt_txpreemphesis_1)

        );

  end
  

  
  
endgenerate


endmodule
