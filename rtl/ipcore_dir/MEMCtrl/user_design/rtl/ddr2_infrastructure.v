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
//  /   /         Filename: ddr2_infrastructure.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Clock distribution and reset synchronization
//Reference:
//Revision History:
//   Rev 1.1 - Port name changed from dcm_lock to locked. PK. 10/14/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_infrastructure #
  (
   parameter RST_ACT_LOW  = 1
   )
  (
   input  clk0,
   input  clk90,
   input  clk200,
   input  clkdiv0,
   input  locked,
   input  sys_rst_n,
   input  idelay_ctrl_rdy,
   output rst0,
   output rst90,
   output rst200,
   output rstdiv0
   );

  // # of clock cycles to delay deassertion of reset. Needs to be a fairly
  // high number not so much for metastability protection, but to give time
  // for reset (i.e. stable clock cycles) to propagate through all state
  // machines and to all control signals (i.e. not all control signals have
  // resets, instead they rely on base state logic being reset, and the effect
  // of that reset propagating through the logic). Need this because we may not
  // be getting stable clock cycles while reset asserted (i.e. since reset
  // depends on DCM lock status)
  localparam RST_SYNC_NUM = 25;

  reg [RST_SYNC_NUM-1:0]     rst0_sync_r    /* synthesis syn_maxfan = 10 */;
  reg [RST_SYNC_NUM-1:0]     rst200_sync_r  /* synthesis syn_maxfan = 10 */;
  reg [RST_SYNC_NUM-1:0]     rst90_sync_r   /* synthesis syn_maxfan = 10 */;
  reg [(RST_SYNC_NUM/2)-1:0] rstdiv0_sync_r /* synthesis syn_maxfan = 10 */;
  wire                       rst_tmp;
  wire                       sys_clk_ibufg;
  wire                       sys_rst;

  assign sys_rst = RST_ACT_LOW ? ~sys_rst_n: sys_rst_n;

  //***************************************************************************
  // Reset synchronization
  // NOTES:
  //   1. shut down the whole operation if the DCM hasn't yet locked (and by
  //      inference, this means that external SYS_RST_IN has been asserted -
  //      DCM deasserts LOCKED as soon as SYS_RST_IN asserted)
  //   2. In the case of all resets except rst200, also assert reset if the
  //      IDELAY master controller is not yet ready
  //   3. asynchronously assert reset. This was we can assert reset even if
  //      there is no clock (needed for things like 3-stating output buffers).
  //      reset deassertion is synchronous.
  //***************************************************************************

  assign rst_tmp = sys_rst | ~locked | ~idelay_ctrl_rdy;

  // synthesis attribute max_fanout of rst0_sync_r is 10
  always @(posedge clk0 or posedge rst_tmp)
    if (rst_tmp)
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      // logical left shift by one (pads with 0)
      rst0_sync_r <= rst0_sync_r << 1;

  // synthesis attribute max_fanout of rstdiv0_sync_r is 10
  always @(posedge clkdiv0 or posedge rst_tmp)
    if (rst_tmp)
      rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
    else
      // logical left shift by one (pads with 0)
      rstdiv0_sync_r <= rstdiv0_sync_r << 1;

  // synthesis attribute max_fanout of rst90_sync_r is 10
  always @(posedge clk90 or posedge rst_tmp)
    if (rst_tmp)
      rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst90_sync_r <= rst90_sync_r << 1;

  // make sure CLK200 doesn't depend on IDELAY_CTRL_RDY, else chicken n' egg
   // synthesis attribute max_fanout of rst200_sync_r is 10
  always @(posedge clk200 or negedge locked)
    if (!locked)
      rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst200_sync_r <= rst200_sync_r << 1;

  assign rst0    = rst0_sync_r[RST_SYNC_NUM-1];
  assign rst90   = rst90_sync_r[RST_SYNC_NUM-1];
  assign rst200  = rst200_sync_r[RST_SYNC_NUM-1];
  assign rstdiv0 = rstdiv0_sync_r[(RST_SYNC_NUM/2)-1];

endmodule
