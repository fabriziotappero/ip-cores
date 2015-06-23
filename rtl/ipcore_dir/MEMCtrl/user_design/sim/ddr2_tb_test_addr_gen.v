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
//  /   /         Filename: ddr2_tb_test_addr_gen.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Fri Sep 01 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   The address for the memory and the various user commands can be given
//   through this module. It instantiates the block RAM which stores all the
//   information in particular sequence. The data stored should be in a
//   sequence starting from LSB:
//      column address, row address, bank address, commands.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_tb_test_addr_gen #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH = 2,
   parameter COL_WIDTH  = 10,
   parameter ROW_WIDTH  = 14
   )
  (
   input             clk,
   input             rst,
   input             wr_addr_en,
   output reg [2:0]  app_af_cmd,
   output reg [30:0] app_af_addr,
   output reg        app_af_wren
   );

  // RAM initialization patterns
  // NOTE: Not all bits in each range may be used (e.g. in an application
  //  using only 10 column bits, bits[11:10] of ROM output will be unused
  //  COLUMN  = [11:0]
  //  ROW     = [27:12]
  //  BANK    = [30:28]
  //  CHIP    = [31]
  //  COMMAND = [35:32]

  localparam RAM_INIT_00 = {128'h800020C0_800020C8_000020D0_000020D8,
                            128'h000010E0_000010E8_800010F0_800010F8};
  localparam RAM_INIT_01 = {128'h800020C0_800020C8_000020D0_000020D8,
                            128'h000010E0_000010E8_800010F0_800010F8};
  localparam RAM_INIT_02 = {128'h100040C0_100040C8_900040D0_900040D8,
                            128'h900030E0_900030E8_100030F0_100030F8};
  localparam RAM_INIT_03 = {128'h100040C0_100040C8_900040D0_900040D8,
                            128'h900030E0_900030E8_100030F0_100030F8};
  localparam RAM_INIT_04 = {128'hA00060C0_200060C8_200060D0_A00060D8,
                            128'h200050E0_A00050E8_A00050F0_200050F8};
  localparam RAM_INIT_05 = {128'hA00060C0_200060C8_200060D0_A00060D8,
                            128'h200050E0_A00050E8_A00050F0_200050F8};
  localparam RAM_INIT_06 = {128'h300080C0_B00080C8_B00080D0_300080D8,
                            128'hB00070E0_300070E8_300070F0_B00070F8};
  localparam RAM_INIT_07 = {128'h300080C0_B00080C8_B00080D0_300080D8,
                            128'hB00070E0_300070E8_300070F0_B00070F8};
  localparam RAM_INITP_00 = {128'h11111111_00000000_11111111_00000000,
                             128'h11111111_00000000_11111111_00000000};

  reg             wr_addr_en_r1;
  reg [2:0]       af_cmd_r;
  reg [30:0]      af_addr_r;
  reg             af_wren_r;
  wire [15:0]     ramb_addr;
  wire [35:0]     ramb_dout;
  reg             rst_r
                  /* synthesis syn_preserve = 1 */;
  reg             rst_r1
                  /* synthesis syn_maxfan = 10 */;
  reg [5:0]       wr_addr_cnt;
  reg             wr_addr_en_r0;

  // XST attributes for local reset "tree"
  // synthesis attribute shreg_extract of rst_r is "no";
  // synthesis attribute shreg_extract of rst_r1 is "no";
  // synthesis attribute equivalent_register_removal of rst_r is "no"

  //*****************************************************************

  // local reset "tree" for controller logic only. Create this to ease timing
  // on reset path. Prohibit equivalent register removal on RST_R to prevent
  // "sharing" with other local reset trees (caution: make sure global fanout
  // limit is set to larger than fanout on RST_R, otherwise SLICES will be
  // used for fanout control on RST_R.
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end

  //***************************************************************************
  // ADDRESS generation for Write and Read Address FIFOs:
  // ROM with address patterns
  // 512x36 mode is used with addresses 0-127 for storing write addresses and
  // addresses (128-511) for storing read addresses
  // INIP_OO: read 1
  // INIP_OO: write 0
  //***************************************************************************

  assign ramb_addr = {5'b00000, wr_addr_cnt, 5'b00000};

  RAMB36 #
    (
     .READ_WIDTH_A (36),
     .READ_WIDTH_B (36),
     .DOA_REG      (1),              // register to help timing
     .INIT_00      (RAM_INIT_00),
     .INIT_01      (RAM_INIT_01),
     .INIT_02      (RAM_INIT_02),
     .INIT_03      (RAM_INIT_03),
     .INIT_04      (RAM_INIT_04),
     .INIT_05      (RAM_INIT_05),
     .INIT_06      (RAM_INIT_06),
     .INIT_07      (RAM_INIT_07),
     .INITP_00     (RAM_INITP_00)
     )
    u_wr_rd_addr_lookup
      (
       .CASCADEOUTLATA   (),
       .CASCADEOUTLATB   (),
       .CASCADEOUTREGA   (),
       .CASCADEOUTREGB   (),
       .DOA              (ramb_dout[31:0]),
       .DOB              (),
       .DOPA             (ramb_dout[35:32]),
       .DOPB             (),
       .ADDRA            (ramb_addr),
       .ADDRB            (16'h0000),
       .CASCADEINLATA    (),
       .CASCADEINLATB    (),
       .CASCADEINREGA    (),
       .CASCADEINREGB    (),
       .CLKA             (clk),
       .CLKB             (clk),
       .DIA              (32'b0),
       .DIB              (32'b0),
       .DIPA             (4'b0),
       .DIPB             (4'b0),
       .ENA              (1'b1),
       .ENB              (1'b1),
       .REGCEA           (1'b1),
       .REGCEB           (1'b1),
       .SSRA             (1'b0),
       .SSRB             (1'b0),
       .WEA              (4'b0000),
       .WEB              (4'b0000)
       );

  // register backend enables / FIFO enables
  // write enable for Command/Address FIFO is generated 2 CC after WR_ADDR_EN
  // (takes 2 CC to come out of test RAM)
  always @(posedge clk)
    if (rst_r1) begin
      app_af_wren   <= 1'b0;
      wr_addr_en_r0 <= 1'b0;
      wr_addr_en_r1 <= 1'b0;
      af_wren_r     <= 1'b0;
    end else begin
      wr_addr_en_r0 <= wr_addr_en;
      wr_addr_en_r1 <= wr_addr_en_r0;
      af_wren_r   <= wr_addr_en_r1;
      app_af_wren   <= af_wren_r;
    end

  // FIFO addresses
  always @(posedge clk) begin
    af_addr_r <= {30{1'b0}};
    af_addr_r[COL_WIDTH-1:0] <= ramb_dout[COL_WIDTH-1:0];
    af_addr_r[ROW_WIDTH+COL_WIDTH-1:COL_WIDTH]
      <= ramb_dout[ROW_WIDTH+11:12];
    af_addr_r[BANK_WIDTH+ROW_WIDTH+COL_WIDTH-1:ROW_WIDTH+COL_WIDTH]
      <= ramb_dout[BANK_WIDTH+27:28];
    af_addr_r[BANK_WIDTH+ROW_WIDTH+COL_WIDTH]
      <= ramb_dout[31];
    // only reads and writes are supported for now
    af_cmd_r  <= {1'b0, ramb_dout[33:32]};
    app_af_cmd <= af_cmd_r;
    app_af_addr <= af_addr_r;
  end

  // address input for RAM
  always @ (posedge clk)
    if (rst_r1)
      wr_addr_cnt <= 6'b000000;
    else if (wr_addr_en)
      wr_addr_cnt <= wr_addr_cnt + 1;


endmodule
