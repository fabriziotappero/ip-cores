//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Power Management                                   ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  PM according to OR1K architectural specification.           ////
////                                                              ////
////  To Do:                                                      ////
////   - add support for dynamic clock gating                     ////
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
// Revision 1.1  2001/07/20 00:46:21  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_pm_cm4(
		clk_i_cml_1,
		clk_i_cml_2,
		clk_i_cml_3,
		
	// RISC Internal Interface
	clk, rst, pic_wakeup, spr_write, spr_addr, spr_dat_i, spr_dat_o,
	
	// Power Management Interface
	pm_clksd, pm_cpustall, pm_dc_gate, pm_ic_gate, pm_dmmu_gate,
	pm_immu_gate, pm_tt_gate, pm_cpu_gate, pm_wakeup, pm_lvolt
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
reg  pm_cpustall_cml_3;
reg  pm_cpustall_cml_2;
reg  pm_cpustall_cml_1;
reg [ 3 : 0 ] sdf_cml_3;
reg [ 3 : 0 ] sdf_cml_2;
reg [ 3 : 0 ] sdf_cml_1;
reg  dme_cml_3;
reg  dme_cml_2;
reg  dme_cml_1;
reg  sme_cml_3;
reg  sme_cml_2;
reg  sme_cml_1;
reg  dcge_cml_3;
reg  dcge_cml_2;
reg  dcge_cml_1;



//
// RISC Internal Interface
//
input		clk;		// Clock
input		rst;		// Reset
input		pic_wakeup;	// Wakeup from the PIC
input		spr_write;	// SPR Read/Write
input	[31:0]	spr_addr;	// SPR Address
input	[31:0]	spr_dat_i;	// SPR Write Data
output	[31:0]	spr_dat_o;	// SPR Read Data

//
// Power Management Interface
//
input		pm_cpustall;	// Stall the CPU
output	[3:0]	pm_clksd;	// Clock Slowdown factor
output		pm_dc_gate;	// Gate DCache clock
output		pm_ic_gate;	// Gate ICache clock
output		pm_dmmu_gate;	// Gate DMMU clock
output		pm_immu_gate;	// Gate IMMU clock
output		pm_tt_gate;	// Gate Tick Timer clock
output		pm_cpu_gate;	// Gate main RISC/CPU clock
output		pm_wakeup;	// Activate (de-gate) all clocks
output		pm_lvolt;	// Lower operating voltage

`ifdef OR1200_PM_IMPLEMENTED

//
// Power Management Register bits
//
reg	[3:0]	sdf;	// Slow-down factor
reg		dme;	// Doze Mode Enable
reg		sme;	// Sleep Mode Enable
reg		dcge;	// Dynamic Clock Gating Enable

//
// Internal wires
//
wire		pmr_sel; // PMR select

//
// PMR address decoder (partial decoder)
//
`ifdef OR1200_PM_PARTIAL_DECODING

// SynEDA CoreMultiplier
// assignment(s): pmr_sel
// replace(s): spr_addr
assign pmr_sel = (spr_addr_cml_3[`OR1200_SPR_GROUP_BITS] == `OR1200_SPRGRP_PM) ? 1'b1 : 1'b0;
`else
assign pmr_sel = ((spr_addr[`OR1200_SPR_GROUP_BITS] == `OR1200_SPRGRP_PM) &&
		  (spr_addr[`OR1200_SPR_OFS_BITS] == `OR1200_PM_OFS_PMR)) ? 1'b1 : 1'b0;
`endif

//
// Write to PMR and also PMR[DME]/PMR[SME] reset when
// pic_wakeup is asserted
//

// SynEDA CoreMultiplier
// assignment(s): sdf, dme, sme, dcge
// replace(s): spr_write, spr_dat_i, sdf, dme, sme, dcge
always @(posedge clk or posedge rst)
	if (rst)
		{dcge, sme, dme, sdf} <= 7'b0;
	else begin  dcge <= dcge_cml_3; sme <= sme_cml_3; dme <= dme_cml_3; sdf <= sdf_cml_3; if (pmr_sel && spr_write_cml_3) begin
		sdf <= #1 spr_dat_i_cml_3[`OR1200_PM_PMR_SDF];
		dme <= #1 spr_dat_i_cml_3[`OR1200_PM_PMR_DME];
		sme <= #1 spr_dat_i_cml_3[`OR1200_PM_PMR_SME];
		dcge <= #1 spr_dat_i_cml_3[`OR1200_PM_PMR_DCGE];
	end
	else if (pic_wakeup) begin
		dme <= #1 1'b0;
		sme <= #1 1'b0;
	end end

//
// Read PMR
//
`ifdef OR1200_PM_READREGS
assign spr_dat_o[`OR1200_PM_PMR_SDF] = sdf_cml_1;
assign spr_dat_o[`OR1200_PM_PMR_DME] = dme_cml_1;
assign spr_dat_o[`OR1200_PM_PMR_SME] = sme_cml_1;
assign spr_dat_o[`OR1200_PM_PMR_DCGE] = dcge_cml_1;
`ifdef OR1200_PM_UNUSED_ZERO

// SynEDA CoreMultiplier
// assignment(s): spr_dat_o
// replace(s): sdf, dme, sme, dcge
assign spr_dat_o[`OR1200_PM_PMR_UNUSED] = 25'b0;
`endif
`endif

//
// Generate pm_clksd
//

// SynEDA CoreMultiplier
// assignment(s): pm_clksd
// replace(s): sdf
assign pm_clksd = sdf_cml_3;

//
// Statically generate all clock gate outputs
// TODO: add dynamic clock gating feature
//

// SynEDA CoreMultiplier
// assignment(s): pm_cpu_gate
// replace(s): dme, sme
assign pm_cpu_gate = (dme_cml_3 | sme_cml_3) & ~pic_wakeup;
assign pm_dc_gate = pm_cpu_gate;
assign pm_ic_gate = pm_cpu_gate;
assign pm_dmmu_gate = pm_cpu_gate;
assign pm_immu_gate = pm_cpu_gate;

// SynEDA CoreMultiplier
// assignment(s): pm_tt_gate
// replace(s): sme
assign pm_tt_gate = sme_cml_3 & ~pic_wakeup;

//
// Assert pm_wakeup when pic_wakeup is asserted
//
assign pm_wakeup = pic_wakeup;

//
// Assert pm_lvolt when pm_cpu_gate or pm_cpustall are asserted
//

// SynEDA CoreMultiplier
// assignment(s): pm_lvolt
// replace(s): pm_cpustall
assign pm_lvolt = pm_cpu_gate | pm_cpustall_cml_3;

`else

//
// When PM is not implemented, drive all outputs as would when PM is disabled
//
assign pm_clksd = 4'b0;
assign pm_cpu_gate = 1'b0;
assign pm_dc_gate = 1'b0;
assign pm_ic_gate = 1'b0;
assign pm_dmmu_gate = 1'b0;
assign pm_immu_gate = 1'b0;
assign pm_tt_gate = 1'b0;
assign pm_wakeup = 1'b1;
assign pm_lvolt = 1'b0;

//
// Read PMR
//
`ifdef OR1200_PM_READREGS
assign spr_dat_o[`OR1200_PM_PMR_SDF] = 4'b0;
assign spr_dat_o[`OR1200_PM_PMR_DME] = 1'b0;
assign spr_dat_o[`OR1200_PM_PMR_SME] = 1'b0;
assign spr_dat_o[`OR1200_PM_PMR_DCGE] = 1'b0;
`ifdef OR1200_PM_UNUSED_ZERO
assign spr_dat_o[`OR1200_PM_PMR_UNUSED] = 25'b0;
`endif
`endif

`endif


always @ (posedge clk_i_cml_1) begin
spr_write_cml_1 <= spr_write;
spr_addr_cml_1 <= spr_addr;
spr_dat_i_cml_1 <= spr_dat_i;
pm_cpustall_cml_1 <= pm_cpustall;
sdf_cml_1 <= sdf;
dme_cml_1 <= dme;
sme_cml_1 <= sme;
dcge_cml_1 <= dcge;
end
always @ (posedge clk_i_cml_2) begin
spr_write_cml_2 <= spr_write_cml_1;
spr_addr_cml_2 <= spr_addr_cml_1;
spr_dat_i_cml_2 <= spr_dat_i_cml_1;
pm_cpustall_cml_2 <= pm_cpustall_cml_1;
sdf_cml_2 <= sdf_cml_1;
dme_cml_2 <= dme_cml_1;
sme_cml_2 <= sme_cml_1;
dcge_cml_2 <= dcge_cml_1;
end
always @ (posedge clk_i_cml_3) begin
spr_write_cml_3 <= spr_write_cml_2;
spr_addr_cml_3 <= spr_addr_cml_2;
spr_dat_i_cml_3 <= spr_dat_i_cml_2;
pm_cpustall_cml_3 <= pm_cpustall_cml_2;
sdf_cml_3 <= sdf_cml_2;
dme_cml_3 <= dme_cml_2;
sme_cml_3 <= sme_cml_2;
dcge_cml_3 <= dcge_cml_2;
end
endmodule

