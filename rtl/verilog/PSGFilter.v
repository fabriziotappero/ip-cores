`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGFilter.v
//	Version 1.1
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
//        16-tap digital filter
//
//    Currently this filter is only partially tested. The author believes that
//    the approach used is valid however.
//	The author opted to include the filter because it is part of the design,
//	and even this untested component can provide an idea of the resource
//	requirements, and device capabilities.
//		This is a "how one might approach the problem" example, at least
//	until the author is sure the filter is working correctly.
//        
//	Time division multiplexing is used to implement this filter in order to
//	reduce the resource requirement. This should be okay because it is being
//	used to filter audio signals. The effective operating frequency of the
//	filter depends on the 'cnt' supplied (eg 1MHz)
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	158 LUTs / 88 slices / 73.865MHz
//	1 MULT
//============================================================================
//
module PSGFilter(rst, clk, cnt, wr, adr, din, i, o);
parameter pTaps = 16;
input rst;
input clk;
input [7:0] cnt;
input wr;
input [3:0] adr;
input [12:0] din;
input [14:0] i;
output [14:0] o;
reg [14:0] o;

reg [30:0] acc;                 // accumulator
reg [14:0] tap [0:pTaps-1];     // tap registers
integer n;

// coefficient memory
reg [11:0] coeff [0:pTaps-1];   // magnitude of coefficient
reg [pTaps-1:0] sgn;            // sign of coefficient

initial begin
	for (n = 0; n < pTaps; n = n + 1)
	begin
		coeff[n] <= 0;
		sgn[n] <= 0;
	end
end

// update coefficient memory
always @(posedge clk)
    if (wr) begin
        coeff[adr] <= din[11:0];
        sgn[adr] <= din[12];
    end

// shift taps
// Note: infer a dsr by NOT resetting the registers
always @(posedge clk)
    if (cnt==8'd0) begin
        tap[0] <= i;
        for (n = 1; n < pTaps; n = n + 1)
        	tap[n] <= tap[n-1];
    end

wire [26:0] mult = coeff[cnt[3:0]] * tap[cnt[3:0]];

always @(posedge clk)
    if (rst)
        acc <= 0;
    else if (cnt==8'd0)
        acc <= sgn[cnt[3:0]] ? 0 - mult : 0 + mult;
    else if (cnt < pTaps)
        acc <= sgn[cnt[3:0]] ? acc - mult : acc + mult;

always @(posedge clk)
    if (rst)
        o <= 0;
    else if (cnt==8'd0)
        o <= acc[30:16];

endmodule

