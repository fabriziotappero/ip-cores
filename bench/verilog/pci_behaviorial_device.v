//===========================================================================
// $Id: pci_behaviorial_device.v,v 1.2 2002-03-21 07:35:50 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  A top-level PCI Behaviorial interface.  This module instantiates
//           a number of behaviorial IO pads and a behaviorial PCI Master
//           and behaviorial PCI Target.  Not much going on here.
//
// This library is free software; you can distribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, write to
// Free Software Foundation, Inc.
// 59 Temple Place, Suite 330
// Boston, MA 02111-1307 USA
//
// Author's note about this license:  The intention of the Author and of
// the Gnu Lesser General Public License is that users should be able to
// use this code for any purpose, including combining it with other source
// code, combining it with other logic, translated it into a gate-level
// representation, or projected it into gates in a programmable or
// hardwired chip, as long as the users of the resulting source, compiled
// source, or chip are given the means to get a copy of this source code
// with no new restrictions on redistribution of this source.
//
// If you make changes, even substantial changes, to this code, or use
// substantial parts of this code as an inseparable part of another work
// of authorship, the users of the resulting IP must be given the means
// to get a copy of the modified or combined source code, with no new
// restrictions on redistribution of the resulting source.
//
// Separate parts of the combined source code, compiled code, or chip,
// which are NOT derived from this source code do NOT need to be offered
// to the final user of the chip merely because they are used in
// combination with this code.  Other code is not forced to fall under
// the GNU Lesser General Public License when it is linked to this code.
// The license terms of other source code linked to this code might require
// that it NOT be made available to users.  The GNU Lesser General Public
// License does not prevent this code from being used in such a situation,
// as long as the user of the resulting IP is given the means to get a
// copy of this component of the IP with no new restrictions on
// redistribution of this source.
//
// This code was developed using VeriLogger Pro, by Synapticad.
// Their support is greatly appreciated.
//
// NOTE:  This Test Chip instantiates one PCI interface and connects it
//        to its IO pads and to logic representing a real application.
//
// NOTE:  Needs to be improved to allow back-to-back transfers from
//        the same Master.  I think the request is being held off
//        too long!  But it might also be fast-back-to-back.
//
//===========================================================================

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module pci_behaviorial_device (
  pci_ext_ad, pci_ext_cbe_l, pci_ext_par,
  pci_ext_frame_l, pci_ext_irdy_l,
  pci_ext_devsel_l, pci_ext_trdy_l, pci_ext_stop_l,
  pci_ext_perr_l, pci_ext_serr_l,
  pci_ext_idsel,
  pci_ext_inta_l,
  pci_ext_req_l, pci_ext_gnt_l,
  pci_ext_reset_l, pci_ext_clk,
// Signals used by the test bench instead of using "." notation
  test_observe_oe_sigs,
  test_master_number, test_address, test_command,
  test_data, test_byte_enables_l, test_size,
  test_make_addr_par_error, test_make_data_par_error,
  test_master_initial_wait_states, test_master_subsequent_wait_states,
  test_target_initial_wait_states, test_target_subsequent_wait_states,
  test_target_devsel_speed, test_fast_back_to_back,
  test_target_termination,
  test_expect_master_abort,
  test_start, test_accepted_l, test_error_event,
  test_device_id,
  test_target_response,

  master_received_data,
  master_received_data_valid,
  master_check_received_data
);

`include "pci_blue_options.vh"
`include "pci_blue_constants.vh"

  inout  [PCI_BUS_DATA_RANGE:0] pci_ext_ad;
  inout  [PCI_BUS_CBE_RANGE:0] pci_ext_cbe_l;
  inout   pci_ext_par;
  inout   pci_ext_frame_l, pci_ext_irdy_l;
  inout   pci_ext_devsel_l, pci_ext_trdy_l, pci_ext_stop_l;
  inout   pci_ext_perr_l, pci_ext_serr_l;
  input   pci_ext_idsel;
  inout   pci_ext_inta_l;
  output  pci_ext_req_l;
  input   pci_ext_gnt_l;
  input   pci_ext_reset_l, pci_ext_clk;
// Test wires to make it easier to understand who is driving the bus
  output [5:0] test_observe_oe_sigs;
  input  [2:0] test_master_number;
  input  [PCI_BUS_DATA_RANGE:0] test_address;
  input  [PCI_BUS_CBE_RANGE:0] test_command;
  input  [PCI_BUS_DATA_RANGE:0] test_data;
  input  [PCI_BUS_CBE_RANGE:0] test_byte_enables_l;
  input  [9:0] test_size;
  input   test_make_addr_par_error, test_make_data_par_error;
  input  [3:0] test_master_initial_wait_states;
  input  [3:0] test_master_subsequent_wait_states;
  input  [3:0] test_target_initial_wait_states;
  input  [3:0] test_target_subsequent_wait_states;
  input  [1:0] test_target_devsel_speed;
  input   test_fast_back_to_back;
  input  [2:0] test_target_termination;
  input   test_expect_master_abort;
  input   test_start;
  output  test_accepted_l;
  output  test_error_event;
  input  [2:0] test_device_id;
  input  [25:0] test_target_response ;
  output [PCI_BUS_DATA_RANGE:0] master_received_data ;
  output master_received_data_valid ;
  input  master_check_received_data ;

// Make temporary Bip every time an error is detected
  reg     test_error_event;
  initial test_error_event <= 1'bZ;
  wire    master_error_event, target_error_event;
  reg     error_detected;
  initial error_detected <= 1'b0;
  always @(error_detected or master_error_event or target_error_event)
  begin
    test_error_event <= 1'b0;
    #2;
    test_error_event <= 1'bZ;
  end

// Assign local variables to board-level signals
// NOTE:  all of these output pads are combinational, not clocked, on output
  wire pci_reset_comb = ~pci_ext_reset_l;

  wire    master_req;
  wire    master_req_dly1, master_req_dly2;
  assign #`PAD_MIN_DATA_DLY master_req_dly1 = master_req;
  assign #`PAD_MAX_DATA_DLY master_req_dly2 = master_req;
  assign  pci_ext_req_l = (master_req_dly1 !== master_req_dly2)
                        ? 1'bX : ~master_req_dly2;

  wire    master_gnt_now = ~pci_ext_gnt_l;

  wire   [PCI_BUS_DATA_RANGE:0] pci_ad_out;
  wire   [PCI_BUS_DATA_RANGE:0] pci_ad_out_dly1, pci_ad_out_dly2;
  assign #`PAD_MIN_DATA_DLY pci_ad_out_dly1[PCI_BUS_DATA_RANGE:0] = pci_ad_out[PCI_BUS_DATA_RANGE:0];
  assign #`PAD_MAX_DATA_DLY pci_ad_out_dly2[PCI_BUS_DATA_RANGE:0] = pci_ad_out[PCI_BUS_DATA_RANGE:0];
  wire    pci_ad_oe;
  wire    pci_ad_oe_dly1, pci_ad_oe_dly2;
  assign #`PAD_MIN_OE_DLY pci_ad_oe_dly1 = pci_ad_oe;
  assign #`PAD_MAX_OE_DLY pci_ad_oe_dly2 = pci_ad_oe;
  wire    force_ad_x = (pci_ad_oe_dly1 !== pci_ad_oe_dly2)
                     | (pci_ad_oe & (pci_ad_out_dly1 !== pci_ad_out_dly2));
  assign  pci_ext_ad[PCI_BUS_DATA_RANGE:0] = force_ad_x ? `PCI_BUS_DATA_X
                           : (pci_ad_oe_dly2
                           ? pci_ad_out_dly2[PCI_BUS_DATA_RANGE:0]
                           : `PCI_BUS_DATA_Z);
// NOTE ad_now must have a bypass from internal data in the synthesized design
  wire   [PCI_BUS_DATA_RANGE:0] ad_now = pci_ext_ad[PCI_BUS_DATA_RANGE:0];
  reg    [PCI_BUS_DATA_RANGE:0] ad_prev;

  wire   [PCI_BUS_CBE_RANGE:0] master_cbe_l_out;
  wire   [PCI_BUS_CBE_RANGE:0] master_cbe_l_dly1, master_cbe_l_dly2;
  assign #`PAD_MIN_DATA_DLY master_cbe_l_dly1[PCI_BUS_CBE_RANGE:0] = master_cbe_l_out[PCI_BUS_CBE_RANGE:0];
  assign #`PAD_MAX_DATA_DLY master_cbe_l_dly2[PCI_BUS_CBE_RANGE:0] = master_cbe_l_out[PCI_BUS_CBE_RANGE:0];
  wire    master_cbe_oe;
  wire    master_cbe_oe_dly1, master_cbe_oe_dly2;
  assign #`PAD_MIN_OE_DLY master_cbe_oe_dly1 = master_cbe_oe;
  assign #`PAD_MAX_OE_DLY master_cbe_oe_dly2 = master_cbe_oe;
  wire    force_cbe_x = (master_cbe_oe_dly1 !== master_cbe_oe_dly2)
                      | (master_cbe_oe & (master_cbe_l_dly1 !== master_cbe_l_dly2));
  assign  pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0] = force_cbe_x ? `PCI_BUS_CBE_X
                             : (master_cbe_oe_dly2
                             ? master_cbe_l_dly2[PCI_BUS_CBE_RANGE:0]
                             : `PCI_BUS_CBE_Z);
// NOTE cbe_l_now must have a bypass from internal data in the synthesized design
  wire   [PCI_BUS_CBE_RANGE:0] cbe_l_now = pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0];
  reg    [PCI_BUS_CBE_RANGE:0] cbe_l_prev;
  always @(posedge pci_ext_clk)
  begin
    ad_prev[PCI_BUS_DATA_RANGE:0] <= pci_ext_ad[PCI_BUS_DATA_RANGE:0];
    cbe_l_prev[PCI_BUS_CBE_RANGE:0] <= pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0];
  end

  wire    idsel_now, idsel_prev, idsel_now_l, idsel_prev_l;
delayed_test_pad test_pad_idsel (
  .external_sig    (pci_ext_idsel),     .data_in_comb    (idsel_now_l),
  .data_in_prev    (idsel_prev_l),      .data_out_comb   (1'b0),
  .data_oe_comb    (1'b0),              .pci_ext_clk     (pci_ext_clk)
);
  assign  idsel_now = ~idsel_now_l;
  assign  idsel_prev = ~idsel_prev_l;

  reg     pci_par_out, pci_par_oe;
  wire    par_now, par_prev, par_now_l, par_prev_l;
delayed_test_pad test_pad_par (
  .external_sig    (pci_ext_par),       .data_in_comb    (par_now_l),
  .data_in_prev    (par_prev_l),        .data_out_comb   (pci_par_out),
  .data_oe_comb    (pci_par_oe),        .pci_ext_clk     (pci_ext_clk)
);
  assign  par_now = ~par_now_l;  // oups, want NON-inverted version of this
  assign  par_prev = ~par_prev_l;

  wire    master_frame_out, master_frame_oe;
  wire    frame_now, frame_prev;
delayed_test_pad test_pad_frame (
  .external_sig    (pci_ext_frame_l),   .data_in_comb    (frame_now),
  .data_in_prev    (frame_prev),        .data_out_comb   (~master_frame_out),
  .data_oe_comb    (master_frame_oe),   .pci_ext_clk     (pci_ext_clk)
);

  wire    master_irdy_out, master_irdy_oe;
  wire    irdy_now, irdy_prev;
delayed_test_pad test_pad_irdy (
  .external_sig    (pci_ext_irdy_l),    .data_in_comb    (irdy_now),
  .data_in_prev    (irdy_prev),         .data_out_comb   (~master_irdy_out),
  .data_oe_comb    (master_irdy_oe),    .pci_ext_clk     (pci_ext_clk)
);

  wire    target_devsel_out, target_d_t_s_oe;
  wire    devsel_now, devsel_prev;
delayed_test_pad test_pad_devsel (
  .external_sig    (pci_ext_devsel_l),  .data_in_comb    (devsel_now),
  .data_in_prev    (devsel_prev),       .data_out_comb  (~target_devsel_out),
  .data_oe_comb    (target_d_t_s_oe),   .pci_ext_clk     (pci_ext_clk)
);

  wire    target_trdy_out;  // shares target_d_t_s_oe
  wire    trdy_prev, trdy_now;
delayed_test_pad test_pad_trdy (
  .external_sig    (pci_ext_trdy_l),    .data_in_comb    (trdy_now),
  .data_in_prev    (trdy_prev),         .data_out_comb   (~target_trdy_out),
  .data_oe_comb    (target_d_t_s_oe),   .pci_ext_clk     (pci_ext_clk)
);

  wire    target_stop_out;  // shares target_d_t_s_oe
  wire    stop_now, stop_prev;
delayed_test_pad test_pad_stop (
  .external_sig    (pci_ext_stop_l),    .data_in_comb    (stop_now),
  .data_in_prev    (stop_prev),         .data_out_comb   (~target_stop_out),
  .data_oe_comb    (target_d_t_s_oe),   .pci_ext_clk     (pci_ext_clk)
);

  wire    pci_perr_out, pci_perr_oe;
  wire    perr_now, perr_prev;
delayed_test_pad test_pad_perr (
  .external_sig    (pci_ext_perr_l),    .data_in_comb    (perr_now),
  .data_in_prev    (perr_prev),         .data_out_comb   (~pci_perr_out),
  .data_oe_comb    (pci_perr_oe),       .pci_ext_clk     (pci_ext_clk)
);

  wire    pci_serr_oe;
  wire    serr_now, serr_prev;
delayed_test_pad test_pad_serr (
  .external_sig    (pci_ext_serr_l),    .data_in_comb    (serr_now),
  .data_in_prev    (serr_prev),         .data_out_comb   (1'b0),
  .data_oe_comb    (pci_serr_oe),       .pci_ext_clk     (pci_ext_clk)
);

// Make visible the internal OE signals.  This makes it MUCH easier to
//   see who is using the bus during simulation.
// OE Observation signals are
// {frame_oe, irdy_oe, devsel_t_s_oe, ad_oe, cbe_oe, perr_oe}
  assign  test_observe_oe_sigs[5:0] = {master_frame_oe, master_irdy_oe,
               target_d_t_s_oe, pci_ad_oe, master_cbe_oe, pci_perr_oe};

// Variables to give access to shared IO pins
  wire   [PCI_BUS_DATA_RANGE:0] master_ad_out;
  wire    master_par_out_next;
  wire    master_perr_out;
  wire    master_ad_oe, master_perr_oe, master_serr_oe;
  wire    master_debug_force_bad_par;
  wire   [PCI_BUS_DATA_RANGE:0] target_ad_out;
  wire    target_par_out_next;
  wire    target_perr_out;
  wire    target_ad_oe, target_perr_oe, target_serr_oe;
  wire    target_debug_force_bad_par;

// Shared Bus Wires which can be driven by the Master or the Target
  assign  pci_ad_out[PCI_BUS_DATA_RANGE:0] = master_ad_oe
                     ? master_ad_out[PCI_BUS_DATA_RANGE:0]
                     : (target_ad_oe
                     ? target_ad_out[PCI_BUS_DATA_RANGE:0]
                     : `PCI_BUS_DATA_X);
  assign  pci_ad_oe = master_ad_oe | target_ad_oe;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      pci_par_oe <= 1'b0;
    end
    else
    begin
      pci_par_oe <= master_ad_oe | target_ad_oe;
    end
  end
  assign  master_par_out_next = (^master_ad_out[PCI_BUS_DATA_RANGE:0])
                              ^ (^master_cbe_l_out[PCI_BUS_CBE_RANGE:0])
                              ^ master_debug_force_bad_par;
  assign  target_par_out_next = (^target_ad_out[PCI_BUS_DATA_RANGE:0])
                              ^ (^cbe_l_now[PCI_BUS_CBE_RANGE:0])
                              ^ target_debug_force_bad_par;
  always @(posedge pci_ext_clk)
  begin
    pci_par_out <= master_ad_oe ? master_par_out_next
                       : (target_ad_oe ? target_par_out_next : 1'bX);
  end
  assign  pci_perr_out = master_perr_oe ? master_perr_out
                       : (target_perr_oe ? target_perr_out : 1'bX);
  assign  pci_perr_oe = master_perr_oe | target_perr_oe;
  assign  pci_serr_oe = master_serr_oe | target_serr_oe;

// synopsys translate_off
// Test for obvious errors in this test device
  always @(posedge pci_ext_clk)
  begin
    if (master_ad_oe & target_ad_oe)
    begin
      $display ("*** test %h - Master and Target drive AD bus at the same time, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
    if (master_perr_oe & target_perr_oe)
    begin
      $display ("*** test %h - Master and Target drive PERR at the same time, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
    if (master_serr_oe & target_serr_oe)
    begin
      $display ("*** test %h - Master and Target drive SERR at the same time, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
// synopsys translate_on

// Share a parity generator on inputs (Is this legal?  Can't receive CBE in Master)
  wire    calc_input_parity_prev = (^ad_prev[PCI_BUS_DATA_RANGE:0])
                                 ^ (^cbe_l_prev[PCI_BUS_CBE_RANGE:0]) ;
                                 // added by miha d for bad PERR generation
                                 //^ target_debug_force_bad_par ;

// Master needs to report conditions to Target, which contains the Config Register
// If the system is a target only, these bits should all be wired to 0
  wire    master_got_parity_error, master_asserted_serr, master_got_master_abort;
  wire    master_got_target_abort, master_caused_parity_error;
  wire    master_enable, master_fast_b2b_en, master_perr_enable, master_serr_enable;
  wire   [7:0] master_latency_value;

pci_behaviorial_master pci_behaviorial_master (
  .ad_now                     (ad_now[PCI_BUS_DATA_RANGE:0]),
  .ad_prev                    (ad_prev[PCI_BUS_DATA_RANGE:0]),
  .calc_input_parity_prev     (calc_input_parity_prev),
  .master_ad_out              (master_ad_out[PCI_BUS_DATA_RANGE:0]),
  .master_ad_oe               (master_ad_oe),
  .master_cbe_l_out           (master_cbe_l_out[PCI_BUS_CBE_RANGE:0]),
  .master_cbe_oe              (master_cbe_oe),
  .par_now                    (par_now),
  .par_prev                   (par_prev),
  .frame_now                  (frame_now),
  .frame_prev                 (frame_prev),
  .master_frame_out           (master_frame_out),
  .master_frame_oe            (master_frame_oe),
  .irdy_now                   (irdy_now),
  .irdy_prev                  (irdy_prev),
  .master_irdy_out            (master_irdy_out),
  .master_irdy_oe             (master_irdy_oe),
  .devsel_now                 (devsel_now),
  .devsel_prev                (devsel_prev),
  .trdy_now                   (trdy_now),
  .trdy_prev                  (trdy_prev),
  .stop_now                   (stop_now),
  .stop_prev                  (stop_prev),
  .perr_now                   (perr_now),
  .perr_prev                  (perr_prev),
  .master_perr_out            (master_perr_out),
  .master_perr_oe             (master_perr_oe),
  .master_serr_oe             (master_serr_oe),
  .master_req_out             (master_req),
  .master_gnt_now             (master_gnt_now),
  .pci_reset_comb             (pci_reset_comb),
  .pci_ext_clk                (pci_ext_clk),
// Signals from the master to the target to set bits in the Status Register
  .master_got_parity_error    (master_got_parity_error),
  .master_asserted_serr       (master_asserted_serr),
  .master_got_master_abort    (master_got_master_abort),
  .master_got_target_abort    (master_got_target_abort),
  .master_caused_parity_error (master_caused_parity_error),
  .master_enable              (master_enable),
  .master_fast_b2b_en         (master_fast_b2b_en),
  .master_perr_enable         (master_perr_enable),
  .master_serr_enable         (master_serr_enable),
  .master_latency_value       (master_latency_value[7:0]),
// Signals used by the test bench instead of using "." notation
  .master_debug_force_bad_par (master_debug_force_bad_par),
  .test_master_number         (test_master_number[2:0]),
  .test_address               (test_address[PCI_BUS_DATA_RANGE:0]),
  .test_command               (test_command[PCI_BUS_CBE_RANGE:0]),
  .test_data                  (test_data[PCI_BUS_DATA_RANGE:0]),
  .test_byte_enables_l        (test_byte_enables_l[PCI_BUS_CBE_RANGE:0]),
  .test_size                  (test_size),
  .test_make_addr_par_error   (test_make_addr_par_error),
  .test_make_data_par_error   (test_make_data_par_error),
  .test_master_initial_wait_states     (test_master_initial_wait_states[3:0]),
  .test_master_subsequent_wait_states  (test_master_subsequent_wait_states[3:0]),
  .test_target_initial_wait_states     (test_target_initial_wait_states[3:0]),
  .test_target_subsequent_wait_states  (test_target_subsequent_wait_states[3:0]),
  .test_target_devsel_speed   (test_target_devsel_speed[1:0]),
  .test_fast_back_to_back     (test_fast_back_to_back),
  .test_target_termination    (test_target_termination[2:0]),
  .test_expect_master_abort   (test_expect_master_abort),
  .test_start                 (test_start),
  .test_accepted_l            (test_accepted_l),
  .test_error_event           (master_error_event),
  .test_device_id             (test_device_id[2:0]),
// target read data and data valid signals for testbench
  .master_received_data       (master_received_data),
  .master_received_data_valid (master_received_data_valid),
  .master_check_received_data (master_check_received_data)
);

pci_behaviorial_target pci_behaviorial_target (
  .ad_now                     (ad_now[PCI_BUS_DATA_RANGE:0]),
  .ad_prev                    (ad_prev[PCI_BUS_DATA_RANGE:0]),
  .calc_input_parity_prev     (calc_input_parity_prev),
  .target_ad_out              (target_ad_out[PCI_BUS_DATA_RANGE:0]),
  .target_ad_oe               (target_ad_oe),
  .cbe_l_now                  (cbe_l_now[PCI_BUS_CBE_RANGE:0]),
  .cbe_l_prev                 (cbe_l_prev[PCI_BUS_CBE_RANGE:0]),
  .par_now                    (par_now),
  .par_prev                   (par_prev),
  .frame_now                  (frame_now),
  .frame_prev                 (frame_prev),
  .irdy_now                   (irdy_now),
  .irdy_prev                  (irdy_prev),
  .target_devsel_out          (target_devsel_out),
  .target_d_t_s_oe            (target_d_t_s_oe),
  .target_trdy_out            (target_trdy_out),
  .target_stop_out            (target_stop_out),
  .target_perr_out            (target_perr_out),
  .target_perr_oe             (target_perr_oe),
  .target_serr_oe             (target_serr_oe),
  .idsel_now                  (idsel_now),
  .idsel_prev                 (idsel_prev),
  .pci_reset_comb             (pci_reset_comb),
  .pci_ext_clk                (pci_ext_clk),
// Signals from the master to the target to set bits in the Status Register
  .master_got_parity_error    (master_got_parity_error),
  .master_asserted_serr       (master_asserted_serr),
  .master_got_master_abort    (master_got_master_abort),
  .master_got_target_abort    (master_got_target_abort),
  .master_caused_parity_error (master_caused_parity_error),
  .master_enable              (master_enable),
  .master_fast_b2b_en         (master_fast_b2b_en),
  .master_perr_enable         (master_perr_enable),
  .master_serr_enable         (master_serr_enable),
  .master_latency_value       (master_latency_value[7:0]),
// Signals used by the test bench instead of using "." notation
  .target_debug_force_bad_par (target_debug_force_bad_par),
  .test_error_event           (target_error_event),
  .test_device_id             (test_device_id[2:0]),
  .test_response              (test_target_response)
);
endmodule

module delayed_test_pad (
  external_sig, data_out_comb, data_oe_comb, data_in_comb, data_in_prev,
  pci_ext_clk
);
  inout   external_sig;
  input   data_out_comb, data_oe_comb;
  output  data_in_comb, data_in_prev;
  input   pci_ext_clk;

  wire    data_out_dly1, data_out_dly2;
  assign #`PAD_MIN_DATA_DLY data_out_dly1 = data_out_comb;
  assign #`PAD_MAX_DATA_DLY data_out_dly2 = data_out_comb;

  wire    data_oe_dly1, data_oe_dly2;
  assign #`PAD_MIN_OE_DLY data_oe_dly1 = data_oe_comb;
  assign #`PAD_MAX_OE_DLY data_oe_dly2 = data_oe_comb;

  wire    force_data_x = (data_oe_dly1 !== data_oe_dly2)
                       | (data_oe_comb & (data_out_dly1 !== data_out_dly2));
  assign  external_sig = force_data_x ? 1'bX
                       : (data_oe_dly2 ? data_out_dly2 : 1'bZ);
  assign  data_in_comb = ~external_sig;

  reg     pci_ad_out_oe_hold, pci_ad_out_hold, pci_ad_in_hold, data_in_prev;
  always @(posedge pci_ext_clk)
  begin
    data_in_prev <= ~external_sig;
    pci_ad_out_oe_hold <= data_oe_comb;
    pci_ad_out_hold <= data_out_comb;
    pci_ad_in_hold <= external_sig;
    if (pci_ad_out_oe_hold & (pci_ad_out_hold !== pci_ad_in_hold))
    begin
      $display ("*** Test Device Pad drives one value while receiving another %h, %h, %h, at %t",
                  pci_ad_out_oe_hold, pci_ad_out_hold, pci_ad_in_hold, $time);
    end
    `NO_ELSE;
  end
endmodule

