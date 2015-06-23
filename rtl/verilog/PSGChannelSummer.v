`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGChannelSummer.v 
//		Sums the channel outputs.
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
//============================================================================

module PSGChannelSummer(clk_i, cnt, outctrl, tmc_i, o);
input clk_i;			// master clock
input [7:0] cnt;		// select counter
input [3:0] outctrl;	// channel output enable control
input [19:0] tmc_i;		// time-multiplexed channel input
output [21:0] o;		// summed output
reg [21:0] o;

// channel select signal
wire [1:0] sel = cnt[1:0];

always @(posedge clk_i)
	if (cnt==8'd0)
		o <= 22'd0 + (tmc_i & {20{outctrl[sel]}});
	else if (cnt < 8'd4)
		o <= o + (tmc_i & {20{outctrl[sel]}});

endmodule
