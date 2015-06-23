
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
// File       : pcie_blk_plus_ll_rx.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Block Plus Rx LocalLink Bridge
//--
//--             
//--
//------------------------------------------------------------------------------

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

`ifndef TCQ
  `define TCQ 1
`endif

module pcie_blk_plus_ll_rx #
(
   parameter   BAR0 = 32'hffff_0001,               // base address                                   cfg[ 95: 64]
   parameter   BAR1 = 32'hffff_0000,               // base address                                   cfg[127: 96]
   parameter   BAR2 = 32'hffff_0004,               // base address                                   cfg[159:128]
   parameter   BAR3 = 32'hffff_ffff,               // base address                                   cfg[191:160]
   parameter   BAR4 = 32'h0000_0000,               // base address                                   cfg[223:192]
   parameter   BAR5 = 32'h0000_0000,               // base address                                   cfg[255:224]
   parameter   XROM_BAR = 32'hffff_f001,           // expansion rom bar                              cfg[351:320]
   parameter   MPS = 3'b101,                       // Max Payload Size                               cfg[370:368]
   parameter   LEGACY_EP = 1'b0,                   // Legacy PCI endpoint?
   parameter   TRIM_ECRC = 1'b0,                   // Trim ECRC from rx TLPs                         cfg[508]
   parameter   CPL_STREAMING_PRIORITIZE_P_NP = 0   // arb priority to P/NP during cpl strm
)
(
  // Clock and reset

  input wire         clk,
  input wire         rst_n,

  // PCIe Block Rx Ports
  
  output wire        llk_rx_dst_req_n,
  output wire        llk_rx_dst_cont_req_n,
  output wire [2:0]  llk_rx_ch_tc,
  output wire [1:0]  llk_rx_ch_fifo,
  
  input  wire [7:0]  llk_tc_status,
  input  wire [63:0] llk_rx_data,
  output reg  [63:0] llk_rx_data_d = 64'hffffffff, //needed by mgmt module
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

  // LocalLink Rx Ports

  output      [63:0] trn_rd,
  output      [7:0]  trn_rrem_n,
  output             trn_rsof_n,
  output             trn_reof_n,
  output             trn_rsrc_rdy_n,
  output reg         trn_rsrc_dsc_n = 1'b1, // FIXME
  output             trn_rerrfwd_n,
  output      [6:0]  trn_rbar_hit_n,
  input  wire        trn_lnk_up_n,

  input  wire        trn_rnp_ok_n,
  input  wire        trn_rdst_rdy_n,
  input  wire        trn_rcpl_streaming_n,

  // Sideband signals to control operation
  input  wire [31:0] cfg_rx_bar0,
  input  wire [31:0] cfg_rx_bar1,
  input  wire [31:0] cfg_rx_bar2,
  input  wire [31:0] cfg_rx_bar3,
  input  wire [31:0] cfg_rx_bar4,
  input  wire [31:0] cfg_rx_bar5,
  input  wire [31:0] cfg_rx_xrom,
  input  wire [7:0]  cfg_bus_number,
  input  wire [4:0]  cfg_device_number,
  input  wire [2:0]  cfg_function_number,
  input  wire [15:0] cfg_dcommand,
  input  wire [15:0] cfg_pmcsr,
  input  wire        io_space_enable,
  input  wire        mem_space_enable,
  input  wire [2:0]  max_payload_size,

  // Error signaling logic
  output wire        rx_err_cpl_abort_n,
  output wire        rx_err_cpl_ur_n,
  output wire        rx_err_cpl_ep_n,
  output wire        rx_err_ep_n,
  output wire [47:0] err_tlp_cpl_header,
  output wire        err_tlp_p,
  output wire        err_tlp_ur,
  output wire        err_tlp_ur_lock,
  output wire        err_tlp_uc,
  output wire        err_tlp_malformed,
  input  wire        l0_stats_tlp_received,

  input  wire  [7:0] rx_ch_credits_received,
  input  wire        rx_ch_credits_received_inc
); 

  localparam MPS_DECODE = (MPS == 3'b101) ? 4096 :
                          (MPS == 3'b100) ? 2048 :
                          (MPS == 3'b011) ? 1024 :
                          (MPS == 3'b010) ?  512 :
                          (MPS == 3'b001) ?  256 :
                          (MPS == 3'b000) ?  128 :
                                             -1; // Dummy bad value

  // Data from data_snk to FIFO
  wire [63:0]     snk_d;
  wire            snk_sof;
  wire            snk_eof;
  wire            snk_preeof;
  wire            snk_src_rdy;
  wire            snk_rem;
  wire            snk_src_dsc;
  wire [6:0]      snk_bar;
  wire            snk_rid;
  wire            snk_bar_src_rdy;
  wire            snk_np;
  wire            snk_cpl;
  wire            snk_cfg;
  wire            snk_locked;
  wire            snk_vend_msg;

  // BAR checking between data_snk and cmm_decoder
  wire [63:0]     check_raddr;
  wire            check_mem32;
  wire            check_mem64;
  wire            check_rio;
  wire            check_rdev;
  wire            check_rbus;
  wire            check_rfun;
  wire            check_rhit;
  wire [6:0]      check_rhit_bar;
  wire            check_rhit_bar_lat3;

  // Interface between FIFO and request logic
  wire            fifo_np_ok;
  wire            fifo_pcpl_ok;
  wire            fifo_np_req;
  wire            fifo_pcpl_req;

  // Processing of data between data_snk and FIFO
  reg             snk_np_reg;
  reg  [3:0]      snk_barenc;
  reg             snk_bar_ok;
  reg             abort_np;
  reg             abort_pcpl;

  // User outputs (these signals are inverted before being output)
  wire            trn_rsrc_rdy;
  wire [7:0]      trn_rrem;
  wire            trn_rsof;
  wire            trn_reof;
  wire            trn_rerrfwd;
  wire [6:0]      trn_rbar_hit;
 

  reg             llk_rx_sof_n_d     = 1;
  reg             llk_rx_eof_n_d     = 1;
  reg  [1:0]      llk_rx_valid_n_d   = 0;
  reg             llk_rx_src_rdy_n_d = 1;
  reg             llk_rx_src_dsc_n_d = 1;

  wire            rx_err_cpl_abort;
  wire            rx_err_cpl_ur;
  wire            rx_err_cpl_ep;
  wire            rx_err_ep;

  assign          rx_err_cpl_abort_n = !rx_err_cpl_abort;
  assign          rx_err_cpl_ur_n    = !rx_err_cpl_ur;
  assign          rx_err_cpl_ep_n    = !rx_err_cpl_ep;
  assign          rx_err_ep_n        = !rx_err_ep;

  // Drive unsupported outputs to a known value
  //assign llk_rx_dst_cont_req_n = 1;

  // BAR Checking and packet filtering logic (from TLM)
  tlm_rx_data_snk 
  #(.DW              (64), // Data width
    .FCW             (6),  // Packet credit width - not used
    .BARW            (7),  // BAR-hit width
    .DOWNSTREAM_PORT (0),  // Endpoint, not downstream port
    .MPS             (MPS_DECODE),// Core (capability) MPS
    .TYPE1_UR        (1)   // Issue UR on Type1 config TLP
   ) snk_inst (
    .clk_i               (clk),
    .reset_i             (!rst_n),

    //--------------------------------------------------------
    // Datapath signals
    //--------------------------------------------------------

    // To FIFO
    .d_o                (snk_d),               // Data
    .sof_o              (snk_sof),             // ll sof
    .eof_o              (snk_eof),             // ll eof
    .preeof_o           (snk_preeof),          // ll eof 1 cycle early
    .src_rdy_o          (snk_src_rdy),         // ll src_rdy
    .rem_o              (snk_rem),             // ll rem (in words)
    .dsc_o              (snk_src_dsc),         // ll dsc

    .cfg_o              (snk_cfg),             // Config packet, @bar
    .locked_o           (snk_locked),          // Locked msg or cpl, @bar
    .np_o               (snk_np),              // Non-posted packet, @bar
    .cpl_o              (snk_cpl),             // Completion packet, @bar
    .bar_o              (snk_bar),             // Bar hit, @bar
    .rid_o              (snk_rid),             // RID hit, @bar
    .vend_msg_o         (snk_vend_msg),        // Vendor-defined MSG, @bar
    .bar_src_rdy_o      (snk_bar_src_rdy),     // ll src_rdy

    // To Flow controller
    .fc_use_p_o         (), // posted update.. implies 1 hdr
    .fc_use_np_o        (), // nonposted update.. ''
    .fc_use_cpl_o       (), // compl update..     ''
    .fc_use_data_o      (), // number of data credits used
    .fc_unuse_o         (), // ll src_rdy.. implies 1 header

    // From LLM
    .d_i                (llk_rx_data_d),        // Data
    .sof_i              (!llk_rx_sof_n_d),      // ll sof
    .eof_i              (!llk_rx_eof_n_d),      // ll eof
    .rem_i              (!llk_rx_valid_n_d[0]), // ll rem in binary bytes
    .src_rdy_i          (!llk_rx_src_rdy_n_d),  // ll src_rdy
    .src_dsc_i          (!llk_rx_src_dsc_n_d),  // ll dsc

    //--------------------------------------------------------
    // Sideband signals
    //--------------------------------------------------------

    // InitFC communication to LLM
    .vc_hit_o           (),     // TLP received on VC0

    // Power management signals for CMM
    .pm_as_nak_l1_o     (),     // Pkt detected, implies src_rdy
    .pm_turn_off_o      (),     // Pkt detected, implies src_rdy
    .pm_set_slot_pwr_o  (),     // Pkt detected, implies src_rdy
    .pm_set_slot_pwr_data_o (), // value of field
    .pm_suspend_req_i   (1'b0), // Go into pm.. drop packets - NOTE: should be
                                // handled internally by Block

    // Completion event information for CMM
    .err_tlp_cpl_header_o (err_tlp_cpl_header), // Header fields
    .err_tlp_p_o        (err_tlp_p),     // Pkt is posted
    .err_tlp_ur_o       (err_tlp_ur),    // Unsupported req, implies src_rdy
    .err_tlp_ur_lock_o  (err_tlp_ur_lock),// Unsupported req dur to lock, implies src_rdy
    .err_tlp_uc_o       (err_tlp_uc),    // Unsupported cpl, implies src_rdy
    .err_tlp_malformed_o (err_tlp_malformed),   // Pkt is badly constructed,
                                                //   implies src_rdy
    // status register in the CMM
    .stat_tlp_cpl_abort_o (rx_err_cpl_abort),   // cpl stat is abort
    .stat_tlp_cpl_ur_o  (rx_err_cpl_ur),  // cpl stat is ur
    .stat_tlp_cpl_ep_o  (rx_err_cpl_ep),  // cpl inc pkt poison
    .stat_tlp_ep_o      (rx_err_ep),      // incoming pkt poison

    // Outgoing information to check CMM for bar hit
    .check_raddr_o      (check_raddr),     // is address mapped?
    .check_mem32_o      (check_mem32),
    .check_mem64_o      (check_mem64),
    .check_rio_o        (check_rio),       // implies src_rdy
    .check_rdev_o       (check_rdev),      // implies src_rdy
    .check_rbus_o       (check_rbus),      // implies src_rdy
    .check_rfun_o       (check_rfun),      // implies src_rdy
    // Incoming information from CMM on bar hit status
    .check_rhit_i       (check_rhit),    // match found
    .check_rhit_bar_i   (check_rhit_bar),// address of match
    // Static control from CMM
    .max_payload_i      (max_payload_size),// Enc val for max paysize allowed
    .rhit_bar_lat3_i    (check_rhit_bar_lat3), // BAR-hit latency 3 clocks?
    .legacy_mode_i      (LEGACY_EP), // For interp of the spec
    .legacy_cfg_access_i(1'b0),      // User implements legacy config? Not
                                     // supported in this release
    .ext_cfg_access_i   (1'b0),      // User implements ext. config? Not
                                     // supported in this release
    .hotplug_msg_enable_i(1'b0),     // Pass obsolete hot-plug to user? Never.
    .td_ecrc_trim_i     (TRIM_ECRC)  // Strip digest for user?
  );

  // Populate the bits of the cfg bus which are required by cmm_decoder;
  //   set everything else to X so if it's used but we didn't notice, the
  //   X will propagate
  wire [671:0] cfg_temp = {{320{1'bx}}, XROM_BAR, {64{1'bx}}, BAR5,
                          BAR4, BAR3, BAR2, BAR1, BAR0, {64{1'bx}}};

  // Instantiate BAR decoder logic from the CMM32
  cmm_decoder bar_decoder
  (
   .raddr              (check_raddr),
   .rmem32             (check_mem32),
   .rmem64             (check_mem64),
   .rio                (check_rio),
   .rcheck_bus_id      (check_rbus),
   .rcheck_dev_id      (check_rdev),
   .rcheck_fun_id      (check_rfun),
   .rhit               (check_rhit),
   .bar_hit            (check_rhit_bar),
   .cmmt_rbar_hit_lat2_n (check_rhit_bar_lat3), // lat=2 if low, =3 if high
   .command            ({14'hXXXX, mem_space_enable, io_space_enable}),
   .bar0_reg           (cfg_rx_bar0),
   .bar1_reg           (cfg_rx_bar1),
   .bar2_reg           (cfg_rx_bar2),
   .bar3_reg           (cfg_rx_bar3),
   .bar4_reg           (cfg_rx_bar4),
   .bar5_reg           (cfg_rx_bar5),
   .xrom_reg           (cfg_rx_xrom),
   .pme_pmcsr          (cfg_pmcsr),
   .bus_num            (cfg_bus_number),
   .device_num         (cfg_device_number),
   .function_num       (cfg_function_number),
   .phantom_functions_supported (2'b01), //Block core supports 1 phantom bit
   .phantom_functions_enabled   (cfg_dcommand[9]),
   .cfg                (cfg_temp),
   .rst                (!rst_n),
   .clk                (clk)
  );

  // Determine if the current TLP from the data_snk is valid for output
  // to user logic. TLPs are valid _unless_ one of the following is true:
  //
  // 1)  TLP is a request and did not hit any BAR
  // 2)  TLP should have been processed by config logic
  // 3)  TLP is a locked transaction and this isn't a Legacy Endpoint
  // 4)  TLP is a completion but doesn't match our RID
  //
  // Additionally, the BAR value is encoded to fit in 4 bits so that it
  // can be stored in a single BRAM in parallel with data.
  always @(posedge clk) begin
    if (snk_bar_src_rdy) begin
      case (snk_bar)
        // 32-bit BARs
        7'b0000001:  snk_barenc <= #`TCQ 4'b0000;
        7'b0000010:  snk_barenc <= #`TCQ 4'b0001;
        7'b0000100:  snk_barenc <= #`TCQ 4'b0010;
        7'b0001000:  snk_barenc <= #`TCQ 4'b0011;
        7'b0010000:  snk_barenc <= #`TCQ 4'b0100;
        7'b0100000:  snk_barenc <= #`TCQ 4'b0101;
        7'b1000000:  snk_barenc <= #`TCQ 4'b0110;
        // 64-bit BARs
        7'b0000011:  snk_barenc <= #`TCQ 4'b0111;
        7'b0000110:  snk_barenc <= #`TCQ 4'b1000;
        7'b0001100:  snk_barenc <= #`TCQ 4'b1001;
        7'b0011000:  snk_barenc <= #`TCQ 4'b1010;
        7'b0110000:  snk_barenc <= #`TCQ 4'b1011;
        // No BAR hit
        default:     snk_barenc <= #`TCQ 4'b1100;
      endcase
      snk_np_reg   <= #`TCQ snk_np;
      snk_bar_ok   <= #`TCQ (snk_vend_msg ? 1'b1 :
                                            (snk_cpl ? snk_rid : |snk_bar))
                            && !snk_cfg && !(snk_locked && !LEGACY_EP);
    end
  end

  // Detect TLPs that are never fully written to the FIFO and cause the
  // FIFO fullness counter to be decremented appropriately
  always @(posedge clk) begin
    if (!rst_n) begin
      abort_np    <= #`TCQ 1'b0;
      abort_pcpl  <= #`TCQ 1'b0;
    end else begin
      abort_np    <= #`TCQ snk_src_rdy && snk_src_dsc && snk_np_reg;
      abort_pcpl  <= #`TCQ snk_src_rdy && snk_src_dsc && !snk_np_reg;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      llk_rx_sof_n_d     <= #`TCQ 1;
      llk_rx_eof_n_d     <= #`TCQ 1;
      llk_rx_valid_n_d   <= #`TCQ 0;
      llk_rx_src_rdy_n_d <= #`TCQ 1;
      llk_rx_src_dsc_n_d <= #`TCQ 1;
    end else begin
      llk_rx_sof_n_d     <= #`TCQ llk_rx_sof_n;
      llk_rx_eof_n_d     <= #`TCQ llk_rx_eof_n;
      llk_rx_valid_n_d   <= #`TCQ llk_rx_valid_n;
      llk_rx_src_rdy_n_d <= #`TCQ llk_rx_src_rdy_n;
      llk_rx_src_dsc_n_d <= #`TCQ llk_rx_src_dsc_n;
    end
  end

  always @(posedge clk) begin
    llk_rx_data_d      <= #`TCQ llk_rx_data;
  end

  // FIFO to store data and BAR values
  // Accepts data from data_snk, passes data to TRN (user) interface,
  // and communicates fullness to arbiter so it can request as many TLPs
  // as possible to keep FIFO full.
  //pcie_blk_ll_dualfifo fifo_inst (
  pcie_blk_ll_oqbqfifo fifo_inst (
    .clk             (clk),
    .rst_n           (rst_n),
    .trn_rsrc_rdy    (trn_rsrc_rdy),
    .trn_rd          (trn_rd),
    .trn_rrem        (trn_rrem),
    .trn_rsof        (trn_rsof),
    .trn_reof        (trn_reof),
    .trn_rerrfwd     (trn_rerrfwd),
    .trn_rbar_hit    (trn_rbar_hit),
    .fifo_np_ok      (fifo_np_ok),
    .fifo_pcpl_ok    (fifo_pcpl_ok),
    .trn_rdst_rdy    (!trn_rdst_rdy_n),
    .trn_rnp_ok      (!trn_rnp_ok_n),
    .fifo_wren       (snk_src_rdy),
    .fifo_data       (snk_d),
    .fifo_rem        (snk_rem),
    .fifo_sof        (snk_sof && snk_bar_ok),
    .fifo_preeof     (snk_preeof),
    .fifo_eof        (snk_eof),
    .fifo_dsc        (snk_src_dsc),
    .fifo_np         (snk_np_reg),
    .fifo_barenc     (snk_barenc),
    .fifo_np_req     (fifo_np_req),
    .fifo_pcpl_req   (fifo_pcpl_req),
    .fifo_np_abort   (abort_np),
    .fifo_pcpl_abort (abort_pcpl)
  );
  // Invert outputs for user logic
  assign trn_rsrc_rdy_n = !trn_rsrc_rdy;
  assign trn_rrem_n     = ~trn_rrem;
  assign trn_rsof_n     = !trn_rsof;
  assign trn_reof_n     = !trn_reof;
  assign trn_rerrfwd_n  = !trn_rerrfwd;
  assign trn_rbar_hit_n = ~trn_rbar_hit;
  // FIXME add trn_tsrc_dsc_n

  // Instantiate the arbiter, which determines which of the Block's FIFOs
  // to read from next.
  pcie_blk_ll_arb #(.CPL_STREAMING_PRIORITIZE_P_NP(CPL_STREAMING_PRIORITIZE_P_NP))
  arb_inst (
    .clk              (clk),
    .rst_n            (rst_n),
    .llk_rx_dst_req_n (llk_rx_dst_req_n),
    .llk_rx_dst_cont_req_n (llk_rx_dst_cont_req_n),
    .llk_rx_ch_tc     (llk_rx_ch_tc),
    .llk_rx_ch_fifo   (llk_rx_ch_fifo),
    .fifo_np_req      (fifo_np_req),
    .fifo_pcpl_req    (fifo_pcpl_req),
    .fifo_np_ok       (fifo_np_ok),
    .fifo_pcpl_ok     (fifo_pcpl_ok),
    .trn_rnp_ok_n     (trn_rnp_ok_n),
    .llk_rx_src_last_req_n            (llk_rx_src_last_req_n),
    .llk_rx_ch_posted_available_n     (llk_rx_ch_posted_available_n),
    .llk_rx_ch_non_posted_available_n (llk_rx_ch_non_posted_available_n),
    .llk_rx_ch_completion_available_n (llk_rx_ch_completion_available_n),
    .llk_rx_preferred_type            (llk_rx_preferred_type),
    .trn_rcpl_streaming_n             (trn_rcpl_streaming_n),
    .cpl_tlp_cntr     (rx_ch_credits_received),
    .cpl_tlp_cntr_inc (rx_ch_credits_received_inc)
  ); 

//ASSERTIONS
//synthesis translate_off
always @(posedge clk) begin
  if (!llk_rx_sof_n && !llk_rx_eof_n) 
     $display("FAIL: Simultaneous assertion of Llk Rx SOF/EOF ");
end
//synthesis translate_on

`ifdef SV
  //synthesis translate_off
  ASSERT_STALL_NP2:      assert property (@(posedge clk)
    fifo_inst.bq_full || fifo_inst.oq_full |-> !(!llk_rx_sof_n && !llk_rx_src_rdy_n && 
                                                 ((llk_rx_data[63:56]==8'h00) ||
                                                  (llk_rx_data[63:56]==8'h20) ||
                                                  (llk_rx_data[63:56]==8'h01) ||
                                                  (llk_rx_data[63:56]==8'h21)
                                                 ))
                                         ) else $fatal;
  ASSERT_STALL_PCPL2:    assert property (@(posedge clk)
    fifo_inst.oq_full                      |-> !(!llk_rx_sof_n && !llk_rx_src_rdy_n)
                                         ) else $fatal;
//synthesis translate_on
`endif


endmodule // pcie_blk_plus_ll_rx

