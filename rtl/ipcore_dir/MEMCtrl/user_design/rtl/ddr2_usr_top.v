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
//  /   /         Filename: ddr2_usr_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Mon Aug 28 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module interfaces with the user. The user should provide the data
//   and  various commands.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH     = 2,
   parameter CS_BITS        = 0,
   parameter COL_WIDTH      = 10,
   parameter DQ_WIDTH       = 72,
   parameter DQ_PER_DQS     = 8,
   parameter APPDATA_WIDTH  = 144,
   parameter ECC_ENABLE     = 0,
   parameter DQS_WIDTH      = 9,
   parameter ROW_WIDTH      = 14
   )
  (
   input                                     clk0,
   input                                     clk90,
   input                                     rst0,
   input [DQ_WIDTH-1:0]                      rd_data_in_rise,
   input [DQ_WIDTH-1:0]                      rd_data_in_fall,
   input [DQS_WIDTH-1:0]                     phy_calib_rden,
   input [DQS_WIDTH-1:0]                     phy_calib_rden_sel,
   output                                    rd_data_valid,
   output [APPDATA_WIDTH-1:0]                rd_data_fifo_out,
   input [2:0]                               app_af_cmd,
   input [30:0]                              app_af_addr,
   input                                     app_af_wren,
   input                                     ctrl_af_rden,
   output [2:0]                              af_cmd,
   output [30:0]                             af_addr,
   output                                    af_empty,
   output                                    app_af_afull,
   output [1:0]                              rd_ecc_error,
   input                                     app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                 app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]             app_wdf_mask_data,
   input                                     wdf_rden,
   output                                    app_wdf_afull,
   output [(2*DQ_WIDTH)-1:0]                 wdf_data,
   output [((2*DQ_WIDTH)/8)-1:0]             wdf_mask_data
   );

  wire [(APPDATA_WIDTH/2)-1:0] i_rd_data_fifo_out_fall;
  wire [(APPDATA_WIDTH/2)-1:0] i_rd_data_fifo_out_rise;

  //***************************************************************************

  assign rd_data_fifo_out = {i_rd_data_fifo_out_fall,
                             i_rd_data_fifo_out_rise};

  // read data de-skew and ECC calculation
  ddr2_usr_rd #
    (
     .DQ_PER_DQS    (DQ_PER_DQS),
     .ECC_ENABLE    (ECC_ENABLE),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .DQS_WIDTH     (DQS_WIDTH)
     )
     u_usr_rd
      (
       .clk0             (clk0),
       .rst0             (rst0),
       .rd_data_in_rise  (rd_data_in_rise),
       .rd_data_in_fall  (rd_data_in_fall),
       .rd_ecc_error     (rd_ecc_error),
       .ctrl_rden        (phy_calib_rden),
       .ctrl_rden_sel    (phy_calib_rden_sel),
       .rd_data_valid    (rd_data_valid),
       .rd_data_out_rise (i_rd_data_fifo_out_rise),
       .rd_data_out_fall (i_rd_data_fifo_out_fall)
       );

  // Command/Addres FIFO
  ddr2_usr_addr_fifo #
    (
     .BANK_WIDTH (BANK_WIDTH),
     .COL_WIDTH  (COL_WIDTH),
     .CS_BITS    (CS_BITS),
     .ROW_WIDTH  (ROW_WIDTH)
     )
     u_usr_addr_fifo
      (
       .clk0         (clk0),
       .rst0         (rst0),
       .app_af_cmd   (app_af_cmd),
       .app_af_addr  (app_af_addr),
       .app_af_wren  (app_af_wren),
       .ctrl_af_rden (ctrl_af_rden),
       .af_cmd       (af_cmd),
       .af_addr      (af_addr),
       .af_empty     (af_empty),
       .app_af_afull (app_af_afull)
       );

  ddr2_usr_wr #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_BITS       (CS_BITS),
     .DQ_WIDTH      (DQ_WIDTH),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .ECC_ENABLE    (ECC_ENABLE),
     .ROW_WIDTH     (ROW_WIDTH)
     )
    u_usr_wr
      (
       .clk0              (clk0),
       .clk90             (clk90),
       .rst0              (rst0),
       .app_wdf_wren      (app_wdf_wren),
       .app_wdf_data      (app_wdf_data),
       .app_wdf_mask_data (app_wdf_mask_data),
       .wdf_rden          (wdf_rden),
       .app_wdf_afull     (app_wdf_afull),
       .wdf_data          (wdf_data),
       .wdf_mask_data     (wdf_mask_data)
       );

endmodule