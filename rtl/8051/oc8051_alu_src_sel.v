//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 alu source select module                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select data on alu sources      ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
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
// Revision 1.3  2003/06/03 17:13:57  simont
// remove pc_r register.
//
// Revision 1.2  2003/05/06 09:41:35  simont
// remove define OC8051_AS2_PCL, chane signal src_sel2 to 2 bit wide.
//
// Revision 1.1  2003/01/13 14:13:12  simont
// initial import
//
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_alu_src_sel (clk, rst, rd, sel1, sel2, sel3,
                     acc, ram, pc, dptr,

                     op1, op2, op3,

                     src1, src2, src3);


input clk, rst, rd, sel3;
input [1:0] sel2;
input [2:0] sel1;
input [7:0] acc, ram;
input [15:0] dptr;
input [15:0] pc;


input [7:0] op1, op2, op3;

output [7:0] src1, src2, src3;

reg [7:0] src1, src2, src3;

reg [7:0] op1_r, op2_r, op3_r;

///////
//
// src1
//
///////
always @(sel1 or op1_r or op2_r or op3_r or pc or acc or ram)
begin
  case (sel1) /* synopsys full_case parallel_case */
    `OC8051_AS1_RAM: src1 = ram;
    `OC8051_AS1_ACC: src1 = acc;
    `OC8051_AS1_OP1: src1 = op1_r;
    `OC8051_AS1_OP2: src1 = op2_r;
    `OC8051_AS1_OP3: src1 = op3_r;
    `OC8051_AS1_PCH: src1 = pc[15:8];
    `OC8051_AS1_PCL: src1 = pc[7:0];
//    default: src1 = 8'h00;
  endcase
end

///////
//
// src2
//
///////
always @(sel2 or op2_r or acc or ram or op1_r)
begin
  case (sel2) /* synopsys full_case parallel_case */
    `OC8051_AS2_ACC: src2= acc;
    `OC8051_AS2_ZERO: src2= 8'h00;
    `OC8051_AS2_RAM: src2= ram;
    `OC8051_AS2_OP2: src2= op2_r;
//    default: src2= 8'h00;
  endcase
end

///////
//
// src3
//
///////

always @(sel3 or pc[15:8] or dptr[15:8] or op1_r)
begin
  case (sel3) /* synopsys full_case parallel_case */
    `OC8051_AS3_DP:   src3= dptr[15:8];
    `OC8051_AS3_PC:   src3= pc[15:8];
//    default: src3= 16'h0;
  endcase
end


always @(posedge clk or posedge rst)
  if (rst) begin
    op1_r <= #1 8'h00;
    op2_r <= #1 8'h00;
    op3_r <= #1 8'h00;
  end else begin
    op1_r <= #1 op1;
    op2_r <= #1 op2;
    op3_r <= #1 op3;
  end

endmodule
