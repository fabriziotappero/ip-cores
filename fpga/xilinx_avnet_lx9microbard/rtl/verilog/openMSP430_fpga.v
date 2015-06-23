//----------------------------------------------------------------------------
// Copyright (C) 2011 Authors
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
//                      openMSP430 FPGA Top-level for the Avnet LX9 Microboard
//
// *Author(s):
//              - Ricardo Ribalda,    ricardo.ribalda@gmail.com
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
`include "openmsp430/openMSP430_defines.v"

module openMSP430_fpga (

     //----------------------------------------------
     // User Reset Push Button
     //----------------------------------------------
     USER_RESET,

     //----------------------------------------------
     // Micron N25Q128 SPI Flash
     //   This is a Multi-I/O Flash.  Several pins
     //  have dual purposes depending on the mode.
     //----------------------------------------------
     SPI_SCK,
     SPI_CS_n,
     SPI_MOSI_MISO0,
     SPI_MISO_MISO1,
     SPI_Wn_MISO2,
     SPI_HOLDn_MISO3,

     //----------------------------------------------
     // TI CDCE913 Triple-Output PLL Clock Chip
     //   Y1: 40 MHz, USER_CLOCK can be used as
     //              external configuration clock
     //   Y2: 66.667 MHz
     //   Y3: 100 MHz 
     //----------------------------------------------
     USER_CLOCK,
     CLOCK_Y2,
     CLOCK_Y3,

     //----------------------------------------------
     // The following oscillator is not populated
     // in production but the footprint is compatible
     // with the Maxim DS1088LU			
     //----------------------------------------------
     BACKUP_CLK,

     //----------------------------------------------
     // User DIP Switch x4
     //----------------------------------------------
     GPIO_DIP1,
     GPIO_DIP2,
     GPIO_DIP3,
     GPIO_DIP4,

     //----------------------------------------------
     // User LEDs			
     //----------------------------------------------
     GPIO_LED1,
     GPIO_LED2,
     GPIO_LED3,
     GPIO_LED4,

     //----------------------------------------------
     // Silicon Labs CP2102 USB-to-UART Bridge Chip
     //----------------------------------------------
     USB_RS232_RXD,
     USB_RS232_TXD,

     //----------------------------------------------
     // Texas Instruments CDCE913 programming port
     //----------------------------------------------
     SCL,
     SDA,

     //----------------------------------------------
     // Micron MT46H32M16LFBF-5 LPDDR			
     //----------------------------------------------

     // Addresses
     LPDDR_A0,
     LPDDR_A1,
     LPDDR_A2,
     LPDDR_A3,
     LPDDR_A4,
     LPDDR_A5,
     LPDDR_A6,
     LPDDR_A7,
     LPDDR_A8,
     LPDDR_A9,
     LPDDR_A10,
     LPDDR_A11,
     LPDDR_A12,
     LPDDR_BA0,
     LPDDR_BA1,

     // Data                                                                  
     LPDDR_DQ0,
     LPDDR_DQ1,
     LPDDR_DQ2,
     LPDDR_DQ3,
     LPDDR_DQ4,
     LPDDR_DQ5,
     LPDDR_DQ6,
     LPDDR_DQ7,
     LPDDR_DQ8,
     LPDDR_DQ9,
     LPDDR_DQ10,
     LPDDR_DQ11,
     LPDDR_DQ12,
     LPDDR_DQ13,
     LPDDR_DQ14,
     LPDDR_DQ15,
     LPDDR_LDM,
     LPDDR_UDM,
     LPDDR_LDQS,
     LPDDR_UDQS,

     // Clock
     LPDDR_CK_N,
     LPDDR_CK_P,
     LPDDR_CKE,

     // Control
     LPDDR_CAS_n,
     LPDDR_RAS_n,
     LPDDR_WE_n,
     LPDDR_RZQ,

     //----------------------------------------------
     // National Semiconductor DP83848J 10/100 Ethernet PHY			
     //   Pull-ups on RXD are necessary to set the PHY AD to 11110b.
     //   Must keep the PHY from defaulting to PHY AD = 00000b      
     //   because this is Isolate Mode                              
     //----------------------------------------------
     ETH_COL,
     ETH_CRS,
     ETH_MDC,
     ETH_MDIO,
     ETH_RESET_n,
     ETH_RX_CLK,
     ETH_RX_D0,
     ETH_RX_D1,
     ETH_RX_D2,
     ETH_RX_D3,
     ETH_RX_DV,
     ETH_RX_ER,
     ETH_TX_CLK,
     ETH_TX_D0,
     ETH_TX_D1,
     ETH_TX_D2,
     ETH_TX_D3,
     ETH_TX_EN,

     //----------------------------------------------
     // Peripheral Modules (PMODs) and GPIO
     //     https://www.digilentinc.com/PMODs
     //----------------------------------------------

     // Connector J5
     PMOD1_P1,
     PMOD1_P2,
     PMOD1_P3,
     PMOD1_P4,
     PMOD1_P7,
     PMOD1_P8,
     PMOD1_P9,
     PMOD1_P10,

     // Connector J4
     PMOD2_P1,
     PMOD2_P2,
     PMOD2_P3,
     PMOD2_P4,
     PMOD2_P7,
     PMOD2_P8,
     PMOD2_P9,
     PMOD2_P10
);

//----------------------------------------------
// User Reset Push Button
//----------------------------------------------
input    USER_RESET;

//----------------------------------------------
// Micron N25Q128 SPI Flash
//   This is a Multi-I/O Flash.  Several pins
//  have dual purposes depending on the mode.
//----------------------------------------------
output   SPI_SCK;
output   SPI_CS_n;
inout    SPI_MOSI_MISO0;
inout    SPI_MISO_MISO1;
output   SPI_Wn_MISO2;
output   SPI_HOLDn_MISO3;

//----------------------------------------------
// TI CDCE913 Triple-Output PLL Clock Chip
//   Y1: 40 MHz; USER_CLOCK can be used as
//              external configuration clock
//   Y2: 66.667 MHz
//   Y3: 100 MHz 
//----------------------------------------------
input    USER_CLOCK;
input    CLOCK_Y2;
input    CLOCK_Y3;

//----------------------------------------------
// The following oscillator is not populated
// in production but the footprint is compatible
// with the Maxim DS1088LU			
//----------------------------------------------
input    BACKUP_CLK;

//----------------------------------------------
// User DIP Switch x4
//----------------------------------------------
input    GPIO_DIP1;
input    GPIO_DIP2;
input    GPIO_DIP3;
input    GPIO_DIP4;

//----------------------------------------------
// User LEDs			
//----------------------------------------------
output   GPIO_LED1;
output   GPIO_LED2;
output   GPIO_LED3;
output   GPIO_LED4;

//----------------------------------------------
// Silicon Labs CP2102 USB-to-UART Bridge Chip
//----------------------------------------------
input    USB_RS232_RXD;
output   USB_RS232_TXD;

//----------------------------------------------
// Texas Instruments CDCE913 programming port
//----------------------------------------------
output   SCL;
inout    SDA;

//----------------------------------------------
// Micron MT46H32M16LFBF-5 LPDDR			
//----------------------------------------------

// Addresses
output   LPDDR_A0;
output   LPDDR_A1;
output   LPDDR_A2;
output   LPDDR_A3;
output   LPDDR_A4;
output   LPDDR_A5;
output   LPDDR_A6;
output   LPDDR_A7;
output   LPDDR_A8;
output   LPDDR_A9;
output   LPDDR_A10;
output   LPDDR_A11;
output   LPDDR_A12;
output   LPDDR_BA0;
output   LPDDR_BA1;

// Data                                                                  
inout    LPDDR_DQ0;
inout    LPDDR_DQ1;
inout    LPDDR_DQ2;
inout    LPDDR_DQ3;
inout    LPDDR_DQ4;
inout    LPDDR_DQ5;
inout    LPDDR_DQ6;
inout    LPDDR_DQ7;
inout    LPDDR_DQ8;
inout    LPDDR_DQ9;
inout    LPDDR_DQ10;
inout    LPDDR_DQ11;
inout    LPDDR_DQ12;
inout    LPDDR_DQ13;
inout    LPDDR_DQ14;
inout    LPDDR_DQ15;
output   LPDDR_LDM;
output   LPDDR_UDM;
inout    LPDDR_LDQS;
inout    LPDDR_UDQS;

// Clock
output   LPDDR_CK_N;
output   LPDDR_CK_P;
output   LPDDR_CKE;

// Control
output   LPDDR_CAS_n;
output   LPDDR_RAS_n;
output   LPDDR_WE_n;
inout    LPDDR_RZQ;

//----------------------------------------------
// National Semiconductor DP83848J 10/100 Ethernet PHY			
//   Pull-ups on RXD are necessary to set the PHY AD to 11110b.
//   Must keep the PHY from defaulting to PHY AD = 00000b      
//   because this is Isolate Mode                              
//----------------------------------------------
input    ETH_COL;
input    ETH_CRS;
output   ETH_MDC;
inout    ETH_MDIO;
output   ETH_RESET_n;
input    ETH_RX_CLK;
input    ETH_RX_D0;
input    ETH_RX_D1;
input    ETH_RX_D2;
input    ETH_RX_D3;
input    ETH_RX_DV;
input    ETH_RX_ER;
input    ETH_TX_CLK;
output   ETH_TX_D0;
output   ETH_TX_D1;
output   ETH_TX_D2;
output   ETH_TX_D3;
output   ETH_TX_EN;

//----------------------------------------------
// Peripheral Modules (PMODs) and GPIO
//     https://www.digilentinc.com/PMODs
//----------------------------------------------

// Connector J5
inout    PMOD1_P1;
inout    PMOD1_P2;
inout    PMOD1_P3;
input    PMOD1_P4;
inout    PMOD1_P7;
inout    PMOD1_P8;
inout    PMOD1_P9;
inout    PMOD1_P10;

// Connector J4
inout    PMOD2_P1;
inout    PMOD2_P2;
inout    PMOD2_P3;
inout    PMOD2_P4;
inout    PMOD2_P7;
inout    PMOD2_P8;
inout    PMOD2_P9;
inout    PMOD2_P10;


//=============================================================================
// 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
//=============================================================================

// Clock generation
wire               clk_40mhz;
wire               dcm_locked;
wire               dcm_clkfx;
wire               dcm_clk0;
wire               dcm_clkfb;
wire               dco_clk;

// Reset generation
wire               reset_pin;
wire               reset_pin_n;
wire               reset_n;

// Debug interface
wire               omsp_dbg_i2c_scl;
wire 	           omsp_dbg_i2c_sda_in;
wire               omsp_dbg_i2c_sda_out;
wire               omsp0_dbg_i2c_sda_out;
wire               omsp1_dbg_i2c_sda_out;
wire        [23:0] chipscope_trigger;

// Data memory
wire [`DMEM_MSB:0] omsp0_dmem_addr;
wire               omsp0_dmem_cen;
wire               omsp0_dmem_cen_sp;
wire               omsp0_dmem_cen_dp;
wire        [15:0] omsp0_dmem_din;
wire         [1:0] omsp0_dmem_wen;
wire        [15:0] omsp0_dmem_dout;
wire        [15:0] omsp0_dmem_dout_sp;
wire        [15:0] omsp0_dmem_dout_dp;
reg                omsp0_dmem_dout_sel;

wire [`DMEM_MSB:0] omsp1_dmem_addr;
wire               omsp1_dmem_cen;
wire               omsp1_dmem_cen_sp;
wire               omsp1_dmem_cen_dp;
wire        [15:0] omsp1_dmem_din;
wire         [1:0] omsp1_dmem_wen;
wire        [15:0] omsp1_dmem_dout;
wire        [15:0] omsp1_dmem_dout_sp;
wire        [15:0] omsp1_dmem_dout_dp;
reg                omsp1_dmem_dout_sel;

// Program memory
wire [`PMEM_MSB:0] omsp0_pmem_addr;
wire               omsp0_pmem_cen;
wire        [15:0] omsp0_pmem_din;
wire         [1:0] omsp0_pmem_wen;
wire        [15:0] omsp0_pmem_dout;

wire [`PMEM_MSB:0] omsp1_pmem_addr;
wire               omsp1_pmem_cen;
wire        [15:0] omsp1_pmem_din;
wire         [1:0] omsp1_pmem_wen;
wire        [15:0] omsp1_pmem_dout;

// UART
wire               omsp0_uart_rxd;
wire               omsp0_uart_txd;

// LEDs & Switches
wire         [3:0] omsp_switch;
wire         [1:0] omsp0_led;
wire         [1:0] omsp1_led;


//=============================================================================
// 2)  RESET GENERATION & FPGA STARTUP
//=============================================================================

// Reset input buffer
IBUF   ibuf_reset_n   (.O(reset_pin), .I(USER_RESET));
assign reset_pin_n = ~reset_pin;

// Release the reset only, if the DCM is locked
assign  reset_n = reset_pin_n & dcm_locked;

// Top level reset generation
wire dco_rst;
omsp_sync_reset sync_reset_dco (.rst_s (dco_rst), .clk(dco_clk), .rst_a(!reset_n));


//=============================================================================
// 3)  CLOCK GENERATION
//=============================================================================

// Input buffers
//------------------------
IBUFG ibuf_clk_main   (.O(clk_40mhz),    .I(USER_CLOCK));
IBUFG ibuf_clk_y2     (.O(),             .I(CLOCK_Y2));
IBUFG ibuf_clk_y3     (.O(),             .I(CLOCK_Y3));
IBUFG ibuf_clk_bkup   (.O(),             .I(BACKUP_CLK));


// Digital Clock Manager
//------------------------
DCM_SP #(.CLKFX_MULTIPLY(7),
	 .CLKFX_DIVIDE(10),
	 .CLKIN_PERIOD(25.000)) dcm_inst (

// OUTPUTs
    .CLKFX        (dcm_clkfx),
    .CLK0         (dcm_clk0),
    .LOCKED       (dcm_locked),

// INPUTs
    .CLKFB        (dcm_clkfb),
    .CLKIN        (clk_40mhz),
    .PSEN         (1'b0),
    .RST          (reset_pin)
);

BUFG CLK0_BUFG_INST (
    .I(dcm_clk0),
    .O(dcm_clkfb)
);

//synthesis translate_off
defparam dcm_inst.CLKFX_MULTIPLY  = 7;
defparam dcm_inst.CLKFX_DIVIDE    = 10;
defparam dcm_inst.CLKIN_PERIOD    = 25.000;
//synthesis translate_on

// Clock buffers
//------------------------
BUFG  buf_sys_clock  (.O(dco_clk), .I(dcm_clkfx));


//=============================================================================
// 4)  OPENMSP430 SYSTEM 0
//=============================================================================

omsp_system_0 omsp_system_0_inst (

// Clock & Reset
    .dco_clk           (dco_clk),                     // Fast oscillator (fast clock)
    .reset_n           (reset_n),                     // Reset Pin (low active, asynchronous and non-glitchy)

// Serial Debug Interface (I2C)
    .dbg_i2c_addr      (7'd50),                       // Debug interface: I2C Address
    .dbg_i2c_broadcast (7'd49),                       // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (omsp_dbg_i2c_scl),            // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (omsp_dbg_i2c_sda_in),         // Debug interface: I2C SDA IN
    .dbg_i2c_sda_out   (omsp0_dbg_i2c_sda_out),       // Debug interface: I2C SDA OUT

// Data Memory
    .dmem_addr         (omsp0_dmem_addr),             // Data Memory address
    .dmem_cen          (omsp0_dmem_cen),              // Data Memory chip enable (low active)
    .dmem_din          (omsp0_dmem_din),              // Data Memory data input
    .dmem_wen          (omsp0_dmem_wen),              // Data Memory write enable (low active)
    .dmem_dout         (omsp0_dmem_dout),             // Data Memory data output

// Program Memory
    .pmem_addr         (omsp0_pmem_addr),             // Program Memory address
    .pmem_cen          (omsp0_pmem_cen),              // Program Memory chip enable (low active)
    .pmem_din          (omsp0_pmem_din),              // Program Memory data input (optional)
    .pmem_wen          (omsp0_pmem_wen),              // Program Memory write enable (low active) (optional)
    .pmem_dout         (omsp0_pmem_dout),             // Program Memory data output

// UART
    .uart_rxd          (omsp0_uart_rxd),              // UART Data Receive (RXD)
    .uart_txd          (omsp0_uart_txd),              // UART Data Transmit (TXD)

// Switches & LEDs
    .switch            (omsp_switch),                 // Input switches
    .led               (omsp0_led)                    // LEDs
);


//=============================================================================
// 5)  OPENMSP430 SYSTEM 1
//=============================================================================

omsp_system_1 omsp_system_1_inst (

// Clock & Reset
    .dco_clk           (dco_clk),                     // Fast oscillator (fast clock)
    .reset_n           (reset_n),                     // Reset Pin (low active, asynchronous and non-glitchy)

// Serial Debug Interface (I2C)
    .dbg_i2c_addr      (7'd51),                       // Debug interface: I2C Address
    .dbg_i2c_broadcast (7'd49),                       // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (omsp_dbg_i2c_scl),            // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (omsp_dbg_i2c_sda_in),         // Debug interface: I2C SDA IN
    .dbg_i2c_sda_out   (omsp1_dbg_i2c_sda_out),       // Debug interface: I2C SDA OUT

// Data Memory
    .dmem_addr         (omsp1_dmem_addr),             // Data Memory address
    .dmem_cen          (omsp1_dmem_cen),              // Data Memory chip enable (low active)
    .dmem_din          (omsp1_dmem_din),              // Data Memory data input
    .dmem_wen          (omsp1_dmem_wen),              // Data Memory write enable (low active)
    .dmem_dout         (omsp1_dmem_dout),             // Data Memory data output

// Program Memory
    .pmem_addr         (omsp1_pmem_addr),             // Program Memory address
    .pmem_cen          (omsp1_pmem_cen),              // Program Memory chip enable (low active)
    .pmem_din          (omsp1_pmem_din),              // Program Memory data input (optional)
    .pmem_wen          (omsp1_pmem_wen),              // Program Memory write enable (low active) (optional)
    .pmem_dout         (omsp1_pmem_dout),             // Program Memory data output

// Switches & LEDs
    .switch            (omsp_switch),                 // Input switches
    .led               (omsp1_led)                    // LEDs
);


//=============================================================================
// 6)  PROGRAM AND DATA MEMORIES
//=============================================================================

// Memory muxing (CPU 0)
assign omsp0_dmem_cen_sp =  omsp0_dmem_addr[`DMEM_MSB] | omsp0_dmem_cen;
assign omsp0_dmem_cen_dp = ~omsp0_dmem_addr[`DMEM_MSB] | omsp0_dmem_cen;
assign omsp0_dmem_dout   =  omsp0_dmem_dout_sel ? omsp0_dmem_dout_sp : omsp0_dmem_dout_dp;

always @ (posedge dco_clk or posedge dco_rst)
  if (dco_rst)                  omsp0_dmem_dout_sel <=  1'b1;
  else if (~omsp0_dmem_cen_sp)  omsp0_dmem_dout_sel <=  1'b1;
  else if (~omsp0_dmem_cen_dp)  omsp0_dmem_dout_sel <=  1'b0;

// Memory muxing (CPU 1)
assign omsp1_dmem_cen_sp =  omsp1_dmem_addr[`DMEM_MSB] | omsp1_dmem_cen;
assign omsp1_dmem_cen_dp = ~omsp1_dmem_addr[`DMEM_MSB] | omsp1_dmem_cen;
assign omsp1_dmem_dout   =  omsp1_dmem_dout_sel ? omsp1_dmem_dout_sp : omsp1_dmem_dout_dp;

always @ (posedge dco_clk or posedge dco_rst)
  if (dco_rst)                  omsp1_dmem_dout_sel <=  1'b1;
  else if (~omsp1_dmem_cen_sp)  omsp1_dmem_dout_sel <=  1'b1;
  else if (~omsp1_dmem_cen_dp)  omsp1_dmem_dout_sel <=  1'b0;

// Data Memory (CPU 0)
ram_16x1k_sp ram_16x1k_sp_dmem_omsp0 (
    .clka           ( dco_clk),
    .ena            (~omsp0_dmem_cen_sp),
    .wea            (~omsp0_dmem_wen),
    .addra          ( omsp0_dmem_addr[`DMEM_MSB-1:0]),
    .dina           ( omsp0_dmem_din),
    .douta          ( omsp0_dmem_dout_sp)
);

// Data Memory (CPU 1)
ram_16x1k_sp ram_16x1k_sp_dmem_omsp1 (
    .clka           ( dco_clk),
    .ena            (~omsp1_dmem_cen_sp),
    .wea            (~omsp1_dmem_wen),
    .addra          ( omsp1_dmem_addr[`DMEM_MSB-1:0]),
    .dina           ( omsp1_dmem_din),
    .douta          ( omsp1_dmem_dout_sp)
);

// Shared Data Memory
ram_16x1k_dp ram_16x1k_dp_dmem_shared (
    .clka           ( dco_clk),
    .ena            (~omsp0_dmem_cen_dp),
    .wea            (~omsp0_dmem_wen),
    .addra          ( omsp0_dmem_addr[`DMEM_MSB-1:0]),
    .dina           ( omsp0_dmem_din),
    .douta          ( omsp0_dmem_dout_dp),
    .clkb           ( dco_clk),
    .enb            (~omsp1_dmem_cen_dp),
    .web            (~omsp1_dmem_wen),
    .addrb          ( omsp1_dmem_addr[`DMEM_MSB-1:0]),
    .dinb           ( omsp1_dmem_din),
    .doutb          ( omsp1_dmem_dout_dp)
);

// Shared Program Memory
ram_16x8k_dp ram_16x8k_dp_pmem_shared (
    .clka           ( dco_clk),
    .ena            (~omsp0_pmem_cen),
    .wea            (~omsp0_pmem_wen),
    .addra          ( omsp0_pmem_addr),
    .dina           ( omsp0_pmem_din),
    .douta          ( omsp0_pmem_dout),
    .clkb           ( dco_clk),
    .enb            (~omsp1_pmem_cen),
    .web            (~omsp1_pmem_wen),
    .addrb          ( omsp1_pmem_addr),
    .dinb           ( omsp1_pmem_din),
    .doutb          ( omsp1_pmem_dout)
);


//=============================================================================
// 7)  I/O CELLS
//=============================================================================

//----------------------------------------------
// Micron N25Q128 SPI Flash
//   This is a Multi-I/O Flash.  Several pins
//  have dual purposes depending on the mode.
//----------------------------------------------
OBUF  SPI_CLK_PIN        (.I(1'b0),                  .O(SPI_SCK));
OBUF  SPI_CSN_PIN        (.I(1'b1),                  .O(SPI_CS_n));
IOBUF SPI_MOSI_MISO0_PIN (.T(1'b0), .I(1'b0), .O(),  .IO(SPI_MOSI_MISO0));
IOBUF SPI_MISO_MISO1_PIN (.T(1'b0), .I(1'b0), .O(),  .IO(SPI_MISO_MISO1));
OBUF  SPI_WN_PIN         (.I(1'b1),                  .O(SPI_Wn_MISO2));
OBUF  SPI_HOLD_PIN       (.I(1'b1),                  .O(SPI_HOLDn_MISO3));

//----------------------------------------------
// User DIP Switch x4
//----------------------------------------------
IBUF  SW3_PIN            (.O(omsp_switch[3]),        .I(GPIO_DIP4));
IBUF  SW2_PIN            (.O(omsp_switch[2]),        .I(GPIO_DIP3));
IBUF  SW1_PIN            (.O(omsp_switch[1]),        .I(GPIO_DIP2));
IBUF  SW0_PIN            (.O(omsp_switch[0]),        .I(GPIO_DIP1));

//----------------------------------------------
// User LEDs			
//----------------------------------------------
OBUF  LED3_PIN           (.I(omsp1_led[1]),          .O(GPIO_LED4));
OBUF  LED2_PIN           (.I(omsp1_led[0]),          .O(GPIO_LED3));
OBUF  LED1_PIN           (.I(omsp0_led[1]),          .O(GPIO_LED2));
OBUF  LED0_PIN           (.I(omsp0_led[0]),          .O(GPIO_LED1));

//----------------------------------------------
// Silicon Labs CP2102 USB-to-UART Bridge Chip
//----------------------------------------------
IBUF  UART_RXD_PIN       (.O(omsp0_uart_rxd),        .I(USB_RS232_RXD));
OBUF  UART_TXD_PIN       (.I(omsp0_uart_txd),        .O(USB_RS232_TXD));

//----------------------------------------------
// Texas Instruments CDCE913 programming port
//----------------------------------------------
IOBUF SCL_PIN            (.T(1'b0), .I(1'b1), .O(),  .IO(SCL));
IOBUF SDA_PIN            (.T(1'b0), .I(1'b1), .O(),  .IO(SDA));

//----------------------------------------------
// Micron MT46H32M16LFBF-5 LPDDR			
//----------------------------------------------

// Addresses
OBUF  LPDDR_A0_PIN       (.I(1'b0),                  .O(LPDDR_A0));
OBUF  LPDDR_A1_PIN       (.I(1'b0),                  .O(LPDDR_A1));
OBUF  LPDDR_A2_PIN       (.I(1'b0),                  .O(LPDDR_A2));
OBUF  LPDDR_A3_PIN       (.I(1'b0),                  .O(LPDDR_A3));
OBUF  LPDDR_A4_PIN       (.I(1'b0),                  .O(LPDDR_A4));
OBUF  LPDDR_A5_PIN       (.I(1'b0),                  .O(LPDDR_A5));
OBUF  LPDDR_A6_PIN       (.I(1'b0),                  .O(LPDDR_A6));
OBUF  LPDDR_A7_PIN       (.I(1'b0),                  .O(LPDDR_A7));
OBUF  LPDDR_A8_PIN       (.I(1'b0),                  .O(LPDDR_A8));
OBUF  LPDDR_A9_PIN       (.I(1'b0),                  .O(LPDDR_A9));
OBUF  LPDDR_A10_PIN      (.I(1'b0),                  .O(LPDDR_A10));
OBUF  LPDDR_A11_PIN      (.I(1'b0),                  .O(LPDDR_A11));
OBUF  LPDDR_A12_PIN      (.I(1'b0),                  .O(LPDDR_A12));
OBUF  LPDDR_BA0_PIN      (.I(1'b0),                  .O(LPDDR_BA0));
OBUF  LPDDR_BA1_PIN      (.I(1'b0),                  .O(LPDDR_BA1));

// Data                                                                  
IOBUF LPDDR_DQ0_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ0));
IOBUF LPDDR_DQ1_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ1));
IOBUF LPDDR_DQ2_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ2));
IOBUF LPDDR_DQ3_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ3));
IOBUF LPDDR_DQ4_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ4));
IOBUF LPDDR_DQ5_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ5));
IOBUF LPDDR_DQ6_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ6));
IOBUF LPDDR_DQ7_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ7));
IOBUF LPDDR_DQ8_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ8));
IOBUF LPDDR_DQ9_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ9));
IOBUF LPDDR_DQ10_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ10));
IOBUF LPDDR_DQ11_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ11));
IOBUF LPDDR_DQ12_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ12));
IOBUF LPDDR_DQ13_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ13));
IOBUF LPDDR_DQ14_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ14));
IOBUF LPDDR_DQ15_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_DQ15));
OBUF  LPDDR_LDM_PIN      (.I(1'b0),                  .O(LPDDR_LDM));
OBUF  LPDDR_UDM_PIN      (.I(1'b0),                  .O(LPDDR_UDM));
IOBUF LPDDR_LDQS_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_LDQS));
IOBUF LPDDR_UDQS_PIN     (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_UDQS));

// Clock
IOBUF LPDDR_CK_N_PIN     (.T(1'b1), .I(1'b0), .O(),  .IO(LPDDR_CK_N));
IOBUF LPDDR_CK_P_PIN     (.T(1'b1), .I(1'b1), .O(),  .IO(LPDDR_CK_P));
OBUF  LPDDR_CKE_PIN      (.I(1'b0),                  .O(LPDDR_CKE));

// Control
OBUF  LPDDR_CAS_N_PIN    (.I(1'b1),                  .O(LPDDR_CAS_n));
OBUF  LPDDR_RAS_N_PIN    (.I(1'b1),                  .O(LPDDR_RAS_n));
OBUF  LPDDR_WE_N_PIN     (.I(1'b1),                  .O(LPDDR_WE_n));
IOBUF LPDDR_RZQ_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(LPDDR_RZQ));


//----------------------------------------------
// National Semiconductor DP83848J 10/100 Ethernet PHY			
//   Pull-ups on RXD are necessary to set the PHY AD to 11110b.
//   Must keep the PHY from defaulting to PHY AD = 00000b      
//   because this is Isolate Mode                              
//----------------------------------------------
IBUF  ETH_COL_PIN        (.O(),                      .I(ETH_COL));
IBUF  ETH_CRS_PIN        (.O(),                      .I(ETH_CRS));
OBUF  ETH_MDC_PIN        (.I(1'b0),                  .O(ETH_MDC));
IOBUF ETH_MDIO_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(ETH_MDIO));
OBUF  ETH_RESET_N_PIN    (.I(1'b1),                  .O(ETH_RESET_n));
IBUF  ETH_RX_CLK_PIN     (.O(),                      .I(ETH_RX_CLK));
IBUF  ETH_RX_D0_PIN      (.O(),                      .I(ETH_RX_D0));
IBUF  ETH_RX_D1_PIN      (.O(),                      .I(ETH_RX_D1));
IBUF  ETH_RX_D2_PIN      (.O(),                      .I(ETH_RX_D2));
IBUF  ETH_RX_D3_PIN      (.O(),                      .I(ETH_RX_D3));
IBUF  ETH_RX_DV_PIN      (.O(),                      .I(ETH_RX_DV));
IBUF  ETH_RX_ER_PIN      (.O(),                      .I(ETH_RX_ER));
IBUF  ETH_TX_CLK_PIN     (.O(),                      .I(ETH_TX_CLK));
OBUF  ETH_TX_D0_PIN      (.I(1'b0),                  .O(ETH_TX_D0));
OBUF  ETH_TX_D1_PIN      (.I(1'b0),                  .O(ETH_TX_D1));
OBUF  ETH_TX_D2_PIN      (.I(1'b0),                  .O(ETH_TX_D2));
OBUF  ETH_TX_D3_PIN      (.I(1'b0),                  .O(ETH_TX_D3));
OBUF  ETH_TX_EN_PIN      (.I(1'b0),                  .O(ETH_TX_EN));

//----------------------------------------------
// Peripheral Modules (PMODs) and GPIO
//     https://www.digilentinc.com/PMODs
//----------------------------------------------

assign omsp_dbg_i2c_sda_out = omsp0_dbg_i2c_sda_out & omsp1_dbg_i2c_sda_out;
   
// Connector J5
IOBUF PMOD1_P1_PIN       (.T(1'b0),                  .I(1'b0), .O(),                     .IO(PMOD1_P1));
IOBUF PMOD1_P2_PIN       (.T(1'b0),                  .I(1'b0), .O(),                     .IO(PMOD1_P2));
IOBUF PMOD1_P3_PIN       (.T(omsp_dbg_i2c_sda_out),  .I(1'b0), .O(omsp_dbg_i2c_sda_in),  .IO(PMOD1_P3));
IBUF  PMOD1_P4_PIN       (                                     .O(omsp_dbg_i2c_scl),     .I (PMOD1_P4));
IOBUF PMOD1_P7_PIN       (.T(1'b0),                  .I(1'b0), .O(),                     .IO(PMOD1_P7));
IBUF  PMOD1_P8_PIN       (                                     .O(),                     .I (PMOD1_P8));
IOBUF PMOD1_P9_PIN       (.T(1'b0),                  .I(1'b0), .O(),                     .IO(PMOD1_P9));
IOBUF PMOD1_P10_PIN      (.T(1'b0),                  .I(1'b0), .O(),                     .IO(PMOD1_P10));
   
// Connector J4
IOBUF PMOD2_P1_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P1));
IOBUF PMOD2_P2_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P2));
IOBUF PMOD2_P3_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P3));
IOBUF PMOD2_P4_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P4));
IOBUF PMOD2_P7_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P7));
IOBUF PMOD2_P8_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P8));
IOBUF PMOD2_P9_PIN       (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P9));
IOBUF PMOD2_P10_PIN      (.T(1'b0), .I(1'b0), .O(),  .IO(PMOD2_P10));


//=============================================================================
//8)  CHIPSCOPE
//=============================================================================
//`define WITH_CHIPSCOPE
`ifdef WITH_CHIPSCOPE

// Sampling clock
reg [7:0] div_cnt;
always @ (posedge dco_clk or posedge dco_rst)
  if (dco_rst)           div_cnt <=  8'h00;
  else if (div_cnt > 10) div_cnt <=  8'h00;
  else                   div_cnt <=  div_cnt+8'h01;

reg clk_sample;
always @ (posedge dco_clk or posedge dco_rst)
  if (dco_rst) clk_sample <=  1'b0;
  else         clk_sample <=  (div_cnt==8'h00);

   
// ChipScope instance
wire        [35:0] chipscope_control;
chipscope_ila chipscope_ila (
    .CONTROL  (chipscope_control),
    .CLK      (clk_sample),
    .TRIG0    (chipscope_trigger)
);

chipscope_icon chipscope_icon (
    .CONTROL0 (chipscope_control)
);


assign chipscope_trigger[0]     = 1'b0;
assign chipscope_trigger[1]     = 1'b0;
assign chipscope_trigger[2]     = 1'b0;
assign chipscope_trigger[23:3]  = 21'h00_0000;
`endif

endmodule // openMSP430_fpga

