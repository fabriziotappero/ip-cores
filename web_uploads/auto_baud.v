//-----------------------------------------------------------------------------
// Auto Baud core
//
// This file is part of the "auto_baud" project.
// http://www.opencores.org/
// 
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 2002 John Clayton and OPENCORES.ORG
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation;  either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source.
// If not, download it from http://www.opencores.org/lgpl.shtml
//
//-----------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : Aug. 20, 2002
// Update: Aug. 20, 2002 copied this file from rs232_syscon.v (pared down).
// Update: Sep.  4, 2002 First test of this module.  The baud rate appears
//                       to be produced at 1/2 of the desired rate!
// Update: Sep.  5, 2002 First working results.  Fixed measurement (shift had
//                       been left out.)  Removed debug port since the unit
//                       appears to be working fine.  It Worked for all of the
//                       following BAUD rates, using 49.152 MHz clock and
//                       CLK_FACTOR = 8 and 16 bit main counter:
//                       300, 1200, 2400, 9600, 19200, 38400, 57600, 115200.
//                       Next step is to build the "tracking" version that
//                       doesn't need a reset to find a new BAUD rate...
// Update: Sep. 13, 2002 Added test data from "auto_baud_with_tracking.v"
//                       module tests.  This module has also been tested
//                       at various speeds, and it works well.
//
// Description
//-----------------------------------------------------------------------------
// This is a state-machine driven core that measures transition intervals
// in a particular character arriving via rs232 transmission (i.e. PC serial 
// port.)  Measurements of time intervals between transitions in the received
// character are then used to generate a baud rate clock for use in serial
// communications back and forth with the device that originally transmitted
// the measured character.  The clock which is generated is in reality a
// clock enable pulse, one single clock wide, occurring at a rate suitable
// for use in serial communications.  (This means that it will be generated
// at 4x or 8x or 16x the actual measured baud rate of the received character.
// The multiplication factor is called "CLOCK_FACTOR_PP" and is a settable
// parameter within this module.  The parameter "CLOCK_FACTOR_PP" need not
// be a power of two, but it should be a number between 2 and 16 inclusive.)
//
// The particular character which is targeted for measurement and verification
// in this module is: carriage return (CR) = 0x0d = 13.
// This particular character was chosen because it is frequently used at the
// end of a command line, as entered at a keyboard by a human user interacting
// with a command interpreter.  It is anticipated that the user would press
// the "enter" key once upon initializing communications with the electronic
// device, and the resulting carriage return character would be used for 
// determining BAUD rate, thus allowing the device to respond at the correct
// rate, and to carry on further communications.  The electronic device using
// this "auto_baud" module adjusts its baud rate to match the baud rate of
// the received data.  This works for all baud rates, within certain limits,
// and for all system clock rates, within certain limits.
//
// Received serially, the carriage return appears as the following waveform:
// ________    __    ____          _______________
//         |__|d0|__|d2d3|________|stop
//        start   d1      d4d5d6d7
//
// The waveform is shown with an identical "high" time and "low" time for
// each bit.  However, actual measurements taken using a logic analyzer
// on characters received from a PC show that the times are not equal.
// The "high" times turned out shorter, and the "low" times longer...
// Therefore, this module attempts to average out this discrepancy by
// measuring one low time and one high time.
//
// Since the transition measurements must unavoidably contain small amounts
// of error, the measurements are made during the beginning 2 bits of
// the received character, (that is, start bit and data bit zero).
// Then the measurement is immediately transformed into a baud rate clock,
// used to verify correct reception of the remaining 8 bits of the character.
// If the entire character is not received correctly using the generated
// baud rate, then the measurement is scrapped, and the unit goes into an
// idle scanning mode waiting for another character to test.
//
// This effectively filters out characters that the unit is not interested in
// receiving (anything that is not a carriage return.)  There is a slight
// possibility that a group of other characters could appear by random
// chance in a configuration that resembles a carriage return closely enough
// that the unit might accept the measurement and produce a baud clock too
// low.  But the probability of this happening is remote enough that the
// unit is considered highly "robust" in normal use, especially when used
// for command entry by humans.  It would take a very clever user indeed, to
// enter the correct series of characters with the correct intercharacter
// timing needed to possibly "fool" the unit!
//
// (Also, the baud rate produced falls within certain limits imposed by
//  the hardware of the unit, which prevents the auto_baud unit from mistaking
//  a series of short glitches on the serial data line for a really
//  fast CR character.)
//
// The first carriage return character received will produce a BAUD rate clock
// and the unit will indicate a "locked" condition.  From that point onward,
// the unit will continue running, but it will not scan for any more
// input characters.  The only way to reset the unit to its initial condition
// is through the use of the "reset_i" pin.  Following reset, the unit is
// once again looking for a carriage return character to lock on to.
// Another module, called "auto_baud_with_tracking.v" handles situations where
// you might want to have the BAUD rate change dynamically.
//
//
// NOTES:
// - This module uses a counter to divide down the clk_i signal to produce the
//   baud_clk_o signal.  Since the frequency of baud_clk_o is nominally
//   CLOCK_FACTOR_PP * rx_baud_rate, where "rx_baud_rate" is the baud rate
//   of the received character, then the higher you make CLOCK_FACTOR_PP, the
//   higher the generated baud_clk_o signal frequency, and hence the lower the
//   resolution of the divider.  Therefore, using a lower value for the
//   CLOCK_FACTOR_PP will allow you to use a lower clk_i with this module.
// - To set LOG2_MAX_COUNT_PP, remember (max_count*CLOCK_FACTOR_PP)/Fclk_i
//   is the maximum measurement time that can be accomodated by the circuit.
//   (where Fclk_i is the frequency of clk_i, and 1/Fclk_i is the period.)
//   Therefore, set LOG2_MAX_COUNT_PP so that the maximum measurement time
//   is at least as long as 2x the baud interval of the slowest received
//   serial data (2x because there are two bits involved in the measurement!)
//   For example, for Fclk_i = 20MHz, CLOCK_FACTOR_PP = 4 and a minimum
//   baud rate of 115,200, you would calculate:
//
//   (max_count * CLOCK_FACTOR_PP)*1/Fclk_i >= 2/Fbaud_max
//
//   Solving for the bit width of the max_count counter...
//
//   LOG2_MAX_COUNT_PP >= ceil(log_base_2(max_count))
//
//                 >= ceil(log_base_2(2*Fclk_i/(Fbaud_max*CLOCK_FACTOR_PP)))
//
//                 >= ceil(log_base_2(2*20E6/(115200*4)))
//
//                 >= ceil(log_base_2(86.8))
//
//                 >= 7 bits.
//
// - In the above example, the maximum count would approach 87, which means
//   that a measurement error of 1 count is about (1/87)=approx. 1.15%.  This
//   is an acceptable level of error for a baud rate clock.  Notice that the
//   lower baud rates have an even smaller error percentage (Yes!) but that
//   they require a much larger measurement counter...  For instance,
//   to lock onto 300 baud using the same example above, would require:
//
//   LOG2_MAX_COUNT_PP >= ceil(log_base_2(40000000/1200))
//
//                     >= ceil(log_base_2(33333.3))
//
//                     >= ceil(15.024678)
//
//                     >= 16 bits.
//
// - If the percentage error for your highest desired baud rate is greater
//   than a few percent, you might want to use a higher Fclk_i or else a 
//   lower CLOCK_FACTOR_PP.
//
// - Using the default settings:  CLK_FACTOR_PP = 8, LOG2_MAX_COUNT_PP = 16
//   The following test results were obtained, using an actual session in
//   hyperterm, looking for correct readable character transmission both
//   directions.  (Note: These tests were performed at "human interface"
//   speeds.  High speed or "back-to-back" character transmission might
//   exhibit worse performance than these results.)
//   The test results shown below were actually obtained using the more
//   complex "auto_baud_with_tracking.v" module.  Similar or better results
//   are expected with this module.
//
//   Clk_i
//   Freq.
//   (MHz)    110    300    1200   2400   4800   9600   19200  57600  115200
//   ------  ---------------------------------------------------------------
//   98       FAIL   pass   pass   pass   pass   pass   pass   pass   pass
//   55       FAIL   pass   pass   pass   pass   pass   pass   pass   pass
//   49       pass   pass   pass   pass   pass   pass   pass   pass   pass
//   24.5     pass   pass   pass   pass   pass   pass   pass   pass   FAIL
//   12       pass   pass   pass   pass   pass   pass   pass   pass   FAIL
//    6       pass   pass   pass   pass   pass   pass   pass   FAIL   FAIL
//    3       pass   pass   pass   pass   pass   FAIL   FAIL   FAIL   FAIL
//    1.5     pass   pass   pass   pass   FAIL   FAIL   FAIL   FAIL   FAIL
//
//
//-------------------------------------------------------------------------------------

`define LOG2_MAX_CLOCK_FACTOR 4  // Sets the size of the CLOCK_FACTOR
                                 // prescaler.
`define BITS_PER_CHAR         8  // Include parity, if used, but not
                                 // start and stop bits...

// Note: Simply changing the template bits does not reconfigure the
//       module to look for a different character (because a new measurement
//       window would have to be defined for a different character...)
//       The template bits are the exact bits used during verify, against
//       which the incoming character is checked.
//       The LSB of the character is discarded, and the stop bit is appended
//       since it is the last bit used during verify.
//
// so, for N:8:1 (no parity, 8 data bits, 1 stop bit) it is:
//                         = {1,(character>>1)} = 9'h086
// or, with parity included it is:
//                         = {1,parity_bit,(character>>1)} = 9'h106
//
`define TEMPLATE_BITS     9'h086  // Carriage return && termination flag


module auto_baud
  (
  clk_i,
  reset_i,
  serial_dat_i,
  auto_baud_locked_o,
  baud_clk_o
  );


// Parameters

// CLOCK_FACTOR_PP can be from [2..16] inclusive.
parameter CLOCK_FACTOR_PP = 8;     // Baud clock multiplier
parameter LOG2_MAX_COUNT_PP = 16;  // Bit width of measurement counter

// State encodings, provided as parameters
// for flexibility to the one instantiating the module.
// In general, the default values need not be changed.

// There is one state machines: m1.
// "default" state upon power-up and configuration is:
//    "m1_idle" because that is the all zero state.

parameter m1_idle          = 4'h0;  // Initial state (scanning)
parameter m1_measure_0     = 4'h1;  // start bit     (measuring)
parameter m1_measure_1     = 4'h2;  // debounce      (measuring)
parameter m1_measure_2     = 4'h3;  // data bit 0    (measuring)
parameter m1_measure_3     = 4'h4;  // debounce      (measuring)
parameter m1_measure_4     = 4'h5;  // measurement done (headed to verify)
parameter m1_verify_0      = 4'h8;  // data bit 1    (verifying)
parameter m1_verify_1      = 4'h9;  // data bit 2    (verifying)
parameter m1_run           = 4'h6;  // running
parameter m1_verify_failed = 4'h7;  // resetting   (headed back to idle)

// I/O declarations
input clk_i;                 // System clock input
input reset_i;               // Reset signal for this module
input serial_dat_i;          // TTL level serial data signal

output auto_baud_locked_o;   // Indicates BAUD clock is being generated
output baud_clk_o;           // BAUD clock output (actually a clock enable)


// Internal signal declarations
wire mid_bit_count;       // During measurement, advances measurement counter
                          // (Using the mid bit time to advance the
                          //  measurement timer accomplishes a timing "round"
                          //  so that the timing measurement is as accurate
                          //  as possible.)
                          // During verify, pulses at mid bit time are used
                          // to signal the state machine to check a data bit.
wire main_count_rollover;       // Causes main_count to roll over
wire clock_count_rollover;      // Causes clock_count to roll over
                                // (when clock_count is used as a 
                                //  clock_factor prescaler)
wire enable_clock_count;        // Logic that determines when clock_count
                                // should be counting
wire verify_done;               // Indicates finish of verification time

reg idle;                 // Indicates state
reg run;                  // Indicates state
reg measure;              // Indicates state
reg clear_counters;       // Pulses once when measurement is done.
reg verify;               // Indicates state
reg character_miscompare; // Indicates character did not verify
reg [`LOG2_MAX_CLOCK_FACTOR-1:0] clock_count; // Clock_factor prescaler,
                                              // and mid_bit counter.
reg [LOG2_MAX_COUNT_PP-1:0] main_count;       // Main counter register
reg [LOG2_MAX_COUNT_PP-1:0] measurement;      // Stored measurement count
reg [`BITS_PER_CHAR:0] target_bits;           // Character bits to compare
// (lsb is not needed, since it is used up during measurement time,
//  but the stop bit and possible parity bit are needed.)

    // For the state machine
reg [3:0] m1_state;
reg [3:0] m1_next_state;



//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------


// This is the CLOCK_FACTOR_PP prescaler and also mid_bit_count counter
assign enable_clock_count = measure || (verify && main_count_rollover);
always @(posedge clk_i or posedge reset_i)
begin
  if (reset_i) clock_count <= 0;
  else if (clear_counters) clock_count <= 0;
  else if (enable_clock_count)
  begin  // Must have been clk_i edge
    if (clock_count_rollover) clock_count <= 0;
    else clock_count <= clock_count + 1;
  end
end
// Counter rollover condition
assign clock_count_rollover = (clock_count == (CLOCK_FACTOR_PP-1));
// This condition signals the middle of a bit time, for use during the
// verify stage.  Also, this signal is used to advance the main count,
// instead of "clock_count_rollover."  This produces an effective "rounding"
// operation for the measurement (which would otherwise "truncate" any
// fraction of time contained in this counter at the instant the measurement
// is finished.
// (The "enable_clock_count" is included in order to make the pulse narrow,
//  only one clock wide...)
assign mid_bit_count = (
                        (clock_count == ((CLOCK_FACTOR_PP>>1)-1))
                        && enable_clock_count
                        );

// This is the main counter.  During measurement, it advances once for
// each CLOCK_FACTOR_PP cycles of clk_i.  This accumulated measurement
// is then latched into "measurement" when the state machine determines that
// the measurement interval is finished.
// During verify and idle_run times (whenever the baud rate clock is used)
// this counter is allowed to run freely, advancing once each clk_i, but being
// reset when it reaches a total count of "measurement" clock cycles.  The
// signal that reset the counter during this type of operation is the baud
// rate clock.
always @(posedge clk_i or posedge reset_i)
begin
  if (reset_i) main_count <= 0;
  else // must have been clk_i edge
  begin
    // Clear main count when measurement is done
    if (clear_counters) main_count <= 0;
    // If measuring, advance once per CLOCK_FACTOR_PP clk_i pulses.
    else if (measure && mid_bit_count) main_count <= main_count + 1;
    // If verifying or running, check reset conditions, 
    // otherwise advance always.
    else if (verify || run)
    begin
      if (main_count_rollover) main_count <= 0;
      else main_count <= main_count + 1;
    end
  end
end

// This is a shift register used to provide "target" character bits one at
// a time for verification as they are "received" (sampled) using the
// candidate baud clock.
always @(posedge clk_i or posedge reset_i)
begin
  if (reset_i) target_bits <= `TEMPLATE_BITS;
  else // must have been a clock edge
  begin
    if (~verify) target_bits <= `TEMPLATE_BITS;
    if (verify && mid_bit_count) target_bits <= {0,(target_bits>>1)};
  end
end
// It is done when only the stop bit is left in the shift register.
assign verify_done = (
                       (target_bits == 1)
                       && verify
                       && mid_bit_count
                      );

// This is a flip-flop used to keep track of whether the verify operation
// is succeeding or not.  Any target bits that do not match the received
// data at the sampling edge, will cause the verify_failed bit to go high.
// This is what the state machine looks at to determine whether it passed
// or not.
always @(posedge clk_i or posedge reset_i)
begin
  if (reset_i) character_miscompare <= 0;
  else  // Must have been a clock edge
  begin
    if (idle) character_miscompare <= 0;
    if (verify && mid_bit_count
        && (target_bits[0] ^ serial_dat_i)) character_miscompare <= 1;
  end
end


// This is the measurement storage latch.  The final measured time count
// from main_count is stored in this latch upon completion of the measurement
// interval.  The value stored in this latch is used whenever the baud clock
// is being generated, to reset the main count (causing a "rollover").
always @(posedge clk_i or posedge idle)
begin
  // Set to all ones during idle (asynchronous).
  if (idle) measurement <= -1;
  // Otherwise, there must have been a clk_i edge
  // When the measurement is done, the counters are cleared, and the time
  // interval must be stored before it is cleared away...
  // This also causes a store following a failed verify state on the way back
  // into idle, but the idle state clears out the false measurement anyway.
  else if (clear_counters) measurement <= (main_count>>1);
end

// This is effectively the baud clock signal
// But it is prevented from reaching the output pin during verification...
// It is only allowed out of the module during idle_run state.
assign main_count_rollover = (main_count == measurement);
assign baud_clk_o = (main_count_rollover && run);


// This is state machine m1.  It checks the status of the serial_dat_i line
// and coordinates the measurement of the time interval of the first two
// bits of the received character, which is the "measurement interval."
// Following the measurement interval, the state machine enters a new
// phase of bit verification.  If the measured time interval is accurate
// enough to measure the remaining 8 bits of the character correctly, then
// the measurement is accepted, and the baud rate clock is driven onto
// the baud_clk_o output pin.  Incidentally, the process of verification
// effectively filters out all characters which are not the desired target
// character for measurement.  In this case, the target character is the
// carriage return.


// State register
always @(posedge clk_i or posedge reset_i)
begin : m1_state_register
  if (reset_i) m1_state <= m1_idle;          // asynchronous reset
  else m1_state <= m1_next_state;
end

// State transition logic
always @(m1_state
         or mid_bit_count
         or serial_dat_i
         or verify_done
         or character_miscompare
         )
begin : m1_state_logic

  // Default values for outputs.  The individual states can override these.
  idle <= 1'b0;
  run <= 1'b0;
  measure <= 1'b0;
  clear_counters <= 1'b0;
  verify <= 1'b0;

  case (m1_state) // synthesis parallel_case

    m1_idle :
      begin
        idle <= 1'b1;
        if (serial_dat_i == 0) m1_next_state <= m1_measure_0;
        else m1_next_state <= m1_idle;
      end

    m1_measure_0 :
      begin
        measure <= 1'b1;
        // Check at mid bit time, to make sure serial line is still low...
        // (At this time, "mid_bit_count" is simply CLOCK_FACTOR_PP>>1 clk_i's.)
        if (mid_bit_count && ~serial_dat_i) m1_next_state <= m1_measure_1;
        // If it is not low, then it must have been a "glitch"...
        else if (mid_bit_count && serial_dat_i) m1_next_state <= m1_idle;
        else m1_next_state <= m1_measure_0;
      end

    m1_measure_1 :
      begin
        measure <= 1'b1;
        // Look for first data bit (high).
        if (serial_dat_i) m1_next_state <= m1_measure_2;
        // If it is not high keep waiting...
        // (Put detection of measurement overflow in here if necessary...)
        else m1_next_state <= m1_measure_1;
      end

    m1_measure_2 :
      begin
        measure <= 1'b1;
        // Check using mid bit time, to make sure serial line is still high...
        // (At this time, "mid_bit_count" is simply CLOCK_FACTOR_PP>>1 clk_i's.)
        if (mid_bit_count && serial_dat_i) m1_next_state <= m1_measure_3;
        // If it is not high, then it must have been a "glitch"...
        else if (mid_bit_count && ~serial_dat_i) m1_next_state <= m1_idle;
        else m1_next_state <= m1_measure_2;
      end

    m1_measure_3 :
      begin
        measure <= 1'b1;
        // Look for end of measurement interval (low)
        if (!serial_dat_i) m1_next_state <= m1_measure_4;
        // If it is not high keep waiting...
        // (Put detection of measurement overflow in here if necessary...)
        else m1_next_state <= m1_measure_3;
      end

    // This state outputs a reset pulse, to clear counters and store the
    // measurement from main_count.
    m1_measure_4 :
      begin
        clear_counters <= 1'b1; // Clears counters, stores measurement
        m1_next_state <= m1_verify_0;
      end

    m1_verify_0 :  // Wait for verify operations to finish
      begin
        verify <= 1'b1;
        if (verify_done) m1_next_state <= m1_verify_1;
        else m1_next_state <= m1_verify_0;
      end

    // NOTE: This "extra" state is needed because the character_miscompare
    //       information is not valid until 1 cycle after verify_done is
    //       active.
    m1_verify_1 :  // Checks for character miscompare
      begin
        if (character_miscompare) m1_next_state <= m1_verify_failed;
        else m1_next_state <= m1_run;
      end

    m1_verify_failed : // Resets counters on the way back to idle
      begin
        clear_counters <= 1'b1;
        m1_next_state <= m1_idle;
      end

    // This state is for successful verification results!
    // Since this is a single measurement unit, only reset can exit this
    // state.
    m1_run :       
      begin
        run <= 1'b1;
        m1_next_state <= m1_run;
      end

    default : m1_next_state <= m1_idle;
  endcase
end


assign auto_baud_locked_o = run;


endmodule

//`undef LOG2_MAX_CLOCK_FACTOR
