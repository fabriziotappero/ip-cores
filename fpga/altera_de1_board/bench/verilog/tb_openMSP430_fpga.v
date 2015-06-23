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
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
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

// Clock
reg         [1:0] CLOCK_24;
reg         [1:0] CLOCK_27;
reg               CLOCK_50;
reg               EXT_CLOCK;

// Push Button
reg         [3:0] KEY;

// DPDT Switch
reg         [9:0] SW;

// 7-SEG Dispaly
wire        [6:0] HEX0;
wire        [6:0] HEX1;
wire        [6:0] HEX2;
wire        [6:0] HEX3;

// LED
wire        [7:0] LEDG;
wire        [9:0] LEDR;

// UART
wire              UART_TXD;
reg               UART_RXD;

// SDRAM Interface
wire       [15:0] DRAM_DQ;
wire       [11:0] DRAM_ADDR;
wire              DRAM_LDQM;
wire              DRAM_UDQM;
wire              DRAM_WE_N;
wire              DRAM_CAS_N;
wire              DRAM_RAS_N;
wire              DRAM_CS_N;
wire              DRAM_BA_0;
wire              DRAM_BA_1;
wire              DRAM_CLK;
wire              DRAM_CKE;

// Flash Interface
wire        [7:0] FL_DQ;
wire       [21:0] FL_ADDR;
wire              FL_WE_N;
wire              FL_RST_N;
wire              FL_OE_N;
wire              FL_CE_N;

// SRAM Interface
wire       [15:0] SRAM_DQ;
wire       [17:0] SRAM_ADDR;
wire              SRAM_UB_N;
wire              SRAM_LB_N;
wire              SRAM_WE_N;
wire              SRAM_CE_N;
wire              SRAM_OE_N;

// SD Card Interface
wire              SD_DAT;
wire              SD_DAT3;
wire              SD_CMD;
wire              SD_CLK;

// I2C
wire              I2C_SDAT;
wire              I2C_SCLK;

// PS2
reg               PS2_DAT;
reg               PS2_CLK;

// USB JTAG link
reg               TDI;
reg               TCK;
reg               TCS;
wire              TDO;

// VGA
wire              VGA_HS;
wire              VGA_VS;
wire        [3:0] VGA_R;
wire        [3:0] VGA_G;
wire        [3:0] VGA_B;

// Audio CODEC
wire              AUD_ADCLRCK;
reg               AUD_ADCDAT;
wire              AUD_DACLRCK;
wire              AUD_DACDAT;
wire              AUD_BCLK;
wire              AUD_XCK;

// GPIO
wire       [35:0] GPIO_0;
wire       [35:0] GPIO_1;

   
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
  end

//
// Generate Clock & Reset
//------------------------------
initial
  begin
     CLOCK_24 = 2'b10;
     forever #20.8 CLOCK_24 = ~CLOCK_24; // 24 MHz
  end
initial
  begin
     CLOCK_27 = 2'b01;
     forever #18.5 CLOCK_27 = ~CLOCK_27; // 27 MHz
  end
initial
  begin
     CLOCK_50 = 1'b0;
     forever #10.0 CLOCK_50 = ~CLOCK_50; // 50 MHz
  end

initial
  begin
     KEY[3]        = 1'b1;
     #100 KEY[3]   = 1'b0;
     #600 KEY[3]   = 1'b1;
  end

//
// Global initialization
//------------------------------
initial
  begin
     error         = 0;
     stimulus_done = 1;
     EXT_CLOCK     = 1'b0;
     KEY[2:0]      = 3'b111;
     SW            = 10'h000;
     UART_RXD      = 1'b0;
     PS2_DAT       = 1'b0;
     PS2_CLK       = 1'b0;
     TDI           = 1'b0;
     TCK           = 1'b0;
     TCS           = 1'b0;
     AUD_ADCDAT    = 1'b0;
  end

//
// openMSP430 FPGA Instance
//----------------------------------

main dut (

    ////////////////////////////////    Clock Input          /////////////
    .CLOCK_24     (CLOCK_24),                                     //      24 MHz
    .CLOCK_27     (CLOCK_27),                                     //      27 MHz
    .CLOCK_50     (CLOCK_50),                                     //      50 MHz
    .EXT_CLOCK    (EXT_CLOCK),                                    //      External Clock
    ////////////////////////////////    Push Button          /////////////
    .KEY          (KEY),                                          //      Pushbutton[3:0]
    ////////////////////////////////    DPDT Switch          /////////////
    .SW           (SW),                                           //      Toggle Switch[9:0]
    ////////////////////////////////    7-SEG Dispaly        /////////////
    .HEX0         (HEX0),                                         //      Seven Segment Digit 0
    .HEX1         (HEX1),                                         //      Seven Segment Digit 1
    .HEX2         (HEX2),                                         //      Seven Segment Digit 2
    .HEX3         (HEX3),                                         //      Seven Segment Digit 3
    ////////////////////////////////    LED                  /////////////
    .LEDG         (LEDG),                                         //      LED Green[7:0]
    .LEDR         (LEDR),                                         //      LED Red[9:0]
    ////////////////////////////////    UART                 /////////////
    .UART_TXD     (UART_TXD),                                     //      UART Transmitter
    .UART_RXD     (UART_RXD),                                     //      UART Receiver
    ////////////////////////////////    SDRAM Interface      /////////////
    .DRAM_DQ      (DRAM_DQ),                                      //      SDRAM Data bus 16 Bits
    .DRAM_ADDR    (DRAM_ADDR),                                    //      SDRAM Address bus 12 Bits
    .DRAM_LDQM    (DRAM_LDQM),                                    //      SDRAM Low-byte Data Mask
    .DRAM_UDQM    (DRAM_UDQM),                                    //      SDRAM High-byte Data Mask
    .DRAM_WE_N    (DRAM_WE_N),                                    //      SDRAM Write Enable
    .DRAM_CAS_N   (DRAM_CAS_N),                                   //      SDRAM Column Address Strobe
    .DRAM_RAS_N   (DRAM_RAS_N),                                   //      SDRAM Row Address Strobe
    .DRAM_CS_N    (DRAM_CS_N),                                    //      SDRAM Chip Select
    .DRAM_BA_0    (DRAM_BA_0),                                    //      SDRAM Bank Address 0
    .DRAM_BA_1    (DRAM_BA_1),                                    //      SDRAM Bank Address 0
    .DRAM_CLK     (DRAM_CLK),                                     //      SDRAM Clock
    .DRAM_CKE     (DRAM_CKE),                                     //      SDRAM Clock Enable
    ////////////////////////////////    Flash Interface      /////////////
    .FL_DQ        (FL_DQ),                                        //      FLASH Data bus 8 Bits
    .FL_ADDR      (FL_ADDR),                                      //      FLASH Address bus 22 Bits
    .FL_WE_N      (FL_WE_N),                                      //      FLASH Write Enable
    .FL_RST_N     (FL_RST_N),                                     //      FLASH Reset
    .FL_OE_N      (FL_OE_N),                                      //      FLASH Output Enable
    .FL_CE_N      (FL_CE_N),                                      //      FLASH Chip Enable
    ////////////////////////////////    SRAM Interface       /////////////
    .SRAM_DQ      (SRAM_DQ),                                      //      SRAM Data bus 16 Bits
    .SRAM_ADDR    (SRAM_ADDR),                                    //      SRAM Address bus 18 Bits
    .SRAM_UB_N    (SRAM_UB_N),                                    //      SRAM High-byte Data Mask
    .SRAM_LB_N    (SRAM_LB_N),                                    //      SRAM Low-byte Data Mask
    .SRAM_WE_N    (SRAM_WE_N),                                    //      SRAM Write Enable
    .SRAM_CE_N    (SRAM_CE_N),                                    //      SRAM Chip Enable
    .SRAM_OE_N    (SRAM_OE_N),                                    //      SRAM Output Enable
    ////////////////////////////////    SD_Card Interface    /////////////
    .SD_DAT       (SD_DAT),                                       //      SD Card Data
    .SD_DAT3      (SD_DAT3),                                      //      SD Card Data 3
    .SD_CMD       (SD_CMD),                                       //      SD Card Command Signal
    .SD_CLK       (SD_CLK),                                       //      SD Card Clock
    ///////////////////////////////    USB JTAG link        /////////////
    .TDI          (TDI),                                          //      CPLD -> FPGA (data in)
    .TCK          (TCK),                                          //      CPLD -> FPGA (clk)
    .TCS          (TCS),                                          //      CPLD -> FPGA (CS)
    .TDO          (TDO),                                          //      FPGA -> CPLD (data out)
    ////////////////////////////////    I2C                  /////////////
    .I2C_SDAT     (I2C_SDAT),                                     //      I2C Data
    .I2C_SCLK     (I2C_SCLK),                                     //      I2C Clock
    ////////////////////////////////    PS2                  /////////////
    .PS2_DAT      (PS2_DAT),                                      //      PS2 Data
    .PS2_CLK      (PS2_CLK),                                      //      PS2 Clock
    ////////////////////////////////    VGA                  /////////////
    .VGA_HS       (VGA_HS),                                       //      VGA H_SYNC
    .VGA_VS       (VGA_VS),                                       //      VGA V_SYNC
    .VGA_R        (VGA_R),                                        //      VGA Red[3:0]
    .VGA_G        (VGA_G),                                        //      VGA Green[3:0]
    .VGA_B        (VGA_B),                                        //      VGA Blue[3:0]
    ////////////////////////////////    Audio CODEC          /////////////
    .AUD_ADCLRCK  (AUD_ADCLRCK),                                  //      Audio CODEC ADC LR Clock
    .AUD_ADCDAT   (AUD_ADCDAT),                                   //      Audio CODEC ADC Data
    .AUD_DACLRCK  (AUD_DACLRCK),                                  //      Audio CODEC DAC LR Clock
    .AUD_DACDAT   (AUD_DACDA),                                    //      Audio CODEC DAC Data
    .AUD_BCLK     (AUD_BCLK),                                     //      Audio CODEC Bit-Stream Clock
    .AUD_XCK      (AUD_XCK),                                      //      Audio CODEC Chip Clock
    ////////////////////////////////    GPIO                 /////////////
    .GPIO_0       (GPIO_0),                                       //      GPIO Connection 0
    .GPIO_1       (GPIO_1)                                        //      GPIO Connection 1
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
     #1000000;
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
