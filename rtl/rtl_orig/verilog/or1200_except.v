//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Exception logic                                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Handles all OR1K exceptions inside CPU block.               ////
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
// Revision 1.16  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.15.4.1  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.15  2003/04/20 22:23:57  lampret
// No functional change. Only added customization for exception vectors.
//
// Revision 1.14  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default and optionally (OR1200_CASE_DEFAULT) can be disabled to increase clock frequncy.
//
// Revision 1.13  2002/08/28 01:44:25  lampret
// Removed some commented RTL. Fixed SR/ESR flag bug.
//
// Revision 1.12  2002/08/22 02:16:45  lampret
// Fixed IMMU bug.
//
// Revision 1.11  2002/08/18 19:54:28  lampret
// Added store buffer.
//
// Revision 1.10  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.9  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.8  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.7  2002/01/23 07:52:36  lampret
// Changed default reset values for SR and ESR to match or1ksim's. Fixed flop model in or1200_dpram_32x32 when OR1200_XILINX_RAM32X1D is defined.
//
// Revision 1.6  2002/01/18 14:21:43  lampret
// Fixed 'the NPC single-step fix'.
//
// Revision 1.5  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.4  2002/01/14 21:11:50  lampret
// Changed alignment exception EPCR. Not tested yet.
//
// Revision 1.3  2002/01/14 19:09:57  lampret
// Fixed order of syscall and range exceptions.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.15  2001/11/27 23:13:11  lampret
// Fixed except_stop width and fixed EX PC for 1400444f no-ops.
//
// Revision 1.14  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.13  2001/11/20 18:46:15  simons
// Break point bug fixed
//
// Revision 1.12  2001/11/18 09:58:28  lampret
// Fixed some l.trap typos.
//
// Revision 1.11  2001/11/18 08:36:28  lampret
// For GDB changed single stepping and disabled trap exception.
//
// Revision 1.10  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
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

`define OR1200_EXCEPTFSM_WIDTH 3
`define OR1200_EXCEPTFSM_IDLE	`OR1200_EXCEPTFSM_WIDTH'd0
`define OR1200_EXCEPTFSM_FLU1 	`OR1200_EXCEPTFSM_WIDTH'd1
`define OR1200_EXCEPTFSM_FLU2 	`OR1200_EXCEPTFSM_WIDTH'd2
`define OR1200_EXCEPTFSM_FLU3 	`OR1200_EXCEPTFSM_WIDTH'd3
`define OR1200_EXCEPTFSM_FLU4 	`OR1200_EXCEPTFSM_WIDTH'd4
`define OR1200_EXCEPTFSM_FLU5 	`OR1200_EXCEPTFSM_WIDTH'd5

//
// Exception recognition and sequencing
//

module or1200_except(
	// Clock and reset
	clk, rst, 

	// Internal i/f
	sig_ibuserr, sig_dbuserr, sig_illegal, sig_align, sig_range, sig_dtlbmiss, sig_dmmufault,
	sig_int, sig_syscall, sig_trap, sig_itlbmiss, sig_immufault, sig_tick,
	branch_taken, genpc_freeze, id_freeze, ex_freeze, wb_freeze, if_stall,
	if_pc, id_pc, lr_sav, flushpipe, extend_flush, except_type, except_start,
	except_started, except_stop, ex_void,
	spr_dat_ppc, spr_dat_npc, datain, du_dsr, epcr_we, eear_we, esr_we, pc_we, epcr, eear,
	esr, sr_we, to_sr, sr, lsu_addr, abort_ex, icpu_ack_i, icpu_err_i, dcpu_ack_i, dcpu_err_i
);

//
// I/O
//
input				clk;
input				rst;
input				sig_ibuserr;
input				sig_dbuserr;
input				sig_illegal;
input				sig_align;
input				sig_range;
input				sig_dtlbmiss;
input				sig_dmmufault;
input				sig_int;
input				sig_syscall;
input				sig_trap;
input				sig_itlbmiss;
input				sig_immufault;
input				sig_tick;
input				branch_taken;
input				genpc_freeze;
input				id_freeze;
input				ex_freeze;
input				wb_freeze;
input				if_stall;
input	[31:0]			if_pc;
output	[31:0]			id_pc;
output	[31:2]			lr_sav;
input	[31:0]			datain;
input   [`OR1200_DU_DSR_WIDTH-1:0]     du_dsr;
input				epcr_we;
input				eear_we;
input				esr_we;
input				pc_we;
output	[31:0]			epcr;
output	[31:0]			eear;
output	[`OR1200_SR_WIDTH-1:0]	esr;
input	[`OR1200_SR_WIDTH-1:0]	to_sr;
input				sr_we;
input	[`OR1200_SR_WIDTH-1:0]	sr;
input	[31:0]			lsu_addr;
output				flushpipe;
output				extend_flush;
output	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
output				except_start;
output				except_started;
output	[12:0]			except_stop;
input				ex_void;
output	[31:0]			spr_dat_ppc;
output	[31:0]			spr_dat_npc;
output				abort_ex;
input				icpu_ack_i;
input				icpu_err_i;
input				dcpu_ack_i;
input				dcpu_err_i;

//
// Internal regs and wires
//
reg	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
reg	[31:0]			id_pc;
reg	[31:0]			ex_pc;
reg	[31:0]			wb_pc;
reg	[31:0]			epcr;
reg	[31:0]			eear;
reg	[`OR1200_SR_WIDTH-1:0]		esr;
reg	[2:0]			id_exceptflags;
reg	[2:0]			ex_exceptflags;
reg	[`OR1200_EXCEPTFSM_WIDTH-1:0]	state;
reg				extend_flush;
reg				extend_flush_last;
reg				ex_dslot;
reg				delayed1_ex_dslot;
reg				delayed2_ex_dslot;
wire				except_started;
wire	[12:0]			except_trig;
wire				except_flushpipe;
reg	[2:0]			delayed_iee;
reg	[2:0]			delayed_tee;
wire				int_pending;
wire				tick_pending;

//
// Simple combinatorial logic
//
assign except_started = extend_flush & except_start;
assign lr_sav = ex_pc[31:2];
assign spr_dat_ppc = wb_pc;
assign spr_dat_npc = ex_void ? id_pc : ex_pc;
assign except_start = (except_type != `OR1200_EXCEPT_NONE) & extend_flush;
assign int_pending = sig_int & sr[`OR1200_SR_IEE] & delayed_iee[2] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign tick_pending = sig_tick & sr[`OR1200_SR_TEE] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign abort_ex = sig_dbuserr | sig_dmmufault | sig_dtlbmiss | sig_align | sig_illegal;		// Abort write into RF by load & other instructions

//
// Order defines exception detection priority
//
assign except_trig = {
			tick_pending		& ~du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& ~du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& ~du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& ~du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& ~du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& ~du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& ~du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& ~du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& ~du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& ~du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& ~du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};
assign except_stop = {
			tick_pending		& du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};

//
// PC and Exception flags pipelines
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		id_pc <= #1 32'd0;
		id_exceptflags <= #1 3'b000;
	end
	else if (flushpipe) begin
		id_pc <= #1 32'h0000_0000;
		id_exceptflags <= #1 3'b000;
	end
	else if (!id_freeze) begin
		id_pc <= #1 if_pc;
		id_exceptflags <= #1 { sig_ibuserr, sig_itlbmiss, sig_immufault };
	end
end

//
// delayed_iee
//
// SR[IEE] should not enable interrupts right away
// when it is restored with l.rfe. Instead delayed_iee
// together with SR[IEE] enables interrupts once
// pipeline is again ready.
//
always @(posedge rst or posedge clk)
	if (rst)
		delayed_iee <= #1 3'b000;
	else if (!sr[`OR1200_SR_IEE])
		delayed_iee <= #1 3'b000;
	else
		delayed_iee <= #1 {delayed_iee[1:0], 1'b1};

//
// delayed_tee
//
// SR[TEE] should not enable tick exceptions right away
// when it is restored with l.rfe. Instead delayed_tee
// together with SR[TEE] enables tick exceptions once
// pipeline is again ready.
//
always @(posedge rst or posedge clk)
	if (rst)
		delayed_tee <= #1 3'b000;
	else if (!sr[`OR1200_SR_TEE])
		delayed_tee <= #1 3'b000;
	else
		delayed_tee <= #1 {delayed_tee[1:0], 1'b1};

//
// PC and Exception flags pipelines
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		ex_dslot <= #1 1'b0;
		ex_pc <= #1 32'd0;
		ex_exceptflags <= #1 3'b000;
		delayed1_ex_dslot <= #1 1'b0;
		delayed2_ex_dslot <= #1 1'b0;
	end
	else if (flushpipe) begin
		ex_dslot <= #1 1'b0;
		ex_pc <= #1 32'h0000_0000;
		ex_exceptflags <= #1 3'b000;
		delayed1_ex_dslot <= #1 1'b0;
		delayed2_ex_dslot <= #1 1'b0;
	end
	else if (!ex_freeze & id_freeze) begin
		ex_dslot <= #1 1'b0;
		ex_pc <= #1 id_pc;
		ex_exceptflags <= #1 3'b000;
		delayed1_ex_dslot <= #1 ex_dslot;
		delayed2_ex_dslot <= #1 delayed1_ex_dslot;
	end
	else if (!ex_freeze) begin
		ex_dslot <= #1 branch_taken;
		ex_pc <= #1 id_pc;
		ex_exceptflags <= #1 id_exceptflags;
		delayed1_ex_dslot <= #1 ex_dslot;
		delayed2_ex_dslot <= #1 delayed1_ex_dslot;
	end
end

//
// PC and Exception flags pipelines
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wb_pc <= #1 32'd0;
	end
	else if (!wb_freeze) begin
		wb_pc <= #1 ex_pc;
	end
end

//
// Flush pipeline
//
assign flushpipe = except_flushpipe | pc_we | extend_flush;

//
// We have started execution of exception handler:
//  1. Asserted for 3 clock cycles
//  2. Don't execute any instruction that is still in pipeline and is not part of exception handler
//
assign except_flushpipe = |except_trig & ~|state;

//
// Exception FSM that sequences execution of exception handler
//
// except_type signals which exception handler we start fetching in:
//  1. Asserted in next clock cycle after exception is recognized
//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= #1 `OR1200_EXCEPTFSM_IDLE;
		except_type <= #1 `OR1200_EXCEPT_NONE;
		extend_flush <= #1 1'b0;
		epcr <= #1 32'b0;
		eear <= #1 32'b0;
		esr <= #1 {1'b1, {`OR1200_SR_WIDTH-2{1'b0}}, 1'b1};
		extend_flush_last <= #1 1'b0;
	end
	else begin
`ifdef OR1200_CASE_DEFAULT
		case (state)	// synopsys parallel_case
`else
		case (state)	// synopsys full_case parallel_case
`endif
			`OR1200_EXCEPTFSM_IDLE:
				if (except_flushpipe) begin
					state <= #1 `OR1200_EXCEPTFSM_FLU1;
					extend_flush <= #1 1'b1;
					esr <= #1 sr_we ? to_sr : sr;
					casex (except_trig)
`ifdef OR1200_EXCEPT_TICK
						13'b1_xxxx_xxxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_TICK;
							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
`ifdef OR1200_EXCEPT_INT
						13'b0_1xxx_xxxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_INT;
							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
`ifdef OR1200_EXCEPT_ITLBMISS
						13'b0_01xx_xxxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_ITLBMISS;
//
// itlb miss exception and active ex_dslot caused wb_pc to put into eear instead of +4 address of ex_pc (or id_pc since it was equal to ex_pc?)
//							eear <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
//	mmu-icdc-O2 ex_pc only OK when no ex_dslot	eear <= #1 ex_dslot ? ex_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
//	mmu-icdc-O2 ex_pc only OK when no ex_dslot	epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
							eear <= #1 ex_dslot ? ex_pc : ex_pc;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
//							eear <= #1 ex_dslot ? ex_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
//							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
`ifdef OR1200_EXCEPT_IPF
						13'b0_001x_xxxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_IPF;
//
// ipf exception and active ex_dslot caused wb_pc to put into eear instead of +4 address of ex_pc (or id_pc since it was equal to ex_pc?)
//							eear <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
							eear <= #1 ex_dslot ? ex_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
`ifdef OR1200_EXCEPT_BUSERR
						13'b0_0001_xxxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_BUSERR;
							eear <= #1 ex_dslot ? wb_pc : ex_pc;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_ILLEGAL
						13'b0_0000_1xxx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_ILLEGAL;
							eear <= #1 ex_pc;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_ALIGN
						13'b0_0000_01xx_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_ALIGN;
							eear <= #1 lsu_addr;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_DTLBMISS
						13'b0_0000_001x_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_DTLBMISS;
							eear <= #1 lsu_addr;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_DPF
						13'b0_0000_0001_xxxx: begin
							except_type <= #1 `OR1200_EXCEPT_DPF;
							eear <= #1 lsu_addr;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_BUSERR
						13'b0_0000_0000_1xxx: begin	// Data Bus Error
							except_type <= #1 `OR1200_EXCEPT_BUSERR;
							eear <= #1 lsu_addr;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_RANGE
						13'b0_0000_0000_01xx: begin
							except_type <= #1 `OR1200_EXCEPT_RANGE;
							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
`ifdef OR1200_EXCEPT_TRAP			13'b0_0000_0000_001x: begin
							except_type <= #1 `OR1200_EXCEPT_TRAP;
							epcr <= #1 ex_dslot ? wb_pc : ex_pc;
						end
`endif
`ifdef OR1200_EXCEPT_SYSCALL
						13'b0_0000_0000_0001: begin
							except_type <= #1 `OR1200_EXCEPT_SYSCALL;
							epcr <= #1 ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
						end
`endif
						default:
							except_type <= #1 `OR1200_EXCEPT_NONE;
					endcase
				end
				else if (pc_we) begin
					state <= #1 `OR1200_EXCEPTFSM_FLU1;
					extend_flush <= #1 1'b1;
				end
				else begin
					if (epcr_we)
						epcr <= #1 datain;
					if (eear_we)
						eear <= #1 datain;
					if (esr_we)
						esr <= #1 {1'b1, datain[`OR1200_SR_WIDTH-2:0]};
				end
			`OR1200_EXCEPTFSM_FLU1:
				if (icpu_ack_i | icpu_err_i | genpc_freeze)
					state <= #1 `OR1200_EXCEPTFSM_FLU2;
			`OR1200_EXCEPTFSM_FLU2:
`ifdef OR1200_EXCEPT_TRAP
			        if (except_type == `OR1200_EXCEPT_TRAP) begin
					state <= #1 `OR1200_EXCEPTFSM_IDLE;
					extend_flush <= #1 1'b0;
					extend_flush_last <= #1 1'b0;
					except_type <= #1 `OR1200_EXCEPT_NONE;
				end
                        	else
`endif
					state <= #1 `OR1200_EXCEPTFSM_FLU3;
			`OR1200_EXCEPTFSM_FLU3:
					begin
						state <= #1 `OR1200_EXCEPTFSM_FLU4;
					end
			`OR1200_EXCEPTFSM_FLU4: begin
					state <= #1 `OR1200_EXCEPTFSM_FLU5;
					extend_flush <= #1 1'b0;
					extend_flush_last <= #1 1'b0; // damjan
				end
`ifdef OR1200_CASE_DEFAULT
			default: 
`else
			`OR1200_EXCEPTFSM_FLU5: 
`endif
			begin	if (!if_stall && !id_freeze) begin
					state <= #1 `OR1200_EXCEPTFSM_IDLE;
					except_type <= #1 `OR1200_EXCEPT_NONE;
					extend_flush_last <= #1 1'b0;
				end
			end
		endcase
	end
end

endmodule
