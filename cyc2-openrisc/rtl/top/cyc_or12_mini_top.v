//
// OR1K minimal configuration for Base2Designs OpenRISC development board
// Top Level.
// Only CPU, debug unit, on-chip RAM, UART, memory controller
// and SPI controller are configured.
// JTAG debug port not tested.
// Serial port runs at 9600 baud.
// The pll_30MHz_15MHz is set up to generate 30MHz and 15MHz from a 48MHz oscillator
// The project comes with sw/hello-uart/hello.intel.hex. You can create your
// own Intel hex files using hex2bram utility available at 
// http://www.base2designs.com/downloads/hex2bram.zip

//
// Author(s):
// - Steve Fielding, sfielding@base2designs.com
// - Serge Vakulenko, vak@cronyx.ru
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//

`include "cyc_or12_defines.v"
`include "or1200_defines.v"

module cyc_or12_mini_top (

  //
  // Global signals
  //
  clk,
  watchDogStrobe,

  //
  // UART signals
  //
  uart_stx,
  //uart_stx_temp,
  uart_srx,

  //
  // JTAG signals
  //
  jtag_tdi,
  jtag_tms,
  jtag_tck,
  jtag_trst,
  jtag_tdo,

  //
  // SDRAM
  //
  mc_addr,
  mc_ba,
  mc_dq,
  mc_dqm,
  mc_we_,
  mc_cas_,
  mc_ras_,
  mc_cke_,
  sdram_cs,
  sdram_clk,

  //
  // SPI bus
  //
  spiClk,
  spiMasterDataIn,
  spiMasterDataOut,
  spiCS_n,


  //
  // Santa Cruz header
  //
  SC_P_CLK,
  SC_RST_N,
  SC_CS_N,
  SC_P0,
  SC_P1,
  SC_P2,
  SC_P3,
  SC_P4,
  SC_P5,
  SC_P6,
  SC_P7,
  SC_P8,
  SC_P9,
  SC_P10,
  SC_P11,
  SC_P12,
  SC_P13,
  SC_P14,
  SC_P15,
  SC_P16,
  SC_P17,
  SC_P18,
  SC_P19,
  SC_P20,
  SC_P21,
  SC_P22,
  SC_P23,
  SC_P24,
  SC_P25,
  SC_P26,
  SC_P27,
  SC_P28,
  SC_P29,
  SC_P30,
  SC_P31,
  SC_P32,
  SC_P33,
  SC_P34,
  SC_P35,
  SC_P36,
  SC_P37,
  SC_P38,
  SC_P39



);
//
// Global signals
//
input	clk;
output watchDogStrobe;

//
// UART signals
//
output	uart_stx;
//output	uart_stx_temp;
input	uart_srx;

//
// JTAG signals
//
input	jtag_tdi;
input	jtag_tms;
input	jtag_tck;
input	jtag_trst;
output	jtag_tdo;


//
// SDRAM
//
output	[11:0]	mc_addr;
output	[1:0]	mc_ba;
inout	[31:0]	mc_dq;
output	[3:0]	mc_dqm;
output		mc_we_;
output		mc_cas_;
output		mc_ras_;
output		mc_cke_;
output		sdram_cs;
output		sdram_clk;

//
// SPI bus
//
output spiClk;
input spiMasterDataIn;
output spiMasterDataOut;
output spiCS_n;

  //
  // Santa Cruz header
  //
`ifdef PHY_ISP1105
  input SC_P_CLK;
  input SC_RST_N;
  input SC_CS_N;
  input SC_P0;
  input SC_P1;
  input SC_P2;
  input SC_P3;
  output SC_P4;
  input SC_P5;
  input SC_P6;
  input SC_P7;
  input SC_P8;
  input SC_P9;
  input SC_P10;
  input SC_P11;
  input SC_P12;
  input SC_P13;
  input SC_P14;
  input SC_P15;
  input SC_P16;
  input SC_P17;
  input SC_P18;
  input SC_P19;
  input SC_P20;
  input SC_P21;
  inout SC_P22;
  inout SC_P23;
  output SC_P24;
  inout SC_P25;
  output SC_P26;
  inout SC_P27;
  output SC_P28;
  input SC_P29;
  input SC_P30;
  input SC_P31;
  input SC_P32;
  input SC_P33;
  input SC_P34;
  input SC_P35;
  input SC_P36;
  input SC_P37;
  input SC_P38;
  input SC_P39;
`else
  output SC_P_CLK;
  output SC_RST_N;
  output SC_CS_N;
  output SC_P0;
  output SC_P1;
  input SC_P2;
  output SC_P3;
  input SC_P4;
  output SC_P5;
  output SC_P6;
  output SC_P7;
  output SC_P8;
  output SC_P9;
  output SC_P10;
  output SC_P11;
  output SC_P12;
  output SC_P13;
  output SC_P14;
  output SC_P15;
  output SC_P16;
  output SC_P17;
  output SC_P18;
  output SC_P19;
  output SC_P20;
  output SC_P21;
  input SC_P22;
  output SC_P23;
  input SC_P24;
  output SC_P25;
  output SC_P26;
  output SC_P27;
  output SC_P28;
  output SC_P29;
  output SC_P30;
  output SC_P31;
  output SC_P32;
  output SC_P33;
  output SC_P34;
  output SC_P35;
  output SC_P36;
  output SC_P37;
  output SC_P38;
  output SC_P39;
`endif
//----------------------
// Internal wires
//
wire watchDogStrobe;
reg [23:0] watchDogCnt;


//
// Debug core master i/f wires
//
wire 	[31:0]		wb_dm_adr_o;
wire 	[31:0] 		wb_dm_dat_i;
wire 	[31:0] 		wb_dm_dat_o;
wire 	[3:0]		wb_dm_sel_o;
wire			wb_dm_we_o;
wire 			wb_dm_stb_o;
wire			wb_dm_cyc_o;
wire			wb_dm_cab_o;
wire			wb_dm_ack_i;
wire			wb_dm_err_i;

//
// Debug <-> RISC wires
//
wire	[3:0]		dbg_lss;
wire	[1:0]		dbg_is;
wire	[10:0]		dbg_wp;
wire			dbg_bp;
wire	[31:0]		dbg_dat_dbg;
wire	[31:0]		dbg_dat_risc;
wire	[31:0]		dbg_adr;
wire			dbg_ewt;
wire			dbg_stall;
wire	[2:0]		dbg_op;

//
// RISC instruction master i/f wires
//
wire 	[31:0]		wb_rim_adr_o;
wire			wb_rim_cyc_o;
wire 	[31:0]		wb_rim_dat_i;
wire 	[31:0]		wb_rim_dat_o;
wire 	[3:0]		wb_rim_sel_o;
wire			wb_rim_ack_i;
wire			wb_rim_err_i;
wire			wb_rim_rty_i = 1'b0;
wire			wb_rim_we_o;
wire			wb_rim_stb_o;
wire			wb_rim_cab_o;

//
// RISC data master i/f wires
//
wire 	[31:0]		wb_rdm_adr_o;
wire			wb_rdm_cyc_o;
wire 	[31:0]		wb_rdm_dat_i;
wire 	[31:0]		wb_rdm_dat_o;
wire 	[3:0]		wb_rdm_sel_o;
wire			wb_rdm_ack_i;
wire			wb_rdm_err_i;
wire			wb_rdm_rty_i = 1'b0;
wire			wb_rdm_we_o;
wire			wb_rdm_stb_o;
wire			wb_rdm_cab_o;

//
// RISC misc
//
wire	[19:0]		pic_ints;

//
// SRAM controller slave i/f wires
//
wire 	[31:0]		wb_ss_dat_i;
wire 	[31:0]		wb_ss_dat_o;
wire 	[31:0]		wb_ss_adr_i;
wire 	[3:0]		wb_ss_sel_i;
wire			wb_ss_we_i;
wire			wb_ss_cyc_i;
wire			wb_ss_stb_i;
wire			wb_ss_ack_o;
wire			wb_ss_err_o;

//
// UART16550 core slave i/f wires
//
wire	[31:0]		wb_us_dat_i;
wire	[31:0]		wb_us_dat_o;
wire	[31:0]		wb_us_adr_i;
wire	[3:0]		wb_us_sel_i;
wire			wb_us_we_i;
wire			wb_us_cyc_i;
wire			wb_us_stb_i;
wire			wb_us_ack_o;
wire			wb_us_err_o;

//wire uart_srx;
//wire uart_stx;

//
// spiMaster core slave i/f wires
//
wire	[31:0]		wb_sds_dat_i;
wire 	[7:0]   	wb_sds_dat_8bit;
wire	[31:0]		wb_sds_dat_o;
wire	[31:0]		wb_sds_adr_i;
wire 	[3:0]       	wb_sds_sel_i;
wire			wb_sds_we_i;
wire			wb_sds_cyc_i;
wire			wb_sds_stb_i;
wire			wb_sds_ack_o;

//
// usbhost usb1 i/f wires
//
wire	[31:0]		wb_usb1_dat_i;
wire  	[7:0]       	wb_usb1_dat_8bit;
wire	[31:0]		wb_usb1_dat_o;
wire	[31:0]		wb_usb1_adr_i;
wire  	[3:0]       	wb_usb1_sel_i;
wire			wb_usb1_we_i;
wire			wb_usb1_cyc_i;
wire			wb_usb1_stb_i;
wire			wb_usb1_ack_o;

wire usbHostVP;
wire usbHostVM;
wire usbHostOE_n;
wire usbHostVPin;
wire usbHostVMin;
wire usbHostVPout;
wire usbHostVMout;
wire usbHostFullSpeed;

//
// usbSlave usb2 i/f wires
//
wire	[31:0]		wb_usb2_dat_i;
wire  	[7:0]       	wb_usb2_dat_8bit;
wire	[31:0]		wb_usb2_dat_o;
wire	[31:0]		wb_usb2_adr_i;
wire  	[3:0]       	wb_usb2_sel_i;
wire			wb_usb2_we_i;
wire			wb_usb2_cyc_i;
wire			wb_usb2_stb_i;
wire			wb_usb2_ack_o;

wire usbSlaveVP;
wire usbSlaveVM;
wire vBusDetect;
wire usbSlaveVPin;
wire usbSlaveVMin;
wire usbSlaveVPout;
wire usbSlaveVMout;
wire usbDPlusPullup;
wire usbDMinusPullup;
wire usbSlaveFullSpeed;

//
// Reset debounce
//
wire			rst;
reg			rst_r;
reg			wb_rst;
wire        pll_locked_n;

//
// SDRAM
//
wire	[31:0]	mc_data_i;
wire	[31:0]	mc_data_o;
wire		mc_data_oe;
wire	[23:0]	_mc_addr;
wire	[3:0]	_mc_dqm;
wire		_mc_we_;
wire		_mc_cas_;
wire		_mc_ras_;
wire		_mc_cke_;
wire	[7:0]	_mc_cs_;
wire		mc_c_oe;

wire	[31:0]	wb_mc_dat_i;
wire	[31:0]	wb_mc_dat_o;
wire	[31:0]	wb_mc_adr_i;
wire	[3:0]	wb_mc_sel_i;
wire		wb_mc_we_i;
wire		wb_mc_cyc_i;
wire		wb_mc_stb_i;
wire		wb_mc_ack_o;
wire		wb_mc_err_o;


//
// reg wire selection
//
`ifdef SIM_COMPILE
reg			wb_clk;
reg			mem_clk;
reg 			pll_locked;
`else
wire			wb_clk;
wire			mem_clk;
wire 			pll_locked;
`endif

assign pll_locked_n = ~pll_locked;

//assign uart_stx_temp = uart_stx;

//
// generate reset
//
always @(posedge wb_clk or posedge pll_locked_n)
	if (pll_locked_n)
		rst_r <= 1'b1;
	else
		rst_r <= 1'b0;

//
// sync wb_rst to wb_clk
//
always @(posedge wb_clk)
	wb_rst <= #1 rst_r;

//
// This is purely for testing 1/2 WB clock
// This should never be used when implementing in
// an FPGA. It is used only for simulation regressions.
//
`ifdef SIM_COMPILE

initial begin
  wb_clk = 0;
  pll_locked = 0;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  pll_locked = 1;
end

always @(posedge clk)
	wb_clk = ~wb_clk;

always @(posedge wb_clk) begin
  if (mem_clk != 1'b0)
    mem_clk <= 1'b0;
  else 
    mem_clk <= 1'b1;
end


`else // not SIM_COMPILE
//
// Some Xilinx P&R tools need this
//
`ifdef TARGET_VIRTEX
`ifdef USE_DIRECT_CLOCK

IBUFG IBUFG1 (
	.O	( wb_clk ),
	.I	( clk )
);

`else // not USE_DIRECT_CLOCK

//
// Divide clock by 10
//
wire clock_feedback_output, clock_feedback_input, dll_output;
CLKDLL clkdiv (
	.CLKIN (clk),
	.CLKFB (clock_feedback_input),
	.RST (1'b0),
	.CLK0 (clock_feedback_output),
	.CLKDV (dll_output));
// synthesis attribute CLKDV_DIVIDE of clkdiv is "10.0"
BUFG clkg1 (.I (clock_feedback_output), .O (clock_feedback_input));
BUFG clkg2 (.I (dll_output), .O (wb_clk));

`endif // USE_DIRECT_CLOCK
`else // not TARGET_VIRTEX

`ifdef CYCLONE


pll_30MHz_15MHz	pll_30MHz_15MHz_inst (
	.inclk0 ( clk ),
	.c0 ( wb_clk ),
	.c1 ( mem_clk ),
	.locked( pll_locked)
	);

`else //not CYCLONE

assign wb_clk = clk;


`endif

`endif // TARGET_VIRTEX
`endif // SIM_COMPILE

//
// Unused interrupts
//
assign pic_ints[`APP_INT_RES1] = 'b0;
assign pic_ints[`APP_INT_RES2] = 'b0;
assign pic_ints[`APP_INT_RES3] = 'b0;
assign pic_ints[`APP_INT_ETH] = 'b0;
assign pic_ints[`APP_INT_PS2] = 'b0;

//
// Unused WISHBONE signals
//
assign wb_us_err_o = 1'b0;

//
// Instantiation of the development i/f model
//
// Used only for simulations.
//
`ifdef DBG_IF_MODEL
dbg_if_model dbg_if_model  (

	// JTAG pins
	.tdi_pad_i	( jtag_tdi ),
	.tms_pad_i	( jtag_tms ),
	.tck_pad_i	( jtag_tck ),
	.trst_pad_i	( ~jtag_trst ),
	.tdi_pad_i	( jtag_tdi ),
	.tdo_pad_o	( jtag_tdo ),

	// Boundary Scan signals
	.capture_dr_o	( ),
	.shift_dr_o	( ),
	.update_dr_o	( ),
	.extest_selected_o ( ),
	.bs_chain_i	( 1'b0 ),

	// RISC signals
	.risc_clk_i	( wb_clk ),
	.risc_data_i	( dbg_dat_risc ),
	.risc_data_o	( dbg_dat_dbg ),
	.risc_addr_o	( dbg_adr ),
	.wp_i		( dbg_wp ),
	.bp_i		( dbg_bp ),
	.opselect_o	( dbg_op ),
	.lsstatus_i	( dbg_lss ),
	.istatus_i	( dbg_is ),
	.risc_stall_o	( dbg_stall ),
	.reset_o	( ),

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE master interface
	.wb_adr_o	( wb_dm_adr_o ),
	.wb_dat_i	( wb_dm_dat_i ),
	.wb_dat_o	( wb_dm_dat_o ),
	.wb_sel_o	( wb_dm_sel_o ),
	.wb_we_o	( wb_dm_we_o  ),
	.wb_stb_o	( wb_dm_stb_o ),
	.wb_cyc_o	( wb_dm_cyc_o ),
	.wb_cab_o	( wb_dm_cab_o ),
	.wb_ack_i	( wb_dm_ack_i ),
	.wb_err_i	( wb_dm_err_i )
);
`else
//
// Instantiation of the development i/f
//
dbg_top dbg_top  (

	// JTAG pins
	.tms_pad_i	( jtag_tms ),
	.tck_pad_i	( jtag_tck ),
	.trst_pad_i	( ~jtag_trst ),
	.tdi_pad_i	( jtag_tdi ),
	//.tms_pad_i	( 1'b1 ),
	//.tck_pad_i	( 1'b0 ),
	//.trst_pad_i	(wb_rst ),
	//.tdi_pad_i	( 1'b1 ),
	.tdo_pad_o	( jtag_tdo ),
	.tdo_padoen_o	( ),

	// Boundary Scan signals
	.capture_dr_o	( ),
	.shift_dr_o	( ),
	.update_dr_o	( ),
	.extest_selected_o ( ),
	.bs_chain_i	( 1'b0 ),
	.bs_chain_o	( ),

	// RISC signals
	.risc_clk_i	( wb_clk ),
	.risc_addr_o	( dbg_adr ),
	.risc_data_i	( dbg_dat_risc ),
	.risc_data_o	( dbg_dat_dbg ),
	.wp_i		( dbg_wp ),
	.bp_i		( dbg_bp ),
	.opselect_o	( dbg_op ),
	.lsstatus_i	( dbg_lss ),
	.istatus_i	( dbg_is ),
	.risc_stall_o	( dbg_stall ),
	.reset_o	( ),

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE master interface
	.wb_adr_o	( wb_dm_adr_o ),
	.wb_dat_i	( wb_dm_dat_i ),
	.wb_dat_o	( wb_dm_dat_o ),
	.wb_sel_o	( wb_dm_sel_o ),
	.wb_we_o	( wb_dm_we_o  ),
	.wb_stb_o	( wb_dm_stb_o ),
	.wb_cyc_o	( wb_dm_cyc_o ),
	.wb_cab_o	( wb_dm_cab_o ),
	.wb_ack_i	( wb_dm_ack_i ),
	.wb_err_i	( wb_dm_err_i )
);
`endif

//
// Generate watchdog strobe
//
always @(posedge wb_clk) begin
  if (wb_rst == 1'b1)
    watchDogCnt <= {24{1'b0}};
  else
    watchDogCnt <= watchDogCnt + 1'b1;
end
assign watchDogStrobe = watchDogCnt[23];

//
// Instantiation of the OR1200 RISC
//
or1200_top or1200_top (

	// Common
	.rst_i		( wb_rst ),
	.clk_i		( wb_clk ),
`ifdef OR1200_CLMODE_1TO2
	.clmode_i	( 2'b01 ),
`else
`ifdef OR1200_CLMODE_1TO4
	.clmode_i	( 2'b11 ),
`else
	.clmode_i	( 2'b00 ),
`endif
`endif

	// WISHBONE Instruction Master
	.iwb_clk_i	( wb_clk ),
	.iwb_rst_i	( wb_rst ),
	.iwb_cyc_o	( wb_rim_cyc_o ),
	.iwb_adr_o	( wb_rim_adr_o ),
	.iwb_dat_i	( wb_rim_dat_i ),
	.iwb_dat_o	( wb_rim_dat_o ),
	.iwb_sel_o	( wb_rim_sel_o ),
	.iwb_ack_i	( wb_rim_ack_i ),
	.iwb_err_i	( wb_rim_err_i ),
	.iwb_rty_i	( wb_rim_rty_i ),
	.iwb_we_o	( wb_rim_we_o  ),
	.iwb_stb_o	( wb_rim_stb_o ),
	.iwb_cab_o	( wb_rim_cab_o ),

	// WISHBONE Data Master
	.dwb_clk_i	( wb_clk ),
	.dwb_rst_i	( wb_rst ),
	.dwb_cyc_o	( wb_rdm_cyc_o ),
	.dwb_adr_o	( wb_rdm_adr_o ),
	.dwb_dat_i	( wb_rdm_dat_i ),
	.dwb_dat_o	( wb_rdm_dat_o ),
	.dwb_sel_o	( wb_rdm_sel_o ),
	.dwb_ack_i	( wb_rdm_ack_i ),
	.dwb_err_i	( wb_rdm_err_i ),
	.dwb_rty_i	( wb_rdm_rty_i ),
	.dwb_we_o	( wb_rdm_we_o  ),
	.dwb_stb_o	( wb_rdm_stb_o ),
	.dwb_cab_o	( wb_rdm_cab_o ),

	// Debug
	.dbg_stall_i	( dbg_stall ),
	.dbg_dat_i	( dbg_dat_dbg ),
	.dbg_adr_i	( dbg_adr ),
	.dbg_ewt_i	( 1'b0 ),
	.dbg_lss_o	( dbg_lss ),
	.dbg_is_o	( dbg_is ),
	.dbg_wp_o	( dbg_wp ),
	.dbg_bp_o	( dbg_bp ),
	.dbg_dat_o	( dbg_dat_risc ),
	.dbg_ack_o	( ),
	.dbg_stb_i	( dbg_op[2] ),
	.dbg_we_i	( dbg_op[0] ),

	// Power Management
	.pm_clksd_o	( ),
	.pm_cpustall_i	( 1'b0 ),
	.pm_dc_gate_o	( ),
	.pm_ic_gate_o	( ),
	.pm_dmmu_gate_o	( ),
	.pm_immu_gate_o	( ),
	.pm_tt_gate_o	( ),
	.pm_cpu_gate_o	( ),
	.pm_wakeup_o	( ),
	.pm_lvolt_o	( ),

	// Interrupts
	.pic_ints_i	( pic_ints )
);

//
// Instantiation of the on-chip RAM
//
`ifdef SIM_COMPILE
generic_sram_top onchip_ram_top (
`else
onchip_ram_top onchip_ram_top (
`endif

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_dat_i	( wb_ss_dat_i ),
	.wb_dat_o	( wb_ss_dat_o ),
	.wb_adr_i	( wb_ss_adr_i ),
	.wb_sel_i	( wb_ss_sel_i ),
	.wb_we_i	( wb_ss_we_i  ),
	.wb_cyc_i	( wb_ss_cyc_i ),
	.wb_stb_i	( wb_ss_stb_i ),
	.wb_ack_o	( wb_ss_ack_o ),
	.wb_err_o	( wb_ss_err_o )
);
//
// Instantiation of the UART16550
//
uart_top uart_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_adr_i	( wb_us_adr_i[4:0] ),
	.wb_dat_i	( wb_us_dat_i ),
	.wb_dat_o	( wb_us_dat_o ),
	.wb_we_i	( wb_us_we_i  ),
	.wb_stb_i	( wb_us_stb_i ),
	.wb_cyc_i	( wb_us_cyc_i ),
	.wb_ack_o	( wb_us_ack_o ),
	.wb_sel_i	( wb_us_sel_i ),

	// Interrupt request
	.int_o		( pic_ints[`APP_INT_UART] ),

	// UART signals
	// serial input/output
	.stx_pad_o	( uart_stx ),
	.srx_pad_i	( uart_srx ),

	// modem signals
	.rts_pad_o	( ),
	.cts_pad_i	( 1'b0 ),
	.dtr_pad_o	( ),
	.dsr_pad_i	( 1'b0 ),
	.ri_pad_i	( 1'b0 ),
	.dcd_pad_i	( 1'b0 )
);

spiMaster u_spiMaster (
  //Wishbone bus
  .clk_i(wb_clk),
  .rst_i(wb_rst),
  .address_i(wb_sds_adr_i[7:0]),
  .data_i(wb_sds_dat_i[7:0]),
  .data_o(wb_sds_dat_8bit),
  .strobe_i(wb_sds_stb_i),
  .we_i(wb_sds_we_i),
  .ack_o(wb_sds_ack_o),

  // SPI logic clock
  .spiSysClk(clk),
  //.spiSysClk(wb_clk),

  //SPI bus
  .spiClkOut(spiClk),
  .spiDataIn(spiMasterDataIn),
  .spiDataOut(spiMasterDataOut),
  .spiCS_n(spiCS_n)
);

assign wb_sds_dat_o = {wb_sds_dat_8bit, wb_sds_dat_8bit, wb_sds_dat_8bit, wb_sds_dat_8bit};

`ifdef PHY_ISP1105
usbHostCyc2Wrap usb1_usbHostCyc2Wrap (
  //Wishbone bus
  .clk_i(wb_clk), 
  .rst_i(wb_rst),
  .address_i(wb_usb1_adr_i[7:0]), 
  .data_i(wb_usb1_dat_i[7:0]), 
  .data_o(wb_usb1_dat_8bit), 
  .we_i(wb_usb1_we_i), 
  .strobe_i(wb_usb1_stb_i),
  .ack_o(wb_usb1_ack_o),

  .irq(usb1_irq), 
  .usbClk(clk),
  .USBWireVP(usbHostVP),
  .USBWireVM(usbHostVM),
  .USBWireOE_n(usbHostOE_n),
  .USBFullSpeed()
   );
`else
usbHostCyc2Wrap_usb1t11 usb1_usbHostCyc2Wrap (
  //Wishbone bus
  .clk_i(wb_clk), 
  .rst_i(wb_rst),
  .address_i(wb_usb1_adr_i[7:0]), 
  .data_i(wb_usb1_dat_i[7:0]), 
  .data_o(wb_usb1_dat_8bit), 
  .we_i(wb_usb1_we_i), 
  .strobe_i(wb_usb1_stb_i),
  .ack_o(wb_usb1_ack_o),

  .irq(usb1_irq), 
  .usbClk(clk),
  .USBWireVPin(usbHostVPin),
  .USBWireVMin(usbHostVMin),
  .USBWireVPout(usbHostVPout),
  .USBWireVMout(usbHostVMout),
  .USBWireOE_n(usbHostOE_n),
  .USBFullSpeed(usbHostFullSpeed)
   );
`endif

assign wb_usb1_dat_o = {wb_usb1_dat_8bit, wb_usb1_dat_8bit, wb_usb1_dat_8bit, wb_usb1_dat_8bit};


`ifdef PHY_ISP1105
usbSlaveCyc2Wrap usb2_usbSlaveCyc2Wrap (
  //Wishbone bus
  .clk_i(wb_clk), 
  .rst_i(wb_rst),
  .address_i(wb_usb2_adr_i[7:0]), 
  .data_i(wb_usb2_dat_i[7:0]), 
  .data_o(wb_usb2_dat_8bit), 
  .we_i(wb_usb2_we_i), 
  .strobe_i(wb_usb2_stb_i),
  .ack_o(wb_usb2_ack_o),

  .irq(usb2_irq), 
  .usbClk(clk),
  .USBWireVP(usbSlaveVP),
  .USBWireVM(usbSlaveVM),
  .USBWireOE_n(usbSlaveOE_n),
  .USBFullSpeed(),
  .USBDPlusPullup(usbDPlusPullup),
  .USBDMinusPullup(),
  .vBusDetect(vBusDetect)
   );
`else
usbSlaveCyc2Wrap_usb1t11 usb2_usbSlaveCyc2Wrap (
  //Wishbone bus
  .clk_i(wb_clk), 
  .rst_i(wb_rst),
  .address_i(wb_usb2_adr_i[7:0]), 
  .data_i(wb_usb2_dat_i[7:0]), 
  .data_o(wb_usb2_dat_8bit), 
  .we_i(wb_usb2_we_i), 
  .strobe_i(wb_usb2_stb_i),
  .ack_o(wb_usb2_ack_o),

  .irq(usb2_irq), 
  .usbClk(clk),
  .USBWireVPin(usbSlaveVPin),
  .USBWireVMin(usbSlaveVMin),
  .USBWireVPout(usbSlaveVPout),
  .USBWireVMout(usbSlaveVMout),
  .USBWireOE_n(usbSlaveOE_n),
  .USBFullSpeed(usbSlaveFullSpeed),
  .USBDPlusPullup(usbDPlusPullup),
  .USBDMinusPullup(usbDMinusPullup),
  .vBusDetect(1'b1)
   );
`endif

assign wb_usb2_dat_o = {wb_usb2_dat_8bit, wb_usb2_dat_8bit, wb_usb2_dat_8bit, wb_usb2_dat_8bit};


/////////////////////////////////////////////////////////////////////
//
// WISHBONE Memory Controller IP Core
//
mc_top	u_mc_top(
		.clk_i(		wb_clk		),
		.rst_i(		wb_rst		),
		.wb_data_i(	wb_mc_dat_i	),
		.wb_data_o(	wb_mc_dat_o	),
		.wb_addr_i(	wb_mc_adr_i	),
		.wb_sel_i(	wb_mc_sel_i	),
		.wb_we_i(	wb_mc_we_i	),
		.wb_cyc_i(	wb_mc_cyc_i	),
		.wb_stb_i(	wb_mc_stb_i	),
		.wb_ack_o(	wb_mc_ack_o	),
		.wb_err_o(	wb_mc_err_o	),
		.susp_req_i(	1'b0	),
		.resume_req_i(	1'b0	),
		.suspended_o(		),
		.poc_o(				),
		.mc_clk_i(	mem_clk		),
		.mc_br_pad_i(	1'b0		),
		.mc_bg_pad_o(			),
		.mc_ack_pad_i(	1'b0		),
		.mc_addr_pad_o(	_mc_addr	),
		.mc_data_pad_i(	mc_data_i	),
		.mc_data_pad_o(	mc_data_o	),
		.mc_dp_pad_i(	4'b0000		),
		.mc_dp_pad_o(			),
		.mc_doe_pad_doe_o(mc_data_oe	),
		.mc_dqm_pad_o(	_mc_dqm		),
		.mc_oe_pad_o_(			),
		.mc_we_pad_o_(	_mc_we_		),
		.mc_cas_pad_o_(	_mc_cas_	),
		.mc_ras_pad_o_(	_mc_ras_	),
		.mc_cke_pad_o_(	_mc_cke_	),
		.mc_cs_pad_o_(	_mc_cs_		),
		.mc_sts_pad_i(	1'b0		),
		.mc_rp_pad_o_(			),
		.mc_vpen_pad_o(		),
		.mc_adsc_pad_o_(	),
		.mc_adv_pad_o_(		),
		.mc_zz_pad_o(			),
		.mc_coe_pad_coe_o(mc_c_oe	)
		);

assign  mc_dq = mc_data_oe ? mc_data_o : 32'hzzzz_zzzz;
assign  mc_data_i = mc_dq;

assign  mc_addr = mc_c_oe ? _mc_addr[11:0] : 12'bz;
assign  mc_ba = mc_c_oe ? _mc_addr[14:13] : 2'bz;
assign  mc_dqm = mc_c_oe ? _mc_dqm : 4'bz;
assign  mc_we_ = mc_c_oe ? _mc_we_ : 1'bz;
assign  mc_cas_ = mc_c_oe ? _mc_cas_ : 1'bz;
assign  mc_ras_ = mc_c_oe ? _mc_ras_ : 1'bz;
assign  mc_cke_ = mc_c_oe ? _mc_cke_ : 1'bz;
assign  sdram_cs = mc_c_oe ? _mc_cs_[0] : 1'bz;

`ifdef SIM_COMPILE
assign sdram_clk = mem_clk;
`else
ddrClkOut u_ddrClkOut (
    .datain_h (1'b0),
    .datain_l (1'b1),
    .outclock (mem_clk),
    .aclr (wb_rst),
    .dataout (sdram_clk)
);
`endif

//
// Instantiation of the Traffic COP
//
tc_top #(`APP_ADDR_DEC_W,
	 `APP_ADDR_SRAM,   //Target 0 address
	 `APP_ADDR_DEC_DRAM_W,
	 `APP_ADDR_DRAM,   //Target 1 address
	 `APP_ADDR_DECP_W,
	 `APP_ADDR_PERIP,  //Target 2-8 address base
	 `APP_ADDR_DEC_W,
	 `APP_ADDR_VGA,     //Target 2 address offset
	 `APP_ADDR_ETH,     //Target 3 address offset
	 `APP_ADDR_USB1,    //Target 4 address offset
	 `APP_ADDR_UART,    //Target 5 address offset
	 `APP_ADDR_USB2,    //Target 6 address offset
	 `APP_ADDR_SD,      //Target 7 address offset
	 `APP_ADDR_RES2     //Target 8 address offset
	) tc_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE Initiator 0
	.i0_wb_cyc_i	( 1'b0 ),
	.i0_wb_stb_i	( 1'b0 ),
	.i0_wb_cab_i	( 1'b0 ),
	.i0_wb_adr_i	( 32'h0000_0000 ),
	.i0_wb_sel_i	( 4'b0000 ),
	.i0_wb_we_i	( 1'b0 ),
	.i0_wb_dat_i	( 32'h0000_0000 ),
	.i0_wb_dat_o	( ),
	.i0_wb_ack_o	( ),
	.i0_wb_err_o	( ),

	// WISHBONE Initiator 1
	.i1_wb_cyc_i	( 1'b0 ),
	.i1_wb_stb_i	( 1'b0 ),
	.i1_wb_cab_i	( 1'b0 ),
	.i1_wb_adr_i	( 32'h0000_0000 ),
	.i1_wb_sel_i	( 4'b0000 ),
	.i1_wb_we_i	( 1'b0 ),
	.i1_wb_dat_i	( 32'h0000_0000 ),
	.i1_wb_dat_o	( ),
	.i1_wb_ack_o	( ),
	.i1_wb_err_o	( ),

	// WISHBONE Initiator 2
	.i2_wb_cyc_i	( 1'b0 ),
	.i2_wb_stb_i	( 1'b0 ),
	.i2_wb_cab_i	( 1'b0 ),
	.i2_wb_adr_i	( 32'h0000_0000 ),
	.i2_wb_sel_i	( 4'b0000 ),
	.i2_wb_we_i	( 1'b0 ),
	.i2_wb_dat_i	( 32'h0000_0000 ),
	.i2_wb_dat_o	( ),
	.i2_wb_ack_o	( ),
	.i2_wb_err_o	( ),

	// WISHBONE Initiator 3
	// Risc debug
	.i3_wb_cyc_i	( wb_dm_cyc_o ),
	.i3_wb_stb_i	( wb_dm_stb_o ),
	.i3_wb_cab_i	( wb_dm_cab_o ),
	.i3_wb_adr_i	( wb_dm_adr_o ),
	.i3_wb_sel_i	( wb_dm_sel_o ),
	.i3_wb_we_i	( wb_dm_we_o  ),
	.i3_wb_dat_i	( wb_dm_dat_o ),
	.i3_wb_dat_o	( wb_dm_dat_i ),
	.i3_wb_ack_o	( wb_dm_ack_i ),
	.i3_wb_err_o	( wb_dm_err_i ),

	// WISHBONE Initiator 4
	// Risc Data Master
	.i4_wb_cyc_i	( wb_rdm_cyc_o ),
	.i4_wb_stb_i	( wb_rdm_stb_o ),
	.i4_wb_cab_i	( wb_rdm_cab_o ),
	.i4_wb_adr_i	( wb_rdm_adr_o ),
	.i4_wb_sel_i	( wb_rdm_sel_o ),
	.i4_wb_we_i	( wb_rdm_we_o  ),
	.i4_wb_dat_i	( wb_rdm_dat_o ),
	.i4_wb_dat_o	( wb_rdm_dat_i ),
	.i4_wb_ack_o	( wb_rdm_ack_i ),
	.i4_wb_err_o	( wb_rdm_err_i ),

	// WISHBONE Initiator 5
	// Risc Instruction Master
	.i5_wb_cyc_i	( wb_rim_cyc_o ),
	.i5_wb_stb_i	( wb_rim_stb_o ),
	.i5_wb_cab_i	( wb_rim_cab_o ),
	.i5_wb_adr_i	( wb_rim_adr_o ),
	.i5_wb_sel_i	( wb_rim_sel_o ),
	.i5_wb_we_i	( wb_rim_we_o  ),
	.i5_wb_dat_i	( wb_rim_dat_o ),
	.i5_wb_dat_o	( wb_rim_dat_i ),
	.i5_wb_ack_o	( wb_rim_ack_i ),
	.i5_wb_err_o	( wb_rim_err_i ),

	// WISHBONE Initiator 6
	.i6_wb_cyc_i	( 1'b0 ),
	.i6_wb_stb_i	( 1'b0 ),
	.i6_wb_cab_i	( 1'b0 ),
	.i6_wb_adr_i	( 32'h0000_0000 ),
	.i6_wb_sel_i	( 4'b0000 ),
	.i6_wb_we_i	( 1'b0 ),
	.i6_wb_dat_i	( 32'h0000_0000 ),
	.i6_wb_dat_o	( ),
	.i6_wb_ack_o	( ),
	.i6_wb_err_o	( ),

	// WISHBONE Initiator 7
	.i7_wb_cyc_i	( 1'b0 ),
	.i7_wb_stb_i	( 1'b0 ),
	.i7_wb_cab_i	( 1'b0 ),
	.i7_wb_adr_i	( 32'h0000_0000 ),
	.i7_wb_sel_i	( 4'b0000 ),
	.i7_wb_we_i	( 1'b0 ),
	.i7_wb_dat_i	( 32'h0000_0000 ),
	.i7_wb_dat_o	( ),
	.i7_wb_ack_o	( ),
	.i7_wb_err_o	( ),

	// WISHBONE Target 0
	// Onchip RAM
	.t0_wb_cyc_o	( wb_ss_cyc_i ),
	.t0_wb_stb_o	( wb_ss_stb_i ),
	.t0_wb_cab_o	(  ),
	.t0_wb_adr_o	( wb_ss_adr_i ),
	.t0_wb_sel_o	( wb_ss_sel_i ),
	.t0_wb_we_o	( wb_ss_we_i  ),
	.t0_wb_dat_o	( wb_ss_dat_i ),
	.t0_wb_dat_i	( wb_ss_dat_o ),
	.t0_wb_ack_i	( wb_ss_ack_o ),
	.t0_wb_err_i	( wb_ss_err_o ),

	// WISHBONE Target 1
	// SDRAM
	.t1_wb_cyc_o	( wb_mc_cyc_i ),
	.t1_wb_stb_o	( wb_mc_stb_i ),
	.t1_wb_cab_o	(  ),
	.t1_wb_adr_o	( wb_mc_adr_i ),
	.t1_wb_sel_o	( wb_mc_sel_i ),
	.t1_wb_we_o	( wb_mc_we_i  ),
	.t1_wb_dat_o	( wb_mc_dat_i ),
	.t1_wb_dat_i	( wb_mc_dat_o ),
	.t1_wb_ack_i	( wb_mc_ack_o ),
	.t1_wb_err_i	( wb_mc_err_o ),

	// WISHBONE Target 2
	.t2_wb_cyc_o	( ),
	.t2_wb_stb_o	( ),
	.t2_wb_cab_o	( ),
	.t2_wb_adr_o	( ),
	.t2_wb_sel_o	( ),
	.t2_wb_we_o	( ),
	.t2_wb_dat_o	( ),
	.t2_wb_dat_i	( 32'h0000_0000 ),
	.t2_wb_ack_i	( 1'b0 ),
	.t2_wb_err_i	( 1'b1 ),

	// WISHBONE Target 3
	.t3_wb_cyc_o	( ),
	.t3_wb_stb_o	( ),
	.t3_wb_cab_o	( ),
	.t3_wb_adr_o	( ),
	.t3_wb_sel_o	( ),
	.t3_wb_we_o	( ),
	.t3_wb_dat_o	( ),
	.t3_wb_dat_i	( 32'h0000_0000 ),
	.t3_wb_ack_i	( 1'b0 ),
	.t3_wb_err_i	( 1'b1 ),

	// WISHBONE Target 4
	// USB Host
	.t4_wb_cyc_o	( wb_usb1_cyc_i ),
	.t4_wb_stb_o	( wb_usb1_stb_i ),
	.t4_wb_cab_o	( wb_usb1_cab_i ),
	.t4_wb_adr_o	( wb_usb1_adr_i ),
	.t4_wb_sel_o	( wb_usb1_sel_i ),
	.t4_wb_we_o	( wb_usb1_we_i ),
	.t4_wb_dat_o	( wb_usb1_dat_i ),
	.t4_wb_dat_i	( wb_usb1_dat_o ),
	.t4_wb_ack_i	( wb_usb1_ack_o ),
	.t4_wb_err_i	( 1'b0 ),

	// WISHBONE Target 5
	// UART
	.t5_wb_cyc_o	( wb_us_cyc_i ),
	.t5_wb_stb_o	( wb_us_stb_i ),
	.t5_wb_cab_o	( wb_us_cab_i ),
	.t5_wb_adr_o	( wb_us_adr_i ),
	.t5_wb_sel_o	( wb_us_sel_i ),
	.t5_wb_we_o	( wb_us_we_i  ),
	.t5_wb_dat_o	( wb_us_dat_i ),
	.t5_wb_dat_i	( wb_us_dat_o ),
	.t5_wb_ack_i	( wb_us_ack_o ),
	.t5_wb_err_i	( wb_us_err_o ),

	// WISHBONE Target 6
	// USB Slave
	.t6_wb_cyc_o	( wb_usb2_cyc_i ),
	.t6_wb_stb_o	( wb_usb2_stb_i ),
	.t6_wb_cab_o	( wb_usb2_cab_i ),
	.t6_wb_adr_o	( wb_usb2_adr_i ),
	.t6_wb_sel_o	( wb_usb2_sel_i ),
	.t6_wb_we_o	( wb_usb2_we_i ),
	.t6_wb_dat_o	( wb_usb2_dat_i ),
	.t6_wb_dat_i	( wb_usb2_dat_o ),
	.t6_wb_ack_i	( wb_usb2_ack_o ),
	.t6_wb_err_i	( 1'b0 ),

	// WISHBONE Target 7
	// SPI bus (Secure Digital memory card)
	.t7_wb_cyc_o	( wb_sds_cyc_i ),
	.t7_wb_stb_o	( wb_sds_stb_i ),
	.t7_wb_cab_o	( wb_sds_cab_i),
	.t7_wb_adr_o	( wb_sds_adr_i),
	.t7_wb_sel_o	(wb_sds_sel_i ),
	.t7_wb_we_o	( wb_sds_we_i),
	.t7_wb_dat_o	( wb_sds_dat_i),
	.t7_wb_dat_i	( wb_sds_dat_o ),
	.t7_wb_ack_i	( wb_sds_ack_o ),
	.t7_wb_err_i	( 1'b0 ),

	// WISHBONE Target 8
	.t8_wb_cyc_o	( ),
	.t8_wb_stb_o	( ),
	.t8_wb_cab_o	( ),
	.t8_wb_adr_o	( ),
	.t8_wb_sel_o	( ),
	.t8_wb_we_o	( ),
	.t8_wb_dat_o	( ),
	.t8_wb_dat_i	( 32'h0000_0000 ),
	.t8_wb_ack_i	( 1'b0 ),
	.t8_wb_err_i	( 1'b1 )
);


`ifdef PHY_ISP1105
  //assign SC_P_CLK = 1'b0;
  //assign SC_RST_N = 1'b0;
  //assign SC_CS_N = 1'b0;
  //assign SC_P0 = 1'b0;
  //assign SC_P1 = 1'b0;
  assign uart_srx = SC_P2;
  //assign SC_P3 = 1'b0;
  assign SC_P4 = uart_stx;
  //assign SC_P5 = 1'b0;
  //assign SC_P6 = 1'b0;
  //assign SC_P7 = 1'b0;
  //assign SC_P8 = 1'b0;
  //assign SC_P9 = 1'b0;
  //assign SC_P10 = 1'b0;
  //assign SC_P11 = 1'b0;
  //assign SC_P12 = 1'b0;
  //assign SC_P13 = 1'b0;
  //assign SC_P14 = 1'b0;
  //assign SC_P15 = 1'b0;
  //assign SC_P16 = 1'b0;
  //assign SC_P17 = 1'b0;
  //assign SC_P18 = 1'b0;
  //assign SC_P19 = 1'b0;
  assign vBusDetect = SC_P20;
  //assign SC_P21 = 1'b0;
  assign SC_P22 = usbSlaveVM;
  assign SC_P23 = usbSlaveVP;
  assign SC_P24 = usbSlaveOE_n;
  assign SC_P25 = usbHostVM;
  assign SC_P26 = usbDPlusPullup;
  assign SC_P27 = usbHostVP;
  assign SC_P28 = usbHostOE_n;
  //assign SC_P29 = 1'b0;
  //assign SC_P30 = 1'b0;
  //assign SC_P31 = 1'b0;
  //assign SC_P32 = 1'b0;
  //assign SC_P33 = 1'b0;
  //assign SC_P34 = 1'b0;
  //assign SC_P35 = 1'b0;
  //assign SC_P36 = 1'b0;
  //assign SC_P37 = 1'b0;
  //assign SC_P38 = 1'b0;
  //assign SC_P39 = 1'b0;
`else
  assign SC_P_CLK = 1'b0;
  assign SC_RST_N = 1'b0;
  assign SC_CS_N = 1'b0;
  assign SC_P0 = usbSlaveFullSpeed;
  assign SC_P1 = 1'b0;
  assign usbSlaveVMin = SC_P2;
  assign SC_P3 = 1'b0;
  assign usbSlaveVPin = SC_P4;
  assign SC_P5 = 1'b0;
  assign SC_P6 = usbSlaveOE_n;
  assign SC_P7 = 1'b0;
  assign SC_P8 = usbSlaveVMout;
  assign SC_P9 = 1'b0;
  assign SC_P10 = usbSlaveVPout;
  assign SC_P11 = 1'b0;
  assign SC_P12 = usbDPlusPullup;
  assign SC_P13 = 1'b0;
  assign SC_P14 = usbDMinusPullup;
  assign SC_P15 = 1'b0;
  assign SC_P16 = 1'b0;
  assign SC_P17 = 1'b0;
  assign SC_P18 = 1'b0;
  assign SC_P19 = 1'b0;
  assign SC_P20 = 1'b0;
  assign SC_P21 = usbHostFullSpeed;
  assign usbHostVMin = SC_P22;
  assign SC_P23 = 1'b0;
  assign usbHostVPin = SC_P24;
  assign SC_P25 = usbHostOE_n;
  assign SC_P26 = 1'b0;
  assign SC_P27 = usbHostVMout;
  assign SC_P28 = usbHostVPout;
  assign SC_P29 = 1'b0;
  assign SC_P30 = 1'b0;
  assign SC_P31 = 1'b0;
  assign SC_P32 = 1'b0;
  assign SC_P33 = 1'b0;
  assign SC_P34 = 1'b0;
  assign SC_P35 = 1'b0;
  assign SC_P36 = 1'b0;
  assign SC_P37 = 1'b0;
  assign SC_P38 = 1'b0;
  assign SC_P39 = 1'b0;
`endif

endmodule
