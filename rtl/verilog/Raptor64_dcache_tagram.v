`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_dcache_tagram.v
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
module Raptor64_dcache_tagram(wclk, we, adr, d, rclk, ea, tago);
input wclk;
input we;
input [8:0] adr;
input [49:0] d;
input rclk;
input [8:0] ea;
output [49:0] tago;

reg [49:0] ram [0:511];
reg [8:0] radr;

always @(posedge wclk)
	if (we) ram[adr] <= d;

always @(posedge rclk)
	radr <= ea;

assign tago = ram[radr];

endmodule
