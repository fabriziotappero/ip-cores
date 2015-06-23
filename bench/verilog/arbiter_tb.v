//////////////////////////////////////////////////////////////////////
////                                                              ////
//// arbiter_tb.v                                                 ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// arbiter testbench.                                           ////
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
// $Id: arbiter_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module arbiter_tb();

reg    clk_i;
reg    rst_i;
reg   [7:0] reqst;
wire  [7:0] grant;

always #5 clk_i <= ~clk_i;

/* arbiter AUTO_TEMPLATE (
.grant (grant),
.reqst (reqst), 
); */

arbiter #(3) u_arb ( /*AUTOINST*/
                    // Outputs
                    .grant              (grant),                 // Templated
                    // Inputs
                    .rst_i              (rst_i),
                    .clk_i              (clk_i),
                    .reqst              (reqst));                 // Templated

reg  [2:0] count;
integer    passes;

initial
begin
 reqst  = 0;
 count  = 1;
 passes = 0;
 clk_i   <= 0;
 rst_i   <= 1;
 #10;
 rst_i   <= 0;
 @( posedge clk_i );

 forever
 begin

   reqst = 8'hFF;

   @( posedge clk_i );
   @( posedge clk_i );

   if( grant != (1<<count) )
   begin
      $display( "%d:bad grant, expect=%x, actual=%x", $time, 1<<count , grant );
      $stop;
   end

   reqst = 8'h00;

   @( posedge clk_i );
   @( posedge clk_i );

   if( |grant )
   begin
      $display( "%d:unexpected grant; actual=%x", $time, grant );
      $stop;
   end

   count  = count  + 1;

   passes = passes + 1;

   if( passes > 64 )
   begin
      $display("OK");
      $finish;
   end

 end
end

endmodule
