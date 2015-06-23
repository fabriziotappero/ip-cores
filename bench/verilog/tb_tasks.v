//////////////////////////////////////////////////////////////////////
////                                                              ////
////  PTC Testbench Tasks                                         ////
////                                                              ////
////  This file is part of the PTC project                        ////
////  http://www.opencores.org/cores/ptc/                         ////
////                                                              ////
////  Description                                                 ////
////  Testbench tasks.                                            ////
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
// Revision 1.2  2001/08/21 23:23:48  lampret
// Changed directory structure, defines and port names.
//
// Revision 1.1  2001/06/05 07:45:32  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

`include "timescale.v"
`include "ptc_defines.v"
`include "tb_defines.v"

module tb_tasks;

integer nr_failed;
integer ints_disabled;
integer ints_working;
integer capt_working;
integer monitor_ptc_pwm, pwm_l1, pwm_l2;

//
// Count/report failed tests
//
task failed;
begin
	$display("FAILED !!!");
	nr_failed = nr_failed + 1;
end
endtask

//
// Set RPTC_CNTR register
//
task setcntr;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`PTC_RPTC_CNTR<<2, val, 4'b1111);
end

endtask

//
// Set PTC_RPTC_HRC register
//
task sethrc;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`PTC_RPTC_HRC<<2, val, 4'b1111);
end

endtask

//
// Set PTC_RPTC_LRC register
//
task setlrc;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`PTC_RPTC_LRC<<2, val, 4'b1111);
end

endtask

//
// Set PTC_RPTC_CTRL register
//
task setctrl;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`PTC_RPTC_CTRL<<2, val, 4'b1111);
end

endtask

//
// Display RPTC_CNTR register
//
task showcntr;

reg	[31:0] tmp;
begin
	tb_top.wb_master.rd(`PTC_RPTC_CNTR<<2, tmp);
	$write(" RPTC_CNTR: %h", tmp);
end

endtask

//
// Display RPTC_HRC register
//
task showhrc;

reg	[31:0] tmp;
begin
	tb_top.wb_master.rd(`PTC_RPTC_HRC<<2, tmp);
	$write(" RPTC_HRC: %h", tmp);
end

endtask
//
// Display RPTC_LRC register
//
task showlrc;

reg	[31:0] tmp;
begin
	tb_top.wb_master.rd(`PTC_RPTC_LRC<<2, tmp);
	$write(" RPTC_LRC:%h", tmp);
end

endtask
//
// Display RPTC_CTRL register
//
task showctrl;

reg	[31:0] tmp;
begin
	tb_top.wb_master.rd(`PTC_RPTC_CTRL<<2, tmp);
	$write(" RPTC_CTRL: %h", tmp);
end

endtask

//
// Compare parameter with PTC_RPTC_CNTR register
//
task comp_cntr;
input	[31:0] 	val;
output		ret;

reg	[31:0]	tmp;
reg		ret;
begin
	tb_top.wb_master.rd(`PTC_RPTC_CNTR<<2, tmp);

	if (tmp == val)
		ret = 1;
	else
		ret = 0;
end

endtask

//
// Compare parameter with PTC_RPTC_HRC register
//
task comp_hrc;
input	[31:0] 	val;
output		ret;

reg	[31:0]	tmp;
reg		ret;
begin
	tb_top.wb_master.rd(`PTC_RPTC_HRC<<2, tmp);

	if (tmp == val)
		ret = 1;
	else
		ret = 0;
end

endtask


//
// Compare parameter with PTC_RPTC_LRC register
//
task comp_lrc;
input	[31:0] 	val;
output		ret;

reg	[31:0]	tmp;
reg		ret;
begin
	tb_top.wb_master.rd(`PTC_RPTC_LRC<<2, tmp);

	if (tmp == val)
		ret = 1;
	else
		ret = 0;
end

endtask

//
// Get PTC_RPTC_CNTR register
//
task getcntr;
output	[31:0]	tmp;

begin
	tb_top.wb_master.rd(`PTC_RPTC_CNTR<<2, tmp);
end

endtask

//
// Get PTC_RPTC_HRC register
//
task gethrc;
output	[31:0]	tmp;

begin
	tb_top.wb_master.rd(`PTC_RPTC_HRC<<2, tmp);
end

endtask

//
// Get PTC_RPTC_LRC register
//
task getlrc;
output	[31:0]	tmp;

begin
	tb_top.wb_master.rd(`PTC_RPTC_LRC<<2, tmp);
end

endtask

//
// Get PTC_RPTC_CTRL register
//
task getctrl;
output	[31:0]	tmp;

begin
	tb_top.wb_master.rd(`PTC_RPTC_CTRL<<2, tmp);
end

endtask

//
// Test operation of control bit PTC_RPTC_CTRL[ECLK]
//
task test_eclk;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[ECLK] ...");

	//
	// Phase 1
	//
	// PTC uses WISHBONE clock
	//

	// Disable PTC, reset counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC and PTC_RPTC_LRC to some high value
	sethrc('hffffffff);
	setlrc('hffffffff);

	// Enable PTC
	setctrl(1 << `PTC_RPTC_CTRL_EN);

	// Wait for time to advance
	#20000;

	// Get counter
	getcntr(l1);

	//
	// Phase 2
	//
	// PTC uses external clock
	//

	// Disable PTC, reset counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Enable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif
	// Do 10000 external clock cyles
	tb_top.clkrst.gen_ptc_ecgt(10000);

	// Get counter
	getcntr(l2);

	//
	// Phase 3
	//
	// Compare counter from phase 1 and phase 2
	//
	if (l2 - l1 == 7498)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[EN]
//
task test_en;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[EN] ...");

	//
	// Phase 1
	//
	// PTC does 1000 external clock cycles
	//

	// Disable PTC, reset counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Enable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif
	// Do 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Get counter
	getcntr(l1);

	//
	// Phase 2
	//
	// Disable PTC and run for another 1000 external clock cycles
	//

	// Disable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif
	// Do 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Get counter
	getcntr(l2);

	//
	// Phase 3
	//
	// Compare counter from phase 1 and phase 2. Should be the same.
	//
	if (l1 == l2 && l2 == 1000)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[NEC]
//
task test_nec;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[NEC] ...");

	//
	// Phase 1
	//
	// PTC does 1000 external clock cycles
	//

	// Disable PTC, reset counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Enable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif
	// Do 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Get counter
	getcntr(l1);

	//
	// Phase 2
	//
	// Enable PTC_RPTC_CTRL[NEC] and run for another 1000 external clock cycles
	//

	// Enable PTC_RPTC_CTRL[NEC], use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK | 1 << `PTC_RPTC_CTRL_NEC);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif
	// Do 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Get counter
	getcntr(l2);

	//
	// Phase 3
	//
	// Compare counter from phase 1 and phase 2.
	//
	if (l2 - l1 == 1001)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[CNTRRST]
//
task test_cntrrst;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[CNTRRST] ...");

	//
	// Phase 1
	//
	// Set counter and clear it
	//

	// Disable PTC
	setctrl(0);

	// Manually set counter
	setcntr('d1234);
`ifdef PTC_DEBUG
	showctrl;
	showcntr;
`endif

	// Get counter
	getcntr(l1);

	// Disable PTC, reset counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Get counter
	getcntr(l2);

	//
	// Phase 3
	//
	// Counter l1 should be 1234 and counter l2 should be zero
	//
	if (l1 == 1234 && l2 == 0)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[OE]
//
task test_oe;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[OE] ...");

	//
	// Phase 1
	//
	// Clear PTC_RPTC_CTRL[OE]
	//

	// Disable PTC, clear PTC_RPTC_CTRL[OE]
	setctrl(0);

`ifdef PTC_DEBUG
	showctrl;
`endif

	// Get ptc_oen
	l1 = tb_top.ptc_top.oen_padoen_o;

	//
	// Phase 2
	//
	// Set PTC_RPTC_CTRL[OE]
	//

	// Disable PTC, set PTC_RPTC_CTRL[OE]
	setctrl(1 << `PTC_RPTC_CTRL_OE);

`ifdef PTC_DEBUG
	showctrl;
`endif

	// Get ptc_oen
	l2 = tb_top.ptc_top.oen_padoen_o;

	//
	// Phase 3
	//
	// l1 should be 1 and l2 should be zero
	//
	if (l1 && !l2)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[CAPTE]
//
task test_capte;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[CAPTE] ...");

	//
	// Phase 1
	//
	// Run counter off external clock and capture it into PTC_RPTC_HRC/LRC
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC/LRC to some high value
	sethrc('hffffffff);
	setlrc('hffffffff);

	// Enable PTC, use external clock, enable PTC_RPTC_CTRL[CAPTE]
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK | 1 << `PTC_RPTC_CTRL_CAPTE);

`ifdef PTC_DEBUG
	showctrl;
`endif

	// Do 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Do posedge ptc_capt
	tb_top.set_ptc_capt(1);

	// Get PTC_RPTC_HRC
	gethrc(l1);

	// Do additional 1000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1000);

	// Do posedge ptc_capt
	tb_top.set_ptc_capt(0);

	// Get PTC_RPTC_LRC
	getlrc(l2);

	//
	// Phase 3
	//
	// l1 should be 1000 and l2 should be 2000
	//
	if (l1 == 1000 && l2 == 2000) begin
		$display(" OK");
		capt_working = 1;
	end else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[SINGLE]
//
task test_single;
integer		l1, l2;
begin
	$write("  Testing control bit RPTC_CTRL[SINGLE] ...");

	//
	// Phase 1
	//
	// Run counter off external clock with cleared PTC_RPTC_CTRL[SINGLE].
	// Counter should roll over when it reaches PTC_RPTC_LRC value.
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC to some high value and PTC_RPTC_LRC to 1000
	sethrc('hffffffff);
	setlrc('d1000);

	// Enable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
`endif

	// Do 1501 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1501);

	// Get counter
	getcntr(l1);

	//
	// Phase 2
	//
	// Run counter off external clock with PTC_RPTC_CTRL[SINGLE] set.
	// Counter should stop when it reaches PTC_RPTC_LRC value.
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC to some high value and PTC_RPTC_LRC to 1000
	sethrc('hffffffff);
	setlrc('d1000);

	// Enable PTC, use external clock, set PTC_RPTC_CTRL[SINGLE]
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK | 1 << `PTC_RPTC_CTRL_SINGLE);
`ifdef PTC_DEBUG
	showctrl;
`endif

	// Do 1500 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(1500);

	// Get counter
	getcntr(l2);


	//
	// Phase 3
	//
	// l1 should be 500 and l2 should be 1000
	//
	if (l1 == 500 && l2 == 1000)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[INTE] and PTC_RPTC_CTRL[INT]
//
task test_ints;
integer		l1, l2, l3;
begin
	$write("  Testing control bit RPTC_CTRL[INTE] and PTC_RPTC_CTRL[INT]...");

	//
	// Phase 1
	//
	// Run counter off external clock.
	// Counter should generate an interrupt when it reaches PTC_RPTC_LRC value.
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC to some high value and PTC_RPTC_LRC to 1000
	sethrc('hffffffff);
	setlrc('d1000);

	// Disable detection of spurious interrupts
	ints_disabled = 0;

	// Enable PTC, use external clock, set PTC_RPTC_CTRL[INTE]
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK | 1 << `PTC_RPTC_CTRL_INTE);
`ifdef PTC_DEBUG
	showctrl;
`endif
	// Do 999 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(999);

	// Sample interrupt request. It should be zero.
	l1 = tb_top.ptc_top.wb_inta_o;

	// Do 4 additional external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(4);

	// Sample interrupt request. It should be one.
	l2 = tb_top.ptc_top.wb_inta_o;

	//
	// Phase 2
	//
	// Mask interrupt.
	//

	// Enable detection of spurious interrupts
	ints_disabled = 1;

	// Mask interrupt
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);

	// Sample interrupt request. It should be again zero.
	l3 = tb_top.ptc_top.wb_inta_o;

	//
	// Phase 3
	//
	// l1 should be zero, l2 should be one and l3 should be zero
	//
	if (!l1 && l2 && !l3) begin
		$display(" OK");
		ints_working = ints_working + 1;
	end else
		failed;
end
endtask

always @(posedge tb_top.ptc_top.gate_clk_pad_i)
	if (monitor_ptc_pwm && !tb_top.ptc_top.pwm_pad_o)
		pwm_l1 = pwm_l1 + 1;

always @(posedge tb_top.ptc_top.gate_clk_pad_i)
	if (monitor_ptc_pwm && tb_top.ptc_top.pwm_pad_o)
		pwm_l2 = pwm_l2 + 1;

//
// Test PWM mode
//
task test_pwm;
begin
	$write("  Testing PWM mode ...");

	//
	// Phase 1
	//
	// Run counter off external clock with PWM low for 10 clocks and
	// PWM high for 20 clocks
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set intervals 10 and 20
	// HRC must be set with number one less than low period
	// because it takes one clock cycle to reset the counter
	sethrc('d9);
	setlrc('d29);

	// Enable PTC, use external clock
	setctrl(1 << `PTC_RPTC_CTRL_EN | 1 << `PTC_RPTC_CTRL_ECLK);
`ifdef PTC_DEBUG
	showctrl;
`endif
	// Start monitoring ptc_pwm
	monitor_ptc_pwm = 1;

	// Do 3000 external clock cycles
	tb_top.clkrst.gen_ptc_ecgt(3000);

	// Stop monitoring ptc_pwm
	monitor_ptc_pwm = 0;

	//
	// Phase 2
	//
	// l1 should be 1000 and l2 should be 2000
	//
	if (pwm_l1 == 1000 && pwm_l2 == 2000)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test gate feature
//
task test_gate;
integer		l1, l2, l3;
begin
	$write("  Testing gate feature ...");

	//
	// Phase 1
	//
	// Run counter off WB clock and in the middle assert gating
	//

	// Disable PTC, clear counter
	setctrl(1 << `PTC_RPTC_CTRL_CNTRRST);

	// Set PTC_RPTC_HRC/LRC to some high value
	sethrc('hffffffff);
	setlrc('hffffffff);

	// Enable PTC
	setctrl(1 << `PTC_RPTC_CTRL_EN);
`ifdef PTC_DEBUG
	showctrl;
`endif

	// Increment counter
	#5000;

	// Get counter
	getcntr(l1);

	// Increment counter
	#5000;

	// Assert gate
	tb_top.clkrst.gen_ptc_ecgt(-1);

	// Get counter
	getcntr(l2);

	// Increment counter
	#5000;

	// Get counter (should be the same as l2)
	getcntr(l3);

	//
	// Phase 2
	//
	// l1 should be nonzero and l2 and l3 should be the same
	//
	if (l1 && l1 < l2 && l2 == l3)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test operation of control bit PTC_RPTC_CTRL[INTE] and PTC_RPTC_CTRL[INT]
//
task test_modes;
integer		l1, l2, l3;
begin

	// Test PWM mode
	test_pwm;

	$write("  Testing timer/counter mode ...");
	if (nr_failed == 0)
		$display(" OK");
	else
		failed;

	// Test gate feature
	test_gate;

	$write("  Testing interrupt feature ...");
	if (ints_working == 1)
		$display(" OK");
	else
		failed;

	$write("  Testing capture feature ...");
	if (capt_working == 1)
		$display(" OK");
	else
		failed;

end
endtask

//
// Do continues check for interrupts
//
always @(posedge tb_top.ptc_top.wb_inta_o)
	if (ints_disabled) begin
		$display("Spurious interrupt detected. ");
		failed;
		ints_working = 9876;
		$display;
	end

//
// Start of testbench test tasks
//
initial begin
`ifdef PTC_DUMP_VCD
	$dumpfile("../out/tb_top.vcd");
	$dumpvars(0);
`endif
	nr_failed = 0;
	ints_disabled = 1;
	ints_working = 0;
	capt_working = 0;
	monitor_ptc_pwm = 0;
	pwm_l1 = 0;
	pwm_l2 = 0;
	$display;
	$display("###");
	$display("### PTC IP Core Verification ###");
	$display("###");
	$display;
	$display("I. Testing correct operation of RPTC_CTRL control bits");
	$display;
	test_eclk;
	test_oe;
	test_cntrrst;
	test_en;
	test_nec;
	test_capte;
	test_single;
	test_ints;
	$display;
	$display("II. Testing modes of operation ...");
	$display;
	test_modes;
	$display;
	$display("###");
	$display("### FAILED TESTS: %d ###", nr_failed);
	$display("###");
	$display;
	$finish;
end

endmodule
