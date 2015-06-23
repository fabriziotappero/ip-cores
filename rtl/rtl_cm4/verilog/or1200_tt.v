//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Tick Timer                                         ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  TT according to OR1K architectural specification.           ////
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
// Revision 1.4  2002/03/29 15:16:56  lampret
// Some of the warnings fixed.
//
// Revision 1.3  2002/02/12 01:33:47  lampret
// No longer using async rst as sync reset for the counter.
//
// Revision 1.2  2002/01/28 01:16:00  lampret
// Changed 'void' nop-ops instead of insn[0] to use insn[16]. Debug unit stalls the tick timer. Prepared new flag generation for add and and insns. Blocked DC/IC while they are turned off. Fixed I/D MMU SPRs layout except WAYs. TODO: smart IC invalidate, l.j 2 and TLB ways.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.10  2001/11/13 10:00:49  lampret
// Fixed tick timer interrupt reporting by using TTCR[IP] bit.
//
// Revision 1.9  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.8  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.7  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:35  igorm
// no message
//
// Revision 1.2  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.1  2001/07/20 00:46:23  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_tt_cm4(
		clk_i_cml_1,
		clk_i_cml_2,
		clk_i_cml_3,
		
	// RISC Internal Interface
	clk, rst, du_stall,
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o,
	intr
);


input clk_i_cml_1;
input clk_i_cml_2;
input clk_i_cml_3;
reg  du_stall_cml_3;
reg  du_stall_cml_2;
reg  du_stall_cml_1;
reg  spr_write_cml_3;
reg  spr_write_cml_2;
reg  spr_write_cml_1;
reg [ 31 : 0 ] spr_addr_cml_3;
reg [ 31 : 0 ] spr_addr_cml_2;
reg [ 31 : 0 ] spr_addr_cml_1;
reg [ 31 : 0 ] spr_dat_i_cml_3;
reg [ 31 : 0 ] spr_dat_i_cml_2;
reg [ 31 : 0 ] spr_dat_i_cml_1;
reg [ 31 : 0 ] ttmr_cml_3;
reg [ 31 : 0 ] ttmr_cml_2;
reg [ 31 : 0 ] ttmr_cml_1;
reg [ 31 : 0 ] ttcr_cml_3;
reg [ 31 : 0 ] ttcr_cml_2;
reg [ 31 : 0 ] ttcr_cml_1;



//
// RISC Internal Interface
//
input		clk;		// Clock
input		rst;		// Reset
input		du_stall;	// DU stall
input		spr_cs;		// SPR CS
input		spr_write;	// SPR Write
input	[31:0]	spr_addr;	// SPR Address
input	[31:0]	spr_dat_i;	// SPR Write Data
output	[31:0]	spr_dat_o;	// SPR Read Data
output		intr;		// Interrupt output

`ifdef OR1200_TT_IMPLEMENTED

//
// TT Mode Register bits (or no register)
//
`ifdef OR1200_TT_TTMR
reg	[31:0]	ttmr;	// TTMR bits
`else
wire	[31:0]	ttmr;	// No TTMR register
`endif

//
// TT Count Register bits (or no register)
//
`ifdef OR1200_TT_TTCR
reg	[31:0]	ttcr;	// TTCR bits
`else
wire	[31:0]	ttcr;	// No TTCR register
`endif

//
// Internal wires & regs
//
wire		ttmr_sel;	// TTMR select
wire		ttcr_sel;	// TTCR select
wire		match;		// Asserted when TTMR[TP]
				// is equal to TTCR[27:0]
wire		restart;	// Restart counter when asserted
wire		stop;		// Stop counter when asserted
reg	[31:0] 	spr_dat_o;	// SPR data out

//
// TT registers address decoder
//

// SynEDA CoreMultiplier
// assignment(s): ttmr_sel
// replace(s): spr_addr
assign ttmr_sel = (spr_cs && (spr_addr_cml_3[`OR1200_TTOFS_BITS] == `OR1200_TT_OFS_TTMR)) ? 1'b1 : 1'b0;

// SynEDA CoreMultiplier
// assignment(s): ttcr_sel
// replace(s): spr_addr
assign ttcr_sel = (spr_cs && (spr_addr_cml_3[`OR1200_TTOFS_BITS] == `OR1200_TT_OFS_TTCR)) ? 1'b1 : 1'b0;

//
// Write to TTMR or update of TTMR[IP] bit
//
`ifdef OR1200_TT_TTMR

// SynEDA CoreMultiplier
// assignment(s): ttmr
// replace(s): spr_write, spr_dat_i, ttmr
always @(posedge clk or posedge rst)
	if (rst)
		ttmr <= 32'b0;
	else begin  ttmr <= ttmr_cml_3; if (ttmr_sel && spr_write_cml_3)
		ttmr <= #1 spr_dat_i_cml_3;
	else if (ttmr_cml_3[`OR1200_TT_TTMR_IE])
		ttmr[`OR1200_TT_TTMR_IP] <= #1 ttmr_cml_3[`OR1200_TT_TTMR_IP] | (match & ttmr_cml_3[`OR1200_TT_TTMR_IE]); end
`else
assign ttmr = {2'b11, 30'b0};	// TTMR[M] = 0x3
`endif

//
// Write to or increment of TTCR
//
`ifdef OR1200_TT_TTCR

// SynEDA CoreMultiplier
// assignment(s): ttcr
// replace(s): spr_write, spr_dat_i, ttcr
always @(posedge clk or posedge rst)
	if (rst)
		ttcr <= 32'b0;
	else begin  ttcr <= ttcr_cml_3; if (restart)
		ttcr <= #1 32'b0;
	else if (ttcr_sel && spr_write_cml_3)
		ttcr <= #1 spr_dat_i_cml_3;
	else if (!stop)
		ttcr <= #1 ttcr_cml_3 + 32'd1; end
`else
assign ttcr = 32'b0;
`endif

//
// Read TT registers
//

// SynEDA CoreMultiplier
// assignment(s): spr_dat_o
// replace(s): spr_addr, ttmr, ttcr
always @(spr_addr_cml_1 or ttmr_cml_1 or ttcr_cml_1)
	case (spr_addr_cml_1[`OR1200_TTOFS_BITS])	// synopsys parallel_case
`ifdef OR1200_TT_READREGS
		`OR1200_TT_OFS_TTMR: spr_dat_o = ttmr_cml_1;
`endif
		default: spr_dat_o = ttcr_cml_1;
	endcase

//
// A match when TTMR[TP] is equal to TTCR[27:0]
//

// SynEDA CoreMultiplier
// assignment(s): match
// replace(s): ttmr, ttcr
assign match = (ttmr_cml_3[`OR1200_TT_TTMR_TP] == ttcr_cml_3[27:0]) ? 1'b1 : 1'b0;

//
// Restart when match and TTMR[M]==0x1
//

// SynEDA CoreMultiplier
// assignment(s): restart
// replace(s): ttmr
assign restart = match && (ttmr_cml_3[`OR1200_TT_TTMR_M] == 2'b01);

//
// Stop when match and TTMR[M]==0x2 or when TTMR[M]==0x0 or when RISC is stalled by debug unit
//

// SynEDA CoreMultiplier
// assignment(s): stop
// replace(s): du_stall, ttmr
assign stop = match & (ttmr_cml_3[`OR1200_TT_TTMR_M] == 2'b10) | (ttmr_cml_3[`OR1200_TT_TTMR_M] == 2'b00) | du_stall_cml_3;

//
// Generate an interrupt request
//

// SynEDA CoreMultiplier
// assignment(s): intr
// replace(s): ttmr
assign intr = ttmr_cml_2[`OR1200_TT_TTMR_IP];

`else

//
// When TT is not implemented, drive all outputs as would when TT is disabled
//
assign intr = 1'b0;

//
// Read TT registers
//
`ifdef OR1200_TT_READREGS
assign spr_dat_o = 32'b0;
`endif

`endif


always @ (posedge clk_i_cml_1) begin
du_stall_cml_1 <= du_stall;
spr_write_cml_1 <= spr_write;
spr_addr_cml_1 <= spr_addr;
spr_dat_i_cml_1 <= spr_dat_i;
ttmr_cml_1 <= ttmr;
ttcr_cml_1 <= ttcr;
end
always @ (posedge clk_i_cml_2) begin
du_stall_cml_2 <= du_stall_cml_1;
spr_write_cml_2 <= spr_write_cml_1;
spr_addr_cml_2 <= spr_addr_cml_1;
spr_dat_i_cml_2 <= spr_dat_i_cml_1;
ttmr_cml_2 <= ttmr_cml_1;
ttcr_cml_2 <= ttcr_cml_1;
end
always @ (posedge clk_i_cml_3) begin
du_stall_cml_3 <= du_stall_cml_2;
spr_write_cml_3 <= spr_write_cml_2;
spr_addr_cml_3 <= spr_addr_cml_2;
spr_dat_i_cml_3 <= spr_dat_i_cml_2;
ttmr_cml_3 <= ttmr_cml_2;
ttcr_cml_3 <= ttcr_cml_2;
end
endmodule

