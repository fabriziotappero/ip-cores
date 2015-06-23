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
// Copyright 2006, 2007 Xilinx, Inc.
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
//  /   /         Filename: ddr2_tb_test_gen.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Fri Sep 01 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module instantiates the addr_gen and the data_gen modules. It takes
//   the user data stored in internal FIFOs and gives the data that is to be
//   compared with the read data
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_tb_test_gen #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter DM_WIDTH      = 9,
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input                                  clk,
   input                                  rst,
   input                                  wr_addr_en,
   input                                  wr_data_en,
   input                                  rd_data_valid,
   output                                 app_af_wren,
   output [2:0]                           app_af_cmd,
   output [30:0]                          app_af_addr,
   output                                 app_wdf_wren,
   output [APPDATA_WIDTH-1:0]             app_wdf_data,
   output [(APPDATA_WIDTH/8)-1:0]         app_wdf_mask_data,
   output [APPDATA_WIDTH-1:0]             app_cmp_data
   );

  //***************************************************************************

  ddr2_tb_test_addr_gen #
    (
     .BANK_WIDTH (BANK_WIDTH),
     .COL_WIDTH  (COL_WIDTH),
     .ROW_WIDTH  (ROW_WIDTH)
     )
    u_addr_gen
      (
       .clk         (clk),
       .rst         (rst),
       .wr_addr_en  (wr_addr_en),
       .app_af_cmd  (app_af_cmd),
       .app_af_addr (app_af_addr),
       .app_af_wren (app_af_wren)
       );

  ddr2_tb_test_data_gen #
    (
     .DM_WIDTH      (DM_WIDTH),
     .DQ_WIDTH      (DQ_WIDTH),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .ECC_ENABLE    (ECC_ENABLE)
     )
    u_data_gen
      (
       .clk               (clk),
       .rst               (rst),
       .wr_data_en        (wr_data_en),
       .rd_data_valid     (rd_data_valid),
       .app_wdf_wren      (app_wdf_wren),
       .app_wdf_data      (app_wdf_data),
       .app_wdf_mask_data (app_wdf_mask_data),
       .app_cmp_data      (app_cmp_data)
       );

endmodule
