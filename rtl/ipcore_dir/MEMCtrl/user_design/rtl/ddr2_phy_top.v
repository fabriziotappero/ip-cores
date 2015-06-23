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
//  /   /         Filename: ddr2_phy_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Top-level for memory physical layer (PHY) interface
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter CS_BITS added. PK. 10/8/08
//   Rev 1.4 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v3_61_ddr2_sdram_v5, Coregen 12.4" , CORE_GENERATION_INFO = "ddr2_sdram_v5,mig_v3_61,{component_name=ddr2_phy_top, BANK_WIDTH=2, CKE_WIDTH=1, CLK_WIDTH=2, COL_WIDTH=10, CS_NUM=1, CS_WIDTH=1, DM_WIDTH=8, DQ_WIDTH=64, DQ_PER_DQS=8, DQS_WIDTH=8, ODT_WIDTH=1, ROW_WIDTH=13, ADDITIVE_LAT=0, BURST_LEN=4, BURST_TYPE=0, CAS_LAT=3, ECC_ENABLE=0, MULTI_BANK_EN=1, TWO_T_TIME_EN=1, ODT_TYPE=1, REDUCE_DRV=0, REG_ENABLE=0, TREFI_NS=7800, TRAS=40000, TRCD=15000, TRFC=105000, TRP=15000, TRTP=7500, TWR=15000, TWTR=7500, CLK_PERIOD=8000, RST_ACT_LOW=1, INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=Verilog, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=1}" *)
module ddr2_phy_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH            = 2,
   parameter CLK_WIDTH             = 1,
   parameter CKE_WIDTH             = 1,
   parameter COL_WIDTH             = 10,
   parameter CS_BITS               = 0,
   parameter CS_NUM                = 1,
   parameter CS_WIDTH              = 1,
   parameter USE_DM_PORT           = 1,
   parameter DM_WIDTH              = 9,
   parameter DQ_WIDTH              = 72,
   parameter DQ_BITS               = 7,
   parameter DQ_PER_DQS            = 8,
   parameter DQS_WIDTH             = 9,
   parameter DQS_BITS              = 4,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG",
   parameter ODT_WIDTH             = 1,
   parameter ROW_WIDTH             = 14,
   parameter ADDITIVE_LAT          = 0,
   parameter TWO_T_TIME_EN         = 0,
   parameter BURST_LEN             = 4,
   parameter BURST_TYPE            = 0,
   parameter CAS_LAT               = 5,
   parameter TWR                   = 15000,
   parameter ECC_ENABLE            = 0,
   parameter ODT_TYPE              = 1,
   parameter DDR_TYPE              = 1,
   parameter REDUCE_DRV            = 0,
   parameter REG_ENABLE            = 1,
   parameter CLK_PERIOD            = 3000,
   parameter SIM_ONLY              = 0,
   parameter DEBUG_EN              = 0,
   parameter FPGA_SPEED_GRADE      = 2
   )
  (
   input                                  clk0,
   input                                  clk90,
   input                                  clkdiv0,
   input                                  rst0,
   input                                  rst90,
   input                                  rstdiv0,
   input                                  ctrl_wren,
   input [ROW_WIDTH-1:0]                  ctrl_addr,
   input [BANK_WIDTH-1:0]                 ctrl_ba,
   input                                  ctrl_ras_n,
   input                                  ctrl_cas_n,
   input                                  ctrl_we_n,
   input [CS_NUM-1:0]                     ctrl_cs_n,
   input                                  ctrl_rden,
   input                                  ctrl_ref_flag,
   input [(2*DQ_WIDTH)-1:0]               wdf_data,
   input [(2*DQ_WIDTH/8)-1:0]             wdf_mask_data,
   output                                 wdf_rden,
   output                                 phy_init_done,
   output [DQS_WIDTH-1:0]                 phy_calib_rden,
   output [DQS_WIDTH-1:0]                 phy_calib_rden_sel,
   output [DQ_WIDTH-1:0]                  rd_data_rise,
   output [DQ_WIDTH-1:0]                  rd_data_fall,
   output [CLK_WIDTH-1:0]                 ddr_ck,
   output [CLK_WIDTH-1:0]                 ddr_ck_n,
   output [ROW_WIDTH-1:0]                 ddr_addr,
   output [BANK_WIDTH-1:0]                ddr_ba,
   output                                 ddr_ras_n,
   output                                 ddr_cas_n,
   output                                 ddr_we_n,
   output [CS_WIDTH-1:0]                  ddr_cs_n,
   output [CKE_WIDTH-1:0]                 ddr_cke,
   output [ODT_WIDTH-1:0]                 ddr_odt,
   output [DM_WIDTH-1:0]                  ddr_dm,
   inout [DQS_WIDTH-1:0]                  ddr_dqs,
   inout [DQS_WIDTH-1:0]                  ddr_dqs_n,
   inout [DQ_WIDTH-1:0]                   ddr_dq,
   // Debug signals (optional use)
   input                                  dbg_idel_up_all,
   input                                  dbg_idel_down_all,
   input                                  dbg_idel_up_dq,
   input                                  dbg_idel_down_dq,
   input                                  dbg_idel_up_dqs,
   input                                  dbg_idel_down_dqs,
   input                                  dbg_idel_up_gate,
   input                                  dbg_idel_down_gate,
   input [DQ_BITS-1:0]                    dbg_sel_idel_dq,
   input                                  dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                     dbg_sel_idel_dqs,
   input                                  dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                     dbg_sel_idel_gate,
   input                                  dbg_sel_all_idel_gate,
   output [3:0]                           dbg_calib_done,
   output [3:0]                           dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]              dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]             dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]             dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                 dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]             dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]             dbg_calib_gate_dly
   );

  wire [3:0]               calib_done;
  wire                     calib_ref_done;
  wire                     calib_ref_req;
  wire [3:0]               calib_start;
  wire                     dm_ce;
  wire [1:0]               dq_oe_n;
  wire                     dqs_oe_n;
  wire                     dqs_rst_n;
  wire [(DQ_WIDTH/8)-1:0]  mask_data_fall;
  wire [(DQ_WIDTH/8)-1:0]  mask_data_rise;
  wire [CS_NUM-1:0]        odt;
  wire [ROW_WIDTH-1:0]     phy_init_addr;
  wire [BANK_WIDTH-1:0]    phy_init_ba;
  wire                     phy_init_cas_n;
  wire [CKE_WIDTH-1:0]     phy_init_cke;
  wire [CS_NUM-1:0]        phy_init_cs_n;
  wire                     phy_init_data_sel;
  wire                     phy_init_ras_n;
  wire                     phy_init_rden;
  wire                     phy_init_we_n;
  wire                     phy_init_wren;
  wire [DQ_WIDTH-1:0]      wr_data_fall;
  wire [DQ_WIDTH-1:0]      wr_data_rise;

  //***************************************************************************

  ddr2_phy_write #
    (
     .DQ_WIDTH     (DQ_WIDTH),
     .CS_NUM       (CS_NUM),
     .ADDITIVE_LAT (ADDITIVE_LAT),
     .CAS_LAT      (CAS_LAT),
     .ECC_ENABLE   (ECC_ENABLE),
     .ODT_TYPE     (ODT_TYPE),
     .REG_ENABLE   (REG_ENABLE),
     .DDR_TYPE     (DDR_TYPE)
     )
    u_phy_write
      (
       .clk0                    (clk0),
       .clk90                   (clk90),
       .rst90                   (rst90),
       .wdf_data                (wdf_data),
       .wdf_mask_data           (wdf_mask_data),
       .ctrl_wren               (ctrl_wren),
       .phy_init_wren           (phy_init_wren),
       .phy_init_data_sel       (phy_init_data_sel),
       .dm_ce                   (dm_ce),
       .dq_oe_n                 (dq_oe_n),
       .dqs_oe_n                (dqs_oe_n),
       .dqs_rst_n               (dqs_rst_n),
       .wdf_rden                (wdf_rden),
       .odt                     (odt),
       .wr_data_rise            (wr_data_rise),
       .wr_data_fall            (wr_data_fall),
       .mask_data_rise          (mask_data_rise),
       .mask_data_fall          (mask_data_fall)
       );

  ddr2_phy_io #
    (
     .CLK_WIDTH             (CLK_WIDTH),
     .USE_DM_PORT           (USE_DM_PORT),
     .DM_WIDTH              (DM_WIDTH),
     .DQ_WIDTH              (DQ_WIDTH),
     .DQ_BITS               (DQ_BITS),
     .DQ_PER_DQS            (DQ_PER_DQS),
     .DQS_BITS              (DQS_BITS),
     .DQS_WIDTH             (DQS_WIDTH),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IODELAY_GRP           (IODELAY_GRP),
     .ODT_WIDTH             (ODT_WIDTH),
     .ADDITIVE_LAT          (ADDITIVE_LAT),
     .CAS_LAT               (CAS_LAT),
     .REG_ENABLE            (REG_ENABLE),
     .CLK_PERIOD            (CLK_PERIOD),
     .DDR_TYPE              (DDR_TYPE),
     .SIM_ONLY              (SIM_ONLY),
     .DEBUG_EN              (DEBUG_EN),
     .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
     )
    u_phy_io
      (
       .clk0                   (clk0),
       .clk90                  (clk90),
       .clkdiv0                (clkdiv0),
       .rst0                   (rst0),
       .rst90                  (rst90),
       .rstdiv0                (rstdiv0),
       .dm_ce                  (dm_ce),
       .dq_oe_n                (dq_oe_n),
       .dqs_oe_n               (dqs_oe_n),
       .dqs_rst_n              (dqs_rst_n),
       .calib_start            (calib_start),
       .ctrl_rden              (ctrl_rden),
       .phy_init_rden          (phy_init_rden),
       .calib_ref_done         (calib_ref_done),
       .calib_done             (calib_done),
       .calib_ref_req          (calib_ref_req),
       .calib_rden             (phy_calib_rden),
       .calib_rden_sel         (phy_calib_rden_sel),
       .wr_data_rise           (wr_data_rise),
       .wr_data_fall           (wr_data_fall),
       .mask_data_rise         (mask_data_rise),
       .mask_data_fall         (mask_data_fall),
       .rd_data_rise           (rd_data_rise),
       .rd_data_fall           (rd_data_fall),
       .ddr_ck                 (ddr_ck),
       .ddr_ck_n               (ddr_ck_n),
       .ddr_dm                 (ddr_dm),
       .ddr_dqs                (ddr_dqs),
       .ddr_dqs_n              (ddr_dqs_n),
       .ddr_dq                 (ddr_dq),
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

  ddr2_phy_ctl_io #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .CKE_WIDTH     (CKE_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_NUM        (CS_NUM),
     .CS_WIDTH      (CS_WIDTH),
     .TWO_T_TIME_EN (TWO_T_TIME_EN),
     .ODT_WIDTH     (ODT_WIDTH),
     .ROW_WIDTH     (ROW_WIDTH),
     .DDR_TYPE      (DDR_TYPE)
     )
    u_phy_ctl_io
      (
       .clk0                    (clk0),
       .clk90                   (clk90),
       .rst0                    (rst0),
       .rst90                   (rst90),
       .ctrl_addr               (ctrl_addr),
       .ctrl_ba                 (ctrl_ba),
       .ctrl_ras_n              (ctrl_ras_n),
       .ctrl_cas_n              (ctrl_cas_n),
       .ctrl_we_n               (ctrl_we_n),
       .ctrl_cs_n               (ctrl_cs_n),
       .phy_init_addr           (phy_init_addr),
       .phy_init_ba             (phy_init_ba),
       .phy_init_ras_n          (phy_init_ras_n),
       .phy_init_cas_n          (phy_init_cas_n),
       .phy_init_we_n           (phy_init_we_n),
       .phy_init_cs_n           (phy_init_cs_n),
       .phy_init_cke            (phy_init_cke),
       .phy_init_data_sel       (phy_init_data_sel),
       .odt                     (odt),
       .ddr_addr                (ddr_addr),
       .ddr_ba                  (ddr_ba),
       .ddr_ras_n               (ddr_ras_n),
       .ddr_cas_n               (ddr_cas_n),
       .ddr_we_n                (ddr_we_n),
       .ddr_cke                 (ddr_cke),
       .ddr_cs_n                (ddr_cs_n),
       .ddr_odt                 (ddr_odt)
       );

  ddr2_phy_init #
    (
     .BANK_WIDTH   (BANK_WIDTH),
     .CKE_WIDTH    (CKE_WIDTH),
     .COL_WIDTH    (COL_WIDTH),
     .CS_BITS      (CS_BITS),
     .CS_NUM       (CS_NUM),
     .DQ_WIDTH     (DQ_WIDTH),
     .ODT_WIDTH    (ODT_WIDTH),
     .ROW_WIDTH    (ROW_WIDTH),
     .ADDITIVE_LAT (ADDITIVE_LAT),
     .BURST_LEN    (BURST_LEN),
     .BURST_TYPE   (BURST_TYPE),
     .TWO_T_TIME_EN(TWO_T_TIME_EN),
     .CAS_LAT      (CAS_LAT),
     .ODT_TYPE     (ODT_TYPE),
     .REDUCE_DRV   (REDUCE_DRV),
     .REG_ENABLE   (REG_ENABLE),
     .TWR          (TWR),
     .CLK_PERIOD   (CLK_PERIOD),
     .DDR_TYPE     (DDR_TYPE),
     .SIM_ONLY     (SIM_ONLY)
     )
    u_phy_init
      (
       .clk0                    (clk0),
       .clkdiv0                 (clkdiv0),
       .rst0                    (rst0),
       .rstdiv0                 (rstdiv0),
       .calib_done              (calib_done),
       .ctrl_ref_flag           (ctrl_ref_flag),
       .calib_ref_req           (calib_ref_req),
       .calib_start             (calib_start),
       .calib_ref_done          (calib_ref_done),
       .phy_init_wren           (phy_init_wren),
       .phy_init_rden           (phy_init_rden),
       .phy_init_addr           (phy_init_addr),
       .phy_init_ba             (phy_init_ba),
       .phy_init_ras_n          (phy_init_ras_n),
       .phy_init_cas_n          (phy_init_cas_n),
       .phy_init_we_n           (phy_init_we_n),
       .phy_init_cs_n           (phy_init_cs_n),
       .phy_init_cke            (phy_init_cke),
       .phy_init_done           (phy_init_done),
       .phy_init_data_sel       (phy_init_data_sel)
       );

endmodule
