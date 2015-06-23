 module 
  cde_mult_generic 
    #( parameter 
      WIDTH=32)
     (
 input   wire                 alu_op_mul,
 input   wire                 clk,
 input   wire                 ex_freeze,
 input   wire                 reset,
 input   wire    [ WIDTH-1 :  0]        a_in,
 input   wire    [ WIDTH-1 :  0]        b_in,
 output   reg    [ 2*WIDTH-1 :  0]        mul_prod_r,
 output   wire                 mul_stall);
   //
   // Internal wires and regs
   //
reg ex_freeze_r;
  always @( posedge clk)
     if (reset) ex_freeze_r <= 1'b1;
     else       ex_freeze_r <= ex_freeze;
   wire [2*WIDTH-1:0] 			mul_prod;
   reg [1:0] 				mul_stall_count;   
always@(posedge clk)
if(mul_stall_count == 2'b10)
begin
   $display("%t %m mul (%x,%x,%x);",$realtime,a_in,b_in,mul_prod );
end
   or1200_gmultp2_32x32 or1200_gmultp2_32x32(
					     .X(a_in),
					     .Y(b_in),
					     .RST(reset),
					     .CLK(clk),
					     .P(mul_prod)
					     );
   always @( posedge clk)
     if (reset) begin
	mul_prod_r <=  64'h0000_0000_0000_0000;
     end
     else begin
	mul_prod_r <=  mul_prod[63:0];
     end
   //
   // Generate stall signal during multiplication
   //
   always @( posedge clk)
     if (reset)
       mul_stall_count <= 0;
     else if (!(|mul_stall_count))
       mul_stall_count <= {mul_stall_count[0], alu_op_mul & !ex_freeze_r};
     else 
       mul_stall_count <= {mul_stall_count[0],1'b0};
   assign mul_stall = (|mul_stall_count) | 
		      (!(|mul_stall_count) & alu_op_mul & !ex_freeze_r);
  endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic 32x32 multiplier                                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/project,or1k                       ////
////                                                              ////
////  Description                                                 ////
////  Generic 32x32 multiplier with pipeline stages.              ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
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
// $Log: or1200_gmultp2_32x32.v,v $
// Revision 2.0  2010/06/30 11:00:00  ORSoC
// No update 
//
// synopsys translate_off
// synopsys translate_on
// 32x32 multiplier, no input/output registers
// Registers inside Wallace trees every 8 full adder levels,
// with first pipeline after level 4
module or1200_gmultp2_32x32 ( X, Y, CLK, RST, P );
input   [32-1:0]  X;
input   [32-1:0]  Y;
input           CLK;
input           RST;
output  [64-1:0]  P;
reg     [64-1:0]  p0;
reg     [64-1:0]  p1;
integer 		  xi;
integer 		  yi;
//
// Conversion unsigned to signed
//
always @(X)
	xi = X;
//
// Conversion unsigned to signed
//
always @(Y)
	yi = Y;
//
// First multiply stage
//
always @(posedge CLK )
        if (RST)
                p0 <= 64'b0;
        else
                p0 <=  xi * yi;
//
// Second multiply stage
//
always @(posedge CLK )
        if (RST)
                p1 <= 64'b0;
        else
                p1 <=  p0;
assign P = p1;
endmodule
