
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
// File       : pcie_blk_plus_ll_tx.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : PCIe Block Plus Tx Bridge - instantiates the primary
 *                LocalLink bridge (which translates between Soft-macro
 *                LocalLink and the Hard-Block interface) and the TX Mux/arb
 *                module (which muxes in input from the config module)
 *
 *  NOTE:  Search for "FIXME" tags for high-priority changes to be made
 ****************************************************************************/

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

module pcie_blk_plus_ll_tx #
  ( parameter   TX_CPL_STALL_THRESHOLD   = 6,
    parameter   TX_DATACREDIT_FIX_EN     = 1,
    parameter   TX_DATACREDIT_FIX_1DWONLY= 1,
    parameter   TX_DATACREDIT_FIX_MARGIN = 6,
    parameter   MPS = 0,
    parameter   LEGACY_EP = 1'b0             // Legacy PCI endpoint?
  )
  (
   // Clock and reset

   input             clk,
   input             rst_n,

   // Transaction Link Up

   input             trn_lnk_up_n,

   // PCIe Block Tx Ports
   output [63:0]     llk_tx_data,
   output            llk_tx_src_rdy_n,
   output            llk_tx_src_dsc_n,
   output            llk_tx_sof_n,
   output            llk_tx_eof_n,
   output            llk_tx_sop_n,
   output            llk_tx_eop_n,
   output [1:0]      llk_tx_enable_n,
   output [2:0]      llk_tx_ch_tc,
   output [1:0]      llk_tx_ch_fifo,

   input             llk_tx_dst_rdy_n,
   input [9:0]       llk_tx_chan_space,            // ignored input
   input [7:0]       llk_tx_ch_posted_ready_n,     // ignored input
   input [7:0]       llk_tx_ch_non_posted_ready_n, // ignored input
   input [7:0]       llk_tx_ch_completion_ready_n, // ignored input


   // LocalLink Tx Ports from userapp

   input [63:0]      trn_td,
   input [7:0]       trn_trem_n,
   input             trn_tsof_n,
   input             trn_teof_n,
   input             trn_tsrc_rdy_n,
   input             trn_tsrc_dsc_n,    // NOTE: may not be supported by Block
   input             trn_terrfwd_n,     // NOTE: not supported by bridge/Block

   output            trn_tdst_rdy_n,
   output            trn_tdst_dsc_n,
   output reg [3:0]  trn_tbuf_av,

   // LocalLink TX Ports from cfg/mgmt logic
   input [63:0]      cfg_tx_td,
   input             cfg_tx_rem_n,
   input             cfg_tx_sof_n,
   input             cfg_tx_eof_n,
   input             cfg_tx_src_rdy_n,
   output            cfg_tx_dst_rdy_n,

   // Status output to config-bridge
   output reg         tx_err_wr_ep_n = 1'b1,
   input  wire  [7:0] tx_ch_credits_consumed,
   input  wire [11:0] tx_pd_credits_available,
   input  wire [11:0] tx_pd_credits_consumed,
   input  wire [11:0] tx_npd_credits_available,
   input  wire [11:0] tx_npd_credits_consumed,
   input  wire [11:0] tx_cd_credits_available,
   input  wire [11:0] tx_cd_credits_consumed,
   input  wire        pd_credit_limited,
   input  wire        npd_credit_limited,
   input  wire        cd_credit_limited,
   output wire        clear_cpl_count,
   input  wire  [7:0] trn_pfc_cplh_cl,
   input  wire        trn_pfc_cplh_cl_upd,
   input  wire        l0_stats_cfg_transmitted
   );

   wire [63:0] tx_td;
   wire        tx_sof_n;
   wire        tx_eof_n;
   wire [7:0]  tx_rem_n;
   wire        tx_src_dsc_n;
   wire        tx_src_rdy_n;
   wire        tx_dst_rdy_n;
   reg  [2:0]  trn_tbuf_av_int;

  pcie_blk_ll_tx_arb tx_arb
    (
     .clk( clk ),                                                    // I
     .rst_n( rst_n ),                                                // I
     // Outputs to original TX Bridge
     .tx_td( tx_td ),                                                // O[63:0]
     .tx_sof_n( tx_sof_n ),                                          // O
     .tx_eof_n( tx_eof_n ),                                          // O
     .tx_rem_n( tx_rem_n ),                                          // O
     .tx_src_dsc_n( tx_src_dsc_n ),                                  // O
     .tx_src_rdy_n( tx_src_rdy_n ),                                  // O
     .tx_dst_rdy_n( tx_dst_rdy_n ),                                  // I
     // User (TRN) Tx Ports
     .trn_td( trn_td ),                                              // I[63:0]
     .trn_trem_n( trn_trem_n ),                                      // I[7:0]
     .trn_tsof_n( trn_tsof_n ),                                      // I
     .trn_teof_n( trn_teof_n ),                                      // I
     .trn_tsrc_rdy_n( trn_tsrc_rdy_n ),                              // I
     .trn_tsrc_dsc_n( trn_tsrc_dsc_n ),                              // I
     .trn_tdst_rdy_n( trn_tdst_rdy_n ),                              // O 
     .trn_tdst_dsc_n( trn_tdst_dsc_n ),                              // O 
     // Config Tx Ports
     .cfg_tx_td( cfg_tx_td ),                                        // I[63:0]
     .cfg_tx_rem_n( cfg_tx_rem_n ),                                  // I
     .cfg_tx_sof_n( cfg_tx_sof_n ),                                  // I
     .cfg_tx_eof_n( cfg_tx_eof_n ),                                  // I
     .cfg_tx_src_rdy_n( cfg_tx_src_rdy_n ),                          // I
     .cfg_tx_dst_rdy_n( cfg_tx_dst_rdy_n )                           // O
     );
   
  always @(posedge clk) begin
    // Pulse tx_err_wr_ep_n output when a packet with the EP
    // bit set is transmitted
    tx_err_wr_ep_n  <= #`TCQ !(!tx_sof_n && !tx_src_rdy_n &&
                               !tx_dst_rdy_n && tx_td[46]);
  end
   
  pcie_blk_ll_tx #
    ( .TX_CPL_STALL_THRESHOLD   ( TX_CPL_STALL_THRESHOLD ),
      .TX_DATACREDIT_FIX_EN     ( TX_DATACREDIT_FIX_EN ),
      .TX_DATACREDIT_FIX_1DWONLY( TX_DATACREDIT_FIX_1DWONLY ),
      .TX_DATACREDIT_FIX_MARGIN ( TX_DATACREDIT_FIX_MARGIN ),
      .MPS                      ( MPS ),
      .LEGACY_EP                ( LEGACY_EP )
    )
  tx_bridge
    (
     // Clock & Reset
     .clk( clk ),                                                    // I
     .rst_n( rst_n ),                                                // I
     // Transaction Link Up
     .trn_lnk_up_n (trn_lnk_up_n),                                   // I
     // PCIe Block Tx Ports
     .llk_tx_data( llk_tx_data ),                                    // O[63:0] 
     .llk_tx_src_rdy_n( llk_tx_src_rdy_n ),                          // O
     .llk_tx_src_dsc_n( llk_tx_src_dsc_n ),                          // O
     .llk_tx_sof_n( llk_tx_sof_n ),                                  // O
     .llk_tx_eof_n( llk_tx_eof_n ),                                  // O
     .llk_tx_sop_n( llk_tx_sop_n ),                                  // O
     .llk_tx_eop_n( llk_tx_eop_n ),                                  // O
     .llk_tx_enable_n( llk_tx_enable_n ),                            // O[1:0]
     .llk_tx_ch_tc( llk_tx_ch_tc ),                                  // O[2:0]
     .llk_tx_ch_fifo( llk_tx_ch_fifo ),                              // O[1:0]
     .llk_tx_dst_rdy_n( llk_tx_dst_rdy_n ),                          // I
     .llk_tx_chan_space( llk_tx_chan_space ),                        // I[9:0]
     .llk_tx_ch_posted_ready_n( llk_tx_ch_posted_ready_n ),          // I[7:0]
     .llk_tx_ch_non_posted_ready_n( llk_tx_ch_non_posted_ready_n ),  // I[7:0]
     .llk_tx_ch_completion_ready_n( llk_tx_ch_completion_ready_n ),  // I[7:0]
     // LocalLink Tx Ports (from arbiter/mux)
     .trn_td( tx_td ),                                               // I[63:0]
     .trn_trem_n( tx_rem_n ),                                        // I[7:0]
     .trn_tsof_n( tx_sof_n ),                                        // I
     .trn_teof_n( tx_eof_n ),                                        // I
     .trn_tsrc_rdy_n( tx_src_rdy_n ),                                // I
     .trn_tsrc_dsc_n( tx_src_dsc_n ),                                // I
     .trn_terrfwd_n( 1'b1 ), // Unused input                         // I
     .trn_tdst_rdy_n( tx_dst_rdy_n ),                                // O
     .trn_tdst_dsc_n( tx_dst_dsc_n ),                                // O
     .trn_tbuf_av_cpl( trn_tbuf_av_cpl ),
     .tx_ch_credits_consumed   ( tx_ch_credits_consumed ),
     .tx_pd_credits_available  ( tx_pd_credits_available ),
     .tx_pd_credits_consumed   ( tx_pd_credits_consumed ),
     .tx_npd_credits_available ( tx_npd_credits_available ),
     .tx_npd_credits_consumed  ( tx_npd_credits_consumed ),
     .tx_cd_credits_available  ( tx_cd_credits_available ),
     .tx_cd_credits_consumed   ( tx_cd_credits_consumed ),
     .clear_cpl_count          ( clear_cpl_count ),
     .pd_credit_limited        ( pd_credit_limited ),
     .npd_credit_limited       ( npd_credit_limited ),
     .cd_credit_limited        ( cd_credit_limited ),
     .trn_pfc_cplh_cl          ( trn_pfc_cplh_cl ),
     .trn_pfc_cplh_cl_upd      ( trn_pfc_cplh_cl_upd ),
     .l0_stats_cfg_transmitted ( l0_stats_cfg_transmitted )
    );

  // trn_tbuf_av output -
  //   Each bit corresponds to one payload type:
  //     0:  non-posted
  //     1:  posted
  //     2:  completion
  //   When all FIFOs of that type have room, the corresponding bit of
  //   trn_tbuf_av is asserted, indicating that the Block can definitely
  //   accept a packet of that type.
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_tbuf_av_int    <= #`TCQ 3'b000;
    end else begin
      trn_tbuf_av_int[0] <= &(~llk_tx_ch_non_posted_ready_n);
      trn_tbuf_av_int[1] <= &(~llk_tx_ch_posted_ready_n);
      trn_tbuf_av_int[2] <= &(~llk_tx_ch_completion_ready_n);
    end
  end

  always @* begin
     trn_tbuf_av[2:0] = trn_tbuf_av_int[2:0];
     trn_tbuf_av[3]   = trn_tbuf_av_cpl;
  end

endmodule // pcie_blk_plus_ll_tx
