//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's reg2mem aligner                                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Aligns register data to memory alignment.                   ////
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
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/19 23:28:46  lampret
// Fixed some synthesis warnings. Configured with caches and MMUs.
//
// Revision 1.7  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
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

module or1200_reg2mem_cm4(
		clk_i_cml_1,
		clk_i_cml_2,
		clk_i_cml_3,
		addr, lsu_op, regdata, memdata);


input clk_i_cml_1;
input clk_i_cml_2;
input clk_i_cml_3;
reg [ 1 : 0 ] addr_cml_3;
reg [ 4 - 1 : 0 ] lsu_op_cml_3;
reg [ 4 - 1 : 0 ] lsu_op_cml_2;
reg [ 4 - 1 : 0 ] lsu_op_cml_1;
reg [ 32 - 1 : 0 ] regdata_cml_3;
reg [ 32 - 1 : 0 ] regdata_cml_2;
reg [ 32 - 1 : 0 ] regdata_cml_1;



parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O
//
input	[1:0]			addr;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[width-1:0]		regdata;
output	[width-1:0]		memdata;

//
// Internal regs and wires
//
reg	[7:0]			memdata_hh;
reg	[7:0]			memdata_hl;
reg	[7:0]			memdata_lh;
reg	[7:0]			memdata_ll;

assign memdata = {memdata_hh, memdata_hl, memdata_lh, memdata_ll};

//
// Mux to memdata[31:24]
//

// SynEDA CoreMultiplier
// assignment(s): memdata_hh
// replace(s): addr, lsu_op, regdata
always @(lsu_op_cml_3 or addr_cml_3 or regdata_cml_3) begin
	casex({lsu_op_cml_3, addr_cml_3[1:0]})	// synopsys parallel_case
		{`OR1200_LSUOP_SB, 2'b00} : memdata_hh = regdata_cml_3[7:0];
		{`OR1200_LSUOP_SH, 2'b00} : memdata_hh = regdata_cml_3[15:8];
		default : memdata_hh = regdata_cml_3[31:24];
	endcase
end

//
// Mux to memdata[23:16]
//

// SynEDA CoreMultiplier
// assignment(s): memdata_hl
// replace(s): addr, lsu_op, regdata
always @(lsu_op_cml_3 or addr_cml_3 or regdata_cml_3) begin
	casex({lsu_op_cml_3, addr_cml_3[1:0]})	// synopsys parallel_case
		{`OR1200_LSUOP_SW, 2'b00} : memdata_hl = regdata_cml_3[23:16];
		default : memdata_hl = regdata_cml_3[7:0];
	endcase
end

//
// Mux to memdata[15:8]
//

// SynEDA CoreMultiplier
// assignment(s): memdata_lh
// replace(s): addr, lsu_op, regdata
always @(lsu_op_cml_3 or addr_cml_3 or regdata_cml_3) begin
	casex({lsu_op_cml_3, addr_cml_3[1:0]})	// synopsys parallel_case
		{`OR1200_LSUOP_SB, 2'b10} : memdata_lh = regdata_cml_3[7:0];
		default : memdata_lh = regdata_cml_3[15:8];
	endcase
end

//
// Mux to memdata[7:0]
//

// SynEDA CoreMultiplier
// assignment(s): memdata_ll
// replace(s): regdata
always @(regdata_cml_3)
	memdata_ll = regdata_cml_3[7:0];


always @ (posedge clk_i_cml_1) begin
lsu_op_cml_1 <= lsu_op;
regdata_cml_1 <= regdata;
end
always @ (posedge clk_i_cml_2) begin
lsu_op_cml_2 <= lsu_op_cml_1;
regdata_cml_2 <= regdata_cml_1;
end
always @ (posedge clk_i_cml_3) begin
addr_cml_3 <= addr;
lsu_op_cml_3 <= lsu_op_cml_2;
regdata_cml_3 <= regdata_cml_2;
end
endmodule

