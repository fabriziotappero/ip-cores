//===========================================================================
// $Id: pci_bus_monitor.v,v 1.4 2003-08-03 18:04:44 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  Watch the PCI Bus Wires to try to see Protocol Errors.
//           This module also has access to the individual PCI Bus OE
//           signals for each interface (either through extra output
//           ports or through "." notation), and it can see when more
//           than one interface is driving the bus, even if the values
//           are the same.
//           A future version of this module should write out a transcript
//           of the activity seen on the PCI Bus.
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
// NOTE:  This module watches the PCI bus and gives commentary about what
//        it sees.
//        I hope that this can get a parameter which says whether to put
//        its log in a file, on the terminal, or both.
//
// TO DO: create code to act on MONITOR_CREATE_BUS_ACTIVITY_TRANSCRIPT
//
//===========================================================================

// Note that master aborts are the norm on Special Cycles!

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
//`timescale 1ns/10ps

module pci_bus_monitor (
  pci_ext_ad, pci_ext_cbe_l, pci_ext_par,
  pci_ext_frame_l, pci_ext_irdy_l,
  pci_ext_devsel_l, pci_ext_trdy_l, pci_ext_stop_l,
  pci_ext_perr_l, pci_ext_serr_l,
  pci_real_req_l, pci_real_gnt_l,
  pci_ext_req_l, pci_ext_gnt_l,
  test_error_event, test_observe_r_oe_sigs,
  test_observe_0_oe_sigs, test_observe_1_oe_sigs,
  test_observe_2_oe_sigs, test_observe_3_oe_sigs,
  pci_ext_reset_l, pci_ext_clk,
  log_file_desc
);

`include "pci_blue_options.vh"
`include "pci_blue_constants.vh"

  input  [PCI_BUS_DATA_RANGE:0] pci_ext_ad;
  input  [PCI_BUS_CBE_RANGE:0] pci_ext_cbe_l;
  input   pci_ext_par;
  input   pci_ext_frame_l, pci_ext_irdy_l;
  input   pci_ext_devsel_l, pci_ext_trdy_l, pci_ext_stop_l;
  input   pci_ext_perr_l, pci_ext_serr_l;
  input   pci_real_req_l, pci_real_gnt_l;
  input  [3:0] pci_ext_req_l;
  input  [3:0] pci_ext_gnt_l;
  output  test_error_event;
  input  [5:0] test_observe_r_oe_sigs;
  input  [5:0] test_observe_0_oe_sigs;
  input  [5:0] test_observe_1_oe_sigs;
  input  [5:0] test_observe_2_oe_sigs;
  input  [5:0] test_observe_3_oe_sigs;

  input   pci_ext_reset_l, pci_ext_clk;

  input [31:0] log_file_desc ;
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

// watch for the PCI Clock going X
  always @(pci_ext_clk)
  begin
    if (($time > 0) && ((pci_ext_clk ^ pci_ext_clk) === 1'bx))
    begin
      $display ("*** monitor - PCI External Clock invalid 'h%x, at %t",
                  pci_ext_clk, $time);
      $fdisplay (log_file_desc, "*** monitor - PCI External Clock invalid 'h%x, at %t",
                  pci_ext_clk, $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end

// watch for the Reset signal going X
  always @(pci_ext_reset_l)
  begin
    if (($time > 0) & ((pci_ext_reset_l ^ pci_ext_reset_l) === 1'bx))
    begin
      $display ("*** monitor - PCI External RESET_L invalid 'h%x, at %t",
                  pci_ext_reset_l, $time);
      $fdisplay (log_file_desc, "*** monitor - PCI External RESET_L invalid 'h%x, at %t",
                  pci_ext_reset_l, $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end

// Make sure all PCI signals are HIGH-Z or Deasserted HIGH as needed
//   when the external PCI bus leaves reset.
// The values of some signals are set by pullups on the PC board
  always @(posedge pci_ext_reset_l)
  begin
  if ($time > 0)
    begin
      if (pci_ext_ad[PCI_BUS_DATA_RANGE:0] !== `PCI_BUS_DATA_Z)
      begin
        $display ("*** monitor - PCI External AD not high-Z 'h%x, at %t",
                    pci_ext_ad[PCI_BUS_DATA_RANGE:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External AD not high-Z 'h%x, at %t",
                    pci_ext_ad[PCI_BUS_DATA_RANGE:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0] !== `PCI_BUS_CBE_Z)
      begin
        $display ("*** monitor - PCI External CBE_L not high-Z 'h%x, at %t",
                    pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External CBE_L not high-Z 'h%x, at %t",
                    pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_par !== 1'bz)
      begin
        $display ("*** monitor - PCI External PAR not high-Z 'h%x, at %t",
                    pci_ext_par, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External PAR not high-Z 'h%x, at %t",
                    pci_ext_par, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_frame_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External FRAME_L invalid 'h%x, at %t",
                    pci_ext_frame_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External FRAME_L invalid 'h%x, at %t",
                    pci_ext_frame_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_irdy_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External IRDY_L invalid 'h%x, at %t",
                    pci_ext_irdy_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External IRDY_L invalid 'h%x, at %t",
                    pci_ext_irdy_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_devsel_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External DEVSEL_L invalid 'h%x, at %t",
                    pci_ext_devsel_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External DEVSEL_L invalid 'h%x, at %t",
                    pci_ext_devsel_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_trdy_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External TRDY_L invalid 'h%x, at %t",
                    pci_ext_trdy_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External TRDY_L invalid 'h%x, at %t",
                    pci_ext_trdy_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_stop_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External STOP_L invalid 'h%x, at %t",
                    pci_ext_stop_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External STOP_L invalid 'h%x, at %t",
                    pci_ext_stop_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_perr_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External PERR_L invalid 'h%x, at %t",
                    pci_ext_perr_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External PERR_L invalid 'h%x, at %t",
                    pci_ext_perr_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_serr_l !== 1'b1)
      begin
        $display ("*** monitor - PCI External SERR_L invalid 'h%x, at %t",
                    pci_ext_serr_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External SERR_L invalid 'h%x, at %t",
                    pci_ext_serr_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_real_req_l !== 1'b1)
      begin
        $display ("*** monitor - PCI Internal REQ_L invalid 'h%x, at %t",
                    pci_real_req_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Internal REQ_L invalid 'h%x, at %t",
                    pci_real_req_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_real_gnt_l !== 1'b1)
      begin
        $display ("*** monitor - PCI Internal GNT_L invalid 'h%x, at %t",
                    pci_real_gnt_l, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Internal GNT_L invalid 'h%x, at %t",
                    pci_real_gnt_l, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_req_l[3:0] !== 4'hF)
      begin
        $display ("*** monitor - PCI External REQ_L invalid 'h%x, at %t",
                    pci_ext_req_l[3:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External REQ_L invalid 'h%x, at %t",
                    pci_ext_req_l[3:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (pci_ext_gnt_l[3:0] !== 4'hF)
      begin
        $display ("*** monitor - PCI External GNT_L invalid 'h%x, at %t",
                    pci_ext_gnt_l[3:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI External GNT_L invalid 'h%x, at %t",
                    pci_ext_gnt_l[3:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
    end
    `NO_ELSE;
  end

task Watch_For_X_On_OE_Sigs;
  input  [2:0] signal_source;
  input  [5:0] oe_signals;
  begin
    if ((^oe_signals[5:0]) === 1'bX)
    begin
      if (signal_source[2:0] == `Test_Master_Real)
      begin
        $display ("*** monitor - PCI Real OE signals have X's {F, I, D_T_S, AD, CBE, PERR} 'b%b, at %t",
                    oe_signals[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Real OE signals have X's {F, I, D_T_S, AD, CBE, PERR} 'b%b, at %t",
                    oe_signals[5:0], $time);
      end
      else
      begin
        $display ("*** monitor - PCI Test %h OE signals have X's {F, I, D_T_S, AD, CBE, PERR} 'b%b, at %t",
                    signal_source[2:0], oe_signals[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Test %h OE signals have X's {F, I, D_T_S, AD, CBE, PERR} 'b%b, at %t",
                    signal_source[2:0], oe_signals[5:0], $time);
        error_detected <= ~error_detected;
      end
    end
    `NO_ELSE;
  end
endtask

task Watch_For_Simultaneous_Drive_Of_OE_Sigs;
  input  [2:0] signal_source_0;
  input  [2:0] signal_source_1;
  input  [5:0] oe_signals_0;
  input  [5:0] oe_signals_1;
  begin
    if ((oe_signals_0 & oe_signals_1) !== 6'h00)
    begin
      if (signal_source_0[2:0] == `Test_Master_Real)
      begin
        $display ("*** monitor - PCI Real and Test %x drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_1[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Real and Test %x drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_1[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
      end
      else if (signal_source_1[2:0] == `Test_Master_Real)
      begin
        $display ("*** monitor - PCI Test %x and Real drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Test %x and Real drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
      end
      else
      begin
        $display ("*** monitor - PCI Test %x and Test %h drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], signal_source_1[1:0],
                    oe_signals_0[5:0], oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Test %x and Test %h drive bus simultaneously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], signal_source_1[1:0],
                    oe_signals_0[5:0], oe_signals_1[5:0], $time);
      end
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

task Watch_For_Deassert_Before_Tristate ;
    input [2:0] signal_source ;
    input [5:0] prev_oe_sigs ;
    input [5:0] current_oe_sigs ;
    input       prev_perr ;
    input       prev_frame ;
    input       prev_irdy ;
    input       prev_trdy ;
    input       prev_stop ;
    input       prev_devsel ;
    reg         do_error ;
begin
    do_error = 0 ;
    if ( prev_oe_sigs[0] && !current_oe_sigs[0] && prev_perr )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving PERR before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving PERR before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving PERR before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving PERR before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( prev_oe_sigs[3] && !current_oe_sigs[3] && prev_stop )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving STOP before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving STOP before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving STOP before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving STOP before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( prev_oe_sigs[3] && !current_oe_sigs[3] && prev_trdy )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving TRDY before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving TRDY before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving TRDY before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving TRDY before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( prev_oe_sigs[3] && !current_oe_sigs[3] && prev_devsel )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving DEVSEL before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving DEVSEL before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving DEVSEL before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving DEVSEL before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( prev_oe_sigs[4] && !current_oe_sigs[4] && prev_irdy )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving IRDY before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving IRDY before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving IRDY before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving IRDY before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( prev_oe_sigs[5] && !current_oe_sigs[5] && prev_frame )
    begin
        do_error = 1 ;
        if ( signal_source == `Test_Master_Real )
        begin
            $display("*** monitor - PCI Real Stopped driving FRAME before Deasserting it for one cycle, at %t", $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Real Stopped driving FRAME before Deasserting it for one cycle, at %t", $time) ;
        end
        else
        begin
            $display("*** monitor - PCI Test %x Stopped driving FRAME before Deasserting it for one cycle, at %t", signal_source, $time) ;
            $fdisplay(log_file_desc, "*** monitor - PCI Test %x Stopped driving FRAME before Deasserting it for one cycle, at %t", signal_source, $time) ;
        end
    end

    if ( do_error )
        error_detected <= ~error_detected ;
end
endtask

task Watch_For_Back_To_Back_Drive_Of_OE_Sigs;
  input  [2:0] signal_source_0;
  input  [2:0] signal_source_1;
  input  [5:0] oe_signals_0;
  input  [5:0] oe_signals_1;
  begin
    if ((oe_signals_0 & oe_signals_1) !== 6'h00)
    begin
      if (signal_source_0[2:0] == `Test_Master_Real)
      begin
        $display ("*** monitor - PCI Real drives when Test %x drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_1[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Real drives when Test %x drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_1[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
      end
      else if (signal_source_1[2:0] == `Test_Master_Real)
      begin
        $display ("*** monitor - PCI Test %x drives when Real drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Test %x drives when Real drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], oe_signals_0[5:0],
                    oe_signals_1[5:0], $time);
      end
      else
      begin
        $display ("*** monitor - PCI Test %x drives when Test %h drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], signal_source_1[1:0],
                    oe_signals_0[5:0], oe_signals_1[5:0], $time);
        $fdisplay (log_file_desc, "*** monitor - PCI Test %x drives when Test %h drove previously {F, I, D_T_S, AD, CBE, PERR} 'b%b, 'b%b, at %t",
                    signal_source_0[2:0], signal_source_1[1:0],
                    oe_signals_0[5:0], oe_signals_1[5:0], $time);
      end
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
  end
endtask

// watch for PCI devices simultaneously driving PCI wires
// OE Observation signals are
// {frame_oe, irdy_oe, devsel_t_s_oe, ad_oe, cbe_oe, perr_oe}
// Unused ports should be wired to 0
  reg    [5:0] prev_real_oe_sigs;
  reg    [5:0] prev_test_0_oe_sigs;
  reg    [5:0] prev_test_1_oe_sigs;
  reg    [5:0] prev_test_2_oe_sigs;
  reg    [5:0] prev_test_3_oe_sigs;

  // Make Asserted HIGH signals to prevent (cause?) confusion
  wire    frame_now =  ~pci_ext_frame_l;
  wire    irdy_now =   ~pci_ext_irdy_l;
  wire    devsel_now = ~pci_ext_devsel_l;
  wire    trdy_now =   ~pci_ext_trdy_l;
  wire    stop_now =   ~pci_ext_stop_l;
  wire    perr_now =   ~pci_ext_perr_l;
// Delay PCI bus signals, used by several tests below.
// Detect Address Phases on the bus.
// Ignore Dual Access Cycle, as mentioned in the PCI Local Bus Spec
// Revision 2.2 section 3.1.1.
  reg    [4:0] grant_prev;
  reg    [PCI_BUS_DATA_RANGE:0] ad_prev;
  reg    [PCI_BUS_CBE_RANGE:0] cbe_l_prev;
  reg     frame_prev, irdy_prev, devsel_prev, trdy_prev, stop_prev, perr_prev;
  reg     address_phase_prev, read_operation_prev;

  always @(posedge pci_ext_clk or negedge pci_ext_reset_l)
  begin
    if (pci_ext_reset_l == 1'b0)
    begin
      prev_real_oe_sigs <= 6'h00;
      prev_test_0_oe_sigs <= 6'h00;
      prev_test_1_oe_sigs <= 6'h00;
      prev_test_2_oe_sigs <= 6'h00;
      prev_test_3_oe_sigs <= 6'h00;
    end
    else
    begin
      prev_real_oe_sigs <= test_observe_r_oe_sigs[5:0];
      prev_test_0_oe_sigs <= test_observe_0_oe_sigs[5:0];
      prev_test_1_oe_sigs <= test_observe_1_oe_sigs[5:0];
      prev_test_2_oe_sigs <= test_observe_2_oe_sigs[5:0];
      prev_test_3_oe_sigs <= test_observe_3_oe_sigs[5:0];
    end
  end

  always @(posedge pci_ext_clk)
  begin
    if (($time > 0) & (pci_ext_reset_l == 1'b1))
    begin
      Watch_For_X_On_OE_Sigs (`Test_Master_Real, test_observe_r_oe_sigs[5:0]);
      Watch_For_X_On_OE_Sigs (3'h0, test_observe_0_oe_sigs[5:0]);
      Watch_For_X_On_OE_Sigs (3'h1, test_observe_1_oe_sigs[5:0]);
      Watch_For_X_On_OE_Sigs (3'h2, test_observe_2_oe_sigs[5:0]);
      Watch_For_X_On_OE_Sigs (3'h3, test_observe_3_oe_sigs[5:0]);

      Watch_For_Simultaneous_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h0,
                     test_observe_r_oe_sigs[5:0], test_observe_0_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h1,
                     test_observe_r_oe_sigs[5:0], test_observe_1_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h2,
                     test_observe_r_oe_sigs[5:0], test_observe_2_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h3,
                     test_observe_r_oe_sigs[5:0], test_observe_3_oe_sigs[5:0]);

      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h0, 3'h1,
                     test_observe_0_oe_sigs[5:0], test_observe_1_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h0, 3'h2,
                     test_observe_0_oe_sigs[5:0], test_observe_2_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h0, 3'h3,
                     test_observe_0_oe_sigs[5:0], test_observe_3_oe_sigs[5:0]);

      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h1, 3'h2,
                     test_observe_1_oe_sigs[5:0], test_observe_2_oe_sigs[5:0]);
      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h1, 3'h3,
                     test_observe_1_oe_sigs[5:0], test_observe_3_oe_sigs[5:0]);

      Watch_For_Simultaneous_Drive_Of_OE_Sigs (3'h2, 3'h3,
                     test_observe_2_oe_sigs[5:0], test_observe_3_oe_sigs[5:0]);

      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h0,
                     test_observe_r_oe_sigs[5:0], prev_test_0_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h1,
                     test_observe_r_oe_sigs[5:0], prev_test_1_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h2,
                     test_observe_r_oe_sigs[5:0], prev_test_2_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (`Test_Master_Real, 3'h3,
                     test_observe_r_oe_sigs[5:0], prev_test_3_oe_sigs[5:0]);

      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h0, `Test_Master_Real,
                     test_observe_0_oe_sigs[5:0], prev_real_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h0, 3'h1,
                     test_observe_0_oe_sigs[5:0], prev_test_1_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h0, 3'h2,
                     test_observe_0_oe_sigs[5:0], prev_test_2_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h0, 3'h3,
                     test_observe_0_oe_sigs[5:0], prev_test_3_oe_sigs[5:0]);

      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h1, 3'h0,
                     test_observe_1_oe_sigs[5:0], prev_test_0_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h1, `Test_Master_Real,
                     test_observe_1_oe_sigs[5:0], prev_real_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h1, 3'h2,
                     test_observe_1_oe_sigs[5:0], prev_test_2_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h1, 3'h3,
                     test_observe_1_oe_sigs[5:0], prev_test_3_oe_sigs[5:0]);

      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h2, 3'h0,
                     test_observe_2_oe_sigs[5:0], prev_test_0_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h2, 3'h1,
                     test_observe_2_oe_sigs[5:0], prev_test_1_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h2, `Test_Master_Real,
                     test_observe_2_oe_sigs[5:0], prev_real_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h2, 3'h3,
                     test_observe_2_oe_sigs[5:0], prev_test_3_oe_sigs[5:0]);

      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h3, 3'h0,
                     test_observe_3_oe_sigs[5:0], prev_test_0_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h3, 3'h1,
                     test_observe_3_oe_sigs[5:0], prev_test_1_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h3, 3'h2,
                     test_observe_3_oe_sigs[5:0], prev_test_2_oe_sigs[5:0]);
      Watch_For_Back_To_Back_Drive_Of_OE_Sigs (3'h3, `Test_Master_Real,
                     test_observe_3_oe_sigs[5:0], prev_real_oe_sigs[5:0]);

      Watch_For_Deassert_Before_Tristate(`Test_Master_Real, prev_real_oe_sigs, test_observe_r_oe_sigs, perr_prev, frame_prev, irdy_prev, trdy_prev, stop_prev, devsel_prev) ;
      Watch_For_Deassert_Before_Tristate(3'h0, prev_test_0_oe_sigs, test_observe_0_oe_sigs, perr_prev, frame_prev, irdy_prev, trdy_prev, stop_prev, devsel_prev) ;
      Watch_For_Deassert_Before_Tristate(3'h1, prev_test_1_oe_sigs, test_observe_1_oe_sigs, perr_prev, frame_prev, irdy_prev, trdy_prev, stop_prev, devsel_prev) ;
      Watch_For_Deassert_Before_Tristate(3'h2, prev_test_2_oe_sigs, test_observe_2_oe_sigs, perr_prev, frame_prev, irdy_prev, trdy_prev, stop_prev, devsel_prev) ;
      Watch_For_Deassert_Before_Tristate(3'h3, prev_test_3_oe_sigs, test_observe_3_oe_sigs, perr_prev, frame_prev, irdy_prev, trdy_prev, stop_prev, devsel_prev) ;

    end
    `NO_ELSE;
  end

  wire [4:0] grant_now = {pci_ext_gnt_l[3:0], pci_real_gnt_l} ;

  always @(posedge pci_ext_clk or negedge pci_ext_reset_l)
  begin
    if (pci_ext_reset_l == 1'b0)
    begin
      grant_prev <= 5'h00;
      ad_prev[PCI_BUS_DATA_RANGE:0] <= `PCI_BUS_DATA_X;
      cbe_l_prev[PCI_BUS_CBE_RANGE:0] <= `PCI_BUS_CBE_X;
      frame_prev <= 1'b0;
      irdy_prev <= 1'b0;
      devsel_prev <= 1'b0;
      trdy_prev <= 1'b0;
      stop_prev <= 1'b0;
      address_phase_prev <= 1'b0;
      read_operation_prev <= 1'b0;
    end
    else
    begin
      grant_prev <= grant_now ;
      ad_prev[PCI_BUS_DATA_RANGE:0] <= pci_ext_ad[PCI_BUS_DATA_RANGE:0];
      cbe_l_prev[PCI_BUS_CBE_RANGE:0] <= pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0];
      frame_prev <= frame_now;
      irdy_prev <= irdy_now;
      devsel_prev <= devsel_now;
      trdy_prev <= trdy_now;
      stop_prev <= stop_now;
      perr_prev <= perr_now ;

      if (frame_now & ~frame_prev)
      begin
        address_phase_prev <= 1'b1;
        read_operation_prev <= ~pci_ext_cbe_l[0];  // reads have LSB == 0;
      end
      else if(address_phase_prev && (cbe_l_prev[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_DUAL_ADDRESS_CYCLE))
      begin
        address_phase_prev <= 1'b1;
        read_operation_prev <= ~pci_ext_cbe_l[0];  // reads have LSB == 0;
      end
      else
      begin
        address_phase_prev <= 1'b0;
        read_operation_prev <= read_operation_prev;
      end
    end
  end

// Track the behavior of the PCI Arbiter.  Rules:
// 1) No grant during reset
// 2) At most 1 grant at any time
// 3) One non-grant cycle on any grant transition when the bus is idle
// See the PCI Local Bus Spec Revision 2.2 Appendix C.
  always @(posedge pci_ext_clk)
  begin
    if ($time > 0)
    begin
      if ((^{pci_ext_gnt_l[3:0], pci_real_gnt_l}) === 1'bX)
      begin
        $display ("*** monitor - PCI GNT_L unknown 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI GNT_L unknown 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if ((pci_ext_reset_l == 1'b0)
           && ({pci_ext_gnt_l[3:0], pci_real_gnt_l} != 5'h1F))
      begin
        $display ("*** monitor - PCI GNT_L not deasserted during Reset 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        $fdisplay (log_file_desc, "*** monitor - PCI GNT_L not deasserted during Reset 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (   (~pci_ext_gnt_l[3] & ~pci_ext_gnt_l[2])
          || (~pci_ext_gnt_l[3] & ~pci_ext_gnt_l[1])
          || (~pci_ext_gnt_l[3] & ~pci_ext_gnt_l[0])
          || (~pci_ext_gnt_l[3] & ~pci_real_gnt_l)
          || (~pci_ext_gnt_l[2] & ~pci_ext_gnt_l[1])
          || (~pci_ext_gnt_l[2] & ~pci_ext_gnt_l[0])
          || (~pci_ext_gnt_l[2] & ~pci_real_gnt_l)
          || (~pci_ext_gnt_l[1] & ~pci_ext_gnt_l[0])
          || (~pci_ext_gnt_l[1] & ~pci_real_gnt_l)
          || (~pci_ext_gnt_l[0] & ~pci_real_gnt_l) )
      begin
        $display ("*** monitor - More than 1 PCI GNT_L asserted 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        $fdisplay (log_file_desc, "*** monitor - More than 1 PCI GNT_L asserted 'h%x, at %t",
                    {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if  (  (pci_ext_reset_l == 1'b1)
          && (~frame_prev & ~irdy_prev)  // bus idle
          && (grant_prev != 5'h1F) && ({pci_ext_gnt_l[3:0], pci_real_gnt_l} != 5'h1F)
          && ({pci_ext_gnt_l[3:0], pci_real_gnt_l} != grant_prev))
      begin
        $display ("*** monitor - Changed from one Grant to another when bus idle 'h%x to 'h%x, at %t",
                    grant_prev, {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        $fdisplay (log_file_desc, "*** monitor - Changed from one Grant to another when bus idle 'h%x to 'h%x, at %t",
                    grant_prev, {pci_ext_gnt_l[3:0], pci_real_gnt_l}, $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
    end
    `NO_ELSE;
  end

// Classify bus activity and notice slow or dead devices.
// See the PCI Local Bus Spec Revision 2.2 section 3.5
  reg     master_activity_seen, target_activity_seen, target_subsequently_seen;
  reg    [2:0] master_initial_latency_counter;
  reg    [3:0] target_initial_latency_counter;
  reg    [2:0] target_subsequent_latency_counter;
  reg    [3:0] master_abort_timer;
  reg     master_abort;

  always @(posedge pci_ext_clk or negedge pci_ext_reset_l)
  begin
    if (pci_ext_reset_l == 1'b0)
    begin
      master_activity_seen <= 1'b0;
      master_initial_latency_counter <= 3'h0;
      target_activity_seen <= 1'b0;
      target_initial_latency_counter <= 4'h0;
      target_subsequently_seen <= 1'b0;
      target_subsequent_latency_counter <= 3'h0;
      master_abort_timer <= 4'h0;
      master_abort <= 1'b0;
    end
    else
    begin
      if ((address_phase_prev) | (~frame_prev & ~irdy_prev))  // address or idle
      begin
        master_abort_timer <= 4'h0;
        master_abort <= 1'b0;
        master_activity_seen <= 1'b0;
        master_initial_latency_counter <= 3'h0;
        target_activity_seen <= 1'b0;
        target_initial_latency_counter <= 4'h0;
        target_subsequently_seen <= 1'b0;
        target_subsequent_latency_counter <= 3'h0;
      end
      else
      begin
// NOTE WORKING not debugged yet.
        master_initial_latency_counter <= master_initial_latency_counter + 3'h1;
        master_activity_seen <= master_activity_seen | irdy_now;
        if ((master_initial_latency_counter == 3'h7) & ~master_activity_seen)
        begin
          $display ("*** monitor - Master didn't assert IRDY within 8 clocks of FRAME, at %t",
                    $time);
          $fdisplay (log_file_desc, "*** monitor - Master didn't assert IRDY within 8 clocks of FRAME, at %t",
                    $time);
          error_detected <= ~error_detected;
          master_activity_seen <= 1'b1;
        end
        `NO_ELSE;

        target_initial_latency_counter <= target_initial_latency_counter
                              + (devsel_now ? 4'h1 : 4'h0);
        target_activity_seen <= target_activity_seen | trdy_now;
        if ((target_initial_latency_counter == 4'hF) & ~target_activity_seen)
        begin
          $display ("*** monitor - Target didn't assert TRDY within 16 clocks of DEVSEL, at %t",
                    $time);
          $fdisplay (log_file_desc, "*** monitor - Target didn't assert TRDY within 16 clocks of DEVSEL, at %t",
                    $time);
          error_detected <= ~error_detected;
          target_activity_seen <= 1'b1;
        end
        `NO_ELSE;

// NOTE This only detects Target misbehavior on the FIRST subsequent transfer!!!
        target_subsequent_latency_counter <= target_subsequent_latency_counter
                              + (target_activity_seen ? 3'h1 : 3'h0);
        target_subsequently_seen <= target_subsequently_seen
                                  | (target_activity_seen & trdy_now);
        if ((target_subsequent_latency_counter == 3'h7) & ~target_subsequently_seen)
        begin
          $display ("*** monitor - Target didn't assert TRDY within 8 clocks of first TRDY, at %t",
                    $time);
          $fdisplay (log_file_desc, "*** monitor - Target didn't assert TRDY within 8 clocks of first TRDY, at %t",
                    $time);
          error_detected <= ~error_detected;
          target_subsequently_seen <= 1'b1;
        end
        `NO_ELSE;

        master_abort_timer <= master_abort_timer + 4'h1;
        master_abort <= (master_abort_timer >= 4'h2) ? 1'b1 : master_abort;
      end
    end
  end

// Track the parity bit status on the bus.  The rules are:
// 1) parity has to be correct whenever FRAME is asserted to be a valid address
// 2) parity has to be correct whenever IRDY is asserted on writes
// 3) parity has to be correct whenever TRDY is asserted on reads
// parity covers the ad bus, and the cbe wires.  The PCI bus is even parity.
// The number of bits set to 1 in AD plus CBE plus PAR is an EVEN number.
// This code will notice an error, but will only complain if the PERR and SERR
// bits don't match,
  reg     prev_calculated_ad_cbe_parity;
  reg     prev_prev_calculated_ad_cbe_parity, read_operation_prev_prev;
  reg     prev_prev_devsel, prev_prev_trdy, prev_prev_irdy, prev_pci_ext_par;
  reg     ad_prev_address_phase;
  reg    [PCI_BUS_DATA_RANGE:0] ad_prev_prev;
  reg    [PCI_BUS_CBE_RANGE:0] cbe_l_prev_prev;
  always @(posedge pci_ext_clk)
  begin
// calculate 1 if an odd number of bits is set, 0 if an even number is set
    prev_calculated_ad_cbe_parity <= (^pci_ext_ad[PCI_BUS_DATA_RANGE:0])
                                   ^ (^pci_ext_cbe_l[PCI_BUS_CBE_RANGE:0]);
    prev_prev_calculated_ad_cbe_parity <= prev_calculated_ad_cbe_parity;
    read_operation_prev_prev <= read_operation_prev;
    ad_prev_address_phase <= address_phase_prev;
    prev_prev_devsel <= devsel_prev;
    prev_prev_trdy <= trdy_prev;
    prev_prev_irdy <= irdy_prev;
    prev_pci_ext_par <= pci_ext_par;
    ad_prev_prev[PCI_BUS_DATA_RANGE:0] <= ad_prev[PCI_BUS_DATA_RANGE:0];
    cbe_l_prev_prev[PCI_BUS_CBE_RANGE:0] <= cbe_l_prev[PCI_BUS_CBE_RANGE:0];
    if (($time > 0) && (pci_ext_reset_l !== 1'b0))
    begin
      if (ad_prev_address_phase)
      begin
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity !== prev_pci_ext_par) & pci_ext_serr_l))
        begin
          $display ("*** monitor - Undetected Address Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Undetected Address Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity === prev_pci_ext_par) & ~pci_ext_serr_l))
        begin
          $display ("*** monitor - Invalid Address Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Invalid Address Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
      end
      `NO_ELSE;
      if (read_operation_prev_prev & prev_prev_trdy)
      begin
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity !== prev_pci_ext_par) & pci_ext_perr_l))
        begin
          $display ("*** monitor - Undetected Read Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Undetected Read Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity === prev_pci_ext_par) & ~pci_ext_perr_l))
        begin
          $display ("*** monitor - Invalid Read Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Invalid Read Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
      end
      `NO_ELSE;
      if (~read_operation_prev_prev & prev_prev_irdy & prev_prev_devsel)
      begin
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity !== prev_pci_ext_par) & pci_ext_perr_l))
        begin
          $display ("*** monitor - Undetected Write Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Undetected Write Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
        if (((prev_prev_calculated_ad_cbe_parity ^ prev_prev_calculated_ad_cbe_parity) === 1'bX)
             | ((prev_pci_ext_par ^ prev_pci_ext_par) === 1'bX)
             | ((prev_prev_calculated_ad_cbe_parity === prev_pci_ext_par) & ~pci_ext_perr_l))
        begin
          $display ("*** monitor - Invalid Write Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          $fdisplay (log_file_desc, "*** monitor - Invalid Write Data Parity Error, Address 'h%x, CBE 'h%x, PAR: 'h%x, at %t",
                      ad_prev_prev, cbe_l_prev_prev, prev_pci_ext_par, $time);
          error_detected <= ~error_detected;
        end
        `NO_ELSE;
      end
      `NO_ELSE;
    end
  end

// Verify some of the state transitions observed on the bus.
// See the PCI Local Bus Spec Revision 2.2 Appendix C.
// In general, transition tests should look at one present signal, and
//   a bunch of previous signals.
// In general, simultaneous transition tests should look at two present
//   signals, and a bunch of previous signals.
  always @(posedge pci_ext_clk)
  begin
    if (($time > 0) && (pci_ext_reset_l !== 1'b0))
    begin
      if (irdy_prev & ~read_operation_prev & ~(trdy_prev | stop_prev) & (pci_ext_ad != ad_prev))
      begin  // Appendix C line 2C
        $display ("*** monitor - AD Bus Changed when Writing with IRDY Asserted and TRDY Deasserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - AD Bus Changed when Writing with IRDY Asserted and TRDY Deasserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (trdy_prev & read_operation_prev & ~irdy_prev & (pci_ext_ad != ad_prev))
      begin  // Appendix C line 2C
        $display ("*** monitor - AD Bus Changed when Reading with TRDY Asserted and IRDY Deasserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - AD Bus Changed when Reading with TRDY Asserted and IRDY Deasserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (frame_prev & (frame_now | irdy_now) & ~address_phase_prev & ~trdy_now
                                                 & (pci_ext_cbe_l != cbe_l_prev))
      begin  // Appendix C line 3B
        $display ("*** monitor - CBE Bus Changed when TRDY Desserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - CBE Bus Changed when TRDY Desserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (~frame_prev & frame_now & irdy_now)
      begin  // Section 3.3.3.1 rule 2, Appendix C line 7B
        $display ("*** monitor - FRAME Asserted while IRDY still Asserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - FRAME Asserted while IRDY still Asserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (~irdy_prev & irdy_now & ~frame_prev)
      begin  // Appendix C line ?  not in there!
        $display ("*** monitor - IRDY Asserted when FRAME Deasserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - IRDY Asserted when FRAME Deasserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (frame_prev & ~frame_now & ~irdy_now)
      begin  // Section 3.3.3.1 rule 3, Appendix C line 7C
        $display ("*** monitor - FRAME Desserted without IRDY being Asserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - FRAME Desserted without IRDY being Asserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (irdy_prev & ~(trdy_prev | stop_prev | master_abort)
                                             & (frame_now != frame_prev))
      begin  // Section 3.3.3.1 rule 4, Appendix C line 7D
        $display ("*** monitor - FRAME changed while IRDY Asserted when not end of reference, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - FRAME changed while IRDY Asserted when not end of reference, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (irdy_prev & ~(trdy_prev | stop_prev | master_abort) & ~irdy_now)
      begin  // Section 3.3.3.1 rule 5, Appendix C line 7E
        $display ("*** monitor - IRDY Deasserted after being Asserted when not end of reference, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - IRDY Deasserted after being Asserted when not end of reference, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
// NOTE WORKING section 3.3.3.2.2, Appendix C line 10, REQ must be removed for
// NOTE WORKING IDLE and one clock on either side of IDLE upon retry or disconnect
      if (stop_prev & frame_prev & frame_now & ~stop_now)
      begin  // Section 3.3.3.2.1 rule 3, Appendix C line 12C
        $display ("*** monitor - STOP Deasserted while FRAME Asserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - STOP Deasserted while FRAME Asserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (stop_prev & ~frame_prev & frame_now & stop_now)
      begin  // Section 3.3.3.2.1 rule 3, Appendix C line 12C, author addition
        $display ("*** monitor - STOP didn't Deassert while FRAME Deasserted in fast back-to-back, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - STOP didn't Deassert while FRAME Deasserted in fast back-to-back, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if ((trdy_prev | stop_prev) & ~irdy_prev & (devsel_prev != devsel_now))
      begin  // Section 3.3.3.2.1 rule 4, Appendix C line 12D
        $display ("*** monitor - DEVSEL changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - DEVSEL changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if ((trdy_prev | stop_prev) & ~irdy_prev & (trdy_prev != trdy_now))
      begin  // Section 3.3.3.2.1 rule 4, Appendix C line 12D
        $display ("*** monitor - TRDY changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - TRDY changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if ((trdy_prev | stop_prev) & ~irdy_prev & (stop_prev != stop_now))
      begin  // Section 3.3.3.2.1 rule 4, Appendix C line 12D
        $display ("*** monitor - STOP changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - STOP changed while TRDY or STOP Asserted when not end of data phase, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (~trdy_prev & trdy_now & ~devsel_now)
      begin  // Appendix C line 14
        $display ("*** monitor - TRDY Asserted when DEVSEL Deasserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - TRDY Asserted when DEVSEL Deasserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (~stop_prev & stop_now & ~(devsel_prev | devsel_now))
      begin  // Appendix C line 14
        $display ("*** monitor - STOP Asserted when DEVSEL Deasserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - STOP Asserted when DEVSEL Deasserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (~frame_prev & frame_now & (grant_prev == 5'h1F))
      begin  // Appendix C line 21
        $display ("*** monitor - FRAME Asserted when no GNT Asserted, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - FRAME Asserted when no GNT Asserted, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
      if (devsel_prev & ~devsel_now & frame_prev & ~(stop_now & ~trdy_now))
      begin  // Appendix C line 30
        $display ("*** monitor - DEVSEL Deasserted when FRAME Asserted, and no Target Abort, at %t",
                    $time);
        $fdisplay (log_file_desc, "*** monitor - DEVSEL Deasserted when FRAME Asserted, and no Target Abort, at %t",
                    $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
    end
    `NO_ELSE;
  end

// Verify some of the state transitions observed on the bus. See the
// PCI Local Bus Spec Revision 2.2 section 3.2.1, plus Appendix C.
`ifdef VERBOSE_MONITOR_DEVICE
  reg     prev_pci_ext_reset_l;
  always @(pci_ext_reset_l)
  begin
    prev_pci_ext_reset_l <= pci_ext_reset_l;

    if (($time > 0) && (pci_ext_reset_l !== prev_pci_ext_reset_l))
    begin
      if (pci_ext_reset_l == 1'b0)
      begin
        $display (" monitor - PCI External RESET_L asserted LOW at %t", $time);
      end
      `NO_ELSE;

      if (pci_ext_reset_l == 1'b1)
      begin
        $display (" monitor - PCI External RESET_L deasserted HIGH at %t", $time);
      end
      `NO_ELSE;
    end
  end

  always @(posedge pci_ext_clk)
  begin
    if (($time > 0) && (pci_ext_reset_l !== 1'b0))
    begin
// report a Master Abort, which is not an error
      if ((irdy_prev & ~irdy_now) & (~trdy_prev & ~stop_prev & master_abort))
      begin
        $display (" monitor - IRDY Deasserted due to Master Abort, at %t", $time);
      end
      `NO_ELSE;

      if (~frame_prev & frame_now & irdy_prev & ~irdy_now)
      begin
        $display (" Fast Back-to-Back reference with no Idle cycle started at %t",
                  $time);
      end
      `NO_ELSE;
    end
    `NO_ELSE;
  end
`endif // VERBOSE_MONITOR_DEVICE

`ifdef VERBOSE_MONITOR_DEVICE
  always @(posedge pci_ext_clk)
  begin
    if (($time > 0) && (pci_ext_reset_l !== 1'b0) && address_phase_prev)
    begin
// command list taken from PCI Local Bus Spec Revision 2.2 section 3.1.1.
      case (cbe_l_prev[PCI_BUS_CBE_RANGE:0])
      PCI_COMMAND_INTERRUPT_ACKNOWLEDGE:
        $display (" monitor - Interrupt Acknowledge started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);,
      PCI_COMMAND_SPECIAL_CYCLE:
        $display (" monitor - Special Cycle started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_IO_READ:
        $display (" monitor - IO Read started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_IO_WRITE:
        $display (" monitor - IO Write started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_RESERVED_READ_4:
        $display (" monitor - Reserved started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_RESERVED_WRITE_5:
        $display (" monitor - Reserved started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_MEMORY_READ:
        $display (" monitor - Memory Read started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_MEMORY_WRITE:
        $display (" monitor - Memory Write started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_RESERVED_READ_8:
        $display (" monitor - Reserved started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_RESERVED_WRITE_9:
        $display (" monitor - Reserved started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_CONFIG_READ:
        $display (" monitor - Configuration Read started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_CONFIG_WRITE:
        $display (" monitor - Configuration Write started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_MEMORY_READ_MULTIPLE:
        $display (" monitor - Memory Read Multiple started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_DUAL_ADDRESS_CYCLE:
        $display (" monitor - Dual Address Cycle started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_MEMORY_READ_LINE:
        $display (" monitor - Memory Read Line started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      PCI_COMMAND_MEMORY_WRITE_INVALIDATE:
        $display (" monitor - Memory Write and Invalidate started, AD: 'h%x, CBE: 'h%x, at time %t",
                    ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
      default:
        begin
          $display ("*** monitor - Unknown operation started, AD: 'h%x, CBE: 'h%x, at time %t",
                      ad_prev[PCI_BUS_DATA_RANGE:0], cbe_l_prev[PCI_BUS_CBE_RANGE:0], $time);
          error_detected <= ~error_detected;
        end
      endcase
    end
    `NO_ELSE;
  end
`endif // VERBOSE_MONITOR_DEVICE

initial get_pci_op.timeout_val = 32'hffff ;

reg     [4:0] cur_transaction_owner ;

initial cur_transaction_owner = 5'h1F ;

task get_pci_op ;
    output [31:0] address_o     ;
    output [3:0 ] bus_command_o ;
    reg    [31:0] timeout_val   ;
    reg           in_use        ;
begin:main
    if (in_use === 1'b1)
    begin
        $display("%m re-entered!") ;
        $fdisplay(log_file_desc, "%m re-entered!") ;
        error_detected <= ~error_detected;
        disable main ;
    end

    in_use = 1'b1 ;

    fork
    begin:get_op_blk
        wait(pci_ext_reset_l === 1'b1) ;
        
        @(posedge pci_ext_clk) ;
    
        while ((frame_now !== 1'b1) | (frame_prev !== 1'b0) )
            @(posedge pci_ext_clk) ;

        disable timeout_blk ;

        address_o     = pci_ext_ad    ;
        bus_command_o = pci_ext_cbe_l ;
        cur_transaction_owner = grant_now ;

    end
    begin:timeout_blk
        #(timeout_val) ;
        disable get_op_blk ;
        address_o     = 32'hxxxx_xxxx ;
        bus_command_o = 4'hx ;
    end
    join

    in_use = 1'b0 ;

end
endtask // get_pci_op

task get_pci_op_num_of_transfers ;
    output [31:0] num_of_transfers_o             ;
    output        gnt_deasserted_o ;
    reg    [7:0]  num_of_cycles_without_transfer ;
    reg           in_use        ;
begin:main

    if (in_use === 1'b1)
    begin
        $display("%m re-entered!") ;
        $fdisplay(log_file_desc, "%m re-entered!") ;
        error_detected <= ~error_detected;
        disable main ;
    end

    in_use = 1'b1 ;

    num_of_transfers_o             = 0 ;
    num_of_cycles_without_transfer = 0 ;

    @(posedge pci_ext_clk) ;
    while( (frame_now === 1'b1) & (num_of_cycles_without_transfer < 128) )
    begin
        if ( (irdy_now === 1'b1) & (trdy_now === 1'b1) & (devsel_now === 1'b1))
        begin
            num_of_transfers_o = num_of_transfers_o + 1'b1 ;
            num_of_cycles_without_transfer = 0 ;
        end
        else
        begin
            num_of_cycles_without_transfer = num_of_cycles_without_transfer + 1'b1 ;
        end

        @(posedge pci_ext_clk) ;

    end

    if (num_of_cycles_without_transfer === 128)
    begin
        $display("%m, no transfers in 128 pci clock cycles! Terminating!") ;
        $fdisplay(log_file_desc, "%m, no transfers in 128 pci clock cycles! Terminating!") ;
        error_detected <= ~error_detected ;
        num_of_transfers_o = 32'hxxxx_xxxx ;
        gnt_deasserted_o = 1'bx ;
    end
    else
    begin
        gnt_deasserted_o = ( cur_transaction_owner != grant_now ) ;

        while ( (irdy_now === 1'b1) & (trdy_now === 1'b0) & (stop_now === 1'b0) )
            @(posedge pci_ext_clk) ;

        if ( (irdy_now === 1'b1) & (trdy_now === 1'b1) & (devsel_now === 1'b1))
            num_of_transfers_o = num_of_transfers_o + 1'b1 ;
    end        

    in_use = 1'b0 ;
end
endtask // get_pci_op_num_of_transfers

task get_pci_op_num_of_cycles ;
    output [31:0] frame_asserted_cycles_o ;
    reg    [31:0] num_of_cycles_after_last_data_phase_termination ;
    reg           in_use        ;
begin:main
    if (in_use === 1'b1)
    begin
        $display("%m re-entered!") ;
        $fdisplay(log_file_desc, "%m re-entered!") ;
        error_detected <= ~error_detected;
        disable main ;
    end

    in_use = 1'b1 ;

    frame_asserted_cycles_o                         = 1 ;
    num_of_cycles_after_last_data_phase_termination = 1 ;

    @(posedge pci_ext_clk) ;
    while( (frame_now === 1'b1) & (num_of_cycles_after_last_data_phase_termination < 128) )
    begin

        if (irdy_prev & trdy_prev & devsel_prev )
        begin

            frame_asserted_cycles_o = frame_asserted_cycles_o + num_of_cycles_after_last_data_phase_termination ;

            num_of_cycles_after_last_data_phase_termination = 1 ;
        end
        else
            num_of_cycles_after_last_data_phase_termination = num_of_cycles_after_last_data_phase_termination + 1'b1 ;

        @(posedge pci_ext_clk) ;

    end

    if ( num_of_cycles_after_last_data_phase_termination === 128)
    begin
        $display("%m, no transfers in 128 pci clock cycles! Terminating!") ;
        $fdisplay(log_file_desc, "%m, no transfers in 128 pci clock cycles! Terminating!") ;
        error_detected <= ~error_detected ;
        frame_asserted_cycles_o = 32'hxxxx_xxxx ;
    end

    in_use = 1'b0 ;
end
endtask // get_pci_op_num_of_cycles

task get_pci_master_abort ;
    output [31:0 ] ret_adr_o ;
    output [ 3:0 ] ret_bc_o  ;
    output         ret_mabort_detected_o ;
begin:main
    ret_mabort_detected_o = 1'b0 ;
    get_pci_op(ret_adr_o, ret_bc_o) ;

    if ( (ret_adr_o ^ ret_adr_o) !== 0 )
        disable main ;

    if ( (ret_bc_o ^ ret_bc_o) !== 0 )
        disable main ;

    while (frame_now !== 1'b0)
    begin
        if (devsel_now !== 1'b0)
        begin
            // exit immediately on target response detection
            ret_mabort_detected_o = 1'b0 ;
            disable main ;
        end

        @(posedge pci_ext_clk) ;
    end

    while(irdy_now !== 1'b0)
    begin

        if (devsel_now !== 1'b0)
        begin
            // exit immediately on target response detection
            ret_mabort_detected_o = 1'b0 ;
            disable main ;
        end

        @(posedge pci_ext_clk) ;
    end

    ret_mabort_detected_o = 1'b1 ;
end
endtask // get_pci_master_abort
endmodule