/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
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
//  $Id: test_bench_top.v,v 1.7 2002-01-21 13:10:37 rudi Exp $
//
//  $Date: 2002-01-21 13:10:37 $
//  $Revision: 1.7 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.6  2001/11/29 02:17:36  rudi
//
//
//               - More Synthesis cleanup, mostly for speed
//               - Several bug fixes
//               - Changed code to avoid auto-precharge and
//                 burst-terminate combinations (apparently illegal ?)
//                 Now we will do a manual precharge ...
//
//               Revision 1.5  2001/11/13 00:45:15  rudi
//
//               Just minor test bench update, syncing all the files.
//
//               Revision 1.4  2001/11/11 01:52:02  rudi
//
//               Minor fixes to testbench ...
//
//               Revision 1.3  2001/09/02 02:29:43  rudi
//
//               Fixed the TMS register setup to be tight and correct.
//
//               Revision 1.2  2001/08/10 08:16:21  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Removed "Refresh Early" configuration
//
//               Revision 1.1  2001/07/29 07:34:40  rudi
//
//
//               1) Changed Directory Structure
//               2) Fixed several minor bugs
//
//               Revision 1.2  2001/06/03 11:34:18  rudi
//               *** empty log message ***
//
//               Revision 1.1.1.1  2001/05/13 09:36:32  rudi
//               Created Directory Structure
//
//
//
//                        

`include "mc_defines.v"

module test;

reg		clk;
reg		rst;

// IO Prototypes

wire	[31:0]	wb_data_i;
wire	[31:0]	wb_data_o;
wire	[31:0]	wb_addr_i;
wire	[3:0]	wb_sel_i;
wire		wb_we_i;
wire		wb_cyc_i;
wire		wb_stb_i;
wire		wb_ack_o;
wire		wb_err_o;
wire		wb_rty_o;

reg		susp_req, resume_req;
wire		suspended;
wire	[31:0]	poc;

reg		mc_clk;
reg		mc_br;
wire		mc_bg;
wire		mc_ack;
wire	[23:0]	mc_addr;
wire	[31:0]	mc_data_i;
wire	[31:0]	mc_data_o;
wire	[3:0]	mc_dp_i;
wire	[3:0]	mc_dp_o;
wire		mc_data_oe;
wire	[3:0]	mc_dqm;
wire		mc_oe_;
wire		mc_we_;
wire		mc_cas_;
wire		mc_ras_;
wire		mc_cke_;
wire	[7:0]	mc_cs_;
wire		mc_sts;
wire		mc_rp_;
wire		mc_vpen;
wire		mc_adsc_;
wire		mc_adv_;
wire		mc_zz;
wire		mc_c_oe;


// Test Bench Variables
reg	[31:0]	wd_cnt;
integer		error_cnt;
integer		verbose;
integer		poc_mode;
reg		wb_err_check_dis;
integer		LVL;

integer	cyc_cnt;
integer	ack_cnt;

// Misc Variables

integer		n,m;

reg	[31:0]	data;

reg	[31:0]	buffer32;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		read, write;
integer		done;
integer		adr;
integer		do_quick;

/////////////////////////////////////////////////////////////////////
//
// Defines 
//

`define	MEM_BASE	32'h0000_0000
`define	MEM_BASE1	32'h0400_0000
`define	MEM_BASE2	32'h0800_0000
`define	MEM_BASE3	32'h0c00_0000
`define	MEM_BASE4	32'h1000_0000
`define	MEM_BASE5	32'h1400_0000
`define	MEM_BASE6	32'h1800_0000
`define	REG_BASE	32'h6000_0000

`define	CSR		8'h00
`define	POC		8'h04
`define	BA_MASK		8'h08

`define	CSC0		8'h10
`define	TMS0		8'h14
`define	CSC1		8'h18
`define	TMS1		8'h1c
`define	CSC2		8'h20
`define	TMS2		8'h24
`define	CSC3		8'h28
`define	TMS3		8'h2c
`define	CSC4		8'h30
`define	TMS4		8'h34
`define	CSC5		8'h38
`define	TMS5		8'h3c
`define	CSC6		8'h40
`define	TMS6		8'h44
`define	CSC7		8'h48
`define	TMS7		8'h4c

/////////////////////////////////////////////////////////////////////
//
// Simulation Initialization and Start up Section
//

`define	SDRAM0		1
`define	SRAM		1
`define MULTI_SDRAM	1
`define	FLASH		1
`define MICRON		1

initial
   begin
	$display("\n\n");
	$display("*****************************************************");
	$display("* WISHBONE Memory Controller Simulation started ... *");
	$display("*****************************************************");
	$display("\n");
`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	do_quick = 0;
	poc_mode = 1;
	#1;
	poc_mode = 0;
	wb_err_check_dis=0;
	cyc_cnt = 0;
	ack_cnt = 0;
	wd_cnt = 0;
	error_cnt = 0;
   	clk = 1;
	mc_clk = 0;
   	rst = 1;
	susp_req = 0;
	resume_req = 0;
	verbose = 1;
	mc_br = 0;

   	repeat(11)	@(posedge clk);
	#1;
   	rst = 0;
   	repeat(10)	@(posedge clk);

	// HERE IS WHERE THE TEST CASES GO ...

	LVL = 2;
if(0)	// Full Regression Run
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Long Regression Run ...                         :");
$display(" :....................................................:");
	verbose = 0;
`ifdef FLASH
	boot(0);
`endif

	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0000_0000);
	sdram_wr1(0);
	sdram_rd1(0);
	sdram_rd2(0);
	sdram_wr2(0);
	sdram_rd3(0);
	sdram_wr3(0);
	sdram_rd4(0);
	sdram_wr4(0);
	sdram_wp(0);
	sdram_bo;
	sdram_rmw1(0);
	sdram_rmw2(0);
	rmw_cross1(0);

`ifdef MULTI_SDRAM
	sdram_rd5(0);
	sdram_wr5(0);
`endif

`ifdef FLASH
	asc_rdwr1(0);
`endif

`ifdef SRAM
	sram_rd1;
	sram_wr1;
	sram_wp;
	sram_rmw1;
	sram_rmw2;
`endif

	scs_rdwr1(0);
   end
else
if(1)	// Quick Regression Run
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Short Regression Run ...                        :");
$display(" :....................................................:");
	do_quick = 1;
	verbose = 0;
	LVL = 1;

`ifdef FLASH
	boot(LVL);
`endif
	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0000_0000);

	sdram_rd1(LVL);
	sdram_wr1(LVL);

	sdram_rd2(LVL);
	sdram_wr2(LVL);

	sdram_rd3(LVL);
	sdram_wr3(LVL);

	sdram_rd4(LVL);
	sdram_wr4(LVL);

	sdram_wp(LVL);
	sdram_bo;
	sdram_rmw1(LVL);
	sdram_rmw2(LVL);
	rmw_cross1(LVL);

`ifdef MULTI_SDRAM
	sdram_rd5(LVL);
	sdram_wr5(LVL);
`endif


`ifdef FLASH
	asc_rdwr1(LVL);
`endif

`ifdef SRAM
	sram_rd1;
	sram_wr1;
	sram_wp;
	sram_rmw1;
	sram_rmw2;
`endif
	scs_rdwr1(LVL);

	mc_reset;
   end
if(do_quick)	// Suspend resume testing
begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Suspend Resume Testing ...                      :");
$display(" :....................................................:");
	//verbose = 0;
	//LVL = 1;
	done = 0;
	fork
	   begin

`ifdef FLASH
		boot(LVL);
`endif
		m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0000_0000);

		while(susp_req | suspended)	@(posedge clk);
		sdram_rd1(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_wr1(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_rd2(LVL);

		while(susp_req | suspended)	@(posedge clk);
		sdram_wr2(LVL);

		while(susp_req | suspended)	@(posedge clk);
		sdram_rd3(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_wr3(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_rd4(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_wr4(LVL);

		while(susp_req | suspended)	@(posedge clk);
		sdram_wp(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_bo;
		while(susp_req | suspended)	@(posedge clk);
		sdram_rmw1(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_rmw2(LVL);

		while(susp_req | suspended)	@(posedge clk);
		rmw_cross1(LVL);


`ifdef MULTI_SDRAM
		while(susp_req | suspended)	@(posedge clk);
		sdram_rd5(LVL);
		while(susp_req | suspended)	@(posedge clk);
		sdram_wr5(LVL);
`endif

`ifdef FLASH
		while(susp_req | suspended)	@(posedge clk);
		asc_rdwr1(LVL);
`endif

`ifdef SRAM
		while(susp_req | suspended)	@(posedge clk);
		sram_rd1;
		while(susp_req | suspended)	@(posedge clk);
		sram_wr1;
		while(susp_req | suspended)	@(posedge clk);
		sram_wp;
		while(susp_req | suspended)	@(posedge clk);
		sram_wp;
		while(susp_req | suspended)	@(posedge clk);
		sram_rmw1;

		while(susp_req | suspended)	@(posedge clk);
		sram_rmw1;
		while(susp_req | suspended)	@(posedge clk);
		sram_rmw2;
`endif
		while(susp_req | suspended)	@(posedge clk);
		scs_rdwr1(LVL);

		done = 1;
	   end

	   begin
		repeat(50)	@(posedge clk);
		while(!done)
		   begin
			repeat(40)	@(posedge clk);
			susp_res;
		   end
	   end
	join

	mc_reset;
end
if(do_quick)	// Bus Request testing
begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Bus Request/Grant Testing ...                   :");
$display(" :....................................................:");
	verbose = 0;
	done = 0;
	fork
	   begin
`ifdef FLASH
		boot(LVL);
`endif

		m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0000_0000);

		sdram_rd1(LVL);
		sdram_wr1(LVL);
		sdram_rd1(LVL);
		sdram_wr1(LVL);
		sdram_rd3(LVL);
		sdram_wr3(LVL);
		sdram_rd4(LVL);
		sdram_wr4(LVL);
		sdram_wp(LVL);
		sdram_bo;
		sdram_rmw1(LVL);
		sdram_rmw2(LVL);

`ifdef MULTI_SDRAM
		sdram_rd5(LVL);
		sdram_wr5(LVL);
`endif


`ifdef FLASH
		asc_rdwr1(LVL);
`endif

`ifdef SRAM
		sram_rd1;
		sram_wr1;
		sram_wp;
		sram_rmw1;
		sram_rmw2;
`endif
		scs_rdwr1(LVL);
		done = 1;
	   end

	   begin
		repeat(50)	@(posedge clk);
		while(!done)
		   begin
			repeat(40)	@(posedge clk);
			bus_req;
		   end
	   end

	join
end
else
if(0)	// Debug Tests
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Test Debug Testing ...                          :");
$display(" :....................................................:");
	verbose = 0;
	//boot(2);

	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0000_0000);
	//sdram_rd1(2);
	//sdram_wr1(2);
	//asc_rdwr1(2);
//	sram_rd1;
//	sram_wr1;
	//sram_rmw1;
	//sram_rmw2;
	//sram_wp;
	//scs_rdwr1(2);

	//scs_rdwr1(2);

	//asc_rdwr1(2);
	//asc_rdwr1_x(2);

	//sdram_wp(2);
	//sdram_rmw1(2);
	//sdram_rmw2(2);

	//sdram_rd2(2);
	//sdram_wr2(2);

	//sdram_bo;
	//sdram_rd1b(2);




	//sdram_rd4(2);
	//sdram_wr4(2);
	//sdram_rd5(2);
	//sdram_wr5(2);

	//sdram_wp(2);
	//sdram_rmw1(2);
	//sdram_rmw2(2); 

	
	//rmw_cross1(2);

/*
	sram_rd1;
	sram_wr1;
	sram_rmw1;
	sram_rmw2;
	sram_wp;
*/


	sdram_rd1(2);
	sdram_wr1(2);
	sdram_rd2(2);
	sdram_wr2(2);
	sdram_rd3(2);
	sdram_wr3(2);
	sdram_rd4(2);
	sdram_wr4(2);


	sdram_rd5(2);
	sdram_wr5(2);

	sdram_wp(2);

	sdram_rmw1(2);
	sdram_rmw2(2); 
	rmw_cross1(2);




	repeat(100)	@(posedge clk);
	$finish;
   end
else 
   begin

	//
	// TEST DEVELOPMENT AREA
	//
	$display("\n\n");
	$display("*****************************************************");
	$display("*** Test Development ...                          ***");
	$display("*****************************************************\n");


	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");
   end

   	repeat(100)	@(posedge clk);
   	$finish;

end	// End of Initial


/////////////////////////////////////////////////////////////////////
//
// Clock Generation
//

always #2.5	clk = ~clk;

always @(posedge clk)
	mc_clk <= ~mc_clk;

/////////////////////////////////////////////////////////////////////
//
// IO Monitors
//

`define STD	10
always @(posedge clk)
	if((wb_ack_o === 1'bx) & ($time > `STD) )
	   begin
		$display("ERROR: Wishbone ACK unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(posedge clk)
	if( (wb_err_o === 1'bx) & ($time > `STD) )

	   begin
		$display("ERROR: Wishbone ERR unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(posedge clk)
	if( (mc_ras_ === 1'bx) & ($time > `STD) )

	   begin
		$display("ERROR: MC RAS unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(posedge clk)
	if( (mc_cas_ === 1'bx) & ($time > `STD) )

	   begin
		$display("ERROR: MC CAS unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(posedge clk)
	if( (mc_we_ === 1'bx) & ($time > `STD) )

	   begin
		$display("ERROR: MC WE unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(posedge clk)
	if( ((|mc_cs_) === 1'bx) & ($time > `STD) )

	   begin
		$display("ERROR: MC CS unknown (%t)", $time);
		error_cnt = error_cnt + 1;
	   end

always @(error_cnt)
	if(error_cnt > 25)	#500 $finish;

/*
time mc_time;

always @(posedge mc_clk)
	mc_time = $time;

always @(mc_cke_)
	if($time != (mc_time+1) )
		$display("WARNING: Unsexpected change of CKE (%t)", $time);
*/
	
/////////////////////////////////////////////////////////////////////
//
// IO Buffers
//

reg	rst_r1, rst_r2, rst_r3, rst_r4;

always @(posedge clk or posedge rst)
	if(rst)		rst_r1 <= #1 1'b1;
	else		rst_r1 <= #1 1'b0;

always @(posedge clk or posedge rst)
	if(rst)		rst_r2 <= #1 1'b1;
	else		rst_r2 <= #1 rst_r1;

always @(posedge clk or posedge rst)
	if(rst)		rst_r3 <= #1 1'b1;
	else		rst_r3 <= #1 rst_r2;

always @(posedge clk or posedge rst)
	if(rst)		rst_r4 <= #1 1'b1;
	else		rst_r4 <= #1 rst_r3;


wire	[31:0]	mc_dq;
wire	[3:0]	mc_dqp;
wire	[23:0]	_mc_addr;
wire	[3:0]	_mc_dqm;
wire		_mc_oe_;
wire		_mc_we_;
wire		_mc_cas_;
wire		_mc_ras_;
wire		_mc_cke_;
wire	[7:0]	_mc_cs_;
wire		_mc_rp_;
wire		_mc_vpen;
wire		_mc_adsc_;
wire		_mc_adv_;
wire		_mc_zz;
reg	[31:0]	rst_dq_val;

always @(poc_mode)
	case(poc_mode)
	   0: rst_dq_val = {28'hzzz_zzzz, 2'b10, 2'b00};
	   1: rst_dq_val = {28'hzzz_zzzz, 2'b10, 2'b01};
	   2: rst_dq_val = {28'hzzz_zzzz, 2'b10, 2'b10};
	 //  3: rst_dq_val = {28'hzzzz_zzzz, 2'b10, 2'b11};
	   default: rst_dq_val = 32'hzzzz_zzzz;
	endcase

assign  mc_dq = mc_data_oe ? mc_data_o : (rst_r4 ? rst_dq_val : 32'hzzzz_zzzz);
assign  mc_data_i = mc_dq;

assign  mc_dqp = mc_data_oe ? mc_dp_o : 4'hz;
assign  mc_dp_i = mc_dqp;

assign  mc_addr = mc_c_oe ? _mc_addr : 24'bz;
assign  mc_dqm = mc_c_oe ? _mc_dqm : 4'bz;
assign  mc_oe_ = mc_c_oe ? _mc_oe_ : 1'bz;
assign  mc_we_ = mc_c_oe ? _mc_we_ : 1'bz;
assign  mc_cas_ = mc_c_oe ? _mc_cas_ : 1'bz;
assign  mc_ras_ = mc_c_oe ? _mc_ras_ : 1'bz;
assign  mc_cke_ = mc_c_oe ? _mc_cke_ : 1'bz;
assign  mc_cs_ = mc_c_oe ? _mc_cs_ : 8'bz;
assign  mc_rp_ = mc_c_oe ? _mc_rp_ : 1'bz;
assign  mc_vpen = mc_c_oe ? _mc_vpen : 1'bz;
assign  mc_adsc_ = mc_c_oe ? _mc_adsc_ : 1'bz;
assign  mc_adv_ = mc_c_oe ? _mc_adv_ : 1'bz;
assign  mc_zz = mc_c_oe ? _mc_zz : 1'bz;

pullup p0(mc_cas_);
pullup p1(mc_ras_);
pullup p2(mc_oe_);
pullup p3(mc_we_);
pullup p4(mc_cke_);
pullup p5(mc_adsc_);
pullup p6(mc_adv_);
pullup p70(mc_cs_[0]);
pullup p71(mc_cs_[1]);
pullup p72(mc_cs_[2]);
pullup p73(mc_cs_[3]);
pullup p74(mc_cs_[4]);
pullup p75(mc_cs_[5]);
pullup p76(mc_cs_[6]);
pullup p77(mc_cs_[7]);
pullup p8(mc_rp_);


/////////////////////////////////////////////////////////////////////
//
// WISHBONE Memory Controller IP Core
//
mc_top	u0(
		.clk_i(		clk		),
		.rst_i(		rst		),
		.wb_data_i(	wb_data_i	),
		.wb_data_o(	wb_data_o	),
		.wb_addr_i(	wb_addr_i	),
		.wb_sel_i(	wb_sel_i	),
		.wb_we_i(	wb_we_i		),
		.wb_cyc_i(	wb_cyc_i	),
		.wb_stb_i(	wb_stb_i	),
		.wb_ack_o(	wb_ack_o	),
		.wb_err_o(	wb_err_o	),
		.susp_req_i(	susp_req	),
		.resume_req_i(	resume_req	),
		.suspended_o(	suspended	),
		.poc_o(		poc		),
		.mc_clk_i(	mc_clk		),
		.mc_br_pad_i(	mc_br		),
		.mc_bg_pad_o(	mc_bg		),
		.mc_ack_pad_i(	mc_ack		),
		.mc_addr_pad_o(	_mc_addr	),
		.mc_data_pad_i(	mc_data_i	),
		.mc_data_pad_o(	mc_data_o	),
		.mc_dp_pad_i(	mc_dp_i		),
		.mc_dp_pad_o(	mc_dp_o		),
		.mc_doe_pad_doe_o(mc_data_oe	),
		.mc_dqm_pad_o(	_mc_dqm		),
		.mc_oe_pad_o_(	_mc_oe_		),
		.mc_we_pad_o_(	_mc_we_		),
		.mc_cas_pad_o_(	_mc_cas_	),
		.mc_ras_pad_o_(	_mc_ras_	),
		.mc_cke_pad_o_(	_mc_cke_	),
		.mc_cs_pad_o_(	_mc_cs_		),
		.mc_sts_pad_i(	mc_sts		),
		.mc_rp_pad_o_(	_mc_rp_		),
		.mc_vpen_pad_o(	_mc_vpen	),
		.mc_adsc_pad_o_(_mc_adsc_	),
		.mc_adv_pad_o_(	_mc_adv_	),
		.mc_zz_pad_o(	_mc_zz		),
		.mc_coe_pad_coe_o(mc_c_oe	)
		);

/////////////////////////////////////////////////////////////////////
//
// WISHBONE Master Model
//

wb_mast	m0(	.clk(		clk		),
		.rst(		~rst		),
		.adr(		wb_addr_i	),
		.din(		wb_data_o	),
		.dout(		wb_data_i	),
		.cyc(		wb_cyc_i	),
		.stb(		wb_stb_i	),
		.sel(		wb_sel_i	),
		.we(		wb_we_i		),
		.ack(		wb_ack_o	),
		.err(		wb_err_o	),
		.rty(		wb_rty_o	)
		);

/////////////////////////////////////////////////////////////////////
//
// Sync. CS Device Model
//

sync_cs_dev s0(
		.clk(		mc_clk		),
		.addr(		mc_addr[15:0]	),
		.dq(		mc_dq		),
		.cs_(		mc_cs_[5]	),
		.we_(		mc_we_		),
		.oe_(		mc_oe_		),
		.ack_(		mc_ack		)
		);


/////////////////////////////////////////////////////////////////////
//
// Memory Models
//

wire	[27:0]	dq_tmp;

`ifdef SDRAM0
//	Model:  MT48LC2M32B2 (2Meg x 32 x 4 Banks)
mt48lc2m32b2 sdram0(
		.Dq(		mc_dq		),
		.Addr(		mc_addr[10:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[0]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm		)
		);

mt48lc2m32b2 sdram0p(
		.Dq(		{dq_tmp, mc_dqp}),
		.Addr(		mc_addr[10:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[0]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm		)
		);

`endif

`ifdef MULTI_SDRAM
//	Model:  MT48LC2M32B2 (2Meg x 32 x 4 Banks)

mt48lc2m32b2 sdram1(
		.Dq(		mc_dq		),
		.Addr(		mc_addr[10:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[1]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm		)
		);

mt48lc2m32b2 sdram1p(
		.Dq(		{dq_tmp, mc_dqp}	),
		.Addr(		mc_addr[10:0]		),
		.Ba(		mc_addr[14:13]		),
		.Clk(		mc_clk			),
		.Cke(		mc_cke_			),
		.Cs_n(		mc_cs_[1]		),
		.Ras_n(		mc_ras_			),
		.Cas_n(		mc_cas_			),
		.We_n(		mc_we_			),
		.Dqm(		mc_dqm			)
		);


//	Model:  MT48LC2M32B2 (2Meg x 32 x 4 Banks)
mt48lc2m32b2 sdram2(
		.Dq(		mc_dq		),
		.Addr(		mc_addr[10:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[2]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm		)
		);

mt48lc2m32b2 sdram2p(
		.Dq(		{dq_tmp, mc_dqp}),
		.Addr(		mc_addr[10:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[2]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm		)
		);

mt48lc16m16a2 sdram1a(
		.Dq(		mc_dq[15:0]	),
		.Addr(		mc_addr[12:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[5]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm[1:0]	)
		);

mt48lc16m16a2 sdram1b(
		.Dq(		mc_dq[31:16]	),
		.Addr(		mc_addr[12:0]	),
		.Ba(		mc_addr[14:13]	),
		.Clk(		mc_clk		),
		.Cke(		mc_cke_		),
		.Cs_n(		mc_cs_[5]	),
		.Ras_n(		mc_ras_		),
		.Cas_n(		mc_cas_		),
		.We_n(		mc_we_		),
		.Dqm(		mc_dqm[3:2]	)
		);

`endif

`ifdef FLASH
IntelAdvBoot f1(
		.dq(	mc_dq[15:0]	),
		.addr(	mc_addr[19:0]	),
		.ceb(	mc_cs_[3]	),
		.oeb(	mc_oe_		),
		.web(	mc_we_		),
		.rpb(	mc_rp_		),
		.wpb(	1'b0		),
		.vpp(	3300		),
		.vcc(	3300		)
		);
`endif


`ifdef SRAM

`ifdef MICRON
mt58l1my18d sram0a(
		.Dq(		{mc_dqp[1],
				mc_dq[15:8],
				mc_dqp[0],
				mc_dq[7:0]}	),

		.Addr(		mc_addr[19:0]	),
		.Mode(		1'b0		),
		.Adv_n(		mc_adv_		),
		.Clk(		mc_clk		),
		.Adsc_n(	mc_adsc_	),
		.Adsp_n(	1'b1		),

		.Bwa_n(		mc_dqm[0]	),
		.Bwb_n(		mc_dqm[1]	),
		.Bwe_n(		mc_we_		),
		.Gw_n(		1'b1		),

		.Ce_n(		mc_cs_[4]	),
		.Ce2(		1'b1		),
		.Ce2_n(		1'b0		),
		.Oe_n(		mc_oe_		),
		.Zz(		mc_zz		)
		);


mt58l1my18d sram0b(
		.Dq(		{mc_dqp[3],
				mc_dq[31:24],
				mc_dqp[2],
				mc_dq[23:16]}	),

		.Addr(		mc_addr[19:0]	),
		.Mode(		1'b0		),
		.Adv_n(		mc_adv_		),
		.Clk(		mc_clk		),
		.Adsc_n(	mc_adsc_	),
		.Adsp_n(	1'b1		),

		.Bwa_n(		mc_dqm[2]	),
		.Bwb_n(		mc_dqm[3]	),
		.Bwe_n(		mc_we_		),
		.Gw_n(		1'b1		),

		.Ce_n(		mc_cs_[4]	),
		.Ce2(		1'b1		),
		.Ce2_n(		1'b0		),
		.Oe_n(		mc_oe_		),
		.Zz(		mc_zz		)
		);

`else

idt71t67802s133 sram0a(
		.A(	mc_addr[18:0]	),
		.D(	mc_dq[15:0]	),
		.DP(	mc_dqp[1:0]	),
		.oe_(	mc_oe_		),
		.ce_(	mc_cs_[4]	),
		.cs0(	1'b1		),
		.cs1_(	1'b0		),
		.lbo_(	1'b0		), 

		.gw_(	1'b1		),
		.bwe_(	mc_we_		),
		.bw2_(	mc_dqm[1]	),
		.bw1_(	mc_dqm[0]	),

		.adsp_(	1'b1		),
		.adsc_(	mc_adsc_	),
		.adv_(	mc_adv_		),
		.clk(	mc_clk		)
		);

idt71t67802s133 sram0b(
		.A(	mc_addr[18:0]	),
		.D(	mc_dq[31:16]	),
		.DP(	mc_dqp[3:2]	),
		.oe_(	mc_oe_		),
		.ce_(	mc_cs_[4]	),
		.cs0(	1'b1		),
		.cs1_(	1'b0		),
		.lbo_(	1'b0		), 

		.gw_(	1'b1		),
		.bwe_(	mc_we_		),
		.bw2_(	mc_dqm[3]	),
		.bw1_(	mc_dqm[2]	),

		.adsp_(	1'b1		),
		.adsc_(	mc_adsc_	),
		.adv_(	mc_adv_		),
		.clk(	mc_clk		)
		);
`endif

`endif

`include "tests.v"
`include "test_lib.v"

endmodule

