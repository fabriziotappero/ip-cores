
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : tlm_rx_data_snk_bar.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : Rx Data Sink bar hit communication
 *
 *     Hierarchical :
 *
 *     Functional :
 *      Contructs the bar check fields, and passes hit information on
 *
 ****************************************************************************/
`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif

`ifndef AS
module tlm_rx_data_snk_bar #(
  parameter             DW = 32,        // Data width
  parameter             BARW = 7)       // BAR-hit width
 (
  input                 clk_i,
  input                 reset_i,

  output reg [63:0]     check_raddr_o,
  output reg            check_rmem32_o,
  output reg            check_rmem64_o,
  output reg            check_rio_o,
  output reg            check_rdev_id_o,
  output reg            check_rbus_id_o,
  output reg            check_rfun_id_o,
  input  [BARW-1:0]     check_rhit_bar_i,
  input                 check_rhit_i,
  output [BARW-1:0]     check_rhit_bar_o,
  output                check_rhit_o,
  output                check_rhit_src_rdy_o,
  output                check_rhit_ack_o,
  output                check_rhit_lock_o,

  input [31:0]          addr_lo_i,      // 32b addr high word
  input [31:0]          addr_hi_i,      // 32b addr high word
  input [8:0]           fulltype_oh_i,  // Packet data type
  input [2:0]           routing_i,      // routing
  input                 mem64_i,        // 64b memory access?
  input [15:0]          req_id_i,       // requester ID
  input [15:0]          req_id_cpl_i,   // req ID when pkt == cpl
  input                 eval_check_i,   // latch the formatting check
  input                 rhit_lat3_i,    // Is BAR-hit latency 3 clocks?
  input                 legacy_mode_i
  );

  localparam            CHECK_IO_BAR_HIT_EN = 1'b1;

  //---------------------------------------------------------------------------
  // PCI Express constants
  //---------------------------------------------------------------------------
  // Bit taps for one-hot Full Type
  localparam    MEM_BIT   = 8;
  localparam    ADR_BIT   = 7;
  localparam    MRD_BIT   = 6;
  localparam    MWR_BIT   = 5;
  localparam    MLK_BIT   = 4;
  localparam    IO_BIT    = 3;
  localparam    CFG_BIT   = 2;
  localparam    MSG_BIT   = 1;
  localparam    CPL_BIT   = 0;

  // Route
  localparam    ROUTE_BY_ID = 3'b010;

  wire [63:0]   addr_64b = {addr_hi_i, addr_lo_i};

  reg [63:0]    check_raddr_d;
  reg           check_rmem32_d;
  reg           check_rmem64_d;
  reg           check_rmemlock_d;
  reg           check_rmemlock_d1a;
  reg           check_rio_d;
  reg           check_rdev_id_d;
  reg           check_rbus_id_d;
  reg           check_rfun_id_d;


  reg           eval_check_q1, eval_check_q2, eval_check_q3, eval_check_q4;
  reg                          sent_check_q2, sent_check_q3, sent_check_q4;
  reg           lock_check_q2, lock_check_q3, lock_check_q4;

  // Check if endpoint is the correct recipient
  //---------------------------------------------------------------------------
  // On every request received, except implicitly routed messages, check if:
  // 1. the endpoint is the right recipient by passing to the CMM for checking:
  //    . for Mem, IO and Cfg: the destination addr (checked with BARs)
  //    . for Messages:
  //      a. the req_id,  if TLP was routed by ID
  //      b. the address, if TLP was routed by addr
  //      c. if dest is not RC, the endpoint is the implicit recipient
  //    . for Completions: the req_id
  // 2. the type is valid
  // 3. for Messages: msg_code and routing are valid
  //
  // Since the invalid type won't trigger the 1. check, it will be detected by
  // the non assertion of check_rhit_i by the CMM
  // => check 2. is redundant with check 1.
  //
  // Note: Future possible enhancement
  // . check 3. may also be merged with 1., but that will affect the timing of
  //   the live check_*_o signals provided to the CMM
  //   => to be considered if those outputs get registered
  //
  // No need to check:
  // . silently dropped: Unlock
  // . passed on       : User messages (Vendor_Defined)
  //---------------------------------------------------------------------------

  // Timing is tight here at 250 MHz -> split the calculations out from the CE
  //   and return to 0
  // This also allows for a blocking default assignment, which makes the code
  //   easier to follow
  always @* begin
    check_raddr_d   = (fulltype_oh_i[MSG_BIT] ? {req_id_i,48'h0}     : 0) |
                      (fulltype_oh_i[CPL_BIT] ? {req_id_cpl_i,48'h0} : 0) |
                      (fulltype_oh_i[ADR_BIT] ? addr_64b             : 0);

    check_rbus_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];

    check_rdev_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];

    check_rfun_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];

    check_rmem32_d  =  fulltype_oh_i[MEM_BIT] && !mem64_i;

    check_rmem64_d  =  fulltype_oh_i[MEM_BIT] &&  mem64_i;

    check_rmemlock_d=  fulltype_oh_i[MLK_BIT];

    check_rio_d     =  fulltype_oh_i[IO_BIT] && CHECK_IO_BAR_HIT_EN;

    // No checks on CFG: CMM captures bus and dev ids for that function
  end

  always @(posedge clk_i) begin
    if (eval_check_i) begin
      check_raddr_o     <= #`TCQ check_raddr_d;
    end
  end

  always @(posedge clk_i) begin
    if (reset_i) begin
      check_rmem32_o    <= #`TCQ 0;
      check_rmem64_o    <= #`TCQ 0;
      check_rmemlock_d1a <= #`TCQ 0;
      check_rio_o       <= #`TCQ 0;
      check_rbus_id_o   <= #`TCQ 0;
      check_rdev_id_o   <= #`TCQ 0;
      check_rfun_id_o   <= #`TCQ 0;

    // Our calculation from above is ready
    end else if (eval_check_i) begin
      check_rmem32_o    <= #`TCQ check_rmem32_d;
      check_rmem64_o    <= #`TCQ check_rmem64_d;
      check_rmemlock_d1a <= #`TCQ check_rmemlock_d;
      check_rio_o       <= #`TCQ check_rio_d;
      check_rbus_id_o   <= #`TCQ check_rbus_id_d;
      check_rdev_id_o   <= #`TCQ check_rdev_id_d;
      check_rfun_id_o   <= #`TCQ check_rfun_id_d;

    // these signals all imply src_rdy, return to zero
    end else begin
      check_rmem32_o    <= #`TCQ 0;
      check_rmem64_o    <= #`TCQ 0;
      check_rmemlock_d1a <= #`TCQ 0;
      check_rio_o       <= #`TCQ 0;
      check_rbus_id_o   <= #`TCQ 0;
      check_rdev_id_o   <= #`TCQ 0;
      check_rfun_id_o   <= #`TCQ 0;
    end
  end

  // Need a pipe to time the return back from the CMM, since
  //   32 and 64 signal the CMM to start calculating at
  //   different times
  // Eval is when the check is occuring
  // Sent is if we actually sent one (and expect a response)
  //---------------------------------------------------------
  always @(posedge clk_i) begin
    eval_check_q1       <= #`TCQ eval_check_i;
    eval_check_q2       <= #`TCQ eval_check_q1;
    eval_check_q3       <= #`TCQ eval_check_q2;
    eval_check_q4       <= #`TCQ eval_check_q3;
    sent_check_q2       <= #`TCQ eval_check_q1 &&
                           (check_rmem32_o  ||
                            check_rmem64_o  ||
                            check_rio_o     ||
                            check_rbus_id_o ||
                            check_rdev_id_o ||
                            check_rfun_id_o);
    sent_check_q3       <= #`TCQ sent_check_q2;
    sent_check_q4       <= #`TCQ sent_check_q3;
    lock_check_q2       <= #`TCQ check_rmemlock_d1a;
    lock_check_q3       <= #`TCQ lock_check_q2;
    lock_check_q4       <= #`TCQ lock_check_q3;
  end

  // Values from the CMM
  assign check_rhit_bar_o     = check_rhit_bar_i;
  assign check_rhit_o         = check_rhit_i;
  // Result of our internal timing circuit
  assign check_rhit_src_rdy_o = rhit_lat3_i ? eval_check_q4 : eval_check_q3;
  assign check_rhit_ack_o     = rhit_lat3_i ? sent_check_q4 : sent_check_q3;

  assign check_rhit_lock_o    = rhit_lat3_i ? lock_check_q4 : lock_check_q3;
endmodule
`endif
