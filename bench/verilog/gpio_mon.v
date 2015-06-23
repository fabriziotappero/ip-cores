//////////////////////////////////////////////////////////////////////
////                                                              ////
////  GPIO Monitor                                                ////
////                                                              ////
////  This file is part of the GPIO project                       ////
////  http://www.opencores.org/cores/gpio/                        ////
////                                                              ////
////  Description                                                 ////
////  Generates and monitors GPIO external signals (+auxiliary)   ////
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
// Revision 1.2  2003/11/10 23:23:57  gorand
// tests passed.
//
// Revision 1.1  2001/08/21 21:39:27  lampret
// Changed directory structure, port names and drfines.
//
// Revision 1.2  2001/07/14 20:37:20  lampret
// Test bench improvements.
//
// Revision 1.1  2001/06/05 07:45:22  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

`include "timescale.v"
`include "gpio_defines.v"

module gpio_mon(gpio_aux, gpio_in, gpio_eclk, gpio_out, gpio_oen);

parameter gw = `GPIO_IOS;

//
// I/O ports
//
output	[gw-1:0]	gpio_aux;	// Auxiliary
output	[gw-1:0]	gpio_in;	// GPIO inputs
output	gpio_eclk;	// GPIO external clock
input	[gw-1:0]	gpio_out;	// GPIO outputs
input	[gw-1:0]	gpio_oen;	// GPIO output enables

//
// Internal regs
//
reg	[gw-1:0]	gpio_aux;
reg	[gw-1:0]	gpio_in;
reg	gpio_eclk;

initial gpio_eclk = 0;

//
// Set gpio_in
//
task set_gpioin;
input	[31:0]	val;
begin
	gpio_in = val;
end
endtask

//
// Set gpio_aux
//
task set_gpioaux;
input	[31:0]	val;
begin
	gpio_aux = val;
end
endtask

//
// Set gpio_eclk
//
task set_gpioeclk;
input	[31:0]	val;
begin
	gpio_eclk = val[0];
end
endtask

//
// Get gpio_out
//
task get_gpioout;
output	[31:0]	val;
reg	[31:0]	val;
begin
	val = gpio_out;
end
endtask

//
// Get gpio_oen
//
task get_gpiooen;
output	[31:0]	val;
begin
	val = gpio_oen;
end
endtask

endmodule
