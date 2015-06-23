//////////////////////////////////////////////////////////////////////
////                                                              ////
//// clock_switch4_basic.v                                        ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// 1-of-4 glitchless clock switcher                             ////
////                                                              ////
//// The 4 clocks, enable, and select are assumed to be           ////
//// asynchronous.                                                ////
////                                                              ////
//// Selecting/deselecting a stopped clock is not handled.        ////
////                                                              ////
//// To Do:                                                       ////
//// Verify in silicon.                                           ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
//// (based on "Techniques to make clock switching glitch free"   ////
//// By Rafey Mahmud; EEdesign.com June 26, 2003)                 ////
////                                                              ////
//// http://www.eedesign.com/showArticle.jhtml?articleID=16501239 ////
////                                                              ////
//// (modified to use only positive edge flops; stall the output  ////
////  clock high).                                                ////
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
// $Id: clock_switch4_basic.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module clock_switch4_basic( /*AUTOARG*/
// Outputs
clk_o, 
// Inputs
rst0_i, clk0_i, rst1_i, clk1_i, rst2_i, clk2_i, rst3_i, clk3_i, 
enable, select
);

input        rst0_i;
input        clk0_i;
input        rst1_i;
input        clk1_i;
input        rst2_i;
input        clk2_i;
input        rst3_i;
input        clk3_i;
input        enable;   // start/stop clock
input  [1:0] select;   // select a source clock
output       clk_o;

reg    [1:0] ssync0;   // selection synchronizers...
reg    [1:0] ssync1;
reg    [1:0] ssync2;
reg    [1:0] ssync3;

reg    [3:0] decode;   // 1-of-4 decode

always @( select or enable )
begin
          decode    = 4'h0;
 case( select )
 2'b00:   decode[0] = enable;
 2'b01:   decode[1] = enable;
 2'b10:   decode[2] = enable;
 2'b11:   decode[3] = enable;
 default: decode    = 4'h0;
 endcase
end

always @( posedge clk0_i or posedge rst0_i )
if( rst0_i )
     ssync0 <=   2'b0;
else ssync0 <= { ssync0[0], ( decode[0] & ~ssync1[1] & ~ssync2[1] & ~ssync3[1] ) }; // async input

always @( posedge clk1_i or posedge rst1_i )
if( rst1_i )
     ssync1 <=   2'b0;
else ssync1 <= { ssync1[0], (~ssync0[1] &  decode[1] & ~ssync2[1] & ~ssync3[1] ) }; // async input

always @( posedge clk2_i or posedge rst2_i )
if( rst2_i )
     ssync2 <=   2'b0;
else ssync2 <= { ssync2[0], (~ssync0[1] & ~ssync1[1] &  decode[2] & ~ssync3[1] ) }; // async input

always @( posedge clk3_i or posedge rst3_i )
if( rst3_i )
     ssync3 <=   2'b0;
else ssync3 <= { ssync3[0], (~ssync0[1] & ~ssync1[1] & ~ssync2[1] &  decode[3] ) }; // async input

wire gclk0 = ~ssync0[1] | clk0_i; // forced high when not selected
wire gclk1 = ~ssync1[1] | clk1_i; // forced high when not selected
wire gclk2 = ~ssync2[1] | clk2_i; // forced high when not selected
wire gclk3 = ~ssync3[1] | clk3_i; // forced high when not selected

wire clk_o =  gclk0 & gclk1 & gclk2 & gclk3; // clock stalls high

endmodule
