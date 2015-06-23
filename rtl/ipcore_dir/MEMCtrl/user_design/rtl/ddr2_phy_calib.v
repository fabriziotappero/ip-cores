//*****************************************************************************
// (c) Copyright 2006-2009 Xilinx, Inc. All rights reserved.
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
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_phy_calib.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Thu Aug 10 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module handles calibration after memory initialization.
//Reference:
//Revision History:
//   Rev 1.1 - Default statement is added for the CASE statement of
//             rdd_mux_sel logic. PK. 03/23/09
//   Rev 1.2 - Change training pattern detected for stage 3 calibration.
//             Use 2-bits per DQS group for stage 3 pattern detection.
//             RC. 09/21/09
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_calib #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter DQ_WIDTH      = 72,
   parameter DQ_BITS       = 7,
   parameter DQ_PER_DQS    = 8,
   parameter DQS_BITS      = 4,
   parameter DQS_WIDTH     = 9,
   parameter ADDITIVE_LAT  = 0,
   parameter CAS_LAT       = 5,
   parameter REG_ENABLE    = 1,
   parameter CLK_PERIOD    = 3000,
   parameter SIM_ONLY      = 0,
   parameter DEBUG_EN      = 0
   )
  (
   input                                   clk,
   input                                   clkdiv,
   input                                   rstdiv,
   input [3:0]                             calib_start,
   input                                   ctrl_rden,
   input                                   phy_init_rden,
   input [DQ_WIDTH-1:0]                    rd_data_rise,
   input [DQ_WIDTH-1:0]                    rd_data_fall,
   input                                   calib_ref_done,
   output reg [3:0]                        calib_done,
   output reg                              calib_ref_req,
   output [DQS_WIDTH-1:0]                  calib_rden,
   output reg [DQS_WIDTH-1:0]              calib_rden_sel,
   output reg                              dlyrst_dq,
   output reg [DQ_WIDTH-1:0]               dlyce_dq,
   output reg [DQ_WIDTH-1:0]               dlyinc_dq,
   output reg                              dlyrst_dqs,
   output reg [DQS_WIDTH-1:0]              dlyce_dqs,
   output reg [DQS_WIDTH-1:0]              dlyinc_dqs,
   output reg [DQS_WIDTH-1:0]              dlyrst_gate,
   output reg [DQS_WIDTH-1:0]              dlyce_gate,
   output reg [DQS_WIDTH-1:0]              dlyinc_gate,
   //(* XIL_PAR_NO_REG_ORDER = "TRUE", XIL_PAR_PATH="Q->u_iodelay_dq_ce.DATAIN", syn_keep = "1", keep = "TRUE"*)
   output [DQS_WIDTH-1:0]                  en_dqs,
   output [DQS_WIDTH-1:0]                  rd_data_sel,
   // Debug signals (optional use)
   input                                   dbg_idel_up_all,
   input                                   dbg_idel_down_all,
   input                                   dbg_idel_up_dq,
   input                                   dbg_idel_down_dq,
   input                                   dbg_idel_up_dqs,
   input                                   dbg_idel_down_dqs,
   input                                   dbg_idel_up_gate,
   input                                   dbg_idel_down_gate,
   input [DQ_BITS-1:0]                     dbg_sel_idel_dq,
   input                                   dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                      dbg_sel_idel_dqs,
   input                                   dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                      dbg_sel_idel_gate,
   input                                   dbg_sel_all_idel_gate,
   output [3:0]                            dbg_calib_done,
   output [3:0]                            dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]               dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]              dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]              dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                  dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]              dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]              dbg_calib_gate_dly
   );

  // minimum time (in IDELAY taps) for which capture data must be stable for
  // algorithm to consider
  localparam MIN_WIN_SIZE = 5;
  // IDEL_SET_VAL = (# of cycles - 1) to wait after changing IDELAY value
  // we only have to wait enough for input with new IDELAY value to
  // propagate through pipeline stages.
  localparam IDEL_SET_VAL = 3'b111;
  // # of clock cycles to delay read enable to determine if read data pattern
  // is correct for stage 3/4 (RDEN, DQS gate) calibration
  localparam CALIB_RDEN_PIPE_LEN = 31;
  // translate CAS latency into number of clock cycles for read valid delay
  // determination. Really only needed for CL = 2.5 (set to 2)
  localparam CAS_LAT_RDEN = (CAS_LAT == 25) ? 2 : CAS_LAT;
  // an SRL32 is used to delay CTRL_RDEN to generate read valid signal. This
  // is min possible value delay through SRL32 can be
  localparam RDEN_BASE_DELAY = CAS_LAT_RDEN + ADDITIVE_LAT + REG_ENABLE;
  // an SRL32 is used to delay the CTRL_RDEN from the read postamble DQS
  // gate. This is min possible value the SRL32 delay can be:
  //  - Delay from end of deassertion of CTRL_RDEN to last falling edge of
  //    read burst = 3.5 (CTRL_RDEN -> CAS delay) + 3 (min CAS latency) = 6.5
  //  - Minimum time for DQS gate circuit to be generated:
  //      * 1 cyc to register CTRL_RDEN from controller
  //      * 1 cyc after RDEN_CTRL falling edge
  //      * 1 cyc min through SRL32
  //      * 1 cyc through SRL32 output flop
  //      * 0 (<1) cyc of synchronization to DQS domain via IDELAY
  //      * 1 cyc of delay through IDDR to generate CE to DQ IDDR's
  //    Total = 5 cyc < 6.5 cycles
  //    The total should be less than 5.5 cycles to account prop delays
  //    adding one cycle to the synchronization time via the IDELAY.
  //    NOTE: Value differs because of optional pipeline register added
  //      for case of RDEN_BASE_DELAY > 3 to improve timing
  localparam GATE_BASE_DELAY = RDEN_BASE_DELAY - 3;
  localparam GATE_BASE_INIT = (GATE_BASE_DELAY <= 1) ? 0 : GATE_BASE_DELAY;
  // used for RDEN calibration: difference between shift value used during
  // calibration, and shift value for actual RDEN SRL. Only applies when
  // RDEN edge is immediately captured by CLKDIV0. If not (depends on phase
  // of CLK0 and CLKDIV0 when RDEN is asserted), then add 1 to this value.
  localparam CAL3_RDEN_SRL_DLY_DELTA = 6;
  // fix minimum value of DQS to be 1 to handle the case where's there's only
  // one DQS group. We could also enforce that user always inputs minimum
  // value of 1 for DQS_BITS (even when DQS_WIDTH=1). Leave this as safeguard
  // Assume we don't have to do this for DQ, DQ_WIDTH always > 1
  localparam DQS_BITS_FIX = (DQS_BITS == 0) ? 1 : DQS_BITS;
  // how many taps to "pre-delay" DQ before stg 1 calibration - not needed for
  // current calibration, but leave for debug
  localparam DQ_IDEL_INIT = 6'b000000;
  // # IDELAY taps per bit time (i.e. half cycle). Limit to 63.
  localparam integer BIT_TIME_TAPS = (CLK_PERIOD/150 < 64) ?
             CLK_PERIOD/150 : 63;

  // used in various places during stage 4 cal: (1) determines maximum taps
  // to increment when finding right edge, (2) amount to decrement after
  // finding left edge, (3) amount to increment after finding right edge
  localparam CAL4_IDEL_BIT_VAL = (BIT_TIME_TAPS >= 6'b100000) ?
             6'b100000 : BIT_TIME_TAPS;

  localparam CAL1_IDLE                   = 4'h0;
  localparam CAL1_INIT                   = 4'h1;
  localparam CAL1_INC_IDEL               = 4'h2;
  localparam CAL1_FIND_FIRST_EDGE        = 4'h3;
  localparam CAL1_FIRST_EDGE_IDEL_WAIT   = 4'h4;
  localparam CAL1_FOUND_FIRST_EDGE_WAIT  = 4'h5;
  localparam CAL1_FIND_SECOND_EDGE       = 4'h6;
  localparam CAL1_SECOND_EDGE_IDEL_WAIT  = 4'h7;
  localparam CAL1_CALC_IDEL              = 4'h8;
  localparam CAL1_DEC_IDEL               = 4'h9;
  localparam CAL1_DONE                   = 4'hA;

  localparam CAL2_IDLE                    = 4'h0;
  localparam CAL2_INIT                    = 4'h1;
  localparam CAL2_INIT_IDEL_WAIT          = 4'h2;
  localparam CAL2_FIND_EDGE_POS           = 4'h3;
  localparam CAL2_FIND_EDGE_IDEL_WAIT_POS = 4'h4;
  localparam CAL2_FIND_EDGE_NEG           = 4'h5;
  localparam CAL2_FIND_EDGE_IDEL_WAIT_NEG = 4'h6;
  localparam CAL2_DEC_IDEL                = 4'h7;
  localparam CAL2_DONE                    = 4'h8;

  localparam CAL3_IDLE                    = 3'h0;
  localparam CAL3_INIT                    = 3'h1;
  localparam CAL3_DETECT                  = 3'h2;
  localparam CAL3_RDEN_PIPE_CLR_WAIT      = 3'h3;
  localparam CAL3_DONE                    = 3'h4;

  localparam CAL4_IDLE                    = 3'h0;
  localparam CAL4_INIT                    = 3'h1;
  localparam CAL4_FIND_WINDOW             = 3'h2;
  localparam CAL4_FIND_EDGE               = 3'h3;
  localparam CAL4_IDEL_WAIT               = 3'h4;
  localparam CAL4_RDEN_PIPE_CLR_WAIT      = 3'h5;
  localparam CAL4_ADJ_IDEL                = 3'h6;
  localparam CAL4_DONE                    = 3'h7;

  integer                        i, j;

  reg [5:0]                      cal1_bit_time_tap_cnt;
  reg [1:0]                      cal1_data_chk_last;
  reg                            cal1_data_chk_last_valid;
  reg [1:0]                      cal1_data_chk_r;
  reg                            cal1_dlyce_dq;
  reg                            cal1_dlyinc_dq;
  reg                            cal1_dqs_dq_init_phase;
  reg                            cal1_detect_edge;
  reg                            cal1_detect_stable;
  reg                            cal1_found_second_edge;
  reg                            cal1_found_rising;
  reg                            cal1_found_window;
  reg                            cal1_first_edge_done;
  reg [5:0]                      cal1_first_edge_tap_cnt;
  reg [6:0]                      cal1_idel_dec_cnt;
  reg [5:0]                      cal1_idel_inc_cnt;
  reg [5:0]                      cal1_idel_max_tap;
  reg                            cal1_idel_max_tap_we;
  reg [5:0]                      cal1_idel_tap_cnt;
  reg                            cal1_idel_tap_limit_hit;
  reg [6:0]                      cal1_low_freq_idel_dec;
  reg                            cal1_ref_req;
  wire                           cal1_refresh;
  reg [3:0]                      cal1_state;
  reg [3:0]                      cal1_window_cnt;
  reg                            cal2_curr_sel;
  wire                           cal2_detect_edge;
  reg                            cal2_dlyce_dqs;
  reg                            cal2_dlyinc_dqs;
  reg [5:0]                      cal2_idel_dec_cnt;
  reg [5:0]                      cal2_idel_tap_cnt;
  reg [5:0]                      cal2_idel_tap_limit;
  reg                            cal2_idel_tap_limit_hit;
  reg                            cal2_rd_data_fall_last_neg;
  reg                            cal2_rd_data_fall_last_pos;
  reg                            cal2_rd_data_last_valid_neg;
  reg                            cal2_rd_data_last_valid_pos;
  reg                            cal2_rd_data_rise_last_neg;
  reg                            cal2_rd_data_rise_last_pos;
  reg [DQS_WIDTH-1:0]            cal2_rd_data_sel;
  wire                           cal2_rd_data_sel_edge;
  reg [DQS_WIDTH-1:0]            cal2_rd_data_sel_r;
  reg                            cal2_ref_req;
  reg [3:0]                      cal2_state;
  reg                            cal3_data_match;
  reg                            cal3_data_match_stgd;
  wire                           cal3_data_valid;
  wire                           cal3_match_found;
  wire [4:0]                     cal3_rden_dly;
  reg [4:0]                      cal3_rden_srl_a;
  reg [2:0]                      cal3_state;
  wire                           cal4_data_good;
  reg                            cal4_data_match;
  reg                            cal4_data_match_stgd;
  wire                           cal4_data_valid;
  reg                            cal4_dlyce_gate;
  reg                            cal4_dlyinc_gate;
  reg                            cal4_dlyrst_gate;
  reg [4:0]                      cal4_gate_srl_a;
  reg [5:0]                      cal4_idel_adj_cnt;
  reg                            cal4_idel_adj_inc;
  reg                            cal4_idel_bit_tap;
  reg [5:0]                      cal4_idel_tap_cnt;
  reg                            cal4_idel_max_tap;
  reg [4:0]                      cal4_rden_srl_a;
  reg                            cal4_ref_req;
  reg                            cal4_seek_left;
  reg                            cal4_stable_window;
  reg [2:0]                      cal4_state;
  reg [3:0]                      cal4_window_cnt;
  reg [3:0]                      calib_done_tmp;         // only for stg1/2/4
  reg                            calib_ctrl_gate_pulse_r;
  reg                            calib_ctrl_rden;
  reg                            calib_ctrl_rden_r;
  wire                           calib_ctrl_rden_negedge;
  reg                            calib_ctrl_rden_negedge_r;
  reg [3:0]                      calib_done_r;
  reg [3:0]                      calib_err;
  reg [1:0]                      calib_err_2;
  wire                           calib_init_gate_pulse;
  reg                            calib_init_gate_pulse_r;
  reg                            calib_init_gate_pulse_r1;
  reg                            calib_init_rden;
  reg                            calib_init_rden_r;
  reg [4:0]                      calib_rden_srl_a;
  wire [4:0]                     calib_rden_srl_a_r;
  reg [(5*DQS_WIDTH)-1:0]        calib_rden_dly;
  reg                            calib_rden_edge_r;
  reg [4:0]                      calib_rden_pipe_cnt;
  wire                           calib_rden_srl_out;
  wire                           calib_rden_srl_out_r;
  reg                            calib_rden_srl_out_r1;
  reg                            calib_rden_valid;
  reg                            calib_rden_valid_stgd;
  reg [DQ_BITS-1:0]              count_dq;
  reg [DQS_BITS_FIX-1:0]         count_dqs;
  reg [DQS_BITS_FIX-1:0]         count_gate;
  reg [DQS_BITS_FIX-1:0]         count_rden;
  reg                            ctrl_rden_r;
  wire                           dlyce_or;
  reg [(5*DQS_WIDTH)-1:0]        gate_dly;
  wire [(5*DQS_WIDTH)-1:0]       gate_dly_r;
  wire                           gate_srl_in;
  wire [DQS_WIDTH-1:0]           gate_srl_out;
  wire [DQS_WIDTH-1:0]           gate_srl_out_r;
  reg [2:0]                      idel_set_cnt;
  wire                           idel_set_wait;
  reg [DQ_BITS-1:0]              next_count_dq;
  reg [DQS_BITS_FIX-1:0]         next_count_dqs;
  reg [DQS_BITS_FIX-1:0]         next_count_gate;
  reg                            phy_init_rden_r;
  reg                            phy_init_rden_r1;
  reg [DQS_WIDTH-1:0]            rd_data_fall_1x_bit1_r1;  
  reg [DQ_WIDTH-1:0]             rd_data_fall_1x_r;
  reg [DQS_WIDTH-1:0]            rd_data_fall_1x_r1;
  reg [DQS_WIDTH-1:0]            rd_data_fall_2x_bit1_r;
  reg [DQS_WIDTH-1:0]            rd_data_fall_2x_r;
  wire [DQS_WIDTH-1:0]           rd_data_fall_chk_q1;
  wire [DQS_WIDTH-1:0]           rd_data_fall_chk_q1_bit1;
  wire [DQS_WIDTH-1:0]           rd_data_fall_chk_q2;
  wire [DQS_WIDTH-1:0]           rd_data_fall_chk_q2_bit1;  
  reg [DQS_WIDTH-1:0]            rd_data_rise_1x_bit1_r1;
  reg [DQ_WIDTH-1:0]             rd_data_rise_1x_r;
  reg [DQS_WIDTH-1:0]            rd_data_rise_1x_r1;
  reg [DQS_WIDTH-1:0]            rd_data_rise_2x_bit1_r;
  reg [DQS_WIDTH-1:0]            rd_data_rise_2x_r;
  wire [DQS_WIDTH-1:0]           rd_data_rise_chk_q1;
  wire [DQS_WIDTH-1:0]           rd_data_rise_chk_q1_bit1;  
  wire [DQS_WIDTH-1:0]           rd_data_rise_chk_q2;
  wire [DQS_WIDTH-1:0]           rd_data_rise_chk_q2_bit1;  
  reg                            rdd_fall_q1;
  reg                            rdd_fall_q1_bit1;
  reg                            rdd_fall_q1_bit1_r;  
  reg                            rdd_fall_q1_bit1_r1;  
  reg                            rdd_fall_q1_r;
  reg                            rdd_fall_q1_r1;
  reg                            rdd_fall_q2;
  reg                            rdd_fall_q2_bit1;  
  reg                            rdd_fall_q2_bit1_r;  
  reg                            rdd_fall_q2_r;
  reg                            rdd_rise_q1;
  reg                            rdd_rise_q1_bit1; 
  reg                            rdd_rise_q1_bit1_r;  
  reg                            rdd_rise_q1_bit1_r1;  
  reg                            rdd_rise_q1_r;
  reg                            rdd_rise_q1_r1;
  reg                            rdd_rise_q2;
  reg                            rdd_rise_q2_bit1;  
  reg                            rdd_rise_q2_bit1_r;  
  reg                            rdd_rise_q2_r;
  reg [DQS_BITS_FIX-1:0]         rdd_mux_sel;
  reg                            rden_dec;
  reg [(5*DQS_WIDTH)-1:0]        rden_dly;
  wire [(5*DQS_WIDTH)-1:0]       rden_dly_r;
  reg [4:0]                      rden_dly_0;
  reg                            rden_inc;
  reg [DQS_WIDTH-1:0]            rden_mux;
  wire [DQS_WIDTH-1:0]           rden_srl_out;

  // Debug
  integer                        x;
  reg [5:0]                      dbg_dq_tap_cnt [DQ_WIDTH-1:0];
  reg [5:0]                      dbg_dqs_tap_cnt [DQS_WIDTH-1:0];
  reg [5:0]                      dbg_gate_tap_cnt [DQS_WIDTH-1:0];

  //***************************************************************************
  // Debug output ("dbg_phy_calib_*")
  // NOTES:
  //  1. All debug outputs coming out of PHY_CALIB are clocked off CLKDIV0,
  //     although they are also static after calibration is complete. This
  //     means the user can either connect them to a Chipscope ILA, or to
  //     either a sync/async VIO input block. Using an async VIO has the
  //     advantage of not requiring these paths to meet cycle-to-cycle timing.
  //  2. The widths of most of these debug buses are dependent on the # of
  //     DQS/DQ bits (e.g. dq_tap_cnt width = 6 * (# of DQ bits)
  // SIGNAL DESCRIPTION:
  //  1. calib_done:   4 bits - each one asserted as each phase of calibration
  //                   is completed.
  //  2. calib_err:    4 bits - each one asserted when a calibration error
  //                   encountered for that stage. Some of these bits may not
  //                   be used (not all cal stages report an error).
  //  3. dq_tap_cnt:   final IDELAY tap counts for all DQ IDELAYs
  //  4. dqs_tap_cnt:  final IDELAY tap counts for all DQS IDELAYs
  //  5. gate_tap_cnt: final IDELAY tap counts for all DQS gate
  //                   synchronization IDELAYs
  //  6. rd_data_sel:  final read capture MUX (either "positive" or "negative"
  //                   edge capture) settings for all DQS groups
  //  7. rden_dly:     related to # of cycles after issuing a read until when
  //                   read data is valid - for all DQS groups
  //  8. gate_dly:     related to # of cycles after issuing a read until when
  //                   clock enable for all DQ's is deasserted to prevent
  //                   effect of DQS postamble glitch - for all DQS groups
  //***************************************************************************

  //*****************************************************************
  // Record IDELAY tap values by "snooping" IDELAY control signals
  //*****************************************************************

  // record DQ IDELAY tap values
  genvar dbg_dq_tc_i;
  generate
    for (dbg_dq_tc_i = 0; dbg_dq_tc_i < DQ_WIDTH;
         dbg_dq_tc_i = dbg_dq_tc_i + 1) begin: gen_dbg_dq_tap_cnt
      assign dbg_calib_dq_tap_cnt[(6*dbg_dq_tc_i)+5:(6*dbg_dq_tc_i)]
               = dbg_dq_tap_cnt[dbg_dq_tc_i];
      always @(posedge clkdiv)
        if (rstdiv | dlyrst_dq)
          dbg_dq_tap_cnt[dbg_dq_tc_i] <= 6'b000000;
        else
          if (dlyce_dq[dbg_dq_tc_i])
            if (dlyinc_dq[dbg_dq_tc_i])
              dbg_dq_tap_cnt[dbg_dq_tc_i]
                <= dbg_dq_tap_cnt[dbg_dq_tc_i] + 1;
            else
              dbg_dq_tap_cnt[dbg_dq_tc_i]
                <= dbg_dq_tap_cnt[dbg_dq_tc_i] - 1;
    end
  endgenerate

  // record DQS IDELAY tap values
  genvar dbg_dqs_tc_i;
  generate
    for (dbg_dqs_tc_i = 0; dbg_dqs_tc_i < DQS_WIDTH;
         dbg_dqs_tc_i = dbg_dqs_tc_i + 1) begin: gen_dbg_dqs_tap_cnt
      assign dbg_calib_dqs_tap_cnt[(6*dbg_dqs_tc_i)+5:(6*dbg_dqs_tc_i)]
               = dbg_dqs_tap_cnt[dbg_dqs_tc_i];
      always @(posedge clkdiv)
        if (rstdiv | dlyrst_dqs)
          dbg_dqs_tap_cnt[dbg_dqs_tc_i] <= 6'b000000;
        else
          if (dlyce_dqs[dbg_dqs_tc_i])
            if (dlyinc_dqs[dbg_dqs_tc_i])
              dbg_dqs_tap_cnt[dbg_dqs_tc_i]
                <= dbg_dqs_tap_cnt[dbg_dqs_tc_i] + 1;
            else
              dbg_dqs_tap_cnt[dbg_dqs_tc_i]
                <= dbg_dqs_tap_cnt[dbg_dqs_tc_i] - 1;
    end
  endgenerate

  // record DQS gate IDELAY tap values
  genvar dbg_gate_tc_i;
  generate
    for (dbg_gate_tc_i = 0; dbg_gate_tc_i < DQS_WIDTH;
         dbg_gate_tc_i = dbg_gate_tc_i + 1) begin: gen_dbg_gate_tap_cnt
      assign dbg_calib_gate_tap_cnt[(6*dbg_gate_tc_i)+5:(6*dbg_gate_tc_i)]
               = dbg_gate_tap_cnt[dbg_gate_tc_i];
      always @(posedge clkdiv)
        if (rstdiv | dlyrst_gate[dbg_gate_tc_i])
          dbg_gate_tap_cnt[dbg_gate_tc_i] <= 6'b000000;
        else
          if (dlyce_gate[dbg_gate_tc_i])
            if (dlyinc_gate[dbg_gate_tc_i])
              dbg_gate_tap_cnt[dbg_gate_tc_i]
                <= dbg_gate_tap_cnt[dbg_gate_tc_i] + 1;
            else
              dbg_gate_tap_cnt[dbg_gate_tc_i]
                <= dbg_gate_tap_cnt[dbg_gate_tc_i] - 1;
    end
  endgenerate

  assign dbg_calib_done        = calib_done;
  assign dbg_calib_err         = calib_err;
  assign dbg_calib_rd_data_sel = cal2_rd_data_sel;
  assign dbg_calib_rden_dly    = rden_dly;
  assign dbg_calib_gate_dly    = gate_dly;

  //***************************************************************************
  // Read data pipelining, and read data "ISERDES" data width expansion
  //***************************************************************************

  // For all data bits, register incoming capture data to slow clock to improve
  // timing. Adding single pipeline stage does not affect functionality (as
  // long as we make sure to wait extra clock cycle after changing DQ IDELAY)
  // Also note in this case that we're "missing" every other clock cycle's
  // worth of data capture since we're sync'ing to the slow clock. This is
  // fine for stage 1 and stage 2 cal, but not for stage 3 and 4 (see below
  // for different circuit to handle those stages)
  always @(posedge clkdiv) begin
    rd_data_rise_1x_r <= rd_data_rise;
    rd_data_fall_1x_r <= rd_data_fall;
  end

  // For every DQ_PER_DQS bit, generate what is essentially a ISERDES-type
  // data width expander. Will need this for stage 3 and 4 cal, where we need
  // to compare data over consecutive clock cycles. We can also use this for
  // stage 2 as well (stage 2 doesn't require every bit to be looked at, only
  // one bit per DQS group)
  // MIG 3.3: Expand to use lower two bits of each DQS group - use for stage
  //  3 calibration for added robustness, since we will be checking for the
  //  training pattern from the memory even when the data bus is 3-stated.
  //  Theoretically it is possible for whatever garbage data is on the bus
  //  to be interpreted as the training sequence, although this can be made
  //  very unlikely by the choice of training sequence (bit sequence, length)
  //  and the number of bits compared for each DQS group. 
  genvar rdd_i;
  generate
    for (rdd_i = 0; rdd_i < DQS_WIDTH; rdd_i = rdd_i + 1) begin: gen_rdd
      // first stage: keep data in fast clk domain. Store data over two
      // consecutive clock cycles for rise/fall data for proper transfer
      // to slow clock domain
      always @(posedge clk) begin
        rd_data_rise_2x_r[rdd_i]      <= rd_data_rise[(rdd_i*DQ_PER_DQS)];
        rd_data_fall_2x_r[rdd_i]      <= rd_data_fall[(rdd_i*DQ_PER_DQS)];
        rd_data_rise_2x_bit1_r[rdd_i] <= rd_data_rise[(rdd_i*DQ_PER_DQS)+1];
        rd_data_fall_2x_bit1_r[rdd_i] <= rd_data_fall[(rdd_i*DQ_PER_DQS)+1];
      end
      // second stage, register first stage to slow clock domain, 2nd stage
      // consists of both these flops, and the rd_data_rise_1x_r flops
      always @(posedge clkdiv) begin
        rd_data_rise_1x_r1[rdd_i]      <= rd_data_rise_2x_r[rdd_i];
        rd_data_fall_1x_r1[rdd_i]      <= rd_data_fall_2x_r[rdd_i];
        rd_data_rise_1x_bit1_r1[rdd_i] <= rd_data_rise_2x_bit1_r[rdd_i];
        rd_data_fall_1x_bit1_r1[rdd_i] <= rd_data_fall_2x_bit1_r[rdd_i];
      end
      // now we have four outputs - representing rise/fall outputs over last
      // 2 fast clock cycles. However, the ordering these represent can either
      // be: (1) Q2 = data @ time = n, Q1 = data @ time = n+1, or (2)
      // Q2 = data @ time = n - 1, Q1 = data @ time = n (and data at [Q1,Q2]
      // is "staggered") - leave it up to the stage of calibration using this
      // to figure out which is which, if they care at all (e.g. stage 2 cal
      // doesn't care about the ordering)
      assign rd_data_rise_chk_q1[rdd_i]
               = rd_data_rise_1x_r[(rdd_i*DQ_PER_DQS)];
      assign rd_data_rise_chk_q2[rdd_i]
               = rd_data_rise_1x_r1[rdd_i];
      assign rd_data_fall_chk_q1[rdd_i]
               = rd_data_fall_1x_r[(rdd_i*DQ_PER_DQS)];
      assign rd_data_fall_chk_q2[rdd_i]
               = rd_data_fall_1x_r1[rdd_i];
    // MIG 3.3: Added comparison for second bit in DQS group for stage 3 cal
      assign rd_data_rise_chk_q1_bit1[rdd_i]
               = rd_data_rise_1x_r[(rdd_i*DQ_PER_DQS)+1];
      assign rd_data_rise_chk_q2_bit1[rdd_i]
               = rd_data_rise_1x_bit1_r1[rdd_i];
      assign rd_data_fall_chk_q1_bit1[rdd_i]
               = rd_data_fall_1x_r[(rdd_i*DQ_PER_DQS)+1];
      assign rd_data_fall_chk_q2_bit1[rdd_i]
               = rd_data_fall_1x_bit1_r1[rdd_i];
    end
  endgenerate

  //*****************************************************************
  // Outputs of these simplified ISERDES circuits then feed MUXes based on
  // which DQ the current calibration algorithm needs to look at
  //*****************************************************************

  // generate MUX control; assume that adding an extra pipeline stage isn't
  // an issue - whatever stage cal logic is using output of MUX will wait
  // enough time after changing it
  always @(posedge clkdiv) begin
    (* full_case, parallel_case *) case (calib_done[2:0])
      3'b001: rdd_mux_sel <= next_count_dqs;
      3'b011: rdd_mux_sel <= count_rden;
      3'b111: rdd_mux_sel <= next_count_gate;
      default: rdd_mux_sel <= {DQS_BITS_FIX{1'bx}};
    endcase
  end

  always @(posedge clkdiv) begin
    rdd_rise_q1 <= rd_data_rise_chk_q1[rdd_mux_sel];
    rdd_rise_q2 <= rd_data_rise_chk_q2[rdd_mux_sel];
    rdd_fall_q1 <= rd_data_fall_chk_q1[rdd_mux_sel];
    rdd_fall_q2 <= rd_data_fall_chk_q2[rdd_mux_sel];
    rdd_rise_q1_bit1 <= rd_data_rise_chk_q1_bit1[rdd_mux_sel];
    rdd_rise_q2_bit1 <= rd_data_rise_chk_q2_bit1[rdd_mux_sel];
    rdd_fall_q1_bit1 <= rd_data_fall_chk_q1_bit1[rdd_mux_sel];
    rdd_fall_q2_bit1 <= rd_data_fall_chk_q2_bit1[rdd_mux_sel];    
  end

  //***************************************************************************
  // Demultiplexor to control (reset, increment, decrement) IDELAY tap values
  //   For DQ:
  //     STG1: for per-bit-deskew, only inc/dec the current DQ. For non-per
  //       deskew, increment all bits in the current DQS set
  //     STG2: inc/dec all DQ's in the current DQS set.
  // NOTE: Nice to add some error checking logic here (or elsewhere in the
  //       code) to check if logic attempts to overflow tap value
  //***************************************************************************

  // don't use DLYRST to reset value of IDELAY after reset. Need to change this
  // if we want to allow user to recalibrate after initial reset
  always @(posedge clkdiv)
    if (rstdiv) begin
      dlyrst_dq <= 1'b1;
      dlyrst_dqs <= 1'b1;
    end else begin
      dlyrst_dq <= 1'b0;
      dlyrst_dqs <= 1'b0;
    end

  always @(posedge clkdiv) begin
    if (rstdiv) begin
      dlyce_dq   <= 'b0;
      dlyinc_dq  <= 'b0;
      dlyce_dqs  <= 'b0;
      dlyinc_dqs <= 'b0;
    end else begin
      dlyce_dq   <= 'b0;
      dlyinc_dq  <= 'b0;
      dlyce_dqs  <= 'b0;
      dlyinc_dqs <= 'b0;

      // stage 1 cal: change only specified DQ
      if (cal1_dlyce_dq) begin
        if (SIM_ONLY == 0) begin
          dlyce_dq[count_dq] <= 1'b1;
          dlyinc_dq[count_dq] <= cal1_dlyinc_dq;
        end else begin
          // if simulation, then calibrate only first DQ, apply results
          // to all DQs (i.e. assume delay on all DQs is the same)
          for (i = 0; i < DQ_WIDTH; i = i + 1) begin: loop_sim_dq_dly
            dlyce_dq[i] <= 1'b1;
            dlyinc_dq[i] <= cal1_dlyinc_dq;
          end
        end
      end else if (cal2_dlyce_dqs) begin
        // stage 2 cal: change DQS and all corresponding DQ's
        if (SIM_ONLY == 0) begin
          dlyce_dqs[count_dqs] <= 1'b1;
          dlyinc_dqs[count_dqs] <= cal2_dlyinc_dqs;
          for (i = 0; i < DQ_PER_DQS; i = i + 1) begin: loop_dqs_dly
            dlyce_dq[(DQ_PER_DQS*count_dqs)+i] <= 1'b1;
            dlyinc_dq[(DQ_PER_DQS*count_dqs)+i] <= cal2_dlyinc_dqs;
          end
        end else begin
          for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_sim_dqs_dly
            // if simulation, then calibrate only first DQS
            dlyce_dqs[i] <= 1'b1;
            dlyinc_dqs[i] <= cal2_dlyinc_dqs;
            for (j = 0; j < DQ_PER_DQS; j = j + 1) begin: loop_sim_dq_dqs_dly
              dlyce_dq[(DQ_PER_DQS*i)+j] <= 1'b1;
              dlyinc_dq[(DQ_PER_DQS*i)+j] <= cal2_dlyinc_dqs;
            end
          end
        end
      end else if (DEBUG_EN != 0) begin
        // DEBUG: allow user to vary IDELAY tap settings
        // For DQ IDELAY taps
        if (dbg_idel_up_all || dbg_idel_down_all ||
            dbg_sel_all_idel_dq) begin
          for (x = 0; x < DQ_WIDTH; x = x + 1) begin: loop_dly_inc_dq
            dlyce_dq[x] <= dbg_idel_up_all | dbg_idel_down_all |
                           dbg_idel_up_dq  | dbg_idel_down_dq;
            dlyinc_dq[x] <= dbg_idel_up_all | dbg_idel_up_dq;
          end
        end else begin
          dlyce_dq <= 'b0;
          dlyce_dq[dbg_sel_idel_dq] <= dbg_idel_up_dq |
                                       dbg_idel_down_dq;
          dlyinc_dq[dbg_sel_idel_dq] <= dbg_idel_up_dq;
        end
        // For DQS IDELAY taps
        if (dbg_idel_up_all || dbg_idel_down_all ||
            dbg_sel_all_idel_dqs) begin
          for (x = 0; x < DQS_WIDTH; x = x + 1) begin: loop_dly_inc_dqs
            dlyce_dqs[x] <= dbg_idel_up_all | dbg_idel_down_all |
                            dbg_idel_up_dqs | dbg_idel_down_dqs;
            dlyinc_dqs[x] <= dbg_idel_up_all | dbg_idel_up_dqs;
          end
        end else begin
          dlyce_dqs <= 'b0;
          dlyce_dqs[dbg_sel_idel_dqs] <= dbg_idel_up_dqs |
                                         dbg_idel_down_dqs;
          dlyinc_dqs[dbg_sel_idel_dqs] <= dbg_idel_up_dqs;
        end
      end
    end
  end

  // GATE synchronization is handled directly by Stage 4 calibration FSM
  always @(posedge clkdiv)
    if (rstdiv) begin
      dlyrst_gate <= {DQS_WIDTH{1'b1}};
      dlyce_gate  <= {DQS_WIDTH{1'b0}};
      dlyinc_gate <= {DQS_WIDTH{1'b0}};
    end else begin
      dlyrst_gate <= {DQS_WIDTH{1'b0}};
      dlyce_gate  <= {DQS_WIDTH{1'b0}};
      dlyinc_gate <= {DQS_WIDTH{1'b0}};

      if (cal4_dlyrst_gate) begin
        if (SIM_ONLY == 0)
          dlyrst_gate[count_gate] <= 1'b1;
        else
          for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_gate_sim_dly_rst
            dlyrst_gate[i] <= 1'b1;
          end
      end

      if (cal4_dlyce_gate) begin
        if (SIM_ONLY == 0) begin
          dlyce_gate[count_gate]  <= 1'b1;
          dlyinc_gate[count_gate] <= cal4_dlyinc_gate;
        end else begin
          // if simulation, then calibrate only first gate
          for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_gate_sim_dly
            dlyce_gate[i]  <= 1'b1;
            dlyinc_gate[i] <= cal4_dlyinc_gate;
          end
        end
      end else if (DEBUG_EN != 0) begin
        // DEBUG: allow user to vary IDELAY tap settings
        if (dbg_idel_up_all || dbg_idel_down_all ||
            dbg_sel_all_idel_gate) begin
          for (x = 0; x < DQS_WIDTH; x = x + 1) begin: loop_dly_inc_gate
            dlyce_gate[x] <= dbg_idel_up_all | dbg_idel_down_all |
                             dbg_idel_up_gate | dbg_idel_down_gate;
            dlyinc_gate[x] <= dbg_idel_up_all | dbg_idel_up_gate;
          end
        end else begin
          dlyce_gate <= {DQS_WIDTH{1'b0}};
          dlyce_gate[dbg_sel_idel_gate] <= dbg_idel_up_gate |
                                           dbg_idel_down_gate;
          dlyinc_gate[dbg_sel_idel_gate] <= dbg_idel_up_gate;
        end
      end
    end

  //***************************************************************************
  // signal to tell calibration state machines to wait and give IDELAY time to
  // settle after it's value is changed (both time for IDELAY chain to settle,
  // and for settled output to propagate through ISERDES). For general use: use
  // for any calibration state machines that modify any IDELAY.
  // Should give at least enough time for IDELAY output to settle (technically
  // for V5, this should be "glitchless" when IDELAY taps are changed, so don't
  // need any time here), and also time for new data to propagate through both
  // ISERDES and the "RDD" MUX + associated pipelining
  // For now, give very "generous" delay - doesn't really matter since only
  // needed during calibration
  //***************************************************************************

  // determine if calibration polarity has changed
  always @(posedge clkdiv)
    cal2_rd_data_sel_r   <= cal2_rd_data_sel;

  assign cal2_rd_data_sel_edge = |(cal2_rd_data_sel ^ cal2_rd_data_sel_r);

  // combine requests to modify any of the IDELAYs into one. Also when second
  // stage capture "edge" polarity is changed (IDELAY isn't changed in this
  // case, but use the same counter to stall cal logic)
  assign dlyce_or = cal1_dlyce_dq |
                    cal2_dlyce_dqs |
                    cal2_rd_data_sel_edge |
                    cal4_dlyce_gate |
                    cal4_dlyrst_gate;

  // SYN_NOTE: Can later recode to avoid combinational path
  assign idel_set_wait = dlyce_or || (idel_set_cnt != IDEL_SET_VAL);

  always @(posedge clkdiv)
    if (rstdiv)
      idel_set_cnt <= 4'b0000;
    else if (dlyce_or)
      idel_set_cnt <= 4'b0000;
    else if (idel_set_cnt != IDEL_SET_VAL)
      idel_set_cnt <= idel_set_cnt + 1;

  // generate request to PHY_INIT logic to issue auto-refresh
  // used by certain states to force prech/auto-refresh part way through
  // calibration to avoid a tRAS violation (which will happen if that
  // stage of calibration lasts long enough). This signal must meet the
  // following requirements: (1) only transition from 0->1 when the refresh
  // request is needed, (2) stay at 1 and only transition 1->0 when
  // CALIB_REF_DONE is asserted
  always @(posedge clkdiv)
    if (rstdiv)
      calib_ref_req <= 1'b0;
    else
      calib_ref_req <= cal1_ref_req | cal2_ref_req  | cal4_ref_req;

  // stage 1 calibration requests auto-refresh every 4 bits
  generate
    if (DQ_BITS < 2) begin: gen_cal1_refresh_dq_lte4
      assign cal1_refresh = 1'b0;
    end else begin: gen_cal1_refresh_dq_gt4
      assign cal1_refresh = (next_count_dq[1:0] == 2'b00);
    end
  endgenerate

  //***************************************************************************
  // First stage calibration: DQ-DQS
  // Definitions:
  //  edge: detected when varying IDELAY, and current capture data != prev
  //    capture data
  //  valid bit window: detected when current capture data == prev capture
  //    data for more than half the bit time
  //  starting conditions for DQS-DQ phase:
  //    case 1: when DQS starts somewhere in rising edge bit window, or
  //      on the right edge of the rising bit window.
  //    case 2: when DQS starts somewhere in falling edge bit window, or
  //      on the right edge of the falling bit window.
  // Algorithm Description:
  //  1. Increment DQ IDELAY until we find an edge.
  //  2. While we're finding the first edge, note whether a valid bit window
  //     has been detected before we found an edge. If so, then figure out if
  //     this is the rising or falling bit window. If rising, then our starting
  //     DQS-DQ phase is case 1. If falling, then it's case 2. If don't detect
  //     a valid bit window, then we must have started on the edge of a window.
  //     Need to wait until later on to decide which case we are.
  //       - Store FIRST_EDGE IDELAY value
  //  3. Now look for second edge.
  //  4. While we're finding the second edge, note whether valid bit window
  //     is detected. If so, then use to, along with results from (2) to figure
  //     out what the starting case is. If in rising bit window, then we're in
  //     case 2. If falling, then case 1.
  //       - Store SECOND_EDGE IDELAY value
  //     NOTES:
  //       a. Finding two edges allows us to calculate the bit time (although
  //          not the "same" bit time polarity - need to investigate this
  //          more).
  //       b. If we run out of taps looking for the second edge, then the bit
  //       time must be too long (>= 2.5ns, and DQS-DQ starting phase must be
  //       case 1).
  //  5. Calculate absolute amount to delay DQ as:
  //       If second edge found, and case 1:
  //         - DQ_IDELAY = FIRST_EDGE - 0.5*(SECOND_EDGE - FIRST_EDGE)
  //       If second edge found, and case 2:
  //         - DQ_IDELAY = SECOND_EDGE - 0.5*(SECOND_EDGE - FIRST_EDGE)
  //       If second edge not found, then need to make an approximation on
  //       how much to shift by (should be okay, because we have more timing
  //       margin):
  //         - DQ_IDELAY = FIRST_EDGE - 0.5 * (bit_time)
  //     NOTE: Does this account for either case 1 or case 2?????
  //     NOTE: It's also possible even when we find the second edge, that
  //           to instead just use half the bit time to subtract from either
  //           FIRST or SECOND_EDGE. Finding the actual bit time (which is
  //           what (SECOND_EDGE - FIRST_EDGE) is, is slightly more accurate,
  //           since it takes into account duty cycle distortion.
  //  6. Repeat for each DQ in current DQS set.
  //***************************************************************************

  //*****************************************************************
  // for first stage calibration - used for checking if DQS is aligned to the
  // particular DQ, such that we're in the data valid window. Basically, this
  // is one giant MUX.
  //  = [falling data, rising data]
  //  = [0, 1] = rising DQS aligned in proper (rising edge) bit window
  //  = [1, 0] = rising DQS aligned in wrong (falling edge) bit window
  //  = [0, 0], or [1,1] = in uncertain region between windows
  //*****************************************************************

  // SYN_NOTE: May have to split this up into multiple levels - MUX can get
  //  very wide - as wide as the data bus width
  always @(posedge clkdiv)
    cal1_data_chk_r <= {rd_data_fall_1x_r[next_count_dq],
                       rd_data_rise_1x_r[next_count_dq]};

  //*****************************************************************
  // determine when an edge has occurred - when either the current value
  // is different from the previous latched value or when the DATA_CHK
  // outputs are the same (rare, but indicates that we're at an edge)
  // This is only valid when the IDELAY output and propagation of the
  // data through the capture flops has had a chance to settle out.
  //*****************************************************************

  // write CAL1_DETECT_EDGE and CAL1_DETECT_STABLE in such a way that
  // if X's are captured on the bus during functional simulation, that
  // the logic will register this as an edge detected. Do this to allow
  // use of this HDL with Denali memory models (Denali models drive DQ
  // to X's on both edges of the data valid window to simulate jitter)
  // This is only done for functional simulation purposes. **Should not**
  // make the final synthesized logic more complicated, but it does make
  // the HDL harder to understand b/c we have to "phrase" the logic
  // slightly differently than when not worrying about X's
  always @(*) begin
    // no edge found if: (1) we have recorded prev edge, and rise
    // data == fall data, (2) we haven't yet recorded prev edge, but
    // rise/fall data is equal to either [0,1] or [1,0] (i.e. rise/fall
    // data isn't either X's, or [0,0] or [1,1], which indicates we're
    // in the middle of an edge, since normally rise != fall data for stg1)
    if ((cal1_data_chk_last_valid &&
         (cal1_data_chk_r == cal1_data_chk_last)) ||
        (!cal1_data_chk_last_valid &&
         ((cal1_data_chk_r == 2'b01) || (cal1_data_chk_r == 2'b10))))
      cal1_detect_edge = 1'b0;
    else
      cal1_detect_edge = 1'b1;
  end

  always @(*) begin
    // assert if we've found a region where data valid window is stable
    // over consecutive IDELAY taps, and either rise/fall = [1,0], or [0,1]
    if ((cal1_data_chk_last_valid &&
         (cal1_data_chk_r == cal1_data_chk_last)) &&
        ((cal1_data_chk_r == 2'b01) || (cal1_data_chk_r == 2'b10)))
      cal1_detect_stable = 1'b1;
    else
      cal1_detect_stable = 1'b0;
  end

  //*****************************************************************
  // Find valid window: keep track of how long we've been in the same data
  // window. If it's been long enough, then declare that we've found a valid
  // window. Also returns whether we found a rising or falling window (only
  // valid when found_window is asserted)
  //*****************************************************************

  always @(posedge clkdiv) begin
    if (cal1_state == CAL1_INIT) begin
      cal1_window_cnt   <= 4'b0000;
      cal1_found_window <= 1'b0;
      cal1_found_rising <= 1'bx;
    end else if (!cal1_data_chk_last_valid) begin
      // if we haven't stored a previous value of CAL1_DATA_CHK (or it got
      // invalidated because we detected an edge, and are now looking for the
      // second edge), then make sure FOUND_WINDOW deasserted on following
      // clock edge (to avoid finding a false window immediately after finding
      // an edge). Note that because of jitter, it's possible to not find an
      // edge at the end of the IDELAY increment settling time, but to find an
      // edge on the next clock cycle (e.g. during CAL1_FIND_FIRST_EDGE)
      cal1_window_cnt   <= 4'b0000;
      cal1_found_window <= 1'b0;
      cal1_found_rising <= 1'bx;
    end else if (((cal1_state == CAL1_FIRST_EDGE_IDEL_WAIT) ||
                  (cal1_state == CAL1_SECOND_EDGE_IDEL_WAIT)) &&
                 !idel_set_wait) begin
      // while finding the first and second edges, see if we can detect a
      // stable bit window (occurs over MIN_WIN_SIZE number of taps). If
      // so, then we're away from an edge, and can conclusively determine the
      // starting DQS-DQ phase.
      if (cal1_detect_stable) begin
        cal1_window_cnt <= cal1_window_cnt + 1;
        if (cal1_window_cnt == MIN_WIN_SIZE-1) begin
          cal1_found_window <= 1'b1;
          if (cal1_data_chk_r == 2'b01)
            cal1_found_rising <= 1'b1;
          else
            cal1_found_rising <= 1'b0;
        end
      end else begin
        // otherwise, we're not in a data valid window, reset the window
        // counter, and indicate we're not currently in window. This should
        // happen by design at least once after finding the first edge.
        cal1_window_cnt <= 4'b0000;
        cal1_found_window <= 1'b0;
        cal1_found_rising <= 1'bx;
      end
    end
  end

  //*****************************************************************
  // keep track of edge tap counts found, and whether we've
  // incremented to the maximum number of taps allowed
  //*****************************************************************

  always @(posedge clkdiv)
    if (cal1_state == CAL1_INIT) begin
      cal1_idel_tap_limit_hit   <= 1'b0;
      cal1_idel_tap_cnt   <= 6'b000000;
    end else if (cal1_dlyce_dq) begin
      if (cal1_dlyinc_dq) begin
        cal1_idel_tap_cnt <= cal1_idel_tap_cnt + 1;
        cal1_idel_tap_limit_hit <= (cal1_idel_tap_cnt == 6'b111110);
      end else begin
        cal1_idel_tap_cnt <= cal1_idel_tap_cnt - 1;
        cal1_idel_tap_limit_hit <= 1'b0;
      end
    end

  //*****************************************************************
  // Pipeline for better timing - amount to decrement by if second
  // edge not found
  //*****************************************************************
  // if only one edge found (possible for low frequencies), then:
  //  1. Assume starting DQS-DQ phase has DQS in DQ window (aka "case 1")
  //  2. We have to decrement by (63 - first_edge_tap_cnt) + (BIT_TIME_TAPS/2)
  //     (i.e. decrement by 63-first_edge_tap_cnt to get to right edge of
  //     DQ window. Then decrement again by (BIT_TIME_TAPS/2) to get to center
  //     of DQ window.
  //  3. Clamp the above value at 63 to ensure we don't underflow IDELAY
  //     (note: clamping happens in the CAL1 state machine)
  always @(posedge clkdiv)
    cal1_low_freq_idel_dec
      <= (7'b0111111 - {1'b0, cal1_first_edge_tap_cnt}) +
         (BIT_TIME_TAPS/2);

  //*****************************************************************
  // Keep track of max taps used during stage 1, use this to limit
  // the number of taps that can be used in stage 2
  //*****************************************************************

  always @(posedge clkdiv)
    if (rstdiv) begin
      cal1_idel_max_tap    <= 6'b000000;
      cal1_idel_max_tap_we <= 1'b0;
    end else begin
      // pipeline latch enable for CAL1_IDEL_MAX_TAP - we have plenty
      // of time, tap count gets updated, then dead cycles waiting for
      // IDELAY output to settle
      cal1_idel_max_tap_we <= (cal1_idel_max_tap < cal1_idel_tap_cnt);
      // record maximum # of taps used for stg 1 cal
      if ((cal1_state == CAL1_DONE) && cal1_idel_max_tap_we)
        cal1_idel_max_tap <= cal1_idel_tap_cnt;
    end

  //*****************************************************************

  always @(posedge clkdiv)
    if (rstdiv) begin
      calib_done[0]            <= 1'b0;
      calib_done_tmp[0]        <= 1'bx;
      calib_err[0]             <= 1'b0;
      count_dq                 <= {DQ_BITS{1'b0}};
      next_count_dq            <= {DQ_BITS{1'b0}};
      cal1_bit_time_tap_cnt    <= 6'bxxxxxx;
      cal1_data_chk_last       <= 2'bxx;
      cal1_data_chk_last_valid <= 1'bx;
      cal1_dlyce_dq            <= 1'b0;
      cal1_dlyinc_dq           <= 1'b0;
      cal1_dqs_dq_init_phase   <= 1'bx;
      cal1_first_edge_done     <= 1'bx;
      cal1_found_second_edge   <= 1'bx;
      cal1_first_edge_tap_cnt  <= 6'bxxxxxx;
      cal1_idel_dec_cnt        <= 7'bxxxxxxx;
      cal1_idel_inc_cnt        <= 6'bxxxxxx;
      cal1_ref_req             <= 1'b0;
      cal1_state               <= CAL1_IDLE;
    end else begin
      // default values for all "pulse" outputs
      cal1_ref_req        <= 1'b0;
      cal1_dlyce_dq       <= 1'b0;
      cal1_dlyinc_dq      <= 1'b0;

      case (cal1_state)
        CAL1_IDLE: begin
          count_dq      <= {DQ_BITS{1'b0}};
          next_count_dq <= {DQ_BITS{1'b0}};
          if (calib_start[0]) begin
            calib_done[0] <= 1'b0;
            calib_done_tmp[0] <= 1'b0;
            cal1_state    <= CAL1_INIT;
          end
        end

        CAL1_INIT: begin
          cal1_data_chk_last_valid <= 1'b0;
          cal1_found_second_edge <= 1'b0;
          cal1_dqs_dq_init_phase <= 1'b0;
          cal1_idel_inc_cnt      <= 6'b000000;
          cal1_state <= CAL1_INC_IDEL;
        end

        // increment DQ IDELAY so that either: (1) DQS starts somewhere in
        // first rising DQ window, or (2) DQS starts in first falling DQ
        // window. The amount to shift is frequency dependent (and is either
        // precalculated by MIG or possibly adjusted by the user)
        CAL1_INC_IDEL:
          if ((cal1_idel_inc_cnt == DQ_IDEL_INIT) && !idel_set_wait) begin
            cal1_state <= CAL1_FIND_FIRST_EDGE;
          end else if (cal1_idel_inc_cnt != DQ_IDEL_INIT) begin
            cal1_idel_inc_cnt <= cal1_idel_inc_cnt + 1;
            cal1_dlyce_dq <= 1'b1;
            cal1_dlyinc_dq <= 1'b1;
          end

        // look for first edge
        CAL1_FIND_FIRST_EDGE: begin
          // Determine DQS-DQ phase if we can detect enough of a valid window
          if (cal1_found_window)
            cal1_dqs_dq_init_phase <= ~cal1_found_rising;
          // find first edge - if found then record position
          if (cal1_detect_edge) begin
            cal1_state <= CAL1_FOUND_FIRST_EDGE_WAIT;
            cal1_first_edge_done   <= 1'b0;
            cal1_first_edge_tap_cnt <= cal1_idel_tap_cnt;
            cal1_data_chk_last_valid <= 1'b0;
          end else begin
            // otherwise, store the current value of DATA_CHK, increment
            // DQ IDELAY, and compare again
            cal1_state <= CAL1_FIRST_EDGE_IDEL_WAIT;
            cal1_data_chk_last <= cal1_data_chk_r;
            // avoid comparing against DATA_CHK_LAST for previous iteration
            cal1_data_chk_last_valid <= 1'b1;
            cal1_dlyce_dq <= 1'b1;
            cal1_dlyinc_dq <= 1'b1;
          end
        end

        // wait for DQ IDELAY to settle
        CAL1_FIRST_EDGE_IDEL_WAIT:
          if (!idel_set_wait)
            cal1_state <= CAL1_FIND_FIRST_EDGE;

        // delay state between finding first edge and looking for second
        // edge. Necessary in order to invalidate CAL1_FOUND_WINDOW before
        // starting to look for second edge
        CAL1_FOUND_FIRST_EDGE_WAIT:
          cal1_state <= CAL1_FIND_SECOND_EDGE;

        // Try and find second edge
        CAL1_FIND_SECOND_EDGE: begin
          // When looking for 2nd edge, first make sure data stabilized (by
          // detecting valid data window) - needed to avoid false edges
          if (cal1_found_window) begin
            cal1_first_edge_done <= 1'b1;
            cal1_dqs_dq_init_phase <= cal1_found_rising;
          end
          // exit if run out of taps to increment
          if (cal1_idel_tap_limit_hit)
            cal1_state <= CAL1_CALC_IDEL;
          else begin
            // found second edge, record the current edge count
            if (cal1_first_edge_done && cal1_detect_edge) begin
              cal1_state <= CAL1_CALC_IDEL;
              cal1_found_second_edge <= 1'b1;
              cal1_bit_time_tap_cnt <= cal1_idel_tap_cnt -
                                       cal1_first_edge_tap_cnt + 1;
            end else begin
              cal1_state <= CAL1_SECOND_EDGE_IDEL_WAIT;
              cal1_data_chk_last <= cal1_data_chk_r;
              cal1_data_chk_last_valid <= 1'b1;
              cal1_dlyce_dq <= 1'b1;
              cal1_dlyinc_dq <= 1'b1;
            end
          end
        end

        // wait for DQ IDELAY to settle, then store ISERDES output
        CAL1_SECOND_EDGE_IDEL_WAIT:
          if (!idel_set_wait)
            cal1_state <= CAL1_FIND_SECOND_EDGE;

        // pipeline delay state to calculate amount to decrement DQ IDELAY
        // NOTE: We're calculating the amount to decrement by, not the
        //  absolute setting for DQ IDELAY
        CAL1_CALC_IDEL: begin
          // if two edges found
          if (cal1_found_second_edge)
            // case 1: DQS was in DQ window to start with. First edge found
            // corresponds to left edge of DQ rising window. Backup by 1.5*BT
            // NOTE: In this particular case, it is possible to decrement
            //  "below 0" in the case where DQS delay is less than 0.5*BT,
            //  need to limit decrement to prevent IDELAY tap underflow
            if (!cal1_dqs_dq_init_phase)
              cal1_idel_dec_cnt <= {1'b0, cal1_bit_time_tap_cnt} +
                                   {1'b0, (cal1_bit_time_tap_cnt >> 1)};
            // case 2: DQS was in wrong DQ window (in DQ falling window).
            // First edge found is right edge of DQ rising window. Second
            // edge is left edge of DQ rising window. Backup by 0.5*BT
            else
              cal1_idel_dec_cnt <= {1'b0, (cal1_bit_time_tap_cnt >> 1)};
          // if only one edge found - assume will always be case 1 - DQS in
          // DQS window. Case 2 only possible if path delay on DQS > 5ns
          else
            cal1_idel_dec_cnt <= cal1_low_freq_idel_dec;
          cal1_state <= CAL1_DEC_IDEL;
        end

        // decrement DQ IDELAY for final adjustment
        CAL1_DEC_IDEL:
          // once adjustment is complete, we're done with calibration for
          // this DQ, now return to IDLE state and repeat for next DQ
          // Add underflow protection for case of 2 edges found and DQS
          // starting in DQ window (see comments for above state) - note we
          // have to take into account delayed value of CAL1_IDEL_TAP_CNT -
          // gets updated one clock cycle after CAL1_DLYCE/INC_DQ
          if ((cal1_idel_dec_cnt == 7'b0000000) ||
              (cal1_dlyce_dq && (cal1_idel_tap_cnt == 6'b000001))) begin
            cal1_state <= CAL1_DONE;
            // stop when all DQ's calibrated, or DQ[0] cal'ed (for sim)
            if ((count_dq == DQ_WIDTH-1) || (SIM_ONLY != 0))
              calib_done_tmp[0] <= 1'b1;
            else
              // need for VHDL simulation to prevent out-of-index error
              next_count_dq <= count_dq + 1;
          end else begin
            // keep decrementing until final tap count reached
            cal1_idel_dec_cnt <= cal1_idel_dec_cnt - 1;
            cal1_dlyce_dq <= 1'b1;
            cal1_dlyinc_dq <= 1'b0;
          end

        // delay state to allow count_dq and DATA_CHK to point to the next
        // DQ bit (allows us to potentially begin checking for an edge on
        // next DQ right away).
        CAL1_DONE:
          if (!idel_set_wait) begin
            count_dq <= next_count_dq;
            if (calib_done_tmp[0]) begin
              calib_done[0] <= 1'b1;
              cal1_state <= CAL1_IDLE;
            end else begin
              // request auto-refresh after every 8-bits calibrated to
              // avoid tRAS violation
              if (cal1_refresh) begin
                cal1_ref_req <= 1'b1;
                if (calib_ref_done)
                  cal1_state <= CAL1_INIT;
              end else
                // if no need this time for refresh, proceed to next bit
                cal1_state <= CAL1_INIT;
            end
          end
      endcase
    end

  //***************************************************************************
  // Second stage calibration: DQS-FPGA Clock
  // Algorithm Description:
  //  1. Assumes a training pattern that will produce a pattern oscillating at
  //     half the core clock frequency each on rise and fall outputs, and such
  //     that rise and fall outputs are 180 degrees out of phase from each
  //     other. Note that since the calibration logic runs at half the speed
  //     of the interface, expect that data sampled with the slow clock always
  //     to be constant (either always = 1, or = 0, and rise data != fall data)
  //     unless we cross the edge of the data valid window
  //  2. Start by setting RD_DATA_SEL = 0. This selects the rising capture data
  //     sync'ed to rising edge of core clock, and falling edge data sync'ed
  //     to falling edge of core clock
  //  3. Start looking for an edge. An edge is defined as either: (1) a
  //     change in capture value or (2) an invalid capture value (e.g. rising
  //     data != falling data for that same clock cycle).
  //  4. If an edge is found, go to step (6). If edge hasn't been found, then
  //     set RD_DATA_SEL = 1, and try again.
  //  5. If no edge is found, then increment IDELAY and return to step (3)
  //  6. If an edge if found, then invert RD_DATA_SEL - this shifts the
  //     capture point 180 degrees from the edge of the window (minus duty
  //     cycle distortion, delay skew between rising/falling edge capture
  //     paths, etc.)
  //  7. If no edge is found by CAL2_IDEL_TAP_LIMIT (= 63 - # taps used for
  //     stage 1 calibration), then decrement IDELAY (without reinverting
  //     RD_DATA_SEL) by CAL2_IDEL_TAP_LIMIT/2. This guarantees we at least
  //     have CAL2_IDEL_TAP_LIMIT/2 of slack both before and after the
  //     capture point (not optimal, but best we can do not having found an
  //     of the window). This happens only for very low frequencies.
  //  8. Repeat for each DQS group.
  //  NOTE: Step 6 is not optimal. A better (and perhaps more complicated)
  //   algorithm might be to find both edges of the data valid window (using
  //   the same polarity of RD_DATA_SEL), and then decrement to the midpoint.
  //***************************************************************************

  // RD_DATA_SEL should be tagged with FROM-TO (multi-cycle) constraint in
  // UCF file to relax timing. This net is "pseudo-static" (after value is
  // changed, FSM waits number of cycles before using the output).
  // Note that we are adding one clock cycle of delay (to isolate it from
  // the other logic CAL2_RD_DATA_SEL feeds), make sure FSM waits long
  // enough to compensate (by default it does, it waits a few cycles more
  // than minimum # of clock cycles)
  genvar rd_i;
  generate
    for (rd_i = 0; rd_i < DQS_WIDTH; rd_i = rd_i+1) begin: gen_rd_data_sel
      FDRSE u_ff_rd_data_sel
        (
         .Q   (rd_data_sel[rd_i]),
         .C   (clkdiv),
         .CE  (1'b1),
         .D   (cal2_rd_data_sel[rd_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  //*****************************************************************
  // Max number of taps used for stg2 cal dependent on number of taps
  // used for stg1 (give priority to stg1 cal - let it use as many
  // taps as it needs - the remainder of the IDELAY taps can be used
  // by stg2)
  //*****************************************************************

  always @(posedge clkdiv)
    cal2_idel_tap_limit <= 6'b111111 - cal1_idel_max_tap;

  //*****************************************************************
  // second stage calibration uses readback pattern of "1100" (i.e.
  // 1st rising = 1, 1st falling = 1, 2nd rising = 0, 2nd falling = 0)
  // only look at the first bit of each DQS group
  //*****************************************************************

  // deasserted when captured data has changed since IDELAY was
  // incremented, or when we're right on the edge (i.e. rise data =
  // fall data).
  assign cal2_detect_edge =
    ((((rdd_rise_q1 != cal2_rd_data_rise_last_pos) ||
       (rdd_fall_q1 != cal2_rd_data_fall_last_pos)) &&
      cal2_rd_data_last_valid_pos && (!cal2_curr_sel)) ||
     (((rdd_rise_q1 != cal2_rd_data_rise_last_neg) ||
       (rdd_fall_q1 != cal2_rd_data_fall_last_neg)) &&
      cal2_rd_data_last_valid_neg && (cal2_curr_sel)) ||
     (rdd_rise_q1 != rdd_fall_q1));

  //*****************************************************************
  // keep track of edge tap counts found, and whether we've
  // incremented to the maximum number of taps allowed
  // NOTE: Assume stage 2 cal always increments the tap count (never
  //       decrements) when searching for edge of the data valid window
  //*****************************************************************

  always @(posedge clkdiv)
    if (cal2_state == CAL2_INIT) begin
      cal2_idel_tap_limit_hit <= 1'b0;
      cal2_idel_tap_cnt <= 6'b000000;
    end else if (cal2_dlyce_dqs) begin
      cal2_idel_tap_cnt <= cal2_idel_tap_cnt + 1;
      cal2_idel_tap_limit_hit <= (cal2_idel_tap_cnt ==
                                  cal2_idel_tap_limit - 1);
    end

  //*****************************************************************

  always @(posedge clkdiv)
    if (rstdiv) begin
      calib_done[1]               <= 1'b0;
      calib_done_tmp[1]           <= 1'bx;
      calib_err[1]                <= 1'b0;
      count_dqs                   <= 'b0;
      next_count_dqs              <= 'b0;
      cal2_dlyce_dqs              <= 1'b0;
      cal2_dlyinc_dqs             <= 1'b0;
      cal2_idel_dec_cnt           <= 6'bxxxxxx;
      cal2_rd_data_last_valid_neg <= 1'bx;
      cal2_rd_data_last_valid_pos <= 1'bx;
      cal2_rd_data_sel            <= 'b0;
      cal2_ref_req                <= 1'b0;
      cal2_state                  <= CAL2_IDLE;
    end else begin
      cal2_ref_req      <= 1'b0;
      cal2_dlyce_dqs    <= 1'b0;
      cal2_dlyinc_dqs   <= 1'b0;

      case (cal2_state)
        CAL2_IDLE: begin
          count_dqs      <= 'b0;
          next_count_dqs <= 'b0;
          if (calib_start[1]) begin
            cal2_rd_data_sel  <= {DQS_WIDTH{1'b0}};
            calib_done[1]     <= 1'b0;
            calib_done_tmp[1] <= 1'b0;
            cal2_state        <= CAL2_INIT;
          end
        end

        // Pass through this state every time we calibrate a new DQS group
        CAL2_INIT: begin
          cal2_curr_sel <= 1'b0;
          cal2_rd_data_last_valid_neg <= 1'b0;
          cal2_rd_data_last_valid_pos <= 1'b0;
          cal2_state <= CAL2_INIT_IDEL_WAIT;
        end

        // Stall state only used if calibration run more than once. Can take
        // this state out if design never runs calibration more than once.
        // We need this state to give time for MUX'ed data to settle after
        // resetting RD_DATA_SEL
        CAL2_INIT_IDEL_WAIT:
          if (!idel_set_wait)
            cal2_state <= CAL2_FIND_EDGE_POS;

        // Look for an edge - first check "positive-edge" stage 2 capture
        CAL2_FIND_EDGE_POS: begin
          // if found an edge, then switch to the opposite edge stage 2
          // capture and we're done - no need to decrement the tap count,
          // since switching to the opposite edge will shift the capture
          // point by 180 degrees
          if (cal2_detect_edge) begin
            cal2_curr_sel <= 1'b1;
            cal2_state <= CAL2_DONE;
            // set all DQS groups to be the same for simulation
            if (SIM_ONLY != 0)
              cal2_rd_data_sel <= {DQS_WIDTH{1'b1}};
            else
              cal2_rd_data_sel[count_dqs] <= 1'b1;
            if ((count_dqs == DQS_WIDTH-1) || (SIM_ONLY != 0))
              calib_done_tmp[1] <= 1'b1;
            else
              // MIG 2.1: Fix for simulation out-of-bounds error when
              // SIM_ONLY=0, and DQS_WIDTH=(power of 2) (needed for VHDL)
              next_count_dqs <= count_dqs + 1;
          end else begin
            // otherwise, invert polarity of stage 2 capture and look for
            // an edge with opposite capture clock polarity
            cal2_curr_sel <= 1'b1;
            cal2_rd_data_sel[count_dqs] <= 1'b1;
            cal2_state <= CAL2_FIND_EDGE_IDEL_WAIT_POS;
            cal2_rd_data_rise_last_pos  <= rdd_rise_q1;
            cal2_rd_data_fall_last_pos  <= rdd_fall_q1;
            cal2_rd_data_last_valid_pos <= 1'b1;
          end
        end

        // Give time to switch from positive-edge to negative-edge second
        // stage capture (need time for data to filter though pipe stages)
        CAL2_FIND_EDGE_IDEL_WAIT_POS:
          if (!idel_set_wait)
            cal2_state <= CAL2_FIND_EDGE_NEG;

        // Look for an edge - check "negative-edge" stage 2 capture
        CAL2_FIND_EDGE_NEG:
          if (cal2_detect_edge) begin
            cal2_curr_sel <= 1'b0;
            cal2_state <= CAL2_DONE;
            // set all DQS groups to be the same for simulation
            if (SIM_ONLY != 0)
              cal2_rd_data_sel <= {DQS_WIDTH{1'b0}};
            else
              cal2_rd_data_sel[count_dqs] <= 1'b0;
            if ((count_dqs == DQS_WIDTH-1) || (SIM_ONLY != 0))
              calib_done_tmp[1] <= 1'b1;
            else
              // MIG 2.1: Fix for simulation out-of-bounds error when
              // SIM_ONLY=0, and DQS_WIDTH=(power of 2) (needed for VHDL)
              next_count_dqs <= count_dqs + 1;
          end else if (cal2_idel_tap_limit_hit) begin
            // otherwise, if we've run out of taps, then immediately
            // backoff by half # of taps used - that's our best estimate
            // for optimal calibration point. Doesn't matter whether which
            // polarity we're using for capture (we don't know which one is
            // best to use)
            cal2_idel_dec_cnt <= {1'b0, cal2_idel_tap_limit[5:1]};
            cal2_state <= CAL2_DEC_IDEL;
            if ((count_dqs == DQS_WIDTH-1) || (SIM_ONLY != 0))
              calib_done_tmp[1] <= 1'b1;
            else
              // MIG 2.1: Fix for simulation out-of-bounds error when
              // SIM_ONLY=0, and DQS_WIDTH=(power of 2) (needed for VHDL)
              next_count_dqs <= count_dqs + 1;
          end else begin
            // otherwise, increment IDELAY, and start looking for edge again
            cal2_curr_sel <= 1'b0;
            cal2_rd_data_sel[count_dqs] <= 1'b0;
            cal2_state <= CAL2_FIND_EDGE_IDEL_WAIT_NEG;
            cal2_rd_data_rise_last_neg  <= rdd_rise_q1;
            cal2_rd_data_fall_last_neg  <= rdd_fall_q1;
            cal2_rd_data_last_valid_neg <= 1'b1;
            cal2_dlyce_dqs  <= 1'b1;
            cal2_dlyinc_dqs <= 1'b1;
          end

        CAL2_FIND_EDGE_IDEL_WAIT_NEG:
          if (!idel_set_wait)
            cal2_state <= CAL2_FIND_EDGE_POS;

        // if no edge found, then decrement by half # of taps used
        CAL2_DEC_IDEL: begin
          if (cal2_idel_dec_cnt == 6'b000000)
            cal2_state <= CAL2_DONE;
          else begin
            cal2_idel_dec_cnt <= cal2_idel_dec_cnt - 1;
            cal2_dlyce_dqs  <= 1'b1;
            cal2_dlyinc_dqs <= 1'b0;
          end
        end

        // delay state to allow count_dqs and ISERDES data to point to next
        // DQ bit (DQS group) before going to INIT
        CAL2_DONE:
          if (!idel_set_wait) begin
            count_dqs <= next_count_dqs;
            if (calib_done_tmp[1]) begin
              calib_done[1] <= 1'b1;
              cal2_state <= CAL2_IDLE;
            end else begin
              // request auto-refresh after every DQS group calibrated to
              // avoid tRAS violation
              cal2_ref_req <= 1'b1;
              if (calib_ref_done)
                cal2_state <= CAL2_INIT;
            end
          end
      endcase
    end

  //***************************************************************************
  // Stage 3 calibration: Read Enable
  // Description:
  // read enable calibration determines the "round-trip" time (in # of CLK0
  // cycles) between when a read command is issued by the controller, and
  // when the corresponding read data is synchronized by into the CLK0 domain
  // this is a long delay chain to delay read enable signal from controller/
  // initialization logic (i.e. this is used for both initialization and
  // during normal controller operation). Stage 3 calibration logic decides
  // which delayed version is appropriate to use (which is affected by the
  // round trip delay of DQ/DQS) as a "valid" signal to tell rest of logic
  // when the captured data output from ISERDES is valid.
  //***************************************************************************

  //*****************************************************************
  // Delay chains: Use shift registers
  // Two sets of delay chains are used:
  //  1. One to delay RDEN from PHY_INIT module for calibration
  //     purposes (delay required for RDEN for calibration is different
  //     than during normal operation)
  //  2. One per DQS group to delay RDEN from controller for normal
  //     operation - the value to delay for each DQS group can be different
  //     as is determined during calibration
  //*****************************************************************

  //*****************************************************************
  // First delay chain, use only for calibration
  // input = asserted on rising edge of RDEN from PHY_INIT module
  //*****************************************************************

  always @(posedge clk) begin
    ctrl_rden_r       <= ctrl_rden;
    phy_init_rden_r   <= phy_init_rden;
    phy_init_rden_r1  <= phy_init_rden_r;
    calib_rden_edge_r <= phy_init_rden_r & ~phy_init_rden_r1;
  end

  // Calibration shift register used for both Stage 3 and Stage 4 cal
  // (not strictly necessary for stage 4, but use as an additional check
  // to make sure we're checking for correct data on the right clock cycle)
  always @(posedge clkdiv)
    if (!calib_done[2])
      calib_rden_srl_a <= cal3_rden_srl_a;
    else
      calib_rden_srl_a <= cal4_rden_srl_a;

  // Flops for targetting of multi-cycle path in UCF
  genvar cal_rden_ff_i;
  generate
    for (cal_rden_ff_i = 0; cal_rden_ff_i < 5;
         cal_rden_ff_i = cal_rden_ff_i+1) begin: gen_cal_rden_dly
      FDRSE u_ff_cal_rden_dly
        (
         .Q   (calib_rden_srl_a_r[cal_rden_ff_i]),
         .C   (clkdiv),
         .CE  (1'b1),
         .D   (calib_rden_srl_a[cal_rden_ff_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  SRLC32E u_calib_rden_srl
    (
     .Q   (calib_rden_srl_out),
     .Q31 (),
     .A   (calib_rden_srl_a_r),
     .CE  (1'b1),
     .CLK (clk),
     .D   (calib_rden_edge_r)
     );

  FDRSE u_calib_rden_srl_out_r
    (
         .Q   (calib_rden_srl_out_r),
         .C   (clk),
         .CE  (1'b1),
         .D   (calib_rden_srl_out),
         .R   (1'b0),
         .S   (1'b0)
     ) /* synthesis syn_preserve = 1 */;

  // convert to CLKDIV domain. Two version are generated because we need
  // to be able to tell exactly which fast (clk) clock cycle the read
  // enable was asserted in. Only one of CALIB_DATA_VALID or
  // CALIB_DATA_VALID_STGD will be asserted for any given shift value
  always @(posedge clk)
    calib_rden_srl_out_r1 <= calib_rden_srl_out_r;

  always @(posedge clkdiv) begin
    calib_rden_valid      <= calib_rden_srl_out_r;
    calib_rden_valid_stgd <= calib_rden_srl_out_r1;
  end

  //*****************************************************************
  // Second set of delays chain, use for normal reads
  // input = RDEN from controller
  //*****************************************************************

  // Flops for targetting of multi-cycle path in UCF
  genvar rden_ff_i;
  generate
    for (rden_ff_i = 0; rden_ff_i < 5*DQS_WIDTH;
         rden_ff_i = rden_ff_i+1) begin: gen_rden_dly
      FDRSE u_ff_rden_dly
        (
         .Q   (rden_dly_r[rden_ff_i]),
         .C   (clkdiv),
         .CE  (1'b1),
         .D   (rden_dly[rden_ff_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  // NOTE: Comment this section explaining purpose of SRL's
  genvar rden_i;
  generate
    for (rden_i = 0; rden_i < DQS_WIDTH; rden_i = rden_i + 1) begin: gen_rden
      SRLC32E u_rden_srl
        (
         .Q   (rden_srl_out[rden_i]),
         .Q31 (),
         .A   ({rden_dly_r[(rden_i*5)+4],
                rden_dly_r[(rden_i*5)+3],
                rden_dly_r[(rden_i*5)+2],
                rden_dly_r[(rden_i*5)+1],
                rden_dly_r[(rden_i*5)]}),
         .CE  (1'b1),
         .CLK (clk),
         .D   (ctrl_rden_r)
         );
      FDRSE u_calib_rden_r
        (
         .Q   (calib_rden[rden_i]),
         .C   (clk),
         .CE  (1'b1),
         .D   (rden_srl_out[rden_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */;
    end
  endgenerate

  //*****************************************************************
  // indicates that current received data is the correct pattern. Check both
  // rising and falling data for first DQ in each DQS group. Note that
  // we're checking using a pipelined version of read data, so need to take
  // this inherent delay into account in determining final read valid delay
  // Data is written to the memory in the following order (first -> last):
  //   0x1, 0xE, 0xE, 0x1, 0x1, 0xE, 0x1, 0xE
  // Looking at the two LSb bits, expect data in sequence (in binary):
  //   bit[0]: 1, 0, 0, 1, 0, 1, 0, 1
  //   bit[1]: 0, 1, 1, 0, 1, 0, 1, 0
  // Check for the presence of the first 7 words, and compensate read valid
  // delay accordingly. Don't check last falling edge data, it may be
  // corrupted by the DQS tri-state glitch at end of read postamble
  // (glitch protection not yet active until stage 4 cal)
  //*****************************************************************

  always @(posedge clkdiv) begin
    rdd_rise_q1_r  <= rdd_rise_q1;
    rdd_fall_q1_r  <= rdd_fall_q1;
    rdd_rise_q2_r  <= rdd_rise_q2;
    rdd_fall_q2_r  <= rdd_fall_q2;
    rdd_rise_q1_r1 <= rdd_rise_q1_r;
    rdd_fall_q1_r1 <= rdd_fall_q1_r;
    // MIG 3.3: Added comparison for second bit in DQS group for stage 3 cal
    rdd_rise_q1_bit1_r  <= rdd_rise_q1_bit1;
    rdd_fall_q1_bit1_r  <= rdd_fall_q1_bit1;
    rdd_rise_q2_bit1_r  <= rdd_rise_q2_bit1;
    rdd_fall_q2_bit1_r  <= rdd_fall_q2_bit1;
    rdd_rise_q1_bit1_r1 <= rdd_rise_q1_bit1_r;
    rdd_fall_q1_bit1_r1 <= rdd_fall_q1_bit1_r;    
  end

  always @(posedge clkdiv) begin
    // For the following sequence from memory:
    //   rise[0], fall[0], rise[1], fall[1]
    // if data is aligned out of fabric ISERDES:
    //   RDD_RISE_Q2 = rise[0]
    //   RDD_FALL_Q2 = fall[0]
    //   RDD_RISE_Q1 = rise[1]
    //   RDD_FALL_Q1 = fall[1]
    cal3_data_match <= ((rdd_rise_q2_r == 1) &&
                        (rdd_fall_q2_r == 0) &&
                        (rdd_rise_q1_r == 0) &&
                        (rdd_fall_q1_r == 1) &&
                        (rdd_rise_q2   == 0) &&
                        (rdd_fall_q2   == 1) &&
                        (rdd_rise_q1   == 0) &&
                        (rdd_rise_q2_bit1_r == 0) &&
                        (rdd_fall_q2_bit1_r == 1) &&
                        (rdd_rise_q1_bit1_r == 1) &&
                        (rdd_fall_q1_bit1_r == 0) &&
                        (rdd_rise_q2_bit1   == 1) &&
                        (rdd_fall_q2_bit1   == 0) &&
                        (rdd_rise_q1_bit1   == 1));

    // if data is staggered out of fabric ISERDES:
    //   RDD_RISE_Q1_R = rise[0]
    //   RDD_FALL_Q1_R = fall[0]
    //   RDD_RISE_Q2   = rise[1]
    //   RDD_FALL_Q2   = fall[1]
    cal3_data_match_stgd <= ((rdd_rise_q1_r1 == 1) &&
                             (rdd_fall_q1_r1 == 0) &&
                             (rdd_rise_q2_r  == 0) &&
                             (rdd_fall_q2_r  == 1) &&
                             (rdd_rise_q1_r  == 0) &&
                             (rdd_fall_q1_r  == 1) &&
                             (rdd_rise_q2    == 0) &&
                             (rdd_rise_q1_bit1_r1 == 0) &&
                             (rdd_fall_q1_bit1_r1 == 1) &&
                             (rdd_rise_q2_bit1_r  == 1) &&
                             (rdd_fall_q2_bit1_r  == 0) &&
                             (rdd_rise_q1_bit1_r  == 1) &&
                             (rdd_fall_q1_bit1_r  == 0) &&
                             (rdd_rise_q2_bit1    == 1));
  end

  assign cal3_rden_dly = cal3_rden_srl_a - CAL3_RDEN_SRL_DLY_DELTA;
  assign cal3_data_valid = (calib_rden_valid | calib_rden_valid_stgd);
  assign cal3_match_found
    = ((calib_rden_valid && cal3_data_match) ||
       (calib_rden_valid_stgd && cal3_data_match_stgd));

  // when calibrating, check to see which clock cycle (after the read is
  // issued) does the expected data pattern arrive. Record this result
  // NOTE: Can add error checking here in case valid data not found on any
  //  of the available pipeline stages
  always @(posedge clkdiv) begin
    if (rstdiv) begin
      cal3_rden_srl_a <= 5'bxxxxx;
      cal3_state      <= CAL3_IDLE;
      calib_done[2]   <= 1'b0;
      calib_err_2[0]  <= 1'b0;
      count_rden      <= {DQS_WIDTH{1'b0}};
      rden_dly        <= {5*DQS_WIDTH{1'b0}};
    end else begin

      case (cal3_state)
        CAL3_IDLE: begin
          count_rden <= {DQS_WIDTH{1'b0}};
          if (calib_start[2]) begin
            calib_done[2] <= 1'b0;
            cal3_state    <= CAL3_INIT;
          end
        end

        CAL3_INIT: begin
          cal3_rden_srl_a <= RDEN_BASE_DELAY;
          // let SRL pipe clear after loading initial shift value
          cal3_state      <= CAL3_RDEN_PIPE_CLR_WAIT;
        end

        CAL3_DETECT:
          if (cal3_data_valid)
            // if match found at the correct clock cycle
            if (cal3_match_found) begin

              // For simulation, load SRL addresses for all DQS with same value
              if (SIM_ONLY != 0) begin
                for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_sim_rden_dly
                  rden_dly[(i*5)]   <= cal3_rden_dly[0];
                  rden_dly[(i*5)+1] <= cal3_rden_dly[1];
                  rden_dly[(i*5)+2] <= cal3_rden_dly[2];
                  rden_dly[(i*5)+3] <= cal3_rden_dly[3];
                  rden_dly[(i*5)+4] <= cal3_rden_dly[4];
                end
              end else begin
                rden_dly[(count_rden*5)]   <= cal3_rden_dly[0];
                rden_dly[(count_rden*5)+1] <= cal3_rden_dly[1];
                rden_dly[(count_rden*5)+2] <= cal3_rden_dly[2];
                rden_dly[(count_rden*5)+3] <= cal3_rden_dly[3];
                rden_dly[(count_rden*5)+4] <= cal3_rden_dly[4];
              end

              // Use for stage 4 calibration
              calib_rden_dly[(count_rden*5)]   <= cal3_rden_srl_a[0];
              calib_rden_dly[(count_rden*5)+1] <= cal3_rden_srl_a[1];
              calib_rden_dly[(count_rden*5)+2] <= cal3_rden_srl_a[2];
              calib_rden_dly[(count_rden*5)+3] <= cal3_rden_srl_a[3];
              calib_rden_dly[(count_rden*5)+4] <= cal3_rden_srl_a[4];
              cal3_state <= CAL3_DONE;
            end else begin
              // If we run out of stages to shift, without finding correct
              // result, the stop and assert error
              if (cal3_rden_srl_a == 5'b11111) begin
                calib_err_2[0] <= 1'b1;
                cal3_state   <= CAL3_IDLE;
              end else begin
                // otherwise, increase the shift value and try again
                cal3_rden_srl_a <= cal3_rden_srl_a + 1;
                cal3_state      <= CAL3_RDEN_PIPE_CLR_WAIT;
              end
            end

        // give additional time for RDEN_R pipe to clear from effects of
        // previous pipeline or IDELAY tap change
        CAL3_RDEN_PIPE_CLR_WAIT:
          if (calib_rden_pipe_cnt == 5'b00000)
              cal3_state <= CAL3_DETECT;

        CAL3_DONE: begin
          if ((count_rden == DQS_WIDTH-1) || (SIM_ONLY != 0)) begin
            calib_done[2] <= 1'b1;
            cal3_state    <= CAL3_IDLE;
          end else begin
            count_rden    <= count_rden + 1;
            cal3_state    <= CAL3_INIT;
          end
        end
      endcase
    end
  end

  //*****************************************************************
  // Last part of stage 3 calibration - compensate for differences
  // in delay between different DQS groups. Assume that in the worst
  // case, DQS groups can only differ by one clock cycle. Data for
  // certain DQS groups must be delayed by one clock cycle.
  // NOTE: May need to increase allowable variation to greater than
  //  one clock cycle in certain customer designs.
  // Algorithm is:
  //   1. Record shift delay value for DQS[0]
  //   2. Compare each DQS[x] delay value to that of DQS[0]:
  //     - If different, than record this fact (RDEN_MUX)
  //     - If greater than DQS[0], set RDEN_INC. Assume greater by
  //       one clock cycle only - this is a key assumption, assume no
  //       more than a one clock cycle variation.
  //     - If less than DQS[0], set RDEN_DEC
  //   3. After calibration is complete, set control for DQS group
  //      delay (CALIB_RDEN_SEL):
  //     - If RDEN_DEC = 1, then assume that DQS[0] is the lowest
  //       delay (and at least one other DQS group has a higher
  //       delay).
  //     - If RDEN_INC = 1, then assume that DQS[0] is the highest
  //       delay (and that all other DQS groups have the same or
  //       lower delay).
  //     - If both RDEN_INC and RDEN_DEC = 1, then flag error
  //       (variation is too high for this algorithm to handle)
  //*****************************************************************

  always @(posedge clkdiv) begin
    if (rstdiv) begin
      calib_err_2[1] <= 1'b0;
      calib_rden_sel <= {DQS_WIDTH{1'bx}};
      rden_dec       <= 1'b0;
      rden_dly_0     <= 5'bxxxxx;
      rden_inc       <= 1'b0;
      rden_mux       <= {DQS_WIDTH{1'b0}};
    end else begin
      // if a match if found, then store the value of rden_dly
      if (!calib_done[2]) begin
        if ((cal3_state == CAL3_DETECT) && cal3_match_found) begin
          // store the value for DQS[0] as a reference
          if (count_rden == 0) begin
            // for simulation, RDEN calibration only happens for DQS[0]
            // set RDEN_MUX for all DQS groups to be the same as DQS[0]
            if (SIM_ONLY != 0)
              rden_mux <= {DQS_WIDTH{1'b0}};
            else begin
              // otherwise, load values for DQS[0]
              rden_dly_0  <= cal3_rden_srl_a;
              rden_mux[0] <= 1'b0;
            end
          end else if (SIM_ONLY == 0) begin
            // for all other DQS groups, compare RDEN_DLY delay value with
            // that of DQS[0]
            if (rden_dly_0 != cal3_rden_srl_a) begin
              // record that current DQS group has a different delay
              // than DQS[0] (the "reference" DQS group)
              rden_mux[count_rden] <= 1'b1;
              if (rden_dly_0 > cal3_rden_srl_a)
                rden_inc <= 1'b1;
              else if (rden_dly_0 < cal3_rden_srl_a)
                rden_dec <= 1'b1;
              // otherwise, if current DQS group has same delay as DQS[0],
              // then rden_mux[count_rden] remains at 0 (since rden_mux
              // array contents initialized to 0)
            end
          end
        end
      end else begin
        // Otherwise - if we're done w/ stage 2 calibration:
        // set final value for RDEN data delay
        // flag error if there's more than one cycle variation from DQS[0]
        calib_err_2[1] <= (rden_inc && rden_dec);
        if (rden_inc)
          // if DQS[0] delay represents max delay
          calib_rden_sel <= ~rden_mux;
        else
          // if DQS[0] delay represents min delay (or all the delays are
          // the same between DQS groups)
          calib_rden_sel <= rden_mux;
      end
    end
  end

  // flag error for stage 3 if appropriate
  always @(posedge clkdiv)
    calib_err[2] <= calib_err_2[0] | calib_err_2[1];

  //***************************************************************************
  // Stage 4 calibration: DQS gate
  //***************************************************************************

  //*****************************************************************
  // indicates that current received data is the correct pattern. Same as
  // for READ VALID calibration, except that the expected data sequence is
  // different since DQS gate is asserted after the 6th word.
  // Data sequence:
  //  Arrives from memory (at FPGA input) (R, F): 1 0 0 1 1 0 0 1
  //  After gating the sequence looks like: 1 0 0 1 1 0 1 0 (7th word =
  //   5th word, 8th word = 6th word)
  // What is the gate timing is off? Need to make sure we can distinquish
  // between the results of correct vs. incorrect gate timing. We also use
  // the "read_valid" signal from stage 3 calibration to help us determine
  // when to check for a valid sequence for stage 4 calibration (i.e. use
  // CAL4_DATA_VALID in addition to CAL4_DATA_MATCH/CAL4_DATA_MATCH_STGD)
  // Note that since the gate signal from the CLK0 domain is synchronized
  // to the falling edge of DQS, that the effect of the gate will only be
  // seen starting with a rising edge data (although it is possible
  // the GATE IDDR output could go metastable and cause a unexpected result
  // on the first rising and falling edges after the gate is enabled).
  // Also note that the actual DQS glitch can come more than 0.5*tCK after
  // the last falling edge of DQS and the constraint for this path is can
  // be > 0.5*tCK; however, this means when calibrating, the output of the
  // GATE IDDR may miss the setup time requirement of the rising edge flop
  // and only meet it for the falling edge flop. Therefore the rising
  // edge data immediately following the assertion of the gate can either
  // be a 1 or 0 (can rely on either)
  // As the timing on the gate is varied, we expect to see (sequence of
  // captured read data shown below):
  //       - 1 0 0 1 1 0 0 1 (gate is really early, starts and ends before
  //                          read burst even starts)
  //       - x 0 0 1 1 0 0 1 (gate pulse starts before the burst, and ends
  //       - x y 0 1 1 0 0 1  sometime during the burst; x,y = 0, or 1, but
  //       - x y x 1 1 0 0 1  all bits that show an x are the same value,
  //       - x y x y 1 0 0 1  and y are the same value)
  //       - x y x y x 0 0 1
  //       - x y x y x y 0 1 (gate starts just before start of burst)
  //       - 1 0 x 0 x 0 x 0 (gate starts after 1st falling word. The "x"
  //                          represents possiblity that gate may not disable
  //                          clock for 2nd rising word in time)
  //       - 1 0 0 1 x 1 x 1 (gate starts after 2nd falling word)
  //       - 1 0 0 1 1 0 x 0 (gate starts after 3rd falling word - GOOD!!)
  //       - 1 0 0 1 1 0 0 1 (gate starts after burst is already done)
  //*****************************************************************

  assign cal4_data_valid = calib_rden_valid | calib_rden_valid_stgd;
  assign cal4_data_good  = (calib_rden_valid &
                            cal4_data_match) |
                           (calib_rden_valid_stgd &
                            cal4_data_match_stgd);

  always @(posedge clkdiv) begin
    // if data is aligned out of fabric ISERDES:
    cal4_data_match <= ((rdd_rise_q2_r == 1) &&
                        (rdd_fall_q2_r == 0) &&
                        (rdd_rise_q1_r == 0) &&
                        (rdd_fall_q1_r == 1) &&
                        (rdd_rise_q2   == 1) &&
                        (rdd_fall_q2   == 0) &&
                        // MIG 2.1: Last rising edge data value not
                        // guaranteed to be certain value at higher
                        // frequencies
                        // (rdd_rise_q1   == 0) &&
                        (rdd_fall_q1   == 0));
    // if data is staggered out of fabric ISERDES:
    cal4_data_match_stgd <= ((rdd_rise_q1_r1 == 1) &&
                             (rdd_fall_q1_r1 == 0) &&
                             (rdd_rise_q2_r  == 0) &&
                             (rdd_fall_q2_r  == 1) &&
                             (rdd_rise_q1_r  == 1) &&
                             (rdd_fall_q1_r  == 0) &&
                             // MIG 2.1: Last rising edge data value not
                             // guaranteed to be certain value at higher
                             // frequencies
                             // (rdd_rise_q2    == 0) &&
                             (rdd_fall_q2    == 0));
  end

  //*****************************************************************
  // DQS gate enable generation:
  // This signal gets synchronized to DQS domain, and drives IDDR
  // register that in turn asserts/deasserts CE to all 4 or 8 DQ
  // IDDR's in that DQS group.
  //   1. During normal (post-cal) operation, this is only for 2 clock
  //      cycles following the end of a burst. Check for falling edge
  //      of RDEN. But must also make sure NOT assert for a read-idle-
  //      read (two non-consecutive reads, separated by exactly one
  //      idle cycle) - in this case, don't assert the gate because:
  //      (1) we don't have enough time to deassert the gate before the
  //          first rising edge of DQS for second burst (b/c of fact
  //          that DQS gate is generated in the fabric only off rising
  //          edge of CLK0 - if we somehow had an ODDR in fabric, we
  //          could pull this off, (2) assumption is that the DQS glitch
  //          will not rise enough to cause a glitch because the
  //          post-amble of the first burst is followed immediately by
  //          the pre-amble of the next burst
  //   2. During stage 4 calibration, assert for 3 clock cycles
  //      (assert gate enable one clock cycle early), since we gate out
  //      the last two words (in addition to the crap on the DQ bus after
  //      the DQS read postamble).
  // NOTE: PHY_INIT_RDEN and CTRL_RDEN have slightly different timing w/r
  //  to when they are asserted w/r to the start of the read burst
  //  (PHY_INIT_RDEN is one cycle earlier than CTRL_RDEN).
  //*****************************************************************

  // register for timing purposes for fast clock path - currently only
  // calib_done_r[2] used
  always @(posedge clk)
    calib_done_r <= calib_done;

  always @(*) begin
    calib_ctrl_rden = ctrl_rden;
    calib_init_rden = calib_done_r[2] & phy_init_rden;
  end

  assign calib_ctrl_rden_negedge = ~calib_ctrl_rden & calib_ctrl_rden_r;
  // check for read-idle-read before asserting DQS pulse at end of read
  assign calib_ctrl_gate_pulse   = calib_ctrl_rden_negedge_r &
                                   ~calib_ctrl_rden;
  always @(posedge clk) begin
    calib_ctrl_rden_r         <= calib_ctrl_rden;
    calib_ctrl_rden_negedge_r <= calib_ctrl_rden_negedge;
    calib_ctrl_gate_pulse_r   <= calib_ctrl_gate_pulse;
  end

  assign calib_init_gate_pulse = ~calib_init_rden & calib_init_rden_r;
  always @(posedge clk) begin
    calib_init_rden_r        <= calib_init_rden;
    calib_init_gate_pulse_r  <= calib_init_gate_pulse;
    calib_init_gate_pulse_r1 <= calib_init_gate_pulse_r;
  end

  // Gate is asserted: (1) during cal, for 3 cycles, starting 1 cycle
  // after falling edge of CTRL_RDEN, (2) during normal ops, for 2
  // cycles, starting 2 cycles after falling edge of CTRL_RDEN
  assign gate_srl_in = ~((calib_ctrl_gate_pulse |
                          calib_ctrl_gate_pulse_r) |
                         (calib_init_gate_pulse   |
                          calib_init_gate_pulse_r |
                          calib_init_gate_pulse_r1));

  //*****************************************************************
  // generate DQS enable signal for each DQS group
  // There are differences between DQS gate signal for calibration vs. during
  // normal operation:
  //  * calibration gates the second to last clock cycle of the burst,
  //    rather than after the last word (e.g. for a 8-word, 4-cycle burst,
  //    cycle 4 is gated for calibration; during normal operation, cycle
  //    5 (i.e. cycle after the last word) is gated)
  // enable for DQS is deasserted for two clock cycles, except when
  // we have the preamble for the next read immediately following
  // the postamble of the current read - assume DQS does not glitch
  // during this time, that it stays low. Also if we did have to gate
  // the DQS for this case, then we don't have enough time to deassert
  // the gate in time for the first rising edge of DQS for the second
  // read
  //*****************************************************************

  // Flops for targetting of multi-cycle path in UCF
  genvar gate_ff_i;
  generate
    for (gate_ff_i = 0; gate_ff_i < 5*DQS_WIDTH;
         gate_ff_i = gate_ff_i+1) begin: gen_gate_dly
      FDRSE u_ff_gate_dly
        (
         .Q   (gate_dly_r[gate_ff_i]),
         .C   (clkdiv),
         .CE  (1'b1),
         .D   (gate_dly[gate_ff_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  genvar gate_i;
  generate
    for (gate_i = 0; gate_i < DQS_WIDTH; gate_i = gate_i + 1) begin: gen_gate
      SRLC32E u_gate_srl
        (
         .Q   (gate_srl_out[gate_i]),
         .Q31 (),
         .A   ({gate_dly_r[(gate_i*5)+4],
                gate_dly_r[(gate_i*5)+3],
                gate_dly_r[(gate_i*5)+2],
                gate_dly_r[(gate_i*5)+1],
                gate_dly_r[(gate_i*5)]}),
         .CE  (1'b1),
         .CLK (clk),
         .D   (gate_srl_in)
         );

      // For GATE_BASE_DELAY > 0, have one extra cycle to register outputs
      // from controller before generating DQS gate pulse. In PAR, the
      // location of the controller logic can be far from the DQS gate
      // logic (DQS gate logic located near the DQS I/O's), contributing
      // to large net delays. Registering the controller outputs for
      // CL >= 4 (above 200MHz) adds a stage of pipelining to reduce net
      // delays
      if (GATE_BASE_DELAY > 0) begin: gen_gate_base_dly_gt3
        // add flop between SRL32 and EN_DQS flop (which is located near the
        // DDR2 IOB's)
        FDRSE u_gate_srl_ff
          (
         .Q   (gate_srl_out_r[gate_i]),
         .C   (clk),
         .CE  (1'b1),
         .D   (gate_srl_out[gate_i]),
         .R   (1'b0),
         .S   (1'b0)
           ) /* synthesis syn_preserve = 1 */;
      end else begin: gen_gate_base_dly_le3
        assign gate_srl_out_r[gate_i] = gate_srl_out[gate_i];
      end

      FDRSE u_en_dqs_ff
        (
         .Q   (en_dqs[gate_i]),
         .C   (clk),
         .CE  (1'b1),
         .D   (gate_srl_out_r[gate_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  //*****************************************************************
  // Find valid window: keep track of how long we've been in the same data
  // window. If it's been long enough, then declare that we've found a stable
  // valid window - in particular, that we're past any region of instability
  // associated with the edge of the window. Use only when finding left edge
  //*****************************************************************

  always @(posedge clkdiv)
    // reset before we start to look for window
    if (cal4_state == CAL4_INIT) begin
      cal4_window_cnt    <= 4'b0000;
      cal4_stable_window <= 1'b0;
    end else if ((cal4_state == CAL4_FIND_EDGE) && cal4_seek_left) begin
      // if we're looking for left edge, and incrementing IDELAY, count
      // consecutive taps over which we're in the window
      if (cal4_data_valid) begin
        if (cal4_data_good)
          cal4_window_cnt <= cal4_window_cnt + 1;
        else
          cal4_window_cnt <= 4'b0000;
      end

      if (cal4_window_cnt == MIN_WIN_SIZE-1)
        cal4_stable_window <= 1'b1;
    end

  //*****************************************************************
  // keep track of edge tap counts found, and whether we've
  // incremented to the maximum number of taps allowed
  //*****************************************************************

  always @(posedge clkdiv)
    if ((cal4_state == CAL4_INIT) || cal4_dlyrst_gate) begin
      cal4_idel_max_tap <= 1'b0;
      cal4_idel_bit_tap <= 1'b0;
      cal4_idel_tap_cnt <= 6'b000000;
    end else if (cal4_dlyce_gate) begin
      if (cal4_dlyinc_gate) begin
        cal4_idel_tap_cnt <= cal4_idel_tap_cnt + 1;
        cal4_idel_bit_tap <= (cal4_idel_tap_cnt == CAL4_IDEL_BIT_VAL-2);
        cal4_idel_max_tap <= (cal4_idel_tap_cnt == 6'b111110);
      end else begin
        cal4_idel_tap_cnt <= cal4_idel_tap_cnt - 1;
        cal4_idel_bit_tap <= 1'b0;
        cal4_idel_max_tap <= 1'b0;
      end
    end

  always @(posedge clkdiv)
    if ((cal4_state != CAL4_RDEN_PIPE_CLR_WAIT) &&
        (cal3_state != CAL3_RDEN_PIPE_CLR_WAIT))
      calib_rden_pipe_cnt <= CALIB_RDEN_PIPE_LEN-1;
    else
      calib_rden_pipe_cnt <= calib_rden_pipe_cnt - 1;

  //*****************************************************************
  // Stage 4 cal state machine
  //*****************************************************************

  always @(posedge clkdiv)
    if (rstdiv) begin
      calib_done[3]      <= 1'b0;
      calib_done_tmp[3]  <= 1'b0;
      calib_err[3]       <= 1'b0;
      count_gate         <= 'b0;
      gate_dly           <= 'b0;
      next_count_gate    <= 'b0;
      cal4_idel_adj_cnt  <= 6'bxxxxxx;
      cal4_dlyce_gate    <= 1'b0;
      cal4_dlyinc_gate   <= 1'b0;
      cal4_dlyrst_gate   <= 1'b0;    // reset handled elsewhere in code
      cal4_gate_srl_a    <= 5'bxxxxx;
      cal4_rden_srl_a    <= 5'bxxxxx;
      cal4_ref_req       <= 1'b0;
      cal4_seek_left     <= 1'bx;
      cal4_state         <= CAL4_IDLE;
    end else begin
      cal4_ref_req     <= 1'b0;
      cal4_dlyce_gate  <= 1'b0;
      cal4_dlyinc_gate <= 1'b0;
      cal4_dlyrst_gate <= 1'b0;

      case (cal4_state)
        CAL4_IDLE: begin
          count_gate      <= 'b0;
          next_count_gate <= 'b0;
          if (calib_start[3]) begin
            gate_dly      <= 'b0;
            calib_done[3] <= 1'b0;
            cal4_state    <= CAL4_INIT;
          end
        end

        CAL4_INIT: begin
          // load: (1) initial value of gate delay SRL, (2) appropriate
          // value of RDEN SRL (so that we get correct "data valid" timing)
          cal4_gate_srl_a <= GATE_BASE_INIT;
          cal4_rden_srl_a <= {calib_rden_dly[(count_gate*5)+4],
                              calib_rden_dly[(count_gate*5)+3],
                              calib_rden_dly[(count_gate*5)+2],
                              calib_rden_dly[(count_gate*5)+1],
                              calib_rden_dly[(count_gate*5)]};
          // let SRL pipe clear after loading initial shift value
          cal4_state <= CAL4_RDEN_PIPE_CLR_WAIT;
        end

        // sort of an initial state - start checking to see whether we're
        // already in the window or not
        CAL4_FIND_WINDOW:
          // decide right away if we start in the proper window - this
          // determines if we are then looking for the left (trailing) or
          // right (leading) edge of the data valid window
          if (cal4_data_valid) begin
            // if we find a match - then we're already in window, now look
            // for left edge. Otherwise, look for right edge of window
            cal4_seek_left  <= cal4_data_good;
            cal4_state      <= CAL4_FIND_EDGE;
          end

        CAL4_FIND_EDGE:
          // don't do anything until the exact clock cycle when to check that
          // readback data is valid or not
          if (cal4_data_valid) begin
            // we're currently in the window, look for left edge of window
            if (cal4_seek_left) begin
              // make sure we've passed the right edge before trying to detect
              // the left edge (i.e. avoid any edge "instability") - else, we
              // may detect an "false" edge too soon. By design, if we start in
              // the data valid window, always expect at least
              // MIN(BIT_TIME_TAPS,32) (-/+ jitter, see below) taps of valid
              // window before we hit the left edge (this is because when stage
              // 4 calibration first begins (i.e., gate_dly = 00, and IDELAY =
              // 00), we're guaranteed to NOT be in the window, and we always
              // start searching for MIN(BIT_TIME_TAPS,32) for the right edge
              // of window. If we don't find it, increment gate_dly, and if we
              // now start in the window, we have at least approximately
              // CLK_PERIOD-MIN(BIT_TIME_TAPS,32) = MIN(BIT_TIME_TAPS,32) taps.
              // It's approximately because jitter, noise, etc. can bring this
              // value down slightly. Because of this (although VERY UNLIKELY),
              // we have to protect against not decrementing IDELAY below 0
              // during adjustment phase).
              if (cal4_stable_window && !cal4_data_good) begin
                // found left edge of window, dec by MIN(BIT_TIME_TAPS,32)
                cal4_idel_adj_cnt <= CAL4_IDEL_BIT_VAL;
                cal4_idel_adj_inc <= 1'b0;
                cal4_state        <= CAL4_ADJ_IDEL;
              end else begin
                // Otherwise, keep looking for left edge:
                if (cal4_idel_max_tap) begin
                  // ran out of taps looking for left edge (max=63) - happens
                  // for low frequency case, decrement by 32
                  cal4_idel_adj_cnt <= 6'b100000;
                  cal4_idel_adj_inc <= 1'b0;
                  cal4_state        <= CAL4_ADJ_IDEL;
                end else begin
                  cal4_dlyce_gate  <= 1'b1;
                  cal4_dlyinc_gate <= 1'b1;
                  cal4_state       <= CAL4_IDEL_WAIT;
                end
              end
            end else begin
              // looking for right edge of window:
              // look for the first match - this means we've found the right
              // (leading) edge of the data valid window, increment by
              // MIN(BIT_TIME_TAPS,32)
              if (cal4_data_good) begin
                cal4_idel_adj_cnt <= CAL4_IDEL_BIT_VAL;
                cal4_idel_adj_inc <= 1'b1;
                cal4_state        <= CAL4_ADJ_IDEL;
              end else begin
                // Otherwise, keep looking:
                // only look for MIN(BIT_TIME_TAPS,32) taps for right edge,
                // if we haven't found it, then inc gate delay, try again
                if (cal4_idel_bit_tap) begin
                  // if we're already maxed out on gate delay, then error out
                  // (simulation only - calib_err isn't currently connected)
                  if (cal4_gate_srl_a == 5'b11111) begin
                    calib_err[3] <= 1'b1;
                    cal4_state   <= CAL4_IDLE;
                  end else begin
                    // otherwise, increment gate delay count, and start
                    // over again
                    cal4_gate_srl_a <= cal4_gate_srl_a + 1;
                    cal4_dlyrst_gate <= 1'b1;
                    cal4_state <= CAL4_RDEN_PIPE_CLR_WAIT;
                  end
                end else begin
                  // keep looking for right edge
                  cal4_dlyce_gate  <= 1'b1;
                  cal4_dlyinc_gate <= 1'b1;
                  cal4_state       <= CAL4_IDEL_WAIT;
                end
              end
            end
          end

        // wait for GATE IDELAY to settle, after reset or increment
        CAL4_IDEL_WAIT: begin
          // For simulation, load SRL addresses for all DQS with same value
          if (SIM_ONLY != 0) begin
            for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_sim_gate_dly
              gate_dly[(i*5)+4] <= cal4_gate_srl_a[4];
              gate_dly[(i*5)+3] <= cal4_gate_srl_a[3];
              gate_dly[(i*5)+2] <= cal4_gate_srl_a[2];
              gate_dly[(i*5)+1] <= cal4_gate_srl_a[1];
              gate_dly[(i*5)]   <= cal4_gate_srl_a[0];
            end
          end else begin
            gate_dly[(count_gate*5)+4] <= cal4_gate_srl_a[4];
            gate_dly[(count_gate*5)+3] <= cal4_gate_srl_a[3];
            gate_dly[(count_gate*5)+2] <= cal4_gate_srl_a[2];
            gate_dly[(count_gate*5)+1] <= cal4_gate_srl_a[1];
            gate_dly[(count_gate*5)]   <= cal4_gate_srl_a[0];
          end
          // check to see if we've found edge of window
          if (!idel_set_wait)
            cal4_state <= CAL4_FIND_EDGE;
        end

        // give additional time for RDEN_R pipe to clear from effects of
        // previous pipeline (and IDELAY reset)
        CAL4_RDEN_PIPE_CLR_WAIT: begin
          // MIG 2.2: Bug fix - make sure to update GATE_DLY count, since
          // possible for FIND_EDGE->RDEN_PIPE_CLR_WAIT->FIND_WINDOW
          // transition (i.e. need to make sure the gate count updated in
          // FIND_EDGE gets reflected in GATE_DLY by the time we reach
          // state FIND_WINDOW) - previously GATE_DLY only being updated
          // during state CAL4_IDEL_WAIT
          if (SIM_ONLY != 0) begin
            for (i = 0; i < DQS_WIDTH; i = i + 1) begin: loop_sim_gate_dly_pipe
              gate_dly[(i*5)+4] <= cal4_gate_srl_a[4];
              gate_dly[(i*5)+3] <= cal4_gate_srl_a[3];
              gate_dly[(i*5)+2] <= cal4_gate_srl_a[2];
              gate_dly[(i*5)+1] <= cal4_gate_srl_a[1];
              gate_dly[(i*5)]   <= cal4_gate_srl_a[0];
            end
          end else begin
            gate_dly[(count_gate*5)+4] <= cal4_gate_srl_a[4];
            gate_dly[(count_gate*5)+3] <= cal4_gate_srl_a[3];
            gate_dly[(count_gate*5)+2] <= cal4_gate_srl_a[2];
            gate_dly[(count_gate*5)+1] <= cal4_gate_srl_a[1];
            gate_dly[(count_gate*5)]   <= cal4_gate_srl_a[0];
          end
          // look for new window
          if (calib_rden_pipe_cnt == 5'b00000)
            cal4_state <= CAL4_FIND_WINDOW;
        end

        // increment/decrement DQS/DQ IDELAY for final adjustment
        CAL4_ADJ_IDEL:
          // add underflow protection for corner case when left edge found
          // using fewer than MIN(BIT_TIME_TAPS,32) taps
          if ((cal4_idel_adj_cnt == 6'b000000) ||
              (cal4_dlyce_gate && !cal4_dlyinc_gate &&
               (cal4_idel_tap_cnt == 6'b000001))) begin
            cal4_state <= CAL4_DONE;
            // stop when all gates calibrated, or gate[0] cal'ed (for sim)
            if ((count_gate == DQS_WIDTH-1) || (SIM_ONLY != 0))
              calib_done_tmp[3] <= 1'b1;
            else
              // need for VHDL simulation to prevent out-of-index error
              next_count_gate <= count_gate + 1;
          end else begin
            cal4_idel_adj_cnt <= cal4_idel_adj_cnt - 1;
            cal4_dlyce_gate  <= 1'b1;
            // whether inc or dec depends on whether left or right edge found
            cal4_dlyinc_gate <= cal4_idel_adj_inc;
          end

        // wait for IDELAY output to settle after decrement. Check current
        // COUNT_GATE value and decide if we're done
        CAL4_DONE:
          if (!idel_set_wait) begin
            count_gate <= next_count_gate;
            if (calib_done_tmp[3]) begin
              calib_done[3] <= 1'b1;
              cal4_state <= CAL4_IDLE;
            end else begin
              // request auto-refresh after every DQS group calibrated to
              // avoid tRAS violation
              cal4_ref_req <= 1'b1;
              if (calib_ref_done)
                cal4_state <= CAL4_INIT;
            end
          end
      endcase
    end

endmodule
