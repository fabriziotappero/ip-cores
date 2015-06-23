`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2012-2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module Raptor64_BypassMux(dpc,dRn,xRt,m1Rt,m2Rt,wRt,tRt,rfo,xData,m1Data,m2Data,wData,tData,nxt);
input [63:0] dpc;
input [8:0] dRn;
input [8:0] xRt;
input [8:0] m1Rt;
input [8:0] m2Rt;
input [8:0] wRt;
input [8:0] tRt;
input [63:0] rfo;	// register file output
input [63:0] xData;
input [63:0] m1Data;
input [63:0] m2Data;
input [63:0] wData;
input [63:0] tData;
output [63:0] nxt;
reg [63:0] nxt;

always @(dRn or xData or m1Data or m2Data or wData or tData or rfo or dpc or xRt or m1Rt or m2Rt or wRt or tRt)
	casex(dRn)
	9'bxxxx00000:	nxt <= 64'd0;
	9'bxxxx11101:	nxt <= dpc;
	xRt:	nxt <= xData;
	m1Rt:	nxt <= m1Data;
	m2Rt:	nxt <= m2Data;
	wRt:	nxt <= wData;
	tRt:	nxt <= tData;
	default:	nxt <= rfo;
	endcase

endmodule
