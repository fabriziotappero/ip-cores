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
//  /   /         Filename: ddr2_phy_ctl_io.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Thu Aug 24 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module puts the memory control signals like address, bank address,
//   row address strobe, column address strobe, write enable and clock enable
//   in the IOBs.
//Reference:
//Revision History:
//   Rev 1.1 - To fix CR 540201, S attribute is added for CS, CKE and ODT
//             module (FDCPE) instances. PK. 01/08/10
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_ctl_io #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter CKE_WIDTH     = 1,
   parameter COL_WIDTH     = 10,
   parameter CS_NUM        = 1,
   parameter TWO_T_TIME_EN = 0,
   parameter CS_WIDTH      = 1,
   parameter ODT_WIDTH     = 1,
   parameter ROW_WIDTH     = 14,
   parameter DDR_TYPE      = 1
   )
  (
   input                   clk0,
   input                   clk90,
   input                   rst0,
   input                   rst90,
   input [ROW_WIDTH-1:0]   ctrl_addr,
   input [BANK_WIDTH-1:0]  ctrl_ba,
   input                   ctrl_ras_n,
   input                   ctrl_cas_n,
   input                   ctrl_we_n,
   input [CS_NUM-1:0]      ctrl_cs_n,
   input [ROW_WIDTH-1:0]   phy_init_addr,
   input [BANK_WIDTH-1:0]  phy_init_ba,
   input                   phy_init_ras_n,
   input                   phy_init_cas_n,
   input                   phy_init_we_n,
   input [CS_NUM-1:0]      phy_init_cs_n,
   input [CKE_WIDTH-1:0]   phy_init_cke,
   input                   phy_init_data_sel,
   input [CS_NUM-1:0]      odt,
   output [ROW_WIDTH-1:0]  ddr_addr,
   output [BANK_WIDTH-1:0] ddr_ba,
   output                  ddr_ras_n,
   output                  ddr_cas_n,
   output                  ddr_we_n,
   output [CKE_WIDTH-1:0]  ddr_cke,
   output [CS_WIDTH-1:0]   ddr_cs_n,
   output [ODT_WIDTH-1:0]  ddr_odt
   );

  reg [ROW_WIDTH-1:0]     addr_mux;
  reg [BANK_WIDTH-1:0]    ba_mux;
  reg                     cas_n_mux;
  reg [CS_NUM-1:0]        cs_n_mux;
  reg                     ras_n_mux;
  reg                     we_n_mux;



  //***************************************************************************




  // MUX to choose from either PHY or controller for SDRAM control

  generate // in 2t timing mode the extra register stage cannot be used.
    if(TWO_T_TIME_EN) begin // the control signals are asserted for two cycles
      always @(*)begin
        if (phy_init_data_sel) begin
          addr_mux  = ctrl_addr;
          ba_mux    = ctrl_ba;
          cas_n_mux = ctrl_cas_n;
          cs_n_mux  = ctrl_cs_n;
          ras_n_mux = ctrl_ras_n;
          we_n_mux  = ctrl_we_n;
        end else begin
          addr_mux  = phy_init_addr;
          ba_mux    = phy_init_ba;
          cas_n_mux = phy_init_cas_n;
          cs_n_mux  = phy_init_cs_n;
          ras_n_mux = phy_init_ras_n;
          we_n_mux  = phy_init_we_n;
        end
      end
    end else begin
      always @(posedge clk0)begin // register the signals in non 2t mode
        if (phy_init_data_sel) begin
          addr_mux <= ctrl_addr;
          ba_mux <= ctrl_ba;
          cas_n_mux <= ctrl_cas_n;
          cs_n_mux <= ctrl_cs_n;
          ras_n_mux <= ctrl_ras_n;
          we_n_mux <= ctrl_we_n;
        end else begin
          addr_mux <= phy_init_addr;
          ba_mux <= phy_init_ba;
          cas_n_mux <= phy_init_cas_n;
          cs_n_mux <= phy_init_cs_n;
          ras_n_mux <= phy_init_ras_n;
          we_n_mux <= phy_init_we_n;
        end
      end
    end
  endgenerate

  //***************************************************************************
  // Output flop instantiation
  // NOTE: Make sure all control/address flops are placed in IOBs
  //***************************************************************************

  // RAS: = 1 at reset
  (* IOB = "FORCE" *) FDCPE u_ff_ras_n
    (
     .Q   (ddr_ras_n),
     .C   (clk0),
     .CE  (1'b1),
     .CLR (1'b0),
     .D   (ras_n_mux),
     .PRE (rst0)
     ) /* synthesis syn_useioff = 1 */;

  // CAS: = 1 at reset
  (* IOB = "FORCE" *) FDCPE u_ff_cas_n
    (
     .Q   (ddr_cas_n),
     .C   (clk0),
     .CE  (1'b1),
     .CLR (1'b0),
     .D   (cas_n_mux),
     .PRE (rst0)
     ) /* synthesis syn_useioff = 1 */;

  // WE: = 1 at reset
  (* IOB = "FORCE" *) FDCPE u_ff_we_n
    (
     .Q   (ddr_we_n),
     .C   (clk0),
     .CE  (1'b1),
     .CLR (1'b0),
     .D   (we_n_mux),
     .PRE (rst0)
     ) /* synthesis syn_useioff = 1 */;

  // CKE: = 0 at reset
  genvar cke_i;
  generate
    for (cke_i = 0; cke_i < CKE_WIDTH; cke_i = cke_i + 1) begin: gen_cke
      (* IOB = "FORCE" *) (* S = "TRUE" *) FDCPE u_ff_cke
        (
         .Q   (ddr_cke[cke_i]),
         .C   (clk0),
         .CE  (1'b1),
         .CLR (rst0),
         .D   (phy_init_cke[cke_i]),
         .PRE (1'b0)
         ) /* synthesis syn_useioff = 1 */;
    end
  endgenerate

  // chip select: = 1 at reset
  // For unbuffered dimms the loading will be high. The chip select
  // can be asserted early if the loading is very high. The
  // code as is uses clock 0. If needed clock 270 can be used to
  // toggle chip select 1/4 clock cycle early. The code has
  // the clock 90 input for the early assertion of chip select.

  genvar cs_i;
  generate
    for(cs_i = 0; cs_i < CS_WIDTH; cs_i = cs_i + 1) begin: gen_cs_n
      if(TWO_T_TIME_EN) begin
         (* IOB = "FORCE" *) (* S = "TRUE" *) FDCPE u_ff_cs_n
           (
            .Q   (ddr_cs_n[cs_i]),
            .C   (clk0),
            .CE  (1'b1),
            .CLR (1'b0),
            .D   (cs_n_mux[(cs_i*CS_NUM)/CS_WIDTH]),
            .PRE (rst0)
            ) /* synthesis syn_useioff = 1 */;
      end else begin // if (TWO_T_TIME_EN)
         (* IOB = "FORCE" *) (* S = "TRUE" *) FDCPE u_ff_cs_n
           (
            .Q   (ddr_cs_n[cs_i]),
            .C   (clk0),
            .CE  (1'b1),
            .CLR (1'b0),
            .D   (cs_n_mux[(cs_i*CS_NUM)/CS_WIDTH]),
            .PRE (rst0)
            ) /* synthesis syn_useioff = 1 */;
      end // else: !if(TWO_T_TIME_EN)
    end
  endgenerate

  // address: = X at reset
  genvar addr_i;
  generate
    for (addr_i = 0; addr_i < ROW_WIDTH; addr_i = addr_i + 1) begin: gen_addr
      (* IOB = "FORCE" *) FDCPE u_ff_addr
        (
         .Q   (ddr_addr[addr_i]),
         .C   (clk0),
         .CE  (1'b1),
         .CLR (1'b0),
         .D   (addr_mux[addr_i]),
         .PRE (1'b0)
         ) /* synthesis syn_useioff = 1 */;
    end
  endgenerate

  // bank address = X at reset
  genvar ba_i;
  generate
    for (ba_i = 0; ba_i < BANK_WIDTH; ba_i = ba_i + 1) begin: gen_ba
      (* IOB = "FORCE" *) FDCPE u_ff_ba
        (
         .Q   (ddr_ba[ba_i]),
         .C   (clk0),
         .CE  (1'b1),
         .CLR (1'b0),
         .D   (ba_mux[ba_i]),
         .PRE (1'b0)
         ) /* synthesis syn_useioff = 1 */;
    end
  endgenerate

  // ODT control = 0 at reset
  genvar odt_i;
  generate
    if (DDR_TYPE > 0) begin: gen_odt_ddr2
      for (odt_i = 0; odt_i < ODT_WIDTH; odt_i = odt_i + 1) begin: gen_odt
        (* IOB = "FORCE" *) (* S = "TRUE" *) FDCPE u_ff_odt
          (
           .Q   (ddr_odt[odt_i]),
           .C   (clk0),
           .CE  (1'b1),
           .CLR (rst0),
           .D   (odt[(odt_i*CS_NUM)/ODT_WIDTH]),
           .PRE (1'b0)
           ) /* synthesis syn_useioff = 1 */;
      end
    end
  endgenerate

endmodule
