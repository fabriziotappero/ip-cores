//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic Single-Port Synchronous RAM                         ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/minsoc/ 		  ////
////                                                              ////
////  Description                                                 ////
////  This block is a wrapper with common single-port             ////
////  synchronous memory interface for different                  ////
////  types of ASIC and FPGA RAMs. Beside universal memory        ////
////  interface it also provides behavioral model of generic      ////
////  single-port synchronous RAM.                                ////
////  It should be used in all OPENCORES designs that want to be  ////
////  portable accross different target technologies and          ////
////  independent of target memory.                               ////
////                                                              ////
////  Supported ASIC RAMs are:                                    ////
////  - Artisan Single-Port Sync RAM                              ////
////  - Avant! Two-Port Sync RAM (*)                              ////
////  - Virage Single-Port Sync RAM                               ////
////  - Virtual Silicon Single-Port Sync RAM                      ////
////                                                              ////
////  Supported FPGA RAMs are:                                    ////
////  - Xilinx Virtex RAMB16                                      ////
////  - Xilinx Virtex RAMB4                                       ////
////  - Altera LPM                                                ////
////                                                              ////
////  To Do:                                                      ////
////   - fix avant! two-port ram                                  ////
////   - add additional RAMs                                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Raul Fajardo, rfajardo@gmail.com	                  ////
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
//// from http://www.gnu.org/licenses/lgpl.html                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// Revision History
//
//
// Revision 2.1 2009/08/23 16:41:00   fajardo
// Sensitivity of addr_reg and memory write changed back to posedge clk for GENERIC_MEMORY
// This actually models appropriately the behavior of the FPGA internal RAMs
//
// Revision 2.0 2009/09/10 11:30:00   fajardo
// Added tri-state buffering for altera output
// Sensitivity of addr_reg and memory write changed to negedge clk for GENERIC_MEMORY
//
// Revision 1.9 2009/08/18 15:15:00   fajardo
// Added tri-state buffering for xilinx and generic memory output
//
// $Log: not supported by cvs2svn $
// Revision 1.8  2004/06/08 18:15:32  lampret
// Changed behavior of the simulation generic models
//
// Revision 1.7  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.3.4.1  2003/12/09 11:46:48  simons
// Mbist nameing changed, Artisan ram instance signal names fixed, some synthesis waning fixed.
//
// Revision 1.3  2003/04/07 01:19:07  lampret
// Added Altera LPM RAMs. Changed generic RAM output when OE inactive.
//
// Revision 1.2  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.8  2001/11/02 18:57:14  lampret
// Modified virtual silicon instantiations.
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
`include "timescale.v"
// synopsys translate_on
`include "minsoc_defines.v"

module minsoc_onchip_ram(
`ifdef BIST
	// RAM BIST
	mbist_si_i, mbist_so_o, mbist_ctrl_i,
`endif
	// Generic synchronous single-port RAM interface
	clk, rst, ce, we, oe, addr, di, doq
);

//
// Default address and data buses width
//
parameter aw = 11;
parameter dw = 8;

`ifdef BIST
//
// RAM BIST
//
input mbist_si_i;
input [`MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;
output mbist_so_o;
`endif

//
// Generic synchronous single-port RAM interface
//
input			clk;	// Clock
input			rst;	// Reset
input			ce;	// Chip enable input
input			we;	// Write enable input
input			oe;	// Output enable input
input 	[aw-1:0]	addr;	// address bus inputs
input	[dw-1:0]	di;	// input data bus
output	[dw-1:0]	doq;	// output data bus

//
// Decide memory implementation for Xilinx FPGAs
//
`ifdef SPARTAN2
	`define MINSOC_XILINX_RAMB4
`elsif VIRTEX
	`define MINSOC_XILINX_RAMB4
`endif	// !SPARTAN2/VIRTEX

`ifdef SPARTAN3
	`define MINSOC_XILINX_RAMB16
`elsif SPARTAN3E
	`define MINSOC_XILINX_RAMB16
`elsif SPARTAN3A
	`define MINSOC_XILINX_RAMB16
`elsif VIRTEX2
	`define MINSOC_XILINX_RAMB16
`elsif VIRTEX4
	`define MINSOC_XILINX_RAMB16
`elsif VIRTEX5
	`define MINSOC_XILINX_RAMB16
`elsif SPARTAN6
	`define MINSOC_XILINX_RAMB16
`endif	// !SPARTAN3/SPARTAN3E/SPARTAN3A/VIRTEX2/VIRTEX4/VIRTEX5/SPARTAN6


//
// Internal wires and registers
//

`ifdef ARTISAN_SSP
`else
`ifdef VIRTUALSILICON_SSP
`else
`ifdef BIST
assign mbist_so_o = mbist_si_i;
`endif
`endif
`endif


`ifdef GENERIC_MEMORY
//
// Generic single-port synchronous RAM model
//

//
// Generic RAM's registers and wires
//
reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_reg;		// RAM address register

//
// Data output drivers
//
assign doq = (oe) ? mem[addr_reg] : {dw{1'bZ}};

//
// RAM address register
//
always @(posedge clk or posedge rst)
	if (rst)
		addr_reg <= #1 {aw{1'b0}};
	else if (ce)
		addr_reg <= #1 addr;

//
// RAM write
//
always @(posedge clk)
	if (ce && we)
		mem[addr] <= #1 di;


`elsif ARTISAN_SSP
//
// Instantiation of ASIC memory:
//
// Artisan Synchronous Single-Port RAM (ra1sh)
//
`ifdef UNUSED
art_hssp_2048x8 #(dw, 1<<aw, aw) artisan_ssp(
`else
`ifdef BIST
art_hssp_2048x8_bist artisan_ssp(
`else
art_hssp_2048x8 artisan_ssp(
`endif
`endif
`ifdef BIST
	// RAM BIST
	.mbist_si_i(mbist_si_i),
	.mbist_so_o(mbist_so_o),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.CLK(clk),
	.CEN(~ce),
	.WEN(~we),
	.A(addr),
	.D(di),
	.OEN(~oe),
	.Q(doq)
);


`elsif AVANT_ATP
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
	.doq(doq)
);


`elsif VIRAGE_SSP
//
// Instantiation of ASIC memory:
//
// Virage Synchronous 1-port R/W RAM
//
virage_ssp virage_ssp(
	.clk(clk),
	.adr(addr),
	.d(di),
	.we(we),
	.oe(oe),
	.me(ce),
	.q(doq)
);


`elsif VIRTUALSILICON_SSP
//
// Instantiation of ASIC memory:
//
// Virtual Silicon Single-Port Synchronous SRAM
//
`ifdef UNUSED
vs_hdsp_2048x8 #(1<<aw, aw-1, dw-1) vs_ssp(
`else
`ifdef BIST
vs_hdsp_2048x8_bist vs_ssp(
`else
vs_hdsp_2048x8 vs_ssp(
`endif
`endif
`ifdef BIST
	// RAM BIST
	.mbist_si_i(mbist_si_i),
	.mbist_so_o(mbist_so_o),
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	.CK(clk),
	.ADR(addr),
	.DI(di),
	.WEN(~we),
	.CEN(~ce),
	.OEN(~oe),
	.DOUT(doq)
);


`elsif MINSOC_XILINX_RAMB4
//
// Instantiation of FPGA memory:
//
// SPARTAN2/VIRTEX
//

wire	[dw-1:0]	doq_internal;	// output data bus

//
// Block 0
//
RAMB4_S2 ramb4_s2_0(
	.CLK(clk),
	.RST(rst),
	.ADDR(addr),
	.DI(di[1:0]),
	.EN(ce),
	.WE(we),
	.DO(doq_internal[1:0])
);

//
// Block 1
//
RAMB4_S2 ramb4_s2_1(
	.CLK(clk),
	.RST(rst),
	.ADDR(addr),
	.DI(di[3:2]),
	.EN(ce),
	.WE(we),
	.DO(doq_internal[3:2])
);

//
// Block 2
//
RAMB4_S2 ramb4_s2_2(
	.CLK(clk),
	.RST(rst),
	.ADDR(addr),
	.DI(di[5:4]),
	.EN(ce),
	.WE(we),
	.DO(doq_internal[5:4])
);

//
// Block 3
//
RAMB4_S2 ramb4_s2_3(
	.CLK(clk),
	.RST(rst),
	.ADDR(addr),
	.DI(di[7:6]),
	.EN(ce),
	.WE(we),
	.DO(doq_internal[7:6])
);

assign doq = (oe) ? (doq_internal) : { dw{1'bZ} };


`elsif MINSOC_XILINX_RAMB16
//
// Instantiation of FPGA memory:
//
// SPARTAN3/SPARTAN3E/VIRTEX2
// SPARTAN3A/VIRTEX4/VIRTEX5 are automatically reallocated by ISE
//
// Added By Nir Mor
//

wire	[dw-1:0]	doq_internal;	// output data bus

RAMB16_S9 ramb16_s9(
	.CLK(clk),
	.SSR(rst),
	.ADDR(addr),
	.DI(di),
	.DIP(1'b0),
	.EN(ce),
	.WE(we),
	.DO(doq_internal),
	.DOP()
);

assign doq = (oe) ? (doq_internal) : { dw{1'bZ} };


`elsif ALTERA_FPGA
//
// Instantiation of FPGA memory:
//
// Altera LPM
//
// Added By Jamil Khatib
//

wire    wr;

assign  wr = ce & we;

wire	[dw-1:0]	doq_internal;	// output data bus

initial $display("Using Altera LPM.");

lpm_ram_dq lpm_ram_dq_component (
        .address(addr),
        .inclock(clk),
        .data(di),
        .we(wr),
        .q(doq_internal)
);

assign doq = (oe) ? (doq_internal) : { dw{1'bZ} };

defparam lpm_ram_dq_component.lpm_width = dw,
        lpm_ram_dq_component.lpm_widthad = aw,
        lpm_ram_dq_component.lpm_indata = "REGISTERED",
        lpm_ram_dq_component.lpm_address_control = "REGISTERED",
        lpm_ram_dq_component.lpm_outdata = "UNREGISTERED",
        lpm_ram_dq_component.lpm_hint = "USE_EAB=ON";
        // examplar attribute lpm_ram_dq_component NOOPT TRUE


`endif  // !ALTERA_FPGA/MINCON_XILINX_RAMB16/MINCON_XILINX_RAMB4/VIRTUALSILICON_SSP/VIRAGE_SSP/AVANT_ATP/ARTISAN_SSP/GENERIC_MEMORY


endmodule
