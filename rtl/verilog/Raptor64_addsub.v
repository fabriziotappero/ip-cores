`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_addsub.v
//  - addsub datapath operations
//
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
//
module Raptor64_addsub(xIR, a, b, imm, o);
input [31:0] xIR;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
output [63:0] o;
reg [63:0] o;

wire [6:0] xOpcode = xIR[31:25];
wire [5:0] xFunc = xIR[5:0];
wire [7:0] bcdaddo,bcdsubo;

BCDAdd u1(.ci(1'b0),.a(a[7:0]),.b(b[7:0]),.o(bcdaddo),.c());
BCDSub u2(.ci(1'b0),.a(a[7:0]),.b(b[7:0]),.o(bcdsubo),.c());

always @(xOpcode,xFunc,a,b,imm,bcdaddo,bcdsubo)
case (xOpcode)
`RR:
	case(xFunc)
	`ADD:	o = a + b;
	`ADDU:	o = a + b;
	`SUB:	o = a - b;
	`SUBU:	o = a - b;
	`BCD_ADD:	o = bcdaddo;
	`BCD_SUB:	o = bcdsubo;
	default:	o = 64'd0;
	endcase
`INB,`INCH,`INH,`INW,`INCU,`INHU,`INBU,
`OUTB,`OUTC,`OUTH,`OUTW,`OUTBC,
`LW,`LH,`LC,`LB,`LHU,`LCU,`LBU,`LEA,`LF,`LFD,`LWR,
`SW,`SH,`SC,`SB,`SF,`SFD,`SWC,
`ADDI,`ADDUI:
		o = a + imm;
`SUBI:	o = a - imm;
`SUBUI:	o = a - imm;
default:	o = 64'd0;
endcase

endmodule
