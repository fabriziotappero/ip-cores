//===========================================================================
// $Id: pci_behaviorial_master.v,v 1.4 2003-12-19 11:11:28 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  A PCI Behaviorial Master.  This module accepts commands from
//           the top-level Stimulus generator.  Based on arguments supplied
//           to it, it generates a reference containing paramaters to the
//           Target in the middle 16 bits of PCI Address.  It also arbitrates
//           for the bus, sends data when writing, and compares returned data
//           when reading.
//           This interface does not understand retries after Target Disconnect
//           commands, and does not implement a disconnect counter.
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
// NOTE TODO: Horrible.  Tasks can't depend on their Arguments being safe
//        if there are several instances ofthe tasl running at once.
// NOTE TODO: Verify that Fast-Back-To-Back references are done correctly
// NOTE TODO: Verify that PERR and SERR are driven correctly, and that signals
//        reflecting their detection are available for use in the Config Regs
//  Detect and report PERR and SERR reports as enabled.  3.7.4
//  Start adding the address register needed to handle retries
//  Start trying to understand the latency register.  Why not simply
//    get off the bus when grant goes away?
// Do not do a retry or disconnect if all 4 BE wires are 1's.  End of 3.8
// Start adding Latency Counter
// Complain if SERR caused by address parity error not seen when expected
// complain if data parity error not seen when expected
//
//===========================================================================

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module pci_behaviorial_master (
  ad_now, ad_prev, master_ad_out, master_ad_oe,
  master_cbe_l_out, master_cbe_oe,
  calc_input_parity_prev,
  par_now, par_prev,
  frame_now, frame_prev, master_frame_out, master_frame_oe,
  irdy_now, irdy_prev, master_irdy_out, master_irdy_oe,
  devsel_now, devsel_prev, trdy_now, trdy_prev, stop_now, stop_prev,
  perr_now, perr_prev, master_perr_out, master_perr_oe, master_serr_oe,
  master_req_out, master_gnt_now,
  pci_reset_comb, pci_ext_clk,
// Signals from the master to the target to set bits in the Status Register
  master_got_parity_error, master_asserted_serr, master_got_master_abort,
  master_got_target_abort, master_caused_parity_error,
  master_enable, master_fast_b2b_en, master_perr_enable, master_serr_enable,
  master_latency_value,
// Signals used by the test bench instead of using "." notation
  master_debug_force_bad_par,
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
  master_received_data,
  master_received_data_valid,
  master_check_received_data
);

`include "pci_blue_options.vh"
`include "pci_blue_constants.vh"

  input  [PCI_BUS_DATA_RANGE:0] ad_now;
  input  [PCI_BUS_DATA_RANGE:0] ad_prev;
  output [PCI_BUS_DATA_RANGE:0] master_ad_out;
  output  master_ad_oe;
  output [PCI_BUS_CBE_RANGE:0] master_cbe_l_out;
  output  master_cbe_oe;
  input   calc_input_parity_prev;
  input   par_now, par_prev;
  input   frame_now, frame_prev;
  output  master_frame_out, master_frame_oe;
  input   irdy_now, irdy_prev;
  output  master_irdy_out, master_irdy_oe;
  input   devsel_now, devsel_prev, trdy_now, trdy_prev, stop_now, stop_prev;
  input   perr_now, perr_prev;
  output  master_perr_out, master_perr_oe, master_serr_oe;
  output  master_req_out;
  input   master_gnt_now;
  input   pci_reset_comb, pci_ext_clk;
// Signals from the master to the target to set bits in the Status Register
  output  master_got_parity_error, master_asserted_serr, master_got_master_abort;
  output  master_got_target_abort, master_caused_parity_error;
  input   master_enable, master_fast_b2b_en, master_perr_enable, master_serr_enable;
  input  [7:0] master_latency_value;  // NOTE WORKING
// Signals used by the test bench instead of using "." notation
  output  master_debug_force_bad_par;
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
  output [PCI_BUS_DATA_RANGE:0] master_received_data ;
  output master_received_data_valid ;
  input  master_check_received_data ;

  reg    [PCI_BUS_DATA_RANGE:0] master_ad_out;
  reg     master_ad_oe;
  reg    [PCI_BUS_CBE_RANGE:0] master_cbe_l_out;
  reg     master_cbe_oe;
  reg     master_frame_out, master_irdy_out;
  wire    master_frame_oe, master_irdy_oe, master_perr_oe, master_serr_oe;
  reg     master_perr_out;
  reg     master_req_out;
  reg     master_debug_force_bad_par;
  reg     [PCI_BUS_DATA_RANGE:0] master_received_data ;
  reg                            master_received_data_valid ;

  // MihaD - added an option to keep the byte enables the same through complete
  // transfer
  reg keep_master_mask ;
  reg keep_master_data ;
  initial 
  begin
    keep_master_mask = 1'b0 ;
    keep_master_data = 1'b0 ;
  end

// Let test commander know when this PCI Master has accepted the command.
  reg     test_accepted_next, test_accepted_int;
// Display on negative edge so easy to see
  always @(negedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      test_accepted_int <= 1'b0;
      master_received_data_valid <= 1'b0 ;
    end
    else
    begin
      test_accepted_int <= test_accepted_next;
    end
  end
  assign  test_accepted_l = test_accepted_int ? 1'b0 : 1'bZ;

// Make temporary Bip every time an error is detected
  reg     test_error_event;
  initial test_error_event <= 1'bZ;
  reg     error_detected;
  initial error_detected <= 1'b0;
  always @(error_detected)
  begin
    test_error_event <= 1'b0;
    #2;
    test_error_event <= 1'bZ;
  end

// Make the FRAME_OE and IRDY_OE output enable signals.  They must
//   become asserted as soon as each of those signals become asserted, and
//   must stay asserted one clock after the signal becomes deasserted.
  reg     prev_frame_asserted, prev_irdy_asserted;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      prev_frame_asserted <= 1'b0;
      prev_irdy_asserted <= 1'b0;
    end
    else
    begin
      prev_frame_asserted <= master_frame_out;
      prev_irdy_asserted <= master_irdy_out;
    end
  end
  assign  master_frame_oe = master_frame_out | prev_frame_asserted;
  assign  master_irdy_oe = master_irdy_out | prev_irdy_asserted;

// Make the PERR_OE signal.
// See the PCI Local Bus Spec Revision 2.2 section 3.7.4.1
// At time N, master_perr_check_next is set
// At time N+1, external data is latched, and trdy is also latched
// At time N+1, master_perr_check is latched
// At time N+2, calc_input_parity_prev is valid
// Also at N+2, external parity is valid
// Target can assert data slowly the first reference.
// Qualify PERR with TRDY (?)
  reg     master_perr_prev, master_perr_check_next, master_perr_check;
  reg     master_oe_prev, master_oe_prev_prev;
  reg     master_perr_detected, master_target_perr_received;
  reg     master_debug_force_bad_perr ;

  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
        master_debug_force_bad_perr <= 1'b0 ;
    else
        master_debug_force_bad_perr <= master_debug_force_bad_par ;
  end

  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      master_perr_check <= 1'b0;
      master_perr_detected <= 1'b0;
      master_target_perr_received <= 1'b0;
      master_perr_out <= 1'b0;
      master_perr_prev <= 1'b0;
      master_oe_prev <= 1'b0;
      master_oe_prev_prev <= 1'b0;
    end
    else
    begin
      master_perr_check <= master_perr_check_next;
      master_perr_detected <= master_perr_check & trdy_prev
                         & (calc_input_parity_prev != par_now);
      master_oe_prev <= master_ad_oe;
      master_oe_prev_prev <= master_oe_prev;
      master_target_perr_received <= master_oe_prev_prev & perr_now;
      master_perr_out <= master_perr_check & trdy_prev & master_perr_enable
                         & (calc_input_parity_prev != ( par_now ^ master_debug_force_bad_perr));
      master_perr_prev <= master_perr_out;
    end
  end
  assign  master_perr_oe = master_perr_out | master_perr_prev;

// Tell the Config Status Register when errors occur
  assign  master_got_parity_error = master_perr_detected;
  assign  master_serr_oe = 1'b0;        // This master NEVER asserts SERR
  assign  master_asserted_serr = 1'b0;  // This master NEVER asserts SERR
  reg     master_got_master_abort, master_got_target_abort, master_got_target_retry;  // assigned in state machine
// PERR_detected or PERR pin seen while master
// See the PCI Local Bus Spec Revision 2.2 section 6.2.3
  assign  master_caused_parity_error = master_perr_out
                               | (master_target_perr_received & master_perr_enable);

// Remember whether this device drove the AD Bus last clock, which allows
// Zero-Wait-State Back-to-Back references
  wire    This_Master_Drove_The_AD_Bus_The_Last_Clock = master_ad_oe;

// Model of a Master Source of Data, which writes whatever it wants on bursts
task Compare_Read_Data_With_Expected_Data;
  input  [PCI_BUS_DATA_RANGE:0] target_read_data;
  input  [PCI_BUS_DATA_RANGE:0] master_check_data;
  input	 [PCI_BUS_CBE_RANGE:0]  mask_l;// Added by Tadej M. on 11.12.2001
  begin																			// Added by Tadej M. on 11.12.2001
    if (~pci_reset_comb & ((target_read_data[31:24] !=  master_check_data[31:24]) & ~mask_l[3]) &
    					  ((target_read_data[23:16] !=  master_check_data[23:16]) & ~mask_l[2]) &
    					  ((target_read_data[15:8]  !=  master_check_data[15:8])  & ~mask_l[1]) &
    					  ((target_read_data[7:0]   !=  master_check_data[7:0])   & ~mask_l[0]) )
    begin
      $display ("*** test master %h - Master Read Data 'h%x not as expected 'h%x, at %t",
                  test_device_id[2:0], target_read_data[PCI_BUS_DATA_RANGE:0],
                  master_check_data[PCI_BUS_DATA_RANGE:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

// Tasks can't have local storage!  have to be module global
  reg    [PCI_BUS_DATA_RANGE:0] up_temp;
task Update_Write_Data;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  output [PCI_BUS_DATA_RANGE:0] master_write_data_next;
  output [PCI_BUS_CBE_RANGE:0] master_mask_l_next;
  begin
    up_temp[31:24] = master_write_data[31:24] + 8'h01;
    up_temp[23:16] = master_write_data[23:16] + 8'h01;
    up_temp[15: 8] = master_write_data[15: 8] + 8'h01;
    up_temp[ 7: 0] = master_write_data[ 7: 0] + 8'h01;
// Wrap adds so that things repeat in the 256 Byte (64 Word) Target SRAM
    if (~keep_master_data)
        master_write_data_next[PCI_BUS_DATA_RANGE:0] = up_temp[PCI_BUS_DATA_RANGE:0];// & 32'h3F3F3F3F; commented by Tadej M. on 07.12.2001
    else
        master_write_data_next = master_write_data ;

    // MihaD - added an option to keep byte enables the same through complete transfer
    if (~keep_master_mask)
        master_mask_l_next[PCI_BUS_CBE_RANGE:0] = {master_mask_l[2:0], master_mask_l[3]};
    else
        master_mask_l_next = master_mask_l ;
  end
endtask

// Counter to detect unexpected master aborts
  reg    [2:0] Master_Abort_Counter;

task Init_Master_Abort_Counter;
  begin
    Master_Abort_Counter <= 3'h1;
  end
endtask

task Inc_Master_Abort_Counter;
  begin
    if (Master_Abort_Counter < 3'h7)  // count up cycles since Address
    begin
      Master_Abort_Counter <= Master_Abort_Counter + 3'h1;
    end
    `NO_ELSE;
  end
endtask

task Check_Master_Abort_Counter;
  output  got_master_abort;
  begin
    got_master_abort = (Master_Abort_Counter >= 3'h5);
  end
endtask

// Signals used by Master test code to apply correct info to the PCI bus
  reg    [23:9] hold_master_address;
  reg    [PCI_BUS_CBE_RANGE:0] hold_master_command;
  reg    [PCI_BUS_DATA_RANGE:0] hold_master_data;
  reg    [PCI_BUS_CBE_RANGE:0] hold_master_byte_enables_l;
  reg    [9:0] hold_master_size;
  reg     hold_master_addr_par_err, hold_master_data_par_err;
  reg    [3:0] hold_master_initial_waitstates;
  reg    [3:0] hold_master_subsequent_waitstates;
  reg    [3:0] hold_master_target_initial_waitstates;
  reg    [3:0] hold_master_target_subsequent_waitstates;
  reg    [1:0] hold_master_target_devsel_speed;
  reg     hold_master_fast_b2b;
  reg    [2:0] hold_master_target_termination;
  reg     hold_master_expect_master_abort;
  reg    [PCI_BUS_DATA_RANGE:0] modified_master_address;

// Tasks to do behaviorial PCI references
// NOTE all tasks end with an @(posedge pci_ext_clk) statement
//      to let any signals asserted during that task settle out.
// If a task DOESN'T end with @(posedge pci_ext_clk), then it must
//      be called just before some other task which does.

parameter TEST_MASTER_SPINLOOP_MAX = 20;

task Clock_Wait_Unless_Reset;
  begin
    if (~pci_reset_comb)
    begin
      @ (posedge pci_ext_clk or posedge pci_reset_comb) ;
    end
    `NO_ELSE;
  end
endtask

task Assert_FRAME;
  begin
    master_frame_out <= 1'b1;
  end
endtask

task Deassert_FRAME;
  begin
    master_frame_out <= 1'b0;
  end
endtask

task Assert_IRDY;
  begin
    master_irdy_out <= 1'b1;
  end
endtask

task Deassert_IRDY;
  begin
    master_irdy_out <= 1'b0;
  end
endtask

task Assert_Master_Continue_Or_Terminate;
  input do_master_terminate;
  begin
    if (do_master_terminate)
    begin
      Deassert_FRAME;    Assert_IRDY;
    end
    else
    begin
      Assert_FRAME;      Assert_IRDY;
    end
  end
endtask

task Indicate_Start;
  begin
`ifdef VERBOSE_TEST_DEVICE
    $display (" test %h - Task Started, at %t", test_device_id[2:0], $time);
`endif // VERBOSE_TEST_DEVICE
      test_accepted_next <= 1'b1;
  end
endtask

task Indicate_Done;
  begin
// `ifdef VERBOSE_TEST_DEVICE
//     $display (" test %h - Task Done, at %t", test_device_id[2:0], $time);
// `endif // VERBOSE_TEST_DEVICE
      test_accepted_next <= 1'b0;
  end
endtask

task Master_Req_Bus;  // must be followed by an address assertion task
  begin
`ifdef VERBOSE_TEST_DEVICE
    $display (" test %h - Requesting the bus, at %t",
                test_device_id[2:0], $time);
`endif // VERBOSE_TEST_DEVICE
      master_req_out <= 1'b1;
  end
endtask

task Master_Unreq_Bus;  // must be followed by SOMETHING???
  begin
`ifdef VERBOSE_TEST_DEVICE
    $display (" test %h - Un-Requesting the bus, at %t",
                test_device_id[2:0], $time);
`endif // VERBOSE_TEST_DEVICE
      master_req_out <= 1'b0;
  end
endtask

parameter TEST_MASTER_IMMEDIATE_ADDRESS = 1'b0;
parameter TEST_MASTER_STEP_ADDRESS      = 1'b1;

// Tasks can't have local storage!  have to be module global
  integer ii; // sequential code, so OK to use "=" assignment operator
  reg     first_step_delay;
task Master_Assert_Address;
  input  [PCI_BUS_DATA_RANGE:0] address;
  input  [PCI_BUS_CBE_RANGE:0] command;
  input   address_speed, enable_fast_back_to_back, force_addr_par_error;
  begin
`ifdef VERBOSE_TEST_DEVICE
    $display (" test %h - Driving Address 'h%x, CBE 'h%x, at %t",
              test_device_id[2:0], address[PCI_BUS_DATA_RANGE:0],
              command[PCI_BUS_CBE_RANGE:0], $time);
`endif // VERBOSE_TEST_DEVICE
    first_step_delay = (address_speed == TEST_MASTER_STEP_ADDRESS);
    for (ii = 0; ii < TEST_MASTER_SPINLOOP_MAX; ii = ii + 1)
    begin
      if (master_gnt_now
           & (  (~frame_now & ~irdy_now)  // and bus previously idle
// ... or we previously were driving data, so fast back-to-back is possible.
              | (  ~frame_now & irdy_now
                  & This_Master_Drove_The_AD_Bus_The_Last_Clock
                  & enable_fast_back_to_back & master_fast_b2b_en) ) )
      begin
        if (first_step_delay == 1'b1)
        begin  // stepping, so drive address with some unknown bits
          master_ad_out[PCI_BUS_DATA_RANGE:0] <= address[PCI_BUS_DATA_RANGE:0] ^ 32'hXX00XX00;
          master_ad_oe <= 1'b1;
          master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= command[PCI_BUS_CBE_RANGE:0] ^ 4'bX0X0;
          master_cbe_oe <= 1'b1;
          master_debug_force_bad_par <= 1'b1;
          master_got_master_abort <= 1'b0;
          master_got_target_abort <= 1'b0;
          master_got_target_retry <= 1'b0;
          master_perr_check_next <= 1'b0;
          Deassert_FRAME;
          Deassert_IRDY;
          first_step_delay = 1'b0;  // next time through, make frame
        end
        else
        begin  // drive address AND frame
          master_ad_out[PCI_BUS_DATA_RANGE:0] <= address[PCI_BUS_DATA_RANGE:0];
          master_ad_oe <= 1'b1;
          master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= command[PCI_BUS_CBE_RANGE:0];
          master_cbe_oe <= 1'b1;
          master_debug_force_bad_par <= force_addr_par_error;
          master_got_master_abort <= 1'b0;
          master_got_target_abort <= 1'b0;
          master_got_target_retry <= 1'b0;
          master_perr_check_next <= 1'b0;
          Assert_FRAME;
          Deassert_IRDY;
          Init_Master_Abort_Counter;  // just completed master cycle 1
          first_step_delay = 1'b0;  // next time through, make frame
          ii = TEST_MASTER_SPINLOOP_MAX + 1;  // break
        end
      end
      else
      begin  // might have lost things after first step.  Undrive everything.
        master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
        master_ad_oe <= 1'b0;
        master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= PCI_COMMAND_RESERVED_READ_4;  // easy to see
        master_cbe_oe <= 1'b0;
        master_debug_force_bad_par <= 1'b0;
        master_got_master_abort <= 1'b0;
        master_got_target_abort <= 1'b0;
        master_got_target_retry <= 1'b0;
        master_perr_check_next <= 1'b0;
        Deassert_FRAME;
        Deassert_IRDY;
        first_step_delay = (address_speed == TEST_MASTER_STEP_ADDRESS);
      end
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
      Indicate_Done;  // indicate done as early as possible, while still after start
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (ii == TEST_MASTER_SPINLOOP_MAX))
    begin
      $display ("*** test %h - PCI Gnt never arrived, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// While asserting FRAME, wait zero or more clocks as commanded by master
//   tasks can't have local storage!  have to be module global
  reg    [3:0] cnt;
task Execute_Master_Waitstates_But_Quit_On_Target_Abort;
  input   drive_ad_bus;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  input  [3:0] num_waitstates;
  begin
    for (cnt = 4'h0; cnt < num_waitstates[3:0]; cnt = cnt + 4'h1)
    begin
      if (~devsel_now & stop_now)
      begin
        cnt = num_waitstates[3:0];  // immediate exit on Target Abort
      end
      else
      begin
        master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_WAIT_STATE_VALUE;
        master_ad_oe <= drive_ad_bus;
        master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
        master_cbe_oe <= 1'b1;
        master_debug_force_bad_par <= 1'b0;
        master_got_master_abort <= 1'b0;
        master_got_target_abort <= 1'b0;
        master_got_target_retry <= 1'b0;
        master_perr_check_next <= ~drive_ad_bus;
        Assert_FRAME;                  // frame, but no action
        Deassert_IRDY;
        Inc_Master_Abort_Counter;
        Clock_Wait_Unless_Reset;  // wait for outputs to settle
      end
    end
  end
endtask

task Check_Target_Abort;
  input   got_target_abort;
  input  [9:0] words_transferred;
  input  [9:0] words_expected;
  begin
    if (~got_target_abort)
    begin
      $display ("*** test master %h - Target Abort not received when expected, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    else if (words_transferred[9:0] != words_expected[9:0])
    begin
      $display ("*** test master %h - Target Abort received, but Word Count %d not %d, at %t",
                  test_device_id[2:0], words_transferred, words_expected, $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

task Check_Target_Retry;
  input   got_target_retry;
  input  [9:0] words_transferred;
  input  [9:0] words_expected;
  begin
    if (~got_target_retry)
    begin
      $display ("*** test master %h - Target Retry not received when expected, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    else if (words_transferred[9:0] != words_expected[9:0])
    begin
      $display ("*** test master %h - Target Retry received, but Word Count %d not %d, at %t",
                  test_device_id[2:0], words_transferred, words_expected, $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

task Check_Target_Stop;
  input   got_target_stop;
  input  [9:0] words_transferred;
  input  [9:0] words_expected;
  begin
    if (~got_target_stop)
    begin
      $display ("*** test master %h - Target Stop not received when expected, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    else if (words_transferred[9:0] != words_expected[9:0])
    begin
      $display ("*** test master %h - Target Stop received, but Word Count %d not %d, at %t",
                  test_device_id[2:0], words_transferred, words_expected, $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

// The initiator asked for a certain termination scheme.  Did it do that?
task Check_Master_Burst_Termination_Cause;
  input   got_master_abort, got_master_terminate;
  input   got_target_retry, got_target_stop, got_target_abort;
  input  [9:0] words_transferred;
  begin
    if (~pci_reset_comb)
    begin
// Check for Master Abort status
      if (~hold_master_expect_master_abort & got_master_abort)
      begin
        $display ("*** test master %h - Master Abort received when none was expected, at %t",
                    test_device_id[2:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (hold_master_expect_master_abort & ~got_master_abort)
      begin
        $display ("*** test master %h - Master Abort not received when expected, at %t",
                    test_device_id[2:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
// Check for Target Abort status
      if (hold_master_target_termination[2:0] == `Test_Target_Abort_On)
        Check_Target_Abort (got_target_abort, words_transferred[9:0], hold_master_size - 1);

      if (hold_master_target_termination[2:0] == `Test_Target_Abort_Before)
      begin
        if (hold_master_size[9:0] >= 10'h2)  // too small, don't get a chance to do 2
        begin
          Check_Target_Abort (got_target_abort, words_transferred[9:0], hold_master_size - 2);
        end
        else
        begin
          Check_Target_Stop (got_master_terminate,
                             words_transferred[9:0], hold_master_size[9:0]);
        end
      end
      `NO_ELSE;
// Check for Target Retry status
      if (hold_master_target_termination[2:0] == `Test_Target_Retry_On)
      begin
//        Check_Target_Retry (got_target_retry, words_transferred[9:0], hold_master_size - 1);
// tadejm, tadejm@flextronics.si, 7.8.2003; target disconnect is target_retry and target_stop
        Check_Target_Retry ((got_target_retry || got_target_stop), words_transferred[9:0], hold_master_size - 1);
      end
      `NO_ELSE;

      if (hold_master_target_termination[2:0] == `Test_Target_Retry_Before)
      begin
        if (hold_master_size[9:0] >= 10'h2)  // too small, don't get a chance to do 2
        begin
//          Check_Target_Retry (got_target_retry, words_transferred[9:0], hold_master_size - 2);
// tadejm, tadejm@flextronics.si, 7.8.2003; target disconnect is target_retry and target_stop
          Check_Target_Retry ((got_target_retry || got_target_stop), words_transferred[9:0], hold_master_size - 2);
        end
        else
        begin
          Check_Target_Stop (got_master_terminate,
                             words_transferred[9:0], hold_master_size[9:0]);
        end
      end
      `NO_ELSE;
// Check for Target Disconnect status
      if (hold_master_target_termination[2:0] == `Test_Target_Disc_On)
      begin
        Check_Target_Stop (got_target_stop, words_transferred[9:0], hold_master_size);
      end
      `NO_ELSE;

      if (hold_master_target_termination[2:0] == `Test_Target_Disc_Before)
      begin
        if (hold_master_size[9:0] >= 10'h2)  // too small, don't get a chance to do 2
        begin
          Check_Target_Stop (got_target_stop, words_transferred[9:0], hold_master_size - 1);
        end
        else
        begin
          Check_Target_Stop (got_master_terminate,
                             words_transferred[9:0], hold_master_size[9:0]);
        end
      end
    `NO_ELSE;
// Check for retry due to starting a delayed read
      if (hold_master_target_termination[2:0] == `Test_Target_Start_Delayed_Read)
      begin
//        Check_Target_Retry (got_target_retry, words_transferred[9:0], 10'h0);
// tadejm, tadejm@flextronics.si, 7.8.2003; target disconnect is target_retry and target_stop
        Check_Target_Retry ((got_target_retry || got_target_stop), words_transferred[9:0], 10'h0);
      end
      `NO_ELSE;

// Check for normal completion caused by the Master
      if (   (hold_master_target_termination[2:0] == `Test_Target_Normal_Completion)
           & ~hold_master_expect_master_abort )
      begin
        if (got_target_abort)
        begin
          $display ("*** test master %h - Target Abort received when doing normal transfer, at %t",
                      test_device_id[2:0], $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
        if (got_target_retry)
        begin
          $display ("*** test master %h - Target Retry received when doing normal transfer, at %t",
                      test_device_id[2:0], $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
        if (words_transferred[9:0] != hold_master_size[9:0])
        begin
          $display ("*** test master %h - Normal Transfer, but Word Count %d not %d, at %t",
                      test_device_id[2:0], words_transferred, hold_master_size, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
      end
      `NO_ELSE;
    end
  end
endtask

// Linger until DEVSEL.
// Tasks can't have local storage!  have to be module global
  integer iii;
task Linger_Until_DEVSEL_Or_Master_Abort_Or_Target_Abort;
  input   drive_ad_bus;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  input   do_master_terminate;
  output  got_master_abort;
  begin
`ifdef VERBOSE_TEST_DEVICE
    $display (" test %h - Lingering waiting for DEVSEL, at %t",
              test_device_id[2:0], $time);
`endif // VERBOSE_TEST_DEVICE
    for (iii = 0; iii < TEST_MASTER_SPINLOOP_MAX; iii = iii + 1)
    begin
      if (~devsel_now)  // no master yet
      begin
        if (stop_now)  // target abort!
        begin
          iii = TEST_MASTER_SPINLOOP_MAX + 1;  // break
          got_master_abort = 1'b0;  // target abort handled before master abort
        end
        else
        begin
          Check_Master_Abort_Counter (got_master_abort);
          if (got_master_abort)  // immediate exit on master abort
          begin
            iii = TEST_MASTER_SPINLOOP_MAX + 1;  // break
          end
          else
          begin
            master_ad_out[PCI_BUS_DATA_RANGE:0] <= master_write_data[PCI_BUS_DATA_RANGE:0];
            master_ad_oe <= drive_ad_bus;
            master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
            master_cbe_oe <= 1'b1;
            master_debug_force_bad_par <= hold_master_data_par_err;
            master_got_master_abort <= 1'b0;
            master_got_target_abort <= 1'b0;
            master_got_target_retry <= 1'b0;
            master_perr_check_next <= ~drive_ad_bus;
            Assert_Master_Continue_Or_Terminate (do_master_terminate);
            Inc_Master_Abort_Counter;
            Clock_Wait_Unless_Reset;  // wait for outputs to settle
          end
        end
      end
      else
      begin
        iii = TEST_MASTER_SPINLOOP_MAX + 1;  // break
        got_master_abort = 1'b0;  // success
      end
    end
    if (iii == TEST_MASTER_SPINLOOP_MAX)
    begin
      got_master_abort = 1'b1;  // fail if fall off end
    end
    `NO_ELSE;
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (iii == TEST_MASTER_SPINLOOP_MAX))
    begin
      $display ("*** test master %h - Bus didn't get DEVSEL during Master ref, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// Linger until TRDY or STOP are asserted.
// Tasks can't have local storage!  have to be module global
  integer iiii;
task Linger_Until_Target_Waitstates_Done;
  input   drive_ad_bus;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  input   do_master_terminate;
  begin
    for (iiii = 0; iiii < TEST_MASTER_SPINLOOP_MAX; iiii = iiii + 1)
    begin
      if (~trdy_now & ~stop_now)  // stick in master wait states
      begin
        master_ad_out[PCI_BUS_DATA_RANGE:0] <= master_write_data[PCI_BUS_DATA_RANGE:0];
        master_ad_oe <= drive_ad_bus;
        master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
        master_cbe_oe <= 1'b1;
        master_debug_force_bad_par <= hold_master_data_par_err;
        master_got_master_abort <= 1'b0;
        master_got_target_abort <= 1'b0;
        master_got_target_retry <= 1'b0;
        master_perr_check_next <= ~drive_ad_bus;
        Assert_Master_Continue_Or_Terminate (do_master_terminate);
        Clock_Wait_Unless_Reset;  // wait for outputs to settle
      end
      else
      begin
        iiii = TEST_MASTER_SPINLOOP_MAX + 1;  // break
      end
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (iiii == TEST_MASTER_SPINLOOP_MAX))
    begin
      $display ("*** test master %h - Bus didn't get DEVSEL during Master ref, at %t",
                  test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// Transfer a word with or without target termination, and act on Master Termination
// This task MIGHT be entered when DEVSEL is Deasserted and STOP is Asserted!
// Handle this Target Abort if it occurs.
task Execute_Master_Ref_Undrive_All_In_Any_Termination_Unless_Fast_B2B;
  input   drive_ad_bus;
  input   watching_for_master_abort;
  input   do_master_terminate;
  input   enable_fast_back_to_back;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  output [PCI_BUS_DATA_RANGE:0] target_read_data;
  output  got_master_abort, got_target_retry, got_target_stop, got_target_abort;
  output  want_fast_back_to_back;
  begin
    if (~devsel_now & stop_now)
    begin  // Target Abort.
      got_master_abort = 1'b0;
      got_target_retry = 1'b0; got_target_stop = 1'b0; got_target_abort = 1'b1;
      do_master_terminate = 1'b0;  // force clean termination activity as if master abort
    end
    else
    begin
      master_ad_out[PCI_BUS_DATA_RANGE:0] <= master_write_data[PCI_BUS_DATA_RANGE:0];
      master_ad_oe <= drive_ad_bus;
      master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
      master_cbe_oe <= 1'b1;
      master_debug_force_bad_par <= hold_master_data_par_err;
      master_got_master_abort <= 1'b0;
      master_got_target_abort <= 1'b0;
      master_got_target_retry <= 1'b0;
      master_perr_check_next <= ~drive_ad_bus;
      Assert_Master_Continue_Or_Terminate (do_master_terminate);
      Inc_Master_Abort_Counter;
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
      if (watching_for_master_abort)
      begin
        Linger_Until_DEVSEL_Or_Master_Abort_Or_Target_Abort (drive_ad_bus,
                                      master_write_data[PCI_BUS_DATA_RANGE:0],
                                      master_mask_l[PCI_BUS_CBE_RANGE:0],
                                      do_master_terminate, got_master_abort);
      end
      else
      begin
        got_master_abort = 1'b0;
      end
      if (got_master_abort)
      begin
        got_target_retry = 1'b0; got_target_stop = 1'b0; got_target_abort = 1'b0;
      end
      else
      begin
        Linger_Until_Target_Waitstates_Done (drive_ad_bus,
                                           master_write_data[PCI_BUS_DATA_RANGE:0],
                                           master_mask_l[PCI_BUS_CBE_RANGE:0],
                                           do_master_terminate);
        target_read_data[PCI_BUS_DATA_RANGE:0] = ad_now[PCI_BUS_DATA_RANGE:0];  // unconditionally grab.
        if (~devsel_now & stop_now)
        begin
          got_target_retry = 1'b0; got_target_stop = 1'b0; got_target_abort = 1'b1;
        end
        else if (devsel_now & trdy_now & stop_now)
        begin
          got_target_retry = 1'b0; got_target_stop = 1'b1; got_target_abort = 1'b0;
        end
        else if (devsel_now & ~trdy_now & stop_now)
        begin
          got_target_retry = 1'b1; got_target_stop = 1'b0; got_target_abort = 1'b0;
        end
        else if (devsel_now & trdy_now & ~stop_now)
        begin
          got_target_retry = 1'b0; got_target_stop = 1'b0; got_target_abort = 1'b0;
        end
        else
        begin
          if (~pci_reset_comb)
          begin
            $display ("*** test %h - Master got unexpected Target Handshake Signals, at %t",
                        test_device_id[2:0], $time);
            error_detected <= ~error_detected;
          end
          `NO_ELSE;
          got_target_retry = 1'b0; got_target_stop = 1'b0; got_target_abort = 1'b1;
        end
      end
    end
    if ((got_master_abort | got_target_retry | got_target_stop | got_target_abort)
          & ~do_master_terminate)  // If not do_master_terminate, FRAME still asserted
    begin  // turn-around cycle on FRAME
      master_ad_out[PCI_BUS_DATA_RANGE:0] <= master_write_data[PCI_BUS_DATA_RANGE:0];
      master_ad_oe <= drive_ad_bus;
      master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
      master_cbe_oe <= 1'b1;
      master_debug_force_bad_par <= hold_master_data_par_err;
      master_got_master_abort <= 1'b0;
      master_got_target_abort <= 1'b0;
      master_got_target_retry <= 1'b0;
      master_perr_check_next <= ~drive_ad_bus;
      Deassert_FRAME;  // do the work that master_terminate would have already done
      Assert_IRDY;
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
    end
    if (got_master_abort | got_target_retry | got_target_stop | got_target_abort
         | do_master_terminate)  // If do_master_terminate, FRAME already deasserted
    begin
// If doing immediate Address phase due to fast back-to-back, don't drive bus here
// Extremely subtle point.
// Cannot do a fast back-to-back transfer if Address Lines are being stepped!
// Fast-Back-To-Back only works if the device is able to grab the bus the next cycle.
// It must do this because the PCI Arbiter thinks the bus is busy, and might grant
//   mastership to another party without a wait state assuming that an idle state
//   must be inserted by the present device before it re-drives the bus.
// The other party will drive the bus the next clock if it does NOT see FRAME
//   asserted now.  Frame will always be delayed by address-stepping devices.
// See the PCI Local Bus Spec Revision 2.2 section 3.4.1 and 3.4.2.
//   no fast B2B if master or target abort, to give time to report error to Config Reg
      if (~got_master_abort & ~got_target_abort
             & master_gnt_now & enable_fast_back_to_back & master_fast_b2b_en
             & This_Master_Drove_The_AD_Bus_The_Last_Clock
             & test_start & (test_master_number[2:0] == test_device_id[2:0])
             & (   (test_command[3:0] != PCI_COMMAND_CONFIG_READ)
                 & (test_command[3:0] != PCI_COMMAND_CONFIG_WRITE) ) )
      begin
        want_fast_back_to_back = 1'b1;
// No clock here to let the next command dispatch quickly.  The dispatcher has a wait
      end
      else
      begin
// Otherwise enforce an idle state
        master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
        master_ad_oe <= 1'b0;
        master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= PCI_COMMAND_RESERVED_READ_4;  // easy to see
        master_cbe_oe <= 1'b0;
        master_debug_force_bad_par <= 1'b0;
        master_got_master_abort <= got_master_abort;
        master_got_target_abort <= got_target_abort;
        master_got_target_retry <= got_target_retry;
        master_perr_check_next <= 1'b0;
        Deassert_FRAME;
        Deassert_IRDY;
        want_fast_back_to_back = 1'b0;
      end
    end
    else
    begin
      want_fast_back_to_back = 1'b0;
    end
  end
endtask

parameter TEST_MASTER_DOING_CONFIG_READ  = 3'b000;
parameter TEST_MASTER_DOING_CONFIG_WRITE = 3'b001;
parameter TEST_MASTER_DOING_MEM_READ     = 3'b010;
parameter TEST_MASTER_DOING_MEM_WRITE    = 3'b011;
parameter TEST_MASTER_DOING_MEM_READ_LN  = 3'b100; // Added by Tadej M., 06.12.2001
parameter TEST_MASTER_DOING_MEM_READ_MUL = 3'b110; // Added by Tadej M., 06.12.2001

task Report_On_Master_PCI_Ref_Start;
  input  [2:0] reference_type;
  begin
    case (reference_type[2:0])
    TEST_MASTER_DOING_CONFIG_READ:
      $display (" test master %h - Starting Config Read, at %t",
                    test_device_id[2:0], $time);
    TEST_MASTER_DOING_CONFIG_WRITE:
      $display (" test master %h - Starting Config Write, at %t",
                    test_device_id[2:0], $time);
    TEST_MASTER_DOING_MEM_READ:
      $display (" test master %h - Starting Memory Read, at %t",
                    test_device_id[2:0], $time);
    TEST_MASTER_DOING_MEM_WRITE:
      $display (" test master %h - Starting Memory Write, at %t",
                    test_device_id[2:0], $time);
    TEST_MASTER_DOING_MEM_READ_LN:
      $display (" test master %h - Starting Memory Read Line, at %t",
                    test_device_id[2:0], $time);
    TEST_MASTER_DOING_MEM_READ_MUL:
      $display (" test master %h - Starting Memory Read Line Multiple, at %t",
                    test_device_id[2:0], $time);
    default:
      $display (" test master %h - Doing Unknown Reference, at %t",
                    test_device_id[2:0], $time);
    endcase
`ifdef VERBOSE_TEST_DEVICE
    Report_Master_Reference_Paramaters;
`endif // VERBOSE_TEST_DEVICE
  end
endtask

task Report_On_Master_PCI_Ref_Finish;
  input   got_master_abort;
  input   got_target_abort;
  input   got_target_retry;
  input   got_target_stop;
  input  [9:0] words_transferred;
  begin
    if (got_master_abort)
    begin
      $display (" test master %h - Got Master Abort, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
    if (got_target_abort)
    begin
      $display (" test master %h - Got Target Abort, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
    if (got_target_retry)
    begin
      $display (" test master %h - Got Target Retry, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
    if (got_target_stop)
    begin
      $display (" test master %h - Got Target Stop, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
    if (~got_master_abort & ~got_target_abort & ~got_target_retry & ~got_target_stop)
    begin
      $display (" test master %h - Normal Success, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
    if (words_transferred != 10'h0)
    begin
      $display (" test master %h - Transferred %h words, at %t",
                    test_device_id[2:0], words_transferred[9:0], $time);
    end
    `NO_ELSE;
  end
endtask

// Tasks can't have local storage!  have to be module global
  reg     step_address;
  reg    [3:0] wait_states_this_time;
  reg    [9:0] words_transferred;
  reg     drive_ad_bus, watching_for_master_abort, do_master_terminate_this_time;
  reg    [PCI_BUS_DATA_RANGE:0] target_read_data;
  reg    [PCI_BUS_DATA_RANGE:0] master_write_data;
  reg    [PCI_BUS_CBE_RANGE:0] master_mask_l;
  reg    [PCI_BUS_DATA_RANGE:0] master_write_data_next;
  reg    [PCI_BUS_CBE_RANGE:0] master_mask_l_next;
  reg     got_master_abort, got_target_retry, got_target_stop, got_target_abort;
  reg     got_master_terminate;
task Execute_Master_PCI_Ref;
  input  [2:0] reference_type;
  output  want_fast_back_to_back;
  begin
    Master_Req_Bus;
    if (   (reference_type[2:0] == TEST_MASTER_DOING_CONFIG_READ)
         | (reference_type[2:0] == TEST_MASTER_DOING_CONFIG_WRITE) )
    begin
      step_address = TEST_MASTER_STEP_ADDRESS;
    end
    else
    begin
      step_address = TEST_MASTER_IMMEDIATE_ADDRESS;
    end
    Master_Assert_Address (modified_master_address[PCI_BUS_DATA_RANGE:0],
                     hold_master_command[PCI_BUS_CBE_RANGE:0],
                     step_address, hold_master_fast_b2b, hold_master_addr_par_err);
    Master_Unreq_Bus;  // After FRAME is asserted!
`ifdef REPORT_TEST_DEVICE
// Do Report after Address to let the time of the report line up with the bus event.
    Report_On_Master_PCI_Ref_Start (reference_type[2:0]);
`endif // REPORT_TEST_DEVICE
    drive_ad_bus = (reference_type[2:0] == TEST_MASTER_DOING_CONFIG_WRITE)
                 | (reference_type[2:0] == TEST_MASTER_DOING_MEM_WRITE);
    words_transferred = 9'h0;
    wait_states_this_time = hold_master_initial_waitstates[3:0];
    do_master_terminate_this_time =
                 ((words_transferred[9:0] + 4'h1) == hold_master_size[9:0]);
    watching_for_master_abort = 1'b1;
    master_write_data[PCI_BUS_DATA_RANGE:0] = hold_master_data[PCI_BUS_DATA_RANGE:0];
    master_mask_l[PCI_BUS_CBE_RANGE:0] = hold_master_byte_enables_l[PCI_BUS_CBE_RANGE:0];
    got_master_abort = 1'b0;
    got_target_retry = 1'b0;
    got_target_stop = 1'b0;
    got_target_abort = 1'b0;
    got_master_terminate = 1'b0;
    while (   ~got_master_abort & ~got_target_retry & ~got_target_stop
            & ~got_target_abort & ~got_master_terminate)
    begin
      Execute_Master_Waitstates_But_Quit_On_Target_Abort (drive_ad_bus,
                           master_mask_l[3:0], wait_states_this_time[3:0]);
      Execute_Master_Ref_Undrive_All_In_Any_Termination_Unless_Fast_B2B (drive_ad_bus,
                            watching_for_master_abort, do_master_terminate_this_time,
                            hold_master_fast_b2b, master_write_data[PCI_BUS_DATA_RANGE:0],
                            master_mask_l[PCI_BUS_CBE_RANGE:0],
                            target_read_data[PCI_BUS_DATA_RANGE:0],
                            got_master_abort, got_target_retry,
                            got_target_stop, got_target_abort,
                            want_fast_back_to_back);
      got_master_terminate = do_master_terminate_this_time;
      if (~got_master_abort & ~got_target_retry & ~got_target_abort)
      begin
        if (~drive_ad_bus)
        begin
          if ( master_check_received_data )
              Compare_Read_Data_With_Expected_Data (target_read_data[PCI_BUS_DATA_RANGE:0],
                                                master_write_data[PCI_BUS_DATA_RANGE:0],
                                                master_mask_l[PCI_BUS_CBE_RANGE:0]);

          master_received_data = target_read_data ;
          master_received_data_valid <= ~master_received_data_valid ;
        end
        `NO_ELSE;
        wait_states_this_time = hold_master_subsequent_waitstates[3:0];
        words_transferred = words_transferred + 10'b1;
        do_master_terminate_this_time =
                        ((words_transferred[9:0] + 4'h1) == hold_master_size[9:0]);
        watching_for_master_abort = 1'b0;
        Update_Write_Data (master_write_data[PCI_BUS_DATA_RANGE:0],
                           master_mask_l[PCI_BUS_CBE_RANGE:0],
                           master_write_data_next[PCI_BUS_DATA_RANGE:0],
                           master_mask_l_next[PCI_BUS_CBE_RANGE:0]);
        master_write_data[PCI_BUS_DATA_RANGE:0] = master_write_data_next[PCI_BUS_DATA_RANGE:0];
        master_mask_l[PCI_BUS_CBE_RANGE:0] = master_mask_l_next[PCI_BUS_CBE_RANGE:0];
      end
      `NO_ELSE;
    end
`ifdef NORMAL_PCI_CHECKS
    Check_Master_Burst_Termination_Cause (got_master_abort, got_master_terminate,
                    got_target_retry, got_target_stop, got_target_abort,
                    words_transferred[9:0]);
`endif // NORMAL_PCI_CHECKS
`ifdef VERBOSE_TEST_DEVICE
    Report_On_Master_PCI_Ref_Finish (got_master_abort, got_target_abort,
                                     got_target_retry, got_target_stop,
                                     words_transferred[9:0]);
`endif // VERBOSE_TEST_DEVICE
  end
endtask

// Task to print debug info
// NOTE This must change if bit allocation changes
task Report_Master_Reference_Paramaters;
  begin
    if (hold_master_address[23:9] != 15'h0000)
    begin
// hold_master_address, hold_master_command, hold_master_data,
// hold_master_byte_enables_l, hold_master_size
      $display ("  First Master Data Wait States %h, Subsequent Master Data Wait States %h",
            hold_master_initial_waitstates[3:0],
            hold_master_subsequent_waitstates[3:0]);
      $display ("  Master Fast B-to_B En %h, Expect Master Abort %h",
            hold_master_fast_b2b, hold_master_expect_master_abort);
      $display ("  Target Devsel Speed %h, Target Termination %h,",
            hold_master_target_devsel_speed[1:0],
            hold_master_target_termination[2:0]);
      $display ("  First Target Data Wait States %h, Subsequent Target Data Wait States %h",
            hold_master_target_initial_waitstates[3:0],
            hold_master_target_subsequent_waitstates[3:0]);
      $display ("  Addr Par Error %h, Data Par Error %h",
            hold_master_addr_par_err, hold_master_data_par_err);
    end
    `NO_ELSE;
  end
endtask

task Complain_That_Test_Not_Written;
  output  want_fast_back_to_back;
  begin
    $display ("*** test master %h - Diag not written yet: 'h%x, at %t",
                test_device_id[2:0], hold_master_command[3:0], $time);
    error_detected <= ~error_detected;
    master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
    master_ad_oe <= 1'b0;
    master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= PCI_COMMAND_RESERVED_READ_4;  // easy to see
    master_cbe_oe <= 1'b0;
    master_debug_force_bad_par <= 1'b0;
    master_got_master_abort <= 1'b0;
    master_got_target_abort <= 1'b0;
    master_got_target_retry <= 1'b0;
    master_perr_check_next <= 1'b0;
    Deassert_FRAME;
    Deassert_IRDY;
    Clock_Wait_Unless_Reset;  // wait for outputs to settle
    Indicate_Done;  // indicate done as early as possible, while still after start
    want_fast_back_to_back = 1'b0;
  end
endtask

task Reset_Master_To_Idle;
  begin
    master_req_out <= 1'b0;
    master_ad_out[PCI_BUS_DATA_RANGE:0]   <= `PCI_BUS_DATA_ZERO;
    master_ad_oe <= 1'b0;
    master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= `PCI_BUS_CBE_ZERO;
    master_cbe_oe <= 1'b0;
    master_frame_out <= 1'b0;      master_irdy_out <= 1'b0;
    master_got_master_abort <= 1'b0;
    master_got_target_abort <= 1'b0;
    master_got_target_retry <= 1'b0;
    master_perr_check_next <= 1'b0;
    test_accepted_next <= 1'b0;
  end
endtask

// We want the Target to do certain behavior to let us test the interface.
// We will use Address Bits to encode Target Wait State, Target Completion,
//   and Target Error info.
//
// Our Test Chips will use an 8-Bit Base Address Register, which
//   will result in a 16 MByte memory map for each BAR.
// Our Targets only have 256 bytes of SRAM.  That leaves 16 Address
//   Bits to play with.
// Allocate Address Bits to mean the following:
// Bit  [23]    When 1, the Target acts upon the fancy encoded info below
// Bits [22:19] Target Wait States for First Data Item
// Bits [18:15] Target Wait States for Subsequent Data Items
// Bits [14:12] What sort of Target Termination to make
// Bits [11:10] Devsel Speed
// Bit  [9]     Whether to make or expect a Data Parity Error
// Bit  [8]     Whether to expect an Address Parity Error

// fire off Master tasks in response to top-level testbench
  reg     want_fast_back_to_back;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (  ~pci_reset_comb & test_start
        & (test_master_number[2:0] == test_device_id[2:0]))
    begin
      want_fast_back_to_back = 1'b1;
      while (want_fast_back_to_back)
      begin
        Indicate_Start;
// Grab address and data in case it takes a while to get bus mastership
// Intentionally use "=" assignment so these variables are available to tasks
        hold_master_address[23:9] = test_address[23:9];
        hold_master_command[3:0] = test_command[3:0];
        hold_master_data[PCI_BUS_DATA_RANGE:0] = test_data[PCI_BUS_DATA_RANGE:0];
        hold_master_byte_enables_l[PCI_BUS_CBE_RANGE:0] =
                                      test_byte_enables_l[PCI_BUS_CBE_RANGE:0];
        hold_master_size[9:0] = test_size[9:0];
        hold_master_addr_par_err = test_make_addr_par_error;
        hold_master_data_par_err = test_make_data_par_error;
        hold_master_initial_waitstates[3:0] = test_master_initial_wait_states[3:0];
        hold_master_subsequent_waitstates[3:0] = test_master_subsequent_wait_states[3:0];
        hold_master_target_initial_waitstates[3:0] = test_target_initial_wait_states[3:0];
        hold_master_target_subsequent_waitstates[3:0] = test_target_subsequent_wait_states[3:0];
        hold_master_target_devsel_speed[1:0] = test_target_devsel_speed[1:0];
        hold_master_fast_b2b = test_fast_back_to_back;
        hold_master_target_termination[2:0] = test_target_termination[2:0];
        hold_master_expect_master_abort = test_expect_master_abort;
        if (hold_master_size[9:0] == 0)  // This means read causing delayed read
        begin
          hold_master_size = 1;
          hold_master_target_termination = `Test_Target_Retry_Before_First;
        end
        `NO_ELSE;
        // changed by Miha D. - no need for encoded addresses
        modified_master_address = test_address ;
        /*
        modified_master_address[31:24] = test_address[31:24];
        modified_master_address[`TARGET_ENCODED_PARAMATERS_ENABLE] = 1'b1;
        modified_master_address[`TARGET_ENCODED_INIT_WAITSTATES] =
                                          test_target_initial_wait_states[3:0];
        modified_master_address[`TARGET_ENCODED_SUBS_WAITSTATES] =
                                          test_target_subsequent_wait_states[3:0];
        modified_master_address[`TARGET_ENCODED_TERMINATION]  =
                                          test_target_termination[2:0];
        modified_master_address[`TARGET_ENCODED_DEVSEL_SPEED] =
                                          test_target_devsel_speed[1:0];
        modified_master_address[`TARGET_ENCODED_DATA_PAR_ERR] =
                                          test_make_data_par_error;
        modified_master_address[`TARGET_ENCODED_ADDR_PAR_ERR] =
                                          test_make_addr_par_error;
        modified_master_address[7:0] = test_address[7:0];
        */
        case (test_command[3:0])
        PCI_COMMAND_INTERRUPT_ACKNOWLEDGE:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_SPECIAL_CYCLE:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_IO_READ:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_READ,
                                             want_fast_back_to_back);
        PCI_COMMAND_IO_WRITE:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_WRITE,
                                             want_fast_back_to_back);
        PCI_COMMAND_RESERVED_READ_4:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_RESERVED_WRITE_5:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_MEMORY_READ:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_READ,
                                             want_fast_back_to_back);
        PCI_COMMAND_MEMORY_WRITE:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_WRITE,
                                             want_fast_back_to_back);
        PCI_COMMAND_RESERVED_READ_8:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_RESERVED_WRITE_9:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_CONFIG_READ:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_CONFIG_READ,
                                             want_fast_back_to_back);
        PCI_COMMAND_CONFIG_WRITE:
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_CONFIG_WRITE,
                                             want_fast_back_to_back);
        PCI_COMMAND_MEMORY_READ_MULTIPLE: // Added by Tadej M., 06.12.2001
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_READ_MUL,
                                             want_fast_back_to_back);
//          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_DUAL_ADDRESS_CYCLE:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_MEMORY_READ_LINE: // Added by Tadej M., 06.12.2001
          Execute_Master_PCI_Ref (TEST_MASTER_DOING_MEM_READ_LN,
                                             want_fast_back_to_back);
//          Complain_That_Test_Not_Written (want_fast_back_to_back);
        PCI_COMMAND_MEMORY_WRITE_INVALIDATE:
          Complain_That_Test_Not_Written (want_fast_back_to_back);
        default:
          begin
            $display ("*** test master %h - Unknown External Device Activity 'h%x, at %t",
                        test_device_id[2:0], test_command, $time);
            error_detected <= ~error_detected;
          end
        endcase
        if (pci_reset_comb)
        begin
          want_fast_back_to_back = 1'b0;
        end
        `NO_ELSE;
      end
    end // while want_fast_back_to_back
    else if (~frame_now & ~irdy_now & master_gnt_now)
    begin  // park bus
      master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_PARK_VALUE;
      master_ad_oe <= 1'b1;
      master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= PCI_COMMAND_RESERVED_READ_4;
      master_cbe_oe <= 1'b1;
    end
    else
    begin  // unpark if grant is removed
      master_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
      master_ad_oe <= 1'b0;
      master_cbe_l_out[PCI_BUS_CBE_RANGE:0] <= PCI_COMMAND_RESERVED_READ_4;
      master_cbe_oe <= 1'b0;
    end
// NOTE WORKING need to handle master_got_target_retry here

// Because this is sequential code, have to reset all regs if the above falls
//   through due to a reset.  This would not be needed in synthesizable code.
    if (pci_reset_comb)
    begin
      Reset_Master_To_Idle;
    end
    `NO_ELSE;
  end
endmodule

