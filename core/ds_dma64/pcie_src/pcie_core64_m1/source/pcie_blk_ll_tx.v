
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
// File       : pcie_blk_ll_tx.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : PCIe Block LocalLink Tx Bridge - adds a LocalLink interface
 *                compatible with the PCIe soft core to the V-5 PCIe Hard
 *                Block
 *
 *  NOTE:  Search for "FIXME" tags for high-priority changes to be made
 ****************************************************************************/

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

module pcie_blk_ll_tx
  //{{{ Module Port declarations
  #( parameter TX_CPL_STALL_THRESHOLD   = 6,
     parameter TX_DATACREDIT_FIX_EN     = 1,
     parameter TX_DATACREDIT_FIX_1DWONLY= 1,
     parameter TX_DATACREDIT_FIX_MARGIN = 6,
     parameter MPS                      = 0,
     parameter LEGACY_EP                = 0
  )
  (
   // Clock and reset
   input  wire        clk,
   input  wire        rst_n,
   // Transaction Link Up
   input  wire        trn_lnk_up_n,
   // PCIe Block Tx Ports
   output wire [63:0] llk_tx_data,
   output reg         llk_tx_src_rdy_n = 1'b1,
   output wire        llk_tx_src_dsc_n,
   output wire        llk_tx_sof_n,
   output wire        llk_tx_eof_n,
   output wire        llk_tx_sop_n,
   output wire        llk_tx_eop_n,
   output wire  [1:0] llk_tx_enable_n,
   output reg   [2:0] llk_tx_ch_tc = 0,
   output reg   [1:0] llk_tx_ch_fifo = 2'b11,
   input  wire        llk_tx_dst_rdy_n,
   input  wire  [9:0] llk_tx_chan_space,
   input  wire  [7:0] llk_tx_ch_posted_ready_n,     // ignored input
   input  wire  [7:0] llk_tx_ch_non_posted_ready_n, // ignored input
   input  wire  [7:0] llk_tx_ch_completion_ready_n, // ignored input
   // LocalLink Tx Ports
   input  wire [63:0] trn_td,
   input  wire  [7:0] trn_trem_n,
   input  wire        trn_tsof_n,
   input  wire        trn_teof_n,
   input  wire        trn_tsrc_rdy_n,
   input  wire        trn_tsrc_dsc_n,
   input  wire        trn_terrfwd_n,  // NOTE: this input is ignored
(* XIL_PAR_PATH = "pcie_ep.LLKTXDSTRDYN->D", XIL_PAR_IP_NAME = "PCIE", syn_keep = "1", keep = "TRUE" *)
   output reg         trn_tdst_rdy_n = 1'b0,
   output wire        trn_tdst_dsc_n,
   output wire        trn_tbuf_av_cpl,
   input  wire  [7:0] tx_ch_credits_consumed,
   input  wire [11:0] tx_pd_credits_available,
   input  wire [11:0] tx_pd_credits_consumed,
   input  wire [11:0] tx_npd_credits_available,
   input  wire [11:0] tx_npd_credits_consumed,
   input  wire [11:0] tx_cd_credits_available,
   input  wire [11:0] tx_cd_credits_consumed,
   output wire        clear_cpl_count,
   input  wire        pd_credit_limited,
   input  wire        npd_credit_limited,
   input  wire        cd_credit_limited,
   input  wire        trn_pfc_cplh_cl_upd,   //used to cause initialization of CPLD fix Margin
   input  wire  [7:0] trn_pfc_cplh_cl,       //CPLD fix Margin value
   input  wire        l0_stats_cfg_transmitted
   );
  //}}}
  //{{{ Parameters, regs, wires

  // FIFO encodings
  localparam POSTED_CAT     = 2'b00;
  localparam NONPOSTED_CAT  = 2'b01;
  localparam COMPLETION_CAT = 2'b10;
  // Format/Type encoding for message types
  localparam MRD            = 7'b0X_00000; // Memory Read
  localparam MRDLK          = 7'b0X_00001; // Memory Read Lock
  localparam MWR            = 7'b1X_00000; // Memory Write
  localparam MSG            = 7'bX1_10XXX; // Message
  localparam IORD           = 7'b00_00010; // I/O Read
  localparam IOWR           = 7'b10_00010; // I/O Write
  localparam CFGRD          = 7'b00_0010X; // Config Read
  localparam CFGWR          = 7'b10_0010X; // Config Write
  localparam CPL            = 7'bX0_0101X; // Completion

  localparam CHANSPACE_CPLEMPTY = (MPS==0)? 8'h48 : (MPS==1)? 8'h80 : 8'h80;

  // Static outputs
  assign trn_tdst_dsc_n    = 1'b1;

  // Signals for pipeline storage. Note that all signals are active-high,
  // even though some inputs & outputs are active-low. Also, signals are
  // added to the pipeline in later stages (sof_gap for example) that are
  // not present in earlier stages.
  reg [63:0]       td_q1 = 0;       // Data
  reg              sof_q1 = 0;      // Start of frame
  reg              eof_q1 = 0;      // End of frame
  reg              rem_q1 = 0;      // 1-bit encoding of remainder/enable
  reg              dsc_q1 = 0;      // Discontinue
  reg              vld_q1 = 0;      // Valid
(* XIL_PAR_PATH = "pcie_ep.LLKTXDSTRDYN->D", XIL_PAR_IP_NAME = "PCIE", syn_keep = "1", keep = "TRUE" *)
  reg [63:0]       td_q2 = 0;
(* XIL_PAR_PATH = "pcie_ep.LLKTXDSTRDYN->CE", XIL_PAR_IP_NAME = "PCIE", syn_keep = "1", keep = "TRUE" *)
  reg [5:0]        td_q2_credits = 0; //assume 512byte MPS; 512by*(1dw/4by)*(1cr/4dw)=32 (6 bits needed)
  reg              td_q2_credits_prev = 0;
  reg              td_q2_posted  = 0;
  reg              td_q2_iowr    = 0;
  reg              td_q2_cpl     = 0;
  reg              sof_q2_reg    = 0;
  wire             sofpd_q2_rose;
  wire             sofnpd_q2_rose;
  wire             sofcpl_q2_rose;
  reg              pd_q1_reg     = 0;
  reg              npd_q1_reg    = 0;
  reg              cpl_q1_reg    = 0;
  reg              sof_q2 = 0;
  reg              eof_q2 = 0;
  reg              rem_q2 = 0;
  reg              dsc_q2 = 0;
  reg              vld_q2 = 0;
  reg              sof_gap_q2 = 0;  // Insert gap before SOF
                                    //   (due to change of tc and/or fifo)
  reg [1:0]        fifo_q2 = 0;     // FIFO (Posted, Non-posted, or Completion)
  reg [2:0]        tc_q2 = 0;       // Traffic class
  reg [63:0]       td_q3 = 0;
  reg              sof_q3 = 0;
  reg              eof_q3 = 0;
  reg              rem_q3 = 0;
  reg              dsc_q3 = 0;
  reg              vld_q3 = 0;
  reg              sof_gap_q3 = 0;
(* XIL_PAR_PATH = "pcie_ep.LLKTXDSTRDYN->CE", XIL_PAR_IP_NAME = "PCIE", syn_keep = "1", keep = "TRUE" *)
  reg [1:0]        fifo_q3 = 0;
  reg [2:0]        tc_q3 = 0;
  // FIFO and TC of previous packet - used to determine whether to insert a
  // gap between EOF and SOF
  reg [1:0]        fifo_last = 0;
  reg [2:0]        tc_last = 0;

  //(* keep = "true" *) reg              shift_pipe;      // Move data through pipeline
  wire             shift_pipe;
  wire             only_eof;        // Asserted to flush pipeline at EOF

  reg              sof_gap_q3_and_block = 1;
  reg              block_sof = 1;   // Asserted to indicate when an SOF with
                                    // a new TC or FIFO should be held off
  reg [2:0]        block_cnt = 0;   // Control changing of TC/FIFO outputs

  // Signals comprising the shunt buffer used to decouple the trn_tdst_rdy_n
  // output from the llk_tx_dst_rdy_n input
  reg [63:0]       td_buf;
  reg              sof_buf;
  reg              eof_buf;
  reg              rem_buf;
  reg              dsc_buf;
  reg              vld_buf = 1'b0;  // Shunt buffer contents valid
  wire             buf_divert;      // Current cycle to be stored in shunt buf
  wire             buf_rd;          // Xfer shunt buffer to pipeline this cycle
  reg  [ 4:0]      cpl_in_count;
  wire  [4:0]      cpls_buffered;
  reg              llk_tlp_halt;
  reg              llk_tx_src_rdy_n_int;
  reg  [11:0]      user_pd_data_credits_in    = 0;
  reg  [11:0]      user_npd_data_credits_in   = 0;
  reg  [11:0]      user_cd_data_credits_in    = 0;
  reg  [11:0]      all_cd_data_credits_in    = 0;
  reg  [11:0]      l0_stats_cfg_transmitted_cnt=0;

  reg  [11:0]      user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1    = 0;

  reg              pd_credits_near_gte_far    = 0;
  reg              npd_credits_near_gte_far   = 0;
  reg              llk_cpl_second_cycle       = 0;
  reg              llk_tx_ch_fifo_d           = 2'b11;
  reg              q2_cpl_second_cycle        = 0;
  wire [11:0]      near_end_pd_credits_buffered;
  wire [11:0]      near_end_npd_credits_buffered;
  wire [11:0]      near_end_cd_credits_buffered;
  reg              near_end_cd_credits_buffered_11_d;
  wire             packet_in_progress;
  reg              packet_in_progress_reg     = 0;
  reg              len_eq1_q2                 = 0;
  reg              llk_tx_chan_space_cpl_empty= 0;
  reg              eof_q3_only = 0;
  reg              eof_q2_only = 0;
  reg              eof_q1_or_eof_q2_only = 0;
  reg              tc_fifo_change = 1'b0;
  reg              block_fifo     = 1'b1;

  reg  [11:0]      cd_space_remaining_int     = 0;
  reg              cd_space_remaining_int_zero= 0;
  reg   [8:0]      trn_pfc_cplh_cl_plus1      = 9;
  reg              trn_pfc_cplh_cl_upd_d1     = 0;
  reg              trn_pfc_cplh_cl_upd_d2     = 0;
  //}}}

  //{{{ Shunt Buffer
  // Input shunt buffer - absorb one cycle of data to decouple
  // trn_tdst_rdy_n from other signals (and therefore make it a
  // registered output)

  // vld_buf has to be set and cleared every cycle something changes
  always @(posedge clk) begin
    if (!rst_n) begin
      vld_buf         <= #`TCQ 1'b0;
    end else begin
      if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && buf_divert) begin
        vld_buf       <= #`TCQ 1'b1;
      end else if (buf_rd) begin
        vld_buf       <= #`TCQ 1'b0;
      end
    end
  end

  // All the rest of the data & control signals only need to be changed
  // when new data is available since they're masked with vld_buf
  always @(posedge clk) begin
    if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n) begin
      td_buf        <= #`TCQ trn_td;
      sof_buf       <= #`TCQ !trn_tsof_n;
      eof_buf       <= #`TCQ !trn_teof_n;
      rem_buf       <= #`TCQ !trn_trem_n[0];
      dsc_buf       <= #`TCQ !trn_tsrc_dsc_n;
    end
  end

  // Control when the shunt buffer is written and read
  //   Writes go to the shunt buffer when the first pipeline stage is full
  //   and not emptying
  // attribute fast of vld_q1 is "true";
  assign buf_divert = vld_q1 && !shift_pipe;
  //   The shunt buffer gets read when the pipeline is first shifted after
  //   the shuny buffer is filled
  // attribute fast of vld_buf is "true";
  assign buf_rd     = vld_buf && shift_pipe;

  // Generate trn_tdst_rdy output. It is always asserted unless the shunt
  // buffer is full or going full. When the shunt buffer goes full, input
  // is cut off until it goes empty, since the buffer can only absorb a
  // single cycle of data.
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_tdst_rdy_n  <= #`TCQ 1'b0;
    end else begin
      trn_tdst_rdy_n  <= #`TCQ !((!vld_buf &&
      //                             !(buf_divert && !trn_tdst_rdy_n)) ||
      // fix for CR472508-add additional qualifier
                  !(buf_divert && !trn_tdst_rdy_n && !trn_tsrc_rdy_n)) ||
                                 buf_rd);
    end
  end
  //}}}

  //{{{ Stage 1
  // Data & control pipeline, first stage. First stage can receive data
  // from either the user or the shunt buffer.

  always @(posedge clk) begin
    // Only SOF, and vld are reset - to allow inferring of SRL16s
    if (!rst_n) begin
      vld_q1       <= #`TCQ 1'b0;
    end else begin
      vld_q1   <= #`TCQ (((!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) || buf_rd) ||
                       (vld_q1 && !shift_pipe));
    end
    if (!rst_n) begin
      sof_q1  <= #`TCQ 1'b0;
    end else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin
      sof_q1  <= #`TCQ !trn_tsof_n;
    end else if (buf_rd) begin
      sof_q1  <= #`TCQ sof_buf;
    //end else if (shift_pipe) begin
    //  sof_q1  <= #`TCQ 1'b0; // SOF implies vld
    end else begin
      sof_q1  <= #`TCQ (!shift_pipe && sof_q1);
    end
    if (!rst_n) begin
      eof_q1  <= #`TCQ 0;
      dsc_q1  <= #`TCQ 0;
    end else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin
      eof_q1  <= #`TCQ !trn_teof_n;
      dsc_q1  <= #`TCQ !trn_tsrc_dsc_n;
    end else if (buf_rd) begin
      eof_q1  <= #`TCQ eof_buf;
      dsc_q1  <= #`TCQ dsc_buf;
    end
  end

  always @(posedge clk) begin
    //If user data available, buffer empty, and either pipe isn't stalled OR stage 1 isn't valid,
    // grab user data  (note: tdst_rdy won't assert if buffer is full)
    if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin // !buf_divert = shift_pipe || !vld_q1
      td_q1   <= #`TCQ trn_td;
      rem_q1  <= #`TCQ !trn_trem_n[0];
    //If pipe isn't stalled and buffer is valid, pull from buffer
    //end else if (buf_rd) begin       // buf_rd = shift_pipe && vld_buf
    end else if (shift_pipe) begin       // buf_rd = shift_pipe && vld_buf
      td_q1   <= #`TCQ td_buf;
      rem_q1  <= #`TCQ rem_buf;
    end
  end
  //}}}

  //{{{ Stages 2 and 3
  // 2nd & 3rd pipeline stages - note that each stage must remain full
  // in order to correctly generate EOP. Once an EOF is received, the
  // pipeline can be flushed unless an SOF is received. This allows a
  // single packet to pass all the way through the pipeline without being
  // "pushed" by another packet.

  always @(posedge clk) begin
    // Only SOF and vld are reset - to allow inferring of SRL16s on other
    // signals
    if (!rst_n) begin
      sof_q2     <= #`TCQ 1'b0;
      vld_q2     <= #`TCQ 1'b0;
      len_eq1_q2 <= #`TCQ 1'b0;
      sof_q3     <= #`TCQ 1'b0;
      eof_q3     <= #`TCQ 1'b0;
      vld_q3     <= #`TCQ 1'b0;
    end else begin
      if (shift_pipe) begin
        // Second stage
        sof_q2     <= #`TCQ sof_q1;
        vld_q2     <= #`TCQ vld_q1;
        if (sof_q1) len_eq1_q2 <= #`TCQ (td_q1[41:32] == 10'h001) && !(!td_q1[62] && td_q1[60:57] != 4'b0000);
        // Third stage - this stage is also the output data
        sof_q3     <= #`TCQ sof_q2;
        eof_q3     <= #`TCQ eof_q2 && vld_q2; // Need EOF to be gated with vld
                                              // for gapping below
        vld_q3     <= #`TCQ vld_q2;
      end
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      td_q2      <= #`TCQ 0;
      td_q2_credits <= #`TCQ 'h0;
      td_q2_posted  <= #`TCQ 0;
      td_q2_iowr    <= #`TCQ 0;
      td_q2_cpl     <= #`TCQ 0;
      pd_q1_reg     <= #`TCQ 0;
      npd_q1_reg    <= #`TCQ 0;
      cpl_q1_reg    <= #`TCQ 0;
      eof_q2     <= #`TCQ 0;
      rem_q2     <= #`TCQ 0;
      dsc_q2     <= #`TCQ 0;
    end else if (shift_pipe) begin
      // Second stage
      td_q2      <= #`TCQ td_q1;
      if (sof_q1)
        td_q2_credits <= #`TCQ (td_q1[39:34] + (|td_q1[33:32])); //assume MPS<=512
      td_q2_posted  <= #`TCQ (td_q1[62:57] == 'b10_0000) || (td_q1[62:57] == 'b11_0000) || (td_q1[62:59] == 'b11_10);
      td_q2_iowr    <= #`TCQ (td_q1[62:57] == 'b10_0001);
      td_q2_cpl     <= #`TCQ (td_q1[62:57] == 'b10_0101);
      pd_q1_reg     <= #`TCQ (td_q1[62:57] == 'b100_000) || (td_q1[62:57] == 'b110_000) || (td_q1[62:59] == 'b111_0);
      npd_q1_reg    <= #`TCQ (td_q1[62:57] == 'b10_0001);
      cpl_q1_reg    <= #`TCQ (td_q1[62:57] == 'b10_0101);
      eof_q2     <= #`TCQ eof_q1;
      rem_q2     <= #`TCQ rem_q1 || !eof_q1; // Mask off REM when not EOF
      dsc_q2     <= #`TCQ dsc_q1;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      sof_q2_reg    <= #`TCQ 0;
    end else begin
      sof_q2_reg    <= #`TCQ sof_q2;
    end
  end

  assign sofpd_q2_rose  = (sof_q2 && !sof_q2_reg && pd_q1_reg);
  assign sofnpd_q2_rose = (sof_q2 && !sof_q2_reg && npd_q1_reg);
  assign sofcpl_q2_rose = (sof_q2 && !sof_q2_reg && cpl_q1_reg);

  always @(posedge clk) begin
    if (!rst_n) begin
      td_q3      <= #`TCQ 0;
      rem_q3     <= #`TCQ 0;
      dsc_q3     <= #`TCQ 0;
      tc_q3      <= #`TCQ 0;
      fifo_q3    <= #`TCQ 0;
    end else if (shift_pipe) begin
      // Third stage - this stage is also the output data
      td_q3      <= #`TCQ td_q2;
      rem_q3     <= #`TCQ rem_q2;
      dsc_q3     <= #`TCQ dsc_q2;
      // TC and FIFO only change at SOF
      if (sof_q2) begin
        tc_q3    <= #`TCQ tc_q2;
        fifo_q3  <= #`TCQ fifo_q2;
      end
    end
  end

  // Calculate and latch "FIFO" (Posted, Non-posted, or Completion) and TC
  // Calculated from first stage and valid in parallel with sof_q2
  always @(posedge clk) begin
    // No reset neccesary

    if (sof_q1 && shift_pipe) begin
      casex (td_q1[62:56])
        // Posted
        MWR,    // Memory Write
        MSG:    // Message
          fifo_q2 <= #`TCQ POSTED_CAT;
        // Non-Posted
        MRD,    // Memory Read
        MRDLK,  // Memory Read Lock
        IORD,   // I/O Read
        IOWR,   // I/O Write
        CFGRD,  // Config Read
        CFGWR:  // Config Write
          fifo_q2 <= #`TCQ NONPOSTED_CAT;
        // Completion
        CPL:    // Completion
          fifo_q2 <= #`TCQ COMPLETION_CAT;
        // Frame should _always_ be one of the above, so this is just
        // here to ensure the synthesizer doesn't do anything weird
        default:
          fifo_q2 <= #`TCQ POSTED_CAT;
      endcase
      tc_q2  <= #`TCQ td_q1[54:52];
    end
  end
  //}}}

  // {{{ TC/FIFO Outputs; Enforce 2-cycle FIFO Change
  // Generate TC and FIFO output, as well as the block_sof signal. This
  // prevents changing of TC/FIFO for 2 cycles after EOF and asserting of
  // a valid SOF beat for one cycle after changing of TC/FIFO.
  // This does not affect SOF when TC/FIFO doesn't change.
  //
  // FIXME comment better
  // Requirements:
  //   1) Hold TC/FIFO steady for two cycles WITH DST_RDY ASSERTED after EOF.
  //   2) Don't assert SOF for one cycle after changing TC/FIFO.
  //
  //   #1 means asserting block_sof for (at least) two cycles after valid
  //   EOF output.
  //   #2 means continuing to assert block_sof until
  //      a) a valid (non tc/fifo change) sof is transmitted
  //      b) one cycle after tc/fifo changes

  // synthesis attribute use_clock_enable of block_cnt is no;
  // attribute fast of eof_q3 is "true";

  // Generate sof_gap signal. sof_gap directs the output logic to delay
  // changing TC/FIFO outputs and starting a new packet when either TC or
  // FIFO changes.
  always @(posedge clk) begin
    if (!rst_n) begin
      sof_gap_q3    <= #`TCQ 1'b0;
      fifo_last     <= #`TCQ 2'b00;
      tc_last       <= #`TCQ 0;
    end else if (sof_q2 && shift_pipe) begin // sof_q2 implies vld_q2
      // If FIFO or TC has changed, assert sof_gap
      if ((tc_q2 != tc_last) || (fifo_q2 != fifo_last)) begin
        sof_gap_q3  <= #`TCQ 1'b1;
      end else begin
        sof_gap_q3  <= #`TCQ 1'b0;
      end
      // Latch current TC & FIFO at SOF
      fifo_last     <= #`TCQ fifo_q2;
      tc_last       <= #`TCQ tc_q2;
    end else if (vld_q2 && shift_pipe) begin
      // Sof_gap is only asserted with SOF
      sof_gap_q3    <= #`TCQ 1'b0;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      block_sof          <= #`TCQ 1'b1;
    end else begin
      if (tc_fifo_change) begin
        block_sof        <= #`TCQ 1'b0;
      end else if (sof_q2) begin
        block_sof        <= #`TCQ 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (!rst_n)
      sof_gap_q3_and_block  <= #`TCQ 1'b0;
    else begin
      if      (tc_fifo_change)
        sof_gap_q3_and_block  <= #`TCQ 1'b0;
      else if (  sof_q2 && shift_pipe )
        sof_gap_q3_and_block  <= #`TCQ ((tc_q2 != tc_last) || (fifo_q2 != fifo_last)) && (block_sof || sof_q2);
      else if (  vld_q2 && shift_pipe )
        sof_gap_q3_and_block  <= #`TCQ 1'b0;
      else 
        sof_gap_q3_and_block  <= #`TCQ sof_gap_q3 && (block_sof || sof_q2);
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      block_cnt          <= #`TCQ 0;
      block_fifo         <= #`TCQ 1'b0;
      tc_fifo_change     <= #`TCQ 1'b0;
      llk_tx_ch_tc       <= #`TCQ 0;
      llk_tx_ch_fifo     <= #`TCQ 2'b11;
      llk_tx_ch_fifo_d   <= #`TCQ 2'b11;
    end else begin
      if (!llk_tx_dst_rdy_n && !llk_tlp_halt) begin
        block_cnt[0]     <= #`TCQ !llk_tx_eof_n && !llk_tx_src_rdy_n_int;
      end
      if (!llk_tx_dst_rdy_n && !llk_tlp_halt) begin
        block_cnt[2:1]   <= #`TCQ block_cnt[1:0];
      end
      if (eof_q3) begin
        block_fifo       <= #`TCQ 1'b1;
      end else if (block_cnt[1] && !llk_tx_dst_rdy_n && !llk_tlp_halt) begin 
        block_fifo       <= #`TCQ 1'b0;
      end
      if (!block_fifo && 
           (llk_tx_ch_tc != tc_q3 || llk_tx_ch_fifo != fifo_q3)) begin
        llk_tx_ch_tc     <= #`TCQ tc_q3;
        llk_tx_ch_fifo   <= #`TCQ fifo_q3;
        tc_fifo_change   <= #`TCQ 1'b1;
      end else begin
        tc_fifo_change   <= #`TCQ 1'b0;
      end
      llk_tx_ch_fifo_d   <= #`TCQ llk_tx_ch_fifo;
    end
  end
  //}}}

  //{{{ LLK TX SRC RDY Logic
  // Generate src_rdy to the PCIe block
  always @* begin
      llk_tx_src_rdy_n_int <= sof_gap_q3_and_block || !(vld_q3 && (only_eof || !trn_tsrc_rdy_n || vld_buf));
  end
  always @* begin
      llk_tx_src_rdy_n <= sof_gap_q3_and_block || llk_tlp_halt || !(vld_q3 && (only_eof || !trn_tsrc_rdy_n || vld_buf));
  end

  // only_eof indicates when the end of a packet is in the pipeline and
  // can be flushed. Flushing is allowed when no SOF follows the EOF.
  // NOTE: It would be a -very- good idea to make this the output of a
  //        register, to improve timing, if practical.
  assign   only_eof = eof_q1_or_eof_q2_only   ||   eof_q3_only;
  //}}}

  //{{{ Shift Pipe Logic
  // Shift pipeline when:
  // 1) Data is read out. This can only happen if:
  //    A) There is new data available to be shifted into the pipeline -or-
  //    B) There is an EOF at the beginning of the pipeline (*)
  // -or-
  // 2) There's an EOF at the beginning of the pipeline and the end of the
  //    pipeline doesn't contain valid data (*)
  // -or-
  // 3) New data is available to be written into the pipeline and the
  //    end of the pipeline doesn't contain valid data
  //
  // (*) NOTE - this is to ensure that a single packet (or the end of a
  //            packet) can make it all the way to the output even if there
  //            isn't new data "pushing" it through.
  //


  //{{{ Old shift pipe logic
  //synthesis translate_off
  // Keep this around for Assertion comparison

  wire shift_pipe_old = (!llk_tx_src_rdy_n_int && !llk_tx_dst_rdy_n && !llk_tlp_halt) ||
                        ((!trn_tsrc_rdy_n || vld_buf) && !vld_q3) ||
                        (!vld_q3 && (eof_q1   ||   (eof_q2 && !sof_q1)   ||   (eof_q3 && !sof_q2 && !sof_q1)));
  //synthesis translate_on
  //}}}



  wire   shift_pipe_input0 = (vld_buf || eof_q1 || eof_q2_only || eof_q3_only);

  LUT6 #(.INIT(64'b00100011_00100011_00100011_00100011_00100011_00100011_00100011_11111111)) 
  shift_pipe1                 (.O (shift_pipe),
                               .I5(llk_tx_dst_rdy_n),
                               .I4(llk_tlp_halt),
                               .I3(llk_tx_src_rdy_n_int),
                               .I2(trn_tsrc_rdy_n),
                               .I1(vld_q3),
                               .I0(shift_pipe_input0));


  always @(posedge clk) begin
    if (!rst_n) begin
      eof_q3_only           <= #`TCQ 0;
      eof_q2_only           <= #`TCQ 0;
      eof_q1_or_eof_q2_only <= #`TCQ 0;
    end else begin
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1  && trn_tsof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q3_only <= #`TCQ (eof_q3)           && !sof_q2  && trn_tsof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1  && !sof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q3_only <= #`TCQ (eof_q3)           && !sof_q2  && !sof_buf;
      else if (shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1;
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q2_only <= #`TCQ eof_q1 && trn_tsof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q2_only <= #`TCQ eof_q2 && trn_tsof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q2_only <= #`TCQ eof_q1 && !sof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q2_only <= #`TCQ eof_q2 && !sof_buf;
      else if (shift_pipe)
        eof_q2_only <= #`TCQ eof_q1;
      //eof_q2  <= #`TCQ eof_q1;
     
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q1 && trn_tsof_n) || !trn_teof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q2 && trn_tsof_n) || !trn_teof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q1 && !sof_buf) || eof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q2 && !sof_buf) || eof_buf;
      else if (shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ eof_q1;
      else
        eof_q1_or_eof_q2_only <= #`TCQ eof_q2_only || eof_q1;
    end
  end
  //}}}

  //{{{ LLK Output assignments
  // Outputs to the PCIe block are just polarity-fixed versions of the last
  // pipeline stage (except for TC/FIFO, which change at different times than
  // the data)
  assign llk_tx_data      = td_q3;
  assign llk_tx_enable_n  = {1'b0, !rem_q3};
  assign llk_tx_sof_n     = !(sof_q3);// || (!packet_in_progress && cd_credits_near_gte_far));
  assign llk_tx_eof_n     = !(eof_q3);// || (!packet_in_progress && cd_credits_near_gte_far));
  assign llk_tx_sop_n     = 1'b1; //not needed
  assign llk_tx_eop_n     = 1'b1; //not needed
  assign llk_tx_src_dsc_n = !(dsc_q3);// || (!packet_in_progress && cd_credits_near_gte_far));
  //}}}

  //{{{ Completion Fix and Datacredit Fix Logic
  always @(posedge clk) begin
    if (!rst_n) begin
      cpl_in_count <= #`TCQ 'b0;
      llk_tlp_halt <= #`TCQ 'b0;
    end else begin
      //Counts number of valid (not-discontinued) Completions put into the TRN interface
      cpl_in_count <= #`TCQ cpl_in_count + l0_stats_cfg_transmitted + 
                            (!llk_tx_sof_n && !llk_tx_src_rdy_n_int && !llk_tx_dst_rdy_n && !llk_tlp_halt &&
                            (llk_tx_data[61:57] == 5'b0_0101));
      //Halt the LLK interface if:
      // 1: There are 8 (or close to 8) CPLs buffered, and the next CPL is
      //    being presented, or is about to.
      //    --or --
      // 2: The number of data credits is about to run out, if the link
      //    parter advertised credits such that it is data-credit limited
      llk_tlp_halt <= #`TCQ 
          ((cpls_buffered >= TX_CPL_STALL_THRESHOLD) && fifo_q2[1] && (llk_tlp_halt || (sof_q2 && shift_pipe)))
                                                      ||
//          (TX_DATACREDIT_FIX_EN &&        
//           (({6'b000000,td_q2_credits} > cd_space_remaining_int)||cd_space_remaining_int_zero)
//                                                 &&   fifo_q2[1]   && (llk_tlp_halt || (sof_q2 && shift_pipe)))
//                                                      ||
          (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) && (
           (pd_credits_near_gte_far              && ~|fifo_q2[1:0] && (llk_tlp_halt || (sof_q2 && shift_pipe))) ||
           (npd_credits_near_gte_far             &&   fifo_q2[0]   && (llk_tlp_halt || (sof_q2 && shift_pipe)) && LEGACY_EP))
                            );

    end
  end

  //synthesis translate_off
  reg llk_tlp_halt_cpl8buf;
  reg llk_tlp_halt_cpldatacredit;
  reg llk_tlp_halt_pdatacredit;
  reg llk_tlp_halt_npdatacredit;

  always @(posedge clk) begin
    if (!rst_n) begin
      llk_tlp_halt_cpl8buf       <= #`TCQ 1'b0;
      llk_tlp_halt_cpldatacredit <= #`TCQ 1'b0;
      llk_tlp_halt_pdatacredit   <= #`TCQ 1'b0;
      llk_tlp_halt_npdatacredit  <= #`TCQ 1'b0;
    end else begin
      llk_tlp_halt_cpl8buf       <= #`TCQ ((cpls_buffered >= TX_CPL_STALL_THRESHOLD) && fifo_q2[1] &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe)));
      llk_tlp_halt_cpldatacredit <= #`TCQ (TX_DATACREDIT_FIX_EN && ({6'b0,td_q2_credits} > cd_space_remaining_int));
      llk_tlp_halt_pdatacredit   <= #`TCQ (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) && 
                                           (pd_credits_near_gte_far && ~|fifo_q2[1:0] &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe))));
      llk_tlp_halt_npdatacredit  <= #`TCQ (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) &&
                                           (npd_credits_near_gte_far &&  fifo_q2[0]   &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe)) && LEGACY_EP));
    end
  end
  //synthesis translate_on

  assign cpls_buffered   = cpl_in_count - tx_ch_credits_consumed[4:0];
  assign trn_tbuf_av_cpl = (cpls_buffered < (TX_CPL_STALL_THRESHOLD - 2)); 

  assign near_end_pd_credits_buffered  = (user_pd_data_credits_in  - tx_pd_credits_consumed);
  assign near_end_npd_credits_buffered = (user_npd_data_credits_in - tx_npd_credits_consumed);
  //This is an estimate of the number of Cpls buffered in the TLM's Tx buffer.
  //It makes a conservate estimate of Cfg Cpls.
  //#Cpls presented on TRN - # Cpls sent (subtract conservate estimate for internal Cfg Cpls)
  assign near_end_cd_credits_buffered  = (all_cd_data_credits_in  - tx_cd_credits_consumed);

  assign clear_cpl_count = llk_tx_chan_space_cpl_empty;

  assign packet_in_progress = packet_in_progress_reg || (sof_q3 && !llk_tx_src_rdy_n);

  always @(posedge clk) begin
    if (!rst_n) begin
       packet_in_progress_reg <= #`TCQ 0;
    end else if (sof_q3 && !llk_tx_src_rdy_n) begin
       packet_in_progress_reg <= #`TCQ 1;
    end else if (eof_q3 && !llk_tx_src_rdy_n) begin
       packet_in_progress_reg <= #`TCQ 0;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      user_pd_data_credits_in     <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      user_npd_data_credits_in    <= #`TCQ 'h1; //NPD is different; must account for itself only
      user_cd_data_credits_in     <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      all_cd_data_credits_in      <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      l0_stats_cfg_transmitted_cnt<= #`TCQ 0;
      near_end_cd_credits_buffered_11_d<= #`TCQ 0;
    end else begin
      near_end_cd_credits_buffered_11_d<= #`TCQ near_end_cd_credits_buffered[11];
      // POSTED FIX
      if (sofpd_q2_rose)
        user_pd_data_credits_in    <= #`TCQ user_pd_data_credits_in + td_q2_credits;
      // NON-POSTED FIX
      if (sofnpd_q2_rose)
        user_npd_data_credits_in   <= #`TCQ user_npd_data_credits_in + 1;
      // COMPLETION FIX
      if (sofcpl_q2_rose) begin
        user_cd_data_credits_in    <= #`TCQ user_cd_data_credits_in + td_q2_credits;
        user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1 <= #`TCQ user_cd_data_credits_in + td_q2_credits -
                                                              trn_pfc_cplh_cl_plus1;
      end
      //If Cpl queue goes empty, then near_end_cd_credits_buffered s/b 0 (or MARGIN). The
      //Cfg Cpl estimate (possibly high)  s/b adjusted to reflect the delta
      //between total consumed and user to return "near_end.." to MARGIN (trn_pfc_cplh_cl_plus1)
//      if (llk_tx_chan_space_cpl_empty || near_end_cd_credits_buffered[11])
      if (llk_tx_chan_space_cpl_empty || near_end_cd_credits_buffered_11_d)
        l0_stats_cfg_transmitted_cnt <= #`TCQ tx_cd_credits_consumed - user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1;
      else
        l0_stats_cfg_transmitted_cnt <= #`TCQ l0_stats_cfg_transmitted_cnt + l0_stats_cfg_transmitted;

      if (sofcpl_q2_rose)
        all_cd_data_credits_in     <= #`TCQ user_cd_data_credits_in + l0_stats_cfg_transmitted_cnt + td_q2_credits;
      else
        all_cd_data_credits_in     <= #`TCQ user_cd_data_credits_in + l0_stats_cfg_transmitted_cnt;
    end
  end


  always @(posedge clk) begin
    if (!rst_n) begin
      td_q2_credits_prev           <= #`TCQ 'h0;
      llk_tx_chan_space_cpl_empty  <= #`TCQ 1'b0;
      llk_cpl_second_cycle         <= #`TCQ 1'b0;
      q2_cpl_second_cycle          <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_upd_d1       <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_upd_d2       <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_plus1        <= #`TCQ 'd9; //default of 8 headers + 1
    end else begin
      if (sofcpl_q2_rose)
        td_q2_credits_prev           <= #`TCQ td_q2_credits[0];
      //llk_tx_chan_space_cpl_empty  <= #`TCQ (llk_tx_chan_space[7:0] == 8'hb1) && llk_cpl_second_cycle;
      llk_tx_chan_space_cpl_empty  <= #`TCQ (llk_tx_chan_space[7:0] == CHANSPACE_CPLEMPTY) && (llk_tx_ch_fifo==2'b10);
      llk_cpl_second_cycle         <= #`TCQ !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && llk_tx_ch_fifo[1];
      q2_cpl_second_cycle          <= #`TCQ sof_q2 && vld_q2 && shift_pipe && td_q2_cpl;
      trn_pfc_cplh_cl_upd_d1       <= #`TCQ trn_pfc_cplh_cl_upd;
      trn_pfc_cplh_cl_upd_d2       <= #`TCQ trn_pfc_cplh_cl_upd_d1;
      if (trn_pfc_cplh_cl_upd && !trn_pfc_cplh_cl_upd_d1)
        trn_pfc_cplh_cl_plus1        <= #`TCQ {1'b0,trn_pfc_cplh_cl} + 1;
    end
  end

  always @(posedge clk) begin
    //SOFq2___|A|_|B|_____ assume "A" is final good packet (first pkt to violate inequality)
    //EOFq2_____|A|_|B|___
    //userpd____(+A (+B
    //gte  _______|^^^^^^^
    //halt _________|^^^^^
    //SOFq3_____|A|_|B|___  
    //EOFq3_______|A|_|B|_  
    if (!pd_credit_limited)
      pd_credits_near_gte_far     <= #`TCQ 1'b0;
    else
      pd_credits_near_gte_far     <= #`TCQ (near_end_pd_credits_buffered  >= tx_pd_credits_available);
    if (!npd_credit_limited)
      npd_credits_near_gte_far    <= #`TCQ 1'b0;
    else
      npd_credits_near_gte_far    <= #`TCQ (near_end_npd_credits_buffered >  tx_npd_credits_available);

    //SOFq2___|A|_|B|_____ assume "A" is final good packet (does NOT to violate inequality)
    //EOFq2_____|A|_|B|___
    //usercd____(+A (+B
    //cdrema______(+A (+B
    //gte  _______|^^^^^^^
    //halt _________|^^^^^
    //SOFq3_____|A|_|B|___
    //EOFq3_______|A|_|B|_
  end

  always @(posedge clk) begin
    if (!cd_credit_limited) begin
      cd_space_remaining_int      <= #`TCQ 12'hFFF;
      cd_space_remaining_int_zero <= #`TCQ 1'b0;
//  else if (tx_cd_credits_available < near_end_cd_credits_buffered) //underflow protection
//    cd_space_remaining_int      <= #`TCQ 0;
    end else begin
      //tx_cd_credits_available is how many credits the link partner can
      // accept, and no more than that should exist in the Tx buffer (otherwise
      // data credit bug c/b triggered, and TLPs c/b sent). It is CPL DATA LIMIT-CONSUMED 
      cd_space_remaining_int      <= #`TCQ (tx_cd_credits_available  - near_end_cd_credits_buffered);
      cd_space_remaining_int_zero <= #`TCQ (tx_cd_credits_available <= near_end_cd_credits_buffered);
    end
  end

  //}}}

  //{{{ Debug
  //synthesis translate_off
 reg [11:0] llk_pd_credit_count;
 reg [11:0] llk_pd_credit_count_reg;

 reg [11:0] llk_npd_credit_count;
 reg [11:0] llk_npd_credit_count_reg;

 reg [11:0] llk_cpl_credit_count;
 reg [11:0] llk_cpl_credit_count_reg;

  always @(posedge clk) begin
     if (!rst_n)
        llk_pd_credit_count_reg <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
              ((llk_tx_data[62] && (llk_tx_data[60:56]==5'b00000)) || (llk_tx_data[62:59] == 4'b11_10)))
        if (llk_tx_data[41:32]==10'h0)
          llk_pd_credit_count_reg <= #`TCQ llk_pd_credit_count_reg + {1'b1,llk_tx_data[41:34]};
        else
          llk_pd_credit_count_reg <= #`TCQ llk_pd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
         ((llk_tx_data[62] && (llk_tx_data[60:56]==5'b00000)) || (llk_tx_data[62:59] == 4'b11_10)))
        if (llk_tx_data[41:32]==10'h0)
          llk_pd_credit_count = llk_pd_credit_count_reg + {1'b1,llk_tx_data[41:34]};
        else
          llk_pd_credit_count = llk_pd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
       llk_pd_credit_count = llk_pd_credit_count_reg;
  end


  always @(posedge clk) begin
     if (!rst_n)
        llk_npd_credit_count_reg <= #`TCQ 'h1;
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:56]==7'b100_0010))
        llk_npd_credit_count_reg <= #`TCQ llk_npd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:56]==7'b100_0010))
        llk_npd_credit_count = llk_npd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
        llk_npd_credit_count = llk_npd_credit_count_reg;
  end

  always @(posedge clk) begin
     if (!trn_pfc_cplh_cl_upd_d2)
        llk_cpl_credit_count_reg <= #`TCQ {3'b000, trn_pfc_cplh_cl_plus1};
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:57]==6'b100_101))
        llk_cpl_credit_count_reg <= #`TCQ llk_cpl_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:57]==6'b100_101))
        llk_cpl_credit_count = llk_cpl_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
        llk_cpl_credit_count = llk_cpl_credit_count_reg;
  end

  wire  [11:0] user_pd_data_credits_in_raw  = user_pd_data_credits_in  - TX_DATACREDIT_FIX_MARGIN;
  wire  [11:0] user_npd_data_credits_in_raw = user_npd_data_credits_in - 1;
  wire  [11:0] user_cd_data_credits_in_raw  = all_cd_data_credits_in  - TX_DATACREDIT_FIX_MARGIN;
  //synthesis translate_on
  //}}}

  //{{{ Assertions
  `ifdef SV
  //synthesis translate_off
     //During SOF, either LLK Tx is inactive, or active transmitting non-Cpl, or active
     // transmitting a Cpl and is below threshold
   ASSERT_LLK_TX_NOCPL_BEYOND_THRESHOLD: assert property (@(posedge clk)
       !llk_tx_sof_n && !llk_tx_src_rdy_n && llk_tx_ch_fifo[1] |->
              (cpls_buffered <= TX_CPL_STALL_THRESHOLD)  
                                                         ) else $fatal;
   ASSERT_SHIFT_PIPE_LUT_EQ_EQUATION:    assert property (@(posedge clk)
        rst_n  |-> (shift_pipe == shift_pipe_old)
                                                         ) else $fatal;
   ASSERT_EOFQ1Q2_REPLACEMENT:           assert property (@(posedge clk)
        rst_n  |-> (eof_q1_or_eof_q2_only == (eof_q1 || (eof_q2 && !sof_q1)))
                                                         ) else $fatal;
   ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF:  assert property (@(posedge clk)
        rst_n && llk_tlp_halt |-> !llk_tx_sof_n
                                                         ) else $fatal;
   ASSERT_LLK_PD_CREDITCNT_INCONSISTENT: assert property (@(posedge clk)
        rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n |-> (llk_pd_credit_count != user_pd_data_credits_in)
                                                         ) else $fatal;
   ASSERT_LLK_NPD_CREDITCNT_INCONSISTENT:assert property (@(posedge clk)
        rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n |-> (llk_npd_credit_count!= user_npd_data_credits_in)
                                                         ) else $fatal;
   //ASSERT_LLK_CPL_CREDITCNT_INCONSISTENT:assert property (@(posedge clk)
   //     rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n |-> (llk_cpl_credit_count!= user_cd_data_credits_in)
   //                                                      ) else $fatal;
  //synthesis translate_on
  `else
  //synthesis translate_off
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && llk_tx_ch_fifo[1] && (cpls_buffered > TX_CPL_STALL_THRESHOLD)) begin
        $display("ASSERT_LLK_TX_NOCPL_BEYOND_THRESHOLD");
        $finish;
     end
     always @(posedge clk) if (rst_n && (shift_pipe != shift_pipe_old)) begin
        $display("ASSERT_SHIFT_PIPE_LUT_EQ_EQUATION");
        $finish;
     end
     always @(posedge clk) if (rst_n && (eof_q1_or_eof_q2_only != (eof_q1 || (eof_q2 && !sof_q1)))) begin
        $display("ASSERT_EOFQ1Q2_REPLACEMENT");
        $finish;
     end
     always @(posedge clk) if (rst_n && llk_tlp_halt && llk_tx_sof_n) begin
        $display("ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF");
        $finish;
     end
     always @(posedge clk) if (rst_n && llk_tlp_halt && llk_tx_sof_n) begin
        $display("ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF");
        $finish;
     end
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
                               (llk_pd_credit_count != user_pd_data_credits_in)) begin
        $display("ASSERT_LLK_PD_CREDITCNT_INCONSISTENT");
        $finish;
     end
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
                               (llk_npd_credit_count != user_npd_data_credits_in)) begin
        $display("ASSERT_LLK_NPD_CREDITCNT_INCONSISTENT");
        $finish;
     end
     reg [9:0] initcnt = 0;
     always @(posedge clk) begin
       if (!rst_n)
         initcnt <= #`TCQ 0;
       else if (trn_pfc_cplh_cl_upd && !(&initcnt))
         initcnt <= #`TCQ initcnt + 1;
     end
     //Check that Posteds do not go over the limit by more than MPS
     always @(posedge clk) if (rst_n && pd_credit_limited &&  (near_end_pd_credits_buffered  > (tx_pd_credits_available + 512))) begin
        $display("ASSERT_TX_TOOMUCH_POSTEDDATA_OUTSTANDING");
        $finish;
     end
     always @(posedge clk) if (rst_n && npd_credit_limited && (near_end_npd_credits_buffered  > (tx_npd_credits_available + 1))) begin
        $display("ASSERT_TX_TOOMUCH_NONPOSTEDDATA_OUTSTANDING");
        $finish;
     end
  //synthesis translate_on
  `endif
  //}}}


endmodule // pcie_blk_ll_tx
