`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_SetTargetRegister.v
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
//=============================================================================

`define EX_IRQ			9'd449	// interrupt
`define EX_NMI			9'd510	// non-maskable interrupt

module Raptor64_SetTargetRegister(rst,clk,advanceR,advanceX,dIR,dIRvalid,dAXC,xRt);
input rst;
input clk;
input advanceR;
input advanceX;
input [31:0] dIR;
input dIRvalid;
input [3:0] dAXC;
output [8:0] xRt;
reg [8:0] xRt;

wire [6:0] dOpcode = dIR[31:25];
wire [6:0] dFunc = dIR[6:0];

always @(posedge clk)
if (rst) begin
	xRt <= 9'd0;
end
else begin
if (advanceR) begin
	if (dIRvalid) begin
		casex(dOpcode)
		`MISC:
			case(dFunc)
			`SYSCALL:	xRt <= 9'd0;
			default:	xRt <= 9'd0;
			endcase
		`R:
			case(dFunc)
			`MTSPR,`CMG,`CMGI,`EXEC:
						xRt <= 9'd0;
			default:	xRt <= {dAXC,dIR[19:15]};
			endcase
		`MYST,`MUX:	xRt <= {dAXC,dIR[ 9: 5]};
		`SETLO:		xRt <= {dAXC,dIR[26:22]};
		`SETMID:	xRt <= {dAXC,dIR[26:22]};
		`SETHI:		xRt <= {dAXC,dIR[26:22]};
		`RR,`FP:	xRt <= {dAXC,dIR[14:10]};
		`BTRI:		xRt <= 9'd0;
		`BTRR:
			case(dIR[4:0])
			`LOOP:	xRt <= {dAXC,dIR[19:15]};
			default: xRt <= 9'd0;
			endcase
		`TRAPcc:	xRt <= 9'd0;
		`TRAPcci:	xRt <= 9'd0;
		`JMP:		xRt <= 9'd00;
		`CALL:		xRt <= {dAXC,5'd31};
		`RET:		xRt <= {dAXC,5'd30};
		`MEMNDX:
			case(dFunc[5:0])
			`SWX,`SHX,`SCX,`SBX,`SFX,`SFDX,`SPX,`SFPX,`SFDPX,`SSHX,`SSWX,
			`OUTWX,`OUTHX,`OUTCX,`OUTBX:
					xRt <= 9'd0;
			default:	xRt <= {dAXC,dIR[14:10]};
			endcase
		`LSH,`LSW,
		`SW,`SH,`SC,`SB,`SF,`SFD,`SSH,`SSW,`SP,`SFP,`SFDP,	// but not SWC!
		`OUTW,`OUTH,`OUTC,`OUTB:
					xRt <= 9'd0;
		`NOPI:		xRt <= 9'd0;
		`BEQI,`BNEI,`BLTI,`BLEI,`BGTI,`BGEI,`BLTUI,`BLEUI,`BGTUI,`BGEUI:
					xRt <= 9'd0;
		`IMM1:		xRt <= 9'd0;
		`IMM2:		xRt <= 9'd0;
		`IMM3:		xRt <= 9'd0;
		default:	xRt <= {dAXC,dIR[19:15]};
		endcase
	end
	else
		xRt <= 9'd0;
end
else if (advanceX)
	xRt <= 9'd0;
end

endmodule
