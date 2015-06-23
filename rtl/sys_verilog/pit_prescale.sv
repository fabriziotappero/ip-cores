////////////////////////////////////////////////////////////////////////////////
//
//  Programable Interrupt Timer - Prescale Counter
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/pit.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011, Robert Hayes
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

module pit_prescale #(parameter COUNT_SIZE = 15,
                      parameter DECADE_CNTR = 1,
		      parameter NO_PRESCALE = 0)
  (
  output                      prescale_out,  // 
  output                      counter_sync,  // 
  input                       async_rst_b,   // 
  input                       sync_reset,    // Syncronous reset signal
  input                       bus_clk,       // Reference Clock
  input                       cnt_sync_o,    // Syncronous counter enable
  input                       ext_sync_i,    // Enable from external PIT
  input                       pit_slave,     // PIT Slave Mode
  input                 [3:0] divisor        // Count Divisor
  );
  
// Warning: This counter has no safety net if the divisor changes while the
//           counter is active. There may need to be an addtional latch
//           register for"divisor" that captures on the falling edge of
//           "cnt_sync_o" or when "cnt_n" rolls over to eliminate this problem.

logic  [COUNT_SIZE-1:0] cnt_n;         // Div N counter
logic  [COUNT_SIZE-1:0] end_count;     // Psudo register for decoding

logic                   div_1;         // 
logic                   rollover;      // 

// This was going to be a "generate" block but iverilog does't support that
//  command so we'll just have to trust the compiler to simplify the logic based
//  on the setting of the constant "DECADE_CNTR"
   always_comb
     if ( DECADE_CNTR )
       case (divisor)
          0: end_count = 1;
          1: end_count = 2;
          2: end_count = 4;
          3: end_count = 8;
          4: end_count = 10;
          5: end_count = 100;
          6: end_count = 1_000;
          7: end_count = 10_000;
          8: end_count = 20_000;
          default: end_count = 20_000;
        endcase
    else
        unique case (divisor)
           0: end_count = 1;
           1: end_count = 2;
           2: end_count = 4;
           3: end_count = 8;
           4: end_count = 16;
           5: end_count = 32;
           6: end_count = 64;
           7: end_count = 128;
           8: end_count = 256;
           9: end_count = 512;
          10: end_count = 1024;
          11: end_count = 2048;
          12: end_count = 4096;
          13: end_count = 8192;
          14: end_count = 16384;
          15: end_count = 32768;
        endcase

assign counter_sync = pit_slave ? ext_sync_i : cnt_sync_o;

assign div_1 = (end_count == 1);

assign rollover = NO_PRESCALE || (cnt_n == end_count);

assign prescale_out = (pit_slave && div_1 && ext_sync_i) || rollover; 

// Div N Counter
// If the "NO_PRESCALE" parameter is set the compiler should hopefully strip
//  these counter bits when the module is compiled because the only place the
//  register outputs go to drive a signal "rollover" that is already a constant.
always_ff @(posedge bus_clk or negedge async_rst_b)
  if ( !async_rst_b )
    cnt_n  <= 1;
  else if ( !counter_sync || rollover)
    cnt_n  <= 1;
  else
    cnt_n  <= cnt_n + 1;


endmodule  // pit_prescale

