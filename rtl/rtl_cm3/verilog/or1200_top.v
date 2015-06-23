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
// $Log: not supported by cvs2svn $
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

module or1200_top_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
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


input clk_i_cml_1;
input clk_i_cml_2;
input [1:0] cmls;
reg  iwb_cyc_o_cml_2;
reg  iwb_cyc_o_cml_1;
reg [ 32 - 1 : 0 ] iwb_adr_o_cml_2;
reg [ 32 - 1 : 0 ] iwb_adr_o_cml_1;
reg  iwb_stb_o_cml_2;
reg  iwb_stb_o_cml_1;
reg  iwb_we_o_cml_2;
reg  iwb_we_o_cml_1;
reg [ 3 : 0 ] iwb_sel_o_cml_2;
reg [ 3 : 0 ] iwb_sel_o_cml_1;
reg [ 32 - 1 : 0 ] iwb_dat_o_cml_2;
reg [ 32 - 1 : 0 ] iwb_dat_o_cml_1;
reg  iwb_cab_o_cml_2;
reg  iwb_cab_o_cml_1;
reg  dwb_cyc_o_cml_2;
reg  dwb_cyc_o_cml_1;
reg [ 32 - 1 : 0 ] dwb_adr_o_cml_2;
reg [ 32 - 1 : 0 ] dwb_adr_o_cml_1;
reg  dwb_stb_o_cml_2;
reg  dwb_stb_o_cml_1;
reg  dwb_we_o_cml_2;
reg  dwb_we_o_cml_1;
reg [ 3 : 0 ] dwb_sel_o_cml_2;
reg [ 3 : 0 ] dwb_sel_o_cml_1;
reg [ 32 - 1 : 0 ] dwb_dat_o_cml_2;
reg [ 32 - 1 : 0 ] dwb_dat_o_cml_1;
reg  dwb_cab_o_cml_2;
reg  dwb_cab_o_cml_1;
reg [ 1 : 0 ] dbg_is_o_cml_2;
reg [ 1 : 0 ] dbg_is_o_cml_1;
reg  dbg_ack_o_cml_2;
reg  dbg_ack_o_cml_1;
reg  pm_cpu_gate_o_cml_2;
reg [ 31 : 0 ] spr_cs_cml_2;
reg [ 31 : 0 ] spr_cs_cml_1;



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


//
// Internal wires and regs
//

//
// DC to SB
//
wire	[dw-1:0]	dcsb_dat_dc;
wire	[aw-1:0]	dcsb_adr_dc;
wire			dcsb_cyc_dc;
wire			dcsb_stb_dc;
wire			dcsb_we_dc;
wire	[3:0]		dcsb_sel_dc;
wire			dcsb_cab_dc;
wire	[dw-1:0]	dcsb_dat_sb;
wire			dcsb_ack_sb;
wire			dcsb_err_sb;

//
// SB to BIU
//
wire	[dw-1:0]	sbbiu_dat_sb;
wire	[aw-1:0]	sbbiu_adr_sb;
wire			sbbiu_cyc_sb;
wire			sbbiu_stb_sb;
wire			sbbiu_we_sb;
wire	[3:0]		sbbiu_sel_sb;
wire			sbbiu_cab_sb;
wire	[dw-1:0]	sbbiu_dat_biu;
wire			sbbiu_ack_biu;
wire			sbbiu_err_biu;

//
// IC to BIU
//
wire	[dw-1:0]	icbiu_dat_ic;
wire	[aw-1:0]	icbiu_adr_ic;
wire			icbiu_cyc_ic;
wire			icbiu_stb_ic;
wire			icbiu_we_ic;
wire	[3:0]		icbiu_sel_ic;
wire	[3:0]		icbiu_tag_ic;
wire			icbiu_cab_ic;
wire	[dw-1:0]	icbiu_dat_biu;
wire			icbiu_ack_biu;
wire			icbiu_err_biu;
wire	[3:0]		icbiu_tag_biu;

//
// CPU's SPR access to various RISC units (shared wires)
//
wire			supv;
wire	[aw-1:0]	spr_addr;
wire	[dw-1:0]	spr_dat_cpu;
wire	[31:0]		spr_cs;
wire			spr_we;

//
// DMMU and CPU
//
wire			dmmu_en;
wire	[31:0]		spr_dat_dmmu;

//
// DMMU and QMEM
//
wire			qmemdmmu_err_qmem;
wire	[3:0]		qmemdmmu_tag_qmem;
wire	[aw-1:0]	qmemdmmu_adr_dmmu;
wire			qmemdmmu_cycstb_dmmu;
wire			qmemdmmu_ci_dmmu;

//
// CPU and data memory subsystem
//
wire			dc_en;
wire	[31:0]		dcpu_adr_cpu;
wire			dcpu_cycstb_cpu;
wire			dcpu_we_cpu;
wire	[3:0]		dcpu_sel_cpu;
wire	[3:0]		dcpu_tag_cpu;
wire	[31:0]		dcpu_dat_cpu;
wire	[31:0]		dcpu_dat_qmem;
wire			dcpu_ack_qmem;
wire			dcpu_rty_qmem;
wire			dcpu_err_dmmu;
wire	[3:0]		dcpu_tag_dmmu;

//
// IMMU and CPU
//
wire			immu_en;
wire	[31:0]		spr_dat_immu;

//
// CPU and insn memory subsystem
//
wire			ic_en;
wire	[31:0]		icpu_adr_cpu;
wire			icpu_cycstb_cpu;
wire	[3:0]		icpu_sel_cpu;
wire	[3:0]		icpu_tag_cpu;
wire	[31:0]		icpu_dat_qmem;
wire			icpu_ack_qmem;
wire	[31:0]		icpu_adr_immu;
wire			icpu_err_immu;
wire	[3:0]		icpu_tag_immu;
wire			icpu_rty_immu;

//
// IMMU and QMEM
//
wire	[aw-1:0]	qmemimmu_adr_immu;
wire			qmemimmu_rty_qmem;
wire			qmemimmu_err_qmem;
wire	[3:0]		qmemimmu_tag_qmem;
wire			qmemimmu_cycstb_immu;
wire			qmemimmu_ci_immu;

//
// QMEM and IC
//
wire	[aw-1:0]	icqmem_adr_qmem;
wire			icqmem_rty_ic;
wire			icqmem_err_ic;
wire	[3:0]		icqmem_tag_ic;
wire			icqmem_cycstb_qmem;
wire			icqmem_ci_qmem;
wire	[31:0]		icqmem_dat_ic;
wire			icqmem_ack_ic;

//
// QMEM and DC
//
wire	[aw-1:0]	dcqmem_adr_qmem;
wire			dcqmem_rty_dc;
wire			dcqmem_err_dc;
wire	[3:0]		dcqmem_tag_dc;
wire			dcqmem_cycstb_qmem;
wire			dcqmem_ci_qmem;
wire	[31:0]		dcqmem_dat_dc;
wire	[31:0]		dcqmem_dat_qmem;
wire			dcqmem_we_qmem;
wire	[3:0]		dcqmem_sel_qmem;
wire			dcqmem_ack_dc;

//
// Connection between CPU and PIC
//
wire	[dw-1:0]	spr_dat_pic;
wire			pic_wakeup;
wire			sig_int;

//
// Connection between CPU and PM
//
wire	[dw-1:0]	spr_dat_pm;

//
// CPU and TT
//
wire	[dw-1:0]	spr_dat_tt;
wire			sig_tick;

//
// Debug port and caches/MMUs
//
wire	[dw-1:0]	spr_dat_du;
wire			du_stall;
wire	[dw-1:0]	du_addr;
wire	[dw-1:0]	du_dat_du;
wire			du_read;
wire			du_write;
wire	[12:0]		du_except;
wire	[`OR1200_DU_DSR_WIDTH-1:0]     du_dsr;
wire	[dw-1:0]	du_dat_cpu;
wire			du_hwbkpt;

wire			ex_freeze;
wire	[31:0]		ex_insn;
wire	[31:0]		id_pc;
wire	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
wire	[31:0]		spr_dat_npc;
wire	[31:0]		rf_dataw;

`ifdef OR1200_BIST
//
// RAM BIST
//
wire			mbist_immu_so;
wire			mbist_ic_so;
wire			mbist_dmmu_so;
wire			mbist_dc_so;
wire      mbist_qmem_so;
wire			mbist_immu_si = mbist_si_i;
wire			mbist_ic_si = mbist_immu_so;
wire			mbist_qmem_si = mbist_ic_so;
wire			mbist_dmmu_si = mbist_qmem_so;
wire			mbist_dc_si = mbist_dmmu_so;
assign			mbist_so_o = mbist_dc_so;
`endif

wire  [3:0] icqmem_sel_qmem;
wire  [3:0] icqmem_tag_qmem;
wire  [3:0] dcqmem_tag_qmem;

//
// Instantiation of Instruction WISHBONE BIU
//
or1200_iwb_biu_cm3 iwb_biu(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC clk, rst and clock control
	.clk(clk_i),
	.rst(rst_i),
	.clmode(clmode_i),

	// WISHBONE interface
	.wb_clk_i(iwb_clk_i),
	.wb_rst_i(iwb_rst_i),
	.wb_ack_i(iwb_ack_i),
	.wb_err_i(iwb_err_i),
	.wb_rty_i(iwb_rty_i),
	.wb_dat_i(iwb_dat_i),
	.wb_cyc_o(iwb_cyc_o),
	.wb_adr_o(iwb_adr_o),
	.wb_stb_o(iwb_stb_o),
	.wb_we_o(iwb_we_o),
	.wb_sel_o(iwb_sel_o),
	.wb_dat_o(iwb_dat_o),
`ifdef OR1200_WB_CAB
	.wb_cab_o(iwb_cab_o),
`endif
`ifdef OR1200_WB_B3
	.wb_cti_o(iwb_cti_o),
	.wb_bte_o(iwb_bte_o),
`endif

	// Internal RISC bus
	.biu_dat_i(icbiu_dat_ic),
	.biu_adr_i(icbiu_adr_ic),
	.biu_cyc_i(icbiu_cyc_ic),
	.biu_stb_i(icbiu_stb_ic),
	.biu_we_i(icbiu_we_ic),
	.biu_sel_i(icbiu_sel_ic),
	.biu_cab_i(icbiu_cab_ic),
	.biu_dat_o(icbiu_dat_biu),
	.biu_ack_o(icbiu_ack_biu),
	.biu_err_o(icbiu_err_biu)
);

//
// Instantiation of Data WISHBONE BIU
//
or1200_wb_biu_cm3 dwb_biu(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC clk, rst and clock control
	.clk(clk_i),
	.rst(rst_i),
	.clmode(clmode_i),

	// WISHBONE interface
	.wb_clk_i(dwb_clk_i),
	.wb_rst_i(dwb_rst_i),
	.wb_ack_i(dwb_ack_i),
	.wb_err_i(dwb_err_i),
	.wb_rty_i(dwb_rty_i),
	.wb_dat_i(dwb_dat_i),
	.wb_cyc_o(dwb_cyc_o),
	.wb_adr_o(dwb_adr_o),
	.wb_stb_o(dwb_stb_o),
	.wb_we_o(dwb_we_o),
	.wb_sel_o(dwb_sel_o),
	.wb_dat_o(dwb_dat_o),
`ifdef OR1200_WB_CAB
	.wb_cab_o(dwb_cab_o),
`endif
`ifdef OR1200_WB_B3
	.wb_cti_o(dwb_cti_o),
	.wb_bte_o(dwb_bte_o),
`endif

	// Internal RISC bus
	.biu_dat_i(sbbiu_dat_sb),
	.biu_adr_i(sbbiu_adr_sb),
	.biu_cyc_i(sbbiu_cyc_sb),
	.biu_stb_i(sbbiu_stb_sb),
	.biu_we_i(sbbiu_we_sb),
	.biu_sel_i(sbbiu_sel_sb),
	.biu_cab_i(sbbiu_cab_sb),
	.biu_dat_o(sbbiu_dat_biu),
	.biu_ack_o(sbbiu_ack_biu),
	.biu_err_o(sbbiu_err_biu)
);

//
// Instantiation of IMMU
//
wire spr_cs_group_immu;
assign spr_cs_group_immu = spr_cs[`OR1200_SPR_GROUP_IMMU];
or1200_immu_top_cm3 or1200_immu_top(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	// Rst and clk
	.clk(clk_i),
	.rst(rst_i),

`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_immu_si),
	.mbist_so_o(mbist_immu_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif

	// CPU and IMMU
	.ic_en(ic_en),
	.immu_en(immu_en),
	.supv(supv),
	.icpu_adr_i(icpu_adr_cpu),
	.icpu_cycstb_i(icpu_cycstb_cpu),
	.icpu_adr_o(icpu_adr_immu),
	.icpu_tag_o(icpu_tag_immu),
	.icpu_rty_o(icpu_rty_immu),
	.icpu_err_o(icpu_err_immu),

	// SPR access
	.spr_cs(spr_cs_group_immu),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_immu),

	// QMEM and IMMU
	.qmemimmu_rty_i(qmemimmu_rty_qmem),
	.qmemimmu_err_i(qmemimmu_err_qmem),
	.qmemimmu_tag_i(qmemimmu_tag_qmem),
	.qmemimmu_adr_o(qmemimmu_adr_immu),
	.qmemimmu_cycstb_o(qmemimmu_cycstb_immu),
	.qmemimmu_ci_o(qmemimmu_ci_immu)
);

//
// Instantiation of Instruction Cache
//
wire spr_cs_group_ic;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_ic
// replace(s): spr_cs
assign spr_cs_group_ic = spr_cs_cml_2[`OR1200_SPR_GROUP_IC];
or1200_ic_top_cm3 or1200_ic_top(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	.clk(clk_i),
	.rst(rst_i),

`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_ic_si),
	.mbist_so_o(mbist_ic_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif

	// IC and QMEM
	.ic_en(ic_en),
	.icqmem_adr_i(icqmem_adr_qmem),
	.icqmem_cycstb_i(icqmem_cycstb_qmem),
	.icqmem_ci_i(icqmem_ci_qmem),
	.icqmem_sel_i(icqmem_sel_qmem),
	.icqmem_tag_i(icqmem_tag_qmem),
	.icqmem_dat_o(icqmem_dat_ic),
	.icqmem_ack_o(icqmem_ack_ic),
	.icqmem_rty_o(icqmem_rty_ic),
	.icqmem_err_o(icqmem_err_ic),
	.icqmem_tag_o(icqmem_tag_ic),

	// SPR access
	.spr_cs(spr_cs_group_ic),
	.spr_write(spr_we),
	.spr_dat_i(spr_dat_cpu),

	// IC and BIU
	.icbiu_dat_o(icbiu_dat_ic),
	.icbiu_adr_o(icbiu_adr_ic),
	.icbiu_cyc_o(icbiu_cyc_ic),
	.icbiu_stb_o(icbiu_stb_ic),
	.icbiu_we_o(icbiu_we_ic),
	.icbiu_sel_o(icbiu_sel_ic),
	.icbiu_cab_o(icbiu_cab_ic),
	.icbiu_dat_i(icbiu_dat_biu),
	.icbiu_ack_i(icbiu_ack_biu),
	.icbiu_err_i(icbiu_err_biu)
);

//
// Instantiation of Instruction Cache
//
or1200_cpu_cm3 or1200_cpu(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	.clk(clk_i),
	.rst(rst_i),

	// Connection QMEM and IFETCHER inside CPU
	.ic_en(ic_en),
	.icpu_adr_o(icpu_adr_cpu),
	.icpu_cycstb_o(icpu_cycstb_cpu),
	.icpu_sel_o(icpu_sel_cpu),
	.icpu_tag_o(icpu_tag_cpu),
	.icpu_dat_i(icpu_dat_qmem),
	.icpu_ack_i(icpu_ack_qmem),
	.icpu_rty_i(icpu_rty_immu),
	.icpu_adr_i(icpu_adr_immu),
	.icpu_err_i(icpu_err_immu),
	.icpu_tag_i(icpu_tag_immu),

	// Connection CPU to external Debug port
	.ex_freeze(ex_freeze),
	.ex_insn(ex_insn),
	.id_pc(id_pc),
	.branch_op(branch_op),
	.du_stall(du_stall),
	.du_addr(du_addr),
	.du_dat_du(du_dat_du),
	.du_read(du_read),
	.du_write(du_write),
	.du_dsr(du_dsr),
	.du_except(du_except),
	.du_dat_cpu(du_dat_cpu),
	.du_hwbkpt(du_hwbkpt),
	.rf_dataw(rf_dataw),


	// Connection IMMU and CPU internally
	.immu_en(immu_en),

	// Connection QMEM and CPU
	.dc_en(dc_en),
	.dcpu_adr_o(dcpu_adr_cpu),
	.dcpu_cycstb_o(dcpu_cycstb_cpu),
	.dcpu_we_o(dcpu_we_cpu),
	.dcpu_sel_o(dcpu_sel_cpu),
	.dcpu_tag_o(dcpu_tag_cpu),
	.dcpu_dat_o(dcpu_dat_cpu),
        .dcpu_dat_i(dcpu_dat_qmem),
	.dcpu_ack_i(dcpu_ack_qmem),
	.dcpu_rty_i(dcpu_rty_qmem),
	.dcpu_err_i(dcpu_err_dmmu),
	.dcpu_tag_i(dcpu_tag_dmmu),

	// Connection DMMU and CPU internally
	.dmmu_en(dmmu_en),

	// Connection PIC and CPU's EXCEPT
	.sig_int(sig_int),
	.sig_tick(sig_tick),

	// SPRs
	.supv(supv),
	.spr_addr(spr_addr),
	.spr_dat_cpu(spr_dat_cpu),
	.spr_dat_pic(spr_dat_pic),
	.spr_dat_tt(spr_dat_tt),
	.spr_dat_pm(spr_dat_pm),
	.spr_dat_dmmu(spr_dat_dmmu),
	.spr_dat_immu(spr_dat_immu),
	.spr_dat_du(spr_dat_du),
	.spr_dat_npc(spr_dat_npc),
	.spr_cs(spr_cs),
	.spr_we(spr_we)
);

//
// Instantiation of DMMU
//
wire spr_cs_group_dmmu;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_dmmu
// replace(s): spr_cs
assign spr_cs_group_dmmu = spr_cs_cml_1[`OR1200_SPR_GROUP_DMMU];
or1200_dmmu_top_cm3 or1200_dmmu_top(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	// Rst and clk
	.clk(clk_i),
	.rst(rst_i),

`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_dmmu_si),
	.mbist_so_o(mbist_dmmu_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif

	// CPU i/f
	.dc_en(dc_en),
	.dmmu_en(dmmu_en),
	.supv(supv),
	.dcpu_adr_i(dcpu_adr_cpu),
	.dcpu_cycstb_i(dcpu_cycstb_cpu),
	.dcpu_we_i(dcpu_we_cpu),
	.dcpu_tag_o(dcpu_tag_dmmu),
	.dcpu_err_o(dcpu_err_dmmu),

	// SPR access
	.spr_cs(spr_cs_group_dmmu),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_dmmu),

	// QMEM and DMMU
	.qmemdmmu_err_i(qmemdmmu_err_qmem),
	.qmemdmmu_tag_i(qmemdmmu_tag_qmem),
	.qmemdmmu_adr_o(qmemdmmu_adr_dmmu),
	.qmemdmmu_cycstb_o(qmemdmmu_cycstb_dmmu),
	.qmemdmmu_ci_o(qmemdmmu_ci_dmmu)
);

//
// Instantiation of Data Cache
//
wire spr_cs_group_dc;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_dc
// replace(s): spr_cs
assign spr_cs_group_dc = spr_cs_cml_1[`OR1200_SPR_GROUP_DC];
or1200_dc_top_cm3 or1200_dc_top(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	.clk(clk_i),
	.rst(rst_i),

`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_dc_si),
	.mbist_so_o(mbist_dc_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif

	// DC and QMEM
	.dc_en(dc_en),
	.dcqmem_adr_i(dcqmem_adr_qmem),
	.dcqmem_cycstb_i(dcqmem_cycstb_qmem),
	.dcqmem_ci_i(dcqmem_ci_qmem),
	.dcqmem_we_i(dcqmem_we_qmem),
	.dcqmem_sel_i(dcqmem_sel_qmem),
	.dcqmem_tag_i(dcqmem_tag_qmem),
	.dcqmem_dat_i(dcqmem_dat_qmem),
	.dcqmem_dat_o(dcqmem_dat_dc),
	.dcqmem_ack_o(dcqmem_ack_dc),
	.dcqmem_rty_o(dcqmem_rty_dc),
	.dcqmem_err_o(dcqmem_err_dc),
	.dcqmem_tag_o(dcqmem_tag_dc),

	// SPR access
	.spr_cs(spr_cs_group_dc),
	.spr_write(spr_we),
	.spr_dat_i(spr_dat_cpu),

	// DC and BIU
	.dcsb_dat_o(dcsb_dat_dc),
	.dcsb_adr_o(dcsb_adr_dc),
	.dcsb_cyc_o(dcsb_cyc_dc),
	.dcsb_stb_o(dcsb_stb_dc),
	.dcsb_we_o(dcsb_we_dc),
	.dcsb_sel_o(dcsb_sel_dc),
	.dcsb_cab_o(dcsb_cab_dc),
	.dcsb_dat_i(dcsb_dat_sb),
	.dcsb_ack_i(dcsb_ack_sb),
	.dcsb_err_i(dcsb_err_sb)
);

//
// Instantiation of embedded memory - qmem
//
or1200_qmem_top_cm3 or1200_qmem_top(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	.clk(clk_i),
	.rst(rst_i),

`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_qmem_si),
	.mbist_so_o(mbist_qmem_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif

	// QMEM and CPU/IMMU
	.qmemimmu_adr_i(qmemimmu_adr_immu),
	.qmemimmu_cycstb_i(qmemimmu_cycstb_immu),
	.qmemimmu_ci_i(qmemimmu_ci_immu),
	.qmemicpu_sel_i(icpu_sel_cpu),
	.qmemicpu_tag_i(icpu_tag_cpu),
	.qmemicpu_dat_o(icpu_dat_qmem),
	.qmemicpu_ack_o(icpu_ack_qmem),
	.qmemimmu_rty_o(qmemimmu_rty_qmem),
	.qmemimmu_err_o(qmemimmu_err_qmem),
	.qmemimmu_tag_o(qmemimmu_tag_qmem),

	// QMEM and IC
	.icqmem_adr_o(icqmem_adr_qmem),
	.icqmem_cycstb_o(icqmem_cycstb_qmem),
	.icqmem_ci_o(icqmem_ci_qmem),
	.icqmem_sel_o(icqmem_sel_qmem),
	.icqmem_tag_o(icqmem_tag_qmem),
	.icqmem_dat_i(icqmem_dat_ic),
	.icqmem_ack_i(icqmem_ack_ic),
	.icqmem_rty_i(icqmem_rty_ic),
	.icqmem_err_i(icqmem_err_ic),
	.icqmem_tag_i(icqmem_tag_ic),

	// QMEM and CPU/DMMU
	.qmemdmmu_adr_i(qmemdmmu_adr_dmmu),
	.qmemdmmu_cycstb_i(qmemdmmu_cycstb_dmmu),
	.qmemdmmu_ci_i(qmemdmmu_ci_dmmu),
	.qmemdcpu_we_i(dcpu_we_cpu),
	.qmemdcpu_sel_i(dcpu_sel_cpu),
	.qmemdcpu_tag_i(dcpu_tag_cpu),
	.qmemdcpu_dat_i(dcpu_dat_cpu),
	.qmemdcpu_dat_o(dcpu_dat_qmem),
	.qmemdcpu_ack_o(dcpu_ack_qmem),
	.qmemdcpu_rty_o(dcpu_rty_qmem),
	.qmemdmmu_err_o(qmemdmmu_err_qmem),
	.qmemdmmu_tag_o(qmemdmmu_tag_qmem),

	// QMEM and DC
	.dcqmem_adr_o(dcqmem_adr_qmem),
	.dcqmem_cycstb_o(dcqmem_cycstb_qmem),
	.dcqmem_ci_o(dcqmem_ci_qmem),
	.dcqmem_we_o(dcqmem_we_qmem),
	.dcqmem_sel_o(dcqmem_sel_qmem),
	.dcqmem_tag_o(dcqmem_tag_qmem),
	.dcqmem_dat_o(dcqmem_dat_qmem),
	.dcqmem_dat_i(dcqmem_dat_dc),
	.dcqmem_ack_i(dcqmem_ack_dc),
	.dcqmem_rty_i(dcqmem_rty_dc),
	.dcqmem_err_i(dcqmem_err_dc),
	.dcqmem_tag_i(dcqmem_tag_dc)
);

//
// Instantiation of Store Buffer
//
or1200_sb_cm3 or1200_sb(
	// RISC clock, reset
	.clk(clk_i),
	.rst(rst_i),

	// Internal RISC bus (DC<->SB)
	.dcsb_dat_i(dcsb_dat_dc),
	.dcsb_adr_i(dcsb_adr_dc),
	.dcsb_cyc_i(dcsb_cyc_dc),
	.dcsb_stb_i(dcsb_stb_dc),
	.dcsb_we_i(dcsb_we_dc),
	.dcsb_sel_i(dcsb_sel_dc),
	.dcsb_cab_i(dcsb_cab_dc),
	.dcsb_dat_o(dcsb_dat_sb),
	.dcsb_ack_o(dcsb_ack_sb),
	.dcsb_err_o(dcsb_err_sb),

	// SB and BIU
	.sbbiu_dat_o(sbbiu_dat_sb),
	.sbbiu_adr_o(sbbiu_adr_sb),
	.sbbiu_cyc_o(sbbiu_cyc_sb),
	.sbbiu_stb_o(sbbiu_stb_sb),
	.sbbiu_we_o(sbbiu_we_sb),
	.sbbiu_sel_o(sbbiu_sel_sb),
	.sbbiu_cab_o(sbbiu_cab_sb),
	.sbbiu_dat_i(sbbiu_dat_biu),
	.sbbiu_ack_i(sbbiu_ack_biu),
	.sbbiu_err_i(sbbiu_err_biu)
);

//
// Instantiation of Debug Unit
//
wire spr_cs_group_du;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_du
// replace(s): spr_cs
assign spr_cs_group_du = spr_cs_cml_2[`OR1200_SPR_GROUP_DU];
or1200_du_cm3 or1200_du(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC Internal Interface
	.clk(clk_i),
	.rst(rst_i),
	.dcpu_cycstb_i(dcpu_cycstb_cpu),
	.dcpu_we_i(dcpu_we_cpu),
	.dcpu_adr_i(dcpu_adr_cpu),
	.dcpu_dat_lsu(dcpu_dat_cpu),
	.dcpu_dat_dc(dcpu_dat_qmem),
	.icpu_cycstb_i(icpu_cycstb_cpu),
	.ex_freeze(ex_freeze),
	.branch_op(branch_op),
	.ex_insn(ex_insn),
	.id_pc(id_pc),
	.du_dsr(du_dsr),

	// For Trace buffer
	.spr_dat_npc(spr_dat_npc),
	.rf_dataw(rf_dataw),

	// DU's access to SPR unit
	.du_stall(du_stall),
	.du_addr(du_addr),
	.du_dat_i(du_dat_cpu),
	.du_dat_o(du_dat_du),
	.du_read(du_read),
	.du_write(du_write),
	.du_except(du_except),
	.du_hwbkpt(du_hwbkpt),

	// Access to DU's SPRs
	.spr_cs(spr_cs_group_du),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_du),

	// External Debug Interface
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
	.dbg_ack_o(dbg_ack_o)
);

//
// Programmable interrupt controller
//
wire spr_cs_group_pic;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_pic
// replace(s): spr_cs
assign spr_cs_group_pic = spr_cs_cml_2[`OR1200_SPR_GROUP_PIC];
or1200_pic_cm3 or1200_pic(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC Internal Interface
	.clk(clk_i),
	.rst(rst_i),
	.spr_cs(spr_cs_group_pic),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_pic),
	.pic_wakeup(pic_wakeup),
	.intr(sig_int), 

	// PIC Interface
	.pic_int(pic_ints_i)
);

//
// Instantiation of Tick timer
//
wire spr_cs_group_tt;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_tt
// replace(s): spr_cs
assign spr_cs_group_tt = spr_cs_cml_2[`OR1200_SPR_GROUP_TT];
or1200_tt_cm3 or1200_tt(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC Internal Interface
	.clk(clk_i),
	.rst(rst_i),
	.du_stall(du_stall),
	.spr_cs(spr_cs_group_tt),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_tt),
	.intr(sig_tick)
);

//
// Instantiation of Power Management
//
or1200_pm_cm3 or1200_pm(
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
	// RISC Internal Interface
	.clk(clk_i),
	.rst(rst_i),
	.pic_wakeup(pic_wakeup),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_pm),

	// Power Management Interface
	.pm_cpustall(pm_cpustall_i),
	.pm_clksd(pm_clksd_o),
	.pm_dc_gate(pm_dc_gate_o),
	.pm_ic_gate(pm_ic_gate_o),
	.pm_dmmu_gate(pm_dmmu_gate_o),
	.pm_immu_gate(pm_immu_gate_o),
	.pm_tt_gate(pm_tt_gate_o),
	.pm_cpu_gate(pm_cpu_gate_o),
	.pm_wakeup(pm_wakeup_o),
	.pm_lvolt(pm_lvolt_o)
);



always @ (posedge clk_i_cml_1) begin
iwb_cyc_o_cml_1 <= iwb_cyc_o;
iwb_adr_o_cml_1 <= iwb_adr_o;
iwb_stb_o_cml_1 <= iwb_stb_o;
iwb_we_o_cml_1 <= iwb_we_o;
iwb_sel_o_cml_1 <= iwb_sel_o;
iwb_dat_o_cml_1 <= iwb_dat_o;
iwb_cab_o_cml_1 <= iwb_cab_o;
dwb_cyc_o_cml_1 <= dwb_cyc_o;
dwb_adr_o_cml_1 <= dwb_adr_o;
dwb_stb_o_cml_1 <= dwb_stb_o;
dwb_we_o_cml_1 <= dwb_we_o;
dwb_sel_o_cml_1 <= dwb_sel_o;
dwb_dat_o_cml_1 <= dwb_dat_o;
dwb_cab_o_cml_1 <= dwb_cab_o;
dbg_is_o_cml_1 <= dbg_is_o;
dbg_ack_o_cml_1 <= dbg_ack_o;
spr_cs_cml_1 <= spr_cs;
end
always @ (posedge clk_i_cml_2) begin
iwb_cyc_o_cml_2 <= iwb_cyc_o_cml_1;
iwb_adr_o_cml_2 <= iwb_adr_o_cml_1;
iwb_stb_o_cml_2 <= iwb_stb_o_cml_1;
iwb_we_o_cml_2 <= iwb_we_o_cml_1;
iwb_sel_o_cml_2 <= iwb_sel_o_cml_1;
iwb_dat_o_cml_2 <= iwb_dat_o_cml_1;
iwb_cab_o_cml_2 <= iwb_cab_o_cml_1;
dwb_cyc_o_cml_2 <= dwb_cyc_o_cml_1;
dwb_adr_o_cml_2 <= dwb_adr_o_cml_1;
dwb_stb_o_cml_2 <= dwb_stb_o_cml_1;
dwb_we_o_cml_2 <= dwb_we_o_cml_1;
dwb_sel_o_cml_2 <= dwb_sel_o_cml_1;
dwb_dat_o_cml_2 <= dwb_dat_o_cml_1;
dwb_cab_o_cml_2 <= dwb_cab_o_cml_1;
dbg_is_o_cml_2 <= dbg_is_o_cml_1;
dbg_ack_o_cml_2 <= dbg_ack_o_cml_1;
pm_cpu_gate_o_cml_2 <= pm_cpu_gate_o;
spr_cs_cml_2 <= spr_cs_cml_1;
end
endmodule

