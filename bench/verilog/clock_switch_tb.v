//////////////////////////////////////////////////////////////////////
////                                                              ////
//// clock_switch_tb.v                                            ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// Clock switcher testbench.                                    ////
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
// $Id: clock_switch_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module clock_switch_tb();

reg       clock;
reg       clk0_i;
reg       clk1_i;
reg       clk2_i;
reg       clk3_i;
reg       clk4_i;
reg       clk5_i;
reg       clk6_i;
reg       clk7_i;

reg       rst0_i;
reg       rst1_i;
reg       rst2_i;
reg       rst3_i;
reg       rst4_i;
reg       rst5_i;
reg       rst6_i;
reg       rst7_i;

reg       enable;
reg [2:0] select;

real  launch_b2;
real  launch_b3;
real  launch_b4;
real  launch_b8;

real  actual_b2;
real  actual_b3;
real  actual_b4;
real  actual_b8;

real  expect_b2;
real  expect_b3;
real  expect_b4;
real  expect_b8;

integer passes;

initial
begin

 passes    = 0;

 launch_b2 = 0.0;
 launch_b3 = 0.0;
 launch_b4 = 0.0;
 launch_b8 = 0.0;

 actual_b2 = 0.0;
 actual_b3 = 0.0;
 actual_b4 = 0.0;
 actual_b8 = 0.0;

 clock    <= 0;

 clk0_i   <= 0;
 clk1_i   <= 0;
 clk2_i   <= 0;
 clk3_i   <= 0;
 clk4_i   <= 0;
 clk5_i   <= 0;
 clk6_i   <= 0;
 clk7_i   <= 0;

 rst0_i   <= 1;
 rst1_i   <= 1;
 rst2_i   <= 1;
 rst3_i   <= 1;
 rst4_i   <= 1;
 rst5_i   <= 1;
 rst6_i   <= 1;
 rst7_i   <= 1;

 enable   <= 1;
 select   <= 1;

#10;
 rst0_i   <= 0;
 rst1_i   <= 0;
 rst2_i   <= 0;
 rst3_i   <= 0;
 rst4_i   <= 0;
 rst5_i   <= 0;
 rst6_i   <= 0;
 rst7_i   <= 0;
end

always #50     clock  <= ~clock;

parameter C0P = 3.00;
parameter C1P = 4.00;
parameter C2P = 5.00;
parameter C3P = 6.00;
parameter C4P = 7.00;
parameter C5P = 8.00;
parameter C6P = 9.00;
parameter C7P = 10.00;

always #(C0P/2.0) clk0_i <= ~clk0_i;
always #(C1P/2.0) clk1_i <= ~clk1_i;
always #(C2P/2.0) clk2_i <= ~clk2_i;
always #(C3P/2.0) clk3_i <= ~clk3_i;
always #(C4P/2.0) clk4_i <= ~clk4_i;
always #(C5P/2.0) clk5_i <= ~clk5_i;
always #(C6P/2.0) clk6_i <= ~clk6_i;
always #(C7P/2.0) clk7_i <= ~clk7_i;

wire  clock_b2;
wire  clock_b3;
wire  clock_b4;
wire  clock_b8;

always @( posedge clock_b2 )
begin
 actual_b2 = $realtime - launch_b2;
 launch_b2 = $realtime;
end

always @( posedge clock_b3 )
begin
 actual_b3 = $realtime - launch_b3;
 launch_b3 = $realtime;
end

always @( posedge clock_b4 )
begin
 actual_b4 = $realtime - launch_b4;
 launch_b4 = $realtime;
end

always @( posedge clock_b8 )
begin
 actual_b8 = $realtime - launch_b8;
 launch_b8 = $realtime;
end

always @( posedge clock )
begin

    case( select[0] )
    1'b0: expect_b2 = C0P;
    1'b1: expect_b2 = C1P;
    endcase

    case( select[1:0] )
    2'b00: expect_b3 = C0P;
    2'b01: expect_b3 = C1P;
    2'b10: expect_b3 = C2P;
    2'b11: expect_b3 = C2P;
    endcase

    case( select[1:0] )
    2'b00: expect_b4 = C0P;
    2'b01: expect_b4 = C1P;
    2'b10: expect_b4 = C2P;
    2'b11: expect_b4 = C3P;
    endcase

    case( select[2:0] )
    3'b000: expect_b8 = C0P;
    3'b001: expect_b8 = C1P;
    3'b010: expect_b8 = C2P;
    3'b011: expect_b8 = C3P;
    3'b100: expect_b8 = C4P;
    3'b101: expect_b8 = C5P;
    3'b110: expect_b8 = C6P;
    3'b111: expect_b8 = C7P;
    endcase

    if( (launch_b2 > 0.0) & (expect_b2 != actual_b2))
    begin
     $display( "%d: expect_b2=%f, actual_b2=%f", $time, expect_b2, actual_b2);
     $stop;
    end

    if( (launch_b3 > 0.0) & (expect_b3 != actual_b3))
    begin
     $display( "%d: expect_b3=%f, actual_b3=%f", $time, expect_b3, actual_b3);
     $stop;
    end

    if( (launch_b4 > 0.0) & (expect_b4 != actual_b4))
    begin
     $display( "%d: expect_b4=%f, actual_b4=%f", $time, expect_b4, actual_b4);
     $stop;
    end

    if( (launch_b8 > 0.0) & (expect_b8 != actual_b8))
    begin
     $display( "%d: expect_b8=%f, actual_b8=%f", $time, expect_b8, actual_b8);
     $stop;
    end

    select <= select + 1;

    passes  = passes + 1;

    if( passes > 256 )
    begin
        $display("OK");
        $finish;
    end
end

/* clock_switch2_basic AUTO_TEMPLATE (
.select    (select[0]),
.clk_o     (clock_b2),
); */

clock_switch2_basic u_b2 ( /*AUTOINST*/
                          // Outputs
                          .clk_o        (clock_b2),              // Templated
                          // Inputs
                          .rst0_i       (rst0_i),
                          .clk0_i       (clk0_i),
                          .rst1_i       (rst1_i),
                          .clk1_i       (clk1_i),
                          .enable       (enable),
                          .select       (select[0]));             // Templated

/* clock_switch3_basic AUTO_TEMPLATE (
.select    (select[1:0]), 
.clk_o     (clock_b3),  
); */

clock_switch3_basic u_b3 ( /*AUTOINST*/
                          // Outputs
                          .clk_o        (clock_b3),              // Templated
                          // Inputs
                          .rst0_i       (rst0_i),
                          .clk0_i       (clk0_i),
                          .rst1_i       (rst1_i),
                          .clk1_i       (clk1_i),
                          .rst2_i       (rst2_i),
                          .clk2_i       (clk2_i),
                          .enable       (enable),
                          .select       (select[1:0]));           // Templated

/* clock_switch4_basic AUTO_TEMPLATE (
.select     (select[1:0]), 
.clk_o      (clock_b4),  
); */

clock_switch4_basic u_b4 ( /*AUTOINST*/
                          // Outputs
                          .clk_o        (clock_b4),              // Templated
                          // Inputs
                          .rst0_i       (rst0_i),
                          .clk0_i       (clk0_i),
                          .rst1_i       (rst1_i),
                          .clk1_i       (clk1_i),
                          .rst2_i       (rst2_i),
                          .clk2_i       (clk2_i),
                          .rst3_i       (rst3_i),
                          .clk3_i       (clk3_i),
                          .enable       (enable),
                          .select       (select[1:0]));           // Templated

/* clock_switch8_basic AUTO_TEMPLATE (
.select     (select[2:0]), 
.clk_o      (clock_b8),  
); */

clock_switch8_basic u_b8 ( /*AUTOINST*/
                          // Outputs
                          .clk_o        (clock_b8),              // Templated
                          // Inputs
                          .rst0_i       (rst0_i),
                          .clk0_i       (clk0_i),
                          .rst1_i       (rst1_i),
                          .clk1_i       (clk1_i),
                          .rst2_i       (rst2_i),
                          .clk2_i       (clk2_i),
                          .rst3_i       (rst3_i),
                          .clk3_i       (clk3_i),
                          .rst4_i       (rst4_i),
                          .clk4_i       (clk4_i),
                          .rst5_i       (rst5_i),
                          .clk5_i       (clk5_i),
                          .rst6_i       (rst6_i),
                          .clk6_i       (clk6_i),
                          .rst7_i       (rst7_i),
                          .clk7_i       (clk7_i),
                          .enable       (enable),
                          .select       (select[2:0]));           // Templated

reg     notify;
initial notify = 0;

always @( posedge notify ) $stop;

specify
specparam c_width = 1.50;  // is C0P/2.0

// check for narrow pulses
$width( negedge clock_b2, c_width, 0, notify );
$width( posedge clock_b2, c_width, 0, notify );

$width( negedge clock_b3, c_width, 0, notify );
$width( posedge clock_b3, c_width, 0, notify );

$width( negedge clock_b4, c_width, 0, notify );
$width( posedge clock_b4, c_width, 0, notify );

$width( negedge clock_b8, c_width, 0, notify );
$width( posedge clock_b8, c_width, 0, notify );

endspecify

endmodule
