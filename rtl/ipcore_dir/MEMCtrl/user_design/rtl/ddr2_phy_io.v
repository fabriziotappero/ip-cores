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
//  /   /         Filename: ddr2_phy_io.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module instantiates calibration logic, data, data strobe and the
//   data mask iobs.
//Reference:
//Revision History:
//   Rev 1.1 - DM_IOB instance made based on USE_DM_PORT value . PK. 25/6/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_io #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter CLK_WIDTH             = 1,
   parameter USE_DM_PORT           = 1,
   parameter DM_WIDTH              = 9,
   parameter DQ_WIDTH              = 72,
   parameter DQ_BITS               = 7,
   parameter DQ_PER_DQS            = 8,
   parameter DQS_BITS              = 4,
   parameter DQS_WIDTH             = 9,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG",
   parameter ODT_WIDTH             = 1,
   parameter ADDITIVE_LAT          = 0,
   parameter CAS_LAT               = 5,
   parameter REG_ENABLE            = 1,
   parameter CLK_PERIOD            = 3000,
   parameter DDR_TYPE              = 1,
   parameter SIM_ONLY              = 0,
   parameter DEBUG_EN              = 0,
   parameter FPGA_SPEED_GRADE      = 2
   )
  (
   input                                clk0,
   input                                clk90,
   input                                clkdiv0,
   input                                rst0,
   input                                rst90,
   input                                rstdiv0,
   input                                dm_ce,
   input [1:0]                          dq_oe_n,
   input                                dqs_oe_n,
   input                                dqs_rst_n,
   input [3:0]                          calib_start,
   input                                ctrl_rden,
   input                                phy_init_rden,
   input                                calib_ref_done,
   output [3:0]                         calib_done,
   output                               calib_ref_req,
   output [DQS_WIDTH-1:0]               calib_rden,
   output [DQS_WIDTH-1:0]               calib_rden_sel,
   input [DQ_WIDTH-1:0]                 wr_data_rise,
   input [DQ_WIDTH-1:0]                 wr_data_fall,
   input [(DQ_WIDTH/8)-1:0]             mask_data_rise,
   input [(DQ_WIDTH/8)-1:0]             mask_data_fall,
   output [(DQ_WIDTH)-1:0]              rd_data_rise,
   output [(DQ_WIDTH)-1:0]              rd_data_fall,
   output [CLK_WIDTH-1:0]               ddr_ck,
   output [CLK_WIDTH-1:0]               ddr_ck_n,
   output [DM_WIDTH-1:0]                ddr_dm,
   inout [DQS_WIDTH-1:0]                ddr_dqs,
   inout [DQS_WIDTH-1:0]                ddr_dqs_n,
   inout [DQ_WIDTH-1:0]                 ddr_dq,
   // Debug signals (optional use)
   input                                dbg_idel_up_all,
   input                                dbg_idel_down_all,
   input                                dbg_idel_up_dq,
   input                                dbg_idel_down_dq,
   input                                dbg_idel_up_dqs,
   input                                dbg_idel_down_dqs,
   input                                dbg_idel_up_gate,
   input                                dbg_idel_down_gate,
   input [DQ_BITS-1:0]                  dbg_sel_idel_dq,
   input                                dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                   dbg_sel_idel_dqs,
   input                                dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                   dbg_sel_idel_gate,
   input                                dbg_sel_all_idel_gate,
   output [3:0]                         dbg_calib_done,
   output [3:0]                         dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]            dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]           dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]           dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]               dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]           dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]           dbg_calib_gate_dly
   );

  // ratio of # of physical DM outputs to bytes in data bus
  // may be different - e.g. if using x4 components
  localparam DM_TO_BYTE_RATIO = DM_WIDTH / (DQ_WIDTH/8);

  wire [CLK_WIDTH-1:0]                     ddr_ck_q;
  wire [DQS_WIDTH-1:0]                     delayed_dqs;
  wire [DQ_WIDTH-1:0]                      dlyce_dq;
  wire [DQS_WIDTH-1:0]                     dlyce_dqs;
  wire [DQS_WIDTH-1:0]                     dlyce_gate;
  wire [DQ_WIDTH-1:0]                      dlyinc_dq;
  wire [DQS_WIDTH-1:0]                     dlyinc_dqs;
  wire [DQS_WIDTH-1:0]                     dlyinc_gate;
  wire                                     dlyrst_dq;
  wire                                     dlyrst_dqs;
  wire [DQS_WIDTH-1:0]                     dlyrst_gate;
  wire [DQS_WIDTH-1:0]                     dq_ce;
  (* KEEP = "TRUE" *) wire [DQS_WIDTH-1:0] en_dqs /* synthesis syn_keep = 1 */;
  wire [DQS_WIDTH-1:0]                     rd_data_sel;

  //***************************************************************************

  ddr2_phy_calib #
    (
     .DQ_WIDTH      (DQ_WIDTH),
     .DQ_BITS       (DQ_BITS),
     .DQ_PER_DQS    (DQ_PER_DQS),
     .DQS_BITS      (DQS_BITS),
     .DQS_WIDTH     (DQS_WIDTH),
     .ADDITIVE_LAT  (ADDITIVE_LAT),
     .CAS_LAT       (CAS_LAT),
     .REG_ENABLE    (REG_ENABLE),
     .CLK_PERIOD    (CLK_PERIOD),
     .SIM_ONLY      (SIM_ONLY),
     .DEBUG_EN      (DEBUG_EN)
     )
    u_phy_calib
      (
       .clk                    (clk0),
       .clkdiv                 (clkdiv0),
       .rstdiv                 (rstdiv0),
       .calib_start            (calib_start),
       .ctrl_rden              (ctrl_rden),
       .phy_init_rden          (phy_init_rden),
       .rd_data_rise           (rd_data_rise),
       .rd_data_fall           (rd_data_fall),
       .calib_ref_done         (calib_ref_done),
       .calib_done             (calib_done),
       .calib_ref_req          (calib_ref_req),
       .calib_rden             (calib_rden),
       .calib_rden_sel         (calib_rden_sel),
       .dlyrst_dq              (dlyrst_dq),
       .dlyce_dq               (dlyce_dq),
       .dlyinc_dq              (dlyinc_dq),
       .dlyrst_dqs             (dlyrst_dqs),
       .dlyce_dqs              (dlyce_dqs),
       .dlyinc_dqs             (dlyinc_dqs),
       .dlyrst_gate            (dlyrst_gate),
       .dlyce_gate             (dlyce_gate),
       .dlyinc_gate            (dlyinc_gate),
       .en_dqs                 (en_dqs),
       .rd_data_sel            (rd_data_sel),
       .dbg_idel_up_all        (dbg_idel_up_all),
       .dbg_idel_down_all      (dbg_idel_down_all),
       .dbg_idel_up_dq         (dbg_idel_up_dq),
       .dbg_idel_down_dq       (dbg_idel_down_dq),
       .dbg_idel_up_dqs        (dbg_idel_up_dqs),
       .dbg_idel_down_dqs      (dbg_idel_down_dqs),
       .dbg_idel_up_gate       (dbg_idel_up_gate),
       .dbg_idel_down_gate     (dbg_idel_down_gate),
       .dbg_sel_idel_dq        (dbg_sel_idel_dq),
       .dbg_sel_all_idel_dq    (dbg_sel_all_idel_dq),
       .dbg_sel_idel_dqs       (dbg_sel_idel_dqs),
       .dbg_sel_all_idel_dqs   (dbg_sel_all_idel_dqs),
       .dbg_sel_idel_gate      (dbg_sel_idel_gate),
       .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate),
       .dbg_calib_done         (dbg_calib_done),
       .dbg_calib_err          (dbg_calib_err),
       .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
       .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
       .dbg_calib_gate_tap_cnt (dbg_calib_gate_tap_cnt),
       .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
       .dbg_calib_rden_dly     (dbg_calib_rden_dly),
       .dbg_calib_gate_dly     (dbg_calib_gate_dly)
       );

  //***************************************************************************
  // Memory clock generation
  //***************************************************************************

  genvar ck_i;
  generate
    for(ck_i = 0; ck_i < CLK_WIDTH; ck_i = ck_i+1) begin: gen_ck
      ODDR #
        (
         .SRTYPE       ("SYNC"),
         .DDR_CLK_EDGE ("OPPOSITE_EDGE")
         )
        u_oddr_ck_i
          (
           .Q   (ddr_ck_q[ck_i]),
           .C   (clk0),
           .CE  (1'b1),
           .D1  (1'b0),
           .D2  (1'b1),
           .R   (1'b0),
           .S   (1'b0)
           );
      // Can insert ODELAY here if required
      OBUFDS u_obuf_ck_i
        (
         .I   (ddr_ck_q[ck_i]),
         .O   (ddr_ck[ck_i]),
         .OB  (ddr_ck_n[ck_i])
         );
    end
  endgenerate

  //***************************************************************************
  // DQS instances
  //***************************************************************************

  genvar dqs_i;
  generate
    for(dqs_i = 0; dqs_i < DQS_WIDTH; dqs_i = dqs_i+1) begin: gen_dqs
      ddr2_phy_dqs_iob #
        (
         .DDR_TYPE              (DDR_TYPE),
         .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
         .IODELAY_GRP           (IODELAY_GRP)
         )
        u_iob_dqs
          (
           .clk0           (clk0),
           .clkdiv0        (clkdiv0),
           .rst0           (rst0),
           .dlyinc_dqs     (dlyinc_dqs[dqs_i]),
           .dlyce_dqs      (dlyce_dqs[dqs_i]),
           .dlyrst_dqs     (dlyrst_dqs),
           .dlyinc_gate    (dlyinc_gate[dqs_i]),
           .dlyce_gate     (dlyce_gate[dqs_i]),
           .dlyrst_gate    (dlyrst_gate[dqs_i]),
           .dqs_oe_n       (dqs_oe_n),
           .dqs_rst_n      (dqs_rst_n),
           .en_dqs         (en_dqs[dqs_i]),
           .ddr_dqs        (ddr_dqs[dqs_i]),
           .ddr_dqs_n      (ddr_dqs_n[dqs_i]),
           .dq_ce          (dq_ce[dqs_i]),
           .delayed_dqs    (delayed_dqs[dqs_i])
           );
    end
  endgenerate

  //***************************************************************************
  // DM instances
  //***************************************************************************

  genvar dm_i;
  generate
    if (USE_DM_PORT) begin: gen_dm_inst
      for(dm_i = 0; dm_i < DM_WIDTH; dm_i = dm_i+1) begin: gen_dm
        ddr2_phy_dm_iob u_iob_dm
          (
           .clk90           (clk90),
           .dm_ce           (dm_ce),
           .mask_data_rise  (mask_data_rise[dm_i/DM_TO_BYTE_RATIO]),
           .mask_data_fall  (mask_data_fall[dm_i/DM_TO_BYTE_RATIO]),
           .ddr_dm          (ddr_dm[dm_i])
           );
      end
    end
  endgenerate

  //***************************************************************************
  // DQ IOB instances
  //***************************************************************************

  genvar dq_i;
  generate
    for(dq_i = 0; dq_i < DQ_WIDTH; dq_i = dq_i+1) begin: gen_dq
      ddr2_phy_dq_iob #
        (
         .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
         .IODELAY_GRP           (IODELAY_GRP),
         .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
         )
        u_iob_dq
        (
         .clk0         (clk0),
         .clk90        (clk90),
         .clkdiv0      (clkdiv0),
         .rst90        (rst90),
         .dlyinc       (dlyinc_dq[dq_i]),
         .dlyce        (dlyce_dq[dq_i]),
         .dlyrst       (dlyrst_dq),
         .dq_oe_n      (dq_oe_n),
         .dqs          (delayed_dqs[dq_i/DQ_PER_DQS]),
         .ce           (dq_ce[dq_i/DQ_PER_DQS]),
         .rd_data_sel  (rd_data_sel[dq_i/DQ_PER_DQS]),
         .wr_data_rise (wr_data_rise[dq_i]),
         .wr_data_fall (wr_data_fall[dq_i]),
         .rd_data_rise (rd_data_rise[dq_i]),
         .rd_data_fall (rd_data_fall[dq_i]),
         .ddr_dq       (ddr_dq[dq_i])
         );
    end
  endgenerate

endmodule
