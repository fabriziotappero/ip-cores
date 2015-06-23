//////////////////////////////////////////////////////////////////////
////                                                              ////
//// oc_fifo_basic_tb.v                                           ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// One Clock Fifo Testbench                                     ////
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
// $Id: oc_fifo_basic_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module oc_fifo_basic_tb();

parameter AW = 3;
parameter DW = 8;

reg            clk_i;
reg            rst_i;

reg            give;
reg  [DW-1:0]  give_di;

reg            take;
wire [DW-1:0]  take_do;

reg  [DW-1:0]  exp_do;

reg  [7:0]     take_timeout;
reg  [7:0]     give_timeout;

wire           have;
wire           need;

reg            give_allow;

real           period;

integer        passes;

initial
begin

 rst_i       <= 1;
 clk_i       <= 0;
 give        <= 0;
 give_di     <= 0;
 take        <= 0;
 exp_do      <= 0;
#200;

 rst_i       <= 0;
end

initial
begin

 passes = 0;
 period = 4.0;

 give_allow <= 0;

 forever
 begin

    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );

    give_allow <= 1;
    #5000;
    give_allow <= 0;

    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );
    @( posedge clk_i );

    passes = passes + 1;

    if( passes > 256 )
    begin
     $display("OK");
     $finish;
    end
 end
end

always #(period/2.0) clk_i = ~clk_i;

always @( posedge clk_i )
begin

     give   <= 0;

if( ~rst_i & need & give_allow ) give <= 1;
if(          need & give       ) give_di <= give_di + 1;
end

always @( posedge clk_i )
begin

    take <= have & ~rst_i;

if( take & have )
begin
   if( exp_do !== take_do )
    begin
    $display( "%d: expected != actual; exp_do=%x take_do=%x", $time,exp_do,take_do);
    $stop;
    end
    exp_do <= exp_do + 1;
end
end

oc_fifo_basic #(AW,DW) u_fifo( /*AUTOINST*/
                              // Outputs
                              .have     (have),
                              .take_do  (take_do[DW-1:0]),
                              .need     (need),
                              // Inputs
                              .rst_i    (rst_i),
                              .clk_i    (clk_i),
                              .take     (take),
                              .give     (give),
                              .give_di  (give_di[DW-1:0]));

always @( posedge clk_i )
begin
if( &take_timeout )
begin
 $display( "%d: take inactive for too long.", $time);
 $stop;
end

if( take | rst_i )
     take_timeout <= 0;
else take_timeout <= take_timeout + 1;
end

always @( posedge clk_i )
begin
if( &give_timeout )
begin
 $display( "%d: give inactive too long.", $time);
 $stop;
end

if( give | rst_i )
     give_timeout <= 0;
else give_timeout <= give_timeout + 1;
end

endmodule
