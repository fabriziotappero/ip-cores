////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Computer Operating Properly - Top-level
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/cop.....
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

module cop_top #(parameter ARST_LVL = 1'b0,      // asynchronous reset level
                 parameter INIT_ENA = 1'b1,      // COP Enabled after reset
                 parameter SERV_WD_0 = 16'h5555, // First Service Word
		 parameter SERV_WD_1 = 16'haaaa, // Second Service Word
                 parameter COUNT_SIZE = 16,      // Main counter size
                 parameter SINGLE_CYCLE = 1'b0,  // No bus wait state added
		 parameter DWIDTH = 16)          // Data bus width
  (
  // Wishbone Signals
  output [DWIDTH-1:0] wb_dat_o,     // databus output
  output              wb_ack_o,     // bus cycle acknowledge output
  input               wb_clk_i,     // master clock input
  input               wb_rst_i,     // synchronous active high reset
  input               arst_i,       // asynchronous reset
  input         [2:0] wb_adr_i,     // lower address bits
  input  [DWIDTH-1:0] wb_dat_i,     // databus input
  input               wb_we_i,      // write enable input
  input               wb_stb_i,     // stobe/core select signal
  input               wb_cyc_i,     // valid bus cycle input
  input         [1:0] wb_sel_i,     // Select byte in word bus transaction
  // COP IO Signals
  output              cop_rst_o,    // COP reset output, active low
  output              cop_irq_o,    // COP interrupt request signal output
  input               por_reset_i,  // System Power On Reset, active low
  input               startup_osc_i,// System Startup Oscillator
  input               stop_mode_i,  // System STOP Mode
  input               wait_mode_i,  // System WAIT Mode
  input               debug_mode_i, // System DEBUG Mode
  input               scantestmode  // Chip in in scan test mode
  );
  
  logic                  cop_event;     // COP status bit
  logic                  cop_flag;      // COP Rollover Flag
  logic            [1:0] cop_irq_en;    // COP Interrupt request enable
  logic [COUNT_SIZE-1:0] cop_counter;   // COP Counter Value
  logic [COUNT_SIZE-1:0] cop_capture;   // Counter value syncronized to bus_clk domain
  logic                  async_rst_b;   // Asyncronous reset
  logic                  sync_reset;    // Syncronous reset
  logic           [ 4:0] write_regs;    // Control register write strobes
  logic                  prescale_out;  //
  logic                  stop_ena;      // Clear COP Rollover Status Bit
  logic                  debug_ena;     // COP in Slave Mode, ext_sync_i selected
  logic                  wait_ena;      // Enable COP in system wait mode
  logic                  cop_ena;       // Enable COP Timout Counter
  logic                  cwp;           // COP write protect
  logic                  clck;          // COP lock
  logic                  reload_count;  // COP System service complete
  logic                  clear_event;   // Reset COP Event register
  logic [COUNT_SIZE-1:0] timeout_value; // Prescaler modulo
  logic                  counter_sync;  // 
  
  // Wishbone Bus interface
  cop_wb_bus #(.ARST_LVL(ARST_LVL),
               .SINGLE_CYCLE(SINGLE_CYCLE),
               .DWIDTH(DWIDTH))
    wishbone(
    .*,
    .irq_source   ( cnt_flag_o ),
    .read_regs    (               // in  -- read register bits
		   { cop_capture,
		     timeout_value,
		     {7'b0, cop_event, cop_irq_en, debug_ena, stop_ena, wait_ena,
		      cop_ena, cwp, clck}
		   }
		  )
  );

// -----------------------------------------------------------------------------
  cop_regs #(.ARST_LVL(ARST_LVL),
             .INIT_ENA(INIT_ENA),
             .SERV_WD_0(SERV_WD_0),
	     .SERV_WD_1(SERV_WD_1),
             .COUNT_SIZE(COUNT_SIZE),
             .DWIDTH(DWIDTH))
    regs(
    .*,
    .bus_clk        ( wb_clk_i ),
    .write_bus      ( wb_dat_i ) 
  );

// -----------------------------------------------------------------------------
  cop_count #(.COUNT_SIZE(COUNT_SIZE))
    counter(
    .*,
    .bus_clk           ( wb_clk_i )
  );

endmodule // cop_top
