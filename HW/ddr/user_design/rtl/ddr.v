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
// Copyright 2005, 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor		    : Xilinx
// \   \   \/    Version            : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename	    : ddr.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This module has the instantiations main and infrastructure_top
//		  modules
//*****************************************************************************

`timescale 1ns/100ps

(* X_CORE_INFO = "mig_v3_61_ddr2_sp3, Coregen 12.4" , 
   CORE_GENERATION_INFO = "ddr2_sp3,mig_v3_61,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=13'b0010100110010, ext_load_mode_register=13'b0000000000000, language=Verilog, synthesis_tool=ISE, interface_type=DDR2_SDRAM, no_of_controllers=1}" *)
module ddr
  (
   inout  [15:0]   cntrl0_ddr2_dq,
   output [12:0]   cntrl0_ddr2_a,
   output [1:0]    cntrl0_ddr2_ba,
   output          cntrl0_ddr2_cke,
   output          cntrl0_ddr2_cs_n,
   output          cntrl0_ddr2_ras_n,
   output          cntrl0_ddr2_cas_n,
   output          cntrl0_ddr2_we_n,
   output          cntrl0_ddr2_odt,
   output [1:0]    cntrl0_ddr2_dm,
   input           cntrl0_rst_dqs_div_in,
   output          cntrl0_rst_dqs_div_out,
   input           reset_in_n,
   input           cntrl0_burst_done,
   output          cntrl0_init_done,
   output          cntrl0_ar_done,
   output          cntrl0_user_data_valid,
   output          cntrl0_auto_ref_req,
   output          cntrl0_user_cmd_ack,
   input  [2:0]    cntrl0_user_command_register,
   output          cntrl0_clk_tb,
   output          cntrl0_clk90_tb,
   output          cntrl0_sys_rst_tb,
   output          cntrl0_sys_rst90_tb,
   output          cntrl0_sys_rst180_tb,
   output [31:0]   cntrl0_user_output_data,
   input  [31:0]   cntrl0_user_input_data,
   input  [3:0]    cntrl0_user_data_mask,
   input  [24:0]   cntrl0_user_input_address,
   input           clk_int,
   input           clk90_int,
   input           dcm_lock,
   inout  [1:0]    cntrl0_ddr2_dqs,
   inout  [1:0]    cntrl0_ddr2_dqs_n,
   output [0:0]    cntrl0_ddr2_ck,
   output [0:0]    cntrl0_ddr2_ck_n
   );

   wire       wait_200us;
   wire       sys_rst;
   wire       sys_rst90;
   wire       sys_rst180;
   wire [4:0] delay_sel_val;

 // debug signals declarations
   wire [4:0] dbg_delay_sel;
   wire [4:0] dbg_phase_cnt;
   wire [5:0] dbg_cnt;
   wire       dbg_trans_onedtct;
   wire       dbg_trans_twodtct;
   wire       dbg_enb_trans_two_dtct;
   wire       dbg_rst_calib;
// chipscope signals 
   wire [19:0] dbg_data;
   wire [3:0]  dbg_trig;
   wire [35:0] control0;
   wire [35:0] control1;
   wire [11:0] vio_out;
   wire [4:0]  vio_out_dqs;
   wire        vio_out_dqs_en;
   wire [4:0]  vio_out_rst_dqs_div;
   wire        vio_out_rst_dqs_div_en;


ddr_top_0 top_00
 (
     .ddr2_dq                   (cntrl0_ddr2_dq),
     .ddr2_a                    (cntrl0_ddr2_a),
     .ddr2_ba                   (cntrl0_ddr2_ba),
     .ddr2_cke                  (cntrl0_ddr2_cke),
     .ddr2_cs_n                 (cntrl0_ddr2_cs_n),
     .ddr2_ras_n                (cntrl0_ddr2_ras_n),
     .ddr2_cas_n                (cntrl0_ddr2_cas_n),
     .ddr2_we_n                 (cntrl0_ddr2_we_n),
     .ddr2_odt                  (cntrl0_ddr2_odt),
     .ddr2_dm                   (cntrl0_ddr2_dm),
     .rst_dqs_div_in            (cntrl0_rst_dqs_div_in),
     .rst_dqs_div_out           (cntrl0_rst_dqs_div_out),
     .burst_done                (cntrl0_burst_done),
     .init_done                 (cntrl0_init_done),
     .ar_done                   (cntrl0_ar_done),
     .user_data_valid           (cntrl0_user_data_valid),
     .auto_ref_req              (cntrl0_auto_ref_req),
     .user_cmd_ack              (cntrl0_user_cmd_ack),
     .user_command_register     (cntrl0_user_command_register),
     .clk_tb                    (cntrl0_clk_tb),
     .clk90_tb                  (cntrl0_clk90_tb),
     .sys_rst_tb                (cntrl0_sys_rst_tb),
     .sys_rst90_tb              (cntrl0_sys_rst90_tb),
     .sys_rst180_tb             (cntrl0_sys_rst180_tb),
     .user_output_data          (cntrl0_user_output_data),
     .user_input_data           (cntrl0_user_input_data),
     .user_data_mask            (cntrl0_user_data_mask),
     .user_input_address        (cntrl0_user_input_address),
     .ddr2_dqs                  (cntrl0_ddr2_dqs),
     .ddr2_dqs_n                (cntrl0_ddr2_dqs_n),
     .ddr2_ck                   (cntrl0_ddr2_ck),
     .ddr2_ck_n                 (cntrl0_ddr2_ck_n),
     .clk_int                   (clk_int),
     .clk90_int                 (clk90_int),
   .wait_200us        (wait_200us),
   .sys_rst           (sys_rst),
   .sys_rst90         (sys_rst90),
   .sys_rst180        (sys_rst180),
   .delay_sel_val     (delay_sel_val),

    //Debug signals

     .dbg_delay_sel            (dbg_delay_sel),
     .dbg_rst_calib            (dbg_rst_calib),
     .vio_out_dqs              (vio_out_dqs),   
     .vio_out_dqs_en           (vio_out_dqs_en),   
     .vio_out_rst_dqs_div      (vio_out_rst_dqs_div),
     .vio_out_rst_dqs_div_en   (vio_out_rst_dqs_div_en)
  );

ddr_infrastructure_top0 infrastructure_top0
  (
     .reset_in_n                (reset_in_n),
     .clk_int                   (clk_int),
     .clk90_int                 (clk90_int),
     .dcm_lock                  (dcm_lock),
   .wait_200us_rout        (wait_200us),
   .delay_sel_val1_val     (delay_sel_val),
   .sys_rst_val            (sys_rst),
   .sys_rst90_val          (sys_rst90),
   .sys_rst180_val         (sys_rst180),
   .dbg_phase_cnt          (dbg_phase_cnt),
   .dbg_cnt                (dbg_cnt),
   .dbg_trans_onedtct      (dbg_trans_onedtct),
   .dbg_trans_twodtct      (dbg_trans_twodtct),
   .dbg_enb_trans_two_dtct (dbg_enb_trans_two_dtct)
   );



endmodule


