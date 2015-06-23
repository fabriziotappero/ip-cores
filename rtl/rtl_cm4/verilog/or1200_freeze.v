//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Freeze logic                                       ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Generates all freezes and stalls inside RISC                ////
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
// Revision 1.7  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.6.4.2  2003/12/05 00:09:49  lampret
// No functional change.
//
// Revision 1.6.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.6  2002/07/31 02:04:35  lampret
// MAC now follows software convention (signed multiply instead of unsigned).
//
// Revision 1.5  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.4  2002/03/29 15:16:55  lampret
// Some of the warnings fixed.
//
// Revision 1.3  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.10  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/19 23:28:46  lampret
// Fixed some synthesis warnings. Configured with caches and MMUs.
//
// Revision 1.7  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
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

`define OR1200_NO_FREEZE	3'd0
`define OR1200_FREEZE_BYDC	3'd1
`define OR1200_FREEZE_BYMULTICYCLE	3'd2
`define OR1200_WAIT_LSU_TO_FINISH	3'd3
`define OR1200_WAIT_IC			3'd4

//
// Freeze logic (stalls CPU pipeline, ifetcher etc.)
//
module or1200_freeze_cm4(
		clk_i_cml_1,
		clk_i_cml_2,
		clk_i_cml_3,
		
	// Clock and reset
	clk, rst,

	// Internal i/f
	multicycle, flushpipe, extend_flush, lsu_stall, if_stall,
	lsu_unstall, du_stall, mac_stall, 
	force_dslot_fetch, abort_ex,
	genpc_freeze, if_freeze, id_freeze, ex_freeze, wb_freeze,
	icpu_ack_i, icpu_err_i
);


input clk_i_cml_1;
input clk_i_cml_2;
input clk_i_cml_3;
reg  extend_flush_cml_3;
reg  extend_flush_cml_2;
reg  extend_flush_cml_1;
reg  lsu_stall_cml_3;
reg  lsu_stall_cml_2;
reg  if_stall_cml_3;
reg  lsu_unstall_cml_3;
reg  lsu_unstall_cml_2;
reg  lsu_unstall_cml_1;
reg  abort_ex_cml_2;
reg  du_stall_cml_3;
reg  du_stall_cml_2;
reg  du_stall_cml_1;
reg  mac_stall_cml_3;
reg  mac_stall_cml_2;
reg  mac_stall_cml_1;
reg  ex_freeze_cml_3;
reg  icpu_ack_i_cml_3;
reg  icpu_ack_i_cml_2;
reg  icpu_err_i_cml_3;
reg  multicycle_freeze_cml_3;
reg  multicycle_freeze_cml_2;
reg [ 2 - 1 : 0 ] multicycle_cnt_cml_3;
reg [ 2 - 1 : 0 ] multicycle_cnt_cml_2;
reg [ 2 - 1 : 0 ] multicycle_cnt_cml_1;
reg  flushpipe_r_cml_3;
reg  flushpipe_r_cml_2;
reg  flushpipe_r_cml_1;



//
// I/O
//
input				clk;
input				rst;
input	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle;
input				flushpipe;
input				extend_flush;
input				lsu_stall;
input				if_stall;
input				lsu_unstall;
input				force_dslot_fetch;
input				abort_ex;
input				du_stall;
input				mac_stall;
output				genpc_freeze;
output				if_freeze;
output				id_freeze;
output				ex_freeze;
output				wb_freeze;
input				icpu_ack_i;
input				icpu_err_i;

//
// Internal wires and regs
//
wire				multicycle_freeze;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle_cnt;
reg				flushpipe_r;

//
// Pipeline freeze
//
// Rules how to create freeze signals:
// 1. Not overwriting pipeline stages:
// Freze signals at the beginning of pipeline (such as if_freeze) can be asserted more
// often than freeze signals at the of pipeline (such as wb_freeze). In other words, wb_freeze must never
// be asserted when ex_freeze is not. ex_freeze must never be asserted when id_freeze is not etc.
//
// 2. Inserting NOPs in the middle of pipeline only if supported:
// At this time, only ex_freeze (and wb_freeze) can be deassrted when id_freeze (and if_freeze) are asserted.
// This way NOP is asserted from stage ID into EX stage.
//
//assign genpc_freeze = du_stall | flushpipe_r | lsu_stall;

// SynEDA CoreMultiplier
// assignment(s): genpc_freeze
// replace(s): du_stall, flushpipe_r
assign genpc_freeze = du_stall_cml_3 | flushpipe_r_cml_3;

// SynEDA CoreMultiplier
// assignment(s): if_freeze
// replace(s): extend_flush
assign if_freeze = id_freeze | extend_flush_cml_3;
//assign id_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze | force_dslot_fetch) & ~flushpipe | du_stall;

// SynEDA CoreMultiplier
// assignment(s): id_freeze
// replace(s): lsu_stall, if_stall, lsu_unstall, du_stall, mac_stall, multicycle_freeze
assign id_freeze = (lsu_stall_cml_3 | (~lsu_unstall_cml_3 & if_stall_cml_3) | multicycle_freeze_cml_3 | force_dslot_fetch) | du_stall_cml_3 | mac_stall_cml_3;
assign ex_freeze = wb_freeze;
//assign wb_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze) & ~flushpipe | du_stall | mac_stall;

// SynEDA CoreMultiplier
// assignment(s): wb_freeze
// replace(s): lsu_stall, lsu_unstall, abort_ex, du_stall, mac_stall, multicycle_freeze
assign wb_freeze = (lsu_stall_cml_2 | (~lsu_unstall_cml_2 & if_stall) | multicycle_freeze_cml_2) | du_stall_cml_2 | mac_stall_cml_2 | abort_ex_cml_2;

//
// registered flushpipe
//

// SynEDA CoreMultiplier
// assignment(s): flushpipe_r
// replace(s): icpu_ack_i, icpu_err_i, flushpipe_r
always @(posedge clk or posedge rst)
	if (rst)
		flushpipe_r <= #1 1'b0;
	else begin  flushpipe_r <= flushpipe_r_cml_3; if (icpu_ack_i_cml_3 | icpu_err_i_cml_3)
//	else if (!if_stall)
		flushpipe_r <= #1 flushpipe;
	else if (!flushpipe)
		flushpipe_r <= #1 1'b0; end
		
//
// Multicycle freeze
//

// SynEDA CoreMultiplier
// assignment(s): multicycle_freeze
// replace(s): multicycle_cnt
assign multicycle_freeze = |multicycle_cnt_cml_1;

//
// Multicycle counter
//

// SynEDA CoreMultiplier
// assignment(s): multicycle_cnt
// replace(s): ex_freeze, multicycle_cnt
always @(posedge clk or posedge rst)
	if (rst)
		multicycle_cnt <= #1 2'b00;
	else begin  multicycle_cnt <= multicycle_cnt_cml_3; if (|multicycle_cnt_cml_3)
		multicycle_cnt <= #1 multicycle_cnt_cml_3 - 2'd1;
	else if (|multicycle & !ex_freeze_cml_3)
		multicycle_cnt <= #1 multicycle; end


always @ (posedge clk_i_cml_1) begin
extend_flush_cml_1 <= extend_flush;
lsu_unstall_cml_1 <= lsu_unstall;
du_stall_cml_1 <= du_stall;
mac_stall_cml_1 <= mac_stall;
multicycle_cnt_cml_1 <= multicycle_cnt;
flushpipe_r_cml_1 <= flushpipe_r;
end
always @ (posedge clk_i_cml_2) begin
extend_flush_cml_2 <= extend_flush_cml_1;
lsu_stall_cml_2 <= lsu_stall;
lsu_unstall_cml_2 <= lsu_unstall_cml_1;
abort_ex_cml_2 <= abort_ex;
du_stall_cml_2 <= du_stall_cml_1;
mac_stall_cml_2 <= mac_stall_cml_1;
icpu_ack_i_cml_2 <= icpu_ack_i;
multicycle_freeze_cml_2 <= multicycle_freeze;
multicycle_cnt_cml_2 <= multicycle_cnt_cml_1;
flushpipe_r_cml_2 <= flushpipe_r_cml_1;
end
always @ (posedge clk_i_cml_3) begin
extend_flush_cml_3 <= extend_flush_cml_2;
lsu_stall_cml_3 <= lsu_stall_cml_2;
if_stall_cml_3 <= if_stall;
lsu_unstall_cml_3 <= lsu_unstall_cml_2;
du_stall_cml_3 <= du_stall_cml_2;
mac_stall_cml_3 <= mac_stall_cml_2;
ex_freeze_cml_3 <= ex_freeze;
icpu_ack_i_cml_3 <= icpu_ack_i_cml_2;
icpu_err_i_cml_3 <= icpu_err_i;
multicycle_freeze_cml_3 <= multicycle_freeze_cml_2;
multicycle_cnt_cml_3 <= multicycle_cnt_cml_2;
flushpipe_r_cml_3 <= flushpipe_r_cml_2;
end
endmodule

