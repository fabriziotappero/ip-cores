//===========================================================================
// $Id: pci_blue_arbiter.v,v 1.2 2002-03-21 07:35:50 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  A synthesizable PCI Arbiter.  This will have 4 external PCI
//           Request/Grant pairs and one internal Request/Grant Pair.
//           A Compile-time option selects whether to include an un-latched
//           IRDY_L signal ithe arbitration.  This might make the bus use
//           slightly more efficient.  But there would be more load in
//           IRDY_L, a very timing critical signal.  Not sure which is best.
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
// NOTE:  This PCI Arbiter is an implementation of the arbiter ideas
//        described in the PCI Local Bus Specification Revision 2.2,
//        section 3.4.
//
// NOTE:  This arbiter serves 4 external Request/Grant pairs and one
//        internal Request/Grant pair.  It would be attractive to
//        try to implement the 2-level arbitration given in the
//        implementation note.
//
// NOTE:  Upon Reset, this Arbiter parks the bus on the Internal Grant.
//
// NOTE:  The 4 arbitration rules given in the PCI Local Bus Specification
//        Revision 2.2, section 3.4.1, are:
//        0) Be fair.  Do not starve anyone.  However, priorities are OK.
//        1) If GNT_L is Deasserted and FRAME_L is asserted on the same
//           clock, a valid reference is started
//        2) One GNT_L can be deasserted the same clock which another
//           GNT_L is asserted if NOT in Idle state.  If in Idle state,
//           one clock with no GNT at all must be inserted to avoid
//           contention on the AD and PAR lines.
//        3) When FRAME_L is deasserted, GNT_L may be deasserted at
//           any time.
//
// NOTE:  The arbiter can assume a device is "broken" if it receives REQ,
//        assertes GNT, and no FRAME is asserted, for 16 clocks.  It is legal
//        to ignore that device's REQ signal after that, and report the
//        problem to the host.  This device just moves on to the next REQ.
//
// NOTE:  When the Arbiter is on-chip, the FRAME signal must NOT be the
//        external FRAME signal when the internam PCI device is driving
//        the bus.  In the case that the internal device is driving the
//        bus, the INTERNAL FRAME signal must be used.  This is due to
//        time-of-flight concerns on the external PCI bus.  See the PCI
//        Local Bus Specification Revision 2.2, section 3.10 item 9.
//
// NOTE:  It is not clear when a change in bus ownership should occur.
//        This arbiter grants a device the bus, and then waits until
//        the device has started a reference before granting to a new
//        device.  If no other requests are pending, the grant stays put.
//
//===========================================================================

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

// Allows printing of Arbiter Debug info.  Usually not defined
//`define PCI_TRACE_ARB 1

module pci_blue_arbiter (
  pci_int_req_direct, pci_ext_req_prev,
  pci_int_gnt_direct_out, pci_ext_gnt_direct_out,
  pci_frame_prev, pci_irdy_prev, pci_irdy_now,
  arbitration_enable,
  pci_clk, pci_reset_comb
);

`include "pci_blue_options.vh"
`include "pci_blue_constants.vh"

  input   pci_int_req_direct;  // direct from internal flop clocked with pci_clk
  input  [3:0] pci_ext_req_prev;
  output  pci_int_gnt_direct_out;
  output [3:0] pci_ext_gnt_direct_out;
  input   pci_frame_prev, pci_irdy_prev, pci_irdy_now;
  input   arbitration_enable;
  input   pci_clk, pci_reset_comb;

// detect the deassertion of reset, hopefully without metastability
  reg     prev_unreset, prev_prev_unreset;
  reg     arbiter_init;
  always @(posedge pci_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      prev_unreset <= 1'b0;
      prev_prev_unreset <= 1'b0;
      arbiter_init <= 1'b0;
    end
    else
    begin
      prev_unreset <= 1'b1;
      prev_prev_unreset <= prev_unreset;
// init arbiter when reset goes away, or when user disables arbiter
      arbiter_init <= ~prev_prev_unreset | ~arbitration_enable;
    end
  end

// watch for bus activity.
  reg     prev_prev_frame;
  always @(posedge pci_clk)
  begin
    prev_prev_frame <= pci_frame_prev;
  end

// approximate, but always conservative
//  wire    pci_bus_not_idle = pci_frame_prev;
// expensive because irdy is critical
`define INCLUDE_FAST_IRDY_INPUT
`ifdef INCLUDE_FAST_IRDY_INPUT
  wire    pci_bus_not_idle = pci_frame_prev | pci_irdy_now;
`else // INCLUDE_FAST_IRDY_INPUT
  wire    pci_bus_not_idle = pci_frame_prev;
`endif // INCLUDE_FAST_IRDY_INPUT
  wire    pci_bus_went_idle = ~pci_frame_prev & ~pci_irdy_prev;
  wire    pci_address_phase =  pci_frame_prev & ~prev_prev_frame;

// upon assertion of reset, remove all bus grants.
//   note that the PCI Local Bus Specification Revision 2.2,
//   section 2.2.4, says the devices must ignore GNT_L when
//   reset is asserted, no matter what it's value is.
// upon reset, all requests are pulled HIGH by motherboard pullups,
//   because upon reset, all PCI devices are supposed to HIGH-Z
//   their request lines.  See the PCI Local Bus Specification
//   Revision 2.2, section 2.2.4.  The internal device cannot
//   be tristated,  Instead, it de-requests.
// upon deassertion of reset, park the bus on the internal device.
//   note that the bus parking will not happen if the PCI Clock is
//   not running.
// after initialization, the bus is parked at the last bus user.

// round_robin arbitration.  No priorities or anything.
// Note this can change constantly as new requests come in
  reg [4:0] prev_master;  // remembered from last good arbitration
  wire [4:0] present_requestors = {pci_ext_req_prev[3:0], pci_int_req_direct};
  wire [4:0] no_master = 5'h00;
  wire [4:0] internal_master = 5'h01;

  wire     New_Master_Wants_Bus =
                   (present_requestors != 5'h00)
                && (present_requestors != prev_master);
  wire     New_Master_Stopped_Requesting =
                  ((present_requestors & prev_master) == 5'h00);

  wire [4:0] next_master =
            ((prev_master == 5'h00) || (prev_master == 5'h01))
             ? (    (present_requestors[1]) ? 5'h02
                 : ((present_requestors[2]) ? 5'h04
                 : ((present_requestors[3]) ? 5'h08
                 : ((present_requestors[4]) ? 5'h10
                 : 5'h01))))
             : ((prev_master == 5'h02)
                 ? (    (present_requestors[2]) ? 5'h04
                     : ((present_requestors[3]) ? 5'h08
                     : ((present_requestors[4]) ? 5'h10
                     : ((present_requestors[0]) ? 5'h01
                     : 5'h02))))
                 : ((prev_master == 5'h04)
                     ? (    (present_requestors[3]) ? 5'h08
                         : ((present_requestors[4]) ? 5'h10
                         : ((present_requestors[0]) ? 5'h01
                         : ((present_requestors[1]) ? 5'h02
                         : 5'h04))))
                     : ((prev_master == 5'h08)
                         ? (    (present_requestors[4]) ? 5'h10
                             : ((present_requestors[0]) ? 5'h01
                             : ((present_requestors[1]) ? 5'h02
                             : ((present_requestors[2]) ? 5'h04
                             : 5'h08))))
                         :  // ((prev_master == 5'h10) || (more than 1 bit set)) ?
                               (    (present_requestors[0]) ? 5'h01
                                 : ((present_requestors[1]) ? 5'h02
                                 : ((present_requestors[2]) ? 5'h04
                                 : ((present_requestors[3]) ? 5'h08
                                 : 5'h10))))
               )   )   );

// state machine moves to next state when a new request is available and
// the previous grent has resulted in a memory reference, or when the
// bus has been idle too long.
//
// When the PCI Bus is not Idle, it is fine to deassert one grant and
// assert another the next clock.  If the bus is NOT Idle, there must be
// a one clock delay between the deassertion of one GNT and the next GNT.
// Refer to the PCI Local Bus Specification Revision 2.2, section 3.4.1.
//
// In order to remove any dependence on the IRDY and TRDY signals directly
// received from the PCI Bus, this arbiter uses the latched versions.
// The PCI Bus is Idle whenever BOTH FRAME and IRDY are deasserted.  This
// arbiter uses an approximation of that.  It uses the Latched FRAME
// signal alone.  This is not too bad, because each reference ends with
// FRAME going deasserted and IRDY going asserted for at least one clock.
// Latched FRAME is valid for 1 clock after Frame goes away, which is
// automatically also a non-idle clock.  Latched FRAME is a conservative
// estimate of whether the bus is idle or not.  When Latched FRAME is
// not asserted, the Arbiter will deassert all GNT signals for one clock
// before asserting a new GNT.
//
// The event sequence is as follows:
// 1) at time minus infinity, some device gets bus mastership
// 2) at time before 0, the arbiter decides the first device is done
// 3) at time -1, a new device requests
// 4) at time 0, the old device is ungranted, and the new device is granted
// 5) at time 0, the old device might start a new reference or continue an old one
// 6) at time 1, the new device gets a chance to see the grant
// 7) at time 1, the new device can drive the bus ONLY if it is idle
// 8) at time 2, the arbiter sees whether the bus was idle at time 1
//    from time 2 on, it watches to see when the bus finally goes idle
// 9) whenever the arbiter sees the bus going idle, it starts counting
//    a counter to 16.  It also watches for a transition on frame indicating
//    that an address phase has happened.
// 10) when the timer expires or the address phase happens, the arbiter
//    rearbitrates to give the next requestor a chance. 

  parameter PCI_ARBITER_HAPPILY_WAITING  = 5'b00001;
  parameter PCI_ARBITER_REMOVE_GNT       = 5'b00010;
  parameter PCI_ARBITER_DELAY_ONE        = 5'b00100;
  parameter PCI_ARBITER_WAIT_FOR_IDLE    = 5'b01000;
  parameter PCI_ARBITER_WAIT_FOR_ADDRESS = 5'b10000;
  reg [4:0] PCI_Arbiter_State;

  reg [4:0] new_master;
  reg [3:0] gnt_timeout;
  always @(posedge pci_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
      prev_master <= no_master;
      new_master  <= no_master;
      gnt_timeout <= 4'h0;
    end
    else
    begin
      if (arbiter_init)
      begin
        PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
        prev_master <= internal_master;
        new_master  <= internal_master;
        gnt_timeout <= 4'h0;
      end
      else
      begin
        case (PCI_Arbiter_State)
        PCI_ARBITER_HAPPILY_WAITING:
          begin
            gnt_timeout <= 4'h0;  // all cases
            if (New_Master_Wants_Bus)
            begin
              if (pci_bus_not_idle)
              begin  // directly grant new bus owner
                PCI_Arbiter_State <= PCI_ARBITER_DELAY_ONE;
                prev_master <= next_master;
                new_master  <= next_master;
              end
              else
              begin  // case that bus is idle.  make no grant for 1 clock
                PCI_Arbiter_State <= PCI_ARBITER_REMOVE_GNT;
                prev_master <= prev_master;
                new_master  <= no_master;
              end
            end
            else
            begin  // no requestor or same requestor.  Park on previous winner
              PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
              prev_master <= prev_master;
              new_master  <= prev_master;
            end
          end
        PCI_ARBITER_REMOVE_GNT:
          begin
            if (New_Master_Wants_Bus)
            begin  // directly grant new bus owner
              PCI_Arbiter_State <= PCI_ARBITER_DELAY_ONE;
              prev_master <= next_master;
              new_master  <= next_master;
            end
            else
            begin  // requestor gave up.  Park on previous winner
              PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
              prev_master <= prev_master;
              new_master  <= prev_master;
            end
          end
        PCI_ARBITER_DELAY_ONE:
          begin  // wait for pipelined copy of FRAME, IRDY to become valid
            prev_master <= prev_master;  // all cases
            new_master  <= prev_master;  // all cases
            gnt_timeout <= 4'h0;         // all cases
            if (New_Master_Stopped_Requesting)
            begin  // requestor removed request!  Never happens.  Rearb immediately.
              PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
            end
            else
            begin  // start looking for bus idle, when new master takes over
              PCI_Arbiter_State <= PCI_ARBITER_WAIT_FOR_IDLE;
            end
          end
        PCI_ARBITER_WAIT_FOR_IDLE:
          begin  // A new master is granted, but can't start until the PCI bus is idle
            prev_master <= prev_master;  // all cases
            new_master  <= prev_master;  // all cases
            gnt_timeout <= 4'h0;         // all cases
            if (New_Master_Stopped_Requesting)
            begin  // requestor removed request!  Never happens.  Rearb immediately.
              PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
            end
            else
            begin
              if (pci_bus_went_idle)
              begin  // now the new master can take control by driving an address
                PCI_Arbiter_State <= PCI_ARBITER_WAIT_FOR_ADDRESS;
              end
              else
              begin  // wait for old master to release bus
                PCI_Arbiter_State <= PCI_ARBITER_WAIT_FOR_IDLE;
              end
            end
          end
        PCI_ARBITER_WAIT_FOR_ADDRESS:
          begin
            gnt_timeout <= gnt_timeout + 4'h1;  // all cases
            if (New_Master_Stopped_Requesting)
            begin  // requestor removed request!  Never happens.  Rearb immediately.
              PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
              prev_master <= prev_master;
              new_master  <= prev_master;
            end
            else
            begin
              if (pci_address_phase || (gnt_timeout == 4'hF))
              begin
`ifdef INCLUDE_FAST_IRDY_ON_IDLE_TERM
// This term makes some improvement in arbitration timing, but not sure how
// much.  With the term, certain wait states at the end of single-word or burst
// transfers are eliminated.  The arbitration time in the case of a genuinely
// idle bus isn't changed however.  Presently not using this.
                if (New_Master_Wants_Bus)
                begin   // safe to rearbitrate.  Is anyone waiting?
                  if (pci_bus_not_idle)  // bus is busy, switch instantly
                  begin
                    PCI_Arbiter_State <= PCI_ARBITER_DELAY_ONE;
                    prev_master <= next_master;
                    new_master  <= next_master;
                  end
                  else  // bus is idle, force an idle period
                  begin
                    PCI_Arbiter_State <= PCI_ARBITER_REMOVE_GNT;
                    prev_master <= prev_master;
                    new_master  <= no_master;
                  end
                end
                else
`endif // INCLUDE_FAST_IRDY_ON_IDLE_TERM
                begin  // no requestor or same requestor.  Park on previous winner
                  PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
                  prev_master <= prev_master;
                  new_master  <= prev_master;
                end
              end
              else
              begin  // no addres phase or timeout yet.  Just keep looking
                PCI_Arbiter_State <= PCI_ARBITER_WAIT_FOR_ADDRESS;
                prev_master <= prev_master;
                new_master  <= prev_master;
              end
            end
          end
        default:
          begin
            PCI_Arbiter_State <= PCI_ARBITER_HAPPILY_WAITING;
            prev_master <= internal_master;
            new_master  <= internal_master;
            gnt_timeout <= 4'h0;
          end
        endcase
      end
    end
  end

  assign pci_int_gnt_direct_out = new_master[0];
  assign pci_ext_gnt_direct_out = new_master[4:1];

// synopsys translate_off
`ifdef PCI_TRACE_ARB
  always @(posedge pci_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      $display ("async reset");
    end
    else
    begin
      if (arbiter_init)
      begin
        $display ("sync reset");
      end
      else
      begin
        case (PCI_Arbiter_State)
        PCI_ARBITER_HAPPILY_WAITING:
          begin
            if (New_Master_Wants_Bus)
            begin  // new requestor.  Either ungrant for 1 clock if idle or go directly
              if (pci_bus_not_idle)  // indication that bus is busy
              begin
               $display ("Waiting, New Master, Bus Not Idle %x %x",
                          present_requestors, prev_master);
              end
              else
              begin  // case that bus is idle.  make no grant for 1 clock
               $display ("Waiting, New Master, Bus Idle %x %x",
                          present_requestors, prev_master);
              end
            end
            else
            begin  // no reason to change.  Park on previous winner
             $display ("Waiting, No New Master %x %x",
                        present_requestors, prev_master);
            end
          end
        PCI_ARBITER_REMOVE_GNT:
          begin  // pick the new winner, or the previous winner if the requestor left
            if (New_Master_Wants_Bus)
            begin  // new requestor wins.  Wait for it's reference before rearbitrating
             $display ("Remove Gnt, New Master still requesting %x %x",
                        present_requestors, prev_master);
            end
            else
            begin  // no reason to change.  Park on previous winner
             $display ("Remove Gnt, New Master removed request %x %x",
                        present_requestors, prev_master);
            end
          end
        PCI_ARBITER_DELAY_ONE:
          begin  // wait for pipelined copy of FRAME, IRDY to become valid
            $display ("Delay 1, wait for Frame and IRDY pipeline %x %x",
                       present_requestors, prev_master);
          end
        PCI_ARBITER_WAIT_FOR_IDLE:
          begin  // A new master is granted, but can't start until the PCI bus is idle
            if (New_Master_Stopped_Requesting)
            begin  // requestor removed request!  Never happens.  Rearb immediately.
             $display ("Waiting for Idle, New Master removed request %x %x",
                        present_requestors, prev_master);
            end
            else
            begin
              if (pci_bus_went_idle)
              begin  // now the new master can take control
               $display ("Waiting for Idle, went idle, New Master still requesting %x %x",
                          present_requestors, prev_master);
              end
              else
              begin  // wait for old master to release bus
               $display ("Waiting for Idle, not idle, New Master still requesting %x %x",
                          present_requestors, prev_master);
              end
            end
          end
        PCI_ARBITER_WAIT_FOR_ADDRESS:
          begin
            if (New_Master_Stopped_Requesting)
            begin  // requestor removed request!  Never happens.  Rearb immediately.
             $display ("Waiting for Address, New Master removed request %x %x",
                        present_requestors, prev_master);
            end
            else
            begin
              if ((pci_address_phase == 1'b1) || (gnt_timeout == 4'hF))
              begin  // safe to rearbitrate.  Is anyone waiting?
                if (New_Master_Wants_Bus)
                begin
                  if (pci_bus_not_idle) // bus is busy, switch instantly
                  begin
                   $display ("Waiting for Address, Address or Timeout, New Master still requesting, bus was busy %x %x",
                              present_requestors, prev_master);
                  end
                  else  // bus is idle, force an idle period
                  begin
                   $display ("Waiting for Address, Address or Timeout, New Master still requesting, bus was idle %x %x",
                              present_requestors, prev_master);
                  end
                end
                else
                begin  // no reason to change.  Park on previous winner
                  $display ("Waiting for Address, No New Master, giving up %x %x",
                             present_requestors, prev_master);
                end
              end
              else
              begin
                $display ("Waiting for Address, New Master still requesting, no address or timeout yet %x %x",
                           present_requestors, prev_master);
              end
            end
          end
        default:
          begin
            $display ("PCI Arbiter went insane with REQ 'h%x at time %t",
                       present_requestors, $time);
          end
        endcase
      end
    end
  end
`endif // PCI_TRACE_ARB
// synopsys translate_on
endmodule

