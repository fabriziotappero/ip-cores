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
// $Rev: 153 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-08-22 00:27:18 +0200 (Wed, 22 Aug 2012) $
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
reg               CLK_50MHz;
reg               RESET;

// Slide Switches
reg               SW7;
reg               SW6;
reg               SW5;
reg               SW4;
reg               SW3;
reg               SW2;
reg               SW1;
reg               SW0;

// Push Button Switches
reg               BTN2;
reg               BTN1;
reg               BTN0;

// LEDs
wire              LED7;
wire              LED6;
wire              LED5;
wire              LED4;
wire              LED3;
wire              LED2;
wire              LED1;
wire              LED0;

// Four-Sigit, Seven-Segment LED Display
wire              SEG_A;
wire              SEG_B;
wire              SEG_C;
wire              SEG_D;
wire              SEG_E;
wire              SEG_F;
wire              SEG_G;
wire              SEG_DP;
wire              SEG_AN0;
wire              SEG_AN1;
wire              SEG_AN2;
wire              SEG_AN3;

// UART
reg               UART_RXD;
wire              UART_TXD;

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


//
// Include files
//------------------------------

// CPU & Memory registers
`include "registers.v"

// Verilog stimulus
`include "stimulus.v"

//
// Initialize Program Memory
//------------------------------

initial
   begin
      // Read memory file
      #10 $readmemh("./pmem.mem", pmem);

      // Update Xilinx memory banks
      for (i=0; i<2048; i=i+1)
	begin
	   dut.rom_8x2k_hi_0.inst.mem[i] = pmem[i][15:8];
	   dut.rom_8x2k_lo_0.inst.mem[i] = pmem[i][7:0];
	end
  end

//
// Generate Clock & Reset
//------------------------------
initial
  begin
     CLK_50MHz = 1'b0;
     forever #10 CLK_50MHz <= ~CLK_50MHz; // 50 MHz
  end

initial
  begin
     RESET         = 1'b0;
     #100 RESET    = 1'b1;
     #600 RESET    = 1'b0;
  end

//
// Global initialization
//------------------------------
initial
  begin
     error         = 0;
     stimulus_done = 1;
     SW7           = 1'b0;  // Slide Switches
     SW6           = 1'b0;
     SW5           = 1'b0;
     SW4           = 1'b0;
     SW3           = 1'b0;
     SW2           = 1'b0;
     SW1           = 1'b0;
     SW0           = 1'b0;
     BTN2          = 1'b0;  // Push Button Switches
     BTN1          = 1'b0;
     BTN0          = 1'b0;
     UART_RXD      = 1'b0;  // UART
  end

//
// openMSP430 FPGA Instance
//----------------------------------

openMSP430_fpga dut (

// Clock Sources
    .CLK_50MHz    (CLK_50MHz),
    .CLK_SOCKET   (1'b0),

// Slide Switches
    .SW7          (SW7),
    .SW6          (SW6),
    .SW5          (SW5),
    .SW4          (SW4),
    .SW3          (SW3),
    .SW2          (SW2),
    .SW1          (SW1),
    .SW0          (SW0),

// Push Button Switches
    .BTN3         (RESET),
    .BTN2         (BTN2),
    .BTN1         (BTN1),
    .BTN0         (BTN0),

// LEDs
    .LED7         (LED7),
    .LED6         (LED6),
    .LED5         (LED5),
    .LED4         (LED4),
    .LED3         (LED3),
    .LED2         (LED2),
    .LED1         (LED1),
    .LED0         (LED0),

// Four-Sigit, Seven-Segment LED Display
    .SEG_A        (SEG_A),
    .SEG_B        (SEG_B),
    .SEG_C        (SEG_C),
    .SEG_D        (SEG_D),
    .SEG_E        (SEG_E),
    .SEG_F        (SEG_F),
    .SEG_G        (SEG_G),
    .SEG_DP       (SEG_DP),
    .SEG_AN0      (SEG_AN0),
    .SEG_AN1      (SEG_AN1),
    .SEG_AN2      (SEG_AN2),
    .SEG_AN3      (SEG_AN3),

// RS-232 Port
    .UART_RXD     (UART_RXD),
    .UART_TXD     (UART_TXD),
    .UART_RXD_A   (1'b0),
    .UART_TXD_A   (UART_TXD_A),

// PS/2 Mouse/Keyboard Port
    .PS2_D        (PS2_D),
    .PS2_C        (PS2_C),

// Fast, Asynchronous SRAM
    .SRAM_A17     (SRAM_A17),	  // Address Bus Connections
    .SRAM_A16     (SRAM_A16),
    .SRAM_A15     (SRAM_A15),
    .SRAM_A14     (SRAM_A14),
    .SRAM_A13     (SRAM_A13),
    .SRAM_A12     (SRAM_A12),
    .SRAM_A11     (SRAM_A11),
    .SRAM_A10     (SRAM_A10),
    .SRAM_A9      (SRAM_A9),
    .SRAM_A8      (SRAM_A8),
    .SRAM_A7      (SRAM_A7),
    .SRAM_A6      (SRAM_A6),
    .SRAM_A5      (SRAM_A5),
    .SRAM_A4      (SRAM_A4),
    .SRAM_A3      (SRAM_A3),
    .SRAM_A2      (SRAM_A2),
    .SRAM_A1      (SRAM_A1),
    .SRAM_A0      (SRAM_A0),
    .SRAM_OE      (SRAM_OE),       // Write enable and output enable control signals
    .SRAM_WE      (SRAM_WE),
    .SRAM0_IO15   (SRAM0_IO15),    // SRAM Data signals, chip enables, and byte enables
    .SRAM0_IO14   (SRAM0_IO14),
    .SRAM0_IO13   (SRAM0_IO13),
    .SRAM0_IO12   (SRAM0_IO12),
    .SRAM0_IO11   (SRAM0_IO11),
    .SRAM0_IO10   (SRAM0_IO10),
    .SRAM0_IO9    (SRAM0_IO9),
    .SRAM0_IO8    (SRAM0_IO8),
    .SRAM0_IO7    (SRAM0_IO7),
    .SRAM0_IO6    (SRAM0_IO6),
    .SRAM0_IO5    (SRAM0_IO5),
    .SRAM0_IO4    (SRAM0_IO4),
    .SRAM0_IO3    (SRAM0_IO3),
    .SRAM0_IO2    (SRAM0_IO2),
    .SRAM0_IO1    (SRAM0_IO1),
    .SRAM0_IO0    (SRAM0_IO0),
    .SRAM0_CE1    (SRAM0_CE1),
    .SRAM0_UB1    (SRAM0_UB1),
    .SRAM0_LB1    (SRAM0_LB1),
    .SRAM1_IO15   (SRAM1_IO15),
    .SRAM1_IO14   (SRAM1_IO14),
    .SRAM1_IO13   (SRAM1_IO13),
    .SRAM1_IO12   (SRAM1_IO12),
    .SRAM1_IO11   (SRAM1_IO11),
    .SRAM1_IO10   (SRAM1_IO10),
    .SRAM1_IO9    (SRAM1_IO9),
    .SRAM1_IO8    (SRAM1_IO8),
    .SRAM1_IO7    (SRAM1_IO7),
    .SRAM1_IO6    (SRAM1_IO6),
    .SRAM1_IO5    (SRAM1_IO5),
    .SRAM1_IO4    (SRAM1_IO4),
    .SRAM1_IO3    (SRAM1_IO3),
    .SRAM1_IO2    (SRAM1_IO2),
    .SRAM1_IO1    (SRAM1_IO1),
    .SRAM1_IO0    (SRAM1_IO0),
    .SRAM1_CE2    (SRAM1_CE2),
    .SRAM1_UB2    (SRAM1_UB2),
    .SRAM1_LB2    (SRAM1_LB2),

// VGA Port
    .VGA_R        (VGA_R),
    .VGA_G        (VGA_G),
    .VGA_B        (VGA_B),
    .VGA_HS       (VGA_HS),
    .VGA_VS       (VGA_VS)
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
   `ifdef NO_TIMEOUT
   `else
     `ifdef VERY_LONG_TIMEOUT
       #500000000;
     `else     
     `ifdef LONG_TIMEOUT
       #5000000;
     `else     
       #500000;
     `endif
     `endif
       $display(" ===============================================");
       $display("|               SIMULATION FAILED               |");
       $display("|              (simulation Timeout)             |");
       $display(" ===============================================");
       $finish;
   `endif
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
