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
//                      openMSP430 FPGA Top-level for the Diligent
//                     Spartan-3 starter kit.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 155 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-10-15 23:35:05 +0200 (Mon, 15 Oct 2012) $
//----------------------------------------------------------------------------
`include "openMSP430_defines.v"

module openMSP430_fpga (

// Clock Sources
    CLK_50MHz,
    CLK_SOCKET,

// Slide Switches
    SW7,
    SW6,
    SW5,
    SW4,
    SW3,
    SW2,
    SW1,
    SW0,

// Push Button Switches
    BTN3,
    BTN2,
    BTN1,
    BTN0,

// LEDs
    LED7,
    LED6,
    LED5,
    LED4,
    LED3,
    LED2,
    LED1,
    LED0,

// Four-Sigit, Seven-Segment LED Display
    SEG_A,
    SEG_B,
    SEG_C,
    SEG_D,
    SEG_E,
    SEG_F,
    SEG_G,
    SEG_DP,
    SEG_AN0,
    SEG_AN1,
    SEG_AN2,
    SEG_AN3,

// RS-232 Port
    UART_RXD,
    UART_TXD,
    UART_RXD_A,
    UART_TXD_A,

// PS/2 Mouse/Keyboard Port
    PS2_D,
    PS2_C,

// Fast, Asynchronous SRAM
    SRAM_A17,	            // Address Bus Connections
    SRAM_A16,
    SRAM_A15,
    SRAM_A14,
    SRAM_A13,
    SRAM_A12,
    SRAM_A11,
    SRAM_A10,
    SRAM_A9,
    SRAM_A8,
    SRAM_A7,
    SRAM_A6,
    SRAM_A5,
    SRAM_A4,
    SRAM_A3,
    SRAM_A2,
    SRAM_A1,
    SRAM_A0,
    SRAM_OE,                // Write enable and output enable control signals
    SRAM_WE,
    SRAM0_IO15,             // SRAM Data signals, chip enables, and byte enables
    SRAM0_IO14,
    SRAM0_IO13,
    SRAM0_IO12,
    SRAM0_IO11,
    SRAM0_IO10,
    SRAM0_IO9,
    SRAM0_IO8,
    SRAM0_IO7,
    SRAM0_IO6,
    SRAM0_IO5,
    SRAM0_IO4,
    SRAM0_IO3,
    SRAM0_IO2,
    SRAM0_IO1,
    SRAM0_IO0,
    SRAM0_CE1,
    SRAM0_UB1,
    SRAM0_LB1,
    SRAM1_IO15,
    SRAM1_IO14,
    SRAM1_IO13,
    SRAM1_IO12,
    SRAM1_IO11,
    SRAM1_IO10,
    SRAM1_IO9,
    SRAM1_IO8,
    SRAM1_IO7,
    SRAM1_IO6,
    SRAM1_IO5,
    SRAM1_IO4,
    SRAM1_IO3,
    SRAM1_IO2,
    SRAM1_IO1,
    SRAM1_IO0,
    SRAM1_CE2,
    SRAM1_UB2,
    SRAM1_LB2,

// VGA Port
    VGA_R,
    VGA_G,
    VGA_B,
    VGA_HS,
    VGA_VS
);

// Clock Sources
input     CLK_50MHz;
input     CLK_SOCKET;

// Slide Switches
input     SW7;
input     SW6;
input     SW5;
input     SW4;
input     SW3;
input     SW2;
input     SW1;
input     SW0;

// Push Button Switches
input     BTN3;
input     BTN2;
input     BTN1;
input     BTN0;

// LEDs
output    LED7;
output    LED6;
output    LED5;
output    LED4;
output    LED3;
output    LED2;
output    LED1;
output    LED0;

// Four-Sigit, Seven-Segment LED Display
output    SEG_A;
output    SEG_B;
output    SEG_C;
output    SEG_D;
output    SEG_E;
output    SEG_F;
output    SEG_G;
output    SEG_DP;
output    SEG_AN0;
output    SEG_AN1;
output    SEG_AN2;
output    SEG_AN3;

// RS-232 Port
input     UART_RXD;
output    UART_TXD;
input     UART_RXD_A;
output    UART_TXD_A;

// PS/2 Mouse/Keyboard Port
inout     PS2_D;
output    PS2_C;

// Fast, Asynchronous SRAM
output    SRAM_A17;	    // Address Bus Connections
output    SRAM_A16;
output    SRAM_A15;
output    SRAM_A14;
output    SRAM_A13;
output    SRAM_A12;
output    SRAM_A11;
output    SRAM_A10;
output    SRAM_A9;
output    SRAM_A8;
output    SRAM_A7;
output    SRAM_A6;
output    SRAM_A5;
output    SRAM_A4;
output    SRAM_A3;
output    SRAM_A2;
output    SRAM_A1;
output    SRAM_A0;
output    SRAM_OE;          // Write enable and output enable control signals
output    SRAM_WE;
inout     SRAM0_IO15;       // SRAM Data signals, chip enables, and byte enables
inout     SRAM0_IO14;
inout     SRAM0_IO13;
inout     SRAM0_IO12;
inout     SRAM0_IO11;
inout     SRAM0_IO10;
inout     SRAM0_IO9;
inout     SRAM0_IO8;
inout     SRAM0_IO7;
inout     SRAM0_IO6;
inout     SRAM0_IO5;
inout     SRAM0_IO4;
inout     SRAM0_IO3;
inout     SRAM0_IO2;
inout     SRAM0_IO1;
inout     SRAM0_IO0;
output    SRAM0_CE1;
output    SRAM0_UB1;
output    SRAM0_LB1;
inout     SRAM1_IO15;
inout     SRAM1_IO14;
inout     SRAM1_IO13;
inout     SRAM1_IO12;
inout     SRAM1_IO11;
inout     SRAM1_IO10;
inout     SRAM1_IO9;
inout     SRAM1_IO8;
inout     SRAM1_IO7;
inout     SRAM1_IO6;
inout     SRAM1_IO5;
inout     SRAM1_IO4;
inout     SRAM1_IO3;
inout     SRAM1_IO2;
inout     SRAM1_IO1;
inout     SRAM1_IO0;
output    SRAM1_CE2;
output    SRAM1_UB2;
output    SRAM1_LB2;

// VGA Port
output    VGA_R;
output    VGA_G;
output    VGA_B;
output    VGA_HS;
output    VGA_VS;


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
wire   	    [13:0] irq_bus;
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

// Simple UART
wire               irq_uart_rx;
wire               irq_uart_tx;
wire        [15:0] per_dout_uart;
wire               hw_uart_txd;
wire               hw_uart_rxd;

      
// Others
wire               reset_pin;


//=============================================================================
// 2)  CLOCK GENERATION
//=============================================================================

// Input buffers
//------------------------
IBUFG ibuf_clk_main   (.O(clk_50M_in),    .I(CLK_50MHz));
IBUFG ibuf_clk_socket (.O(clk_socket_in), .I(CLK_SOCKET));


// Digital Clock Manager
//------------------------

// Generate 20MHz clock from 50MHz on-board oscillator
//`define DCM_FX_MODE
`ifdef DCM_FX_MODE
DCM dcm_adv_clk_main (

// OUTPUTs
    .CLK0         (),
    .CLK90        (),
    .CLK180       (),
    .CLK270       (),
    .CLK2X        (), 
    .CLK2X180     (),
    .CLKDV        (),
    .CLKFX        (dcm_clk),
    .CLKFX180     (),
    .PSDONE       (), 
    .STATUS       (),
    .LOCKED       (dcm_locked),

// INPUTs
    .CLKIN        (clk_50M_in),
    .CLKFB        (1'b0),
    .PSINCDEC     (1'b0),
    .PSEN         (1'b0),
    .DSSEN        (1'b0),
    .RST          (reset_pin),
    .PSCLK        (1'b0)
);

// synopsys translate_off
defparam dcm_adv_clk_main.CLK_FEEDBACK          = "NONE";
defparam dcm_adv_clk_main.CLKDV_DIVIDE          = 2.5;
defparam dcm_adv_clk_main.CLKIN_DIVIDE_BY_2     = "FALSE";
defparam dcm_adv_clk_main.CLKIN_PERIOD          = 20.0;
defparam dcm_adv_clk_main.CLKOUT_PHASE_SHIFT    = "NONE";
defparam dcm_adv_clk_main.DESKEW_ADJUST         = "SYSTEM_SYNCHRONOUS";
defparam dcm_adv_clk_main.DFS_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DLL_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DUTY_CYCLE_CORRECTION = "TRUE";
defparam dcm_adv_clk_main.FACTORY_JF            = 16'hC080;
defparam dcm_adv_clk_main.PHASE_SHIFT           = 0;
defparam dcm_adv_clk_main.STARTUP_WAIT          = "FALSE";

defparam dcm_adv_clk_main.CLKFX_DIVIDE          = 5;
defparam dcm_adv_clk_main.CLKFX_MULTIPLY        = 2;
// synopsys translate_on
`else
DCM dcm_adv_clk_main (

// OUTPUTs
    .CLKDV        (dcm_clk), 
    .CLKFX        (), 
    .CLKFX180     (), 
    .CLK0         (CLK0_BUF), 
    .CLK2X        (), 
    .CLK2X180     (), 
    .CLK90        (), 
    .CLK180       (), 
    .CLK270       (), 
    .LOCKED       (dcm_locked), 
    .PSDONE       (), 
    .STATUS       (),

// INPUTs
    .CLKFB        (CLKFB_IN), 
    .CLKIN        (clk_50M_in), 
    .PSEN         (1'b0), 
    .PSINCDEC     (1'b0), 
    .DSSEN        (1'b0), 
    .PSCLK        (1'b0), 
    .RST          (reset_pin) 
);
BUFG CLK0_BUFG_INST (
    .I(CLK0_BUF), 
    .O(CLKFB_IN)
);

// synopsys translate_off
defparam dcm_adv_clk_main.CLK_FEEDBACK          = "1X";
defparam dcm_adv_clk_main.CLKDV_DIVIDE          = 2.5;
defparam dcm_adv_clk_main.CLKFX_DIVIDE          = 1;
defparam dcm_adv_clk_main.CLKFX_MULTIPLY        = 4;
defparam dcm_adv_clk_main.CLKIN_DIVIDE_BY_2     = "FALSE";
defparam dcm_adv_clk_main.CLKIN_PERIOD          = 20.000;
defparam dcm_adv_clk_main.CLKOUT_PHASE_SHIFT    = "NONE";
defparam dcm_adv_clk_main.DESKEW_ADJUST         = "SYSTEM_SYNCHRONOUS";
defparam dcm_adv_clk_main.DFS_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DLL_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DUTY_CYCLE_CORRECTION = "TRUE";
defparam dcm_adv_clk_main.FACTORY_JF            = 16'h8080;
defparam dcm_adv_clk_main.PHASE_SHIFT           = 0;
defparam dcm_adv_clk_main.STARTUP_WAIT          = "FALSE";
// synopsys translate_on  
`endif

   
//wire 	  dcm_locked = 1'b1;
//wire      reset_n;
   
//reg 	  dcm_clk;
//always @(posedge clk_50M_in)
//  if (~reset_n) dcm_clk <= 1'b0;
//  else          dcm_clk <= ~dcm_clk;
   

// Clock buffers
//------------------------
BUFG  buf_sys_clock  (.O(clk_sys), .I(dcm_clk));


//=============================================================================
// 3)  RESET GENERATION & FPGA STARTUP
//=============================================================================

// Reset input buffer
IBUF   ibuf_reset_n   (.O(reset_pin), .I(BTN3));
wire reset_pin_n = ~reset_pin;

// Release the reset only, if the DCM is locked
assign  reset_n = reset_pin_n & dcm_locked;

//Include the startup device   
wire  gsr_tb;
wire  gts_tb;
STARTUP_SPARTAN3 xstartup (.CLK(clk_sys), .GSR(gsr_tb), .GTS(gts_tb));


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

driver_7segment driver_7segment_0 (

// OUTPUTs
    .per_dout     (per_dout_7seg), // Peripheral data output
    .seg_a        (seg_a_),        // Segment A control
    .seg_b        (seg_b_),        // Segment B control
    .seg_c        (seg_c_),        // Segment C control
    .seg_d        (seg_d_),        // Segment D control
    .seg_e        (seg_e_),        // Segment E control
    .seg_f        (seg_f_),        // Segment F control
    .seg_g        (seg_g_),        // Segment G control
    .seg_dp       (seg_dp_),       // Segment DP control
    .seg_an0      (seg_an0_),      // Anode 0 control
    .seg_an1      (seg_an1_),      // Anode 1 control
    .seg_an2      (seg_an2_),      // Anode 2 control
    .seg_an3      (seg_an3_),      // Anode 3 control

// INPUTs
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst)        // Main system reset
);


//
// Simple full duplex UART (8N1 protocol)
//----------------------------------------

omsp_uart #(.BASE_ADDR(15'h0080)) uart_0 (

// OUTPUTs
    .irq_uart_rx  (irq_uart_rx),   // UART receive interrupt
    .irq_uart_tx  (irq_uart_tx),   // UART transmit interrupt
    .per_dout     (per_dout_uart), // Peripheral data output
    .uart_txd     (hw_uart_txd),   // UART Data Transmit (TXD)

// INPUTs
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .uart_rxd     (hw_uart_rxd)    // UART Data Receive (RXD)
);


//
// Combine peripheral data buses
//-------------------------------

assign per_dout = per_dout_dio  |
                  per_dout_tA   |
                  per_dout_7seg |
                  per_dout_uart;
   
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
                     irq_uart_rx,  // Vector  7  (0xFFEE)
                     irq_uart_tx,  // Vector  6  (0xFFEC)
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
// 6)  PROGRAM AND DATA MEMORIES
//=============================================================================

// Data Memory
ram_8x512_hi ram_8x512_hi_0 (
    .addr         (dmem_addr),
    .clk          (clk_sys),
    .din          (dmem_din[15:8]),
    .dout         (dmem_dout[15:8]),
    .en           (dmem_cen),
    .we           (dmem_wen[1])
);
ram_8x512_lo ram_8x512_lo_0 (
    .addr         (dmem_addr),
    .clk          (clk_sys),
    .din          (dmem_din[7:0]),
    .dout         (dmem_dout[7:0]),
    .en           (dmem_cen),
    .we           (dmem_wen[0])
);


// Program Memory
rom_8x2k_hi rom_8x2k_hi_0 (
    .addr         (pmem_addr),
    .clk          (clk_sys),
    .din          (pmem_din[15:8]),
    .dout         (pmem_dout[15:8]),
    .en           (pmem_cen),
    .we           (pmem_wen[1])
);

rom_8x2k_lo rom_8x2k_lo_0 (
    .addr         (pmem_addr),
    .clk          (clk_sys),
    .din          (pmem_din[7:0]),
    .dout         (pmem_dout[7:0]),
    .en           (pmem_cen),
    .we           (pmem_wen[0])
);



//=============================================================================
// 7)  I/O CELLS
//=============================================================================


// Slide Switches (Port 1 inputs)
//--------------------------------
IBUF  SW7_PIN        (.O(p3_din[7]),                   .I(SW7));
IBUF  SW6_PIN        (.O(p3_din[6]),                   .I(SW6));
IBUF  SW5_PIN        (.O(p3_din[5]),                   .I(SW5));
IBUF  SW4_PIN        (.O(p3_din[4]),                   .I(SW4));
IBUF  SW3_PIN        (.O(p3_din[3]),                   .I(SW3));
IBUF  SW2_PIN        (.O(p3_din[2]),                   .I(SW2));
IBUF  SW1_PIN        (.O(p3_din[1]),                   .I(SW1));
IBUF  SW0_PIN        (.O(p3_din[0]),                   .I(SW0));

// LEDs (Port 1 outputs)
//-----------------------
OBUF  LED7_PIN       (.I(p3_dout[7] & p3_dout_en[7]),  .O(LED7));
OBUF  LED6_PIN       (.I(p3_dout[6] & p3_dout_en[6]),  .O(LED6));
OBUF  LED5_PIN       (.I(p3_dout[5] & p3_dout_en[5]),  .O(LED5));
OBUF  LED4_PIN       (.I(p3_dout[4] & p3_dout_en[4]),  .O(LED4));
OBUF  LED3_PIN       (.I(p3_dout[3] & p3_dout_en[3]),  .O(LED3));
OBUF  LED2_PIN       (.I(p3_dout[2] & p3_dout_en[2]),  .O(LED2));
OBUF  LED1_PIN       (.I(p3_dout[1] & p3_dout_en[1]),  .O(LED1));
OBUF  LED0_PIN       (.I(p3_dout[0] & p3_dout_en[0]),  .O(LED0));
   
// Push Button Switches
//----------------------
IBUF  BTN2_PIN       (.O(),                            .I(BTN2));
IBUF  BTN1_PIN       (.O(),                            .I(BTN1));
IBUF  BTN0_PIN       (.O(),                            .I(BTN0));

// Four-Sigit, Seven-Segment LED Display
//---------------------------------------
OBUF  SEG_A_PIN      (.I(seg_a_),                      .O(SEG_A));
OBUF  SEG_B_PIN      (.I(seg_b_),                      .O(SEG_B));
OBUF  SEG_C_PIN      (.I(seg_c_),                      .O(SEG_C));
OBUF  SEG_D_PIN      (.I(seg_d_),                      .O(SEG_D));
OBUF  SEG_E_PIN      (.I(seg_e_),                      .O(SEG_E));
OBUF  SEG_F_PIN      (.I(seg_f_),                      .O(SEG_F));
OBUF  SEG_G_PIN      (.I(seg_g_),                      .O(SEG_G));
OBUF  SEG_DP_PIN     (.I(seg_dp_),                     .O(SEG_DP));
OBUF  SEG_AN0_PIN    (.I(seg_an0_),                    .O(SEG_AN0));
OBUF  SEG_AN1_PIN    (.I(seg_an1_),                    .O(SEG_AN1));
OBUF  SEG_AN2_PIN    (.I(seg_an2_),                    .O(SEG_AN2));
OBUF  SEG_AN3_PIN    (.I(seg_an3_),                    .O(SEG_AN3));

// RS-232 Port
//----------------------
// P1.1 (TX) and P2.2 (RX)
assign p1_io_din      = 8'h00;
assign p2_io_din[7:3] = 5'h00;
assign p2_io_din[1:0] = 2'h0;

// Mux the RS-232 port between:
//   - GPIO port P1.1 (TX) / P2.2 (RX)
//   - the debug interface.
//   - the simple hardware UART
//
// The mux is controlled with the SW0/SW1 switches:
//        00 = debug interface
//        01 = GPIO
//        10 = simple hardware uart
//        11 = debug interface
wire sdi_select  = ({p3_din[1], p3_din[0]}==2'b00) |
                   ({p3_din[1], p3_din[0]}==2'b11);
wire gpio_select = ({p3_din[1], p3_din[0]}==2'b01);
wire uart_select = ({p3_din[1], p3_din[0]}==2'b10);

wire   uart_txd_out = gpio_select ? p1_io_dout[1]  :
                      uart_select ? hw_uart_txd    : dbg_uart_txd;

wire   uart_rxd_in;
assign p2_io_din[2] = gpio_select ? uart_rxd_in : 1'b1;
assign hw_uart_rxd  = uart_select ? uart_rxd_in : 1'b1;
assign dbg_uart_rxd = sdi_select  ? uart_rxd_in : 1'b1;

IBUF  UART_RXD_PIN   (.O(uart_rxd_in),                 .I(UART_RXD));
OBUF  UART_TXD_PIN   (.I(uart_txd_out),                .O(UART_TXD));

IBUF  UART_RXD_A_PIN (.O(),                            .I(UART_RXD_A));
OBUF  UART_TXD_A_PIN (.I(1'b0),                        .O(UART_TXD_A));

   
// PS/2 Mouse/Keyboard Port
//--------------------------
IOBUF PS2_D_PIN      (.O(), .I(1'b0), .T(1'b1),        .IO(PS2_D));
OBUF  PS2_C_PIN      (.I(1'b0),                        .O(PS2_C));

// Fast, Asynchronous SRAM
//--------------------------
OBUF  SRAM_A17_PIN   (.I(1'b0),                        .O(SRAM_A17));
OBUF  SRAM_A16_PIN   (.I(1'b0),                        .O(SRAM_A16));
OBUF  SRAM_A15_PIN   (.I(1'b0),                        .O(SRAM_A15));
OBUF  SRAM_A14_PIN   (.I(1'b0),                        .O(SRAM_A14));
OBUF  SRAM_A13_PIN   (.I(1'b0),                        .O(SRAM_A13));
OBUF  SRAM_A12_PIN   (.I(1'b0),                        .O(SRAM_A12));
OBUF  SRAM_A11_PIN   (.I(1'b0),                        .O(SRAM_A11));
OBUF  SRAM_A10_PIN   (.I(1'b0),                        .O(SRAM_A10));
OBUF  SRAM_A9_PIN    (.I(1'b0),                        .O(SRAM_A9));
OBUF  SRAM_A8_PIN    (.I(1'b0),                        .O(SRAM_A8));
OBUF  SRAM_A7_PIN    (.I(1'b0),                        .O(SRAM_A7));
OBUF  SRAM_A6_PIN    (.I(1'b0),                        .O(SRAM_A6));
OBUF  SRAM_A5_PIN    (.I(1'b0),                        .O(SRAM_A5));
OBUF  SRAM_A4_PIN    (.I(1'b0),                        .O(SRAM_A4));
OBUF  SRAM_A3_PIN    (.I(1'b0),                        .O(SRAM_A3));
OBUF  SRAM_A2_PIN    (.I(1'b0),                        .O(SRAM_A2));
OBUF  SRAM_A1_PIN    (.I(1'b0),                        .O(SRAM_A1));
OBUF  SRAM_A0_PIN    (.I(1'b0),                        .O(SRAM_A0));
OBUF  SRAM_OE_PIN    (.I(1'b1),                        .O(SRAM_OE));
OBUF  SRAM_WE_PIN    (.I(1'b1),                        .O(SRAM_WE));
IOBUF SRAM0_IO15_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO15));
IOBUF SRAM0_IO14_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO14));
IOBUF SRAM0_IO13_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO13));
IOBUF SRAM0_IO12_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO12));
IOBUF SRAM0_IO11_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO11));
IOBUF SRAM0_IO10_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO10));
IOBUF SRAM0_IO9_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO9));
IOBUF SRAM0_IO8_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO8));
IOBUF SRAM0_IO7_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO7));
IOBUF SRAM0_IO6_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO6));
IOBUF SRAM0_IO5_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO5));
IOBUF SRAM0_IO4_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO4));
IOBUF SRAM0_IO3_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO3));
IOBUF SRAM0_IO2_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO2));
IOBUF SRAM0_IO1_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO1));
IOBUF SRAM0_IO0_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO0));
OBUF  SRAM0_CE1_PIN  (.I(1'b1),                        .O(SRAM0_CE1));
OBUF  SRAM0_UB1_PIN  (.I(1'b1),                        .O(SRAM0_UB1));
OBUF  SRAM0_LB1_PIN  (.I(1'b1),                        .O(SRAM0_LB1));
IOBUF SRAM1_IO15_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO15));
IOBUF SRAM1_IO14_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO14));
IOBUF SRAM1_IO13_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO13));
IOBUF SRAM1_IO12_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO12));
IOBUF SRAM1_IO11_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO11));
IOBUF SRAM1_IO10_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO10));
IOBUF SRAM1_IO9_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO9));
IOBUF SRAM1_IO8_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO8));
IOBUF SRAM1_IO7_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO7));
IOBUF SRAM1_IO6_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO6));
IOBUF SRAM1_IO5_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO5));
IOBUF SRAM1_IO4_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO4));
IOBUF SRAM1_IO3_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO3));
IOBUF SRAM1_IO2_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO2));
IOBUF SRAM1_IO1_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO1));
IOBUF SRAM1_IO0_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO0));
OBUF  SRAM1_CE2_PIN  (.I(1'b1),                        .O(SRAM1_CE2));
OBUF  SRAM1_UB2_PIN  (.I(1'b1),                        .O(SRAM1_UB2));
OBUF  SRAM1_LB2_PIN  (.I(1'b1),                        .O(SRAM1_LB2));

// VGA Port
//---------------------------------------
OBUF  VGA_R_PIN      (.I(1'b0),                        .O(VGA_R));
OBUF  VGA_G_PIN      (.I(1'b0),                        .O(VGA_G));
OBUF  VGA_B_PIN      (.I(1'b0),                        .O(VGA_B));
OBUF  VGA_HS_PIN     (.I(1'b0),                        .O(VGA_HS));
OBUF  VGA_VS_PIN     (.I(1'b0),                        .O(VGA_VS));


endmodule // openMSP430_fpga

