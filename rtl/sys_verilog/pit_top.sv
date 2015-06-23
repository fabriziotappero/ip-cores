////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Programable Interrupt Timer - Top-level
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

module pit_top #(parameter D_WIDTH = 16,
                 parameter ARST_LVL = 1'b0,      // asynchronous reset level
                 parameter SINGLE_CYCLE = 1'b0,  // Add a wait state to bus transcation
                 parameter PRE_COUNT_SIZE = 15,  // Prescale Counter size
                 parameter COUNT_SIZE = 16,      // Main counter size
                 parameter DECADE_CNTR = 1'b1,   // Prescale rollover decode
                 parameter NO_PRESCALE = 1'b0)   // Remove prescale function
  (
  // Wishbone Signals
  wishbone_if.slave          wb,        // Wishbone interface instance
  output logic [D_WIDTH-1:0] wb_dat_o,  // databus output - Pseudo Register
  output logic               wb_ack,    // bus cycle acknowledge output
  input  logic               wb_stb,    // stobe/core select signal
  // PIT IO Signals
  output              pit_o,        // PIT output pulse
  output              pit_irq_o,    // PIT interrupt request signal output
  output              cnt_flag_o,   // PIT Flag Out
  output              cnt_sync_o,   // PIT Master Enable for Slave PIT's
  input               ext_sync_i    // Counter enable from Master PIT
  );
  
  logic [COUNT_SIZE-1:0] mod_value;     // Main Counter Modulo
  logic [COUNT_SIZE-1:0] cnt_n;         // PIT Counter Value
  logic                  async_rst_b;   // Asyncronous reset
  logic                  sync_reset;    // Syncronous reset
  logic           [ 3:0] write_regs;    // Control register write strobes
  logic                  prescale_out;  //
  logic                  pit_flg_clr;   // Clear PIT Rollover Status Bit
  logic                  pit_slave;     // PIT in Slave Mode, ext_sync_i selected
  logic           [ 3:0] pit_pre_scl;   // Prescaler modulo
  logic                  counter_sync;  // 
  logic                  pit_flag;      //
  
  // Wishbone Bus interface
  pit_wb_bus #(.ARST_LVL    (ARST_LVL),
               .D_WIDTH     (D_WIDTH))
    wishbone(
    // Wishbone Signals
    .wb           ( wb ),
    .wb_stb       ( wb_stb ),
    .wb_ack       ( wb_ack ),
    .irq_source   ( cnt_flag_o ),
    .read_regs    (               // in  -- status register bits
		   { cnt_n,
		     mod_value,
		     {pit_slave, DECADE_CNTR, NO_PRESCALE, 1'b0, pit_pre_scl,
		      5'b0, cnt_flag_o, pit_ien, cnt_sync_o}
		   }
		  ),
    .*);

// -----------------------------------------------------------------------------
  pit_regs #(.COUNT_SIZE(COUNT_SIZE),
	     .NO_PRESCALE(NO_PRESCALE),
             .D_WIDTH(D_WIDTH))
    regs(
      .bus_clk      ( wb.wb_clk ),
      .write_bus    ( wb.wb_dat ),
      .*);

// -----------------------------------------------------------------------------
  pit_prescale #(.COUNT_SIZE(PRE_COUNT_SIZE),
                 .DECADE_CNTR(DECADE_CNTR),
		 .NO_PRESCALE(NO_PRESCALE))
    prescale(
    .bus_clk      ( wb.wb_clk ),
    .divisor      ( pit_pre_scl ),
    .*);

// -----------------------------------------------------------------------------
  pit_count #(.COUNT_SIZE(COUNT_SIZE))
    counter(
    .bus_clk      ( wb.wb_clk ),
    .*);

endmodule // pit_top
