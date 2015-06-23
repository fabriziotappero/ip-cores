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
// *File Name: openMSP430_fpga.v
//
// *Module Description:
//                      openMSP430 FPGA Top-level for the Altera DE1 board
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//              - Vadim Akimov,      lvd.mhm@gmail.com


`include "openMSP430_defines.v"


module main
        (
                ////////////////////    Clock Input             ////////////////
                CLOCK_24,                                               //      24 MHz
                CLOCK_27,                                               //      27 MHz
                CLOCK_50,                                               //      50 MHz
                EXT_CLOCK,                                              //      External Clock
                ////////////////////    Push Button             ////////////////
                KEY,                                                    //      Pushbutton[3:0]
                ////////////////////    DPDT Switch             ////////////////
                SW,                                                     //      Toggle Switch[9:0]
                ////////////////////    7-SEG Dispaly           ////////////////
                HEX0,                                                   //      Seven Segment Digit 0
                HEX1,                                                   //      Seven Segment Digit 1
                HEX2,                                                   //      Seven Segment Digit 2
                HEX3,                                                   //      Seven Segment Digit 3
                ////////////////////    LED                     ////////////////
                LEDG,                                                   //      LED Green[7:0]
                LEDR,                                                   //      LED Red[9:0]
                ////////////////////    UART                    ////////////////
                UART_TXD,                                               //      UART Transmitter
                UART_RXD,                                               //      UART Receiver
                ////////////////////    SDRAM Interface         ////////////////
                DRAM_DQ,                                                //      SDRAM Data bus 16 Bits
                DRAM_ADDR,                                              //      SDRAM Address bus 12 Bits
                DRAM_LDQM,                                              //      SDRAM Low-byte Data Mask
                DRAM_UDQM,                                              //      SDRAM High-byte Data Mask
                DRAM_WE_N,                                              //      SDRAM Write Enable
                DRAM_CAS_N,                                             //      SDRAM Column Address Strobe
                DRAM_RAS_N,                                             //      SDRAM Row Address Strobe
                DRAM_CS_N,                                              //      SDRAM Chip Select
                DRAM_BA_0,                                              //      SDRAM Bank Address 0
                DRAM_BA_1,                                              //      SDRAM Bank Address 0
                DRAM_CLK,                                               //      SDRAM Clock
                DRAM_CKE,                                               //      SDRAM Clock Enable
                ////////////////////    Flash Interface         ////////////////
                FL_DQ,                                                  //      FLASH Data bus 8 Bits
                FL_ADDR,                                                //      FLASH Address bus 22 Bits
                FL_WE_N,                                                //      FLASH Write Enable
                FL_RST_N,                                               //      FLASH Reset
                FL_OE_N,                                                //      FLASH Output Enable
                FL_CE_N,                                                //      FLASH Chip Enable
                ////////////////////    SRAM Interface          ////////////////
                SRAM_DQ,                                                //      SRAM Data bus 16 Bits
                SRAM_ADDR,                                              //      SRAM Address bus 18 Bits
                SRAM_UB_N,                                              //      SRAM High-byte Data Mask
                SRAM_LB_N,                                              //      SRAM Low-byte Data Mask
                SRAM_WE_N,                                              //      SRAM Write Enable
                SRAM_CE_N,                                              //      SRAM Chip Enable
                SRAM_OE_N,                                              //      SRAM Output Enable
                ////////////////////    SD_Card Interface       ////////////////
                SD_DAT,                                                 //      SD Card Data
                SD_DAT3,                                                //      SD Card Data 3
                SD_CMD,                                                 //      SD Card Command Signal
                SD_CLK,                                                 //      SD Card Clock
                ////////////////////    USB JTAG link           ////////////////
                TDI,                                                    //      CPLD -> FPGA (data in)
                TCK,                                                    //      CPLD -> FPGA (clk)
                TCS,                                                    //      CPLD -> FPGA (CS)
                TDO,                                                    //      FPGA -> CPLD (data out)
                ////////////////////    I2C                     ////////////////
                I2C_SDAT,                                               //      I2C Data
                I2C_SCLK,                                               //      I2C Clock
                ////////////////////    PS2                     ////////////////
                PS2_DAT,                                                //      PS2 Data
                PS2_CLK,                                                //      PS2 Clock
                ////////////////////    VGA                     ////////////////
                VGA_HS,                                                 //      VGA H_SYNC
                VGA_VS,                                                 //      VGA V_SYNC
                VGA_R,                                                  //      VGA Red[3:0]
                VGA_G,                                                  //      VGA Green[3:0]
                VGA_B,                                                  //      VGA Blue[3:0]
                ////////////////////    Audio CODEC             ////////////////
                AUD_ADCLRCK,                                            //      Audio CODEC ADC LR Clock
                AUD_ADCDAT,                                             //      Audio CODEC ADC Data
                AUD_DACLRCK,                                            //      Audio CODEC DAC LR Clock
                AUD_DACDAT,                                             //      Audio CODEC DAC Data
                AUD_BCLK,                                               //      Audio CODEC Bit-Stream Clock
                AUD_XCK,                                                //      Audio CODEC Chip Clock
                ////////////////////    GPIO                    ////////////////
                GPIO_0,                                                 //      GPIO Connection 0
                GPIO_1                                                  //      GPIO Connection 1
        );

////////////////////////        Clock Input        /////////////
input   [1:0]   CLOCK_24;                               //      24 MHz
input   [1:0]   CLOCK_27;                               //      27 MHz
input           CLOCK_50;                               //      50 MHz
input           EXT_CLOCK;                              //      External Clock
////////////////////////        Push Button        /////////////
input   [3:0]   KEY;                                    //      Pushbutton[3:0]
////////////////////////        DPDT Switch        /////////////
input   [9:0]   SW;                                     //      Toggle Switch[9:0]
////////////////////////        7-SEG Dispaly      /////////////
output  [6:0]   HEX0;                                   //      Seven Segment Digit 0
output  [6:0]   HEX1;                                   //      Seven Segment Digit 1
output  [6:0]   HEX2;                                   //      Seven Segment Digit 2
output  [6:0]   HEX3;                                   //      Seven Segment Digit 3
////////////////////////        LED                /////////////
output  [7:0]   LEDG;                                   //      LED Green[7:0]
output  [9:0]   LEDR;                                   //      LED Red[9:0]
////////////////////////        UART               /////////////
output          UART_TXD;                               //      UART Transmitter
input           UART_RXD;                               //      UART Receiver
////////////////////////        SDRAM Interface    /////////////
inout   [15:0]  DRAM_DQ;                                //      SDRAM Data bus 16 Bits
output  [11:0]  DRAM_ADDR;                              //      SDRAM Address bus 12 Bits
output          DRAM_LDQM;                              //      SDRAM Low-byte Data Mask
output          DRAM_UDQM;                              //      SDRAM High-byte Data Mask
output          DRAM_WE_N;                              //      SDRAM Write Enable
output          DRAM_CAS_N;                             //      SDRAM Column Address Strobe
output          DRAM_RAS_N;                             //      SDRAM Row Address Strobe
output          DRAM_CS_N;                              //      SDRAM Chip Select
output          DRAM_BA_0;                              //      SDRAM Bank Address 0
output          DRAM_BA_1;                              //      SDRAM Bank Address 0
output          DRAM_CLK;                               //      SDRAM Clock
output          DRAM_CKE;                               //      SDRAM Clock Enable
////////////////////////        Flash Interface    /////////////
inout    [7:0]  FL_DQ;                                  //      FLASH Data bus 8 Bits
output  [21:0]  FL_ADDR;                                //      FLASH Address bus 22 Bits
output          FL_WE_N;                                //      FLASH Write Enable
output          FL_RST_N;                               //      FLASH Reset
output          FL_OE_N;                                //      FLASH Output Enable
output          FL_CE_N;                                //      FLASH Chip Enable
////////////////////////        SRAM Interface     /////////////
inout   [15:0]  SRAM_DQ;                                //      SRAM Data bus 16 Bits
output  [17:0]  SRAM_ADDR;                              //      SRAM Address bus 18 Bits
output          SRAM_UB_N;                              //      SRAM High-byte Data Mask
output          SRAM_LB_N;                              //      SRAM Low-byte Data Mask
output          SRAM_WE_N;                              //      SRAM Write Enable
output          SRAM_CE_N;                              //      SRAM Chip Enable
output          SRAM_OE_N;                              //      SRAM Output Enable
////////////////////////        SD Card Interface  /////////////
inout           SD_DAT;                                 //      SD Card Data
inout           SD_DAT3;                                //      SD Card Data 3
inout           SD_CMD;                                 //      SD Card Command Signal
output          SD_CLK;                                 //      SD Card Clock
////////////////////////        I2C                /////////////
inout           I2C_SDAT;                               //      I2C Data
output          I2C_SCLK;                               //      I2C Clock
////////////////////////        PS2                /////////////
input           PS2_DAT;                                //      PS2 Data
input           PS2_CLK;                                //      PS2 Clock
////////////////////////        USB JTAG link      /////////////
input           TDI;                                    //      CPLD -> FPGA (data in)
input           TCK;                                    //      CPLD -> FPGA (clk)
input           TCS;                                    //      CPLD -> FPGA (CS)
output          TDO;                                    //      FPGA -> CPLD (data out)
////////////////////////        VGA                /////////////
output          VGA_HS;                                 //      VGA H_SYNC
output          VGA_VS;                                 //      VGA V_SYNC
output  [3:0]   VGA_R;                                  //      VGA Red[3:0]
output  [3:0]   VGA_G;                                  //      VGA Green[3:0]
output  [3:0]   VGA_B;                                  //      VGA Blue[3:0]
////////////////////////        Audio CODEC        /////////////
output          AUD_ADCLRCK;                            //      Audio CODEC ADC LR Clock
input           AUD_ADCDAT;                             //      Audio CODEC ADC Data
output          AUD_DACLRCK;                            //      Audio CODEC DAC LR Clock
output          AUD_DACDAT;                             //      Audio CODEC DAC Data
inout           AUD_BCLK;                               //      Audio CODEC Bit-Stream Clock
output          AUD_XCK;                                //      Audio CODEC Chip Clock
////////////////////////        GPIO               /////////////
inout   [35:0]  GPIO_0;                                 //      GPIO Connection 0
inout   [35:0]  GPIO_1;                                 //      GPIO Connection 1
////////////////////////////////////////////////////////////////

//      All inout port turn to tri-state
assign  DRAM_DQ         =       16'hzzzz;
assign  FL_DQ                   =       8'hzz;
assign  SD_DAT          =       1'bz;
assign  I2C_SDAT                =       1'bz;
assign  GPIO_0          =       36'hzzzzzzzzz;
assign  GPIO_1          =       36'hzzzzzzzzz;

// SDRAM blocking
assign DRAM_CS_N = 1'b1;
assign DRAM_CKE  = 1'b0;
// FLASH blocking
assign FL_RST_N = 1'b1;
assign FL_CE_N  = 1'b1;
assign FL_OE_N  = 1'b1;
assign FL_WE_N  = 1'b1;





// overall clock
wire clk_sys;




//=============================================================================
// 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
//=============================================================================

// openMSP430 output buses
wire        [13:0] per_addr;
wire        [15:0] per_din;
wire         [1:0] per_we;
wire [`DMEM_MSB:0] dmem_addr;
wire        [15:0] dmem_din;
wire         [1:0] dmem_wen;
wire [`PMEM_MSB:0] pmem_addr;
wire        [15:0] pmem_din;
wire         [1:0] pmem_wen;
wire        [13:0] irq_acc;

// openMSP430 input buses
wire        [13:0] irq_bus;
wire        [15:0] per_dout;
wire        [15:0] dmem_dout;
wire        [15:0] pmem_dout;

// GPIO
wire         [7:0] p1_din;
wire         [7:0] p1_dout;
wire         [7:0] p1_dout_en;
wire         [7:0] p1_sel;
wire         [7:0] p2_din;
wire         [7:0] p2_dout;
wire         [7:0] p2_dout_en;
wire         [7:0] p2_sel;
wire         [7:0] p3_din;
wire         [7:0] p3_dout;
wire         [7:0] p3_dout_en;
wire         [7:0] p3_sel;
wire        [15:0] per_dout_dio;

// Timer A
wire        [15:0] per_dout_tA;

// 7 segment driver
wire        [15:0] per_dout_7seg;

// Others
wire               reset_pin;




assign clk_sys = CLOCK_24[0]; // no PLL for now

wire reset_pin_n = KEY[3];    // resets
assign reset_n = reset_pin_n;





//=============================================================================
// 4)  OPENMSP430
//=============================================================================

openMSP430 openMSP430_0 (

// OUTPUTs
    .aclk              (),             // ASIC ONLY: ACLK
    .aclk_en           (aclk_en),      // FPGA ONLY: ACLK enable
    .dbg_freeze        (dbg_freeze),   // Freeze peripherals
    .dbg_i2c_sda_out   (),             // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (dbg_uart_txd), // Debug interface: UART TXD
    .dco_enable        (),             // ASIC ONLY: Fast oscillator enable
    .dco_wkup          (),             // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr         (dmem_addr),    // Data Memory address
    .dmem_cen          (dmem_cen),     // Data Memory chip enable (low active)
    .dmem_din          (dmem_din),     // Data Memory data input
    .dmem_wen          (dmem_wen),     // Data Memory write enable (low active)
    .irq_acc           (irq_acc),      // Interrupt request accepted (one-hot signal)
    .lfxt_enable       (),             // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup         (),             // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk              (mclk),         // Main system clock
    .per_addr          (per_addr),     // Peripheral address
    .per_din           (per_din),      // Peripheral data input
    .per_we            (per_we),       // Peripheral write enable (high active)
    .per_en            (per_en),       // Peripheral enable (high active)
    .pmem_addr         (pmem_addr),    // Program Memory address
    .pmem_cen          (pmem_cen),     // Program Memory chip enable (low active)
    .pmem_din          (pmem_din),     // Program Memory data input (optional)
    .pmem_wen          (pmem_wen),     // Program Memory write enable (low active) (optional)
    .puc_rst           (puc_rst),      // Main system reset
    .smclk             (),             // ASIC ONLY: SMCLK
    .smclk_en          (smclk_en),     // FPGA ONLY: SMCLK enable

// INPUTs
    .cpu_en            (1'b1),         // Enable CPU code execution (asynchronous and non-glitchy)
    .dbg_en            (1'b1),         // Debug interface enable (asynchronous and non-glitchy)
    .dbg_i2c_addr      (7'h00),        // Debug interface: I2C Address
    .dbg_i2c_broadcast (7'h00),        // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (1'b1),         // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (1'b1),         // Debug interface: I2C SDA IN
    .dbg_uart_rxd      (dbg_uart_rxd), // Debug interface: UART RXD (asynchronous)
    .dco_clk           (clk_sys),      // Fast oscillator (fast clock)
    .dmem_dout         (dmem_dout),    // Data Memory data output
    .irq               (irq_bus),      // Maskable interrupts
    .lfxt_clk          (1'b0),         // Low frequency oscillator (typ 32kHz)
    .nmi               (nmi),          // Non-maskable interrupt (asynchronous)
    .per_dout          (per_dout),     // Peripheral data output
    .pmem_dout         (pmem_dout),    // Program Memory data output
    .reset_n           (reset_n),      // Reset Pin (low active, asynchronous and non-glitchy)
    .scan_enable       (1'b0),         // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode         (1'b0),         // ASIC ONLY: Scan mode
    .wkup              (1'b0)          // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
);






//=============================================================================
// 5)  OPENMSP430 PERIPHERALS
//=============================================================================

//
// Digital I/O
//-------------------------------

omsp_gpio #(.P1_EN(1),
            .P2_EN(1),
            .P3_EN(1),
            .P4_EN(0),
            .P5_EN(0),
            .P6_EN(0)) gpio_0 (

// OUTPUTs
    .irq_port1    (irq_port1),     // Port 1 interrupt
    .irq_port2    (irq_port2),     // Port 2 interrupt
    .p1_dout      (p1_dout),       // Port 1 data output
    .p1_dout_en   (p1_dout_en),    // Port 1 data output enable
    .p1_sel       (p1_sel),        // Port 1 function select
    .p2_dout      (p2_dout),       // Port 2 data output
    .p2_dout_en   (p2_dout_en),    // Port 2 data output enable
    .p2_sel       (p2_sel),        // Port 2 function select
    .p3_dout      (p3_dout),       // Port 3 data output
    .p3_dout_en   (p3_dout_en),    // Port 3 data output enable
    .p3_sel       (p3_sel),        // Port 3 function select
    .p4_dout      (),              // Port 4 data output
    .p4_dout_en   (),              // Port 4 data output enable
    .p4_sel       (),              // Port 4 function select
    .p5_dout      (),              // Port 5 data output
    .p5_dout_en   (),              // Port 5 data output enable
    .p5_sel       (),              // Port 5 function select
    .p6_dout      (),              // Port 6 data output
    .p6_dout_en   (),              // Port 6 data output enable
    .p6_sel       (),              // Port 6 function select
    .per_dout     (per_dout_dio),  // Peripheral data output

// INPUTs
    .mclk         (mclk),          // Main system clock
    .p1_din       (p1_din),        // Port 1 data input
    .p2_din       (p2_din),        // Port 2 data input
    .p3_din       (p3_din),        // Port 3 data input
    .p4_din       (8'h00),         // Port 4 data input
    .p5_din       (8'h00),         // Port 5 data input
    .p6_din       (8'h00),         // Port 6 data input
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst)        // Main system reset
);

//
// Timer A
//----------------------------------------------

omsp_timerA timerA_0 (

// OUTPUTs
    .irq_ta0      (irq_ta0),       // Timer A interrupt: TACCR0
    .irq_ta1      (irq_ta1),       // Timer A interrupt: TAIV, TACCR1, TACCR2
    .per_dout     (per_dout_tA),   // Peripheral data output
    .ta_out0      (ta_out0),       // Timer A output 0
    .ta_out0_en   (ta_out0_en),    // Timer A output 0 enable
    .ta_out1      (ta_out1),       // Timer A output 1
    .ta_out1_en   (ta_out1_en),    // Timer A output 1 enable
    .ta_out2      (ta_out2),       // Timer A output 2
    .ta_out2_en   (ta_out2_en),    // Timer A output 2 enable

// INPUTs
    .aclk_en      (aclk_en),       // ACLK enable (from CPU)
    .dbg_freeze   (dbg_freeze),    // Freeze Timer A counter
    .inclk        (inclk),         // INCLK external timer clock (SLOW)
    .irq_ta0_acc  (irq_acc[9]),    // Interrupt request TACCR0 accepted
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .ta_cci0a     (ta_cci0a),      // Timer A capture 0 input A
    .ta_cci0b     (ta_cci0b),      // Timer A capture 0 input B
    .ta_cci1a     (ta_cci1a),      // Timer A capture 1 input A
    .ta_cci1b     (1'b0),          // Timer A capture 1 input B
    .ta_cci2a     (ta_cci2a),      // Timer A capture 2 input A
    .ta_cci2b     (1'b0),          // Timer A capture 2 input B
    .taclk        (taclk)          // TACLK external timer clock (SLOW)
);


//
// Four-Digit, Seven-Segment LED Display driver
//----------------------------------------------
wire [3:0] unconnected;
driver_7segment driver_7segment_0 (

// OUTPUTs
    .per_dout     (per_dout_7seg), // Peripheral data output

        .hex0({unconnected[0], HEX0}),
        .hex1({unconnected[1], HEX1}),
        .hex2({unconnected[2], HEX2}),
        .hex3({unconnected[3], HEX3}),


// INPUTs
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst)        // Main system reset
);


//
// Combine peripheral data buses
//-------------------------------

assign per_dout = per_dout_dio  |
                  per_dout_tA   |
                  per_dout_7seg;

//
// Assign interrupts
//-------------------------------

assign nmi        =  1'b0;
assign irq_bus    = {1'b0,         // Vector 13  (0xFFFA)
                     1'b0,         // Vector 12  (0xFFF8)
                     1'b0,         // Vector 11  (0xFFF6)
                     1'b0,         // Vector 10  (0xFFF4) - Watchdog -
                     irq_ta0,      // Vector  9  (0xFFF2)
                     irq_ta1,      // Vector  8  (0xFFF0)
                     1'b0,         // Vector  7  (0xFFEE)
                     1'b0,         // Vector  6  (0xFFEC)
                     1'b0,         // Vector  5  (0xFFEA)
                     1'b0,         // Vector  4  (0xFFE8)
                     irq_port2,    // Vector  3  (0xFFE6)
                     irq_port1,    // Vector  2  (0xFFE4)
                     1'b0,         // Vector  1  (0xFFE2)
                     1'b0};        // Vector  0  (0xFFE0)

//
// GPIO Function selection
//--------------------------

// P1.0/TACLK      I/O pin / Timer_A, clock signal TACLK input
// P1.1/TA0        I/O pin / Timer_A, capture: CCI0A input, compare: Out0 output
// P1.2/TA1        I/O pin / Timer_A, capture: CCI1A input, compare: Out1 output
// P1.3/TA2        I/O pin / Timer_A, capture: CCI2A input, compare: Out2 output
// P1.4/SMCLK      I/O pin / SMCLK signal output
// P1.5/TA0        I/O pin / Timer_A, compare: Out0 output
// P1.6/TA1        I/O pin / Timer_A, compare: Out1 output
// P1.7/TA2        I/O pin / Timer_A, compare: Out2 output
wire [7:0] p1_io_mux_b_unconnected;
wire [7:0] p1_io_dout;
wire [7:0] p1_io_dout_en;
wire [7:0] p1_io_din;

io_mux #8 io_mux_p1 (
                     .a_din      (p1_din),
                     .a_dout     (p1_dout),
                     .a_dout_en  (p1_dout_en),

                     .b_din      ({p1_io_mux_b_unconnected[7],
                                   p1_io_mux_b_unconnected[6],
                                   p1_io_mux_b_unconnected[5],
                                   p1_io_mux_b_unconnected[4],
                                   ta_cci2a,
                                   ta_cci1a,
                                   ta_cci0a,
                                   taclk
                                  }),
                     .b_dout     ({ta_out2,
                                   ta_out1,
                                   ta_out0,
                                   (smclk_en & mclk),
                                   ta_out2,
                                   ta_out1,
                                   ta_out0,
                                   1'b0
                                  }),
                     .b_dout_en  ({ta_out2_en,
                                   ta_out1_en,
                                   ta_out0_en,
                                   1'b1,
                                   ta_out2_en,
                                   ta_out1_en,
                                   ta_out0_en,
                                   1'b0
                                  }),

                     .io_din     (p1_io_din),
                     .io_dout    (p1_io_dout),
                     .io_dout_en (p1_io_dout_en),

                     .sel        (p1_sel)
);



// P2.0/ACLK       I/O pin / ACLK output
// P2.1/INCLK      I/O pin / Timer_A, clock signal at INCLK
// P2.2/TA0        I/O pin / Timer_A, capture: CCI0B input
// P2.3/TA1        I/O pin / Timer_A, compare: Out1 output
// P2.4/TA2        I/O pin / Timer_A, compare: Out2 output
wire [7:0] p2_io_mux_b_unconnected;
wire [7:0] p2_io_dout;
wire [7:0] p2_io_dout_en;
wire [7:0] p2_io_din;

io_mux #8 io_mux_p2 (
                     .a_din      (p2_din),
                     .a_dout     (p2_dout),
                     .a_dout_en  (p2_dout_en),

                     .b_din      ({p2_io_mux_b_unconnected[7],
                                   p2_io_mux_b_unconnected[6],
                                   p2_io_mux_b_unconnected[5],
                                   p2_io_mux_b_unconnected[4],
                                   p2_io_mux_b_unconnected[3],
                                   ta_cci0b,
                                   inclk,
                                   p2_io_mux_b_unconnected[0]
                                  }),
                     .b_dout     ({1'b0,
                                   1'b0,
                                   1'b0,
                                   ta_out2,
                                   ta_out1,
                                   1'b0,
                                   1'b0,
                                   (aclk_en & mclk)
                                  }),
                     .b_dout_en  ({1'b0,
                                   1'b0,
                                   1'b0,
                                   ta_out2_en,
                                   ta_out1_en,
                                   1'b0,
                                   1'b0,
                                   1'b1
                                  }),

                     .io_din     (p2_io_din),
                     .io_dout    (p2_io_dout),
                     .io_dout_en (p2_io_dout_en),

                     .sel        (p2_sel)
);






//=============================================================================
// 6)  RAM / ROM
//=============================================================================

// You can use either synchronous ram16x512 module generated by MegaWizard,
// or ext_de1_sram module accessing to the on-board static asynchronous RAM

// RAM

//cyclone's M4k cells - just an example of instantiating 16-bit M4K altera RAM
ram16x512 ram (
        .address (dmem_addr[8:0]),
        .clken   (~dmem_cen),
        .clock   (clk_sys),
        .data    (dmem_din[15:0]),
        .q       (dmem_dout[15:0]),
        .wren    ( ~(&dmem_wen[1:0]) ),
        .byteena ( ~dmem_wen[1:0] )
);
/**/
/*
// DE1's onboard sram - only 512 words used
ext_de1_sram #(.ADDR_WIDTH(9)) ram (

        .clk(clk_sys),

        .ram_addr(dmem_addr[8:0]),
        .ram_cen(dmem_cen),
        .ram_wen(dmem_wen[1:0]),
        .ram_dout(dmem_dout[15:0]),
        .ram_din(dmem_din[15:0]),

        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_DQ(SRAM_DQ),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_OE_N(SRAM_OE_N),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_UB_N(SRAM_UB_N),
        .SRAM_LB_N(SRAM_LB_N)
);
*/



// ROM - DEBUG ACCESS removed. If you need it, use as example original diligent's sources
rom16x2048 rom_0 (
        .clock  (clk_sys),
        .clken  (~pmem_cen),
        .address        (pmem_addr[10:0]),
        .q              ( pmem_dout )
);





//=============================================================================
// 7)  I/O CELLS
//=============================================================================

assign p3_din[7:0] = SW[7:0];

assign LEDR[7:0] = p3_dout[7:0] & p3_dout_en[7:0];


// RS-232 Port
//----------------------
// P1.1 (TX) and P2.2 (RX)
assign p1_io_din      = 8'h00;
assign p2_io_din[7:3] = 5'h00;
assign p2_io_din[1:0] = 2'h0;

// Mux the RS-232 port between IO port and the debug interface.
// The mux is controlled with the SW0 switch
wire   uart_txd_out = p3_din[0] ? dbg_uart_txd : p1_io_dout[1];
wire   uart_rxd_in;
assign p2_io_din[2] = p3_din[0] ? 1'b1         : uart_rxd_in;
assign dbg_uart_rxd = p3_din[0] ? uart_rxd_in  : 1'b1;


assign uart_rxd_in = UART_RXD;
assign UART_TXD = uart_txd_out;





endmodule

