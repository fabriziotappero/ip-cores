///////////////////////////////////////////////////////////////////////
////                                                              ////
////  xilinx_internal_jtag.v                                      ////
////                                                              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Authors                                   ////
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
//                                                                  //
// This file is a wrapper for the various Xilinx internal BSCAN     //
// TAP devices.  It is designed to take the place of a separate TAP //
// controller in Xilinx systems, to allow a user to access a CPU    //
// debug module (such as that of the OR1200) through the FPGA's     //
// dedicated JTAG / configuration port.                             //
//                                                                  //
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: xilinx_internal_jtag.v,v $
// Revision 1.4  2009-12-28 01:15:28  Nathan
// Removed incorrect duplicate assignment of capture_dr_o in SPARTAN2 TAP, per bug report from Raul Fajardo.
//
// Revision 1.3  2009/06/16 02:54:23  Nathan
// Changed some signal names for better consistency between different hardware modules.
//
// Revision 1.2  2009/05/17 20:54:16  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/18 20:07:32  Nathan
// Changed the directory structure to match existing projects.
//
// Revision 1.4  2008/07/11 08:26:10  Nathan
// Ran through dos2unix
//
// Revision 1.3  2008/07/11 08:25:52  Nathan
// Added logic to provide CAPTURE_DR signal when necessary, and to provide a TCK while UPDATE_DR is asserted.  Note that there is no TCK event between SHIFT_DR and UPDATE_DR, and no TCK event between UPDATE_DR and the next CAPTURE_DR; the Xilinx BSCAN devices do not provide it.  Tested successfully with the adv_dbg_if on Virtex-4.
//
// Revision 1.2  2008/06/09 19:34:14  Nathan
// Syntax and functional fixes made after compiling each type of BSCAN module using Xilinx tools.
//
// Revision 1.1  2008/05/22 19:54:07  Nathan
// Initial version
//


`include "xilinx_internal_jtag_options.v"

// Note that the SPARTAN BSCAN controllers have more than one channel.
// This implementation always uses channel 1, this is not configurable.
// If you want to use another channel, then it is probably because you
// want to attach multiple devices to the BSCAN device, which means
// you'll be making changes to this file anyway.
// Virtex BSCAN devices are instantiated separately for each channel.
// To select something other than the default (1), change the parameter
// "virtex_jtag_chain".


module xilinx_internal_jtag (
	tck_o,
	debug_tdo_i,
	tdi_o,
	test_logic_reset_o,
	run_test_idle_o,
	shift_dr_o,
	capture_dr_o,
	pause_dr_o,
	update_dr_o,
	debug_select_o
);

// May be 1, 2, 3, or 4
// Only used for Virtex 4/5 devices
parameter virtex_jtag_chain = 1;

input debug_tdo_i;
output tck_o;
output tdi_o;
output test_logic_reset_o;
output run_test_idle_o;
output shift_dr_o;
output capture_dr_o;
output pause_dr_o;
output update_dr_o;
output debug_select_o;

wire debug_tdo_i;
wire tck_o;
wire drck;
wire tdi_o;
wire test_logic_reset_o;
wire run_test_idle_o;
wire shift_dr_o;
wire pause_dr_o;
wire update_dr_o;
wire debug_select_o;



`ifdef SPARTAN2

// Note that this version is missing three outputs.
// It also does not have a real TCK...DRCK1 is only active when USER1 is selected
// AND the TAP is in SHIFT_DR or CAPTURE_DR states...except there's no
// capture_dr output. 

reg capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_SPARTAN2 BSCAN_SPARTAN2_inst (
.DRCK1(drck), // Data register output for USER1 functions
.DRCK2(), // Data register output for USER2 functions
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL1(debug_select_o), // USER1 active output
.SEL2(), // USER2 active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO1(debug_tdo_i), // Data input for USER1 function
.TDO2( 1'b0 ) // Data input for USER2 function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// We get one TCK during capture_dr state (low,high,SHIFT goes high on next DRCK high)
// On that negative edge, set capture_dr, and it will get registered on the rising
// edge.
always @ (negedge tck_o)
begin
	if(debug_select_o && !shift_dr_o)
		capture_dr_o <= 1'b1;
	else
		capture_dr_o <= 1'b0;
end

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;

`else
`ifdef SPARTAN3
// Note that this version is missing two outputs.
// It also does not have a real TCK...DRCK1 is only active when USER1 is selected.

wire capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_SPARTAN3 BSCAN_SPARTAN3_inst (
.CAPTURE(capture_dr_o), // CAPTURE output from TAP controller
.DRCK1(drck), // Data register output for USER1 functions
.DRCK2(), // Data register output for USER2 functions
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL1(debug_select_o), // USER1 active output
.SEL2(), // USER2 active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO1(debug_tdo_i), // Data input for USER1 function
.TDO2(1'b0) // Data input for USER2 function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;

`else
`ifdef SPARTAN3A
// Note that this version is missing two outputs.
// At least it has a real TCK.

wire capture_dr_o;

BSCAN_SPARTAN3A BSCAN_SPARTAN3A_inst (
.CAPTURE(capture_dr_o), // CAPTURE output from TAP controller
.DRCK1(), // Data register output for USER1 functions
.DRCK2(), // Data register output for USER2 functions
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL1(debug_select_o), // USER1 active output
.SEL2(), // USER2 active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TCK(tck_o), // TCK output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.TMS(), // TMS output from TAP controller
.UPDATE(update_dr_o), // UPDATE output from TAP controller
.TDO1(debug_tdo_i), // Data input for USER1 function
.TDO2( 1'b0) // Data input for USER2 function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

`else
`ifdef VIRTEX

// Note that this version is missing three outputs.
// It also does not have a real TCK...DRCK1 is only active when USER1 is selected.

reg capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_VIRTEX BSCAN_VIRTEX_inst (
.DRCK1(drck), // Data register output for USER1 functions
.DRCK2(), // Data register output for USER2 functions
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL1(debug_select_o), // USER1 active output
.SEL2(), // USER2 active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO1(debug_tdo_i), // Data input for USER1 function
.TDO2( 1'b0) // Data input for USER2 function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// We get one TCK during capture_dr state (low,high,SHIFT goes high on next DRCK low)
// On that negative edge, set capture_dr, and it will get registered on the rising
// edge, then de-asserted on the same edge that SHIFT goes high.
always @ (negedge tck_o)
begin
	if(debug_select_o && !shift_dr_o)
		capture_dr_o <= 1'b1;
	else
		capture_dr_o <= 1'b0;
end

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;

`else
`ifdef VIRTEX2

// Note that this version is missing two outputs.
// It also does not have a real TCK...DRCK1 is only active when USER1 is selected.

wire capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_VIRTEX2 BSCAN_VIRTEX2_inst (
.CAPTURE(capture_dr_o), // CAPTURE output from TAP controller
.DRCK1(drck), // Data register output for USER1 functions
.DRCK2(), // Data register output for USER2 functions
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL1(debug_select_o), // USER1 active output
.SEL2(), // USER2 active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO1(debug_tdo_i), // Data input for USER1 function
.TDO2( 1'b0 ) // Data input for USER2 function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;

`else
`ifdef VIRTEX4
// Note that this version is missing two outputs.
// It also does not have a real TCK...DRCK is only active when USERn is selected.

wire capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_VIRTEX4 #(
.JTAG_CHAIN(virtex_jtag_chain) 
) BSCAN_VIRTEX4_inst (
.CAPTURE(capture_dr_o), // CAPTURE output from TAP controller
.DRCK(drck), // Data register output for USER function
.RESET(test_logic_reset_o), // Reset output from TAP controller
.SEL(debug_select_o), // USER active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO( debug_tdo_i ) // Data input for USER function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;

`else
`ifdef VIRTEX5
// Note that this version is missing two outputs.
// It also does not have a real TCK...DRCK is only active when USERn is selected.

wire capture_dr_o;
wire update_bscan;
reg update_out;

BSCAN_VIRTEX5 #(
.JTAG_CHAIN(virtex_jtag_chain) 
) BSCAN_VIRTEX5_inst (
.CAPTURE(capture_dr_o), // CAPTURE output from TAP controller
.DRCK(drck), // Data register output for USER function
.RESET(test_logic_reset), // Reset output from TAP controller
.SEL(debug_select_o), // USER active output
.SHIFT(shift_dr_o), // SHIFT output from TAP controller
.TDI(tdi_o), // TDI output from TAP controller
.UPDATE(update_bscan), // UPDATE output from TAP controller
.TDO(debug_tdo_i) // Data input for USER function
);

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

// The & !update_bscan tern will provide a clock edge so update_dr_o can be registered
// The &debug_select term will drop TCK when the module is un-selected (does not happen in the BSCAN block).
// This allows a user to kludge clock ticks in the IDLE state, which is needed by the advanced debug module.
assign tck_o = (drck & debug_select_o & !update_bscan);

// This will hold the update_dr output so it can be registered on the rising edge
// of the clock created above.
always @(posedge update_bscan or posedge capture_dr_o or negedge debug_select_o)
begin
	if(update_bscan) update_out <= 1'b1;
	else if(capture_dr_o) update_out <= 1'b0;
	else if(!debug_select_o) update_out <= 1'b0;
end

assign update_dr_o = update_out;


`endif
`endif
`endif
`endif
`endif
`endif
`endif

endmodule