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
//                      openMSP430 FPGA Top-level
//                      (targeting an Actel ProASIC3L).
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 37 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-12-29 21:58:14 +0100 (Tue, 29 Dec 2009) $
//----------------------------------------------------------------------------
`include "openMSP430_defines.v"
  
module openMSP430_fpga (

// OUTPUTs
    din_x,                        // SPI Serial Data
    din_y,                        // SPI Serial Data
    led,                          // Board LEDs
    sclk_x,                       // SPI Serial Clock
    sclk_y,                       // SPI Serial Clock
    sync_n_x,                     // SPI Frame synchronization signal (low active)
    sync_n_y,                     // SPI Frame synchronization signal (low active)
    uart_tx,                      // Board UART TX pin

// INPUTs
    oscclk,                       // Board Oscillator (?? MHz)
    porst_n,                      // Board Power-On reset (active low)
    pbrst_n,                      // Board Push-Button reset (active low)
    uart_rx,                      // Board UART RX pin
    switch                        // Board Switches
);

// OUTPUTs
//=========
output              din_x;        // SPI Serial Data
output              din_y;        // SPI Serial Data
output        [9:0] led;          // Board LEDs
output              sclk_x;       // SPI Serial Clock
output              sclk_y;       // SPI Serial Clock
output              sync_n_x;     // SPI Frame synchronization signal (low active)
output              sync_n_y;     // SPI Frame synchronization signal (low active)
output              uart_tx;      // Board UART TX pin

// INPUTs
//=========
input               oscclk;       // Board Oscillator (?? MHz)
input               porst_n;      // Board Power-On reset (active low)
input               pbrst_n;      // Board Push-Button reset (active low)
input               uart_rx;      // Board UART RX pin
input  	      [9:0] switch;       // Board Switches


//=============================================================================
// 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
//=============================================================================

wire  [`DMEM_MSB:0] dmem_addr;
wire                dmem_cen;
wire         [15:0] dmem_din;
wire          [1:0] dmem_wen;
wire         [15:0] dmem_dout;

wire  [`PMEM_MSB:0] pmem_addr;
wire                pmem_cen;
wire         [15:0] pmem_din;
wire          [1:0] pmem_wen;
wire         [15:0] pmem_dout;

wire         [13:0] per_addr;
wire         [15:0] per_din;
wire                per_en;
wire          [1:0] per_we;
wire         [15:0] per_dout;

wire         [13:0] irq_acc;
wire   	     [13:0] irq_bus;
wire                lfxt_clk;
wire 	            nmi;
wire                reset_n;

wire                dco_clk;
wire                mclk;
wire                puc_rst;

wire          [7:0] p1_din;
wire          [7:0] p1_dout;
wire          [7:0] p1_dout_en;
wire          [7:0] p1_sel;
wire         [15:0] per_dout_dio;

wire         [15:0] per_dout_tA;

wire          [3:0] cntrl1;
wire          [3:0] cntrl2;
wire         [15:0] per_dout_dac_x;
wire         [15:0] per_dout_dac_y;

  
//=============================================================================
// 2)  PLL & CLOCK GENERATION
//=============================================================================

// Input clock buffer
PLLINT clk_in0 (.A(oscclk), .Y(oscclk_buf));


parameter  FCLKA  = 48.0;
parameter  M      = 7'd6;
parameter  N      = 7'd9;
parameter  U      = 5'd2;
parameter  V      = 5'd1;
parameter  W      = 5'd1;

parameter  FVCO   = FCLKA*M/N;  //  32 MHz
parameter  FGLA   = FVCO/U;     //  16 MHz
parameter  FGLB   = FVCO/V;     //  32 MHz
parameter  FGLC   = FVCO/W;     //  32 MHz

wire [4:0] oadiv  = U-5'h01;
wire [4:0] obdiv  = V-5'h01;
wire [4:0] ocdiv  = W-5'h01;
wire [6:0] findiv = N-7'h01;
wire [6:0] fbdiv  = M-7'h01;
   
PLL #(.VCOFREQUENCY(FVCO))  pll_0 (

// PLL Inputs
    .CLKA         (oscclk_buf),   // Reference Clock Input
    .EXTFB        (1'b0),         // External Feedback
    .POWERDOWN    (1'b1),         // Power-Down (active low)

// PLL Outputs
    .GLA          (dco_clk),      // Primary output
    .LOCK         (lock),         // PLL Lock Indicator
    .GLB          (glb),          // Secondary 1 output
    .YB           (yb),           // Core 1 output
    .GLC          (glc),          // Secondary 2 output
    .YC           (yc),           // Core 2 output

// GLA Configuration
    .OADIV0       (oadiv[0]),     // Primary output divider (divider is oadiv+1)
    .OADIV1       (oadiv[1]),
    .OADIV2       (oadiv[2]),
    .OADIV3       (oadiv[3]),
    .OADIV4       (oadiv[4]),

    .OAMUX0       (1'b0),         // Primary output select (selects from the VCO's four phases)
    .OAMUX1       (1'b0),
    .OAMUX2       (1'b1),

    .DLYGLA0      (1'b0),         // Primary output delay
    .DLYGLA1      (1'b0),
    .DLYGLA2      (1'b0),
    .DLYGLA3      (1'b0),
    .DLYGLA4      (1'b0),

// GLB/YB configuration
    .OBDIV0       (obdiv[0]),     // Secondary 1 output divider (divider is obdiv+1)
    .OBDIV1       (obdiv[1]),
    .OBDIV2       (obdiv[2]),
    .OBDIV3       (obdiv[3]),
    .OBDIV4       (obdiv[4]),

    .OBMUX0       (1'b1),         // Secondary 1 output select (selects from the VCO's four phases)
    .OBMUX1       (1'b0),
    .OBMUX2       (1'b1),

    .DLYYB0       (1'b0),         // Secondary 1 YB output delay
    .DLYYB1       (1'b0),
    .DLYYB2       (1'b0),
    .DLYYB3       (1'b0),
    .DLYYB4       (1'b0),

    .DLYGLB0      (1'b0),         // Secondary 1 GLB output delay
    .DLYGLB1      (1'b0),
    .DLYGLB2      (1'b0),
    .DLYGLB3      (1'b0),
    .DLYGLB4      (1'b0),

// GLC/YC configuration
    .OCDIV0       (ocdiv[0]),     // Secondary 2 output divider (divider is ocdiv+1)
    .OCDIV1       (ocdiv[1]),
    .OCDIV2       (ocdiv[2]),
    .OCDIV3       (ocdiv[3]),
    .OCDIV4       (ocdiv[4]),

    .OCMUX0       (1'b0),         // Secondary 2 output select (selects from the VCO's four phases)
    .OCMUX1       (1'b0),
    .OCMUX2       (1'b1),

    .DLYYC0       (1'b0),         // Secondary 2 YC output delay
    .DLYYC1       (1'b0),
    .DLYYC2       (1'b0),
    .DLYYC3       (1'b0),
    .DLYYC4       (1'b0),

    .DLYGLC0      (1'b0),         // Secondary 2 GLC output delay
    .DLYGLC1      (1'b0),
    .DLYGLC2      (1'b0),
    .DLYGLC3      (1'b0),
    .DLYGLC4      (1'b0),

// PLL Core configuration
    .FINDIV0      (findiv[0]),    // Input clock divider (divider is findiv+1)
    .FINDIV1      (findiv[1]),
    .FINDIV2      (findiv[2]),
    .FINDIV3      (findiv[3]),
    .FINDIV4      (findiv[4]),
    .FINDIV5      (findiv[5]),
    .FINDIV6      (findiv[6]),

    .FBDIV0       (fbdiv[0]),     // Feedback clock divider (divider is fbdiv+1)
    .FBDIV1       (fbdiv[1]),
    .FBDIV2       (fbdiv[2]),
    .FBDIV3       (fbdiv[3]),
    .FBDIV4       (fbdiv[4]),
    .FBDIV5       (fbdiv[5]),
    .FBDIV6       (fbdiv[6]),

    .FBDLY0       (1'b0),         // Feedback Delay
    .FBDLY1       (1'b0),
    .FBDLY2       (1'b0),
    .FBDLY3       (1'b0),
    .FBDLY4       (1'b0),

    .FBSEL0       (1'b1),         // Primary feedback delay select (0:no dly; 1:prog dly element; 2:external feedback)
    .FBSEL1       (1'b0),

    .XDLYSEL      (1'b0),         // System Delay Select (0: no dly; 1:inserts system dly)

    .VCOSEL0      (1'b1),         // PLL lock acquisition time (0: Fast with high tracking jitter; 1: Slow with low tracking jitter)

    .VCOSEL1      (1'b1),         // VCO gear control (see table below)
    .VCOSEL2      (1'b0)
);

//-------------+--------------------------------------------------------------+
//             |                           VCOSEL[2:1]                        |
//             |---------------+---------------+--------------+---------------|
//             |       00      |       01      |       10     |       11      |
//  VOLTAGE    |---------------+---------------+--------------+---------------|
//             |   Min.  Max.  |   Min.  Max.  |   Min.  Max. |   Min.  Max.  |
//             |  (MHz) (MHz)  |  (MHz) (MHz)  |  (MHz) (MHz) |  (MHz) (MHz)  |
//-------------+---------------+---------------+--------------+---------------|
// IGLOO and IGLOO PLUS                                                       |
//-------------+---------------+---------------+--------------+---------------|
// 1.2 V +- 5% |   24    35    |   30     70   |   60    140  |   135   160   |
// 1.5 V +- 5% |   24    43.75 |   30     87.5 |   60    175  |   135   250   |
//-------------+---------------+---------------+--------------+---------------|
// ProASIC3L, RT ProASIC3, and Military ProASIC3/L                            |
//-------------+---------------+---------------+--------------+---------------|
// 1.2 V +- 5% |   24    35    |    30    70   |   60    140  |   135   250   |
// 1.5 V +- 5% |   24    43.75 |    30    70   |   60    175  |   135   350   |
//-------------+---------------+---------------+--------------+---------------|
// ProASIC3 and Fusion                                                        |
//-------------+---------------+---------------+--------------+---------------|
// 1.5 V +- 5% |   24    43.75 |    33.75 87.5 |  67.5   175  |   135   350   |
//-------------+---------------+---------------+--------------+---------------+

   
//=============================================================================
// 3)  PROGRAM AND DATA MEMORIES
//=============================================================================

dmem_128B dmem_hi (.WD(dmem_din[15:8]), .RD(dmem_dout[15:8]), .WEN(dmem_wen[1] | dmem_cen), .REN(~dmem_wen[1] | dmem_cen), .WADDR(dmem_addr) , .RADDR(dmem_addr), .RWCLK(mclk), .RESET(~puc_rst));
dmem_128B dmem_lo (.WD(dmem_din[7:0]),  .RD(dmem_dout[7:0]),  .WEN(dmem_wen[0] | dmem_cen), .REN(~dmem_wen[0] | dmem_cen), .WADDR(dmem_addr) , .RADDR(dmem_addr), .RWCLK(mclk), .RESET(~puc_rst));

pmem_2kB  pmem_hi (.WD(pmem_din[15:8]), .RD(pmem_dout[15:8]), .WEN(pmem_wen[1] | pmem_cen), .REN(~pmem_wen[1] | pmem_cen), .WADDR(pmem_addr) , .RADDR(pmem_addr), .RWCLK(mclk), .RESET(~puc_rst));
pmem_2kB  pmem_lo (.WD(pmem_din[7:0]),  .RD(pmem_dout[7:0]),  .WEN(pmem_wen[0] | pmem_cen), .REN(~pmem_wen[0] | pmem_cen), .WADDR(pmem_addr) , .RADDR(pmem_addr), .RWCLK(mclk), .RESET(~puc_rst));

  
//=============================================================================
// 4)  OPENMSP430
//=============================================================================

openMSP430 openMSP430_0 (

// OUTPUTs
    .aclk              (),             // ASIC ONLY: ACLK
    .aclk_en           (aclk_en),      // FPGA ONLY: ACLK enable
    .dbg_freeze        (dbg_freeze),   // Freeze peripherals
    .dbg_i2c_sda_out   (),             // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (uart_tx),      // Debug interface: UART TXD
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
    .dbg_uart_rxd      (uart_rx),      // Debug interface: UART RXD (asynchronous)
    .dco_clk           (dco_clk),      // Fast oscillator (fast clock)
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
// SPI Interface for the 12 bit DACs
//-----------------------------------

dac_spi_if #(1, 9'h190) dac_spi_if_x (
 
// OUTPUTs
    .cntrl1       (cntrl1),         // Control value 1
    .cntrl2       (cntrl2),         // Control value 2
    .din          (din_x),          // SPI Serial Data
    .per_dout     (per_dout_dac_x), // Peripheral data output
    .sclk         (sclk_x),         // SPI Serial Clock
    .sync_n       (sync_n_x),       // SPI Frame synchronization signal (low active)
 
// INPUTs
    .mclk         (mclk),           // Main system clock
    .per_addr     (per_addr),       // Peripheral address
    .per_din      (per_din),        // Peripheral data input
    .per_en       (per_en),         // Peripheral enable (high active)
    .per_we       (per_we),         // Peripheral write enable (high active)
    .puc_rst      (puc_rst)         // Main system reset
);

dac_spi_if #(1, 9'h1A0) dac_spi_if_y (
 
// OUTPUTs
    .cntrl1       (),               // Control value 1
    .cntrl2       (),               // Control value 2
    .din          (din_y),          // SPI Serial Data
    .per_dout     (per_dout_dac_y), // Peripheral data output
    .sclk         (sclk_y),         // SPI Serial Clock
    .sync_n       (sync_n_y),       // SPI Frame synchronization signal (low active)
 
// INPUTs
    .mclk         (mclk),           // Main system clock
    .per_addr     (per_addr),       // Peripheral address
    .per_din      (per_din),        // Peripheral data input
    .per_en       (per_en),         // Peripheral enable (high active)
    .per_we       (per_we),         // Peripheral write enable (high active)
    .puc_rst      (puc_rst)         // Main system reset
);

//
// Digital I/O
//-------------------------------

omsp_gpio #(.P1_EN(1),
            .P2_EN(0),
            .P3_EN(0),
            .P4_EN(0),
            .P5_EN(0),
            .P6_EN(0)) gpio_0 (

// OUTPUTs
    .irq_port1    (irq_port1),     // Port 1 interrupt
    .irq_port2    (),              // Port 2 interrupt
    .p1_dout      (p1_dout),       // Port 1 data output
    .p1_dout_en   (p1_dout_en),    // Port 1 data output enable
    .p1_sel       (p1_sel),        // Port 1 function select
    .p2_dout      (),              // Port 2 data output
    .p2_dout_en   (),              // Port 2 data output enable
    .p2_sel       (),              // Port 2 function select
    .p3_dout      (),              // Port 3 data output
    .p3_dout_en   (),              // Port 3 data output enable
    .p3_sel       (),              // Port 3 function select
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
    .p2_din       (8'h00),         // Port 2 data input
    .p3_din       (8'h00),         // Port 3 data input
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
    .inclk        (1'b0),          // INCLK external timer clock (SLOW)
    .irq_ta0_acc  (irq_acc[9]),    // Interrupt request TACCR0 accepted
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .ta_cci0a     (1'b0),          // Timer A capture 0 input A
    .ta_cci0b     (1'b0),          // Timer A capture 0 input B
    .ta_cci1a     (1'b0),          // Timer A capture 1 input A
    .ta_cci1b     (1'b0),          // Timer A capture 1 input B
    .ta_cci2a     (1'b0),          // Timer A capture 2 input A
    .ta_cci2b     (1'b0),          // Timer A capture 2 input B
    .taclk        (1'b0)           // TACLK external timer clock (SLOW)
);

//
// Combine peripheral data buses
//-------------------------------

assign per_dout = per_dout_dio   |
                  per_dout_tA    |
                  per_dout_dac_x |
                  per_dout_dac_y;
   
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
                     1'b0,         // Vector  3  (0xFFE6)
                     irq_port1,    // Vector  2  (0xFFE4)
                     1'b0,         // Vector  1  (0xFFE2)
                     1'b0};        // Vector  0  (0xFFE0)

//
// Diverse
//-------------------------------

assign  reset_n =  (porst_n & pbrst_n);

assign  p1_din  =  8'h00;

assign  led     =  {cntrl1, p1_dout[0], p1_dout[0], cntrl2};

   
endmodule // openMSP430_fpga

