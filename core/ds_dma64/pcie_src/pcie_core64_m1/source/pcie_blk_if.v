
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
// File       : pcie_blk_if.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Block Interface
//--
//--             
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module pcie_blk_if #
(
   parameter   BAR0 = 32'hffff_0001,               // base address             cfg[ 95: 64]
   parameter   BAR1 = 32'hffff_0000,               // base address             cfg[127: 96]
   parameter   BAR2 = 32'hffff_0004,               // base address             cfg[159:128]
   parameter   BAR3 = 32'hffff_ffff,               // base address             cfg[191:160]
   parameter   BAR4 = 32'h0000_0000,               // base address             cfg[223:192]
   parameter   BAR5 = 32'h0000_0000,               // base address             cfg[255:224]
   parameter   XROM_BAR = 32'hffff_f001,           // expansion rom bar        cfg[351:320]
   parameter   MPS = 3'b101,                       // Max Payload Size         cfg[370:368]
   parameter   LEGACY_EP = 1'b0,                   // Legacy PCI endpoint?
   parameter   TRIM_ECRC = 1'b0,                   // Trim ECRC from rx TLPs   cfg[508]
   parameter   CPL_STREAMING_PRIORITIZE_P_NP = 0,  // arb priority to P/NP during cpl strm
   parameter   C_CALENDAR_LEN     = 9,
   parameter   C_CALENDAR_SUB_LEN = 12,
   parameter   C_CALENDAR_SEQ     = 72'h68_08_68_2C_68_08_68_0C_FF, //S Tc S T1 S Tc S T2 F
   parameter   C_CALENDAR_SUB_SEQ = 96'h40_60_44_64_4C_6C_20_24_28_2C_30_34,
   parameter   TX_CPL_STALL_THRESHOLD   = 6,
   parameter   TX_DATACREDIT_FIX_EN     = 1,
   parameter   TX_DATACREDIT_FIX_1DWONLY= 1,
   parameter   TX_DATACREDIT_FIX_MARGIN = 6
)
(
       // MGT Reset
       input wire        mgt_reset_n,
 
       // PCIe Block clock and reset

       input wire         clk,
       input wire         rst_n,

       // PCIe Block Misc Inputs

       input wire         mac_link_up,
       input wire   [3:0] mac_negotiated_link_width,
 
       // PCIe Block Cfg Interface

       input wire         io_space_enable,
       input wire         mem_space_enable,
       input wire         bus_master_enable,
       input wire         parity_error_response,
       input wire         serr_enable,
       input wire         msi_enable,
       input wire  [12:0] completer_id,
       input wire   [2:0] max_read_request_size,
       input wire   [2:0] max_payload_size,
    
       output             legacy_int_request,
       output             transactions_pending,

       output       [3:0] msi_request,
       input              cfg_interrupt_assert_n,
       input        [7:0] cfg_interrupt_di,
       output       [2:0] cfg_interrupt_mmenable,
       output             cfg_interrupt_msienable,
       output       [7:0] cfg_interrupt_do,
       input              msi_8bit_en,

       // PCIe Block Management Interface

       output wire [10:0] mgmt_addr,
       output wire        mgmt_wren,
       output wire        mgmt_rden,
       output wire [31:0] mgmt_wdata,
       output wire [3:0]  mgmt_bwren,
       input  wire [31:0] mgmt_rdata,
       input  wire [16:0] mgmt_pso,

       // PCIe Soft Macro Cfg Interface
       
       output      [31:0] cfg_do,
       input wire  [31:0] cfg_di,
       input wire  [63:0] cfg_dsn,
       input wire   [3:0] cfg_byte_en_n,
       input wire  [11:0] cfg_dwaddr,
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
       input wire         cfg_turnoff_ok_n,
       output             cfg_to_turnoff_n,
       input wire         cfg_pm_wake_n,
       input wire  [47:0] cfg_err_tlp_cpl_header,
       output wire        cfg_err_cpl_rdy_n,
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

       // PCIe Block Tx Ports

       output      [63:0] llk_tx_data,
       output             llk_tx_src_rdy_n,
       output             llk_tx_src_dsc_n,
       output             llk_tx_sof_n,
       output             llk_tx_eof_n,
       output             llk_tx_sop_n,
       output             llk_tx_eop_n,
       output      [1:0]  llk_tx_enable_n,
       output      [2:0]  llk_tx_ch_tc,
       output      [1:0]  llk_tx_ch_fifo,

       input  wire        llk_tx_dst_rdy_n,
       input  wire [9:0]  llk_tx_chan_space,
       input  wire [7:0]  llk_tx_ch_posted_ready_n,
       input  wire [7:0]  llk_tx_ch_non_posted_ready_n,
       input  wire [7:0]  llk_tx_ch_completion_ready_n,

       // PCIe Block Rx Ports

       output             llk_rx_dst_req_n,
       output             llk_rx_dst_cont_req_n,
       output [2:0]       llk_rx_ch_tc,
       output [1:0]       llk_rx_ch_fifo,

       input  wire [7:0]  llk_tc_status,
       input  wire [63:0] llk_rx_data,
       input  wire        llk_rx_src_rdy_n,
       input  wire        llk_rx_src_last_req_n,
       input  wire        llk_rx_src_dsc_n,
       input  wire        llk_rx_sof_n,
       input  wire        llk_rx_eof_n,
       input  wire [1:0]  llk_rx_valid_n,
       input  wire [7:0]  llk_rx_ch_posted_available_n,
       input  wire [7:0]  llk_rx_ch_non_posted_available_n,
       input  wire [7:0]  llk_rx_ch_completion_available_n,
       input  wire [15:0] llk_rx_preferred_type,
       output wire [6:0]  mgmt_stats_credit_sel,
       input  wire [11:0] mgmt_stats_credit,

       // LocalLink Common

       output             trn_clk,
       output             trn_reset_n,
       output             trn_lnk_up_n,

       // LocalLink Tx Ports
           
       input  wire [63:0] trn_td,
       input  wire [7:0]  trn_trem_n,
       input  wire        trn_tsof_n,
       input  wire        trn_teof_n,
       input  wire        trn_tsrc_rdy_n,
       input  wire        trn_tsrc_dsc_n,
       input  wire        trn_terrfwd_n,

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

       // LocalLink Rx Ports

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
       input  wire        trn_rcpl_streaming_n,

       input  wire        trn_rnp_ok_n,
       input  wire        trn_rdst_rdy_n,

       input  wire  [6:0] l0_dll_error_vector,
       input  wire  [1:0] l0_rx_mac_link_error,
       output wire        l0_set_unsupported_request_other_error,
       output wire        l0_set_detected_fatal_error,
       output wire        l0_set_detected_nonfatal_error,
       output wire        l0_set_detected_corr_error,
       output wire        l0_set_user_system_error,
       output wire        l0_set_user_master_data_parity,
       output wire        l0_set_user_signaled_target_abort,
       output wire        l0_set_user_received_target_abort,
       output wire        l0_set_user_received_master_abort,
       output wire        l0_set_user_detected_parity_error,
       input  wire        l0_stats_tlp_received,
       input  wire        l0_stats_cfg_received,
       input  wire        l0_stats_cfg_transmitted,
       input  wire  [3:0] l0_ltssm_state,
       input  wire        l0_pwr_turn_off_req,
       output wire        l0_pme_req_in,
       input  wire        l0_pme_ack

); // synthesis syn_hier = "hard"


wire [31:0] cfg_rx_bar0;
wire [31:0] cfg_rx_bar1;
wire [31:0] cfg_rx_bar2;
wire [31:0] cfg_rx_bar3;
wire [31:0] cfg_rx_bar4;
wire [31:0] cfg_rx_bar5;
wire [31:0] cfg_rx_xrom;

wire [63:0] cfg_arb_td;
wire  [7:0] cfg_arb_trem_n;
wire        cfg_arb_tsof_n;
wire        cfg_arb_teof_n;
wire        cfg_arb_tsrc_rdy_n;
wire        cfg_arb_tdst_rdy_n;
wire        rx_err_cpl_abort_n;
wire        rx_err_cpl_ep_n;
wire        tx_err_wr_ep_n;
wire        rx_err_ep_n;
wire        rx_err_tlp_poisoned_n = 1;
wire        rx_err_cpl_ur_n;
wire        rx_err_tlp_ur;
wire        rx_err_tlp_ur_lock;
wire [47:0] rx_err_tlp_hdr;
wire [31:0] cfg_pmcsr;
wire [31:0] cfg_dcap;
wire [63:0] llk_rx_data_d;

wire        rx_err_tlp_ur_n      = ~rx_err_tlp_ur;
wire        rx_err_tlp_ur_lock_n = ~rx_err_tlp_ur_lock;
wire        rx_err_tlp_p_cpl;
wire        rx_err_tlp_p_cpl_n = ~rx_err_tlp_p_cpl;

wire        err_tlp_malformed;
wire        rx_err_tlp_malformed_n  = ~err_tlp_malformed;

pcie_blk_ll #
(      .BAR0      (BAR0),
       .BAR1      (BAR1),
       .BAR2      (BAR2),
       .BAR3      (BAR3),
       .BAR4      (BAR4),
       .BAR5      (BAR5),
       .XROM_BAR  (XROM_BAR),
       .MPS       (MPS),
       .LEGACY_EP (LEGACY_EP),
       .TRIM_ECRC (TRIM_ECRC),
       .C_CALENDAR_LEN         (C_CALENDAR_LEN),
       .C_CALENDAR_SEQ         (C_CALENDAR_SEQ),
       .C_CALENDAR_SUB_LEN     (C_CALENDAR_SUB_LEN),
       .C_CALENDAR_SUB_SEQ     (C_CALENDAR_SUB_SEQ),
       .TX_CPL_STALL_THRESHOLD       (TX_CPL_STALL_THRESHOLD),
       .TX_DATACREDIT_FIX_EN         (TX_DATACREDIT_FIX_EN),
       .TX_DATACREDIT_FIX_1DWONLY    (TX_DATACREDIT_FIX_1DWONLY),
       .TX_DATACREDIT_FIX_MARGIN     (TX_DATACREDIT_FIX_MARGIN),
       .CPL_STREAMING_PRIORITIZE_P_NP(CPL_STREAMING_PRIORITIZE_P_NP)
)
ll_bridge 
(
       // Clock & Reset

       .clk( clk ),                                               // I
       .rst_n( rst_n ),                                           // I

       // Transaction Link Up

       .trn_lnk_up_n( trn_lnk_up_n ),                             // I

       // PCIe Block Tx Ports

       .llk_tx_data( llk_tx_data ),                               // O[63:0] 
       .llk_tx_src_rdy_n( llk_tx_src_rdy_n ),                     // O
       .llk_tx_src_dsc_n( llk_tx_src_dsc_n ),                     // O
       .llk_tx_sof_n( llk_tx_sof_n ),                             // O
       .llk_tx_eof_n( llk_tx_eof_n ),                             // O
       .llk_tx_sop_n( llk_tx_sop_n ),                             // O
       .llk_tx_eop_n( llk_tx_eop_n ),                             // O
       .llk_tx_enable_n( llk_tx_enable_n ),                       // O[1:0]
       .llk_tx_ch_tc( llk_tx_ch_tc ),                             // O[2:0]
       .llk_tx_ch_fifo( llk_tx_ch_fifo ),                         // O[1:0]

       .llk_tx_dst_rdy_n( llk_tx_dst_rdy_n ),                     // I
       .llk_tx_chan_space( llk_tx_chan_space ),                   // I[9:0]
       .llk_tx_ch_posted_ready_n( llk_tx_ch_posted_ready_n ),     // I[7:0]
       .llk_tx_ch_non_posted_ready_n( llk_tx_ch_non_posted_ready_n ), // I[7:0]
       .llk_tx_ch_completion_ready_n( llk_tx_ch_completion_ready_n ), // I[7:0]

       // LocalLink Tx Ports (User input)

       .trn_td( trn_td ),                                         // I[63:0]
       .trn_trem_n( trn_trem_n ),                                 // I[7:0]
       .trn_tsof_n( trn_tsof_n ),                                 // I
       .trn_teof_n( trn_teof_n ),                                 // I
       .trn_tsrc_rdy_n( trn_tsrc_rdy_n ),                         // I
       .trn_tsrc_dsc_n( trn_tsrc_dsc_n ),                         // I
       .trn_terrfwd_n( trn_terrfwd_n ),                           // I

       .trn_tdst_rdy_n( trn_tdst_rdy_n ),                         // O
       .trn_tdst_dsc_n( trn_tdst_dsc_n ),                         // O
       .trn_tbuf_av( trn_tbuf_av),                                // O[2:0]

       `ifdef PFC_CISCO_DEBUG
       .trn_pfc_nph_cl( trn_pfc_nph_cl),
       .trn_pfc_npd_cl( trn_pfc_npd_cl),
       .trn_pfc_ph_cl( trn_pfc_ph_cl),
       .trn_pfc_pd_cl( trn_pfc_pd_cl),
       .trn_pfc_cplh_cl( trn_pfc_cplh_cl),
       .trn_pfc_cpld_cl( trn_pfc_cpld_cl),
       `endif

       // Config Tx Ports

       .cfg_tx_td( cfg_arb_td ),                                  // I[63:0]
       .cfg_tx_rem_n( cfg_arb_trem_n[0] ),                        // I
       .cfg_tx_sof_n( cfg_arb_tsof_n ),                           // I
       .cfg_tx_eof_n( cfg_arb_teof_n ),                           // I
       .cfg_tx_src_rdy_n( cfg_arb_tsrc_rdy_n ),                   // I
       .cfg_tx_dst_rdy_n( cfg_arb_tdst_rdy_n ),                   // O

       // PCIe Block Rx Ports

       .llk_rx_dst_req_n( llk_rx_dst_req_n ),                     // O
       .llk_rx_dst_cont_req_n( llk_rx_dst_cont_req_n ),           // O
       .llk_rx_ch_tc( llk_rx_ch_tc ),                             // O[2:0]
       .llk_rx_ch_fifo( llk_rx_ch_fifo ),                         // O[1:0]

       .llk_tc_status( llk_tc_status ),                           // I[7:0]
       .llk_rx_data  ( llk_rx_data ),                             // I[63:0]
       .llk_rx_data_d( llk_rx_data_d ),                           // O[63:0]
       .llk_rx_src_rdy_n( llk_rx_src_rdy_n ),                     // I
       .llk_rx_src_last_req_n( llk_rx_src_last_req_n ),           // I
       .llk_rx_src_dsc_n( llk_rx_src_dsc_n ),                     // I
       .llk_rx_sof_n( llk_rx_sof_n ),                             // I
       .llk_rx_eof_n( llk_rx_eof_n ),                             // I
       .llk_rx_valid_n( llk_rx_valid_n ),                         // I[1:0]
.llk_rx_ch_posted_available_n( llk_rx_ch_posted_available_n ),         // I[7:0]
.llk_rx_ch_non_posted_available_n( llk_rx_ch_non_posted_available_n ), // I[7:0]
.llk_rx_ch_completion_available_n( llk_rx_ch_completion_available_n ), // I[7:0]
       .llk_rx_preferred_type( llk_rx_preferred_type ),           // I[15:0]
       .mgmt_stats_credit_sel (mgmt_stats_credit_sel),
       .mgmt_stats_credit     (mgmt_stats_credit),

       // LocalLink Rx Ports

       .trn_rd( trn_rd ),                                         // O[63:0]
       .trn_rrem_n( trn_rrem_n ),                                 // O[7:0]
       .trn_rsof_n( trn_rsof_n ),                                 // O
       .trn_reof_n( trn_reof_n ),                                 // O
       .trn_rsrc_rdy_n( trn_rsrc_rdy_n ),                         // O
       .trn_rsrc_dsc_n( trn_rsrc_dsc_n ),                         // O
       .trn_rerrfwd_n( trn_rerrfwd_n ),                           // O
       .trn_rbar_hit_n( trn_rbar_hit_n ),                         // O[6:0]
       .trn_rfc_nph_av( trn_rfc_nph_av ),                         // O[7:0]
       .trn_rfc_npd_av( trn_rfc_npd_av ),                         // O[11:0]
       .trn_rfc_ph_av( trn_rfc_ph_av ),                           // O[7:0]
       .trn_rfc_pd_av( trn_rfc_pd_av ),                           // O[11:0]
       .trn_rfc_cplh_av( trn_rfc_cplh_av ),                       // O[7:0]
       .trn_rfc_cpld_av( trn_rfc_cpld_av ),                       // O[11:0]

       .trn_rnp_ok_n( trn_rnp_ok_n ),                             // I
       .trn_rdst_rdy_n( trn_rdst_rdy_n ),                         // I
       .trn_rcpl_streaming_n( trn_rcpl_streaming_n ),             // I

       // Sideband signals to control operation
 
       .cfg_rx_bar0( cfg_rx_bar0 ),                               // I[31:0]
       .cfg_rx_bar1( cfg_rx_bar1 ),                               // I[31:0]
       .cfg_rx_bar2( cfg_rx_bar2 ),                               // I[31:0]
       .cfg_rx_bar3( cfg_rx_bar3 ),                               // I[31:0]
       .cfg_rx_bar4( cfg_rx_bar4 ),                               // I[31:0]
       .cfg_rx_bar5( cfg_rx_bar5 ),                               // I[31:0]
       .cfg_rx_xrom( cfg_rx_xrom ),                               // I[31:0]
       .cfg_bus_number( cfg_bus_number ),                         // I[7:0]
       .cfg_device_number( cfg_device_number ),                   // I[4:0]
       .cfg_function_number( cfg_function_number ),               // I[2:0]
       .cfg_dcommand( cfg_dcommand ),                             // I[15:0]
       .cfg_pmcsr( cfg_pmcsr[15:0] ),                             // I[15:0]
       //.io_space_enable( io_space_enable ),                       // I
       .io_space_enable( cfg_command[0] ),                        // I
       //.mem_space_enable( mem_space_enable ),                     // I
       .mem_space_enable( cfg_command[1] ),                       // I
       //.max_payload_size( max_payload_size ),                     // I[2:0]
       .max_payload_size( cfg_dcap[2:0] ),                        // I[2:0]

       // Error reporting
       .rx_err_cpl_abort_n( rx_err_cpl_abort_n ),                 // O
       .rx_err_cpl_ur_n( rx_err_cpl_ur_n ),                       // O
       .rx_err_cpl_ep_n( rx_err_cpl_ep_n ),                       // O
       .rx_err_ep_n    ( rx_err_ep_n ),                           // O
       .err_tlp_cpl_header( rx_err_tlp_hdr ),                     // O[47:0]
       .err_tlp_p  ( rx_err_tlp_p_cpl ),
       .err_tlp_ur ( rx_err_tlp_ur ),
       .err_tlp_ur_lock ( rx_err_tlp_ur_lock ),
       .err_tlp_uc ( ),
       .err_tlp_malformed( err_tlp_malformed ),                   // O
       .tx_err_wr_ep_n  (tx_err_wr_ep_n),                         // O

       .l0_stats_tlp_received (l0_stats_tlp_received),
       .l0_stats_cfg_transmitted (l0_stats_cfg_transmitted)
);

pcie_blk_cf cf_bridge  (

       // Clock & Reset

       .clk( clk ),                                               // I
       .rst_n( rst_n ),                                           // I

       // Transcation Link Up

       .trn_lnk_up_n( trn_lnk_up_n ),                             // 0

       // PCIe Block Misc Inputs

       .mac_link_up (mac_link_up),                                // I
       .mac_negotiated_link_width (mac_negotiated_link_width),    // I[3:0]
       .llk_tc_status( llk_tc_status ),                           // I[7:0]
 
       // PCIe Block Cfg Interface

       .io_space_enable (io_space_enable),
       .mem_space_enable (mem_space_enable),
       .bus_master_enable (bus_master_enable),
       .parity_error_response (parity_error_response),
       .serr_enable (serr_enable),
       .msi_enable (msi_enable),
       .completer_id (completer_id),
       .max_read_request_size (),                                // NEW
       .max_payload_size (),                                     // NEW

       .legacy_int_request(legacy_int_request),
       .transactions_pending(transactions_pending),
       .msi_request(msi_request),

       .cfg_interrupt_assert_n(cfg_interrupt_assert_n),  // I
       .cfg_interrupt_di(cfg_interrupt_di),              // I[7:0]
       .cfg_interrupt_mmenable(cfg_interrupt_mmenable),  // O[2:0]
       .cfg_interrupt_msienable(cfg_interrupt_msienable),  // O
       .cfg_interrupt_do(cfg_interrupt_do),              // O[7:0]
       .msi_8bit_en(msi_8bit_en),                        // I

       // PCIe Block Management Interface
       
       .mgmt_addr           (mgmt_addr),
       .mgmt_wren           (mgmt_wren),
       .mgmt_rden           (mgmt_rden),
       .mgmt_wdata          (mgmt_wdata),
       .mgmt_bwren          (mgmt_bwren),
       .mgmt_rdata          (mgmt_rdata),
       .mgmt_pso            (mgmt_pso),
       //// These signals go to mgmt block to implement a workaround
       .llk_rx_data_d            (llk_rx_data_d),
       .llk_rx_src_rdy_n         (llk_rx_src_rdy_n),
       .l0_stats_cfg_received    (l0_stats_cfg_received),
       .l0_stats_cfg_transmitted (l0_stats_cfg_transmitted),

       // PCIe Soft Macro Cfg Interface
       
       .cfg_do (cfg_do),
       .cfg_di (cfg_di),
       .cfg_dsn (cfg_dsn),
       .cfg_byte_en_n (cfg_byte_en_n),
       .cfg_dwaddr (cfg_dwaddr),
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
       .cfg_rx_bar0 (cfg_rx_bar0),
       .cfg_rx_bar1 (cfg_rx_bar1),
       .cfg_rx_bar2 (cfg_rx_bar2),
       .cfg_rx_bar3 (cfg_rx_bar3),
       .cfg_rx_bar4 (cfg_rx_bar4),
       .cfg_rx_bar5 (cfg_rx_bar5),
       .cfg_rx_xrom (cfg_rx_xrom),
       .cfg_status (cfg_status),
       .cfg_command (cfg_command),
       .cfg_dstatus (cfg_dstatus),
       .cfg_dcommand (cfg_dcommand),
       .cfg_lstatus (cfg_lstatus),
       .cfg_lcommand (cfg_lcommand),
       .cfg_pmcsr    (cfg_pmcsr),
       .cfg_dcap     (cfg_dcap),
       .cfg_bus_number (cfg_bus_number),
       .cfg_device_number (cfg_device_number),
       .cfg_function_number (cfg_function_number),
       .cfg_pcie_link_state_n (cfg_pcie_link_state_n),
       .cfg_arb_td             ( cfg_arb_td ),
       .cfg_arb_trem_n         ( cfg_arb_trem_n ),
       .cfg_arb_tsof_n         ( cfg_arb_tsof_n ),
       .cfg_arb_teof_n         ( cfg_arb_teof_n ),
       .cfg_arb_tsrc_rdy_n     ( cfg_arb_tsrc_rdy_n ),
       .cfg_arb_tdst_rdy_n     ( cfg_arb_tdst_rdy_n ),
       .rx_err_cpl_ep_n        ( rx_err_cpl_ep_n ), 
       .tx_err_wr_ep_n         ( tx_err_wr_ep_n ),
       .rx_err_ep_n            ( rx_err_ep_n ),
       .rx_err_tlp_poisoned_n  ( rx_err_tlp_poisoned_n ),
       .rx_err_cpl_abort_n     ( rx_err_cpl_abort_n ),
       .rx_err_cpl_ur_n        ( rx_err_cpl_ur_n ),
       .rx_err_tlp_ur_n        ( rx_err_tlp_ur_n ),
       .rx_err_tlp_ur_lock_n   ( rx_err_tlp_ur_lock_n ),
       .rx_err_tlp_p_cpl_n     ( rx_err_tlp_p_cpl_n ),
       .rx_err_tlp_malformed_n ( rx_err_tlp_malformed_n ),
       .rx_err_tlp_hdr         ( rx_err_tlp_hdr ),
       .l0_dll_error_vector               ( l0_dll_error_vector ),
       .l0_rx_mac_link_error              ( l0_rx_mac_link_error ),
       .l0_set_unsupported_request_other_error( l0_set_unsupported_request_other_error ),
       .l0_set_detected_fatal_error       ( l0_set_detected_fatal_error ),
       .l0_set_detected_nonfatal_error    ( l0_set_detected_nonfatal_error ),
       .l0_set_detected_corr_error        ( l0_set_detected_corr_error ),
       .l0_set_user_system_error          ( l0_set_user_system_error ),
       .l0_set_user_master_data_parity    ( l0_set_user_master_data_parity ),
       .l0_set_user_signaled_target_abort ( l0_set_user_signaled_target_abort ),
       .l0_set_user_received_target_abort ( l0_set_user_received_target_abort ),
       .l0_set_user_received_master_abort ( l0_set_user_received_master_abort ),
       .l0_set_user_detected_parity_error ( l0_set_user_detected_parity_error ),
       .l0_ltssm_state                    ( l0_ltssm_state ),
       .l0_pwr_turn_off_req               ( l0_pwr_turn_off_req ),
       .l0_pme_req_in                     ( l0_pme_req_in ),
       .l0_pme_ack                        ( l0_pme_ack )
);

assign trn_clk = clk;
assign trn_reset_n = mgt_reset_n;

endmodule // pcie_blk_if


