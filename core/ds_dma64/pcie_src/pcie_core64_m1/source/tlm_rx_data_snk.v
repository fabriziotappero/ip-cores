
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
// File       : tlm_rx_data_snk.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : Rx Data Sink
 *
 *     Hierarchical : tlm_rx
 *                       tlm_rx_data_snk *
 *                          malformed_checks
 *                          pwr_mgmt
 *                          bar_hit
 *
 *     Functional :
 *      Takes incoming packets, examines the packet for correct
 *        construction and drops if it malformed.
 *      Removes power management packets from the stream and signals
 *        sideband to CMM
 *      Rips out header control information for easier control downstream
 *
 ****************************************************************************/

`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef PCIE
 `ifndef AS
  `define PCIE
 `endif
`endif

module tlm_rx_data_snk #(parameter DW              = 32,// Data width
                         parameter FCW             = 6, // Packet credit width
                         `ifdef PCIE
                         parameter BARW            = 7, // BAR-hit width
                         parameter DOWNSTREAM_PORT = 0, // Endpoint or switch?
                         `else // `ifdef AS
                         parameter OVC             = 0, // Any ordered VCs?
                         parameter MVC             = 0, // Any multicast VCs?
                         `endif
                         parameter MPS             = 512,//Core MPS
                         parameter TYPE1_UR        = 0) // Type1 config bad?
  (
   input                 clk_i,
   input                 reset_i,

   //--------------------------------------------------------
   // Datapath signals
   //--------------------------------------------------------

   // To FIFO
   output reg [DW-1:0]   d_o,               // Data
   output reg            sof_o,             // ll sof
   output reg            eof_o,             // ll eof
   output reg            preeof_o,          // ll eof - one cycle early
   output reg            src_rdy_o,         // ll src_rdy
   output reg            rem_o,             // ll rem (in words)
   output reg            dsc_o,             // ll dsc

   output reg            cfg_o,             // Config packet, @bar
   `ifdef PCIE
   output reg            np_o,              // Non-posted packet, @bar
   output reg            cpl_o,             // Completion packet, @bar
   output reg            locked_o,          // Locked msg or cpl, @bar
   output reg [BARW-1:0] bar_o,             // Bar hit, @bar
   output reg            rid_o,             // RID hit, @bar
   output reg            vend_msg_o,        // Vendor-defined MSG
   output reg            bar_src_rdy_o,     // ll src_rdy
   `endif

   // To Flow controller
   output reg            fc_use_p_o,        // posted update.. implies 1 hdr
   output reg            fc_use_np_o,       // nonposted update.. ''
   `ifdef PCIE
   output reg            fc_use_cpl_o,      // compl update..     ''
   `endif
   output reg [FCW-1:0]  fc_use_data_o,     // number of data credits used
   output reg            fc_unuse_o,        // ll src_rdy.. implies 1 header

   // From LLM
   input [DW-1:0]        d_i,               // Data
   input                 sof_i,             // ll sof
   input                 eof_i,             // ll eof
   input                 rem_i,             // ll rem in binary bytes
   input                 src_rdy_i,         // ll src_rdy
   input                 src_dsc_i,         // ll dsc

   //--------------------------------------------------------
   // Sideband signals
   //--------------------------------------------------------

   // InitFC communication to LLM
   output reg            vc_hit_o,          // TLP received on VC0

   // Power management signals for CMM
   `ifdef PCIE
   output                pm_as_nak_l1_o,    // Pkt detected, implies src_rdy
   output                pm_turn_off_o,     // Pkt detected, implies src_rdy
   output                pm_set_slot_pwr_o, // Pkt detected, implies src_rdy
   output [9:0]          pm_set_slot_pwr_data_o, // value of field
   input                 pm_suspend_req_i,  // Go into pm.. drop packets
   `else // `ifdef AS
   input [1:0]           lnk_state_i,       // Link state
   input                 lnk_state_src_rdy_i,   // New link state valid
   `endif

   `ifdef PCIE
   // Completion event information for CMM
   output reg [47:0]     err_tlp_cpl_header_o, // Header fields
   output reg            err_tlp_p_o,       // Pkt is posted
   output reg            err_tlp_ur_o,      // Unsupported req, implies src_rdy
   output reg            err_tlp_ur_lock_o, // Unsupported req due to Lock, implies src_rdy
   output reg            err_tlp_uc_o,      // Unsupported cpl, implies src_rdy
   output reg            err_tlp_malformed_o, // Pkt is badly constructed,
                                              //   implies src_rdy
   // status register in the CMM
   output reg            stat_tlp_cpl_ep_o,   // cpl inc pkt poison
   output reg            stat_tlp_cpl_abort_o, // cpl stat is abort
   output reg            stat_tlp_cpl_ur_o, // cpl stat is ur
   output reg            stat_tlp_ep_o,     // incoming pkt poison

   // Outgoing information to check CMM for bar hit
   output [63:0]         check_raddr_o,     // is address mapped?
   output                check_mem32_o,
   output                check_mem64_o,
   output                check_rio_o,       // implies src_rdy
   output                check_rdev_o,      // implies src_rdy
   output                check_rbus_o,      // implies src_rdy
   output                check_rfun_o,      // implies src_rdy
   // Incoming information from CMM on bar hit status
   input                 check_rhit_i,      // match found
   input [BARW-1:0]      check_rhit_bar_i,  // address of match
   `else // `ifdef AS
   // PI-5 event information for CMM.
   output reg            err_tlp_bad_header_crc_o,          // Bad HCRC
   output reg            err_tlp_bad_pi_chain_o,            // Bad PI chain
   output reg            err_tlp_bad_credit_length_o,       // CR < length
   output reg            err_tlp_invalid_credit_length_o,   // CR > MPS
   output reg            err_tlp_non_zero_turn_pointer_o,   // Endpoints only
   output reg            err_tlp_unsup_mvc_o,               // MVC
   output reg            err_tlp_unsup_ovc_o,               // OVC
   output reg [159:0]    err_tlp_type_b_header_o,           // PI-5 rtn. info
   input                 err_tlp_type_b_ack_i,              // PI-5 ack'd
   `endif
   // Static control from CMM
   `ifdef PCIE
   input [2:0]           max_payload_i,     // Enc val for max paysize allowed
   input                 rhit_bar_lat3_i,   // BAR-hit latency 3 clocks?
   input                 legacy_mode_i,     // For interp of the spec
   input                 legacy_cfg_access_i,//User implements legacy config?
   input                 ext_cfg_access_i,  // User implements ext. config?
   input                 hotplug_msg_enable_i,//Pass obsolete hot-plug to user?
   `else // `ifdef AS
   input [3:0]           max_payload_i,     // Enc val for max paysize allowed
   input                 switch_mode_i,         // Is core a Switch?
   input                 fabric_manager_mode_i, // Is core a Fabric Manager?
   input [31:0]          cfg_ap0_space_end_i,   // End of Aperture 0 range
   input [31:0]          cfg_ap1_space_start_i, // Start of Aperture 1 range
   input [31:0]          cfg_ap1_space_end_i,   // End of Aperture 1 range
   `endif
   input                 td_ecrc_trim_i     // Strip digest for user?
   );

  //--------------------------------------------------------------------------
  // Locally derived constants

  `ifdef PCIE
  //--------------------------------------------------------------------------
  // Symbolic constants

  // Full type
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
  localparam             MSG     = 7'b01_10xxx;
  localparam             MSGD    = 7'b11_10xxx;
  localparam             MSGAS   = 7'b01_11xxx;
  localparam             MSGASD  = 7'b11_11xxx;
  localparam             CPL     = 7'b00_01010;
  localparam             CPLD    = 7'b10_01010;
  localparam             CPLLK   = 7'b00_01011;
  localparam             CPLDLK  = 7'b10_01011;
  // Encoded Full type into "one hots"
  localparam             MEM_BIT   = 8;
  localparam             ADR_BIT   = 7;
  localparam             MRD_BIT   = 6;
  localparam             MWR_BIT   = 5;
  localparam             MLK_BIT   = 4;
  localparam             IO_BIT    = 3;
  localparam             CFG_BIT   = 2;
  localparam             MSG_BIT   = 1;
  localparam             CPL_BIT   = 0;

  // Memory and address-routed types are given an extra bits to improve
  // timing for BAR checks
  localparam [8:0]       OTHERTYPE =  9'b0;
  localparam [8:0]       MEMANY    =  9'b1 << MEM_BIT;
  localparam [8:0]       ADRANY    =  9'b1 << ADR_BIT;
  localparam [8:0]       MRDANY    = (9'b1 << MRD_BIT) | ADRANY | MEMANY;
  localparam [8:0]       MWRANY    = (9'b1 << MWR_BIT) | ADRANY | MEMANY;
  localparam [8:0]       MLKANY    = (9'b1 << MLK_BIT) | ADRANY | MEMANY;
  localparam [8:0]       IOANY     = (9'b1 << IO_BIT)  | ADRANY;
  localparam [8:0]       CFGANY    =  9'b1 << CFG_BIT;
  localparam [8:0]       MSGANY    =  9'b1 << MSG_BIT;
  localparam [8:0]       CPLANY    =  9'b1 << CPL_BIT;
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
  localparam             VENDOR_DEFINED_TYPE_0     = 8'b0111_1110;
  localparam             VENDOR_DEFINED_TYPE_1     = 8'b0111_1111;
  // Route
  localparam             ROUTE_BY_ID = 3'b010;
  // Format
  localparam             FMT_3DW_NODATA = 2'b00;
  localparam             FMT_4DW_NODATA = 2'b01;
  localparam             FMT_3DW_WDATA  = 2'b10;
  localparam             FMT_4DW_WDATA  = 2'b11;
  // Completion status
  localparam             CPL_STAT_SC  = 3'b000;
  localparam             CPL_STAT_UR  = 3'b001;
  localparam             CPL_STAT_CRS = 3'b010;
  localparam             CPL_STAT_CA  = 3'b100;
  `endif // `ifdef PCIE

  //------------------------------------------------------------------
  // Bit indices for aliasing

  `ifdef PCIE
  // First Dword
  localparam             FULLTYPE_HI_IND = DW-2;
  localparam             FULLTYPE_LO_IND = DW-8;
  localparam             TC_HI_IND       = DW-10;
  localparam             TC_LO_IND       = DW-12;
  localparam             TD_IND          = DW-17;
  localparam             EP_IND          = DW-18;
  localparam             ATTR_HI_IND     = DW-19;
  localparam             ATTR_LO_IND     = DW-20;
  localparam             LENGTH_HI_IND   = DW-23;
  localparam             LENGTH_LO_IND   = DW-32;
  // Second Dword
  localparam             REQ_ID_HI_IND   = 31;
  localparam             REQ_ID_LO_IND   = 16;
  localparam             TAG_HI_IND      = 15;
  localparam             TAG_LO_IND      = 8;
  localparam             CPL_STAT_HI_IND = 15;
  localparam             CPL_STAT_LO_IND = 13;
  // Third Dword
  localparam             REQ_ID_CPL_HI_IND   = DW-1;
  localparam             REQ_ID_CPL_LO_IND   = DW-16;
  localparam             LOWER_ADDR32_HI_IND = DW-26;
  localparam             LOWER_ADDR32_LO_IND = DW-30;
  localparam             APERTURE_HI_IND     = DW-21;
  localparam             APERTURE_LO_IND     = DW-24;
  localparam             OFFSET_HI_IND       = DW-25;
  localparam             OFFSET_LO_IND       = DW-30;
  // Fourth Dword
  localparam             LOWER_ADDR64_HI_IND = 6;
  localparam             LOWER_ADDR64_LO_IND = 2;
  // Data
  localparam             SET_SLOT_PWRVAL_HI_IND = DW-1;
  localparam             SET_SLOT_PWRVAL_LO_IND = DW-8;
  localparam             SET_SLOT_PWRSCL_HI_IND = DW-15;
  localparam             SET_SLOT_PWRSCL_LO_IND = DW-16;
  `else // `ifdef AS
  // First Dword
  localparam             PI_1ST_HI_IND   = DW-26;
  localparam             PI_1ST_LO_IND   = DW-32;
  localparam             TC_HI_IND       = DW-21;
  localparam             TC_LO_IND       = DW-23;
  localparam             TD_IND          = DW-24;
  localparam             OO_IND          = DW-20;
  localparam             TS_IND          = DW-19;
  localparam             LENGTH_HI_IND   = DW-14;
  localparam             LENGTH_LO_IND   = DW-18;
  localparam             TURN_PTR_HI_IND = DW-8;
  localparam             TURN_PTR_LO_IND = DW-12;
  localparam             HCRC_HI_IND     = DW-1;
  localparam             HCRC_LO_IND     = DW-7;
  // Second Dword
  localparam             TURN_POOL_HI_IND= 30;
  localparam             TURN_POOL_LO_IND= 0;
  localparam             DIR_IND         = 31;
  // Third Dword
  localparam             PI_2ND_HI_IND   = DW-26;
  localparam             PI_2ND_LO_IND   = DW-32;
  localparam             APERTURE_HI_IND = DW-29;
  localparam             APERTURE_LO_IND = DW-32;
  // Fourth Dword
  localparam             PI_3RD_HI_IND   = 6;
  localparam             PI_3RD_LO_IND   = 0;
  localparam             OFFSET_HI_IND   = 31;
  localparam             OFFSET_LO_IND   = 2;
  // Fifth Dword
  localparam             PI_4TH_HI_IND   = DW-26;
  localparam             PI_4TH_LO_IND   = DW-32;
  `endif

  // Delayed versions of input signals
  //--------------------------------------------------------
  reg [6:1]              sof_q;
  reg [6:1]              eof_q;
  reg [6:1]              eof_nd_q;
  reg [6:1]              src_rdy_q;
  reg [6:1]              dsc_q;
  reg [6:1]              rem_q;
  reg                    cur_rem; // before TD change
  reg                    packet_ip;
  wire [DW-1:0]          d_mux;
  reg [DW-1:0]           d_q1, d_q2, d_q3, d_q4, d_q5, d_q6;
                         // 2D makes NC unhappy

  //====================================================================
  // Because certain operations take more time than might be available
  // in a packet, we need the information for the packet that's arriving
  // as well as the information from the packet that is exiting. Since
  // we're immediately registering the values when they come in we can
  // alias the D-input of the flops right to the data coming in.
  //====================================================================

  //----------------------------------------------------------
  // Latch enable signals
  //----------------------------------------------------------
  //           64 bit         32 bit
  //         -------------    ------
  // sof_i  | DW 1 | DW 2 |  | DW 1 |
  // sof_q1 | DW 3 | DW 4 |  | DW 2 |
  // sof_q2  -------------   | DW 3 |
  // sof_q3                  | DW 4 |
  //                          ------

  wire                   latch_1st_dword = sof_i && src_rdy_i;
  reg                    latch_1st_dword_q1, latch_1st_dword_q2,
                         latch_1st_dword_q3, latch_1st_dword_q4;
  wire                   latch_2nd_dword = (DW == 32) ? sof_q[1]:
                                                        sof_i  && src_rdy_i;
  reg                    latch_2nd_dword_q1, latch_2nd_dword_q2;
  wire                   latch_3rd_dword = (DW == 32) ? sof_q[2] : sof_q[1];
  reg                    latch_3rd_dword_q1;
  wire                   latch_4th_dword = (DW == 32) ? sof_q[3] : sof_q[1];
  reg                    latch_4th_dword_q1;
  `ifdef AS
  wire                   latch_5th_dword = (DW == 32) ? sof_q[4] : sof_q[2];
  `endif

  //-----------------------------------------------------------
  // First Dword
  //-----------------------------------------------------------
  `ifdef PCIE
  // Fulltype is used in packet type determination, and header type
  wire [6:0]             fulltype_in   = d_i[FULLTYPE_HI_IND:FULLTYPE_LO_IND];
  reg [6:0]              cur_fulltype;
  reg                    cur_fulltype_64, cur_fulltype_mem;
  wire                   cur_has_data = cur_fulltype[6];
  wire [2:0]             cur_routing = cur_fulltype[2:0];
  reg [8:0]              cur_fulltype_oh;
  reg                    cur_locked, cur_locked_q;
  reg                    cur_cpl;

  // Traffic class needs to be 0 for certain packets, also to CMM cpl
  wire [2:0]             tc_in         = d_i[TC_HI_IND:TC_LO_IND];
  reg [2:0]              cur_tc;
  reg                    cur_tc0;

  // The error poisoned bit gets forwarded with the packet
  wire                   ep_in         = d_i[EP_IND];
  reg                    cur_ep, cur_ep_q;

  // Attributes needs to be know for the CMM to construct a completion
  wire [1:0]             attr_in       = d_i[ATTR_HI_IND:ATTR_LO_IND];
  reg [1:0]              cur_attr;
  `else // `ifdef AS
  // Primary PI
  wire [6:0]             pi_1st        = d_i[PI_1ST_HI_IND:PI_1ST_LO_IND];

  // Header CRC
  reg [6:0]              cur_hcrc;

  // Turn Pointer
  reg [4:0]              cur_turn_pointer;

  // Ordered-Only and Type-Specific
  reg                    cur_oo, cur_ts;
  `endif

  // TLP Digest/PCRC
  wire                   td_in         = d_i[TD_IND];
  reg                    cur_td, cur_td_q;

  // Length/Credits Required is used in correct length determination
  localparam             LENW = LENGTH_HI_IND - LENGTH_LO_IND + 1;

  wire [9:0]             length_in     = d_i[LENGTH_HI_IND:LENGTH_LO_IND];
  reg  [9:0]             cur_length;
  `ifdef PCIE
  reg                    cur_length1;
  `else // `ifdef AS
  reg                    np_o;  // Local in AS, needed for credit tracking
  `endif

  reg                    cur_np;
  wire                   cur_cfg;

  //----------------------------------------------------------
  // Second Dword
  //----------------------------------------------------------
  `ifdef PCIE
  wire [15:0]            req_id_in     = d_i[REQ_ID_HI_IND:REQ_ID_LO_IND];
  reg [15:0]             cur_req_id;

  // Used in CMM cpl to mark pkts
  wire [7:0]             tag_in        = d_i[TAG_HI_IND:TAG_LO_IND];
  reg [7:0]              cur_tag;

  // Byte enables on boundaries
  wire [3:0]             last_be_in    = d_i[7:4];
  reg [1:0]              last_be_missing;
  wire [3:0]             first_be_in   = d_i[3:0];
  reg [1:0]              cur_first_be_adj;
  reg [1:0]              first_be_missing;
  reg [2:0]              cur_bytes_missing;
  reg [2:0]              cur_byte_ct_1dw;
  reg [2:0]              byte_ct_1dw;

  // Message types
  wire [7:0]             msgcode_in    = d_i[7:0];
  reg [7:0]              cur_msgcode;
  reg                    cur_vend_msg;
  `else // `ifdef AS
  // Turn Pool and Routing Direction
  reg [30:0]             cur_turn_pool;
  reg                    cur_dir;

  // Route header (for Header CRC check, actually covers 2 DW)
  reg [50:0]             cur_route_header;
  `endif

  //----------------------------------------------------------
  // Third Dword
  //----------------------------------------------------------
  `ifdef PCIE
  wire [15:0]            req_id_cpl_in = d_i[REQ_ID_CPL_HI_IND:
                                             REQ_ID_CPL_LO_IND];
  wire [31:0]            addr_hi_in    = d_i[DW-1:DW-32];
  reg [31:0]             cur_addr_hi;
  wire [6:2]             lower_addr32_in = d_i[LOWER_ADDR32_HI_IND:
                                               LOWER_ADDR32_LO_IND];
  wire [6:2]             lower_addr64_in = d_i[LOWER_ADDR64_HI_IND:
                                               LOWER_ADDR64_LO_IND];
  reg  [6:2]             lower_addr32_in_q, lower_addr64_in_q;
  wire [2:0]             cpl_stat_in = d_i[CPL_STAT_HI_IND:
                                           CPL_STAT_LO_IND];
  reg [2:0]              cur_cpl_stat;
  `else // `ifdef AS
  // Secondary PI
  wire [6:0]             pi_2nd        = d_i[PI_2ND_HI_IND:PI_2ND_LO_IND];
  `endif

  // PCIe config extended reg. number or AS PI-4 config address aperture
  wire [3:0]             aperture      = d_i[APERTURE_HI_IND:APERTURE_LO_IND];

  //----------------------------------------------------------
  // Third/Fourth Dword
  //----------------------------------------------------------

  // Config TLP (3rd DW) or PI-4 config (4th DW) address offset
  wire [OFFSET_HI_IND-OFFSET_LO_IND+2:0] offset;

  assign offset = {d_i[OFFSET_HI_IND:OFFSET_LO_IND],2'b00};

  //----------------------------------------------------------
  // Fourth Dword
  //----------------------------------------------------------
  `ifdef PCIE
  wire   [31:0]          addr_lo_i     = d_i[31:0];
  `else // `ifdef AS
  // Tertiary PI
  wire [6:0]             pi_3rd        = d_i[PI_3RD_HI_IND:PI_3RD_LO_IND];
  `endif

  `ifdef AS
  //----------------------------------------------------------
  // Fifth Dword
  //----------------------------------------------------------
  // Quaternary PI
  wire [6:0]             pi_4th        = d_i[PI_4TH_HI_IND:PI_4TH_LO_IND];
  `endif

  `ifdef PCIE
  //----------------------------------------------------------
  // Data
  //----------------------------------------------------------
  wire [9:0]             pwr_data_i = {d_i[SET_SLOT_PWRSCL_HI_IND:
                                           SET_SLOT_PWRSCL_LO_IND],
                                       d_i[SET_SLOT_PWRVAL_HI_IND:
                                           SET_SLOT_PWRVAL_LO_IND]};
  `endif

  //----------------------------------------------------------
  // Derived signals
  //----------------------------------------------------------
  // Data credits
  wire [FCW-1:0]         cur_data_credits;
  wire                   cur_data_credits_vld;
  reg [FCW-1:0]          fc_use_data_d;
  // Digest removal
  reg                    remove_lastword;
  // Bad or dropped packets
  `ifdef PCIE
  wire                   malformed;
  wire                   tlp_ur;
  wire                   tlp_ur_lock;
  wire                   tlp_uc;
  wire                   tlp_filt;
  reg [6:0]              cur_lower_addr; // used to assemble cpl's
  reg [11:0]             cur_byte_ct;    // ''
  `else // `ifdef AS
  wire                   bad_header_crc;
  wire                   bad_pi_chain;
  wire                   bad_credit_length;
  wire                   invalid_credit_length;
  wire                   non_zero_turn_pointer;
  wire                   unsup_mvc;
  wire                   unsup_ovc;
  wire                   filter_drop;
  `endif
  reg                    cur_drop, next_cur_drop;
  `ifdef PCIE
  // Power management
  reg                    pwr_mgmt_mode_on;
  wire                   cur_pm_msg_detect;
  // packet types
  reg                    np_d, cpl_d, cfg_d, locked_d, vend_msg_d;
  // bar checks
  wire [BARW-1:0]        rhit_bar_d;
  wire                   rhit_src_rdy;
  wire                   rhit_ack;
  wire                   rhit_lock;
  // cmm status
  reg                    cur_cpl_ep, cur_cpl_abort, cur_cpl_ur;
  reg [28:0]             cur_cpl_header_fmt;
  reg [47:0]             err_tlp_cpl_header_d;
  // obsolete packet types (hot-plug)
  wire                   cur_hp_msg_detect;
  `else // `ifdef AS
  // Storage of Type B header
  reg [5:0]              load_type_b;
  reg                    type_b_pending;
  wire                   wr_hdr;
  wire                   rd_hdr;
  wire                   sof_hdr;
  wire [DW-1:0]          hdr;
  `endif
  // data-path sync
  wire [2:0]             out_d1;
  wire [2:0]             out_d2;
  wire [2:0]             out_d3;


  //================================================================
  // EOF/Discontinue
  //================================================================
  // Synchronize EOF events, including error reporting
  //----------------------------------------------------------------

  `ifdef PCIE
  assign                 out_d1 = rhit_bar_lat3_i ? 6 : 5;
  `else // `ifdef AS
  assign                 out_d1 = 4;
  `endif
  assign                 out_d2 = out_d1 - 1;
  assign                 out_d3 = out_d1 - 2;


  //====================================================
  // Credit transmissions
  //====================================================
  // Output registers that drive the flow controller
  //----------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      fc_use_p_o   <= #`TCQ 0;
      fc_use_np_o  <= #`TCQ 0;
      `ifdef PCIE
      fc_use_cpl_o <= #`TCQ 0;
      `endif
      fc_unuse_o   <= #`TCQ 0;

    // At this point we know if the packet is correctly
    //    formed..
    // np and cpl we can directly use the same control
    //    going to the FIFO
    end else if (eof_q[out_d2] && !dsc_q[out_d2]) begin
      fc_use_np_o  <= #`TCQ np_o;
      `ifdef PCIE
      fc_use_p_o   <= #`TCQ !np_o && !cpl_o;
      fc_use_cpl_o <= #`TCQ cpl_o;
      `else // `ifdef AS
      fc_use_p_o   <= #`TCQ !np_o;
      `endif
      // Packets that we dropped because we signal them
      //   sideband or they are invalid, we 'fake' out
      //   the flow controller by freeing those packets
      //   immediately
      // Dsc in from the LLM is the only case we don't
      //   do this-- which has priority over invalid
      //   packets
      fc_unuse_o   <= #`TCQ next_cur_drop;

    // all signals imply src ready, return back to zero
    end else begin
      fc_use_p_o   <= #`TCQ 0;
      fc_use_np_o  <= #`TCQ 0;
      `ifdef PCIE
      fc_use_cpl_o <= #`TCQ 0;
      `endif
      fc_unuse_o   <= #`TCQ 0;
    end
  end

  // cur_data_credits may only be valid until eof_q3.. but
  //   since this signal only has a quantity, latch it earlier
  always @(posedge clk_i) begin
    `ifdef PCIE
    if (!rhit_bar_lat3_i || (DW == 32))
    `endif
    begin
      if (cur_data_credits_vld) begin
        fc_use_data_o   <= #`TCQ cur_data_credits;
      end
      fc_use_data_d     <= #`TCQ 0;
    `ifdef PCIE
    end else begin
      if (cur_data_credits_vld) begin
        fc_use_data_d   <= #`TCQ cur_data_credits;
      end
      fc_use_data_o     <= #`TCQ fc_use_data_d;
    `endif
    end
  end

  `ifdef PCIE
  //====================================================
  // Status register updates for the CMM's registers
  //====================================================
  // Output registers
  //-------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      stat_tlp_ep_o        <= #`TCQ 0;
      stat_tlp_cpl_ep_o    <= #`TCQ 0;
      stat_tlp_cpl_abort_o <= #`TCQ 0;
      stat_tlp_cpl_ur_o    <= #`TCQ 0;

    // at this point we know if the packet is valid so we
    //   can safely communicate these status fields to the
    //   cmm.. we can wait until eof5, because we might lose
    //   the ep bit when multiple packets are in the pipe for
    //   64 bit
    end else if (eof_q[out_d2] && !dsc_q[out_d2] && !next_cur_drop) begin
      stat_tlp_ep_o        <= #`TCQ cur_ep_q;
      stat_tlp_cpl_ep_o    <= #`TCQ cur_cpl_ep;
      stat_tlp_cpl_abort_o <= #`TCQ cur_cpl_abort;
      stat_tlp_cpl_ur_o    <= #`TCQ cur_cpl_ur;

    // all signals imply source ready, return to zero
    end else begin
      stat_tlp_ep_o        <= #`TCQ 0;
      stat_tlp_cpl_ep_o    <= #`TCQ 0;
      stat_tlp_cpl_abort_o <= #`TCQ 0;
      stat_tlp_cpl_ur_o    <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_cpl_ep    <= #`TCQ 0;
      cur_cpl_abort <= #`TCQ 0;
      cur_cpl_ur    <= #`TCQ 0;
    end else if (latch_2nd_dword_q2) begin
      // We need to know if completions are poisoned, or if have
      //   their status fields set to abort or ur.
      // We're stealing one cycle to keep these calcs valid for
      //   the output drivers
      if (cur_fulltype_oh[CPL_BIT]) begin
        cur_cpl_ep    <= #`TCQ cur_ep;
        cur_cpl_abort <= #`TCQ cur_cpl_stat == CPL_STAT_CA;
        cur_cpl_ur    <= #`TCQ cur_cpl_stat == CPL_STAT_UR;
      end else begin
        cur_cpl_ep    <= #`TCQ 0;
        cur_cpl_abort <= #`TCQ 0;
        cur_cpl_ur    <= #`TCQ 0;
      end
    end
  end

  //================================================================
  // In the case of malformed packets, communicate data to the CMM
  //   such that it can construct the completion header
  //================================================================
  always @(posedge clk_i) begin
    if (reset_i) begin
      err_tlp_malformed_o <= #`TCQ 0;
      err_tlp_ur_o        <= #`TCQ 0;
      err_tlp_ur_lock_o   <= #`TCQ 0;
      err_tlp_uc_o        <= #`TCQ 0;
      err_tlp_p_o         <= #`TCQ 0;
    // If the LNK signaled dsc, then the packet never happened
    //    if not, we can signal malformed
    //       if not malformed, we can signal ur or uc
    // wait until eof4/5 -> the earliest time bar misses are known
    //   as well as if the packet has invalid length
    // We don't need a return to 0 because eof is in the logic signal
    end else begin
      err_tlp_malformed_o <= #`TCQ  eof_nd_q[out_d2] &&  malformed;
      err_tlp_ur_o        <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_ur;
      err_tlp_ur_lock_o   <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_ur_lock;
      err_tlp_uc_o        <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_uc;
      // posted continuously valid -> no eof
      err_tlp_p_o         <= #`TCQ !np_o;
    end
  end

  // The header is only looked at if there was a problem, always latch
  always @(posedge clk_i) begin
    // In order to save 48 flops, steal some time by delaying capture of
    // err_tlp_cpl_header as long as possible.
    // In 64-bit, worst case is eof_q2 of next == eof_q4 of current.
    // Current errors are latched on eof_q4, so we need to wait until
    // AFTER eof_q2 of next to make sure the next err_tlp_cpl_header is
    // not associated with any current TLP error.
    if (!rhit_bar_lat3_i || (DW == 32)) begin
      if (eof_q[3]) begin
        err_tlp_cpl_header_o <= #`TCQ {cur_lower_addr, cur_byte_ct,
                                       cur_cpl_header_fmt};
      end

    // Unfortunately, we cannot do this in case of a three-clock BAR
    // latency with a 64-bit data path as the minimum TLP size is only
    // two clocks.
    end else begin
      if (eof_q[3]) begin
        err_tlp_cpl_header_d <= #`TCQ {cur_lower_addr, cur_byte_ct,
                                       cur_cpl_header_fmt};
      end
      err_tlp_cpl_header_o   <= #`TCQ err_tlp_cpl_header_d;
    end
  end

  always @(posedge clk_i) begin
    // For 64b, the most we can wait is 2 cycles for either 1st or
    //   2nd word. For 32b, we can wait 3 cycles on the 1st word
    //   because we are guaranteed a gap
    if (latch_2nd_dword_q2) begin
      cur_cpl_header_fmt <= #`TCQ {cur_tc, cur_attr, cur_req_id, cur_tag};
    end
  end
  `endif

  // Packets are dropped when they're malformed, unexpected/unsupported,
  // filtered or signaled sideband to the LLM such as power management.
  // This does not contain dsc, which has different credit rules. We
  // use the "next" signal in another place, which is why the flop is
  // split out from the logic cloud.
  //--------------------------------------------------------------------
  always @* begin
    if (eof_q[out_d2]) begin
      `ifdef PCIE
      next_cur_drop = malformed || tlp_ur || tlp_uc || cur_pm_msg_detect ||
                      tlp_filt || (!hotplug_msg_enable_i && cur_hp_msg_detect);
      `else // `ifdef AS
      next_cur_drop = bad_header_crc || bad_pi_chain || bad_credit_length ||
                      invalid_credit_length || non_zero_turn_pointer ||
                      unsup_ovc || unsup_mvc || filter_drop;
      `endif
    end else begin
      next_cur_drop = 0;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_drop      <= #`TCQ 0;
    end else begin
      cur_drop      <= #`TCQ next_cur_drop;
    end
  end

  //====================================================================
  // Instantiation of malformed checks/drops
  //                  power management checks/drops
  //                  bar hits/drops
  // These are scheduled when we know that the fields are able to be
  // latched. All power managment sidebands are not allowed to actually
  // activate until we know that the packet is sound.
  //====================================================================

  tlm_rx_data_snk_mal #(
    .DW                         (DW),
    .FCW                        (FCW),
    `ifdef PCIE
    .DOWNSTREAM_PORT            (DOWNSTREAM_PORT),
    `else // `ifdef AS
    .OVC                        (OVC),
    .MVC                        (MVC),
    `endif
    .MPS                        (MPS),
    .TYPE1_UR                   (TYPE1_UR))
  malformed_checks
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .sof_i                      (sof_i && src_rdy_i && !packet_ip),
    .eof_i                      (eof_i && src_rdy_i &&  packet_ip),
    `ifdef PCIE
    .rem_i                      (rem_i),
    `endif

    .eval_formats_i             (latch_2nd_dword_q1),
    .length_i                   (cur_length),
    `ifdef PCIE
    .length_1dw_i               (cur_length1),
    `endif
    .aperture_i                 (aperture),
    .load_aperture_i            (latch_3rd_dword),
    .offset_i                   (offset),

    `ifdef PCIE
    .eval_fulltype_i            (latch_1st_dword),
    .fulltype_i                 (fulltype_in),
    .eval_msgcode_i             (latch_2nd_dword),
    .msgcode_i                  (msgcode_in),

    .tc0_i                      (cur_tc0),
    .td_i                       (cur_td),
    .hit_src_rdy_i              (rhit_src_rdy),
    .hit_ack_i                  (rhit_ack),
    .hit_lock_i                 (rhit_lock),
    .hit_i                      (rhit_d),
    `else // `ifdef AS
    .oo_i                       (cur_oo),
    .ts_i                       (cur_ts),

    .pi_1st_i                   (pi_1st),
    .pi_2nd_i                   (pi_2nd),
    .pi_3rd_i                   (pi_3rd),
    .pi_4th_i                   (pi_4th),
    .load_pi_1st_i              (latch_1st_dword),
    .load_pi_2nd_i              (latch_3rd_dword),
    .load_pi_3rd_i              (latch_4th_dword),
    .load_pi_4th_i              (latch_5th_dword),

    .load_offset_i              (latch_4th_dword),

    .hcrc_i                     (cur_hcrc),
    .route_header_i             (cur_route_header),
    .turn_pointer_i             (cur_turn_pointer),
    .dir_i                      (cur_dir),
    `endif

    .data_credits_o             (cur_data_credits),
    .data_credits_vld_o         (cur_data_credits_vld),
    .cfg_o                      (cur_cfg),
    .hp_msg_detect_o            (cur_hp_msg_detect),
    `ifdef PCIE
    .malformed_o                (malformed),
    .tlp_ur_o                   (tlp_ur),
    .tlp_ur_lock_o              (tlp_ur_lock),
    .tlp_uc_o                   (tlp_uc),
    .tlp_filt_o                 (tlp_filt),
    `else // `ifdef AS
    .bad_header_crc_o           (bad_header_crc),
    .bad_pi_chain_o             (bad_pi_chain),
    .bad_credit_length_o        (bad_credit_length),
    .invalid_credit_length_o    (invalid_credit_length),
    .non_zero_turn_pointer_o    (non_zero_turn_pointer),
    .unsup_mvc_o                (unsup_mvc),
    .unsup_ovc_o                (unsup_ovc),
    .filter_drop_o              (filter_drop),
    `endif

    .max_payload_i              (max_payload_i),
    `ifdef PCIE
    .legacy_mode_i              (legacy_mode_i),
    .legacy_cfg_access_i        (legacy_cfg_access_i),
    .ext_cfg_access_i           (ext_cfg_access_i),
    .hit_lat3_i                 (rhit_bar_lat3_i),
    .pwr_mgmt_on_i              (pwr_mgmt_mode_on)
    `else // `ifdef AS
    .switch_mode_i              (switch_mode_i),
    .fabric_manager_mode_i      (fabric_manager_mode_i),
    .cmm_ap0_space_end_i        (cfg_ap0_space_end_i),
    .cmm_ap1_space_start_i      (cfg_ap1_space_start_i),
    .cmm_ap1_space_end_i        (cfg_ap1_space_end_i),
    .lnk_state_i                (lnk_state_i),
    .lnk_state_src_rdy_i        (lnk_state_src_rdy_i)
    `endif
    );

  `ifdef PCIE
  tlm_rx_data_snk_pwr_mgmt
  pwr_mgmt
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .pm_as_nak_l1_o             (pm_as_nak_l1_o),
    .pm_turn_off_o              (pm_turn_off_o),
    .pm_set_slot_pwr_o          (pm_set_slot_pwr_o),
    .pm_set_slot_pwr_data_o     (pm_set_slot_pwr_data_o),
    .pm_msg_detect_o            (cur_pm_msg_detect),
    // AS messages will get thrown out elsewhere as UR's
    .ismsg_i                    (cur_fulltype_oh[MSG_BIT]),
    .msgcode_i                  (cur_msgcode),
    .pwr_data_i                 (pwr_data_i),
    .eval_pwr_mgmt_i            (latch_2nd_dword_q2),
    // The set slot power field is not known at the same
    //   time as the message types
    .eval_pwr_mgmt_data_i       (latch_4th_dword_q1),
    // This is the first time we know the packet it correct
    //   -we only check bar hits for ROUTE_BY_ID, which is not
    //    allowed for any of the pwr mgmt message types
    // Messages are never completion types
    .act_pwr_mgmt_i             (eof_q[out_d3] && !(malformed || tlp_ur))
    );

  tlm_rx_data_snk_bar #(
    .BARW (BARW))
  bar_hit
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .check_raddr_o              (check_raddr_o),
    .check_rmem64_o             (check_mem64_o),
    .check_rmem32_o             (check_mem32_o),
    .check_rio_o                (check_rio_o),
    .check_rdev_id_o            (check_rdev_o),
    .check_rbus_id_o            (check_rbus_o),
    .check_rfun_id_o            (check_rfun_o),
    .check_rhit_bar_i           (check_rhit_bar_i),
    .check_rhit_i               (check_rhit_i),
    .check_rhit_bar_o           (rhit_bar_d),
    .check_rhit_o               (rhit_d),
    .check_rhit_src_rdy_o       (rhit_src_rdy),
    .check_rhit_ack_o           (rhit_ack),
    .check_rhit_lock_o          (rhit_lock),
    .addr_lo_i                  (addr_lo_i),
    .addr_hi_i                  (((DW == 32) && cur_fulltype_64) ?
                                 cur_addr_hi : addr_hi_in),
    .fulltype_oh_i              (cur_fulltype_oh),
    .mem64_i                    (cur_fulltype_64),
    .routing_i                  (cur_routing),
    .req_id_i                   (cur_req_id),
    .req_id_cpl_i               (req_id_cpl_in), // in 3rd dw, latch on 3rd
    .eval_check_i               (cur_fulltype_64 ? latch_4th_dword:
                                                   latch_3rd_dword),
    .rhit_lat3_i                (rhit_bar_lat3_i),
    .legacy_mode_i              (legacy_mode_i)
    );
  `endif

  `ifdef PCIE
  //===================================================================
  // Generate Byte Count and Lower Address fields for non-Successful
  // Completion Header using the byte enables as offsets, and the
  // byte counts as totals
  // Byte Count    from table 2-21, page 90 PCI 1.1 spec
  // Lower address from table 2-22, page 91 PCI 1.1 spec
  //===================================================================
  // convert the byte enable signals into actual bytes removed from
  //    the length field
  //--------------------------------------------------------------------------
  always @* begin
    casex (last_be_in)
      4'b1xxx: last_be_missing = 0;  // 1111 - all enabled, no offset
      4'b01xx: last_be_missing = 1;
      4'b001x: last_be_missing = 2;
      4'b0001: last_be_missing = 3;  // 0001 - 1 enabled, 3 offset
      default: last_be_missing = 0;
    endcase
    casex (first_be_in)
      4'bxxx1: first_be_missing = 0; // 1111 - all enabled, no offset
      4'bxx10: first_be_missing = 1; // 1110 - 1st 3 enabled, 1 offset
      4'bx100: first_be_missing = 2; // 1100 - 1st 2 enables, 2 offset
      4'b1000: first_be_missing = 3; // 1000 - 1st enabled, 3 offset
      default: first_be_missing = 0; // 0000 - no offset, 1 DW flush below
    endcase
    casex (first_be_in) // last_be_in must == 0000
      4'b1xx1: byte_ct_1dw      = 4;
      4'b01x1: byte_ct_1dw      = 3;
      4'b1x10: byte_ct_1dw      = 3;
      4'b0011: byte_ct_1dw      = 2;
      4'b0110: byte_ct_1dw      = 2;
      4'b1100: byte_ct_1dw      = 2;
      4'b0001: byte_ct_1dw      = 1;
      4'b0010: byte_ct_1dw      = 1;
      4'b0100: byte_ct_1dw      = 1;
      4'bx000: byte_ct_1dw      = 1;
    endcase
  end

  // Subtract from the total byte count (length x 4) based on the First
  // and Last DW BE fields.
  //--------------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_bytes_missing <= #`TCQ first_be_missing + last_be_missing;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_byte_ct_1dw   <= #`TCQ 0;
    end else if (latch_2nd_dword) begin
      cur_byte_ct_1dw   <= #`TCQ byte_ct_1dw;
    end
  end

  // We need to move the address forward to handle any empty bytes
  //   in the payload.. this will be the start of the first actual
  //   byte of payload
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_first_be_adj            <= #`TCQ 0;
    end else if (latch_2nd_dword) begin
      cur_first_be_adj            <= #`TCQ first_be_missing;
    end
  end

  //--------------------------------------------------------------------------
  // Determine the Byte Count for the CMM to create a completion
  //--------------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (latch_2nd_dword_q2) begin
      casex (cur_fulltype)
        MRD32, MRD64, MRD32LK, MRD64LK:
          // for a 1 dword length, the last be is not involved, so
          //   be sure not to use it
          if (cur_length1) begin
            cur_byte_ct       <= #`TCQ cur_byte_ct_1dw;
          end else begin
            // length is in words- total length is length*4
            // ..subtracting the bytes that don't particpate
            cur_byte_ct       <= #`TCQ {cur_length,2'b00} - cur_bytes_missing;
          end
        // The Byte Count is set to 4 for Completions other than Memory Read
        default:
          cur_byte_ct         <= #`TCQ 4;
      endcase
    end
  end

  //--------------------------------------------------------------------------
  // Lower Address is calculated from the Address field for Memory Reads,
  // and is set to zero for all other transaction types. The lower address is
  // taken from the third dword in MR32 and from the fourth dword in MR64.
  //--------------------------------------------------------------------------

  always @(posedge clk_i) begin
    if (cur_fulltype_64) begin
      if (latch_4th_dword_q1) begin
        if (cur_fulltype_mem) begin
          cur_lower_addr[6:2]   <= #`TCQ lower_addr64_in_q;
        end else begin
          cur_lower_addr[6:2]   <= #`TCQ 0;
        end
      end
    end else begin
      if (latch_3rd_dword_q1) begin
        if (cur_fulltype_mem) begin
          cur_lower_addr[6:2]   <= #`TCQ lower_addr32_in_q;
        end else begin
          cur_lower_addr[6:2]   <= #`TCQ 0;
        end
      end
    end
  end

  // The lower two bits are based on the First DW Byte Enables.
  always @(posedge clk_i) begin
    if (latch_3rd_dword_q1) begin
      if (cur_fulltype_mem) begin
        cur_lower_addr[1:0]     <= #`TCQ cur_first_be_adj;
      end else begin
        cur_lower_addr[1:0]     <= #`TCQ 0;
      end
    end
  end

  always @(posedge clk_i) begin
    lower_addr32_in_q           <= #`TCQ lower_addr32_in;
    lower_addr64_in_q           <= #`TCQ lower_addr64_in;
  end

  //=======================================================================
  // If directed to go to into management, let the current packet
  //   complete, then reject following packets - used in malformed checks
  //=======================================================================
  always @(posedge clk_i) begin
    if (reset_i) begin
      pwr_mgmt_mode_on            <= #`TCQ 0;
    end else if (sof_i) begin
      pwr_mgmt_mode_on            <= #`TCQ pm_suspend_req_i;
    end
  end
  `endif // `ifdef PCIE

  //=====================================================================
  // Datapath pipe and associated control logic
  //   there are only resets where absolutely required as we want
  //   to infer SRLs wherever possible
  //=====================================================================

  // used to create clean local link packets... concatenating two packets
  //   together because one had bad signalling will results in a malformed
  //   packet, so we are covered
  //---------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_ip                   <= #`TCQ 0;
    end else if (src_rdy_i) begin
      packet_ip                   <= #`TCQ (sof_i || packet_ip) && !eof_i;
    end
  end
  //--------------------------------------------------------------------------
  // The last qword of the frame is removed if it doesn't contain any header
  //   or data information (contain only an unaligned TD dword)
  // If the TD is in the lower dword of the last qword, it is disabled by
  //   inverting rem for 64b
  //--------------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      remove_lastword         <= #`TCQ 0;
    end else begin
      // defer calc until needed due to packet overlap
      if (eof_q[3]) begin
        if (DW == 64) begin
          remove_lastword   <= #`TCQ !cur_rem && (cur_td_q && td_ecrc_trim_i);
        end else begin
          remove_lastword   <= #`TCQ cur_td_q && td_ecrc_trim_i;
        end
      end else if (eof_o) begin
        remove_lastword     <= #`TCQ 0;
      end
    end
  end


  // Control pipe
  //-------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      sof_q[1]             <= #`TCQ 0;
      eof_q[1]             <= #`TCQ 0;
      src_rdy_q[1]         <= #`TCQ 0;
      rem_q[1]             <= #`TCQ 1;
      dsc_q[1]             <= #`TCQ 0;
      eof_nd_q[1]          <= #`TCQ 0;

      sof_o                <= #`TCQ 0;
    end else begin
      // gate the input signals with src_rdy, and ensure valid
      //    local link signalling
      sof_q[1]             <= #`TCQ sof_i && src_rdy_i && !packet_ip;
      eof_q[1]             <= #`TCQ eof_i && src_rdy_i && packet_ip;
      src_rdy_q[1]         <= #`TCQ src_rdy_i && (packet_ip || sof_i);
      dsc_q[1]             <= #`TCQ eof_i && src_rdy_i && packet_ip
                                    && src_dsc_i;
      eof_nd_q[1]          <= #`TCQ eof_i && src_rdy_i && packet_ip
                                    && !src_dsc_i;
      // if we have rem, only modify it if we are actually removing the digest
      if (DW == 64) begin
        if (eof_i) begin
          rem_q[1]         <= #`TCQ rem_i ^ (cur_td && td_ecrc_trim_i);
          cur_rem          <= #`TCQ rem_i;
        end else begin
          rem_q[1]         <= #`TCQ 1;
        end
      end else begin
        rem_q[1]           <= #`TCQ 1;
        cur_rem            <= #`TCQ 1;
      end

      sof_o                <= #`TCQ sof_q[out_d1];
    end
  end
  // Mux for last word when digest removal requires a forward. Turn off
  // src_rdy_o for one cycle if the last (unadjusted) data beat is
  // unaligned in 64-bit. In 32-bit, this cycle is always invalidated.
  always @(posedge clk_i) begin
    if (reset_i) begin
      src_rdy_o          <= #`TCQ 0;
      dsc_o              <= #`TCQ 0;
      rem_o              <= #`TCQ 1;
      eof_o              <= #`TCQ 0;
      preeof_o           <= #`TCQ 0;
    end else if (remove_lastword) begin
      if (!eof_o) begin
        src_rdy_o        <= #`TCQ src_rdy_q[out_d2];

      // Note that rem_q has already been adjusted for ECRC trim by this
      // point so that, in a 64-bit system, an UNaligned indicator means
      // that the trimming has NOT blanked out the original EOF quadword
      // completely. Thus the original src_rdy is still valid.
      end else if ((DW == 64) && !rem_q[out_d2]) begin
        src_rdy_o        <= #`TCQ src_rdy_q[out_d2];
      end else begin
        src_rdy_o        <= #`TCQ 1'b0;
      end
      dsc_o              <= #`TCQ dsc_q[out_d2] ||
                                 (eof_q[out_d2] && next_cur_drop);
      rem_o              <= #`TCQ (DW == 64) ? rem_q[out_d2] : 1'b1;
      eof_o              <= #`TCQ eof_q[out_d2];
      preeof_o           <= #`TCQ eof_q[out_d3];
    end else begin
                                  // Special case to filter src_rdy_o
                                  // when eof is moved forward across
                                  // DWORD boundaries due to ECRC trimming
      src_rdy_o          <= #`TCQ src_rdy_q[out_d1] &&
                                  !(eof_o && !sof_q[out_d1]);
      dsc_o              <= #`TCQ dsc_q[out_d1] || (eof_q[out_d1] && cur_drop);
      rem_o              <= #`TCQ (DW == 64) ?  rem_q[out_d1] : 1'b1;
      eof_o              <= #`TCQ eof_q[out_d1];
      preeof_o           <= #`TCQ eof_q[out_d2];
    end
  end
  // we want SRLs for the internal stages
  //   we've got resets on the input/output -> the middles will resolve
  always @(posedge clk_i) begin
    sof_q[6:2]         <= #`TCQ sof_q[5:1];
    eof_q[6:2]         <= #`TCQ eof_q[5:1];
    src_rdy_q[6:2]     <= #`TCQ src_rdy_q[5:1];
    dsc_q[6:2]         <= #`TCQ dsc_q[5:1];
    rem_q[6:2]         <= #`TCQ (DW == 64) ? rem_q[5:1] : 5'h1f;
    eof_nd_q[6:2]      <= #`TCQ eof_nd_q[5:1];
  end

  `ifdef PCIE
  // In PCIe, if we are dropping the digest, we don't want to tell the
  // downstream logic that we have one. It's a bit ugly, but it creates
  // only one extra flop instead of a whole word.
  assign d_mux = (sof_i && td_ecrc_trim_i) ?
                 {d_i[DW-1:TD_IND+1], 1'b0, d_i[TD_IND-1:0]} : d_i;
  `else // `ifdef AS
  // In AS, even if we trim the packet CRC, we still want to tell the
  // Read Monitor that PCRC existed, so it can be counted toward credit
  // reallocation. The FIFO will turn off the PCRC bit later so that the
  // packet looks clean to the user.
  assign d_mux = d_i;
  `endif

  // Data pipe
  always @(posedge clk_i) begin
    d_q1                 <= #`TCQ d_mux;
    d_q2                 <= #`TCQ d_q1;
    d_q3                 <= #`TCQ d_q2;
    d_q4                 <= #`TCQ d_q3;
    d_q5                 <= #`TCQ d_q4;
    d_q6                 <= #`TCQ d_q5;
    case (out_d1)
      5:       d_o       <= #`TCQ d_q5;
      6:       d_o       <= #`TCQ d_q6;
      default: d_o       <= #`TCQ d_q4;
    endcase
  end

  // Tell the LLM that a TLP has been received, so that it can exit
  // FC_INIT2 if necessary. This signal stays asserted for the life of
  // device operation, until the next system reset.

  always @(posedge clk_i) begin
    if (reset_i) begin
      vc_hit_o           <= #`TCQ 1'b0;
    end else if (src_rdy_o && eof_o && !dsc_o) begin
      vc_hit_o           <= #`TCQ 1'b1;
    end
  end


  // Latch the side bands signals that the FIFO needs which are valid at eof
  // We never have to worry about mal/ur/uc checks here.. but we do need
  //   to worry about back-to-back packets.
  // We can have up to three packets in the pipeline on any given time
  //   we need three copies of the registers
  //-----------------------------------------------------------------------
  always @(posedge clk_i) begin
    `ifdef PCIE
    if (!rhit_bar_lat3_i || (DW == 32))
    `endif
    begin
      if (latch_1st_dword_q4) begin
        `ifdef PCIE
        cpl_o           <= #`TCQ cur_cpl;
        locked_o        <= #`TCQ cur_locked_q;
        vend_msg_o      <= #`TCQ cur_vend_msg;
        `endif
        np_o            <= #`TCQ cur_np;
        cfg_o           <= #`TCQ cur_cfg;
      end
    end
    `ifdef PCIE
    else begin
      if (latch_1st_dword_q4) begin
        np_d            <= #`TCQ cur_np;
        cpl_d           <= #`TCQ cur_cpl;
        locked_d        <= #`TCQ cur_locked_q;
        cfg_d           <= #`TCQ cur_cfg;
        vend_msg_d      <= #`TCQ vend_msg_d;
      end

      np_o              <= #`TCQ np_d;
      cpl_o             <= #`TCQ cpl_d;
      locked_o          <= #`TCQ locked_d;
      cfg_o             <= #`TCQ cfg_d;
      vend_msg_o        <= #`TCQ vend_msg_d;
    end
    `endif
  end

  always @(posedge clk_i) begin
    if (latch_1st_dword_q2) begin
      `ifdef PCIE
      cur_ep_q          <= #`TCQ cur_ep;
      cur_cpl           <= #`TCQ cur_fulltype_oh[CPL_BIT];
      cur_locked_q      <= #`TCQ cur_locked;
      // These are the POSTED types
      cur_np            <= #`TCQ !cur_fulltype_oh[MWR_BIT] &&
                                 !cur_fulltype_oh[MSG_BIT] &&
                                 !cur_fulltype_oh[CPL_BIT];
      `else // `ifdef AS
      cur_np            <= #`TCQ !cur_oo && cur_ts;
      `endif
      cur_td_q          <= #`TCQ cur_td;
    end
  end

  `ifdef PCIE
  always @(posedge clk_i) begin
    if (latch_2nd_dword_q2) begin
      cur_vend_msg      <= #`TCQ ((cur_msgcode == VENDOR_DEFINED_TYPE_0) ||
                                  (cur_msgcode == VENDOR_DEFINED_TYPE_1)) &&
                                 cur_fulltype_oh[MSG_BIT];
    end
  end
  `endif

  `ifdef PCIE
  // Bar has come back from the CMM when src_rdy is true.
  // If the packet type needs bar set to 0, the bar block
  //    has already done this for us
  // Assert rid_o if the requester ID matches (used for completions)
  //------------------------------------------------------
  always @(posedge clk_i) begin
    if (rhit_src_rdy) begin
      bar_o                     <= #`TCQ rhit_bar_d;
      rid_o                     <= #`TCQ rhit_d;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      bar_src_rdy_o             <= #`TCQ 0;
    end else if (rhit_src_rdy) begin
      bar_src_rdy_o             <= #`TCQ 1;
    end else begin
      bar_src_rdy_o             <= #`TCQ 0;
    end
  end
  `else // `ifdef AS
  // Latch the OO and TS bits for Bypassable determination.

  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_oo               <= #`TCQ d_i[OO_IND];
      cur_ts               <= #`TCQ d_i[TS_IND];
    end
  end
  `endif

  //=======================================================================
  // Latch the data fields as the packet arrives into the core
  //=======================================================================
  // Delayed versions of control signals
  //-----------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      latch_1st_dword_q1 <= #`TCQ 0;
      latch_1st_dword_q2 <= #`TCQ 0;
      latch_1st_dword_q3 <= #`TCQ 0;
      latch_1st_dword_q4 <= #`TCQ 0;
      latch_2nd_dword_q1 <= #`TCQ 0;
      latch_2nd_dword_q2 <= #`TCQ 0;
      latch_3rd_dword_q1 <= #`TCQ 0;
      latch_4th_dword_q1 <= #`TCQ 0;
    end else begin
      latch_1st_dword_q1 <= #`TCQ latch_1st_dword;
      latch_1st_dword_q2 <= #`TCQ latch_1st_dword_q1;
      latch_1st_dword_q3 <= #`TCQ latch_1st_dword_q2;
      latch_1st_dword_q4 <= #`TCQ latch_1st_dword_q3;
      latch_2nd_dword_q1 <= #`TCQ latch_2nd_dword;
      latch_2nd_dword_q2 <= #`TCQ latch_2nd_dword_q1;
      latch_3rd_dword_q1 <= #`TCQ latch_3rd_dword;
      latch_4th_dword_q1 <= #`TCQ latch_4th_dword;
    end
  end

  // fields valid on this packet
  //-----------------------------------------------------------------------
  // NOTE: The following attributes were added for XST synthesis of the
  // PCIe Block Plus project. They are needed to make 250 MHz in a V-5,
  // but it is very likely that they will have to be removed/disabled for
  // V-4 and V-IIPro.
  // synthesis attribute use_clock_enable of cur_td is no;
  // synthesis attribute use_clock_enable of cur_length is no;
  // synthesis attribute use_clock_enable of cur_tc is no;
  // synthesis attribute use_clock_enable of cur_tc0 is no;
  // synthesis attribute use_clock_enable of cur_ep is no;
  // synthesis attribute use_clock_enable of cur_attr is no;
  // synthesis attribute use_clock_enable of cur_length1 is no;
  // synthesis attribute use_clock_enable of cur_fulltype is no;

  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_td                    <= #`TCQ td_in;
      cur_length                <= #`TCQ length_in;
      `ifdef PCIE
      cur_tc                    <= #`TCQ tc_in;
      cur_tc0                   <= #`TCQ tc_in == 0;
      cur_ep                    <= #`TCQ ep_in;
      cur_attr                  <= #`TCQ attr_in;
      cur_length1               <= #`TCQ length_in == 1;
      cur_fulltype              <= #`TCQ fulltype_in;
      casex (fulltype_in)
        MRD32, MRD32LK, MWR32, MRD64, MRD64LK, MWR64:
          cur_fulltype_mem      <= #`TCQ 1;
        default:
          cur_fulltype_mem      <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        MRD64, MRD64LK, MWR64:
          cur_fulltype_64       <= #`TCQ 1;
        default:
          cur_fulltype_64       <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        MRD32, MRD64:
          cur_fulltype_oh       <= #`TCQ MRDANY;
        MWR32, MWR64:
          cur_fulltype_oh       <= #`TCQ MWRANY;
        MRD32LK, MRD64LK:
          cur_fulltype_oh       <= #`TCQ MLKANY;
        IORD, IOWR:
          cur_fulltype_oh       <= #`TCQ IOANY;
        CFGRD0, CFGWR0, CFGRD1, CFGWR1:
          cur_fulltype_oh       <= #`TCQ CFGANY;
        MSG, MSGD:
          cur_fulltype_oh       <= #`TCQ MSGANY;
        CPL, CPLD, CPLLK, CPLDLK:
          cur_fulltype_oh       <= #`TCQ CPLANY;
        default: // don't want MSGAS to alias other types
          cur_fulltype_oh       <= #`TCQ OTHERTYPE;
      endcase
      casex (fulltype_in)
        MRD32LK, MRD64LK, CPLLK, CPLDLK:
          cur_locked            <= #`TCQ 1;
        default:
          cur_locked            <= #`TCQ 0;
      endcase
      `else // `ifdef AS
      cur_hcrc          <= #`TCQ d_i[HCRC_HI_IND:HCRC_LO_IND];
      cur_turn_pointer  <= #`TCQ d_i[TURN_PTR_HI_IND:TURN_PTR_LO_IND];
      `endif
    end
  end

  `ifdef PCIE
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_req_id                <= #`TCQ req_id_in;
      cur_tag                   <= #`TCQ tag_in;
      cur_msgcode               <= #`TCQ msgcode_in;
      cur_cpl_stat              <= #`TCQ cpl_stat_in;
    end
  end

  // Store the High Address field for a 64-bit memory address (only
  // needed with the 32-bit datapath)
  //--------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (latch_3rd_dword) begin
      cur_addr_hi               <= #`TCQ addr_hi_in;
    end
  end
  `else // `ifdef AS

  // Store the Direction bit for Turn Pointer check
  //--------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_dir                   <= #`TCQ d_i[DIR_IND];
    end
  end

  // Store the Route Header for HCRC check
  //--------------------------------------------------------------------
  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_route_header[50:32]   <= #`TCQ d_i[DW-14:DW-32];
    end
    if (latch_2nd_dword) begin
      cur_route_header[31:0]    <= #`TCQ d_i[31:0];
    end
  end
  `endif

  `ifdef AS
  //====================================================================
  // Error Reporting
  //====================================================================
  // All errors detected by AS data_snk are Type B events. A Type B
  // event must be reported with the first 5 DW of the offending packet.
  // Because the CMM must process the event and send out a PI-5 event
  // before it can digest the next one, we must wait for acknowledgment
  // of a Type B event before we can report a new one. This means that
  // we may need to forgo report of any Type B events while we are
  // waiting for the CMM's reply.
  //--------------------------------------------------------------------

  // Capture the header information in case of a Type B event. Read it
  // out and forward it to the CMM if a previous event is not pending.
  //--------------------------------------------------------------------

  tlm_srl_fifo
    #(.DW       (DW),
      .DMW      (DW+1), // Mark each header's SOF
      .DEPTH    (7),
      .CT_OUT   (0))
  buf_fifo
     (.clk_i    (clk_i),
      .reset_i  (reset_i),
      .wen_i    (wr_hdr),
      .d_i      ({sof_i,d_i}),
      .ren_i    (rd_hdr),
      .d_o      ({hdr_sof,hdr}),
      .vld_o    (),
      .nxt_vld_o(),
      .ct_o     (),
      .chkpt_i  (1'b1),
      .bkp_i    (1'b0)
      );

  // Write any of the first 5 DWORDs to the queue.

  assign wr_hdr = (latch_1st_dword && !packet_ip) ||
                   latch_2nd_dword || latch_3rd_dword ||
                   latch_4th_dword || latch_5th_dword;

  // Read out of the queue when we're about to see the result of the
  // error checks. Don't append the start of the next packet.

  generate
    if (DW == 64) begin : rd_hdr_64
      assign rd_hdr = eof_q[1] || (|eof_q[3:2] || !sof_hdr);
    end else begin : rd_hdr_32
      assign rd_hdr = eof_o    || (|eof_q[4:1] || !sof_hdr);
    end
  endgenerate

  // Read into the header output register if a Type B is not already
  // pending. Since the queue must synchronize with the data stream, any
  // headers received while waiting for a Type B acknowledgment will be
  // read from the queue and silently dropped.

  always @* load_type_b[0] = !type_b_pending &&
                             ((DW == 64) ? eof_q[1] :
                                          (eof_i && src_rdy_i && packet_ip));

  always @(posedge clk_i) begin
    load_type_b[5:1] <= #`TCQ load_type_b[4:0];
  end

  wire latch_1st_hdr_dword = load_type_b[0];
  wire latch_2nd_hdr_dword = (DW == 64) ? load_type_b[0] : load_type_b[1];
  wire latch_3rd_hdr_dword = (DW == 64) ? load_type_b[1] : load_type_b[2];
  wire latch_4th_hdr_dword = (DW == 64) ? load_type_b[1] :
                                         (load_type_b[3] && !sof_hdr);
  wire latch_5th_hdr_dword = (DW == 64) ?(load_type_b[2] && !sof_hdr) :
                                         (load_type_b[4] && !sof_hdr);
  localparam UPPER_HI_IND = DW-1;
  localparam UPPER_LO_IND = DW-32;
  localparam LOWER_HI_IND = 31;
  localparam LOWER_LO_IND = 0;

  always @(posedge clk_i) begin
    if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[159:128]<= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end

    if (latch_2nd_hdr_dword) begin
      err_tlp_type_b_header_o[127:96] <= #`TCQ hdr[LOWER_HI_IND:LOWER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[127:96] <= #`TCQ 0;
    end

    if (latch_3rd_hdr_dword) begin
      err_tlp_type_b_header_o[95:64]  <= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[95:64]  <= #`TCQ 0;
    end

    if (latch_4th_hdr_dword) begin
      err_tlp_type_b_header_o[63:32]  <= #`TCQ hdr[LOWER_HI_IND:LOWER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[63:32]  <= #`TCQ 0;
    end

    if (latch_5th_hdr_dword) begin
      err_tlp_type_b_header_o[31:0]   <= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[31:0]   <= #`TCQ 0;
    end
  end

  // Synchronize the data_snk_mal error flags to the Type B header.

  // In 64-bit, the header is available following the 3rd quadword.
  // In 32-bit, the header is available following the 5th doubleword.

  localparam Q2HDR   = (DW == 64) ? 3 : 5;

  // In 64-bit, the header is available following EOF + 3.
  // In 32-bit, the header is available following EOF + 4.

  localparam EOF2HDR = (DW == 64) ? 3 : 4;

  always @(posedge clk_i) begin
    if (reset_i) begin
      err_tlp_bad_header_crc_o        <= #`TCQ 0;
      err_tlp_bad_pi_chain_o          <= #`TCQ 0;
      err_tlp_invalid_credit_length_o <= #`TCQ 0;
      err_tlp_bad_credit_length_o     <= #`TCQ 0;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ 0;
      err_tlp_unsup_ovc_o             <= #`TCQ 0;
      err_tlp_unsup_mvc_o             <= #`TCQ 0;

    // load_type_b makes sure we stored the current header (i.e., a
    // previous Type B was not pending). eof_nd_q makes sure the packet
    // wasn't discontinued.
    end else if (load_type_b[Q2HDR] && eof_nd_q[EOF2HDR]) begin
      err_tlp_bad_header_crc_o        <= #`TCQ bad_header_crc;
      err_tlp_bad_pi_chain_o          <= #`TCQ bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_invalid_credit_length_o <= #`TCQ invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_bad_credit_length_o     <= #`TCQ bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_unsup_mvc_o             <= #`TCQ unsup_mvc &&
                                              !non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_unsup_ovc_o             <= #`TCQ unsup_ovc &&
                                              !unsup_mvc &&
                                              !non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
    end else begin
      err_tlp_bad_header_crc_o        <= #`TCQ 0;
      err_tlp_bad_pi_chain_o          <= #`TCQ 0;
      err_tlp_invalid_credit_length_o <= #`TCQ 0;
      err_tlp_bad_credit_length_o     <= #`TCQ 0;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ 0;
      err_tlp_unsup_mvc_o             <= #`TCQ 0;
      err_tlp_unsup_ovc_o             <= #`TCQ 0;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      type_b_pending <= #`TCQ 0;
    end else if (eof_nd_q[EOF2HDR] && load_type_b[Q2HDR]) begin
      type_b_pending <= #`TCQ bad_header_crc || bad_pi_chain ||
                              invalid_credit_length || bad_credit_length ||
                              non_zero_turn_pointer || unsup_mvc || unsup_ovc;
    end else if (err_tlp_type_b_ack_i) begin
      type_b_pending <= #`TCQ 0;
    end
  end
  `endif

  // synthesis translate_off
  `ifdef PCIE
  reg [10*8:0] cur_type_str;
  always @* begin
    casex (cur_fulltype)
      MRD32   :  begin cur_type_str = "MRD32";  end
      MRD64   :  begin cur_type_str = "MRD64";  end
      MRD32LK :  begin cur_type_str = "MRD32LK";end
      MRD64LK :  begin cur_type_str = "MRD64LK";end
      MWR32   :  begin cur_type_str = "MWR32";  end
      MWR64   :  begin cur_type_str = "MWR64";  end
      IORD    :  begin cur_type_str = "IORD";   end
      IOWR    :  begin cur_type_str = "IOWR";   end
      CFGRD0  :  begin cur_type_str = "CFGRD0"; end
      CFGWR0  :  begin cur_type_str = "CFGWR0"; end
      CFGRD1  :  begin cur_type_str = "CFGRD1"; end
      CFGWR1  :  begin cur_type_str = "CFGWR1"; end
      MSG     :  begin cur_type_str = "MSG";    end
      MSGD    :  begin cur_type_str = "MSGD";   end
      MSGAS   :  begin cur_type_str = "MSGAS";  end
      MSGASD  :  begin cur_type_str = "MSGASD"; end
      CPL     :  begin cur_type_str = "CPL";    end
      CPLD    :  begin cur_type_str = "CPLD";   end
      CPLLK   :  begin cur_type_str = "CPLLK";  end
      CPLDLK  :  begin cur_type_str = "CPLDLK"; end
      default :  begin cur_type_str = "undef";  end
    endcase
  end
  reg [30*8:0] cur_msgstr;
  always @* begin
    case (cur_msgcode)
      UNLOCK                    : cur_msgstr = "UNLOCK";
      PM_ACTIVE_STATE_NAK       : cur_msgstr = "PM_ACTIVE_STATE_NAK";
      PM_PME                    : cur_msgstr = "PM_PME";
      PME_TURN_OFF              : cur_msgstr = "PME_TURN_OFF";
      PME_TO_ACK                : cur_msgstr = "PME_TO_ACK";
      ATTENTION_INDICATOR_OFF   : cur_msgstr = "ATTENTION_INDICATOR_OFF";
      ATTENTION_INDICATOR_ON    : cur_msgstr = "ATTENTION_INDICATOR_ON";
      ATTENTION_INDICATOR_BLINK : cur_msgstr = "ATTENTION_INDICATOR_BLINK";
      POWER_INDICATOR_ON        : cur_msgstr = "POWER_INDICATOR_ON";
      POWER_INDICATOR_BLINK     : cur_msgstr = "POWER_INDICATOR_BLINK";
      POWER_INDICATOR_OFF       : cur_msgstr = "POWER_INDICATOR_OFF";
      ATTENTION_BUTTON_PRESSED  : cur_msgstr = "ATTENTION_BUTTON_PRESSED";
      SET_SLOT_POWER_LIMIT      : cur_msgstr = "SET_SLOT_POWER_LIMIT";
      VENDOR_DEFINED_TYPE_0     : cur_msgstr = "VENDOR_DEFINED_TYPE_0";
      VENDOR_DEFINED_TYPE_1     : cur_msgstr = "VENDOR_DEFINED_TYPE_1";
      default                   : cur_msgstr = "undef";
    endcase
  end
  `endif
  // synthesis translate_on

endmodule
