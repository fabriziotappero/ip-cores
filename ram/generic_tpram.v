//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic Two-Port Synchronous RAM                            ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/generic_memories/     ////
////                                                              ////
////  Description                                                 ////
////  This block is a wrapper with common two-port                ////
////  synchronous memory interface for different                  ////
////  types of ASIC and FPGA RAMs. Beside universal memory        ////
////  interface it also provides behavioral model of generic      ////
////  two-port synchronous RAM.                                   ////
////  It should be used in all OPENCORES designs that want to be  ////
////  portable accross different target technologies and          ////
////  independent of target memory.                               ////
////                                                              ////
////  Supported ASIC RAMs are:                                    ////
////  - Artisan Double-Port Sync RAM                              ////
////  - Avant! Two-Port Sync RAM (*)                              ////
////  - Virage 2-port Sync RAM                                    ////
////                                                              ////
////  Supported FPGA RAMs are:                                    ////
////  - Xilinx Virtex RAMB4_S16_S16                               ////
////                                                              ////
////  To Do:                                                      ////
////   - fix Avant!                                               ////
////   - xilinx rams need external tri-state logic                ////
////   - add additional RAMs (Altera, VS etc)                     ////
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
// Revision 1.1  2001/11/07 18:10:21  samg
// added checks and task in behavioral section
//
// Revision 1.7  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.6  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/30 05:38:02  lampret
// Adding empty directories required by HDL coding guidelines
//
//

// synopsys translate_off
//`include "timescale.v"
// synopsys translate_on
//`include "defines.v"

module generic_tpram(
	// Generic synchronous two-port RAM interface
	clk_a, rst_a, ce_a, we_a, oe_a, addr_a, di_a, do_a,
	clk_b, rst_b, ce_b, we_b, oe_b, addr_b, di_b, do_b
);

//
// Default address and data buses width
//
parameter aw = 5;
parameter dw = 32;
parameter MEM_SIZE = (1<<aw); 

//
// Generic synchronous two-port RAM interface
//
input			clk_a;	// Clock
input			rst_a;	// Reset
input			ce_a;	// Chip enable input
input			we_a;	// Write enable input
input			oe_a;	// Output enable input
input 	[aw-1:0]	addr_a;	// address bus inputs
input	[dw-1:0]	di_a;	// input data bus
output	[dw-1:0]	do_a;	// output data bus
input			clk_b;	// Clock
input			rst_b;	// Reset
input			ce_b;	// Chip enable input
input			we_b;	// Write enable input
input			oe_b;	// Output enable input
input 	[aw-1:0]	addr_b;	// address bus inputs
input	[dw-1:0]	di_b;	// input data bus
output	[dw-1:0]	do_b;	// output data bus

//
// Internal wires and registers
//


`ifdef ARTISAN_SDP

//
// Instantiation of ASIC memory:
//
// Artisan Synchronous Double-Port RAM (ra2sh)
//
`ifdef UNUSED
art_hsdp_32x32 #(dw, 1<<aw, aw) artisan_sdp(
`else
art_hsdp_32x32 artisan_sdp(
`endif
	.qa(do_a),
	.clka(clk_a),
	.cena(~ce_a),
	.wena(~we_a),
	.aa(addr_a),
	.da(di_a),
	.oena(~oe_a),
	.qb(do_b),
	.clkb(clk_b),
	.cenb(~ce_b),
	.wenb(~we_b),
	.ab(addr_b),
	.db(di_b),
	.oenb(~oe_b)
);

`else

`ifdef AVANT_ATP

//
// Instantiation of ASIC memory:
//
// Avant! Asynchronous Two-Port RAM
//
avant_atp avant_atp(
	.web(~we),
	.reb(),
	.oeb(~oe),
	.rcsb(),
	.wcsb(),
	.ra(addr),
	.wa(addr),
	.di(di),
	.do(do)
);

`else

`ifdef VIRAGE_STP

//
// Instantiation of ASIC memory:
//
// Virage Synchronous 2-port R/W RAM
//
virage_stp virage_stp(
	.QA(do_a),
	.QB(do_b),

	.ADRA(addr_a),
	.DA(di_a),
	.WEA(we_a),
	.OEA(oe_a),
	.MEA(ce_a),
	.CLKA(clk_a),

	.ADRB(adr_b),
	.DB(di_b),
	.WEB(we_b),
	.OEB(oe_b),
	.MEB(ce_b),
	.CLKB(clk_b)
);

`else

`ifdef XILINX_RAMB4

//
// Instantiation of FPGA memory:
//
// Virtex/Spartan2
//

//
// Block 0
//
RAMB4_S16_S16 ramb4_s16_s16_0(
	.CLKA(clk_a),
	.RSTA(rst_a),
	.ADDRA(addr_a),
	.DIA(di_a[15:0]),
	.ENA(ce_a),
	.WEA(we_a),
	.DOA(do_a[15:0]),

	.CLKB(clk_b),
	.RSTB(rst_b),
	.ADDRB(addr_b),
	.DIB(di_b[15:0]),
	.ENB(ce_b),
	.WEB(we_b),
	.DOB(do_b[15:0])
);

//
// Block 1
//
RAMB4_S16_S16 ramb4_s16_s16_1(
	.CLKA(clk_a),
	.RSTA(rst_a),
	.ADDRA(addr_a),
	.DIA(di_a[31:16]),
	.ENA(ce_a),
	.WEA(we_a),
	.DOA(do_a[31:16]),

	.CLKB(clk_b),
	.RSTB(rst_b),
	.ADDRB(addr_b),
	.DIB(di_b[31:16]),
	.ENB(ce_b),
	.WEB(we_b),
	.DOB(do_b[31:16])
);

`else

//
// Generic two-port synchronous RAM model
//

//
// Generic RAM's registers and wires
//
reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
wire	[dw-1:0]	do_reg_a;		// RAM data output register
wire	[dw-1:0]	do_reg_b;		// RAM data output register
reg	[dw-1:0]	do_wc_reg_a;		// RAM data output register (write check)
reg	[dw-1:0]	do_wc_reg_b;		// RAM data output register (write check)

//
// Data output drivers
//
// Output only valid when output enabled and chip enbled
assign do_a = (oe_a & ce_a) ? do_reg_a : {dw{1'bz}};
assign do_b = (oe_b & ce_b) ? do_reg_b : {dw{1'bz}};

// Output is invalid while writing data 
assign do_reg_a = (we_a) ? {dw{1'b x}} : do_wc_reg_a;
assign do_reg_b = (we_b) ? {dw{1'b x}} : do_wc_reg_b;

//
// RAM read and write
//
always @(posedge clk_a)
	if (ce_a && !we_a)
        	do_wc_reg_a <= #1 (we_b && (addr_a==addr_b)) ? {dw{1'b x}} : mem[addr_a];
	else if (ce_a && we_a)
		mem[addr_a] <= #1 di_a;

//
// RAM read and write
//
always @(posedge clk_b)
	if (ce_b && !we_b)
        	do_wc_reg_b <= #1 (we_a && (addr_a==addr_b)) ? {dw{1'b x}} : mem[addr_b];
	else if (ce_b && we_b)
		mem[addr_b] <= #1 di_b;

// Task prints range of memory
// *** Remember that tasks are non reentrant, don't call this task in parallel for multiple instantiations. 
task print_ram;
input [aw-1:0] start;
input [aw-1:0] finish;
integer rnum;
  begin
    for (rnum=start;rnum<=finish;rnum=rnum+1)
      $display("Addr %h = %h",rnum,mem[rnum]);
  end
endtask

`endif	// !XILINX_RAMB4_S16_S16
`endif	// !VIRAGE_STP
`endif  // !AVANT_ATP
`endif	// !ARTISAN_SDP

endmodule
