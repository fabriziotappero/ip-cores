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
//                      openMSP430 FPGA Top-level for the Xilinx synthesis.
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
`include "openMSP430_defines.v"
`include "arch.v"
  
module openMSP430_fpga (

// OUTPUTs
    aclk_en,                      // ACLK enable
    dbg_freeze,                   // Freeze peripherals
    dbg_uart_txd,                 // Debug interface: UART TXD
    irq_acc,                      // Interrupt request accepted (one-hot signal)
    per_addr,                     // Peripheral address
    per_din,                      // Peripheral data input
    per_wen,                      // Peripheral write enable (high active)
    per_en,                       // Peripheral enable (high active)
    smclk_en,                     // SMCLK enable

// INPUTs
    dbg_uart_rxd,                 // Debug interface: UART RXD
    dco_clk,                      // Fast oscillator (fast clock)
    irq,                          // Maskable interrupts
    lfxt_clk,                     // Low frequency oscillator (typ 32kHz)
    nmi,                          // Non-maskable interrupt (asynchronous)
    per_dout,                     // Peripheral data output
    reset_n                       // Reset Pin (low active)
);

// OUTPUTs
//=========
output              aclk_en;      // ACLK enable
output              dbg_freeze;   // Freeze peripherals
output              dbg_uart_txd; // Debug interface: UART TXD
output       [13:0] irq_acc;      // Interrupt request accepted (one-hot signal)
output        [7:0] per_addr;     // Peripheral address
output       [15:0] per_din;      // Peripheral data input
output        [1:0] per_wen;      // Peripheral write enable (high active)
output              per_en;       // Peripheral enable (high active)
output              smclk_en;     // SMCLK enable


// INPUTs
//=========
input               dbg_uart_rxd; // Debug interface: UART RXD
input               dco_clk;      // Fast oscillator (fast clock)
input  	     [13:0] irq;          // Maskable interrupts
input               lfxt_clk;     // Low frequency oscillator (typ 32kHz)
input  	            nmi;          // Non-maskable interrupt (asynchronous)
input        [15:0] per_dout;     // Peripheral data output
input               reset_n;      // Reset Pin (active low)


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

wire                mclk;
wire                puc;

  
//=============================================================================
// 2)  PROGRAM AND DATA MEMORIES
//=============================================================================

`ifdef SPARTAN3
spartan3_pmem pmem_hi (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen[1]), .addra(pmem_addr), .dina(pmem_din[15:8]), .douta(pmem_dout[15:8]));
spartan3_pmem pmem_lo (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen[0]), .addra(pmem_addr), .dina(pmem_din[7:0]),  .douta(pmem_dout[7:0]));
spartan3_dmem dmem_hi (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen[1]), .addra(dmem_addr), .dina(dmem_din[15:8]), .douta(dmem_dout[15:8]));
spartan3_dmem dmem_lo (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen[0]), .addra(dmem_addr), .dina(dmem_din[7:0]),  .douta(dmem_dout[7:0]));
`endif
`ifdef SPARTAN3E
spartan3e_pmem pmem_hi (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen[1]), .addra(pmem_addr), .dina(pmem_din[15:8]), .douta(pmem_dout[15:8]));
spartan3e_pmem pmem_lo (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen[0]), .addra(pmem_addr), .dina(pmem_din[7:0]),  .douta(pmem_dout[7:0]));
spartan3e_dmem dmem_hi (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen[1]), .addra(dmem_addr), .dina(dmem_din[15:8]), .douta(dmem_dout[15:8]));
spartan3e_dmem dmem_lo (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen[0]), .addra(dmem_addr), .dina(dmem_din[7:0]),  .douta(dmem_dout[7:0]));
`endif
`ifdef SPARTAN3A
spartan3a_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
spartan3a_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif
`ifdef SPARTAN3ADSP
spartan3adsp_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
spartan3adsp_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif
`ifdef SPARTAN6
spartan6_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
spartan6_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif
`ifdef VIRTEX4
virtex4_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
virtex4_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif
`ifdef VIRTEX5
virtex5_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
virtex5_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif
`ifdef VIRTEX6
virtex6_pmem pmem (.clka(mclk), .ena(~pmem_cen), .wea(~pmem_wen), .addra(pmem_addr), .dina(pmem_din), .douta(pmem_dout));
virtex6_dmem dmem (.clka(mclk), .ena(~dmem_cen), .wea(~dmem_wen), .addra(dmem_addr), .dina(dmem_din), .douta(dmem_dout));
`endif


//=============================================================================
// 3)  OPENMSP430
//=============================================================================

openMSP430 openMSP430_0 (

// OUTPUTs
    .aclk_en      (aclk_en),      // ACLK enable
    .dbg_freeze   (dbg_freeze),   // Freeze peripherals
    .dbg_uart_txd (dbg_uart_txd), // Debug interface: UART TXD
    .dmem_addr    (dmem_addr),    // Data Memory address
    .dmem_cen     (dmem_cen),     // Data Memory chip enable (low active)
    .dmem_din     (dmem_din),     // Data Memory data input
    .dmem_wen     (dmem_wen),     // Data Memory write enable (low active)
    .irq_acc      (irq_acc),      // Interrupt request accepted (one-hot signal)
    .mclk         (mclk),         // Main system clock
    .per_addr     (per_addr),     // Peripheral address
    .per_din      (per_din),      // Peripheral data input
    .per_wen      (per_wen),      // Peripheral write enable (high active)
    .per_en       (per_en),       // Peripheral enable (high active)
    .pmem_addr    (pmem_addr),    // Program Memory address
    .pmem_cen     (pmem_cen),     // Program Memory chip enable (low active)
    .pmem_din     (pmem_din),     // Program Memory data input (optional)
    .pmem_wen     (pmem_wen),     // Program Memory write enable (low active) (optional)
    .puc          (puc),          // Main system reset
    .smclk_en     (smclk_en),     // SMCLK enable

// INPUTs
    .dbg_uart_rxd (dbg_uart_rxd), // Debug interface: UART RXD
    .dco_clk      (dco_clk),      // Fast oscillator (fast clock)
    .dmem_dout    (dmem_dout),    // Data Memory data output
    .irq          (irq),          // Maskable interrupts
    .lfxt_clk     (lfxt_clk),     // Low frequency oscillator (typ 32kHz)
    .nmi          (nmi),          // Non-maskable interrupt (asynchronous)
    .per_dout     (per_dout),     // Peripheral data output
    .pmem_dout    (pmem_dout),    // Program Memory data output
    .reset_n      (reset_n)       // Reset Pin (low active)
);

   

endmodule // openMSP430_fpga

