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
//  /   /         Filename: ddr2_phy_dqs_iob.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module places the data strobes in the IOBs.
//Reference:
//Revision History:
//   Rev 1.1 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.2 - Parameter IODELAY_GRP added and constraint IODELAY_GROUP added
//             on IODELAY primitives. PK. 11/27/08
//   Rev 1.3 - IDDR primitve (u_iddr_dq_ce) is replaced with a negative-edge
//             triggered flip-flop. PK. 03/20/09
//   Rev 1.4 - To fix CR 540201, S and syn_preserve attributes are added
//             for dqs_oe_n_r. PK. 01/08/10
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_phy_dqs_iob #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter DDR_TYPE              = 1,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG"
   )
  (
   input        clk0,
   input        clkdiv0,
   input        rst0,
   input        dlyinc_dqs,
   input        dlyce_dqs,
   input        dlyrst_dqs,
   input        dlyinc_gate,
   input        dlyce_gate,
   input        dlyrst_gate,
   input        dqs_oe_n,
   input        dqs_rst_n,
   input        en_dqs,
   inout        ddr_dqs,
   inout        ddr_dqs_n,
   output       dq_ce,
   output       delayed_dqs
   );

  wire                     clk180;
  wire                     dqs_bufio;

  wire                     dqs_ibuf;
  wire                     dqs_idelay;
  wire                     dqs_oe_n_delay;
  (* S = "TRUE" *) wire    dqs_oe_n_r /* synthesis syn_preserve = 1*/;
  wire                     dqs_rst_n_delay;
  reg                      dqs_rst_n_r /* synthesis syn_preserve = 1*/;
  wire                     dqs_out;
  wire                     en_dqs_sync /* synthesis syn_keep = 1 */;

  // for simulation only. Synthesis should ignore this delay
  localparam    DQS_NET_DELAY = 0.8;

  assign        clk180 = ~clk0;

  // add delta delay to inputs clocked by clk180 to avoid delta-delay
  // simulation issues
  assign dqs_rst_n_delay = dqs_rst_n;
  assign dqs_oe_n_delay  = dqs_oe_n;

  //***************************************************************************
  // DQS input-side resources:
  //  - IODELAY (pad -> IDELAY)
  //  - BUFIO (IDELAY -> BUFIO)
  //***************************************************************************

  // Route DQS from PAD to IDELAY
  (* IODELAY_GROUP = IODELAY_GRP *) IODELAY #
    (
     .DELAY_SRC("I"),
     .IDELAY_TYPE("VARIABLE"),
     .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
     .IDELAY_VALUE(0),
     .ODELAY_VALUE(0)
     )
    u_idelay_dqs
      (
       .DATAOUT (dqs_idelay),
       .C       (clkdiv0),
       .CE      (dlyce_dqs),
       .DATAIN  (),
       .IDATAIN (dqs_ibuf),
       .INC     (dlyinc_dqs),
       .ODATAIN (),
       .RST     (dlyrst_dqs),
       .T       ()
       );

  // From IDELAY to BUFIO
  BUFIO u_bufio_dqs
    (
     .I  (dqs_idelay),
     .O  (dqs_bufio)
     );

  // To model additional delay of DQS BUFIO + gating network
  // for behavioral simulation. Make sure to select a delay number smaller
  // than half clock cycle (otherwise output will not track input changes
  // because of inertial delay). Duplicate to avoid delta delay issues.
  assign #(DQS_NET_DELAY) i_delayed_dqs = dqs_bufio;
  assign #(DQS_NET_DELAY) delayed_dqs   = dqs_bufio;

  //***************************************************************************
  // DQS gate circuit (not supported for all controllers)
  //***************************************************************************

  // Gate routing:
  //   en_dqs -> IDELAY -> en_dqs_sync -> IDDR.S -> dq_ce ->
  //   capture IDDR.CE

  // Delay CE control so that it's in phase with delayed DQS
  (* IODELAY_GROUP = IODELAY_GRP *) IODELAY #
    (
     .DELAY_SRC             ("DATAIN"),
     .IDELAY_TYPE           ("VARIABLE"),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IDELAY_VALUE          (0),
     .ODELAY_VALUE          (0)
     )
    u_iodelay_dq_ce
      (
       .DATAOUT (en_dqs_sync),
       .C       (clkdiv0),
       .CE      (dlyce_gate),
       .DATAIN  (en_dqs),
       .IDATAIN (),
       .INC     (dlyinc_gate),
       .ODATAIN (),
       .RST     (dlyrst_gate),
       .T       ()
       );

  // Generate sync'ed CE to DQ IDDR's using a negative-edge triggered flip-flop
  // clocked by DQS. This flop should be locked to the IOB flip-flop at the same
  // site as IODELAY u_idelay_dqs in order to use the dedicated route from
  // the IODELAY to flip-flop (to keep this route as short as possible)
  (* IOB = "FORCE" *) FDCPE_1 #
    (
     .INIT(1'b0)
    )
    u_iddr_dq_ce
      (
       .Q   (dq_ce),
       .C   (i_delayed_dqs),
       .CE  (1'b1),
       .CLR (1'b0),
       .D   (en_dqs_sync),
       .PRE (en_dqs_sync)
       ) /* synthesis syn_useioff = 1 */
         /* synthesis syn_replicate = 0 */;

  //***************************************************************************
  // DQS output-side resources
  //***************************************************************************

  // synthesis attribute keep of dqs_rst_n_r is "true"
  always @(posedge clk180)
    dqs_rst_n_r <= dqs_rst_n_delay;

  ODDR #
    (
     .SRTYPE("SYNC"),
     .DDR_CLK_EDGE("OPPOSITE_EDGE")
     )
    u_oddr_dqs
      (
       .Q  (dqs_out),
       .C  (clk180),
       .CE (1'b1),
       .D1 (dqs_rst_n_r),      // keep output deasserted for write preamble
       .D2 (1'b0),
       .R  (1'b0),
       .S  (1'b0)
       );

  (* IOB = "FORCE" *) FDP u_tri_state_dqs
    (
     .D   (dqs_oe_n_delay),
     .Q   (dqs_oe_n_r),
     .C   (clk180),
     .PRE (rst0)
     ) /* synthesis syn_useioff = 1 */;

  //***************************************************************************

  // use either single-ended (for DDR1) or differential (for DDR2) DQS input

  generate
    if (DDR_TYPE > 0) begin: gen_dqs_iob_ddr2
      IOBUFDS u_iobuf_dqs
        (
         .O   (dqs_ibuf),
         .IO  (ddr_dqs),
         .IOB (ddr_dqs_n),
         .I   (dqs_out),
         .T   (dqs_oe_n_r)
         );
    end else begin: gen_dqs_iob_ddr1
      IOBUF u_iobuf_dqs
        (
         .O   (dqs_ibuf),
         .IO  (ddr_dqs),
         .I   (dqs_out),
         .T   (dqs_oe_n_r)
         );
    end
  endgenerate

endmodule
