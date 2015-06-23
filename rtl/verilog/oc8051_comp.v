//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 compare                                                ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   compares selected inputs and set eq to 1 if they are equal ////
////   Is used for conditional jumps.                             ////
////                                                              ////
////  To Do:                                                      ////
////   replace CSS_AZ with CSS_DES                                ////
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
// Revision 1.7  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.6  2003/04/02 11:26:21  simont
// updating...
//
// Revision 1.5  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_comp (sel, b_in, cy, acc, des, /*comp_wait, */eq);
//
// sel          (in)  select whithc sourses to compare (look defines.v) [oc8051_decoder.comp_sel]
// b_in         (in)  bit in - output from bit addressable memory space [oc8051_ram_sel.bit_out]
// cy           (in)  carry flag [oc8051_psw.data_out[7] ]
// acc          (in)  accumulator [oc8051_acc.data_out]
// ram          (in)  input from ram [oc8051_ram_sel.out_data]
// op2          (in)  immediate data [oc8051_op_select.op2_out -r]
// des          (in)  destination from alu [oc8051_alu.des1 -r]
// eq           (out) if (src1 == src2) eq = 1  [oc8051_decoder.eq]
//


input [1:0] sel;
input b_in, cy/*, comp_wait*/;
input [7:0] acc, des;

output eq;

reg eq_r;

assign eq = eq_r;// & comp_wait;


always @(sel or b_in or cy or acc or des)
begin
  case (sel) /* synopsys full_case parallel_case */
    `OC8051_CSS_AZ  : eq_r = (acc == 8'h00);
    `OC8051_CSS_DES : eq_r = (des == 8'h00);
    `OC8051_CSS_CY  : eq_r = cy;
    `OC8051_CSS_BIT : eq_r = b_in;
  endcase
end

endmodule
