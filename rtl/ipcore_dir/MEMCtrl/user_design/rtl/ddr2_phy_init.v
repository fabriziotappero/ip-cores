//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_phy_init.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Thu Aug 24 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//Reference:
//   This module is the intialization control logic of the memory interface.
//   All commands are issued from here acoording to the burst, CAS Latency and
//   the user commands.
//Revision History:
//   Rev 1.1 - Localparam WR_RECOVERY added and mapped to
//             load mode register. PK. 14/7/08
//   Rev 1.2 - To issue an Auto Refresh command to each chip during various
//             calibration stages logic modified. PK. 08/10/08
//   Rev 1.3 - Retain current data pattern for stage 4 calibration, and create
//             new pattern for stage 4. RC. 09/21/09.
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_init #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter CKE_WIDTH     = 1,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter CS_NUM        = 1,
   parameter DQ_WIDTH      = 72,
   parameter ODT_WIDTH     = 1,
   parameter ROW_WIDTH     = 14,
   parameter ADDITIVE_LAT  = 0,
   parameter BURST_LEN     = 4,
   parameter TWO_T_TIME_EN = 0,
   parameter BURST_TYPE    = 0,
   parameter CAS_LAT       = 5,
   parameter ODT_TYPE      = 1,
   parameter REDUCE_DRV    = 0,
   parameter REG_ENABLE    = 1,
   parameter TWR           = 15000,
   parameter CLK_PERIOD    = 3000,
   parameter DDR_TYPE      = 1,
   parameter SIM_ONLY      = 0
   )
  (
   input                                   clk0,
   input                                   clkdiv0,
   input                                   rst0,
   input                                   rstdiv0,
   input [3:0]                             calib_done,
   input                                   ctrl_ref_flag,
   input                                   calib_ref_req,
   output reg [3:0]                        calib_start,
   output reg                              calib_ref_done,
   output reg                              phy_init_wren,
   output reg                              phy_init_rden,
   output [ROW_WIDTH-1:0]                  phy_init_addr,
   output [BANK_WIDTH-1:0]                 phy_init_ba,
   output                                  phy_init_ras_n,
   output                                  phy_init_cas_n,
   output                                  phy_init_we_n,
   output [CS_NUM-1:0]                     phy_init_cs_n,
   output [CKE_WIDTH-1:0]                  phy_init_cke,
   output reg                              phy_init_done,
   output                                  phy_init_data_sel
   );

  // time to wait between consecutive commands in PHY_INIT - this is a
  // generic number, and must be large enough to account for worst case
  // timing parameter (tRFC - refresh-to-active) across all memory speed
  // grades and operating frequencies. Expressed in CLKDIV clock cycles.
  localparam  CNTNEXT_CMD = 7'b1111111;
  // time to wait between read and read or precharge for stage 3 & 4
  // the larger CNTNEXT_CMD can also be used, use smaller number to
  // speed up calibration - avoid tRAS violation, and speeds up simulation
  localparam  CNTNEXT_RD  = 4'b1111;

  // Write recovery (WR) time - is defined by
  // tWR (in nanoseconds) by tCK (in nanoseconds) and rounding up a
  // noninteger value to the next integer
  localparam integer WR_RECOVERY =  ((TWR + CLK_PERIOD) - 1)/CLK_PERIOD;
  localparam CS_BITS_FIX         = (CS_BITS == 0) ? 1 : CS_BITS;

  localparam  INIT_CAL1_READ            = 5'h00;
  localparam  INIT_CAL2_READ            = 5'h01;
  localparam  INIT_CAL3_READ            = 5'h02;
  localparam  INIT_CAL4_READ            = 5'h03;
  localparam  INIT_CAL1_WRITE           = 5'h04;
  localparam  INIT_CAL2_WRITE           = 5'h05;
  localparam  INIT_CAL3_WRITE           = 5'h06;
  localparam  INIT_DUMMY_ACTIVE_WAIT    = 5'h07;
  localparam  INIT_PRECHARGE            = 5'h08;
  localparam  INIT_LOAD_MODE            = 5'h09;
  localparam  INIT_AUTO_REFRESH         = 5'h0A;
  localparam  INIT_IDLE                 = 5'h0B;
  localparam  INIT_CNT_200              = 5'h0C;
  localparam  INIT_CNT_200_WAIT         = 5'h0D;
  localparam  INIT_PRECHARGE_WAIT       = 5'h0E;
  localparam  INIT_MODE_REGISTER_WAIT   = 5'h0F;
  localparam  INIT_AUTO_REFRESH_WAIT    = 5'h10;
  localparam  INIT_DEEP_MEMORY_ST       = 5'h11;
  localparam  INIT_DUMMY_ACTIVE         = 5'h12;
  localparam  INIT_CAL1_WRITE_READ      = 5'h13;
  localparam  INIT_CAL1_READ_WAIT       = 5'h14;
  localparam  INIT_CAL2_WRITE_READ      = 5'h15;
  localparam  INIT_CAL2_READ_WAIT       = 5'h16;
  localparam  INIT_CAL3_WRITE_READ      = 5'h17;
  localparam  INIT_CAL3_READ_WAIT       = 5'h18;
  localparam  INIT_CAL4_READ_WAIT       = 5'h19;
  localparam  INIT_CALIB_REF            = 5'h1A;
  localparam  INIT_ZQCL                 = 5'h1B;
  localparam  INIT_WAIT_DLLK_ZQINIT     = 5'h1C;
  localparam  INIT_CAL4_WRITE           = 5'h1D;  // MIG 3.3: New state
  localparam  INIT_CAL4_WRITE_READ      = 5'h1E;  // MIG 3.3: New state
  
  localparam  INIT_CNTR_INIT            = 4'h0;
  localparam  INIT_CNTR_PRECH_1         = 4'h1;
  localparam  INIT_CNTR_EMR2_INIT       = 4'h2;
  localparam  INIT_CNTR_EMR3_INIT       = 4'h3;
  localparam  INIT_CNTR_EMR_EN_DLL      = 4'h4;
  localparam  INIT_CNTR_MR_RST_DLL      = 4'h5;
  localparam  INIT_CNTR_CNT_200_WAIT    = 4'h6;
  localparam  INIT_CNTR_PRECH_2         = 4'h7;
  localparam  INIT_CNTR_AR_1            = 4'h8;
  localparam  INIT_CNTR_AR_2            = 4'h9;
  localparam  INIT_CNTR_MR_ACT_DLL      = 4'hA;
  localparam  INIT_CNTR_EMR_DEF_OCD     = 4'hB;
  localparam  INIT_CNTR_EMR_EXIT_OCD    = 4'hC;
  localparam  INIT_CNTR_DEEP_MEM        = 4'hD;
  // MIG 3.3: Remove extra precharge occurring at end of calibration
//  localparam  INIT_CNTR_PRECH_3         = 4'hE;
//  localparam  INIT_CNTR_DONE            = 4'hF;
  localparam  INIT_CNTR_DONE            = 4'hE;

  localparam   DDR1                     = 0;
  localparam   DDR2                     = 1;
  localparam   DDR3                     = 2;

  reg [CS_BITS_FIX :0]  auto_cnt_r;
  reg [1:0]             burst_addr_r;
  reg [1:0]             burst_cnt_r;
  wire [1:0]            burst_val;
  wire                  cal_read;
  wire                  cal_write;
  wire                  cal_write_read;
  reg                   cal1_started_r;
  reg                   cal2_started_r;
  reg                   cal4_started_r;
  reg [3:0]             calib_done_r;
  reg                   calib_ref_req_posedge;
  reg                   calib_ref_req_r;
  reg [15:0]            calib_start_shift0_r;
  reg [15:0]            calib_start_shift1_r;
  reg [15:0]            calib_start_shift2_r;
  reg [15:0]            calib_start_shift3_r;
  reg [1:0]             chip_cnt_r;
  reg [4:0]             cke_200us_cnt_r;
  reg                   cke_200us_cnt_en_r;
  reg [7:0]             cnt_200_cycle_r;
  reg                   cnt_200_cycle_done_r;
  reg [6:0]             cnt_cmd_r;
  reg                   cnt_cmd_ok_r;
  reg [3:0]             cnt_rd_r;
  reg                   cnt_rd_ok_r;
  reg                   ctrl_ref_flag_r;
  reg                   done_200us_r;
  reg [ROW_WIDTH-1:0]   ddr_addr_r;
  reg [ROW_WIDTH-1:0]   ddr_addr_r1;
  reg [BANK_WIDTH-1:0]  ddr_ba_r;
  reg [BANK_WIDTH-1:0]  ddr_ba_r1;
  reg                   ddr_cas_n_r;
  reg                   ddr_cas_n_r1;
  reg [CKE_WIDTH-1:0]   ddr_cke_r;
  reg [CS_NUM-1:0]      ddr_cs_n_r;
  reg [CS_NUM-1:0]      ddr_cs_n_r1;
  reg [CS_NUM-1:0]      ddr_cs_disable_r;
  reg                   ddr_ras_n_r;
  reg                   ddr_ras_n_r1;
  reg                   ddr_we_n_r;
  reg                   ddr_we_n_r1;
  wire [15:0]           ext_mode_reg;
  reg [3:0]             init_cnt_r;
  reg                   init_done_r;
  reg [4:0]             init_next_state;
  reg [4:0]             init_state_r;
  reg [4:0]             init_state_r1;
  reg [4:0]             init_state_r1_2t;
  reg [4:0]             init_state_r2;
  wire [15:0]           load_mode_reg;
  wire [15:0]           load_mode_reg0;
  wire [15:0]           load_mode_reg1;
  wire [15:0]           load_mode_reg2;
  wire [15:0]           load_mode_reg3;
  reg                   phy_init_done_r;
  reg                   phy_init_done_r1;
  reg                   phy_init_done_r2;
  reg                   phy_init_done_r3;
  reg                   refresh_req;
  wire [3:0]            start_cal;

  //***************************************************************************

  //*****************************************************************
  // DDR1 and DDR2 Load mode register
  // Mode Register (MR):
  //   [15:14] - unused          - 00
  //   [13]    - reserved        - 0
  //   [12]    - Power-down mode - 0 (normal)
  //   [11:9]  - write recovery  - for Auto Precharge (tWR/tCK)
  //   [8]     - DLL reset       - 0 or 1
  //   [7]     - Test Mode       - 0 (normal)
  //   [6:4]   - CAS latency     - CAS_LAT
  //   [3]     - Burst Type      - BURST_TYPE
  //   [2:0]   - Burst Length    - BURST_LEN
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR2) begin: gen_load_mode_reg_ddr2
      assign load_mode_reg[2:0]   = (BURST_LEN == 8) ? 3'b011 :
                                    ((BURST_LEN == 4) ? 3'b010 : 3'b111);
      assign load_mode_reg[3]     = BURST_TYPE;
      assign load_mode_reg[6:4]   = (CAS_LAT == 3) ? 3'b011 :
                                    ((CAS_LAT == 4) ? 3'b100 :
                                     ((CAS_LAT == 5) ? 3'b101 : 3'b111));
      assign load_mode_reg[7]     = 1'b0;
      assign load_mode_reg[8]     = 1'b0;    // init value only (DLL not reset)
      assign load_mode_reg[11:9]  = (WR_RECOVERY == 6) ? 3'b101 :
                                    ((WR_RECOVERY == 5) ? 3'b100 :
                                     ((WR_RECOVERY == 4) ? 3'b011 :
                                      ((WR_RECOVERY == 3) ? 3'b010 :
                                      3'b001)));
      assign load_mode_reg[15:12] = 4'b000;
    end else if (DDR_TYPE == DDR1)begin: gen_load_mode_reg_ddr1
      assign load_mode_reg[2:0]   = (BURST_LEN == 8) ? 3'b011 :
                                    ((BURST_LEN == 4) ? 3'b010 :
                                     ((BURST_LEN == 2) ? 3'b001 : 3'b111));
      assign load_mode_reg[3]     = BURST_TYPE;
      assign load_mode_reg[6:4]   = (CAS_LAT == 2) ? 3'b010 :
                                    ((CAS_LAT == 3) ? 3'b011 :
                                     ((CAS_LAT == 25) ? 3'b110 : 3'b111));
      assign load_mode_reg[12:7]  = 6'b000000; // init value only
      assign load_mode_reg[15:13]  = 3'b000;
    end
  endgenerate

  //*****************************************************************
  // DDR1 and DDR2 ext mode register
  // Extended Mode Register (MR):
  //   [15:14] - unused          - 00
  //   [13]    - reserved        - 0
  //   [12]    - output enable   - 0 (enabled)
  //   [11]    - RDQS enable     - 0 (disabled)
  //   [10]    - DQS# enable     - 0 (enabled)
  //   [9:7]   - OCD Program     - 111 or 000 (first 111, then 000 during init)
  //   [6]     - RTT[1]          - RTT[1:0] = 0(no ODT), 1(75), 2(150), 3(50)
  //   [5:3]   - Additive CAS    - ADDITIVE_CAS
  //   [2]     - RTT[0]
  //   [1]     - Output drive    - REDUCE_DRV (= 0(full), = 1 (reduced)
  //   [0]     - DLL enable      - 0 (normal)
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR2) begin: gen_ext_mode_reg_ddr2
      assign ext_mode_reg[0]     = 1'b0;
      assign ext_mode_reg[1]     = REDUCE_DRV;
      assign ext_mode_reg[2]     = ((ODT_TYPE == 1) || (ODT_TYPE == 3)) ?
                                   1'b1 : 1'b0;
      assign ext_mode_reg[5:3]   = (ADDITIVE_LAT == 0) ? 3'b000 :
                                   ((ADDITIVE_LAT == 1) ? 3'b001 :
                                    ((ADDITIVE_LAT == 2) ? 3'b010 :
                                     ((ADDITIVE_LAT == 3) ? 3'b011 :
                                      ((ADDITIVE_LAT == 4) ? 3'b100 :
                                      3'b111))));
      assign ext_mode_reg[6]     = ((ODT_TYPE == 2) || (ODT_TYPE == 3)) ?
                                   1'b1 : 1'b0;
      assign ext_mode_reg[9:7]   = 3'b000;
      assign ext_mode_reg[10]    = 1'b0;
      assign ext_mode_reg[15:10] = 6'b000000;
    end else if (DDR_TYPE == DDR1) begin: gen_ext_mode_reg_ddr1
      assign ext_mode_reg[0]     = 1'b0;
      assign ext_mode_reg[1]     = REDUCE_DRV;
      assign ext_mode_reg[12:2]  = 11'b00000000000;
      assign ext_mode_reg[15:13] = 3'b000;
    end
  endgenerate

  //*****************************************************************
  // DDR3 Load mode reg0
  // Mode Register (MR0):
  //   [15:13] - unused          - 000
  //   [12]    - Precharge Power-down DLL usage - 0 (DLL frozen, slow-exit),
  //             1 (DLL maintained)
  //   [11:9]  - write recovery for Auto Precharge (tWR/tCK = 6)
  //   [8]     - DLL reset       - 0 or 1
  //   [7]     - Test Mode       - 0 (normal)
  //   [6:4],[2]   - CAS latency     - CAS_LAT
  //   [3]     - Burst Type      - BURST_TYPE
  //   [1:0]   - Burst Length    - BURST_LEN
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR3) begin: gen_load_mode_reg0_ddr3
      assign load_mode_reg0[1:0]   = (BURST_LEN == 8) ? 2'b00 :
                                     ((BURST_LEN == 4) ? 2'b10 : 2'b11);
      // Part of CAS latency. This bit is '0' for all CAS latencies
      assign load_mode_reg0[2]     = 1'b0;
      assign load_mode_reg0[3]     = BURST_TYPE;
      assign load_mode_reg0[6:4]   = (CAS_LAT == 5) ? 3'b001 :
                                     (CAS_LAT == 6) ? 3'b010 : 3'b111;
      assign load_mode_reg0[7]     = 1'b0;
      // init value only (DLL reset)
      assign load_mode_reg0[8]     = 1'b1;
      assign load_mode_reg0[11:9]  = 3'b010;
      // Precharge Power-Down DLL 'slow-exit'
      assign load_mode_reg0[12]    = 1'b0;
      assign load_mode_reg0[15:13] = 3'b000;
    end
  endgenerate

  //*****************************************************************
  // DDR3 Load mode reg1
  // Mode Register (MR1):
  //   [15:13] - unused          - 00
  //   [12]    - output enable   - 0 (enabled for DQ, DQS, DQS#)
  //   [11]    - TDQS enable     - 0 (TDQS disabled and DM enabled)
  //   [10]    - reserved   - 0 (must be '0')
  //   [9]     - RTT[2]     - 0
  //   [8]     - reserved   - 0 (must be '0')
  //   [7]     - write leveling - 0 (disabled), 1 (enabled)
  //   [6]     - RTT[1]          - RTT[1:0] = 0(no ODT), 1(75), 2(150), 3(50)
  //   [5]     - Output driver impedance[1] - 0 (RZQ/6 and RZQ/7)
  //   [4:3]   - Additive CAS    - ADDITIVE_CAS
  //   [2]     - RTT[0]
  //   [1]     - Output driver impedance[0] - 0(RZQ/6), or 1 (RZQ/7)
  //   [0]     - DLL enable      - 0 (normal)
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR3) begin: gen_ext_mode_reg1_ddr3
      // DLL enabled during Imitialization
      assign load_mode_reg1[0]     = 1'b0;
      // RZQ/6
      assign load_mode_reg1[1]     = REDUCE_DRV;
      assign load_mode_reg1[2]     = ((ODT_TYPE == 1) || (ODT_TYPE == 3)) ?
                                     1'b1 : 1'b0;
      assign load_mode_reg1[4:3]   = (ADDITIVE_LAT == 0) ? 2'b00 :
                                     ((ADDITIVE_LAT == 1) ? 2'b01 :
                                      ((ADDITIVE_LAT == 2) ? 2'b10 :
                                       3'b111));
      // RZQ/6
      assign load_mode_reg1[5]     = 1'b0;
      assign load_mode_reg1[6]     = ((ODT_TYPE == 2) || (ODT_TYPE == 3)) ?
                                   1'b1 : 1'b0;
      // Make zero WRITE_LEVEL
      assign load_mode_reg1[7]   = 0;
      assign load_mode_reg1[8]   = 1'b0;
      assign load_mode_reg1[9]   = 1'b0;
      assign load_mode_reg1[10]    = 1'b0;
      assign load_mode_reg1[15:11] = 5'b00000;
    end
  endgenerate

  //*****************************************************************
  // DDR3 Load mode reg2
  // Mode Register (MR2):
  //   [15:11] - unused     - 00
  //   [10:9]  - RTT_WR     - 00 (Dynamic ODT off)
  //   [8]     - reserved   - 0 (must be '0')
  //   [7]     - self-refresh temperature range -
  //               0 (normal), 1 (extended)
  //   [6]     - Auto Self-Refresh - 0 (manual), 1(auto)
  //   [5:3]   - CAS Write Latency (CWL) -
  //               000 (5 for 400 MHz device),
  //               001 (6 for 400 MHz to 533 MHz devices),
  //               010 (7 for 533 MHz to 667 MHz devices),
  //               011 (8 for 667 MHz to 800 MHz)
  //   [2:0]   - Partial Array Self-Refresh (Optional)      -
  //               000 (full array)
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR3) begin: gen_ext_mode_reg2_ddr3
      assign load_mode_reg2[2:0]     = 3'b000;
      assign load_mode_reg2[5:3]   = (CAS_LAT == 5) ? 3'b000 :
                                     (CAS_LAT == 6) ? 3'b001 : 3'b111;
      assign load_mode_reg2[6]     = 1'b0; // Manual Self-Refresh
      assign load_mode_reg2[7]   = 1'b0;
      assign load_mode_reg2[8]   = 1'b0;
      assign load_mode_reg2[10:9]  = 2'b00;
      assign load_mode_reg2[15:11] = 5'b00000;
    end
  endgenerate

  //*****************************************************************
  // DDR3 Load mode reg3
  // Mode Register (MR3):
  //   [15:3] - unused          - All zeros
  //   [2]     - MPR Operation - 0(normal operation), 1(data flow from MPR)
  //   [1:0]   - MPR location     - 00 (Predefined pattern)
  //*****************************************************************

  generate
    if (DDR_TYPE == DDR3)begin: gen_ext_mode_reg3_ddr3
      assign load_mode_reg3[1:0]   = 2'b00;
      assign load_mode_reg3[2]     = 1'b0;
      assign load_mode_reg3[15:3] = 13'b0000000000000;
    end
  endgenerate

  //***************************************************************************
  // Logic for calibration start, and for auto-refresh during cal request
  // CALIB_REF_REQ is used by calibration logic to request auto-refresh
  // durign calibration (used to avoid tRAS violation is certain calibration
  // stages take a long time). Once the auto-refresh is complete and cal can
  // be resumed, CALIB_REF_DONE is asserted by PHY_INIT.
  //***************************************************************************

  // generate pulse for each of calibration start controls
  assign start_cal[0] = ((init_state_r1 == INIT_CAL1_READ) &&
                         (init_state_r2 != INIT_CAL1_READ));
  assign start_cal[1] = ((init_state_r1 == INIT_CAL2_READ) &&
                         (init_state_r2 != INIT_CAL2_READ));
  assign start_cal[2] = ((init_state_r1 == INIT_CAL3_READ) &&
                         (init_state_r2 == INIT_CAL3_WRITE_READ));
  assign start_cal[3] = ((init_state_r1 == INIT_CAL4_READ) &&
                         (init_state_r2 != INIT_CAL4_READ));
  // MIG 3.3: Change to accomodate FSM changes related to stage 4 calibration
//                         (init_state_r2 == INIT_CAL4_WRITE_READ));

  // Generate positive-edge triggered, latched signal to force initialization
  // to pause calibration, and to issue auto-refresh. Clear flag as soon as
  // refresh initiated
  always @(posedge clkdiv0)
    if (rstdiv0) begin
      calib_ref_req_r       <= 1'b0;
      calib_ref_req_posedge <= 1'b0;
      refresh_req           <= 1'b0;
    end else begin
      calib_ref_req_r       <= calib_ref_req;
      calib_ref_req_posedge <= calib_ref_req & ~calib_ref_req_r;
      if (init_state_r1 == INIT_AUTO_REFRESH)
        refresh_req <= 1'b0;
      else if (calib_ref_req_posedge)
        refresh_req <= 1'b1;
    end

  // flag to tell cal1 calibration was started.
  // This flag is used for cal1 auto refreshes
  // some of these bits may not be needed - only needed for those stages that
  // need refreshes within the stage (i.e. very long stages)
  always @(posedge clkdiv0)
    if (rstdiv0) begin
      cal1_started_r <= 1'b0;
      cal2_started_r <= 1'b0;
      cal4_started_r <= 1'b0;
    end else begin
      if (calib_start[0])
        cal1_started_r <= 1'b1;
      if (calib_start[1])
        cal2_started_r <= 1'b1;
      if (calib_start[3])
        cal4_started_r <= 1'b1;
    end

  // Delay start of each calibration by 16 clock cycles to
  // ensure that when calibration logic begins, that read data is already
  // appearing on the bus. Don't really need it, it's more for simulation
  // purposes. Each circuit should synthesize using an SRL16.
  // In first stage of calibration  periodic auto refreshes
  // will be issued to meet memory timing. calib_start_shift0_r[15] will be
  // asserted more than once.calib_start[0] is anded with cal1_started_r so
  // that it is asserted only once. cal1_refresh_done is anded with
  // cal1_started_r so that it is asserted after the auto refreshes.
  always @(posedge clkdiv0) begin
    calib_start_shift0_r <= {calib_start_shift0_r[14:0], start_cal[0]};
    calib_start_shift1_r <= {calib_start_shift1_r[14:0], start_cal[1]};
    calib_start_shift2_r <= {calib_start_shift2_r[14:0], start_cal[2]};
    calib_start_shift3_r <= {calib_start_shift3_r[14:0], start_cal[3]};
    calib_start[0]       <= calib_start_shift0_r[15] & ~cal1_started_r;
    calib_start[1]       <= calib_start_shift1_r[15] & ~cal2_started_r;
    calib_start[2]       <= calib_start_shift2_r[15];
    calib_start[3]       <= calib_start_shift3_r[15] & ~cal4_started_r;
    calib_ref_done       <= calib_start_shift0_r[15] |
                            calib_start_shift1_r[15] |
                            calib_start_shift3_r[15];
  end

  // generate delay for various states that require it (no maximum delay
  // requirement, make sure that terminal count is large enough to cover
  // all cases)
  always @(posedge clkdiv0) begin
    case (init_state_r)
      INIT_PRECHARGE_WAIT,
      INIT_MODE_REGISTER_WAIT,
      INIT_AUTO_REFRESH_WAIT,
      INIT_DUMMY_ACTIVE_WAIT,
      INIT_CAL1_WRITE_READ,
      INIT_CAL1_READ_WAIT,
      INIT_CAL2_WRITE_READ,
      INIT_CAL2_READ_WAIT,
      INIT_CAL3_WRITE_READ,
      INIT_CAL4_WRITE_READ :
        cnt_cmd_r <= cnt_cmd_r + 1;
      default:
        cnt_cmd_r <= 7'b0000000;
    endcase
  end

  // assert when count reaches the value
  always @(posedge clkdiv0) begin
    if(cnt_cmd_r == CNTNEXT_CMD)
      cnt_cmd_ok_r <= 1'b1;
    else
      cnt_cmd_ok_r <= 1'b0;
  end

  always @(posedge clkdiv0) begin
    case (init_state_r)
      INIT_CAL3_READ_WAIT,
      INIT_CAL4_READ_WAIT:
        cnt_rd_r <= cnt_rd_r + 1;
      default:
        cnt_rd_r <= 4'b0000;
    endcase
  end

  always @(posedge clkdiv0) begin
    if(cnt_rd_r == CNTNEXT_RD)
      cnt_rd_ok_r <= 1'b1;
    else
      cnt_rd_ok_r <= 1'b0;
  end

  //***************************************************************************
  // Initial delay after power-on
  //***************************************************************************

  // register the refresh flag from the controller.
  // The refresh flag is in full frequency domain - so a pulsed version must
  // be generated for half freq domain using 2 consecutive full clk cycles
  // The registered version is used for the 200us counter
  always @(posedge clk0)
    ctrl_ref_flag_r <= ctrl_ref_flag;
  always @(posedge clkdiv0)
    cke_200us_cnt_en_r <= ctrl_ref_flag || ctrl_ref_flag_r;

  // 200us counter for cke
  always @(posedge clkdiv0)
    if (rstdiv0) begin
      // skip power-up count if only simulating
      if (SIM_ONLY)
        cke_200us_cnt_r <= 5'b00001;
      else
        cke_200us_cnt_r <= 5'd27;
    end else if (cke_200us_cnt_en_r)
      cke_200us_cnt_r <= cke_200us_cnt_r - 1;

  always @(posedge clkdiv0)
    if (rstdiv0)
      done_200us_r <= 1'b0;
    else if (!done_200us_r)
      done_200us_r <= (cke_200us_cnt_r == 5'b00000);

  // 200 clocks counter - count value : h'64 required for initialization
  // Counts 100 divided by two clocks
  always @(posedge clkdiv0)
    if (rstdiv0 || (init_state_r == INIT_CNT_200))
      cnt_200_cycle_r <= 8'h64;
    else if  (init_state_r == INIT_ZQCL) // ddr3
      cnt_200_cycle_r <= 8'hC8;
    else if (cnt_200_cycle_r != 8'h00)
      cnt_200_cycle_r <= cnt_200_cycle_r - 1;

  always @(posedge clkdiv0)
    if (rstdiv0 || (init_state_r == INIT_CNT_200)
        || (init_state_r == INIT_ZQCL))
      cnt_200_cycle_done_r <= 1'b0;
    else if (cnt_200_cycle_r == 8'h00)
      cnt_200_cycle_done_r <= 1'b1;

  //*****************************************************************
  //   handle deep memory configuration:
  //   During initialization: Repeat initialization sequence once for each
  //   chip select. Note that we could perform initalization for all chip
  //   selects simulataneously. Probably fine - any potential SI issues with
  //   auto refreshing all chip selects at once?
  //   Once initialization complete, assert only CS[1] for calibration.
  //*****************************************************************

  always @(posedge clkdiv0)
    if (rstdiv0) begin
      chip_cnt_r <= 2'b00;
    end else if (init_state_r == INIT_DEEP_MEMORY_ST) begin
      if (chip_cnt_r != CS_NUM)
        chip_cnt_r <= chip_cnt_r + 1;
      else
        chip_cnt_r <= 2'b00;
    // MIG 2.4: Modified to issue an Auto Refresh commmand
    // to each chip select during various calibration stages
    end else if (init_state_r == INIT_PRECHARGE && init_done_r) begin
      chip_cnt_r <= 2'b00;
    end else if (init_state_r1 == INIT_AUTO_REFRESH && init_done_r) begin
      if (chip_cnt_r < (CS_NUM-1))
        chip_cnt_r <= chip_cnt_r + 1;
    end

  // keep track of which chip selects got auto-refreshed (avoid auto-refreshing
  // all CS's at once to avoid current spike)
  always @(posedge clkdiv0)begin
    if (rstdiv0 || init_state_r == INIT_PRECHARGE)
      auto_cnt_r <= 'd0;
    else if (init_state_r == INIT_AUTO_REFRESH && init_done_r) begin
      if (auto_cnt_r < CS_NUM)
        auto_cnt_r <= auto_cnt_r + 1;
    end
  end

  always @(posedge clkdiv0)
    if (rstdiv0) begin
      ddr_cs_n_r <= {CS_NUM{1'b1}};
    end else begin
      ddr_cs_n_r <= {CS_NUM{1'b1}};
      if ((init_state_r == INIT_DUMMY_ACTIVE) ||
          ((init_state_r == INIT_PRECHARGE) && (~init_done_r))||
          (init_state_r == INIT_LOAD_MODE) ||
          (init_state_r == INIT_AUTO_REFRESH) ||
          (init_state_r  == INIT_ZQCL    ) ||
          (((init_state_r == INIT_CAL1_READ) ||
            (init_state_r == INIT_CAL2_READ) ||
            (init_state_r == INIT_CAL3_READ) ||
            (init_state_r == INIT_CAL4_READ) ||
            (init_state_r == INIT_CAL1_WRITE) ||
            (init_state_r == INIT_CAL2_WRITE) ||
            (init_state_r == INIT_CAL3_WRITE) ||
            (init_state_r == INIT_CAL4_WRITE)) && (burst_cnt_r == 2'b00)))
        ddr_cs_n_r[chip_cnt_r] <= 1'b0;
      else if (init_state_r == INIT_PRECHARGE)
        ddr_cs_n_r <= {CS_NUM{1'b0}};
      else
        ddr_cs_n_r[chip_cnt_r] <= 1'b1;
    end

  //***************************************************************************
  // Write/read burst logic
  //***************************************************************************

  assign cal_write = ((init_state_r == INIT_CAL1_WRITE) ||
                      (init_state_r == INIT_CAL2_WRITE) ||
                      (init_state_r == INIT_CAL3_WRITE) ||
                      (init_state_r == INIT_CAL4_WRITE));
  assign cal_read = ((init_state_r == INIT_CAL1_READ) ||
                     (init_state_r == INIT_CAL2_READ) ||
                     (init_state_r == INIT_CAL3_READ) ||
                     (init_state_r == INIT_CAL4_READ));
  assign cal_write_read = ((init_state_r == INIT_CAL1_READ) ||
                           (init_state_r == INIT_CAL2_READ) ||
                           (init_state_r == INIT_CAL3_READ) ||
                           (init_state_r == INIT_CAL4_READ) ||
                           (init_state_r == INIT_CAL1_WRITE) ||
                           (init_state_r == INIT_CAL2_WRITE) ||
                           (init_state_r == INIT_CAL3_WRITE) ||
                           (init_state_r == INIT_CAL4_WRITE));

  assign burst_val = (BURST_LEN == 4) ? 2'b00 :
                     (BURST_LEN == 8) ? 2'b01 : 2'b00;

  // keep track of current address - need this if burst length < 8 for
  // stage 2-4 calibration writes and reads. Make sure value always gets
  // initialized to 0 before we enter write/read state. This is used to
  // keep track of when another burst must be issued
  always @(posedge clkdiv0)
    if (cal_write_read)
      burst_addr_r <= burst_addr_r + 2;
    else
      burst_addr_r <= 2'b00;

  // write/read burst count
  always @(posedge clkdiv0)
    if (cal_write_read)
      if (burst_cnt_r == 2'b00)
        burst_cnt_r <= burst_val;
      else // SHOULD THIS BE -2 CHECK THIS LOGIC
        burst_cnt_r <= burst_cnt_r - 1;
    else
      burst_cnt_r <= 2'b00;

  // indicate when a write is occurring
  always @(posedge clkdiv0)
    // MIG 2.1: Remove (burst_addr_r<4) term - not used
    // phy_init_wren <= cal_write && (burst_addr_r < 3'd4);
    phy_init_wren <= cal_write;

  // used for read enable calibration, pulse to indicate when read issued
  always @(posedge clkdiv0)
    // MIG 2.1: Remove (burst_addr_r<4) term - not used
    // phy_init_rden <= cal_read && (burst_addr_r < 3'd4);
    phy_init_rden <= cal_read;

  //***************************************************************************
  // Initialization state machine
  //***************************************************************************

  always @(posedge clkdiv0)
    // every time we need to initialize another rank of memory, need to
    // reset init count, and repeat the entire initialization (but not
    // calibration) sequence
    if (rstdiv0 || (init_state_r == INIT_DEEP_MEMORY_ST))
      init_cnt_r <= INIT_CNTR_INIT;
    else if ((DDR_TYPE == DDR1) && (init_state_r == INIT_PRECHARGE) &&
             (init_cnt_r == INIT_CNTR_PRECH_1))
      // skip EMR(2) and EMR(3) register loads
      init_cnt_r <= INIT_CNTR_EMR_EN_DLL;
    else if ((DDR_TYPE == DDR1) && (init_state_r == INIT_LOAD_MODE) &&
             (init_cnt_r == INIT_CNTR_MR_ACT_DLL))
      // skip OCD calibration for DDR1
      init_cnt_r <= INIT_CNTR_DEEP_MEM;
    else if ((DDR_TYPE == DDR3) && (init_state_r ==  INIT_ZQCL))
      // skip states for DDR3
      init_cnt_r <= INIT_CNTR_DEEP_MEM;
    else if ((init_state_r == INIT_LOAD_MODE) ||
             ((init_state_r == INIT_PRECHARGE) && 
              (init_state_r1 != INIT_CALIB_REF)) ||
             ((init_state_r == INIT_AUTO_REFRESH) && (~init_done_r)) ||
             (init_state_r == INIT_CNT_200) ||
             // MIG 3.3: Added increment when starting calibration
             ((init_state_r == INIT_DUMMY_ACTIVE) &&
              (init_state_r1 == INIT_IDLE)))
      init_cnt_r <= init_cnt_r + 1;

  always @(posedge clkdiv0) begin
    if ((init_state_r == INIT_IDLE) && (init_cnt_r == INIT_CNTR_DONE)) begin
      phy_init_done_r <= 1'b1;
    end else
      phy_init_done_r <= 1'b0;
  end

  // phy_init_done to the controller and the user interface.
  // It is delayed by four clocks to account for the
  // multi cycle path constraint to the (phy_init_data_sel)
  // to the phy layer.
  always @(posedge clkdiv0) begin
    phy_init_done_r1 <= phy_init_done_r;
    phy_init_done_r2 <= phy_init_done_r1;
    phy_init_done_r3 <= phy_init_done_r2;
    phy_init_done <= phy_init_done_r3;
  end

  // Instantiate primitive to allow this flop to be attached to multicycle
  // path constraint in UCF. This signal goes to PHY_WRITE and PHY_CTL_IO
  // datapath logic only. Because it is a multi-cycle path, it can be
  // clocked by either CLKDIV0 or CLK0.
  FDRSE u_ff_phy_init_data_sel
    (
     .Q   (phy_init_data_sel),
     .C   (clkdiv0),
     .CE  (1'b1),
     .D   (phy_init_done_r1),
     .R   (1'b0),
     .S   (1'b0)
     ) /* synthesis syn_preserve=1 */
       /* synthesis syn_replicate = 0 */;

  //synthesis translate_off
  always @(posedge calib_done[0])
      $display ("First Stage Calibration completed at time %t", $time);

  always @(posedge calib_done[1])
    $display ("Second Stage Calibration completed at time %t", $time);

  always @(posedge calib_done[2]) begin
    $display ("Third Stage Calibration completed at time %t", $time);
  end

  always @(posedge calib_done[3]) begin
    $display ("Fourth Stage Calibration completed at time %t", $time);
    $display ("Calibration completed at time %t", $time);
  end
  //synthesis translate_on

  always @(posedge clkdiv0) begin
    if ((init_cnt_r >= INIT_CNTR_DEEP_MEM))begin
       init_done_r <= 1'b1;
    end else
       init_done_r <= 1'b0;
  end

  //*****************************************************************

  always @(posedge clkdiv0)
    if (rstdiv0) begin
      init_state_r  <= INIT_IDLE;
      init_state_r1 <= INIT_IDLE;
      init_state_r2 <= INIT_IDLE;
      calib_done_r  <= 4'b0000;
    end else begin
      init_state_r  <= init_next_state;
      init_state_r1 <= init_state_r;
      init_state_r2 <= init_state_r1;
      calib_done_r  <= calib_done; // register for timing
    end

  always @(*) begin
    init_next_state = init_state_r;
    (* full_case, parallel_case *) case (init_state_r)
      INIT_IDLE: begin
        if (done_200us_r) begin
          (* parallel_case *) case (init_cnt_r)
            INIT_CNTR_INIT:
              init_next_state = INIT_CNT_200;
            INIT_CNTR_PRECH_1:
              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_EMR2_INIT:
              init_next_state = INIT_LOAD_MODE; // EMR(2)
            INIT_CNTR_EMR3_INIT:
              init_next_state = INIT_LOAD_MODE; // EMR(3);
            INIT_CNTR_EMR_EN_DLL:
              init_next_state = INIT_LOAD_MODE; // EMR, enable DLL
            INIT_CNTR_MR_RST_DLL:
              init_next_state = INIT_LOAD_MODE; // MR, reset DLL
            INIT_CNTR_CNT_200_WAIT:begin
              if(DDR_TYPE == DDR3)
                 init_next_state = INIT_ZQCL; // DDR3
              else
                // Wait 200cc after reset DLL
                init_next_state = INIT_CNT_200;
            end
            INIT_CNTR_PRECH_2:
              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_AR_1:
              init_next_state = INIT_AUTO_REFRESH;
            INIT_CNTR_AR_2:
              init_next_state = INIT_AUTO_REFRESH;
            INIT_CNTR_MR_ACT_DLL:
              init_next_state = INIT_LOAD_MODE; // MR, unreset DLL
            INIT_CNTR_EMR_DEF_OCD:
              init_next_state = INIT_LOAD_MODE; // EMR, OCD default
            INIT_CNTR_EMR_EXIT_OCD:
              init_next_state = INIT_LOAD_MODE; // EMR, enable OCD exit
            INIT_CNTR_DEEP_MEM: begin
               if ((chip_cnt_r < CS_NUM-1))
                  init_next_state = INIT_DEEP_MEMORY_ST;
              else if (cnt_200_cycle_done_r)
                init_next_state = INIT_DUMMY_ACTIVE;
              else
                init_next_state = INIT_IDLE;
            end
  // MIG 3.3: Remove extra precharge occurring at end of calibration
//            INIT_CNTR_PRECH_3:
//              init_next_state = INIT_PRECHARGE;
            INIT_CNTR_DONE:
              init_next_state = INIT_IDLE;
            default :
              init_next_state = INIT_IDLE;
          endcase
        end
      end
      INIT_CNT_200:
        init_next_state = INIT_CNT_200_WAIT;
      INIT_CNT_200_WAIT:
        if (cnt_200_cycle_done_r)
          init_next_state = INIT_IDLE;
      INIT_PRECHARGE:
        init_next_state = INIT_PRECHARGE_WAIT;
      INIT_PRECHARGE_WAIT:
        if (cnt_cmd_ok_r)begin
          if (init_done_r && (!(&calib_done_r)))
            init_next_state = INIT_AUTO_REFRESH;
          else
            init_next_state = INIT_IDLE;
        end
      INIT_ZQCL:
        init_next_state = INIT_WAIT_DLLK_ZQINIT;
      INIT_WAIT_DLLK_ZQINIT:
        if (cnt_200_cycle_done_r)
          init_next_state = INIT_IDLE;
      INIT_LOAD_MODE:
        init_next_state = INIT_MODE_REGISTER_WAIT;
      INIT_MODE_REGISTER_WAIT:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_IDLE;
      INIT_AUTO_REFRESH:
        init_next_state = INIT_AUTO_REFRESH_WAIT;
      INIT_AUTO_REFRESH_WAIT:
        // MIG 2.4: Modified to issue an Auto Refresh commmand
        // to each chip select during various calibration stages
        if (auto_cnt_r < CS_NUM && init_done_r) begin
          if (cnt_cmd_ok_r)
            init_next_state = INIT_AUTO_REFRESH;
        end else if (cnt_cmd_ok_r)begin
            if (init_done_r)
              init_next_state = INIT_DUMMY_ACTIVE;
            else
              init_next_state = INIT_IDLE;
        end
      INIT_DEEP_MEMORY_ST:
        init_next_state = INIT_IDLE;
      // single row activate. All subsequent calibration writes and
      // read will take place in this row
      INIT_DUMMY_ACTIVE:
        init_next_state = INIT_DUMMY_ACTIVE_WAIT;
      INIT_DUMMY_ACTIVE_WAIT:
        if (cnt_cmd_ok_r)begin
          if (~calib_done_r[0]) begin
            // if returning to stg1 after refresh, don't need to write
            if (cal1_started_r)
              init_next_state = INIT_CAL1_READ;
            // if first entering stg1, need to write training pattern
            else
              init_next_state = INIT_CAL1_WRITE;
          end else if (~calib_done[1]) begin
            if (cal2_started_r)
              init_next_state = INIT_CAL2_READ;
            else
              init_next_state = INIT_CAL2_WRITE;
          end else if (~calib_done_r[2])
            // Stage 3 only requires a refresh after the entire stage is
            // finished
            init_next_state = INIT_CAL3_WRITE;
          else begin
            // Stage 4 requires a refresh after every DQS group
            if (cal4_started_r)
              init_next_state = INIT_CAL4_READ;
            else
              init_next_state = INIT_CAL4_WRITE;
          end
        end
      // Stage 1 calibration (write and continuous read)
      INIT_CAL1_WRITE:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL1_WRITE_READ;
      INIT_CAL1_WRITE_READ:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CAL1_READ;
      INIT_CAL1_READ:
        // Stage 1 requires inter-stage auto-refresh
        if (calib_done_r[0] || refresh_req)
          init_next_state = INIT_CAL1_READ_WAIT;
      INIT_CAL1_READ_WAIT:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CALIB_REF;
      // Stage 2 calibration (write and continuous read)
      INIT_CAL2_WRITE:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL2_WRITE_READ;
      INIT_CAL2_WRITE_READ:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CAL2_READ;
      INIT_CAL2_READ:
        // Stage 2 requires inter-stage auto-refresh
        if (calib_done_r[1] || refresh_req)
          init_next_state = INIT_CAL2_READ_WAIT;
      INIT_CAL2_READ_WAIT:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CALIB_REF;
      // Stage 3 calibration (write and continuous read)
      INIT_CAL3_WRITE:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL3_WRITE_READ;
      INIT_CAL3_WRITE_READ:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CAL3_READ;
      INIT_CAL3_READ:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL3_READ_WAIT;
      INIT_CAL3_READ_WAIT: begin
        if (cnt_rd_ok_r)
          if (calib_done_r[2]) begin
            init_next_state = INIT_CALIB_REF;
          end else
            init_next_state = INIT_CAL3_READ;
      end
      // Stage 4 calibration
      INIT_CAL4_WRITE:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL4_WRITE_READ;
      INIT_CAL4_WRITE_READ:
        if (cnt_cmd_ok_r)
          init_next_state = INIT_CAL4_READ;
      INIT_CAL4_READ:
        if (burst_addr_r == 2'b10)
          init_next_state = INIT_CAL4_READ_WAIT;
      INIT_CAL4_READ_WAIT: begin
        if (cnt_rd_ok_r)
          // Stage 4 requires inter-stage auto-refresh
          if (calib_done_r[3] || refresh_req)
            // MIG 3.3: With removal of extra precharge, proceed to
            //  state CALIB_REF first to avoid incrementing init_cntr
//            init_next_state = INIT_PRECHARGE;
            init_next_state = INIT_CALIB_REF;   
          else
            init_next_state = INIT_CAL4_READ;
      end
      INIT_CALIB_REF:
        init_next_state = INIT_PRECHARGE;
    endcase
  end

  //***************************************************************************
  // Memory control/address
  //***************************************************************************

  always @(posedge clkdiv0)
    if ((init_state_r == INIT_DUMMY_ACTIVE) ||
        (init_state_r == INIT_PRECHARGE) ||
        (init_state_r == INIT_LOAD_MODE) ||
        (init_state_r == INIT_AUTO_REFRESH)) begin
      ddr_ras_n_r <= 1'b0;
    end else begin
      ddr_ras_n_r <= 1'b1;
    end

  always @(posedge clkdiv0)
    if ((init_state_r == INIT_LOAD_MODE) ||
        (init_state_r == INIT_AUTO_REFRESH) ||
        (cal_write_read && (burst_cnt_r == 2'b00))) begin
      ddr_cas_n_r <= 1'b0;
    end else begin
      ddr_cas_n_r <= 1'b1;
    end

  always @(posedge clkdiv0)
    if ((init_state_r == INIT_LOAD_MODE) ||
        (init_state_r == INIT_PRECHARGE) ||
        (init_state_r == INIT_ZQCL) ||
        (cal_write && (burst_cnt_r == 2'b00)))begin
      ddr_we_n_r <= 1'b0;
    end else begin
      ddr_we_n_r <= 1'b1;
    end

  //*****************************************************************
  // memory address during init
  //*****************************************************************

  always @(posedge clkdiv0) begin
    if ((init_state_r == INIT_PRECHARGE)
        || (init_state_r == INIT_ZQCL))begin
      // Precharge all - set A10 = 1
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
      ddr_addr_r[10] <= 1'b1;
      ddr_ba_r <= {BANK_WIDTH{1'b0}};
    end else if (init_state_r == INIT_LOAD_MODE) begin
      ddr_ba_r <= {BANK_WIDTH{1'b0}};
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
      case (init_cnt_r)
        // EMR (2)
        INIT_CNTR_EMR2_INIT: begin
          ddr_ba_r[1:0] <= 2'b10;
          ddr_addr_r    <= {ROW_WIDTH{1'b0}};
        end
        // EMR (3)
        INIT_CNTR_EMR3_INIT: begin
          ddr_ba_r[1:0] <= 2'b11;
          if(DDR_TYPE == DDR3)
            ddr_addr_r    <= load_mode_reg3[ROW_WIDTH-1:0];
          else
            ddr_addr_r    <= {ROW_WIDTH{1'b0}};
        end
        // EMR write - A0 = 0 for DLL enable
        INIT_CNTR_EMR_EN_DLL: begin
          ddr_ba_r[1:0] <= 2'b01;
          if(DDR_TYPE == DDR3)
            ddr_addr_r <= load_mode_reg1[ROW_WIDTH-1:0];
          else
            ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
        end
        // MR write, reset DLL (A8=1)
        INIT_CNTR_MR_RST_DLL: begin
          if(DDR_TYPE == DDR3)
            ddr_addr_r <= load_mode_reg0[ROW_WIDTH-1:0];
          else
            ddr_addr_r <= load_mode_reg[ROW_WIDTH-1:0];
          ddr_ba_r[1:0] <= 2'b00;
          ddr_addr_r[8] <= 1'b1;
        end
        // MR write, unreset DLL (A8=0)
        INIT_CNTR_MR_ACT_DLL: begin
          ddr_ba_r[1:0] <= 2'b00;
          ddr_addr_r <= load_mode_reg[ROW_WIDTH-1:0];
        end
        // EMR write, OCD default state
        INIT_CNTR_EMR_DEF_OCD: begin
          ddr_ba_r[1:0] <= 2'b01;
          ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
          ddr_addr_r[9:7] <= 3'b111;
        end
        // EMR write - OCD exit
        INIT_CNTR_EMR_EXIT_OCD: begin
          ddr_ba_r[1:0] <= 2'b01;
          ddr_addr_r <= ext_mode_reg[ROW_WIDTH-1:0];
        end
        default: begin
          ddr_ba_r <= {BANK_WIDTH{1'bx}};
          ddr_addr_r <= {ROW_WIDTH{1'bx}};
        end
      endcase
    end else if (cal_write_read) begin
      // when writing or reading for Stages 2-4, since training pattern is
      // either 4 (stage 2) or 8 (stage 3-4) long, if BURST LEN < 8, then
      // need to issue multiple bursts to read entire training pattern
      ddr_addr_r[ROW_WIDTH-1:3] <= {ROW_WIDTH-4{1'b0}};
      ddr_addr_r[2:0]           <= {burst_addr_r, 1'b0};
      ddr_ba_r                  <= {BANK_WIDTH-1{1'b0}};
    end else if (init_state_r == INIT_DUMMY_ACTIVE) begin
      // all calibration writing read takes place in row 0x0 only
      ddr_ba_r   <= {BANK_WIDTH{1'b0}};
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
    end else begin
      // otherwise, cry me a river
      ddr_ba_r   <= {BANK_WIDTH{1'bx}};
      ddr_addr_r <= {ROW_WIDTH{1'bx}};
    end
  end

  // Keep CKE asserted after initial power-on delay
  always @(posedge clkdiv0)
    ddr_cke_r <= {CKE_WIDTH{done_200us_r}};

  // register commands to memory. Two clock cycle delay from state -> output
  always @(posedge clk0) begin
    ddr_addr_r1   <= ddr_addr_r;
    ddr_ba_r1     <= ddr_ba_r;
    ddr_cas_n_r1  <= ddr_cas_n_r;
    ddr_ras_n_r1  <= ddr_ras_n_r;
    ddr_we_n_r1   <= ddr_we_n_r;
    ddr_cs_n_r1   <= ddr_cs_n_r;
  end // always @ (posedge clk0)

  always @(posedge clk0)
    init_state_r1_2t   <= init_state_r1;

  // logic to toggle chip select. The chip_select is
  // clocked of clkdiv0 and will be asserted for
  // two clock cycles.
   always @(posedge clk0) begin
      if(rst0)
        ddr_cs_disable_r <= {CS_NUM{1'b0}};
      else begin
         if(| ddr_cs_disable_r)
            ddr_cs_disable_r <= {CS_NUM{1'b0}};
         else begin
           if (TWO_T_TIME_EN) begin
             if (init_state_r1_2t == INIT_PRECHARGE && init_done_r)
               ddr_cs_disable_r <= 'd3;
             else
              ddr_cs_disable_r[chip_cnt_r] <= ~ddr_cs_n_r1[chip_cnt_r];
           end
           else begin
             if (init_state_r1 == INIT_PRECHARGE && init_done_r)
               ddr_cs_disable_r <= 'd3;
             else
              ddr_cs_disable_r[chip_cnt_r] <= ~ddr_cs_n_r[chip_cnt_r];
           end
         end
       end
   end


  assign phy_init_addr      = ddr_addr_r;
  assign phy_init_ba        = ddr_ba_r;
  assign phy_init_cas_n     = ddr_cas_n_r;
  assign phy_init_cke       = ddr_cke_r;
  assign phy_init_ras_n     = ddr_ras_n_r;
  assign phy_init_we_n      = ddr_we_n_r;
  assign phy_init_cs_n      = (TWO_T_TIME_EN) ?
                              ddr_cs_n_r1 | ddr_cs_disable_r
                              : ddr_cs_n_r| ddr_cs_disable_r;

endmodule
