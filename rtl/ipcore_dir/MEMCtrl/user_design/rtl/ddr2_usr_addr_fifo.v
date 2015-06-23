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
//  /   /         Filename: ddr2_usr_addr_fifo.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Mon Aug 28 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module instantiates the block RAM based FIFO to store the user
//   address and the command information. Also calculates potential bank/row
//   conflicts by comparing the new address with last address issued.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_addr_fifo #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input          clk0,
   input          rst0,
   input [2:0]    app_af_cmd,
   input [30:0]   app_af_addr,
   input          app_af_wren,
   input          ctrl_af_rden,
   output [2:0]   af_cmd,
   output [30:0]  af_addr,
   output         af_empty,
   output         app_af_afull
   );

  wire [35:0]     fifo_data_out;
   reg            rst_r;


  always @(posedge clk0)
     rst_r <= rst0;


  //***************************************************************************

  assign af_cmd      = fifo_data_out[33:31];
  assign af_addr     = fifo_data_out[30:0];

  //***************************************************************************

  FIFO36 #
    (
     .ALMOST_EMPTY_OFFSET     (13'h0007),
     .ALMOST_FULL_OFFSET      (13'h000F),
     .DATA_WIDTH              (36),
     .DO_REG                  (1),
     .EN_SYN                  ("TRUE"),
     .FIRST_WORD_FALL_THROUGH ("FALSE")
     )
    u_af
      (
       .ALMOSTEMPTY (),
       .ALMOSTFULL  (app_af_afull),
       .DO          (fifo_data_out[31:0]),
       .DOP         (fifo_data_out[35:32]),
       .EMPTY       (af_empty),
       .FULL        (),
       .RDCOUNT     (),
       .RDERR       (),
       .WRCOUNT     (),
       .WRERR       (),
       .DI          ({app_af_cmd[0],app_af_addr}),
       .DIP         ({2'b00,app_af_cmd[2:1]}),
       .RDCLK       (clk0),
       .RDEN        (ctrl_af_rden),
       .RST         (rst_r),
       .WRCLK       (clk0),
       .WREN        (app_af_wren)
       );

endmodule
