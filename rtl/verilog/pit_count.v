////////////////////////////////////////////////////////////////////////////////
//
//  Programable Interrupt Timer - Main Counter
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/pit.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

module pit_count #(parameter COUNT_SIZE = 16)
  (
  output reg [COUNT_SIZE-1:0] cnt_n,         // Modulo Counter value
  output reg                  cnt_flag_o,    // Counter Rollover Flag
  output reg                  pit_o,         // PIT output pulse
  input                       async_rst_b,   //
  input                       sync_reset,    // Syncronous reset signal
  input                       bus_clk,       // Reference Clock
  input                       counter_sync,  // Syncronous counter enable
  input                       prescale_out,  // Increment Counter
  input                       pit_flg_clr,   // Clear PIT Rollover Flag
  input      [COUNT_SIZE-1:0] mod_value      // Count Divisor
  );

// Warning: This counter has no saftynet if the mod_value changes while the counter
//           is active. There may need to be an addtional latch register for
//           "mod_value" that captures on the falling edge of "counter_sync" or
//           when "cnt_n" rolls over to eliminate this problem.


wire rollover;      // Counter has reached the mod_value
wire no_div;        // Modulo set for Zero or One
wire clear_counter; // Set counter to initial state

assign no_div = (mod_value == 1) || ~|mod_value;

assign rollover = ((cnt_n == mod_value) || no_div) && prescale_out;

assign clear_counter = !counter_sync;

//  Div N Counter
always @(posedge bus_clk or negedge async_rst_b)
  if ( !async_rst_b )
    cnt_n  <= 1;
  else if ( clear_counter || rollover || no_div)
    cnt_n  <= 1;
  else if ( prescale_out )
    cnt_n  <= cnt_n + 1;

//  Counter Rollover Flag and Interrupt
always @(posedge bus_clk or negedge async_rst_b)
  if ( !async_rst_b )
    cnt_flag_o <= 0;
  else if ( clear_counter || pit_flg_clr)
    cnt_flag_o <= 0;
  else if ( rollover )
    cnt_flag_o <= 1;

//  PIT Output Register
always @(posedge bus_clk or negedge async_rst_b)
  if ( !async_rst_b )
    pit_o <= 0;
  else
    pit_o <= rollover && counter_sync && !sync_reset;

endmodule  // pit_count

