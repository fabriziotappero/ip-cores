//////////////////////////////////////////////////////////////////////////////
// Copyright 2010 by Iztok Jeras (based on code by Terasic Technologies Inc.)
//////////////////////////////////////////////////////////////////////////////

module DE1_soc_nios2 (
// Clock Input
input   [1:0] CLOCK_24,     // 24 MHz
input   [1:0] CLOCK_27,     // 27 MHz
input         CLOCK_50,     // 50 MHz
input         EXT_CLOCK,    // External Clock
// Push Button
input   [3:0] KEY,          // Pushbutton[3:0]
// DPDT Switch
input   [9:0] SW,           // Toggle Switch[9:0]
// 7-SEG Dispaly
output  [6:0] HEX0,         // Seven Segment Digit 0
output  [6:0] HEX1,         // Seven Segment Digit 1
output  [6:0] HEX2,         // Seven Segment Digit 2
output  [6:0] HEX3,         // Seven Segment Digit 3
// LED
output  [7:0] LEDG,         // LED Green[7:0]
output  [9:0] LEDR,         // LED Red[9:0]
// UART
output        UART_TXD,     // UART Transmitter
input         UART_RXD,     // UART Receiver
// SDRAM Interface
output        DRAM_CLK,     // SDRAM Clock
output        DRAM_CKE,     // SDRAM Clock Enable
output        DRAM_CS_N,    // SDRAM Chip Select
output        DRAM_WE_N,    // SDRAM Write Enable
output        DRAM_CAS_N,   // SDRAM Column Address Strobe
output        DRAM_RAS_N,   // SDRAM Row Address Strobe
output  [1:0] DRAM_BA,      // SDRAM Bank Address
output [11:0] DRAM_ADDR,    // SDRAM Address bus 12 Bits
inout  [15:0] DRAM_DQ,      // SDRAM Data bus 16 Bits
output  [1:0] DRAM_DQM,     // SDRAM Byte Data Mask 
// Flash Interface
output        FL_RST_N,     // FLASH Reset
output        FL_CE_N,      // FLASH Chip Enable
output        FL_WE_N,      // FLASH Write Enable
output        FL_OE_N,      // FLASH Output Enable
output [21:0] FL_ADDR,      // FLASH Address bus 22 Bits
inout   [7:0] FL_DQ,        // FLASH Data bus 8 Bits
// SRAM Interface
output        SRAM_CE_N,    // SRAM Chip Enable
output        SRAM_WE_N,    // SRAM Write Enable
output        SRAM_OE_N,    // SRAM Output Enable
output [17:0] SRAM_ADDR,    // SRAM Address bus 18 Bits
output  [1:0] SRAM_B_N,     // SRAM Byte Data Mask 
inout  [15:0] SRAM_DQ,      // SRAM Data bus 16 Bits
// SD_Card Interface
inout         SD_DAT,       // SD Card Data
inout         SD_DAT3,      // SD Card Data 3
inout         SD_CMD,       // SD Card Command Signal
output        SD_CLK,       // SD Card Clock
// USB JTAG link
input         TDI,          // CPLD -> FPGA (data in)
input         TCK,          // CPLD -> FPGA (clk)
input         TCS,          // CPLD -> FPGA (CS)
output        TDO,          // FPGA -> CPLD (data out)
// I2C
inout         I2C_SDAT,     // I2C Data
output        I2C_SCLK,     // I2C Clock
// PS2
inout         PS2_DAT,      // PS2 Data
inout         PS2_CLK,      // PS2 Clock
// VGA
output        VGA_HS,       // VGA H_SYNC
output        VGA_VS,       // VGA V_SYNC
output  [3:0] VGA_R,        // VGA Red[3:0]
output  [3:0] VGA_G,        // VGA Green[3:0]
output  [3:0] VGA_B,        // VGA Blue[3:0]
// Audio CODEC
inout         AUD_ADCLRCK,  // Audio CODEC ADC LR Clock
input         AUD_ADCDAT,   // Audio CODEC ADC Data
inout         AUD_DACLRCK,  // Audio CODEC DAC LR Clock
output        AUD_DACDAT,   // Audio CODEC DAC Data
inout         AUD_BCLK,     // Audio CODEC Bit-Stream Clock
output        AUD_XCK,      // Audio CODEC Chip Clock
// GPIO
inout  [35:0] GPIO_0,       // GPIO Connection 0
inout  [35:0] GPIO_1        // GPIO Connection 1
);

localparam FRQ = 24000000;  // 24MHz

// system clock and reset
wire clk, rst;

// debounced button signals
wire [3:0] btn;

// 7 segment display negated signals
wire [31:0] seg7;

// 1-wire
wire [1:0] owr_p;
wire [1:0] owr_e;
wire [1:0] owr_i;

// All inout port turn to tri-state
assign SD_DAT      = 1'bz;
//assign I2C_SDAT    = 1'bz;
assign AUD_ADCLRCK = 1'bz;
assign AUD_DACLRCK = 1'bz;
assign AUD_BCLK    = 1'bz;
assign GPIO_0      = 36'hzzzzzzzzz;
assign GPIO_1      = 36'hzzzzzzzzz;

// set system clock to 24MHz
assign clk = CLOCK_24[0];
assign rst = btn[0];

// debouncing of command buttons (buttons are active low)
debouncer #(.CN (FRQ/100)) debouncer_i [3:0] (.clk (clk), .d_i (~KEY), .d_o (btn));

// soc_nios RTL instance
soc soc_i (
  // 1) global signals:
  .clk                             (clk),
  .reset_n                         (~rst),
  // the_epcs_flash
  .ds_MISO_from_the_epcs_flash     (),
  // the_pio_7seg
  .out_port_from_the_pio_7seg      (seg7),
  // the_pio_ledg
  .out_port_from_the_pio_ledg      (LEDG),
  // the_pio_ledr
  .out_port_from_the_pio_ledr      (LEDR),
  // the_sdram
  .zs_cke_from_the_sdram           (DRAM_CKE),
  .zs_cs_n_from_the_sdram          (DRAM_CS_N),
  .zs_we_n_from_the_sdram          (DRAM_WE_N),
  .zs_cas_n_from_the_sdram         (DRAM_CAS_N),
  .zs_ras_n_from_the_sdram         (DRAM_RAS_N),
  .zs_ba_from_the_sdram            (DRAM_BA),
  .zs_addr_from_the_sdram          (DRAM_ADDR),
  .zs_dq_to_and_from_the_sdram     (DRAM_DQ),
  .zs_dqm_from_the_sdram           (DRAM_DQM),
  // the_tri_state_bridge_flash_avalon_slave
  .select_n_to_the_cfi_flash       (FL_CE_N),
  .write_n_to_the_cfi_flash        (FL_WE_N),
  .read_n_to_the_cfi_flash         (FL_OE_N),
  .address_to_the_cfi_flash        (FL_ADDR),
  .data_to_and_from_the_cfi_flash  (FL_DQ),
  // the_uart
  .rxd_to_the_uart                 (UART_TXD),
  .txd_from_the_uart               (UART_RXD),
  // onewire
  .owr_p_from_the_onewire          (owr_p),
  .owr_e_from_the_onewire          (owr_e),
  .owr_i_to_the_onewire            (owr_i)
);

// 1-wire
assign PS2_DAT = (owr_p [0] | owr_e [0]) ? owr_p [0] : 1'bz;
assign PS2_CLK = (owr_p [1] | owr_e [1]) ? owr_p [1] : 1'bz;
assign owr_i = {PS2_CLK, PS2_DAT};

// SDRAM Interface
assign DRAM_CLK = ~clk;  // SDRAM Clock
// Flash Interface
assign FL_RST_N = ~rst;  // FLASH Reset

// active low 7 segment outputs
assign HEX0 = ~seg7[0*8+:7];
assign HEX1 = ~seg7[1*8+:7];
assign HEX2 = ~seg7[2*8+:7];
assign HEX3 = ~seg7[3*8+:7];

endmodule
