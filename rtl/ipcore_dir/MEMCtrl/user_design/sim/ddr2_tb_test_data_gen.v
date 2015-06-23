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
//  /   /         Filename: ddr2_tb_test_data_gen.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Fri Sep 01 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module contains the data generation logic for the synthesizable
//   testbench.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_tb_test_data_gen #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter DM_WIDTH      = 9,
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0
   )
  (
   input                                      clk,
   input                                      rst,
   input                                      wr_data_en,
   input                                      rd_data_valid,
   output                                     app_wdf_wren,
   output reg [APPDATA_WIDTH-1:0]             app_wdf_data,
   output reg [(APPDATA_WIDTH/8)-1:0]         app_wdf_mask_data,
   output     [APPDATA_WIDTH-1:0]             app_cmp_data
   );

  localparam WR_IDLE_FIRST_DATA = 2'b00;
  localparam WR_SECOND_DATA     = 2'b01;
  localparam WR_THIRD_DATA      = 2'b10;
  localparam WR_FOURTH_DATA     = 2'b11;
  localparam RD_IDLE_FIRST_DATA = 2'b00;
  localparam RD_SECOND_DATA     = 2'b01;
  localparam RD_THIRD_DATA      = 2'b10;
  localparam RD_FOURTH_DATA     = 2'b11;

  reg [APPDATA_WIDTH-1:0]              app_wdf_data_r;
  reg [(APPDATA_WIDTH/8)-1:0]          app_wdf_mask_data_r;
  wire                                 app_wdf_wren_r;
  reg [(APPDATA_WIDTH/2)-1:0]          rd_data_pat_fall;
  reg [(APPDATA_WIDTH/2)-1:0]          rd_data_pat_rise;
  wire                                 rd_data_valid_r;
  reg [1:0]                            rd_state;
  reg                                  rst_r
                                       /* synthesis syn_preserve = 1 */;
  reg                                  rst_r1
                                       /* synthesis syn_maxfan = 10 */;
  wire [APPDATA_WIDTH-1:0]             wr_data;
  reg                                  wr_data_en_r;
  reg [(APPDATA_WIDTH/2)-1:0]          wr_data_fall
                                       /* synthesis syn_maxfan = 2 */;
  reg [(APPDATA_WIDTH/2)-1:0]          wr_data_rise
                                        /* synthesis syn_maxfan = 2 */;
  wire [(APPDATA_WIDTH/8)-1:0]         wr_mask_data;
  wire [(APPDATA_WIDTH/16)-1:0]        wr_mask_data_fall;
  wire [(APPDATA_WIDTH/16)-1:0]        wr_mask_data_rise;
  reg [1:0]                            wr_state;

  // XST attributes for local reset "tree"
  // synthesis attribute shreg_extract of rst_r is "no";
  // synthesis attribute shreg_extract of rst_r1 is "no";
  // synthesis attribute equivalent_register_removal of rst_r is "no"

  //***************************************************************************

  // local reset "tree" for controller logic only. Create this to ease timing
  // on reset path. Prohibit equivalent register removal on RST_R to prevent
  // "sharing" with other local reset trees (caution: make sure global fanout
  // limit is set to larger than fanout on RST_R, otherwise SLICES will be
  // used for fanout control on RST_R.
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end

  always @(posedge clk) begin
    app_wdf_data_r      <= wr_data;
    app_wdf_mask_data_r <= wr_mask_data;
    app_wdf_data        <= app_wdf_data_r;
    app_wdf_mask_data   <= app_wdf_mask_data_r;
  end

  // inst ff for timing
  FDRSE ff_wdf_wren
    (
     .Q   (app_wdf_wren_r),
     .C   (clk),
     .CE  (1'b1),
     .D   (wr_data_en_r),
     .R   (1'b0),
     .S   (1'b0)
     );

  FDRSE ff_wdf_wren_r
    (
     .Q   (app_wdf_wren),
     .C   (clk),
     .CE  (1'b1),
     .D   (app_wdf_wren_r),
     .R   (1'b0),
     .S   (1'b0)
     );

  FDRSE ff_rd_data_valid_r
    (
     .Q   (rd_data_valid_r),
     .C   (clk),
     .CE  (1'b1),
     .D   (rd_data_valid),
     .R   (1'b0),
     .S   (1'b0)
     );

  //***************************************************************************
  // DATA generation for WRITE DATA FIFOs & for READ DATA COMPARE
  //***************************************************************************

  assign wr_data      = {wr_data_fall, wr_data_rise};
  assign wr_mask_data = {wr_mask_data_fall, wr_mask_data_rise};

  //*****************************************************************
  // For now, don't vary data masks
  //*****************************************************************

  assign wr_mask_data_rise = {(APPDATA_WIDTH/8){1'b0}};
  assign wr_mask_data_fall = {(APPDATA_WIDTH/8){1'b0}};

  //*****************************************************************
  // Write data logic
  //*****************************************************************

  // write data generation
  //synthesis attribute max_fanout of wr_data_fall is 2
  //synthesis attribute max_fanout of wr_data_rise is 2
  always @(posedge clk) begin
    if (rst_r1) begin
      wr_data_rise <= {(APPDATA_WIDTH/2){1'bx}};
      wr_data_fall <= {(APPDATA_WIDTH/2){1'bx}};
      wr_state <= WR_IDLE_FIRST_DATA;
    end else begin
      case (wr_state)
        WR_IDLE_FIRST_DATA:
          if (wr_data_en) begin
            wr_data_rise <= {(APPDATA_WIDTH/2){1'b1}}; // 0xF
            wr_data_fall <= {(APPDATA_WIDTH/2){1'b0}}; // 0x0
            wr_state <= WR_SECOND_DATA;
          end
        WR_SECOND_DATA:
          if (wr_data_en) begin
            wr_data_rise <= {(APPDATA_WIDTH/4){2'b10}}; // 0xA
            wr_data_fall <= {(APPDATA_WIDTH/4){2'b01}}; // 0x5
            wr_state <= WR_THIRD_DATA;
          end
        WR_THIRD_DATA:
          if (wr_data_en) begin
            wr_data_rise <= {(APPDATA_WIDTH/4){2'b01}}; // 0x5
            wr_data_fall <= {(APPDATA_WIDTH/4){2'b10}}; // 0xA
            wr_state <= WR_FOURTH_DATA;
          end
        WR_FOURTH_DATA:
          if (wr_data_en) begin
            wr_data_rise <= {(APPDATA_WIDTH/8){4'b1001}}; // 0x9
            wr_data_fall <= {(APPDATA_WIDTH/8){4'b0110}}; // 0x6
            wr_state <= WR_IDLE_FIRST_DATA;
          end
      endcase
    end
  end

  always @(posedge clk)
    if (rst_r1)
      wr_data_en_r <= 1'b0;
    else
      wr_data_en_r <= wr_data_en;

  //*****************************************************************
  // Read data logic
  //*****************************************************************

  // read comparison data generation
  always @(posedge clk)
    if (rst_r1) begin
      rd_data_pat_rise <= {(APPDATA_WIDTH/2){1'bx}};
      rd_data_pat_fall <= {(APPDATA_WIDTH/2){1'bx}};
      rd_state <= RD_IDLE_FIRST_DATA;
    end else begin
      case (rd_state)
        RD_IDLE_FIRST_DATA:
          if (rd_data_valid_r)
            begin
              rd_data_pat_rise <= {(APPDATA_WIDTH/2){1'b1}}; // 0xF
              rd_data_pat_fall <= {(APPDATA_WIDTH/2){1'b0}}; // 0x0
              rd_state <= RD_SECOND_DATA;
            end
        RD_SECOND_DATA:
          if (rd_data_valid_r) begin
            rd_data_pat_rise <= {(APPDATA_WIDTH/4){2'b10}};  // 0xA
            rd_data_pat_fall <= {(APPDATA_WIDTH/4){2'b01}};  // 0x5
            rd_state <= RD_THIRD_DATA;
          end
        RD_THIRD_DATA:
          if (rd_data_valid_r) begin
            rd_data_pat_rise <= {(APPDATA_WIDTH/4){2'b01}};  // 0x5
            rd_data_pat_fall <= {(APPDATA_WIDTH/4){2'b10}};  // 0xA
            rd_state <= RD_FOURTH_DATA;
          end
        RD_FOURTH_DATA:
          if (rd_data_valid_r) begin
            rd_data_pat_rise <= {(APPDATA_WIDTH/8){4'b1001}}; // 0x9
            rd_data_pat_fall <= {(APPDATA_WIDTH/8){4'b0110}}; // 0x6
            rd_state <= RD_IDLE_FIRST_DATA;
          end
      endcase
    end

  //data to the compare circuit during read
  assign app_cmp_data = {rd_data_pat_fall, rd_data_pat_rise};

endmodule
