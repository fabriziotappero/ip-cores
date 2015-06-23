//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Instruction decode                                 ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Majority of instruction decoding is performed here.         ////
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
// Revision 1.12  2005/01/07 09:31:07  andreje
// sign/zero extension for l.sfxxi instructions corrected
//
// Revision 1.11  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.10  2004/05/09 19:49:04  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.9  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.8.4.1  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.8  2003/04/24 00:16:07  lampret
// No functional changes. Added defines to disable implementation of multiplier/MAC
//
// Revision 1.7  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.6  2002/03/29 15:16:54  lampret
// Some of the warnings fixed.
//
// Revision 1.5  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.4  2002/01/28 01:15:59  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.3  2002/01/18 14:21:43  lampret
// Fixed 'the NPC single-step fix'.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.14  2001/11/30 18:59:17  simons
// force_dslot_fetch does not work -  allways zero.
//
// Revision 1.13  2001/11/20 18:46:15  simons
// Break point bug fixed
//
// Revision 1.12  2001/11/18 08:36:28  lampret
// For GDB changed single stepping and disabled trap exception.
//
// Revision 1.11  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.10  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.9  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.8  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.7  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.2  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_ctrl(
	// Clock and reset
	clk, rst,

	// Internal i/f
	id_freeze, ex_freeze, wb_freeze, flushpipe, if_insn, ex_insn, branch_op, branch_taken,
	rf_addra, rf_addrb, rf_rda, rf_rdb, alu_op, mac_op, shrot_op, comp_op, rf_addrw, rfwb_op,
	wb_insn, simm, branch_addrofs, lsu_addrofs, sel_a, sel_b, lsu_op,
	cust5_op, cust5_limm,
	multicycle, spr_addrimm, wbforw_valid, du_hwbkpt, sig_syscall, sig_trap,
	force_dslot_fetch, no_more_dslot, ex_void, id_macrc_op, ex_macrc_op, rfe, except_illegal
);

//
// I/O
//
input					clk;
input					rst;
input					id_freeze;
input					ex_freeze;
input					wb_freeze;
input					flushpipe;
input	[31:0]				if_insn;
output	[31:0]				ex_insn;
output	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
input						branch_taken;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addra;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrb;
output					rf_rda;
output					rf_rdb;
output	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
output	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
output	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
output	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
output	[31:0]				wb_insn;
output	[31:0]				simm;
output	[31:2]				branch_addrofs;
output	[31:0]				lsu_addrofs;
output	[`OR1200_SEL_WIDTH-1:0]		sel_a;
output	[`OR1200_SEL_WIDTH-1:0]		sel_b;
output	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
output	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
output	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
output	[4:0]				cust5_op;
output	[5:0]				cust5_limm;
output	[15:0]				spr_addrimm;
input					wbforw_valid;
input					du_hwbkpt;
output					sig_syscall;
output					sig_trap;
output					force_dslot_fetch;
output					no_more_dslot;
output					ex_void;
output					id_macrc_op;
output					ex_macrc_op;
output					rfe;
output					except_illegal;

//
// Internal wires and regs
//
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		pre_branch_op;
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
reg	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
`ifdef OR1200_MAC_IMPLEMENTED
reg	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
reg					ex_macrc_op;
`else
wire	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
wire					ex_macrc_op;
`endif
reg	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
reg	[31:0]				id_insn;
reg	[31:0]				ex_insn;
reg	[31:0]				wb_insn;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	wb_rfaddrw;
reg	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
reg	[31:0]				lsu_addrofs;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_a;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_b;
reg					sel_imm;
reg	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
reg	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
reg					imm_signextend;
reg	[15:0]				spr_addrimm;
reg					sig_syscall;
reg					sig_trap;
reg					except_illegal;
wire					id_void;

//
// Register file read addresses
//
assign rf_addra = if_insn[20:16];
assign rf_addrb = if_insn[15:11];
assign rf_rda = if_insn[31];
assign rf_rdb = if_insn[30];

//
// Force fetch of delay slot instruction when jump/branch is preceeded by load/store
// instructions
//
// SIMON
// assign force_dslot_fetch = ((|pre_branch_op) & (|lsu_op));
assign force_dslot_fetch = 1'b0;
assign no_more_dslot = |branch_op & !id_void & branch_taken | (branch_op == `OR1200_BRANCHOP_RFE);
assign id_void = (id_insn[31:26] == `OR1200_OR32_NOP) & id_insn[16];
assign ex_void = (ex_insn[31:26] == `OR1200_OR32_NOP) & ex_insn[16];

//
// Sign/Zero extension of immediates
//
assign simm = (imm_signextend == 1'b1) ? {{16{id_insn[15]}}, id_insn[15:0]} : {{16'b0}, id_insn[15:0]};

//
// Sign extension of branch offset
//
assign branch_addrofs = {{4{ex_insn[25]}}, ex_insn[25:0]};

//
// l.macrc in ID stage
//
`ifdef OR1200_MAC_IMPLEMENTED
assign id_macrc_op = (id_insn[31:26] == `OR1200_OR32_MOVHI) & id_insn[16];
`else
assign id_macrc_op = 1'b0;
`endif

//
// cust5_op, cust5_limm (L immediate)
//
assign cust5_op = ex_insn[4:0];
assign cust5_limm = ex_insn[10:5];

//
//
//
assign rfe = (pre_branch_op == `OR1200_BRANCHOP_RFE) | (branch_op == `OR1200_BRANCHOP_RFE);

//
// Generation of sel_a
//
always @(rf_addrw or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if ((id_insn[20:16] == rf_addrw) && rfwb_op[0])
		sel_a = `OR1200_SEL_EX_FORW;
	else if ((id_insn[20:16] == wb_rfaddrw) && wbforw_valid)
		sel_a = `OR1200_SEL_WB_FORW;
	else
		sel_a = `OR1200_SEL_RF;

//
// Generation of sel_b
//
always @(rf_addrw or sel_imm or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if (sel_imm)
		sel_b = `OR1200_SEL_IMM;
	else if ((id_insn[15:11] == rf_addrw) && rfwb_op[0])
		sel_b = `OR1200_SEL_EX_FORW;
	else if ((id_insn[15:11] == wb_rfaddrw) && wbforw_valid)
		sel_b = `OR1200_SEL_WB_FORW;
	else
		sel_b = `OR1200_SEL_RF;

//
// l.macrc in EX stage
//
`ifdef OR1200_MAC_IMPLEMENTED
always @(posedge clk or posedge rst) begin
	if (rst)
		ex_macrc_op <= #1 1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_macrc_op <= #1 1'b0;
	else if (!ex_freeze)
		ex_macrc_op <= #1 id_macrc_op;
end
`else
assign ex_macrc_op = 1'b0;
`endif

//
// Decode of spr_addrimm
//
always @(posedge clk or posedge rst) begin
	if (rst)
		spr_addrimm <= #1 16'h0000;
	else if (!ex_freeze & id_freeze | flushpipe)
		spr_addrimm <= #1 16'h0000;
	else if (!ex_freeze) begin
		case (id_insn[31:26])	// synopsys parallel_case
			// l.mfspr
			`OR1200_OR32_MFSPR: 
				spr_addrimm <= #1 id_insn[15:0];
			// l.mtspr
			default:
				spr_addrimm <= #1 {id_insn[25:21], id_insn[10:0]};
		endcase
	end
end

//
// Decode of multicycle
//
always @(id_insn) begin
  case (id_insn[31:26])		// synopsys parallel_case
`ifdef UNUSED
    // l.lwz
    `OR1200_OR32_LWZ:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.lbz
    `OR1200_OR32_LBZ:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.lbs
    `OR1200_OR32_LBS:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.lhz
    `OR1200_OR32_LHZ:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.lhs
    `OR1200_OR32_LHS:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.sw
    `OR1200_OR32_SW:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.sb
    `OR1200_OR32_SB:
      multicycle = `OR1200_TWO_CYCLES;
    
    // l.sh
    `OR1200_OR32_SH:
      multicycle = `OR1200_TWO_CYCLES;
`endif    
    // ALU instructions except the one with immediate
    `OR1200_OR32_ALU:
      multicycle = id_insn[`OR1200_ALUMCYC_POS];
    
    // Single cycle instructions
    default: begin
      multicycle = `OR1200_ONE_CYCLE;
    end
    
  endcase
  
end

//
// Decode of imm_signextend
//
always @(id_insn) begin
  case (id_insn[31:26])		// synopsys parallel_case

	// l.addi
	`OR1200_OR32_ADDI:
		imm_signextend = 1'b1;

	// l.addic
	`OR1200_OR32_ADDIC:
		imm_signextend = 1'b1;

	// l.xori
	`OR1200_OR32_XORI:
		imm_signextend = 1'b1;

	// l.muli
`ifdef OR1200_MULT_IMPLEMENTED
	`OR1200_OR32_MULI:
		imm_signextend = 1'b1;
`endif

	// l.maci
`ifdef OR1200_MAC_IMPLEMENTED
	`OR1200_OR32_MACI:
		imm_signextend = 1'b1;
`endif

	// SFXX insns with immediate
	`OR1200_OR32_SFXXI:
		imm_signextend = 1'b1;

	// Instructions with no or zero extended immediate
	default: begin
		imm_signextend = 1'b0;
	end

endcase

end

//
// LSU addr offset
//
always @(lsu_op or ex_insn) begin
	lsu_addrofs[10:0] = ex_insn[10:0];
	case(lsu_op)	// synopsys parallel_case
		`OR1200_LSUOP_SW, `OR1200_LSUOP_SH, `OR1200_LSUOP_SB : 
			lsu_addrofs[31:11] = {{16{ex_insn[25]}}, ex_insn[25:21]};
		default : 
			lsu_addrofs[31:11] = {{16{ex_insn[15]}}, ex_insn[15:11]};
	endcase
end

//
// Register file write address
//
always @(posedge clk or posedge rst) begin
	if (rst)
		rf_addrw <= #1 5'd0;
	else if (!ex_freeze & id_freeze)
		rf_addrw <= #1 5'd00;
	else if (!ex_freeze)
		case (pre_branch_op)	// synopsys parallel_case
			`OR1200_BRANCHOP_JR, `OR1200_BRANCHOP_BAL:
				rf_addrw <= #1 5'd09;	// link register r9
			default:
				rf_addrw <= #1 id_insn[25:21];
		endcase
end

//
// rf_addrw in wb stage (used in forwarding logic)
//
always @(posedge clk or posedge rst) begin
	if (rst)
		wb_rfaddrw <= #1 5'd0;
	else if (!wb_freeze)
		wb_rfaddrw <= #1 rf_addrw;
end

//
// Instruction latch in id_insn
//
always @(posedge clk or posedge rst) begin
	if (rst)
		id_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};
        else if (flushpipe)
                id_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};        // id_insn[16] must be 1
	else if (!id_freeze) begin
		id_insn <= #1 if_insn;
`ifdef OR1200_VERBOSE
// synopsys translate_off
		$display("%t: id_insn <= %h", $time, if_insn);
// synopsys translate_on
`endif
	end
end

//
// Instruction latch in ex_insn
//
always @(posedge clk or posedge rst) begin
	if (rst)
		ex_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};	// ex_insn[16] must be 1
	else if (!ex_freeze) begin
		ex_insn <= #1 id_insn;
`ifdef OR1200_VERBOSE
// synopsys translate_off
		$display("%t: ex_insn <= %h", $time, id_insn);
// synopsys translate_on
`endif
	end
end

//
// Instruction latch in wb_insn
//
always @(posedge clk or posedge rst) begin
	if (rst)
		wb_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};
	else if (flushpipe)
		wb_insn <= #1 {`OR1200_OR32_NOP, 26'h041_0000};	// wb_insn[16] must be 1
	else if (!wb_freeze) begin
		wb_insn <= #1 ex_insn;
	end
end

//
// Decode of sel_imm
//
always @(posedge clk or posedge rst) begin
	if (rst)
		sel_imm <= #1 1'b0;
	else if (!id_freeze) begin
	  case (if_insn[31:26])		// synopsys parallel_case

	    // j.jalr
	    `OR1200_OR32_JALR:
	      sel_imm <= #1 1'b0;
	    
	    // l.jr
	    `OR1200_OR32_JR:
	      sel_imm <= #1 1'b0;
	    
	    // l.rfe
	    `OR1200_OR32_RFE:
	      sel_imm <= #1 1'b0;
	    
	    // l.mfspr
	    `OR1200_OR32_MFSPR:
	      sel_imm <= #1 1'b0;
	    
	    // l.mtspr
	    `OR1200_OR32_MTSPR:
	      sel_imm <= #1 1'b0;
	    
	    // l.sys, l.brk and all three sync insns
	    `OR1200_OR32_XSYNC:
	      sel_imm <= #1 1'b0;
	    
	    // l.mac/l.msb
`ifdef OR1200_MAC_IMPLEMENTED
	    `OR1200_OR32_MACMSB:
	      sel_imm <= #1 1'b0;
`endif

	    // l.sw
	    `OR1200_OR32_SW:
	      sel_imm <= #1 1'b0;
	    
	    // l.sb
	    `OR1200_OR32_SB:
	      sel_imm <= #1 1'b0;
	    
	    // l.sh
	    `OR1200_OR32_SH:
	      sel_imm <= #1 1'b0;
	    
	    // ALU instructions except the one with immediate
	    `OR1200_OR32_ALU:
	      sel_imm <= #1 1'b0;
	    
	    // SFXX instructions
	    `OR1200_OR32_SFXX:
	      sel_imm <= #1 1'b0;

`ifdef OR1200_OR32_CUST5
	    // l.cust5 instructions
	    `OR1200_OR32_CUST5:
	      sel_imm <= #1 1'b0;
`endif
	    
	    // l.nop
	    `OR1200_OR32_NOP:
	      sel_imm <= #1 1'b0;

	    // All instructions with immediates
	    default: begin
	      sel_imm <= #1 1'b1;
	    end
	    
	  endcase
	  
	end
end

//
// Decode of except_illegal
//
always @(posedge clk or posedge rst) begin
	if (rst)
		except_illegal <= #1 1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		except_illegal <= #1 1'b0;
	else if (!ex_freeze) begin
	  case (id_insn[31:26])		// synopsys parallel_case

	    `OR1200_OR32_J,
	    `OR1200_OR32_JAL,
	    `OR1200_OR32_JALR,
	    `OR1200_OR32_JR,
	    `OR1200_OR32_BNF,
	    `OR1200_OR32_BF,
	    `OR1200_OR32_RFE,
	    `OR1200_OR32_MOVHI,
	    `OR1200_OR32_MFSPR,
	    `OR1200_OR32_XSYNC,
`ifdef OR1200_MAC_IMPLEMENTED
	    `OR1200_OR32_MACI,
`endif
	    `OR1200_OR32_LWZ,
	    `OR1200_OR32_LBZ,
	    `OR1200_OR32_LBS,
	    `OR1200_OR32_LHZ,
	    `OR1200_OR32_LHS,
	    `OR1200_OR32_ADDI,
	    `OR1200_OR32_ADDIC,
	    `OR1200_OR32_ANDI,
	    `OR1200_OR32_ORI,
	    `OR1200_OR32_XORI,
`ifdef OR1200_MULT_IMPLEMENTED
	    `OR1200_OR32_MULI,
`endif
	    `OR1200_OR32_SH_ROTI,
	    `OR1200_OR32_SFXXI,
	    `OR1200_OR32_MTSPR,
`ifdef OR1200_MAC_IMPLEMENTED
	    `OR1200_OR32_MACMSB,
`endif
	    `OR1200_OR32_SW,
	    `OR1200_OR32_SB,
	    `OR1200_OR32_SH,
	    `OR1200_OR32_ALU,
	    `OR1200_OR32_SFXX,
`ifdef OR1200_OR32_CUST5
	    `OR1200_OR32_CUST5,
`endif
	    `OR1200_OR32_NOP:
		except_illegal <= #1 1'b0;

	    // Illegal and OR1200 unsupported instructions
	    default:
	      except_illegal <= #1 1'b1;

	  endcase
	  
	end
end

//
// Decode of alu_op
//
always @(posedge clk or posedge rst) begin
	if (rst)
		alu_op <= #1 `OR1200_ALUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		alu_op <= #1 `OR1200_ALUOP_NOP;
	else if (!ex_freeze) begin
	  case (id_insn[31:26])		// synopsys parallel_case
	    
	    // l.j
	    `OR1200_OR32_J:
	      alu_op <= #1 `OR1200_ALUOP_IMM;
	    
	    // j.jal
	    `OR1200_OR32_JAL:
	      alu_op <= #1 `OR1200_ALUOP_IMM;
	    
	    // l.bnf
	    `OR1200_OR32_BNF:
	      alu_op <= #1 `OR1200_ALUOP_NOP;
	    
	    // l.bf
	    `OR1200_OR32_BF:
	      alu_op <= #1 `OR1200_ALUOP_NOP;
	    
	    // l.movhi
	    `OR1200_OR32_MOVHI:
	      alu_op <= #1 `OR1200_ALUOP_MOVHI;
	    
	    // l.mfspr
	    `OR1200_OR32_MFSPR:
	      alu_op <= #1 `OR1200_ALUOP_MFSR;
	    
	    // l.mtspr
	    `OR1200_OR32_MTSPR:
	      alu_op <= #1 `OR1200_ALUOP_MTSR;
	    
	    // l.addi
	    `OR1200_OR32_ADDI:
	      alu_op <= #1 `OR1200_ALUOP_ADD;
	    
	    // l.addic
	    `OR1200_OR32_ADDIC:
	      alu_op <= #1 `OR1200_ALUOP_ADDC;
	    
	    // l.andi
	    `OR1200_OR32_ANDI:
	      alu_op <= #1 `OR1200_ALUOP_AND;
	    
	    // l.ori
	    `OR1200_OR32_ORI:
	      alu_op <= #1 `OR1200_ALUOP_OR;
	    
	    // l.xori
	    `OR1200_OR32_XORI:
	      alu_op <= #1 `OR1200_ALUOP_XOR;
	    
	    // l.muli
`ifdef OR1200_MULT_IMPLEMENTED
	    `OR1200_OR32_MULI:
	      alu_op <= #1 `OR1200_ALUOP_MUL;
`endif
	    
	    // Shift and rotate insns with immediate
	    `OR1200_OR32_SH_ROTI:
	      alu_op <= #1 `OR1200_ALUOP_SHROT;
	    
	    // SFXX insns with immediate
	    `OR1200_OR32_SFXXI:
	      alu_op <= #1 `OR1200_ALUOP_COMP;
	    
	    // ALU instructions except the one with immediate
	    `OR1200_OR32_ALU:
	      alu_op <= #1 id_insn[3:0];
	    
	    // SFXX instructions
	    `OR1200_OR32_SFXX:
	      alu_op <= #1 `OR1200_ALUOP_COMP;

`ifdef OR1200_OR32_CUST5
	    // l.cust5 instructions
	    `OR1200_OR32_CUST5:
	      alu_op <= #1 `OR1200_ALUOP_CUST5;
`endif
	    
	    // Default
	    default: begin
	      alu_op <= #1 `OR1200_ALUOP_NOP;
	    end
	      
	  endcase
	  
	end
end

//
// Decode of mac_op
//
`ifdef OR1200_MAC_IMPLEMENTED
always @(posedge clk or posedge rst) begin
	if (rst)
		mac_op <= #1 `OR1200_MACOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		mac_op <= #1 `OR1200_MACOP_NOP;
	else if (!ex_freeze)
	  case (id_insn[31:26])		// synopsys parallel_case

	    // l.maci
	    `OR1200_OR32_MACI:
	      mac_op <= #1 `OR1200_MACOP_MAC;

	    // l.nop
	    `OR1200_OR32_MACMSB:
	      mac_op <= #1 id_insn[1:0];

	    // Illegal and OR1200 unsupported instructions
	    default: begin
	      mac_op <= #1 `OR1200_MACOP_NOP;
	    end	      

	  endcase
	else
		mac_op <= #1 `OR1200_MACOP_NOP;
end
`else
assign mac_op = `OR1200_MACOP_NOP;
`endif

//
// Decode of shrot_op
//
always @(posedge clk or posedge rst) begin
	if (rst)
		shrot_op <= #1 `OR1200_SHROTOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		shrot_op <= #1 `OR1200_SHROTOP_NOP;
	else if (!ex_freeze) begin
		shrot_op <= #1 id_insn[`OR1200_SHROTOP_POS];
	end
end

//
// Decode of rfwb_op
//
always @(posedge clk or posedge rst) begin
	if (rst)
		rfwb_op <= #1 `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze & id_freeze | flushpipe)
		rfwb_op <= #1 `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze) begin
		case (id_insn[31:26])		// synopsys parallel_case

		  // j.jal
		  `OR1200_OR32_JAL:
		    rfwb_op <= #1 `OR1200_RFWBOP_LR;
		  
		  // j.jalr
		  `OR1200_OR32_JALR:
		    rfwb_op <= #1 `OR1200_RFWBOP_LR;
		  
		  // l.movhi
		  `OR1200_OR32_MOVHI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.mfspr
		  `OR1200_OR32_MFSPR:
		    rfwb_op <= #1 `OR1200_RFWBOP_SPRS;
		  
		  // l.lwz
		  `OR1200_OR32_LWZ:
		    rfwb_op <= #1 `OR1200_RFWBOP_LSU;
		  
		  // l.lbz
		  `OR1200_OR32_LBZ:
		    rfwb_op <= #1 `OR1200_RFWBOP_LSU;
		  
		  // l.lbs
		  `OR1200_OR32_LBS:
		    rfwb_op <= #1 `OR1200_RFWBOP_LSU;
		  
		  // l.lhz
		  `OR1200_OR32_LHZ:
		    rfwb_op <= #1 `OR1200_RFWBOP_LSU;
		  
		  // l.lhs
		  `OR1200_OR32_LHS:
		    rfwb_op <= #1 `OR1200_RFWBOP_LSU;
		  
		  // l.addi
		  `OR1200_OR32_ADDI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.addic
		  `OR1200_OR32_ADDIC:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.andi
		  `OR1200_OR32_ANDI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.ori
		  `OR1200_OR32_ORI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.xori
		  `OR1200_OR32_XORI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // l.muli
`ifdef OR1200_MULT_IMPLEMENTED
		  `OR1200_OR32_MULI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
`endif
		  
		  // Shift and rotate insns with immediate
		  `OR1200_OR32_SH_ROTI:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
		  
		  // ALU instructions except the one with immediate
		  `OR1200_OR32_ALU:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;

`ifdef OR1200_OR32_CUST5
		  // l.cust5 instructions
		  `OR1200_OR32_CUST5:
		    rfwb_op <= #1 `OR1200_RFWBOP_ALU;
`endif

		  // Instructions w/o register-file write-back
		  default: begin
		    rfwb_op <= #1 `OR1200_RFWBOP_NOP;
		  end

		endcase
	end
end

//
// Decode of pre_branch_op
//
always @(posedge clk or posedge rst) begin
	if (rst)
		pre_branch_op <= #1 `OR1200_BRANCHOP_NOP;
	else if (flushpipe)
		pre_branch_op <= #1 `OR1200_BRANCHOP_NOP;
	else if (!id_freeze) begin
		case (if_insn[31:26])		// synopsys parallel_case
		  
		  // l.j
		  `OR1200_OR32_J:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_BAL;
		  
		  // j.jal
		  `OR1200_OR32_JAL:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_BAL;
		  
		  // j.jalr
		  `OR1200_OR32_JALR:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_JR;
		  
		  // l.jr
		  `OR1200_OR32_JR:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_JR;
		  
		  // l.bnf
		  `OR1200_OR32_BNF:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_BNF;
		  
		  // l.bf
		  `OR1200_OR32_BF:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_BF;
		  
		  // l.rfe
		  `OR1200_OR32_RFE:
		    pre_branch_op <= #1 `OR1200_BRANCHOP_RFE;
		  
		  // Non branch instructions
		  default: begin
		    pre_branch_op <= #1 `OR1200_BRANCHOP_NOP;
		  end
		endcase
	end
end

//
// Generation of branch_op
//
always @(posedge clk or posedge rst)
	if (rst)
		branch_op <= #1 `OR1200_BRANCHOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		branch_op <= #1 `OR1200_BRANCHOP_NOP;		
	else if (!ex_freeze)
		branch_op <= #1 pre_branch_op;

//
// Decode of lsu_op
//
always @(posedge clk or posedge rst) begin
	if (rst)
		lsu_op <= #1 `OR1200_LSUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		lsu_op <= #1 `OR1200_LSUOP_NOP;
	else if (!ex_freeze)  begin
	  case (id_insn[31:26])		// synopsys parallel_case
	    
	    // l.lwz
	    `OR1200_OR32_LWZ:
	      lsu_op <= #1 `OR1200_LSUOP_LWZ;
	    
	    // l.lbz
	    `OR1200_OR32_LBZ:
	      lsu_op <= #1 `OR1200_LSUOP_LBZ;
	    
	    // l.lbs
	    `OR1200_OR32_LBS:
	      lsu_op <= #1 `OR1200_LSUOP_LBS;
	    
	    // l.lhz
	    `OR1200_OR32_LHZ:
	      lsu_op <= #1 `OR1200_LSUOP_LHZ;
	    
	    // l.lhs
	    `OR1200_OR32_LHS:
	      lsu_op <= #1 `OR1200_LSUOP_LHS;
	    
	    // l.sw
	    `OR1200_OR32_SW:
	      lsu_op <= #1 `OR1200_LSUOP_SW;
	    
	    // l.sb
	    `OR1200_OR32_SB:
	      lsu_op <= #1 `OR1200_LSUOP_SB;
	    
	    // l.sh
	    `OR1200_OR32_SH:
	      lsu_op <= #1 `OR1200_LSUOP_SH;
	    
	    // Non load/store instructions
	    default: begin
	      lsu_op <= #1 `OR1200_LSUOP_NOP;
	    end
	  endcase
	end
end

//
// Decode of comp_op
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		comp_op <= #1 4'd0;
	end else if (!ex_freeze & id_freeze | flushpipe)
		comp_op <= #1 4'd0;
	else if (!ex_freeze)
		comp_op <= #1 id_insn[24:21];
end

//
// Decode of l.sys
//
always @(posedge clk or posedge rst) begin
	if (rst)
		sig_syscall <= #1 1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_syscall <= #1 1'b0;
	else if (!ex_freeze) begin
`ifdef OR1200_VERBOSE
// synopsys translate_off
		if (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b000})
			$display("Generating sig_syscall");
// synopsys translate_on
`endif
		sig_syscall <= #1 (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b000});
	end
end

//
// Decode of l.trap
//
always @(posedge clk or posedge rst) begin
	if (rst)
		sig_trap <= #1 1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_trap <= #1 1'b0;
	else if (!ex_freeze) begin
`ifdef OR1200_VERBOSE
// synopsys translate_off
		if (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b010})
			$display("Generating sig_trap");
// synopsys translate_on
`endif
		sig_trap <= #1 (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b010})
			| du_hwbkpt;
	end
end

endmodule
