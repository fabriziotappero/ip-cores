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
//  /   /         Filename: ddr2_phy_dq_iob.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module places the data in the IOBs.
//Reference:
//Revision History:
//   Rev 1.1 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.2 - DIRT strings removed and modified the code. PK. 11/13/08
//   Rev 1.3 - Parameter IODELAY_GRP added and constraint IODELAY_GROUP added
//             on IODELAY primitive. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_dq_iob #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG",
   parameter FPGA_SPEED_GRADE      = 2
   )
  (
   input        clk0,
   input        clk90,
   input        clkdiv0,
   input        rst90,
   input        dlyinc,
   input        dlyce,
   input        dlyrst,
   input  [1:0] dq_oe_n,
   input        dqs,
   input        ce,
   input        rd_data_sel,
   input        wr_data_rise,
   input        wr_data_fall,
   output       rd_data_rise,
   output       rd_data_fall,
   inout        ddr_dq
   );

  wire       dq_iddr_clk;
  wire       dq_idelay;
  wire       dq_in;
  wire       dq_oe_n_r;
  wire       dq_out;
  wire       stg2a_out_fall;
  wire       stg2a_out_rise;
  (* XIL_PAR_DELAY = "0 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire       stg2b_out_fall;
  (* XIL_PAR_DELAY = "0 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire       stg2b_out_rise;
  wire       stg3a_out_fall;
  wire       stg3a_out_rise;
  wire       stg3b_out_fall;
  wire       stg3b_out_rise;

  //***************************************************************************
  // Directed routing constraints for route between IDDR and stage 2 capture
  // in fabric.
  // Only 2 out of the 12 wire declarations will be used for any given
  // instantiation of this module.
  // Varies according:
  //  (1) I/O column (left, center, right) used
  //  (2) Which I/O in I/O pair (master, slave) used
  // Nomenclature: _Xy, X = column (0 = left, 1 = center, 2 = right),
  //  y = master or slave
  //***************************************************************************

  // MODIFIED, RC, 06/13/08: Remove all references to DIRT, master/slave

  (* XIL_PAR_DELAY = "515 ps", XIL_PAR_SKEW = "55 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_rise_sg3;
  (* XIL_PAR_DELAY = "515 ps", XIL_PAR_SKEW = "55 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_fall_sg3;
  (* XIL_PAR_DELAY = "575 ps", XIL_PAR_SKEW = "65 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_rise_sg2;
  (* XIL_PAR_DELAY = "575 ps", XIL_PAR_SKEW = "65 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_fall_sg2;
  (* XIL_PAR_DELAY = "650 ps", XIL_PAR_SKEW = "70 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_rise_sg1;
  (* XIL_PAR_DELAY = "650 ps", XIL_PAR_SKEW = "70 ps", XIL_PAR_IP_NAME = "MIG", syn_keep = "1", keep = "TRUE" *)
  wire stg1_out_fall_sg1;

  //***************************************************************************
  // Bidirectional I/O
  //***************************************************************************

  IOBUF u_iobuf_dq
    (
     .I  (dq_out),
     .T  (dq_oe_n_r),
     .IO (ddr_dq),
     .O  (dq_in)
     );

  //***************************************************************************
  // Write (output) path
  //***************************************************************************

  // on a write, rising edge of DQS corresponds to rising edge of CLK180
  // (aka falling edge of CLK0 -> rising edge DQS). We also know:
  //  1. data must be driven 1/4 clk cycle before corresponding DQS edge
  //  2. first rising DQS edge driven on falling edge of CLK0
  //  3. rising data must be driven 1/4 cycle before falling edge of CLK0
  //  4. therefore, rising data driven on rising edge of CLK
  ODDR #
    (
     .SRTYPE("SYNC"),
     .DDR_CLK_EDGE("SAME_EDGE")
     )
    u_oddr_dq
      (
       .Q  (dq_out),
       .C  (clk90),
       .CE (1'b1),
       .D1 (wr_data_rise),
       .D2 (wr_data_fall),
       .R  (1'b0),
       .S  (1'b0)
       );

  // make sure output is tri-state during reset (DQ_OE_N_R = 1)
  ODDR #
    (
     .SRTYPE("ASYNC"),
     .DDR_CLK_EDGE("SAME_EDGE")
     )
    u_tri_state_dq
      (
       .Q  (dq_oe_n_r),
       .C  (clk90),
       .CE (1'b1),
       .D1 (dq_oe_n[0]),
       .D2 (dq_oe_n[1]),
       .R  (1'b0),
       .S  (rst90)
       );

  //***************************************************************************
  // Read data capture scheme description:
  // Data capture consists of 3 ranks of flops, and a MUX
  //  1. Rank 1 ("Stage 1"): IDDR captures delayed DDR DQ from memory using
  //     delayed DQS.
  //     - Data is split into 2 SDR streams, one each for rise and fall data.
  //     - BUFIO (DQS) input inverted to IDDR. IDDR configured in SAME_EDGE
  //       mode. This means that: (1) Q1 = fall data, Q2 = rise data,
  //       (2) Both rise and fall data are output on falling edge of DQS -
  //       rather than rise output being output on one edge of DQS, and fall
  //       data on the other edge if the IDDR were configured in OPPOSITE_EDGE
  //       mode. This simplifies Stage 2 capture (only one core clock edge
  //       used, removing effects of duty-cycle-distortion), and saves one
  //       fabric flop in Rank 3.
  //  2. Rank 2 ("Stage 2"): Fabric flops are used to capture output of first
  //     rank into FPGA clock (CLK) domain. Each rising/falling SDR stream
  //     from IDDR is feed into two flops, one clocked off rising and one off
  //     falling edge of CLK. One of these flops is chosen, with the choice
  //     being the one that reduces # of DQ/DQS taps necessary to align Stage
  //     1 and Stage 2. Same edge is used to capture both rise and fall SDR
  //     streams.
  //  3. Rank 3 ("Stage 3"): Removes half-cycle paths in CLK domain from
  //     output of Rank 2. This stage, like Stage 2, is clocked by CLK. Note
  //     that Stage 3 can be expanded to also support SERDES functionality
  //  4. Output MUX: Selects whether Stage 1 output is aligned to rising or
  //     falling edge of CLK (i.e. specifically this selects whether IDDR
  //     rise/fall output is transfered to rising or falling edge of CLK).
  // Implementation:
  //  1. Rank 1 is implemented using an IDDR primitive
  //  2. Rank 2 is implemented using:
  //     - An RPM to fix the location of the capture flops near the DQ I/O.
  //       The exact RPM used depends on which I/O column (left, center,
  //       right) the DQ I/O is placed at - this affects the optimal location
  //       of the slice flops (or does it - can we always choose the two
  //       columns to slices to the immediate right of the I/O to use, no
  //       matter what the column?). The origin of the RPM must be set in the
  //       UCF file using the RLOC_ORIGIN constraint (where the original is
  //       based on the DQ I/O location).
  //     - Directed Routing Constraints ("DIRT strings") to fix the routing
  //       to the rank 2 fabric flops. This is done to minimize: (1) total
  //       route delay (and therefore minimize voltage/temperature-related
  //       variations), and (2) minimize skew both within each rising and
  //       falling data net, as well as between the rising and falling nets.
  //       The exact DIRT string used depends on: (1) which I/O column the
  //       DQ I/O is placed, and (2) whether the DQ I/O is placed on the
  //       "Master" or "Slave" I/O of a diff pair (DQ is not differential, but
  //       the routing will be affected by which of each I/O pair is used)
  // 3. Rank 3 is implemented using fabric flops. No LOC or DIRT contraints
  //    are used, tools are expected to place these and meet PERIOD timing
  //    without constraints (constraints may be necessary for "full" designs,
  //    in this case, user may need to add LOC constraints - if this is the
  //    case, there are no constraints - other than meeting PERIOD timing -
  //    for rank 3 flops.
  //***************************************************************************

  //***************************************************************************
  // MIG 2.2: Define AREA_GROUP = "DDR_CAPTURE_FFS" contain all RPM flops in
  //          design. In UCF file, add constraint:
  //             AREA_GROUP "DDR_CAPTURE_FFS" GROUP = CLOSED;
  //          This is done to prevent MAP from packing unrelated logic into
  //          the slices used by the RPMs. Doing so may cause the DIRT strings
  //          that define the IDDR -> fabric flop routing to later become
  //          unroutable during PAR because the unrelated logic placed by MAP
  //          may use routing resources required by the DIRT strings. MAP
  //          does not currently take into account DIRT strings when placing
  //          logic
  //***************************************************************************

  // IDELAY to delay incoming data for synchronization purposes
  (* IODELAY_GROUP = IODELAY_GRP *) IODELAY #
    (
     .DELAY_SRC             ("I"),
     .IDELAY_TYPE           ("VARIABLE"),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IDELAY_VALUE          (0),
     .ODELAY_VALUE          (0)
     )
    u_idelay_dq
      (
       .DATAOUT (dq_idelay),
       .C       (clkdiv0),
       .CE      (dlyce),
       .DATAIN  (),
       .IDATAIN (dq_in),
       .INC     (dlyinc),
       .ODATAIN (),
       .RST     (dlyrst),
       .T       ()
       );

  //***************************************************************************
  // Rank 1 capture: Use IDDR to generate two SDR outputs
  //***************************************************************************

  // invert clock to IDDR in order to use SAME_EDGE mode (otherwise, we "run
  // out of clocks" because DQS is not continuous
  assign dq_iddr_clk = ~dqs;

  //***************************************************************************
  // Rank 2 capture: Use fabric flops to capture Rank 1 output. Use RPM and
  // DIRT strings here.
  // BEL ("Basic Element of Logic") and relative location constraints for
  // second stage capture. C
  // Varies according:
  //  (1) I/O column (left, center, right) used
  //  (2) Which I/O in I/O pair (master, slave) used
  //***************************************************************************

  // MODIFIED, RC, 06/13/08: Remove all references to DIRT, master/slave
  //  Take out generate statements - collapses to a single case

  generate
    if (FPGA_SPEED_GRADE == 3) begin: gen_stg2_sg3
      IDDR #
        (
         .DDR_CLK_EDGE ("SAME_EDGE")
         )
        u_iddr_dq
          (
           .Q1 (stg1_out_fall_sg3),
           .Q2 (stg1_out_rise_sg3),
           .C  (dq_iddr_clk),
           .CE (ce),
           .D  (dq_idelay),
           .R  (1'b0),
           .S  (1'b0)
           );

      //*********************************************************
      // Slice #1 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
      //  2. stg2 falling edge -> stg3 rising edge transfer
      //*********************************************************

      // Stage 2 capture
      FDRSE u_ff_stg2a_fall
        (
         .Q   (stg2a_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg3),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg2a_rise
        (
         .Q   (stg2a_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg3),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      // Stage 3 falling -> rising edge translation
      FDRSE u_ff_stg3b_fall
        (
         .Q   (stg3b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_fall),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg3b_rise
        (
         .Q   (stg3b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_rise),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      //*********************************************************
      // Slice #2 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
      //*********************************************************

      FDRSE_1 u_ff_stg2b_fall
        (
         .Q   (stg2b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg3),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      FDRSE_1 u_ff_stg2b_rise
        (
         .Q   (stg2b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg3),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
    end else if (FPGA_SPEED_GRADE == 2) begin: gen_stg2_sg2
      IDDR #
        (
         .DDR_CLK_EDGE ("SAME_EDGE")
         )
        u_iddr_dq
          (
           .Q1 (stg1_out_fall_sg2),
           .Q2 (stg1_out_rise_sg2),
           .C  (dq_iddr_clk),
           .CE (ce),
           .D  (dq_idelay),
           .R  (1'b0),
           .S  (1'b0)
           );

      //*********************************************************
      // Slice #1 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
      //  2. stg2 falling edge -> stg3 rising edge transfer
      //*********************************************************

      // Stage 2 capture
      FDRSE u_ff_stg2a_fall
        (
         .Q   (stg2a_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg2),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg2a_rise
        (
         .Q   (stg2a_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg2),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      // Stage 3 falling -> rising edge translation
      FDRSE u_ff_stg3b_fall
        (
         .Q   (stg3b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_fall),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg3b_rise
        (
         .Q   (stg3b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_rise),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      //*********************************************************
      // Slice #2 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
      //*********************************************************

      FDRSE_1 u_ff_stg2b_fall
        (
         .Q   (stg2b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg2),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      FDRSE_1 u_ff_stg2b_rise
        (
         .Q   (stg2b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg2),
         .R   (1'b0),
         .S   (1'b0)
          )/* synthesis syn_preserve = 1 */
           /* synthesis syn_replicate = 0 */;
    end else if (FPGA_SPEED_GRADE == 1) begin: gen_stg2_sg1
      IDDR #
        (
         .DDR_CLK_EDGE ("SAME_EDGE")
         )
        u_iddr_dq
          (
           .Q1 (stg1_out_fall_sg1),
           .Q2 (stg1_out_rise_sg1),
           .C  (dq_iddr_clk),
           .CE (ce),
           .D  (dq_idelay),
           .R  (1'b0),
           .S  (1'b0)
           );

      //*********************************************************
      // Slice #1 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
      //  2. stg2 falling edge -> stg3 rising edge transfer
      //*********************************************************

      // Stage 2 capture
      FDRSE u_ff_stg2a_fall
        (
         .Q   (stg2a_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg1),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg2a_rise
        (
         .Q   (stg2a_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg1),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      // Stage 3 falling -> rising edge translation
      FDRSE u_ff_stg3b_fall
        (
         .Q   (stg3b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_fall),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
      FDRSE u_ff_stg3b_rise
        (
         .Q   (stg3b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg2b_out_rise),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      //*********************************************************
      // Slice #2 (posedge CLK): Used for:
      //  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
      //*********************************************************

      FDRSE_1 u_ff_stg2b_fall
        (
         .Q   (stg2b_out_fall),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_fall_sg1),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;

      FDRSE_1 u_ff_stg2b_rise
        (
         .Q   (stg2b_out_rise),
         .C   (clk0),
         .CE  (1'b1),
         .D   (stg1_out_rise_sg1),
         .R   (1'b0),
         .S   (1'b0)
         )/* synthesis syn_preserve = 1 */
          /* synthesis syn_replicate = 0 */;
    end
  endgenerate

  //***************************************************************************
  // Second stage flops clocked by posedge CLK0 don't need another layer of
  // registering
  //***************************************************************************

  assign stg3a_out_rise = stg2a_out_rise;
  assign stg3a_out_fall = stg2a_out_fall;

  //*******************************************************************

  assign rd_data_rise = (rd_data_sel) ? stg3a_out_rise : stg3b_out_rise;
  assign rd_data_fall = (rd_data_sel) ? stg3a_out_fall : stg3b_out_fall;

endmodule
