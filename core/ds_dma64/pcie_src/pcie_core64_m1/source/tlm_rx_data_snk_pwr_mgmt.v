
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
// File       : tlm_rx_data_snk_pwr_mgmt.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : Rx Data Sink power management packet interpretation
 *
 *     Hierarchical :
 *
 *     Functional :
 *      Removes power management packets from the stream and signals
 *        sideband to CMM
 *
 ****************************************************************************/
`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif

`ifndef AS
module tlm_rx_data_snk_pwr_mgmt
  (
   input                 clk_i,
   input                 reset_i,

   // Power management signals for CMM
   output reg            pm_as_nak_l1_o,    // Pkt detected, implies src_rdy
   output reg            pm_turn_off_o,     // Pkt detected, implies src_rdy
   output reg            pm_set_slot_pwr_o, // Pkt detected, implies src_rdy
   output reg [9:0]      pm_set_slot_pwr_data_o, // value of field
   output reg            pm_msg_detect_o,   // grabbed a pm signal

   input                 ismsg_i,           // Packet data type
   input [7:0]           msgcode_i,         // message code
   input [9:0]           pwr_data_i,        // set slot value
   input                 eval_pwr_mgmt_i,   // grab the sideband fields
   input                 eval_pwr_mgmt_data_i, // get the data, if it exists
   input                 act_pwr_mgmt_i     // transmit the sideband fields
   );

  //-----------------------------------------------------------------------------
  // PCI Express constants
  //-----------------------------------------------------------------------------
  // Message code
  localparam             PM_ACTIVE_STATE_NAK       = 8'b0001_0100;
  localparam             PME_TURN_OFF              = 8'b0001_1001;
  localparam             SET_SLOT_POWER_LIMIT      = 8'b0101_0000;

  reg                    cur_pm_as_nak_l1;
  reg                    cur_pm_turn_off;
  reg                    cur_pm_set_slot_pwr;

  reg                    eval_pwr_mgmt_q1;
  reg                    eval_pwr_mgmt_data_q1;
  reg                    act_pwr_mgmt_q1;

  reg [9:0]              pm_set_slot_pwr_data_d1;

  // grab the fields at the beginning of the packet when known
  //----------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_pm_as_nak_l1           <= #`TCQ 0;
      cur_pm_turn_off            <= #`TCQ 0;
      cur_pm_set_slot_pwr        <= #`TCQ 0;
    end else if (eval_pwr_mgmt_i) begin
      // ismsg is ANY message - malformed will are another modules
      // problem
      if (ismsg_i) begin
        cur_pm_as_nak_l1         <= #`TCQ (msgcode_i == PM_ACTIVE_STATE_NAK);
        cur_pm_turn_off          <= #`TCQ (msgcode_i == PME_TURN_OFF);
        cur_pm_set_slot_pwr      <= #`TCQ (msgcode_i == SET_SLOT_POWER_LIMIT);

      // if we aren't a mesg, these can't be true
      end else begin
        cur_pm_as_nak_l1         <= #`TCQ 0;
        cur_pm_turn_off          <= #`TCQ 0;
        cur_pm_set_slot_pwr      <= #`TCQ 0;
      end
    end
  end

  // We need to know which packets we're dropping because we're
  //   already signalling them sideband
  // pipelined due to timing
  //------------------------------------------------------
  always @(posedge clk_i) begin
    if (reset_i) begin
      pm_msg_detect_o            <= #`TCQ 0;
    end else if (eval_pwr_mgmt_q1) begin
      pm_msg_detect_o            <= #`TCQ cur_pm_as_nak_l1 ||
                                          cur_pm_turn_off  ||
                                          cur_pm_set_slot_pwr;
    end
  end


  // Data comes two cycles after the header fields, so we can't
  //   share the input latching fields
  // Furthermore, it will not go away until after eof_q2, so we
  //   can cheat on registers
  // Lastly, it does not imply activation, so we can always grab
  //   the field
  //-----------------------------------------------------------
  always @(posedge clk_i) begin
    if (eval_pwr_mgmt_data_i) begin
      pm_set_slot_pwr_data_d1 <= #`TCQ pwr_data_i;
    end
    if (eval_pwr_mgmt_data_q1) begin
      pm_set_slot_pwr_data_o  <= #`TCQ pm_set_slot_pwr_data_d1;
    end
  end

  // transmit sidebands when we know they are good for
  //   one cycle only
  always @(posedge clk_i) begin
    if (reset_i) begin
      pm_as_nak_l1_o         <= #`TCQ 0;
      pm_turn_off_o          <= #`TCQ 0;
      pm_set_slot_pwr_o      <= #`TCQ 0;
    // at this point, we know the packet is valid
    end else if (act_pwr_mgmt_i) begin
      pm_as_nak_l1_o         <= #`TCQ cur_pm_as_nak_l1;
      pm_turn_off_o          <= #`TCQ cur_pm_turn_off;
      pm_set_slot_pwr_o      <= #`TCQ cur_pm_set_slot_pwr;
    // implies src_rdy, return to zero
    end else if (act_pwr_mgmt_q1) begin
      pm_as_nak_l1_o         <= #`TCQ 0;
      pm_turn_off_o          <= #`TCQ 0;
      pm_set_slot_pwr_o      <= #`TCQ 0;
    end
  end

  // Also need delayed version
  always @(posedge clk_i) begin
    if (reset_i) begin
      eval_pwr_mgmt_q1           <= #`TCQ 0;
      eval_pwr_mgmt_data_q1      <= #`TCQ 0;
      act_pwr_mgmt_q1            <= #`TCQ 0;
    end else begin
      eval_pwr_mgmt_q1           <= #`TCQ eval_pwr_mgmt_i;
      eval_pwr_mgmt_data_q1      <= #`TCQ eval_pwr_mgmt_data_i;
      act_pwr_mgmt_q1            <= #`TCQ act_pwr_mgmt_i;
    end
  end

endmodule
`endif
