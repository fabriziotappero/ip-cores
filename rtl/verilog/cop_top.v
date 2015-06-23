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
  
  wire                  cop_event;     // COP status bit
  wire            [1:0] cop_irq_en;    // COP Interrupt request enable
  wire [COUNT_SIZE-1:0] cop_counter;   // COP Counter Value
  wire [COUNT_SIZE-1:0] cop_capture;   // Counter value syncronized to bus_clk domain
  wire                  async_rst_b;   // Asyncronous reset
  wire                  sync_reset;    // Syncronous reset
  wire           [ 4:0] write_regs;    // Control register write strobes
  wire                  prescale_out;  //
  wire                  stop_ena;      // Clear COP Rollover Status Bit
  wire                  debug_ena;     // COP in Slave Mode, ext_sync_i selected
  wire                  wait_ena;      // Enable COP in system wait mode
  wire                  cop_ena;       // Enable COP Timout Counter
  wire                  cwp;           // COP write protect
  wire                  clck;          // COP lock
  wire                  reload_count;  // COP System service complete
  wire                  clear_event;   // Reset COP Event register
  wire [COUNT_SIZE-1:0] timeout_value; // Prescaler modulo
  wire                  counter_sync;  // 
  
  // Wishbone Bus interface
  cop_wb_bus #(.ARST_LVL(ARST_LVL),
               .SINGLE_CYCLE(SINGLE_CYCLE),
               .DWIDTH(DWIDTH))
    wishbone(
    .wb_dat_o     ( wb_dat_o ),
    .wb_ack_o     ( wb_ack_o ),
    .wb_clk_i     ( wb_clk_i ),
    .wb_rst_i     ( wb_rst_i ),
    .arst_i       ( arst_i ),
    .wb_adr_i     ( wb_adr_i ),
    .wb_dat_i     ( wb_dat_i ),
    .wb_we_i      ( wb_we_i ),
    .wb_stb_i     ( wb_stb_i ),
    .wb_cyc_i     ( wb_cyc_i ),
    .wb_sel_i     ( wb_sel_i ),
    
    // outputs
    .write_regs   ( write_regs ),
    .sync_reset   ( sync_reset ),
    // inputs    
    .async_rst_b  ( async_rst_b ),
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
    // outputs
    .cop_irq_en     ( cop_irq_en ),
    .timeout_value  ( timeout_value ),
    .debug_ena      ( debug_ena ),
    .stop_ena       ( stop_ena ),
    .wait_ena       ( wait_ena ),
    .cop_ena        ( cop_ena ),
    .cwp            ( cwp ),
    .clck           ( clck ),
    .reload_count   ( reload_count ),
    .clear_event    ( clear_event ),
    // inputs
    .async_rst_b    ( async_rst_b ),
    .sync_reset     ( sync_reset ),
    .bus_clk        ( wb_clk_i ),
    .write_bus      ( wb_dat_i ),
    .write_regs     ( write_regs )
  );

// -----------------------------------------------------------------------------
  cop_count #(.COUNT_SIZE(COUNT_SIZE))
    counter(
    // outputs
    .cop_counter       ( cop_counter ),
    .cop_capture       ( cop_capture ),
    .cop_rst_o         ( cop_rst_o ),
    .cop_irq_o         ( cop_irq_o ),
    .cop_event         ( cop_event ),
    // inputs
    .por_reset_i       ( por_reset_i ),
    .async_rst_b       ( async_rst_b ),
    .sync_reset        ( sync_reset ),
    .startup_osc_i     ( startup_osc_i ),
    .bus_clk           ( wb_clk_i ),
    .reload_count      ( reload_count ),
    .clear_event       ( clear_event ),
    .debug_ena         ( debug_ena ),
    .debug_mode_i      ( debug_mode_i ),
    .wait_ena          ( wait_ena ),
    .wait_mode_i       ( wait_mode_i ),
    .stop_ena          ( stop_ena ),
    .stop_mode_i       ( stop_mode_i ),
    .cop_ena           ( cop_ena ),
    .cop_irq_en        ( cop_irq_en ),
    .timeout_value     ( timeout_value ),
    .scantestmode      ( scantestmode )
  );

endmodule // cop_top
