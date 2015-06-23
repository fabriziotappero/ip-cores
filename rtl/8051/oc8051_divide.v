//////////////////////////////////////////////////////////////////////
//// 								  ////
//// divide for 8051 Core 				  	  ////
//// 								  ////
//// This file is part of the 8051 cores project 		  ////
//// http://www.opencores.org/cores/8051/ 			  ////
//// 								  ////
//// Description 						  ////
//// Four cycle implementation of division used in alu.v	  ////
//// 								  ////
//// To Do: 							  ////
////  check if compiler does proper optimizations of the code     ////
//// 								  ////
//// Author(s): 						  ////
//// - Simon Teran, simont@opencores.org 			  ////
//// - Marko Mlinar, markom@opencores.org 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//// 								  ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG 		  ////
//// 								  ////
//// This source file may be used and distributed without 	  ////
//// restriction provided that this copyright statement is not 	  ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
//// 								  ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version. 						  ////
//// 								  ////
//// This source is distributed in the hope that it will be 	  ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	  ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details. 							  ////
//// 								  ////
//// You should have received a copy of the GNU Lesser General 	  ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.8  2002/09/30 17:15:31  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

module oc8051_divide (clk, rst, enable, src1, src2, des1, des2, desOv);
//
// this module is part of alu
// clk          (in)
// rst          (in)
// enable       (in)  starts divison
// src1         (in)  first operand
// src2         (in)  second operand
// des1         (out) first result
// des2         (out) second result
// desOv        (out) Overflow output
//

input clk, rst, enable;
input [7:0] src1, src2;
output desOv;
output [7:0] des1, des2;

// wires
wire desOv;
wire div0, div1;
wire [7:0] rem0, rem1, rem2;
wire [8:0] sub0, sub1;
wire [15:0] cmp0, cmp1;
wire [7:0] div_out, rem_out;

// real registers
reg [1:0] cycle;
reg [5:0] tmp_div;
reg [7:0] tmp_rem;

// The main logic
assign cmp1 = src2 << ({2'h3 - cycle, 1'b0} + 3'h1);
assign cmp0 = src2 << ({2'h3 - cycle, 1'b0} + 3'h0);

assign rem2 = cycle != 0 ? tmp_rem : src1;

assign sub1 = {1'b0, rem2} - {1'b0, cmp1[7:0]};
assign div1 = |cmp1[15:8] ? 1'b0 : !sub1[8];
assign rem1 = div1 ? sub1[7:0] : rem2[7:0];

assign sub0 = {1'b0, rem1} - {1'b0, cmp0[7:0]};
assign div0 = |cmp0[15:8] ? 1'b0 : !sub0[8];
assign rem0 = div0 ? sub0[7:0] : rem1[7:0];

//
// in clock cycle 0 we first calculate two MSB bits, ...
// till finally in clock cycle 3 we calculate two LSB bits
assign div_out = {tmp_div, div1, div0};
assign rem_out = rem0;
assign desOv = src2 == 8'h0;

//
// divider works in four clock cycles -- 0, 1, 2 and 3
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    cycle <= #1 2'b0;
    tmp_div <= #1 6'h0;
    tmp_rem <= #1 8'h0;
  end else begin
    if (enable) cycle <= #1 cycle + 2'b1;
    tmp_div <= #1 div_out[5:0];
    tmp_rem <= #1 rem_out;
  end
end

//
// assign outputs
assign des1 = rem_out;
assign des2 = div_out;

endmodule
