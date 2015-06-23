//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system_sim.v                                                ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Simulation testbench for SPARTAN-3E STARTER KIT          ////
////     clock and reset.                                         ////
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


//----------------------------------------------------------------------------
// Simulation testbench for SPARTAN-3E STARTER KIT clock and reset
//----------------------------------------------------------------------------
`timescale 1ns / 1ps

module system_sim;
reg clk = 0;
reg reset = 1;

//----------------------------------------------------------------------------
// Memory-Tester System
//----------------------------------------------------------------------------
system dut (
      .clk   ( clk   ),
      .reset   ( reset )
);


//----------------------------------------------------------------------------
// Clock Generation (50 MHZ)
//----------------------------------------------------------------------------
initial clk <= 1'b0;
always #10 clk <=  ~clk;

//----------------------------------------------------------------------------
// Reset Generation
//----------------------------------------------------------------------------
initial begin
	$dumpfile("system.vcd");
	$dumpvars;

	#0       reset <= 1'b1; 
	#80      reset <= 1'b0;

//	#10000000000  $finish;
end

endmodule

// vim: set ts=4
