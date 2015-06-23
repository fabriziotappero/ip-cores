//////////////////////////////////////////////////////////////////////
////                                                              ////
////  actel_ujtag.v                                               ////
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
//// Copyright (C) 2010 Authors                                   ////
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
// This file is a wrapper for the Actel UJTAG                       //
// TAP devices.  It is designed to take the place of a separate TAP //
// controller in Actel systems, to allow a user to access a CPU     //
// debug module (such as that of the OR1200) through the FPGA's     //
// dedicated JTAG / configuration port.                             //
//                                                                  //
//////////////////////////////////////////////////////////////////////

`define UJTAG_DEBUG_IR 8'h44

module actel_ujtag (

	// These must be routed to the top-level module, where they must
	// connected to top-level ports called TCK, TMS, TDI, TDO, and 
	// TRSTB.  But, these ports must NOT be connected to IO pins.
	tck_pad_i,
	tms_pad_i,
	tdi_pad_i,
	tdo_pad_o,
	trstb_pad_i,

	// These are to/from the debug unit
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
input tck_pad_i;
input tms_pad_i;
input tdi_pad_i;
output tdo_pad_o;
input trstb_pad_i;

wire debug_tdo_i;
wire tck_o;
wire tdi_o;
wire test_logic_reset_o;
wire run_test_idle_o;
wire shift_dr_o;
wire pause_dr_o;
wire update_dr_o;
wire debug_select_o;

wire [7:0] inst_reg;

wire tck_pad_i;
wire tms_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire trstb_pad_i;

UJTAG ujtag_inst (
.URSTB(test_logic_reset_o),
.UTDO(debug_tdo_i),
.UDRCK(tck_o),
.UDRCAP(capture_dr_o),
.UDRSH(shift_dr_o),
.UDRUPD(update_dr_o),
.UTDI(tdi_o),
.UIREG0(inst_reg[0]),
.UIREG1(inst_reg[1]),
.UIREG2(inst_reg[2]),
.UIREG3(inst_reg[3]),
.UIREG4(inst_reg[4]),
.UIREG5(inst_reg[5]),
.UIREG6(inst_reg[6]),
.UIREG7(inst_reg[7]),
.TCK(tck_pad_i),
.TDO(tdo_pad_o),
.TDI(tdi_pad_i),
.TMS(tms_pad_i),
.TRSTB(trstb_pad_i)
);


assign debug_select_o = (inst_reg == `UJTAG_DEBUG_IR) ? 1'b1 : 1'b0;

assign pause_dr_o = 1'b0;
assign run_test_idle_o = 1'b0;

endmodule