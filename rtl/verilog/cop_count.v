////////////////////////////////////////////////////////////////////////////////
//
//  Computer Operating Properly - Watchdog Counter
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/cop.....
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

module cop_count #(parameter COUNT_SIZE = 16)
  (
  output reg [COUNT_SIZE-1:0] cop_counter,   // Modulo Counter value
  output reg [COUNT_SIZE-1:0] cop_capture,   // Counter value syncronized to bus_clk domain
  output reg                  cop_rst_o,     // COP Reset
  output reg                  cop_irq_o,     // COP Interrupt Request
  output reg                  cop_event,     // COP status bit
  input                       async_rst_b,   // Asyncronous reset signal
  input                       sync_reset,    // Syncronous reset signal
  input                       por_reset_i,   // System Power On Reset, active low
  input                       startup_osc_i, // System Startup Oscillator
  input                       bus_clk,       // Control register bus clock
  input                       reload_count,  // Correct control words written
  input                       clear_event,   // Reset the COP event register
  input                       debug_mode_i,  // System DEBUG Mode
  input                       debug_ena,     // Enable COP in system debug mode
  input                       wait_ena,      // Enable COP in system wait mode
  input                       wait_mode_i,   // System WAIT Mode
  input                       stop_ena,      // Enable COP in system stop mode
  input                       stop_mode_i,   // System STOP Mode
  input                       cop_ena,       // Enable COP Timout Counter
  input                [ 1:0] cop_irq_en,    // COP IRQ Enable/Value
  input      [COUNT_SIZE-1:0] timeout_value, // COP Counter initial value
  input                       scantestmode   // Chip in in scan test mode
  );


  wire stop_counter;    // Enable COP because of external inputs
  wire cop_clk;         // Clock for COP Timeout counter
  wire event_reset;     // Clear COP event status bit
  wire cop_clk_posedge; // Syncronizing signal to move data to bus_clk domain

  reg  cop_irq_dec;     // COP Interrupt Request Decode
  reg  cop_irq;         // COP Interrupt Request
  reg  reload_1;        // Resync register for commands crossing from bus_clk domain to cop_clk domain
  reg  reload_2;        //
  reg  cop_clk_resync1; //
  reg  cop_clk_resync2; //

  
  assign event_reset = reload_count || clear_event;

  assign stop_counter = (debug_mode_i && debug_ena) ||
		        (wait_mode_i && wait_ena) || (stop_mode_i && stop_ena);

  assign cop_clk = scantestmode ? bus_clk : startup_osc_i;

  
  assign cop_clk_posedge = cop_clk_resync1 && !cop_clk_resync2;

  //  Watchdog Timout Counter
  always @(posedge cop_clk or negedge async_rst_b)
    if ( !async_rst_b )
      cop_counter  <= {COUNT_SIZE{1'b1}};
    else if ( reload_2 )
      cop_counter  <= timeout_value;
    else if ( !stop_counter )
      cop_counter  <= cop_counter - 1;

  //  COP Output Register
  always @(posedge cop_clk or negedge por_reset_i)
    if ( !por_reset_i )
      cop_rst_o <= 1'b0;
    else if ( reload_2 )
      cop_rst_o <= 1'b0;
    else
      cop_rst_o <= (cop_counter == 0);

  // Clock domain crossing registers. Take data from cop_clk domain and move it
  //  to the bus_clk domain.
  always @(posedge bus_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        cop_clk_resync1 <= 1'b0;
        cop_clk_resync2 <= 1'b0;
	cop_capture     <= {COUNT_SIZE{1'b1}};
      end
    else if (sync_reset)
      begin
        cop_clk_resync1 <= 1'b0;
        cop_clk_resync2 <= 1'b0;
	cop_capture     <= {COUNT_SIZE{1'b1}};
      end
    else
      begin
        cop_clk_resync1 <= cop_clk;
        cop_clk_resync2 <= cop_clk_resync1;
	cop_capture     <= cop_clk_posedge ? cop_counter : cop_capture;
      end

  // Stage one of pulse strecher and resync
  always @(posedge bus_clk or negedge async_rst_b)
    if ( !async_rst_b )
      reload_1 <= 1'b0;
    else if (sync_reset)
      reload_1 <= 1'b0;
    else
      reload_1 <= (sync_reset || reload_count || !cop_ena) || (reload_1 && !reload_2);

  // Stage two pulse strecher and resync
  always @(posedge cop_clk or negedge por_reset_i)
    if ( !por_reset_i )
      reload_2 <= 1'b1;
    else
      reload_2 <= reload_1;

  // Decode COP Interrupt Request
  always @*
    case (cop_irq_en) // synopsys parallel_case
       2'b01 : cop_irq_dec = (cop_counter <= 16);
       2'b10 : cop_irq_dec = (cop_counter <= 32);
       2'b11 : cop_irq_dec = (cop_counter <= 64);
       default: cop_irq_dec = 1'b0;
    endcase

  //  Watchdog Interrupt and resync
  always @(posedge bus_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        cop_irq   <= 0;
        cop_irq_o <= 0;
      end
    else if (sync_reset)
      begin
        cop_irq   <= 0;
        cop_irq_o <= 0;
      end
    else
      begin
        cop_irq   <= cop_irq_dec;
        cop_irq_o <= cop_irq;
      end

  //  Watchdog Status Bit
  always @(posedge bus_clk or negedge por_reset_i)
    if ( !por_reset_i )
      cop_event <= 0;
    else
      cop_event <= cop_rst_o || (cop_event && !event_reset);

endmodule  // cop_count

