
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
// File       : pcie_blk_ll_tx_arb.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/*****************************************************************************
 *  Description : PCIe Block Plus Tx Arbiter - multiplexes input to the
 *    PCIE Block between the user input and bridge-generated traffic (such
 *    as interrupts and config TLPs)
 ****************************************************************************/

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

module pcie_blk_ll_tx_arb
  (
   // Clock and reset

   input             clk,
   input             rst_n,

   // Transaction Link Up

//   input             trn_lnk_up_n,  // Might need this for discontinue

   // Tx Bridge Ports
   output reg [63:0] tx_td,
   output reg        tx_sof_n,
   output reg        tx_eof_n,
   output [7:0]      tx_rem_n,
   output reg        tx_src_dsc_n = 1'b1,
   output reg        tx_src_rdy_n = 1'b1,
   input             tx_dst_rdy_n,

   // User (TRN) Tx Ports

   input [63:0]      trn_td,
   input [7:0]       trn_trem_n,
   input             trn_tsof_n,
   input             trn_teof_n,
   input             trn_tsrc_rdy_n,
   input             trn_tsrc_dsc_n,

   output reg        trn_tdst_rdy_n = 1'b1,
   output            trn_tdst_dsc_n,

   // Config Tx Ports

   input [63:0]      cfg_tx_td,
   input             cfg_tx_rem_n,
   input             cfg_tx_sof_n,
   input             cfg_tx_eof_n,
   input             cfg_tx_src_rdy_n,
   output reg        cfg_tx_dst_rdy_n = 1'b1
   );

  reg                cfg_in_pkt = 1'b0;
  reg                usr_in_pkt = 1'b0;
  wire               cfg_start;
  wire               cfg_done;
  wire               usr_start;
  wire               usr_done;
  wire               usr_in_pkt_inc;  // Inclusive of SOF cycle

  reg [63:0]         buf_td;
  reg                buf_sof_n;
  reg                buf_eof_n;
  reg                buf_dsc_n = 1'b1;
  reg                buf_rem_n;
  reg                buf_vld = 1'b0;
  wire               buf_divert;
  wire               buf_rd;
  wire               buf_filling;

  reg                tx_rem_n_bit;

  // Assign static output to undriven signals
  assign trn_tdst_dsc_n = 1'b1;  // FIXME do we need to do something with this?

  // Generate enables (dst_rdy)
  // NOTE this will insert a cycle switching cfg->usr; it is unavoidable
  // if we want to allow back-to-back TLPs from the CFG input
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_tdst_rdy_n      <= #`TCQ 1'b1;
      cfg_tx_dst_rdy_n    <= #`TCQ 1'b1;
    end else begin
      if (cfg_in_pkt || ((!usr_in_pkt_inc || usr_done) &&
                         !cfg_tx_src_rdy_n)) begin
        cfg_tx_dst_rdy_n  <= #`TCQ ((buf_vld && !buf_rd) || buf_filling);
        trn_tdst_rdy_n    <= #`TCQ 1'b1;
      end else begin
        cfg_tx_dst_rdy_n  <= #`TCQ 1'b1;
        trn_tdst_rdy_n    <= #`TCQ ((buf_vld && !buf_rd) || buf_filling);
      end
    end
  end

  assign usr_start = !trn_tdst_rdy_n && !trn_tsrc_rdy_n && !trn_tsof_n;
  assign usr_done  = !trn_tdst_rdy_n && !trn_tsrc_rdy_n &&
                     (!trn_teof_n || !trn_tsrc_dsc_n);
  assign usr_in_pkt_inc = usr_in_pkt ||
          (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !trn_tsof_n);
  
  assign cfg_start = !cfg_tx_dst_rdy_n && !cfg_tx_src_rdy_n && !cfg_tx_sof_n;
  assign cfg_done  = !cfg_tx_dst_rdy_n && !cfg_tx_src_rdy_n && !cfg_tx_eof_n;

  // Create usr_in_pkt and cfg_in_pkt
  always @(posedge clk) begin
    if (!rst_n) begin
      usr_in_pkt     <= #`TCQ 1'b0;
      cfg_in_pkt     <= #`TCQ 1'b0;
    end else begin
      if (usr_start) begin
        usr_in_pkt   <= #`TCQ 1'b1;
      end else if (usr_done) begin
        usr_in_pkt   <= #`TCQ 1'b0;
      end
      if (cfg_start) begin
        cfg_in_pkt   <= #`TCQ 1'b1;
      end else if (cfg_done) begin
        cfg_in_pkt   <= #`TCQ 1'b0;
      end
    end
  end

  // Input shunt buffer - absorb one cycle of data to decouple
  // trn_tdst_rdy_n from other signals (and therefore make it a
  // registered output)
  always @(posedge clk) begin
    if (!rst_n) begin
      buf_vld         <= #`TCQ 1'b0;
    end else begin
      if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && buf_divert) begin
        buf_td        <= #`TCQ trn_td;
        buf_sof_n     <= #`TCQ trn_tsof_n;
        buf_eof_n     <= #`TCQ trn_teof_n && trn_tsrc_dsc_n;
        buf_dsc_n     <= #`TCQ trn_tsrc_dsc_n;
        buf_rem_n     <= #`TCQ trn_trem_n[0];

        // Prevent user-data outside of a packet (data after EOF and before
        // SOF) from being accepted by the core by masking with usr_in_pkt_inc
        buf_vld       <= #`TCQ usr_in_pkt_inc;
      end else if (!cfg_tx_dst_rdy_n && !cfg_tx_src_rdy_n && buf_divert) begin
        buf_td        <= #`TCQ cfg_tx_td;
        buf_sof_n     <= #`TCQ cfg_tx_sof_n;
        buf_eof_n     <= #`TCQ cfg_tx_eof_n;
        buf_dsc_n     <= #`TCQ 1'b1;
        buf_rem_n     <= #`TCQ cfg_tx_rem_n;
        buf_vld       <= #`TCQ 1'b1;
      end else if (buf_rd) begin
        buf_vld       <= #`TCQ 1'b0;
      end
    end
  end

  // Control when the shunt buffer is written and read
  //   Writes go to the shunt buffer when the first pipeline stage is full
  //   and not emptying
  assign buf_divert = !tx_src_rdy_n && tx_dst_rdy_n;
  //   The shunt buffer gets read when the pipeline is first shifted after
  //   the shunt buffer is filled
  assign buf_rd     = buf_vld && !tx_src_rdy_n && !tx_dst_rdy_n;
  //   Asserted if the shunt buffer is filling
  assign buf_filling = buf_divert &&
                       ((!cfg_tx_src_rdy_n && !cfg_tx_dst_rdy_n) ||
                        (!trn_tsrc_rdy_n && !trn_tdst_rdy_n));
  // Output buffer
  always @(posedge clk) begin
    if (!rst_n) begin
      tx_src_rdy_n      <= #`TCQ 1'b1;
    end else begin
      // Multiplex the three inputs into the output data
      casex ({buf_rd,
              (!cfg_tx_src_rdy_n && !cfg_tx_dst_rdy_n && !buf_divert),
              (!trn_tsrc_rdy_n && !trn_tdst_rdy_n && !buf_divert)})
        3'b1xx: begin
          // Buf_rd always has priority. If one of the other sources has
          // a successful transaction but we're reading from the buffer,
          // that incoming transaction goes into the buffer, not the output
          tx_td         <= #`TCQ buf_td;
          tx_sof_n      <= #`TCQ buf_sof_n;
          tx_eof_n      <= #`TCQ buf_eof_n;
          tx_src_dsc_n  <= #`TCQ buf_dsc_n;
          tx_rem_n_bit  <= #`TCQ buf_rem_n;
        end
        3'b010: begin
          // Select from config input
          tx_td         <= #`TCQ cfg_tx_td;
          tx_sof_n      <= #`TCQ cfg_tx_sof_n;
          tx_eof_n      <= #`TCQ cfg_tx_eof_n;
          tx_src_dsc_n  <= #`TCQ 1'b1;
          tx_rem_n_bit  <= #`TCQ cfg_tx_rem_n;
        end
        3'b001: begin
          // Select from user input
          tx_td         <= #`TCQ trn_td;
          tx_sof_n      <= #`TCQ trn_tsof_n;
          tx_eof_n      <= #`TCQ trn_teof_n && trn_tsrc_dsc_n;
          tx_src_dsc_n  <= #`TCQ trn_tsrc_dsc_n;
          tx_rem_n_bit  <= #`TCQ trn_trem_n;
        end
        3'b000: ; // This case is OK - don't have to move data every cycle
        default: begin
          // Anything other than the above cases is BAD
          // synthesis translate_off
          $display("ERROR: pcie_blk_ll_tx_arb hit an illegal mux input combination");
          $finish;
          // synthesis translate_on
        end
      endcase
      
      // Generate the output-valid signal
      // Prevent user-data outside of a packet (data after EOF and before
      // SOF) from being accepted by the core by masking with usr_in_pkt_inc
      if (buf_rd || (!cfg_tx_src_rdy_n && !cfg_tx_dst_rdy_n) ||
          (!trn_tsrc_rdy_n && !trn_tdst_rdy_n && usr_in_pkt_inc)) begin
        tx_src_rdy_n    <= #`TCQ 1'b0;
      end else if (!tx_dst_rdy_n) begin
        tx_src_rdy_n    <= #`TCQ 1'b1;
      end
    end
  end

  // REM is an 8-bit signal into the existing bridge code (although
  // only 1 bit is actually used) so we synthesize the rest of it here
  assign tx_rem_n = {4'b0000, {4{tx_rem_n_bit}}};

endmodule // pcie_blk_ll_tx_arb

