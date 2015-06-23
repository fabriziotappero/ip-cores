/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/wb_dma/    ////
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
//  $Id: test_bench_top.v,v 1.5 2002-02-01 01:55:44 rudi Exp $
//
//  $Date: 2002-02-01 01:55:44 $
//  $Revision: 1.5 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.4  2001/10/19 04:47:31  rudi
//
//               - Made the core parameterized
//
//               Revision 1.3  2001/09/07 15:34:36  rudi
//
//               Changed reset to active high.
//
//               Revision 1.2  2001/08/15 05:40:29  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Added Section 3.10, describing DMA restart.
//
//               Revision 1.1  2001/07/29 08:57:02  rudi
//
//
//               1) Changed Directory Structure
//               2) Added restart signal (REST)
//
//               Revision 1.1.1.1  2001/03/19 13:11:22  rudi
//               Initial Release
//
//
//                        

`include "wb_dma_defines.v"

`define	CH_COUNT 4

module test;

reg		clk;
reg		rst;

// IO Prototypes

wire	[31:0]	wb0s_data_i;
wire	[31:0]	wb0s_data_o;
wire	[31:0]	wb0_addr_i;
wire	[3:0]	wb0_sel_i;
wire		wb0_we_i;
wire		wb0_cyc_i;
wire		wb0_stb_i;
wire		wb0_ack_o;
wire		wb0_err_o;
wire		wb0_rty_o;
wire	[31:0]	wb0m_data_i;
wire	[31:0]	wb0m_data_o;
wire	[31:0]	wb0_addr_o;
wire	[3:0]	wb0_sel_o;
wire		wb0_we_o;
wire		wb0_cyc_o;
wire		wb0_stb_o;
wire		wb0_ack_i;
wire		wb0_err_i;
wire		wb0_rty_i;
wire	[31:0]	wb1s_data_i;
wire	[31:0]	wb1s_data_o;
wire	[31:0]	wb1_addr_i;
wire	[3:0]	wb1_sel_i;
wire		wb1_we_i;
wire		wb1_cyc_i;
wire		wb1_stb_i;
wire		wb1_ack_o;
wire		wb1_err_o;
wire		wb1_rty_o;
wire	[31:0]	wb1m_data_i;
wire	[31:0]	wb1m_data_o;
wire	[31:0]	wb1_addr_o;
wire	[3:0]	wb1_sel_o;
wire		wb1_we_o;
wire		wb1_cyc_o;
wire		wb1_stb_o;
wire		wb1_ack_i;
wire		wb1_err_i;
wire		wb1_rty_i;
reg	[`CH_COUNT-1:0]	req_i;
wire	[`CH_COUNT-1:0]	ack_o;
reg	[`CH_COUNT-1:0]	nd_i;
reg	[`CH_COUNT-1:0]	rest_i;
wire		inta_o;
wire		intb_o;

wire	[31:0]	wb0_data_o_mast;
wire	[31:0]	wb1_data_o_mast;
wire	[31:0]	wb0_data_o_slv;
wire	[31:0]	wb1_data_o_slv;

// Test Bench Variables
reg	[31:0]	wd_cnt;
integer		error_cnt;
reg		ack_cnt_clr;
reg	[31:0]	ack_cnt;

// Misc Variables

/////////////////////////////////////////////////////////////////////
//
// Defines 
//


`define	MEM		32'h0002_0000
`define	REG_BASE	32'hb000_0000

`define	COR		8'h0
`define	INT_MASKA	8'h4
`define	INT_MASKB	8'h8
`define	INT_SRCA	8'hc
`define	INT_SRCB	8'h10

`define	CH0_CSR		8'h20
`define	CH0_TXSZ	8'h24
`define	CH0_ADR0	8'h28
`define CH0_AM0		8'h2c
`define	CH0_ADR1	8'h30
`define CH0_AM1		8'h34
`define	PTR0		8'h38

`define	CH1_CSR		8'h40
`define	CH1_TXSZ	8'h44
`define	CH1_ADR0	8'h48
`define CH1_AM0		8'h4c
`define	CH1_ADR1	8'h50
`define CH1_AM1		8'h54
`define	PTR1		8'h58

`define	CH2_CSR		8'h60
`define	CH2_TXSZ	8'h64
`define	CH2_ADR0	8'h68
`define CH2_AM0		8'h6c
`define	CH2_ADR1	8'h70
`define CH2_AM1		8'h74
`define	PTR2		8'h78

`define	CH3_CSR		8'h80
`define	CH3_TXSZ	8'h84
`define	CH3_ADR0	8'h88
`define CH3_AM0		8'h8c
`define	CH3_ADR1	8'h90
`define CH3_AM1		8'h94
`define	PTR3		8'h98

/////////////////////////////////////////////////////////////////////
//
// Simulation Initialization and Start up Section
//

initial
   begin
	$display("\n\n");
	$display("**********************************************");
	$display("* WISHBONE DMA/BRIDGE Simulation started ... *");
	$display("**********************************************");
	$display("\n");
`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	req_i = 0;
	nd_i = 0;
	wd_cnt = 0;
	ack_cnt = 0;
	ack_cnt_clr = 0;
	error_cnt = 0;
   	clk = 0;
   	rst = 1;
	rest_i = 0;

   	repeat(10)	@(posedge clk);
   	rst = 0;
   	repeat(10)	@(posedge clk);

	// HERE IS WHERE THE TEST CASES GO ...

if(1)	// Full Regression Run
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Long Regression Run ...                         :");
$display(" :....................................................:");
	pt10_rd;
	pt01_wr;
	pt01_rd;
	pt10_wr;
	sw_dma1(0);
	sw_dma2(0);
	hw_dma1(0);
	hw_dma2(0);
	arb_test1;
	sw_ext_desc1(0);
	hw_dma3(0);
	hw_dma4(0);
   end
else
if(1)	// Quick Regression Run
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Short Regression Run ...                        :");
$display(" :....................................................:");
	pt10_rd;
	pt01_wr;
	pt01_rd;
	pt10_wr;
	sw_dma1(2);
	sw_dma2(2);
	hw_dma1(1);
	hw_dma2(2);
	hw_dma3(2);
	hw_dma4(2);
	arb_test1;
	sw_ext_desc1(1);
   end
else
   begin

	//
	// TEST DEVELOPMENT AREA
	//
	sw_dma1(3);

	//arb_test1;

   	repeat(100)	@(posedge clk);

   end

   	repeat(100)	@(posedge clk);
   	$finish;
   end

/////////////////////////////////////////////////////////////////////
//
// ack counter
//

always @(posedge clk)
	if(ack_cnt_clr)			ack_cnt <= #1 0;
	else
	if(wb0_ack_i | wb1_ack_i)	ack_cnt <= #1 ack_cnt + 1;

/////////////////////////////////////////////////////////////////////
//
// Watchdog Counter
//


always @(posedge clk)
	if(wb0_cyc_i | wb1_cyc_i | wb0_ack_i | wb1_ack_i)	wd_cnt <= #1 0;
	else							wd_cnt <= #1 wd_cnt + 1;

always @(wd_cnt)
	if(wd_cnt>5000)
	   begin
		$display("\n\n*************************************\n");
		$display("ERROR: Watch Dog Counter Expired\n");
		$display("*************************************\n\n\n");
		$finish;
	   end

always #5 clk = ~clk;

/////////////////////////////////////////////////////////////////////
//
// WISHBONE DMA IP Core
//


// Module Prototype

wb_dma_top
	#(	4'hb,		// register file address
		2'd1,		// Number of priorities (4)
		`CH_COUNT,	// Number of channels
		4'hf,
		4'hf,
		4'hf,
		4'hf,
		4'hf,
		4'hf,
		4'hf,
		4'hf
		)
		u0(
		.clk_i(		clk		),
		.rst_i(		rst		),
		.wb0s_data_i(	wb0s_data_i	),
		.wb0s_data_o(	wb0s_data_o	),
		.wb0_addr_i(	wb0_addr_i	),
		.wb0_sel_i(	wb0_sel_i	),
		.wb0_we_i(	wb0_we_i	),
		.wb0_cyc_i(	wb0_cyc_i	),
		.wb0_stb_i(	wb0_stb_i	),
		.wb0_ack_o(	wb0_ack_o	),
		.wb0_err_o(	wb0_err_o	),
		.wb0_rty_o(	wb0_rty_o	),
		.wb0m_data_i(	wb0m_data_i	),
		.wb0m_data_o(	wb0m_data_o	),
		.wb0_addr_o(	wb0_addr_o	),
		.wb0_sel_o(	wb0_sel_o	),
		.wb0_we_o(	wb0_we_o	),
		.wb0_cyc_o(	wb0_cyc_o	),
		.wb0_stb_o(	wb0_stb_o	),
		.wb0_ack_i(	wb0_ack_i	),
		.wb0_err_i(	wb0_err_i	),
		.wb0_rty_i(	wb0_rty_i	),
		.wb1s_data_i(	wb1s_data_i	),
		.wb1s_data_o(	wb1s_data_o	),
		.wb1_addr_i(	wb1_addr_i	),
		.wb1_sel_i(	wb1_sel_i	),
		.wb1_we_i(	wb1_we_i	),
		.wb1_cyc_i(	wb1_cyc_i	),
		.wb1_stb_i(	wb1_stb_i	),
		.wb1_ack_o(	wb1_ack_o	),
		.wb1_err_o(	wb1_err_o	),
		.wb1_rty_o(	wb1_rty_o	),
		.wb1m_data_i(	wb1m_data_i	),
		.wb1m_data_o(	wb1m_data_o	),
		.wb1_addr_o(	wb1_addr_o	),
		.wb1_sel_o(	wb1_sel_o	),
		.wb1_we_o(	wb1_we_o	),
		.wb1_cyc_o(	wb1_cyc_o	),
		.wb1_stb_o(	wb1_stb_o	),
		.wb1_ack_i(	wb1_ack_i	),
		.wb1_err_i(	wb1_err_i	),
		.wb1_rty_i(	wb1_rty_i	),
		.dma_req_i(	req_i		),
		.dma_ack_o(	ack_o		),
		.dma_nd_i(	nd_i		),
		.dma_rest_i(	rest_i		),
		.inta_o(	inta_o		),
		.intb_o(	intb_o		)
		);

wb_slv	#(14) s0(
		.clk(		clk		),
		.rst(		~rst		),
		.adr(		wb0_addr_o	),
		.din(		wb0s_data_o	),
		.dout(		wb0s_data_i	),
		.cyc(		wb0_cyc_o	),
		.stb(		wb0_stb_o	),
		.sel(		wb0_sel_o	),
		.we(		wb0_we_o	),
		.ack(		wb0_ack_i	),
		.err(		wb0_err_i	),
		.rty(		wb0_rty_i	)
		);

wb_slv	#(14) s1(
		.clk(		clk		),
		.rst(		~rst		),
		.adr(		wb1_addr_o	),
		.din(		wb1s_data_o	),
		.dout(		wb1s_data_i	),
		.cyc(		wb1_cyc_o	),
		.stb(		wb1_stb_o	),
		.sel(		wb1_sel_o	),
		.we(		wb1_we_o	),
		.ack(		wb1_ack_i	),
		.err(		wb1_err_i	),
		.rty(		wb1_rty_i	)
		);

wb_mast	m0(
		.clk(		clk		),
		.rst(		~rst		),
		.adr(		wb0_addr_i	),
		.din(		wb0m_data_o	),
		.dout(		wb0m_data_i	),
		.cyc(		wb0_cyc_i	),
		.stb(		wb0_stb_i	),
		.sel(		wb0_sel_i	),
		.we(		wb0_we_i	),
		.ack(		wb0_ack_o	),
		.err(		wb0_err_o	),
		.rty(		wb0_rty_o	)
		);

wb_mast	m1(
		.clk(		clk		),
		.rst(		~rst		),
		.adr(		wb1_addr_i	),
		.din(		wb1m_data_o	),
		.dout(		wb1m_data_i	),
		.cyc(		wb1_cyc_i	),
		.stb(		wb1_stb_i	),
		.sel(		wb1_sel_i	),
		.we(		wb1_we_i	),
		.ack(		wb1_ack_o	),
		.err(		wb1_err_o	),
		.rty(		wb1_rty_o	)
		);

`include "tests.v"

endmodule

