/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/vga_lcd/   ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
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
//  $Id: test_bench_top.v,v 1.2 2002-02-16 10:41:16 rherveille Exp $
//
//  $Date: 2002-02-16 10:41:16 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2001/08/16 10:01:05  rudi
//
//               - Added Test Bench
//               - Added Synthesis scripts for Design Compiler
//               - Fixed minor bug in atahost_top
//
//
//
//
//                        

`timescale 1ns / 10ps

module test;

reg		clk;
reg		rst;

wire		int;
wire	[31:0]	wb_addr_i;
wire	[31:0]	wb_data_i;
wire	[31:0]	wb_data_o;
wire	[3:0]	wb_sel_i;
wire		wb_we_i;
wire		wb_stb_i;
wire		wb_cyc_i;
wire		wb_ack_o;
wire		wb_err_o;

wire		ata_rst_;
wire	[15:0]	ata_dout;
wire	[15:0]	ata_din;
wire	[15:0]	ata_data;
wire		ata_doe;
wire	[2:0]	ata_da;
wire		ata_cs0, ata_cs1;
wire		ata_dior, ata_diow;
wire		ata_iordy;
wire		ata_intrq;
reg		ata_intrq_r;


// Test Bench Variables
integer		wd_cnt;
integer		error_cnt;
integer		verbose;

// Misc Variables

/////////////////////////////////////////////////////////////////////
//
// Defines 
//

`define	CTRL		32'h0000_0000
`define	STAT		32'h0000_0004
`define	PCTR		32'h0000_0008
`define	ATA_DEV		32'h0000_0040

/////////////////////////////////////////////////////////////////////
//
// Simulation Initialization and Start up Section
//

initial
   begin
	$display("\n\n");
	$display("******************************************************");
	$display("* WISHBONE ATA 1 Controller Simulation started ...   *");
	$display("******************************************************");
	$display("\n");
`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	wd_cnt = 0;
	error_cnt = 0;
   	clk = 0;
   	rst = 0;
	verbose = 1;
	ata_intrq_r=0;

   	repeat(10)	@(posedge clk);
   	rst = 1;
   	repeat(10)	@(posedge clk);

	// HERE IS WHERE THE TEST CASES GO ...

if(1)	// Full Regression Run
   begin
	io_test1;
	io_test2;
	int_test;
	rst_test;

   end
else
   begin

	//
	// TEST DEVELOPMENT AREA
	//
$display("\n\n");
$display("*****************************************************");
$display("*** DEVELOPMENT Test                              ***");
$display("*****************************************************\n");




show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

   end
   	repeat(100)	@(posedge clk);
   	$finish;
   end

/////////////////////////////////////////////////////////////////////
//
// System Clock (100Mhz)
//

always #5	clk = ~clk;

/////////////////////////////////////////////////////////////////////
//
// Watchdog Counter
// Terminate simulation if nothing happens ...
//

always @(wb_cyc_i or wb_ack_o)
	wd_cnt <= #5 0;

always @(posedge clk)
	wd_cnt <= #1 wd_cnt + 1;

always @(wd_cnt)
	if(wd_cnt>5000)
	   begin
		$display("\n\n*************************************\n");
		$display("ERROR: Watch Dog Counter Expired\n");
		$display("*************************************\n\n\n");
		$finish;
	   end

/////////////////////////////////////////////////////////////////////
//
// DUT & Models
//

// Create an external Tri-State Bus to the ATA Device
assign ata_din  = ata_data;
assign ata_data = ata_doe ? ata_dout : 16'hzzzz;

// DUT: ATA Host
atahost_top u0(	//-- WISHBONE SYSCON signals
		.wb_clk_i(		clk		),
		.arst_i(		rst		),
		.wb_rst_i(		~rst		),

		//-- WISHBONE SLAVE signals
		.wb_cyc_i(		wb_cyc_i	),
		.wb_stb_i(		wb_stb_i	),
		.wb_ack_o(		wb_ack_o	),
		.wb_err_o(		wb_err_o	),
		.wb_adr_i(		wb_addr_i[6:2]	),
		.wb_dat_i(		wb_data_i	),
		.wb_dat_o(		wb_data_o	),
		.wb_sel_i(		wb_sel_i	),
		.wb_we_i(		wb_we_i		),
		.wb_inta_o(		int		),

		//-- ATA signals
		.resetn_pad_o(	ata_rst_	),
		.dd_pad_i(		ata_din		),
		.dd_pad_o(		ata_dout	),
		.dd_padoe_o(		ata_doe		),
		.da_pad_o(		ata_da		),
		.cs0n_pad_o(	ata_cs0		),
		.cs1n_pad_o(	ata_cs1		),
		.diorn_pad_o(	ata_dior_	),
		.diown_pad_o(	ata_diow_	),
		.iordy_pad_i(	ata_iordy	),
		.intrq_pad_i(	ata_intrq_r	)
		);

// ATA Device Model
ata_device a0(	.ata_rst_(	ata_rst_	),
		.ata_data(	ata_data	),
		.ata_da(	ata_da		),
		.ata_cs0(	ata_cs0		),
		.ata_cs1(	ata_cs1		),
		.ata_dior_(	ata_dior_	),
		.ata_diow_(	ata_diow_	),
		.ata_iordy(	ata_iordy	),
		.ata_intrq(	ata_intrq	) );

// WISHBONE Master Model
wb_mast	m0(	.clk(		clk		),
		.rst(		rst		),
		.adr(		wb_addr_i	),
		.din(		wb_data_o	),
		.dout(		wb_data_i	),
		.cyc(		wb_cyc_i	),
		.stb(		wb_stb_i	),
		.sel(		wb_sel_i	),
		.we(		wb_we_i		),
		.ack(		wb_ack_o	),
		.err(		wb_err_o	),
		.rty(		1'b0		) );

// External Tests
`include "tests.v"

endmodule


