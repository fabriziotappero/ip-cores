//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1K test application for XESS XSV board, Top Level         ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Top level instantiating all the blocks.                     ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
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
//
// CVS Revision History
//
// $Log: xsv_fpga_top.v,v $
// Revision 1.6  2011-02-14 04:16:25  natey
// Major functionality enhancement - now duplicates the full OR1K self-test performed by adv_jtag_bridge.
//
// Revision 1.5  2010-01-16 02:15:22  Nathan
// Updated to match changes in hardware.  Added support for hi-speed mode.
//
// Revision 1.4  2010-01-08 01:41:07  Nathan
// Removed unused, non-existant include from CPU behavioral model.  Minor text edits.
//
// Revision 1.3  2008/07/11 08:22:17  Nathan
// Added code to make the native TAP simulate a Xilinx BSCAN device, and code to simulate the behavior of the xilinx_internal_jtag module.  The adv_dbg_module should get inputs that emulate the xilinx_internal_jtag device outputs.
//
// Revision 1.10  2004/04/05 08:44:35  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.8  2003/04/07 21:05:58  lampret
// WB = 1/2 RISC clock test code enabled.
//
// Revision 1.7  2003/04/07 01:28:17  lampret
// Adding OR1200_CLMODE_1TO2 test code.
//
// Revision 1.6  2002/08/12 05:35:12  lampret
// rty_i are unused - tied to zero.
//
// Revision 1.5  2002/03/29 20:58:51  lampret
// Changed hardcoded address for fake MC to use a define.
//
// Revision 1.4  2002/03/29 16:30:47  lampret
// Fixed port names that changed.
//
// Revision 1.3  2002/03/29 15:50:03  lampret
// Added response from memory controller (addr 0x60000000)
//
// Revision 1.2  2002/03/21 17:39:16  lampret
// Fixed some typos
//
//

`include "xsv_fpga_defines.v"
//`include "bench_defines.v"

module xsv_fpga_top (

	//
	// Global signals
	//
	//clk,
	//rstn,

	// UART signals
	uart_stx, uart_srx
	
	// SDRAM signals
	/*
	sdram_clk_i, sdram_addr_o, sdram_ba_o, sdram_dqm_o,
	sdram_we_o, sdram_cas_o, sdram_ras_o,
	sdram_cke_o, sdram_cs_o, sdram_data_io
	*/
);

//
// I/O Ports
//

//
// Global
//
//input			clk;
//input			rstn;

// UART
input uart_srx;
output uart_stx;

// SDRAM
/*
input sdram_clk_i;
output [11:0] sdram_addr_o;
output [1:0] sdram_ba_o;
output [3:0] sdram_dqm_o;
output sdram_we_o;
output sdram_cas_o;
output sdram_ras_o;
output sdram_cke_o;
output sdram_cs_o;
inout [31:0] sdram_data_io;
*/

//
// Internal wires
//

wire clk;
wire rstn;

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
wire			wb_dm_ack_i;
wire			wb_dm_err_i;

//
// Debug <-> RISC wires
//
wire	[3:0]		dbg_lss;
wire	[1:0]		dbg_is;
wire	[10:0]	dbg_wp;
wire			dbg_bp;
wire	[31:0]	dbg_dat_dbg;
wire	[31:0]	dbg_dat_risc;
wire	[31:0]	dbg_adr;
wire			dbg_ewt;
wire			dbg_stall;
wire			dbg_we;
wire			dbg_stb;
wire			dbg_ack;
wire     dbg_cpu0_rst;

//
// TAP<->dbg_interface
//      
wire debug_rst;
wire debug_select;
wire debug_tdi;
wire debug_tdo;		     
wire shift_dr;
wire pause_dr;
wire update_dr;
wire capture_dr;
wire drck;  // To emulate the BSCAN_VIRTEX/SPARTAN devices

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
//wire	[31:0]		wb_rif_adr;
//reg			prefix_flash;

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

//
// RISC misc
//
//wire	[19:0]		pic_ints;

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

//
// UART external i/f wires
//
wire			uart_stx;
wire			uart_srx;


//
// Memory controller core slave i/f wires
//
/*
wire	[31:0]		wb_mem_dat_i;
wire	[31:0]		wb_mem_dat_o;
wire	[31:0]		wb_mem_adr_i;
wire	[3:0]		wb_mem_sel_i;
wire			wb_mem_we_i;
wire			wb_mem_cyc_i;
wire			wb_mem_stb_i;
wire			wb_mem_ack_o;
wire			wb_mem_err_o;

// Internal mem control wires
wire [7:0] mc_cs;
wire [12:0] mc_addr_o;


// Memory control external wires
wire sdram_clk_i;
wire [11:0] sdram_addr_o;
wire [1:0] sdram_ba_o;
wire [3:0] sdram_dqm_o;
wire sdram_we_o;
wire sdram_cas_o;
wire sdram_ras_o;
wire sdram_cke_o;
wire sdram_cs_o;
wire [31:0] sdram_data_io;
*/

//
// JTAG wires
//
wire			jtag_tdi;
wire			jtag_tms;
wire			jtag_tck;
wire			jtag_trst;
wire			jtag_tdo;


//
// Reset debounce
//
reg      rstn_debounce;
wire     rst_r;
reg      wb_rst;
reg      cpu_rst;

//
// Global clock
//
`ifdef OR1200_CLMODE_1TO2
reg			wb_clk;
`else
wire			wb_clk;
`endif

//
// Reset debounce
//
always @(posedge wb_clk or negedge rstn)
	if (~rstn)
		rstn_debounce <= 1'b0;
	else
		rstn_debounce <= #1 1'b1;

assign rst_r = ~rstn_debounce;
//assign dbg_trst = rstn_debounce & jtag_trst;

//
// Reset debounce
//
always @(posedge wb_clk)
	wb_rst <= #1 rst_r;
	
always @ (posedge wb_clk)
	cpu_rst <= dbg_cpu0_rst | rst_r;

//
// This is purely for testing 1/2 WB clock
// This should never be used when implementing in
// an FPGA. It is used only for simulation regressions.
//
`ifdef OR1200_CLMODE_1TO2
initial wb_clk = 0;
always @(posedge clk)
	wb_clk = ~wb_clk;
`else
//
// Some Xilinx P&R tools need this
//
`ifdef TARGET_VIRTEX
IBUFG IBUFG1 (
	.O	( wb_clk ),
	.I	( clk )
);
`else
assign wb_clk = clk;
`endif
`endif // OR1200_CLMODE_1TO2

//
// Unused WISHBONE signals
//
assign wb_us_err_o = 1'b0;


assign jtag_tvref = 1'b1;
assign jtag_tgnd = 1'b0;

// JTAG / adv. debug control testbench
adv_debug_tb tb (

.jtag_tck_o(jtag_tck),
.jtag_tms_o(jtag_tms),
.jtag_tdo_o(jtag_tdi),
.jtag_tdi_i(jtag_tdo),

.wb_clk_o(clk),
.sys_rstn_o(rstn)
); 

//
// JTAG TAP controller instantiation
//
tap_top tap (
                // JTAG pads
                .tms_pad_i(jtag_tms), 
                .tck_pad_i(jtag_tck), 
                .trstn_pad_i(1'b1), 
                .tdi_pad_i(jtag_tdi), 
                .tdo_pad_o(jtag_tdo), 
                .tdo_padoe_o(),

                // TAP states
				   .test_logic_reset_o(debug_rst),
				   .run_test_idle_o(),
                .shift_dr_o(shift_dr),
                .pause_dr_o(), 
                .update_dr_o(update_dr),
                .capture_dr_o(capture_dr),
                
                // Select signals for boundary scan or mbist
                .extest_select_o(), 
                .sample_preload_select_o(),
                .mbist_select_o(),
                .debug_select_o(debug_select),
                
                // TDO signal that is connected to TDI of sub-modules.
                .tdi_o(debug_tdi), 
                
                // TDI signals from sub-modules
                .debug_tdo_i(debug_tdo),    // from debug module
                .bs_chain_tdo_i(1'b0), // from Boundary Scan Chain
                .mbist_tdo_i(1'b0)     // from Mbist Chain
              );

// This is taken from the xilinx bscan_virtex4.v module
// It simulates the DRCK output of a BSCAN_* block
assign drck = ((debug_select & !shift_dr & !capture_dr) || 
               (debug_select & shift_dr & jtag_tck) || 
               (debug_select & capture_dr & jtag_tck));
               
reg xshift;
reg xcapture;
reg xupdate;
reg xselect;
               
// TAP state outputs are also delayed half a cycle.
always @(negedge jtag_tck)
begin
   xshift = shift_dr; 
   xcapture = capture_dr;
   xupdate = update_dr;
   xselect = debug_select;
end

//////////////////////////////////////////               
               
               
wire tck2;
assign tck2 = (drck & !xupdate);

reg update2;

always @ (posedge xupdate or posedge xcapture or negedge xselect)
begin
   if(xupdate) update2 <= 1'b1;
   else if(xcapture) update2 <= 1'b0;
   else if(!xselect) update2 <= 1'b0;
end

//
// Instantiation of the development i/f
//
adbg_top dbg_top  (

	// JTAG pins
	.tck_i	( tck2 ),
	.tdi_i	( debug_tdi ),
	.tdo_o	( debug_tdo ),
	.rst_i	( debug_rst ),

     // TAP states
     .shift_dr_i( xshift ),
     .pause_dr_i( pause_dr ),
     .update_dr_i( update2 ),
     .capture_dr_i (xcapture),

     // Instructions
     .debug_select_i( xselect ),

	// RISC signals
	.cpu0_clk_i		( wb_clk ),
	.cpu0_addr_o	( dbg_adr ),
	.cpu0_data_i	( dbg_dat_risc ),
	.cpu0_data_o	( dbg_dat_dbg ),
	.cpu0_bp_i 		( dbg_bp ),
	.cpu0_stall_o 	( dbg_stall ),
	.cpu0_stb_o 	( dbg_stb ),
	.cpu0_we_o 		( dbg_we ),
	.cpu0_ack_i 	( dbg_ack ),
	.cpu0_rst_o		( dbg_cpu0_rst),

	// WISHBONE common
	.wb_clk_i	( wb_clk ),

	// WISHBONE master interface
	.wb_adr_o	( wb_dm_adr_o ),	
	.wb_dat_o	( wb_dm_dat_o ),
	.wb_dat_i	( wb_dm_dat_i ),
	.wb_cyc_o	( wb_dm_cyc_o ),
	.wb_stb_o	( wb_dm_stb_o ),
	.wb_sel_o	( wb_dm_sel_o ),
	.wb_we_o	( wb_dm_we_o  ),
	.wb_ack_i	( wb_dm_ack_i ),
	.wb_cab_o	( wb_dm_cab_o ),
	.wb_err_i	( wb_dm_err_i ),
	.wb_cti_o   (),
	.wb_bte_o   ()
);


//
// Instantiation of the OR1200 RISC
//
or1200_top or1200_top (

	// Common
	.rst_i		( cpu_rst ),
	.clk_i		( clk ),
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

	// Debug
	.dbg_stall_i	( dbg_stall ),  // Set to 1'b0 if debug is absent / broken
	.dbg_dat_i	( dbg_dat_dbg ),
	.dbg_adr_i	( dbg_adr ),
	.dbg_ewt_i	( 1'b0 ),
	.dbg_lss_o	( ),
	.dbg_is_o	( ),
	.dbg_wp_o	( ),
	.dbg_bp_o	( dbg_bp ),
	.dbg_dat_o	( dbg_dat_risc ),
	.dbg_ack_o	( dbg_ack ),
	.dbg_stb_i	( dbg_stb ),
	.dbg_we_i	( dbg_we ),

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
	.pic_ints_i	(20'b0)
);


//
// Instantiation of the On-chip RAM controller
//
onchip_ram_top  #(
	.dwidth  (32),
	.size_bytes(16384)
	) onchip_ram_top (

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
	.int_o		( ),

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

/*
mc_wrapper mc_wrapper (
	.clk_i ( wb_clk ),
	.rst_i ( wb_rst ),
	.clk_mem_i ( sdram_clk_i ), 

	.wb_data_i ( wb_mem_dat_i ), 
	.wb_data_o ( wb_mem_dat_o ), 
	.wb_addr_i ( wb_mem_adr_i ),
	.wb_sel_i ( wb_mem_sel_i ),
	.wb_we_i ( wb_mem_we_i ),
	.wb_cyc_i ( wb_mem_cyc_i ),
	.wb_stb_i ( wb_mem_stb_i ),
	.wb_ack_o ( wb_mem_ack_o ),
	.wb_err_o ( wb_mem_err_o ),

	.susp_req_i ( 1'b0 ), 
	.resume_req_i ( 1'b0 ), 
	.suspended_o (),
	.poc_o ( ),  // This is an output so the rest of the system can configure itself

	.sdram_addr_o ( mc_addr_o ),
	.sdram_ba_o ( sdram_ba_o ),
	.sdram_cas_n_o ( sdram_cas_o ), 
	.sdram_ras_n_o ( sdram_ras_o ),
	.sdram_cke_n_o ( sdram_cke_o ),
	
	.mc_dqm_o ( sdram_dqm_o  ),
	.mc_we_n_o ( sdram_we_o ), 
	.mc_oe_n_o ( ),
	.mc_data_io ( sdram_data_io ),
	.mc_parity_io ( ),
	.mc_cs_n_o ( mc_cs )
	);

assign sdram_cs_o = mc_cs[0];
assign sdram_addr_o = mc_addr_o[11:0];
*/

//
// Instantiation of the Traffic COP
//
wb_conbus_top #(.s0_addr_w  (`APP_ADDR_DEC_W),
	 .s0_addr    (`APP_ADDR_SDRAM),
	 .s1_addr_w  (`APP_ADDR_DEC2_W),
	 .s1_addr    (`APP_ADDR_OCRAM),
	 .s27_addr_w (`APP_ADDR_DECP_W),
	 .s2_addr    (`APP_ADDR_VGA),
	 .s3_addr    (`APP_ADDR_ETH),
	 .s4_addr    (`APP_ADDR_AUDIO),
	 .s5_addr    (`APP_ADDR_UART),
	 .s6_addr    (`APP_ADDR_PS2),
	 .s7_addr    (`APP_ADDR_RES1)
	) tc_top (

	// WISHBONE common
	.clk_i	( wb_clk ),
	.rst_i	( wb_rst ),

	// WISHBONE Initiator 0
	.m0_cyc_i	( 1'b0 ),
	.m0_stb_i	( 1'b0 ),
	.m0_cab_i	( 1'b0 ),
	.m0_adr_i	( 32'h0000_0000 ),
	.m0_sel_i	( 4'b0000 ),
	.m0_we_i	( 1'b0 ),
	.m0_dat_i	( 32'h0000_0000 ),
	.m0_dat_o	( ),
	.m0_ack_o	( ),
	.m0_err_o	( ),

	// WISHBONE Initiator 1
	.m1_cyc_i	( 1'b0 ),
	.m1_stb_i	( 1'b0 ),
	.m1_cab_i	( 1'b0 ),
	.m1_adr_i	( 32'h0000_0000 ),
	.m1_sel_i	( 4'b0000 ),
	.m1_we_i	( 1'b0 ),
	.m1_dat_i	( 32'h0000_0000 ),
	.m1_dat_o	( ),
	.m1_ack_o	( ),
	.m1_err_o	( ),

	// WISHBONE Initiator 2
	.m2_cyc_i	( 1'b0 ),
	.m2_stb_i	( 1'b0 ),
	.m2_cab_i	( 1'b0 ),
	.m2_adr_i	( 32'h0000_0000 ),
	.m2_sel_i	( 4'b0000 ),
	.m2_we_i	( 1'b0 ),
	.m2_dat_i	( 32'h0000_0000 ),
	.m2_dat_o	( ),
	.m2_ack_o	( ),
	.m2_err_o	( ),
	
	// WISHBONE Initiator 3
	.m3_cyc_i	( wb_dm_cyc_o ),
	.m3_stb_i	( wb_dm_stb_o ),
	.m3_cab_i	( 1'b0 ),
	.m3_adr_i	( wb_dm_adr_o ),
	.m3_sel_i	( wb_dm_sel_o ),
	.m3_we_i	( wb_dm_we_o  ),
	.m3_dat_i	( wb_dm_dat_o ),
	.m3_dat_o	( wb_dm_dat_i ),
	.m3_ack_o	( wb_dm_ack_i ),
	.m3_err_o	( wb_dm_err_i ),

	// WISHBONE Initiator 4
	.m4_cyc_i	( wb_rdm_cyc_o ),
	.m4_stb_i	( wb_rdm_stb_o ),
	.m4_cab_i	( 1'b0 ),
	.m4_adr_i	( wb_rdm_adr_o ),
	.m4_sel_i	( wb_rdm_sel_o ),
	.m4_we_i	( wb_rdm_we_o  ),
	.m4_dat_i	( wb_rdm_dat_o ),
	.m4_dat_o	( wb_rdm_dat_i ),
	.m4_ack_o	( wb_rdm_ack_i ),
	.m4_err_o	( wb_rdm_err_i ),

	// WISHBONE Initiator 5
	.m5_cyc_i	( wb_rim_cyc_o ),
	.m5_stb_i	( wb_rim_stb_o ),
	.m5_cab_i	( 1'b0 ),
	.m5_adr_i	( wb_rim_adr_o ),
	.m5_sel_i	( wb_rim_sel_o ),
	.m5_we_i	( wb_rim_we_o  ),
	.m5_dat_i	( wb_rim_dat_o ),
	.m5_dat_o	( wb_rim_dat_i ),
	.m5_ack_o	( wb_rim_ack_i ),
	.m5_err_o	( wb_rim_err_i ),

	// WISHBONE Initiator 6
	.m6_cyc_i	( 1'b0 ),
	.m6_stb_i	( 1'b0 ),
	.m6_cab_i	( 1'b0 ),
	.m6_adr_i	( 32'h0000_0000 ),
	.m6_sel_i	( 4'b0000 ),
	.m6_we_i	( 1'b0 ),
	.m6_dat_i	( 32'h0000_0000 ),
	.m6_dat_o	( ),
	.m6_ack_o	( ),
	.m6_err_o	( ),

	// WISHBONE Initiator 7
	.m7_cyc_i	( 1'b0 ),
	.m7_stb_i	( 1'b0 ),
	.m7_cab_i	( 1'b0 ),
	.m7_adr_i	( 32'h0000_0000 ),
	.m7_sel_i	( 4'b0000 ),
	.m7_we_i	( 1'b0 ),
	.m7_dat_i	( 32'h0000_0000 ),
	.m7_dat_o	( ),
	.m7_ack_o	( ),
	.m7_err_o	( ),

	// WISHBONE Target 0
	.s0_cyc_o	( ),
	.s0_stb_o	( ),
	.s0_cab_o	( ),
	.s0_adr_o	( ),
	.s0_sel_o	( ),
	.s0_we_o	( ),
	.s0_dat_o	( ),
	.s0_dat_i	( 32'h0000_0000 ),
	.s0_ack_i	( 1'b0 ),
	.s0_err_i	( 1'b0 ),
	.s0_rty_i ( 1'b0 ),
	/*
	.s0_cyc_o	( wb_mem_cyc_i ),
	.s0_stb_o	( wb_mem_stb_i ),
	.s0_cab_o	( wb_mem_cab_i ),
	.s0_adr_o	( wb_mem_adr_i ),
	.s0_sel_o	( wb_mem_sel_i ),
	.s0_we_o	( wb_mem_we_i ),
	.s0_dat_o	( wb_mem_dat_i ),
	.s0_dat_i	( wb_mem_dat_o ),
	.s0_ack_i	( wb_mem_ack_o ),
	.s0_err_i	( wb_mem_err_o ),
	.s0_rty_i ( 1'b0),
	*/

	// WISHBONE Target 1
	.s1_cyc_o	( wb_ss_cyc_i ),
	.s1_stb_o	( wb_ss_stb_i ),
	.s1_cab_o	( wb_ss_cab_i ),
	.s1_adr_o	( wb_ss_adr_i ),
	.s1_sel_o	( wb_ss_sel_i ),
	.s1_we_o	( wb_ss_we_i  ),
	.s1_dat_o	( wb_ss_dat_i ),
	.s1_dat_i	( wb_ss_dat_o ),
	.s1_ack_i	( wb_ss_ack_o ),
	.s1_err_i	( wb_ss_err_o ),
	.s1_rty_i ( 1'b0 ),
	
	// WISHBONE Target 2
	.s2_cyc_o	( ),
	.s2_stb_o	( ),
	.s2_cab_o	( ),
	.s2_adr_o	( ),
	.s2_sel_o	( ),
	.s2_we_o	( ),
	.s2_dat_o	( ),
	.s2_dat_i	( 32'h0000_0000 ),
	.s2_ack_i	( 1'b0 ),
	.s2_err_i	( 1'b0 ),
	.s2_rty_i ( 1'b0 ),
	
	// WISHBONE Target 3
	.s3_cyc_o	( ),
	.s3_stb_o	( ),
	.s3_cab_o	( ),
	.s3_adr_o	( ),
	.s3_sel_o	( ),
	.s3_we_o	( ),
	.s3_dat_o	( ),
	.s3_dat_i	( 32'h0000_0000 ),
	.s3_ack_i	( 1'b0 ),
	.s3_err_i	( 1'b0 ),
	.s3_rty_i ( 1'b0),
	
	// WISHBONE Target 4
	.s4_cyc_o	( ),
	.s4_stb_o	( ),
	.s4_cab_o	( ),
	.s4_adr_o	( ),
	.s4_sel_o	( ),
	.s4_we_o	( ),
	.s4_dat_o	( ),
	.s4_dat_i	( 32'h0000_0000 ),
	.s4_ack_i	( 1'b0 ),
	.s4_err_i	( 1'b0 ),
	.s4_rty_i ( 1'b0),
	
	// WISHBONE Target 5
	.s5_cyc_o	( wb_us_cyc_i ),
	.s5_stb_o	( wb_us_stb_i ),
	.s5_cab_o	( wb_us_cab_i ),
	.s5_adr_o	( wb_us_adr_i ),
	.s5_sel_o	( wb_us_sel_i ),
	.s5_we_o	( wb_us_we_i  ),
	.s5_dat_o	( wb_us_dat_i ),
	.s5_dat_i	( wb_us_dat_o ),
	.s5_ack_i	( wb_us_ack_o ),
	.s5_err_i	( wb_us_err_o ),
	.s5_rty_i ( 1'b0 ),
	
	// WISHBONE Target 6
	.s6_cyc_o	( ),
	.s6_stb_o	( ),
	.s6_cab_o	( ),
	.s6_adr_o	( ),
	.s6_sel_o	( ),
	.s6_we_o	( ),
	.s6_dat_o	( ),
	.s6_dat_i	( 32'h0000_0000 ),
	.s6_ack_i	( 1'b0 ),
	.s6_err_i	( 1'b0 ),
	.s6_rty_i ( 1'b0),
	
	// WISHBONE Target 7
	.s7_cyc_o	( ),
	.s7_stb_o	( ),
	.s7_cab_o	( ),
	.s7_adr_o	( ),
	.s7_sel_o	( ),
	.s7_we_o	( ),
	.s7_dat_o	( ),
	.s7_dat_i	( 32'h0000_0000 ),
	.s7_ack_i	( 1'b0 ),
	.s7_err_i	( 1'b0 ),
	.s7_rty_i ( 1'b0)
	
);

//initial begin
//  $dumpvars(0);
//  $dumpfile("dump.vcd");
//end

endmodule
