//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: tb_openMSP430_fpga.v
// 
// *Module Description:
//                      openMSP430 FPGA testbench
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 37 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-12-29 21:58:14 +0100 (Tue, 29 Dec 2009) $
//----------------------------------------------------------------------------
`include "timescale.v"
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module  tb_openMSP430_fpga;

//
// Wire & Register definition
//------------------------------

// Clock & Reset
reg               oscclk;
reg               porst_n;
reg               pbrst_n;

// Slide Switches
reg         [9:0] switch;

// LEDs
wire        [9:0] led;

// UART
wire              dbg_uart_rxd;
wire              dbg_uart_txd;
reg               dbg_uart_rxd_sel;
reg               dbg_uart_rxd_dly;
reg               dbg_uart_rxd_pre;
reg               dbg_uart_rxd_meta;
reg        [15:0] dbg_uart_buf;
reg               dbg_uart_rx_busy;
reg               dbg_uart_tx_busy;

// Core debug signals
wire   [8*32-1:0] i_state;
wire   [8*32-1:0] e_state;
wire       [31:0] inst_cycle;
wire   [8*32-1:0] inst_full;
wire       [31:0] inst_number;
wire       [15:0] inst_pc;
wire   [8*32-1:0] inst_short;

// Testbench variables
integer           i;
integer           error;
reg               stimulus_done;
wire       [11:0] vout_x;
wire       [11:0] vout_y;

//
// Include files
//------------------------------

// CPU & Memory registers
`include "registers.v"

// Debug interface tasks
`include "dbg_uart_tasks.v"

// Verilog stimulus
`include "stimulus.v"

//
// Initialize Program Memory
//------------------------------

initial
   begin
      // Read memory file
      #10 $readmemh("./pmem.mem", pmem);

      // Update Actel memory banks
      for (i=0; i<512; i=i+1)
	begin
	   dut.dmem_hi.dmem_128B_R0C0.MEM_512_9[i] = {1'b0, 8'h00};
	   dut.dmem_lo.dmem_128B_R0C0.MEM_512_9[i] = {1'b0, 8'h00};

	   dut.pmem_hi.pmem_2kB_R0C0.MEM_512_9[i] = {1'b0, pmem[i*4+3][9:8],   pmem[i*4+2][9:8],   pmem[i*4+1][9:8],   pmem[i*4+0][9:8]};
	   dut.pmem_hi.pmem_2kB_R0C1.MEM_512_9[i] = {1'b0, pmem[i*4+3][11:10], pmem[i*4+2][11:10], pmem[i*4+1][11:10], pmem[i*4+0][11:10]};
	   dut.pmem_hi.pmem_2kB_R0C2.MEM_512_9[i] = {1'b0, pmem[i*4+3][13:12], pmem[i*4+2][13:12], pmem[i*4+1][13:12], pmem[i*4+0][13:12]};
	   dut.pmem_hi.pmem_2kB_R0C3.MEM_512_9[i] = {1'b0, pmem[i*4+3][15:14], pmem[i*4+2][15:14], pmem[i*4+1][15:14], pmem[i*4+0][15:14]};

	   dut.pmem_lo.pmem_2kB_R0C0.MEM_512_9[i] = {1'b0, pmem[i*4+3][1:0],   pmem[i*4+2][1:0],   pmem[i*4+1][1:0],   pmem[i*4+0][1:0]};
	   dut.pmem_lo.pmem_2kB_R0C1.MEM_512_9[i] = {1'b0, pmem[i*4+3][3:2],   pmem[i*4+2][3:2],   pmem[i*4+1][3:2],   pmem[i*4+0][3:2]};
	   dut.pmem_lo.pmem_2kB_R0C2.MEM_512_9[i] = {1'b0, pmem[i*4+3][5:4],   pmem[i*4+2][5:4],   pmem[i*4+1][5:4],   pmem[i*4+0][5:4]};
	   dut.pmem_lo.pmem_2kB_R0C3.MEM_512_9[i] = {1'b0, pmem[i*4+3][7:6],   pmem[i*4+2][7:6],   pmem[i*4+1][7:6],   pmem[i*4+0][7:6]};
	end
  end

//
// Generate Clock & Reset
//------------------------------
initial
  begin
     oscclk = 1'b0;
     forever #10.4 oscclk <= ~oscclk; // 48 MHz
  end

initial
  begin
     porst_n       = 1'b1;
     pbrst_n       = 1'b1;
     #100;
     porst_n       = 1'b0;
     pbrst_n       = 1'b0;
     #600;
     porst_n       = 1'b1;
     pbrst_n       = 1'b1;
  end

//
// Global initialization
//------------------------------
initial
  begin
     error            = 0;
     stimulus_done    = 1;
     switch           = 10'h000;
     dbg_uart_rxd_sel = 1'b0;
     dbg_uart_rxd_dly = 1'b1;
     dbg_uart_rxd_pre = 1'b1;
     dbg_uart_rxd_meta= 1'b0;
     dbg_uart_rx_busy = 1'b0;
     dbg_uart_tx_busy = 1'b0;
  end

//
// openMSP430 FPGA Instance
//----------------------------------

openMSP430_fpga dut (

// OUTPUTs
    .din_x        (din_x),          // SPI Serial Data
    .din_y        (din_y),          // SPI Serial Data
    .led          (led),            // Board LEDs
    .sclk_x       (sclk_x),         // SPI Serial Clock
    .sclk_y       (sclk_y),         // SPI Serial Clock
    .sync_n_x     (sync_n_x),       // SPI Frame synchronization signal (low active)
    .sync_n_y     (sync_n_y),       // SPI Frame synchronization signal (low active)
    .uart_tx      (dbg_uart_txd),   // Board UART TX pin

// INPUTs
    .oscclk       (oscclk),         // Board Oscillator (?? MHz)
    .porst_n      (porst_n),        // Board Power-On reset (active low)
    .pbrst_n      (pbrst_n),        // Board Push-Button reset (active low)
    .uart_rx      (dbg_uart_rxd),   // Board UART RX pin
    .switch       (switch)          // Board Switches
);

   
//
// 12 BIT DACs
//----------------------------------------

DAC121S101 DAC121S101_x (
 
// OUTPUTs
    .vout         (vout_x),        // Peripheral data output
 
// INPUTs
    .din          (din_x),         // SPI Serial Data
    .sclk         (sclk_x),        // SPI Serial Clock
    .sync_n       (sync_n_x)       // SPI Frame synchronization signal (low active)
);

DAC121S101 DAC121S101_y (
 
// OUTPUTs
    .vout         (vout_y),        // Peripheral data output
 
// INPUTs
    .din          (din_y),         // SPI Serial Data
    .sclk         (sclk_y),        // SPI Serial Clock
    .sync_n       (sync_n_y)       // SPI Frame synchronization signal (low active)
);

   
//
// Debug utility signals
//----------------------------------------
msp_debug msp_debug_0 (

// OUTPUTs
    .e_state      (e_state),       // Execution state
    .i_state      (i_state),       // Instruction fetch state
    .inst_cycle   (inst_cycle),    // Cycle number within current instruction
    .inst_full    (inst_full),     // Currently executed instruction (full version)
    .inst_number  (inst_number),   // Instruction number since last system reset
    .inst_pc      (inst_pc),       // Instruction Program counter
    .inst_short   (inst_short),    // Currently executed instruction (short version)

// INPUTs
    .mclk         (mclk),          // Main system clock
    .puc_rst      (puc_rst)        // Main system reset
);

//
// Generate Waveform
//----------------------------------------
initial
  begin
   `ifdef VPD_FILE
     $vcdplusfile("tb_openMSP430_fpga.vpd");
     $vcdpluson();
   `else
     `ifdef TRN_FILE
        $recordfile ("tb_openMSP430_fpga.trn");
        $recordvars;
     `else
        $dumpfile("tb_openMSP430_fpga.vcd");
        $dumpvars(0, tb_openMSP430_fpga);
     `endif
   `endif
  end

//
// End of simulation
//----------------------------------------

initial // Timeout
  begin
     #500000;
     $display(" ===============================================");
     $display("|               SIMULATION FAILED               |");
     $display("|              (simulation Timeout)             |");
     $display(" ===============================================");
     $finish;
  end

initial // Normal end of test
  begin
     @(inst_pc===16'hffff)
     $display(" ===============================================");
     if (error!=0)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (some verilog stimulus checks failed)     |");
       end
     else if (~stimulus_done)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (the verilog stimulus didn't complete)    |");
       end
     else 
       begin
	  $display("|               SIMULATION PASSED               |");
       end
     $display(" ===============================================");
     $finish;
  end


//
// Tasks Definition
//------------------------------

   task tb_error;
      input [65*8:0] error_string;
      begin
	 $display("ERROR: %s %t", error_string, $time);
	 error = error+1;
      end
   endtask


endmodule
