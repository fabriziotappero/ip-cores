//---------------------------------------------------------------------------
// PWM reader 
// ...for variable frequency PWM signals from real world sensors.
//
//
// Description: See description below (which suffices for IP core
//                                     specification document.)
//
// Copyright (C) 2002 John Clayton and OPENCORES.ORG (this Verilog version)
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
//---------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : Jan  28, 2003
//
// (NOTE: Date formatted as day/month/year.)
// Update: 11/03/03 Saved "pwd_counter.v" under the new name "pwm_reader.v" so
//                  that the divide_uu module can be integrated into this new
//                  module.
// Update: 13/03/03 Finished coding module, began testing.
//
// Update: 03/06/03 Added ack_r signal, so that stb_o would not oscillate when
//                  connected directly to the ack_i input.
//
// Description
//---------------------------------------------------------------------------
// This module reads the pulse width of a repetitive variable duty cycle
// digital input.  Pulse Width Modulated (PWM) inputs are produced by many 
// devices, including certain real world sensors.
// In this case, the specific sensor for which this module was created
// is the Analog Devices ADXL202e (a +/- 2g. dual accelerometer.)
//
// Operation of this module is very simple:
//
// An up-counter (T) counts clocks in one period of the incoming PWM signal.
// The T counter is reset with each rising edge of the incoming PWM waveform.
//
// Another (clock-enabled) up-counter (S) counts the clocks during the time
// when the PWM signal input is high.
// The S counter is also reset at the rising edge of the incoming PWM wave.
//
// To derive the duty cycle as a fraction, a serial divider calculates S/T.
//
// Once the fraction is obtained, the output is presented at "dat_o."
// The signal "stb_o" (strobe output) indicates that a valid reading is
// present on the data bus output.  The strobe will remain high until the
// reading is acknowledged by pulsing "ack_i" for one clock cycle.
//
// If "stb_o" is tied directly to "ack_i" then each time a new reading is 
// obtained a pulse will be produced at "stb_o" which is one single clock wide.
//
// It is important to note that in the absence of any ack_i signal, the unit
// will hold the contents of the last reading, and any new readings from the
// PWM device will be missed.
//
//---------------------------------------------------------------------------


module pwm_reader (
                    clk_i,
                    clk_en_i,
                    rst_i,
                    pwm_signal_i,
                    ack_i,
                    dat_o,
                    stb_o
                    );

parameter COUNTER_WIDTH_PP     = 10; // Size to hold (max_pwm_period)*(Fclk_i)
parameter DAT_WIDTH_PP         = 8;  // Size of fraction from divider
parameter DIV_COUNT_WIDTH_PP   = 3;  // Must be enough bits to hold the number:
                                     // DAT_WIDTH_PP-1

input clk_i;
input clk_en_i;
input rst_i;
input pwm_signal_i;
input ack_i;

output [DAT_WIDTH_PP-1:0] dat_o;
output stb_o;

// Local signals
reg  [COUNTER_WIDTH_PP-1:0] s_cnt;
reg  [COUNTER_WIDTH_PP-1:0] t_cnt;
reg  pwm_ff_1;
reg  pwm_ff_2;
reg  ack_r;

wire rising_edge;
wire divide_done;

//-----------------------------------------------------------------------
// Try to avoid metastability by running the input signal through
// a D flip flop.
always @(posedge clk_i)
begin
  if (rst_i) pwm_ff_1 <= 0;
  else pwm_ff_1 <= pwm_signal_i;
end

// This is the rising edge detection
always @(posedge clk_i)
begin
  if (rst_i) pwm_ff_2 <= 0;
  else pwm_ff_2 <= pwm_ff_1;
end
assign rising_edge = pwm_ff_1 && ~pwm_ff_2;

// This is period counter
always @(posedge clk_i)
begin
  if (rst_i || rising_edge) t_cnt <= 0;
  else if (clk_en_i) t_cnt <= t_cnt + 1;
end

// This is duty cycle counter
always @(posedge clk_i)
begin
  if (rst_i || rising_edge) s_cnt <= 0;
  else if (clk_en_i && pwm_signal_i) s_cnt <= s_cnt + 1;
end

// This unit provides for the division s_cnt/t_cnt.
// The values in the counters are latched into the divider whenever
// the divide_i input is pulsed.
// The divider ignores the inputs whenever "divide_i" is not pulsed, so
// there is no problem with the counters continually advancing until
// the division is started.
//
// Since the result is expected to be purely fractional, the quotient part
// is all zero, and is thrown away on purpose.  (A special divider could be
// build possibly to avoid this?)
serial_divide_uu #(
                   COUNTER_WIDTH_PP,    // M_PP (dividend width)
                   COUNTER_WIDTH_PP,    // N_PP (divisor width)
                   DAT_WIDTH_PP,        // R_PP (remainder width)
                   COUNTER_WIDTH_PP,    // S_PP (skip integer part of quotient)
                   DIV_COUNT_WIDTH_PP,  // counter bits
                   1                    // need output holding buffers?
                   )
  divider_unit
  (
   .clk_i(clk_i),
   .clk_en_i(1'b1),
   .rst_i(rst_i),
   // New divide is not allowed until previous value is read or acknowledged
   .divide_i(rising_edge && ~stb_o),
   .dividend_i(s_cnt),
   .divisor_i(t_cnt),
   .quotient_o(dat_o),
   .done_o(divide_done)
  );

// This latches the ack_i input, so that at least one pulse of stb_o is produced
// before the ack_i takes it down low again, in case the stb_o output is wired
// directly to the ack_i input.
always @(posedge clk_i)
begin
  if (rst_i || (rising_edge && ~stb_o)) ack_r <= 0;
  else if (stb_o) ack_r <= ack_i;
end

assign stb_o = divide_done && ~ack_r;

endmodule


