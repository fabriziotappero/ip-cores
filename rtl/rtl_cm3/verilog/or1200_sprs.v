//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's interface to SPRs                                  ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Decoding of SPR addresses and access to SPRs                ////
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
// Revision 1.9.4.1  2003/12/17 13:43:38  simons
// Exception prefix configuration changed.
//
// Revision 1.9  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.8  2002/08/28 01:44:25  lampret
// Removed some commented RTL. Fixed SR/ESR flag bug.
//
// Revision 1.7  2002/03/29 15:16:56  lampret
// Some of the warnings fixed.
//
// Revision 1.6  2002/03/11 01:26:57  lampret
// Changed generation of SPR address. Now it is ORed from base and offset instead of a sum.
//
// Revision 1.5  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.4  2002/01/23 07:52:36  lampret
// Changed default reset values for SR and ESR to match or1ksim's. Fixed flop model in or1200_dpram_32x32 when OR1200_XILINX_RAM32X1D is defined.
//
// Revision 1.3  2002/01/19 09:27:49  lampret
// SR[TEE] should be zero after reset.
//
// Revision 1.2  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.12  2001/11/23 21:42:31  simons
// Program counter divided to PPC and NPC.
//
// Revision 1.11  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.10  2001/11/12 01:45:41  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.3  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.2  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.1  2001/07/20 00:46:21  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_sprs_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
		
		// Clk & Rst
		clk, rst,

		// Internal CPU interface
		flagforw, flag_we, flag, cyforw, cy_we, carry,
		addrbase, addrofs, dat_i, alu_op, branch_op,
		epcr, eear, esr, except_started,
		to_wbmux, epcr_we, eear_we, esr_we, pc_we, sr_we, to_sr, sr,
		spr_dat_cfgr, spr_dat_rf, spr_dat_npc, spr_dat_ppc, spr_dat_mac,

		// From/to other RISC units
		spr_dat_pic, spr_dat_tt, spr_dat_pm,
		spr_dat_dmmu, spr_dat_immu, spr_dat_du,
		spr_addr, spr_dat_o, spr_cs, spr_we,

		du_addr, du_dat_du, du_read,
		du_write, du_dat_cpu

);


input clk_i_cml_1;
input clk_i_cml_2;
reg  flag_we_cml_2;
reg  cy_we_cml_2;
reg [ 32 - 1 : 0 ] dat_i_cml_2;
reg [ 32 - 1 : 0 ] dat_i_cml_1;
reg [ 3 - 1 : 0 ] branch_op_cml_2;
reg [ 3 - 1 : 0 ] branch_op_cml_1;
reg [ 32 - 1 : 0 ] epcr_cml_1;
reg [ 32 - 1 : 0 ] eear_cml_1;
reg [ 16 - 1 : 0 ] esr_cml_2;
reg [ 16 - 1 : 0 ] esr_cml_1;
reg [ 32 - 1 : 0 ] to_wbmux_cml_2;
reg  sr_we_cml_2;
reg [ 16 - 1 : 0 ] sr_cml_2;
reg [ 16 - 1 : 0 ] sr_cml_1;
reg [ 31 : 0 ] spr_addr_cml_1;
reg [ 31 : 0 ] spr_dat_o_cml_2;
reg [ 31 : 0 ] spr_dat_o_cml_1;
reg [ 31 : 0 ] spr_cs_cml_1;
reg [ 32 - 1 : 0 ] du_dat_du_cml_2;
reg [ 32 - 1 : 0 ] du_dat_du_cml_1;
reg  du_read_cml_2;
reg  du_read_cml_1;
reg  du_write_cml_2;
reg  du_write_cml_1;
reg  write_spr_cml_2;
reg  write_spr_cml_1;
reg  read_spr_cml_1;
reg  npc_sel_cml_1;
reg  ppc_sel_cml_1;
reg  sr_sel_cml_2;
reg  epcr_sel_cml_2;
reg  eear_sel_cml_2;
reg  esr_sel_cml_2;
reg [ 4 - 1 : 0 ] sprs_op_cml_1;



parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O Ports
//

//
// Internal CPU interface
//
input				clk; 		// Clock
input 				rst;		// Reset
input 				flagforw;	// From ALU
input 				flag_we;	// From ALU
output 				flag;		// SR[F]
input 				cyforw;		// From ALU
input 				cy_we;		// From ALU
output 				carry;		// SR[CY]
input	[width-1:0] 		addrbase;	// SPR base address
input	[15:0] 			addrofs;	// SPR offset
input	[width-1:0]		dat_i;		// SPR write data
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;		// ALU operation
input	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;	// Branch operation
input	[width-1:0] 		epcr;		// EPCR0
input	[width-1:0] 		eear;		// EEAR0
input	[`OR1200_SR_WIDTH-1:0] 	esr;		// ESR0
input 				except_started; // Exception was started
output	[width-1:0]		to_wbmux;	// For l.mfspr
output				epcr_we;	// EPCR0 write enable
output				eear_we;	// EEAR0 write enable
output				esr_we;		// ESR0 write enable
output				pc_we;		// PC write enable
output 				sr_we;		// Write enable SR
output	[`OR1200_SR_WIDTH-1:0]	to_sr;		// Data to SR
output	[`OR1200_SR_WIDTH-1:0]	sr;		// SR
input	[31:0]			spr_dat_cfgr;	// Data from CFGR
input	[31:0]			spr_dat_rf;	// Data from RF
input	[31:0]			spr_dat_npc;	// Data from NPC
input	[31:0]			spr_dat_ppc;	// Data from PPC   
input	[31:0]			spr_dat_mac;	// Data from MAC

//
// To/from other RISC units
//
input	[31:0]			spr_dat_pic;	// Data from PIC
input	[31:0]			spr_dat_tt;	// Data from TT
input	[31:0]			spr_dat_pm;	// Data from PM
input	[31:0]			spr_dat_dmmu;	// Data from DMMU
input	[31:0]			spr_dat_immu;	// Data from IMMU
input	[31:0]			spr_dat_du;	// Data from DU
output	[31:0]			spr_addr;	// SPR Address
output	[31:0]			spr_dat_o;	// Data to unit
output	[31:0]			spr_cs;		// Unit select
output				spr_we;		// SPR write enable

//
// To/from Debug Unit
//
input	[width-1:0]		du_addr;	// Address
input	[width-1:0]		du_dat_du;	// Data from DU to SPRS
input				du_read;	// Read qualifier
input				du_write;	// Write qualifier
output	[width-1:0]		du_dat_cpu;	// Data from SPRS to DU

//
// Internal regs & wires
//
reg	[`OR1200_SR_WIDTH-1:0]		sr;		// SR
reg				write_spr;	// Write SPR
reg				read_spr;	// Read SPR
reg	[width-1:0]		to_wbmux;	// For l.mfspr
wire				cfgr_sel;	// Select for cfg regs
wire				rf_sel;		// Select for RF
wire				npc_sel;	// Select for NPC
wire				ppc_sel;	// Select for PPC
wire 				sr_sel;		// Select for SR	
wire 				epcr_sel;	// Select for EPCR0
wire 				eear_sel;	// Select for EEAR0
wire 				esr_sel;	// Select for ESR0
wire	[31:0]			sys_data;	// Read data from system SPRs
wire				du_access;	// Debug unit access
wire	[`OR1200_ALUOP_WIDTH-1:0]	sprs_op;	// ALU operation
reg	[31:0]			unqualified_cs;	// Unqualified chip selects

//
// Decide if it is debug unit access
//
assign du_access = du_read | du_write;

//
// Generate sprs opcode
//
assign sprs_op = du_write ? `OR1200_ALUOP_MTSR : du_read ? `OR1200_ALUOP_MFSR : alu_op;

//
// Generate SPR address from base address and offset
// OR from debug unit address
//
assign spr_addr = du_access ? du_addr : addrbase | {16'h0000, addrofs};

//
// SPR is written by debug unit or by l.mtspr
//
assign spr_dat_o = du_write ? du_dat_du : dat_i;

//
// debug unit data input:
//  - write into debug unit SPRs by debug unit itself
//  - read of SPRS by debug unit
//  - write into debug unit SPRs by l.mtspr
//

// SynEDA CoreMultiplier
// assignment(s): du_dat_cpu
// replace(s): dat_i, to_wbmux, du_dat_du, du_read, du_write
assign du_dat_cpu = du_write_cml_2 ? du_dat_du_cml_2 : du_read_cml_2 ? to_wbmux_cml_2 : dat_i_cml_2;

//
// Write into SPRs when l.mtspr
//

// SynEDA CoreMultiplier
// assignment(s): spr_we
// replace(s): du_write, write_spr
assign spr_we = du_write_cml_1 | write_spr_cml_1;

//
// Qualify chip selects
//
assign spr_cs = unqualified_cs & {32{read_spr | write_spr}};

//
// Decoding of groups
//
always @(spr_addr)
	case (spr_addr[`OR1200_SPR_GROUP_BITS])	// synopsys parallel_case
		`OR1200_SPR_GROUP_WIDTH'd00: unqualified_cs = 32'b00000000_00000000_00000000_00000001;
		`OR1200_SPR_GROUP_WIDTH'd01: unqualified_cs = 32'b00000000_00000000_00000000_00000010;
		`OR1200_SPR_GROUP_WIDTH'd02: unqualified_cs = 32'b00000000_00000000_00000000_00000100;
		`OR1200_SPR_GROUP_WIDTH'd03: unqualified_cs = 32'b00000000_00000000_00000000_00001000;
		`OR1200_SPR_GROUP_WIDTH'd04: unqualified_cs = 32'b00000000_00000000_00000000_00010000;
		`OR1200_SPR_GROUP_WIDTH'd05: unqualified_cs = 32'b00000000_00000000_00000000_00100000;
		`OR1200_SPR_GROUP_WIDTH'd06: unqualified_cs = 32'b00000000_00000000_00000000_01000000;
		`OR1200_SPR_GROUP_WIDTH'd07: unqualified_cs = 32'b00000000_00000000_00000000_10000000;
		`OR1200_SPR_GROUP_WIDTH'd08: unqualified_cs = 32'b00000000_00000000_00000001_00000000;
		`OR1200_SPR_GROUP_WIDTH'd09: unqualified_cs = 32'b00000000_00000000_00000010_00000000;
		`OR1200_SPR_GROUP_WIDTH'd10: unqualified_cs = 32'b00000000_00000000_00000100_00000000;
		`OR1200_SPR_GROUP_WIDTH'd11: unqualified_cs = 32'b00000000_00000000_00001000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd12: unqualified_cs = 32'b00000000_00000000_00010000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd13: unqualified_cs = 32'b00000000_00000000_00100000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd14: unqualified_cs = 32'b00000000_00000000_01000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd15: unqualified_cs = 32'b00000000_00000000_10000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd16: unqualified_cs = 32'b00000000_00000001_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd17: unqualified_cs = 32'b00000000_00000010_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd18: unqualified_cs = 32'b00000000_00000100_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd19: unqualified_cs = 32'b00000000_00001000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd20: unqualified_cs = 32'b00000000_00010000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd21: unqualified_cs = 32'b00000000_00100000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd22: unqualified_cs = 32'b00000000_01000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd23: unqualified_cs = 32'b00000000_10000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd24: unqualified_cs = 32'b00000001_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd25: unqualified_cs = 32'b00000010_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd26: unqualified_cs = 32'b00000100_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd27: unqualified_cs = 32'b00001000_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd28: unqualified_cs = 32'b00010000_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd29: unqualified_cs = 32'b00100000_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd30: unqualified_cs = 32'b01000000_00000000_00000000_00000000;
		`OR1200_SPR_GROUP_WIDTH'd31: unqualified_cs = 32'b10000000_00000000_00000000_00000000;
	endcase

//
// SPRs System Group
//

//
// What to write into SR
//
assign to_sr[`OR1200_SR_FO:`OR1200_SR_OV] =
		(branch_op_cml_2 == `OR1200_BRANCHOP_RFE) ? esr_cml_2[`OR1200_SR_FO:`OR1200_SR_OV] :
		(write_spr_cml_2 && sr_sel_cml_2) ? {1'b1, spr_dat_o_cml_2[`OR1200_SR_FO-1:`OR1200_SR_OV]}:
		sr_cml_2[`OR1200_SR_FO:`OR1200_SR_OV];
assign to_sr[`OR1200_SR_CY] =
		(branch_op_cml_2 == `OR1200_BRANCHOP_RFE) ? esr_cml_2[`OR1200_SR_CY] :
		cy_we_cml_2 ? cyforw :
		(write_spr_cml_2 && sr_sel_cml_2) ? spr_dat_o_cml_2[`OR1200_SR_CY] :
		sr_cml_2[`OR1200_SR_CY];
assign to_sr[`OR1200_SR_F] =
		(branch_op_cml_2 == `OR1200_BRANCHOP_RFE) ? esr_cml_2[`OR1200_SR_F] :
		flag_we_cml_2 ? flagforw :
		(write_spr_cml_2 && sr_sel_cml_2) ? spr_dat_o_cml_2[`OR1200_SR_F] :
		sr_cml_2[`OR1200_SR_F];

// SynEDA CoreMultiplier
// assignment(s): to_sr
// replace(s): flag_we, cy_we, branch_op, esr, sr, spr_dat_o, write_spr, sr_sel
assign to_sr[`OR1200_SR_CE:`OR1200_SR_SM] =
		(branch_op_cml_2 == `OR1200_BRANCHOP_RFE) ? esr_cml_2[`OR1200_SR_CE:`OR1200_SR_SM] :
		(write_spr_cml_2 && sr_sel_cml_2) ? spr_dat_o_cml_2[`OR1200_SR_CE:`OR1200_SR_SM]:
		sr_cml_2[`OR1200_SR_CE:`OR1200_SR_SM];

//
// Selects for system SPRs
//

// SynEDA CoreMultiplier
// assignment(s): cfgr_sel
// replace(s): spr_addr, spr_cs
assign cfgr_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:4] == `OR1200_SPR_CFGR));

// SynEDA CoreMultiplier
// assignment(s): rf_sel
// replace(s): spr_addr, spr_cs
assign rf_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:5] == `OR1200_SPR_RF));
assign npc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_NPC));
assign ppc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_PPC));

// SynEDA CoreMultiplier
// assignment(s): sr_sel
// replace(s): spr_addr, spr_cs
assign sr_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:0] == `OR1200_SPR_SR));

// SynEDA CoreMultiplier
// assignment(s): epcr_sel
// replace(s): spr_addr, spr_cs
assign epcr_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:0] == `OR1200_SPR_EPCR));

// SynEDA CoreMultiplier
// assignment(s): eear_sel
// replace(s): spr_addr, spr_cs
assign eear_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:0] == `OR1200_SPR_EEAR));

// SynEDA CoreMultiplier
// assignment(s): esr_sel
// replace(s): spr_addr, spr_cs
assign esr_sel = (spr_cs_cml_1[`OR1200_SPR_GROUP_SYS] && (spr_addr_cml_1[10:0] == `OR1200_SPR_ESR));

//
// Write enables for system SPRs
//

// SynEDA CoreMultiplier
// assignment(s): sr_we
// replace(s): branch_op, write_spr
assign sr_we = (write_spr_cml_1 && sr_sel) | (branch_op_cml_1 == `OR1200_BRANCHOP_RFE) | flag_we | cy_we;
assign pc_we = (write_spr && (npc_sel | ppc_sel));

// SynEDA CoreMultiplier
// assignment(s): epcr_we
// replace(s): write_spr, epcr_sel
assign epcr_we = (write_spr_cml_2 && epcr_sel_cml_2);

// SynEDA CoreMultiplier
// assignment(s): eear_we
// replace(s): write_spr, eear_sel
assign eear_we = (write_spr_cml_2 && eear_sel_cml_2);

// SynEDA CoreMultiplier
// assignment(s): esr_we
// replace(s): write_spr, esr_sel
assign esr_we = (write_spr_cml_2 && esr_sel_cml_2);

//
// Output from system SPRs
//
//assign sys_data = (spr_dat_cfgr & {32{read_spr & cfgr_sel}}) |
//		  (spr_dat_rf & {32{read_spr & rf_sel}}) |
//		  (spr_dat_npc & {32{read_spr & npc_sel}}) |
//		  (spr_dat_ppc & {32{read_spr & ppc_sel}}) |
//		  ({{32-`OR1200_SR_WIDTH{1'b0}},sr} & {32{read_spr & sr_sel}}) |
//		  (epcr & {32{read_spr & epcr_sel}}) |
//		  (eear & {32{read_spr & eear_sel}}) |
//		  ({{32-`OR1200_SR_WIDTH{1'b0}},esr} & {32{read_spr & esr_sel}});


wire [31:0] read_spr_cfgr_sel_32;
wire [31:0] read_spr_rf_sel_32;
wire [31:0] read_spr_npc_sel_32;
wire [31:0] read_spr_ppc_sel_32;
wire [31:0] read_spr_sr_sel_32;
wire [31:0] read_spr_epcr_sel_32;
wire [31:0] read_spr_eear_sel_32;
wire [31:0] read_spr_esr_sel_32;
wire [31:0] sr_32;
wire [31:0] esr_32;

// SynEDA CoreMultiplier
// assignment(s): read_spr_cfgr_sel_32
// replace(s): read_spr
assign read_spr_cfgr_sel_32 = {32{read_spr_cml_1 & cfgr_sel}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_rf_sel_32
// replace(s): read_spr
assign read_spr_rf_sel_32 = {32{read_spr_cml_1 & rf_sel}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_npc_sel_32
// replace(s): read_spr, npc_sel
assign read_spr_npc_sel_32 = {32{read_spr_cml_1 & npc_sel_cml_1}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_ppc_sel_32
// replace(s): read_spr, ppc_sel
assign read_spr_ppc_sel_32 = {32{read_spr_cml_1 & ppc_sel_cml_1}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_sr_sel_32
// replace(s): read_spr
assign read_spr_sr_sel_32 = {32{read_spr_cml_1 & sr_sel}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_epcr_sel_32
// replace(s): read_spr
assign read_spr_epcr_sel_32 = {32{read_spr_cml_1 & epcr_sel}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_eear_sel_32
// replace(s): read_spr
assign read_spr_eear_sel_32 = {32{read_spr_cml_1 & eear_sel}};

// SynEDA CoreMultiplier
// assignment(s): read_spr_esr_sel_32
// replace(s): read_spr
assign read_spr_esr_sel_32 = {32{read_spr_cml_1 & esr_sel}};

// SynEDA CoreMultiplier
// assignment(s): sr_32
// replace(s): sr
assign sr_32 = {{32-`OR1200_SR_WIDTH{1'b0}},sr_cml_1};

// SynEDA CoreMultiplier
// assignment(s): esr_32
// replace(s): esr
assign esr_32 = {{32-`OR1200_SR_WIDTH{1'b0}},esr_cml_1};


// SynEDA CoreMultiplier
// assignment(s): sys_data
// replace(s): epcr, eear
assign sys_data = (spr_dat_cfgr & read_spr_cfgr_sel_32) |
		  (spr_dat_rf & read_spr_rf_sel_32) |
		  (spr_dat_npc & read_spr_npc_sel_32) |
		  (spr_dat_ppc & read_spr_ppc_sel_32) |
		  (sr_32 & read_spr_sr_sel_32) |
		  (epcr_cml_1 & read_spr_epcr_sel_32) |
		  (eear_cml_1 & read_spr_eear_sel_32) |
		  (esr_32 & read_spr_esr_sel_32);


//
// Flag alias
//
assign flag = sr[`OR1200_SR_F];

//
// Carry alias
//
assign carry = sr[`OR1200_SR_CY];

//
// Supervision register
//

// SynEDA CoreMultiplier
// assignment(s): sr
// replace(s): sr_we, sr
always @(posedge clk or posedge rst)
	if (rst)
		sr <= #1 {1'b1, `OR1200_SR_EPH_DEF, {`OR1200_SR_WIDTH-3{1'b0}}, 1'b1};
	else begin  sr <= sr_cml_2; if (except_started) begin
		sr[`OR1200_SR_SM]  <= #1 1'b1;
		sr[`OR1200_SR_TEE] <= #1 1'b0;
		sr[`OR1200_SR_IEE] <= #1 1'b0;
		sr[`OR1200_SR_DME] <= #1 1'b0;
		sr[`OR1200_SR_IME] <= #1 1'b0;
	end
	else if (sr_we_cml_2)
		sr <= #1 to_sr[`OR1200_SR_WIDTH-1:0]; end

//
// MTSPR/MFSPR interface
//
always @(sprs_op or spr_addr or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
	case (sprs_op)	// synopsys parallel_case
		`OR1200_ALUOP_MTSR : begin
			write_spr = 1'b1;
		end
		`OR1200_ALUOP_MFSR : begin
			write_spr = 1'b0;
		end
		default : begin
			write_spr = 1'b0;
		end
	endcase
end

always @(sprs_op or spr_addr or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
	case (sprs_op)	// synopsys parallel_case
		`OR1200_ALUOP_MTSR : begin
			read_spr = 1'b0;
		end
		`OR1200_ALUOP_MFSR : begin
			read_spr = 1'b1;
		end
		default : begin
			read_spr = 1'b0;
		end
	endcase
end


// SynEDA CoreMultiplier
// assignment(s): to_wbmux
// replace(s): spr_addr, sprs_op
always @(sprs_op_cml_1 or spr_addr_cml_1 or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
	case (sprs_op_cml_1)	// synopsys parallel_case
		`OR1200_ALUOP_MTSR : begin
			to_wbmux = 32'b0;
		end
		`OR1200_ALUOP_MFSR : begin
			casex (spr_addr_cml_1[`OR1200_SPR_GROUP_BITS]) // synopsys parallel_case
				`OR1200_SPR_GROUP_TT:
					to_wbmux = spr_dat_tt;
				`OR1200_SPR_GROUP_PIC:
					to_wbmux = spr_dat_pic;
				`OR1200_SPR_GROUP_PM:
					to_wbmux = spr_dat_pm;
				`OR1200_SPR_GROUP_DMMU:
					to_wbmux = spr_dat_dmmu;
				`OR1200_SPR_GROUP_IMMU:
					to_wbmux = spr_dat_immu;
				`OR1200_SPR_GROUP_MAC:
					to_wbmux = spr_dat_mac;
				`OR1200_SPR_GROUP_DU:
					to_wbmux = spr_dat_du;
				`OR1200_SPR_GROUP_SYS:
					to_wbmux = sys_data;
				default:
					to_wbmux = 32'b0;
			endcase
		end
		default : begin
			to_wbmux = 32'b0;
		end
	endcase
end


always @ (posedge clk_i_cml_1) begin
dat_i_cml_1 <= dat_i;
branch_op_cml_1 <= branch_op;
epcr_cml_1 <= epcr;
eear_cml_1 <= eear;
esr_cml_1 <= esr;
sr_cml_1 <= sr;
spr_addr_cml_1 <= spr_addr;
spr_dat_o_cml_1 <= spr_dat_o;
spr_cs_cml_1 <= spr_cs;
du_dat_du_cml_1 <= du_dat_du;
du_read_cml_1 <= du_read;
du_write_cml_1 <= du_write;
write_spr_cml_1 <= write_spr;
read_spr_cml_1 <= read_spr;
npc_sel_cml_1 <= npc_sel;
ppc_sel_cml_1 <= ppc_sel;
sprs_op_cml_1 <= sprs_op;
end
always @ (posedge clk_i_cml_2) begin
flag_we_cml_2 <= flag_we;
cy_we_cml_2 <= cy_we;
dat_i_cml_2 <= dat_i_cml_1;
branch_op_cml_2 <= branch_op_cml_1;
esr_cml_2 <= esr_cml_1;
to_wbmux_cml_2 <= to_wbmux;
sr_we_cml_2 <= sr_we;
sr_cml_2 <= sr_cml_1;
spr_dat_o_cml_2 <= spr_dat_o_cml_1;
du_dat_du_cml_2 <= du_dat_du_cml_1;
du_read_cml_2 <= du_read_cml_1;
du_write_cml_2 <= du_write_cml_1;
write_spr_cml_2 <= write_spr_cml_1;
sr_sel_cml_2 <= sr_sel;
epcr_sel_cml_2 <= epcr_sel;
eear_sel_cml_2 <= eear_sel;
esr_sel_cml_2 <= esr_sel;
end
endmodule

