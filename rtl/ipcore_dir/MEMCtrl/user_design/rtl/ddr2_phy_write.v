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
//  /   /         Filename: ddr2_phy_write.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Thu Aug 24 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//Reference:
//   Handles delaying various write control signals appropriately depending
//   on CAS latency, additive latency, etc. Also splits the data and mask in
//   rise and fall buses.
//Revision History:
//   Rev 1.1 - For Dual Rank parts support ODT logic corrected. PK. 08/05/08
//   Rev 1.2 - Retain current data pattern for stage 4 calibration, and create
//             new pattern for stage 4. RC. 09/21/09.
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_write #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter DQ_WIDTH      = 72,
   parameter CS_NUM        = 1,
   parameter ADDITIVE_LAT  = 0,
   parameter CAS_LAT       = 5,
   parameter ECC_ENABLE    = 0,
   parameter ODT_TYPE      = 1,
   parameter REG_ENABLE    = 1,
   parameter DDR_TYPE      = 1
   )
  (
   input                       clk0,
   input                       clk90,
   input                       rst90,
   input [(2*DQ_WIDTH)-1:0]    wdf_data,
   input [(2*DQ_WIDTH/8)-1:0]  wdf_mask_data,
   input                       ctrl_wren,
   input                       phy_init_wren,
   input                       phy_init_data_sel,
   output reg                  dm_ce,
   output reg [1:0]            dq_oe_n,
   output reg                  dqs_oe_n ,
   output reg                  dqs_rst_n ,
   output                      wdf_rden,
   output reg [CS_NUM-1:0]     odt ,
   output [DQ_WIDTH-1:0]       wr_data_rise,
   output [DQ_WIDTH-1:0]       wr_data_fall,
   output [(DQ_WIDTH/8)-1:0]   mask_data_rise,
   output [(DQ_WIDTH/8)-1:0]   mask_data_fall
   );

  localparam   MASK_WIDTH               = DQ_WIDTH/8;
  localparam   DDR1                     = 0;
  localparam   DDR2                     = 1;
  localparam   DDR3                     = 2;

  // (MIN,MAX) value of WR_LATENCY for DDR1:
  //   REG_ENABLE   = (0,1)
  //   ECC_ENABLE   = (0,1)
  //   Write latency = 1
  //   Total: (1,3)
  // (MIN,MAX) value of WR_LATENCY for DDR2:
  //   REG_ENABLE   = (0,1)
  //   ECC_ENABLE   = (0,1)
  //   Write latency = ADDITIVE_CAS + CAS_LAT - 1 = (0,4) + (3,5) - 1 = (2,8)
  //     ADDITIVE_LAT = (0,4) (JEDEC79-2B)
  //     CAS_LAT      = (3,5) (JEDEC79-2B)
  //   Total: (2,10)
  localparam WR_LATENCY = (DDR_TYPE == DDR3) ?
             (ADDITIVE_LAT + (CAS_LAT) + REG_ENABLE ) :
             (DDR_TYPE == DDR2) ?
             (ADDITIVE_LAT + (CAS_LAT-1) + REG_ENABLE ) :
             (1 + REG_ENABLE );

  // NOTE that ODT timing does not need to be delayed for registered
  // DIMM case, since like other control/address signals, it gets
  // delayed by one clock cycle at the DIMM
  localparam ODT_WR_LATENCY = WR_LATENCY - REG_ENABLE;

  wire                     dm_ce_0;
  reg                      dm_ce_r;
  wire [1:0]               dq_oe_0;
  reg [1:0]                dq_oe_n_90_r1;
  reg [1:0]                dq_oe_270;
  wire                     dqs_oe_0;
  reg                      dqs_oe_270;
  reg                      dqs_oe_n_180_r1;
  wire                     dqs_rst_0;
  reg                      dqs_rst_n_180_r1;
  reg                      dqs_rst_270;
  reg                      ecc_dm_error_r;
  reg                      ecc_dm_error_r1;
  reg [(DQ_WIDTH-1):0]     init_data_f;
  reg [(DQ_WIDTH-1):0]     init_data_r;
  reg [3:0]                init_wdf_cnt_r;
  wire                     odt_0;
  reg                      rst90_r /* synthesis syn_maxfan = 10 */;
  reg [10:0]               wr_stages ;
  reg [(2*DQ_WIDTH)-1:0]   wdf_data_r;
  reg [(2*DQ_WIDTH/8)-1:0] wdf_mask_r;
  wire [(2*DQ_WIDTH/8)-1:0] wdf_ecc_mask;

  reg [(2*DQ_WIDTH/8)-1:0] wdf_mask_r1;
  wire                     wdf_rden_0;
  reg                      calib_rden_90_r;
  reg                      wdf_rden_90_r;
  reg                      wdf_rden_90_r1;
  reg                      wdf_rden_270;

  always @(posedge clk90)
      rst90_r <= rst90;

  //***************************************************************************
  // Analysis of additional pipeline delays:
  //   1. dq_oe (DQ 3-state): 1 CLK90 cyc in IOB 3-state FF
  //   2. dqs_oe (DQS 3-state): 1 CLK180 cyc in IOB 3-state FF
  //   3. dqs_rst (DQS output value reset): 1 CLK180 cyc in FF + 1 CLK180 cyc
  //      in IOB DDR
  //   4. odt (ODT control): 1 CLK0 cyc in IOB FF
  //   5. write data (output two cyc after wdf_rden - output of RAMB_FIFO w/
  //      output register enabled): 2 CLK90 cyc in OSERDES
  //***************************************************************************

  // DQS 3-state must be asserted one extra clock cycle due b/c of write
  // pre- and post-amble (extra half clock cycle for each)
  assign dqs_oe_0 = wr_stages[WR_LATENCY-1] | wr_stages[WR_LATENCY-2];

  // same goes for ODT, need to handle both pre- and post-amble (generate
  // ODT only for DDR2)
  // ODT generation for DDR2 based on write latency. The MIN write
  // latency is 2. Based on the write latency ODT is asserted.
  generate
    if ((DDR_TYPE != DDR1) && (ODT_TYPE > 0))begin: gen_odt_ddr2
       if(ODT_WR_LATENCY > 3)
         assign odt_0 =
                   wr_stages[ODT_WR_LATENCY-2] |
                   wr_stages[ODT_WR_LATENCY-3] |
                   wr_stages[ODT_WR_LATENCY-4] ;
       else if ( ODT_WR_LATENCY == 3)
         assign odt_0 =
                   wr_stages[ODT_WR_LATENCY-1] |
                   wr_stages[ODT_WR_LATENCY-2] |
                   wr_stages[ODT_WR_LATENCY-3] ;
       else
         assign odt_0 =
                  wr_stages[ODT_WR_LATENCY] |
                  wr_stages[ODT_WR_LATENCY-1] |
                  wr_stages[ODT_WR_LATENCY-2] ;
    end else
      assign odt_0 = 1'b0;
   endgenerate

  assign dq_oe_0[0]   = wr_stages[WR_LATENCY-1] | wr_stages[WR_LATENCY];
  assign dq_oe_0[1]   = wr_stages[WR_LATENCY-1] | wr_stages[WR_LATENCY-2];
  assign dqs_rst_0    = ~wr_stages[WR_LATENCY-2];
  assign dm_ce_0      = wr_stages[WR_LATENCY] | wr_stages[WR_LATENCY-1]
                        | wr_stages[WR_LATENCY-2];

  // write data fifo, read flag assertion
  generate
    if (DDR_TYPE != DDR1) begin: gen_wdf_ddr2
      if (WR_LATENCY > 2)
        assign wdf_rden_0 = wr_stages[WR_LATENCY-3];
      else
        assign wdf_rden_0 = wr_stages[WR_LATENCY-2];
    end else begin: gen_wdf_ddr1
      assign wdf_rden_0 = wr_stages[WR_LATENCY-2];
    end
  endgenerate

  // first stage isn't registered
  always @(*)
    wr_stages[0] = (phy_init_data_sel) ? ctrl_wren : phy_init_wren;

  always @(posedge clk0) begin
    wr_stages[1] <= wr_stages[0];
    wr_stages[2] <= wr_stages[1];
    wr_stages[3] <= wr_stages[2];
    wr_stages[4] <= wr_stages[3];
    wr_stages[5] <= wr_stages[4];
    wr_stages[6] <= wr_stages[5];
    wr_stages[7] <= wr_stages[6];
    wr_stages[8] <= wr_stages[7];
    wr_stages[9] <= wr_stages[8];
    wr_stages[10] <= wr_stages[9];
  end

  // intermediate synchronization to CLK270
  always @(negedge clk90) begin
    dq_oe_270         <= dq_oe_0;
    dqs_oe_270        <= dqs_oe_0;
    dqs_rst_270       <= dqs_rst_0;
    wdf_rden_270      <= wdf_rden_0;
  end

  // synchronize DQS signals to CLK180
  always @(negedge clk0) begin
    dqs_oe_n_180_r1  <= ~dqs_oe_270;
    dqs_rst_n_180_r1 <= ~dqs_rst_270;
  end

  // All write data-related signals synced to CLK90
  always @(posedge clk90) begin
    dq_oe_n_90_r1  <= ~dq_oe_270;
    wdf_rden_90_r  <= wdf_rden_270;
  end

  // generate for wdf_rden and calib rden. These signals
  // are asserted based on write latency. For write
  // latency of 2, the extra register stage is taken out.
  generate
   if (WR_LATENCY > 2) begin
     always @(posedge clk90) begin
        // assert wdf rden only for non calibration opertations
        wdf_rden_90_r1 <=  wdf_rden_90_r &
                           phy_init_data_sel;
        // rden for calibration
        calib_rden_90_r <= wdf_rden_90_r;
     end
   end else begin
     always @(*) begin
        wdf_rden_90_r1 = wdf_rden_90_r
                         & phy_init_data_sel;
        calib_rden_90_r = wdf_rden_90_r;
     end
  end // else: !if(WR_LATENCY > 2)
  endgenerate

  // dm CE signal to stop dm oscilation
  always @(negedge clk90)begin
    dm_ce_r <= dm_ce_0;
    dm_ce <= dm_ce_r;
  end

  // When in ECC mode the upper byte [71:64] will have the
  // ECC parity. Mapping the bytes which have valid data
  // to the upper byte in ecc mode. Also in ecc mode there
  // is an extra register stage to account for timing.

  genvar mask_i;
  generate
    if(ECC_ENABLE) begin
      for (mask_i  = 0; mask_i < (2*DQ_WIDTH)/72;
          mask_i = mask_i+1) begin: gen_mask
       assign wdf_ecc_mask[((mask_i*9)+9)-1:(mask_i*9)] =
                {&wdf_mask_data[(mask_i*8)+(7+mask_i):mask_i*9],
                wdf_mask_data[(mask_i*8)+(7+mask_i):mask_i*9]};
      end
    end
   endgenerate

  generate
    if (ECC_ENABLE) begin:gen_ecc_reg
       always @(posedge clk90)begin
          if(phy_init_data_sel)
               wdf_mask_r <= wdf_ecc_mask;
          else
             wdf_mask_r <= {(2*DQ_WIDTH/8){1'b0}};
      end       
    end else begin
      always@(posedge clk90) begin
        if (phy_init_data_sel)
          wdf_mask_r <= wdf_mask_data;
        else
          wdf_mask_r <= {(2*DQ_WIDTH/8){1'b0}};
      end
    end
  endgenerate

   always @(posedge clk90) begin
      if(phy_init_data_sel)
          wdf_data_r <= wdf_data;
      else
          wdf_data_r <={init_data_f,init_data_r};
   end

  // Error generation block during simulation.
  // Error will be displayed when all the DM
  // bits are not zero. The error will be
  // displayed only during the start of the sequence
  // for errors that are continous over many cycles.
  generate
    if (ECC_ENABLE) begin: gen_ecc_error
      always @(posedge clk90) begin
        //synthesis translate_off
        wdf_mask_r1 <= wdf_mask_r;
        if(DQ_WIDTH > 72)
           ecc_dm_error_r
              <= (
              (~wdf_mask_r1[35] && (|wdf_mask_r1[34:27])) ||
              (~wdf_mask_r1[26] && (|wdf_mask_r1[25:18])) ||
              (~wdf_mask_r1[17] && (|wdf_mask_r1[16:9])) ||
              (~wdf_mask_r1[8] &&  (|wdf_mask_r1[7:0]))) && phy_init_data_sel;
         else
            ecc_dm_error_r
              <= ((~wdf_mask_r1[17] && (|wdf_mask_r1[16:9])) ||
              (~wdf_mask_r1[8] &&  (|wdf_mask_r1[7:0]))) && phy_init_data_sel;
        ecc_dm_error_r1 <= ecc_dm_error_r ;
        if (ecc_dm_error_r && ~ecc_dm_error_r1) // assert the error only once.
          $display ("ECC DM ERROR. ");
        //synthesis translate_on
      end
    end
  endgenerate

  //***************************************************************************
  // State logic to write calibration training patterns
  //***************************************************************************

  always @(posedge clk90) begin
    if (rst90_r) begin
      init_wdf_cnt_r  <= 4'd0;
      init_data_r <= {64{1'bx}};
      init_data_f <= {64{1'bx}};
    end else begin
      init_wdf_cnt_r  <= init_wdf_cnt_r + calib_rden_90_r;
      casex (init_wdf_cnt_r)
        // First stage calibration. Pattern (rise/fall) = 1(r)->0(f)
        // The rise data and fall data are already interleaved in the manner
        // required for data into the WDF write FIFO
        4'b00xx: begin
          init_data_r <= {DQ_WIDTH{1'b1}};
          init_data_f <= {DQ_WIDTH{1'b0}};
        end
        // Second stage calibration. Pattern = 1(r)->1(f)->0(r)->0(f)
        4'b01x0: begin
           init_data_r <= {DQ_WIDTH{1'b1}};
           init_data_f <= {DQ_WIDTH{1'b1}};
          end
        4'b01x1: begin
           init_data_r <= {DQ_WIDTH{1'b0}};
           init_data_f <= {DQ_WIDTH{1'b0}};
        end
        // MIG 3.2: Changed Stage 3/4 training pattern
        // Third stage calibration patern = 
        //   11(r)->ee(f)->ee(r)->11(f)-ee(r)->11(f)->ee(r)->11(f)
        4'b1000: begin
          init_data_r <= {DQ_WIDTH/4{4'h1}};
          init_data_f <= {DQ_WIDTH/4{4'hE}};
        end
        4'b1001: begin
          init_data_r <= {DQ_WIDTH/4{4'hE}};
          init_data_f <= {DQ_WIDTH/4{4'h1}};
          end
        4'b1010: begin
          init_data_r <= {(DQ_WIDTH/4){4'hE}};
          init_data_f <= {(DQ_WIDTH/4){4'h1}};
        end
        4'b1011: begin
          init_data_r <= {(DQ_WIDTH/4){4'hE}};
          init_data_f <= {(DQ_WIDTH/4){4'h1}};
        end
        // Fourth stage calibration patern = 
        //   11(r)->ee(f)->ee(r)->11(f)-11(r)->ee(f)->ee(r)->11(f)
        4'b1100: begin
          init_data_r <= {DQ_WIDTH/4{4'h1}};
          init_data_f <= {DQ_WIDTH/4{4'hE}};
        end
        4'b1101: begin
          init_data_r <= {DQ_WIDTH/4{4'hE}};
          init_data_f <= {DQ_WIDTH/4{4'h1}};
          end
        4'b1110: begin
          init_data_r <= {(DQ_WIDTH/4){4'h1}};
          init_data_f <= {(DQ_WIDTH/4){4'hE}};
        end
        4'b1111: begin
          // MIG 3.5: Corrected last two writes for stage 4 calibration
          // training pattern. Previously MIG 3.3 and MIG 3.4 had the
          // incorrect pattern. This can sometimes result in a calibration
          // point with small timing margin. 
//          init_data_r <= {(DQ_WIDTH/4){4'h1}};
//          init_data_f <= {(DQ_WIDTH/4){4'hE}};
          init_data_r <= {(DQ_WIDTH/4){4'hE}};
          init_data_f <= {(DQ_WIDTH/4){4'h1}};
        end
      endcase
    end
  end

  //***************************************************************************

  always @(posedge clk90)
    dq_oe_n   <= dq_oe_n_90_r1;

  always @(negedge clk0)
    dqs_oe_n  <= dqs_oe_n_180_r1;

  always @(negedge clk0)
    dqs_rst_n <= dqs_rst_n_180_r1;

  // generate for odt. odt is asserted based on
  //  write latency. For write latency of 2
  //  the extra register stage is taken out.
  generate
    if (ODT_WR_LATENCY > 3) begin
      always @(posedge clk0) begin
        odt    <= 'b0;
        odt[0] <= odt_0;
      end
    end else begin
      always @ (*) begin
        odt = 'b0;
        odt[0] = odt_0;
      end
    end
  endgenerate

  assign wdf_rden  = wdf_rden_90_r1;

  //***************************************************************************
  // Format write data/mask: Data is in format: {fall, rise}
  //***************************************************************************

  assign wr_data_rise = wdf_data_r[DQ_WIDTH-1:0];
  assign wr_data_fall = wdf_data_r[(2*DQ_WIDTH)-1:DQ_WIDTH];
  assign mask_data_rise = wdf_mask_r[MASK_WIDTH-1:0];
  assign mask_data_fall = wdf_mask_r[(2*MASK_WIDTH)-1:MASK_WIDTH];

endmodule
