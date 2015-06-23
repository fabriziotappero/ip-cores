//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Data Cache top level                               ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Instantiation of all DC blocks.                             ////
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
// Revision 1.6.4.2  2003/12/09 11:46:48  simons
// Mbist nameing changed, Artisan ram instance signal names fixed, some synthesis waning fixed.
//
// Revision 1.6.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.6  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.5  2002/08/18 19:54:47  lampret
// Added store buffer.
//
// Revision 1.4  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
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
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/14 13:12:09  lampret
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
// Revision 1.2  2001/07/22 03:31:53  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

//
// Data cache
//
module or1200_dc_top(
	// Rst, clk and clock control
	clk, rst,

	// External i/f
	dcsb_dat_o, dcsb_adr_o, dcsb_cyc_o, dcsb_stb_o, dcsb_we_o, dcsb_sel_o, dcsb_cab_o,
	dcsb_dat_i, dcsb_ack_i, dcsb_err_i,

	// Internal i/f
	dc_en,
	dcqmem_adr_i, dcqmem_cycstb_i, dcqmem_ci_i,
	dcqmem_we_i, dcqmem_sel_i, dcqmem_tag_i, dcqmem_dat_i,
	dcqmem_dat_o, dcqmem_ack_o, dcqmem_rty_o, dcqmem_err_o, dcqmem_tag_o,

`ifdef OR1200_BIST
	// RAM BIST
	mbist_si_i, mbist_so_o, mbist_ctrl_i,
`endif

	// SPRs
	spr_cs, spr_write, spr_dat_i
);

parameter dw = `OR1200_OPERAND_WIDTH;

//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// External I/F
//
output	[dw-1:0]		dcsb_dat_o;
output	[31:0]			dcsb_adr_o;
output				dcsb_cyc_o;
output				dcsb_stb_o;
output				dcsb_we_o;
output	[3:0]			dcsb_sel_o;
output				dcsb_cab_o;
input	[dw-1:0]		dcsb_dat_i;
input				dcsb_ack_i;
input				dcsb_err_i;

//
// Internal I/F
//
input				dc_en;
input	[31:0]			dcqmem_adr_i;
input				dcqmem_cycstb_i;
input				dcqmem_ci_i;
input				dcqmem_we_i;
input	[3:0]			dcqmem_sel_i;
input	[3:0]			dcqmem_tag_i;
input	[dw-1:0]		dcqmem_dat_i;
output	[dw-1:0]		dcqmem_dat_o;
output				dcqmem_ack_o;
output				dcqmem_rty_o;
output				dcqmem_err_o;
output	[3:0]			dcqmem_tag_o;

`ifdef OR1200_BIST
//
// RAM BIST
//
input mbist_si_i;
input [`OR1200_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;
output mbist_so_o;
`endif

//
// SPR access
//
input				spr_cs;
input				spr_write;
input	[31:0]			spr_dat_i;

//
// Internal wires and regs
//
wire				tag_v;
wire	[`OR1200_DCTAG_W-2:0]	tag;
wire	[dw-1:0]		to_dcram;
wire	[dw-1:0]		from_dcram;
wire	[31:0]			saved_addr;
wire	[3:0]			dcram_we;
wire				dctag_we;
wire	[31:0]			dc_addr;
wire				dcfsm_biu_read;
wire				dcfsm_biu_write;
reg				tagcomp_miss;
wire	[`OR1200_DCINDXH:`OR1200_DCLS]	dctag_addr;
wire				dctag_en;
wire				dctag_v; 
wire				dc_inv;
wire				dcfsm_first_hit_ack;
wire				dcfsm_first_miss_ack;
wire				dcfsm_first_miss_err;
wire				dcfsm_burst;
wire				dcfsm_tag_we;
`ifdef OR1200_BIST
//
// RAM BIST
//
wire				mbist_ram_so;
wire				mbist_tag_so;
wire				mbist_ram_si = mbist_si_i;
wire				mbist_tag_si = mbist_ram_so;
assign				mbist_so_o = mbist_tag_so;
`endif

//
// Simple assignments
//
assign dcsb_adr_o = dc_addr;
assign dc_inv = spr_cs & spr_write;
assign dctag_we = dcfsm_tag_we | dc_inv;
assign dctag_addr = dc_inv ? spr_dat_i[`OR1200_DCINDXH:`OR1200_DCLS] : dc_addr[`OR1200_DCINDXH:`OR1200_DCLS];
assign dctag_en = dc_inv | dc_en;
assign dctag_v = ~dc_inv;

//
// Data to BIU is from DCRAM when DC is enabled or from LSU when
// DC is disabled
//
assign dcsb_dat_o = dcqmem_dat_i;

//
// Bypases of the DC when DC is disabled
//
assign dcsb_cyc_o = (dc_en) ? dcfsm_biu_read | dcfsm_biu_write : dcqmem_cycstb_i;
assign dcsb_stb_o = (dc_en) ? dcfsm_biu_read | dcfsm_biu_write : dcqmem_cycstb_i;
assign dcsb_we_o = (dc_en) ? dcfsm_biu_write : dcqmem_we_i;
assign dcsb_sel_o = (dc_en & dcfsm_biu_read & !dcfsm_biu_write & !dcqmem_ci_i) ? 4'b1111 : dcqmem_sel_i;
assign dcsb_cab_o = (dc_en) ? dcfsm_burst : 1'b0;
assign dcqmem_rty_o = ~dcqmem_ack_o;
assign dcqmem_tag_o = dcqmem_err_o ? `OR1200_DTAG_BE : dcqmem_tag_i;

//
// DC/LSU normal and error termination
//
assign dcqmem_ack_o = dc_en ? dcfsm_first_hit_ack | dcfsm_first_miss_ack : dcsb_ack_i;
assign dcqmem_err_o = dc_en ? dcfsm_first_miss_err : dcsb_err_i;

//
// Select between claddr generated by DC FSM and addr[3:2] generated by LSU
//
//assign dc_addr = (dcfsm_biu_read | dcfsm_biu_write) ? saved_addr : dcqmem_adr_i;

//
// Select between input data generated by LSU or by BIU
//
assign to_dcram = (dcfsm_biu_read) ? dcsb_dat_i : dcqmem_dat_i;

//
// Select between data generated by DCRAM or passed by BIU
//
assign dcqmem_dat_o = dcfsm_first_miss_ack | !dc_en ? dcsb_dat_i : from_dcram;

//
// Tag comparison
//
always @(tag or saved_addr or tag_v) begin
	if ((tag != saved_addr[31:`OR1200_DCTAGL]) || !tag_v)
		tagcomp_miss = 1'b1;
	else
		tagcomp_miss = 1'b0;
end

//
// Instantiation of DC Finite State Machine
//
or1200_dc_fsm or1200_dc_fsm(
	.clk(clk),
	.rst(rst),
	.dc_en(dc_en),
	.dcqmem_cycstb_i(dcqmem_cycstb_i),
	.dcqmem_ci_i(dcqmem_ci_i),
	.dcqmem_we_i(dcqmem_we_i),
	.dcqmem_sel_i(dcqmem_sel_i),
	.tagcomp_miss(tagcomp_miss),
	.biudata_valid(dcsb_ack_i),
	.biudata_error(dcsb_err_i),
	.start_addr(dcqmem_adr_i),
	.saved_addr(saved_addr),
	.dcram_we(dcram_we),
	.biu_read(dcfsm_biu_read),
	.biu_write(dcfsm_biu_write),
	.first_hit_ack(dcfsm_first_hit_ack),
	.first_miss_ack(dcfsm_first_miss_ack),
	.first_miss_err(dcfsm_first_miss_err),
	.burst(dcfsm_burst),
	.tag_we(dcfsm_tag_we),
	.dc_addr(dc_addr)
);

//
// Instantiation of DC main memory
//
or1200_dc_ram or1200_dc_ram(
	.clk(clk),
	.rst(rst),
`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_ram_si),
	.mbist_so_o(mbist_ram_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.addr(dc_addr[`OR1200_DCINDXH:2]),
	.en(dc_en),
	.we(dcram_we),
	.datain(to_dcram),
	.dataout(from_dcram)
);

//
// Instantiation of DC TAG memory
//
wire [31:`OR1200_DCTAGL - 1] dc_tag_datain;
assign dc_tag_datain = {dc_addr[31:`OR1200_DCTAGL], dctag_v};
or1200_dc_tag or1200_dc_tag(
	.clk(clk),
	.rst(rst),
`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_tag_si),
	.mbist_so_o(mbist_tag_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.addr(dctag_addr),
	.en(dctag_en),
	.we(dctag_we),
	.datain(dc_tag_datain),
	.tag_v(tag_v),
	.tag(tag)
);

endmodule
