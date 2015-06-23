////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Computer Operating Properly - Bus interface
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

module cop_wb_bus #(parameter ARST_LVL = 1'b0,    // asynchronous reset level
  		    parameter DWIDTH = 16,
                    parameter SINGLE_CYCLE = 1'b0)
  (
  // Wishbone Signals
  output      [DWIDTH-1:0] wb_dat_o,     // databus output
  output                   wb_ack_o,     // bus cycle acknowledge output
  input                    wb_clk_i,     // master clock input
  input                    wb_rst_i,     // synchronous active high reset
  input                    arst_i,       // asynchronous reset
  input             [ 2:0] wb_adr_i,     // lower address bits
  input       [DWIDTH-1:0] wb_dat_i,     // databus input
  input                    wb_we_i,      // write enable input
  input                    wb_stb_i,     // stobe/core select signal
  input                    wb_cyc_i,     // valid bus cycle input
  input              [1:0] wb_sel_i,     // Select byte in word bus transaction
  // COP Control Signals
  output reg        [ 4:0] write_regs,   // Decode write control register
  output                   async_rst_b,  //
  output                   sync_reset,   //
  input                    irq_source,   //
  input             [47:0] read_regs     // status register bits
  );


  // registers
  reg                bus_wait_state;  // Holdoff wb_ack_o for one clock to add wait state
  reg  [DWIDTH-1:0]  rd_data_mux;     // Pseudo Register, WISHBONE Read Data Mux
  reg  [DWIDTH-1:0]  rd_data_reg;     // Latch for WISHBONE Read Data

  // Wires
  wire   eight_bit_bus;
  wire   module_sel;      // This module is selected for bus transaction
  wire   wb_wacc;         // WISHBONE Write Strobe (Clock gating signal)
  wire   wb_racc;         // WISHBONE Read Access (Clock gating signal)

  //
  // module body
  //

  // generate internal resets
  assign eight_bit_bus = (DWIDTH == 8);

  assign async_rst_b = arst_i ^ ARST_LVL;
  assign sync_reset = wb_rst_i;

  // generate wishbone signals
  assign module_sel = wb_cyc_i && wb_stb_i;
  assign wb_wacc    = module_sel && wb_we_i && (wb_ack_o || SINGLE_CYCLE);
  assign wb_racc    = module_sel && !wb_we_i;
  assign wb_ack_o   = SINGLE_CYCLE ? module_sel : ( module_sel && bus_wait_state);
  assign wb_dat_o   = SINGLE_CYCLE ? rd_data_mux : rd_data_reg;

  // generate acknowledge output signal, By using register all accesses takes two cycles.
  //  Accesses in back to back clock cycles are not possable.
  always @(posedge wb_clk_i or negedge async_rst_b)
    if (!async_rst_b)
      bus_wait_state <=  1'b0;
    else if (sync_reset)
      bus_wait_state <=  1'b0;
    else
      bus_wait_state <=  module_sel && !bus_wait_state;

  // assign data read bus -- DAT_O
  always @(posedge wb_clk_i)
    if ( wb_racc )                     // Clock gate for power saving
      rd_data_reg <= rd_data_mux;

      
  // WISHBONE Read Data Mux
  always @*
      case ({eight_bit_bus, wb_adr_i}) // synopsys parallel_case
	// 8 bit Bus, 8 bit Granularity
	4'b1_000: rd_data_mux = read_regs[ 7: 0];  // 8 bit read address 0
	4'b1_001: rd_data_mux = read_regs[15: 8];  // 8 bit read address 1
	4'b1_010: rd_data_mux = read_regs[23:16];  // 8 bit read address 2
	4'b1_011: rd_data_mux = read_regs[31:24];  // 8 bit read address 3
	4'b1_100: rd_data_mux = read_regs[39:32];  // 8 bit read address 4
	4'b1_101: rd_data_mux = read_regs[47:40];  // 8 bit read address 5
	// 16 bit Bus, 16 bit Granularity
	4'b0_000: rd_data_mux = read_regs[15: 0];  // 16 bit read access address 0
	4'b0_001: rd_data_mux = read_regs[31:16];
	4'b0_010: rd_data_mux = read_regs[47:32];
      endcase

  // generate wishbone write register strobes -- one hot if 8 bit bus
  //                                             two hot if 16 bit bus
  always @*
    begin
      write_regs = 0;
      if (wb_wacc)
	case ({eight_bit_bus, wb_adr_i}) // synopsys parallel_case
           // 8 bit Bus, 8 bit Granularity
	   5'b1_000 : write_regs = 5'b00001;
	   5'b1_001 : write_regs = 5'b00010;
	   5'b1_010 : write_regs = 5'b00100;
	   5'b1_011 : write_regs = 5'b01000;
	   5'b1_100 : write_regs = 5'b10000;
           // 16 bit Bus, 16 bit Granularity
	   5'b0_000 : write_regs = 5'b00011;
	   5'b0_001 : write_regs = 5'b01100;
	   5'b0_010 : write_regs = 5'b10000;
	   default: ;
	endcase
    end

endmodule  // cop_wb_bus
