//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's WISHBONE BIU                                       ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Implements WISHBONE interface                               ////
////                                                              ////
////  To Do:                                                      ////
////   - if biu_cyc/stb are deasserted and wb_ack_i is asserted   ////
////   and this happens even before aborted_r is asssrted,        ////
////   wb_ack_i will be delivered even though transfer is         ////
////   internally considered already aborted. However most        ////
////   wb_ack_i are externally registered and delayed. Normally   ////
////   this shouldn't cause any problems.                         ////
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
// Revision 1.6.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.6  2003/04/07 20:57:46  lampret
// Fixed OR1200_CLKDIV_x_SUPPORTED defines. Fixed order of ifdefs.
//
// Revision 1.5  2002/12/08 08:57:56  lampret
// Added optional support for WB B3 specification (xwb_cti_o, xwb_bte_o). Made xwb_cab_o optional.
//
// Revision 1.4  2002/09/16 03:09:16  lampret
// Fixed a combinational loop.
//
// Revision 1.3  2002/08/12 05:31:37  lampret
// Added optional retry counter for wb_rty_i. Added graceful termination for aborted transfers.
//
// Revision 1.2  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.12  2001/11/22 13:42:51  lampret
// Added wb_cyc_o assignment after it was removed by accident.
//
// Revision 1.11  2001/11/20 21:28:10  lampret
// Added optional sampling of inputs.
//
// Revision 1.10  2001/11/18 11:32:00  lampret
// OR1200_REGISTERED_OUTPUTS can now be enabled.
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:35  igorm
// no message
//
// Revision 1.3  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:23  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_wb_biu_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
		
	// RISC clock, reset and clock control
	clk, rst, clmode,

	// WISHBONE interface
	wb_clk_i, wb_rst_i, wb_ack_i, wb_err_i, wb_rty_i, wb_dat_i,
	wb_cyc_o, wb_adr_o, wb_stb_o, wb_we_o, wb_sel_o, wb_dat_o,
`ifdef OR1200_WB_CAB
	wb_cab_o,
`endif
`ifdef OR1200_WB_B3
	wb_cti_o, wb_bte_o,
`endif

	// Internal RISC bus
	biu_dat_i, biu_adr_i, biu_cyc_i, biu_stb_i, biu_we_i, biu_sel_i, biu_cab_i,
	biu_dat_o, biu_ack_o, biu_err_o
);


input clk_i_cml_1;
input clk_i_cml_2;
reg [ 1 : 0 ] clmode_cml_1;
reg  wb_ack_i_cml_2;
reg  wb_ack_i_cml_1;
reg  wb_err_i_cml_2;
reg  wb_err_i_cml_1;
reg [ 32 - 1 : 0 ] wb_dat_i_cml_1;
reg  wb_cyc_o_cml_2;
reg  wb_cyc_o_cml_1;
reg [ 32 - 1 : 0 ] wb_adr_o_cml_2;
reg [ 32 - 1 : 0 ] wb_adr_o_cml_1;
reg  wb_stb_o_cml_2;
reg  wb_stb_o_cml_1;
reg  wb_we_o_cml_2;
reg  wb_we_o_cml_1;
reg [ 3 : 0 ] wb_sel_o_cml_2;
reg [ 3 : 0 ] wb_sel_o_cml_1;
reg [ 32 - 1 : 0 ] wb_dat_o_cml_2;
reg [ 32 - 1 : 0 ] wb_dat_o_cml_1;
reg  wb_cab_o_cml_2;
reg  wb_cab_o_cml_1;
reg [ 1 : 0 ] valid_div_cml_2;
reg [ 1 : 0 ] valid_div_cml_1;
reg  aborted_r_cml_2;
reg  aborted_r_cml_1;



parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_OPERAND_WIDTH;

//
// RISC clock, reset and clock control
//
input			clk;		// RISC clock
input			rst;		// RISC reset
input	[1:0]		clmode;		// 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4

//
// WISHBONE interface
//
input			wb_clk_i;	// clock input
input			wb_rst_i;	// reset input
input			wb_ack_i;	// normal termination
input			wb_err_i;	// termination w/ error
input			wb_rty_i;	// termination w/ retry
input	[dw-1:0]	wb_dat_i;	// input data bus
output			wb_cyc_o;	// cycle valid output
output	[aw-1:0]	wb_adr_o;	// address bus outputs
output			wb_stb_o;	// strobe output
output			wb_we_o;	// indicates write transfer
output	[3:0]		wb_sel_o;	// byte select outputs
output	[dw-1:0]	wb_dat_o;	// output data bus
`ifdef OR1200_WB_CAB
output			wb_cab_o;	// consecutive address burst
`endif
`ifdef OR1200_WB_B3
output	[2:0]		wb_cti_o;	// cycle type identifier
output	[1:0]		wb_bte_o;	// burst type extension
`endif

//
// Internal RISC interface
//
input	[dw-1:0]	biu_dat_i;	// input data bus
input	[aw-1:0]	biu_adr_i;	// address bus
input			biu_cyc_i;	// WB cycle
input			biu_stb_i;	// WB strobe
input			biu_we_i;	// WB write enable
input			biu_cab_i;	// CAB input
input	[3:0]		biu_sel_i;	// byte selects
output	[31:0]		biu_dat_o;	// output data bus
output			biu_ack_o;	// ack output
output			biu_err_o;	// err output

//
// Registers
//
reg	[1:0]		valid_div;	// Used for synchronization
`ifdef OR1200_REGISTERED_OUTPUTS
reg	[aw-1:0]	wb_adr_o;	// address bus outputs
reg			wb_cyc_o;	// cycle output
reg			wb_stb_o;	// strobe output
reg			wb_we_o;	// indicates write transfer
reg	[3:0]		wb_sel_o;	// byte select outputs
`ifdef OR1200_WB_CAB
reg			wb_cab_o;	// CAB output
`endif
`ifdef OR1200_WB_B3
reg	[1:0]		burst_len;	// burst counter
reg	[2:0]		wb_cti_o;	// cycle type identifier
`endif
reg	[dw-1:0]	wb_dat_o;	// output data bus
`endif
`ifdef OR1200_REGISTERED_INPUTS
reg			long_ack_o;	// normal termination
reg			long_err_o;	// error termination
reg	[dw-1:0]	biu_dat_o;	// output data bus
`else
wire			long_ack_o;	// normal termination
wire			long_err_o;	// error termination
`endif
wire			aborted;	// Graceful abort
reg			aborted_r;	// Graceful abort
wire			retry;		// Retry
`ifdef OR1200_WB_RETRY
reg	[`OR1200_WB_RETRY-1:0] retry_cntr;	// Retry counter
`endif

//
// WISHBONE I/F <-> Internal RISC I/F conversion
//

//
// Address bus
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_adr_o
// replace(s): wb_ack_i, wb_adr_o, wb_stb_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_adr_o <= #1 {aw{1'b0}};
	else begin  wb_adr_o <= wb_adr_o_cml_2; if ((biu_cyc_i & biu_stb_i) & ~wb_ack_i_cml_2 & ~aborted & ~(wb_stb_o_cml_2 & ~wb_ack_i_cml_2))
		wb_adr_o <= #1 biu_adr_i; end
`else
assign wb_adr_o = biu_adr_i;
`endif

//
// Input data bus
//
`ifdef OR1200_REGISTERED_INPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		biu_dat_o <= #1 32'h0000_0000;
	else if (wb_ack_i)
		biu_dat_o <= #1 wb_dat_i_cml_1;
`else

// SynEDA CoreMultiplier
// assignment(s): biu_dat_o
// replace(s): wb_dat_i
assign biu_dat_o = wb_dat_i_cml_1;
`endif

//
// Output data bus
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_dat_o
// replace(s): wb_ack_i, wb_dat_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_dat_o <= #1 {dw{1'b0}};
	else begin  wb_dat_o <= wb_dat_o_cml_2; if ((biu_cyc_i & biu_stb_i) & ~wb_ack_i_cml_2 & ~aborted)
		wb_dat_o <= #1 biu_dat_i; end
`else
assign wb_dat_o = biu_dat_i;
`endif

//
// Valid_div counts RISC clock cycles by modulo 4
// and is used to synchronize external WB i/f to
// RISC clock
//

// SynEDA CoreMultiplier
// assignment(s): valid_div
// replace(s): valid_div
always @(posedge clk or posedge rst)
	if (rst)
		valid_div <= #1 2'b0;
	else begin  valid_div <= valid_div_cml_2;
		valid_div <= #1 valid_div_cml_2 + 1'd1; end

//
// biu_ack_o is one RISC clock cycle long long_ack_o.
// long_ack_o is one, two or four RISC clock cycles long because
// WISHBONE can work at 1, 1/2 or 1/4 RISC clock.
//
assign biu_ack_o = long_ack_o
`ifdef OR1200_CLKDIV_2_SUPPORTED
		& (valid_div[0] | ~clmode[0])
`ifdef OR1200_CLKDIV_4_SUPPORTED
		& (valid_div[1] | ~clmode[1])
`endif
`endif
		;

//
// Acknowledgment of the data to the RISC
//
// long_ack_o
//
`ifdef OR1200_REGISTERED_INPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		long_ack_o <= #1 1'b0;
	else
		long_ack_o <= #1 wb_ack_i & ~aborted;
`else
assign long_ack_o = wb_ack_i & ~aborted_r;
`endif

//
// biu_err_o is one RISC clock cycle long long_err_o.
// long_err_o is one, two or four RISC clock cycles long because
// WISHBONE can work at 1, 1/2 or 1/4 RISC clock.
//

// SynEDA CoreMultiplier
// assignment(s): biu_err_o
// replace(s): clmode, valid_div
assign biu_err_o = long_err_o
`ifdef OR1200_CLKDIV_2_SUPPORTED
		& (valid_div_cml_1[0] | ~clmode_cml_1[0])
`ifdef OR1200_CLKDIV_4_SUPPORTED
		& (valid_div_cml_1[1] | ~clmode_cml_1[1])
`endif
`endif
		;

//
// Error termination
//
// long_err_o
//
`ifdef OR1200_REGISTERED_INPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		long_err_o <= #1 1'b0;
	else
		long_err_o <= #1 wb_err_i_cml_1 & ~aborted;
`else

// SynEDA CoreMultiplier
// assignment(s): long_err_o
// replace(s): wb_err_i, aborted_r
assign long_err_o = wb_err_i_cml_1 & ~aborted_r_cml_1;
`endif

//
// Retry counter
//
// Assert 'retry' when 'wb_rty_i' is sampled high and keep it high
// until retry counter doesn't expire
// 
`ifdef OR1200_WB_RETRY
assign retry = wb_rty_i | (|retry_cntr);
`else
assign retry = 1'b0;
`endif
`ifdef OR1200_WB_RETRY
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		retry_cntr <= #1 1'b0;
	else if (wb_rty_i)
		retry_cntr <= #1 {`OR1200_WB_RETRY{1'b1}};
	else if (retry_cntr)
		retry_cntr <= #1 retry_cntr - 7'd1;
`endif

//
// Graceful completion of aborted transfers
//
// Assert 'aborted' when 1) current transfer is in progress (wb_stb_o; which
// we know is only asserted together with wb_cyc_o) 2) and in next WB clock cycle
// wb_stb_o would be deasserted (biu_cyc_i and biu_stb_i are low) 3) and
// there is no termination of current transfer in this WB clock cycle (wb_ack_i
// and wb_err_i are low).
// 'aborted_r' is registered 'aborted' and extended until this "aborted" transfer
// is properly terminated with wb_ack_i/wb_err_i.
// 

// SynEDA CoreMultiplier
// assignment(s): aborted
// replace(s): wb_ack_i, wb_err_i, wb_stb_o
assign aborted = wb_stb_o_cml_2 & ~(biu_cyc_i & biu_stb_i) & ~(wb_ack_i_cml_2 | wb_err_i_cml_2);

// SynEDA CoreMultiplier
// assignment(s): aborted_r
// replace(s): wb_ack_i, wb_err_i, aborted_r
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		aborted_r <= #1 1'b0;
	else begin  aborted_r <= aborted_r_cml_2; if (wb_ack_i_cml_2 | wb_err_i_cml_2)
		aborted_r <= #1 1'b0;
	else if (aborted)
		aborted_r <= #1 1'b1; end

//
// WB cyc_o
//
// Either 1) normal transfer initiated by biu_cyc_i (and biu_cab_i if
// bursts are enabled) and possibly suspended by 'retry'
// or 2) extended "aborted" transfer
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_cyc_o
// replace(s): wb_ack_i, wb_cyc_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_cyc_o <= #1 1'b0;
	else begin  wb_cyc_o <= wb_cyc_o_cml_2;
`ifdef OR1200_NO_BURSTS
		wb_cyc_o <= #1 biu_cyc_i & ~wb_ack_i_cml_2 & ~retry | aborted & ~wb_ack_i_cml_2;
`else
		wb_cyc_o <= #1 biu_cyc_i & ~wb_ack_i_cml_2 & ~retry | biu_cab_i | aborted & ~wb_ack_i_cml_2; end
`endif
`else
`ifdef OR1200_NO_BURSTS
assign wb_cyc_o = biu_cyc_i & ~retry;
`else
assign wb_cyc_o = biu_cyc_i | biu_cab_i & ~retry;
`endif
`endif

//
// WB stb_o
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_stb_o
// replace(s): wb_ack_i, wb_stb_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_stb_o <= #1 1'b0;
	else begin  wb_stb_o <= wb_stb_o_cml_2;
		wb_stb_o <= #1 (biu_cyc_i & biu_stb_i) & ~wb_ack_i_cml_2 & ~retry | aborted & ~wb_ack_i_cml_2; end
`else
assign wb_stb_o = biu_cyc_i & biu_stb_i;
`endif

//
// WB we_o
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_we_o
// replace(s): wb_we_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_we_o <= #1 1'b0;
	else begin  wb_we_o <= wb_we_o_cml_2;
		wb_we_o <= #1 biu_cyc_i & biu_stb_i & biu_we_i | aborted & wb_we_o_cml_2; end
`else
assign wb_we_o = biu_cyc_i & biu_stb_i & biu_we_i;
`endif

//
// WB sel_o
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_sel_o
// replace(s): wb_sel_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_sel_o <= #1 4'b0000;
	else begin  wb_sel_o <= wb_sel_o_cml_2;
		wb_sel_o <= #1 biu_sel_i; end
`else
assign wb_sel_o = biu_sel_i;
`endif

`ifdef OR1200_WB_CAB
//
// WB cab_o
//
`ifdef OR1200_REGISTERED_OUTPUTS

// SynEDA CoreMultiplier
// assignment(s): wb_cab_o
// replace(s): wb_cab_o
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_cab_o <= #1 1'b0;
	else begin  wb_cab_o <= wb_cab_o_cml_2;
		wb_cab_o <= #1 biu_cab_i; end
`else
assign wb_cab_o = biu_cab_i;
`endif
`endif

`ifdef OR1200_WB_B3
//
// Count burst beats
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		burst_len <= #1 2'b00;
	else if (biu_cab_i && burst_len && wb_ack_i)
		burst_len <= #1 burst_len - 1'b1;
	else if (~biu_cab_i)
		burst_len <= #1 2'b11;

//
// WB cti_o
//
`ifdef OR1200_REGISTERED_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_cti_o <= #1 3'b000;	// classic cycle
`ifdef OR1200_NO_BURSTS
	else
		wb_cti_o <= #1 3'b111;	// end-of-burst
`else
	else if (biu_cab_i && burst_len[1])
		wb_cti_o <= #1 3'b010;	// incrementing burst cycle
	else if (biu_cab_i && wb_ack_i)
		wb_cti_o <= #1 3'b111;	// end-of-burst
`endif	// OR1200_NO_BURSTS
`else
Unsupported !!!;
`endif

//
// WB bte_o
//
assign wb_bte_o = 2'b01;	// 4-beat wrap burst

`endif	// OR1200_WB_B3


always @ (posedge clk_i_cml_1) begin
clmode_cml_1 <= clmode;
wb_ack_i_cml_1 <= wb_ack_i;
wb_err_i_cml_1 <= wb_err_i;
wb_dat_i_cml_1 <= wb_dat_i;
wb_cyc_o_cml_1 <= wb_cyc_o;
wb_adr_o_cml_1 <= wb_adr_o;
wb_stb_o_cml_1 <= wb_stb_o;
wb_we_o_cml_1 <= wb_we_o;
wb_sel_o_cml_1 <= wb_sel_o;
wb_dat_o_cml_1 <= wb_dat_o;
wb_cab_o_cml_1 <= wb_cab_o;
valid_div_cml_1 <= valid_div;
aborted_r_cml_1 <= aborted_r;
end
always @ (posedge clk_i_cml_2) begin
wb_ack_i_cml_2 <= wb_ack_i_cml_1;
wb_err_i_cml_2 <= wb_err_i_cml_1;
wb_cyc_o_cml_2 <= wb_cyc_o_cml_1;
wb_adr_o_cml_2 <= wb_adr_o_cml_1;
wb_stb_o_cml_2 <= wb_stb_o_cml_1;
wb_we_o_cml_2 <= wb_we_o_cml_1;
wb_sel_o_cml_2 <= wb_sel_o_cml_1;
wb_dat_o_cml_2 <= wb_dat_o_cml_1;
wb_cab_o_cml_2 <= wb_cab_o_cml_1;
valid_div_cml_2 <= valid_div_cml_1;
aborted_r_cml_2 <= aborted_r_cml_1;
end
endmodule

