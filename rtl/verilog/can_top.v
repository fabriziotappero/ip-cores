//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_top.v                                                   ////
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
// Revision 1.47  2004/02/08 14:53:54  mohor
// Header changed. Address latched to posedge. bus_off_on signal added.
//
// Revision 1.46  2003/10/17 05:55:20  markom
// mbist signals updated according to newest convention
//
// Revision 1.45  2003/09/30 00:55:13  mohor
// Error counters fixed to be compatible with Bosch VHDL reference model.
// Small synchronization changes.
//
// Revision 1.44  2003/09/25 18:55:49  mohor
// Synchronization changed, error counters fixed.
//
// Revision 1.43  2003/08/20 09:57:39  mohor
// Tristate signal tx_o is separated to tx_o and tx_oen_o. Both signals need
// to be joined together on higher level.
//
// Revision 1.42  2003/07/16 15:11:28  mohor
// Fixed according to the linter.
//
// Revision 1.41  2003/07/10 15:32:27  mohor
// Unused signal removed.
//
// Revision 1.40  2003/07/10 01:59:04  tadejm
// Synchronization fixed. In some strange cases it didn't work according to
// the VHDL reference model.
//
// Revision 1.39  2003/07/07 11:21:37  mohor
// Little fixes (to fix warnings).
//
// Revision 1.38  2003/07/03 09:32:20  mohor
// Synchronization changed.
//
// Revision 1.37  2003/06/27 20:56:15  simons
// Virtual silicon ram instances added.
//
// Revision 1.36  2003/06/17 14:30:30  mohor
// "chip select" signal cs_can_i is used only when not using WISHBONE
// interface.
//
// Revision 1.35  2003/06/16 13:57:58  mohor
// tx_point generated one clk earlier. rx_i registered. Data corrected when
// using extended mode.
//
// Revision 1.34  2003/06/13 15:02:24  mohor
// Synchronization is also needed when transmitting a message.
//
// Revision 1.33  2003/06/11 14:21:35  mohor
// When switching to tx, sync stage is overjumped.
//
// Revision 1.32  2003/06/09 11:32:36  mohor
// Ports added for the CAN_BIST.
//
// Revision 1.31  2003/03/26 11:19:46  mohor
// CAN interrupt is active low.
//
// Revision 1.30  2003/03/20 17:01:17  mohor
// unix.
//
// Revision 1.28  2003/03/14 19:36:48  mohor
// can_cs signal used for generation of the cs.
//
// Revision 1.27  2003/03/12 05:56:33  mohor
// Bidirectional port_0_i changed to port_0_io.
// input cs_can changed to cs_can_i.
//
// Revision 1.26  2003/03/12 04:39:40  mohor
// rd_i and wr_i are active high signals. If 8051 is connected, these two signals
// need to be negated one level higher.
//
// Revision 1.25  2003/03/12 04:17:36  mohor
// 8051 interface added (besides WISHBONE interface). Selection is made in
// can_defines.v file.
//
// Revision 1.24  2003/03/10 17:24:40  mohor
// wire declaration added.
//
// Revision 1.23  2003/03/05 15:33:13  mohor
// tx_o is now tristated signal. tx_oen and tx_o combined together.
//
// Revision 1.22  2003/03/05 15:01:56  mohor
// Top level signal names changed.
//
// Revision 1.21  2003/03/01 22:53:33  mohor
// Actel APA ram supported.
//
// Revision 1.20  2003/02/19 15:09:02  mohor
// Incomplete sensitivity list fixed.
//
// Revision 1.19  2003/02/19 15:04:14  mohor
// Typo fixed.
//
// Revision 1.18  2003/02/19 14:44:03  mohor
// CAN core finished. Host interface added. Registers finished.
// Synchronization to the wishbone finished.
//
// Revision 1.17  2003/02/18 00:10:15  mohor
// Most of the registers added. Registers "arbitration lost capture", "error code
// capture" + few more still need to be added.
//
// Revision 1.16  2003/02/14 20:17:01  mohor
// Several registers added. Not finished, yet.
//
// Revision 1.15  2003/02/12 14:25:30  mohor
// abort_tx added.
//
// Revision 1.14  2003/02/11 00:56:06  mohor
// Wishbone interface added.
//
// Revision 1.13  2003/02/09 18:40:29  mohor
// Overload fixed. Hard synchronization also enabled at the last bit of
// interframe.
//
// Revision 1.12  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.11  2003/02/04 14:34:52  mohor
// *** empty log message ***
//
// Revision 1.10  2003/01/31 01:13:38  mohor
// backup.
//
// Revision 1.9  2003/01/15 13:16:48  mohor
// When a frame with "remote request" is received, no data is stored to
// fifo, just the frame information (identifier, ...). Data length that
// is stored is the received data length and not the actual data length
// that is stored to fifo.
//
// Revision 1.8  2003/01/14 17:25:09  mohor
// Addresses corrected to decimal values (previously hex).
//
// Revision 1.7  2003/01/10 17:51:34  mohor
// Temporary version (backup).
//
// Revision 1.6  2003/01/09 21:54:45  mohor
// rx fifo added. Not 100 % verified, yet.
//
// Revision 1.5  2003/01/08 02:10:56  mohor
// Acceptance filter added.
//
// Revision 1.4  2002/12/28 04:13:23  mohor
// Backup version.
//
// Revision 1.3  2002/12/27 00:12:52  mohor
// Header changed, testbench improved to send a frame (crc still missing).
//
// Revision 1.2  2002/12/26 16:00:34  mohor
// Testbench define file added. Clock divider register added.
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

module can_top
( 
  `ifdef CAN_WISHBONE_IF
    wb_clk_i,
    wb_rst_i,
    wb_dat_i,
    wb_dat_o,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_adr_i,
    wb_ack_o,
  `else
    rst_i,
    ale_i,
    rd_i,
    wr_i,
    port_0_io,
    cs_can_i,
  `endif
  clk_i,
  rx_i,
  tx_o,
  bus_off_on,
  irq_on,
  clkout_o

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  mbist_si_i,       // bist scan serial in
  mbist_so_o,       // bist scan serial out
  mbist_ctrl_i        // bist chain shift control
`endif
);

parameter Tp = 1;


`ifdef CAN_WISHBONE_IF
  input        wb_clk_i;
  input        wb_rst_i;
  input  [7:0] wb_dat_i;
  output [7:0] wb_dat_o;
  input        wb_cyc_i;
  input        wb_stb_i;
  input        wb_we_i;
  input  [7:0] wb_adr_i;
  output       wb_ack_o;

  reg          wb_ack_o;
  reg          cs_sync1;
  reg          cs_sync2;
  reg          cs_sync3;
  
  reg          cs_ack1;
  reg          cs_ack2;
  reg          cs_ack3;
  reg          cs_sync_rst1;
  reg          cs_sync_rst2;
  wire         cs_can_i;
`else
  input        rst_i;
  input        ale_i;
  input        rd_i;
  input        wr_i;
  inout  [7:0] port_0_io;
  input        cs_can_i;
  
  reg    [7:0] addr_latched;
  reg          wr_i_q;
  reg          rd_i_q;
`endif

input        clk_i;
input        rx_i;
output       tx_o;
output       bus_off_on;
output       irq_on;
output       clkout_o;

// Bist
`ifdef CAN_BIST
input   mbist_si_i;       // bist scan serial in
output  mbist_so_o;       // bist scan serial out
input [`CAN_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;       // bist chain shift control
`endif

reg          data_out_fifo_selected;


wire   [7:0] data_out_fifo;
wire   [7:0] data_out_regs;


/* Mode register */
wire         reset_mode;
wire         listen_only_mode;
wire         acceptance_filter_mode;
wire         self_test_mode;

/* Command register */
wire         release_buffer;
wire         tx_request;
wire         abort_tx;
wire         self_rx_request;
wire         single_shot_transmission;
wire         tx_state;
wire         tx_state_q;
wire         overload_request;
wire         overload_frame;


/* Arbitration Lost Capture Register */
wire         read_arbitration_lost_capture_reg;

/* Error Code Capture Register */
wire         read_error_code_capture_reg;
wire   [7:0] error_capture_code;

/* Bus Timing 0 register */
wire   [5:0] baud_r_presc;
wire   [1:0] sync_jump_width;

/* Bus Timing 1 register */
wire   [3:0] time_segment1;
wire   [2:0] time_segment2;
wire         triple_sampling;

/* Error Warning Limit register */
wire   [7:0] error_warning_limit;

/* Rx Error Counter register */
wire         we_rx_err_cnt;

/* Tx Error Counter register */
wire         we_tx_err_cnt;

/* Clock Divider register */
wire         extended_mode;

/* This section is for BASIC and EXTENDED mode */
/* Acceptance code register */
wire   [7:0] acceptance_code_0;

/* Acceptance mask register */
wire   [7:0] acceptance_mask_0;
/* End: This section is for BASIC and EXTENDED mode */


/* This section is for EXTENDED mode */
/* Acceptance code register */
wire   [7:0] acceptance_code_1;
wire   [7:0] acceptance_code_2;
wire   [7:0] acceptance_code_3;

/* Acceptance mask register */
wire   [7:0] acceptance_mask_1;
wire   [7:0] acceptance_mask_2;
wire   [7:0] acceptance_mask_3;
/* End: This section is for EXTENDED mode */

/* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
wire   [7:0] tx_data_0;
wire   [7:0] tx_data_1;
wire   [7:0] tx_data_2;
wire   [7:0] tx_data_3;
wire   [7:0] tx_data_4;
wire   [7:0] tx_data_5;
wire   [7:0] tx_data_6;
wire   [7:0] tx_data_7;
wire   [7:0] tx_data_8;
wire   [7:0] tx_data_9;
wire   [7:0] tx_data_10;
wire   [7:0] tx_data_11;
wire   [7:0] tx_data_12;
/* End: Tx data registers */

wire         cs;

/* Output signals from can_btl module */
wire         sample_point;
wire         sampled_bit;
wire         sampled_bit_q;
wire         tx_point;
wire         hard_sync;

/* output from can_bsp module */
wire         rx_idle;
wire         transmitting;
wire         transmitter;
wire         go_rx_inter;
wire         not_first_bit_of_inter;
wire         set_reset_mode;
wire         node_bus_off;
wire         error_status;
wire   [7:0] rx_err_cnt;
wire   [7:0] tx_err_cnt;
wire         rx_err_cnt_dummy;  // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
wire         tx_err_cnt_dummy;  // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
wire         transmit_status;
wire         receive_status;
wire         tx_successful;
wire         need_to_tx;
wire         overrun;
wire         info_empty;
wire         set_bus_error_irq;
wire         set_arbitration_lost_irq;
wire   [4:0] arbitration_lost_capture;
wire         node_error_passive;
wire         node_error_active;
wire   [6:0] rx_message_counter;
wire         tx_next;

wire         go_overload_frame;
wire         go_error_frame;
wire         go_tx;
wire         send_ack;

wire         rst;
wire         we;
wire   [7:0] addr;
wire   [7:0] data_in;
reg    [7:0] data_out;
reg          rx_sync_tmp;
reg          rx_sync;

/* Connecting can_registers module */
can_registers i_can_registers
( 
  .clk(clk_i),
  .rst(rst),
  .cs(cs),
  .we(we),
  .addr(addr),
  .data_in(data_in),
  .data_out(data_out_regs),
  .irq_n(irq_on),

  .sample_point(sample_point),
  .transmitting(transmitting),
  .set_reset_mode(set_reset_mode),
  .node_bus_off(node_bus_off),
  .error_status(error_status),
  .rx_err_cnt(rx_err_cnt),
  .tx_err_cnt(tx_err_cnt),
  .transmit_status(transmit_status),
  .receive_status(receive_status),
  .tx_successful(tx_successful),
  .need_to_tx(need_to_tx),
  .overrun(overrun),
  .info_empty(info_empty),
  .set_bus_error_irq(set_bus_error_irq),
  .set_arbitration_lost_irq(set_arbitration_lost_irq),
  .arbitration_lost_capture(arbitration_lost_capture),
  .node_error_passive(node_error_passive),
  .node_error_active(node_error_active),
  .rx_message_counter(rx_message_counter),


  /* Mode register */
  .reset_mode(reset_mode),
  .listen_only_mode(listen_only_mode),
  .acceptance_filter_mode(acceptance_filter_mode),
  .self_test_mode(self_test_mode),

  /* Command register */
  .clear_data_overrun(),
  .release_buffer(release_buffer),
  .abort_tx(abort_tx),
  .tx_request(tx_request),
  .self_rx_request(self_rx_request),
  .single_shot_transmission(single_shot_transmission),
  .tx_state(tx_state),
  .tx_state_q(tx_state_q),
  .overload_request(overload_request),
  .overload_frame(overload_frame),

  /* Arbitration Lost Capture Register */
  .read_arbitration_lost_capture_reg(read_arbitration_lost_capture_reg),

  /* Error Code Capture Register */
  .read_error_code_capture_reg(read_error_code_capture_reg),
  .error_capture_code(error_capture_code),

  /* Bus Timing 0 register */
  .baud_r_presc(baud_r_presc),
  .sync_jump_width(sync_jump_width),

  /* Bus Timing 1 register */
  .time_segment1(time_segment1),
  .time_segment2(time_segment2),
  .triple_sampling(triple_sampling),

  /* Error Warning Limit register */
  .error_warning_limit(error_warning_limit),

  /* Rx Error Counter register */
  .we_rx_err_cnt(we_rx_err_cnt),

  /* Tx Error Counter register */
  .we_tx_err_cnt(we_tx_err_cnt),

  /* Clock Divider register */
  .extended_mode(extended_mode),
  .clkout(clkout_o),
  
  /* This section is for BASIC and EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_0(acceptance_code_0),

  /* Acceptance mask register */
  .acceptance_mask_0(acceptance_mask_0),
  /* End: This section is for BASIC and EXTENDED mode */
  
  /* This section is for EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_1(acceptance_code_1),
  .acceptance_code_2(acceptance_code_2),
  .acceptance_code_3(acceptance_code_3),

  /* Acceptance mask register */
  .acceptance_mask_1(acceptance_mask_1),
  .acceptance_mask_2(acceptance_mask_2),
  .acceptance_mask_3(acceptance_mask_3),
  /* End: This section is for EXTENDED mode */

  /* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
  .tx_data_0(tx_data_0),
  .tx_data_1(tx_data_1),
  .tx_data_2(tx_data_2),
  .tx_data_3(tx_data_3),
  .tx_data_4(tx_data_4),
  .tx_data_5(tx_data_5),
  .tx_data_6(tx_data_6),
  .tx_data_7(tx_data_7),
  .tx_data_8(tx_data_8),
  .tx_data_9(tx_data_9),
  .tx_data_10(tx_data_10),
  .tx_data_11(tx_data_11),
  .tx_data_12(tx_data_12)
  /* End: Tx data registers */
);




/* Connecting can_btl module */
can_btl i_can_btl
( 
  .clk(clk_i),
  .rst(rst),
  .rx(rx_sync), 
  .tx(tx_o),

  /* Bus Timing 0 register */
  .baud_r_presc(baud_r_presc),
  .sync_jump_width(sync_jump_width),

  /* Bus Timing 1 register */
  .time_segment1(time_segment1),
  .time_segment2(time_segment2),
  .triple_sampling(triple_sampling),

  /* Output signals from this module */
  .sample_point(sample_point),
  .sampled_bit(sampled_bit),
  .sampled_bit_q(sampled_bit_q),
  .tx_point(tx_point),
  .hard_sync(hard_sync),

  
  /* output from can_bsp module */
  .rx_idle(rx_idle),
  .rx_inter(rx_inter),
  .transmitting(transmitting),
  .transmitter(transmitter),
  .go_rx_inter(go_rx_inter),
  .tx_next(tx_next),

  .go_overload_frame(go_overload_frame),
  .go_error_frame(go_error_frame),
  .go_tx(go_tx),
  .send_ack(send_ack),
  .node_error_passive(node_error_passive)
  


);



can_bsp i_can_bsp
(
  .clk(clk_i),
  .rst(rst),
  
  /* From btl module */
  .sample_point(sample_point),
  .sampled_bit(sampled_bit),
  .sampled_bit_q(sampled_bit_q),
  .tx_point(tx_point),
  .hard_sync(hard_sync),

  .addr(addr),
  .data_in(data_in),
  .data_out(data_out_fifo),
  .fifo_selected(data_out_fifo_selected),

  /* Mode register */
  .reset_mode(reset_mode),
  .listen_only_mode(listen_only_mode),
  .acceptance_filter_mode(acceptance_filter_mode),
  .self_test_mode(self_test_mode),
  
  /* Command register */
  .release_buffer(release_buffer),
  .tx_request(tx_request),
  .abort_tx(abort_tx),
  .self_rx_request(self_rx_request),
  .single_shot_transmission(single_shot_transmission),
  .tx_state(tx_state),
  .tx_state_q(tx_state_q),
  .overload_request(overload_request),
  .overload_frame(overload_frame),

  /* Arbitration Lost Capture Register */
  .read_arbitration_lost_capture_reg(read_arbitration_lost_capture_reg),

  /* Error Code Capture Register */
  .read_error_code_capture_reg(read_error_code_capture_reg),
  .error_capture_code(error_capture_code),

  /* Error Warning Limit register */
  .error_warning_limit(error_warning_limit),

  /* Rx Error Counter register */
  .we_rx_err_cnt(we_rx_err_cnt),

  /* Tx Error Counter register */
  .we_tx_err_cnt(we_tx_err_cnt),

  /* Clock Divider register */
  .extended_mode(extended_mode),

  /* output from can_bsp module */
  .rx_idle(rx_idle),
  .transmitting(transmitting),
  .transmitter(transmitter),
  .go_rx_inter(go_rx_inter),
  .not_first_bit_of_inter(not_first_bit_of_inter),
  .rx_inter(rx_inter),
  .set_reset_mode(set_reset_mode),
  .node_bus_off(node_bus_off),
  .error_status(error_status),
  .rx_err_cnt({rx_err_cnt_dummy, rx_err_cnt[7:0]}),   // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
  .tx_err_cnt({tx_err_cnt_dummy, tx_err_cnt[7:0]}),   // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
  .transmit_status(transmit_status),
  .receive_status(receive_status),
  .tx_successful(tx_successful),
  .need_to_tx(need_to_tx),
  .overrun(overrun),
  .info_empty(info_empty),
  .set_bus_error_irq(set_bus_error_irq),
  .set_arbitration_lost_irq(set_arbitration_lost_irq),
  .arbitration_lost_capture(arbitration_lost_capture),
  .node_error_passive(node_error_passive),
  .node_error_active(node_error_active),
  .rx_message_counter(rx_message_counter),
  
  /* This section is for BASIC and EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_0(acceptance_code_0),

  /* Acceptance mask register */
  .acceptance_mask_0(acceptance_mask_0),
  /* End: This section is for BASIC and EXTENDED mode */
  
  /* This section is for EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_1(acceptance_code_1),
  .acceptance_code_2(acceptance_code_2),
  .acceptance_code_3(acceptance_code_3),

  /* Acceptance mask register */
  .acceptance_mask_1(acceptance_mask_1),
  .acceptance_mask_2(acceptance_mask_2),
  .acceptance_mask_3(acceptance_mask_3),
  /* End: This section is for EXTENDED mode */

  /* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
  .tx_data_0(tx_data_0),
  .tx_data_1(tx_data_1),
  .tx_data_2(tx_data_2),
  .tx_data_3(tx_data_3),
  .tx_data_4(tx_data_4),
  .tx_data_5(tx_data_5),
  .tx_data_6(tx_data_6),
  .tx_data_7(tx_data_7),
  .tx_data_8(tx_data_8),
  .tx_data_9(tx_data_9),
  .tx_data_10(tx_data_10),
  .tx_data_11(tx_data_11),
  .tx_data_12(tx_data_12),
  /* End: Tx data registers */
  
  /* Tx signal */
  .tx(tx_o),
  .tx_next(tx_next),
  .bus_off_on(bus_off_on),

  .go_overload_frame(go_overload_frame),
  .go_error_frame(go_error_frame),
  .go_tx(go_tx),
  .send_ack(send_ack)


`ifdef CAN_BIST
  ,
  /* BIST signals */
  .mbist_si_i(mbist_si_i),
  .mbist_so_o(mbist_so_o),
  .mbist_ctrl_i(mbist_ctrl_i)
`endif
);



// Multiplexing wb_dat_o from registers and rx fifo
always @ (extended_mode or addr or reset_mode)
begin
  if (extended_mode & (~reset_mode) & ((addr >= 8'd16) && (addr <= 8'd28)) | (~extended_mode) & ((addr >= 8'd20) && (addr <= 8'd29)))
    data_out_fifo_selected = 1'b1;
  else
    data_out_fifo_selected = 1'b0;
end


always @ (posedge clk_i)
begin
  if (cs & (~we))
    begin
      if (data_out_fifo_selected)
        data_out <=#Tp data_out_fifo;
      else
        data_out <=#Tp data_out_regs;
    end
end



always @ (posedge clk_i or posedge rst)
begin
  if (rst)
    begin
      rx_sync_tmp <= 1'b1;
      rx_sync     <= 1'b1;
    end
  else
    begin
      rx_sync_tmp <=#Tp rx_i;
      rx_sync     <=#Tp rx_sync_tmp;
    end
end



`ifdef CAN_WISHBONE_IF

  assign cs_can_i = 1'b1;

  // Combining wb_cyc_i and wb_stb_i signals to cs signal. Than synchronizing to clk_i clock domain. 
  always @ (posedge clk_i or posedge rst)
  begin
    if (rst)
      begin
        cs_sync1     <= 1'b0;
        cs_sync2     <= 1'b0;
        cs_sync3     <= 1'b0;
        cs_sync_rst1 <= 1'b0;
        cs_sync_rst2 <= 1'b0;
      end
    else
      begin
        cs_sync1     <=#Tp wb_cyc_i & wb_stb_i & (~cs_sync_rst2) & cs_can_i;
        cs_sync2     <=#Tp cs_sync1            & (~cs_sync_rst2);
        cs_sync3     <=#Tp cs_sync2            & (~cs_sync_rst2);
        cs_sync_rst1 <=#Tp cs_ack3;
        cs_sync_rst2 <=#Tp cs_sync_rst1;
      end
  end
  
  
  assign cs = cs_sync2 & (~cs_sync3);
  
  
  always @ (posedge wb_clk_i)
  begin
    cs_ack1 <=#Tp cs_sync3;
    cs_ack2 <=#Tp cs_ack1;
    cs_ack3 <=#Tp cs_ack2;
  end
  
  
  
  // Generating acknowledge signal
  always @ (posedge wb_clk_i)
  begin
    wb_ack_o <=#Tp (cs_ack2 & (~cs_ack3));
  end


  assign rst      = wb_rst_i;
  assign we       = wb_we_i;
  assign addr     = wb_adr_i;
  assign data_in  = wb_dat_i;
  assign wb_dat_o = data_out;


`else

  // Latching address
  always @ (posedge clk_i or posedge rst)
  begin
    if (rst)
      addr_latched <= 8'h0;
    else if (ale_i)
      addr_latched <=#Tp port_0_io;
  end


  // Generating delayed wr_i and rd_i signals
  always @ (posedge clk_i or posedge rst)
  begin
    if (rst)
      begin
        wr_i_q <= 1'b0;
        rd_i_q <= 1'b0;
      end
    else
      begin
        wr_i_q <=#Tp wr_i;
        rd_i_q <=#Tp rd_i;
      end
  end


  assign cs = ((wr_i & (~wr_i_q)) | (rd_i & (~rd_i_q))) & cs_can_i;


  assign rst       = rst_i;
  assign we        = wr_i;
  assign addr      = addr_latched;
  assign data_in   = port_0_io;
  assign port_0_io = (cs_can_i & rd_i)? data_out : 8'hz;

`endif


endmodule
