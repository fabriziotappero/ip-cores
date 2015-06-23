//////////////////////////////////////////////////////////////////////
////                                                              ////
//// clock_detect_tb.v                                            ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// Clock detect testbench.                                      ////
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
// $Id: clock_detect_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module clock_detect_tb();

reg       clk0_i;
reg       clk1_i;
reg       clk2_i;
reg       clk3_i;

reg       rst0_i;

wire   alive1;
wire   alive2;
wire   alive3;


initial
begin
 clk0_i   <= 0;
 clk1_i   <= 0;
 clk2_i   <= 0;
 clk3_i   <= 0;
 rst0_i   <= 1;
#10;
 rst0_i   <= 0;
#5000;
 if( alive1 & alive2 & ~alive3 ) $display("OK");
                            else $display("BAD");
 $finish;
end

always #5      clk0_i <= ~clk0_i;  // 10 ns

always #150    clk1_i <= ~clk1_i;
always #160    clk2_i <= ~clk2_i;
always #170    clk3_i <= ~clk3_i;

/* clock_detect AUTO_TEMPLATE (
.rst_i     (rst0_i),
.clk_i     (clk0_i),
.sclk_i    (clk1_i),
.alive_o   (alive1),
); */

clock_detect #(4) u_d1 ( /*AUTOINST*/
                        // Outputs
                        .alive_o        (alive1),                // Templated
                        // Inputs
                        .rst_i          (rst0_i),                // Templated
                        .clk_i          (clk0_i),                // Templated
                        .sclk_i         (clk1_i));                // Templated

/* clock_detect AUTO_TEMPLATE (
.rst_i     (rst0_i),
.clk_i     (clk0_i),
.sclk_i    (clk2_i),
.alive_o   (alive2),
); */

clock_detect #(4) u_d2 ( /*AUTOINST*/
                        // Outputs
                        .alive_o        (alive2),                // Templated
                        // Inputs
                        .rst_i          (rst0_i),                // Templated
                        .clk_i          (clk0_i),                // Templated
                        .sclk_i         (clk2_i));                // Templated

/* clock_detect AUTO_TEMPLATE (
.rst_i     (rst0_i),
.clk_i     (clk0_i),
.sclk_i    (clk3_i),
.alive_o   (alive3),
); */

clock_detect #(4) u_d3 ( /*AUTOINST*/
                        // Outputs
                        .alive_o        (alive3),                // Templated
                        // Inputs
                        .rst_i          (rst0_i),                // Templated
                        .clk_i          (clk0_i),                // Templated
                        .sclk_i         (clk3_i));                // Templated


endmodule
