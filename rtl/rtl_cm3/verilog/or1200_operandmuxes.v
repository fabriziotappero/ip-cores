//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's register file read operands mux                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Mux for two register file read operands.                    ////
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
// Revision 1.9  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
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
// Revision 1.1  2001/07/20 00:46:05  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_operandmuxes_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
		
	// Clock and reset
	clk, rst,

	// Internal i/f
	id_freeze, ex_freeze, rf_dataa, rf_datab, ex_forw, wb_forw,
	simm, sel_a, sel_b, operand_a, operand_b, muxed_b
);


input clk_i_cml_1;
input clk_i_cml_2;
reg  ex_freeze_cml_2;
reg [ 32 - 1 : 0 ] ex_forw_cml_2;
reg [ 32 - 1 : 0 ] wb_forw_cml_2;
reg [ 32 - 1 : 0 ] wb_forw_cml_1;
reg [ 32 - 1 : 0 ] operand_a_cml_2;
reg [ 32 - 1 : 0 ] operand_a_cml_1;
reg [ 32 - 1 : 0 ] operand_b_cml_2;
reg [ 32 - 1 : 0 ] operand_b_cml_1;
reg  saved_a_cml_2;
reg  saved_a_cml_1;
reg  saved_b_cml_2;
reg  saved_b_cml_1;



parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O
//
input				clk;
input				rst;
input				id_freeze;
input				ex_freeze;
input	[width-1:0]		rf_dataa;
input	[width-1:0]		rf_datab;
input	[width-1:0]		ex_forw;
input	[width-1:0]		wb_forw;
input	[width-1:0]		simm;
input	[`OR1200_SEL_WIDTH-1:0]	sel_a;
input	[`OR1200_SEL_WIDTH-1:0]	sel_b;
output	[width-1:0]		operand_a;
output	[width-1:0]		operand_b;
output	[width-1:0]		muxed_b;

//
// Internal wires and regs
//
reg	[width-1:0]		operand_a;
reg	[width-1:0]		operand_b;
reg	[width-1:0]		muxed_a;
reg	[width-1:0]		muxed_b;
reg				saved_a;
reg				saved_b;

//
// Operand A register
//

// SynEDA CoreMultiplier
// assignment(s): operand_a, saved_a
// replace(s): ex_freeze, operand_a, saved_a
always @(posedge clk or posedge rst) begin
	if (rst) begin
		operand_a <= #1 32'd0;
		saved_a <= #1 1'b0;
	end else begin  saved_a <= saved_a_cml_2; operand_a <= operand_a_cml_2; if (!ex_freeze_cml_2 && id_freeze && !saved_a_cml_2) begin
		operand_a <= #1 muxed_a;
		saved_a <= #1 1'b1;
	end else if (!ex_freeze_cml_2 && !saved_a_cml_2) begin
		operand_a <= #1 muxed_a;
	end else if (!ex_freeze_cml_2 && !id_freeze)
		saved_a <= #1 1'b0; end
end

//
// Operand B register
//

// SynEDA CoreMultiplier
// assignment(s): operand_b, saved_b
// replace(s): ex_freeze, operand_b, saved_b
always @(posedge clk or posedge rst) begin
	if (rst) begin
		operand_b <= #1 32'd0;
		saved_b <= #1 1'b0;
	end else begin  saved_b <= saved_b_cml_2; operand_b <= operand_b_cml_2; if (!ex_freeze_cml_2 && id_freeze && !saved_b_cml_2) begin
		operand_b <= #1 muxed_b;
		saved_b <= #1 1'b1;
	end else if (!ex_freeze_cml_2 && !saved_b_cml_2) begin
		operand_b <= #1 muxed_b;
	end else if (!ex_freeze_cml_2 && !id_freeze)
		saved_b <= #1 1'b0; end
end

//
// Forwarding logic for operand A register
//

// SynEDA CoreMultiplier
// assignment(s): muxed_a
// replace(s): ex_forw, wb_forw
always @(ex_forw_cml_2 or wb_forw_cml_2 or rf_dataa or sel_a) begin
`ifdef OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES
	casex (sel_a)	// synopsys parallel_case infer_mux
`else
	casex (sel_a)	// synopsys parallel_case
`endif
		`OR1200_SEL_EX_FORW:
			muxed_a = ex_forw_cml_2;
		`OR1200_SEL_WB_FORW:
			muxed_a = wb_forw_cml_2;
		default:
			muxed_a = rf_dataa;
	endcase
end

//
// Forwarding logic for operand B register
//

// SynEDA CoreMultiplier
// assignment(s): muxed_b
// replace(s): ex_forw, wb_forw
always @(simm or ex_forw_cml_2 or wb_forw_cml_2 or rf_datab or sel_b) begin
`ifdef OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES
	casex (sel_b)	// synopsys parallel_case infer_mux
`else
	casex (sel_b)	// synopsys parallel_case
`endif
		`OR1200_SEL_IMM:
			muxed_b = simm;
		`OR1200_SEL_EX_FORW:
			muxed_b = ex_forw_cml_2;
		`OR1200_SEL_WB_FORW:
			muxed_b = wb_forw_cml_2;
		default:
			muxed_b = rf_datab;
	endcase
end


always @ (posedge clk_i_cml_1) begin
wb_forw_cml_1 <= wb_forw;
operand_a_cml_1 <= operand_a;
operand_b_cml_1 <= operand_b;
saved_a_cml_1 <= saved_a;
saved_b_cml_1 <= saved_b;
end
always @ (posedge clk_i_cml_2) begin
ex_freeze_cml_2 <= ex_freeze;
ex_forw_cml_2 <= ex_forw;
wb_forw_cml_2 <= wb_forw_cml_1;
operand_a_cml_2 <= operand_a_cml_1;
operand_b_cml_2 <= operand_b_cml_1;
saved_a_cml_2 <= saved_a_cml_1;
saved_b_cml_2 <= saved_b_cml_1;
end
endmodule

