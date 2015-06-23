
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
// File       : pcie_blk_ll_oqbqfifo.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: First word Fall-Thru FIFO with separate storage areas
//--              for Non-posted and posted/completion TLPs
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

module pcie_blk_ll_oqbqfifo
//{{{ Port List
(
  // Clock and reset

  input wire                   clk,
  input wire                   rst_n,
  
  // Outputs
  output reg                   trn_rsrc_rdy  = 0,
  output reg [63:0]            trn_rd        = 0,
  output reg [7:0]             trn_rrem      = 0,
  output reg                   trn_rsof      = 0,
  output reg                   trn_reof      = 0,
  output reg                   trn_rerrfwd   = 0,
  output reg [6:0]             trn_rbar_hit  = 0,
  output reg                   fifo_np_ok    = 1,
  output reg                   fifo_pcpl_ok  = 1,

  // Inputs
  input                        trn_rdst_rdy,
  input                        trn_rnp_ok,
  input                        fifo_wren,
  input      [63:0]            fifo_data,
  input                        fifo_rem,
  input                        fifo_sof,
  input                        fifo_preeof,
  input                        fifo_eof,
  input                        fifo_dsc,
  input                        fifo_np,
  input      [3:0]             fifo_barenc,    // Encoded BAR hit
  input                        fifo_np_req,
  input                        fifo_pcpl_req,
  input                        fifo_np_abort,
  input                        fifo_pcpl_abort
);
//}}}
//{{{ Wire/Reg declarations
wire [71:0]         oq_din,         bq_din;
wire [71:0]         oq_dout,        bq_dout;
wire [63:0]         oq_dataout,     bq_dataout;
wire                oq_sofout,      bq_sofout;
wire                oq_preeofout,   bq_preeofout;
wire                oq_remout,      bq_remout;
wire                oq_errout,      bq_errout;
wire [3:0]          oq_barout,      bq_barout;
wire                oq_wren,        bq_wren;
wire                oq_rden,        bq_rden;
wire                oq_full,        bq_full;
wire                oq_afull,       bq_afull;
wire                oq_rdy,         bq_rdy;
wire                oq_valid,       bq_valid;
wire                oq_empty,       bq_empty;
wire                oq_trn_in_progress, bq_trn_in_progress;
wire                trigger_oq_trn,     trigger_bq_trn;
wire                oq_memrd;
wire                poisoned;
reg                 poisoned_reg = 0;
reg                 packet_in_progress    = 0;
reg                 packet_in_progress_bq = 0;
reg                 packet_in_progress_oq = 0;
wire                trigger_bypass;
wire                oq_byp_in_progress;
reg                 oq_byp_in_progress_reg;
reg [3:0]           np_count = 0;
reg                 trn_np          = 0;
reg                 trn_drain_np    = 0;
reg                 fifo_discard_np = 0;
reg                 trn_rnp_ok_d    = 1;
reg [8:0]           oq_pktcnt       = 0;
reg [3:0]           bq_pktcnt       = 0;
reg                 oq_pkt_avail    = 0;
reg                 bq_pkt_avail    = 0;
reg                 oq_write_pkt_in_progress_reg = 0;
reg                 new_oq_pkt_wr    =0;
reg                 new_oq_pkt_wr_d  =0;
reg                 new_oq_pkt_wr_d2 =0;
integer             i;
//}}}
//{{{ Functions
  function [6:0] barhit;
    input [3:0] selector;
    begin
      casex (selector)
        4'b0000: barhit  = 7'b0000001;
        4'b0001: barhit  = 7'b0000010;
        4'b0010: barhit  = 7'b0000100;
        4'b0011: barhit  = 7'b0001000;
        4'b0100: barhit  = 7'b0010000;
        4'b0101: barhit  = 7'b0100000;
        4'b0110: barhit  = 7'b1000000;
        4'b0111: barhit  = 7'b0000011;
        4'b1000: barhit  = 7'b0000110;
        4'b1001: barhit  = 7'b0001100;
        4'b1010: barhit  = 7'b0011000;
        4'b1011: barhit  = 7'b0110000;
        default: barhit  = 7'b0000000; // No BAR hit (cpl)
      endcase
    end
  endfunction

  function nonposted;
    input [7:0] header;
    begin
      casex (header[6:0])
      7'b0x0000x: nonposted = 1'b1; //MRd, MRdLk
      7'bx000010: nonposted = 1'b1; //IO
      7'bx00010x: nonposted = 1'b1; //Cfg
      default:    nonposted = 1'b0; 
      endcase
    end
  endfunction

//}}}

  //{{{ Ordered Queue (OQ) FIFO
  // Map module inputs and internal signals to BRAM inputs
  wire   nonposted_or_rem =  fifo_sof ? nonposted(fifo_data[63:56]) : fifo_rem;
  //                  71          70           69           68        67:64         63:0
  assign oq_din  = {fifo_sof, fifo_eof, nonposted_or_rem, poisoned, fifo_barenc, fifo_data};
  assign oq_sofout    = oq_dout[71];
  assign oq_eofout    = oq_dout[70];
  assign oq_remout    = oq_eofout ? oq_dout[69] : 1'b1;
  assign oq_errout    = oq_dout[68];
  assign oq_barout    = oq_dout[67:64];
  assign oq_dataout   = oq_dout[63:0];
  assign oq_valid     = !oq_empty;
  assign oq_memrd     = oq_sofout && oq_valid && oq_dout[69]; //bit69 indicates nonposted during SOF
  assign oq_wren      = (oq_write_pkt_in_progress_reg || fifo_sof) && fifo_wren;
  assign oq_rden      = ((oq_trn_in_progress && (trn_rdst_rdy || !trn_rsrc_rdy)) ||
                                     oq_byp_in_progress);

  always @(posedge clk) begin
    if (!rst_n)
      oq_write_pkt_in_progress_reg <= #`TCQ 1'b0;
    else if (fifo_wren && fifo_sof)
      oq_write_pkt_in_progress_reg <= #`TCQ 1'b1;
    else if (fifo_wren && (fifo_eof || fifo_dsc))
      oq_write_pkt_in_progress_reg <= #`TCQ 1'b0;
  end


  sync_fifo
  #(
    .WIDTH  (72),
    .DEPTH  (512),
    .STYLE  ("BRAM"),
    .AFASSERT (512 - 66 - 14), 
    .FWFT       (1),
    .SUP_REWIND (1)
   ) oq_fifo (
   .clk        ( clk      ),
   .rst_n      ( rst_n    ),
   .din        ( oq_din   ),
   .dout       ( oq_dout  ),
   .wr_en      ( oq_wren  ),
   .rd_en      ( oq_rden  ),
   .full       ( oq_full  ),
   .afull      ( oq_afull ),
   .empty      ( oq_empty ),
   .aempty     (          ),
   .data_count (          ),
   .mark_addr  ( fifo_sof && oq_wren ),
   .clear_addr ( fifo_eof && oq_wren ),
   .rewind     ( fifo_dsc && oq_wren )
   );
  //}}}

  //{{{ Bypass Queue (BQ) FIFO
  // Instantiate SRLFIFO for storing BQ data.
  assign bq_din = oq_dout;
  assign bq_sofout    = bq_dout[71];
  assign bq_eofout    = bq_dout[70];
  assign bq_remout    = bq_dout[69];
  assign bq_errout    = bq_dout[68];
  assign bq_barout    = bq_dout[67:64];
  assign bq_dataout   = bq_dout[63:0];
  assign bq_valid     = !bq_empty;
  assign bq_wren      = oq_valid &&   oq_byp_in_progress;
  assign bq_rden      = bq_valid &&   bq_trn_in_progress && (trn_rdst_rdy || !trn_rsrc_rdy);

  sync_fifo
  #(
    .WIDTH (72),
    .DEPTH (16),
    .FWFT  (1),
    .STYLE ("SRL")
   ) bq_fifo (
   .din        ( bq_din   ),
   .dout       ( bq_dout  ),
   .wr_en      ( bq_wren  ),
   .rd_en      ( bq_rden  ),
   .full       ( bq_full  ),
   .afull      ( bq_afull ),
   .empty      ( bq_empty ),
   .aempty     (          ),
   .data_count (          ),
   .clk        ( clk      ),
   .rst_n      ( rst_n    )
   );
  //}}}

  //{{{ OQ/BQ Arbitration Logic; Bypass
  assign trigger_bypass     = (oq_memrd && !bq_afull && !trn_rnp_ok_d);
  assign oq_byp_in_progress = oq_byp_in_progress_reg || trigger_bypass;

  assign bq_rdy = bq_pkt_avail;
  assign oq_rdy = !bq_rdy && oq_pkt_avail && !oq_byp_in_progress;

  assign trigger_bq_trn     = bq_rdy && !trn_rsrc_rdy && !packet_in_progress;
  assign bq_trn_in_progress = packet_in_progress_bq || trigger_bq_trn;

  assign trigger_oq_trn     = oq_rdy && !trn_rsrc_rdy && !packet_in_progress;
  assign oq_trn_in_progress = packet_in_progress_oq || trigger_oq_trn;


  always @(posedge clk) begin
    if (!rst_n)
      oq_byp_in_progress_reg <= #`TCQ 1'b0;
    else if (trigger_bypass)
      oq_byp_in_progress_reg <= #`TCQ 1'b1;
    else if (oq_eofout && oq_valid)
      oq_byp_in_progress_reg <= #`TCQ 1'b0;
  end
  //}}}

  //{{{ TRN Interface
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_rd                <= #`TCQ 'h0;
      trn_rsof              <= #`TCQ 1'b0;
      trn_reof              <= #`TCQ 1'b0;
      trn_rrem              <= #`TCQ 8'hFF;
      trn_rbar_hit          <= #`TCQ 'h0;
      trn_rsrc_rdy          <= #`TCQ 1'b0;
      trn_rerrfwd           <= #`TCQ 1'b0;
      packet_in_progress    <= #`TCQ 1'b0;
      packet_in_progress_bq <= #`TCQ 1'b0;
      packet_in_progress_oq <= #`TCQ 1'b0;
    end else begin
      //Case 1: Waiting for EOF to be accepted (stalled with DST RDY)
      if (trn_rsrc_rdy && trn_reof && !trn_rdst_rdy) begin
        packet_in_progress    <= #`TCQ 1'b0;
        packet_in_progress_bq <= #`TCQ 1'b0;
        packet_in_progress_oq <= #`TCQ 1'b0;
        trn_rd                <= #`TCQ trn_rd;
        trn_rsof              <= #`TCQ trn_rsof;
        trn_reof              <= #`TCQ trn_reof;
        trn_rrem              <= #`TCQ trn_rrem;
        trn_rsrc_rdy          <= #`TCQ trn_rsrc_rdy && !trn_rdst_rdy;
        trn_rbar_hit          <= #`TCQ trn_rbar_hit;
        trn_rerrfwd           <= #`TCQ trn_rerrfwd;
      end
      //Case 2: Packet in progress from BQ queue, or starting new one from idle
      else if (bq_trn_in_progress) begin
        // Filling accepted data
        if ((trn_rdst_rdy || !trn_rsrc_rdy) && bq_valid) begin
           packet_in_progress    <= #`TCQ (!bq_eofout || bq_rdy) || (bq_eofout && oq_rdy);
           packet_in_progress_bq <= #`TCQ !bq_eofout || bq_rdy;
           packet_in_progress_oq <= #`TCQ bq_eofout && oq_rdy && !oq_byp_in_progress;
           trn_rd                <= #`TCQ bq_dataout;
           trn_rsof              <= #`TCQ bq_sofout;
           trn_rrem              <= #`TCQ {4'hF, { 4{bq_remout} }};
           trn_rbar_hit          <= #`TCQ barhit(bq_barout);
           trn_rerrfwd           <= #`TCQ bq_errout;
        end 
        if ((trn_rdst_rdy || !trn_rsrc_rdy) && bq_valid) begin
           trn_rsrc_rdy          <= #`TCQ 1'b1;
           trn_reof              <= #`TCQ bq_eofout;
        // Packet in progress from BQ queue; queue pauses
        end else if (!bq_valid) begin
           trn_rsrc_rdy          <= #`TCQ trn_rsrc_rdy && !trn_rdst_rdy;
           trn_reof              <= #`TCQ bq_eofout    && !trn_rdst_rdy;
        end
      end
      //Case 3: Packet in progress from OQ queue, or starting new one from idle
      else if (oq_trn_in_progress && !oq_byp_in_progress) begin
         //packet_in_progress_oq || (oq_rdy && !trn_rsrc_rdy && !packet_in_progress)) begin
        if ((trn_rdst_rdy || !trn_rsrc_rdy) && oq_valid) begin
          packet_in_progress    <= #`TCQ (!oq_eofout || oq_rdy) || (oq_eofout && bq_rdy);
          packet_in_progress_bq <= #`TCQ oq_eofout && bq_rdy;
          packet_in_progress_oq <= #`TCQ !oq_eofout || oq_rdy;
          trn_rd                <= #`TCQ oq_dataout;
          trn_rsof              <= #`TCQ oq_sofout;
          trn_rrem              <= #`TCQ {4'hF, { 4{oq_remout} }};
          trn_rbar_hit          <= #`TCQ barhit(oq_barout);
          trn_rerrfwd           <= #`TCQ oq_errout;
          trn_rsrc_rdy          <= #`TCQ 1'b1;
          trn_reof              <= #`TCQ oq_eofout;
        // Packet in progress from OQ queue; queue pauses
        end else if (!oq_valid) begin
           trn_rsrc_rdy          <= #`TCQ trn_rsrc_rdy && !trn_rdst_rdy;
           trn_reof              <= #`TCQ oq_eofout    && !trn_rdst_rdy;
        end
      end
      //Case 4: Idle
      else begin
        packet_in_progress    <= #`TCQ 1'b0;
        packet_in_progress_bq <= #`TCQ 1'b0;
        packet_in_progress_oq <= #`TCQ 1'b0;
        trn_rd                <= #`TCQ trn_rd;
        trn_rsof              <= #`TCQ 1'b0;
        trn_reof              <= #`TCQ 1'b0;
        trn_rrem              <= #`TCQ 8'hFF;
        trn_rsrc_rdy          <= #`TCQ 1'b0;
        trn_rbar_hit          <= #`TCQ 'h0;
        trn_rerrfwd           <= #`TCQ 1'b0;
      end
    end
  end
  //}}}

//{{{ ASSERTIONS: LocalLink and TRN
`ifdef SV
  //synthesis translate_off
  ASSERT_LL_DOUBLESOF:      assert property (@(posedge clk)
    (trn_rsof && trn_rdst_rdy && trn_rsrc_rdy) |-> ##1 !(trn_rsof && trn_rdst_rdy && trn_rsrc_rdy)
                                       ) else $fatal;
  ASSERT_LL_DOUBLEEOF:      assert property (@(posedge clk)
    (trn_reof && trn_rdst_rdy && trn_rsrc_rdy) |-> ##1 !(trn_reof && trn_rdst_rdy && trn_rsrc_rdy)
                                       ) else $fatal;
  ASSERT_RDST_HOLDS_OUTPUT: assert property (@(posedge clk)
    !trn_rdst_rdy && trn_rsrc_rdy |-> ##1 $stable(trn_rd)       && 
                                          $stable(trn_rsof)     &&
                                          $stable(trn_reof)     &&
                                          $stable(trn_rrem)     &&
                                          $stable(trn_rbar_hit) &&
                                          $stable(trn_rerrfwd)
                                       ) else $fatal;
  //TLPs s/b back2back if possible, if there is a valid dword in OQ or BQ after
  //a non-stalled EOF, unless:
  //a) OQ->BQ bypass is occurring, and BQ output is empty or stalled due to RNP_OK deassertion
  //b) RNP_OK is deasserted, and either OQ not available or it is a NP
  ASSERT_RX_TRN_BACK2BACK_NP:  assert property (@(posedge clk)
    !(!trn_rdst_rdy && trn_rsrc_rdy && trn_reof) && (bq_valid && (bq_pktcnt>0) && trn_rnp_ok_d) ##1 
       trn_rdst_rdy && trn_rsrc_rdy && trn_reof  |-> ##1 
         (trn_rsof && trn_rsrc_rdy && nonposted(trn_rd[63:56])) 
                                       ) else $fatal;
  ASSERT_RX_TRN_BACK2BACK_PCPL:assert property (@(posedge clk)
    !(!trn_rdst_rdy && trn_rsrc_rdy && trn_reof) && !(bq_valid && (bq_pktcnt>0) && trn_rnp_ok_d) &&
         (oq_valid && (oq_pktcnt>0) && !oq_byp_in_progress && !(!trn_rnp_ok_d && oq_memrd)) ##1 
       trn_rdst_rdy && trn_rsrc_rdy && trn_reof |-> ##1
         (trn_rsof && trn_rsrc_rdy) || oq_byp_in_progress 
                                       ) else $fatal;
  ASSERT_PROGRESS_MUTEX1: assert property (@(posedge clk)
    bq_trn_in_progress  |-> !oq_trn_in_progress
                                       ) else $fatal;
  ASSERT_PROGRESS_MUTEX2: assert property (@(posedge clk)
    oq_trn_in_progress  |-> !bq_trn_in_progress && (!oq_byp_in_progress || (trn_reof && trn_rsrc_rdy))
                                       ) else $fatal;
  ASSERT_PROGRESS_MUTEX3: assert property (@(posedge clk)
    oq_byp_in_progress && !(trn_reof && trn_rsrc_rdy) |-> !oq_trn_in_progress
                                       ) else $fatal;
  ASSERT_PACKETINPROGRESS2: assert property (@(posedge clk)
    packet_in_progress_oq |-> !packet_in_progress_bq && packet_in_progress
                                       ) else $fatal;
  ASSERT_PACKETINPROGRESS3: assert property (@(posedge clk)
    packet_in_progress    |->  packet_in_progress_bq || packet_in_progress_oq
                                       ) else $fatal;
  ASSERT_BYPASS_OQ_MUTEX:   assert property (@(posedge clk)
    !(bq_wren && oq_trn_in_progress && !(trn_reof && trn_rsrc_rdy))
                                       ) else $fatal;
  ASSERT_BQ_WRITE_BYP_ONLY: assert property (@(posedge clk)
    !(bq_wren && !oq_byp_in_progress)
                                       ) else $fatal;
  ASSERT_RNPOK_STOPS_NP:    assert property (@(posedge clk)
   !trn_rnp_ok ##1 !trn_rnp_ok  ##1 !trn_rnp_ok |-> ##1 
            !(trn_rsof && trn_rsrc_rdy && nonposted(trn_rd[64:56]))
                                        ) else $fatal;
  //synthesis translate_on
`endif
//}}}

  //{{{ Poisoned bit logic
  // Assert poisoned when starting or continuing a poisoned TLP
  assign poisoned     = poisoned_reg || (fifo_data[46] && fifo_sof);

  // Continue wrtrans* and poisoned signals after SOF until EOF
  always @(posedge clk) begin
    if (!rst_n) begin
      poisoned_reg           <= #`TCQ 0;
    end else if (fifo_sof && !fifo_eof && fifo_wren) begin
      poisoned_reg           <= #`TCQ fifo_data[46];
    end else if (fifo_eof && fifo_wren) begin
      poisoned_reg           <= #`TCQ 0;
    end
  end
  //}}}
 
  //{{{ FIFO-fullness counting logic
  always @(posedge clk) begin
    if (!rst_n) begin
      fifo_np_ok        <= #`TCQ 1'b1;
      fifo_pcpl_ok      <= #`TCQ 1'b1;
      trn_np            <= #`TCQ 1'b0;
      trn_drain_np      <= #`TCQ 1'b0;
      fifo_discard_np   <= #`TCQ 1'b0;
      np_count          <= #`TCQ 'h0;
      trn_rnp_ok_d      <= #`TCQ 1'b1;
      new_oq_pkt_wr     <= #`TCQ 1'b0;
      new_oq_pkt_wr_d   <= #`TCQ 1'b0;
      new_oq_pkt_wr_d2  <= #`TCQ 1'b0;
      oq_pktcnt         <= #`TCQ 'h0;
      bq_pktcnt         <= #`TCQ 'h0;
      oq_pkt_avail      <= #`TCQ 'b0;
      bq_pkt_avail      <= #`TCQ 'b0;
    end else begin
      fifo_np_ok        <= #`TCQ (np_count<8) && !oq_afull;
      fifo_pcpl_ok      <= #`TCQ !oq_afull;
      if (trn_rsof && nonposted(trn_rd[63:56]) && trn_rsrc_rdy)
        trn_np            <= #`TCQ 1'b1;
      else if (trn_rsof && trn_rsrc_rdy)
        trn_np            <= #`TCQ 1'b0;
      trn_drain_np      <= #`TCQ trn_np && trn_reof && trn_rsrc_rdy && trn_rdst_rdy;
      fifo_discard_np   <= #`TCQ fifo_np && fifo_wren && fifo_dsc;
      case ({fifo_np_req,trn_drain_np,fifo_discard_np})
      3'b000 : np_count   <= #`TCQ np_count;
      3'b001 : np_count   <= #`TCQ np_count - 1;
      3'b010 : np_count   <= #`TCQ np_count - 1;
      3'b011 : np_count   <= #`TCQ np_count - 2;
      3'b100 : np_count   <= #`TCQ np_count + 1;
      3'b101 : np_count   <= #`TCQ np_count;
      3'b110 : np_count   <= #`TCQ np_count;
      3'b111 : np_count   <= #`TCQ np_count - 1;
      default: np_count   <= #`TCQ np_count;
      endcase
      trn_rnp_ok_d      <= #`TCQ trn_rnp_ok;
      new_oq_pkt_wr     <= #`TCQ oq_wren && fifo_eof && !fifo_dsc;
      new_oq_pkt_wr_d   <= #`TCQ new_oq_pkt_wr;
      new_oq_pkt_wr_d2  <= #`TCQ new_oq_pkt_wr_d;
      if      (new_oq_pkt_wr_d2 && !(oq_rden && oq_sofout && oq_valid)) begin
        oq_pktcnt         <= #`TCQ oq_pktcnt + 1;
        oq_pkt_avail      <= #`TCQ 1'b1;
      end 
      else if (!new_oq_pkt_wr_d2 && (oq_rden && oq_sofout && oq_valid)) begin
        oq_pktcnt         <= #`TCQ oq_pktcnt - 1;
        oq_pkt_avail      <= #`TCQ (oq_pktcnt>1);
      end else begin
        oq_pkt_avail      <= #`TCQ (oq_pktcnt>0);
      end
      if      ( (bq_wren && oq_eofout) && 
               !(bq_rden && bq_sofout && bq_valid)) begin
        bq_pktcnt         <= #`TCQ bq_pktcnt + 1;
        bq_pkt_avail      <= #`TCQ trn_rnp_ok_d;
      end
      else if (!(bq_wren && oq_eofout) &&
                (bq_rden && bq_sofout && bq_valid)) begin
        bq_pktcnt         <= #`TCQ bq_pktcnt - 1;
        bq_pkt_avail      <= #`TCQ (bq_pktcnt>1) && trn_rnp_ok_d;
      end else begin
        bq_pkt_avail      <= #`TCQ (bq_pktcnt>0) && trn_rnp_ok_d;
      end
    end
  end



  //}}}

  //{{{ ASSERTIONS: npcount
`ifdef SV
  //synthesis translate_off
  ASSERT_NPCOUNT_IS_0_WHEN_IDLE: assert property (@(posedge clk)
    (!oq_valid && !bq_valid && !trn_rsrc_rdy && !fifo_np_req)[*20]
                                     |-> (np_count == 0)
    
                                       ) else $fatal;
  ASSERT_NPCOUNT_IS_8_OR_LESS: assert property (@(posedge clk)
    !(np_count > 8 )
                                       ) else $fatal;
  //synthesis translate_on
`endif
  //}}}

endmodule

