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
//  /   /         Filename: ddr2_chipscope.v
// /___/   /\     Date Last Modified: $Data$ 
// \   \  /  \	  Date Created: 9/14/06
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   Skeleton Chipscope module declarations - for simulation only
//Reference:
//Revision History:
//
//*****************************************************************************

`timescale 1ns/1ps

module icon4 
  (
      control0,
      control1,
      control2,
      control3
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  output [35:0] control0;
  output [35:0] control1;
  output [35:0] control2;
  output [35:0] control3;
endmodule

module vio_async_in192
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [191:0] async_in;
endmodule

module vio_async_in96
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [95:0] async_in;
endmodule

module vio_async_in100
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [99:0] async_in;
endmodule

module vio_sync_out32
  (
    control,
    clk,
    sync_out
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  clk;
  output [31:0] sync_out;
endmodule