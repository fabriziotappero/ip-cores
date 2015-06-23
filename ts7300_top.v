/* Copyright 2005-2006, Technologic Systems
 * All Rights Reserved.
 *
 * Author(s): Jesse Off <joff@embeddedARM.com>
 *
 * Boilerplate Verilog for use in Technologic Systems TS-7300 FPGA computer
 * at http://www.embeddedarm.com/epc/ts7300-spec-h.htm.  Implements bus cycle
 * demultiplexing to an internal 16 and 32 bit WISHBONE bus, and 10/100
 * ethernet interface. 
 *
 * Full-featured FPGA bitstream from Technologic Systems includes "TS-SDCORE"
 * SD card core, 8 "TS-UART" serial ports, "TS-VIDCORE" VGA video framebuffer and 
 * accelerator, and 2 PWM/Timer/Counter "TS-XDIO" cores for the various GPIO 
 * pins.  Binary bitstream comes with board.  Contact Technologic Systems 
 * for custom FPGA development on the TS-7300 or for non-GPL licensing of this
 * or any of the above (not-included-here) TS-cores and OS drivers.
 *
 * To load the bitstream to the FPGA on the TS-7300, Technologic Systems provides
 * a Linux program "load_ts7300" that takes the ts7300_top.rbf file generated
 * by Altera's Quartus II on the Linux flash filesystem (yaffs, ext2, 
 * jffs2, etc..) and loads the FPGA.  Loading the FPGA takes approx 0.2 seconds
 * this way and can be done (and re-done) at any time during power-up without
 * any special JTAG/ISP cables.
 */
 
/*
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License v2 as published by
 *  the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/* This module is a sample dummy stub that can be filled in by the user.  Any access's on
 * the TS-7300 CPU for address 0x72a00000 to 0x72fffffc arrive here.  Keep in mind
 * the address is a word address not the byte address and address 0x0 is 0x72000000.
 * The interface used here is the WISHBONE bus, described in detail on 
 * http://www.opencores.org
 *
 * There is a 40-pin header next to the FPGA.  It is broken up into 2 20 pin 
 * connectors.  One is labeled DIO2 and contains the 18 dedicated GPIO pins.  The
 * other contains 17 signals that are used by the TS-VIDCORE but can also be used
 * as GPIO if video is not used.  DO NOT DRIVE THESE SIGNALS OVER 3.3V!!!  They
 * go straight into the FPGA pads unbuffered.
 *  ___________________________________________________________
 * | 2  4  6  8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40|
 * | 1  3  5  7  9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39|
 * \-----------------------------------------------------------/
 *   *                           | *         DIO2
 *
 * pins #2 and #22 are grounds
 * pin #20 is fused 5V (polyfuse)
 * pin #40 is regulated 3.3V
 * pin #18 can be externally driven high to disable DB15 VGA connector DACs
 * pin #36 and #38 also go to the red and green LEDs (active low)
 * pin #39 is a dedicated clock input and cannot be programmed for output
 * 
 */
module ts7300_wishbone_slave(
  /* 75Mhz clock is fed to this module */
  wb_clk_i,
  wb_rst_i,
  wb_adr_i,
  wb_dat_i,
  wb_cyc_i,
  wb_stb_i,
  wb_we_i,
  wb_ack_o,
  wb_dat_o,

  /* This is the 40 pin header next to the FPGA */
  headerpin_i,
  headerpin_o,
  headerpin_oe_o, /* output enable */

  /* Use this for an IRQ on ARM IRQ #40 -- In Linux, be sure to
   * use request_irq() with the SA_SHIRQ flag which enables 
   * sharing interrupts with the Linux ethernet driver.
   */
  irq_o
);

input wb_clk_i;
input wb_rst_i;
input wb_cyc_i;
input wb_stb_i;
input wb_we_i;
input [21:0] wb_adr_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
output wb_ack_o;
input [40:1] headerpin_i;
output [40:1] headerpin_o, headerpin_oe_o;
output irq_o;

/*
 * BEGIN USER-SERVICEABLE SECTION
 * 
 * The default here is to alias the entire space onto one 32-bit register "dummyreg"
 * On reset, it is set to 0xdeadbeef but then retains the value last written to it.
 * The value of this register drives GPIO pins 9-40 on the FPGA connector described
 * above. 
 */
 
reg [31:0] dummyreg;

assign wb_ack_o = wb_cyc_i && wb_stb_i; /* 0-wait state WISHBONE */
assign wb_dat_o = dummyreg;
assign headerpin_oe_o[40:1] = 40'hffffffffff; /* All outputs */
assign headerpin_o[40:1] = {dummyreg, 8'd0};
assign irq_o = 1'b0;

always @(posedge wb_clk_i) begin
  if (wb_rst_i) dummyreg <= 32'hdeadbeef;
  else if (wb_cyc_i && wb_stb_i && wb_we_i) dummyreg <= wb_dat_i;
end

/*
 * END USER-SERVICEABLE SECTION
 */

endmodule


/* Now begins the real guts of the TS-7300 Cyclone2 EP2C8 FPGA
 * boilerplate.  You should only have to look below here if the above
 * stub module isn't enough for you. 
 */
module ts7300_top(
  fl_d_pad,
  bd_pad,
  isa_add11_pad,
  isa_add12_pad,
  isa_add14_pad,
  isa_add15_pad,
  isa_add1_pad,
  add_pad,
  start_cycle_pad,
  bd_oe_pad,
  dio0to8_pad,
  dio9_pad,
  dio10to17_pad,
  sdram_data_pad,
  clk_25mhz_pad,
  clk_75mhz_pad,
  isa_wait_pad,
  dma_req_pad,
  irq7_pad,
  sd_soft_power_pad,
  sd_hard_power_pad,
  sd_wprot_pad,
  sd_present_pad,
  sd_dat_pad,
  sd_clk_pad,
  sd_cmd_pad,
  eth_mdio_pad,
  eth_mdc_pad,
  eth_rxdat_pad,
  eth_rxdv_pad,
  eth_rxclk_pad,
  eth_rxerr_pad,
  eth_txdat_pad,
  eth_txclk_pad,
  eth_txen_pad,
  eth_txerr_pad,
  eth_col_pad,
  eth_crs_pad,
  eth_pd_pad,
  sdram_add_pad,
  sdram_ras_pad,
  sdram_cas_pad,
  sdram_we_pad,
  sdram_ba_pad,
  sdram_clk_pad,
  wr_232_pad,
  rd_mux_pad,
  mux_cntrl_pad,
  mux_pad,
  blue_pad,
  red_pad,
  green_pad,
  hsync_pad,
  vsync_pad
);

inout [7:0] fl_d_pad;
inout [7:0] bd_pad;
input isa_add11_pad;
input isa_add12_pad;
input isa_add14_pad;
input isa_add15_pad;
input isa_add1_pad;
input [3:0] add_pad;
input start_cycle_pad;
input bd_oe_pad;
inout reg [8:0] dio0to8_pad;
input dio9_pad;
inout reg [7:0] dio10to17_pad;
inout [15:0] sdram_data_pad; 
input clk_25mhz_pad;
output clk_75mhz_pad;
inout isa_wait_pad;
inout dma_req_pad;
inout irq7_pad;
output sd_soft_power_pad;
output sd_hard_power_pad;
input sd_wprot_pad;
input sd_present_pad;
inout [3:0] sd_dat_pad;
output sd_clk_pad;
inout sd_cmd_pad;
inout eth_mdio_pad;
output eth_mdc_pad;
input [3:0] eth_rxdat_pad;
input eth_rxdv_pad;
input eth_rxclk_pad;
input eth_rxerr_pad;
output [3:0] eth_txdat_pad;
input eth_txclk_pad;
output eth_txen_pad;
output eth_txerr_pad;
input eth_col_pad;
input eth_crs_pad;
output eth_pd_pad;
output [12:0] sdram_add_pad;
output sdram_ras_pad;
output sdram_cas_pad;
output sdram_we_pad;
output [1:0] sdram_ba_pad;
output wr_232_pad;
output rd_mux_pad;
output mux_cntrl_pad;
inout [3:0] mux_pad;
inout reg [4:0] blue_pad;
inout reg [4:0] red_pad;
inout reg [4:0] green_pad;
inout reg hsync_pad;
inout reg vsync_pad;
output sdram_clk_pad;

/* Set to 1'b0 to disable ethernet.  If you disable this, don't
 * attempt to load the ethernet driver module! */
parameter ethernet = 1'b1;

/* Bus cycles from the ep9302 processor come in to the FPGA multiplexed by
 * the MAX2 CPLD on the TS-7300.  Any access on the ep9302 for addresses 
 * 0x72000000 - 0x72ffffff are routed to the FPGA.  The ep9302 CS7 SMCBCR register
 * at 0x8008001c physical should be set to 0x10004508 -- 16-bit, 
 * ~120 nS bus cycle.  The FPGA must be loaded and sending 75Mhz to the MAX2
 * on clk_75mhz_pad before any bus cycles are attempted.
 *
 * Since the native multiplexed bus is a little unfriendly to deal with
 * and non-standard, as our first order of business we translate it into
 * something more easily understood and better documented: a 16 bit WISHBONE bus.
 */

reg epwbm_done, epwbm_done32;
reg isa_add1_pad_q;
reg [23:0] ep93xx_address;
reg epwbm_we_o, epwbm_stb_o;
wire [23:0] epwbm_adr_o;
reg [15:0] epwbm_dat_o;
reg [15:0] epwbm_dat_i;
reg [15:0] ep93xx_dat_latch;
reg epwbm_ack_i;
wire epwbm_clk_o = clk_75mhz_pad;
wire epwbm_cyc_o = start_cycle_posedge_q;  
wire ep93xx_databus_oe = !epwbm_we_o && start_cycle_posedge && !bd_oe_pad;
wire pll_locked, clk_150mhz;
wire epwbm_rst_o = !pll_locked;

assign fl_d_pad[7:0] = ep93xx_databus_oe ? 
  ep93xx_dat_latch[7:0] : 8'hzz;
assign bd_pad[7:0] = ep93xx_databus_oe ? 
  ep93xx_dat_latch[15:8] : 8'hzz;
assign isa_wait_pad =  start_cycle_negedge ?  epwbm_done : 1'bz; 
assign epwbm_adr_o[23:2] = ep93xx_address[23:2];
reg ep93xx_address1_q;
assign epwbm_adr_o[0] = ep93xx_address[0];
assign epwbm_adr_o[1] = ep93xx_address1_q;

/* Use Altera's PLL to multiply 25Mhz from the ethernet PHY to 75Mhz */
pll clkgencore(
  .inclk0(clk_25mhz_pad), 
  .c0(clk_150mhz), 
  .c1(clk_75mhz_pad), 
  .locked(pll_locked)
);

reg ep93xx_end, ep93xx_end_q;
reg start_cycle_negedge, start_cycle_posedge, bd_oe_negedge, bd_oe_posedge;
reg start_cycle_negedge_q, start_cycle_posedge_q;
reg bd_oe_negedge_q, bd_oe_posedge_q;

always @(posedge clk_75mhz_pad) begin
  start_cycle_negedge_q <= start_cycle_negedge;
  start_cycle_posedge_q <= start_cycle_posedge;
  bd_oe_negedge_q <= bd_oe_negedge;
  bd_oe_posedge_q <= bd_oe_posedge;
  isa_add1_pad_q <= isa_add1_pad;

  if ((bd_oe_negedge_q && epwbm_we_o) ||
    (start_cycle_posedge_q && !epwbm_we_o) && !epwbm_done) begin
    epwbm_stb_o <= 1'b1;
    ep93xx_address1_q <= isa_add1_pad_q;
    epwbm_dat_o <= {bd_pad[7:0], fl_d_pad[7:0]};
  end

  if (epwbm_stb_o && epwbm_ack_i) begin
    epwbm_stb_o <= 1'b0;
    epwbm_done <= 1'b1;
    ep93xx_dat_latch <= epwbm_dat_i;
  end

  if (epwbm_done && !epwbm_done32 && (ep93xx_address[1] != isa_add1_pad_q)) begin
    epwbm_done <= 1'b0;
    epwbm_done32 <= 1'b1;
  end

  ep93xx_end_q <= 1'b0;

  if ((start_cycle_negedge_q && start_cycle_posedge_q && 
    bd_oe_negedge_q && bd_oe_posedge) || !pll_locked) begin
    ep93xx_end <= 1'b1;
    ep93xx_end_q <= 1'b0;
  end

  if (ep93xx_end) begin
    ep93xx_end <= 1'b0;
    ep93xx_end_q <= 1'b1;
    epwbm_done32 <= 1'b0;
    epwbm_stb_o <= 1'b0;
    epwbm_done <= 1'b0;
    start_cycle_negedge_q <= 1'b0;
    start_cycle_posedge_q <= 1'b0;
    bd_oe_negedge_q <= 1'b0;
    bd_oe_posedge_q <= 1'b0;
  end
end

wire start_cycle_negedge_aset = !start_cycle_pad && pll_locked;
always @(posedge ep93xx_end_q or posedge start_cycle_negedge_aset) begin
  if (start_cycle_negedge_aset) start_cycle_negedge <= 1'b1;
  else start_cycle_negedge <= 1'b0;
end

always @(posedge start_cycle_pad or posedge ep93xx_end_q) begin
  if (ep93xx_end_q) start_cycle_posedge <= 1'b0;
  else if (start_cycle_negedge) start_cycle_posedge <= 1'b1;
end

always @(posedge start_cycle_pad) begin
  epwbm_we_o <= fl_d_pad[7]; 
  ep93xx_address[23] <= fl_d_pad[0];
  ep93xx_address[22] <= fl_d_pad[1];
  ep93xx_address[21] <= fl_d_pad[2];
  ep93xx_address[20:17] <= add_pad[3:0];
  ep93xx_address[16] <= fl_d_pad[3];
  ep93xx_address[15] <= isa_add15_pad;
  ep93xx_address[14] <= isa_add14_pad;
  ep93xx_address[13] <= fl_d_pad[4];
  ep93xx_address[12] <= isa_add12_pad;
  ep93xx_address[11] <= isa_add11_pad;
  ep93xx_address[10] <= bd_pad[0];
  ep93xx_address[9] <= bd_pad[1];
  ep93xx_address[8] <= bd_pad[2];
  ep93xx_address[7] <= bd_pad[3];
  ep93xx_address[6] <= bd_pad[4];
  ep93xx_address[5] <= bd_pad[5];
  ep93xx_address[4] <= bd_pad[6];
  ep93xx_address[3] <= bd_pad[7];
  ep93xx_address[2] <= fl_d_pad[5];
  ep93xx_address[1] <= isa_add1_pad;
  ep93xx_address[0] <= fl_d_pad[6];
end

always @(negedge bd_oe_pad or posedge ep93xx_end_q) begin
  if (ep93xx_end_q) bd_oe_negedge <= 1'b0;
  else if (start_cycle_posedge) bd_oe_negedge <= 1'b1;
end

always @(posedge bd_oe_pad or posedge ep93xx_end_q) begin
  if (ep93xx_end_q) bd_oe_posedge <= 1'b0;
  else if (bd_oe_negedge) bd_oe_posedge <= 1'b1;
end

wire [15:0] epwbm_wb32m_bridgecore_dat;
wire epwbm_wb32m_bridgecore_ack;
wire [31:0] wb32m_dat_o;
reg [31:0] wb32m_dat_i;
wire [21:0] wb32m_adr_o;
wire [3:0] wb32m_sel_o;
wire wb32m_cyc_o, wb32m_stb_o, wb32m_we_o;
reg wb32m_ack_i;
wire wb32m_clk_o = epwbm_clk_o;
wire wb32m_rst_o = epwbm_rst_o;
wb32_bridge epwbm_wb32m_bridgecore(
  .wb_clk_i(epwbm_clk_o),
  .wb_rst_i(epwbm_rst_o),

  .wb16_adr_i(epwbm_adr_o[23:1]),
  .wb16_dat_i(epwbm_dat_o),
  .wb16_dat_o(epwbm_wb32m_bridgecore_dat),
  .wb16_cyc_i(epwbm_cyc_o),
  .wb16_stb_i(epwbm_stb_o),
  .wb16_we_i(epwbm_we_o),
  .wb16_ack_o(epwbm_wb32m_bridgecore_ack),

  .wbm_adr_o(wb32m_adr_o),
  .wbm_dat_o(wb32m_dat_o),
  .wbm_dat_i(wb32m_dat_i),
  .wbm_cyc_o(wb32m_cyc_o),
  .wbm_stb_o(wb32m_stb_o),
  .wbm_we_o(wb32m_we_o),
  .wbm_ack_i(wb32m_ack_i),
  .wbm_sel_o(wb32m_sel_o)
);

/* At this point we have turned the multiplexed ep93xx bus cycle into a
 * WISHBONE master bus cycle with the local regs/wires:
 * 
 * [15:0] epwbm_dat_i -- WISHBONE master 16-bit databus input
 * [15:0] epwbm_dat_o -- WISHBONE master 16-bit databus output
 * epwbm_clk_o -- WISHBONE master clock output (75 Mhz)
 * epwbm_rst_o -- WISHBONE master reset output
 * [23:0] epwbm_adr_o -- WISHBONE byte address output
 * epwbm_we_o -- WISHBONE master write enable output
 * epwbm_stb_o -- WISHBONE master strobe output
 * epwbm_cyc_o -- WISHBONE master cycle output
 * epwbm_ack_i -- WISHBONE master ack input
 *
 * The WISHBONE slave or WISHBONE interconnect can withhold the bus cycle ack
 * as long as necessary as the above logic will ensure the processor will be
 * halted until the cycle is complete.  In that regard, it is possible
 * to lock up the processor if nothing acks the WISHBONE bus cycle. (!)
 *
 * Note that the above is only a 16-bit WISHBONE bus.  A special WISHBONE
 * to WISHBONE bridge is used to combine two back-to-back 16 bit reads or
 * writes into a single atomic 32-bit WISHBONE bus cycle.  Care should be
 * taken to never issue a byte or halfword ARM insn (ldrh, strh, ldrb, strb) to
 * address space handled here.  This bridge is presented as a secondary
 * WISHBONE master bus prefixed with wb32m_:
 * 
 * [31:0] wb32m_dat_i -- WISHBONE master 32-bit databus input
 * [31:0] wb32m_dat_o -- WISHBONE master 32-bit databus output
 * wb32m_clk_o -- WISHBONE master clock output (75 Mhz)
 * wb32m_rst_o -- WISHBONE master reset output
 * [21:0] wb32m_adr_o -- WISHBONE master word address
 * wb32m_we_o -- WISHBONE master write enable output
 * wb32m_stb_o -- WISHBONE master strobe output
 * wb32m_cyc_o -- WISHBONE master cycle output
 * wb32m_ack_i -- WISHBONE master ack input
 * wb32m_sel_o -- WISHBONE master select output -- always 4'b1111
 */

wire ethwbm_cyc_o, ethwbm_stb_o, ethwbm_we_o, ethwbm_ack_i;
wire [3:0] ethwbm_sel_o;
wire [31:0] ethwbm_dat_i, ethwbm_dat_o, ethwbm_adr_o;
wire ethramcore_ack;
wire [31:0] ethramcore_dat;

/* Ethernet packet ram from 0x7210_0000 - 0x7210_ffff (32-bit, 8Kbyte) 
 * This core is connected both to the ethernet core and to the 32-bit
 * WISHBONE bridge for access by the ep9302 CPU.  It has an internal 2-way 
 * arbiter between both its WISHBONE slave interfaces.  It also endian-swaps
 * so the CPU doesn't have to and Linux can just memcpy()* to copy from/to
 * this 8Kbyte packet RAM 32-bits at a time.  Technologic Systems provides
 * an GPL Linux 2.4 driver for this implementation of the open ethernet
 * core at these addresses.
 *
 * -- *Actually, it can't memcpy() if it uses the ARM ldm* and stm*
 *    instructions in this bus space since the ep9302 SMC strobes are
 *    not deasserted between consecutive accesses.  CPU has to use memcpy()
 *    in terms of ldr and str ARM insns.
 */
reg ethramcore_stb;
wb32_blockram #(.endian_swap(1'b1)) ethramcore(
  .wb_clk_i(wb32m_clk_o && ethernet),
  .wb_rst_i(wb32m_rst_o),
  .wb2_cyc_i(wb32m_cyc_o && ethernet),
  .wb2_stb_i(ethramcore_stb),
  .wb2_we_i(wb32m_we_o),
  .wb2_adr_i(wb32m_adr_o[10:0]),
  .wb2_dat_i(wb32m_dat_o),
  .wb2_dat_o(ethramcore_dat),
  .wb2_sel_i(wb32m_sel_o),
  .wb2_ack_o(ethramcore_ack),

  .wb1_cyc_i(ethwbm_cyc_o && ethernet),
  .wb1_stb_i(ethwbm_stb_o),
  .wb1_we_i(ethwbm_we_o),
  .wb1_adr_i(ethwbm_adr_o[12:2]), 
  .wb1_dat_i(ethwbm_dat_o),
  .wb1_dat_o(ethwbm_dat_i),
  .wb1_sel_i(ethwbm_sel_o),
  .wb1_ack_o(ethwbm_ack_i)
);

wire [31:0] ethcore_dat;
wire ethcore_ack, ethcore_irq;
wire ethcore_mdo, ethcore_mdoe;
reg ethcore_mdo_q, ethcore_mdoe_q;
reg ethcore_stb;
assign eth_mdio_pad = ethcore_mdoe_q ? ethcore_mdo_q : 1'bz;
eth_top ethcore(
  .wb_clk_i(wb32m_clk_o && ethernet),
  .wb_rst_i(wb32m_rst_o),
  .wb_dat_i(wb32m_dat_o),
  .wb_dat_o(ethcore_dat),
  .wb_adr_i(wb32m_adr_o[9:0]), 
  .wb_sel_i(wb32m_sel_o), 
  .wb_we_i(wb32m_we_o),
  .wb_cyc_i(wb32m_cyc_o), 
  .wb_stb_i(ethcore_stb), 
  .wb_ack_o(ethcore_ack), 

  .m_wb_adr_o(ethwbm_adr_o), 
  .m_wb_sel_o(ethwbm_sel_o), 
  .m_wb_we_o(ethwbm_we_o), 
  .m_wb_dat_o(ethwbm_dat_o), 
  .m_wb_dat_i(ethwbm_dat_i), 
  .m_wb_cyc_o(ethwbm_cyc_o), 
  .m_wb_stb_o(ethwbm_stb_o), 
  .m_wb_ack_i(ethwbm_ack_i), 

  //TX
  .mtx_clk_pad_i(eth_txclk_pad && ethernet), 
  .mtxd_pad_o(eth_txdat_pad), 
  .mtxen_pad_o(eth_txen_pad), 
  .mtxerr_pad_o(eth_txerr_pad),

  //RX
  .mrx_clk_pad_i(eth_rxclk_pad && ethernet), 
  .mrxd_pad_i(eth_rxdat_pad), 
  .mrxdv_pad_i(eth_rxdv_pad), 
  .mrxerr_pad_i(eth_rxerr_pad), 
  .mcoll_pad_i(eth_col_pad), 
  .mcrs_pad_i(eth_crs_pad), 
  
  // MIIM
  .mdc_pad_o(eth_mdc_pad), 
  .md_pad_i(eth_mdio_pad), 
  .md_pad_o(ethcore_mdo), 
  .md_padoe_o(ethcore_mdoe),

  .int_o(ethcore_irq)
);

always @(posedge epwbm_clk_o) begin
  ethcore_mdo_q <= ethcore_mdo;
  ethcore_mdoe_q <= ethcore_mdoe;
end

wire [31:0] usercore_dat;
wire usercore_ack;
reg usercore_stb;
reg [40:1] headerpin_i;
wire [40:1] headerpin_oe, headerpin_o;
integer i;
always @(headerpin_o or headerpin_oe or blue_pad or green_pad or red_pad or
  dio10to17_pad or dio0to8_pad or dio9_pad or vsync_pad or hsync_pad) begin
  blue_pad = 5'bzzzzz;
  red_pad = 5'bzzzzz;
  green_pad = 5'bzzzzz;
  for (i = 0; i < 5; i = i + 1) begin
    headerpin_i[1 + (i * 2)] = blue_pad[i];
    headerpin_i[11 + (i * 2)] = green_pad[i];
    headerpin_i[4 + (i * 2)] = red_pad[i];
 
    if (headerpin_oe[1 + (i * 2)]) 
      blue_pad[i] = headerpin_o[1 + (i * 2)];
    if (headerpin_oe[11 + (i * 2)])
      green_pad[i] = headerpin_o[11 + (i * 2)];
    if (headerpin_oe[4 + (i * 2)])
      red_pad[i] = headerpin_o[4 + (i * 2)];
  end

  dio10to17_pad = 8'bzzzzzzzz;
  dio0to8_pad = 9'bzzzzzzzzz;
  for (i = 0; i < 8; i = i + 1) begin
    headerpin_i[24 + (i * 2)] = dio10to17_pad[i];
    headerpin_i[21 + (i * 2)] = dio0to8_pad[i];

    if (headerpin_oe[24 + (i * 2)])
      dio10to17_pad[i] = headerpin_o[24 + (i * 2)];
    if (headerpin_oe[21 + (i * 2)])
      dio0to8_pad[i] = headerpin_o[21 + (i * 2)];
  end

  if (headerpin_oe[14]) hsync_pad = headerpin_o[14];
  else hsync_pad = 1'bz;

  if (headerpin_oe[16]) vsync_pad = headerpin_o[16];
  else vsync_pad = 1'bz;
  
  if (headerpin_oe[37]) dio0to8_pad[8] = headerpin_o[37];

  headerpin_i[39] = dio9_pad;

  headerpin_i[22] = 1'b0;
  headerpin_i[40] = 1'b1;
  headerpin_i[2] = 1'b0;
  headerpin_i[20] = 1'b1;
  headerpin_i[18] = 1'b0;
end
wire usercore_drq, usercore_irq;
ts7300_wishbone_slave usercore(
  .wb_clk_i(wb32m_clk_o),
  .wb_rst_i(wb32m_rst_o),
  .wb_cyc_i(wb32m_cyc_o),
  .wb_stb_i(usercore_stb),
  .wb_we_i(wb32m_we_o),
  .wb_ack_o(usercore_ack),
  .wb_dat_o(usercore_dat),
  .wb_dat_i(wb32m_dat_o),
  .wb_adr_i(wb32m_adr_o),

  .headerpin_i(headerpin_i[40:1]),
  .headerpin_o(headerpin_o[40:1]),
  .headerpin_oe_o(headerpin_oe[40:1]),

  .irq_o(usercore_irq)
);

/* IRQ7 is actually ep9302 VIC IRQ #40 */
assign irq7_pad = (ethcore_irq || usercore_irq) ? 1'b1 : 1'bz; 

/* Now we set up the address decode and the return WISHBONE master 
 * databus and ack signal multiplexors.  This is very simple, on the native
 * WISHBONE bus (epwbm_*) if the address is >= 0x72100000, the 16 to 32 bit
 * bridge is selected.  The 32 bit wishbone bus contains 3 wishbone 
 * slaves: the ethernet core, the ethernet packet RAM, and the usercore.  If the
 * address >= 0x72a00000 the usercore is strobed and expected to ack, for
 * address >= 0x72102000 the ethernet core is strobed and expected to ack
 * otherwise the bus cycle goes to the ethernet RAM core.
 */  
 
always @(epwbm_adr_o or epwbm_wb32m_bridgecore_dat or 
  epwbm_wb32m_bridgecore_ack or usercore_dat or usercore_ack or
  ethcore_dat or ethcore_ack or ethramcore_dat or ethramcore_ack or
  wb32m_adr_o or wb32m_stb_o) begin
  epwbm_dat_i = 16'hxxxx;
  epwbm_ack_i = 1'bx;
  if (epwbm_adr_o >= 24'h100000) begin
    epwbm_dat_i = epwbm_wb32m_bridgecore_dat;
    epwbm_ack_i = epwbm_wb32m_bridgecore_ack;
  end 

  usercore_stb = 1'b0;
  ethcore_stb = 1'b0;
  ethramcore_stb = 1'b0;
  if (wb32m_adr_o >= 22'h280000) begin
    usercore_stb = wb32m_stb_o;
    wb32m_dat_i = usercore_dat;
    wb32m_ack_i = usercore_ack;
  end else if (wb32m_adr_o >= 22'h40800) begin
    ethcore_stb = wb32m_stb_o;
    wb32m_dat_i = ethcore_dat;
    wb32m_ack_i = ethcore_ack;
  end else begin
    ethramcore_stb = wb32m_stb_o;
    wb32m_dat_i = ethramcore_dat;
    wb32m_ack_i = ethramcore_ack;
  end

end

/* Various defaults for signals not used in this boilerplate project: */

/* No use for DMA -- used by TS-SDCORE on shipped bitstream */
assign dma_req_pad = 1'bz;

/* PHY always on */
assign eth_pd_pad = 1'b1;

/* SDRAM signals outputing 0's -- used by TS-VIDCORE in shipped bitstream */
assign sdram_add_pad = 12'd0;
assign sdram_ba_pad = 2'd0;
assign sdram_cas_pad = 1'b0;
assign sdram_ras_pad = 1'b0;
assign sdram_we_pad = 1'b0;
assign sdram_clk_pad = 1'b0;
assign sdram_data_pad = 16'd0;

/* serial (RS232) mux signals safely "parked" -- used by TS-UART */
assign rd_mux_pad = 1'b1;
assign mux_cntrl_pad = 1'b0;
assign wr_232_pad = 1'b1;
assign mux_pad = 4'hz;

/* SD flash card signals "parked" -- used by TS-SDCORE */
assign sd_soft_power_pad = 1'b0;
assign sd_hard_power_pad = 1'b1;
assign sd_dat_pad = 4'hz;
assign sd_clk_pad = 1'b0;
assign sd_cmd_pad = 1'bz;

endmodule

