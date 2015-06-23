//////////////////////////////////////////////////////////////////////
////                                                              ////
//// bc_fifo_basic_tb.v                                           ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
////  Async Boundary Crossing Fifo Testbench                      ////
////   --sweep put_clk_i                                          ////
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
// $Id: bc_fifo_basic_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
`timescale 1ns/1ps

module bc_fifo_basic_tb();

parameter AW = 2;
parameter DW = 8;

reg            put_clk_i;
reg            put;
reg  [DW-1:0]  put_di;

reg            get_clk_i;
reg            get;
wire [DW-1:0]  get_do;

reg  [DW-1:0]  exp_do;

reg  [7:0]     get_timeout;
reg  [7:0]     put_timeout;

wire           get_have;
wire           put_need;

wire           get_h = get & get_have;
wire           put_n = put & put_need;

reg            put_rst_i;
reg            get_rst_i;

reg            put_allow;

real           put_period;
real           get_period;

initial
begin

 put_rst_i   <= 1;
 get_rst_i   <= 1;

 put_clk_i   <= 0;
 put         <= 0;
 put_di      <= 0;
 put_timeout <= 0;

 get_clk_i   <= 0;
 get         <= 0;
 get_timeout <= 0;

 exp_do      <= 0;

#200;
 put_rst_i   <= 0;
 get_rst_i   <= 0;
end

integer mt_seed;

initial
begin
 get_period = 8.0;
 put_period = 8.0;
 mt_seed    = 18788;

 put_allow <= 0;

 forever
 begin

// vary the put clock

   for( put_period = 1.0; put_period < 64.0 ; put_period = put_period + 0.1 )
   begin

     @( posedge put_clk_i );
     @( posedge put_clk_i );
     put_allow <= 1;
     #5000;
     put_allow <= 0;
     @( posedge put_clk_i );

    end

    #100;
    $display("OK");
    $finish;
 end
end

always #(put_period/2.0) put_clk_i = ~put_clk_i;
always #(get_period/2.0) get_clk_i = ~get_clk_i;

always @( posedge put_clk_i )
begin

     put    <= 0;

if( ~put_rst_i & put_need & put_allow ) put <= 1;

if(        put & put_need ) put_di <= put_di + 1;

end

always @( posedge get_clk_i )
begin

    get <= get_have & ~get_rst_i;

if( get & get_have )
begin

   if( exp_do !== get_do )
    begin
    $display( "%d: expected != actual; exp_do=%x get_do=%x", $time,exp_do,get_do);
    $stop;
    end

    exp_do <= exp_do + 1;
end
end

/* bc_fifo_basic AUTO_TEMPLATE (
.put_di    (put_di),
.get_do    (get_do),
); */

bc_fifo_basic #(AW,DW)
              u_fifo( /*AUTOINST*/
                     // Outputs
                     .get_do            (get_do),                // Templated
                     .get_have          (get_have),
                     .put_need          (put_need),
                     // Inputs
                     .put_rst_i         (put_rst_i),
                     .get_rst_i         (get_rst_i),
                     .get_clk_i         (get_clk_i),
                     .get               (get),
                     .put_clk_i         (put_clk_i),
                     .put_di            (put_di),                // Templated
                     .put               (put));


always @( posedge get_clk_i )
begin
if( &get_timeout )
begin
 $display( "%d: get_have inactive for too long.", $time);
 $stop;
end

if( get_have | get_rst_i )
     get_timeout <= 0;
else get_timeout <= get_timeout + 1;
end


always @( posedge put_clk_i )
begin
if( &put_timeout )
begin
 $display( "%d: put_need inactive too long.", $time);
 $stop;
end

if( put_need | put_rst_i )
     put_timeout <= 0;
else put_timeout <= put_timeout + 1;
end

endmodule
