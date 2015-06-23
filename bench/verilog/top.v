//////////////////////////////////////////////////////////////////////
////                                                              ////
////  RNG main simulation file                                    ////
////                                                              ////
////  This file is part of the SystemC RNG                        ////
////                                                              ////
////  Description:                                                ////
////  RNG main simulation file                                    ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, javier.castillo@urjc.es              ////
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
// Revision 1.1  2004/09/23 09:45:06  jcastillo
// Verilog first import
//

`timescale 10ns/1ns

module top;


reg clk;
reg reset;
reg loadseed_i;

reg [31:0] seed_i;
wire [31:0] number_o;

rng r1(clk,reset,loadseed_i,seed_i,number_o);

   initial

   begin
     clk = 1'b1;
     reset = 1'b1;  
     loadseed_i = 1'b0;
     seed_i=32'h12345678;     
     @(posedge clk);
     reset = #1 1'b0;
     @(posedge clk);
     reset = #1 1'b1;
     @(posedge clk);
	 loadseed_i = #1 1'b1;
	 @(posedge clk);
	 loadseed_i = #1 1'b0;
	 
	 while(1)
	 begin
	   @(posedge clk);
       $display("%H",number_o);
	 end
	
	
     $finish;

   end
   
   always #5 clk = !clk;

endmodule
