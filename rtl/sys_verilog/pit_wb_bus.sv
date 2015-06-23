////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Programable Interrupt Timer - Bus interface
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

interface wishbone_if #(parameter D_WIDTH = 16,
                        parameter A_WIDTH = 3)

  // These signals maintain their direction without regard to master or slave
  //  Some signals may not be connected in every instance of the interface usage
  (logic [D_WIDTH-1:0] wb_dat_i,  // databus input
   logic               wb_clk,    // master clock input

   // These signals will change direction based on interface usage
   logic               arst,        // asynchronous reset
   logic               wb_rst,      // synchronous active high reset
   logic [A_WIDTH-1:0] wb_adr,      // lower address bits
   logic               wb_we,       // write enable input
   logic               wb_cyc,      // valid bus cycle input
   logic [2:0]         wb_sel       // Select bytes in word bus transaction
  );
  
  // Define the signal directions when the interface is used as a slave
  modport slave (input   wb_clk,
                         arst,
                         wb_rst,
                         wb_adr,
                         wb_dat_i,
                         wb_we,
                         wb_cyc,
                         wb_sel);

  // define the signal directions when the interface is used as a master
  modport master (output wb_adr,
                         wb_we,
                         wb_cyc,
                         wb_sel,
                  input  wb_clk,
                         wb_dat_i,
                         arst,
                         wb_rst);

endinterface  // wishbone_if  
  
module pit_wb_bus #(parameter D_WIDTH = 16,
                    parameter S_WIDTH = 2,
                    parameter A_WIDTH = 3,
                    parameter ARST_LVL = 1'b0,      // asynchronous reset level
                    parameter SINGLE_CYCLE = 1'b0)  // Add a wait state to bus transcation
  (
  // Wishbone Signals
  wishbone_if.slave          wb,          // Define the interface instance name
  output logic [D_WIDTH-1:0] wb_dat_o,    // databus output - Pseudo Register
  output logic               wb_ack,      // bus cycle acknowledge output
  input  logic               wb_stb,      // stobe/core select signal
  // PIT Control Signals
  output logic       [ 3:0] write_regs,  // Decode write control register
  output                    async_rst_b, //
  output                    sync_reset,  //
  input                     irq_source,  //
  input              [47:0] read_regs    // status register bits
  );


  // registers
  logic       bus_wait_state;  // Holdoff wb_ack for one clock to add wait state
  logic [2:0] addr_latch;      // Capture WISHBONE Address 

  // Wires
  logic       eight_bit_bus;
  logic       module_sel;      // This module is selected for bus transaction
  logic       wb_wacc;         // WISHBONE Write Strobe
  logic       wb_racc;         // WISHBONE Read Access (Clock gating signal)
  logic [2:0] address;         // Select either direct or latched address

  //
  // module body
  //

  // generate internal resets
  assign eight_bit_bus = (D_WIDTH == 8);

  assign async_rst_b = wb.arst ^ ARST_LVL;
  assign sync_reset  = wb.wb_rst;

  // generate wishbone signals
  assign module_sel = wb.wb_cyc && wb_stb;
  assign wb_wacc    = module_sel && wb.wb_we && (wb_ack || SINGLE_CYCLE);
  assign wb_racc    = module_sel && !wb.wb_we;
  assign wb_ack     = SINGLE_CYCLE ? module_sel : (bus_wait_state && module_sel);
  assign address    = SINGLE_CYCLE ? wb.wb_adr : addr_latch;

  // generate acknowledge output signal, By using register all accesses takes two cycles.
  //  Accesses in back to back clock cycles are not possable.
  always_ff @(posedge wb.wb_clk or negedge async_rst_b)
    if (!async_rst_b)
      bus_wait_state <=  1'b0;
    else if (sync_reset)
      bus_wait_state <=  1'b0;
    else
      bus_wait_state <=  module_sel && !bus_wait_state;

  // Capture address in first cycle of WISHBONE Bus tranaction
  //  Only used when Wait states are enabled
  //  Synthesis tool should be enabled to remove these registers in SINGLE_CYCLE mode
  always_ff @(posedge wb.wb_clk)
    if ( module_sel )                  // Clock gate for power saving
      addr_latch <= wb.wb_adr;

  // WISHBONE Read Data Mux
  always_comb
      case ({eight_bit_bus, address}) // synopsys parallel_case
      // 8 bit Bus, 8 bit Granularity
      4'b1_000: wb_dat_o = read_regs[ 7: 0];  // 8 bit read address 0
      4'b1_001: wb_dat_o = read_regs[15: 8];  // 8 bit read address 1
      4'b1_010: wb_dat_o = read_regs[23:16];  // 8 bit read address 2
      4'b1_011: wb_dat_o = read_regs[31:24];  // 8 bit read address 3
      4'b1_100: wb_dat_o = read_regs[39:32];  // 8 bit read address 4
      4'b1_101: wb_dat_o = read_regs[47:40];  // 8 bit read address 5
      // 16 bit Bus, 16 bit Granularity
      4'b0_000: wb_dat_o = read_regs[15: 0];  // 16 bit read access address 0
      4'b0_001: wb_dat_o = read_regs[31:16];
      4'b0_010: wb_dat_o = read_regs[47:32];
      default:  wb_dat_o = '0;
    endcase

  // generate wishbone write register strobes -- one hot if 8 bit bus
  always_comb
    begin
      write_regs = 0;
      if (wb_wacc)
	case ({eight_bit_bus, address}) // synopsys parallel_case
           // 8 bit Bus, 8 bit Granularity
	   4'b1_000 : write_regs = 4'b0001;
	   4'b1_001 : write_regs = 4'b0010;
	   4'b1_010 : write_regs = 4'b0100;
	   4'b1_011 : write_regs = 4'b1000;
           // 16 bit Bus, 16 bit Granularity
	   4'b0_000 : write_regs = 4'b0011;
	   4'b0_001 : write_regs = 4'b1100;
	   default: ;
	endcase
    end

    
endmodule  // pit_wb_bus
