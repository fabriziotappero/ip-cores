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
//  /   /         Filename: ddr2_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   System level module. This level contains just the memory controller.
//   This level will be intiantated when the user wants to remove the
//   synthesizable test bench, IDELAY control block and the clock
//   generation modules.
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH            = 2,      // # of memory bank addr bits
   parameter CKE_WIDTH             = 1,      // # of memory clock enable outputs
   parameter CLK_WIDTH             = 1,      // # of clock outputs
   parameter COL_WIDTH             = 10,     // # of memory column bits
   parameter CS_NUM                = 1,      // # of separate memory chip selects
   parameter CS_BITS               = 0,      // set to log2(CS_NUM) (rounded up)
   parameter CS_WIDTH              = 1,      // # of total memory chip selects
   parameter USE_DM_PORT           = 1,      // enable Data Mask (=1 enable)
   parameter DM_WIDTH              = 9,      // # of data mask bits
   parameter DQ_WIDTH              = 72,     // # of data width
   parameter DQ_BITS               = 7,      // set to log2(DQS_WIDTH*DQ_PER_DQS)
   parameter DQ_PER_DQS            = 8,      // # of DQ data bits per strobe
   parameter DQS_WIDTH             = 9,      // # of DQS strobes
   parameter DQS_BITS              = 4,      // set to log2(DQS_WIDTH)
   parameter HIGH_PERFORMANCE_MODE = "TRUE", // IODELAY Performance Mode
   parameter IODELAY_GRP           = "IODELAY_MIG", // IODELAY Group Name
   parameter ODT_WIDTH             = 1,      // # of memory on-die term enables
   parameter ROW_WIDTH             = 14,     // # of memory row & # of addr bits
   parameter APPDATA_WIDTH         = 144,    // # of usr read/write data bus bits
   parameter ADDITIVE_LAT          = 0,      // additive write latency
   parameter BURST_LEN             = 4,      // burst length (in double words)
   parameter BURST_TYPE            = 0,      // burst type (=0 seq; =1 interlved)
   parameter CAS_LAT               = 5,      // CAS latency
   parameter ECC_ENABLE            = 0,      // enable ECC (=1 enable)
   parameter ODT_TYPE              = 1,      // ODT (=0(none),=1(75),=2(150),=3(50))
   parameter MULTI_BANK_EN         = 1,      // enable bank management
   parameter TWO_T_TIME_EN         = 0,      // 2t timing for unbuffered dimms
   parameter REDUCE_DRV            = 0,      // reduced strength mem I/O (=1 yes)
   parameter REG_ENABLE            = 1,      // registered addr/ctrl (=1 yes)
   parameter TREFI_NS              = 7800,   // auto refresh interval (ns)
   parameter TRAS                  = 40000,  // active->precharge delay
   parameter TRCD                  = 15000,  // active->read/write delay
   parameter TRFC                  = 105000, // ref->ref, ref->active delay
   parameter TRP                   = 15000,  // precharge->command delay
   parameter TRTP                  = 7500,   // read->precharge delay
   parameter TWR                   = 15000,  // used to determine wr->prech
   parameter TWTR                  = 10000,  // write->read delay
   parameter CLK_PERIOD            = 3000,   // Core/Mem clk period (in ps)
   parameter SIM_ONLY              = 0,      // = 1 to skip power up delay
   parameter DEBUG_EN              = 0,      // Enable debug signals/controls
   parameter FPGA_SPEED_GRADE      = 2       // FPGA Speed Grade
   )
  (
   input                                    clk0,
   input                                    clk90,
   input                                    clkdiv0,
   input                                    rst0,
   input                                    rst90,
   input                                    rstdiv0,
   input [2:0]                              app_af_cmd,
   input [30:0]                             app_af_addr,
   input                                    app_af_wren,
   input                                    app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]            app_wdf_mask_data,
   output                                   app_af_afull,
   output                                   app_wdf_afull,
   output                                   rd_data_valid,
   output [APPDATA_WIDTH-1:0]               rd_data_fifo_out,
   output [1:0]                             rd_ecc_error,
   output                                   phy_init_done,
   output [CLK_WIDTH-1:0]                   ddr2_ck,
   output [CLK_WIDTH-1:0]                   ddr2_ck_n,
   output [ROW_WIDTH-1:0]                   ddr2_a,
   output [BANK_WIDTH-1:0]                  ddr2_ba,
   output                                   ddr2_ras_n,
   output                                   ddr2_cas_n,
   output                                   ddr2_we_n,
   output [CS_WIDTH-1:0]                    ddr2_cs_n,
   output [CKE_WIDTH-1:0]                   ddr2_cke,
   output [ODT_WIDTH-1:0]                   ddr2_odt,
   output [DM_WIDTH-1:0]                    ddr2_dm,
   inout [DQS_WIDTH-1:0]                    ddr2_dqs,
   inout [DQS_WIDTH-1:0]                    ddr2_dqs_n,
   inout [DQ_WIDTH-1:0]                     ddr2_dq,
   // Debug signals (optional use)
   input                                    dbg_idel_up_all,
   input                                    dbg_idel_down_all,
   input                                    dbg_idel_up_dq,
   input                                    dbg_idel_down_dq,
   input                                    dbg_idel_up_dqs,
   input                                    dbg_idel_down_dqs,
   input                                    dbg_idel_up_gate,
   input                                    dbg_idel_down_gate,
   input [DQ_BITS-1:0]                      dbg_sel_idel_dq,
   input                                    dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                       dbg_sel_idel_dqs,
   input                                    dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                       dbg_sel_idel_gate,
   input                                    dbg_sel_all_idel_gate,
   output [3:0]                             dbg_calib_done,
   output [3:0]                             dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]                dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                   dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_gate_dly
   );

  // memory initialization/control logic
  ddr2_mem_if_top #
    (
     .BANK_WIDTH            (BANK_WIDTH),
     .CKE_WIDTH             (CKE_WIDTH),
     .CLK_WIDTH             (CLK_WIDTH),
     .COL_WIDTH             (COL_WIDTH),
     .CS_BITS               (CS_BITS),
     .CS_NUM                (CS_NUM),
     .CS_WIDTH              (CS_WIDTH),
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
     .ROW_WIDTH             (ROW_WIDTH),
     .APPDATA_WIDTH         (APPDATA_WIDTH),
     .ADDITIVE_LAT          (ADDITIVE_LAT),
     .BURST_LEN             (BURST_LEN),
     .BURST_TYPE            (BURST_TYPE),
     .CAS_LAT               (CAS_LAT),
     .ECC_ENABLE            (ECC_ENABLE),
     .MULTI_BANK_EN         (MULTI_BANK_EN),
     .TWO_T_TIME_EN         (TWO_T_TIME_EN),
     .ODT_TYPE              (ODT_TYPE),
     .DDR_TYPE              (1),
     .REDUCE_DRV            (REDUCE_DRV),
     .REG_ENABLE            (REG_ENABLE),
     .TREFI_NS              (TREFI_NS),
     .TRAS                  (TRAS),
     .TRCD                  (TRCD),
     .TRFC                  (TRFC),
     .TRP                   (TRP),
     .TRTP                  (TRTP),
     .TWR                   (TWR),
     .TWTR                  (TWTR),
     .CLK_PERIOD            (CLK_PERIOD),
     .SIM_ONLY              (SIM_ONLY),
     .DEBUG_EN              (DEBUG_EN),
     .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
     )
    u_mem_if_top
      (
       .clk0                   (clk0),
       .clk90                  (clk90),
       .clkdiv0                (clkdiv0),
       .rst0                   (rst0),
       .rst90                  (rst90),
       .rstdiv0                (rstdiv0),
       .app_af_cmd             (app_af_cmd),
       .app_af_addr            (app_af_addr),
       .app_af_wren            (app_af_wren),
       .app_wdf_wren           (app_wdf_wren),
       .app_wdf_data           (app_wdf_data),
       .app_wdf_mask_data      (app_wdf_mask_data),
       .app_af_afull           (app_af_afull),
       .app_wdf_afull          (app_wdf_afull),
       .rd_data_valid          (rd_data_valid),
       .rd_data_fifo_out       (rd_data_fifo_out),
       .rd_ecc_error           (rd_ecc_error),
       .phy_init_done          (phy_init_done),
       .ddr_ck                 (ddr2_ck),
       .ddr_ck_n               (ddr2_ck_n),
       .ddr_addr               (ddr2_a),
       .ddr_ba                 (ddr2_ba),
       .ddr_ras_n              (ddr2_ras_n),
       .ddr_cas_n              (ddr2_cas_n),
       .ddr_we_n               (ddr2_we_n),
       .ddr_cs_n               (ddr2_cs_n),
       .ddr_cke                (ddr2_cke),
       .ddr_odt                (ddr2_odt),
       .ddr_dm                 (ddr2_dm),
       .ddr_dqs                (ddr2_dqs),
       .ddr_dqs_n              (ddr2_dqs_n),
       .ddr_dq                 (ddr2_dq),
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

endmodule
