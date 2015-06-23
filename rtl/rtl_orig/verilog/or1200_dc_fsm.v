//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's DC FSM                                             ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Data cache state machine                                    ////
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
// Revision 1.8  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.7.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.7  2002/03/29 15:16:55  lampret
// Some of the warnings fixed.
//
// Revision 1.6  2002/03/28 19:10:40  lampret
// Optimized cache controller FSM.
//
// Revision 1.1.1.1  2002/03/21 16:55:45  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.5  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.4  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.3  2002/01/28 01:15:59  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
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
// Revision 1.1.1.1  2001/10/06 10:18:35  igorm
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

`define OR1200_DCFSM_IDLE	3'd0
`define OR1200_DCFSM_CLOAD	3'd1
`define OR1200_DCFSM_LREFILL3	3'd2
`define OR1200_DCFSM_CSTORE	3'd3
`define OR1200_DCFSM_SREFILL4	3'd4

//
// Data cache FSM for cache line of 16 bytes (4x singleword)
//

module or1200_dc_fsm(
	// Clock and reset
	clk, rst,

	// Internal i/f to top level DC
	dc_en, dcqmem_cycstb_i, dcqmem_ci_i, dcqmem_we_i, dcqmem_sel_i,
	tagcomp_miss, biudata_valid, biudata_error, start_addr, saved_addr,
	dcram_we, biu_read, biu_write, first_hit_ack, first_miss_ack, first_miss_err,
	burst, tag_we, dc_addr
);

//
// I/O
//
input				clk;
input				rst;
input				dc_en;
input				dcqmem_cycstb_i;
input				dcqmem_ci_i;
input				dcqmem_we_i;
input	[3:0]			dcqmem_sel_i;
input				tagcomp_miss;
input				biudata_valid;
input				biudata_error;
input	[31:0]			start_addr;
output	[31:0]			saved_addr;
output	[3:0]			dcram_we;
output				biu_read;
output				biu_write;
output				first_hit_ack;
output				first_miss_ack;
output				first_miss_err;
output				burst;
output				tag_we;
output	[31:0]			dc_addr;

//
// Internal wires and regs
//
reg	[31:0]			saved_addr_r;
reg	[2:0]			state;
reg	[2:0]			cnt;
reg				hitmiss_eval;
reg				store;
reg				load;
reg				cache_inhibit;
wire				first_store_hit_ack;

//
// Generate of DCRAM write enables
//
assign dcram_we = {4{load & biudata_valid & !cache_inhibit}} | {4{first_store_hit_ack}} & dcqmem_sel_i;
assign tag_we = biu_read & biudata_valid & !cache_inhibit;

//
// BIU read and write
//
assign biu_read = (hitmiss_eval & tagcomp_miss) | (!hitmiss_eval & load);
assign biu_write = store;

assign dc_addr = (biu_read | biu_write) & !hitmiss_eval ? saved_addr : start_addr;
assign saved_addr = saved_addr_r;

//
// Assert for cache hit first word ready
// Assert for store cache hit first word ready
// Assert for cache miss first word stored/loaded OK
// Assert for cache miss first word stored/loaded with an error
//
assign first_hit_ack = (state == `OR1200_DCFSM_CLOAD) & !tagcomp_miss & !cache_inhibit & !dcqmem_ci_i | first_store_hit_ack;
assign first_store_hit_ack = (state == `OR1200_DCFSM_CSTORE) & !tagcomp_miss & biudata_valid & !cache_inhibit & !dcqmem_ci_i;
assign first_miss_ack = ((state == `OR1200_DCFSM_CLOAD) | (state == `OR1200_DCFSM_CSTORE)) & biudata_valid;
assign first_miss_err = ((state == `OR1200_DCFSM_CLOAD) | (state == `OR1200_DCFSM_CSTORE)) & biudata_error;

//
// Assert burst when doing reload of complete cache line
//
assign burst = (state == `OR1200_DCFSM_CLOAD) & tagcomp_miss & !cache_inhibit
		| (state == `OR1200_DCFSM_LREFILL3)
`ifdef OR1200_DC_STORE_REFILL
		| (state == `OR1200_DCFSM_SREFILL4)
`endif
		;

//
// Main DC FSM
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= #1 `OR1200_DCFSM_IDLE;
		saved_addr_r <= #1 32'b0;
		hitmiss_eval <= #1 1'b0;
		store <= #1 1'b0;
		load <= #1 1'b0;
		cnt <= #1 3'b000;
		cache_inhibit <= #1 1'b0;
	end
	else
	case (state)	// synopsys parallel_case
		`OR1200_DCFSM_IDLE :
			if (dc_en & dcqmem_cycstb_i & dcqmem_we_i) begin	// store
				state <= #1 `OR1200_DCFSM_CSTORE;
				saved_addr_r <= #1 start_addr;
				hitmiss_eval <= #1 1'b1;
				store <= #1 1'b1;
				load <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
			else if (dc_en & dcqmem_cycstb_i) begin		// load
				state <= #1 `OR1200_DCFSM_CLOAD;
				saved_addr_r <= #1 start_addr;
				hitmiss_eval <= #1 1'b1;
				store <= #1 1'b0;
				load <= #1 1'b1;
				cache_inhibit <= #1 1'b0;
			end
			else begin							// idle
				hitmiss_eval <= #1 1'b0;
				store <= #1 1'b0;
				load <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
		`OR1200_DCFSM_CLOAD: begin		// load
			if (dcqmem_cycstb_i & dcqmem_ci_i)
				cache_inhibit <= #1 1'b1;
			if (hitmiss_eval)
				saved_addr_r[31:13] <= #1 start_addr[31:13];
			if ((hitmiss_eval & !dcqmem_cycstb_i) ||					// load aborted (usually caused by DMMU)
			    (biudata_error) ||										// load terminated with an error
			    ((cache_inhibit | dcqmem_ci_i) & biudata_valid)) begin	// load from cache-inhibited area
				state <= #1 `OR1200_DCFSM_IDLE;
				hitmiss_eval <= #1 1'b0;
				load <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
			else if (tagcomp_miss & biudata_valid) begin	// load missed, finish current external load and refill
				state <= #1 `OR1200_DCFSM_LREFILL3;
				saved_addr_r[3:2] <= #1 saved_addr_r[3:2] + 1'd1;
				hitmiss_eval <= #1 1'b0;
				cnt <= #1 `OR1200_DCLS-2;
				cache_inhibit <= #1 1'b0;
			end
			else if (!tagcomp_miss & !dcqmem_ci_i) begin	// load hit, finish immediately
				state <= #1 `OR1200_DCFSM_IDLE;
				hitmiss_eval <= #1 1'b0;
				load <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
			else						// load in-progress
				hitmiss_eval <= #1 1'b0;
		end
		`OR1200_DCFSM_LREFILL3 : begin
			if (biudata_valid && (|cnt)) begin		// refill ack, more loads to come
				cnt <= #1 cnt - 3'd1;
				saved_addr_r[3:2] <= #1 saved_addr_r[3:2] + 1'd1;
			end
			else if (biudata_valid) begin			// last load of line refill
				state <= #1 `OR1200_DCFSM_IDLE;
				load <= #1 1'b0;
			end
		end
		`OR1200_DCFSM_CSTORE: begin		// store
			if (dcqmem_cycstb_i & dcqmem_ci_i)
				cache_inhibit <= #1 1'b1;
			if (hitmiss_eval)
				saved_addr_r[31:13] <= #1 start_addr[31:13];
			if ((hitmiss_eval & !dcqmem_cycstb_i) ||	// store aborted (usually caused by DMMU)
			    (biudata_error) ||						// store terminated with an error
			    ((cache_inhibit | dcqmem_ci_i) & biudata_valid)) begin	// store to cache-inhibited area
				state <= #1 `OR1200_DCFSM_IDLE;
				hitmiss_eval <= #1 1'b0;
				store <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
`ifdef OR1200_DC_STORE_REFILL
			else if (tagcomp_miss & biudata_valid) begin	// store missed, finish write-through and doq load refill
				state <= #1 `OR1200_DCFSM_SREFILL4;
				hitmiss_eval <= #1 1'b0;
				store <= #1 1'b0;
				load <= #1 1'b1;
				cnt <= #1 `OR1200_DCLS-1;
				cache_inhibit <= #1 1'b0;
			end
`endif
			else if (biudata_valid) begin			// store hit, finish write-through
				state <= #1 `OR1200_DCFSM_IDLE;
				hitmiss_eval <= #1 1'b0;
				store <= #1 1'b0;
				cache_inhibit <= #1 1'b0;
			end
			else						// store write-through in-progress
				hitmiss_eval <= #1 1'b0;
			end
`ifdef OR1200_DC_STORE_REFILL
		`OR1200_DCFSM_SREFILL4 : begin
			if (biudata_valid && (|cnt)) begin		// refill ack, more loads to come
				cnt <= #1 cnt - 1'd1;
				saved_addr_r[3:2] <= #1 saved_addr_r[3:2] + 1'd1;
			end
			else if (biudata_valid) begin			// last load of line refill
				state <= #1 `OR1200_DCFSM_IDLE;
				load <= #1 1'b0;
			end
		end
`endif
		default:
			state <= #1 `OR1200_DCFSM_IDLE;
	endcase
end

endmodule
