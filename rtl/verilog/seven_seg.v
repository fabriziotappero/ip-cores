// ============================================================================
// (C) 2005-2011 Robert Finch
// All Rights Reserved.
//
//	seven_seg.v
//	    Seven segment display driver.
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
//  Webpack 9.2i xc3s1200e 4fg320
//  32 slices / 62 LUTs / 208.160 MHz
//  27 ff's / 1 DCM
//
// 500us on per digit
// 10us interdigit blanking
//=============================================================================

module seven_seg(rst, clk, dp, val, ssLedAnode, ssLedSeg);
parameter pClkFreq=25000000;
parameter pTermCnt=pClkFreq/250000;
input rst;		// reset
input clk;		// clock
input [3:0] dp;
input [15:0] val;
output [3:0] ssLedAnode;
output [7:0] ssLedSeg;

reg [3:0] ssLedAnode;
reg [7:0] ssLedSeg;

// Generate 250kHz clock from input
wire [ 9:0] q1;
wire [11:0] q2;
down_counter #(10) u1 (rst, clk, 1'b1, z, pTermCnt, q1, z);
counter      #(12) u2 (rst, clk, z, 1'b0, 12'h000, q2);

reg [4:0] nyb;

wire [2:0] dig_ndx = q2[11:9];
wire dig_en = q2[8:1]!=8'hFF;

always @(dig_ndx or dig_en)
if (dig_en)
	case (dig_ndx)
	3'd0:	ssLedAnode = 4'hE;
	3'd1:	ssLedAnode = 4'hD;
	3'd2:	ssLedAnode = 4'hB;
	3'd3:	ssLedAnode = 4'h7;
	default:	ssLedAnode = 4'hF;
	endcase
else
	ssLedAnode = 4'hF;

always @(dig_ndx or dp or val)
case (dig_ndx)
3'd0:	nyb = {dp[0],val[ 3: 0]};
3'd1:	nyb = {dp[1],val[ 7: 4]};
3'd2:	nyb = {dp[2],val[11: 8]};
3'd3:	nyb = {dp[3],val[15:12]};
default:	nyb = 5'd0;
endcase

always @(dig_en or nyb)
if (dig_en) begin
	case (nyb[3:0])
	4'h0:	ssLedSeg <= 8'b11000000;
	4'h1:	ssLedSeg <= 8'b11111001;
	4'h2:	ssLedSeg <= 8'b10100100;
	4'h3:	ssLedSeg <= 8'b10110000;
	4'h4:	ssLedSeg <= 8'b10011001;
	4'h5:	ssLedSeg <= 8'b10010010;
	4'h6:	ssLedSeg <= 8'b10000010;
	4'h7:	ssLedSeg <= 8'b11111000;
	4'h8:	ssLedSeg <= 8'b10000000;
	4'h9:	ssLedSeg <= 8'b10011000;
	4'hA:	ssLedSeg <= 8'b10001000;
	4'hB:	ssLedSeg <= 8'b10000011;
	4'hC:	ssLedSeg <= 8'b11000110;
	4'hD:	ssLedSeg <= 8'b10100001;
	4'hE:	ssLedSeg <= 8'b10000110;
	4'hF:	ssLedSeg <= 8'b10001110;
	endcase
	ssLedSeg[7] <= !nyb[4];
end
else
	ssLedSeg <= 8'b11111111;

endmodule
