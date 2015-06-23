//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 main simulation file                                    ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 main simulation file                                    ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
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

`timescale 1ns/100ps

module md5_tb;


reg clk;
reg reset;
reg load_i;
wire ready_o;
reg newtext_i;

reg [127:0] data_i;
wire [127:0] data_o;

md5 DUT(clk,reset,load_i,ready_o,newtext_i,data_i,data_o);

   initial

   begin
     clk = 'b1;
     reset = 'b1;  
     load_i = 'b0;
     newtext_i= 'b0;
     //data_i=128'h00008061000000000000000000000000;
	  data_i = 128'h5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a;
     @(posedge clk);
     reset = #1 'b0;
     @(posedge clk);
     reset = #1 'b1;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     load_i = #1 'b0;
     //data_i= 128'h0;
	  data_i = 128'h5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     @(posedge clk);
     load_i = #1 'b0;
	  //data_i = 128'h8000000000;
     data_i= 128'h00000080000000000000018000000000;
	  //data_i = 128'h5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a;
     @(posedge clk);
     load_i =#1 'b1;
     @(posedge clk);
     load_i = #1 'b0;
	
	
     $display("Running test:");
     wait(ready_o);	
     $display("Hash for \"a\":");
     $display("%H",data_o);
		
     @(posedge clk);
     newtext_i=#1'b1;	
     @(posedge clk);
     newtext_i=#1'b0;		
		
     @(posedge clk);
     data_i=128'h61616161616161616161616161616161;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     load_i = #1 'b0;
     wait(ready_o);	
		
     @(posedge clk);
     data_i=128'h61616161616161616161616161616161;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     @(posedge clk);
     load_i = #1 'b0;
     data_i=128'h80000000000000000000000000;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     load_i = #1 'b0;
     data_i=128'h10000000000;
     @(posedge clk);
     load_i = #1 'b1;
     @(posedge clk);
     load_i = #1 'b0;
     wait(ready_o);	
     $display("Hash for two blocks full of \"a\":");
     $display("%H",data_o);
	
	
     $stop;

   end
   
   always #5 clk = !clk;

endmodule
