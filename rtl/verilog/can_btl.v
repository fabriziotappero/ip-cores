//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_btl.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the CAN Protocol Controller            ////
////  http://www.opencores.org/projects/can/                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002, 2003, 2004 Authors                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//// The CAN protocol is developed by Robert Bosch GmbH and       ////
//// protected by patents. Anybody who wants to implement this    ////
//// CAN IP core on silicon has to obtain a CAN protocol license  ////
//// from Bosch.                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.29  2004/05/12 15:58:41  igorm
// Core improved to pass all tests with the Bosch VHDL Reference system.
//
// Revision 1.28  2004/02/08 14:25:26  mohor
// Header changed.
//
// Revision 1.27  2003/09/30 00:55:13  mohor
// Error counters fixed to be compatible with Bosch VHDL reference model.
// Small synchronization changes.
//
// Revision 1.26  2003/09/25 18:55:49  mohor
// Synchronization changed, error counters fixed.
//
// Revision 1.25  2003/07/16 13:40:35  mohor
// Fixed according to the linter.
//
// Revision 1.24  2003/07/10 15:32:28  mohor
// Unused signal removed.
//
// Revision 1.23  2003/07/10 01:59:04  tadejm
// Synchronization fixed. In some strange cases it didn't work according to
// the VHDL reference model.
//
// Revision 1.22  2003/07/07 11:21:37  mohor
// Little fixes (to fix warnings).
//
// Revision 1.21  2003/07/03 09:32:20  mohor
// Synchronization changed.
//
// Revision 1.20  2003/06/20 14:51:11  mohor
// Previous change removed. When resynchronization occurs we go to seg1
// stage. sync stage does not cause another start of seg1 stage.
//
// Revision 1.19  2003/06/20 14:28:20  mohor
// When hard_sync or resync occure we need to go to seg1 segment. Going to
// sync segment is in that case blocked.
//
// Revision 1.18  2003/06/17 15:53:33  mohor
// clk_cnt reduced from [8:0] to [6:0].
//
// Revision 1.17  2003/06/17 14:32:17  mohor
// Removed few signals.
//
// Revision 1.16  2003/06/16 13:57:58  mohor
// tx_point generated one clk earlier. rx_i registered. Data corrected when
// using extended mode.
//
// Revision 1.15  2003/06/13 15:02:24  mohor
// Synchronization is also needed when transmitting a message.
//
// Revision 1.14  2003/06/13 14:55:11  mohor
// Counters width changed.
//
// Revision 1.13  2003/06/11 14:21:35  mohor
// When switching to tx, sync stage is overjumped.
//
// Revision 1.12  2003/02/14 20:17:01  mohor
// Several registers added. Not finished, yet.
//
// Revision 1.11  2003/02/09 18:40:29  mohor
// Overload fixed. Hard synchronization also enabled at the last bit of
// interframe.
//
// Revision 1.10  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.9  2003/01/31 01:13:38  mohor
// backup.
//
// Revision 1.8  2003/01/10 17:51:34  mohor
// Temporary version (backup).
//
// Revision 1.7  2003/01/08 02:10:53  mohor
// Acceptance filter added.
//
// Revision 1.6  2002/12/28 04:13:23  mohor
// Backup version.
//
// Revision 1.5  2002/12/27 00:12:52  mohor
// Header changed, testbench improved to send a frame (crc still missing).
//
// Revision 1.4  2002/12/26 01:33:05  mohor
// Tripple sampling supported.
//
// Revision 1.3  2002/12/25 23:44:16  mohor
// Commented lines removed.
//
// Revision 1.2  2002/12/25 14:17:00  mohor
// Synchronization working.
//
// Revision 1.1.1.1  2002/12/20 16:39:21  mohor
// Initial
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"

module can_btl
( 
  clk,
  rst,
  rx,
  tx,

  /* Bus Timing 0 register */
  baud_r_presc,
  sync_jump_width,

  /* Bus Timing 1 register */
  time_segment1,
  time_segment2,
  triple_sampling,

  /* Output signals from this module */
  sample_point,
  sampled_bit,
  sampled_bit_q,
  tx_point,
  hard_sync,
  
  /* Output from can_bsp module */
  rx_idle,
  rx_inter,
  transmitting,
  transmitter,
  go_rx_inter,
  tx_next,

  go_overload_frame,
  go_error_frame,
  go_tx,
  send_ack,
  node_error_passive
);

parameter Tp = 1;

input         clk;
input         rst;
input         rx;
input         tx;


/* Bus Timing 0 register */
input   [5:0] baud_r_presc;
input   [1:0] sync_jump_width;

/* Bus Timing 1 register */
input   [3:0] time_segment1;
input   [2:0] time_segment2;
input         triple_sampling;

/* Output from can_bsp module */
input         rx_idle;
input         rx_inter;
input         transmitting;
input         transmitter;
input         go_rx_inter;
input         tx_next;

input         go_overload_frame;
input         go_error_frame;
input         go_tx;
input         send_ack;
input         node_error_passive;

/* Output signals from this module */
output        sample_point;
output        sampled_bit;
output        sampled_bit_q;
output        tx_point;
output        hard_sync;

reg     [6:0] clk_cnt;
reg           clk_en;
reg           clk_en_q;
reg           sync_blocked;
reg           hard_sync_blocked;
reg           sampled_bit;
reg           sampled_bit_q;
reg     [4:0] quant_cnt;
reg     [3:0] delay;
reg           sync;
reg           seg1;
reg           seg2;
reg           resync_latched;
reg           sample_point;
reg     [1:0] sample;
reg           tx_point;
reg           tx_next_sp;

wire          go_sync;
wire          go_seg1;
wire          go_seg2;
wire [7:0]    preset_cnt;
wire          sync_window;
wire          resync;


assign preset_cnt = (baud_r_presc + 1'b1)<<1;        // (BRP+1)*2
assign hard_sync  =   (rx_idle | rx_inter)    & (~rx) & sampled_bit & (~hard_sync_blocked);  // Hard synchronization
assign resync     =  (~rx_idle) & (~rx_inter) & (~rx) & sampled_bit & (~sync_blocked);       // Re-synchronization



/* Generating general enable signal that defines baud rate. */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    clk_cnt <= 7'h0;
  else if (clk_cnt >= (preset_cnt-1'b1))
    clk_cnt <=#Tp 7'h0;
  else
    clk_cnt <=#Tp clk_cnt + 1'b1;
end


always @ (posedge clk or posedge rst)
begin
  if (rst)
    clk_en  <= 1'b0;
  else if ({1'b0, clk_cnt} == (preset_cnt-1'b1))
    clk_en  <=#Tp 1'b1;
  else
    clk_en  <=#Tp 1'b0;
end



always @ (posedge clk or posedge rst)
begin
  if (rst)
    clk_en_q  <= 1'b0;
  else
    clk_en_q  <=#Tp clk_en;
end



/* Changing states */
assign go_sync = clk_en_q & seg2 & (quant_cnt[2:0] == time_segment2) & (~hard_sync) & (~resync);
assign go_seg1 = clk_en_q & (sync | hard_sync | (resync & seg2 & sync_window) | (resync_latched & sync_window));
assign go_seg2 = clk_en_q & (seg1 & (~hard_sync) & (quant_cnt == (time_segment1 + delay)));



always @ (posedge clk or posedge rst)
begin
  if (rst)
    tx_point <= 1'b0;
  else
    tx_point <=#Tp ~tx_point & seg2 & (  clk_en & (quant_cnt[2:0] == time_segment2)
                                       | (clk_en | clk_en_q) & (resync | hard_sync)
                                      );    // When transmitter we should transmit as soon as possible.
end



/* When early edge is detected outside of the SJW field, synchronization request is latched and performed when
   SJW is reached */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    resync_latched <= 1'b0;
  else if (resync & seg2 & (~sync_window))
    resync_latched <=#Tp 1'b1;
  else if (go_seg1)
    resync_latched <= 1'b0;
end



/* Synchronization stage/segment */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    sync <= 1'b0;
  else if (clk_en_q)
    sync <=#Tp go_sync;
end


/* Seg1 stage/segment (together with propagation segment which is 1 quant long) */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    seg1 <= 1'b1;
  else if (go_seg1)
    seg1 <=#Tp 1'b1;
  else if (go_seg2)
    seg1 <=#Tp 1'b0;
end


/* Seg2 stage/segment */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    seg2 <= 1'b0;
  else if (go_seg2)
    seg2 <=#Tp 1'b1;
  else if (go_sync | go_seg1)
    seg2 <=#Tp 1'b0;
end


/* Quant counter */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    quant_cnt <= 5'h0;
  else if (go_sync | go_seg1 | go_seg2)
    quant_cnt <=#Tp 5'h0;
  else if (clk_en_q)
    quant_cnt <=#Tp quant_cnt + 1'b1;
end


/* When late edge is detected (in seg1 stage), stage seg1 is prolonged. */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    delay <= 4'h0;
  else if (resync & seg1 & (~transmitting | transmitting & (tx_next_sp | (tx & (~rx)))))  // when transmitting 0 with positive error delay is set to 0
    delay <=#Tp (quant_cnt > {3'h0, sync_jump_width})? ({2'h0, sync_jump_width} + 1'b1) : (quant_cnt + 1'b1);
  else if (go_sync | go_seg1)
    delay <=#Tp 4'h0;
end


// If early edge appears within this window (in seg2 stage), phase error is fully compensated
assign sync_window = ((time_segment2 - quant_cnt[2:0]) < ( sync_jump_width + 1'b1));


// Sampling data (memorizing two samples all the time).
always @ (posedge clk or posedge rst)
begin
  if (rst)
    sample <= 2'b11;
  else if (clk_en_q)
    sample <= {sample[0], rx};
end


// When enabled, tripple sampling is done here.
always @ (posedge clk or posedge rst)
begin
  if (rst)
    begin
      sampled_bit <= 1'b1;
      sampled_bit_q <= 1'b1;
      sample_point <= 1'b0;
    end
  else if (go_error_frame)
    begin
      sampled_bit_q <=#Tp sampled_bit;
      sample_point <=#Tp 1'b0;
    end
  else if (clk_en_q & (~hard_sync))
    begin
      if (seg1 & (quant_cnt == (time_segment1 + delay)))
        begin
          sample_point <=#Tp 1'b1;
          sampled_bit_q <=#Tp sampled_bit;
          if (triple_sampling)
            sampled_bit <=#Tp (sample[0] & sample[1]) | ( sample[0] & rx) | (sample[1] & rx);
          else
            sampled_bit <=#Tp rx;
        end
    end
  else
    sample_point <=#Tp 1'b0;
end


// tx_next_sp shows next value that will be driven on the TX. When driving 1 and receiving 0 we
// need to synchronize (even when we are a transmitter)
always @ (posedge clk or posedge rst)
begin
  if (rst)
    tx_next_sp <= 1'b0;
  else if (go_overload_frame | (go_error_frame & (~node_error_passive)) | go_tx | send_ack)
    tx_next_sp <=#Tp 1'b0;
  else if (go_error_frame & node_error_passive)
    tx_next_sp <=#Tp 1'b1;
  else if (sample_point)
    tx_next_sp <=#Tp tx_next;
end



/* Blocking synchronization (can occur only once in a bit time) */

always @ (posedge clk or posedge rst)
begin
  if (rst)
    sync_blocked <=#Tp 1'b1;
  else if (clk_en_q)
    begin
      if (resync)
        sync_blocked <=#Tp 1'b1;
      else if (go_seg2)
        sync_blocked <=#Tp 1'b0;
    end
end


/* Blocking hard synchronization when occurs once or when we are transmitting a msg */
always @ (posedge clk or posedge rst)
begin
  if (rst)
    hard_sync_blocked <=#Tp 1'b0;
  else if (hard_sync & clk_en_q | (transmitting & transmitter | go_tx) & tx_point & (~tx_next))
    hard_sync_blocked <=#Tp 1'b1;
  else if (go_rx_inter | (rx_idle | rx_inter) & sample_point & sampled_bit)  // When a glitch performed synchronization
    hard_sync_blocked <=#Tp 1'b0;
end





endmodule

