`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGShaper.v 
//		Shape the channels by applying the envelope to the tone generator
//	output.
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
//============================================================================ */

module PSGShaper(clk_i, ce, tgi, env, o);
input clk_i;		// clock
input ce;			// clock enable
input [11:0] tgi;	// tone generator input
input [7:0] env;	// envelop generator input
output [19:0] o;	// shaped output
reg [19:0] o;		// shaped output

// shape output according to envelope
always @(posedge clk_i)
	if (ce)
		o <= tgi * env;

endmodule
