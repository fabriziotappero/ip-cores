/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/ac97_ctrl/ ////
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
//  $Id: test_bench_top.v,v 1.4 2002-09-19 06:36:19 rudi Exp $
//
//  $Date: 2002-09-19 06:36:19 $
//  $Revision: 1.4 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2002/03/11 03:21:12  rudi
//
//               - Added defines to select fifo depth between 4, 8 and 16 entries.
//
//               Revision 1.2  2002/03/05 04:44:04  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2002/02/13 08:22:32  rudi
//
//               Added test bench for public release
//
//
//
//                        

`include "ac97_defines.v"

module test;

reg		clk;
reg		rst;
wire	[31:0]	wb_data_i;
wire	[31:0]	wb_data_o;
wire	[31:0]	wb_addr_i;
wire	[3:0]	wb_sel_i;
wire		wb_we_i;
wire		wb_cyc_i;
wire		wb_stb_i;
wire		wb_ack_o;
wire		wb_err_o;
wire		int;
wire	[8:0]	dma_req;
reg	[8:0]	dma_ack;
reg		susp_req;
reg		resume_req;
wire		suspended;
reg		bit_clk;
wire		sync;
wire		sdata_out;
wire		sdata_in;
wire		ac97_reset_;

// Test Bench Variables
reg		verbose;
integer		error_cnt;

// DMA model
reg		wb_busy;
reg		oc0_dma_en;
reg		oc1_dma_en;
reg		oc2_dma_en;
reg		oc3_dma_en;
reg		oc4_dma_en;
reg		oc5_dma_en;
reg		ic0_dma_en;
reg		ic1_dma_en;
reg		ic2_dma_en;
reg	[31:0]	oc0_mem[0:256];
reg	[31:0]	oc1_mem[0:256];
reg	[31:0]	oc2_mem[0:256];
reg	[31:0]	oc3_mem[0:256];
reg	[31:0]	oc4_mem[0:256];
reg	[31:0]	oc5_mem[0:256];
reg	[31:0]	ic0_mem[0:256];
reg	[31:0]	ic1_mem[0:256];
reg	[31:0]	ic2_mem[0:256];
reg	[31:0]	reg_mem[0:256];
integer		oc0_ptr;
integer		oc1_ptr;
integer		oc2_ptr;
integer		oc3_ptr;
integer		oc4_ptr;
integer		oc5_ptr;
integer		ic0_ptr;
integer		ic1_ptr;
integer		ic2_ptr;

integer		oc0_th;
integer		oc1_th;
integer		oc2_th;
integer		oc3_th;
integer		oc4_th;
integer		oc5_th;
integer		ic0_th;
integer		ic1_th;
integer		ic2_th;

reg	[31:0]	ints_r;
reg		int_chk_en;
reg		int_ctrl_en;
integer		int_cnt;

integer		n;

// Misc Variables
reg	[31:0]	data;
reg	[31:0]	data1;
reg	[31:0]	data2;
reg	[31:0]	tmp;
integer		size, frames, m, p;

/////////////////////////////////////////////////////////////////////
//
// Defines 
//

`define	CSR		8'h00
`define	OCC0		8'h04
`define	OCC1		8'h08
`define	ICC		8'h0c
`define	CRAC		8'h10
`define	INTM		8'h14
`define	INTS		8'h18

`define	OC0		8'h20
`define	OC1		8'h24
`define	OC2		8'h28
`define	OC3		8'h2c
`define	OC4		8'h30
`define	OC5		8'h34
`define	IC0		8'h38
`define	IC1		8'h3c
`define	IC2		8'h40

/////////////////////////////////////////////////////////////////////
//
// Simulation Initialization and Start up Section
//

task do_rst;

begin
	wb_busy = 0;
	oc0_dma_en = 0;
	oc1_dma_en = 0;
	oc2_dma_en = 0;
	oc3_dma_en = 0;
	oc4_dma_en = 0;
	oc5_dma_en = 0;
	ic0_dma_en = 0;
	ic1_dma_en = 0;
	ic2_dma_en = 0;

	oc0_ptr = 0;
	oc1_ptr = 0;
	oc2_ptr = 0;
	oc3_ptr = 0;
	oc4_ptr = 0;
	oc5_ptr = 0;
	ic0_ptr = 0;
	ic1_ptr = 0;
	ic2_ptr = 0;

   	rst = 0;
   	repeat(48)	@(posedge clk);
   	rst = 1;
   	repeat(48)	@(posedge clk);

end

endtask

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
	//wd_cnt = 0;
	int_chk_en = 1;
	int_ctrl_en = 0;
	int_cnt = 0;
	error_cnt = 0;
   	clk = 1;
	bit_clk = 0;
   	rst = 0;
	susp_req = 0;
	resume_req = 0;
	verbose = 1;
	dma_ack = 0;

	wb_busy = 0;
	oc0_dma_en = 0;
	oc1_dma_en = 0;
	oc2_dma_en = 0;
	oc3_dma_en = 0;
	oc4_dma_en = 0;
	oc5_dma_en = 0;
	ic0_dma_en = 0;
	ic1_dma_en = 0;
	ic2_dma_en = 0;

	oc0_ptr = 0;
	oc1_ptr = 0;
	oc2_ptr = 0;
	oc3_ptr = 0;
	oc4_ptr = 0;
	oc5_ptr = 0;
	ic0_ptr = 0;
	ic1_ptr = 0;
	ic2_ptr = 0;


	oc0_th = 4;
	oc1_th = 4;
	oc2_th = 4;
	oc3_th = 4;
	oc4_th = 4;
	oc5_th = 4;
	ic0_th = 4;
	ic1_th = 4;
	ic2_th = 4;


`ifdef AC97_OUT_FIFO_DEPTH_8
	oc0_th = oc0_th * 2;
	oc1_th = oc1_th * 2;
	oc2_th = oc2_th * 2;
	oc3_th = oc3_th * 2;
	oc4_th = oc4_th * 2;
	oc5_th = oc5_th * 2;
`endif

`ifdef AC97_OUT_FIFO_DEPTH_16
	oc0_th = oc0_th * 4;
	oc1_th = oc1_th * 4;
	oc2_th = oc2_th * 4;
	oc3_th = oc3_th * 4;
	oc4_th = oc4_th * 4;
	oc5_th = oc5_th * 4;
`endif

`ifdef AC97_IN_FIFO_DEPTH_8
	ic0_th = ic0_th * 2;
	ic1_th = ic1_th * 2;
	ic2_th = ic2_th * 2;
`endif

`ifdef AC97_IN_FIFO_DEPTH_16
	ic0_th = ic0_th * 4;
	ic1_th = ic1_th * 4;
	ic2_th = ic2_th * 4;
`endif



   	repeat(48)	@(posedge clk);
   	rst = 1;
   	repeat(48)	@(posedge clk);

	// HERE IS WHERE THE TEST CASES GO ...

if(1)	// Full Regression Run
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Regression Run ...                              :");
$display(" :....................................................:");

	basic1;

	do_rst;

	basic2;

	do_rst;

	vsr1;

	vsr_int;

   end
else
if(1)	// Debug Tests
   begin
$display(" ......................................................");
$display(" :                                                    :");
$display(" :    Test Debug Testing ...                          :");
$display(" :....................................................:");

	//basic1;

	//do_rst;

	//basic2;

	//do_rst;

	//vsr1;

	vsr_int;

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
$display("*** XXX AC97 I/O Test ...                         ***");
$display("*****************************************************\n");


	wb_busy = 1;
	m0.wb_wr1(`INTM,4'hf, 32'h0000_0003);
	m0.wb_wr1(`OCC0,4'hf, 32'h7373_7373);
	m0.wb_wr1(`OCC1,4'hf, 32'h0000_7373);
	m0.wb_wr1(`ICC,4'hf, 32'h0073_7373);
	m0.wb_wr1(`OCC0,4'hf, 32'h7272_7272);
	m0.wb_wr1(`OCC1,4'hf, 32'h0000_7272);

	wb_busy = 0;
	oc0_dma_en = 1;
	oc1_dma_en = 1;
	oc2_dma_en = 1;
	oc3_dma_en = 1;
	oc4_dma_en = 1;
	oc5_dma_en = 1;
	ic0_dma_en = 1;
	ic1_dma_en = 1;
	ic2_dma_en = 1;

	for(n=0;n<256;n=n+1)
	   begin
		oc0_mem[n] = $random;
		oc1_mem[n] = $random;
		oc2_mem[n] = $random;
		oc3_mem[n] = $random;
		oc4_mem[n] = $random;
		oc5_mem[n] = $random;
		ic0_mem[n] = $random;
		ic1_mem[n] = $random;
		ic2_mem[n] = $random;
	   end

	u1.init(0);
	frames = 139;

fork
	u1.tx1(	frames,					// Number of frames to process
		0,					// How many frames before codec is ready
		10'b1111_1111_11,			// Output slots valid bits
		10'b1111_1111_11,			// Input slots valid bits
		20'b00_00_00_00_00_00_00_00_00_00,	// Output Slots intervals
		20'b00_00_00_00_00_00_00_00_00_00	// Input Slots intervals
		);

	begin	// Do a register Write
		repeat(2)	@(posedge sync);

		for(n=0;n<75;n=n+1)
		   begin
			@(negedge sync);
			repeat(230)	@(posedge bit_clk);

			repeat(n)	@(posedge bit_clk);

			while(wb_busy)	@(posedge clk);
			wb_busy = 1;
			m0.wb_wr1(`CRAC,4'hf, {1'b1, 8'h0, n[6:0], 16'h1234 + n[7:0]} );
			wb_busy = 0;

			while(!int)	@(posedge clk);

			while(wb_busy)	@(posedge clk);
			wb_busy = 1;
			m0.wb_rd1(`CRAC,4'hf, reg_mem[n] );
			m0.wb_wr1(`CSR, 4'hf, 32'h0000_0001);

			repeat(10)	@(posedge clk);
			force bit_clk = 0;
			repeat(80)	@(posedge clk);

			m0.wb_wr1(`CSR, 4'hf, 32'h0000_0002);

			repeat(300)	@(posedge clk);

			release bit_clk;

			wb_busy = 0;

		   end
	end
join

repeat(300)	@(posedge bit_clk);

	for(n=0;n<75;n=n+1)
	   begin

			tmp = u1.is2_mem[n];
			data2 = {16'h0, tmp[19:4]};
			tmp = reg_mem[n];
			data1 = {16'h0, tmp[15:0]};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Register Read Data %0d Mismatch Expected: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end

	   end

	size = frames - 4;

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs3_mem[n];
		data = oc0_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH0 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs4_mem[n];
		data = oc1_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH1 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs6_mem[n];
		data = oc2_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH2 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs7_mem[n];
		data = oc3_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH3 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs8_mem[n];
		data = oc4_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH4 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.rs9_mem[n];
		data = oc5_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: Out. CH5 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.is3_mem[n];
		data = ic0_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: In. CH0 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.is4_mem[n];
		data = ic1_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: In. CH1 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<size;n=n+1)
	   begin
		data1 = u1.is6_mem[n];
		data = ic2_mem[n[8:1]];

		if(~n[0])	data2 = {12'h0, data[15:0], 4'h0};
		else		data2 = {12'h0, data[31:16], 4'h0};

		if(	(data1 !== data2) |
			(^data1 === 1'hx) |
			(^data2 === 1'hx)
			)
		   begin
			$display("ERROR: In. CH2 Sample %0d Mismatch Sent: %h Got: %h",
			n, data2, data1);
			error_cnt = error_cnt + 1;
		   end
	   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");


repeat(6000)	@(posedge clk);
$finish;

   end

   	repeat(100)	@(posedge clk);
   	$finish;
   end


task wait_sync;

begin

while(!sync)	@(posedge bit_clk);
repeat(2)	@(posedge bit_clk);
end
endtask

/////////////////////////////////////////////////////////////////////
//
// Simple Interrupt Handler
//

always @(posedge clk)
begin
if(int & int_chk_en)
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	m0.wb_rd1(`INTS,4'hf, ints_r);
	//$display("INFO: Got Interrupt (%0d). INTS: %h (%t)", int_cnt, ints_r, $time);
	wb_busy = 0;
	int_cnt = int_cnt + 1;
   end
if(int & int_ctrl_en)
   begin

	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	m0.wb_rd1(`INTS,4'hf, ints_r);
	//$display("INFO: Got Interrupt (%0d). INTS: %h (%t)", int_cnt, ints_r, $time);

	out_chan_int_handl(ints_r[04:02],0);
	out_chan_int_handl(ints_r[07:05],1);
	out_chan_int_handl(ints_r[10:08],2);
	out_chan_int_handl(ints_r[13:11],3);
	out_chan_int_handl(ints_r[16:14],4);
	out_chan_int_handl(ints_r[19:17],5);

	in_chan_int_handl(ints_r[22:20],0);
	in_chan_int_handl(ints_r[25:23],1);
	in_chan_int_handl(ints_r[28:26],2);

	m0.wb_rd1(`INTS,4'hf, ints_r);
	wb_busy = 0;
	int_cnt = int_cnt + 1;
   end
end


task out_chan_int_handl;
input	[2:0]	int_r;
input		ch;

reg	[2:0]	int_r;
integer		ch;
integer		p;

begin

	if(int_r[0])	// Output Channel at Thrash hold
	   begin
		case(ch)
		0: begin
			for(p=0;p<oc0_th;p=p+1)
				m0.wb_wr1(`OC0,4'hf, oc0_mem[oc0_ptr+p]	);
			oc0_ptr = oc0_ptr + oc0_th;
		   end
		1: begin
			for(p=0;p<oc1_th;p=p+1)
				m0.wb_wr1(`OC1,4'hf, oc1_mem[oc1_ptr+p]	);
			oc1_ptr = oc1_ptr + oc1_th;
		   end
		2: begin
			for(p=0;p<oc2_th;p=p+1)
				m0.wb_wr1(`OC2,4'hf, oc2_mem[oc2_ptr+p]	);
			oc2_ptr = oc2_ptr + oc2_th;
		   end
		3: begin
			for(p=0;p<oc3_th;p=p+1)
				m0.wb_wr1(`OC3,4'hf, oc3_mem[oc3_ptr+p]	);
			oc3_ptr = oc3_ptr + oc3_th;
		   end
		4: begin
			for(p=0;p<oc4_th;p=p+1)
				m0.wb_wr1(`OC4,4'hf, oc4_mem[oc4_ptr+p]	);
			oc4_ptr = oc4_ptr + oc4_th;
		   end
		5: begin
			for(p=0;p<oc5_th;p=p+1)
				m0.wb_wr1(`OC5,4'hf, oc5_mem[oc5_ptr+p]	);
			oc5_ptr = oc5_ptr + oc5_th;
		   end
		endcase
	   end
	if(int_r[1])	// Output Channel FIFO Underrun
		$display("ERROR: Output Channel %0d FIFO Underrun", ch);

	if(int_r[2])	// Output Channel FIFO Overun
		$display("ERROR: Output Channel %0d FIFO Ovverun", ch);
end
endtask



task in_chan_int_handl;
input	[2:0]	int_r;
input		ch;

reg	[2:0]	int_r;
integer		ch;
integer		p;

begin
	if(int_r[0])	// Input Channel at Thrash hold
	   begin
		case(ch)
		0: begin
			for(p=0;p<ic0_th;p=p+1)
				m0.wb_rd1(`IC0,4'hf, ic0_mem[ic0_ptr+p]	);
			ic0_ptr = ic0_ptr + ic0_th;
		   end
		1: begin
			for(p=0;p<ic1_th;p=p+1)
				m0.wb_rd1(`IC1,4'hf, ic1_mem[ic1_ptr+p]	);
			ic1_ptr = ic1_ptr + ic1_th;
		   end
		2: begin
			for(p=0;p<ic2_th;p=p+1)
				m0.wb_rd1(`IC2,4'hf, ic2_mem[ic2_ptr+p]	);
			ic2_ptr = ic2_ptr + ic2_th;
		   end
		endcase
	   end
	if(int_r[1])	// Input Channel FIFO Underrun
		$display("ERROR: Input Channel %0d FIFO Underrun", ch);

	if(int_r[2])	// Input Channel FIFO Overun
		$display("ERROR: Input Channel %0d FIFO Ovverun", ch);
end
endtask



/////////////////////////////////////////////////////////////////////
//
// Simple DMA Engine
//

always @(posedge clk)
if(oc0_dma_en & dma_req[0])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;

	for(p=0;p<oc0_th;p=p+1)
		m0.wb_wr1(`OC0,4'hf, oc0_mem[oc0_ptr+p]	);
	oc0_ptr = oc0_ptr + oc0_th;

	wb_busy = 0;
	dma_ack[0] = 1;
	@(posedge clk);
	#1 dma_ack[0] = 0;
   end


always @(posedge clk)
if(oc1_dma_en & dma_req[1])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<oc1_th;p=p+1)
		m0.wb_wr1(`OC1,4'hf, oc1_mem[oc1_ptr+p]	);
	oc1_ptr = oc1_ptr + oc1_th;
	wb_busy = 0;
	dma_ack[1] = 1;
	@(posedge clk);
	#1 dma_ack[1] = 0;
   end

always @(posedge clk)
if(oc2_dma_en & dma_req[2])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<oc2_th;p=p+1)
		m0.wb_wr1(`OC2,4'hf, oc2_mem[oc2_ptr+p]	);
	oc2_ptr = oc2_ptr + oc2_th;
	wb_busy = 0;
	dma_ack[2] = 1;
	@(posedge clk);
	#1 dma_ack[2] = 0;
   end

always @(posedge clk)
if(oc3_dma_en & dma_req[3])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<oc3_th;p=p+1)
		m0.wb_wr1(`OC3,4'hf, oc3_mem[oc3_ptr+p]	);
	oc3_ptr = oc3_ptr + oc3_th;
	wb_busy = 0;
	dma_ack[3] = 1;
	@(posedge clk);
	#1 dma_ack[3] = 0;
   end

always @(posedge clk)
if(oc4_dma_en & dma_req[4])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<oc4_th;p=p+1)
		m0.wb_wr1(`OC4,4'hf, oc4_mem[oc4_ptr+p]	);
	oc4_ptr = oc4_ptr + oc4_th;
	wb_busy = 0;
	dma_ack[4] = 1;
	@(posedge clk);
	#1 dma_ack[4] = 0;
   end

always @(posedge clk)
if(oc5_dma_en & dma_req[5])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<oc5_th;p=p+1)
		m0.wb_wr1(`OC5,4'hf, oc5_mem[oc5_ptr+p]	);
	oc5_ptr = oc5_ptr + oc5_th;
	wb_busy = 0;
	dma_ack[5] = 1;
	@(posedge clk);
	#1 dma_ack[5] = 0;
   end

always @(posedge clk)
if(ic0_dma_en & dma_req[6])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<ic0_th;p=p+1)
		m0.wb_rd1(`IC0,4'hf, ic0_mem[ic0_ptr+p]	);
	ic0_ptr = ic0_ptr + ic0_th;
	wb_busy = 0;
	dma_ack[6] = 1;
	@(posedge clk);
	#1 dma_ack[6] = 0;
   end

always @(posedge clk)
if(ic1_dma_en & dma_req[7])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<ic1_th;p=p+1)
		m0.wb_rd1(`IC1,4'hf, ic1_mem[ic1_ptr+p]	);
	ic1_ptr = ic1_ptr + ic1_th;
	wb_busy = 0;
	dma_ack[7] = 1;
	@(posedge clk);
	#1 dma_ack[7] = 0;
   end

always @(posedge clk)
if(ic2_dma_en & dma_req[8])
   begin
	while(wb_busy)	@(posedge clk);
	wb_busy = 1;
	for(p=0;p<ic2_th;p=p+1)
		m0.wb_rd1(`IC2,4'hf, ic2_mem[ic2_ptr+p]	);
	ic2_ptr = ic2_ptr + ic2_th;
	wb_busy = 0;
	dma_ack[8] = 1;
	@(posedge clk);
	#1 dma_ack[8] = 0;
   end




/////////////////////////////////////////////////////////////////////
//
// Clock Generation
//

always #2.5	clk = ~clk;
//always #15	clk = ~clk;

always #40.69	bit_clk <= ~bit_clk;


/////////////////////////////////////////////////////////////////////
//
// WISHBONE AC 97 Controller IP Core
//

ac97_top	u0(
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
		.int_o(		int		),
		.dma_req_o(	dma_req		),
		.dma_ack_i(	dma_ack		),
		.suspended_o(	suspended	),
		.bit_clk_pad_i(	bit_clk		),
		.sync_pad_o(	sync		),
		.sdata_pad_o(	sdata_out	),
		.sdata_pad_i(	sdata_in	),
		.ac97_reset_pad_o_(	ac97_reset_	)
		);

/////////////////////////////////////////////////////////////////////
//
// WISHBONE Master Model
//

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
		.rty(				)
		);

/////////////////////////////////////////////////////////////////////
//
// AC 97 Codec Model
//


ac97_codec_top	u1(
		.clk(		bit_clk		),
		.rst(		rst		),
		.sync(		sync		),
		.sdata_out(	sdata_in	),
		.sdata_in(	sdata_out	)
		);



/////////////////////////////////////////////////////////////////////
//
// Tests and libraries
//


`include "tests.v"

endmodule


