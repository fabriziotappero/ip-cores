//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Programmable Interrupt Controller                  ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  PIC according to OR1K architectural specification.          ////
////                                                              ////
////  To Do:                                                      ////
////   None                                                       ////
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
// Revision 1.3  2002/03/29 15:16:56  lampret
// Some of the warnings fixed.
//
// Revision 1.2  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.8  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.7  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.2  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.1  2001/07/20 00:46:21  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_pic_cm4(
		clk_i_cml_1,
		clk_i_cml_2,
		clk_i_cml_3,
		
	// RISC Internal Interface
	clk, rst, spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o,
	pic_wakeup, intr,
	
	// PIC Interface
	pic_int
);


input clk_i_cml_1;
input clk_i_cml_2;
input clk_i_cml_3;
reg  spr_write_cml_3;
reg  spr_write_cml_2;
reg  spr_write_cml_1;
reg [ 31 : 0 ] spr_addr_cml_3;
reg [ 31 : 0 ] spr_addr_cml_2;
reg [ 31 : 0 ] spr_addr_cml_1;
reg [ 31 : 0 ] spr_dat_i_cml_3;
reg [ 31 : 0 ] spr_dat_i_cml_2;
reg [ 31 : 0 ] spr_dat_i_cml_1;
reg  intr_cml_3;
reg  intr_cml_2;
reg [ 20 - 1 : 0 ] pic_int_cml_1;
reg [ 20 - 1 : 2 ] picmr_cml_3;
reg [ 20 - 1 : 2 ] picmr_cml_2;
reg [ 20 - 1 : 2 ] picmr_cml_1;
reg [ 20 - 1 : 0 ] picsr_cml_3;
reg [ 20 - 1 : 0 ] picsr_cml_2;
reg [ 20 - 1 : 0 ] picsr_cml_1;
reg [ 20 - 1 : 0 ] um_ints_cml_3;
reg [ 20 - 1 : 0 ] um_ints_cml_2;



//
// RISC Internal Interface
//
input		clk;		// Clock
input		rst;		// Reset
input		spr_cs;		// SPR CS
input		spr_write;	// SPR Write
input	[31:0]	spr_addr;	// SPR Address
input	[31:0]	spr_dat_i;	// SPR Write Data
output	[31:0]	spr_dat_o;	// SPR Read Data
output		pic_wakeup;	// Wakeup to the PM
output		intr;		// interrupt
				// exception request

//
// PIC Interface
//
input	[`OR1200_PIC_INTS-1:0]	pic_int;// Interrupt inputs

`ifdef OR1200_PIC_IMPLEMENTED

//
// PIC Mask Register bits (or no register)
//
`ifdef OR1200_PIC_PICMR
reg	[`OR1200_PIC_INTS-1:2]	picmr;	// PICMR bits
`else
wire	[`OR1200_PIC_INTS-1:2]	picmr;	// No PICMR register
`endif

//
// PIC Status Register bits (or no register)
//
`ifdef OR1200_PIC_PICSR
reg	[`OR1200_PIC_INTS-1:0]	picsr;	// PICSR bits
`else
wire	[`OR1200_PIC_INTS-1:0]	picsr;	// No PICSR register
`endif

//
// Internal wires & regs
//
wire		picmr_sel;	// PICMR select
wire		picsr_sel;	// PICSR select
wire	[`OR1200_PIC_INTS-1:0] um_ints;// Unmasked interrupts
reg	[31:0] 	spr_dat_o;	// SPR data out

//
// PIC registers address decoder
//

// SynEDA CoreMultiplier
// assignment(s): picmr_sel
// replace(s): spr_addr
assign picmr_sel = (spr_cs && (spr_addr_cml_3[`OR1200_PICOFS_BITS] == `OR1200_PIC_OFS_PICMR)) ? 1'b1 : 1'b0;

// SynEDA CoreMultiplier
// assignment(s): picsr_sel
// replace(s): spr_addr
assign picsr_sel = (spr_cs && (spr_addr_cml_3[`OR1200_PICOFS_BITS] == `OR1200_PIC_OFS_PICSR)) ? 1'b1 : 1'b0;

//
// Write to PICMR
//
`ifdef OR1200_PIC_PICMR

// SynEDA CoreMultiplier
// assignment(s): picmr
// replace(s): spr_write, spr_dat_i, picmr
always @(posedge clk or posedge rst)
	if (rst)
		picmr <= {1'b1, {`OR1200_PIC_INTS-3{1'b0}}};
	else begin  picmr <= picmr_cml_3; if (picmr_sel && spr_write_cml_3) begin
		picmr <= #1 spr_dat_i_cml_3[`OR1200_PIC_INTS-1:2];
	end end
`else
assign picmr = (`OR1200_PIC_INTS)'b1;
`endif

//
// Write to PICSR, both CPU and external ints
//
`ifdef OR1200_PIC_PICSR

// SynEDA CoreMultiplier
// assignment(s): picsr
// replace(s): spr_write, spr_dat_i, picsr, um_ints
always @(posedge clk or posedge rst)
	if (rst)
		picsr <= {`OR1200_PIC_INTS{1'b0}};
	else begin  picsr <= picsr_cml_3; if (picsr_sel && spr_write_cml_3) begin
		picsr <= #1 spr_dat_i_cml_3[`OR1200_PIC_INTS-1:0] | um_ints_cml_3;
	end else begin
		picsr <= #1 picsr_cml_3 | um_ints_cml_3;
	end end
`else
assign picsr = pic_int;
`endif

//
// Read PIC registers
//

// SynEDA CoreMultiplier
// assignment(s): spr_dat_o
// replace(s): spr_addr, picmr, picsr
always @(spr_addr_cml_1 or picmr_cml_1 or picsr_cml_1)
	case (spr_addr_cml_1[`OR1200_PICOFS_BITS])	// synopsys parallel_case
`ifdef OR1200_PIC_READREGS
		`OR1200_PIC_OFS_PICMR: begin
					spr_dat_o[`OR1200_PIC_INTS-1:0] = {picmr_cml_1, 2'b0};
`ifdef OR1200_PIC_UNUSED_ZERO
					spr_dat_o[31:`OR1200_PIC_INTS] = {32-`OR1200_PIC_INTS{1'b0}};
`endif
				end
`endif
		default: begin
				spr_dat_o[`OR1200_PIC_INTS-1:0] = picsr_cml_1;
`ifdef OR1200_PIC_UNUSED_ZERO
				spr_dat_o[31:`OR1200_PIC_INTS] = {32-`OR1200_PIC_INTS{1'b0}};
`endif
			end
	endcase

//
// Unmasked interrupts
//

// SynEDA CoreMultiplier
// assignment(s): um_ints
// replace(s): pic_int, picmr
assign um_ints = pic_int_cml_1 & {picmr_cml_1, 2'b11};

//
// Generate intr
//
assign intr = |um_ints;

//
// Assert pic_wakeup when intr is asserted
//

// SynEDA CoreMultiplier
// assignment(s): pic_wakeup
// replace(s): intr
assign pic_wakeup = intr_cml_3;

`else

//
// When PIC is not implemented, drive all outputs as would when PIC is disabled
//
assign intr = pic_int[1] | pic_int[0];
assign pic_wakeup= intr;

//
// Read PIC registers
//
`ifdef OR1200_PIC_READREGS
assign spr_dat_o[`OR1200_PIC_INTS-1:0] = `OR1200_PIC_INTS'b0;
`ifdef OR1200_PIC_UNUSED_ZERO
assign spr_dat_o[31:`OR1200_PIC_INTS] = 32-`OR1200_PIC_INTS'b0;
`endif
`endif

`endif


always @ (posedge clk_i_cml_1) begin
spr_write_cml_1 <= spr_write;
spr_addr_cml_1 <= spr_addr;
spr_dat_i_cml_1 <= spr_dat_i;
pic_int_cml_1 <= pic_int;
picmr_cml_1 <= picmr;
picsr_cml_1 <= picsr;
end
always @ (posedge clk_i_cml_2) begin
spr_write_cml_2 <= spr_write_cml_1;
spr_addr_cml_2 <= spr_addr_cml_1;
spr_dat_i_cml_2 <= spr_dat_i_cml_1;
intr_cml_2 <= intr;
picmr_cml_2 <= picmr_cml_1;
picsr_cml_2 <= picsr_cml_1;
um_ints_cml_2 <= um_ints;
end
always @ (posedge clk_i_cml_3) begin
spr_write_cml_3 <= spr_write_cml_2;
spr_addr_cml_3 <= spr_addr_cml_2;
spr_dat_i_cml_3 <= spr_dat_i_cml_2;
intr_cml_3 <= intr_cml_2;
picmr_cml_3 <= picmr_cml_2;
picsr_cml_3 <= picsr_cml_2;
um_ints_cml_3 <= um_ints_cml_2;
end
endmodule

