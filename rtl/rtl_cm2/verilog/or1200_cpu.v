//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's CPU                                                ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Instantiation of internal CPU blocks. IFETCH, SPRS, FRZ,    ////
////  ALU, EXCEPT, ID, WBMUX, OPERANDMUX, RF etc.                 ////
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
// Revision 1.15  2004/05/09 19:49:04  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.14  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.12.4.2  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.12.4.1  2003/12/09 11:46:48  simons
// Mbist nameing changed, Artisan ram instance signal names fixed, some synthesis waning fixed.
//
// Revision 1.12  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.11  2002/08/28 01:44:25  lampret
// Removed some commented RTL. Fixed SR/ESR flag bug.
//
// Revision 1.10  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.9  2002/03/29 16:29:37  lampret
// Fixed some ports in instnatiations that were removed from the modules
//
// Revision 1.8  2002/03/29 15:16:54  lampret
// Some of the warnings fixed.
//
// Revision 1.7  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.6  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.5  2002/01/28 01:15:59  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.4  2002/01/18 14:21:43  lampret
// Fixed 'the NPC single-step fix'.
//
// Revision 1.3  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.19  2001/11/30 18:59:47  simons
// *** empty log message ***
//
// Revision 1.18  2001/11/23 21:42:31  simons
// Program counter divided to PPC and NPC.
//
// Revision 1.17  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.16  2001/11/20 00:57:22  lampret
// Fixed width of du_except.
//
// Revision 1.15  2001/11/18 09:58:28  lampret
// Fixed some l.trap typos.
//
// Revision 1.14  2001/11/18 08:36:28  lampret
// For GDB changed single stepping and disabled trap exception.
//
// Revision 1.13  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.12  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.11  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:35  igorm
// no message
//
// Revision 1.4  2001/08/17 08:01:19  lampret
// IC enable/disable.
//
// Revision 1.3  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.2  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_cpu_cm2(
		clk_i_cml_1,
		cmls,
		
	// Clk & Rst
	clk, rst,

	// Insn interface
	ic_en,
	icpu_adr_o, icpu_cycstb_o, icpu_sel_o, icpu_tag_o,
	icpu_dat_i, icpu_ack_i, icpu_rty_i, icpu_err_i, icpu_adr_i, icpu_tag_i,
	immu_en,

	// Debug unit
	ex_insn, ex_freeze, id_pc, branch_op,
	spr_dat_npc, rf_dataw,
	du_stall, du_addr, du_dat_du, du_read, du_write, du_dsr, du_hwbkpt,
	du_except, du_dat_cpu,
	
	// Data interface
	dc_en,
	dcpu_adr_o, dcpu_cycstb_o, dcpu_we_o, dcpu_sel_o, dcpu_tag_o, dcpu_dat_o,
	dcpu_dat_i, dcpu_ack_i, dcpu_rty_i, dcpu_err_i, dcpu_tag_i,
	dmmu_en,

	// Interrupt & tick exceptions
	sig_int, sig_tick,

	// SPR interface
	supv, spr_addr, spr_dat_cpu, spr_dat_pic, spr_dat_tt, spr_dat_pm,
	spr_dat_dmmu, spr_dat_immu, spr_dat_du, spr_cs, spr_we
);


input clk_i_cml_1;
input cmls;
reg [ 31 : 0 ] spr_cs_cml_1;
reg [ 31 : 2 ] lr_sav_cml_1;
reg [ 3 - 1 : 0 ] rfwb_op_cml_1;
reg [ 16 - 1 : 0 ] sr_cml_1;



parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_REGFILE_ADDR_WIDTH;

//
// I/O ports
//

//
// Clk & Rst
//
input 				clk;
input 				rst;

//
// Insn (IC) interface
//
output				ic_en;
output	[31:0]			icpu_adr_o;
output				icpu_cycstb_o;
output	[3:0]			icpu_sel_o;
output	[3:0]			icpu_tag_o;
input	[31:0]			icpu_dat_i;
input				icpu_ack_i;
input				icpu_rty_i;
input				icpu_err_i;
input	[31:0]			icpu_adr_i;
input	[3:0]			icpu_tag_i;

//
// Insn (IMMU) interface
//
output				immu_en;

//
// Debug interface
//
output	[31:0]			ex_insn;
output				ex_freeze;
output	[31:0]			id_pc;
output	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;

input				du_stall;
input	[dw-1:0]		du_addr;
input	[dw-1:0]		du_dat_du;
input				du_read;
input				du_write;
input	[`OR1200_DU_DSR_WIDTH-1:0]	du_dsr;
input				du_hwbkpt;
output	[12:0]			du_except;
output	[dw-1:0]		du_dat_cpu;
output	[dw-1:0]		rf_dataw;

//
// Data (DC) interface
//
output	[31:0]			dcpu_adr_o;
output				dcpu_cycstb_o;
output				dcpu_we_o;
output	[3:0]			dcpu_sel_o;
output	[3:0]			dcpu_tag_o;
output	[31:0]			dcpu_dat_o;
input	[31:0]			dcpu_dat_i;
input				dcpu_ack_i;
input				dcpu_rty_i;
input				dcpu_err_i;
input	[3:0]			dcpu_tag_i;
output				dc_en;

//
// Data (DMMU) interface
//
output				dmmu_en;

//
// SPR interface
//
output				supv;
input	[dw-1:0]		spr_dat_pic;
input	[dw-1:0]		spr_dat_tt;
input	[dw-1:0]		spr_dat_pm;
input	[dw-1:0]		spr_dat_dmmu;
input	[dw-1:0]		spr_dat_immu;
input	[dw-1:0]		spr_dat_du;
output	[dw-1:0]		spr_addr;
output	[dw-1:0]		spr_dat_cpu;
output	[dw-1:0]		spr_dat_npc;
output	[31:0]			spr_cs;
output				spr_we;

//
// Interrupt exceptions
//
input				sig_int;
input				sig_tick;

//
// Internal wires
//
wire	[31:0]			if_insn;
wire	[31:0]			if_pc;
wire	[31:2]			lr_sav;
wire	[aw-1:0]		rf_addrw;
wire	[aw-1:0] 		rf_addra;
wire	[aw-1:0] 		rf_addrb;
wire				rf_rda;
wire				rf_rdb;
wire	[dw-1:0]		simm;
wire	[dw-1:2]		branch_addrofs;
wire	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
wire	[`OR1200_SHROTOP_WIDTH-1:0]	shrot_op;
wire	[`OR1200_COMPOP_WIDTH-1:0]	comp_op;
wire	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
wire	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
wire				genpc_freeze;
wire				if_freeze;
wire				id_freeze;
wire				ex_freeze;
wire				wb_freeze;
wire	[`OR1200_SEL_WIDTH-1:0]	sel_a;
wire	[`OR1200_SEL_WIDTH-1:0]	sel_b;
wire	[`OR1200_RFWBOP_WIDTH-1:0]	rfwb_op;
wire	[dw-1:0]		rf_dataw;
wire	[dw-1:0]		rf_dataa;
wire	[dw-1:0]		rf_datab;
wire	[dw-1:0]		muxed_b;
wire	[dw-1:0]		wb_forw;
wire				wbforw_valid;
wire	[dw-1:0]		operand_a;
wire	[dw-1:0]		operand_b;
wire	[dw-1:0]		alu_dataout;
wire	[dw-1:0]		lsu_dataout;
wire	[dw-1:0]		sprs_dataout;
wire	[31:0]			lsu_addrofs;
wire	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle;
wire	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
wire	[4:0]			cust5_op;
wire	[5:0]			cust5_limm;
wire				flushpipe;
wire				extend_flush;
wire				branch_taken;
wire				flag;
wire				flagforw;
wire				flag_we;
wire				carry;
wire				cyforw;
wire				cy_we;
wire				lsu_stall;
wire				epcr_we;
wire				eear_we;
wire				esr_we;
wire				pc_we;
wire	[31:0]			epcr;
wire	[31:0]			eear;
wire	[`OR1200_SR_WIDTH-1:0]	esr;
wire				sr_we;
wire	[`OR1200_SR_WIDTH-1:0]	to_sr;
wire	[`OR1200_SR_WIDTH-1:0]	sr;
wire				except_start;
wire				except_started;
wire	[31:0]			wb_insn;
wire	[15:0]			spr_addrimm;
wire				sig_syscall;
wire				sig_trap;
wire	[31:0]			spr_dat_cfgr;
wire	[31:0]			spr_dat_rf;
wire    [31:0]                  spr_dat_npc;
wire	[31:0]			spr_dat_ppc;
wire	[31:0]			spr_dat_mac;
wire				force_dslot_fetch;
wire				no_more_dslot;
wire				ex_void;
wire				if_stall;
wire				id_macrc_op;
wire				ex_macrc_op;
wire	[`OR1200_MACOP_WIDTH-1:0] mac_op;
wire	[31:0]			mult_mac_result;
wire				mac_stall;
wire	[12:0]			except_stop;
wire				genpc_refetch;
wire				rfe;
wire				lsu_unstall;
wire				except_align;
wire				except_dtlbmiss;
wire				except_dmmufault;
wire				except_illegal;
wire				except_itlbmiss;
wire				except_immufault;
wire				except_ibuserr;
wire				except_dbuserr;
wire				abort_ex;

//
// Send exceptions to Debug Unit
//
assign du_except = except_stop;

//
// Data cache enable
//
assign dc_en = sr[`OR1200_SR_DCE];

//
// Instruction cache enable
//
assign ic_en = sr[`OR1200_SR_ICE];

//
// DMMU enable
//
assign dmmu_en = sr[`OR1200_SR_DME];

//
// IMMU enable
//
assign immu_en = sr[`OR1200_SR_IME];

//
// SUPV bit
//
assign supv = sr[`OR1200_SR_SM];

//
// Instantiation of instruction fetch block
//
wire except_prefix;
assign except_prefix = sr[`OR1200_SR_EPH];

or1200_genpc_cm2 or1200_genpc(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.icpu_adr_o(icpu_adr_o),
	.icpu_cycstb_o(icpu_cycstb_o),
	.icpu_sel_o(icpu_sel_o),
	.icpu_tag_o(icpu_tag_o),
	.icpu_rty_i(icpu_rty_i),
	.icpu_adr_i(icpu_adr_i),

	.branch_op(branch_op),
	.except_type(except_type),
	.except_start(except_start),
	.except_prefix(except_prefix),
	.branch_addrofs(branch_addrofs),
	.lr_restor(operand_b),
	.flag(flag),
	.taken(branch_taken),
	.binsn_addr(lr_sav),
	.epcr(epcr),
	.spr_dat_i(spr_dat_cpu),
	.spr_pc_we(pc_we),
	.genpc_refetch(genpc_refetch),
	.genpc_freeze(genpc_freeze),
  .genpc_stop_prefetch(1'b0),
	.no_more_dslot(no_more_dslot)
);

//
// Instantiation of instruction fetch block
//
or1200_if_cm2 or1200_if(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.icpu_dat_i(icpu_dat_i),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i),
	.icpu_adr_i(icpu_adr_i),
	.icpu_tag_i(icpu_tag_i),

	.if_freeze(if_freeze),
	.if_insn(if_insn),
	.if_pc(if_pc),
	.flushpipe(flushpipe),
	.if_stall(if_stall),
	.no_more_dslot(no_more_dslot),
	.genpc_refetch(genpc_refetch),
	.rfe(rfe),
	.except_itlbmiss(except_itlbmiss),
	.except_immufault(except_immufault),
	.except_ibuserr(except_ibuserr)
);

//
// Instantiation of instruction decode/control logic
//
or1200_ctrl_cm2 or1200_ctrl(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.wb_freeze(wb_freeze),
	.flushpipe(flushpipe),
	.if_insn(if_insn),
	.ex_insn(ex_insn),
	.branch_op(branch_op),
	.branch_taken(branch_taken),
	.rf_addra(rf_addra),
	.rf_addrb(rf_addrb),
	.rf_rda(rf_rda),
	.rf_rdb(rf_rdb),
	.alu_op(alu_op),
	.mac_op(mac_op),
	.shrot_op(shrot_op),
	.comp_op(comp_op),
	.rf_addrw(rf_addrw),
	.rfwb_op(rfwb_op),
	.wb_insn(wb_insn),
	.simm(simm),
	.branch_addrofs(branch_addrofs),
	.lsu_addrofs(lsu_addrofs),
	.sel_a(sel_a),
	.sel_b(sel_b),
	.lsu_op(lsu_op),
	.cust5_op(cust5_op),
	.cust5_limm(cust5_limm),
	.multicycle(multicycle),
	.spr_addrimm(spr_addrimm),
	.wbforw_valid(wbforw_valid),
	.sig_syscall(sig_syscall),
	.sig_trap(sig_trap),
	.force_dslot_fetch(force_dslot_fetch),
	.no_more_dslot(no_more_dslot),
	.ex_void(ex_void),
	.id_macrc_op(id_macrc_op),
	.ex_macrc_op(ex_macrc_op),
	.rfe(rfe),
	.du_hwbkpt(du_hwbkpt),
	.except_illegal(except_illegal)
);

//
// Instantiation of register file
//
wire supv_wire;

// SynEDA CoreMultiplier
// assignment(s): supv_wire
// replace(s): sr
assign supv_wire = sr_cml_1[`OR1200_SR_SM];
wire we;

// SynEDA CoreMultiplier
// assignment(s): we
// replace(s): rfwb_op
assign we = rfwb_op_cml_1[0];
wire spr_cs_group_sys;
assign spr_cs_group_sys = spr_cs[`OR1200_SPR_GROUP_SYS];

or1200_rf_cm2 or1200_rf(
		.clk_i_cml_1(clk_i_cml_1),
		.cmls(cmls),
	.clk(clk),
	.rst(rst),
	.supv(supv_wire),
	.wb_freeze(wb_freeze),
	.addrw(rf_addrw),
	.dataw(rf_dataw),
	.id_freeze(id_freeze),
	.we(we),
	.flushpipe(flushpipe),
	.addra(rf_addra),
	.rda(rf_rda),
	.dataa(rf_dataa),
	.addrb(rf_addrb),
	.rdb(rf_rdb),
	.datab(rf_datab),
	.spr_cs(spr_cs_group_sys),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_rf)
);

//
// Instantiation of operand muxes
//
or1200_operandmuxes_cm2 or1200_operandmuxes(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.rf_dataa(rf_dataa),
	.rf_datab(rf_datab),
	.ex_forw(rf_dataw),
	.wb_forw(wb_forw),
	.simm(simm),
	.sel_a(sel_a),
	.sel_b(sel_b),
	.operand_a(operand_a),
	.operand_b(operand_b),
	.muxed_b(muxed_b)
);

//
// Instantiation of CPU's ALU
//
or1200_alu_cm2 or1200_alu(
		.clk_i_cml_1(clk_i_cml_1),
	.a(operand_a),
	.b(operand_b),
	.mult_mac_result(mult_mac_result),
	.macrc_op(ex_macrc_op),
	.alu_op(alu_op),
	.shrot_op(shrot_op),
	.comp_op(comp_op),
	.cust5_op(cust5_op),
	.cust5_limm(cust5_limm),
	.result(alu_dataout),
	.flagforw(flagforw),
	.flag_we(flag_we),
	.cyforw(cyforw),
	.cy_we(cy_we),
  .flag(flag),
	.carry(carry)
);

//
// Instantiation of CPU's ALU
//
wire spr_cs_group_mac;

// SynEDA CoreMultiplier
// assignment(s): spr_cs_group_mac
// replace(s): spr_cs
assign spr_cs_group_mac = spr_cs_cml_1[`OR1200_SPR_GROUP_MAC];

or1200_mult_mac_cm2 or1200_mult_mac(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.ex_freeze(ex_freeze),
	.id_macrc_op(id_macrc_op),
	.macrc_op(ex_macrc_op),
	.a(operand_a),
	.b(operand_b),
	.mac_op(mac_op),
	.alu_op(alu_op),
	.result(mult_mac_result),
	.mac_stall_r(mac_stall),
	.spr_cs(spr_cs_group_mac),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_mac)
);

//
// Instantiation of CPU's SPRS block
//
or1200_sprs_cm2 or1200_sprs(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.addrbase(operand_a),
	.addrofs(spr_addrimm),
	.dat_i(operand_b),
	.alu_op(alu_op),
	.flagforw(flagforw),
	.flag_we(flag_we),
	.flag(flag),
	.cyforw(cyforw),
	.cy_we(cy_we),
	.carry(carry),
	.to_wbmux(sprs_dataout),

	.du_addr(du_addr),
	.du_dat_du(du_dat_du),
	.du_read(du_read),
	.du_write(du_write),
	.du_dat_cpu(du_dat_cpu),

	.spr_addr(spr_addr),
	.spr_dat_pic(spr_dat_pic),
	.spr_dat_tt(spr_dat_tt),
	.spr_dat_pm(spr_dat_pm),
	.spr_dat_cfgr(spr_dat_cfgr),
	.spr_dat_rf(spr_dat_rf),
	.spr_dat_npc(spr_dat_npc),
        .spr_dat_ppc(spr_dat_ppc),
	.spr_dat_mac(spr_dat_mac),
	.spr_dat_dmmu(spr_dat_dmmu),
	.spr_dat_immu(spr_dat_immu),
	.spr_dat_du(spr_dat_du),
	.spr_dat_o(spr_dat_cpu),
	.spr_cs(spr_cs),
	.spr_we(spr_we),

	.epcr_we(epcr_we),
	.eear_we(eear_we),
	.esr_we(esr_we),
	.pc_we(pc_we),
	.epcr(epcr),
	.eear(eear),
	.esr(esr),
	.except_started(except_started),

	.sr_we(sr_we),
	.to_sr(to_sr),
	.sr(sr),
	.branch_op(branch_op)
);

//
// Instantiation of load/store unit
//
or1200_lsu_cm2 or1200_lsu(
		.clk_i_cml_1(clk_i_cml_1),
	.addrbase(operand_a),
	.addrofs(lsu_addrofs),
	.lsu_op(lsu_op),
	.lsu_datain(operand_b),
	.lsu_dataout(lsu_dataout),
	.lsu_stall(lsu_stall),
	.lsu_unstall(lsu_unstall),
        .du_stall(du_stall),
	.except_align(except_align),
	.except_dtlbmiss(except_dtlbmiss),
	.except_dmmufault(except_dmmufault),
	.except_dbuserr(except_dbuserr),

	.dcpu_adr_o(dcpu_adr_o),
	.dcpu_cycstb_o(dcpu_cycstb_o),
	.dcpu_we_o(dcpu_we_o),
	.dcpu_sel_o(dcpu_sel_o),
	.dcpu_tag_o(dcpu_tag_o),
	.dcpu_dat_o(dcpu_dat_o),
	.dcpu_dat_i(dcpu_dat_i),
	.dcpu_ack_i(dcpu_ack_i),
	.dcpu_rty_i(dcpu_rty_i),
	.dcpu_err_i(dcpu_err_i),
	.dcpu_tag_i(dcpu_tag_i)
);

//
// Instantiation of write-back muxes
//
wire [31:0] muxin_d;

// SynEDA CoreMultiplier
// assignment(s): muxin_d
// replace(s): lr_sav
assign muxin_d = {lr_sav_cml_1, 2'b0};

or1200_wbmux_cm2 or1200_wbmux(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.wb_freeze(wb_freeze),
	.rfwb_op(rfwb_op),
	.muxin_a(alu_dataout),
	.muxin_b(lsu_dataout),
	.muxin_c(sprs_dataout),
	.muxin_d(muxin_d),
	.muxout(rf_dataw),
	.muxreg(wb_forw),
	.muxreg_valid(wbforw_valid)
);

//
// Instantiation of freeze logic
//
or1200_freeze_cm2 or1200_freeze(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.multicycle(multicycle),
	.flushpipe(flushpipe),
	.extend_flush(extend_flush),
	.lsu_stall(lsu_stall),
	.if_stall(if_stall),
	.lsu_unstall(lsu_unstall),
	.force_dslot_fetch(force_dslot_fetch),
	.abort_ex(abort_ex),
	.du_stall(du_stall),
	.mac_stall(mac_stall),
	.genpc_freeze(genpc_freeze),
	.if_freeze(if_freeze),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.wb_freeze(wb_freeze),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i)
);

//
// Instantiation of exception block
//
or1200_except_cm2 or1200_except(
		.clk_i_cml_1(clk_i_cml_1),
	.clk(clk),
	.rst(rst),
	.sig_ibuserr(except_ibuserr),
	.sig_dbuserr(except_dbuserr),
	.sig_illegal(except_illegal),
	.sig_align(except_align),
	.sig_range(1'b0),
	.sig_dtlbmiss(except_dtlbmiss),
	.sig_dmmufault(except_dmmufault),
	.sig_int(sig_int),
	.sig_syscall(sig_syscall),
	.sig_trap(sig_trap),
	.sig_itlbmiss(except_itlbmiss),
	.sig_immufault(except_immufault),
	.sig_tick(sig_tick),
	.branch_taken(branch_taken),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i),
	.dcpu_ack_i(dcpu_ack_i),
	.dcpu_err_i(dcpu_err_i),
	.genpc_freeze(genpc_freeze),
        .id_freeze(id_freeze),
        .ex_freeze(ex_freeze),
        .wb_freeze(wb_freeze),
	.if_stall(if_stall),
	.if_pc(if_pc),
	.id_pc(id_pc),
	.lr_sav(lr_sav),
	.flushpipe(flushpipe),
	.extend_flush(extend_flush),
	.except_type(except_type),
	.except_start(except_start),
	.except_started(except_started),
	.except_stop(except_stop),
	.ex_void(ex_void),
	.spr_dat_ppc(spr_dat_ppc),
	.spr_dat_npc(spr_dat_npc),

	.datain(operand_b),
	.du_dsr(du_dsr),
	.epcr_we(epcr_we),
	.eear_we(eear_we),
	.esr_we(esr_we),
	.pc_we(pc_we),
        .epcr(epcr),
	.eear(eear),
	.esr(esr),

	.lsu_addr(dcpu_adr_o),
	.sr_we(sr_we),
	.to_sr(to_sr),
	.sr(sr),
	.abort_ex(abort_ex)
);

//
// Instantiation of configuration registers
//
or1200_cfgr_cm2 or1200_cfgr(
		.clk_i_cml_1(clk_i_cml_1),
	.spr_addr(spr_addr),
	.spr_dat_o(spr_dat_cfgr)
);


always @ (posedge clk_i_cml_1) begin
spr_cs_cml_1 <= spr_cs;
lr_sav_cml_1 <= lr_sav;
rfwb_op_cml_1 <= rfwb_op;
sr_cml_1 <= sr;
end
endmodule

