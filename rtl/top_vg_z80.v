//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: top_vg_z80.v,v 1.4 2008-12-15 06:44:47 hharte Exp $    ////
////  top_sk_z80.v - Z80 SBC Based on Xilinx S3E Starter Kit      ////
////                 Top-Level                                    ////
////                                                              ////
////  This file is part of the Vector Graphic Z80 SBC Project     ////
////  http://www.opencores.org/projects/vg_z80_sbc/               ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//+---------------------------------------------------------------------------+
//| 16 1MB Address Regions:
//| 
//| 0:00000 - Wishbone I/O
//| 1:00000 - SRAM (32k)
//| 2:00000 - FLASH (512K) (really 8K SRAM for now)
//| 6:00000 - VGA Controller
//| 8:00000 - DDR SDRAM    (really 4K SRAM for now)
//| 
//| 16 4K Entries:
//| 
//| 0:00xxx - Lower <xxx> 12 address bits are passed through unchanged.
//| 
//| Mapping register (MMR) is divided into two fields:
//| 
//| Upper 4-bits = MMR_H  <h>
//| Lower 8-bits = MMR_L  <ll>
//| 
//| forms the final 24-bit address as follows:
//| 
//| <h>:<llxxx>
//| 
//| This provides for 16MB of address space from 64K,
//|
//| In the Z80's 64K address space, the mapping is configured by default as
//| follows:
//|
//| 0000-0FFF - 4K SRAM containing shadow copy of Monitor, only used to jump to monitor at 0xE000.
//| 1000-1FFF - 4K SRAM
//| 2000-2FFF - 4K SRAM
//| 3000-3FFF - Shadow of 2000-2FFF
//| 4000-4FFF - Shadow of 2000-2FFF
//| 5000-5FFF - Shadow of 2000-2FFF
//| 6000-6FFF - Shadow of 2000-2FFF
//| 7000-7FFF - Shadow of 2000-2FFF
//| 8000-8FFF - Shadow of 2000-2FFF
//| 9000-9FFF - Shadow of 2000-2FFF
//| A000-AFFF - Shadow of 2000-2FFF
//| B000-BFFF - 4K SRAM
//| C000-CFFF - 4K SRAM
//| D000-DFFF - 4K SRAM
//| E000-EFFF - 4K SRAM Containing Vector Graphics Monitor 4.0C (serial) or 4.3 (flashwriter)
//| F000-FFFF - Flashwriter 2 Dual-port SRAM
//|
//| I/O Port Map
//| 00-01 - Keyboard
//| 02-03 - Console UART
//| 04-05 - AUX UART
//| 06-07 - Third UART (not bonded out)
//| 08-1F - Shadow of 00-07
//| 20-23 - MMU
//| 24-3F - Shadow of 20-23
//| 40-7F - CPU Ctrl (test registers for now.)
//| 60-63 - MMU
//| 80-BF - spiMaster
//| C0-C3 - HD/FD Disk Controller
//| C4-C7 - HD/FD Disk Controller Diagnostic Registers
//| C8-DF - Shadow of C0-C7
//| E0-FF - FPB - FF = Programmed Output (LEDs)
//| 
//| This design runs on the Xilinx Spartan-3E Starter Kit with XC3S500E FPGA.
//| There are issues with the SDRAM controller, but everything else seems to
//| work fine.
//|
//| There is slightly more than 2K of RAM
//| available above the display-visible area of the Flashwriter2, from
//| F780-FFFFh.  This can be used as general-purpose RAM, but be aware that
//| the monitor uses some of this RAM for its stack and some temporary
//| variables.
//+---------------------------------------------------------------------------+

`include "ddr_include.v"

`define USE_INTERNAL_RAM

module vg_z80_sbc
(
    CLK,
    RST, // Active Low

    PS2_KBD_CLK,
    PS2_KBD_DAT,
    CONS_UART_TXD,
    CONS_UART_RXD,
    AUX_UART_TXD,
    AUX_UART_RXD,

    FLASH_A,
    FLASH_D,
    FLASH_CE,
    FLASH_OE,
    FLASH_WE,
    FLASH_BYTE,
     
    SD_A,
    SD_DQ,
    SD_BA,
    SD_CAS,
    SD_CK_N,
    SD_CK_P,
    SD_CKE,
    SD_CS,
     
    SD_DM,
    SD_DQS,
    SD_RAS,
    SD_WE,
    SD_CK_FB,

    rot,

    hsync,
    vsync,
    R,
    G,
    B,
    
    SD_SPI_CLK, 
    SD_SPI_MISO, 
    SD_SPI_MOSI, 
    SD_SPI_CS_N,

    LED,
    SW,
    LCD_E,
    LCD_RS,
    LCD_RW,
    LCD_D
    
);

input         CLK ;
input         RST ;

// UARTs
output        CONS_UART_TXD;
input         CONS_UART_RXD;
output        AUX_UART_TXD;
input         AUX_UART_RXD;

// FLASH Memory Interface
output [23:0] FLASH_A;
inout   [7:0] FLASH_D;
output        FLASH_CE;
output        FLASH_OE;
output        FLASH_WE;
output        FLASH_BYTE;

// VGA
output             hsync, vsync, R, G, B;

// PS/2
inout              PS2_KBD_CLK;
inout              PS2_KBD_DAT;

// The DDR interface has problems.  Seems like the caching has trouble.  It is commented out for now,
// and 8K of SRAM is in its place.
// DDR Interface
output             SD_CAS;
output             SD_CK_N;
output             SD_CK_P;
output             SD_CKE;
output             SD_CS;
     
output             SD_RAS;
output             SD_WE;
input              SD_CK_FB;

output [  `A_RNG]  SD_A;
output [ `BA_RNG]  SD_BA;
inout  [ `DQ_RNG]  SD_DQ;
inout  [`DQS_RNG]  SD_DQS;
output [ `DM_RNG]  SD_DM;

input  [2:0]       rot;

output    SD_SPI_CLK;
input     SD_SPI_MISO;
output    SD_SPI_MOSI; 
output    SD_SPI_CS_N;   

output       [7:0] LED;
input        [3:0] SW;

output             LCD_E;
output             LCD_RS;
output             LCD_RW;
output       [3:0] LCD_D;


wire    NRST = !RST;

wire  [7:0] flash_dat_i;
wire  [7:0] flash_dat_o;
wire [23:0] flash_adr_o;
wire        flash_ce_o, flash_oe_o, flash_we_o;

reg clk25mhz;

// Generate 25MHz Clock from 50MHz clock input
always @(posedge CLK or posedge RST)
    if (RST)
        begin
            clk25mhz <= 1'b0;
        end else begin
            clk25mhz <= !clk25mhz;
        end

assign FLASH_A = flash_adr_o; //{5'b0,flash_adr_o};
assign FLASH_D = (!flash_we_o) ? flash_dat_o : 8'bZZZZZZZZ;
assign flash_dat_i = FLASH_D;
assign FLASH_CE = flash_ce_o;
assign FLASH_OE = flash_oe_o;
assign FLASH_WE = flash_we_o;
assign FLASH_BYTE = 1'b0;

wire [15:0] rgb_int ;
// WISHBONE slave interface
wire    [31:0]  ADR_I = 32'h00000000;
wire    [31:0]  SDAT_I = 32'hffffffff;
wire    [31:0]  SDAT_O ;
wire    [3:0]   SEL_I = 1'b0;
wire            CYC_I = 1'b0;
wire            STB_I = 1'b0;
wire            WE_I  = 1'b0;
wire            CAB_I = 1'b0;
wire            ACK_O ;
wire            RTY_O ;
wire            ERR_O ;

// WISHBONE master interface
wire [31:0]  ADR_O ;
wire [31:0]  MDAT_I; 
wire [31:0]  MDAT_O = 32'h00000000;
wire [3:0]   SEL_O = 4'b0000;
wire         CYC_O = 1'b0;
wire         STB_O = 1'b0;
wire         WE_O  = 1'b0;
wire         CAB_O = 1'b0;
wire         ACK_I;
wire         RTY_I;
wire         ERR_I;

wire         PCI_CLK = clk25mhz;

wire [31:0] wb_z80_dat_o;
wire        wb_z80_stb_o;
wire        wb_z80_cyc_o;
wire        wb_z80_we_o;
wire [15:0] wb_z80_adr_o;
wire [1:0]  wb_z80_tga_o;
wire        wb_z80_ack_i;
wire [31:0] wb_z80_dat_i;
wire        z80_int_req_i = 1'b0;
wire        wb_z80_err_i;
wire [3:0]  wb_z80_sel_o;

wire [7:0]  wb_z80_be_dat_i;    // dat moved to correct byte lane depending on sel lines.
wire [7:0]  wb_z80_final_dat_i;

wire        z80_mem_hit;
assign z80_mem_hit = wb_z80_tga_o == 2'b00;

assign wb_z80_sel_o = wb_z80_adr_o[1:0] == 2'b00 ? 4'b0001 :
                      wb_z80_adr_o[1:0] == 2'b01 ? 4'b0010 : 
                      wb_z80_adr_o[1:0] == 2'b10 ? 4'b0100 : 4'b1000;

assign wb_z80_dat_o[15:8]  = wb_z80_dat_o[7:0];
assign wb_z80_dat_o[23:16] = wb_z80_dat_o[7:0];
assign wb_z80_dat_o[31:24] = wb_z80_dat_o[7:0];

assign wb_z80_be_dat_i = wb_z80_adr_o[1:0] == 2'b00 ? wb_z80_dat_i[7:0] :
                         wb_z80_adr_o[1:0] == 2'b01 ? wb_z80_dat_i[15:8] : 
                         wb_z80_adr_o[1:0] == 2'b10 ? wb_z80_dat_i[23:16] : wb_z80_dat_i[31:24];

assign wb_z80_final_dat_i = z80_mem_hit ? wb_z80_be_dat_i : wb_z80_dat_i[7:0]; 

`define USE_WB_Z80      // Select wb_z80 CPU core instead of TV80 CPU Core.
`ifdef USE_WB_Z80
// Instantiate the Wishbone Z80 Core
z80_core_top z80cpu (
    .wb_clk_i(PCI_CLK), 
    .wb_rst_i(RST), 
    .wb_adr_o(wb_z80_adr_o), 
    .wb_tga_o(wb_z80_tga_o), 
    .wb_dat_i(wb_z80_final_dat_i),
    .wb_dat_o(wb_z80_dat_o[7:0]), 
    .wb_cyc_o(wb_z80_cyc_o), 
    .wb_stb_o(wb_z80_stb_o), 
    .wb_we_o(wb_z80_we_o), 
    .wb_ack_i(wb_z80_ack_i), 
    .int_req_i(z80_int_req_i)
    );
`else
wire z80_nmi_req_i = 1'b0;
wire z80_busrq_i = 1'b0;

wire z80_busak_o;

// Instantiate Wishbone tv80 Z80 CPU Core
wb_tv80 z80_cpu (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wbm_adr_o(wb_z80_adr_o), 
    .wbm_tga_o(wb_z80_tga_o), 
    .wbm_dat_i(wb_z80_final_dat_i), 
    .wbm_dat_o(wb_z80_dat_o[7:0]), 
    .wbm_cyc_o(wb_z80_cyc_o), 
    .wbm_stb_o(wb_z80_stb_o), 
    .wbm_we_o(wb_z80_we_o), 
    .wbm_ack_i(wb_z80_ack_i), 
    .nmi_req_i(z80_nmi_req_i),
    .int_req_i(z80_int_req_i),
    .busrq_i(z80_busrq_i),
    .busak_o(z80_busak_o)
    );
`endif // USE_WB_Z80

// Instantiate the CPU Controller
wire [31:0] wb_cpu_ctrl_dat_o;
wire [31:0] wb_cpu_ctrl_dat_i;
wire  [3:0] wb_cpu_ctrl_sel_i;
wire        wb_cpu_ctrl_we_i;
wire        wb_cpu_ctrl_stb_i;
wire        wb_cpu_ctrl_cyc_i;
wire        wb_cpu_ctrl_ack_o;
wire  [2:0] wb_cpu_ctrl_adr_i;
wire [31:0] cpu_ctrl_reg0;
wire [31:0] cpu_ctrl_reg1;

wb_cpu_ctrl cpu_ctrl0 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wb_cpu_ctrl_adr_i[2:0]), 
    .wb_dat_o(wb_cpu_ctrl_dat_o), 
    .wb_dat_i(wb_cpu_ctrl_dat_i), 
    .wb_sel_i(wb_cpu_ctrl_sel_i), 
    .wb_we_i(wb_cpu_ctrl_we_i), 
    .wb_stb_i(wb_cpu_ctrl_stb_i), 
    .wb_cyc_i(wb_cpu_ctrl_cyc_i), 
    .wb_ack_o(wb_cpu_ctrl_ack_o),
    .datareg0(cpu_ctrl_reg0),
    .datareg1(cpu_ctrl_reg1)
    );

`ifdef USE_INTERNAL_RAM
// Instantiate the SRAM
wire [31:0] wbs_sram_dat_o;
wire [31:0] wbs_sram_dat_i;
wire [3:0]  wbs_sram_sel_i;
wire        wbs_sram_we_i;
wire        wbs_sram_stb_i;
wire        wbs_sram_cyc_i;
wire        wbs_sram_ack_o;
wire [14:0] wbs_sram_adr_i;

// Instantiate 16K SRAM initialized with Vector Monitor 4.3 ROM
wb_sram #(
    .mem_file_name("../mon43/MON4043.mem"),
    .adr_width(14),
    .dat_width(8)
) sram0 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wbs_sram_adr_i), 
    .wb_dat_o(wbs_sram_dat_o), 
    .wb_dat_i(wbs_sram_dat_i), 
    .wb_sel_i(wbs_sram_sel_i), 
    .wb_we_i(wbs_sram_we_i), 
    .wb_stb_i(wbs_sram_stb_i), 
    .wb_cyc_i(wbs_sram_cyc_i), 
    .wb_ack_o(wbs_sram_ack_o)
    );
`endif // USE_INTERNAL_RAM

wire [31:0] wbs_vga_dat_o; 
wire        wbs_vga_ack_o; 
wire [31:0] wbs_vga_dat_i; 
wire        wbs_vga_we_i; 
wire  [3:0] wbs_vga_sel_i;
wire [13:0] wbs_vga_adr_i;
wire        wbs_vga_cyc_i; 
wire        wbs_vga_stb_i; 

// Instantiate the VGA Controller (Emulating Vector Graphic FlashWriter2)
wb_vga #(
    .font_height(10),
    .text_height(2))
vga0 (
    .clk_i(PCI_CLK), 
    .clk_50mhz_i(CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wbs_vga_adr_i), 
    .wb_dat_o(wbs_vga_dat_o), 
    .wb_dat_i(wbs_vga_dat_i), 
    .wb_sel_i(wbs_vga_sel_i), 
    .wb_we_i(wbs_vga_we_i), 
    .wb_stb_i(wbs_vga_stb_i), 
    .wb_cyc_i(wbs_vga_cyc_i), 
    .wb_ack_o(wbs_vga_ack_o), 
    .vga_hsync_o(hsync), 
    .vga_vsync_o(vsync), 
    .vga_r_o(R), 
    .vga_g_o(G), 
    .vga_b_o(B)
    );

wire  [2:0] wbs_kbd_adr_i;
wire [31:0] wbs_kbd_dat_i;
wire [31:0] wbs_kbd_dat_o;
wire        wbs_kbd_we_i;
wire  [3:0] wbs_kbd_sel_i;
wire        wbs_kbd_cyc_i;
wire        wbs_kbd_stb_i;
wire        wbs_kbd_ack_o;
wire        uart3_rxd = 1'b0;
wire        uart3_txd;

// Instantiate the PS/2 Keyboard, and three Bitstreamer UARTs (third one not connected.)
wb_uart #(
	.clk_freq(25000000),
	.baud(115200)
) bitstreamer0 (
    .clk(PCI_CLK), 
    .reset(RST), 
    .wb_stb_i(wbs_kbd_stb_i), 
    .wb_cyc_i(wbs_kbd_cyc_i), 
    .wb_ack_o(wbs_kbd_ack_o), 
    .wb_we_i(wbs_kbd_we_i), 
    .wb_adr_i(wbs_kbd_adr_i), 
    .wb_sel_i(wbs_kbd_sel_i), 
    .wb_dat_i(wbs_kbd_dat_i), 
    .wb_dat_o(wbs_kbd_dat_o), 
    .ps2_clk(PS2_KBD_CLK), 
    .ps2_data(PS2_KBD_DAT),
	.uart1_rxd(CONS_UART_RXD),
	.uart1_txd(CONS_UART_TXD),
	.uart2_rxd(AUX_UART_RXD),
	.uart2_txd(AUX_UART_TXD),
	.uart3_rxd(uart3_rxd),
	.uart3_txd(uart3_txd)
    );

wire [31:0] wbs_flash_dat_o; 
wire        wbs_flash_ack_o; 
wire [31:0] wbs_flash_dat_i; 
wire        wbs_flash_we_i; 
wire  [3:0] wbs_flash_sel_i;
wire [18:0] wbs_flash_adr_i;
wire        wbs_flash_cyc_i; 
wire        wbs_flash_stb_i; 

// Instantiate 8K of SRAM instead of FLASH controller.  FLASH is used for VHDFD Storage
wb_sram #(
    .adr_width(13),
    .dat_width(8)
) sram2 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wbs_flash_adr_i), 
    .wb_dat_o(wbs_flash_dat_o), 
    .wb_dat_i(wbs_flash_dat_i), 
    .wb_sel_i(wbs_flash_sel_i), 
    .wb_we_i(wbs_flash_we_i), 
    .wb_stb_i(wbs_flash_stb_i), 
    .wb_cyc_i(wbs_flash_cyc_i), 
    .wb_ack_o(wbs_flash_ack_o)
    );

// Instantiate the FLASH Memory Interface
//wb_flash flash0 (
//    .clk_i(PCI_CLK), 
//    .nrst_i(NRST), 
//    .wb_adr_i(wbs_flash_adr_i), 
//    .wb_dat_o(wbs_flash_dat_o), 
//    .wb_dat_i(wbs_flash_dat_i), 
//    .wb_sel_i(wbs_flash_sel_i), 
//    .wb_we_i(wbs_flash_we_i), 
//    .wb_stb_i(wbs_flash_stb_i), 
//    .wb_cyc_i(wbs_flash_cyc_i), 
//    .wb_ack_o(wbs_flash_ack_o), 
//    .flash_adr_o(flash_adr_o), 
//    .flash_dat_o(flash_dat_o), 
//    .flash_dat_i(flash_dat_i), 
//    .flash_oe(flash_oe_o), 
//    .flash_ce(flash_ce_o), 
//    .flash_we(flash_we_o)
//    );

wire [31:0] wbs_ddr_dat_o; 
wire        wbs_ddr_ack_o; 
wire [31:0] wbs_ddr_dat_i; 
wire        wbs_ddr_we_i; 
wire  [3:0] wbs_ddr_sel_i;
wire [19:0] wbs_ddr_adr_i;
wire        wbs_ddr_cyc_i; 
wire        wbs_ddr_stb_i; 

// Instantiate 8K SRAM instead of DDR Controller
wb_sram #(
    .mem_file_name("none"),
    .adr_width(12),
    .dat_width(8)
) sram1 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wbs_ddr_adr_i[13:0]), 
    .wb_dat_o(wbs_ddr_dat_o), 
    .wb_dat_i(wbs_ddr_dat_i), 
    .wb_sel_i(wbs_ddr_sel_i), 
    .wb_we_i(wbs_ddr_we_i), 
    .wb_stb_i(wbs_ddr_stb_i), 
    .wb_cyc_i(wbs_ddr_cyc_i), 
    .wb_ack_o(wbs_ddr_ack_o)
    );


//// Instantiate the DDR SDRAM Controller
//// (This is not working properly at the moment... not sure why.)
//	wire                   ddr_ps_ready;
//	wire                   ddr_ps_up = 1'b0;
//	wire                   ddr_ps_down = 1'b0;
//	wire                   ddr_probe_clk;
//	wire             [7:0] ddr_probe_sel = 8'h00;
//	wire             [7:0] ddr_probe;
//
//wb_ddr #(
//    .phase_shift(0),
//    .clk_multiply(12), //15), //13),
//    .clk_divide(3),
//    .wait200_init(26)
//) ddr0 (
//    .clk(PCI_CLK), 
//    .reset(RST), 
////    .rot(rot), 
//    .ddr_clk(SD_CK_P), 
//    .ddr_clk_n(SD_CK_N), 
//    .ddr_clk_fb(SD_CK_FB), 
//    .ddr_ras_n(SD_RAS), 
//    .ddr_cas_n(SD_CAS), 
//    .ddr_we_n(SD_WE), 
//    .ddr_cke(SD_CKE), 
//    .ddr_cs_n(SD_CS), 
//    .ddr_a(SD_A), 
//    .ddr_ba(SD_BA), 
//    .ddr_dq(SD_DQ), 
//    .ddr_dqs(SD_DQS), 
//    .ddr_dm(SD_DM), 
//    .wb_adr_i({10'b0, wbs_ddr_adr_i, 2'b00 }), 
//    .wb_dat_i(wbs_ddr_dat_i), 
//    .wb_dat_o(wbs_ddr_dat_o), 
//    .wb_sel_i(4'b1111), //wbs_ddr_sel_i), 
//    .wb_cyc_i(wbs_ddr_cyc_i), 
//    .wb_stb_i(wbs_ddr_stb_i), 
//    .wb_we_i(wbs_ddr_we_i), 
//    .wb_ack_o(wbs_ddr_ack_o), 
//    .ps_ready(ddr_ps_ready),
//    .ps_up(ddr_ps_up),
//    .ps_down(ddr_ps_down),
//    .probe_clk(ddr_probe_clk),
//    .probe_sel(ddr_probe_sel),
//    .probe(ddr_probe)
//    );

wire [31:0] wbs_mmu_dat_o; 
wire        wbs_mmu_ack_o; 
wire [31:0] wbs_mmu_dat_i; 
wire        wbs_mmu_we_i; 
wire  [3:0] wbs_mmu_sel_i;
wire  [1:0] wbs_mmu_adr_i;
wire        wbs_mmu_cyc_i; 
wire        wbs_mmu_stb_i; 

wire [15:0] mmu_adr_i = wb_z80_adr_o[15:0];
wire [23:0] mmu_adr_o;

wire  [1:0] mmu_slave_adr_low;
wire  [7:0] mmu_dat_i;

assign mmu_dat_i = wbs_mmu_sel_i == 4'b0001 ? wbs_mmu_dat_i[7:0] : 
                     wbs_mmu_sel_i == 4'b0010 ? wbs_mmu_dat_i[15:8] : 
                     wbs_mmu_sel_i == 4'b0100 ? wbs_mmu_dat_i[23:16] : 
                     wbs_mmu_dat_i[31:24];

assign mmu_slave_adr_low = wbs_mmu_sel_i == 4'b0001 ? 2'b00 : 
                       wbs_mmu_sel_i == 4'b0010 ? 2'b01 : 
                       wbs_mmu_sel_i == 4'b0100 ? 2'b10 : 2'b11;

// Instantiate the Memory Management Unit
wb_mmu mmu0 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wbs_adr_i(mmu_slave_adr_low), 
    .wbs_dat_o(wbs_mmu_dat_o), 
    .wbs_dat_i(mmu_dat_i), 
    .wbs_sel_i(wbs_mmu_sel_i), 
    .wbs_we_i(wbs_mmu_we_i), 
    .wbs_stb_i(wbs_mmu_stb_i), 
    .wbs_cyc_i(wbs_mmu_cyc_i), 
    .wbs_ack_o(wbs_mmu_ack_o), 
    .mmu_adr_i(mmu_adr_i), 
    .mmu_adr_o(mmu_adr_o),
    .rom_sel_i(SW[0])
    );

// Instantiate the Vector HD-FD Disk Controller
wire [31:0] wbs_vhdfd_dat_o;
wire [31:0] wbs_vhdfd_dat_i;
wire  [3:0] wbs_vhdfd_sel_i;
wire        wbs_vhdfd_we_i;
wire        wbs_vhdfd_stb_i;
wire        wbs_vhdfd_cyc_i;
wire        wbs_vhdfd_ack_o;
wire  [2:0] wbs_vhdfd_adr_i;
wire  [2:0] vhdfd_adr_i;
wire  [1:0] vhdfd_adr_low;
wire  [7:0] vhdfd_dat_i;

assign vhdfd_dat_i = wbs_vhdfd_sel_i == 4'b0001 ? wbs_vhdfd_dat_i[7:0] : 
                     wbs_vhdfd_sel_i == 4'b0010 ? wbs_vhdfd_dat_i[15:8] : 
                     wbs_vhdfd_sel_i == 4'b0100 ? wbs_vhdfd_dat_i[23:16] : 
                     wbs_vhdfd_dat_i[31:24];

assign vhdfd_adr_low = wbs_vhdfd_sel_i == 4'b0001 ? 2'b00 : 
                       wbs_vhdfd_sel_i == 4'b0010 ? 2'b01 : 
                       wbs_vhdfd_sel_i == 4'b0100 ? 2'b10 : 2'b11;

assign vhdfd_adr_i = {wbs_vhdfd_adr_i[2], vhdfd_adr_low};


wb_vhdfd vfdhd0 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wbs_adr_i(vhdfd_adr_i[2:0]), 
    .wbs_dat_o(wbs_vhdfd_dat_o), 
    .wbs_dat_i(vhdfd_dat_i), 
    .wbs_sel_i(wbs_vhdfd_sel_i), 
    .wbs_we_i(wbs_vhdfd_we_i), 
    .wbs_stb_i(wbs_vhdfd_stb_i), 
    .wbs_cyc_i(wbs_vhdfd_cyc_i), 
    .wbs_ack_o(wbs_vhdfd_ack_o),
    .flash_adr_o(flash_adr_o), 
    .flash_dat_o(flash_dat_o), 
    .flash_dat_i(flash_dat_i), 
    .flash_oe(flash_oe_o), 
    .flash_ce(flash_ce_o), 
    .flash_we(flash_we_o)
    );

// Instantiate the spimaster Controller
wire [31:0] wbs_spimaster_dat_o;
wire [31:0] wbs_spimaster_dat_i;
wire  [3:0] wbs_spimaster_sel_i;
wire        wbs_spimaster_we_i;
wire        wbs_spimaster_stb_i;
wire        wbs_spimaster_cyc_i;
wire        wbs_spimaster_ack_o;
wire  [5:0] wbs_spimaster_adr_i;
wire  [7:0] spimaster_dat_i;
wire  [7:0] spimaster_adr_i;
wire  [1:0] spimaster_adr_low;

assign spimaster_dat_i = wbs_spimaster_sel_i == 4'b0001 ? wbs_spimaster_dat_i[7:0] : 
                         wbs_spimaster_sel_i == 4'b0010 ? wbs_spimaster_dat_i[15:8] : 
                         wbs_spimaster_sel_i == 4'b0100 ? wbs_spimaster_dat_i[23:16] : 
                         wbs_spimaster_dat_i[31:24];

assign spimaster_adr_low = wbs_spimaster_sel_i == 4'b0001 ? 2'b00 : 
                           wbs_spimaster_sel_i == 4'b0010 ? 2'b01 : 
                           wbs_spimaster_sel_i == 4'b0100 ? 2'b10 : 2'b11;

assign spimaster_adr_i = {2'b00, wbs_spimaster_adr_i[5:2], spimaster_adr_low};

wire [31:0] cpu_ctrl1_reg0;
wire [31:0] cpu_ctrl1_reg1;

wb_cpu_ctrl cpu_ctrl1 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wb_adr_i(wbs_spimaster_adr_i[2:0]), 
    .wb_dat_o(wbs_spimaster_dat_o), 
    .wb_dat_i(wbs_spimaster_dat_i), 
    .wb_sel_i(wbs_spimaster_sel_i), 
    .wb_we_i(wbs_spimaster_we_i), 
    .wb_stb_i(wbs_spimaster_stb_i), 
    .wb_cyc_i(wbs_spimaster_cyc_i), 
    .wb_ack_o(wbs_spimaster_ack_o),
    .datareg0(cpu_ctrl1_reg0),
    .datareg1(cpu_ctrl1_reg1)
    );

//spiMaster spimaster0 (
//    .clk_i(PCI_CLK), 
//    .rst_i(RST), 
//    .address_i(spimaster_adr_i), 
//    .data_o(wbs_spimaster_dat_o), 
//    .data_i(spimaster_dat_i), 
//    .we_i(wbs_spimaster_we_i), 
//    .strobe_i(wbs_spimaster_stb_i), 
//    .ack_o(wbs_spimaster_ack_o),
//    .spiSysClk(PCI_CLK), 
//    .spiClkOut(SD_SPI_CLK), 
//    .spiDataIn(SD_SPI_MISO), 
//    .spiDataOut(SD_SPI_MOSI), 
//    .spiCS_n(SD_SPI_CS_N)    
//    );

assign SD_SPI_CLK = PCI_CLK;
assign SD_SPI_MOSI = 1'b1;
assign SD_SPI_CS_N = 1'b1;

// Instantiate the fpb Controller
wire [31:0] wbs_fpb_dat_o;
wire [31:0] wbs_fpb_dat_i;
wire  [3:0] wbs_fpb_sel_i;
wire        wbs_fpb_we_i;
wire        wbs_fpb_stb_i;
wire        wbs_fpb_cyc_i;
wire        wbs_fpb_ack_o;
wire  [4:0] wbs_fpb_adr_i;
wire  [7:0] fpb_dat_i;
wire  [7:0] fpb_adr_i;
wire  [1:0] fpb_adr_low;

wb_fpb fpb0 (
    .clk_i(PCI_CLK), 
    .nrst_i(NRST), 
    .wbs_adr_i(wbs_fpb_adr_i[4:0]), 
    .wbs_dat_o(wbs_fpb_dat_o), 
    .wbs_dat_i(wbs_fpb_dat_i), 
    .wbs_sel_i(wbs_fpb_sel_i), 
    .wbs_we_i(wbs_fpb_we_i), 
    .wbs_stb_i(wbs_fpb_stb_i), 
    .wbs_cyc_i(wbs_fpb_cyc_i), 
    .wbs_ack_o(wbs_fpb_ack_o),
    .prog_out_port(LED),
    .sense_sw_i({ 4'h0, SW }),
    .lcd_e(LCD_E),
    .lcd_rs(LCD_RS),
    .lcd_rw(LCD_RW),
    .lcd_dat(LCD_D)
    );


// Instantiate the Wishbone Backplane
intercon wb_intercon (
    .wb32_pci_master_dat_i(MDAT_I), 
    .wb32_pci_master_ack_i(ACK_I), 
    .wb32_pci_master_err_i(ERR_I), 
    .wb32_pci_master_dat_o(MDAT_O), 
    .wb32_pci_master_we_o(WE_O), 
    .wb32_pci_master_sel_o(SEL_O), 
    .wb32_pci_master_adr_o(ADR_O[23:0]), 
    .wb32_pci_master_cyc_o(CYC_O), 
    .wb32_pci_master_stb_o(STB_O),
    .wbm_z80_dat_i(wb_z80_dat_i), 
    .wbm_z80_ack_i(wb_z80_ack_i), 
    .wbm_z80_dat_o(wb_z80_dat_o), 
    .wbm_z80_we_o(wb_z80_we_o), 
    .wbm_z80_sel_o(wb_z80_sel_o), 
    .wbm_z80_adr_o((wb_z80_tga_o & 2'b01) ? {16'h0000,wb_z80_adr_o[7:0]} : mmu_adr_o),
    .wbm_z80_cyc_o(wb_z80_cyc_o), 
    .wbm_z80_stb_o(wb_z80_stb_o),
    .wb_cpu_ctrl_dat_o(wb_cpu_ctrl_dat_o), 
    .wb_cpu_ctrl_ack_o(wb_cpu_ctrl_ack_o), 
    .wb_cpu_ctrl_dat_i(wb_cpu_ctrl_dat_i), 
    .wb_cpu_ctrl_we_i(wb_cpu_ctrl_we_i), 
    .wb_cpu_ctrl_sel_i(wb_cpu_ctrl_sel_i), 
    .wb_cpu_ctrl_adr_i(wb_cpu_ctrl_adr_i), 
    .wb_cpu_ctrl_cyc_i(wb_cpu_ctrl_cyc_i), 
    .wb_cpu_ctrl_stb_i(wb_cpu_ctrl_stb_i),
`ifdef USE_INTERNAL_RAM
    .wbs_sram_dat_o(wbs_sram_dat_o), 
    .wbs_sram_ack_o(wbs_sram_ack_o), 
    .wbs_sram_dat_i(wbs_sram_dat_i), 
    .wbs_sram_we_i(wbs_sram_we_i), 
    .wbs_sram_sel_i(wbs_sram_sel_i), 
    .wbs_sram_adr_i(wbs_sram_adr_i), 
    .wbs_sram_cyc_i(wbs_sram_cyc_i), 
    .wbs_sram_stb_i(wbs_sram_stb_i), 
`endif // USE_INTERNAL_RAM

    .wbs_kbd_dat_o(wbs_kbd_dat_o),          // 0x00-0x01
    .wbs_kbd_ack_o(wbs_kbd_ack_o), 
    .wbs_kbd_dat_i(wbs_kbd_dat_i), 
    .wbs_kbd_we_i(wbs_kbd_we_i), 
    .wbs_kbd_sel_i(wbs_kbd_sel_i), 
    .wbs_kbd_adr_i(wbs_kbd_adr_i), 
    .wbs_kbd_cyc_i(wbs_kbd_cyc_i), 
    .wbs_kbd_stb_i(wbs_kbd_stb_i),

    .wbs_flash_dat_o(wbs_flash_dat_o), 
    .wbs_flash_ack_o(wbs_flash_ack_o), 
    .wbs_flash_dat_i(wbs_flash_dat_i), 
    .wbs_flash_we_i (wbs_flash_we_i), 
    .wbs_flash_sel_i(wbs_flash_sel_i), 
    .wbs_flash_adr_i(wbs_flash_adr_i), 
    .wbs_flash_cyc_i(wbs_flash_cyc_i), 
    .wbs_flash_stb_i(wbs_flash_stb_i), 

    .wbs_ddr_dat_o(wbs_ddr_dat_o), 
    .wbs_ddr_ack_o(wbs_ddr_ack_o), 
    .wbs_ddr_dat_i(wbs_ddr_dat_i), 
    .wbs_ddr_we_i (wbs_ddr_we_i), 
    .wbs_ddr_sel_i(wbs_ddr_sel_i), 
    .wbs_ddr_adr_i(wbs_ddr_adr_i), 
    .wbs_ddr_cyc_i(wbs_ddr_cyc_i), 
    .wbs_ddr_stb_i(wbs_ddr_stb_i), 

    .wbs_mmu_dat_o(wbs_mmu_dat_o),  // 0x20-0x23 
    .wbs_mmu_ack_o(wbs_mmu_ack_o), 
    .wbs_mmu_dat_i(wbs_mmu_dat_i), 
    .wbs_mmu_we_i (wbs_mmu_we_i), 
    .wbs_mmu_sel_i(wbs_mmu_sel_i), 
    .wbs_mmu_adr_i(wbs_mmu_adr_i), 
    .wbs_mmu_cyc_i(wbs_mmu_cyc_i), 
    .wbs_mmu_stb_i(wbs_mmu_stb_i), 

    .wbs_vhdfd_dat_o(wbs_vhdfd_dat_o), // 0xC0
    .wbs_vhdfd_ack_o(wbs_vhdfd_ack_o), 
    .wbs_vhdfd_dat_i(wbs_vhdfd_dat_i), 
    .wbs_vhdfd_we_i (wbs_vhdfd_we_i), 
    .wbs_vhdfd_sel_i(wbs_vhdfd_sel_i), 
    .wbs_vhdfd_adr_i(wbs_vhdfd_adr_i), 
    .wbs_vhdfd_cyc_i(wbs_vhdfd_cyc_i), 
    .wbs_vhdfd_stb_i(wbs_vhdfd_stb_i), 

    .wbs_spimaster_dat_o(wbs_spimaster_dat_o), // 0x80-0xBF
    .wbs_spimaster_ack_o(wbs_spimaster_ack_o), 
    .wbs_spimaster_dat_i(wbs_spimaster_dat_i), 
    .wbs_spimaster_we_i (wbs_spimaster_we_i), 
    .wbs_spimaster_sel_i(wbs_spimaster_sel_i), 
    .wbs_spimaster_adr_i(wbs_spimaster_adr_i), 
    .wbs_spimaster_cyc_i(wbs_spimaster_cyc_i), 
    .wbs_spimaster_stb_i(wbs_spimaster_stb_i), 

    .wbs_fpb_dat_o(wbs_fpb_dat_o), // 0xE0-0xFF
    .wbs_fpb_ack_o(wbs_fpb_ack_o), 
    .wbs_fpb_dat_i(wbs_fpb_dat_i), 
    .wbs_fpb_we_i (wbs_fpb_we_i), 
    .wbs_fpb_sel_i(wbs_fpb_sel_i), 
    .wbs_fpb_adr_i(wbs_fpb_adr_i), 
    .wbs_fpb_cyc_i(wbs_fpb_cyc_i), 
    .wbs_fpb_stb_i(wbs_fpb_stb_i), 

    .wbs_vga_dat_o(wbs_vga_dat_o), 
    .wbs_vga_ack_o(wbs_vga_ack_o), 
    .wbs_vga_dat_i(wbs_vga_dat_i), 
    .wbs_vga_we_i (wbs_vga_we_i), 
    .wbs_vga_sel_i(wbs_vga_sel_i), 
    .wbs_vga_adr_i(wbs_vga_adr_i), 
    .wbs_vga_cyc_i(wbs_vga_cyc_i), 
    .wbs_vga_stb_i(wbs_vga_stb_i), 

    .clk(PCI_CLK), 
    .reset(RST)
    );

endmodule
