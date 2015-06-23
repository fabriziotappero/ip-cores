//////////////////////////////////////////////////////////////////////
////                                                              ////
//// debouncer_tb.v                                               ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// debouncer testbench.                                         ////
////                                                              ////
//// To Do:                                                       ////
//// Done.                                                        ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Shannon Hill and OPENCORES.ORG            ////
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
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: debouncer_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module debouncer_tb();

reg    clk_i;
reg    rst_i;
reg    button_i;
wire   button_o;

integer count;

initial
begin
clk_i <= 0;
rst_i <= 1;
#10;
rst_i <= 0;
end

always @( button_o ) count = count + 1;

always #500 clk_i <= ~clk_i;  // 1000 ns clock

debouncer #(8) u_db ( /*AUTOINST*/
                     // Outputs
                     .button_o          (button_o),
                     // Inputs
                     .rst_i             (rst_i),
                     .clk_i             (clk_i),
                     .button_i          (button_i));
real    period;
integer i;

initial
begin
 button_i <= 0;
 period    = 250000.0;
 count     = 0;
 forever
 begin

   for( i = 0 ; i < 8 ; i = i + 1 ) 
   begin
    #(period);
     button_i <= ~button_i;  // 8 bounces 
   end

       period = period + 1000.0;

   if( period > 400000.0 )
     begin

     if( count == 1160 ) $display("OK");
                    else $display("%d: wrong number of output transitions, expect=1160, actual=%d",$time,count);

     $finish;
     end

 end
end

endmodule
