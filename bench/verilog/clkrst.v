//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Clock and Reset Generator                                   ////
////                                                              ////
////  This file is part of the PTC project                        ////
////  http://www.opencores.org/cores/ptc/                         ////
////                                                              ////
////  Description                                                 ////
////  Clock and reset generator.                                  ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
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
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/06/05 07:45:32  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

`include "timescale.v"

module clkrst(clk_o, rst_o, ptc_ecgt);

//
// I/O ports
//
output	clk_o;	// Clock
output	rst_o;	// Reset
output	ptc_ecgt; // (External) PTC clock/gate

//
// Internal regs
//
reg	clk_o;	// Clock
reg	rst_o;	// Reset
reg	ptc_ecgt; // PTC clock/gate

initial begin
	clk_o = 0;
	rst_o = 1;
	ptc_ecgt = 0;
	#20;
	rst_o = 0;
end

//
// Clock
//
always #4 clk_o = ~clk_o;

//
// PTC clock/gate generator
//
task gen_ptc_ecgt;
input	[31:0]	cycles;
integer 	i;
begin
	if (cycles == -1)
		ptc_ecgt = 1;
	else
	for (i = 2 * cycles; i; i = i - 1) begin
		#4 ptc_ecgt = ~ptc_ecgt;
		if (i % 20000 == 19999)
			$write(".");
	end
end
endtask

endmodule
