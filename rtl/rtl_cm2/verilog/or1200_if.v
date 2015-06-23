//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's instruction fetch                                  ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  PC, instruction fetch, interface to IC.                     ////
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
// Revision 1.3  2002/03/29 15:16:56  lampret
// Some of the warnings fixed.
//
// Revision 1.2  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.10  2001/11/20 18:46:15  simons
// Break point bug fixed
//
// Revision 1.9  2001/11/18 09:58:28  lampret
// Fixed some l.trap typos.
//
// Revision 1.8  2001/11/18 08:36:28  lampret
// For GDB changed single stepping and disabled trap exception.
//
// Revision 1.7  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.6  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_if_cm2(
		clk_i_cml_1,
		
	// Clock and reset
	clk, rst,

	// External i/f to IC
	icpu_dat_i, icpu_ack_i, icpu_err_i, icpu_adr_i, icpu_tag_i,

	// Internal i/f
	if_freeze, if_insn, if_pc, flushpipe,
	if_stall, no_more_dslot, genpc_refetch, rfe,
	except_itlbmiss, except_immufault, except_ibuserr
);


input clk_i_cml_1;
reg  icpu_ack_i_cml_1;
reg [ 31 : 0 ] icpu_adr_i_cml_1;
reg  no_more_dslot_cml_1;
reg [ 31 : 0 ] insn_saved_cml_1;
reg [ 31 : 0 ] addr_saved_cml_1;
reg  saved_cml_1;



//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// External i/f to IC
//
input	[31:0]			icpu_dat_i;
input				icpu_ack_i;
input				icpu_err_i;
input	[31:0]			icpu_adr_i;
input	[3:0]			icpu_tag_i;

//
// Internal i/f
//
input				if_freeze;
output	[31:0]			if_insn;
output	[31:0]			if_pc;
input				flushpipe;
output				if_stall;
input				no_more_dslot;
output				genpc_refetch;
input				rfe;
output				except_itlbmiss;
output				except_immufault;
output				except_ibuserr;

//
// Internal wires and regs
//
reg	[31:0]			insn_saved;
reg	[31:0]			addr_saved;
reg				saved;

//
// IF stage insn
//

// SynEDA CoreMultiplier
// assignment(s): if_insn
// replace(s): icpu_ack_i, no_more_dslot, insn_saved, saved
assign if_insn = icpu_err_i | no_more_dslot_cml_1 | rfe ? {`OR1200_OR32_NOP, 26'h041_0000} : saved_cml_1 ? insn_saved_cml_1 : icpu_ack_i_cml_1 ? icpu_dat_i : {`OR1200_OR32_NOP, 26'h061_0000};
assign if_pc = saved ? addr_saved : icpu_adr_i;
// assign if_stall = !icpu_err_i & !icpu_ack_i & !saved & !no_more_dslot;

// SynEDA CoreMultiplier
// assignment(s): if_stall
// replace(s): icpu_ack_i, saved
assign if_stall = !icpu_err_i & !icpu_ack_i_cml_1 & !saved_cml_1;
assign genpc_refetch = saved & icpu_ack_i;

// SynEDA CoreMultiplier
// assignment(s): except_itlbmiss
// replace(s): no_more_dslot
assign except_itlbmiss = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_TE) & !no_more_dslot_cml_1;

// SynEDA CoreMultiplier
// assignment(s): except_immufault
// replace(s): no_more_dslot
assign except_immufault = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_PE) & !no_more_dslot_cml_1;

// SynEDA CoreMultiplier
// assignment(s): except_ibuserr
// replace(s): no_more_dslot
assign except_ibuserr = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_BE) & !no_more_dslot_cml_1;

//
// Flag for saved insn/address
//

// SynEDA CoreMultiplier
// assignment(s): saved
// replace(s): icpu_ack_i, saved
always @(posedge clk or posedge rst)
	if (rst)
		saved <= #1 1'b0;
	else begin  saved <= saved_cml_1; if (flushpipe)
		saved <= #1 1'b0;
	else if (icpu_ack_i_cml_1 & if_freeze & !saved_cml_1)
		saved <= #1 1'b1;
	else if (!if_freeze)
		saved <= #1 1'b0; end

//
// Store fetched instruction
//

// SynEDA CoreMultiplier
// assignment(s): insn_saved
// replace(s): icpu_ack_i, insn_saved, saved
always @(posedge clk or posedge rst)
	if (rst)
		insn_saved <= #1 {`OR1200_OR32_NOP, 26'h041_0000};
	else begin  insn_saved <= insn_saved_cml_1; if (flushpipe)
		insn_saved <= #1 {`OR1200_OR32_NOP, 26'h041_0000};
	else if (icpu_ack_i_cml_1 & if_freeze & !saved_cml_1)
		insn_saved <= #1 icpu_dat_i;
	else if (!if_freeze)
		insn_saved <= #1 {`OR1200_OR32_NOP, 26'h041_0000}; end

//
// Store fetched instruction's address
//

// SynEDA CoreMultiplier
// assignment(s): addr_saved
// replace(s): icpu_ack_i, icpu_adr_i, addr_saved, saved
always @(posedge clk or posedge rst)
	if (rst)
		addr_saved <= #1 32'h00000000;
	else begin  addr_saved <= addr_saved_cml_1; if (flushpipe)
		addr_saved <= #1 32'h00000000;
	else if (icpu_ack_i_cml_1 & if_freeze & !saved_cml_1)
		addr_saved <= #1 icpu_adr_i_cml_1;
	else if (!if_freeze)
		addr_saved <= #1 icpu_adr_i_cml_1; end


always @ (posedge clk_i_cml_1) begin
icpu_ack_i_cml_1 <= icpu_ack_i;
icpu_adr_i_cml_1 <= icpu_adr_i;
no_more_dslot_cml_1 <= no_more_dslot;
insn_saved_cml_1 <= insn_saved;
addr_saved_cml_1 <= addr_saved;
saved_cml_1 <= saved;
end
endmodule

