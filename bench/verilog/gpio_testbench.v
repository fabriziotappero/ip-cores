//////////////////////////////////////////////////////////////////////
////                                                              ////
////  GPIO Testbench Top                                          ////
////                                                              ////
////  This file is part of the GPIO project                       ////
////  http://www.opencores.org/cores/gpio/                        ////
////                                                              ////
////  Description                                                 ////
////  Top level of testbench. It instantiates all blocks.         ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
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
// Revision 1.2  2003/12/17 13:00:14  gorand
// added ECLK and NEC registers, all tests passed.
//
// Revision 1.1  2003/11/30 12:28:19  gorand
// small "names" modification...
//
// Revision 1.5  2003/11/29 16:22:05  gorand
// small changes, for VATS...
//
// Revision 1.4  2003/11/10 23:23:57  gorand
// tests passed.
//
// Revision 1.3  2002/03/13 20:56:16  lampret
// Removed zero padding as per Avi Shamli suggestion.
//
// Revision 1.2  2001/09/18 15:43:28  lampret
// Changed gpio top level into gpio_top. Changed defines.v into gpio_defines.v.
//
// Revision 1.1  2001/08/21 21:39:27  lampret
// Changed directory structure, port names and drfines.
//
// Revision 1.2  2001/07/14 20:37:24  lampret
// Test bench improvements.
//
// Revision 1.1  2001/06/05 07:45:22  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

`include "timescale.v"
`include "gpio_defines.v"

module gpio_testbench();

parameter aw = `GPIO_ADDRHH+1 ;
parameter dw = 32;
parameter gw = `GPIO_IOS;

//
// Interconnect wires
//
wire			clk;	// Clock
wire			rst;	// Reset
wire			cyc;	// Cycle valid
wire	[aw-1:0]	adr;	// Address bus
wire	[dw-1:0]	dat_m;	// Data bus from PTC to WBM
wire	[3:0]		sel;	// Data selects
wire			we;	// Write enable
wire			stb;	// Strobe
wire	[dw-1:0]	dat_ptc;// Data bus from WBM to PTC
wire			ack;	// Successful cycle termination
wire			err;	// Failed cycle termination
wire	[gw-1:0]	gpio_aux;	// GPIO auxiliary signals
wire	[gw-1:0]	gpio_in;	// GPIO inputs
wire  gpio_eclk;	// GPIO external clock
wire	[gw-1:0]	gpio_out;	// GPIO outputs
wire	[gw-1:0]	gpio_oen;	// GPIO output enables
wire  [ 3 : 0] tag_o ;

//
// description of current test.
//
reg   [127:0]  text;

//
// Instantiation of Clock/Reset Generator
//
clkrst clkrst(
	// Clock
	.clk_o(clk),
	// Reset
	.rst_o(rst)
);

//
// Instantiation of Master WISHBONE BFM
//
wb_master wb_master(
	// WISHBONE Interface
	.CLK_I(clk),
	.RST_I(rst),
	.CYC_O(cyc),
	.ADR_O(adr),
	.DAT_O(dat_ptc),
	.SEL_O(sel),
	.WE_O(we),
	.STB_O(stb),
	.DAT_I(dat_m),
	.ACK_I(ack),
	.ERR_I(err),
	.RTY_I(1'b0),
	.TAG_I(4'b0),
  .TAG_O ( tag_o ) 
);

//
// Instantiation of PTC core
//
gpio_top gpio_top(
	// WISHBONE Interface
	.wb_clk_i(clk),
	.wb_rst_i(rst),
	.wb_cyc_i(cyc),
	.wb_adr_i(adr),
	.wb_dat_i(dat_ptc),
	.wb_sel_i(sel),
	.wb_we_i(we),
	.wb_stb_i(stb),
	.wb_dat_o(dat_m),
	.wb_ack_o(ack),
	.wb_err_o(err),
	.wb_inta_o(),

	// Auxiliary inputs interface
`ifdef GPIO_AUX_IMPLEMENT
	.aux_i(gpio_aux),
`endif //  GPIO_AUX_IMPLEMENT

	// External GPIO Interface
	.ext_pad_i(gpio_in),

`ifdef GPIO_CLKPAD
	.clk_pad_i(gpio_eclk),
`endif // GPIO_CLKPAD
	.ext_pad_o(gpio_out),
	.ext_padoe_o(gpio_oen)
);

//
// GPIO Monitor
//
gpio_mon gpio_mon(
	.gpio_aux(gpio_aux),
	.gpio_in(gpio_in),
	.gpio_eclk(gpio_eclk),
	.gpio_out(gpio_out),
	.gpio_oen(gpio_oen)
);

initial
  text = " ";

endmodule
