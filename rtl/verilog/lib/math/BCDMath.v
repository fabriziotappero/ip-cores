`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	BCDMath.v
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
module BCDAdd(ci,a,b,o,c);
input ci;		// carry input
input [7:0] a;
input [7:0] b;
output [7:0] o;
output c;

wire c0,c1;

wire [4:0] hsN0 = a[3:0] + b[3:0] + ci;
wire [4:0] hsN1 = a[7:4] + b[7:4] + c0;

BCDAddAdjust u1 (hsN0,o[3:0],c0);
BCDAddAdjust u2 (hsN1,o[7:4],c);

endmodule

module BCDSub(ci,a,b,o,c);
input ci;		// carry input
input [7:0] a;
input [7:0] b;
output [7:0] o;
output c;

wire c0,c1;

wire [4:0] hdN0 = a[3:0] - b[3:0] - ci;
wire [4:0] hdN1 = a[7:4] - b[7:4] - c0;

BCDSubAdjust u1 (hdN0,o[3:0],c0);
BCDSubAdjust u2 (hdN1,o[7:4],c);

endmodule

module BCDAddAdjust(i,o,c);
input [4:0] i;
output [3:0] o;
reg [3:0] o;
output c;
reg c;
always @(i)
case(i)
5'h0: begin o = 4'h0; c = 1'b0; end
5'h1: begin o = 4'h1; c = 1'b0; end
5'h2: begin o = 4'h2; c = 1'b0; end
5'h3: begin o = 4'h3; c = 1'b0; end
5'h4: begin o = 4'h4; c = 1'b0; end
5'h5: begin o = 4'h5; c = 1'b0; end
5'h6: begin o = 4'h6; c = 1'b0; end
5'h7: begin o = 4'h7; c = 1'b0; end
5'h8: begin o = 4'h8; c = 1'b0; end
5'h9: begin o = 4'h9; c = 1'b0; end
5'hA: begin o = 4'h0; c = 1'b1; end
5'hB: begin o = 4'h1; c = 1'b1; end
5'hC: begin o = 4'h2; c = 1'b1; end
5'hD: begin o = 4'h3; c = 1'b1; end
5'hE: begin o = 4'h4; c = 1'b1; end
5'hF: begin o = 4'h5; c = 1'b1; end
5'h10:	begin o = 4'h6; c = 1'b1; end
5'h11:	begin o = 4'h7; c = 1'b1; end
5'h12:	begin o = 4'h8; c = 1'b1; end
5'h13:	begin o = 4'h9; c = 1'b1; end
default:	begin o = 4'h9; c = 1'b1; end
endcase
endmodule

module BCDSubAdjust(i,o,c);
input [4:0] i;
output [3:0] o;
reg [3:0] o;
output c;
reg c;
always @(i)
case(i)
5'h0: begin o = 4'h0; c = 1'b0; end
5'h1: begin o = 4'h1; c = 1'b0; end
5'h2: begin o = 4'h2; c = 1'b0; end
5'h3: begin o = 4'h3; c = 1'b0; end
5'h4: begin o = 4'h4; c = 1'b0; end
5'h5: begin o = 4'h5; c = 1'b0; end
5'h6: begin o = 4'h6; c = 1'b0; end
5'h7: begin o = 4'h7; c = 1'b0; end
5'h8: begin o = 4'h8; c = 1'b0; end
5'h9: begin o = 4'h9; c = 1'b0; end
5'h16: begin 0 = 4'h0; c = 1'b1; end
5'h17: begin o = 4'h1; c = 1'b1; end
5'h18: begin o = 4'h2; c = 1'b1; end
5'h19: begin o = 4'h3; c = 1'b1; end
5'h1A: begin o = 4'h4; c = 1'b1; end
5'h1B: begin o = 4'h5; c = 1'b1; end
5'h1C: begin o = 4'h6; c = 1'b1; end
5'h1D: begin o = 4'h7; c = 1'b1; end
5'h1E: begin o = 4'h8; c = 1'b1; end
5'h1F: begin o = 4'h9; c = 1'b1; end
default: begin o = 4'h9; c = 1'b1; end
endcase
endmodule
