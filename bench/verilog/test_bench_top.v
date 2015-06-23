/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/wb_conmax/ ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: test_bench_top.v,v 1.2 2002-10-03 05:40:03 rudi Exp $
//
//  $Date: 2002-10-03 05:40:03 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1.1.1  2001/10/19 11:04:25  rudi
//               WISHBONE CONMAX IP Core
//
//
//
//
//
//


`include "wb_conmax_defines.v"

module test;

reg		clk;
reg		rst;

// IO Prototypes
wire	[31:0]	m0_data_i;
wire	[31:0]	m0_data_o;
wire	[31:0]	m0_addr_i;
wire	[3:0]	m0_sel_i;
wire		m0_we_i;
wire		m0_cyc_i;
wire		m0_stb_i;
wire		m0_ack_o;
wire		m0_err_o;
wire		m0_rty_o;
wire	[31:0]	m1_data_i;
wire	[31:0]	m1_data_o;
wire	[31:0]	m1_addr_i;
wire	[3:0]	m1_sel_i;
wire		m1_we_i;
wire		m1_cyc_i;
wire		m1_stb_i;
wire		m1_ack_o;
wire		m1_err_o;
wire		m1_rty_o;
wire	[31:0]	m2_data_i;
wire	[31:0]	m2_data_o;
wire	[31:0]	m2_addr_i;
wire	[3:0]	m2_sel_i;
wire		m2_we_i;
wire		m2_cyc_i;
wire		m2_stb_i;
wire		m2_ack_o;
wire		m2_err_o;
wire		m2_rty_o;
wire	[31:0]	m3_data_i;
wire	[31:0]	m3_data_o;
wire	[31:0]	m3_addr_i;
wire	[3:0]	m3_sel_i;
wire		m3_we_i;
wire		m3_cyc_i;
wire		m3_stb_i;
wire		m3_ack_o;
wire		m3_err_o;
wire		m3_rty_o;
wire	[31:0]	m4_data_i;
wire	[31:0]	m4_data_o;
wire	[31:0]	m4_addr_i;
wire	[3:0]	m4_sel_i;
wire		m4_we_i;
wire		m4_cyc_i;
wire		m4_stb_i;
wire		m4_ack_o;
wire		m4_err_o;
wire		m4_rty_o;
wire	[31:0]	m5_data_i;
wire	[31:0]	m5_data_o;
wire	[31:0]	m5_addr_i;
wire	[3:0]	m5_sel_i;
wire		m5_we_i;
wire		m5_cyc_i;
wire		m5_stb_i;
wire		m5_ack_o;
wire		m5_err_o;
wire		m5_rty_o;
wire	[31:0]	m6_data_i;
wire	[31:0]	m6_data_o;
wire	[31:0]	m6_addr_i;
wire	[3:0]	m6_sel_i;
wire		m6_we_i;
wire		m6_cyc_i;
wire		m6_stb_i;
wire		m6_ack_o;
wire		m6_err_o;
wire		m6_rty_o;
wire	[31:0]	m7_data_i;
wire	[31:0]	m7_data_o;
wire	[31:0]	m7_addr_i;
wire	[3:0]	m7_sel_i;
wire		m7_we_i;
wire		m7_cyc_i;
wire		m7_stb_i;
wire		m7_ack_o;
wire		m7_err_o;
wire		m7_rty_o;
wire	[31:0]	s0_data_i;
wire	[31:0]	s0_data_o;
wire	[31:0]	s0_addr_o;
wire	[3:0]	s0_sel_o;
wire		s0_we_o;
wire		s0_cyc_o;
wire		s0_stb_o;
wire		s0_ack_i;
wire		s0_err_i;
wire		s0_rty_i;
wire	[31:0]	s1_data_i;
wire	[31:0]	s1_data_o;
wire	[31:0]	s1_addr_o;
wire	[3:0]	s1_sel_o;
wire		s1_we_o;
wire		s1_cyc_o;
wire		s1_stb_o;
wire		s1_ack_i;
wire		s1_err_i;
wire		s1_rty_i;
wire	[31:0]	s2_data_i;
wire	[31:0]	s2_data_o;
wire	[31:0]	s2_addr_o;
wire	[3:0]	s2_sel_o;
wire		s2_we_o;
wire		s2_cyc_o;
wire		s2_stb_o;
wire		s2_ack_i;
wire		s2_err_i;
wire		s2_rty_i;
wire	[31:0]	s3_data_i;
wire	[31:0]	s3_data_o;
wire	[31:0]	s3_addr_o;
wire	[3:0]	s3_sel_o;
wire		s3_we_o;
wire		s3_cyc_o;
wire		s3_stb_o;
wire		s3_ack_i;
wire		s3_err_i;
wire		s3_rty_i;
wire	[31:0]	s4_data_i;
wire	[31:0]	s4_data_o;
wire	[31:0]	s4_addr_o;
wire	[3:0]	s4_sel_o;
wire		s4_we_o;
wire		s4_cyc_o;
wire		s4_stb_o;
wire		s4_ack_i;
wire		s4_err_i;
wire		s4_rty_i;
wire	[31:0]	s5_data_i;
wire	[31:0]	s5_data_o;
wire	[31:0]	s5_addr_o;
wire	[3:0]	s5_sel_o;
wire		s5_we_o;
wire		s5_cyc_o;
wire		s5_stb_o;
wire		s5_ack_i;
wire		s5_err_i;
wire		s5_rty_i;
wire	[31:0]	s6_data_i;
wire	[31:0]	s6_data_o;
wire	[31:0]	s6_addr_o;
wire	[3:0]	s6_sel_o;
wire		s6_we_o;
wire		s6_cyc_o;
wire		s6_stb_o;
wire		s6_ack_i;
wire		s6_err_i;
wire		s6_rty_i;
wire	[31:0]	s7_data_i;
wire	[31:0]	s7_data_o;
wire	[31:0]	s7_addr_o;
wire	[3:0]	s7_sel_o;
wire		s7_we_o;
wire		s7_cyc_o;
wire		s7_stb_o;
wire		s7_ack_i;
wire		s7_err_i;
wire		s7_rty_i;
wire	[31:0]	s8_data_i;
wire	[31:0]	s8_data_o;
wire	[31:0]	s8_addr_o;
wire	[3:0]	s8_sel_o;
wire		s8_we_o;
wire		s8_cyc_o;
wire		s8_stb_o;
wire		s8_ack_i;
wire		s8_err_i;
wire		s8_rty_i;
wire	[31:0]	s9_data_i;
wire	[31:0]	s9_data_o;
wire	[31:0]	s9_addr_o;
wire	[3:0]	s9_sel_o;
wire		s9_we_o;
wire		s9_cyc_o;
wire		s9_stb_o;
wire		s9_ack_i;
wire		s9_err_i;
wire		s9_rty_i;
wire	[31:0]	s10_data_i;
wire	[31:0]	s10_data_o;
wire	[31:0]	s10_addr_o;
wire	[3:0]	s10_sel_o;
wire		s10_we_o;
wire		s10_cyc_o;
wire		s10_stb_o;
wire		s10_ack_i;
wire		s10_err_i;
wire		s10_rty_i;
wire	[31:0]	s11_data_i;
wire	[31:0]	s11_data_o;
wire	[31:0]	s11_addr_o;
wire	[3:0]	s11_sel_o;
wire		s11_we_o;
wire		s11_cyc_o;
wire		s11_stb_o;
wire		s11_ack_i;
wire		s11_err_i;
wire		s11_rty_i;
wire	[31:0]	s12_data_i;
wire	[31:0]	s12_data_o;
wire	[31:0]	s12_addr_o;
wire	[3:0]	s12_sel_o;
wire		s12_we_o;
wire		s12_cyc_o;
wire		s12_stb_o;
wire		s12_ack_i;
wire		s12_err_i;
wire		s12_rty_i;
wire	[31:0]	s13_data_i;
wire	[31:0]	s13_data_o;
wire	[31:0]	s13_addr_o;
wire	[3:0]	s13_sel_o;
wire		s13_we_o;
wire		s13_cyc_o;
wire		s13_stb_o;
wire		s13_ack_i;
wire		s13_err_i;
wire		s13_rty_i;
wire	[31:0]	s14_data_i;
wire	[31:0]	s14_data_o;
wire	[31:0]	s14_addr_o;
wire	[3:0]	s14_sel_o;
wire		s14_we_o;
wire		s14_cyc_o;
wire		s14_stb_o;
wire		s14_ack_i;
wire		s14_err_i;
wire		s14_rty_i;
wire	[31:0]	s15_data_i;
wire	[31:0]	s15_data_o;
wire	[31:0]	s15_addr_o;
wire	[3:0]	s15_sel_o;
wire		s15_we_o;
wire		s15_cyc_o;
wire		s15_stb_o;
wire		s15_ack_i;
wire		s15_err_i;
wire		s15_rty_i;


// Test Bench Variables
reg	[31:0]	wd_cnt;
integer		error_cnt;
integer		verbose;

// Misc Variables

/////////////////////////////////////////////////////////////////////
//
// Defines 
//


/////////////////////////////////////////////////////////////////////
//
// Simulation Initialization and Start up Section
//


initial
   begin
	$timeformat (-9, 1, " ns", 10);

	$display("\n\n");
	$display("*****************************************************");
	$display("* WISHBONE Connection Matrix Simulation started ... *");
	$display("*****************************************************");
	$display("\n");

`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	wd_cnt = 0;
	error_cnt = 0;
   	clk = 1;
   	rst = 1;
	verbose = 1;

   	repeat(5)	@(posedge clk);
	s0.delay = 1;
	s1.delay = 1;
	s2.delay = 1;
	s3.delay = 1;
	s4.delay = 1;
	s5.delay = 1;
	s6.delay = 1;
	s7.delay = 1;
	s8.delay = 1;
	s9.delay = 1;
	s10.delay = 1;
	s11.delay = 1;
	s12.delay = 1;
	s13.delay = 1;
	s14.delay = 1;
	s15.delay = 1;
	#1;
   	rst = 0;
   	repeat(5)	@(posedge clk);

	// HERE IS WHERE THE TEST CASES GO ...

if(1)	// Full Regression Run
   begin
	$display(" ......................................................");
	$display(" :                                                    :");
	$display(" :    Regression Run ...                              :");
	$display(" :....................................................:");
	verbose = 0;

	test_dp1;
	test_rf;
	test_arb1;
	test_arb2;
	test_dp2;

   end
else
if(1)	// Debug Tests
   begin
	$display(" ......................................................");
	$display(" :                                                    :");
	$display(" :    Test Debug Testing ...                          :");
	$display(" :....................................................:");

	test_dp2;

   end

repeat(100)	@(posedge clk);
$finish;
end	// End of Initial

/////////////////////////////////////////////////////////////////////
//
// Clock Generation
//

always #5	clk = ~clk;

/////////////////////////////////////////////////////////////////////
//
// Watchdog Counter
//

always @(posedge clk)
	if(m0_ack_o | m1_ack_o | m2_ack_o | m3_ack_o |
		m4_ack_o | m5_ack_o | m6_ack_o | m7_ack_o)
		wd_cnt = 0;
	else
		wd_cnt = wd_cnt +1;

always @(wd_cnt)
	if(wd_cnt > 5000)
	   begin
		$display("\n*******************************************");
		$display("*** ERROR: Watchdog Counter Expired ... ***");
		$display("*******************************************\n");
		$finish;
	   end

/////////////////////////////////////////////////////////////////////
//
// IO Monitors
//

/////////////////////////////////////////////////////////////////////
//
// WISHBONE Inter Connect
//

wb_conmax_top	#(32,
		32,
		4'hf,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2,
		2'd2
		) conmax(
		.clk_i(		clk		),
		.rst_i(		rst		),
		.m0_data_i(	m0_data_i	),
		.m0_data_o(	m0_data_o	),
		.m0_addr_i(	m0_addr_i	),
		.m0_sel_i(	m0_sel_i	),
		.m0_we_i(	m0_we_i		),
		.m0_cyc_i(	m0_cyc_i	),
		.m0_stb_i(	m0_stb_i	),
		.m0_ack_o(	m0_ack_o	),
		.m0_err_o(	m0_err_o	),
		.m0_rty_o(	m0_rty_o	),
		.m1_data_i(	m1_data_i	),
		.m1_data_o(	m1_data_o	),
		.m1_addr_i(	m1_addr_i	),
		.m1_sel_i(	m1_sel_i	),
		.m1_we_i(	m1_we_i		),
		.m1_cyc_i(	m1_cyc_i	),
		.m1_stb_i(	m1_stb_i	),
		.m1_ack_o(	m1_ack_o	),
		.m1_err_o(	m1_err_o	),
		.m1_rty_o(	m1_rty_o	),
		.m2_data_i(	m2_data_i	),
		.m2_data_o(	m2_data_o	),
		.m2_addr_i(	m2_addr_i	),
		.m2_sel_i(	m2_sel_i	),
		.m2_we_i(	m2_we_i		),
		.m2_cyc_i(	m2_cyc_i	),
		.m2_stb_i(	m2_stb_i	),
		.m2_ack_o(	m2_ack_o	),
		.m2_err_o(	m2_err_o	),
		.m2_rty_o(	m2_rty_o	),
		.m3_data_i(	m3_data_i	),
		.m3_data_o(	m3_data_o	),
		.m3_addr_i(	m3_addr_i	),
		.m3_sel_i(	m3_sel_i	),
		.m3_we_i(	m3_we_i		),
		.m3_cyc_i(	m3_cyc_i	),
		.m3_stb_i(	m3_stb_i	),
		.m3_ack_o(	m3_ack_o	),
		.m3_err_o(	m3_err_o	),
		.m3_rty_o(	m3_rty_o	),
		.m4_data_i(	m4_data_i	),
		.m4_data_o(	m4_data_o	),
		.m4_addr_i(	m4_addr_i	),
		.m4_sel_i(	m4_sel_i	),
		.m4_we_i(	m4_we_i		),
		.m4_cyc_i(	m4_cyc_i	),
		.m4_stb_i(	m4_stb_i	),
		.m4_ack_o(	m4_ack_o	),
		.m4_err_o(	m4_err_o	),
		.m4_rty_o(	m4_rty_o	),
		.m5_data_i(	m5_data_i	),
		.m5_data_o(	m5_data_o	),
		.m5_addr_i(	m5_addr_i	),
		.m5_sel_i(	m5_sel_i	),
		.m5_we_i(	m5_we_i		),
		.m5_cyc_i(	m5_cyc_i	),
		.m5_stb_i(	m5_stb_i	),
		.m5_ack_o(	m5_ack_o	),
		.m5_err_o(	m5_err_o	),
		.m5_rty_o(	m5_rty_o	),
		.m6_data_i(	m6_data_i	),
		.m6_data_o(	m6_data_o	),
		.m6_addr_i(	m6_addr_i	),
		.m6_sel_i(	m6_sel_i	),
		.m6_we_i(	m6_we_i		),
		.m6_cyc_i(	m6_cyc_i	),
		.m6_stb_i(	m6_stb_i	),
		.m6_ack_o(	m6_ack_o	),
		.m6_err_o(	m6_err_o	),
		.m6_rty_o(	m6_rty_o	),
		.m7_data_i(	m7_data_i	),
		.m7_data_o(	m7_data_o	),
		.m7_addr_i(	m7_addr_i	),
		.m7_sel_i(	m7_sel_i	),
		.m7_we_i(	m7_we_i		),
		.m7_cyc_i(	m7_cyc_i	),
		.m7_stb_i(	m7_stb_i	),
		.m7_ack_o(	m7_ack_o	),
		.m7_err_o(	m7_err_o	),
		.m7_rty_o(	m7_rty_o	),
		.s0_data_i(	s0_data_i	),
		.s0_data_o(	s0_data_o	),
		.s0_addr_o(	s0_addr_o	),
		.s0_sel_o(	s0_sel_o	),
		.s0_we_o(	s0_we_o		),
		.s0_cyc_o(	s0_cyc_o	),
		.s0_stb_o(	s0_stb_o	),
		.s0_ack_i(	s0_ack_i	),
		.s0_err_i(	s0_err_i	),
		.s0_rty_i(	s0_rty_i	),
		.s1_data_i(	s1_data_i	),
		.s1_data_o(	s1_data_o	),
		.s1_addr_o(	s1_addr_o	),
		.s1_sel_o(	s1_sel_o	),
		.s1_we_o(	s1_we_o		),
		.s1_cyc_o(	s1_cyc_o	),
		.s1_stb_o(	s1_stb_o	),
		.s1_ack_i(	s1_ack_i	),
		.s1_err_i(	s1_err_i	),
		.s1_rty_i(	s1_rty_i	),
		.s2_data_i(	s2_data_i	),
		.s2_data_o(	s2_data_o	),
		.s2_addr_o(	s2_addr_o	),
		.s2_sel_o(	s2_sel_o	),
		.s2_we_o(	s2_we_o		),
		.s2_cyc_o(	s2_cyc_o	),
		.s2_stb_o(	s2_stb_o	),
		.s2_ack_i(	s2_ack_i	),
		.s2_err_i(	s2_err_i	),
		.s2_rty_i(	s2_rty_i	),
		.s3_data_i(	s3_data_i	),
		.s3_data_o(	s3_data_o	),
		.s3_addr_o(	s3_addr_o	),
		.s3_sel_o(	s3_sel_o	),
		.s3_we_o(	s3_we_o		),
		.s3_cyc_o(	s3_cyc_o	),
		.s3_stb_o(	s3_stb_o	),
		.s3_ack_i(	s3_ack_i	),
		.s3_err_i(	s3_err_i	),
		.s3_rty_i(	s3_rty_i	),
		.s4_data_i(	s4_data_i	),
		.s4_data_o(	s4_data_o	),
		.s4_addr_o(	s4_addr_o	),
		.s4_sel_o(	s4_sel_o	),
		.s4_we_o(	s4_we_o		),
		.s4_cyc_o(	s4_cyc_o	),
		.s4_stb_o(	s4_stb_o	),
		.s4_ack_i(	s4_ack_i	),
		.s4_err_i(	s4_err_i	),
		.s4_rty_i(	s4_rty_i	),
		.s5_data_i(	s5_data_i	),
		.s5_data_o(	s5_data_o	),
		.s5_addr_o(	s5_addr_o	),
		.s5_sel_o(	s5_sel_o	),
		.s5_we_o(	s5_we_o		),
		.s5_cyc_o(	s5_cyc_o	),
		.s5_stb_o(	s5_stb_o	),
		.s5_ack_i(	s5_ack_i	),
		.s5_err_i(	s5_err_i	),
		.s5_rty_i(	s5_rty_i	),
		.s6_data_i(	s6_data_i	),
		.s6_data_o(	s6_data_o	),
		.s6_addr_o(	s6_addr_o	),
		.s6_sel_o(	s6_sel_o	),
		.s6_we_o(	s6_we_o		),
		.s6_cyc_o(	s6_cyc_o	),
		.s6_stb_o(	s6_stb_o	),
		.s6_ack_i(	s6_ack_i	),
		.s6_err_i(	s6_err_i	),
		.s6_rty_i(	s6_rty_i	),
		.s7_data_i(	s7_data_i	),
		.s7_data_o(	s7_data_o	),
		.s7_addr_o(	s7_addr_o	),
		.s7_sel_o(	s7_sel_o	),
		.s7_we_o(	s7_we_o		),
		.s7_cyc_o(	s7_cyc_o	),
		.s7_stb_o(	s7_stb_o	),
		.s7_ack_i(	s7_ack_i	),
		.s7_err_i(	s7_err_i	),
		.s7_rty_i(	s7_rty_i	),
		.s8_data_i(	s8_data_i	),
		.s8_data_o(	s8_data_o	),
		.s8_addr_o(	s8_addr_o	),
		.s8_sel_o(	s8_sel_o	),
		.s8_we_o(	s8_we_o		),
		.s8_cyc_o(	s8_cyc_o	),
		.s8_stb_o(	s8_stb_o	),
		.s8_ack_i(	s8_ack_i	),
		.s8_err_i(	s8_err_i	),
		.s8_rty_i(	s8_rty_i	),
		.s9_data_i(	s9_data_i	),
		.s9_data_o(	s9_data_o	),
		.s9_addr_o(	s9_addr_o	),
		.s9_sel_o(	s9_sel_o	),
		.s9_we_o(	s9_we_o		),
		.s9_cyc_o(	s9_cyc_o	),
		.s9_stb_o(	s9_stb_o	),
		.s9_ack_i(	s9_ack_i	),
		.s9_err_i(	s9_err_i	),
		.s9_rty_i(	s9_rty_i	),
		.s10_data_i(	s10_data_i	),
		.s10_data_o(	s10_data_o	),
		.s10_addr_o(	s10_addr_o	),
		.s10_sel_o(	s10_sel_o	),
		.s10_we_o(	s10_we_o	),
		.s10_cyc_o(	s10_cyc_o	),
		.s10_stb_o(	s10_stb_o	),
		.s10_ack_i(	s10_ack_i	),
		.s10_err_i(	s10_err_i	),
		.s10_rty_i(	s10_rty_i	),
		.s11_data_i(	s11_data_i	),
		.s11_data_o(	s11_data_o	),
		.s11_addr_o(	s11_addr_o	),
		.s11_sel_o(	s11_sel_o	),
		.s11_we_o(	s11_we_o	),
		.s11_cyc_o(	s11_cyc_o	),
		.s11_stb_o(	s11_stb_o	),
		.s11_ack_i(	s11_ack_i	),
		.s11_err_i(	s11_err_i	),
		.s11_rty_i(	s11_rty_i	),
		.s12_data_i(	s12_data_i	),
		.s12_data_o(	s12_data_o	),
		.s12_addr_o(	s12_addr_o	),
		.s12_sel_o(	s12_sel_o	),
		.s12_we_o(	s12_we_o	),
		.s12_cyc_o(	s12_cyc_o	),
		.s12_stb_o(	s12_stb_o	),
		.s12_ack_i(	s12_ack_i	),
		.s12_err_i(	s12_err_i	),
		.s12_rty_i(	s12_rty_i	),
		.s13_data_i(	s13_data_i	),
		.s13_data_o(	s13_data_o	),
		.s13_addr_o(	s13_addr_o	),
		.s13_sel_o(	s13_sel_o	),
		.s13_we_o(	s13_we_o	),
		.s13_cyc_o(	s13_cyc_o	),
		.s13_stb_o(	s13_stb_o	),
		.s13_ack_i(	s13_ack_i	),
		.s13_err_i(	s13_err_i	),
		.s13_rty_i(	s13_rty_i	),
		.s14_data_i(	s14_data_i	),
		.s14_data_o(	s14_data_o	),
		.s14_addr_o(	s14_addr_o	),
		.s14_sel_o(	s14_sel_o	),
		.s14_we_o(	s14_we_o	),
		.s14_cyc_o(	s14_cyc_o	),
		.s14_stb_o(	s14_stb_o	),
		.s14_ack_i(	s14_ack_i	),
		.s14_err_i(	s14_err_i	),
		.s14_rty_i(	s14_rty_i	),
		.s15_data_i(	s15_data_i	),
		.s15_data_o(	s15_data_o	),
		.s15_addr_o(	s15_addr_o	),
		.s15_sel_o(	s15_sel_o	),
		.s15_we_o(	s15_we_o	),
		.s15_cyc_o(	s15_cyc_o	),
		.s15_stb_o(	s15_stb_o	),
		.s15_ack_i(	s15_ack_i	),
		.s15_err_i(	s15_err_i	),
		.s15_rty_i(	s15_rty_i	)
		);


/////////////////////////////////////////////////////////////////////
//
// WISHBONE Master Models
//

wb_mast	m0(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m0_addr_i	),
		.din(		m0_data_o	),
		.dout(		m0_data_i	),
		.cyc(		m0_cyc_i	),
		.stb(		m0_stb_i	),
		.sel(		m0_sel_i	),
		.we(		m0_we_i		),
		.ack(		m0_ack_o	),
		.err(		m0_err_o	),
		.rty(		m0_rty_o	)
		);

wb_mast	m1(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m1_addr_i	),
		.din(		m1_data_o	),
		.dout(		m1_data_i	),
		.cyc(		m1_cyc_i	),
		.stb(		m1_stb_i	),
		.sel(		m1_sel_i	),
		.we(		m1_we_i		),
		.ack(		m1_ack_o	),
		.err(		m1_err_o	),
		.rty(		m1_rty_o	)
		);

wb_mast	m2(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m2_addr_i	),
		.din(		m2_data_o	),
		.dout(		m2_data_i	),
		.cyc(		m2_cyc_i	),
		.stb(		m2_stb_i	),
		.sel(		m2_sel_i	),
		.we(		m2_we_i		),
		.ack(		m2_ack_o	),
		.err(		m2_err_o	),
		.rty(		m2_rty_o	)
		);

wb_mast	m3(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m3_addr_i	),
		.din(		m3_data_o	),
		.dout(		m3_data_i	),
		.cyc(		m3_cyc_i	),
		.stb(		m3_stb_i	),
		.sel(		m3_sel_i	),
		.we(		m3_we_i		),
		.ack(		m3_ack_o	),
		.err(		m3_err_o	),
		.rty(		m3_rty_o	)
		);

wb_mast	m4(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m4_addr_i	),
		.din(		m4_data_o	),
		.dout(		m4_data_i	),
		.cyc(		m4_cyc_i	),
		.stb(		m4_stb_i	),
		.sel(		m4_sel_i	),
		.we(		m4_we_i		),
		.ack(		m4_ack_o	),
		.err(		m4_err_o	),
		.rty(		m4_rty_o	)
		);

wb_mast	m5(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m5_addr_i	),
		.din(		m5_data_o	),
		.dout(		m5_data_i	),
		.cyc(		m5_cyc_i	),
		.stb(		m5_stb_i	),
		.sel(		m5_sel_i	),
		.we(		m5_we_i		),
		.ack(		m5_ack_o	),
		.err(		m5_err_o	),
		.rty(		m5_rty_o	)
		);

wb_mast	m6(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m6_addr_i	),
		.din(		m6_data_o	),
		.dout(		m6_data_i	),
		.cyc(		m6_cyc_i	),
		.stb(		m6_stb_i	),
		.sel(		m6_sel_i	),
		.we(		m6_we_i		),
		.ack(		m6_ack_o	),
		.err(		m6_err_o	),
		.rty(		m6_rty_o	)
		);

wb_mast	m7(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		m7_addr_i	),
		.din(		m7_data_o	),
		.dout(		m7_data_i	),
		.cyc(		m7_cyc_i	),
		.stb(		m7_stb_i	),
		.sel(		m7_sel_i	),
		.we(		m7_we_i		),
		.ack(		m7_ack_o	),
		.err(		m7_err_o	),
		.rty(		m7_rty_o	)
		);


/////////////////////////////////////////////////////////////////////
//
// WISHBONE Slave Models
//

wb_slv  s0(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s0_addr_o	),
		.din(		s0_data_o	),
		.dout(		s0_data_i	),
		.cyc(		s0_cyc_o	),
		.stb(		s0_stb_o	),
		.sel(		s0_sel_o	),
		.we(		s0_we_o		),
		.ack(		s0_ack_i	),
		.err(		s0_err_i	),
		.rty(		s0_rty_i	)
		);

wb_slv  s1(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s1_addr_o	),
		.din(		s1_data_o	),
		.dout(		s1_data_i	),
		.cyc(		s1_cyc_o	),
		.stb(		s1_stb_o	),
		.sel(		s1_sel_o	),
		.we(		s1_we_o		),
		.ack(		s1_ack_i	),
		.err(		s1_err_i	),
		.rty(		s1_rty_i	)
		);

wb_slv  s2(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s2_addr_o	),
		.din(		s2_data_o	),
		.dout(		s2_data_i	),
		.cyc(		s2_cyc_o	),
		.stb(		s2_stb_o	),
		.sel(		s2_sel_o	),
		.we(		s2_we_o		),
		.ack(		s2_ack_i	),
		.err(		s2_err_i	),
		.rty(		s2_rty_i	)
		);

wb_slv  s3(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s3_addr_o	),
		.din(		s3_data_o	),
		.dout(		s3_data_i	),
		.cyc(		s3_cyc_o	),
		.stb(		s3_stb_o	),
		.sel(		s3_sel_o	),
		.we(		s3_we_o		),
		.ack(		s3_ack_i	),
		.err(		s3_err_i	),
		.rty(		s3_rty_i	)
		);

wb_slv  s4(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s4_addr_o	),
		.din(		s4_data_o	),
		.dout(		s4_data_i	),
		.cyc(		s4_cyc_o	),
		.stb(		s4_stb_o	),
		.sel(		s4_sel_o	),
		.we(		s4_we_o		),
		.ack(		s4_ack_i	),
		.err(		s4_err_i	),
		.rty(		s4_rty_i	)
		);

wb_slv  s5(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s5_addr_o	),
		.din(		s5_data_o	),
		.dout(		s5_data_i	),
		.cyc(		s5_cyc_o	),
		.stb(		s5_stb_o	),
		.sel(		s5_sel_o	),
		.we(		s5_we_o		),
		.ack(		s5_ack_i	),
		.err(		s5_err_i	),
		.rty(		s5_rty_i	)
		);

wb_slv  s6(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s6_addr_o	),
		.din(		s6_data_o	),
		.dout(		s6_data_i	),
		.cyc(		s6_cyc_o	),
		.stb(		s6_stb_o	),
		.sel(		s6_sel_o	),
		.we(		s6_we_o		),
		.ack(		s6_ack_i	),
		.err(		s6_err_i	),
		.rty(		s6_rty_i	)
		);

wb_slv  s7(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s7_addr_o	),
		.din(		s7_data_o	),
		.dout(		s7_data_i	),
		.cyc(		s7_cyc_o	),
		.stb(		s7_stb_o	),
		.sel(		s7_sel_o	),
		.we(		s7_we_o		),
		.ack(		s7_ack_i	),
		.err(		s7_err_i	),
		.rty(		s7_rty_i	)
		);

wb_slv  s8(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s8_addr_o	),
		.din(		s8_data_o	),
		.dout(		s8_data_i	),
		.cyc(		s8_cyc_o	),
		.stb(		s8_stb_o	),
		.sel(		s8_sel_o	),
		.we(		s8_we_o		),
		.ack(		s8_ack_i	),
		.err(		s8_err_i	),
		.rty(		s8_rty_i	)
		);

wb_slv  s9(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s9_addr_o	),
		.din(		s9_data_o	),
		.dout(		s9_data_i	),
		.cyc(		s9_cyc_o	),
		.stb(		s9_stb_o	),
		.sel(		s9_sel_o	),
		.we(		s9_we_o		),
		.ack(		s9_ack_i	),
		.err(		s9_err_i	),
		.rty(		s9_rty_i	)
		);

wb_slv  s10(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s10_addr_o	),
		.din(		s10_data_o	),
		.dout(		s10_data_i	),
		.cyc(		s10_cyc_o	),
		.stb(		s10_stb_o	),
		.sel(		s10_sel_o	),
		.we(		s10_we_o	),
		.ack(		s10_ack_i	),
		.err(		s10_err_i	),
		.rty(		s10_rty_i	)
		);

wb_slv  s11(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s11_addr_o	),
		.din(		s11_data_o	),
		.dout(		s11_data_i	),
		.cyc(		s11_cyc_o	),
		.stb(		s11_stb_o	),
		.sel(		s11_sel_o	),
		.we(		s11_we_o	),
		.ack(		s11_ack_i	),
		.err(		s11_err_i	),
		.rty(		s11_rty_i	)
		);

wb_slv  s12(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s12_addr_o	),
		.din(		s12_data_o	),
		.dout(		s12_data_i	),
		.cyc(		s12_cyc_o	),
		.stb(		s12_stb_o	),
		.sel(		s12_sel_o	),
		.we(		s12_we_o	),
		.ack(		s12_ack_i	),
		.err(		s12_err_i	),
		.rty(		s12_rty_i	)
		);

wb_slv  s13(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s13_addr_o	),
		.din(		s13_data_o	),
		.dout(		s13_data_i	),
		.cyc(		s13_cyc_o	),
		.stb(		s13_stb_o	),
		.sel(		s13_sel_o	),
		.we(		s13_we_o	),
		.ack(		s13_ack_i	),
		.err(		s13_err_i	),
		.rty(		s13_rty_i	)
		);

wb_slv  s14(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s14_addr_o	),
		.din(		s14_data_o	),
		.dout(		s14_data_i	),
		.cyc(		s14_cyc_o	),
		.stb(		s14_stb_o	),
		.sel(		s14_sel_o	),
		.we(		s14_we_o	),
		.ack(		s14_ack_i	),
		.err(		s14_err_i	),
		.rty(		s14_rty_i	)
		);

wb_slv  s15(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		s15_addr_o	),
		.din(		s15_data_o	),
		.dout(		s15_data_i	),
		.cyc(		s15_cyc_o	),
		.stb(		s15_stb_o	),
		.sel(		s15_sel_o	),
		.we(		s15_we_o	),
		.ack(		s15_ack_i	),
		.err(		s15_err_i	),
		.rty(		s15_rty_i	)
		);

`include "tests.v"

endmodule

