//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Data TLB                                           ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Instantiation of DTLB.                                      ////
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
// Revision 1.6  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.4.4.1  2003/12/09 11:46:48  simons
// Mbist nameing changed, Artisan ram instance signal names fixed, some synthesis waning fixed.
//
// Revision 1.4  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.3  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.2  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
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
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

//
// Data TLB
//

module or1200_dmmu_tlb_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
		cmls,
		
	// Rst and clk
	clk, rst,

	// I/F for translation
	tlb_en, vaddr, hit, ppn, uwe, ure, swe, sre, ci,

`ifdef OR1200_BIST
	// RAM BIST
	mbist_si_i, mbist_so_o, mbist_ctrl_i,
`endif

	// SPR access
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);


input clk_i_cml_1;
input clk_i_cml_2;
input [1:0] cmls;
reg [ 32 - 1 : 0 ] vaddr_cml_1;
reg  ci_cml_1;
reg  spr_cs_cml_2;
reg  spr_write_cml_2;
reg [ 31 : 0 ] spr_addr_cml_2;
reg [ 31 : 0 ] spr_addr_cml_1;
reg [ 31 : 0 ] spr_dat_i_cml_2;
reg [ 31 : 0 ] spr_dat_i_cml_1;
reg [ 6 - 1 : 0 ] tlb_index_cml_2;
reg [ 32 - 6 - 13 + 1 - 1 : 0 ] tlb_mr_ram_out_cml_1;
reg [ 32 - 13 + 5 - 1 : 0 ] tlb_tr_ram_out_cml_1;



parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_OPERAND_WIDTH;

//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// I/F for translation
//
input				tlb_en;
input	[aw-1:0]		vaddr;
output				hit;
output	[31:`OR1200_DMMU_PS]	ppn;
output				uwe;
output				ure;
output				swe;
output				sre;
output				ci;

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
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;

//
// Internal wires and regs
//
wire	[`OR1200_DTLB_TAG]	vpn;
wire				v;
wire	[`OR1200_DTLB_INDXW-1:0]	tlb_index;
wire				tlb_mr_en;
wire				tlb_mr_we;
wire	[`OR1200_DTLBMRW-1:0]	tlb_mr_ram_in;
wire	[`OR1200_DTLBMRW-1:0]	tlb_mr_ram_out;
wire				tlb_tr_en;
wire				tlb_tr_we;
wire	[`OR1200_DTLBTRW-1:0]	tlb_tr_ram_in;
wire	[`OR1200_DTLBTRW-1:0]	tlb_tr_ram_out;
`ifdef OR1200_BIST
//
// RAM BIST
//
wire				mbist_mr_so;
wire				mbist_tr_so;
wire				mbist_mr_si = mbist_si_i;
wire				mbist_tr_si = mbist_mr_so;
assign				mbist_so_o = mbist_tr_so;
`endif

//
// Implemented bits inside match and translate registers
//
// dtlbwYmrX: vpn 31-19  v 0
// dtlbwYtrX: ppn 31-13  swe 9  sre 8  uwe 7  ure 6
//
// dtlb memory width:
// 19 bits for ppn
// 13 bits for vpn
// 1 bit for valid
// 4 bits for protection
// 1 bit for cache inhibit

//
// Enable for Match registers
//

// SynEDA CoreMultiplier
// assignment(s): tlb_mr_en
// replace(s): spr_cs, spr_addr
assign tlb_mr_en = tlb_en | (spr_cs_cml_2 & !spr_addr_cml_2[`OR1200_DTLB_TM_ADDR]);

//
// Write enable for Match registers
//

// SynEDA CoreMultiplier
// assignment(s): tlb_mr_we
// replace(s): spr_cs, spr_write, spr_addr
assign tlb_mr_we = spr_cs_cml_2 & spr_write_cml_2 & !spr_addr_cml_2[`OR1200_DTLB_TM_ADDR];

//
// Enable for Translate registers
//

// SynEDA CoreMultiplier
// assignment(s): tlb_tr_en
// replace(s): spr_cs, spr_addr
assign tlb_tr_en = tlb_en | (spr_cs_cml_2 & spr_addr_cml_2[`OR1200_DTLB_TM_ADDR]);

//
// Write enable for Translate registers
//

// SynEDA CoreMultiplier
// assignment(s): tlb_tr_we
// replace(s): spr_cs, spr_write, spr_addr
assign tlb_tr_we = spr_cs_cml_2 & spr_write_cml_2 & spr_addr_cml_2[`OR1200_DTLB_TM_ADDR];

//
// Output to SPRS unit
//

// SynEDA CoreMultiplier
// assignment(s): spr_dat_o
// replace(s): ci, spr_addr
assign spr_dat_o = (spr_cs & !spr_write & !spr_addr_cml_1[`OR1200_DTLB_TM_ADDR]) ?
			{vpn, tlb_index & {`OR1200_DTLB_INDXW{v}}, {`OR1200_DTLB_TAGW-7{1'b0}}, 1'b0, 5'b00000, v} :
		(spr_cs & !spr_write & spr_addr_cml_1[`OR1200_DTLB_TM_ADDR]) ?
			{ppn, {`OR1200_DMMU_PS-10{1'b0}}, swe, sre, uwe, ure, {4{1'b0}}, ci_cml_1, 1'b0} :
			32'h00000000;

//
// Assign outputs from Match registers
//
//assign {vpn, v} = tlb_mr_ram_out;

// SynEDA CoreMultiplier
// assignment(s): vpn
// replace(s): tlb_mr_ram_out
assign vpn = tlb_mr_ram_out_cml_1[13:1];

// SynEDA CoreMultiplier
// assignment(s): v
// replace(s): tlb_mr_ram_out
assign v = tlb_mr_ram_out_cml_1[0];

//
// Assign to Match registers inputs
//

// SynEDA CoreMultiplier
// assignment(s): tlb_mr_ram_in
// replace(s): spr_dat_i
assign tlb_mr_ram_in = {spr_dat_i_cml_2[`OR1200_DTLB_TAG], spr_dat_i_cml_2[`OR1200_DTLBMR_V_BITS]};

//
// Assign outputs from Translate registers
//
//assign {ppn, swe, sre, uwe, ure, ci} = tlb_tr_ram_out;

// SynEDA CoreMultiplier
// assignment(s): ppn
// replace(s): tlb_tr_ram_out
assign ppn = tlb_tr_ram_out_cml_1[23:5];

// SynEDA CoreMultiplier
// assignment(s): swe
// replace(s): tlb_tr_ram_out
assign swe = tlb_tr_ram_out_cml_1[4];

// SynEDA CoreMultiplier
// assignment(s): sre
// replace(s): tlb_tr_ram_out
assign sre = tlb_tr_ram_out_cml_1[3];

// SynEDA CoreMultiplier
// assignment(s): uwe
// replace(s): tlb_tr_ram_out
assign uwe = tlb_tr_ram_out_cml_1[2];

// SynEDA CoreMultiplier
// assignment(s): ure
// replace(s): tlb_tr_ram_out
assign ure = tlb_tr_ram_out_cml_1[1];
assign ci = tlb_tr_ram_out[0];

//
// Assign to Translate registers inputs
//

// SynEDA CoreMultiplier
// assignment(s): tlb_tr_ram_in
// replace(s): spr_dat_i
assign tlb_tr_ram_in = {spr_dat_i_cml_2[31:`OR1200_DMMU_PS],
			spr_dat_i_cml_2[`OR1200_DTLBTR_SWE_BITS],
			spr_dat_i_cml_2[`OR1200_DTLBTR_SRE_BITS],
			spr_dat_i_cml_2[`OR1200_DTLBTR_UWE_BITS],
			spr_dat_i_cml_2[`OR1200_DTLBTR_URE_BITS],
			spr_dat_i_cml_2[`OR1200_DTLBTR_CI_BITS]};

//
// Generate hit
//

// SynEDA CoreMultiplier
// assignment(s): hit
// replace(s): vaddr
assign hit = (vpn == vaddr_cml_1[`OR1200_DTLB_TAG]) & v;

//
// TLB index is normally vaddr[18:13]. If it is SPR access then index is
// spr_addr[5:0].
//

// SynEDA CoreMultiplier
// assignment(s): tlb_index
// replace(s): vaddr, spr_addr
assign tlb_index = spr_cs ? spr_addr_cml_1[`OR1200_DTLB_INDXW-1:0] : vaddr_cml_1[`OR1200_DTLB_INDX];

`ifdef OR1200_RAM_MODELS_VIRTEX

//
//	Non-generic FPGA model instantiations
//

wire tlb_mr_en_wire;
wire [0 : 0] tlb_mr_we_wire;
wire [5 : 0] tlb_index_wire;
wire [13 : 0] tlb_mr_ram_in_wire;

assign tlb_mr_en_wire = tlb_mr_en;
assign tlb_mr_we_wire = tlb_mr_we;

// SynEDA CoreMultiplier
// assignment(s): tlb_index_wire
// replace(s): tlb_index
assign tlb_index_wire = tlb_index_cml_2;
assign tlb_mr_ram_in_wire = tlb_mr_ram_in;

dtlb_mr_sub_cm3 dtlb_ram (
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	.clka(clk),
	.ena(tlb_mr_en_wire),
	.wea(tlb_mr_we_wire), // Bus [0 : 0] 
	.addra(tlb_index_wire), // Bus [5 : 0] 
	.dina(tlb_mr_ram_in_wire), // Bus [13 : 0] 
	.clkb(clk),
	.addrb(tlb_index_wire),
	.doutb(tlb_mr_ram_out)); // Bus [13 : 0]

wire tlb_tr_en_wire;
wire [0 : 0] tlb_tr_we_wire;
wire [23 : 0] tlb_tr_ram_in_wire;

assign tlb_tr_en_wire = tlb_tr_en;
assign tlb_tr_we_wire = tlb_tr_we;
assign tlb_tr_ram_in_wire = tlb_tr_ram_in;

dtlb_tr_sub_cm3 dtlb_tr_ram (
		.clk_i_cml_1(clk_i_cml_1),
		.clk_i_cml_2(clk_i_cml_2),
		.cmls(cmls),
	.clka(clk),
	.ena(tlb_tr_en_wire),
	.wea(tlb_tr_we_wire), // Bus [0 : 0] 
	.addra(tlb_index_wire), // Bus [5 : 0] 
	.dina(tlb_tr_ram_in_wire), // Bus [23 : 0] 
	.clkb(clk),
	.addrb(tlb_index_wire),
	.doutb(tlb_tr_ram_out)); // Bus [23 : 0] 

`else

//
// Instantiation of DTLB Match Registers
//
or1200_spram_64x14 dtlb_mr_ram(
	.clk(clk),
	.rst(rst),
`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_mr_si),
	.mbist_so_o(mbist_mr_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.ce(tlb_mr_en),
	.we(tlb_mr_we),
	.oe(1'b1),
	.addr(tlb_index),
	.di(tlb_mr_ram_in),
	.doq(tlb_mr_ram_out)
);

//
// Instantiation of DTLB Translate Registers
//
or1200_spram_64x24 dtlb_tr_ram(
	.clk(clk),
	.rst(rst),
`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_tr_si),
	.mbist_so_o(mbist_tr_so),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.ce(tlb_tr_en),
	.we(tlb_tr_we),
	.oe(1'b1),
	.addr(tlb_index),
	.di(tlb_tr_ram_in),
	.doq(tlb_tr_ram_out)
);
`endif


always @ (posedge clk_i_cml_1) begin
vaddr_cml_1 <= vaddr;
ci_cml_1 <= ci;
spr_addr_cml_1 <= spr_addr;
spr_dat_i_cml_1 <= spr_dat_i;
tlb_mr_ram_out_cml_1 <= tlb_mr_ram_out;
tlb_tr_ram_out_cml_1 <= tlb_tr_ram_out;
end
always @ (posedge clk_i_cml_2) begin
spr_cs_cml_2 <= spr_cs;
spr_write_cml_2 <= spr_write;
spr_addr_cml_2 <= spr_addr_cml_1;
spr_dat_i_cml_2 <= spr_dat_i_cml_1;
tlb_index_cml_2 <= tlb_index;
end
endmodule

