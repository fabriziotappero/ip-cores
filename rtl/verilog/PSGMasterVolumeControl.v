`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGMasterVolumeControl.v 
//		Controls the PSG's output volume.
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
//============================================================================ */

module PSGMasterVolumeControl(rst_i, clk_i, i, volume, o);
input rst_i;
input clk_i;
input [15:0] i;
input [3:0] volume;
output [19:0] o;
reg [19:0] o;

// Multiply 16x4 bits
wire [19:0] v1 = volume[0] ? i : 20'd0;
wire [19:0] v2 = volume[1] ? {i,1'b0} + v1: v1;
wire [19:0] v3 = volume[2] ? {i,2'b0} + v2: v2;
wire [19:0] vo = volume[3] ? {i,3'b0} + v3: v3;

always @(posedge clk_i)
	if (rst_i)
		o <= 20'b0;		// Force the output volume to zero on reset
	else
		o <= vo;

endmodule

