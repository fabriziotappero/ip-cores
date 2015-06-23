//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE PWM/Timer/Counter                                  ////
////                                                              ////
////  This file is part of the PTC project                        ////
////  http://www.opencores.org/cores/ptc/                         ////
////                                                              ////
////  Description                                                 ////
////  Implementation of PWM/Timer/Counter IP core according to    ////
////  PTC IP core specification document.                         ////
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
// Revision 1.4  2001/09/18 18:48:29  lampret
// Changed top level ptc into ptc_top. Changed defines.v into ptc_defines.v. Reset of the counter is now synchronous.
//
// Revision 1.3  2001/08/21 23:23:50  lampret
// Changed directory structure, defines and port names.
//
// Revision 1.2  2001/07/17 00:18:10  lampret
// Added new parameters however RTL still has some issues related to hrc_match and int_match
//
// Revision 1.1  2001/06/05 07:45:36  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ptc_defines.v"

module ptc_top(
	// WISHBONE Interface
	wb_clk_i, wb_rst_i, wb_cyc_i, wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i,
	wb_dat_o, wb_ack_o, wb_err_o, wb_inta_o,

	// External PTC Interface
	gate_clk_pad_i, capt_pad_i, pwm_pad_o, oen_padoen_o
);

parameter dw = 32;
parameter aw = `PTC_ADDRHH+1;
parameter cw = `PTC_CW;

//
// WISHBONE Interface
//
input			wb_clk_i;	// Clock
input			wb_rst_i;	// Reset
input			wb_cyc_i;	// cycle valid input
input 	[aw-1:0]	wb_adr_i;	// address bus inputs
input	[dw-1:0]	wb_dat_i;	// input data bus
input	[3:0]		wb_sel_i;	// byte select inputs
input			wb_we_i;	// indicates write transfer
input			wb_stb_i;	// strobe input
output	[dw-1:0]	wb_dat_o;	// output data bus
output			wb_ack_o;	// normal termination
output			wb_err_o;	// termination w/ error
output			wb_inta_o;	// Interrupt request output

//
// External PTC Interface
//
input		gate_clk_pad_i;	// EClk/Gate input
input		capt_pad_i;	// Capture input
output		pwm_pad_o;	// PWM output
output		oen_padoen_o;	// PWM output driver enable

`ifdef PTC_IMPLEMENTED

//
// PTC Main Counter Register (or no register)
//
`ifdef PTC_RPTC_CNTR
reg	[cw-1:0]	rptc_cntr;	// RPTC_CNTR register
`else
wire	[cw-1:0]	rptc_cntr;	// No RPTC_CNTR register
`endif

//
// PTC HI Reference/Capture Register (or no register)
//
`ifdef PTC_RPTC_HRC
reg	[cw-1:0]	rptc_hrc;	// RPTC_HRC register
`else
wire	[cw-1:0]	rptc_hrc;	// No RPTC_HRC register
`endif

//
// PTC LO Reference/Capture Register (or no register)
//
`ifdef PTC_RPTC_LRC
reg	[cw-1:0]	rptc_lrc;	// RPTC_LRC register
`else
wire	[cw-1:0]	rptc_lrc;	// No RPTC_LRC register
`endif

//
// PTC Control Register (or no register)
//
`ifdef PTC_RPTC_CTRL
reg	[8:0]		rptc_ctrl;	// RPTC_CTRL register
`else
wire	[8:0]		rptc_ctrl;	// No RPTC_CTRL register
`endif

//
// Internal wires & regs
//
wire			rptc_cntr_sel;	// RPTC_CNTR select
wire			rptc_hrc_sel;	// RPTC_HRC select
wire			rptc_lrc_sel;	// RPTC_LRC select
wire			rptc_ctrl_sel;	// RPTC_CTRL select
wire			hrc_match;	// RPTC_HRC matches RPTC_CNTR
wire			lrc_match;	// RPTC_LRC matches RPTC_CNTR
wire			restart;	// Restart counter when asserted
wire			stop;		// Stop counter when asserted
wire			cntr_clk;	// Counter clock
wire			cntr_rst;	// Counter reset
wire			hrc_clk;	// RPTC_HRC clock
wire			lrc_clk;	// RPTC_LRC clock
wire			eclk_gate;	// ptc_ecgt xored by RPTC_CTRL[NEC]
wire			gate;		// Gate function of ptc_ecgt
wire			pwm_rst;	// Reset of a PWM output
reg	[dw-1:0]	wb_dat_o;	// Data out
reg			pwm_pad_o;	// PWM output
reg			int;		// Interrupt reg
wire			int_match;	// Interrupt match
wire			full_decoding;	// Full address decoding qualification

//
// All WISHBONE transfer terminations are successful except when:
// a) full address decoding is enabled and address doesn't match
//    any of the PTC registers
// b) sel_i evaluation is enabled and one of the sel_i inputs is zero
//
assign wb_ack_o = wb_cyc_i & wb_stb_i & !wb_err_o;
`ifdef PTC_FULL_DECODE
`ifdef PTC_STRICT_32BIT_ACCESS
assign wb_err_o = wb_cyc_i & wb_stb_i & (!full_decoding | (wb_sel_i != 4'b1111));
`else
assign wb_err_o = wb_cyc_i & wb_stb_i & !full_decoding;
`endif
`else
`ifdef PTC_STRICT_32BIT_ACCESS
assign wb_err_o = wb_cyc_i & wb_stb_i & (wb_sel_i != 4'b1111);
`else
assign wb_err_o = 1'b0;
`endif
`endif

//
// Counter clock is selected by RPTC_CTRL[ECLK]. When it is set,
// external clock is used.
//
assign cntr_clk = rptc_ctrl[`PTC_RPTC_CTRL_ECLK] ? eclk_gate : wb_clk_i;

//
// Counter reset
//
assign cntr_rst = wb_rst_i;

//
// HRC clock is selected by RPTC_CTRL[CAPTE]. When it is set,
// ptc_capt is used as a clock.
//
assign hrc_clk = rptc_ctrl[`PTC_RPTC_CTRL_CAPTE] ? capt_pad_i : wb_clk_i;

//
// LRC clock is selected by RPTC_CTRL[CAPTE]. When it is set,
// inverted ptc_capt is used as a clock.
//
assign lrc_clk = rptc_ctrl[`PTC_RPTC_CTRL_CAPTE] ? ~capt_pad_i : wb_clk_i;

//
// PWM output driver enable is inverted RPTC_CTRL[OE]
//
assign oen_padoen_o = ~rptc_ctrl[`PTC_RPTC_CTRL_OE];

//
// Use RPTC_CTRL[NEC]
//
assign eclk_gate = gate_clk_pad_i ^ rptc_ctrl[`PTC_RPTC_CTRL_NEC];

//
// Gate function is active when RPTC_CTRL[ECLK] is cleared
//
assign gate = eclk_gate & ~rptc_ctrl[`PTC_RPTC_CTRL_ECLK];

//
// Full address decoder
//
`ifdef PTC_FULL_DECODE
assign full_decoding = (wb_adr_i[`PTC_ADDRHH:`PTC_ADDRHL] == {`PTC_ADDRHH-`PTC_ADDRHL+1{1'b0}}) &
			(wb_adr_i[`PTC_ADDRLH:`PTC_ADDRLL] == {`PTC_ADDRLH-`PTC_ADDRLL+1{1'b0}});
`else
assign full_decoding = 1'b1;
`endif

//
// PTC registers address decoder
//
assign rptc_cntr_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`PTC_OFS_BITS] == `PTC_RPTC_CNTR) & full_decoding;
assign rptc_hrc_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`PTC_OFS_BITS] == `PTC_RPTC_HRC) & full_decoding;
assign rptc_lrc_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`PTC_OFS_BITS] == `PTC_RPTC_LRC) & full_decoding;
assign rptc_ctrl_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`PTC_OFS_BITS] == `PTC_RPTC_CTRL) & full_decoding;

//
// Write to RPTC_CTRL or update of RPTC_CTRL[INT] bit
//
`ifdef PTC_RPTC_CTRL
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rptc_ctrl <= #1 9'b0;
	else if (rptc_ctrl_sel && wb_we_i)
		rptc_ctrl <= #1 wb_dat_i[8:0];
	else if (rptc_ctrl[`PTC_RPTC_CTRL_INTE])
		rptc_ctrl[`PTC_RPTC_CTRL_INT] <= #1 rptc_ctrl[`PTC_RPTC_CTRL_INT] | int;
`else
assign rptc_ctrl = `PTC_DEF_RPTC_CTRL;
`endif

//
// Write to RPTC_HRC
//
`ifdef PTC_RPTC_HRC
always @(posedge hrc_clk or posedge wb_rst_i)
	if (wb_rst_i)
		rptc_hrc <= #1 {cw{1'b0}};
	else if (rptc_hrc_sel && wb_we_i)
		rptc_hrc <= #1 wb_dat_i[cw-1:0];
	else if (rptc_ctrl[`PTC_RPTC_CTRL_CAPTE])
		rptc_hrc <= #1 rptc_cntr;
`else
assign rptc_hrc = `DEF_RPTC_HRC;
`endif

//
// Write to RPTC_LRC
//
`ifdef PTC_RPTC_LRC
always @(posedge lrc_clk or posedge wb_rst_i)
	if (wb_rst_i)
		rptc_lrc <= #1 {cw{1'b0}};
	else if (rptc_lrc_sel && wb_we_i)
		rptc_lrc <= #1 wb_dat_i[cw-1:0];
	else if (rptc_ctrl[`PTC_RPTC_CTRL_CAPTE])
		rptc_lrc <= #1 rptc_cntr;
`else
assign rptc_lrc = `DEF_RPTC_LRC;
`endif

//
// Write to or increment of RPTC_CNTR
//
`ifdef PTC_RPTC_CNTR
always @(posedge cntr_clk or posedge cntr_rst)
	if (cntr_rst)
		rptc_cntr <= #1 {cw{1'b0}};
	else if (rptc_cntr_sel && wb_we_i)
		rptc_cntr <= #1 wb_dat_i[cw-1:0];
	else if (restart)
		rptc_cntr <= #1 {cw{1'b0}};
	else if (!stop && rptc_ctrl[`PTC_RPTC_CTRL_EN] && !gate)
		rptc_cntr <= #1 rptc_cntr + 1;
`else
assign rptc_cntr = `DEF_RPTC_CNTR;
`endif

//
// Read PTC registers
//
always @(wb_adr_i or rptc_hrc or rptc_lrc or rptc_ctrl or rptc_cntr)
	case (wb_adr_i[`PTC_OFS_BITS])	// synopsys full_case parallel_case
`ifdef PTC_READREGS
		`PTC_RPTC_HRC: wb_dat_o[dw-1:0] = {{dw-cw{1'b0}}, rptc_hrc};
		`PTC_RPTC_LRC: wb_dat_o[dw-1:0] = {{dw-cw{1'b0}}, rptc_lrc};
		`PTC_RPTC_CTRL: wb_dat_o[dw-1:0] = {{dw-9{1'b0}}, rptc_ctrl};
`endif
		default: wb_dat_o[dw-1:0] = {{dw-cw{1'b0}}, rptc_cntr};
	endcase

//
// A match when RPTC_HRC is equal to RPTC_CNTR
//
assign hrc_match = rptc_ctrl[`PTC_RPTC_CTRL_EN] & (rptc_cntr == rptc_hrc);

//
// A match when RPTC_LRC is equal to RPTC_CNTR
//
assign lrc_match = rptc_ctrl[`PTC_RPTC_CTRL_EN] & (rptc_cntr == rptc_lrc);

//
// Restart counter when lrc_match asserted and RPTC_CTRL[SINGLE] cleared
// or when RPTC_CTRL[CNTRRST] is set
//
assign restart = lrc_match & ~rptc_ctrl[`PTC_RPTC_CTRL_SINGLE]
	| rptc_ctrl[`PTC_RPTC_CTRL_CNTRRST];

//
// Stop counter when lrc_match and RPTC_CTRL[SINGLE] both asserted
//
assign stop = lrc_match & rptc_ctrl[`PTC_RPTC_CTRL_SINGLE];

//
// PWM reset when lrc_match or system reset
//
assign pwm_rst = lrc_match | wb_rst_i;

//
// PWM output
//
always @(posedge wb_clk_i)	// posedge pwm_rst or posedge hrc_match !!! Damjan
	if (pwm_rst)
		pwm_pad_o <= #1 1'b0;
	else if (hrc_match)
		pwm_pad_o <= #1 1'b1;

//
// Generate an interrupt request
//
assign int_match = (lrc_match | hrc_match) & rptc_ctrl[`PTC_RPTC_CTRL_INTE];

// Register interrupt request
always @(posedge wb_rst_i or posedge wb_clk_i) // posedge int_match (instead of wb_rst_i)
	if (wb_rst_i)
		int <= #1 1'b0;
	else if (int_match)
		int <= #1 1'b1;
	else
		int <= #1 1'b0;

//
// Alias
//
assign wb_inta_o = rptc_ctrl[`PTC_RPTC_CTRL_INT];

`else

//
// When PTC is not implemented, drive all outputs as would when RPTC_CTRL
// is cleared and WISHBONE transfers complete with errors
//
assign wb_inta_o = 1'b0;
assign wb_ack_o = 1'b0;
assign wb_err_o = cyc_i & stb_i;
assign pwm_pad_o = 1'b0;
assign oen_padoen_o = 1'b1;

//
// Read PTC registers
//
`ifdef PTC_READREGS
assign wb_dat_o = {dw{1'b0}};
`endif

`endif

endmodule
