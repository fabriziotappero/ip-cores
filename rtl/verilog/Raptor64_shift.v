`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_shift.v
//  - shift operations
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
module Raptor64_shift(xIR, a, b, mask, o, rolo);
input [31:0] xIR;
input [63:0] a;
input [63:0] b;
input [63:0] mask;
output [63:0] o;
reg [63:0] o;
output [63:0] rolo;

wire [6:0] xOpcode = xIR[31:25];
wire [5:0] xFunc = xIR[5:0];
wire [3:0] xFunc4 = xIR[3:0];

wire [127:0] shlxo = {64'd0,a} << b[5:0];
wire [127:0] shruxo = {a,64'd0} >> b[5:0];
wire [63:0] shlo = shlxo[63:0];
wire [63:0] shruo = shruxo[127:64];
assign rolo = {shlxo[127:64]|shlxo[63:0]};
wire [63:0] roro = {shruxo[127:64]|shruxo[63:0]};
wire [63:0] shro = ~(~a >> b[5:0]);

always @(xOpcode,xFunc,xFunc4,shlo,shruo,rolo,roro,shro,mask)
case(xOpcode)
`RR:
	case(xFunc)
	`SHL:	o = shlo;
	`SHLU:	o = shlo;
	`SHRU:	o = shruo;
	`ROL:	o = rolo;
	`ROR:	o = roro;
	`SHR:	o = shro;
	default:	o = 64'd0;
	endcase
`SHFTI:
	case(xFunc4)
	`SHLI:	o = shlo;
	`SHLUI:	o = shlo;
	`SHRUI:	o = shruo;
	`ROLI:	o = rolo;
	`RORI:	o = roro;
	`SHRI:	o = shro;
	default:	o = 64'd0;
	endcase
default:	o = 64'd0;
endcase

endmodule
