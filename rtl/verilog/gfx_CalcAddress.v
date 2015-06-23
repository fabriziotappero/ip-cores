// ============================================================================
//        __
//   \\__/ o\    (C) 2015  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
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
//	Verilog 1995
//
// ref: XC7a100t-1CSG324
// ============================================================================
//
// Compute the graphics address
//
module gfx_CalcAddress(base_address_i, color_depth_i, hdisplayed_i, x_coord_i, y_coord_i,
	address_o, mb_o, me_o);
input [31:0] base_address_i;
input [2:0] color_depth_i;
input [11:0] hdisplayed_i;	// pixel per line
input [11:0] x_coord_i;
input [11:0] y_coord_i;
output [31:0] address_o;
output [6:0] mb_o;
output [6:0] me_o;

parameter BPP6 = 3'd0;
parameter BPP8 = 3'd1;
parameter BPP9 = 3'd2;
parameter BPP12 = 3'd3;
parameter BPP15 = 3'd4;
parameter BPP16 = 3'd5;
parameter BPP24 = 3'd6;
parameter BPP32 = 3'd7;

reg [15:0] coeff;
always @(color_depth_i)
case(color_depth_i)
BPP6:	coeff = 3121;	// 1/21 * 65536
BPP8:	coeff = 4096;	// 1/16 * 65536
BPP9:	coeff = 4681;	// 1/14 * 65536
BPP12:	coeff = 6554;	// 1/10 * 65536
BPP15:	coeff = 8192;	// 1/8 * 65536
BPP16:	coeff = 8192;	// 1/8 * 65536
BPP24:	coeff = 13107;	// 1/5 * 65536
BPP32:	coeff = 16384;	// 1/4 * 65536
endcase

reg [5:0] bpp;
always @(color_depth_i)
case(color_depth_i)
BPP6:	bpp = 5;
BPP8:	bpp = 7;
BPP9:	bpp = 8;
BPP12:	bpp = 11;
BPP15:	bpp = 15;
BPP16:	bpp = 15;
BPP24:	bpp = 23;
BPP32:	bpp = 31;
endcase

reg [6:0] coeff2;
always @(color_depth_i)
case(color_depth_i)
BPP6:	coeff2 = 126;
BPP8:	coeff2 = 128;
BPP9:	coeff2 = 126;
BPP12:	coeff2 = 120;
BPP15:	coeff2 = 128;
BPP16:	coeff2 = 128;
BPP24:	coeff2 = 120;
BPP32:	coeff2 = 128;
endcase

wire [25:0] strip_num65k = x_coord_i * coeff;
wire [15:0] strip_fract = strip_num65k[15:0];
wire [13:0] ndx = strip_fract[15:9] * coeff2;
assign mb_o = ndx[13:7];
assign me_o = mb_o + bpp;
wire [25:0] strip_num65kr = strip_num65k + 26'hFFFF;
wire [25:0] num_strips65k = hdisplayed_i * coeff + 26'hFFFF;
wire [9:0] strip_num = strip_num65kr[25:16];
wire [9:0] num_strips = num_strips65k[25:16];

wire [31:0] offset = {num_strips * y_coord_i + strip_num,4'h0};
assign address_o = base_address_i + offset;

endmodule
