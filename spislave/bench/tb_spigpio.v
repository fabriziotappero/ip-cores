//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Test Bench for SPI SLAVE IP Core                             ////
////                                                              ////
//// This file is part of the spislave project                    ////
//// http://www.opencores.org/project,spislave                    ////
////                                                              ////
//// Description                                                  ////
//// TB Implementation of spislave IP core according to           ////
//// spislave IP core specification document.                     ////
////                                                              ////
//// To Do:                                                       ////
////   -                                                          ////
////                                                              ////
//// Author(s):                                                   ////
////      - Sivakumar.B ,                                         ////
////                      email: siva12@opencores.org             ////
////                      email: siva@zilogic.com                 ////
////                                                              ////
////        Engineer  Zilogic systems,chennai. www.zilogic.com    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Sivakumar.B,  siva@zilogic.com            ////
///             www.zilogic.com  and OPENCORES.ORG                ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//// test bench for spigpio for SPI GPIO -- shift 8 bit register  ////  
////                                                              ////
//// This is a iverilog simulation from icarus verilog            ////
//// you install it in your linux system                          ////
////        sudo apt-get install verilog                          ////  
//// or go through the following website                          ////  
//// http://www.icarus.com/eda/verilog/                           ////
//////////////////////////////////////////////////////////////////////   


module testbench;

   reg clk = 0;
   reg cs;
   reg sr_in;
   reg [7:0] data;
   wire      sr_out;
   wire [7:0] gpioout;
   integer    i;

   spigpio testbe(.clk(clk),
		  .cs(cs),
		  .sr_in(sr_in),
		  .gpioout(gpioout),
		  .sr_out(sr_out));
   initial
     begin
	i = 0;
	data = 8'hAA;
	cs = 1'b0;
	for (i = 0; i<9; i = i+1)
	  begin
	     #10 clk = 1;
	     #10 clk = 0;
	  end
	cs =  1'b1;
	for (i=0; i<4; i = i + 1)
	  begin
	     #10 clk = 1;
	     #10 clk = 0;
	  end
     end 
   always @(negedge clk)
     begin
	sr_in =  data[7];
	data = data << 1;
     end
   initial
     begin
        $dumpfile("spigpio.vcd");
	$dumpvars(0,clk,cs,sr_in,gpioout,sr_out);
     end
endmodule
