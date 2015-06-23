//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200 Top Level                                            ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  OR1200 Top Level                                            ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
// $Log: or1200_top.v,v $
// Revision 1.13  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.12  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.10.4.9  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.10.4.8  2004/01/17 21:14:14  simons
// Errors fixed.
//
// Revision 1.10.4.7  2004/01/17 19:06:38  simons
// Error fixed.
//
// Revision 1.10.4.6  2004/01/17 18:39:48  simons
// Error fixed.
//
// Revision 1.10.4.5  2004/01/15 06:46:38  markom
// interface to debug changed; no more opselect; stb-ack protocol
//
// Revision 1.10.4.4  2003/12/09 11:46:49  simons
// Mbist nameing changed, Artisan ram instance signal names fixed, some synthesis waning fixed.
//
// Revision 1.10.4.3  2003/12/05 00:08:44  lampret
// Fixed instantiation name.
//
// Revision 1.10.4.2  2003/07/11 01:10:35  lampret
// Added three missing wire declarations. No functional changes.
//
// Revision 1.10.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.10  2002/12/08 08:57:56  lampret
// Added optional support for WB B3 specification (xwb_cti_o, xwb_bte_o). Made xwb_cab_o optional.
//
// Revision 1.9  2002/10/17 20:04:41  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.8  2002/08/18 19:54:22  lampret
// Added store buffer.
//
// Revision 1.7  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.6  2002/03/29 15:16:56  lampret
// Some of the warnings fixed.
//
// Revision 1.5  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.4  2002/02/01 19:56:55  lampret
// Fixed combinational loops.
//
// Revision 1.3  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.2  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.13  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.12  2001/11/20 00:57:22  lampret
// Fixed width of du_except.
//
// Revision 1.11  2001/11/18 08:36:28  lampret
// For GDB changed single stepping and disabled trap exception.
//
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:35  igorm
// no message
//
// Revision 1.4  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.3  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:21  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_top_cm2_top(
	cmls,
	// System
	clk_i, rst_i, pic_ints_i, clmode_i,

	// Instruction WISHBONE INTERFACE
	//iwb_clk_i, iwb_rst_i, 
	iwb_ack_i, iwb_err_i, iwb_rty_i, iwb_dat_i,
	iwb_cyc_o, iwb_adr_o, iwb_stb_o, iwb_we_o, iwb_sel_o, iwb_dat_o,
`ifdef OR1200_WB_CAB
	iwb_cab_o,
`endif
`ifdef OR1200_WB_B3
	iwb_cti_o, iwb_bte_o,
`endif
	// Data WISHBONE INTERFACE
	//dwb_clk_i, dwb_rst_i, 
	dwb_ack_i, dwb_err_i, dwb_rty_i, dwb_dat_i,
	dwb_cyc_o, dwb_adr_o, dwb_stb_o, dwb_we_o, dwb_sel_o, dwb_dat_o,
`ifdef OR1200_WB_CAB
	dwb_cab_o,
`endif
`ifdef OR1200_WB_B3
	dwb_cti_o, dwb_bte_o,
`endif

	// External Debug Interface
	dbg_stall_i, dbg_ewt_i,	dbg_lss_o, dbg_is_o, dbg_wp_o, dbg_bp_o,
	dbg_stb_i, dbg_we_i, dbg_adr_i, dbg_dat_i, dbg_dat_o, dbg_ack_o,
	
`ifdef OR1200_BIST
	// RAM BIST
	mbist_si_i, mbist_so_o, mbist_ctrl_i,
`endif
	// Power Management
	pm_cpustall_i,
	pm_clksd_o, pm_dc_gate_o, pm_ic_gate_o, pm_dmmu_gate_o, 
	pm_immu_gate_o, pm_tt_gate_o, pm_cpu_gate_o, pm_wakeup_o, pm_lvolt_o

);

input cmls;


parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_OPERAND_WIDTH;
parameter ppic_ints = `OR1200_PIC_INTS;

//
// I/O
//

//
// System
//
input			clk_i;
input			rst_i;
input	[1:0]		clmode_i;	// 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
input	[ppic_ints-1:0]	pic_ints_i;

//
// Instruction WISHBONE interface
//
//input			iwb_clk_i;	// clock input
//input			iwb_rst_i;	// reset input
wire iwb_clk_i = clk_i;
wire iwb_rst_i = rst_i;

input			iwb_ack_i;	// normal termination
input			iwb_err_i;	// termination w/ error
input			iwb_rty_i;	// termination w/ retry
input	[dw-1:0]	iwb_dat_i;	// input data bus
output			iwb_cyc_o;	// cycle valid output
output	[aw-1:0]	iwb_adr_o;	// address bus outputs
output			iwb_stb_o;	// strobe output
output			iwb_we_o;	// indicates write transfer
output	[3:0]		iwb_sel_o;	// byte select outputs
output	[dw-1:0]	iwb_dat_o;	// output data bus
`ifdef OR1200_WB_CAB
output			iwb_cab_o;	// indicates consecutive address burst
`endif
`ifdef OR1200_WB_B3
output	[2:0]		iwb_cti_o;	// cycle type identifier
output	[1:0]		iwb_bte_o;	// burst type extension
`endif

//
// Data WISHBONE interface
//
//input			dwb_clk_i;	// clock input
//input			dwb_rst_i;	// reset input
wire dwb_clk_i = clk_i;
wire dwb_rst_i = rst_i;

input			dwb_ack_i;	// normal termination
input			dwb_err_i;	// termination w/ error
input			dwb_rty_i;	// termination w/ retry
input	[dw-1:0]	dwb_dat_i;	// input data bus
output			dwb_cyc_o;	// cycle valid output
output	[aw-1:0]	dwb_adr_o;	// address bus outputs
output			dwb_stb_o;	// strobe output
output			dwb_we_o;	// indicates write transfer
output	[3:0]		dwb_sel_o;	// byte select outputs
output	[dw-1:0]	dwb_dat_o;	// output data bus
`ifdef OR1200_WB_CAB
output			dwb_cab_o;	// indicates consecutive address burst
`endif
`ifdef OR1200_WB_B3
output	[2:0]		dwb_cti_o;	// cycle type identifier
output	[1:0]		dwb_bte_o;	// burst type extension
`endif

//
// External Debug Interface
//
input			dbg_stall_i;	// External Stall Input
input			dbg_ewt_i;	// External Watchpoint Trigger Input
output	[3:0]		dbg_lss_o;	// External Load/Store Unit Status
output	[1:0]		dbg_is_o;	// External Insn Fetch Status
output	[10:0]		dbg_wp_o;	// Watchpoints Outputs
output			dbg_bp_o;	// Breakpoint Output
input			dbg_stb_i;      // External Address/Data Strobe
input			dbg_we_i;       // External Write Enable
input	[aw-1:0]	dbg_adr_i;	// External Address Input
input	[dw-1:0]	dbg_dat_i;	// External Data Input
output	[dw-1:0]	dbg_dat_o;	// External Data Output
output			dbg_ack_o;	// External Data Acknowledge (not WB compatible)

`ifdef OR1200_BIST
//
// RAM BIST
//
input mbist_si_i;
input [`OR1200_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;
output mbist_so_o;
`endif

//
// Power Management
//
input			pm_cpustall_i;
output	[3:0]		pm_clksd_o;
output			pm_dc_gate_o;
output			pm_ic_gate_o;
output			pm_dmmu_gate_o;
output			pm_immu_gate_o;
output			pm_tt_gate_o;
output			pm_cpu_gate_o;
output			pm_wakeup_o;
output			pm_lvolt_o;

or1200_top_cm2 or1200_top_cm2i(
		.clk_i_cml_1(clk_i),
		.cmls(cmls),
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.pic_ints_i(pic_ints_i), 
		.clmode_i(clmode_i),
		.iwb_ack_i(iwb_ack_i), 
		.iwb_err_i(iwb_err_i), 
		.iwb_rty_i(iwb_rty_i), 
		.iwb_dat_i(iwb_dat_i),
		.iwb_cyc_o(iwb_cyc_o), 
		.iwb_adr_o(iwb_adr_o), 
		.iwb_stb_o(iwb_stb_o), 
		.iwb_we_o(iwb_we_o), 
		.iwb_sel_o(iwb_sel_o), 
		.iwb_dat_o(iwb_dat_o),
`ifdef OR1200_WB_CAB
		.iwb_cab_o(iwb_cab_o),
`endif
`ifdef OR1200_WB_B3
		.iwb_cti_o(iwb_cti_o), 
		.iwb_bte_o(iwb_bte_o),
`endif
		.dwb_ack_i(dwb_ack_i), 
		.dwb_err_i(dwb_err_i), 
		.dwb_rty_i(dwb_rty_i), 
		.dwb_dat_i(dwb_dat_i),
		.dwb_cyc_o(dwb_cyc_o), 
		.dwb_adr_o(dwb_adr_o), 
		.dwb_stb_o(dwb_stb_o), 
		.dwb_we_o(dwb_we_o), 
		.dwb_sel_o(dwb_sel_o), 
		.dwb_dat_o(dwb_dat_o),
`ifdef OR1200_WB_CAB
		.dwb_cab_o(dwb_cab_o),
`endif
`ifdef OR1200_WB_B3
		.dwb_cti_o(dwb_cti_o), 
		.dwb_bte_o(dwb_bte_o),
`endif

		.dbg_stall_i(dbg_stall_i), 
		.dbg_ewt_i(dbg_ewt_i),	
		.dbg_lss_o(dbg_lss_o), 
		.dbg_is_o(dbg_is_o), 
		.dbg_wp_o(dbg_wp_o), 
		.dbg_bp_o(dbg_bp_o),
		.dbg_stb_i(dbg_stb_i), 
		.dbg_we_i(dbg_we_i), 
		.dbg_adr_i(dbg_adr_i), 
		.dbg_dat_i(dbg_dat_i), 
		.dbg_dat_o(dbg_dat_o), 
		.dbg_ack_o(dbg_ack_o),
	
`ifdef OR1200_BIST
	// RAM BIST
		.mbist_si_i(mbist_si_i), 
		.mbist_so_o(mbist_so_o), 
		.mbist_ctrl_i(mbist_ctrl_i),
`endif
	
		.pm_cpustall_i(pm_cpustall_i),
		.pm_clksd_o(pm_clksd_o), 
		.pm_dc_gate_o(pm_dc_gate_o), 
		.pm_ic_gate_o(pm_ic_gate_o), 
		.pm_dmmu_gate_o(pm_dmmu_gate_o), 
		.pm_immu_gate_o(pm_immu_gate_o), 
		.pm_tt_gate_o(pm_tt_gate_o), 
		.pm_cpu_gate_o(pm_cpu_gate_o), 
		.pm_wakeup_o(pm_wakeup_o), 
		.pm_lvolt_o(pm_lvolt_o));



endmodule
