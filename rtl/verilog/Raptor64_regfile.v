`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_regfile.v
//  - register file and bypass muxes
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

module Raptor64_regfile(clk, advanceR, advanceW, wIRvalid, dRa, dRb, dRc, dpc,
	xRt, m1Rt, m2Rt, wRt, tRt, xData, m1Data, m2Data, wData, tData, nxt_a, nxt_b, nxt_c);
input clk;
input advanceR;
input advanceW;
input wIRvalid;
input [8:0] dRa;
input [8:0] dRb;
input [8:0] dRc;
input [63:0] dpc;
input [8:0] xRt;
input [8:0] m1Rt;
input [8:0] m2Rt;
input [8:0] wRt;
input [8:0] tRt;
input [63:0] xData;
input [63:0] m1Data;
input [63:0] m2Data;
input [63:0] wData;
input [63:0] tData;
output [63:0] nxt_a;
output [63:0] nxt_b;
output [63:0] nxt_c;

wire [63:0] rfoa, rfob, rfoc;

syncRam512x64_1rw3r u1
(
	.wrst(1'b0),
	.wclk(clk),
	.wce(advanceW),
	.we(wIRvalid),
	.wadr(wRt),
	.i(wData),
	.wo(),
	
	.rrsta(1'b0),
	.rclka(~clk),
	.rcea(advanceR),
	.radra(dRa),
	.roa(rfoa),

	.rrstb(1'b0),
	.rclkb(~clk),
	.rceb(advanceR),
	.radrb(dRb),
	.rob(rfob),

	.rrstc(1'b0),
	.rclkc(~clk),
	.rcec(advanceR),
	.radrc(dRc),
	.roc(rfoc)
);


//	casex(dRa)
//	9'bxxxx00000:	nxt_a <= 64'd0;
//	9'bxxxx11101:	nxt_a <= dpc;
//	xRt:	nxt_a <= xData;
//	m1Rt:	nxt_a <= m1Data;
//	m2Rt:	nxt_a <= m2Data;
//	wRt:	nxt_a <= wData;
//	tRt:	nxt_a <= tData;
//	default:	nxt_a <= rfoa;
//	endcase

//reg [63:0] nxt_b;
//always @(dRb or xData or m1Data or m2Data or wData or tData or rfob or dpc or xRt or m1Rt or m2Rt or wRt or tRt)
//	casex(dRb)
//	9'bxxxx00000:	nxt_b <= 64'd0;
//	9'bxxxx11101:	nxt_b <= dpc;
//	xRt:	nxt_b <= xData;
//	m1Rt:	nxt_b <= m1Data;
//	m2Rt:	nxt_b <= m2Data;
//	wRt:	nxt_b <= wData;
//	tRt:	nxt_b <= tData;
//	default:	nxt_b <= rfob;
//	endcase
//
//reg [63:0] nxt_c;
//always @(dRc or xData or m1Data or m2Data or wData or tData or rfoc or dpc or xRt or m1Rt or m2Rt or wRt or tRt)
//	casex(dRc)
//	9'bxxxx00000:	nxt_c <= 64'd0;
//	9'bxxxx11101:	nxt_c <= dpc;
//	xRt:	nxt_c <= xData;
//	m1Rt:	nxt_c <= m1Data;
//	m2Rt:	nxt_c <= m2Data;
//	wRt:	nxt_c <= wData;
//	tRt:	nxt_c <= tData;
//	default:	nxt_c <= rfoc;
//	endcase


endmodule
