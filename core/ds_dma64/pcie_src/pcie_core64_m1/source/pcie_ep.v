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
// File       : pcie_ep.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Endpoint Wrapper
//--
//--
//--
//--------------------------------------------------------------------------------

`timescale 1 ns/1 ns

`define BAR_MASK_WIDTH_CALC(BAR)   BAR[63] ? (6'h3f) : \
                                   BAR[62] ? (6'h3e) : \
                                   BAR[61] ? (6'h3d) : \
                                   BAR[60] ? (6'h3c) : \
                                   BAR[59] ? (6'h3b) : \
                                   BAR[58] ? (6'h3a) : \
                                   BAR[57] ? (6'h39) : \
                                   BAR[56] ? (6'h38) : \
                                   BAR[55] ? (6'h37) : \
                                   BAR[54] ? (6'h36) : \
                                   BAR[53] ? (6'h35) : \
                                   BAR[52] ? (6'h34) : \
                                   BAR[51] ? (6'h33) : \
                                   BAR[50] ? (6'h32) : \
                                   BAR[49] ? (6'h31) : \
                                   BAR[48] ? (6'h30) : \
                                   BAR[47] ? (6'h2f) : \
                                   BAR[46] ? (6'h2e) : \
                                   BAR[45] ? (6'h2d) : \
                                   BAR[44] ? (6'h2c) : \
                                   BAR[43] ? (6'h2b) : \
                                   BAR[42] ? (6'h2a) : \
                                   BAR[41] ? (6'h29) : \
                                   BAR[40] ? (6'h28) : \
                                   BAR[39] ? (6'h27) : \
                                   BAR[38] ? (6'h26) : \
                                   BAR[37] ? (6'h25) : \
                                   BAR[36] ? (6'h24) : \
                                   BAR[35] ? (6'h23) : \
                                   BAR[34] ? (6'h22) : \
                                   BAR[33] ? (6'h21) : \
                                   BAR[32] ? (6'h20) : \
                                   BAR[31] ? (6'h1f) : \
                                   BAR[30] ? (6'h1e) : \
                                   BAR[29] ? (6'h1d) : \
                                   BAR[28] ? (6'h1c) : \
                                   BAR[27] ? (6'h1b) : \
                                   BAR[26] ? (6'h1a) : \
                                   BAR[25] ? (6'h19) : \
                                   BAR[24] ? (6'h18) : \
                                   BAR[23] ? (6'h17) : \
                                   BAR[22] ? (6'h16) : \
                                   BAR[21] ? (6'h15) : \
                                   BAR[20] ? (6'h14) : \
                                   BAR[19] ? (6'h13) : \
                                   BAR[18] ? (6'h12) : \
                                   BAR[17] ? (6'h11) : \
                                   BAR[16] ? (6'h10) : \
                                   BAR[15] ? (6'h0f) : \
                                   BAR[14] ? (6'h0e) : \
                                   BAR[13] ? (6'h0d) : \
                                   BAR[12] ? (6'h0c) : \
                                   BAR[11] ? (6'h0b) : \
                                   BAR[10] ? (6'h0a) : \
                                   BAR[9]  ? (6'h09) : \
                                   BAR[8]  ? (6'h08) : \
                                   BAR[7]  ? (6'h07) : \
                                   BAR[6]  ? (6'h06) : \
                                   BAR[5]  ? (6'h05) : (6'h04)
module   pcie_ep_top #
(
   parameter   G_USER_RESETS = 0,
   parameter   G_SIM = 0,                          // This is for simulation (1) or not (0)
   parameter   G_CHIPSCOPE = 0,                    // Use Chipscope (1) or not (0)

   parameter   INTF_CLK_FREQ = 0,                  // interface clock frequency (0=62.5, 1=100, 2=250)
   parameter   REF_CLK_FREQ = 1,                   // reference clock frequency (0=100, 1=250)
   parameter   USE_V5FXT = 0,                      // V5FXT Product (0=V5LXT/V5SXT, 1=V5FXT)

   parameter   VEN_ID = 16'h10ee,                  // vendor id                                      cfg[ 15:  0]
   parameter   DEV_ID = 16'h0007,                  // device id                                      cfg[ 31: 16]
   parameter   REV_ID = 8'h00,                     // revision id                                    cfg[ 39: 32]
   parameter   CLASS_CODE = 24'h00_00_00,          // class code                                     cfg[ 63: 40]
   parameter   BAR0 = 32'hffff_0001,               // base address                                   cfg[ 95: 64]
   parameter   BAR1 = 32'hffff_0000,               // base address                                   cfg[127: 96]
   parameter   BAR2 = 32'hffff_0004,               // base address                                   cfg[159:128]
   parameter   BAR3 = 32'hffff_ffff,               // base address                                   cfg[191:160]
   parameter   BAR4 = 32'h0000_0000,               // base address                                   cfg[223:192]
   parameter   BAR5 = 32'h0000_0000,               // base address                                   cfg[255:224]
   parameter   CARDBUS_CIS_PTR = 32'h0000_0000,    // cardbus cis pointer                            cfg[287:256]
   parameter   SUBSYS_VEN_ID = 16'h10ee,           // subsystem vendor id                            cfg[303:288]
   parameter   SUBSYS_ID = 16'h0007,               // subsystem id                                   cfg[319:304]
   parameter   XROM_BAR = 32'hfff0_0001,           // expansion rom bar                              cfg[351:320]

   // Express Capabilities (byte offset 03H-02H), cfg[367:352]
   parameter   INTR_MSG_NUM = 5'b00000,           // Interrupt Msg No.                              cfg[365:361]
   parameter   SLT_IMPL = 1'b0,                   // Slot Implemented                               cfg[360:360]
   parameter   DEV_PORT_TYPE = 4'b0000,           // Dev/Port Type                                  cfg[359:356]
   parameter   CAP_VER = 4'b0001,                 // Capability Version                             cfg[355:352]

   // Express Device Capabilities (byte offset 07H-04H), cfg[399:368]
   parameter   CAPT_SLT_PWR_LIM_SC = 2'b00,      // Capt Slt Pwr Lim Sc                            cfg[395:394]
   parameter   CAPT_SLT_PWR_LIM_VA = 8'h00,      // Capt Slt Pwr Lim Va                            cfg[393:386]
   parameter   PWR_INDI_PRSNT = 1'b0,            // Power Indi Prsnt                               cfg[382:382]
   parameter   ATTN_INDI_PRSNT = 1'b0,           // Attn Indi Prsnt                                cfg[381:381]
   parameter   ATTN_BUTN_PRSNT = 1'b0,           // Attn Butn Prsnt                                cfg[380:380]
   parameter   EP_L1_ACCPT_LAT = 3'b111,         // EP L1 Accpt Lat                                cfg[379:377]
   parameter   EP_L0s_ACCPT_LAT = 3'b111,        // EP L0s Accpt Lat                               cfg[376:374]
   parameter   EXT_TAG_FLD_SUP = 1'b0,           // Ext Tag Fld Sup                                cfg[373:373]
   parameter   PHANTM_FUNC_SUP = 2'b00,          // Phantm Func Sup                                cfg[372:371]
   parameter   MPS = 3'b101,                     // Max Payload Size                               cfg[370:368]

   // Express Link Capabilities (byte offset 00H && 0CH-0FH), cfg[431:400]
   parameter   L1_EXIT_LAT = 3'b111,             // L1 Exit Lat                                    cfg[417:415]
   parameter   L0s_EXIT_LAT = 3'b111,            // L0s Exit Lat                                   cfg[414:412]
   parameter   ASPM_SUP = 2'b01,                 // ASPM Supported                                 cfg[411:410]
   parameter   MAX_LNK_WDT = 6'b000001,          // Max Link Width                                 cfg[409:404]
   parameter   MAX_LNK_SPD = 4'b0001,            // Max Link Speed                                 cfg[403:400]

   parameter   TRM_TLP_DGST_ECRC = 1'b0,         // Trim ECRC                                      cfg[508]
   parameter   FRCE_NOSCRMBL = 1'b0,             // Force No Scrambling                            cfg[510]
   parameter   INFINITECOMPLETIONS = "TRUE",     // Completion credits are infinite
   parameter   VC0_CREDITS_PH = 8,               // Num Posted Headers
   parameter   VC0_CREDITS_NPH = 8,              // Num Non-Posted Headers
   parameter   CPL_STREAMING_PRIORITIZE_P_NP = 0,// arb priority to P/NP during cpl stream

   parameter   SLOT_CLOCK_CONFIG = "FALSE",

   parameter   C_CALENDAR_LEN     = (DEV_PORT_TYPE==4'b0000)? 16: 15,
                                                                // RSt Tc  RSt TP1 RSt Tc  RSt TC1 RSt TP2 RSt Tc  Rst TC2 RSt  F
   parameter   C_CALENDAR_SEQ     = (DEV_PORT_TYPE==4'b0000)? 128'h68__08__68__2C__68__08__68__34__68__0C__68__08__68__14__68__FF:
                                                                // RSt Tc  TP1 RSt TN1 Tc  RSt TC1 TP2 RSt TN2 Tc  RSt TC2  X
                                                              120'h68__08__2C__68__30__08__68__34__0C__68__10__08__68__14__FF,
   parameter   C_CALENDAR_SUB_LEN = 12,
                                     // PHal PHco NPHal NPHco   PDal  PDco PHli  NPHli CHli  PDli  PHli  CDli
   parameter   C_CALENDAR_SUB_SEQ = 96'h40____60____44____64____4C____6C____20____24____28____2C____30____34,
   parameter   TX_DATACREDIT_FIX_EN     = 1,
   parameter   TX_DATACREDIT_FIX_1DWONLY= 1,
   parameter   TX_DATACREDIT_FIX_MARGIN = 6,
   parameter   TX_CPL_STALL_THRESHOLD   = 6,

   // PM CAP REGISTER  (byte offset 03-02H), cfg[527:512]
   parameter   PME_SUP = 5'b01111,               // PME Support                                    cfg[527:523]
   parameter   D2_SUP = 1'b1,                    // D2 Support                                     cfg[522:522]
   parameter   D1_SUP = 1'b1,                    // D1 Support                                     cfg[521:521]
   parameter   AUX_CT = 3'b000,                  // AUX Current                                    cfg[520:518]
   parameter   DSI = 1'b0,                       // Dev Specific Initialisation                    cfg[517:517]
   parameter   PME_CLK = 1'b0,                   // PME Clock                                      cfg[515:515]
   parameter   PM_CAP_VER = 3'b010,              // Version                                        cfg[514:512]

   parameter   MSI_VECTOR = 3'b000,                     // MSI Vector Capability
   parameter   MSI_8BIT_EN = 1'b0,                     // Enable 8-bit MSI Vectors
   parameter   PWR_CON_D0_STATE = 8'h1E,        // Power consumed in D0 state                     cfg[535:528]
   parameter   CON_SCL_FCTR_D0_STATE = 8'h01,   // Scale Factor for power consumed in D0 state    cfg[543:536]
   parameter   PWR_CON_D1_STATE = 8'h1E,        // Power consumed in D1 state                     cfg[551:544]
   parameter   CON_SCL_FCTR_D1_STATE = 8'h01,   // Scale Factor for power consumed in D1 state    cfg[559:552]
   parameter   PWR_CON_D2_STATE = 8'h1E,        // Power consumed in D2 state                     cfg[567:560]
   parameter   CON_SCL_FCTR_D2_STATE = 8'h01,   // Scale Factor for power consumed in D2 state    cfg[575:568]
   parameter   PWR_CON_D3_STATE = 8'h1E,        // Power consumed in D3 state                     cfg[583:576]
   parameter   CON_SCL_FCTR_D3_STATE = 8'h01,   // Scale Factor for power consumed in D3 state    cfg[591:584]

   parameter   PWR_DIS_D0_STATE = 8'h1E,        // Power dissipated in D0 state                   cfg[599:592]
   parameter   DIS_SCL_FCTR_D0_STATE = 8'h01,   // Scale Factor for power dissipated in D0 state  cfg[607:600]
   parameter   PWR_DIS_D1_STATE = 8'h1E,        // Power dissipated in D1 state                   cfg[615:608]
   parameter   DIS_SCL_FCTR_D1_STATE = 8'h01,   // Scale Factor for power dissipated in D1 state  cfg[623:616]
   parameter   PWR_DIS_D2_STATE = 8'h1E,        // Power dissipated in D2 state                   cfg[631:624]
   parameter   DIS_SCL_FCTR_D2_STATE = 8'h01,   // Scale Factor for power dissipated in D2 state  cfg[639:632]
   parameter   PWR_DIS_D3_STATE = 8'h1E,        // Power dissipated in D3 state                   cfg[647:640]
   parameter   DIS_SCL_FCTR_D3_STATE = 8'h01,   // Scale Factor for power dissipated in D3 state  cfg[655:648]
   parameter   TXDIFFBOOST = "FALSE",
   parameter   GTDEBUGPORTS = 0

)

(
  // System Interface

  input wire          sys_clk,
  input wire          sys_reset_n,

  // PCIe Interface

  input  wire  [MAX_LNK_WDT - 1: 0] pci_exp_rxn,
  input  wire  [MAX_LNK_WDT - 1: 0] pci_exp_rxp,
  output wire  [MAX_LNK_WDT - 1: 0] pci_exp_txn,
  output wire  [MAX_LNK_WDT - 1: 0] pci_exp_txp,

  // Configuration Interface

  output      [31:0] cfg_do,
  input wire  [31:0] cfg_di,
  input wire   [3:0] cfg_byte_en_n,
  input wire   [9:0] cfg_dwaddr,
  output             cfg_rd_wr_done_n,
  input wire         cfg_wr_en_n,
  input wire         cfg_rd_en_n,
  input wire         cfg_err_cor_n,
  input wire         cfg_err_ur_n,
  input wire         cfg_err_ecrc_n,
  input wire         cfg_err_cpl_timeout_n,
  input wire         cfg_err_cpl_abort_n,
  input wire         cfg_err_cpl_unexpect_n,
  input wire         cfg_err_posted_n,
  input wire         cfg_err_locked_n,
  input wire         cfg_interrupt_n,
  output             cfg_interrupt_rdy_n,
   input wire                                  cfg_interrupt_assert_n,
   input         [7:0]                         cfg_interrupt_di,
   output    [7:0]                             cfg_interrupt_do,
   output    [2:0]                             cfg_interrupt_mmenable, 
   output                                      cfg_interrupt_msienable,
  input wire         cfg_turnoff_ok_n,
  output             cfg_to_turnoff_n,
  input wire         cfg_pm_wake_n,
  input wire  [47:0] cfg_err_tlp_cpl_header,
  output             cfg_err_cpl_rdy_n,
  input       [63:0] cfg_dsn,
  input wire         cfg_trn_pending_n,
  output      [15:0] cfg_status,
  output      [15:0] cfg_command,
  output      [15:0] cfg_dstatus,
  output      [15:0] cfg_dcommand,
  output      [15:0] cfg_lstatus,
  output      [15:0] cfg_lcommand,
  output       [7:0] cfg_bus_number,
  output       [4:0] cfg_device_number,
  output       [2:0] cfg_function_number,
  output       [2:0] cfg_pcie_link_state_n,

  // Transaction Tx Interface

  input  wire [63:0] trn_td,
  input  wire [7:0]  trn_trem_n,
  input  wire        trn_tsof_n,
  input              trn_teof_n,
  input              trn_tsrc_rdy_n,
  input              trn_tsrc_dsc_n,
  input              trn_terrfwd_n,

  output             trn_tdst_rdy_n,
  output             trn_tdst_dsc_n,
  output      [3:0]  trn_tbuf_av,

 `ifdef PFC_CISCO_DEBUG
  output      [7:0]  trn_pfc_nph_cl,
  output      [11:0] trn_pfc_npd_cl,
  output      [7:0]  trn_pfc_ph_cl,
  output      [11:0] trn_pfc_pd_cl,
  output      [7:0]  trn_pfc_cplh_cl,
  output      [11:0] trn_pfc_cpld_cl,
 `endif

   // Transaction Rx Interface

  input  wire        trn_rnp_ok_n,
  input  wire        trn_rdst_rdy_n,

  output      [63:0] trn_rd,
  output      [7:0]  trn_rrem_n,
  output             trn_rsof_n,
  output             trn_reof_n,
  output             trn_rsrc_rdy_n,
  output             trn_rsrc_dsc_n,
  output             trn_rerrfwd_n,
  output      [6:0]  trn_rbar_hit_n,
  output      [7:0]  trn_rfc_nph_av,
  output      [11:0] trn_rfc_npd_av,
  output      [7:0]  trn_rfc_ph_av,
  output      [11:0] trn_rfc_pd_av,
  output      [7:0]  trn_rfc_cplh_av,
  output      [11:0] trn_rfc_cpld_av,
  input              trn_rcpl_streaming_n,

`ifdef GTP_DEBUG
  //Debugging Ports
  output             GTPCLK_bufg,
  output             REFCLK_OUT_bufg,
  output             LINK_UP,
  output             clock_lock,
  output             pll_lock,
  output             core_clk,
  output             user_clk,
`endif

  output             refclkout,

  input                            gt_dclk,
  input     [MAX_LNK_WDT*7-1:0]    gt_daddr,
  input     [MAX_LNK_WDT-1:0]      gt_den,
  input     [MAX_LNK_WDT-1:0]      gt_dwen,
  input     [MAX_LNK_WDT*16-1:0]   gt_di,
  output    [MAX_LNK_WDT*16-1:0]   gt_do,
  output    [MAX_LNK_WDT-1:0]      gt_drdy,

  input     [2:0]                  gt_txdiffctrl_0,
  input     [2:0]                  gt_txdiffctrl_1,
  input     [2:0]                  gt_txbuffctrl_0,
  input     [2:0]                  gt_txbuffctrl_1,
  input     [2:0]                  gt_txpreemphesis_0,
  input     [2:0]                  gt_txpreemphesis_1,

   // Transaction Common Interface
  output             trn_clk,
  output             trn_reset_n,
  output             trn_lnk_up_n,
  input              fast_train_simulation_only

);

  // Reset wire
  wire fe_fundamental_reset_n;

// Inputs to the pcie core

  wire         fe_compliance_avoid = 1'b0;
  wire         fe_l0_cfg_loopback_master = 1'b0;
  wire         fe_l0_transactions_pending;
  wire         fe_l0_set_completer_abort_error = 1'b0;
  wire         fe_l0_set_detected_corr_error;
  wire         fe_l0_set_detected_fatal_error;
  wire         fe_l0_set_detected_nonfatal_error;
  wire         fe_l0_set_link_detected_parity_error = 1'b0;
  wire         fe_l0_set_link_master_data_parity = 1'b0;
  wire         fe_l0_set_link_received_master_abort = 1'b0;
  wire         fe_l0_set_link_received_target_abort = 1'b0;
  wire         fe_l0_set_link_system_error = 1'b0;
  wire         fe_l0_set_link_signalled_target_abort = 1'b0;
  wire         fe_l0_set_user_detected_parity_error;
  wire         fe_l0_set_user_master_data_parity;
  wire         fe_l0_set_user_received_master_abort;
  wire         fe_l0_set_user_received_target_abort;
  wire         fe_l0_set_user_system_error;
  wire         fe_l0_set_user_signalled_target_abort;
  wire         fe_l0_set_unexpected_completion_uncorr_error = 1'b0;
  wire         fe_l0_set_unexpected_completion_corr_error = 1'b0;
  wire         fe_l0_set_unsupported_request_nonposted_error = 1'b0;
  wire         fe_l0_set_unsupported_request_other_error;
  wire [127:0] fe_l0_packet_header_from_user = 128'b0;


  wire         fe_main_power = 1'b1;

  wire         fe_l0_set_completion_timeout_uncorr_error = 1'b0;
  wire         fe_l0_set_completion_timeout_corr_error = 1'b0;

  wire [3:0]   fe_l0_msi_request0; // = 4'h0;
  wire         fe_l0_legacy_int_funct0; // = 1'b0;

  wire [10:0]  mgmt_addr;
  wire         mgmt_rden;

  // Outputs from the pcie core


  wire [12:0]  fe_l0_completer_id;
  wire [2:0]   maxp;
  wire         fe_l0_rx_dll_tlp_ecrc_ok;
  wire         fe_l0_dll_tx_pm_dllp_outstanding;
  wire         fe_l0_first_cfg_write_occurred;
  wire         fe_l0_cfg_loopback_ack;
  wire         fe_l0_mac_upstream_downstream;
  wire [1:0]   fe_l0_rx_mac_link_error;
  wire [1:0]   fe_l0_rx_mac_link_error_ext;
  wire         fe_l0_mac_link_up;
  wire [3:0]   fe_l0_mac_negotiated_link_width;
  wire         fe_l0_mac_link_training;
  wire [3:0]   fe_l0_ltssm_state;
  wire [7:0]   fe_l0_dll_vc_status;
  wire [7:0]   fe_l0_dl_up_down;
  wire [6:0]   fe_l0_dll_error_vector;
  wire [6:0]   fe_l0_dll_error_vector_ext;
  wire [1:0]   fe_l0_dll_as_rx_state;
  wire         fe_l0_dll_as_tx_state;
  wire         fe_l0_as_autonomous_init_completed;

  wire         fe_l0_unlock_received;
  wire         fe_l0_corr_err_msg_rcvd;
  wire         fe_l0_fatal_err_msg_rcvd;
  wire         fe_l0_nonfatal_err_msg_rcvd;
  wire [15:0]  fe_l0_err_msg_req_id;
  wire         fe_l0_fwd_corr_err_out;
  wire         fe_l0_fwd_fatal_err_out;
  wire         fe_l0_fwd_nonfatal_err_out;

  wire         fe_l0_received_assert_inta_legacy_int;
  wire         fe_l0_received_assert_intb_legacy_int;
  wire         fe_l0_received_assert_intc_legacy_int;
  wire         fe_l0_received_assert_intd_legacy_int;
  wire         fe_l0_received_deassert_inta_legacy_int;
  wire         fe_l0_received_deassert_intb_legacy_int;
  wire         fe_l0_received_deassert_intc_legacy_int;
  wire         fe_l0_received_deassert_intd_legacy_int;

  wire         fe_l0_msi_enable0;
  wire [2:0]   fe_l0_multi_msg_en0;
  wire         fe_l0_stats_dllp_received;
  wire         fe_l0_stats_dllp_transmitted;
  wire         fe_l0_stats_os_received;
  wire         fe_l0_stats_os_transmitted;
  wire         fe_l0_stats_tlp_received;
  wire         fe_l0_stats_tlp_transmitted;
  wire         fe_l0_stats_cfg_received;
  wire         fe_l0_stats_cfg_transmitted;
  wire         fe_l0_stats_cfg_other_received;
  wire         fe_l0_stats_cfg_other_transmitted;

  wire [1:0]   fe_l0_attention_indicator_control;
  wire [1:0]   fe_l0_power_indicator_control;
  wire         fe_l0_power_controller_control;
  wire         fe_l0_toggle_electromechanical_interlock;
  wire         fe_l0_rx_beacon;
  wire [1:0]   fe_l0_pwr_state0;
  wire         fe_l0_pme_req_in;
  wire         fe_l0_pme_ack;
  wire         fe_l0_pme_req_out;
  wire         fe_l0_pme_en;
  wire         fe_l0_pwr_inhibit_transfers;
  wire         fe_l0_pwr_l1_state;
  wire         fe_l0_pwr_l23_ready_device;
  wire         fe_l0_pwr_l23_ready_state;
  wire         fe_l0_pwr_tx_l0s_state;
  wire         fe_l0_pwr_turn_off_req;
  wire         fe_l0_rx_dll_pm;
  wire [2:0]   fe_l0_rx_dll_pm_type;
  wire         fe_l0_tx_dll_pm_updated;
  wire         fe_l0_mac_new_state_ack;
  wire         fe_l0_mac_rx_l0s_state;
  wire         fe_l0_mac_entered_l0;
  wire         fe_l0_dll_rx_ack_outstanding;
  wire         fe_l0_dll_tx_outstanding;
  wire         fe_l0_dll_tx_non_fc_outstanding;
  wire [1:0]   fe_l0_rx_dll_tlp_end;
  wire         fe_l0_tx_dll_sbfc_updated;
  wire [18:0]  fe_l0_rx_dll_sbfc_data;
  wire         fe_l0_rx_dll_sbfc_update;
  wire [7:0]   fe_l0_tx_dll_fc_npost_byp_updated;
  wire [7:0]   fe_l0_tx_dll_fc_post_ord_updated;
  wire [7:0]   fe_l0_tx_dll_fc_cmpl_mc_updated;
  wire [19:0]  fe_l0_rx_dll_fc_npost_byp_cred;
  wire [7:0]   fe_l0_rx_dll_fc_npost_byp_update;
  wire [23:0]  fe_l0_rx_dll_fc_post_ord_cred;
  wire [7:0]   fe_l0_rx_dll_fc_post_ord_update;
  wire [23:0]  fe_l0_rx_dll_fc_cmpl_mc_cred;
  wire [7:0]   fe_l0_rx_dll_fc_cmpl_mc_update;
  wire [3:0]   fe_l0_uc_byp_found;
  wire [3:0]   fe_l0_uc_ord_found;
  wire [2:0]   fe_l0_mc_found;
  wire [2:0]   fe_l0_transformed_vc;

  wire [2:0]  mem_tx_tc_select;
  wire [1:0]  mem_tx_fifo_select;
  wire [1:0]  mem_tx_enable;
  wire        mem_tx_header;
  wire        mem_tx_first;
  wire        mem_tx_last;

  wire        mem_tx_discard;
  wire [63:0] mem_tx_data;
  wire        mem_tx_complete;
  wire [2:0]  mem_rx_tc_select;
  wire [1:0]  mem_rx_fifo_select;
  wire        mem_rx_request;
  wire [31:0] mem_debug;


  wire [7:0]  fe_rx_posted_available;
  wire [7:0]  fe_rx_non_posted_available;
  wire [7:0]  fe_rx_completion_available;
  wire        fe_rx_config_available;

  wire [7:0]  fe_rx_posted_partial;
  wire [7:0]  fe_rx_non_posted_partial;
  wire [7:0]  fe_rx_completion_partial;
  wire        fe_rx_config_partial;

  wire        fe_rx_request_end;
  wire [1:0]  fe_rx_valid;
  wire        fe_rx_header;
  wire        fe_rx_first;
  wire        fe_rx_last;
  wire        fe_rx_discard;
  wire [63:0] fe_rx_data;
  wire [7:0]  fe_tc_status;

  wire [7:0]  fe_tx_posted_ready;
  wire [7:0]  fe_tx_non_posted_ready;
  wire [7:0]  fe_tx_completion_ready;
  wire        fe_tx_config_ready;
  wire [7:0]  fe_leds_out;

  wire        fe_io_space_enable;
  wire        fe_mem_space_enable;
  wire        fe_bus_master_enable;
  wire        fe_parity_error_response;
  wire        fe_serr_enable;
  wire        fe_interrupt_disable;
  wire        fe_ur_reporting_enable;

  wire [2:0]  fe_max_payload_size;
  wire [2:0]  fe_max_read_request_size;

  wire [31:0] mgmt_rdata;
  wire [31:0] mgmt_wdata;
  wire [3:0]  mgmt_bwren;
  wire [16:0] mgmt_pso;
  wire [6:0]  mgmt_stats_credit_sel;
  wire [11:0] mgmt_stats_credit;

  // Local Link Transmit

  wire [7:0]  llk_tc_status;
  wire [63:0] llk_tx_data;
  wire [9:0]  llk_tx_chan_space;
  wire [1:0]  llk_tx_enable_n;
  wire [2:0]  llk_tx_ch_tc;
  wire [1:0]  llk_tx_ch_fifo;
  wire [7:0]  llk_tx_ch_posted_ready_n;
  wire [7:0]  llk_tx_ch_non_posted_ready_n;
  wire [7:0]  llk_tx_ch_completion_ready_n;
  wire        llk_rx_src_last_req_n;
  wire        llk_rx_dst_req_n;
  wire        llk_rx_dst_cont_req_n;

  // Local Link Receive

  wire [63:0] llk_rx_data;
  wire [1:0]  llk_rx_valid_n;
  wire [2:0]  llk_rx_ch_tc;
  wire [1:0]  llk_rx_ch_fifo;
  wire [15:0] llk_rx_preferred_type;
  wire [7:0]  llk_rx_ch_posted_available_n;
  wire [7:0]  llk_rx_ch_non_posted_available_n;
  wire [7:0]  llk_rx_ch_completion_available_n;
  wire [7:0]  llk_rx_ch_posted_partial_n;
  wire [7:0]  llk_rx_ch_non_posted_partial_n;
  wire [7:0]  llk_rx_ch_completion_partial_n;

// Misc wires and regs

  wire        cfg_reset_b;
  wire        grestore_b;
  wire        gwe_b;
  wire        ghigh_b;

  wire        GTPCLK_bufg;
  wire        REFCLK_OUT_bufg;
  wire        core_clk;
  wire [3:0]  PLLLKDET_OUT;

  wire        GTPRESET;

  wire [24:0] ILA_DATA;

  wire        user_clk;

  wire        GSR;

  wire        clk0;
  wire        clkfb;
  wire        clkdv;
  wire [15:0] not_connected;

  wire [7:0]  RESETDONE;
  reg         app_reset_n = 0;
  reg         app_reset_n_flt_reg = 0;
  reg         trn_lnk_up_n_reg = 1;
  reg         trn_lnk_up_n_flt_reg = 1;
  reg         mgt_reset_n_flt_reg = 0;
  wire        mgt_reset_n;
  wire        mgmt_rst;
  wire        clock_lock;

`ifdef MANAGEMENT_WRITE
  wire [10:0]  bridge_mgmt_addr;
  wire         bridge_mgmt_rden;
  wire         bridge_mgmt_wren;
  wire [31:0]  bridge_mgmt_wdata;
  wire [3:0]   bridge_mgmt_bwren;

  wire 	     trn_rst_n;
  wire 	    mgmt_rdy;

  wire		mgmt_rst_delay_n;
  wire		mgmt_reset_delay_n;
`endif

generate
  if (G_SIM == 1) begin : sim_resets
    assign GSR = glbl.GSR;
  end else begin : imp_resets
    assign GSR = 1'b0;
  end
endgenerate

assign fe_fundamental_reset_n = sys_reset_n;
assign GTPRESET = !sys_reset_n;
assign mgmt_rst = ~sys_reset_n;
assign refclkout = REFCLK_OUT_bufg;
`ifdef MANAGEMENT_WRITE
assign mgmt_rst_delay_n = mgmt_reset_delay_n;
`endif

wire LINK_UP;
assign LINK_UP = llk_tc_status[0];
wire pll_lock;
assign pll_lock = PLLLKDET_OUT[0];


// Orphaned signals
wire [338:0] DEBUG;
wire mgmt_wren;

assign llk_rx_src_dsc_n = 1'b1;

/*******************************************************
Convert parameters passed in. Check requirements on
parameters - strings, integers etc  from the
pcie blk model and convert appropriately.
********************************************************/

// RATIO = 1 if USERCLK = 250 MHz; RATIO = 2 if USERCLK = 125 MHz; RATIO = 4 if USERCLK = 62.5 MHz
// 0: INTF_CLK_FREQ = 62.5 MHz; 1: INTF_CLK_FREQ = 125 MHz; 2: INTF_CLK_FREQ = 250 MHz
localparam integer INTF_CLK_RATIO = (MAX_LNK_WDT == 1) ? ((INTF_CLK_FREQ ==  1) ?  2 : 4) :
                                    ((MAX_LNK_WDT == 4) ? ((INTF_CLK_FREQ == 1) ?  2 : 1) :
                                    ((INTF_CLK_FREQ == 2) ?  1 : 2));

`define INTF_CLK_DIVIDED  ((INTF_CLK_RATIO > 1) ? ("TRUE") : ("FALSE"))

localparam BAR0_ENABLED = BAR0[2] ? |{BAR1,BAR0} : |BAR0;
`define BAR0_EXIST  ((BAR0_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR0_IO_OR_MEM = BAR0[0];
localparam BAR0_32_OR_64 = BAR0[2];
localparam [63:0] BAR0_LOG2_EP = ({(BAR0[2] ? ~{BAR1,BAR0[31:6]} : {32'h0,~BAR0[31:6]}), 6'b111111} + 64'h1);
localparam [63:0] BAR0_LOG2_LEGACY = ({(BAR0[2] ? ~{BAR1,BAR0[31:4]} : {32'h0,~BAR0[31:4]}), 4'b1111} + 64'h1);
localparam [63:0] BAR0_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR0_LOG2_EP : BAR0_LOG2_LEGACY;
localparam [5:0]  BAR0_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR0_LOG2);
`define BAR0_PREFETCHABLE  ((BAR0[3]) ? ("TRUE") : ("FALSE"))

localparam BAR1_ENABLED = BAR0[2] ? 0 : |BAR1;
`define BAR1_EXIST  ((BAR1_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR1_IO_OR_MEM = BAR1[0];
localparam [63:0] BAR1_LOG2_EP = ({32'h0,~BAR1[31:6], 6'b111111} + 64'h1);
localparam [63:0] BAR1_LOG2_LEGACY = ({32'h0,~BAR1[31:4], 4'b1111} + 64'h1);
localparam [63:0] BAR1_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR1_LOG2_EP : BAR1_LOG2_LEGACY;
localparam [5:0]  BAR1_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR1_LOG2);
`define BAR1_PREFETCHABLE  ((BAR1[3]) ? ("TRUE") : ("FALSE"))

localparam BAR2_ENABLED = BAR2[2] ? |{BAR3,BAR2} : |BAR2;
`define BAR2_EXIST  ((BAR2_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR2_IO_OR_MEM = BAR2[0];
localparam BAR2_32_OR_64 = BAR2[2];
localparam [63:0] BAR2_LOG2_EP = ({(BAR2[2] ? ~{BAR3,BAR2[31:6]} : {32'h0,~BAR2[31:6]}), 6'b111111} + 64'h1);
localparam [63:0] BAR2_LOG2_LEGACY = ({(BAR2[2] ? ~{BAR3,BAR2[31:4]} : {32'h0,~BAR2[31:4]}), 4'b1111} + 64'h1);
localparam [63:0] BAR2_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR2_LOG2_EP : BAR2_LOG2_LEGACY;
localparam [5:0]  BAR2_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR2_LOG2);
`define BAR2_PREFETCHABLE  ((BAR2[3]) ? ("TRUE") : ("FALSE"))

localparam BAR3_ENABLED = BAR2[2] ? 0 : |BAR3;
`define BAR3_EXIST  ((BAR3_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR3_IO_OR_MEM = BAR3[0];
localparam [63:0] BAR3_LOG2_EP = ({32'h0,~BAR3[31:6], 6'b111111} + 64'h1);
localparam [63:0] BAR3_LOG2_LEGACY = ({32'h0,~BAR3[31:4], 4'b1111} + 64'h1);
localparam [63:0] BAR3_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR3_LOG2_EP : BAR3_LOG2_LEGACY;
localparam [5:0]  BAR3_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR3_LOG2);
`define BAR3_PREFETCHABLE  ((BAR3[3]) ? ("TRUE") : ("FALSE"))

localparam BAR4_ENABLED = BAR4[2] ? |{BAR5,BAR4} : |BAR4;
`define BAR4_EXIST  ((BAR4_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR4_IO_OR_MEM = BAR4[0];
localparam BAR4_32_OR_64 = BAR4[2];
localparam [63:0] BAR4_LOG2_EP = ({(BAR4[2] ? ~{BAR5,BAR4[31:6]} : {32'h0,~BAR4[31:6]}), 6'b111111} + 64'h1);
localparam [63:0] BAR4_LOG2_LEGACY = ({(BAR4[2] ? ~{BAR5,BAR4[31:4]} : {32'h0,~BAR4[31:4]}), 4'b1111} + 64'h1);
localparam [63:0] BAR4_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR4_LOG2_EP : BAR4_LOG2_LEGACY;
localparam [5:0]  BAR4_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR4_LOG2);
`define BAR4_PREFETCHABLE  ((BAR4[3]) ? ("TRUE") : ("FALSE"))

localparam BAR5_ENABLED = BAR4[2] ? 0 : |BAR5;
`define BAR5_EXIST  ((BAR5_ENABLED) ? ("TRUE") : ("FALSE"))
localparam BAR5_IO_OR_MEM = BAR5[0];
localparam [63:0] BAR5_LOG2_EP = ({32'h0,~BAR5[31:6], 6'b111111} + 64'h1);
localparam [63:0] BAR5_LOG2_LEGACY = ({32'h0,~BAR5[31:4], 4'b1111} + 64'h1);
localparam [63:0] BAR5_LOG2 = (DEV_PORT_TYPE == 4'b0000) ? BAR5_LOG2_EP : BAR5_LOG2_LEGACY;
localparam [5:0]  BAR5_MASKWIDTH = `BAR_MASK_WIDTH_CALC(BAR5_LOG2);
`define BAR5_PREFETCHABLE  ((BAR5[3]) ? ("TRUE") : ("FALSE"))

localparam FEATURE_ENABLE = 1;
localparam FEATURE_DISABLE = 0;

`define DSI_x  ((DSI) ? ("TRUE") : ("FALSE"))

//* Program the PCIe Block Advertised NFTS
//  ---------------------------------------
localparam TX_NFTS = 255;

//* Program the PCIe Block Retry Buffer Size
//  ----------------------------------------
//  9 = 4096B Space (1 Retry BRAM)
localparam RETRY_RAM = 9;

//* Program the PCIe Block Reveiver
//  -------------------------------
// Space for:
// Posted = 2048 B (4 MPS TLPs)
// Non-Posted = 192 B (~12 NP TLPs??)
// Completion = 2048 B (4 MPS TLPs)

localparam VC0_RXFIFO_P = 8*(24+256);
//                        |  |   |
//                        |  |   |____PAYLOAD
//                        |  |________HEADER
//                        |________Max. Number of Packets in TX Buffer
localparam VC0_RXFIFO_NP = 8*24;
localparam VC0_RXFIFO_CPL = 9*(24+256); //8*(16+256);
//                          |  |   |
//                          |  |   |____PAYLOAD
//                          |  |________HEADER
//                          |________Max. Number of Packets in TX Buffer

//* Program the PCIe Block Transmitter
//  -----------------------------------
// Space for:
// Posted = 2048 B (4 MPS TLPs)
// Non-Posted = 192 B (~12 NP TLPs??)
// Completion = 2048 B (4 MPS TLPs)

localparam VC0_TXFIFO_P = 2048;
localparam VC0_TXFIFO_NP = 192;
localparam VC0_TXFIFO_CPL = 2048;


 pcie_top_wrapper #
 (
   .COMPONENTTYPE(DEV_PORT_TYPE),
   .NO_OF_LANES(MAX_LNK_WDT),
   .G_SIM(G_SIM),
   .REF_CLK_FREQ(REF_CLK_FREQ),
   .USE_V5FXT(USE_V5FXT),

   .CLKRATIO(INTF_CLK_RATIO),
   .CLKDIVIDED(`INTF_CLK_DIVIDED),
   .G_USER_RESETS(G_USER_RESETS),

   .VENDORID(VEN_ID),
   .DEVICEID(DEV_ID),
   .REVISIONID(REV_ID),
   .SUBSYSTEMVENDORID(SUBSYS_VEN_ID),
   .SUBSYSTEMID(SUBSYS_ID),
   .CLASSCODE(CLASS_CODE),
   .CARDBUSCISPOINTER(CARDBUS_CIS_PTR),
   .INTERRUPTPIN(1),
   .BAR0EXIST(`BAR0_EXIST),
   .BAR0IOMEMN(BAR0_IO_OR_MEM),
   .BAR064(BAR0_32_OR_64),
   .BAR0PREFETCHABLE(`BAR0_PREFETCHABLE),
   .BAR0MASKWIDTH(BAR0_MASKWIDTH),
   .BAR1EXIST(`BAR1_EXIST),
   .BAR1IOMEMN(BAR1_IO_OR_MEM),
   .BAR1PREFETCHABLE(`BAR1_PREFETCHABLE),
   .BAR1MASKWIDTH(BAR1_MASKWIDTH),
   .BAR2EXIST(`BAR2_EXIST),
   .BAR2IOMEMN(BAR2_IO_OR_MEM),
   .BAR264(BAR2_32_OR_64),
   .BAR2PREFETCHABLE(`BAR2_PREFETCHABLE),
   .BAR2MASKWIDTH(BAR2_MASKWIDTH),
   .BAR3EXIST(`BAR3_EXIST),
   .BAR3IOMEMN(BAR3_IO_OR_MEM),
   .BAR3PREFETCHABLE(`BAR3_PREFETCHABLE),
   .BAR3MASKWIDTH(BAR3_MASKWIDTH),
   .BAR4EXIST(`BAR4_EXIST),
   .BAR4IOMEMN(BAR4_IO_OR_MEM),
   .BAR464(BAR4_32_OR_64),
   .BAR4PREFETCHABLE(`BAR4_PREFETCHABLE),
   .BAR4MASKWIDTH(BAR4_MASKWIDTH),
   .BAR5EXIST(`BAR5_EXIST),
   .BAR5IOMEMN(BAR5_IO_OR_MEM),
   .BAR5PREFETCHABLE(`BAR5_PREFETCHABLE),
   .BAR5MASKWIDTH(BAR5_MASKWIDTH),
   .MAXPAYLOADSIZE(MPS),
   .DEVICECAPABILITYENDPOINTL0SLATENCY(EP_L0s_ACCPT_LAT),
   .DEVICECAPABILITYENDPOINTL1LATENCY(EP_L1_ACCPT_LAT),
   .LINKCAPABILITYASPMSUPPORTEN(ASPM_SUP[1]),
   .L0SEXITLATENCY(L0s_EXIT_LAT),
   .L0SEXITLATENCYCOMCLK(L0s_EXIT_LAT),
   .L1EXITLATENCY(L1_EXIT_LAT),
   .L1EXITLATENCYCOMCLK(L1_EXIT_LAT),
   .MSIENABLE(FEATURE_ENABLE),
   .DSNENABLE(FEATURE_ENABLE),
   .VCENABLE(FEATURE_DISABLE),
   .MSICAPABILITYMULTIMSGCAP(MSI_VECTOR),
   .PMCAPABILITYDSI(`DSI_x),
   .PMCAPABILITYPMESUPPORT(PME_SUP),
   .PORTVCCAPABILITYEXTENDEDVCCOUNT(FEATURE_DISABLE),
   .PORTVCCAPABILITYVCARBCAP(FEATURE_DISABLE),
   .LOWPRIORITYVCCOUNT(FEATURE_DISABLE),
   .DEVICESERIALNUMBER(64'h0000_0000_0000_0000),
   .FORCENOSCRAMBLING(FRCE_NOSCRMBL),
   .INFINITECOMPLETIONS(INFINITECOMPLETIONS),
   .VC0_CREDITS_PH(VC0_CREDITS_PH),
   .VC0_CREDITS_NPH(VC0_CREDITS_NPH),
   .LINKSTATUSSLOTCLOCKCONFIG(SLOT_CLOCK_CONFIG),
   .TXTSNFTS(TX_NFTS),
   .TXTSNFTSCOMCLK(TX_NFTS),
   .RESETMODE("TRUE"),
   .RETRYRAMSIZE(RETRY_RAM),
   .VC0RXFIFOSIZEP(VC0_RXFIFO_P),
   .VC0RXFIFOSIZENP(VC0_RXFIFO_NP),
   .VC0RXFIFOSIZEC(VC0_RXFIFO_CPL),
   .VC1RXFIFOSIZEP(FEATURE_DISABLE),
   .VC1RXFIFOSIZENP(FEATURE_DISABLE),
   .VC1RXFIFOSIZEC(FEATURE_DISABLE),
   .VC0TXFIFOSIZEP(VC0_TXFIFO_P),
   .VC0TXFIFOSIZENP(VC0_TXFIFO_NP),
   .VC0TXFIFOSIZEC(VC0_TXFIFO_CPL),
   .VC1TXFIFOSIZEP(FEATURE_DISABLE),
   .VC1TXFIFOSIZENP(FEATURE_DISABLE),
   .VC1TXFIFOSIZEC(FEATURE_DISABLE),
   .TXDIFFBOOST(TXDIFFBOOST),
   .GTDEBUGPORTS(GTDEBUGPORTS)

 )
 pcie_blk

 (

      .user_reset_n (fe_fundamental_reset_n),

      .core_clk (core_clk),
      .user_clk (user_clk),
      .clock_lock (clock_lock),

      .gsr (GSR),

      .crm_urst_n (fe_fundamental_reset_n),
      .crm_nvrst_n (fe_fundamental_reset_n),
      .crm_mgmt_rst_n (fe_fundamental_reset_n),
      .crm_user_cfg_rst_n (fe_fundamental_reset_n),
      .crm_mac_rst_n (fe_fundamental_reset_n),
      .crm_link_rst_n (fe_fundamental_reset_n),

      .compliance_avoid (fe_compliance_avoid),
      .l0_cfg_loopback_master (fe_l0_cfg_loopback_master),
      .l0_transactions_pending (fe_l0_transactions_pending),


      .l0_set_completer_abort_error (fe_l0_set_completer_abort_error),
      .l0_set_detected_corr_error (fe_l0_set_detected_corr_error),
      .l0_set_detected_fatal_error (fe_l0_set_detected_fatal_error),
      .l0_set_detected_nonfatal_error (fe_l0_set_detected_nonfatal_error),
      .l0_set_user_detected_parity_error (fe_l0_set_user_detected_parity_error),
      .l0_set_user_master_data_parity (fe_l0_set_user_master_data_parity),
      .l0_set_user_received_master_abort (fe_l0_set_user_received_master_abort),
      .l0_set_user_received_target_abort (fe_l0_set_user_received_target_abort),
      .l0_set_user_system_error (fe_l0_set_user_system_error),
      .l0_set_user_signalled_target_abort (fe_l0_set_user_signalled_target_abort),
      .l0_set_completion_timeout_uncorr_error (fe_l0_set_completion_timeout_uncorr_error),
      .l0_set_completion_timeout_corr_error (fe_l0_set_completion_timeout_corr_error),
      .l0_set_unexpected_completion_uncorr_error (fe_l0_set_unexpected_completion_uncorr_error),
      .l0_set_unexpected_completion_corr_error (fe_l0_set_unexpected_completion_corr_error),
      .l0_set_unsupported_request_nonposted_error (fe_l0_set_unsupported_request_nonposted_error),
      .l0_set_unsupported_request_other_error (fe_l0_set_unsupported_request_other_error),
      .l0_legacy_int_funct0 (fe_l0_legacy_int_funct0),
      .l0_msi_request0 (fe_l0_msi_request0),

      .mgmt_wdata (mgmt_wdata),
      .mgmt_bwren (mgmt_bwren),
      .mgmt_wren (mgmt_wren),
      .mgmt_addr (mgmt_addr),
      .mgmt_rden (mgmt_rden),

      .mgmt_stats_credit_sel (mgmt_stats_credit_sel),

      .crm_do_hot_reset_n (),
      .crm_pwr_soft_reset_n (),

      .mgmt_rdata (mgmt_rdata),
      .mgmt_pso (mgmt_pso),
      .mgmt_stats_credit (mgmt_stats_credit),

      .l0_first_cfg_write_occurred (fe_l0_first_cfg_write_occurred),
      .l0_cfg_loopback_ack (fe_l0_cfg_loopback_ack),
      .l0_rx_mac_link_error (fe_l0_rx_mac_link_error),
      .l0_mac_link_up (fe_l0_mac_link_up),
      .l0_mac_negotiated_link_width (fe_l0_mac_negotiated_link_width),
      .l0_mac_link_training (fe_l0_mac_link_training),
      .l0_ltssm_state (fe_l0_ltssm_state),

      .l0_mac_new_state_ack (fe_l0_mac_new_state_ack),
      .l0_mac_rx_l0s_state (fe_l0_mac_rx_l0s_state),
      .l0_mac_entered_l0 (fe_l0_mac_entered_l0),

      .l0_dl_up_down (fe_l0_dl_up_down),
      .l0_dll_error_vector (fe_l0_dll_error_vector),

      .l0_completer_id (fe_l0_completer_id),

      .l0_msi_enable0 (fe_l0_msi_enable0),
      .l0_multi_msg_en0 (fe_l0_multi_msg_en0),
      .l0_stats_dllp_received (fe_l0_stats_dllp_received),
      .l0_stats_dllp_transmitted (fe_l0_stats_dllp_transmitted),
      .l0_stats_os_received (fe_l0_stats_os_received),
      .l0_stats_os_transmitted (fe_l0_stats_os_transmitted),
      .l0_stats_tlp_received (fe_l0_stats_tlp_received),
      .l0_stats_tlp_transmitted (fe_l0_stats_tlp_transmitted),
      .l0_stats_cfg_received (fe_l0_stats_cfg_received),
      .l0_stats_cfg_transmitted (fe_l0_stats_cfg_transmitted),
      .l0_stats_cfg_other_received (fe_l0_stats_cfg_other_received),
      .l0_stats_cfg_other_transmitted (fe_l0_stats_cfg_other_transmitted),

      .l0_pwr_state0 (fe_l0_pwr_state0),
      .l0_pwr_l23_ready_state (fe_l0_pwr_l23_ready_state),
      .l0_pwr_tx_l0s_state (fe_l0_pwr_tx_l0s_state),
      .l0_pwr_turn_off_req (fe_l0_pwr_turn_off_req),
      .l0_pme_req_in       (fe_l0_pme_req_in),
      .l0_pme_ack          (fe_l0_pme_ack),


      .io_space_enable (fe_io_space_enable),
      .mem_space_enable (fe_mem_space_enable),
      .bus_master_enable (fe_bus_master_enable),
      .parity_error_response (fe_parity_error_response),
      .serr_enable (fe_serr_enable),
      .interrupt_disable (fe_interrupt_disable),
      .ur_reporting_enable (fe_ur_reporting_enable),

       //Local Link Interface ports

       // TX ports
      .llk_tx_data (llk_tx_data),
      .llk_tx_src_rdy_n (llk_tx_src_rdy_n),
      .llk_tx_sof_n (llk_tx_sof_n),
      .llk_tx_eof_n (llk_tx_eof_n),
      .llk_tx_sop_n (1'b1),
      .llk_tx_eop_n (1'b1),
      .llk_tx_enable_n (llk_tx_enable_n),
      .llk_tx_ch_tc (llk_tx_ch_tc),
      .llk_tx_ch_fifo (llk_tx_ch_fifo),
      .llk_tx_dst_rdy_n (llk_tx_dst_rdy_n),
      .llk_tx_chan_space (llk_tx_chan_space),
      .llk_tx_ch_posted_ready_n (llk_tx_ch_posted_ready_n),
      .llk_tx_ch_non_posted_ready_n (llk_tx_ch_non_posted_ready_n),
      .llk_tx_ch_completion_ready_n (llk_tx_ch_completion_ready_n),

       // (07/11) Added for compatibility
      .llk_tx_src_dsc_n(llk_tx_src_dsc_n),

       //RX Ports
      .llk_rx_dst_req_n (llk_rx_dst_req_n),
      .llk_rx_dst_cont_req_n (llk_rx_dst_cont_req_n),
      .llk_rx_ch_tc (llk_rx_ch_tc),
      .llk_rx_ch_fifo (llk_rx_ch_fifo),
      .llk_tc_status (llk_tc_status),
      .llk_rx_data (llk_rx_data),
      .llk_rx_src_rdy_n (llk_rx_src_rdy_n),
      .llk_rx_src_last_req_n (llk_rx_src_last_req_n),
      .llk_rx_sof_n (llk_rx_sof_n),
      .llk_rx_eof_n (llk_rx_eof_n),
      .llk_rx_sop_n (),
      .llk_rx_eop_n (),
      .llk_rx_valid_n (llk_rx_valid_n),
      .llk_rx_ch_posted_available_n (llk_rx_ch_posted_available_n),
      .llk_rx_ch_non_posted_available_n (llk_rx_ch_non_posted_available_n),
      .llk_rx_ch_completion_available_n (llk_rx_ch_completion_available_n),
      .llk_rx_preferred_type (llk_rx_preferred_type),


      .TXN  (pci_exp_txn),
      .TXP  (pci_exp_txp),
      .RXN  (pci_exp_rxn),
      .RXP  (pci_exp_rxp),
      .GTPCLK_bufg (GTPCLK_bufg),
      .REFCLKOUT_bufg (REFCLK_OUT_bufg),
      .PLLLKDET_OUT (PLLLKDET_OUT),
      .RESETDONE (RESETDONE),
      .DEBUG (DEBUG),
      .GTPRESET (GTPRESET),
      .REFCLK (sys_clk),

      .gt_rx_present (8'b11111111),

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
      .gt_txpreemphesis_1      (gt_txpreemphesis_1),
      .trn_lnk_up_n	(trn_lnk_up_n_reg),

      .max_payload_size  (fe_max_payload_size),
      .max_read_request_size  (fe_max_read_request_size),
`ifdef MANAGEMENT_WRITE
      .mgmt_reset_delay_n(mgmt_rst_delay_n),
      .mgmt_rdy(mgmt_rdy),
`endif
      .fast_train_simulation_only(fast_train_simulation_only)
);

assign mgt_reset_n = PLLLKDET_OUT[0] && clock_lock && fe_fundamental_reset_n;

always @(posedge trn_clk) begin
    mgt_reset_n_flt_reg  <= #1 mgt_reset_n;
    trn_lnk_up_n_flt_reg <= #1 trn_lnk_up_n;
    trn_lnk_up_n_reg     <= #1 trn_lnk_up_n_flt_reg;
    app_reset_n_flt_reg  <= #1 mgt_reset_n_flt_reg && ~trn_lnk_up_n_reg;
    app_reset_n          <= #1 app_reset_n_flt_reg;
end

`ifdef MANAGEMENT_WRITE
assign trn_reset_n = trn_rst_n && mgmt_rdy;

assign mgmt_addr = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? {bridge_mgmt_addr[9], 1'b0, bridge_mgmt_addr[8:0]} : {cfg_dwaddr[9], 1'b0, cfg_dwaddr[8:0]};
assign mgmt_rden = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? bridge_mgmt_rden : 1'b1;
assign mgmt_wren = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? bridge_mgmt_wren : (~&cfg_byte_en_n);
assign mgmt_wdata = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? bridge_mgmt_wdata : cfg_di[31:0];
assign mgmt_bwren = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? bridge_mgmt_bwren : (~cfg_byte_en_n);
assign mgmt_reset_delay_n = ((!trn_lnk_up_n) || (cfg_wr_en_n)) ? 1'b1 : cfg_wr_en_n;
`endif

//------------------------------------------------------------------------------
// PCIe Block Interface
//------------------------------------------------------------------------------

pcie_blk_if #
(      .BAR0( BAR0 ),
       .BAR1( BAR1 ),
       .BAR2( BAR2 ),
       .BAR3( BAR3 ),
       .BAR4( BAR4 ),
       .BAR5( BAR5 ),
       .XROM_BAR( XROM_BAR ),
       .MPS( MPS ),
       .LEGACY_EP( DEV_PORT_TYPE == 4'b0001 ),
       .TRIM_ECRC( TRM_TLP_DGST_ECRC ),
       .CPL_STREAMING_PRIORITIZE_P_NP(CPL_STREAMING_PRIORITIZE_P_NP),
       .C_CALENDAR_LEN            (C_CALENDAR_LEN),
       .C_CALENDAR_SEQ            (C_CALENDAR_SEQ),
       .C_CALENDAR_SUB_LEN        (C_CALENDAR_SUB_LEN),
       .C_CALENDAR_SUB_SEQ        (C_CALENDAR_SUB_SEQ),
       .TX_DATACREDIT_FIX_EN      (TX_DATACREDIT_FIX_EN),
       .TX_DATACREDIT_FIX_1DWONLY (TX_DATACREDIT_FIX_1DWONLY),
       .TX_DATACREDIT_FIX_MARGIN  (TX_DATACREDIT_FIX_MARGIN),
       .TX_CPL_STALL_THRESHOLD    (TX_CPL_STALL_THRESHOLD)

) pcie_blk_if (

     .mgt_reset_n (mgt_reset_n_flt_reg),

     .clk(user_clk),
     .rst_n(app_reset_n),

     // PCIe Block Misc Inputs

     .mac_link_up (fe_l0_mac_link_up),
     .mac_negotiated_link_width (fe_l0_mac_negotiated_link_width),

     // PCIe Block Cfg Interface
     //-------------------------

     // Inputs

     .io_space_enable (fe_io_space_enable),
     .mem_space_enable (fe_mem_space_enable),
     .bus_master_enable (fe_bus_master_enable),
     .parity_error_response (fe_parity_error_response),
     .serr_enable (fe_serr_enable),
     .completer_id (fe_l0_completer_id),
     .max_read_request_size ( fe_max_read_request_size ),
     .max_payload_size ( fe_max_payload_size ),
     .msi_enable (fe_l0_msi_enable0),

     // Outputs

     .legacy_int_request (fe_l0_legacy_int_funct0),
     .transactions_pending (fe_l0_transactions_pending),

     .msi_request (fe_l0_msi_request0),

     .cfg_interrupt_assert_n(cfg_interrupt_assert_n), // I
     .cfg_interrupt_di(cfg_interrupt_di),             // I[7:0]
     .cfg_interrupt_mmenable(cfg_interrupt_mmenable),
     .cfg_interrupt_msienable(cfg_interrupt_msienable),   // O
     .cfg_interrupt_do(cfg_interrupt_do),             // O[7:0]
     .msi_8bit_en(MSI_8BIT_EN),                       // I

     // PCIe Block Management Interface

`ifdef MANAGEMENT_WRITE
     .mgmt_addr           ( bridge_mgmt_addr ),
     .mgmt_wren           ( bridge_mgmt_wren ),
     .mgmt_rden           ( bridge_mgmt_rden ),
     .mgmt_wdata          ( bridge_mgmt_wdata ),
     .mgmt_bwren          ( bridge_mgmt_bwren ),
`else
     .mgmt_addr           ( mgmt_addr ),
     .mgmt_wren           ( mgmt_wren ),
     .mgmt_rden           ( mgmt_rden ),
     .mgmt_wdata          ( mgmt_wdata ),
     .mgmt_bwren          ( mgmt_bwren ),
`endif
     .mgmt_rdata          ( mgmt_rdata ),
     .mgmt_pso            ( mgmt_pso ),
     .mgmt_stats_credit_sel (mgmt_stats_credit_sel),
     .mgmt_stats_credit   (mgmt_stats_credit),

     // PCIe Soft Macro Cfg Interface
     //------------------------------

     .cfg_do (cfg_do),
     .cfg_di (cfg_di),
     .cfg_dsn (cfg_dsn),
     .cfg_byte_en_n (cfg_byte_en_n),
     .cfg_dwaddr ({2'b00, cfg_dwaddr}),
     .cfg_rd_wr_done_n (cfg_rd_wr_done_n),
     .cfg_wr_en_n (cfg_wr_en_n),
     .cfg_rd_en_n (cfg_rd_en_n),
     .cfg_err_cor_n (cfg_err_cor_n),
     .cfg_err_ur_n (cfg_err_ur_n),
     .cfg_err_ecrc_n (cfg_err_ecrc_n),
     .cfg_err_cpl_timeout_n (cfg_err_cpl_timeout_n),
     .cfg_err_cpl_abort_n (cfg_err_cpl_abort_n),
     .cfg_err_cpl_unexpect_n (cfg_err_cpl_unexpect_n),
     .cfg_err_posted_n (cfg_err_posted_n),
     .cfg_err_locked_n (cfg_err_locked_n),
     .cfg_interrupt_n (cfg_interrupt_n),
     .cfg_interrupt_rdy_n (cfg_interrupt_rdy_n),
     .cfg_turnoff_ok_n (cfg_turnoff_ok_n),
     .cfg_to_turnoff_n (cfg_to_turnoff_n),
     .cfg_pm_wake_n (cfg_pm_wake_n),
     .cfg_err_tlp_cpl_header (cfg_err_tlp_cpl_header),
     .cfg_err_cpl_rdy_n (cfg_err_cpl_rdy_n),
     .cfg_trn_pending_n (cfg_trn_pending_n),
     .cfg_status (cfg_status),
     .cfg_command (cfg_command),
     .cfg_dstatus (cfg_dstatus),
     .cfg_dcommand (cfg_dcommand),
     .cfg_lstatus (cfg_lstatus),
     .cfg_lcommand (cfg_lcommand),
     .cfg_bus_number (cfg_bus_number),
     .cfg_device_number (cfg_device_number),
     .cfg_function_number (cfg_function_number),
     .cfg_pcie_link_state_n (cfg_pcie_link_state_n),

     // PCIe Block Tx Ports
     //--------------------

     .llk_tx_data (llk_tx_data),
     .llk_tx_src_rdy_n (llk_tx_src_rdy_n),
     .llk_tx_src_dsc_n (llk_tx_src_dsc_n),
     .llk_tx_sof_n (llk_tx_sof_n),
     .llk_tx_eof_n (llk_tx_eof_n),
     .llk_tx_sop_n (llk_tx_sop_n),                // O: Unused
     .llk_tx_eop_n (llk_tx_eop_n),                // O: Unused
     .llk_tx_enable_n (llk_tx_enable_n),
     .llk_tx_ch_tc (llk_tx_ch_tc),
     .llk_tx_ch_fifo (llk_tx_ch_fifo),

     .llk_tx_dst_rdy_n (llk_tx_dst_rdy_n),
     .llk_tx_chan_space (llk_tx_chan_space),
     .llk_tx_ch_posted_ready_n (llk_tx_ch_posted_ready_n),
     .llk_tx_ch_non_posted_ready_n (llk_tx_ch_non_posted_ready_n),
     .llk_tx_ch_completion_ready_n (llk_tx_ch_completion_ready_n),

     // PCIe Block Rx Ports
     //--------------------

     .llk_rx_dst_req_n (llk_rx_dst_req_n),
     .llk_rx_dst_cont_req_n(llk_rx_dst_cont_req_n),                  // O : Unused
     .llk_rx_ch_tc (llk_rx_ch_tc),
     .llk_rx_ch_fifo (llk_rx_ch_fifo),

     .llk_tc_status (llk_tc_status),
     .llk_rx_data (llk_rx_data),
     .llk_rx_src_rdy_n (llk_rx_src_rdy_n),
     .llk_rx_src_last_req_n (llk_rx_src_last_req_n),
     .llk_rx_src_dsc_n (llk_rx_src_dsc_n),
     .llk_rx_sof_n (llk_rx_sof_n),
     .llk_rx_eof_n (llk_rx_eof_n),
     .llk_rx_valid_n (llk_rx_valid_n),
     .llk_rx_ch_posted_available_n (llk_rx_ch_posted_available_n),
     .llk_rx_ch_non_posted_available_n (llk_rx_ch_non_posted_available_n),
     .llk_rx_ch_completion_available_n (llk_rx_ch_completion_available_n),
      .llk_rx_preferred_type (llk_rx_preferred_type),

     // PCIe Block Status
     //-----------------

     .l0_dll_error_vector               ( fe_l0_dll_error_vector_ext ),
     .l0_rx_mac_link_error              ( fe_l0_rx_mac_link_error_ext ),
     .l0_set_unsupported_request_other_error( fe_l0_set_unsupported_request_other_error ),
     .l0_set_detected_fatal_error       ( fe_l0_set_detected_fatal_error ),
     .l0_set_detected_nonfatal_error    ( fe_l0_set_detected_nonfatal_error ),
     .l0_set_detected_corr_error        ( fe_l0_set_detected_corr_error ),
     .l0_set_user_system_error          ( fe_l0_set_user_system_error ),
     .l0_set_user_master_data_parity    ( fe_l0_set_user_master_data_parity ),
     .l0_set_user_signaled_target_abort ( fe_l0_set_user_signalled_target_abort ),
     .l0_set_user_received_target_abort ( fe_l0_set_user_received_target_abort ),
     .l0_set_user_received_master_abort ( fe_l0_set_user_received_master_abort ),
     .l0_set_user_detected_parity_error ( fe_l0_set_user_detected_parity_error ),
     .l0_ltssm_state                    ( fe_l0_ltssm_state ),
     .l0_stats_tlp_received             ( fe_l0_stats_tlp_received ),
     .l0_stats_cfg_received             ( fe_l0_stats_cfg_received ),
     .l0_stats_cfg_transmitted          ( fe_l0_stats_cfg_transmitted ),

     .l0_pwr_turn_off_req               ( fe_l0_pwr_turn_off_req ),
     .l0_pme_req_in                     ( fe_l0_pme_req_in ),
     .l0_pme_ack                        ( fe_l0_pme_ack ),

     // LocalLink Common
     //-----------------

     .trn_clk (trn_clk),
`ifdef MANAGEMENT_WRITE
     .trn_reset_n (trn_rst_n),
`else
     .trn_reset_n (trn_reset_n),
`endif
     .trn_lnk_up_n (trn_lnk_up_n),

     // LocalLink Tx Ports
     //-------------------

     .trn_td (trn_td),
     .trn_trem_n (trn_trem_n),
     .trn_tsof_n (trn_tsof_n),
     .trn_teof_n (trn_teof_n),
     .trn_tsrc_rdy_n (trn_tsrc_rdy_n),
     .trn_tsrc_dsc_n (trn_tsrc_dsc_n),
     .trn_terrfwd_n (trn_terrfwd_n),

     .trn_tdst_rdy_n (trn_tdst_rdy_n),
     .trn_tdst_dsc_n (trn_tdst_dsc_n),
     .trn_tbuf_av (trn_tbuf_av),

 `ifdef PFC_CISCO_DEBUG
  .trn_pfc_nph_cl (trn_pfc_nph_cl),
  .trn_pfc_npd_cl (trn_pfc_npd_cl),
  .trn_pfc_ph_cl (trn_pfc_ph_cl),
  .trn_pfc_pd_cl (trn_pfc_pd_cl),
  .trn_pfc_cplh_cl (trn_pfc_cplh_cl),
  .trn_pfc_cpld_cl (trn_pfc_cpld_cl),
 `endif

     // LocalLink Rx Ports
     //-------------------

     .trn_rd (trn_rd),
     .trn_rrem_n (trn_rrem_n),
     .trn_rsof_n (trn_rsof_n),
     .trn_reof_n (trn_reof_n),
     .trn_rsrc_rdy_n (trn_rsrc_rdy_n),
     .trn_rsrc_dsc_n (trn_rsrc_dsc_n),
     .trn_rerrfwd_n (trn_rerrfwd_n),
     .trn_rbar_hit_n (trn_rbar_hit_n),
     .trn_rfc_nph_av (trn_rfc_nph_av),
     .trn_rfc_npd_av (trn_rfc_npd_av),
     .trn_rfc_ph_av (trn_rfc_ph_av),
     .trn_rfc_pd_av (trn_rfc_pd_av),
     .trn_rfc_cplh_av (trn_rfc_cplh_av),
     .trn_rfc_cpld_av (trn_rfc_cpld_av),
     .trn_rcpl_streaming_n (trn_rcpl_streaming_n),

     .trn_rnp_ok_n (trn_rnp_ok_n),
     .trn_rdst_rdy_n (trn_rdst_rdy_n) );





// RATIO = 1 if USERCLK = 250 MHz; RATIO = 2 if USERCLK = 125 MHz; RATIO = 4 if USERCLK = 62.5 MHz


extend_clk # (
   .CLKRATIO(INTF_CLK_RATIO)
) 
extend_clk
(
   .clk(core_clk),
   .rst_n(fe_fundamental_reset_n),
   .l0_dll_error_vector(fe_l0_dll_error_vector),             // [6:0] I
   .l0_rx_mac_link_error(fe_l0_rx_mac_link_error),           // [1:0] I

   .l0_dll_error_vector_retime(fe_l0_dll_error_vector_ext),  // [6:0] O
   .l0_rx_mac_link_error_retime(fe_l0_rx_mac_link_error_ext) // [1:0] O
);






endmodule // ep_init_if


