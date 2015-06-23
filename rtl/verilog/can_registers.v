//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_registers.v                                             ////
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
//// Copyright (C) 2002, 2003 Authors                             ////
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
// Revision 1.35  2004/11/30 15:08:26  igorm
// irq is cleared after the release_buffer command. This bug was entered with
// changes for the edge triggered interrupts.
//
// Revision 1.34  2004/11/18 12:39:43  igorm
// Fixes for compatibility after the SW reset.
//
// Revision 1.33  2004/10/25 11:44:38  igorm
// Interrupt is always cleared for one clock after the irq register is read.
// This fixes problems when CPU is using IRQs that are edge triggered.
//
// Revision 1.32  2004/05/12 15:58:41  igorm
// Core improved to pass all tests with the Bosch VHDL Reference system.
//
// Revision 1.31  2003/09/25 18:55:49  mohor
// Synchronization changed, error counters fixed.
//
// Revision 1.30  2003/07/16 15:19:34  mohor
// Fixed according to the linter.
// Case statement for data_out joined.
//
// Revision 1.29  2003/07/10 01:59:04  tadejm
// Synchronization fixed. In some strange cases it didn't work according to
// the VHDL reference model.
//
// Revision 1.28  2003/07/07 11:21:37  mohor
// Little fixes (to fix warnings).
//
// Revision 1.27  2003/06/22 09:43:03  mohor
// synthesi full_case parallel_case fixed.
//
// Revision 1.26  2003/06/22 01:33:14  mohor
// clkout is clk/2 after the reset.
//
// Revision 1.25  2003/06/21 12:16:30  mohor
// paralel_case and full_case compiler directives added to case statements.
//
// Revision 1.24  2003/06/09 11:22:54  mohor
// data_out is already registered in the can_top.v file.
//
// Revision 1.23  2003/04/15 15:31:24  mohor
// Some features are supported in extended mode only (listen_only_mode...).
//
// Revision 1.22  2003/03/20 16:58:50  mohor
// unix.
//
// Revision 1.20  2003/03/11 16:31:05  mohor
// Mux used for clkout to avoid "gated clocks warning".
//
// Revision 1.19  2003/03/10 17:34:25  mohor
// Doubled declarations removed.
//
// Revision 1.18  2003/03/01 22:52:11  mohor
// Data is latched on read.
//
// Revision 1.17  2003/02/19 15:09:02  mohor
// Incomplete sensitivity list fixed.
//
// Revision 1.16  2003/02/19 14:44:03  mohor
// CAN core finished. Host interface added. Registers finished.
// Synchronization to the wishbone finished.
//
// Revision 1.15  2003/02/18 00:10:15  mohor
// Most of the registers added. Registers "arbitration lost capture", "error code
// capture" + few more still need to be added.
//
// Revision 1.14  2003/02/14 20:17:01  mohor
// Several registers added. Not finished, yet.
//
// Revision 1.13  2003/02/12 14:25:30  mohor
// abort_tx added.
//
// Revision 1.12  2003/02/11 00:56:06  mohor
// Wishbone interface added.
//
// Revision 1.11  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.10  2003/01/31 01:13:38  mohor
// backup.
//
// Revision 1.9  2003/01/15 13:16:48  mohor
// When a frame with "remote request" is received, no data is stored
// to fifo, just the frame information (identifier, ...). Data length
// that is stored is the received data length and not the actual data
// length that is stored to fifo.
//
// Revision 1.8  2003/01/14 17:25:09  mohor
// Addresses corrected to decimal values (previously hex).
//
// Revision 1.7  2003/01/14 12:19:35  mohor
// rx_fifo is now working.
//
// Revision 1.6  2003/01/10 17:51:34  mohor
// Temporary version (backup).
//
// Revision 1.5  2003/01/09 14:46:58  mohor
// Temporary files (backup).
//
// Revision 1.4  2003/01/08 02:10:55  mohor
// Acceptance filter added.
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

module can_registers
( 
  clk,
  rst,
  cs,
  we,
  addr,
  data_in,
  data_out,
  irq_n,

  sample_point,
  transmitting,
  set_reset_mode,
  node_bus_off,
  error_status,
  rx_err_cnt,
  tx_err_cnt,
  transmit_status,
  receive_status,
  tx_successful,
  need_to_tx,
  overrun,
  info_empty,
  set_bus_error_irq,
  set_arbitration_lost_irq,
  arbitration_lost_capture,
  node_error_passive,
  node_error_active,
  rx_message_counter,


  /* Mode register */
  reset_mode,
  listen_only_mode,
  acceptance_filter_mode,
  self_test_mode,


  /* Command register */
  clear_data_overrun,
  release_buffer,
  abort_tx,
  tx_request,
  self_rx_request,
  single_shot_transmission,
  tx_state,
  tx_state_q,
  overload_request,
  overload_frame,

  /* Arbitration Lost Capture Register */
  read_arbitration_lost_capture_reg,

  /* Error Code Capture Register */
  read_error_code_capture_reg,
  error_capture_code,

  /* Bus Timing 0 register */
  baud_r_presc,
  sync_jump_width,

  /* Bus Timing 1 register */
  time_segment1,
  time_segment2,
  triple_sampling,
  
  /* Error Warning Limit register */
  error_warning_limit,

  /* Rx Error Counter register */
  we_rx_err_cnt,

  /* Tx Error Counter register */
  we_tx_err_cnt,

  /* Clock Divider register */
  extended_mode,
  clkout,
  
  
  /* This section is for BASIC and EXTENDED mode */
  /* Acceptance code register */
  acceptance_code_0,

  /* Acceptance mask register */
  acceptance_mask_0,
  /* End: This section is for BASIC and EXTENDED mode */
  
  /* This section is for EXTENDED mode */
  /* Acceptance code register */
  acceptance_code_1,
  acceptance_code_2,
  acceptance_code_3,

  /* Acceptance mask register */
  acceptance_mask_1,
  acceptance_mask_2,
  acceptance_mask_3,
  /* End: This section is for EXTENDED mode */
  
  /* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
  tx_data_0,
  tx_data_1,
  tx_data_2,
  tx_data_3,
  tx_data_4,
  tx_data_5,
  tx_data_6,
  tx_data_7,
  tx_data_8,
  tx_data_9,
  tx_data_10,
  tx_data_11,
  tx_data_12
  /* End: Tx data registers */
  
  


);

parameter Tp = 1;

input         clk;
input         rst;
input         cs;
input         we;
input   [7:0] addr;
input   [7:0] data_in;

output  [7:0] data_out;
reg     [7:0] data_out;

output        irq_n;

input         sample_point;
input         transmitting;
input         set_reset_mode;
input         node_bus_off;
input         error_status;
input   [7:0] rx_err_cnt;
input   [7:0] tx_err_cnt;
input         transmit_status;
input         receive_status;
input         tx_successful;
input         need_to_tx;
input         overrun;
input         info_empty;
input         set_bus_error_irq;
input         set_arbitration_lost_irq;
input   [4:0] arbitration_lost_capture;
input         node_error_passive;
input         node_error_active;
input   [6:0] rx_message_counter;



/* Mode register */
output        reset_mode;
output        listen_only_mode;
output        acceptance_filter_mode;
output        self_test_mode;

/* Command register */
output        clear_data_overrun;
output        release_buffer;
output        abort_tx;
output        tx_request;
output        self_rx_request;
output        single_shot_transmission;
input         tx_state;
input         tx_state_q;
output        overload_request;
input         overload_frame;


/* Arbitration Lost Capture Register */
output        read_arbitration_lost_capture_reg;

/* Error Code Capture Register */
output        read_error_code_capture_reg;
input   [7:0] error_capture_code;

/* Bus Timing 0 register */
output  [5:0] baud_r_presc;
output  [1:0] sync_jump_width;


/* Bus Timing 1 register */
output  [3:0] time_segment1;
output  [2:0] time_segment2;
output        triple_sampling;

/* Error Warning Limit register */
output  [7:0] error_warning_limit;

/* Rx Error Counter register */
output        we_rx_err_cnt;

/* Tx Error Counter register */
output        we_tx_err_cnt;

/* Clock Divider register */
output        extended_mode;
output        clkout;


/* This section is for BASIC and EXTENDED mode */
/* Acceptance code register */
output  [7:0] acceptance_code_0;

/* Acceptance mask register */
output  [7:0] acceptance_mask_0;

/* End: This section is for BASIC and EXTENDED mode */


/* This section is for EXTENDED mode */
/* Acceptance code register */
output  [7:0] acceptance_code_1;
output  [7:0] acceptance_code_2;
output  [7:0] acceptance_code_3;

/* Acceptance mask register */
output  [7:0] acceptance_mask_1;
output  [7:0] acceptance_mask_2;
output  [7:0] acceptance_mask_3;

/* End: This section is for EXTENDED mode */

/* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
output  [7:0] tx_data_0;
output  [7:0] tx_data_1;
output  [7:0] tx_data_2;
output  [7:0] tx_data_3;
output  [7:0] tx_data_4;
output  [7:0] tx_data_5;
output  [7:0] tx_data_6;
output  [7:0] tx_data_7;
output  [7:0] tx_data_8;
output  [7:0] tx_data_9;
output  [7:0] tx_data_10;
output  [7:0] tx_data_11;
output  [7:0] tx_data_12;
/* End: Tx data registers */


reg           tx_successful_q;
reg           overrun_q;
reg           overrun_status;
reg           transmission_complete;
reg           transmit_buffer_status_q;
reg           receive_buffer_status;
reg           error_status_q;
reg           node_bus_off_q;
reg           node_error_passive_q;
reg           transmit_buffer_status;
reg           single_shot_transmission;
reg           self_rx_request;
reg           irq_n;

// Some interrupts exist in basic mode and in extended mode. Since they are in different registers they need to be multiplexed.
wire          data_overrun_irq_en;
wire          error_warning_irq_en;
wire          transmit_irq_en;
wire          receive_irq_en;

wire    [7:0] irq_reg;
wire          irq;

wire we_mode                  = cs & we & (addr == 8'd0);
wire we_command               = cs & we & (addr == 8'd1);
wire we_bus_timing_0          = cs & we & (addr == 8'd6) & reset_mode;
wire we_bus_timing_1          = cs & we & (addr == 8'd7) & reset_mode;
wire we_clock_divider_low     = cs & we & (addr == 8'd31);
wire we_clock_divider_hi      = we_clock_divider_low & reset_mode;

wire read = cs & (~we);
wire read_irq_reg = read & (addr == 8'd3);
assign read_arbitration_lost_capture_reg = read & extended_mode & (addr == 8'd11);
assign read_error_code_capture_reg = read & extended_mode & (addr == 8'd12);

/* This section is for BASIC and EXTENDED mode */
wire we_acceptance_code_0       = cs & we &   reset_mode  & ((~extended_mode) & (addr == 8'd4)  | extended_mode & (addr == 8'd16));
wire we_acceptance_mask_0       = cs & we &   reset_mode  & ((~extended_mode) & (addr == 8'd5)  | extended_mode & (addr == 8'd20));
wire we_tx_data_0               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd10) | extended_mode & (addr == 8'd16)) & transmit_buffer_status;
wire we_tx_data_1               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd11) | extended_mode & (addr == 8'd17)) & transmit_buffer_status;
wire we_tx_data_2               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd12) | extended_mode & (addr == 8'd18)) & transmit_buffer_status;
wire we_tx_data_3               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd13) | extended_mode & (addr == 8'd19)) & transmit_buffer_status;
wire we_tx_data_4               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd14) | extended_mode & (addr == 8'd20)) & transmit_buffer_status;
wire we_tx_data_5               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd15) | extended_mode & (addr == 8'd21)) & transmit_buffer_status;
wire we_tx_data_6               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd16) | extended_mode & (addr == 8'd22)) & transmit_buffer_status;
wire we_tx_data_7               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd17) | extended_mode & (addr == 8'd23)) & transmit_buffer_status;
wire we_tx_data_8               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd18) | extended_mode & (addr == 8'd24)) & transmit_buffer_status;
wire we_tx_data_9               = cs & we & (~reset_mode) & ((~extended_mode) & (addr == 8'd19) | extended_mode & (addr == 8'd25)) & transmit_buffer_status;
wire we_tx_data_10              = cs & we & (~reset_mode) & (                                     extended_mode & (addr == 8'd26)) & transmit_buffer_status;
wire we_tx_data_11              = cs & we & (~reset_mode) & (                                     extended_mode & (addr == 8'd27)) & transmit_buffer_status;
wire we_tx_data_12              = cs & we & (~reset_mode) & (                                     extended_mode & (addr == 8'd28)) & transmit_buffer_status;
/* End: This section is for BASIC and EXTENDED mode */


/* This section is for EXTENDED mode */
wire   we_interrupt_enable      = cs & we & (addr == 8'd4)  & extended_mode;
wire   we_error_warning_limit   = cs & we & (addr == 8'd13) & reset_mode & extended_mode;
assign we_rx_err_cnt            = cs & we & (addr == 8'd14) & reset_mode & extended_mode;
assign we_tx_err_cnt            = cs & we & (addr == 8'd15) & reset_mode & extended_mode;
wire   we_acceptance_code_1     = cs & we & (addr == 8'd17) & reset_mode & extended_mode;
wire   we_acceptance_code_2     = cs & we & (addr == 8'd18) & reset_mode & extended_mode;
wire   we_acceptance_code_3     = cs & we & (addr == 8'd19) & reset_mode & extended_mode;
wire   we_acceptance_mask_1     = cs & we & (addr == 8'd21) & reset_mode & extended_mode;
wire   we_acceptance_mask_2     = cs & we & (addr == 8'd22) & reset_mode & extended_mode;
wire   we_acceptance_mask_3     = cs & we & (addr == 8'd23) & reset_mode & extended_mode;
/* End: This section is for EXTENDED mode */



always @ (posedge clk)
begin
  tx_successful_q           <=#Tp tx_successful;
  overrun_q                 <=#Tp overrun;
  transmit_buffer_status_q  <=#Tp transmit_buffer_status;
  error_status_q            <=#Tp error_status;
  node_bus_off_q            <=#Tp node_bus_off;
  node_error_passive_q      <=#Tp node_error_passive;
end



/* Mode register */
wire   [0:0] mode;
wire   [4:1] mode_basic;
wire   [3:1] mode_ext;
wire         receive_irq_en_basic;
wire         transmit_irq_en_basic;
wire         error_irq_en_basic;
wire         overrun_irq_en_basic;

can_register_asyn_syn #(1, 1'h1) MODE_REG0
( .data_in(data_in[0]),
  .data_out(mode[0]),
  .we(we_mode),
  .clk(clk),
  .rst(rst),
  .rst_sync(set_reset_mode)
);

can_register_asyn #(4, 0) MODE_REG_BASIC
( .data_in(data_in[4:1]),
  .data_out(mode_basic[4:1]),
  .we(we_mode),
  .clk(clk),
  .rst(rst)
);

can_register_asyn #(3, 0) MODE_REG_EXT
( .data_in(data_in[3:1]),
  .data_out(mode_ext[3:1]),
  .we(we_mode & reset_mode),
  .clk(clk),
  .rst(rst)
);

assign reset_mode             = mode[0];
assign listen_only_mode       = extended_mode & mode_ext[1];
assign self_test_mode         = extended_mode & mode_ext[2];
assign acceptance_filter_mode = extended_mode & mode_ext[3];

assign receive_irq_en_basic  = mode_basic[1];
assign transmit_irq_en_basic = mode_basic[2];
assign error_irq_en_basic    = mode_basic[3];
assign overrun_irq_en_basic  = mode_basic[4];
/* End Mode register */


/* Command register */
wire   [4:0] command;
can_register_asyn_syn #(1, 1'h0) COMMAND_REG0
( .data_in(data_in[0]),
  .data_out(command[0]),
  .we(we_command),
  .clk(clk),
  .rst(rst),
  .rst_sync(command[0] & sample_point | reset_mode)
);

can_register_asyn_syn #(1, 1'h0) COMMAND_REG1
( .data_in(data_in[1]),
  .data_out(command[1]),
  .we(we_command),
  .clk(clk),
  .rst(rst),
  .rst_sync(sample_point & (tx_request | (abort_tx & ~transmitting)) | reset_mode)
);

can_register_asyn_syn #(2, 2'h0) COMMAND_REG
( .data_in(data_in[3:2]),
  .data_out(command[3:2]),
  .we(we_command),
  .clk(clk),
  .rst(rst),
  .rst_sync(|command[3:2] | reset_mode)
);

can_register_asyn_syn #(1, 1'h0) COMMAND_REG4
( .data_in(data_in[4]),
  .data_out(command[4]),
  .we(we_command),
  .clk(clk),
  .rst(rst),
  .rst_sync(command[4] & sample_point | reset_mode)
);


always @ (posedge clk or posedge rst)
begin
  if (rst)
    self_rx_request <= 1'b0;
  else if (command[4] & (~command[0]))
    self_rx_request <=#Tp 1'b1;
  else if ((~tx_state) & tx_state_q)
    self_rx_request <=#Tp 1'b0;
end


assign clear_data_overrun = command[3];
assign release_buffer = command[2];
assign tx_request = command[0] | command[4];
assign abort_tx = command[1] & (~tx_request);


always @ (posedge clk or posedge rst)
begin
  if (rst)
    single_shot_transmission <= 1'b0;
  else if (tx_request & command[1] & sample_point)
    single_shot_transmission <=#Tp 1'b1;
  else if ((~tx_state) & tx_state_q)
    single_shot_transmission <=#Tp 1'b0;
end


/*
can_register_asyn_syn #(1, 1'h0) COMMAND_REG_OVERLOAD  // Uncomment this to enable overload requests !!!
( .data_in(data_in[5]),
  .data_out(overload_request),
  .we(we_command),
  .clk(clk),
  .rst(rst),
  .rst_sync(overload_frame & ~overload_frame_q)
);

reg           overload_frame_q;

always @ (posedge clk or posedge rst)
begin
  if (rst)
    overload_frame_q <= 1'b0;
  else
    overload_frame_q <=#Tp overload_frame;
end
*/
assign overload_request = 0;  // Overload requests are not supported, yet !!!





/* End Command register */


/* Status register */

wire   [7:0] status;

assign status[7] = node_bus_off;
assign status[6] = error_status;
assign status[5] = transmit_status;
assign status[4] = receive_status;
assign status[3] = transmission_complete;
assign status[2] = transmit_buffer_status;
assign status[1] = overrun_status;
assign status[0] = receive_buffer_status;



always @ (posedge clk or posedge rst)
begin
  if (rst)
    transmission_complete <= 1'b1;
  else if (tx_successful & (~tx_successful_q) | abort_tx)
    transmission_complete <=#Tp 1'b1;
  else if (tx_request)
    transmission_complete <=#Tp 1'b0;
end


always @ (posedge clk or posedge rst)
begin
  if (rst)
    transmit_buffer_status <= 1'b1;
  else if (tx_request)
    transmit_buffer_status <=#Tp 1'b0;
  else if (reset_mode || !need_to_tx)
    transmit_buffer_status <=#Tp 1'b1;
end


always @ (posedge clk or posedge rst)
begin
  if (rst)
    overrun_status <= 1'b0;
  else if (overrun & (~overrun_q))
    overrun_status <=#Tp 1'b1;
  else if (reset_mode || clear_data_overrun)
    overrun_status <=#Tp 1'b0;
end


always @ (posedge clk or posedge rst)
begin
  if (rst)
    receive_buffer_status <= 1'b0;
  else if (reset_mode || release_buffer)
    receive_buffer_status <=#Tp 1'b0;
  else if (~info_empty)
    receive_buffer_status <=#Tp 1'b1;
end

/* End Status register */


/* Interrupt Enable register (extended mode) */
wire   [7:0] irq_en_ext;
wire         bus_error_irq_en;
wire         arbitration_lost_irq_en;
wire         error_passive_irq_en;
wire         data_overrun_irq_en_ext;
wire         error_warning_irq_en_ext;
wire         transmit_irq_en_ext;
wire         receive_irq_en_ext;

can_register #(8) IRQ_EN_REG
( .data_in(data_in),
  .data_out(irq_en_ext),
  .we(we_interrupt_enable),
  .clk(clk)
);


assign bus_error_irq_en             = irq_en_ext[7];
assign arbitration_lost_irq_en      = irq_en_ext[6];
assign error_passive_irq_en         = irq_en_ext[5];
assign data_overrun_irq_en_ext      = irq_en_ext[3];
assign error_warning_irq_en_ext     = irq_en_ext[2];
assign transmit_irq_en_ext          = irq_en_ext[1];
assign receive_irq_en_ext           = irq_en_ext[0];
/* End Bus Timing 0 register */


/* Bus Timing 0 register */
wire   [7:0] bus_timing_0;
can_register #(8) BUS_TIMING_0_REG
( .data_in(data_in),
  .data_out(bus_timing_0),
  .we(we_bus_timing_0),
  .clk(clk)
);

assign baud_r_presc = bus_timing_0[5:0];
assign sync_jump_width = bus_timing_0[7:6];
/* End Bus Timing 0 register */


/* Bus Timing 1 register */
wire   [7:0] bus_timing_1;
can_register #(8) BUS_TIMING_1_REG
( .data_in(data_in),
  .data_out(bus_timing_1),
  .we(we_bus_timing_1),
  .clk(clk)
);

assign time_segment1 = bus_timing_1[3:0];
assign time_segment2 = bus_timing_1[6:4];
assign triple_sampling = bus_timing_1[7];
/* End Bus Timing 1 register */


/* Error Warning Limit register */
can_register_asyn #(8, 96) ERROR_WARNING_REG
( .data_in(data_in),
  .data_out(error_warning_limit),
  .we(we_error_warning_limit),
  .clk(clk),
  .rst(rst)
);
/* End Error Warning Limit register */



/* Clock Divider register */
wire   [7:0] clock_divider;
wire         clock_off;
wire   [2:0] cd;
reg    [2:0] clkout_div;
reg    [2:0] clkout_cnt;
reg          clkout_tmp;

can_register_asyn #(1, 0) CLOCK_DIVIDER_REG_7
( .data_in(data_in[7]),
  .data_out(clock_divider[7]),
  .we(we_clock_divider_hi),
  .clk(clk),
  .rst(rst)
);

assign clock_divider[6:4] = 3'h0;

can_register_asyn #(1, 0) CLOCK_DIVIDER_REG_3
( .data_in(data_in[3]),
  .data_out(clock_divider[3]),
  .we(we_clock_divider_hi),
  .clk(clk),
  .rst(rst)
);

can_register_asyn #(3, 0) CLOCK_DIVIDER_REG_LOW
( .data_in(data_in[2:0]),
  .data_out(clock_divider[2:0]),
  .we(we_clock_divider_low),
  .clk(clk),
  .rst(rst)
);

assign extended_mode = clock_divider[7];
assign clock_off     = clock_divider[3];
assign cd[2:0]       = clock_divider[2:0];



always @ (cd)
begin
  case (cd)                       /* synthesis full_case parallel_case */ 
    3'b000 : clkout_div = 3'd0;
    3'b001 : clkout_div = 3'd1;
    3'b010 : clkout_div = 3'd2;
    3'b011 : clkout_div = 3'd3;
    3'b100 : clkout_div = 3'd4;
    3'b101 : clkout_div = 3'd5;
    3'b110 : clkout_div = 3'd6;
    3'b111 : clkout_div = 3'd0;
  endcase
end



always @ (posedge clk or posedge rst)
begin
  if (rst)
    clkout_cnt <= 3'h0;
  else if (clkout_cnt == clkout_div)
    clkout_cnt <=#Tp 3'h0;
  else
    clkout_cnt <= clkout_cnt + 1'b1;
end



always @ (posedge clk or posedge rst)
begin
  if (rst)
    clkout_tmp <= 1'b0;
  else if (clkout_cnt == clkout_div)
    clkout_tmp <=#Tp ~clkout_tmp;
end


assign clkout = clock_off ? 1'b1 : ((&cd)? clk : clkout_tmp);



/* End Clock Divider register */




/* This section is for BASIC and EXTENDED mode */

/* Acceptance code register */
can_register #(8) ACCEPTANCE_CODE_REG0
( .data_in(data_in),
  .data_out(acceptance_code_0),
  .we(we_acceptance_code_0),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance mask register */
can_register #(8) ACCEPTANCE_MASK_REG0
( .data_in(data_in),
  .data_out(acceptance_mask_0),
  .we(we_acceptance_mask_0),
  .clk(clk)
);
/* End: Acceptance mask register */
/* End: This section is for BASIC and EXTENDED mode */


/* Tx data 0 register. */
can_register #(8) TX_DATA_REG0
( .data_in(data_in),
  .data_out(tx_data_0),
  .we(we_tx_data_0),
  .clk(clk)
);
/* End: Tx data 0 register. */


/* Tx data 1 register. */
can_register #(8) TX_DATA_REG1
( .data_in(data_in),
  .data_out(tx_data_1),
  .we(we_tx_data_1),
  .clk(clk)
);
/* End: Tx data 1 register. */


/* Tx data 2 register. */
can_register #(8) TX_DATA_REG2
( .data_in(data_in),
  .data_out(tx_data_2),
  .we(we_tx_data_2),
  .clk(clk)
);
/* End: Tx data 2 register. */


/* Tx data 3 register. */
can_register #(8) TX_DATA_REG3
( .data_in(data_in),
  .data_out(tx_data_3),
  .we(we_tx_data_3),
  .clk(clk)
);
/* End: Tx data 3 register. */


/* Tx data 4 register. */
can_register #(8) TX_DATA_REG4
( .data_in(data_in),
  .data_out(tx_data_4),
  .we(we_tx_data_4),
  .clk(clk)
);
/* End: Tx data 4 register. */


/* Tx data 5 register. */
can_register #(8) TX_DATA_REG5
( .data_in(data_in),
  .data_out(tx_data_5),
  .we(we_tx_data_5),
  .clk(clk)
);
/* End: Tx data 5 register. */


/* Tx data 6 register. */
can_register #(8) TX_DATA_REG6
( .data_in(data_in),
  .data_out(tx_data_6),
  .we(we_tx_data_6),
  .clk(clk)
);
/* End: Tx data 6 register. */


/* Tx data 7 register. */
can_register #(8) TX_DATA_REG7
( .data_in(data_in),
  .data_out(tx_data_7),
  .we(we_tx_data_7),
  .clk(clk)
);
/* End: Tx data 7 register. */


/* Tx data 8 register. */
can_register #(8) TX_DATA_REG8
( .data_in(data_in),
  .data_out(tx_data_8),
  .we(we_tx_data_8),
  .clk(clk)
);
/* End: Tx data 8 register. */


/* Tx data 9 register. */
can_register #(8) TX_DATA_REG9
( .data_in(data_in),
  .data_out(tx_data_9),
  .we(we_tx_data_9),
  .clk(clk)
);
/* End: Tx data 9 register. */


/* Tx data 10 register. */
can_register #(8) TX_DATA_REG10
( .data_in(data_in),
  .data_out(tx_data_10),
  .we(we_tx_data_10),
  .clk(clk)
);
/* End: Tx data 10 register. */


/* Tx data 11 register. */
can_register #(8) TX_DATA_REG11
( .data_in(data_in),
  .data_out(tx_data_11),
  .we(we_tx_data_11),
  .clk(clk)
);
/* End: Tx data 11 register. */


/* Tx data 12 register. */
can_register #(8) TX_DATA_REG12
( .data_in(data_in),
  .data_out(tx_data_12),
  .we(we_tx_data_12),
  .clk(clk)
);
/* End: Tx data 12 register. */





/* This section is for EXTENDED mode */

/* Acceptance code register 1 */
can_register #(8) ACCEPTANCE_CODE_REG1
( .data_in(data_in),
  .data_out(acceptance_code_1),
  .we(we_acceptance_code_1),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance code register 2 */
can_register #(8) ACCEPTANCE_CODE_REG2
( .data_in(data_in),
  .data_out(acceptance_code_2),
  .we(we_acceptance_code_2),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance code register 3 */
can_register #(8) ACCEPTANCE_CODE_REG3
( .data_in(data_in),
  .data_out(acceptance_code_3),
  .we(we_acceptance_code_3),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance mask register 1 */
can_register #(8) ACCEPTANCE_MASK_REG1
( .data_in(data_in),
  .data_out(acceptance_mask_1),
  .we(we_acceptance_mask_1),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance mask register 2 */
can_register #(8) ACCEPTANCE_MASK_REG2
( .data_in(data_in),
  .data_out(acceptance_mask_2),
  .we(we_acceptance_mask_2),
  .clk(clk)
);
/* End: Acceptance code register */


/* Acceptance mask register 3 */
can_register #(8) ACCEPTANCE_MASK_REG3
( .data_in(data_in),
  .data_out(acceptance_mask_3),
  .we(we_acceptance_mask_3),
  .clk(clk)
);
/* End: Acceptance code register */


/* End: This section is for EXTENDED mode */




// Reading data from registers
always @ ( addr or extended_mode or mode or bus_timing_0 or bus_timing_1 or clock_divider or
           acceptance_code_0 or acceptance_code_1 or acceptance_code_2 or acceptance_code_3 or
           acceptance_mask_0 or acceptance_mask_1 or acceptance_mask_2 or acceptance_mask_3 or
           reset_mode or tx_data_0 or tx_data_1 or tx_data_2 or tx_data_3 or tx_data_4 or 
           tx_data_5 or tx_data_6 or tx_data_7 or tx_data_8 or tx_data_9 or status or 
           error_warning_limit or rx_err_cnt or tx_err_cnt or irq_en_ext or irq_reg or mode_ext or
           arbitration_lost_capture or rx_message_counter or mode_basic or error_capture_code
         )
begin
  case({extended_mode, addr[4:0]})  /* synthesis parallel_case */ 
    {1'h1, 5'd00} :  data_out = {4'b0000, mode_ext[3:1], mode[0]};      // extended mode
    {1'h1, 5'd01} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd02} :  data_out = status;                                 // extended mode
    {1'h1, 5'd03} :  data_out = irq_reg;                                // extended mode
    {1'h1, 5'd04} :  data_out = irq_en_ext;                             // extended mode
    {1'h1, 5'd06} :  data_out = bus_timing_0;                           // extended mode
    {1'h1, 5'd07} :  data_out = bus_timing_1;                           // extended mode
    {1'h1, 5'd11} :  data_out = {3'h0, arbitration_lost_capture[4:0]};  // extended mode
    {1'h1, 5'd12} :  data_out = error_capture_code;                     // extended mode
    {1'h1, 5'd13} :  data_out = error_warning_limit;                    // extended mode
    {1'h1, 5'd14} :  data_out = rx_err_cnt;                             // extended mode
    {1'h1, 5'd15} :  data_out = tx_err_cnt;                             // extended mode
    {1'h1, 5'd16} :  data_out = acceptance_code_0;                      // extended mode
    {1'h1, 5'd17} :  data_out = acceptance_code_1;                      // extended mode
    {1'h1, 5'd18} :  data_out = acceptance_code_2;                      // extended mode
    {1'h1, 5'd19} :  data_out = acceptance_code_3;                      // extended mode
    {1'h1, 5'd20} :  data_out = acceptance_mask_0;                      // extended mode
    {1'h1, 5'd21} :  data_out = acceptance_mask_1;                      // extended mode
    {1'h1, 5'd22} :  data_out = acceptance_mask_2;                      // extended mode
    {1'h1, 5'd23} :  data_out = acceptance_mask_3;                      // extended mode
    {1'h1, 5'd24} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd25} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd26} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd27} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd28} :  data_out = 8'h0;                                   // extended mode
    {1'h1, 5'd29} :  data_out = {1'b0, rx_message_counter};             // extended mode
    {1'h1, 5'd31} :  data_out = clock_divider;                          // extended mode
    {1'h0, 5'd00} :  data_out = {3'b001, mode_basic[4:1], mode[0]};     // basic mode
    {1'h0, 5'd01} :  data_out = 8'hff;                                  // basic mode
    {1'h0, 5'd02} :  data_out = status;                                 // basic mode
    {1'h0, 5'd03} :  data_out = {4'he, irq_reg[3:0]};                   // basic mode
    {1'h0, 5'd04} :  data_out = reset_mode? acceptance_code_0 : 8'hff;  // basic mode
    {1'h0, 5'd05} :  data_out = reset_mode? acceptance_mask_0 : 8'hff;  // basic mode
    {1'h0, 5'd06} :  data_out = reset_mode? bus_timing_0 : 8'hff;       // basic mode
    {1'h0, 5'd07} :  data_out = reset_mode? bus_timing_1 : 8'hff;       // basic mode
    {1'h0, 5'd10} :  data_out = reset_mode? 8'hff : tx_data_0;          // basic mode
    {1'h0, 5'd11} :  data_out = reset_mode? 8'hff : tx_data_1;          // basic mode
    {1'h0, 5'd12} :  data_out = reset_mode? 8'hff : tx_data_2;          // basic mode
    {1'h0, 5'd13} :  data_out = reset_mode? 8'hff : tx_data_3;          // basic mode
    {1'h0, 5'd14} :  data_out = reset_mode? 8'hff : tx_data_4;          // basic mode
    {1'h0, 5'd15} :  data_out = reset_mode? 8'hff : tx_data_5;          // basic mode
    {1'h0, 5'd16} :  data_out = reset_mode? 8'hff : tx_data_6;          // basic mode
    {1'h0, 5'd17} :  data_out = reset_mode? 8'hff : tx_data_7;          // basic mode
    {1'h0, 5'd18} :  data_out = reset_mode? 8'hff : tx_data_8;          // basic mode
    {1'h0, 5'd19} :  data_out = reset_mode? 8'hff : tx_data_9;          // basic mode
    {1'h0, 5'd31} :  data_out = clock_divider;                          // basic mode
    default :  data_out = 8'h0;                                   // the rest is read as 0
  endcase
end


// Some interrupts exist in basic mode and in extended mode. Since they are in different registers they need to be multiplexed.
assign data_overrun_irq_en  = extended_mode ? data_overrun_irq_en_ext  : overrun_irq_en_basic;
assign error_warning_irq_en = extended_mode ? error_warning_irq_en_ext : error_irq_en_basic;
assign transmit_irq_en      = extended_mode ? transmit_irq_en_ext      : transmit_irq_en_basic;
assign receive_irq_en       = extended_mode ? receive_irq_en_ext       : receive_irq_en_basic;


reg data_overrun_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    data_overrun_irq <= 1'b0;
  else if (overrun & (~overrun_q) & data_overrun_irq_en)
    data_overrun_irq <=#Tp 1'b1;
  else if (reset_mode || read_irq_reg)
    data_overrun_irq <=#Tp 1'b0;
end


reg transmit_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    transmit_irq <= 1'b0;
  else if (reset_mode || read_irq_reg)
    transmit_irq <=#Tp 1'b0;
  else if (transmit_buffer_status & (~transmit_buffer_status_q) & transmit_irq_en)
    transmit_irq <=#Tp 1'b1;
end


reg receive_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    receive_irq <= 1'b0;
  else if ((~info_empty) & (~receive_irq) & receive_irq_en)
    receive_irq <=#Tp 1'b1;
  else if (reset_mode || release_buffer)
    receive_irq <=#Tp 1'b0;
end


reg error_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    error_irq <= 1'b0;
  else if (((error_status ^ error_status_q) | (node_bus_off ^ node_bus_off_q)) & error_warning_irq_en)
    error_irq <=#Tp 1'b1;
  else if (read_irq_reg)
    error_irq <=#Tp 1'b0;
end


reg bus_error_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    bus_error_irq <= 1'b0;
  else if (set_bus_error_irq & bus_error_irq_en)
    bus_error_irq <=#Tp 1'b1;
  else if (reset_mode || read_irq_reg)
    bus_error_irq <=#Tp 1'b0;
end


reg arbitration_lost_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    arbitration_lost_irq <= 1'b0;
  else if (set_arbitration_lost_irq & arbitration_lost_irq_en)
    arbitration_lost_irq <=#Tp 1'b1;
  else if (reset_mode || read_irq_reg)
    arbitration_lost_irq <=#Tp 1'b0;
end



reg error_passive_irq;
always @ (posedge clk or posedge rst)
begin
  if (rst)
    error_passive_irq <= 1'b0;
  else if ((node_error_passive & (~node_error_passive_q) | (~node_error_passive) & node_error_passive_q & node_error_active) & error_passive_irq_en)
    error_passive_irq <=#Tp 1'b1;
  else if (reset_mode || read_irq_reg)
    error_passive_irq <=#Tp 1'b0;
end



assign irq_reg = {bus_error_irq, arbitration_lost_irq, error_passive_irq, 1'b0, data_overrun_irq, error_irq, transmit_irq, receive_irq};

assign irq = data_overrun_irq | transmit_irq | receive_irq | error_irq | bus_error_irq | arbitration_lost_irq | error_passive_irq;


always @ (posedge clk or posedge rst)
begin
  if (rst)
    irq_n <= 1'b1;
  else if (read_irq_reg || release_buffer)
    irq_n <=#Tp 1'b1;
  else if (irq)
    irq_n <=#Tp 1'b0;
end



endmodule

