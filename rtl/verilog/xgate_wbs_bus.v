////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Xgate Coprocessor - Slave Bus interface
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/xgate.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Supplemental terms.
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

module xgate_wbs_bus #(parameter ARST_LVL = 1'b0,    // asynchronous reset level
                       parameter DWIDTH   = 16,
                       parameter WB_RD_DEFAULT = 0,  // WISHBONE Read Bus default state
                       parameter SINGLE_CYCLE  = 1'b0)
  (
  // Wishbone Signals
  output      [DWIDTH-1:0] wbs_dat_o,     // databus output - Pseudo Register
  output                   wbs_ack_o,     // bus cycle acknowledge output
  output                   wbs_err_o,     // bus error, lost module select durning wait state
  input                    wbs_clk_i,     // master clock input
  input                    wbs_rst_i,     // synchronous active high reset
  input                    arst_i,        // asynchronous reset
  input             [ 6:1] wbs_adr_i,     // lower address bits
  input                    wbs_we_i,      // write enable input
  input                    wbs_stb_i,     // stobe/core select signal
  input                    wbs_cyc_i,     // valid bus cycle input
  input              [1:0] wbs_sel_i,     // Select byte in word bus transaction
  // XGATE Control Signals
  output reg               write_xgmctl, // Write Strobe for XGMCTL register
  output reg               write_xgchid, // Write Strobe for XGCHID register
  output reg               write_xgisp74,// Write Strobe for XGISP74 register
  output reg               write_xgisp30,// Write Strobe for XGISP30 register
  output reg         [1:0] write_xgvbr,  // Write Strobe for XGVBR register
  output reg         [1:0] write_xgif_7, // Write Strobe for Interrupt Flag Register 7
  output reg         [1:0] write_xgif_6, // Write Strobe for Interrupt Flag Register 6
  output reg         [1:0] write_xgif_5, // Write Strobe for Interrupt Flag Register 5
  output reg         [1:0] write_xgif_4, // Write Strobe for Interrupt Flag Register 4
  output reg         [1:0] write_xgif_3, // Write Strobe for Interrupt Flag Register 3
  output reg         [1:0] write_xgif_2, // Write Strobe for Interrupt Flag Register 2
  output reg         [1:0] write_xgif_1, // Write Strobe for Interrupt Flag Register 1
  output reg         [1:0] write_xgif_0, // Write Strobe for Interrupt Flag Register 0
  output reg               write_xgswt,  // Write Strobe for XGSWT register
  output reg               write_xgsem,  // Write Strobe for XGSEM register
  output reg               write_xgccr,  // Write Strobe for XGATE Condition Code Register
  output reg         [1:0] write_xgpc,   // Write Strobe for XGATE Program Counter
  output reg         [1:0] write_xgr7,   // Write Strobe for XGATE Data Register R7
  output reg         [1:0] write_xgr6,   // Write Strobe for XGATE Data Register R6
  output reg         [1:0] write_xgr5,   // Write Strobe for XGATE Data Register R5
  output reg         [1:0] write_xgr4,   // Write Strobe for XGATE Data Register R4
  output reg         [1:0] write_xgr3,   // Write Strobe for XGATE Data Register R3
  output reg         [1:0] write_xgr2,   // Write Strobe for XGATE Data Register R2
  output reg         [1:0] write_xgr1,   // Write Strobe for XGATE Data Register R1
  output reg         [1:0] write_irw_en_7, // Write Strobe for Interrupt Bypass Control Register 7
  output reg         [1:0] write_irw_en_6, // Write Strobe for Interrupt Bypass Control Register 6
  output reg         [1:0] write_irw_en_5, // Write Strobe for Interrupt Bypass Control Register 5
  output reg         [1:0] write_irw_en_4, // Write Strobe for Interrupt Bypass Control Register 4
  output reg         [1:0] write_irw_en_3, // Write Strobe for Interrupt Bypass Control Register 3
  output reg         [1:0] write_irw_en_2, // Write Strobe for Interrupt Bypass Control Register 2
  output reg         [1:0] write_irw_en_1, // Write Strobe for Interrupt Bypass Control Register 1
  output reg         [1:0] write_irw_en_0, // Write Strobe for Interrupt Bypass Control Register 0
  output                   async_rst_b,    //
  output                   sync_reset,     //
  input            [415:0] read_risc_regs, // status register bits for WISHBONE Read bus
  input            [127:1] irq_bypass      // IRQ status bits WISHBONE Read bus
  );


  // registers
  reg                bus_wait_state;  // Holdoff wbs_ack_o for one clock to add wait state
  reg         [5:0]  addr_latch;      // Capture WISHBONE Address

  reg                write_reserv1;   // Dummy Reg decode for Reserved address
  reg                write_reserv2;   // Dummy Reg decode for Reserved address

  reg  [DWIDTH-1:0]  read_mux_irq;    // Psudo register for WISHBONE IRQ read data bus mux

  // Wires
  wire       module_sel;      // This module is selected for bus transaction
  wire       wbs_wacc;        // WISHBONE Write Strobe (Clock gating signal)
  wire       wbs_racc;        // WISHBONE Read Access (Clock gating signal)
  wire [5:0] address;         // Select either direct or latched address

  reg [DWIDTH-1:0] read_mux_risc;  // Pseudo regester for WISHBONE RISC read data bus mux

  //
  // module body
  //

  // generate internal resets
  assign async_rst_b = arst_i ^ ARST_LVL;
  assign sync_reset  = wbs_rst_i;

  // generate wishbone signals
  assign module_sel  = wbs_cyc_i && wbs_stb_i;
  assign wbs_wacc    = module_sel && wbs_we_i && (wbs_ack_o || SINGLE_CYCLE);
  assign wbs_racc    = module_sel && !wbs_we_i;
  assign wbs_ack_o   = SINGLE_CYCLE ? module_sel : (bus_wait_state && module_sel);
  assign wbs_err_o   = !SINGLE_CYCLE && !module_sel && bus_wait_state;
  assign address     = SINGLE_CYCLE ? wbs_adr_i : addr_latch;

  assign wbs_dat_o   = read_mux_risc | read_mux_irq;

  // generate acknowledge output signal, By using register all accesses takes two cycles.
  //  Accesses in back to back clock cycles are not possible.
  always @(posedge wbs_clk_i or negedge async_rst_b)
    if (!async_rst_b)
      bus_wait_state <=  1'b0;
    else if (sync_reset)
      bus_wait_state <=  1'b0;
    else
      bus_wait_state <=  module_sel && !bus_wait_state;

  // Capture address in first cycle of WISHBONE Bus tranaction
  //  Only used when Wait states are enabled
  always @(posedge wbs_clk_i)
    if ( module_sel )                  // Clock gate for power saving
      addr_latch <= wbs_adr_i;

  // WISHBONE Read Data Mux for RISC status and control registers
  always @*
      case ({wbs_racc, address}) // synopsys parallel_case
        // 16 bit Bus, 16 bit Granularity
        7'b100_0000: read_mux_risc = read_risc_regs[ 15:  0];
        7'b100_0001: read_mux_risc = read_risc_regs[ 31: 16];
        7'b100_0010: read_mux_risc = read_risc_regs[ 47: 32];
        7'b100_0011: read_mux_risc = read_risc_regs[ 63: 48];
        7'b100_0100: read_mux_risc = read_risc_regs[ 79: 64];
        7'b100_0101: read_mux_risc = read_risc_regs[ 95: 80];
        7'b100_0110: read_mux_risc = read_risc_regs[111: 96];
        7'b100_0111: read_mux_risc = read_risc_regs[127:112];
        7'b100_1000: read_mux_risc = read_risc_regs[143:128];
        7'b100_1001: read_mux_risc = read_risc_regs[159:144];
        7'b100_1010: read_mux_risc = read_risc_regs[175:160];
        7'b100_1011: read_mux_risc = read_risc_regs[191:176];
        7'b100_1100: read_mux_risc = read_risc_regs[207:192];
        7'b100_1101: read_mux_risc = read_risc_regs[223:208];
        7'b100_1110: read_mux_risc = read_risc_regs[239:224];
        7'b100_1111: read_mux_risc = read_risc_regs[255:240];
        7'b101_0000: read_mux_risc = read_risc_regs[271:256];
        7'b101_0001: read_mux_risc = read_risc_regs[287:272];
        7'b101_0010: read_mux_risc = read_risc_regs[303:288];
        7'b101_0011: read_mux_risc = read_risc_regs[319:304];
        7'b101_0100: read_mux_risc = read_risc_regs[335:320];
        7'b101_0101: read_mux_risc = read_risc_regs[351:336];
        7'b101_0110: read_mux_risc = read_risc_regs[367:352];
        7'b101_0111: read_mux_risc = read_risc_regs[383:368];
        7'b101_1000: read_mux_risc = read_risc_regs[399:384];
        7'b101_1001: read_mux_risc = read_risc_regs[415:400];
        default: read_mux_risc = {DWIDTH{WB_RD_DEFAULT}};
      endcase

  // generate wishbone write register strobes for Xgate RISC
  always @*
    begin
      write_reserv1 = 1'b0;
      write_reserv2 = 1'b0;
      write_xgmctl  = 1'b0;
      write_xgchid  = 1'b0;
      write_xgisp74 = 1'b0;
      write_xgisp30 = 1'b0;
      write_xgvbr  = 2'b00;
      write_xgif_7 = 2'b00;
      write_xgif_6 = 2'b00;
      write_xgif_5 = 2'b00;
      write_xgif_4 = 2'b00;
      write_xgif_3 = 2'b00;
      write_xgif_2 = 2'b00;
      write_xgif_1 = 2'b00;
      write_xgif_0 = 2'b00;
      write_xgswt  = 1'b0;
      write_xgsem  = 1'b0;
      write_xgccr  = 1'b0;
      write_xgpc   = 2'b00;
      write_xgr7   = 2'b00;
      write_xgr6   = 2'b00;
      write_xgr5   = 2'b00;
      write_xgr4   = 2'b00;
      write_xgr3   = 2'b00;
      write_xgr2   = 2'b00;
      write_xgr1   = 2'b00;
      if (wbs_wacc)
        case (address) // synopsys parallel_case
           // 16 bit Bus, 8 bit Granularity
           6'b00_0000 : write_xgmctl  = &wbs_sel_i;
           6'b00_0001 : write_xgchid  = wbs_sel_i[0];
           6'b00_0010 : write_xgisp74 = 1'b1;
           6'b00_0011 : write_xgisp30 = 1'b1;
           6'b00_0100 : write_xgvbr   = wbs_sel_i;
           6'b00_0101 : write_xgif_7  = wbs_sel_i;
           6'b00_0110 : write_xgif_6  = wbs_sel_i;
           6'b00_0111 : write_xgif_5  = wbs_sel_i;
           6'b00_1000 : write_xgif_4  = wbs_sel_i;
           6'b00_1001 : write_xgif_3  = wbs_sel_i;
           6'b00_1010 : write_xgif_2  = wbs_sel_i;
           6'b00_1011 : write_xgif_1  = wbs_sel_i;
           6'b00_1100 : write_xgif_0  = wbs_sel_i;
           6'b00_1101 : write_xgswt   = &wbs_sel_i;
           6'b00_1110 : write_xgsem   = &wbs_sel_i;
           6'b00_1111 : write_reserv1 = 1'b1;
           6'b01_0000 : write_xgccr   = wbs_sel_i[0];
           6'b01_0001 : write_xgpc    = wbs_sel_i;
           6'b01_0010 : write_reserv2 = 1'b1;
           6'b01_0011 : write_xgr1    = wbs_sel_i;
           6'b01_0100 : write_xgr2    = wbs_sel_i;
           6'b01_0101 : write_xgr3    = wbs_sel_i;
           6'b01_0110 : write_xgr4    = wbs_sel_i;
           6'b01_0111 : write_xgr5    = wbs_sel_i;
           6'b01_1000 : write_xgr6    = wbs_sel_i;
           6'b01_1001 : write_xgr7    = wbs_sel_i;
           default: ;
        endcase
    end

  // WISHBONE Read Data Mux for IRQ control registers
  always @*
      case ({wbs_racc, address}) // synopsys parallel_case
        // 16 bit Bus, 16 bit Granularity
        7'b110_0000: read_mux_irq = {irq_bypass[ 15:  1], 1'b0};
        7'b110_0001: read_mux_irq = irq_bypass[ 31: 16];
        7'b110_0010: read_mux_irq = irq_bypass[ 47: 32];
        7'b110_0011: read_mux_irq = irq_bypass[ 63: 48];
        7'b110_0100: read_mux_irq = irq_bypass[ 79: 64];
        7'b110_0101: read_mux_irq = irq_bypass[ 95: 80];
        7'b110_0110: read_mux_irq = irq_bypass[111: 96];
        7'b110_0111: read_mux_irq = irq_bypass[127:112];
        default: read_mux_irq = {DWIDTH{WB_RD_DEFAULT}};
      endcase

  // generate wishbone write register strobes for interrupt control
  always @*
    begin
      write_irw_en_7 = 2'b00;
      write_irw_en_6 = 2'b00;
      write_irw_en_5 = 2'b00;
      write_irw_en_4 = 2'b00;
      write_irw_en_3 = 2'b00;
      write_irw_en_2 = 2'b00;
      write_irw_en_1 = 2'b00;
      write_irw_en_0 = 2'b00;
      if (wbs_wacc)
        case (address) // synopsys parallel_case
           // 16 bit Bus, 8 bit Granularity
           6'b10_0000 : write_irw_en_0  = wbs_sel_i;
           6'b10_0001 : write_irw_en_1  = wbs_sel_i;
           6'b10_0010 : write_irw_en_2  = wbs_sel_i;
           6'b10_0011 : write_irw_en_3  = wbs_sel_i;
           6'b10_0100 : write_irw_en_4  = wbs_sel_i;
           6'b10_0101 : write_irw_en_5  = wbs_sel_i;
           6'b10_0110 : write_irw_en_6  = wbs_sel_i;
           6'b10_0111 : write_irw_en_7  = wbs_sel_i;
           default: ;
        endcase
    end

endmodule  // xgate_wbs_bus
