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
//  /   /         Filename: ddr2_usr_rd.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Tue Aug 29 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   The delay between the read data with respect to the command issued is
//   calculted in terms of no. of clocks. This data is then stored into the
//   FIFOs and then read back and given as the ouput for comparison.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_rd #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter DQ_PER_DQS    = 8,
   parameter DQS_WIDTH     = 9,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_WIDTH     = 72,
   parameter ECC_ENABLE    = 0
   )
  (
   input                                    clk0,
   input                                    rst0,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]       rd_data_in_rise,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]       rd_data_in_fall,
   input [DQS_WIDTH-1:0]                    ctrl_rden,
   input [DQS_WIDTH-1:0]                    ctrl_rden_sel,
   output reg [1:0]                         rd_ecc_error,
   output                                   rd_data_valid,
   output reg [(APPDATA_WIDTH/2)-1:0]       rd_data_out_rise,
   output reg [(APPDATA_WIDTH/2)-1:0]       rd_data_out_fall
   );

  // determine number of FIFO72's to use based on data width
  localparam RDF_FIFO_NUM = ((APPDATA_WIDTH/2)+63)/64;

  reg [DQS_WIDTH-1:0]               ctrl_rden_r;
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] fall_data;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0]  rd_data_in_fall_r;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0]  rd_data_in_rise_r;
  wire                              rden;
  reg [DQS_WIDTH-1:0]               rden_sel_r
                                    /* synthesis syn_preserve=1 */;
  wire [DQS_WIDTH-1:0]              rden_sel_mux;
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] rise_data;

  // ECC specific signals
  wire [((RDF_FIFO_NUM -1) *2)+1:0] db_ecc_error;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0]  fall_data_r;
  reg                               fifo_rden_r0;
  reg                               fifo_rden_r1;
  reg                               fifo_rden_r2;
  reg                               fifo_rden_r3;
  reg                               fifo_rden_r4;
  reg                               fifo_rden_r5;
  reg                               fifo_rden_r6;
  wire [(APPDATA_WIDTH/2)-1:0]      rd_data_out_fall_temp;
  wire [(APPDATA_WIDTH/2)-1:0]      rd_data_out_rise_temp;
  reg                               rst_r;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0]  rise_data_r;
  wire [((RDF_FIFO_NUM -1) *2)+1:0] sb_ecc_error;


  //***************************************************************************

  always @(posedge clk0) begin
    rden_sel_r        <= ctrl_rden_sel;
    ctrl_rden_r       <= ctrl_rden;
    rd_data_in_rise_r <= rd_data_in_rise;
    rd_data_in_fall_r <= rd_data_in_fall;
  end

  // Instantiate primitive to allow this flop to be attached to multicycle
  // path constraint in UCF. Multicycle path allowed for data from read FIFO.
  // This is the same signal as RDEN_SEL_R, but is only used to select data
  // (does not affect control signals)
  genvar rd_i;
  generate
    for (rd_i = 0; rd_i < DQS_WIDTH; rd_i = rd_i+1) begin: gen_rden_sel_mux
      FDRSE u_ff_rden_sel_mux
        (
         .Q   (rden_sel_mux[rd_i]),
         .C   (clk0),
         .CE  (1'b1),
         .D   (ctrl_rden_sel[rd_i]),
         .R   (1'b0),
         .S   (1'b0)
         ) /* synthesis syn_preserve=1 */;
    end
  endgenerate

  // determine correct read data valid signal timing
  assign rden = (rden_sel_r[0]) ? ctrl_rden[0] : ctrl_rden_r[0];

  // assign data based on the skew
  genvar data_i;
  generate
    for(data_i = 0; data_i < DQS_WIDTH; data_i = data_i+1) begin: gen_data
      assign rise_data[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1):
                       (data_i*DQ_PER_DQS)]
               = (rden_sel_mux[data_i]) ?
                 rd_data_in_rise[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1) :
                                 (data_i*DQ_PER_DQS)] :
                 rd_data_in_rise_r[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1):
                                   (data_i*DQ_PER_DQS)];
       assign fall_data[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1):
                        (data_i*DQ_PER_DQS)]
                = (rden_sel_mux[data_i]) ?
                  rd_data_in_fall[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1):
                                  (data_i*DQ_PER_DQS)] :
                  rd_data_in_fall_r[(data_i*DQ_PER_DQS)+(DQ_PER_DQS-1):
                                    (data_i*DQ_PER_DQS)];
    end
  endgenerate

  // Generate RST for FIFO reset AND for read/write enable:
  // ECC FIFO always being read from and written to
  always @(posedge clk0)
    rst_r <= rst0;

  genvar rdf_i;
  generate
    if (ECC_ENABLE) begin
      always @(posedge clk0) begin
        rd_ecc_error[0]   <= (|sb_ecc_error) & fifo_rden_r5;
        rd_ecc_error[1]   <= (|db_ecc_error) & fifo_rden_r5;
        rd_data_out_rise  <= rd_data_out_rise_temp;
        rd_data_out_fall  <= rd_data_out_fall_temp;
        rise_data_r       <= rise_data;
        fall_data_r       <= fall_data;
      end

      // can use any of the read valids, they're all delayed by same amount
      assign rd_data_valid = fifo_rden_r6;

      // delay read valid to take into account max delay difference btw
      // the read enable coming from the different DQS groups
      always @(posedge clk0) begin
        if (rst0) begin
          fifo_rden_r0 <= 1'b0;
          fifo_rden_r1 <= 1'b0;
          fifo_rden_r2 <= 1'b0;
          fifo_rden_r3 <= 1'b0;
          fifo_rden_r4 <= 1'b0;
          fifo_rden_r5 <= 1'b0;
          fifo_rden_r6 <= 1'b0;
        end else begin
          fifo_rden_r0 <= rden;
          fifo_rden_r1 <= fifo_rden_r0;
          fifo_rden_r2 <= fifo_rden_r1;
          fifo_rden_r3 <= fifo_rden_r2;
          fifo_rden_r4 <= fifo_rden_r3;
          fifo_rden_r5 <= fifo_rden_r4;
          fifo_rden_r6 <= fifo_rden_r5;
        end
      end

      for (rdf_i = 0; rdf_i < RDF_FIFO_NUM; rdf_i = rdf_i + 1) begin: gen_rdf

        FIFO36_72  # // rise fifo
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          // extra CC output delay
           .EN_ECC_WRITE            ("FALSE"),
           .EN_ECC_READ             ("TRUE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_rdf
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (),
             .DBITERR     (db_ecc_error[rdf_i + rdf_i]),
             .DO          (rd_data_out_rise_temp[(64*(rdf_i+1))-1:
                                                 (64 *rdf_i)]),
             .DOP         (),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (sb_ecc_error[rdf_i + rdf_i]),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (rise_data_r[((64*(rdf_i+1)) + (rdf_i*8))-1:
                                       (64 *rdf_i)+(rdf_i*8)]),
             .DIP         (rise_data_r[(72*(rdf_i+1))-1:
                                       (64*(rdf_i+1))+ (8*rdf_i)]),
             .RDCLK       (clk0),
             .RDEN        (~rst_r),
             .RST         (rst_r),
             .WRCLK       (clk0),
             .WREN        (~rst_r)
             );

        FIFO36_72  # // fall_fifo
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          // extra CC output delay
           .EN_ECC_WRITE            ("FALSE"),
           .EN_ECC_READ             ("TRUE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_rdf1
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (),
             .DBITERR     (db_ecc_error[(rdf_i+1) + rdf_i]),
             .DO          (rd_data_out_fall_temp[(64*(rdf_i+1))-1:
                                                 (64 *rdf_i)]),
             .DOP         (),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (sb_ecc_error[(rdf_i+1) + rdf_i]),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (fall_data_r[((64*(rdf_i+1)) + (rdf_i*8))-1:
                                       (64*rdf_i)+(rdf_i*8)]),
             .DIP         (fall_data_r[(72*(rdf_i+1))-1:
                                       (64*(rdf_i+1))+ (8*rdf_i)]),
             .RDCLK       (clk0),
             .RDEN        (~rst_r),
             .RST         (rst_r),          // or can use rst0
             .WRCLK       (clk0),
             .WREN        (~rst_r)
             );
      end
    end else begin
      assign rd_data_valid = fifo_rden_r0;
      always @(posedge clk0) begin
        rd_data_out_rise <= rise_data;
        rd_data_out_fall <= fall_data;
        fifo_rden_r0 <= rden;
      end
    end
  endgenerate

endmodule
