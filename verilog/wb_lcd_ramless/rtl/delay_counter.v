//////////////////////////////////////////////////////////////////////
////                                                              ////
////  delay_counter.v                                             ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Delay down counter.                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module delay_counter #(
	parameter counter_width = 32
) (
	input clk,
	input reset,

	input [counter_width-1:0] count,	
	input load,
	output done
	);



reg [counter_width-1:0] counter;

always @(posedge clk)
	if(load)
		counter <= count;
	else //if (!done)
		counter <= counter - 1'b1;
	
	
assign done = (counter == 0);


endmodule
