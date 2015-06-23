`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_SetOperandRegs.v
//  
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
//
// If a register field is not used by an instruction, then the register
// selected is forced to r0 for that field. This causes load stalls to be
// avoided, which would otherwise occur.
//=============================================================================

module Raptor64_SetOperandRegs(rst, clk, advanceI, advanceR, advanceX, b, AXC, xAXC, insn, xIR, dRa, dRb, dRc, nxt_Ra, nxt_Rb, nxt_Rc);
input rst;
input clk;
input advanceI;
input advanceR;
input advanceX;
input [63:0] b;
input [3:0] AXC;
input [3:0] xAXC;
input [31:0] insn;
input [31:0] xIR;
output [8:0] dRa;
reg [8:0] dRa;
output [8:0] dRb;
reg [8:0] dRb;
output [8:0] dRc;
reg [8:0] dRc;
output [8:0] nxt_Ra;
reg [8:0] nxt_Ra;
output [8:0] nxt_Rb;
reg [8:0] nxt_Rb;
output [8:0] nxt_Rc;
reg [8:0] nxt_Rc;

wire [6:0] iOpcode = insn[31:25];
wire [6:0] xOpcode = xIR[31:25];
wire [5:0] xFunc = xIR[5:0];
wire [6:0] iFunc7 = insn[6:0];


always @*
begin
	nxt_Ra <= dRa;
	nxt_Rb <= dRb;
	nxt_Rc <= dRc;
	if (advanceI) begin
		// Default settings, to be overridden
		nxt_Ra <= {AXC,insn[24:20]};
		nxt_Rb <= {AXC,insn[19:15]};
		nxt_Rc <= {AXC,insn[14:10]};
		casex(iOpcode)
		`MISC:
			case(iFunc7)
			`IRET:	begin
					nxt_Ra <= {AXC,5'd25};
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
			`ERET:	begin
					nxt_Ra <= {AXC,5'd24};
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
			default:
					begin
					nxt_Ra <= 9'd0;
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
			endcase
		`R:	begin nxt_Rb <= 9'd0; nxt_Rc <= 9'd0; end
		`RR: nxt_Rc <= 9'd0;
		`TRAPcc:	nxt_Rc <= 9'd0;
		`TRAPcci:	begin nxt_Rb <= 9'd0; nxt_Rc <= 9'd0; end
		`CALL,`JMP,`NOPI:
					begin
					nxt_Ra <= 9'd0;
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`RET:		begin
					nxt_Ra <= {AXC,5'd30};
					nxt_Rb <= {AXC,5'd31};
					nxt_Rc <= 9'd0;
					end
		`LB,`LBU,`LH,`LHU,`LC,`LCU,`LW,`LP,`LSH,`LSW,`LF,`LFD,`LFP,`LFDP,`LWR:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`SB,`SC,`SH,`SW,`SP,`SSH,`SSW,`SF,`SFD,`SFP,`SFDP,`SWC:
					nxt_Rc <= 9'd0;
		`INB,`INBU,`INCH,`INCU,`INH,`INHU,`INW:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`OUTB,`OUTC,`OUTH,`OUTW:
					nxt_Rc <= 9'd0;
		`BLTI,`BLEI,`BGTI,`BGEI,
		`BLTUI,`BLEUI,`BGTUI,`BGEUI,
		`BEQI,`BNEI:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`BTRI:		nxt_Rc <= 9'd0;
		`SLTI,`SLEI,`SGTI,`SGEI,
		`SLTUI,`SLEUI,`SGTUI,`SGEUI,
		`SEQI,`SNEI:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`ADDI,`ADDUI,`SUBI,`SUBUI,`CMPI,`CMPUI,
		`ANDI,`XORI,`ORI,`MULUI,`MULSI,`DIVUI,`DIVSI:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`JAL:
					begin
					nxt_Rb <= 9'd0;
					nxt_Rc <= 9'd0;
					end
		`SETLO:		begin nxt_Ra <= {AXC,insn[26:22]}; nxt_Rb <= 9'd0; nxt_Rc <= 9'd0; end
		`SETMID:	begin nxt_Ra <= {AXC,insn[26:22]}; nxt_Rb <= 9'd0; nxt_Rc <= 9'd0; end
		`SETHI:		begin nxt_Ra <= {AXC,insn[26:22]}; nxt_Rb <= 9'd0; nxt_Rc <= 9'd0; end
		default:	nxt_Ra <= {AXC,insn[24:20]};
		endcase
	end
	else if (advanceR) begin
		nxt_Ra <= 9'd0;
		nxt_Rb <= 9'd0;
		nxt_Rc <= 9'd0;
	end
	// no else here
	if (advanceX) begin
		if (xOpcode==`R) begin
			if (xFunc==`EXEC) begin
				nxt_Ra <= {xAXC,b[24:20]};
				nxt_Rb <= {xAXC,b[19:15]};
				nxt_Rc <= {xAXC,b[14:10]};
			end
		end
	end
end

always @(posedge clk)
if (rst) begin
	dRa <= 9'd0;
	dRb <= 9'd0;
	dRc <= 9'd0;
end
else begin
	dRa <= nxt_Ra;
	dRb <= nxt_Rb;
	dRc <= nxt_Rc;
end

endmodule
