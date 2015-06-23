//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic 32x32 multiplier                                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
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
// $Log: not supported by cvs2svn $
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.4  2001/12/04 05:02:35  lampret
// Added OR1200_GENERIC_MULTP2_32X32 and OR1200_ASIC_MULTP2_32X32
//
// Revision 1.3  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.2  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.2  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

// 32x32 multiplier, no input/output registers
// Registers inside Wallace trees every 8 full adder levels,
// with first pipeline after level 4

`ifdef OR1200_GENERIC_MULTP2_32X32

`define OR1200_W 32
`define OR1200_WW 64

module or1200_gmultp2_32x32_cm2 (
		clk_i_cml_1,
		 X, Y, CLK, RST, P );


input clk_i_cml_1;
reg [ 64 - 1 : 0 ] p0_cml_1;
reg [ 64 - 1 : 0 ] p1_cml_1;



input   [`OR1200_W-1:0]  X;
input   [`OR1200_W-1:0]  Y;
input           CLK;
input           RST;
output  [`OR1200_WW-1:0]  P;

reg     [`OR1200_WW-1:0]  p0;
reg     [`OR1200_WW-1:0]  p1;
integer 		  xi;
integer 		  yi;

//
// Conversion unsigned to signed
//
always @(X)
	xi <= X;

//
// Conversion unsigned to signed
//
always @(Y)
	yi <= Y;

//
// First multiply stage
//


// SynEDA CoreMultiplier
// assignment(s): p0
// replace(s): p0
always @(posedge CLK) 
                p0 <= #1 xi * yi;


//
// Second multiply stage
//

// SynEDA CoreMultiplier
// assignment(s): p1
// replace(s): p0, p1
always @(posedge CLK) 
		p1 <= #1 p0_cml_1; 


// SynEDA CoreMultiplier
// assignment(s): P
// replace(s): p1
assign P = p1_cml_1;


always @ (posedge CLK) begin
p0_cml_1 <= p0;
p1_cml_1 <= p1;
end

endmodule


`endif
