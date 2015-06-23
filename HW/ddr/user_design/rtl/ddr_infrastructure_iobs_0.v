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
//  /   /        Filename	    : ddr_infrastructure_iobs_0.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:41 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This module has the FDDRRSE instantiations to the clocks.
//*****************************************************************************

`include "../rtl/ddr_parameters_0.v"
`timescale 1ns/100ps

module ddr_infrastructure_iobs_0
  (
   input                     clk0,
   output [(`CLK_WIDTH-1):0] ddr2_ck,
   output [(`CLK_WIDTH-1):0] ddr2_ck_n
  );

   wire vcc;
   wire gnd;


   wire [`CLK_WIDTH-1 :0]  ddr2_clk_q;


   assign  gnd = 1'b0;
   assign  vcc = 1'b1;

//---- ***********************************************************
//----     Output DDR generation
//----     This includes instantiation of the output DDR flip flop
//----     for ddr clk's and dimm clk's
//---- ***********************************************************




 genvar clk_i;
 generate
   for(clk_i = 0; clk_i < `CLK_WIDTH; clk_i = clk_i+1)
   begin: gen_clk
    FDDRRSE clk_inst
     (
      .Q  (ddr2_clk_q[clk_i]),
      .C0 (clk0),
      .C1 (~clk0),
      .CE (vcc),
      .D0 (vcc),
      .D1 (gnd),
      .R  (gnd),
      .S  (gnd)
      );
    end
  endgenerate
 


//---- ******************************************
//---- Ouput BUffers for ddr clk's and dimm clk's
//---- ******************************************




   genvar obuf_i;
   generate
     for(obuf_i = 0; obuf_i < `CLK_WIDTH; obuf_i = obuf_i+1)
     begin: gen_obuf
       OBUFDS OBUFDS_inst
        (
       .I(ddr2_clk_q[obuf_i]),
       .O(ddr2_ck[obuf_i]),
       .OB(ddr2_ck_n[obuf_i])
       );
     end
   endgenerate


endmodule
