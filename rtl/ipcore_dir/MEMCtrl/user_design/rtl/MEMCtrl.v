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
//  /   /         Filename: MEMCtrl.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Top-level  module. Simple model for what the user might use
//   Typically, the user will only instantiate MEM_INTERFACE_TOP in their
//   code, and generate all backend logic (test bench) and all the other infrastructure logic
//    separately.
//   In addition to the memory controller, the module instantiates:
//     1. Reset logic based on user clocks
//     2. IDELAY control block
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v3_61_ddr2_v5, Coregen 12.4" , CORE_GENERATION_INFO = "ddr2_v5,mig_v3_61,{component_name=MEMCtrl, BANK_WIDTH=2, CKE_WIDTH=1, CLK_WIDTH=2, COL_WIDTH=10, CS_NUM=1, CS_WIDTH=1, DM_WIDTH=8, DQ_WIDTH=64, DQ_PER_DQS=8, DQS_WIDTH=8, ODT_WIDTH=1, ROW_WIDTH=13, ADDITIVE_LAT=0, BURST_LEN=4, BURST_TYPE=0, CAS_LAT=3, ECC_ENABLE=0, MULTI_BANK_EN=1, TWO_T_TIME_EN=1, ODT_TYPE=1, REDUCE_DRV=0, REG_ENABLE=0, TREFI_NS=7800, TRAS=40000, TRCD=15000, TRFC=105000, TRP=15000, TRTP=7500, TWR=15000, TWTR=7500, CLK_PERIOD=8000, RST_ACT_LOW=1, INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=Verilog, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=1}" *)
module MEMCtrl #
  (
   parameter BANK_WIDTH              = 2,       
                                       // # of memory bank addr bits.
   parameter CKE_WIDTH               = 1,       
                                       // # of memory clock enable outputs.
   parameter CLK_WIDTH               = 2,       
                                       // # of clock outputs.
   parameter COL_WIDTH               = 10,       
                                       // # of memory column bits.
   parameter CS_NUM                  = 1,       
                                       // # of separate memory chip selects.
   parameter CS_WIDTH                = 1,       
                                       // # of total memory chip selects.
   parameter CS_BITS                 = 0,       
                                       // set to log2(CS_NUM) (rounded up).
   parameter DM_WIDTH                = 8,       
                                       // # of data mask bits.
   parameter DQ_WIDTH                = 64,       
                                       // # of data width.
   parameter DQ_PER_DQS              = 8,       
                                       // # of DQ data bits per strobe.
   parameter DQS_WIDTH               = 8,       
                                       // # of DQS strobes.
   parameter DQ_BITS                 = 6,       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   parameter DQS_BITS                = 3,       
                                       // set to log2(DQS_WIDTH).
   parameter ODT_WIDTH               = 1,       
                                       // # of memory on-die term enables.
   parameter ROW_WIDTH               = 13,       
                                       // # of memory row and # of addr bits.
   parameter ADDITIVE_LAT            = 0,       
                                       // additive write latency.
   parameter BURST_LEN               = 4,       
                                       // burst length (in double words).
   parameter BURST_TYPE              = 0,       
                                       // burst type (=0 seq; =1 interleaved).
   parameter CAS_LAT                 = 3,       
                                       // CAS latency.
   parameter ECC_ENABLE              = 0,       
                                       // enable ECC (=1 enable).
   parameter APPDATA_WIDTH           = 128,       
                                       // # of usr read/write data bus bits.
   parameter MULTI_BANK_EN           = 1,       
                                       // Keeps multiple banks open. (= 1 enable).
   parameter TWO_T_TIME_EN           = 1,       
                                       // 2t timing for unbuffered dimms.
   parameter ODT_TYPE                = 1,       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   parameter REDUCE_DRV              = 0,       
                                       // reduced strength mem I/O (=1 yes).
   parameter REG_ENABLE              = 0,       
                                       // registered addr/ctrl (=1 yes).
   parameter TREFI_NS                = 7800,       
                                       // auto refresh interval (ns).
   parameter TRAS                    = 40000,       
                                       // active->precharge delay.
   parameter TRCD                    = 15000,       
                                       // active->read/write delay.
   parameter TRFC                    = 105000,       
                                       // refresh->refresh, refresh->active delay.
   parameter TRP                     = 15000,       
                                       // precharge->command delay.
   parameter TRTP                    = 7500,       
                                       // read->precharge delay.
   parameter TWR                     = 15000,       
                                       // used to determine write->precharge.
   parameter TWTR                    = 7500,       
                                       // write->read delay.
   parameter HIGH_PERFORMANCE_MODE   = "TRUE",       
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
   parameter SIM_ONLY                = 0,       
                                       // = 1 to skip SDRAM power up delay.
   parameter DEBUG_EN                = 0,       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   parameter CLK_PERIOD              = 8000,       
                                       // Core/Memory clock period (in ps).
   parameter RST_ACT_LOW             = 1        
                                       // =1 for active low reset, =0 for active high.
   )
  (
   inout  [DQ_WIDTH-1:0]              ddr2_dq,
   output [ROW_WIDTH-1:0]             ddr2_a,
   output [BANK_WIDTH-1:0]            ddr2_ba,
   output                             ddr2_ras_n,
   output                             ddr2_cas_n,
   output                             ddr2_we_n,
   output [CS_WIDTH-1:0]              ddr2_cs_n,
   output [ODT_WIDTH-1:0]             ddr2_odt,
   output [CKE_WIDTH-1:0]             ddr2_cke,
   output [DM_WIDTH-1:0]              ddr2_dm,
   input                              sys_rst_n,
   output                             phy_init_done,
   input                              locked,
   output                             rst0_tb,
   input                              clk0,
   output                             clk0_tb,
   input                              clk90,
   input                              clkdiv0,
   input                              clk200,
   output                             app_wdf_afull,
   output                             app_af_afull,
   output                             rd_data_valid,
   input                              app_wdf_wren,
   input                              app_af_wren,
   input  [30:0]                      app_af_addr,
   input  [2:0]                       app_af_cmd,
   output [(APPDATA_WIDTH)-1:0]                rd_data_fifo_out,
   input  [(APPDATA_WIDTH)-1:0]                app_wdf_data,
   input  [(APPDATA_WIDTH/8)-1:0]              app_wdf_mask_data,
   inout  [DQS_WIDTH-1:0]             ddr2_dqs,
   inout  [DQS_WIDTH-1:0]             ddr2_dqs_n,
   output [CLK_WIDTH-1:0]             ddr2_ck,
   output [CLK_WIDTH-1:0]             ddr2_ck_n//,
	//ADAUGAT PT LEDURI
	//output error_o, error_cmp_o
   );

  //***************************************************************************
  // IODELAY Group Name: Replication and placement of IDELAYCTRLs will be
  // handled automatically by software tools if IDELAYCTRLs have same refclk,
  // reset and rdy nets. Designs with a unique RESET will commonly create a
  // unique RDY. Constraint IODELAY_GROUP is associated to a set of IODELAYs
  // with an IDELAYCTRL. The parameter IODELAY_GRP value can be any string.
  //***************************************************************************

  localparam IODELAY_GRP = "IODELAY_MIG";





  wire                              rst0;
  wire                              rst90;
  wire                              rstdiv0;
  wire                              rst200;
  wire                              idelay_ctrl_rdy;

  wire error;
  wire error_cmp;
  wire [35:0] control;
  wire [71:0] data;
  wire [7:0] trig0;

  //Debug signals


  wire [3:0]                        dbg_calib_done;
  wire [3:0]                        dbg_calib_err;
  wire [(6*DQ_WIDTH)-1:0]           dbg_calib_dq_tap_cnt;
  wire [(6*DQS_WIDTH)-1:0]          dbg_calib_dqs_tap_cnt;
  wire [(6*DQS_WIDTH)-1:0]          dbg_calib_gate_tap_cnt;
  wire [DQS_WIDTH-1:0]              dbg_calib_rd_data_sel;
  wire [(5*DQS_WIDTH)-1:0]          dbg_calib_rden_dly;
  wire [(5*DQS_WIDTH)-1:0]          dbg_calib_gate_dly;
  wire                              dbg_idel_up_all;
  wire                              dbg_idel_down_all;
  wire                              dbg_idel_up_dq;
  wire                              dbg_idel_down_dq;
  wire                              dbg_idel_up_dqs;
  wire                              dbg_idel_down_dqs;
  wire                              dbg_idel_up_gate;
  wire                              dbg_idel_down_gate;
  wire [DQ_BITS-1:0]                dbg_sel_idel_dq;
  wire                              dbg_sel_all_idel_dq;
  wire [DQS_BITS:0]                 dbg_sel_idel_dqs;
  wire                              dbg_sel_all_idel_dqs;
  wire [DQS_BITS:0]                 dbg_sel_idel_gate;
  wire                              dbg_sel_all_idel_gate;


    // Debug signals (optional use)

  //***********************************
  // PHY Debug Port demo
  //***********************************
  wire [35:0]                        cs_control0;
  wire [35:0]                        cs_control1;
  wire [35:0]                        cs_control2;
  wire [35:0]                        cs_control3;
  wire [191:0]                       vio0_in;
  wire [95:0]                        vio1_in;
  wire [99:0]                        vio2_in;
  wire [31:0]                        vio3_out;




  //***************************************************************************

  assign  rst0_tb = rst0;
  assign  clk0_tb = clk0;


ddr2_idelay_ctrl #
   (
    .IODELAY_GRP         (IODELAY_GRP)
   )
   u_ddr2_idelay_ctrl
   (
   .rst200                 (rst200),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_infrastructure #
 (
   .RST_ACT_LOW            (RST_ACT_LOW)
   )
u_ddr2_infrastructure
 (
   .sys_rst_n              (sys_rst_n),
   .locked                 (locked),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .rst200                 (rst200),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_top #
 (
   .BANK_WIDTH             (BANK_WIDTH),
   .CKE_WIDTH              (CKE_WIDTH),
   .CLK_WIDTH              (CLK_WIDTH),
   .COL_WIDTH              (COL_WIDTH),
   .CS_NUM                 (CS_NUM),
   .CS_WIDTH               (CS_WIDTH),
   .CS_BITS                (CS_BITS),
   .DM_WIDTH               (DM_WIDTH),
   .DQ_WIDTH               (DQ_WIDTH),
   .DQ_PER_DQS             (DQ_PER_DQS),
   .DQS_WIDTH              (DQS_WIDTH),
   .DQ_BITS                (DQ_BITS),
   .DQS_BITS               (DQS_BITS),
   .ODT_WIDTH              (ODT_WIDTH),
   .ROW_WIDTH              (ROW_WIDTH),
   .ADDITIVE_LAT           (ADDITIVE_LAT),
   .BURST_LEN              (BURST_LEN),
   .BURST_TYPE             (BURST_TYPE),
   .CAS_LAT                (CAS_LAT),
   .ECC_ENABLE             (ECC_ENABLE),
   .APPDATA_WIDTH          (APPDATA_WIDTH),
   .MULTI_BANK_EN          (MULTI_BANK_EN),
   .TWO_T_TIME_EN          (TWO_T_TIME_EN),
   .ODT_TYPE               (ODT_TYPE),
   .REDUCE_DRV             (REDUCE_DRV),
   .REG_ENABLE             (REG_ENABLE),
   .TREFI_NS               (TREFI_NS),
   .TRAS                   (TRAS),
   .TRCD                   (TRCD),
   .TRFC                   (TRFC),
   .TRP                    (TRP),
   .TRTP                   (TRTP),
   .TWR                    (TWR),
   .TWTR                   (TWTR),
   .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
   .IODELAY_GRP            (IODELAY_GRP),
   .SIM_ONLY               (SIM_ONLY),
   .DEBUG_EN               (DEBUG_EN),
   .FPGA_SPEED_GRADE       (3),
   .USE_DM_PORT            (1),
   .CLK_PERIOD             (CLK_PERIOD)
   )
u_ddr2_top_0
(
   .ddr2_dq                (ddr2_dq),
   .ddr2_a                 (ddr2_a),
   .ddr2_ba                (ddr2_ba),
   .ddr2_ras_n             (ddr2_ras_n),
   .ddr2_cas_n             (ddr2_cas_n),
   .ddr2_we_n              (ddr2_we_n),
   .ddr2_cs_n              (ddr2_cs_n),
   .ddr2_odt               (ddr2_odt),
   .ddr2_cke               (ddr2_cke),
   .ddr2_dm                (ddr2_dm),
   .phy_init_done          (phy_init_done),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .app_wdf_afull          (app_wdf_afull),
   .app_af_afull           (app_af_afull),
   .rd_data_valid          (rd_data_valid),
   .app_wdf_wren           (app_wdf_wren),
   .app_af_wren            (app_af_wren),
   .app_af_addr            (app_af_addr),
   .app_af_cmd             (app_af_cmd),
   .rd_data_fifo_out       (rd_data_fifo_out),
   .app_wdf_data           (app_wdf_data),
   .app_wdf_mask_data      (app_wdf_mask_data),
   .ddr2_dqs               (ddr2_dqs),
   .ddr2_dqs_n             (ddr2_dqs_n),
   .ddr2_ck                (ddr2_ck),
   .rd_ecc_error           (),
   .ddr2_ck_n              (ddr2_ck_n),

   .dbg_calib_done         (dbg_calib_done),
   .dbg_calib_err          (dbg_calib_err),
   .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
   .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
   .dbg_calib_gate_tap_cnt  (dbg_calib_gate_tap_cnt),
   .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
   .dbg_calib_rden_dly     (dbg_calib_rden_dly),
   .dbg_calib_gate_dly     (dbg_calib_gate_dly),
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
   .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate)
   );

 
   //*****************************************************************
  // Hooks to prevent sim/syn compilation errors (mainly for VHDL - but
  // keep it also in Verilog version of code) w/ floating inputs if
  // DEBUG_EN = 0.
  //*****************************************************************

  generate
    if (DEBUG_EN == 0) begin: gen_dbg_tie_off
      assign dbg_idel_up_all       = 'b0;
      assign dbg_idel_down_all     = 'b0;
      assign dbg_idel_up_dq        = 'b0;
      assign dbg_idel_down_dq      = 'b0;
      assign dbg_idel_up_dqs       = 'b0;
      assign dbg_idel_down_dqs     = 'b0;
      assign dbg_idel_up_gate      = 'b0;
      assign dbg_idel_down_gate    = 'b0;
      assign dbg_sel_idel_dq       = 'b0;
      assign dbg_sel_all_idel_dq   = 'b0;
      assign dbg_sel_idel_dqs      = 'b0;
      assign dbg_sel_all_idel_dqs  = 'b0;
      assign dbg_sel_idel_gate     = 'b0;
      assign dbg_sel_all_idel_gate = 'b0;
    end else begin: gen_dbg_enable
      
      //*****************************************************************
      // PHY Debug Port example - see MIG User's Guide, XAPP858 or 
      // Answer Record 29443
      // This logic supports up to 32 DQ and 8 DQS I/O
      // NOTES:
      //   1. PHY Debug Port demo connects to 4 VIO modules:
      //     - 3 VIO modules with only asynchronous inputs
      //      * Monitor IDELAY taps for DQ, DQS, DQS Gate
      //      * Calibration status
      //     - 1 VIO module with synchronous outputs
      //      * Allow dynamic adjustment o f IDELAY taps
      //   2. User may need to modify this code to incorporate other
      //      chipscope-related modules in their larger design (e.g.
      //      if they have other ILA/VIO modules, they will need to
      //      for example instantiate a larger ICON module). In addition
      //      user may want to instantiate more VIO modules to control
      //      IDELAY for more DQ, DQS than is shown here
      //*****************************************************************

      icon4 u_icon
        (
         .control0 (cs_control0),
         .control1 (cs_control1),
         .control2 (cs_control2),
         .control3 (cs_control3)
         );

      //*****************************************************************
      // VIO ASYNC input: Display current IDELAY setting for up to 32
      // DQ taps (32x6) = 192
      //*****************************************************************

      vio_async_in192 u_vio0
        (
         .control  (cs_control0),
         .async_in (vio0_in)
         );

      //*****************************************************************
      // VIO ASYNC input: Display current IDELAY setting for up to 8 DQS
      // and DQS Gate taps (8x6x2) = 96
      //*****************************************************************

      vio_async_in96 u_vio1
        (
         .control  (cs_control1),
         .async_in (vio1_in)
         );

      //*****************************************************************
      // VIO ASYNC input: Display other calibration results
      //*****************************************************************

      vio_async_in100 u_vio2
        (
         .control  (cs_control2),
         .async_in (vio2_in)
         );
      
      //*****************************************************************
      // VIO SYNC output: Dynamically change IDELAY taps
      //*****************************************************************
      
      vio_sync_out32 u_vio3
        (
         .control  (cs_control3),
         .clk      (clkdiv0),
         .sync_out (vio3_out)
         );

      //*****************************************************************
      // Bit assignments:
      // NOTE: Not all VIO, ILA inputs/outputs may be used - these will
      //       be dependent on the user's particular bit width
      //*****************************************************************

      if (DQ_WIDTH <= 32) begin: gen_dq_le_32
        assign vio0_in[(6*DQ_WIDTH)-1:0] 
                 = dbg_calib_dq_tap_cnt[(6*DQ_WIDTH)-1:0];
      end else begin: gen_dq_gt_32
        assign vio0_in = dbg_calib_dq_tap_cnt[191:0];
      end

      if (DQS_WIDTH <= 8) begin: gen_dqs_le_8
        assign vio1_in[(6*DQS_WIDTH)-1:0]
                 = dbg_calib_dqs_tap_cnt[(6*DQS_WIDTH)-1:0];
        assign vio1_in[(12*DQS_WIDTH)-1:(6*DQS_WIDTH)] 
                 =  dbg_calib_gate_tap_cnt[(6*DQS_WIDTH)-1:0];
      end else begin: gen_dqs_gt_32
        assign vio1_in[47:0]  = dbg_calib_dqs_tap_cnt[47:0];
        assign vio1_in[95:48] = dbg_calib_gate_tap_cnt[47:0];
      end
 
//dbg_calib_rd_data_sel

     if (DQS_WIDTH <= 8) begin: gen_rdsel_le_8
        assign vio2_in[(DQS_WIDTH)+7:8]    
	         = dbg_calib_rd_data_sel[(DQS_WIDTH)-1:0];
     end else begin: gen_rdsel_gt_32
      assign vio2_in[15:8]    
                 = dbg_calib_rd_data_sel[7:0];
     end
 
//dbg_calib_rden_dly

     if (DQS_WIDTH <= 8) begin: gen_calrd_le_8
       assign vio2_in[(5*DQS_WIDTH)+19:20]   
                 = dbg_calib_rden_dly[(5*DQS_WIDTH)-1:0];
     end else begin: gen_calrd_gt_32
       assign vio2_in[59:20]   
                 = dbg_calib_rden_dly[39:0];
     end

//dbg_calib_gate_dly

     if (DQS_WIDTH <= 8) begin: gen_calgt_le_8
       assign vio2_in[(5*DQS_WIDTH)+59:60]   
                 = dbg_calib_gate_dly[(5*DQS_WIDTH)-1:0];
     end else begin: gen_calgt_gt_32
       assign vio2_in[99:60]   
                 = dbg_calib_gate_dly[39:0];
     end

//dbg_sel_idel_dq

     if (DQ_BITS <= 5) begin: gen_selid_le_5
       assign dbg_sel_idel_dq[DQ_BITS-1:0]      
                 = vio3_out[DQ_BITS+7:8];
     end else begin: gen_selid_gt_32
       assign dbg_sel_idel_dq[4:0]      
                 = vio3_out[12:8];
     end

//dbg_sel_idel_dqs

     if (DQS_BITS <= 3) begin: gen_seldqs_le_3
       assign dbg_sel_idel_dqs[DQS_BITS:0]     
                 = vio3_out[(DQS_BITS+16):16];
     end else begin: gen_seldqs_gt_32
       assign dbg_sel_idel_dqs[3:0]     
                 = vio3_out[19:16];
     end

//dbg_sel_idel_gate

     if (DQS_BITS <= 3) begin: gen_gtdqs_le_3
       assign dbg_sel_idel_gate[DQS_BITS:0]    
                 = vio3_out[(DQS_BITS+21):21];
     end else begin: gen_gtdqs_gt_32
       assign dbg_sel_idel_gate[3:0]    
                 = vio3_out[24:21];
     end


      assign vio2_in[3:0]              = dbg_calib_done;
      assign vio2_in[7:4]              = dbg_calib_err;
      
      assign dbg_idel_up_all           = vio3_out[0];
      assign dbg_idel_down_all         = vio3_out[1];
      assign dbg_idel_up_dq            = vio3_out[2];
      assign dbg_idel_down_dq          = vio3_out[3];
      assign dbg_idel_up_dqs           = vio3_out[4];
      assign dbg_idel_down_dqs         = vio3_out[5];
      assign dbg_idel_up_gate          = vio3_out[6];
      assign dbg_idel_down_gate        = vio3_out[7];
      assign dbg_sel_all_idel_dq       = vio3_out[15];
      assign dbg_sel_all_idel_dqs      = vio3_out[20];
      assign dbg_sel_all_idel_gate     = vio3_out[25];
    end
  endgenerate
  

endmodule



