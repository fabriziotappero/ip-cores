//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's ALU                                                ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  ALU                                                         ////
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
// Revision 1.14  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.13  2004/05/09 19:49:03  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.12  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.11  2003/04/24 00:16:07  lampret
// No functional changes. Added defines to disable implementation of multiplier/MAC
//
// Revision 1.10  2002/09/08 05:52:16  lampret
// Added optional l.div/l.divu insns. By default they are disabled.
//
// Revision 1.9  2002/09/07 19:16:10  lampret
// If SR[CY] implemented with OR1200_IMPL_ADDC enabled, l.add/l.addi also set SR[CY].
//
// Revision 1.8  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.7  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default and optionally (OR1200_CASE_DEFAULT) can be disabled to increase clock frequncy.
//
// Revision 1.6  2002/03/29 16:40:10  lampret
// Added a directive to ignore signed division variables that are only used in simulation.
//
// Revision 1.5  2002/03/29 16:33:59  lampret
// Added again just recently removed full_case directive
//
// Revision 1.4  2002/03/29 15:16:53  lampret
// Some of the warnings fixed.
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
// Revision 1.10  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/19 23:28:45  lampret
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

module or1200_alu(
	a, b, mult_mac_result, macrc_op,
	alu_op, shrot_op, comp_op,
	cust5_op, cust5_limm,
	result, flagforw, flag_we,
	cyforw, cy_we, carry, flag
);

parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O
//
input	[width-1:0]		a;
input	[width-1:0]		b;
input	[width-1:0]		mult_mac_result;
input				macrc_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
input	[`OR1200_SHROTOP_WIDTH-1:0]	shrot_op;
input	[`OR1200_COMPOP_WIDTH-1:0]	comp_op;
input	[4:0]			cust5_op;
input	[5:0]			cust5_limm;
output	[width-1:0]		result;
output				flagforw;
output				flag_we;
output				cyforw;
output				cy_we;
input				carry;
input         flag;

//
// Internal wires and regs
//
reg	[width-1:0]		result;
reg	[width-1:0]		shifted_rotated;
reg	[width-1:0]		result_cust5;
reg				flagforw;
reg				flagcomp;
reg				flag_we;
reg				cy_we;
wire	[width-1:0]		comp_a;
wire	[width-1:0]		comp_b;
`ifdef OR1200_IMPL_ALU_COMP1
wire				a_eq_b;
wire				a_lt_b;
`endif
wire	[width-1:0]		result_sum;
`ifdef OR1200_IMPL_ADDC
wire	[width-1:0]		result_csum;
wire				cy_csum;
`endif
wire	[width-1:0]		result_and;
wire				cy_sum;
reg				cyforw;

//
// Combinatorial logic
//
assign comp_a = {a[width-1] ^ comp_op[3] , a[width-2:0]};
assign comp_b = {b[width-1] ^ comp_op[3] , b[width-2:0]};
`ifdef OR1200_IMPL_ALU_COMP1
assign a_eq_b = (comp_a == comp_b);
assign a_lt_b = (comp_a < comp_b);
`endif
wire	[width:0]		cy_sum_result_sum;
//assign {cy_sum, result_sum} = a + b;
assign cy_sum_result_sum = a + b;
assign cy_sum = cy_sum_result_sum[32];
assign result_sum = cy_sum_result_sum[31:0];
`ifdef OR1200_IMPL_ADDC
wire	[width:0]		cy_csum_result_csum;
//assign {cy_csum, result_csum} = a + b + {32'd0, carry};
assign cy_csum_result_csum = a + b + {32'd0, carry};
assign cy_csum = cy_csum_result_csum[32];
assign result_csum = cy_csum_result_csum[31:0];
`endif
assign result_and = a & b;

//
// Simulation check for bad ALU behavior
//
`ifdef OR1200_WARNINGS
// synopsys translate_off
always @(result) begin
	if (result === 32'bx)
		$display("%t: WARNING: 32'bx detected on ALU result bus. Please check !", $time);
end
// synopsys translate_on
`endif

//
// Central part of the ALU
//
always @(alu_op or a or b or result_sum or result_and or macrc_op or shifted_rotated or mult_mac_result) begin
`ifdef OR1200_CASE_DEFAULT
	casex (alu_op)		// synopsys parallel_case
`else
	casex (alu_op)		// synopsys full_case parallel_case
`endif
    `OR1200_ALUOP_FF1: begin
        result = a[0] ? 1 : a[1] ? 2 : a[2] ? 3 : a[3] ? 4 : a[4] ? 5 : a[5] ? 6 : a[6] ? 7 : a[7] ? 8 : a[8] ? 9 : a[9] ? 10 : a[10] ? 11 : a[11] ? 12 : a[12] ? 13 : a[13] ? 14 : a[14] ? 15 : a[15] ? 16 : a[16] ? 17 : a[17] ? 18 : a[18] ? 19 : a[19] ? 20 : a[20] ? 21 : a[21] ? 22 : a[22] ? 23 : a[23] ? 24 : a[24] ? 25 : a[25] ? 26 : a[26] ? 27 : a[27] ? 28 : a[28] ? 29 : a[29] ? 30 : a[30] ? 31 : a[31] ? 32 : 0;
    end
		`OR1200_ALUOP_CUST5 : begin 
				result = result_cust5;
		end
		`OR1200_ALUOP_SHROT : begin 
				result = shifted_rotated;
		end
		`OR1200_ALUOP_ADD : begin
				result = result_sum;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC : begin
				result = result_csum;
		end
`endif
		`OR1200_ALUOP_SUB : begin
				result = a - b;
		end
		`OR1200_ALUOP_XOR : begin
				result = a ^ b;
		end
		`OR1200_ALUOP_OR  : begin
				result = a | b;
		end
		`OR1200_ALUOP_IMM : begin
				result = b;
		end
		`OR1200_ALUOP_MOVHI : begin
				if (macrc_op) begin
					result = mult_mac_result;
				end
				else begin
					result = b << 16;
				end
		end
`ifdef OR1200_MULT_IMPLEMENTED
`ifdef OR1200_IMPL_DIV
		`OR1200_ALUOP_DIV,
		`OR1200_ALUOP_DIVU,
`endif
		`OR1200_ALUOP_MUL : begin
				result = mult_mac_result;
		end
`endif
    `OR1200_ALUOP_CMOV: begin
        result = flag ? a : b;
    end

`ifdef OR1200_CASE_DEFAULT
    default: begin
`else
    `OR1200_ALUOP_COMP, `OR1200_ALUOP_AND:
    begin
`endif
      result=result_and;
    end 
	endcase
end

//
// l.cust5 custom instructions
//
// Examples for move byte, set bit and clear bit
//
always @(cust5_op or cust5_limm or a or b) begin
	casex (cust5_op)		// synopsys parallel_case
		5'h1 : begin 
			casex (cust5_limm[1:0])
				2'h0: result_cust5 = {a[31:8], b[7:0]};
				2'h1: result_cust5 = {a[31:16], b[7:0], a[7:0]};
				2'h2: result_cust5 = {a[31:24], b[7:0], a[15:0]};
				2'h3: result_cust5 = {b[7:0], a[23:0]};
			endcase
		end
		5'h2 :
			result_cust5 = a | (1 << cust5_limm);
		5'h3 :
			result_cust5 = a & (32'hffffffff ^ (1 << cust5_limm));
//
// *** Put here new l.cust5 custom instructions ***
//
		default: begin
			result_cust5 = a;
		end
	endcase
end

//
// Generate flag and flag write enable
//
always @(alu_op or result_sum or result_and or flagcomp) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_ADDITIONAL_FLAG_MODIFIERS
		`OR1200_ALUOP_ADD : begin
			flagforw = (result_sum == 32'h0000_0000);
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC : begin
			flagforw = (result_csum == 32'h0000_0000);
		end
`endif
		`OR1200_ALUOP_AND: begin
			flagforw = (result_and == 32'h0000_0000);
		end
`endif
		`OR1200_ALUOP_COMP: begin
			flagforw = flagcomp;
		end
		default: begin
			flagforw = 1'b0;
		end
	endcase
end
always @(alu_op or result_sum or result_and or flagcomp) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_ADDITIONAL_FLAG_MODIFIERS
		`OR1200_ALUOP_ADD : begin
			flag_we = 1'b1;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC : begin
			flag_we = 1'b1;
		end
`endif
		`OR1200_ALUOP_AND: begin
			flag_we = 1'b1;
		end
`endif
		`OR1200_ALUOP_COMP: begin
			flag_we = 1'b1;
		end
		default: begin
			flag_we = 1'b0;
		end
	endcase
end

//
// Generate SR[CY] write enable
//
always @(alu_op or cy_sum
`ifdef OR1200_IMPL_ADDC
	or cy_csum
`endif
	) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_IMPL_CY
		`OR1200_ALUOP_ADD : begin
			cyforw = cy_sum;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC: begin
			cyforw = cy_csum;
		end
`endif
`endif
		default: begin
			cyforw = 1'b0;
		end
	endcase
end
always @(alu_op or cy_sum
`ifdef OR1200_IMPL_ADDC
	or cy_csum
`endif
	) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_IMPL_CY
		`OR1200_ALUOP_ADD : begin
			cy_we = 1'b1;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC: begin
			cy_we = 1'b1;
		end
`endif
`endif
		default: begin
			cy_we = 1'b0;
		end
	endcase
end

//
// Shifts and rotation
//
always @(shrot_op or a or b) begin
	case (shrot_op)		// synopsys parallel_case
	`OR1200_SHROTOP_SLL :
				shifted_rotated = (a << b[4:0]);
		`OR1200_SHROTOP_SRL :
				shifted_rotated = (a >> b[4:0]);

`ifdef OR1200_IMPL_ALU_ROTATE
		`OR1200_SHROTOP_ROR :
				shifted_rotated = (a << (6'd32-{1'b0, b[4:0]})) | (a >> b[4:0]);
`endif
		default:
				shifted_rotated = ({32{a[31]}} << (6'd32-{1'b0, b[4:0]})) | a >> b[4:0];
	endcase
end

//
// First type of compare implementation
//
`ifdef OR1200_IMPL_ALU_COMP1
always @(comp_op or a_eq_b or a_lt_b) begin
	case(comp_op[2:0])	// synopsys parallel_case
		`OR1200_COP_SFEQ:
			flagcomp = a_eq_b;
		`OR1200_COP_SFNE:
			flagcomp = ~a_eq_b;
		`OR1200_COP_SFGT:
			flagcomp = ~(a_eq_b | a_lt_b);
		`OR1200_COP_SFGE:
			flagcomp = ~a_lt_b;
		`OR1200_COP_SFLT:
			flagcomp = a_lt_b;
		`OR1200_COP_SFLE:
			flagcomp = a_eq_b | a_lt_b;
		default:
			flagcomp = 1'b0;
	endcase
end
`endif

//
// Second type of compare implementation
//
`ifdef OR1200_IMPL_ALU_COMP2
always @(comp_op or comp_a or comp_b) begin
	case(comp_op[2:0])	// synopsys parallel_case
		`OR1200_COP_SFEQ:
			flagcomp = (comp_a == comp_b);
		`OR1200_COP_SFNE:
			flagcomp = (comp_a != comp_b);
		`OR1200_COP_SFGT:
			flagcomp = (comp_a > comp_b);
		`OR1200_COP_SFGE:
			flagcomp = (comp_a >= comp_b);
		`OR1200_COP_SFLT:
			flagcomp = (comp_a < comp_b);
		`OR1200_COP_SFLE:
			flagcomp = (comp_a <= comp_b);
		default:
			flagcomp = 1'b0;
	endcase
end
`endif

endmodule
