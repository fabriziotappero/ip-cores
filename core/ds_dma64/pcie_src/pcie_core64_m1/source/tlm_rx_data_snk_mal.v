
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
// File       : tlm_rx_data_snk_mal.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/****************************************************************************
 *  Description : Rx Data Sink malformed packet detection
 *
 *     Hierarchical :
 *
 *     Functional :
 *      Takes incoming packets, examines the packet for correct
 *        construction and drops if it malformed.
 *
 ***************************************************************************/
`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef PCIE
 `ifndef AS
  `define PCIE
 `endif
`endif

module tlm_rx_data_snk_mal #(parameter DW = 32,
                             parameter FCW = 6,
                             parameter LENW = 10,
                             `ifdef PCIE
                             parameter DOWNSTREAM_PORT = 0,
                             `else // `ifdef AS
                             parameter OVC = 0,
                             parameter MVC = 0,
                             `endif
                             parameter MPS = 512,
                             parameter TYPE1_UR = 0)
  (
   input                 clk_i,
   input                 reset_i,

   // credit output
   output reg [FCW-1:0]  data_credits_o,    // data credits for the packet
   output                data_credits_vld_o,// data credits valid

   // packet steering
   output reg            cfg_o,             // Packet is config
   `ifdef AS
   input                 oo_i,              // Packet is OVC-bound
   input                 ts_i,              // Packet is Bypassable in BVC
   `endif

   // errors
   `ifdef PCIE
   output reg            malformed_o,       // packet is badly constructed
   output reg            tlp_ur_o,          // unsupported request
   output reg            tlp_ur_lock_o,     // unsupported request due to MemRdLk
   output reg            tlp_uc_o,          // unexpected completion
   output reg            tlp_filt_o,        // filter this packet - not an
                                            //  error, but handled @same time
   `else // `ifdef AS
   output reg            bad_header_crc_o,
   output reg            bad_pi_chain_o,
   output reg            bad_credit_length_o,
   output reg            invalid_credit_length_o,
   output reg            non_zero_turn_pointer_o,
   output reg            unsup_mvc_o,
   output reg            unsup_ovc_o,
   `endif

   // For user/config steering
   input [3:0]           aperture_i,        // Config address ext. reg. number
   input                 load_aperture_i,

   `ifdef PCIE
   // for format calculations
   input                 eval_fulltype_i,   // Latch fulltype_i
   input [6:0]           fulltype_i,        // Type valid on eval_fulltype_i
   input                 eval_msgcode_i,    // Latch msgcode_i
   input [7:0]           msgcode_i,         // Msg code valid on eval_msgcode_i
   input                 tc0_i,             // Are we traffic class 0?

   // for UC/UR determination
   input                 hit_src_rdy_i,     // are the results ready
   input                 hit_ack_i,         // did we request a check?
   input                 hit_lock_i,        // was it for a locked Memrd?
   input                 hit_i,             // is this our address?
   input                 hit_lat3_i,        // is the hit latency 3 clocks?
   input                 pwr_mgmt_on_i,     // are we in power mgmt mode?
   input                 legacy_mode_i,     // core is in legacy mode

   // For user/config steering
   input                 legacy_cfg_access_i,//user implements legacy config
   input                 ext_cfg_access_i,  // user implements extended config
   input [7:0]           offset_i,          // Config address offset

   // for (potential) packet drop
   output reg            hp_msg_detect_o,   // obsolete hot-plug msg detected
   `else // `ifdef AS
   // for PI calculations
   input [6:0]           pi_1st_i,
   input [6:0]           pi_2nd_i,
   input [6:0]           pi_3rd_i,
   input [6:0]           pi_4th_i,

   input                 load_pi_1st_i,
   input                 load_pi_2nd_i,
   input                 load_pi_3rd_i,
   input                 load_pi_4th_i,

   // for format calculations
   input [6:0]           hcrc_i,            // Header CRC
   input [50:0]          route_header_i,    // Route header covered by HCRC
   input [4:0]           turn_pointer_i,    // Pointer into the Turn Pool
   input                 dir_i,             // Direction (1 = back-route)
   input                 switch_mode_i,     // Are we in a Switch?

   // For user/config steering
   input [31:0]          offset_i,          // Config address offset
   input                 load_offset_i,

   input                 fabric_manager_mode_i, // Is core a Fabric Manager?
   input [31:0]          cmm_ap0_space_end_i,   // End of Aperture 0 range
   input [31:0]          cmm_ap1_space_start_i, // Start of Aperture 1 range
   input [31:0]          cmm_ap1_space_end_i,   // End of Aperture 1 range

   // for packet drop
   input [1:0]           lnk_state_i,      // link state
   input                 lnk_state_src_rdy_i,   // link state write enable
   output                filter_drop_o,
   `endif

   // for length calculations
   input                 eval_formats_i,    // latch the formatting check
   input [9:0]           length_i,          // supposed length of the packet
   `ifdef PCIE
   input                 length_1dw_i,      // true if length_i == 1
   `endif
   input                 sof_i,             // beginning of header
   input                 eof_i,             // end of packet
   `ifdef PCIE
   input                 rem_i,             // rem at eof
   input                 td_i,              // packet has digest
   input [2:0]           max_payload_i      // as cfg'd by the cmm
   `else // `ifdef AS
   input [3:0]           max_payload_i      // as cfg'd by the cmm
   `endif
   );

  `ifdef PCIE
  //---------------------------------------------------------------------------
  // PCI Express constants
  //---------------------------------------------------------------------------
  // Full Type
  localparam             MRD32   = 7'b00_00000;
  localparam             MRD64   = 7'b01_00000;
  localparam             MRD32LK = 7'b00_00001;
  localparam             MRD64LK = 7'b01_00001;
  localparam             MWR32   = 7'b10_00000;
  localparam             MWR64   = 7'b11_00000;
  localparam             IORD    = 7'b00_00010;
  localparam             IOWR    = 7'b10_00010;
  localparam             CFGRD0  = 7'b00_00100;
  localparam             CFGWR0  = 7'b10_00100;
  localparam             CFGRD1  = 7'b00_00101;
  localparam             CFGWR1  = 7'b10_00101;
  localparam             CFGANY  = 7'bx0_0010x;
  localparam             CFGANY0 = 7'bx0_00100;
  localparam             CFGANY1 = 7'bx0_00101;
  localparam             MSG     = 7'b01_10xxx;
  localparam             MSGD    = 7'b11_10xxx;
  localparam             CPL     = 7'b00_01010;
  localparam             CPLD    = 7'b10_01010;
  localparam             CPLLK   = 7'b00_01011;
  localparam             CPLDLK  = 7'b10_01011;

  // Message code
  localparam             UNLOCK                    = 8'b0000_0000;
  localparam             PM_ACTIVE_STATE_NAK       = 8'b0001_0100;
  localparam             PM_PME                    = 8'b0001_1000;
  localparam             PME_TURN_OFF              = 8'b0001_1001;
  localparam             PME_TO_ACK                = 8'b0001_1011;
  localparam             ATTENTION_INDICATOR_OFF   = 8'b0100_0000;
  localparam             ATTENTION_INDICATOR_ON    = 8'b0100_0001;
  localparam             ATTENTION_INDICATOR_BLINK = 8'b0100_0011;
  localparam             POWER_INDICATOR_ON        = 8'b0100_0101;
  localparam             POWER_INDICATOR_BLINK     = 8'b0100_0111;
  localparam             POWER_INDICATOR_OFF       = 8'b0100_0100;
  localparam             ATTENTION_BUTTON_PRESSED  = 8'b0100_1000;
  localparam             SET_SLOT_POWER_LIMIT      = 8'b0101_0000;
  localparam             ASSERT_INTA               = 8'b0010_0000;
  localparam             ASSERT_INTB               = 8'b0010_0001;
  localparam             ASSERT_INTC               = 8'b0010_0010;
  localparam             ASSERT_INTD               = 8'b0010_0011;
  localparam             DEASSERT_INTA             = 8'b0010_0100;
  localparam             DEASSERT_INTB             = 8'b0010_0101;
  localparam             DEASSERT_INTC             = 8'b0010_0110;
  localparam             DEASSERT_INTD             = 8'b0010_0111;
  localparam             ERR_COR                   = 8'b0011_0000;
  localparam             ERR_NONFATAL              = 8'b0011_0001;
  localparam             ERR_FATAL                 = 8'b0011_0011;
  localparam             VENDOR_DEFINED_TYPE_0     = 8'b0111_1110;
  localparam             VENDOR_DEFINED_TYPE_1     = 8'b0111_1111;

  // Route
  localparam             ROUTE_TO_RC = 3'b000;
  localparam             ROUTE_BY_AD = 3'b001;
  localparam             ROUTE_BY_ID = 3'b010;
  localparam             ROUTE_BROAD = 3'b011;
  localparam             ROUTE_LOCAL = 3'b100;
  localparam             ROUTE_GATHR = 3'b101;
  localparam             ROUTE_RSRV0 = 3'b110;
  localparam             ROUTE_RSRV1 = 3'b111;
  `endif // `ifdef PCIE

  //---------------------------------------------------------------------------
  // Other constants
  //---------------------------------------------------------------------------
  // Bus widths
  `ifdef PCIE
  localparam             DCW = FCW + ((DW == 64) ? 1 : 2);  // Data-count width
  localparam             PLW = (FCW == 9) ? 10 : (FCW + 2);
                         // Pertinent portion of the Length field
  `else // `ifdef AS
  localparam             DCW = FCW + ((DW == 64) ? 3 : 4);  // Data-count width
  localparam             PLW = (FCW == 6) ? 5 : FCW;
                         // Pertinent portion of the Credits Required field
  `endif

  // Port direction
  localparam UPSTREAM_PORT = !DOWNSTREAM_PORT;

  //---------------------------------------------------------------------------
  // Internal signals
  //---------------------------------------------------------------------------
  // delayed versions of signals
  reg                    eof_q1;
  `ifdef PCIE
  reg                    sof_q1, sof_q2, sof_q3, sof_q4;
  reg                    eof_q2, eof_q3;
  reg                    eval_formats_q, eval_formats_q2;
  wire                   eof_sync, bar_sync;
  reg                    load_aperture_q;
  `else // `ifdef AS
  reg                    load_offset_q;
  `endif

  // Length check
  reg [DCW-1:0]          word_ct;
  reg [DCW-1:0]          word_ct_d;
  reg                    malformed_maxsize;
  reg                    malformed_over;
  `ifdef AS
  reg                    malformed_byp_not_1;
  reg                    malformed_pi4_or_5_not_1;
  `endif
  reg [LENW-1:0]         max_length;

  `ifdef PCIE
  reg [6:0]              fulltype_in;
  reg [7:0]              msgcode_in;

  wire                   has_data   = fulltype_in[6];
  wire                   header_4dw = fulltype_in[5];
  wire                   length_odd = length_i[0] && has_data;
  reg                    type_1dw;

  reg                    malformed_eof;
  reg                    malformed_rem;
  reg                    malformed_len;
  reg                    malformed_min;
  wire                   malformed_1dw;

  wire                   word_ct_zero;
  wire                   word_ct_neg1;
  wire                   expected_rem;

  reg                    delay_ct;
  reg                    delay_ct_d;
  `endif

  `ifdef PCIE
  // URs and UCs
  reg                    malformed_fulltype;
  reg                    malformed_tc;
  reg                    malformed_message;
  reg                    malformed_fmt;

  reg                    ismsg, ismsgd, ismsgany;
  reg                    fulltype_tc0;
  wire                   msgcode_tc0;
  reg                    msgcode_legacy;
  reg                    msgcode_hotplug;
  reg                    msgcode_sigdef;
  reg                    msgcode_vendef;
  reg                    msgcode_dmatch;
  reg [2:0]              msgcode_routing;

  wire [2:0]             routing    = fulltype_i[2:0];
  wire [2:0]             routing_in = fulltype_in[2:0];
  reg                    routing_vendef;
  reg                    cpl_ip;
  reg                    filter_msgcode;
  reg                    filter_msgcode_q;
  reg                    ur_pwr_mgmt, uc_pwr_mgmt;
  reg                    ur_type1_cfg = 0;
  reg                    ur_mem_lk, uc_cpl_lk;
  reg                    ur_format, uc_format;
  reg                    ur_format_lock;

  // Packet steering
  reg                    cfg0_ip, cfg1_ip;
  reg                    is_usr_leg_ap, is_usr_ext_ap;
  `else // `ifdef AS
  // PI chain
  reg  [7:0]             pi_1st;
  reg  [7:0]             pi_2nd;
  reg  [7:0]             pi_3rd;
  reg  [7:0]             pi_4th;

  wire                   load_pi_1st;
  wire                   load_pi_2nd;
  wire                   load_pi_3rd;
  wire                   load_pi_4th;

  reg                    pi_1st_vld;
  reg                    pi_2nd_vld;
  reg                    pi_3rd_vld;
  reg                    pi_4th_vld;

  reg                    pi_2nd_seq_vld;
  reg                    pi_3rd_seq_vld;
  reg                    pi_4th_seq_vld;

  reg                    primary_pi0;
  reg                    primary_pi4;
  reg                    primary_pi5;

  // Config-packet detection
  reg                    pi4_ap0;
  reg                    pi4_ap1;
  reg                    in_ap0_range;
  reg                    in_ap1_range;
  reg                    secondary_pi0;

  // Link state and packet drop
  reg  [1:0]             lnk_state_d;
  reg  [1:0]             lnk_state;
  reg                    packet_ip;
  reg                    packet_keep;

  // Header CRC
  wire [6:0]             header_crc_d;
  wire [6:0]             header_crc_pb_d;
  reg  [6:0]             header_crc;
  reg  [6:0]             header_crc_pb;
  reg                    path_build;
  `endif

  `ifdef PCIE
  // Synchronize checks with BAR-hit latency

  assign eof_sync = hit_lat3_i ? eof_q3 : eof_q2;
  assign bar_sync = hit_lat3_i ? eval_formats_q2 : eval_formats_q;
  `endif

  `ifdef PCIE
  // Calculate data credits from Length field
  //====================================================================
  // If the Length field is not correct, we'll signal Malformed for the
  // packet later, while freeing that same amount with unuse.
  //-------------------------------------------------------------------

  // Data credits are calculated on SOF q2 and provided to the top level
  // at SOF q4 for pipelining purposes.

  // 1 data credit = 4 dwords, round up partials
  always @(posedge clk_i) begin
    if (sof_q2) begin
      data_credits_o[PLW-3:0] <= #`TCQ has_data ?
                                       (length_i[PLW-1:2] + |length_i[1:0]): 0;
    end
  end

  generate
    if (FCW == 9) begin : max_data_credits
      always @(posedge clk_i) begin
        if (sof_q2) begin
          data_credits_o[FCW-1] <= #`TCQ ~|length_i && has_data;
        end
      end
    end
  endgenerate

  assign data_credits_vld_o = sof_q4;
  `else // `ifdef AS
  // Calculate data credits from actual length count
  //====================================================================

  localparam WPC  = 512/DW;      // Words/credit (64 bytes = 512 bits/credit)
  localparam WPCW = (DW == 64) ? 3 : 4;  // log2(WPC)

  // We pull off the upper portion of the word count to get the number
  // of credits. An illustration is how this works is given further
  // along.

  always @* data_credits_o     = word_ct[DCW-1:WPCW];
  assign    data_credits_vld_o = eof_q1;
  `endif

  // Malformed length checks
  //====================================================================

  //------------------------------------------------------------------------
  // Convert the incoming CMM max-payload signal to a max length.
  //------------------------------------------------------------------------

  // Optimize out any unsupported MPS settings. Note: 2176/4096 checked
  // differently.

  `ifdef PCIE
  localparam MAX_128  =                 32;             // 128B
  localparam MAX_256  = (MPS >= 256)  ? 64  : MAX_128;  // 256B
  localparam MAX_512  = (MPS >= 512)  ? 128 : MAX_256;  // 512B
  localparam MAX_1024 = (MPS >= 1024) ? 256 : MAX_512;  // 1024B
  localparam MAX_2048 = (MPS >= 2048) ? 512 : MAX_1024; // 2048B
  localparam MAX_4096 = (MPS >= 4096) ? 0   : MAX_2048; // 4096B*

  always @(posedge clk_i) begin
    if (reset_i) begin
      max_length            <= #`TCQ MAX_128;
    end else begin
      case (max_payload_i)
        3'b000:  max_length <= #`TCQ MAX_128;
        3'b001:  max_length <= #`TCQ MAX_256;
        3'b010:  max_length <= #`TCQ MAX_512;
        3'b011:  max_length <= #`TCQ MAX_1024;
        3'b100:  max_length <= #`TCQ MAX_2048;
        default: max_length <= #`TCQ MAX_4096;
      endcase
    end
  end
  `else // `ifdef AS
  localparam BVC = !OVC && !MVC;

  localparam MAX_64   =  !BVC                  ? 1 : 3;
  localparam MAX_96   = (!BVC && (MPS >= 96))  ? 2 : 3;
  localparam MAX_128  = (!BVC && (MPS >= 128)) ? 2 : 3;
  localparam MAX_192  =          (MPS >= 192)  ? 3 : MAX_128;
  localparam MAX_320  =          (MPS >= 320)  ? 5 : MAX_192;
  localparam MAX_576  =          (MPS >= 576)  ? 9 : MAX_320;
  localparam MAX_1088 =          (MPS >= 1088) ? 17: MAX_576;
  localparam MAX_2176 =          (MPS >= 2176) ? 0 : MAX_1088;

  // Max length is MPS, except for PI-0:0, PI-4, PI-5 and Bypassable
  // packets, whose max length is 1.

  always @(posedge clk_i) begin
    if (reset_i) begin
      max_length            <= #`TCQ MAX_192;
    end else begin
      casex (max_payload_i)
        4'b000x: max_length <= #`TCQ MAX_64;
        4'b0010: max_length <= #`TCQ MAX_96;
        4'b0011: max_length <= #`TCQ MAX_128;
        4'b0100: max_length <= #`TCQ MAX_192;
        4'b0101: max_length <= #`TCQ MAX_320;
        4'b0110: max_length <= #`TCQ MAX_576;
        4'b0111: max_length <= #`TCQ MAX_1088;
        default: max_length <= #`TCQ MAX_2176;
      endcase
    end
  end
  `endif

  //--------------------------------------------------------------------
  // This checks if the Length field is set too large for programmed
  // MPS. In PCIe, this only applies to packets with data; packets
  // without data can have length fields that exceed MPS (other length
  // requirements notwithstanding) since they don't have payloads.
  //--------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_maxsize <= #`TCQ 0;
    end else if (eval_formats_i) begin
      `ifdef PCIE
      // If programmed MPS is not 4096, Length must be non-zero
      if ((max_payload_i < 3'b101) || (MPS < 4096)) begin
        malformed_maxsize <= #`TCQ ((length_i > max_length) || ~|length_i) &&
                                    has_data;
      // If programmed MPS is 4096, any Length setting is legal
      end else begin
        malformed_maxsize <= #`TCQ 0;
      end
      `else // `ifdef AS
      // The Credits Required field must be 1 for Bypassable, PI-0:0,
      // PI-4 and PI-5.
      if ((!oo_i && ts_i) || (primary_pi0 && (pi_2nd_i == 0)) ||
          primary_pi4 || primary_pi5) begin
        malformed_maxsize <= #`TCQ (length_i != 1);
      // If programmed MPS is not 2176, Credits Required must be non-zero
      end else if ((max_payload_i < 4'b1000) || (MPS < 2176)) begin
        malformed_maxsize <= #`TCQ (length_i > max_length) || ~|length_i;
      // If programmed MPS is 2176, any Credits Required setting is legal
      end else begin
        malformed_maxsize <= #`TCQ 0;
      end
      `endif
    end
  end

  //--------------------------------------------------------------------
  // Payload count: DW count in 32-bit, QW count in 64-bit
  //--------------------------------------------------------------------

  `ifdef PCIE
  //--------------------------------------------------------------------
  // In PCIe, word_ct is loaded with the number of data beats following
  // assertion of eval_formats_q (on the 4th DW or 3rd QW), rem
  // notwithstanding. After eval_formats_i, word_ct decrements. This
  // causes word_ct to equal zero on the same clock cycle EOF is
  // expected.
  //--------------------------------------------------------------------

  // The load value of word_ct is one of the following:
  // * Outside of eval_formats_i: current value of word_ct. We want to
  //   decrement word_ct by 1; this will be done separately.
  // * If eval_formats_i is asserted, same as Length in 32-bit, or
  //   Length right-shifted by 1 in 64-bit. The count is later delayed
  //   based on header and TD.

  generate
    if (DW == 64) begin : word_ct_load_64
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[PLW-2:0] = word_ct[PLW-2:0];
        end else if (has_data) begin
          word_ct_d[PLW-2:0] = length_i[PLW-1:1];
        end else begin
          word_ct_d[PLW-2:0] = 0;
        end
      end
    end else begin : word_ct_load_32
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[PLW-1:0] = word_ct[PLW-1:0];
        end else if (has_data) begin
          word_ct_d[PLW-1:0] = length_i[PLW-1:0];
        end else begin
          word_ct_d[PLW-1:0] = 0;
        end
      end
    end
  endgenerate

  // If the data-count width supports 4096 bytes, we need to take care
  // of the all-zero case.

  generate
    if (FCW == 9) begin : word_ct_max_load
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[DCW-1] = word_ct[DCW-1];
        end else begin
          word_ct_d[DCW-1] = ~|length_i && has_data;
        end
      end
    end
  endgenerate

  // Load or increment word_ct, using a mux-before-add strategy. This
  // saves us a level of logic over add-before-mux.

  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct   <= #`TCQ 0;
    end else if (!delay_ct && !delay_ct_d) begin
      word_ct   <= #`TCQ word_ct_d - 1;
    end
  end
  `else // `ifdef AS
  //--------------------------------------------------------------------
  // In AS, word_ct is loaded upon sof_i with the number of data beats
  // per credit (16 in 32-bit, 8 in 64-bit). Unlike PCIe, word_ct counts
  // upward because the upper bits double as the data-credit quantity.
  // As such, the count is valid on the clock cycle after eof_i, as can
  // be seen in these 64-bit examples:
  //
  // 64 bytes => 8 words = 1 credit
  //   clock 1:  sof_i          => load counter
  //   clock 2:                 => length = 8
  //   clock 3:                 => length = 9
  //   clock 4:                 => length = 10
  //   clock 5:                 => length = 11
  //   clock 6:                 => length = 12
  //   clock 7:                 => length = 13
  //   clock 8:  eof_i          => length = 14
  //   clock 9:  eof_q1         => length = 15 -> 01111b -> [01]111b -> 1 cred.
  // 72 bytes => 9 words = 2 credits
  //   clock 1:  sof_i          => load counter
  //   clock 2:                 => length = 8
  //   clock 3:                 => length = 9
  //   clock 4:                 => length = 10
  //   clock 5:                 => length = 11
  //   clock 6:                 => length = 12
  //   clock 7:                 => length = 13
  //   clock 8:                 => length = 14
  //   clock 9:  eof_i          => length = 15
  //   clock 10: eof_q1         => length = 16 -> 10000b -> [10]000b -> 2 cred.
  //
  // Note in the second case that if the
  //
  // To account for built-in incrementer in word_ct, we load
  // with the desired value minus one.
  //-----------------------------------------------------------

  always @* begin
    if (sof_i) begin
      word_ct_d = WPC - 1;
    end else begin
      word_ct_d = word_ct;
    end
  end

  // Load or increment word_ct, using a mux-before-add strategy. This
  // saves us a level of logic over add-before-mux.

  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct   <= #`TCQ 0;
    end else begin
      word_ct   <= #`TCQ word_ct_d + 1;
    end
  end
  `endif

  `ifdef PCIE
  // Delay the start of the word count based on header, TD and length
  // (in 64-bit, even or odd). Delaying the start of the counter rather
  // than adjusting the start value saves muxing logic into the word_ct
  // arithmetic.

  always @(posedge clk_i) begin
    if (reset_i) begin
      delay_ct   <= #`TCQ 0;
      delay_ct_d <= #`TCQ 0;
    end else if (!eval_formats_i) begin
      delay_ct   <= #`TCQ delay_ct_d;
      delay_ct_d <= #`TCQ 0;
    end else if (DW == 64) begin
      // In the 64-bit world, we want to count the number of data beats
      // following the 3rd QW. It's easiest to enumerate the possible
      // scenarios:
      //
      // 1. 3 DW header, no digest, even Length: The end of the packet
      //    would be aligned if not for the 3 DW header. Thus the EOF
      //    ends up at the same place as with a 4 DW, no-digest packet.
      //    Beats after 3rd QW: Length/2 + 2 - 3 = Length/2 - 1.
      // 2. 3 DW header, no digest, odd Length: The odd DW at the end
      //    fills out the last beat in case #1: floor(Length/2) - 1.
      // 3. 3 DW header, digest, even Length: Fills out the unaligned
      //    end of case #1: Length/2 - 1.
      // 4. 3 DW header, digest, odd Length: Adds an unaligned beat to
      //    case #2: floor(Length/2).
      // 5. 4 DW header, no digest, even Length: Additional header DW
      //    fills out the unaligned end of case #1: Length/2 - 1.
      // 6. 4 DW header, no digest, odd Length: Adds an unaligned beat
      //    to case #2: floor(Length/2).
      // 7. 4 DW header, digest, even Length: Adds an unaligned beat to
      //    case #3: Length/2.
      // 8. 4 DW header, digest, odd Length: Fills out the unaligned end
      //    of case #4: floor(Length/2).
      //
      // The decrementer in word_ct causes the load value to be
      // word_ct_d - 1 = (length_i >> 1) - 1 = floor(Length/2) - 1. We
      // distill these out to get the delay needed from the start of
      // the count:
      //
      // Case #1: (Length/2 - 1) - (floor(Length/2) - 1)  = 0 delay
      // ...
      // Case #4: floor(Length/2) - (floor(Length/2) - 1) = 1 delay
      // ...

      case ({header_4dw,td_i,length_odd})
        3'b000:  delay_ct <= #`TCQ 0;
        3'b001:  delay_ct <= #`TCQ 0;
        3'b010:  delay_ct <= #`TCQ 0;
        3'b011:  delay_ct <= #`TCQ 1;
        3'b100:  delay_ct <= #`TCQ 0;
        3'b101:  delay_ct <= #`TCQ 1;
        3'b110:  delay_ct <= #`TCQ 1;
        default: delay_ct <= #`TCQ 1;
      endcase

      delay_ct_d <= #`TCQ 0;    // Only used in 32-bit, where two cycles
                                // of delay may be necessary
    end else begin
      // In the 32-bit world, the number of data beats following the 4th
      // DW is equal to Length + Hdr_DW + TD - 4. The adjustment from
      // word_ct_d is thus Hdr_DW + TD - 4. Note that (Hdr_DW - 3) is
      // the same as header_4dw, so the delay is simply the sum of
      // header_4dw + td_i - 1, PLUS ONE to account for the built-in
      // word_ct decrementer.

      case ({header_4dw,td_i})
        2'b11:   {delay_ct_d,delay_ct} <= #`TCQ 2'b10;  // Two-cycle delay
        2'b00:   {delay_ct_d,delay_ct} <= #`TCQ 2'b00;  // Zero-cycle delay
        default: {delay_ct_d,delay_ct} <= #`TCQ 2'b01;  // One-cycle delay
      endcase
    end
  end

  // Flag a word count of zero. There are two ways to represent zero
  // word count:
  //
  // 1. If word_ct = 0 with no count delay (delay_ct = 0).
  // 2. If word_ct = -1 with count delay (delay_ct = 1). Count delay
  //    represents a +1 adjustment to word_ct, so these two conditions
  //    indicate that the true word count is zero. (See the delay_ct
  //    comments below for more information.) This scenario occurs in
  //    64-bit when we have a packet of 1 DW payload that ends on the
  //    3rd QW: 3 DW header + TD, or 4 DW header w/o TD. (This case is
  //    not covered by malformed_min, which only covers EOF on the 1st
  //    or 2nd QW.)
  //
  // This logic also takes care of the case in 32-bit when Length = 1
  // (causing word_ct = 0) but delay_ct/d is asserted due to a 4 DW
  // header or a TLP Digest. In this case, true word count is non-zero
  // even though word_ct = 0, because of the count delay.
  //
  // The lowest possible start value for word_ct is -1 (derived from a
  // payload length of 0 [or 1 in 64-bit]). This means that the true
  // word count will never be zero if delay_ct_d is asserted, because
  // this represents a two-cycle delay.

  assign word_ct_zero = (delay_ct ? &word_ct : ~|word_ct) && !delay_ct_d;

  // Flag a word count of -1. This occurs when word_ct = -1 with no
  // count delay. Needed to detect rollover.

  assign word_ct_neg1 = &word_ct && !delay_ct && !delay_ct_d;
reg [4:0] test_temp;
  //------------------------------------------------------------------------
  // Check length of short packets (1-4 DW in 32-bit, 1-2 DW in 64-bit).
  // Longer packets are checked against word_ct.
  //------------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_min     <= #`TCQ 0;
    end else begin
      if (DW == 64) begin
        // 2 words or less
        if (sof_i && eof_i) begin
          malformed_min <= #`TCQ 1;

        // Header fields too small check (3 or 4 words)
        // header words + digest <= 3 + rem
        end else if (sof_q1 && eof_i) begin
          casex ({header_4dw, rem_i, td_i, has_data, length_1dw_i})
            // No-data checks
            // 3 DW header, 3 DW packet.. but digest is set!
            5'b0010x:  malformed_min  <= #`TCQ 1;
            // 4 DW header, 3 DW packet (w/wo digest)
            5'b10x0x:  malformed_min  <= #`TCQ 1;
            // 4 DW header, 4 DW packet.. but digest is set!
            5'b1110x:  malformed_min  <= #`TCQ 1;
            // Has-data checks
            // 3 DW header, supposed to have data but doesn't
            5'b00x1x:  malformed_min  <= #`TCQ 1;
            // 3 DW header, only 1 DW of data, but should have more
            5'b0xx10:  malformed_min  <= #`TCQ 1;
            // 3 DW header w/TD, supposed to have data but doesn't
            5'b0x11x:  malformed_min  <= #`TCQ 1;
            // 4 DW header, supposed to have data but doesn't
            5'b1xx1x:  malformed_min  <= #`TCQ 1;
            // header-only (or header + 1DW data) packet is
            // correctly constructed
            default: malformed_min  <= #`TCQ 0;
          endcase

        // There was data.. we'll catch these cases with the
        // word counter
        end else begin
          malformed_min <= #`TCQ 0;
        end

      // 32 bit checks
      end else begin
        // 1 or 2 dwords
        if ((sof_i || sof_q1) && eof_i) begin
          malformed_min <= #`TCQ 1;
        // 3 dword pkt, but w/ digest or data or 4 dw header
        end else if (sof_q2 && eof_i && (td_i || header_4dw || has_data)) begin
          malformed_min <= #`TCQ 1;
        // 4 word pkt && header, but with digest
        end else if (sof_q3 && eof_i && td_i && header_4dw) begin
          malformed_min <= #`TCQ 1;
        // we must be long enough
        end else begin
          malformed_min <= #`TCQ 0;
        end
      end
    end
  end

  //=====================================================================
  // Malformed TLP: incorrect length (valid at eof_o)
  // * length field != 0 while the TLP has no data
  // * length field doesn't match number of data dwords
  // * length field is not hardwired correctly (1 DW only for I/O & Cfg)
  //=====================================================================

  //--------------------------------------------------------------------
  // This checks Config and I/O packets to make sure the Length field is
  // set to 1.
  //--------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (reset_i) begin
      type_1dw      <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CFGRD0, CFGWR0, CFGRD1, CFGWR1, IORD, IOWR:
          type_1dw  <= #`TCQ 1;
        default:
          type_1dw  <= #`TCQ 0;
      endcase
    end
  end

  assign malformed_1dw = type_1dw && !length_1dw_i;

  // Determine if the length of the packet is correct. Interpreted on
  // every clock, but only latched on eof_q1.
  //----------------------------------------------------------

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_eof <= #`TCQ 0;
    end else begin
      malformed_eof <= #`TCQ !eval_formats_i && !word_ct_zero;
    end
  end
  `endif

  `ifdef PCIE
  // Flag when the counter rolls over. This covers the case in 32-bit
  // where a start value of -1 is loaded into word_ct on the 4th DW.
  // A -1 on the 4th DW means EOF should've been asserted on the 3rd DW;
  // but because word_ct cannot be valid on the 3rd DW, we can't flag a
  // zero count on that data beat. So we must flag when the count has
  // been allowed to load with a rollover value on or before EOF, so
  // that eof_q1 will detect the overflow condition.
  //
  // The rollover flag also ensures that the TLM doesn't mark as legal a
  // packet that overshoots Length by exactly MPS*2 (which would cause
  // the word counter to go down to zero a SECOND time).

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_over   <= #`TCQ 0;
    end else begin
      malformed_over   <= #`TCQ (word_ct_neg1 || malformed_over) &&
                                !eval_formats_i;
    end
  end

  // Determine if REM is set incorrectly. Only matters on EOF.
  //----------------------------------------------------------

  // The expected REM is determined by payload length (even vs. odd),
  // header size and and presence of the digest. The formula is:
  //
  //    exp_rem = (!header_4dw + length_i[0] + td_i) % 2 == 0 -OR-
  //    exp_rem =  (header_4dw + length_i[0] + td_i) % 2 == 1
  //
  // a.k.a. XOR. Length is qualified by has_data (embodied by the
  // length_odd signal) as it depends on the presence of the payload.

  assign expected_rem = header_4dw ^ length_odd ^ td_i;

  // The check for malformed REM is performed on each clock cycle but
  // only latched on the cycle after EOF.

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_rem <= #`TCQ 0;
    end else if (DW == 32) begin
      malformed_rem <= #`TCQ 0;
    end else begin
      malformed_rem <= #`TCQ rem_i ^ expected_rem;
    end
  end

  // All our counting is complete on eof_i- latch on q1
  // Our length is bad if the payload was bad, or if a header-only
  //    packet was too short
  //-------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_len <= #`TCQ 0;
    end else if (eof_q1) begin
      malformed_len <= #`TCQ malformed_eof || malformed_over ||
                             malformed_rem || malformed_min;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_o <= #`TCQ 0;
    end else if (eof_sync) begin
      malformed_o <= #`TCQ malformed_len || malformed_fmt;
    end
  end
  `else // `ifdef AS
  // Flag when the counter exceeds Credits Required. We trigger when
  // word_ct equals the maximum allowed for Credits Required. An
  // adjustment must be made for MPS = 96, since this represents an
  // overflow on a half-credit. Note that this is the only case where
  // we check the RUNNING word count against MPS. The malformed_maxsize
  // logic covers all other cases where the actual Credits Required
  // field exceeds MPS.
  //
  // We must adjust the incoming CR upwards for the all-zeroes case.

  reg  [WPCW-1:0] word_ct_lo_limit;
  reg  [FCW-1:0]  word_ct_hi_limit;
  wire [DCW-1:0]  word_ct_limit;
  reg  [FCW-1:0]  true_length;

  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct_lo_limit <= #`TCQ 0;
    end else if ((max_payload_i == 4'b0010) && !BVC && (MPS >= 96) &&
                 (length_i == 2)) begin
      word_ct_lo_limit <= #`TCQ WPC/2;
    end else begin
      word_ct_lo_limit <= #`TCQ 0;
    end
  end

  generate
    if (FCW == 6) begin : word_ct_limit_2176
      always @* begin
        if (~|length_i) begin   // All zeroes
          true_length = 34;
        end else begin
          true_length = {1'b0,length_i};
        end
      end
    end else begin : word_ct_limit_below_2176
      always @* true_length = length_i[FCW-1:0];
    end
  endgenerate

  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct_hi_limit <= #`TCQ 1;
    end else begin
      word_ct_hi_limit <= #`TCQ true_length + 1;
    end
  end

  assign word_ct_limit = {word_ct_hi_limit,word_ct_lo_limit};

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_over <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_over <= #`TCQ 0;
    end else begin
      malformed_over <= #`TCQ (word_ct == word_ct_limit) || malformed_over;
    end
  end

  // Flag if Credits Required is not 1 for a bypassable, PI-4 or PI-5
  // packet.

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_byp_not_1 <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_byp_not_1 <= #`TCQ BVC && !oo_i && ts_i && (length_i != 1);
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_pi4_or_5_not_1 <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_pi4_or_5_not_1 <= #`TCQ (primary_pi4 || primary_pi5) &&
                                        (length_i != 1);
    end
  end

  // All our counting is complete on eof_i; latch on eof_q1.
  //-------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_credit_length_o <= #`TCQ 0;
    end else if (eof_q1) begin
      bad_credit_length_o <= #`TCQ malformed_over;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      invalid_credit_length_o <= #`TCQ 0;
    end else if (eof_q1) begin
      invalid_credit_length_o <= #`TCQ malformed_maxsize ||
                                       malformed_byp_not_1 ||
                                       malformed_pi4_or_5_not_1;
    end
  end
  `endif

  `ifdef PCIE
  //====================================================================
  // Malformed format checks
  //====================================================================

  // delay this one cycle more than is strictly necessary- otherwise
  //   we might collide with another bad back-to-back packet
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_fmt <= #`TCQ 0;

    // All type checks get triggered after we have latched
    //    the inputs. OR together the checks afterwards.
    // ismsg* needs to be added into malformed_message even
    //    though it is also included in some field checks
    //    because completely specifying it in the case statement
    //    absolutely kills timing
    end else if (bar_sync) begin
      malformed_fmt <= #`TCQ malformed_tc ||
                             malformed_fulltype ||
                            (malformed_message && ismsgany) ||
                             malformed_maxsize ||
                             malformed_1dw;
    end
  end

  //--------------------------------------------------------------------
  // Traffic class determinations
  //--------------------------------------------------------------------
  // Bad TC received if doesn't map to any enabled VC, meaning either:
  // * TC not mapped to any VC
  // * TC mapped to a VC not enabled ** FOR THIS VERSION ONLY 0 VALID!! **
  // * TC other than TC0 on received:
  //   * io and cfg
  //   * CplDLk and I guess CplLk (MRdLk is UR and Unlock is dropped)
  //   . Msg: power management (INT and errors are UR because routed to Root)
  //
  // Spec references on TC0 traffic restriction:
  // * "MRdLk, CplDLk and Unlock semantics are allowed only for (...) TC0"
  // * "all Assert_INTx and Deassert_INTx interrupts Requests must use TC0"
  // * "for legacy I/O, TC0 is used"
  // * "all power management system messages must use (...) TC0"
  // * "all Error Messages must use (...) TC0"
  // * "the Unlock Message must use (...) TC0"
  // * "MSIs are not restricted to TC0"
  // * cfg and io header shows a TC hardwired to 0
  //--------------------------------------------------------------------

  // Latch Type and Message code, should be removed as equivalent to
  // cur_fulltype and cur_msgcode on the upper level

  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      fulltype_in       <= #`TCQ fulltype_i;
    end
  end

  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      msgcode_in        <= #`TCQ msgcode_i;
    end
  end

  // Pre-calculate whether the Type is Msg or MsgD; ismsgany will be
  // removed during synthesis as equivalent to cur_fulltype_oh[MSG_BIT]
  // on the upper level.

  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      casex (fulltype_i)
        MSG: begin
          ismsg         <= #`TCQ 1;
          ismsgd        <= #`TCQ 0;
          ismsgany      <= #`TCQ 1;
        end
        MSGD: begin
          ismsg         <= #`TCQ 0;
          ismsgd        <= #`TCQ 1;
          ismsgany      <= #`TCQ 1;
        end
        default: begin
          ismsg         <= #`TCQ 0;
          ismsgd        <= #`TCQ 0;
          ismsgany      <= #`TCQ 0;
        end
      endcase
    end
  end

  // Pre-calculate whether the full type requires TC0

  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      casex (fulltype_i)
        // These Types require TC == 0
        CFGANY, IORD, IOWR, CPLLK, CPLDLK,
        MRD32LK, MRD64LK: begin
          fulltype_tc0  <= #`TCQ 1;
        end
        default: begin
          fulltype_tc0  <= #`TCQ 0;
        end
      endcase
    end
  end

  // Pre-calculate whether the Message code requires TC0. All messages
  // other than Vendor_Defined_0/1 require TC0.

  assign msgcode_tc0 = msgcode_sigdef;

  // Check for Malformed TC

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_tc      <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!tc0_i) begin
        malformed_tc    <= #`TCQ fulltype_tc0 || (ismsgany && msgcode_tc0);
      end else begin
        // tc was 0, we must be good!
        malformed_tc    <= #`TCQ 0;
      end
    end
  end

  // Check if type is valid based on allowable full types
  //    (of spec, not what we actually support in our core)
  // Valid but unsupported types get turned into a UR/UC
  //-------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_fulltype        <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        MWR32, MWR64, MRD32, MRD64, MRD32LK, MRD64LK,
        CFGRD0, CFGWR0, CFGRD1, CFGWR1,
        CPL, CPLD, CPLLK, CPLDLK,
        MSG, MSGD, IORD, IOWR:
          malformed_fulltype    <= #`TCQ 0;
        default:
          malformed_fulltype    <= #`TCQ 1;
      endcase
    end
  end

  //====================================================================
  // UR/UC checks
  //====================================================================

  // Completions lead to Unexpected Completion, others lead to
  //    Unsupported Request
  //--------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      cpl_ip            <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CPL, CPLD, CPLLK, CPLDLK: begin
          cpl_ip        <= #`TCQ 1;
        end
        default: begin
          cpl_ip        <= #`TCQ 0;
        end
      endcase
    end
  end

  // Grab some fields that are special cases in our UC/UR
  //   determination
  // * We don't drop vendor messages on bar misses
  // * A locked mem access when not in legacy mode is unsupported
  // * A locked completion when not in legacy mode is unexpected
  // * We reject most types while in power management mode
  //-------------------------------------------------------------

  // We can receive the legacy UNLOCK message code if the user design is
  // a legacy device, or if this is a downstream port.

  wire allow_legacy = legacy_mode_i || DOWNSTREAM_PORT;

  always @(posedge clk_i) begin
    if (reset_i) begin
      ur_mem_lk           <= #`TCQ 0;
      uc_cpl_lk           <= #`TCQ 0;
      ur_pwr_mgmt         <= #`TCQ 0;
      uc_pwr_mgmt         <= #`TCQ 0;
      ur_type1_cfg        <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!allow_legacy) begin
        ur_mem_lk         <= #`TCQ (fulltype_in == MRD32LK) ||
                                   (fulltype_in == MRD64LK);
        uc_cpl_lk         <= #`TCQ (fulltype_in == CPLLK) ||
                                   (fulltype_in == CPLDLK);
      end else begin
        ur_mem_lk         <= #`TCQ 0;
        uc_cpl_lk         <= #`TCQ 0;
      end

      if (TYPE1_UR && (fulltype_in == CFGWR1 || fulltype_in == CFGRD1 ||
                       fulltype_in == CFGWR1)) begin
        // If TYPE1_UR is left as its default (0) all the ur_type1_cfg
        // logic should be optimized out
        ur_type1_cfg    <= #`TCQ 1'b1;
      end else begin
        ur_type1_cfg    <= #`TCQ 1'b0;
      end

      casex (fulltype_in)
        CPL, CPLD, CPLLK, CPLDLK: begin
          uc_pwr_mgmt     <= #`TCQ pwr_mgmt_on_i;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
        MRD32, MRD64, MRD32LK, MRD64LK, MWR32, MWR64, IORD, IOWR: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ pwr_mgmt_on_i;
        end
        CFGWR1, CFGRD1, CFGANY1: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
        default: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
     endcase
   end
  end

  // There are three components to a UR/UC...
  // 1. We're in power management mode, and this type is
  //    not supported during power management
  // 2. There is a bad field determination.. we grab this
  //    when the formats are ready, and if they are good, we
  //    reset the register back to zero
  // 3. Our bar hit/miss information is available at hit_src_rdy..
  //    if we were a miss set the field
  // Otherwise, use the previous value
  //-------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      ur_format        <= #`TCQ 0;
      ur_format_lock   <= #`TCQ 0;
      uc_format        <= #`TCQ 0;
      filter_msgcode_q <= #`TCQ 0;
    end else if (bar_sync) begin
      // 1. In power management -OR-
      // 2. Our packet has a message or type we don't support -OR-
      // 3. Our packet is a type-1 config access and it's not allowed

      // Unsupported Request
      ur_format        <= #`TCQ ur_pwr_mgmt || ur_mem_lk || ur_type1_cfg;
      ur_format_lock   <= #`TCQ ur_mem_lk; //needed by errman to generate CplLk

      // Unexpected completion
      uc_format        <= #`TCQ uc_pwr_mgmt || uc_cpl_lk;

      // Unpassed message (silently filtered in non-legacy mode)
      filter_msgcode_q <= #`TCQ filter_msgcode;
    end
  end

  // hits are ready, or & grab the format information
  always @(posedge clk_i) begin
    if (reset_i) begin
      tlp_ur_o            <= #`TCQ 0;
      tlp_ur_lock_o       <= #`TCQ 0;
      tlp_uc_o            <= #`TCQ 0;
      tlp_filt_o          <= #`TCQ 0;
    end else if (hit_src_rdy_i) begin
      if (ur_format) begin
        tlp_ur_o          <= #`TCQ 1;
        tlp_ur_lock_o     <= #`TCQ ur_format_lock;
      end else if (!cpl_ip && hit_ack_i && !hit_i && UPSTREAM_PORT) begin
        tlp_ur_o          <= #`TCQ 1;
        tlp_ur_lock_o     <= #`TCQ hit_lock_i;
      end else begin
        tlp_ur_o          <= #`TCQ 0;
        tlp_ur_lock_o     <= #`TCQ 0;
      end
      if (uc_format) begin
        tlp_uc_o          <= #`TCQ 1;
      end else if (cpl_ip && hit_ack_i && !hit_i && UPSTREAM_PORT) begin
        tlp_uc_o          <= #`TCQ 1;
      end else begin
        tlp_uc_o          <= #`TCQ 0;
      end
      if (filter_msgcode_q) begin
        tlp_filt_o        <= #`TCQ 1;
      end else begin
        tlp_filt_o        <= #`TCQ 0;
      end
    end
  end

  //---------------------------------------------------------------------
  // Check if the message is constructed properly according to the spec
  // * routing must be correct by spec
  // * routing must match our ability to route (endpoint/trunk)
  // * Msg/MsgD type must match message value
  //----------------------------------------------------------------------

  // Check for valid message code, other than Vendor_Defined. The message
  // code is valid if it is both:
  // * Defined in the spec
  // * Legal for the port direction

  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        UNLOCK, PME_TURN_OFF, PM_ACTIVE_STATE_NAK,
        SET_SLOT_POWER_LIMIT, ATTENTION_BUTTON_PRESSED,
        ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
        ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
        POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK:
          msgcode_sigdef <= #`TCQ UPSTREAM_PORT;

        ASSERT_INTA, DEASSERT_INTA, ASSERT_INTB, DEASSERT_INTB,
        ASSERT_INTC, DEASSERT_INTC, ASSERT_INTD, DEASSERT_INTD,
        ERR_COR, ERR_NONFATAL, ERR_FATAL, PME_TO_ACK:
          msgcode_sigdef <= #`TCQ DOWNSTREAM_PORT;

        default:
          msgcode_sigdef <= #`TCQ 0;
      endcase
    end
  end

  // Check for Msg vs. MsgD. In 64-bit, fulltype_i and msgcode_i are
  // available on the same clock cycle. In 32-bit, ismsg and ismsgd are
  // calculated before msgcode_i is available.

  generate
    if (DW == 32) begin : msgd_check_32

      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            SET_SLOT_POWER_LIMIT:
              msgcode_dmatch <= #`TCQ ismsgd;
            default:
              msgcode_dmatch <= #`TCQ ismsg;
          endcase
        end
      end

    end else begin : msgd_check_64

      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (fulltype_i)
            MSG:
              msgcode_dmatch <= #`TCQ (msgcode_i != SET_SLOT_POWER_LIMIT);
            default:
              msgcode_dmatch <= #`TCQ (msgcode_i == SET_SLOT_POWER_LIMIT);
          endcase
        end
      end

    end
  endgenerate

  // Check the type of routing required by the Message code. Most codes
  // only take one routing type, but Vendor_Defined can take three types
  // (four if received on a downstream port) so it needs a special
  // register.

  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      routing_vendef <= #`TCQ (routing == ROUTE_LOCAL) ||
                              (routing == ROUTE_BROAD) ||
                              (routing == ROUTE_BY_ID);
    end
  end

  // Create different casex blocks depending on whether
  // in downstream port mode or not. This is done so that when not in
  // downstream port mode, the interrupt-message checks will not be included.
  // Interrupts should not be received when in upstream mode so we
  // don't want to risk having their checks impact timing.

  generate
    if (DOWNSTREAM_PORT == 0) begin : dont_check_int
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            UNLOCK, PME_TURN_OFF:
              msgcode_routing <= #`TCQ ROUTE_BROAD;

            PME_TO_ACK:
              msgcode_routing <= #`TCQ ROUTE_GATHR;

            PM_ACTIVE_STATE_NAK, ATTENTION_BUTTON_PRESSED,
            ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
            ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
            POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK,
            SET_SLOT_POWER_LIMIT:
              msgcode_routing <= #`TCQ ROUTE_LOCAL;

            // Vendor_Defined can take other values besides Route to RC;
            // these are covered by routing_vendef.
            default:
              msgcode_routing <= #`TCQ ROUTE_TO_RC;
          endcase
        end
      end
    end else begin : check_int
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            UNLOCK, PME_TURN_OFF:
              msgcode_routing <= #`TCQ ROUTE_BROAD;

            PME_TO_ACK:
              msgcode_routing <= #`TCQ ROUTE_GATHR;

            PM_ACTIVE_STATE_NAK, ATTENTION_BUTTON_PRESSED,
            ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
            ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
            POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK,
            ASSERT_INTA, ASSERT_INTB, ASSERT_INTC, ASSERT_INTD,
            DEASSERT_INTA, DEASSERT_INTB, DEASSERT_INTC, DEASSERT_INTD,
            SET_SLOT_POWER_LIMIT:
              msgcode_routing <= #`TCQ ROUTE_LOCAL;

            // Vendor_Defined can take other values besides Route to RC;
            // these are covered by routing_vendef.
            default:
              msgcode_routing <= #`TCQ ROUTE_TO_RC;
          endcase
        end
      end
    end
  endgenerate

  // Make sure the Message parameters agree with each other:
  //
  // 1. Message code must be valid per spec
  // 2. Type (Msg or MsgD) must agree with the Message code
  // 3. If not Vendor_Defined, the Routing type must agree with the one
  //    allowed by the Message code
  // 4. If Vendor_Defined, the Routing type must be:
  //    a. Broadcast, Local or Route By ID (routing_vendef), or
  //    b. Route to Root Complex if a downstream port
  // NOTE: Vendor_Defined does not care about Msg vs. MsgD.

  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_message   <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!msgcode_vendef) begin
        malformed_message <= #`TCQ !msgcode_sigdef ||                     // #1
                                   !msgcode_dmatch ||                     // #2
                                   (routing_in != msgcode_routing);       // #3
      end else begin
        malformed_message <= #`TCQ !routing_vendef &&                     // #4
                                   !(DOWNSTREAM_PORT &&
                                     (routing_in == ROUTE_TO_RC));
      end
    end
  end

  //---------------------------------------------------------------------
  // Check if the message is supported by our core
  // * routing must match our ability to route (endpoint/trunk)
  //----------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        UNLOCK:
          msgcode_legacy        <= #`TCQ 1;
        default:
          msgcode_legacy        <= #`TCQ 0;
      endcase
    end
  end

  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        POWER_INDICATOR_ON, POWER_INDICATOR_OFF,
        POWER_INDICATOR_BLINK, ATTENTION_INDICATOR_ON,
        ATTENTION_INDICATOR_OFF, ATTENTION_INDICATOR_BLINK,
        ATTENTION_BUTTON_PRESSED:
          msgcode_hotplug       <= #`TCQ 1;
        default:
          msgcode_hotplug       <= #`TCQ 0;
      endcase
    end
  end

  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        VENDOR_DEFINED_TYPE_0, VENDOR_DEFINED_TYPE_1:
          msgcode_vendef        <= #`TCQ 1;
        default:
          msgcode_vendef        <= #`TCQ 0;
      endcase
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      filter_msgcode            <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (ismsgany) begin
        filter_msgcode          <= #`TCQ !allow_legacy && msgcode_legacy;
      end else begin    // not a Message
        filter_msgcode          <= #`TCQ 0;
      end
    end
  end

  //====================================================================
  // Steer packets to the CMM.

  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg0_ip <= #`TCQ 0;
      cfg1_ip <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CFGANY0: cfg0_ip <= #`TCQ 1;
        default: cfg0_ip <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        CFGANY1: cfg1_ip <= #`TCQ 1;
        default: cfg1_ip <= #`TCQ 0;
      endcase
    end
  end

  // The user gets a Type 0 packet if:
  //
  // 1. The packet's address range is between 192 and 255 inclusive, and
  //    the user implements legacy config space, or
  // 2. The packet's address range is at or above 1024 (4*256) and the
  //    user implements extended config space.

  always @(posedge clk_i) begin
    if (reset_i) begin
      is_usr_leg_ap <= #`TCQ 0;
    end else if (load_aperture_i) begin
      is_usr_leg_ap <= #`TCQ (aperture_i == 0) && (offset_i[7:6] == 3) &&
                             legacy_cfg_access_i;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      is_usr_ext_ap <= #`TCQ 0;
    end else if (load_aperture_i) begin
      is_usr_ext_ap <= #`TCQ |aperture_i[3:2] && ext_cfg_access_i;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      load_aperture_q <= #`TCQ 0;
    end else begin
      load_aperture_q <= #`TCQ load_aperture_i;
    end
  end

  // The packet goes to the CMM if:
  // 1. It is Config Type 1, OR
  // 2. It is Config Type 0 and the packet doesn't fall into either of
  //    the user categories above.

  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg_o <= #`TCQ 0;
    end else if (load_aperture_q) begin
      cfg_o <= #`TCQ cfg1_ip || (cfg0_ip && !is_usr_leg_ap && !is_usr_ext_ap);
    end
  end

  // Signal receipt of a hot-plug Message. These have been obsoleted
  // starting with PCIe 1.1, so the user is given the option of dropping
  // them.

  always @(posedge clk_i) begin
    if (reset_i) begin
      hp_msg_detect_o <= #`TCQ 0;
    end else if (eval_formats_q) begin
      hp_msg_detect_o <= #`TCQ ismsgany && msgcode_hotplug;
    end
  end
  `else // `ifdef AS
  //====================================================================
  // Check for valid PI and PI chain.
  //====================================================================

  // Make sure that PIs are not latched past the end of the chain. Valid
  // chains are:
  // * 0 -> 0
  // * 0 -> 1 -> PDU (8-126)
  // * 0 -> 1 -> 2 -> PDU
  // * 0 -> 2 -> PDU
  // * 1 -> PDU
  // * 1 -> 2 -> PDU
  // * 2 -> PDU
  // * 4
  // * 5
  // * PDU

  // The secondary and tertiary PIs appear on the same clock cycle in
  // 64-bit, which is why the equation for load_pi_3rd is more complex
  // than the other ones.

  assign load_pi_1st = load_pi_1st_i;

  assign load_pi_2nd = load_pi_2nd_i && (pi_1st <= 2);

  // In 64-bit, the secondary and tertiary PIs come on the same cycle,
  // so checks on the 3rd PI involve the live version of the 2nd PI.
  assign load_pi_3rd = load_pi_3rd_i && ((DW == 64) ?
                                         ((pi_2nd_i == 1) || (pi_2nd_i == 2)) :
                                         ((pi_2nd   == 1) || (pi_2nd   == 2)));

  assign load_pi_4th = load_pi_4th_i && (pi_3rd_i <= 2);

  // PIs 128-130 are "placeholders": If their corresponding registers
  // are not written into, they will still be greater than higher-order
  // PIs for the purposes of chain validation.

  always @(posedge clk_i) begin
    if (sof_i) begin
      pi_1st <= #`TCQ load_pi_1st ? pi_1st_i : 0;
      pi_2nd <= #`TCQ 128;
      pi_3rd <= #`TCQ 129;
      pi_4th <= #`TCQ 130;
    end else begin
      if (load_pi_2nd) begin
        pi_2nd[7]   <= #`TCQ 0;
        pi_2nd[6:0] <= #`TCQ pi_2nd_i;
      end
      if (load_pi_3rd) begin
        pi_3rd[7]   <= #`TCQ 0;
        pi_3rd[6:0] <= #`TCQ pi_3rd_i;
      end
      if (load_pi_4th) begin
        pi_4th[7]   <= #`TCQ 0;
        pi_4th[6:0] <= #`TCQ pi_4th_i;
      end
    end
  end

  // Distill certain PIs into one-hot signals

  always @(posedge clk_i) begin
    if (reset_i) begin
      primary_pi0   <= #`TCQ 0;
      primary_pi4   <= #`TCQ 0;
      primary_pi5   <= #`TCQ 0;
    end else if (load_pi_1st) begin
      primary_pi0   <= #`TCQ (pi_1st_i == 0);
      primary_pi4   <= #`TCQ (pi_1st_i == 4);
      primary_pi5   <= #`TCQ (pi_1st_i == 5);
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      secondary_pi0 <= #`TCQ 0;
    end else if (load_pi_2nd) begin
      secondary_pi0 <= #`TCQ (pi_2nd_i == 0);
    end
  end

  // Check for invalid PIs. Note that placeholder PIs (128+) which
  // represent "blanks" are always valid.
  //--------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (reset_i) begin
      pi_1st_vld <= #`TCQ 1;
      pi_2nd_vld <= #`TCQ 1;
      pi_3rd_vld <= #`TCQ 1;
      pi_4th_vld <= #`TCQ 1;
    end else begin
      // Primary PI: Legal values are 0-2, 4, 5, 8-126
      pi_1st_vld <= #`TCQ (pi_1st != 3) && (pi_1st != 6) && (pi_1st != 7) &&
                          (pi_1st != 127);

      // Secondary PI: Legal values are 0-2, 8-126
      pi_2nd_vld <= #`TCQ ((pi_2nd <= 2) || (pi_2nd >= 8)) && (pi_2nd != 127);

      // Tertiary PI: Legal values are 2, 8-126
      pi_3rd_vld <= #`TCQ ((pi_2nd == 2) || (pi_2nd >= 8)) && (pi_3rd != 127);

      // Quaternary PI: Legal values are 8-126
      pi_4th_vld <= #`TCQ (pi_4th >= 8) && (pi_4th != 127);
    end
  end

  // Check for invalid PI sequences. Note that the placeholder PIs will
  // always represent valid chains since they are greater than any legal
  // PI and are loaded in an increasing progression. In addition,
  //--------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (reset_i) begin
      pi_2nd_seq_vld <= #`TCQ 1;
      pi_3rd_seq_vld <= #`TCQ 1;
      pi_4th_seq_vld <= #`TCQ 1;
    end else begin
      // Secondary PI is sequence-valid if 1st PI = 0 or 2nd PI > 1st PI
      pi_2nd_seq_vld <= #`TCQ !((pi_1st < 4) && pi_2nd[7]) &&
                                (pi_2nd > pi_1st);

      // Tertiary PI is sequence-valid if 3rd PI > 2nd PI
      pi_3rd_seq_vld <= #`TCQ !(((pi_2nd > 0) || (pi_2nd < 4)) && pi_3rd[7]) &&
                                 (pi_3rd > pi_2nd);

      // Quaternary PI is sequence-valid if 4th PI > 3rd PI
      pi_4th_seq_vld <= #`TCQ !(((pi_3rd > 0) || (pi_3rd < 4)) && pi_4th[7]) &&
                                 (pi_4th > pi_3rd);
    end
  end

  // Latch any PI error condition.
  //--------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_pi_chain_o <= #`TCQ 1;
    end else if (eof_q1) begin
      bad_pi_chain_o <= #`TCQ !pi_1st_vld || !pi_2nd_vld ||
                              !pi_3rd_vld || !pi_4th_vld ||
                              !pi_2nd_seq_vld || !pi_3rd_seq_vld ||
                              !pi_4th_seq_vld;
    end
  end

  //====================================================================
  // Check the Turn Pointer. Must be zero for any forward-routed packet
  // received by an Endpoint that is not PI-0.

  always @(posedge clk_i) begin
    if (reset_i) begin
      non_zero_turn_pointer_o <= #`TCQ 0;
    end else if (eval_formats_i) begin
      non_zero_turn_pointer_o <= #`TCQ !dir_i && !switch_mode_i &&
                                       (pi_1st != 0) && (turn_pointer_i != 0);
    end
  end

  //====================================================================
  // Check the Header CRC. Path-building and multicast packets (PI-0)
  // have a mutable Turn Pool which must be masked out when performing
  // the CRC calculation. For timing purposes, both the path-build and
  // non-path-build CRCs are calculated and the correct one is later
  // chosen for comparison.

  tlm_hcrc hcrc
   (.d_i        (route_header_i[50:0]),
    .hcrc_o     (header_crc_d));

  tlm_hcrc hcrc_pb
   (.d_i        ({route_header_i[50:32],32'b0}),
    .hcrc_o     (header_crc_pb_d));

  always @(posedge clk_i) begin
    if (reset_i) begin
      path_build    <= #`TCQ 0;
    end else if (eval_formats_i) begin
      path_build    <= #`TCQ (pi_1st == 0);
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      header_crc    <= #`TCQ 0;
      header_crc_pb <= #`TCQ 0;
    end else if (eval_formats_i) begin
      header_crc    <= #`TCQ header_crc_d;
      header_crc_pb <= #`TCQ header_crc_pb_d;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_header_crc_o <= #`TCQ 0;
    end else if (eof_q1) begin
      bad_header_crc_o <= #`TCQ (hcrc_i !=
                                 (path_build ? header_crc_pb : header_crc));
    end
  end

  //====================================================================
  // Check whether we've received an packet intended for an unsupported
  // OVC or MVC.

  always @(posedge clk_i) begin
    if (reset_i) begin
      unsup_ovc_o <= #`TCQ 0;
    end else if (eval_formats_i) begin
      unsup_ovc_o <= #`TCQ oo_i && BVC;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      unsup_mvc_o <= #`TCQ 0;
    end else if (eof_q1) begin
      unsup_mvc_o <= #`TCQ primary_pi0 && (pi_2nd != 0) && !MVC;
    end
  end

  //====================================================================
  // Drop packets depending on link state. In DL_Inactive or DL_init,
  // only PI-0:0 packets are allowed through. In DL_Protected, only
  // PI-0:0, PI-4 and PI-5 packets are allowed.

  localparam [1:0] DL_INACTIVE  = 2'b00;
  localparam [1:0] DL_INIT      = 2'b01;
  localparam [1:0] DL_PROTECTED = 2'b10;
  localparam [1:0] DL_ACTIVE    = 2'b11;

  // Only change link state in between packets.

  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_ip <= #`TCQ 0;
    end else if (sof_i) begin
      packet_ip <= #`TCQ 1;
    end else if (eof_i) begin
      packet_ip <= #`TCQ 0;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      lnk_state_d <= #`TCQ DL_INACTIVE;
    end else if (lnk_state_src_rdy_i) begin
      lnk_state_d <= #`TCQ lnk_state_i;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      lnk_state <= #`TCQ DL_INACTIVE;
    end else if (!packet_ip) begin
      lnk_state <= #`TCQ lnk_state_d;
    end
  end

  // Signal packet drop

  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_keep <= #`TCQ 1'b1;
    end else if (eof_q1) begin
      case (lnk_state)
        DL_INACTIVE:  packet_keep <= #`TCQ  (pi_1st == 0) && (pi_2nd == 0);
        DL_INIT:      packet_keep <= #`TCQ  (pi_1st == 0) && (pi_2nd == 0);
        DL_PROTECTED: packet_keep <= #`TCQ ((pi_1st == 0) && (pi_2nd == 0)) ||
                                            (pi_1st == 4) || (pi_1st == 5);
        DL_ACTIVE:    packet_keep <= #`TCQ  1'b1;
      endcase
    end
  end

  assign filter_drop_o = !packet_keep;

  //====================================================================
  // Flag PI-0:0 and PI-4 packets as config. For PI-4, make sure the
  // config address is in the CMM's range.

  always @(posedge clk_i) begin
    if (reset_i) begin
      pi4_ap0   <= #`TCQ 1'b0;
      pi4_ap1   <= #`TCQ 1'b0;
    end else if (load_aperture_i) begin
      pi4_ap0   <= #`TCQ primary_pi4 && (aperture_i == 0);
      pi4_ap1   <= #`TCQ primary_pi4 && (aperture_i == 1);
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      in_ap0_range  <= #`TCQ 0;
      in_ap1_range  <= #`TCQ 0;
    end else if (load_offset_i) begin
      in_ap0_range  <= #`TCQ (offset_i <  cmm_ap0_space_end_i);
      in_ap1_range  <= #`TCQ (offset_i >= cmm_ap1_space_start_i) &&
                             (offset_i <  cmm_ap1_space_end_i);
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      load_offset_q <= #`TCQ 0;
    end else begin
      load_offset_q <= #`TCQ load_offset_i;
    end
  end

  // The packet goes to the CMM if:
  // 1. It is PI-0:0 and we are not a Fabric Manager, OR
  // 2. It is PI-4 Aperture 0, and in the Aperture 0 address range, OR
  // 3. It is PI-4 Aperture 1, and in the Aperture 1 address range.

  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg_o <= #`TCQ 0;
    end else if (load_offset_q) begin
      cfg_o <= #`TCQ (primary_pi0 && secondary_pi0 &&
                      !fabric_manager_mode_i) ||
                     (pi4_ap0 && in_ap0_range) ||
                     (pi4_ap1 && in_ap1_range);
    end
  end
  `endif

  //====================================================================
  // delay of control signals

  always @(posedge clk_i) begin
    if (reset_i) begin
      `ifdef PCIE
      sof_q1          <= #`TCQ 0;
      sof_q2          <= #`TCQ 0;
      sof_q3          <= #`TCQ 0;
      sof_q4          <= #`TCQ 0;
      eof_q2          <= #`TCQ 0;
      eof_q3          <= #`TCQ 0;
      eval_formats_q  <= #`TCQ 0;
      eval_formats_q2 <= #`TCQ 0;
      `endif
      eof_q1          <= #`TCQ 0;
    end else begin
      `ifdef PCIE
      sof_q1          <= #`TCQ sof_i;
      sof_q2          <= #`TCQ sof_q1;
      sof_q3          <= #`TCQ sof_q2;
      sof_q4          <= #`TCQ sof_q3;
      eof_q2          <= #`TCQ eof_q1;
      eof_q3          <= #`TCQ eof_q2;
      eval_formats_q  <= #`TCQ eval_formats_i;
      eval_formats_q2 <= #`TCQ eval_formats_q;
      `endif
      eof_q1          <= #`TCQ eof_i;
    end
  end
endmodule
