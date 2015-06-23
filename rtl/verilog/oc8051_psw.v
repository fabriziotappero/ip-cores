//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program status word                                    ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program status word                                        ////
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
// Revision 1.11  2003/04/09 15:49:42  simont
// Register oc8051_sfr dato output, add signal wait_data.
//
// Revision 1.10  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.9  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.8  2002/11/05 17:23:54  simont
// add module oc8051_sfr, 256 bytes internal ram
//
// Revision 1.7  2002/09/30 17:33:59  simont
// prepared header
//
//


// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_psw (clk, rst, wr_addr, data_in, wr, wr_bit, data_out, p,
                cy_in, ac_in, ov_in, set, bank_sel);
//
// clk          (in)  clock
// rst          (in)  reset
// addr         (in)  write address [oc8051_ram_wr_sel.out]
// data_in      (in)  data input [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// p            (in)  parity [oc8051_acc.p]
// cy_in        (in)  input bit data [oc8051_alu.desCy]
// ac_in        (in)  auxiliary carry input [oc8051_alu.desAc]
// ov_in        (in)  overflov input [oc8051_alu.desOv]
// set          (in)  set psw (write to caryy, carry and overflov or carry, owerflov and ac) [oc8051_decoder.psw_set -r]
//


input clk, rst, wr, p, cy_in, ac_in, ov_in, wr_bit;
input [1:0] set;
input [7:0] wr_addr, data_in;

output [1:0] bank_sel;
output [7:0] data_out;

reg [7:1] data;
wire wr_psw;

assign wr_psw = (wr & (wr_addr==`OC8051_SFR_PSW) && !wr_bit);

assign bank_sel = wr_psw ? data_in[4:3]:data[4:3];
assign data_out = {data[7:1], p};

//
//case writing to psw
always @(posedge clk or posedge rst)
begin
  if (rst)
    data <= #1 `OC8051_RST_PSW;

//
// write to psw (byte addressable)
  else begin
    if (wr & (wr_bit==1'b0) & (wr_addr==`OC8051_SFR_PSW))
      data[7:1] <= #1 data_in[7:1];
//
// write to psw (bit addressable)
    else if (wr & wr_bit & (wr_addr[7:3]==`OC8051_SFR_B_PSW))
      data[wr_addr[2:0]] <= #1 cy_in;
    else begin
      case (set) /* synopsys full_case parallel_case */
        `OC8051_PS_CY: begin
//
//write carry
          data[7] <= #1 cy_in;
        end
        `OC8051_PS_OV: begin
//
//write carry and overflov
          data[7] <= #1 cy_in;
          data[2] <= #1 ov_in;
        end
        `OC8051_PS_AC:begin
//
//write carry, overflov and ac
          data[7] <= #1 cy_in;
          data[6] <= #1 ac_in;
          data[2] <= #1 ov_in;

        end
      endcase
    end
  end
end

endmodule
