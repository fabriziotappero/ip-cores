//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's register file generic memory                       ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Generic (flip-flop based) register file memory              ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing                                                  ////
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
// $Log: not supported by cvs2svn $
// Revision 1.2  2006/12/22 08:34:00  vak
// The design is successfully compiled using on-chip RAM.
//
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.3  2004/06/08 18:16:32  lampret
// GPR0 hardwired to zero.
//
// Revision 1.2  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default
// and optionally (OR1200_CASE_DEFAULT) can be disabled to increase
// clock frequncy.
//
// Revision 1.1  2002/06/08 16:23:30  lampret
// Generic flip-flop based memory macro for register file.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_rfram_generic(
	// Clock and reset
	clk, rst,

	// Port A
	ce_a, addr_a, do_a,

	// Port B
	ce_b, addr_b, do_b,

	// Port W
	ce_w, we_w, addr_w, di_w
);

parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_REGFILE_ADDR_WIDTH;

//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// Port A
//
input				ce_a;
input	[aw-1:0]		addr_a;
output	[dw-1:0]		do_a;

//
// Port B
//
input				ce_b;
input	[aw-1:0]		addr_b;
output	[dw-1:0]		do_b;

//
// Port W
//
input				ce_w;
input				we_w;
input	[aw-1:0]		addr_w;
input	[dw-1:0]		di_w;

//
// Internal wires and regs
//
reg	[aw-1:0]		intaddr_a;
reg	[aw-1:0]		intaddr_b;
reg	[32*dw-1:0]		mem;
reg	[dw-1:0]		do_a;
reg	[dw-1:0]		do_b;

//
// Write port
//
always @(posedge clk or posedge rst)
	if (rst) begin
		mem <= #1 {512'h0, 512'h0};
	end
	else if (ce_w & we_w)
		case (addr_w)	// synopsys parallel_case
			5'd00: mem[32*0+31:32*0] <= #1 32'h0000_0000;
			5'd01: mem[32*1+31:32*1] <= #1 di_w;
			5'd02: mem[32*2+31:32*2] <= #1 di_w;
			5'd03: mem[32*3+31:32*3] <= #1 di_w;
			5'd04: mem[32*4+31:32*4] <= #1 di_w;
			5'd05: mem[32*5+31:32*5] <= #1 di_w;
			5'd06: mem[32*6+31:32*6] <= #1 di_w;
			5'd07: mem[32*7+31:32*7] <= #1 di_w;
			5'd08: mem[32*8+31:32*8] <= #1 di_w;
			5'd09: mem[32*9+31:32*9] <= #1 di_w;
			5'd10: mem[32*10+31:32*10] <= #1 di_w;
			5'd11: mem[32*11+31:32*11] <= #1 di_w;
			5'd12: mem[32*12+31:32*12] <= #1 di_w;
			5'd13: mem[32*13+31:32*13] <= #1 di_w;
			5'd14: mem[32*14+31:32*14] <= #1 di_w;
			5'd15: mem[32*15+31:32*15] <= #1 di_w;
			5'd16: mem[32*16+31:32*16] <= #1 di_w;
			5'd17: mem[32*17+31:32*17] <= #1 di_w;
			5'd18: mem[32*18+31:32*18] <= #1 di_w;
			5'd19: mem[32*19+31:32*19] <= #1 di_w;
			5'd20: mem[32*20+31:32*20] <= #1 di_w;
			5'd21: mem[32*21+31:32*21] <= #1 di_w;
			5'd22: mem[32*22+31:32*22] <= #1 di_w;
			5'd23: mem[32*23+31:32*23] <= #1 di_w;
			5'd24: mem[32*24+31:32*24] <= #1 di_w;
			5'd25: mem[32*25+31:32*25] <= #1 di_w;
			5'd26: mem[32*26+31:32*26] <= #1 di_w;
			5'd27: mem[32*27+31:32*27] <= #1 di_w;
			5'd28: mem[32*28+31:32*28] <= #1 di_w;
			5'd29: mem[32*29+31:32*29] <= #1 di_w;
			5'd30: mem[32*30+31:32*30] <= #1 di_w;
			default: mem[32*31+31:32*31] <= #1 di_w;
		endcase

//
// Read port A
//
always @(posedge clk or posedge rst)
	if (rst) begin
		intaddr_a <= #1 5'h00;
	end
	else if (ce_a)
		intaddr_a <= #1 addr_a;

always @(mem or intaddr_a)
	case (intaddr_a)	// synopsys parallel_case
		5'd00: do_a = 32'h0000_0000;
		5'd01: do_a = mem[32*1+31:32*1];
		5'd02: do_a = mem[32*2+31:32*2];
		5'd03: do_a = mem[32*3+31:32*3];
		5'd04: do_a = mem[32*4+31:32*4];
		5'd05: do_a = mem[32*5+31:32*5];
		5'd06: do_a = mem[32*6+31:32*6];
		5'd07: do_a = mem[32*7+31:32*7];
		5'd08: do_a = mem[32*8+31:32*8];
		5'd09: do_a = mem[32*9+31:32*9];
		5'd10: do_a = mem[32*10+31:32*10];
		5'd11: do_a = mem[32*11+31:32*11];
		5'd12: do_a = mem[32*12+31:32*12];
		5'd13: do_a = mem[32*13+31:32*13];
		5'd14: do_a = mem[32*14+31:32*14];
		5'd15: do_a = mem[32*15+31:32*15];
		5'd16: do_a = mem[32*16+31:32*16];
		5'd17: do_a = mem[32*17+31:32*17];
		5'd18: do_a = mem[32*18+31:32*18];
		5'd19: do_a = mem[32*19+31:32*19];
		5'd20: do_a = mem[32*20+31:32*20];
		5'd21: do_a = mem[32*21+31:32*21];
		5'd22: do_a = mem[32*22+31:32*22];
		5'd23: do_a = mem[32*23+31:32*23];
		5'd24: do_a = mem[32*24+31:32*24];
		5'd25: do_a = mem[32*25+31:32*25];
		5'd26: do_a = mem[32*26+31:32*26];
		5'd27: do_a = mem[32*27+31:32*27];
		5'd28: do_a = mem[32*28+31:32*28];
		5'd29: do_a = mem[32*29+31:32*29];
		5'd30: do_a = mem[32*30+31:32*30];
		default: do_a = mem[32*31+31:32*31];
	endcase

//
// Read port B
//
always @(posedge clk or posedge rst)
	if (rst) begin
		intaddr_b <= #1 5'h00;
	end
	else if (ce_b)
		intaddr_b <= #1 addr_b;

always @(mem or intaddr_b)
	case (intaddr_b)	// synopsys parallel_case
		5'd00: do_b = 32'h0000_0000;
		5'd01: do_b = mem[32*1+31:32*1];
		5'd02: do_b = mem[32*2+31:32*2];
		5'd03: do_b = mem[32*3+31:32*3];
		5'd04: do_b = mem[32*4+31:32*4];
		5'd05: do_b = mem[32*5+31:32*5];
		5'd06: do_b = mem[32*6+31:32*6];
		5'd07: do_b = mem[32*7+31:32*7];
		5'd08: do_b = mem[32*8+31:32*8];
		5'd09: do_b = mem[32*9+31:32*9];
		5'd10: do_b = mem[32*10+31:32*10];
		5'd11: do_b = mem[32*11+31:32*11];
		5'd12: do_b = mem[32*12+31:32*12];
		5'd13: do_b = mem[32*13+31:32*13];
		5'd14: do_b = mem[32*14+31:32*14];
		5'd15: do_b = mem[32*15+31:32*15];
		5'd16: do_b = mem[32*16+31:32*16];
		5'd17: do_b = mem[32*17+31:32*17];
		5'd18: do_b = mem[32*18+31:32*18];
		5'd19: do_b = mem[32*19+31:32*19];
		5'd20: do_b = mem[32*20+31:32*20];
		5'd21: do_b = mem[32*21+31:32*21];
		5'd22: do_b = mem[32*22+31:32*22];
		5'd23: do_b = mem[32*23+31:32*23];
		5'd24: do_b = mem[32*24+31:32*24];
		5'd25: do_b = mem[32*25+31:32*25];
		5'd26: do_b = mem[32*26+31:32*26];
		5'd27: do_b = mem[32*27+31:32*27];
		5'd28: do_b = mem[32*28+31:32*28];
		5'd29: do_b = mem[32*29+31:32*29];
		5'd30: do_b = mem[32*30+31:32*30];
		default: do_b = mem[32*31+31:32*31];
	endcase

endmodule
