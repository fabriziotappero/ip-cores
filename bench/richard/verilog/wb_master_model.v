///////////////////////////////////////////////////////////////////////
////                                                               ////
////  WISHBONE rev.B2 Wishbone Master model                        ////
////                                                               ////
////                                                               ////
////  Author: Richard Herveille                                    ////
////          richard@asics.ws                                     ////
////          www.asics.ws                                         ////
////                                                               ////
////  Downloaded from: http://www.opencores.org/projects/mem_ctrl  ////
////                                                               ////
///////////////////////////////////////////////////////////////////////
////                                                               ////
//// Copyright (C) 2001 Richard Herveille                          ////
////                    richard@asics.ws                           ////
////                                                               ////
//// This source file may be used and distributed without          ////
//// restriction provided that this copyright statement is not     ////
//// removed from the file and that any derivative work contains   ////
//// the original copyright notice and the associated disclaimer.  ////
////                                                               ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY       ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR        ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,           ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES      ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR          ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF    ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT    ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           ////
//// POSSIBILITY OF SUCH DAMAGE.                                   ////
////                                                               ////
///////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: wb_master_model.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
//
//  $Date: 2002-03-06 15:10:34 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//
`include "timescale.v"

module wb_master_model(clk, rst, adr, din, dout, cyc, stb, we, sel, ack, err, rty);

	//
	// parameters
	//
	parameter dwidth = 32;
	parameter awidth = 32;

	//
	// inputs & outputs
	//
	input                  clk, rst;
	output [awidth   -1:0]	adr;
	input  [dwidth   -1:0]	din;
	output [dwidth   -1:0]	dout;
	output                 cyc, stb;
	output       	        	we;
	output [dwidth/8 -1:0] sel;
	input		                ack, err, rty;

	//
	// variables
	//
	reg	[awidth   -1:0]	adr;
	reg	[dwidth   -1:0]	dout;
	reg		               cyc, stb;
	reg		               we;
	reg [dwidth/8 -1:0] sel;

	reg [dwidth   -1:0] q;

	integer err_cur_cnt, err_tot_cnt, err_wb_cnt, err_watchdog;


	//
	// module body
	//

	// check ack, err and rty assertion
	always@(ack or err or rty)
	begin
		case ({ack, err, rty})
			// ok-states
//			3'b000: // none asserted
//			3'b001: // only rty asserted
//			3'b010: // only err asserted
//			3'b100: // only ack asserted

			// fault-states
			3'b011: // oops, err and rty
				begin
					err_wb_cnt = err_wb_cnt +1;
					$display("Wishbone error: ERR_I and RTY_I are both asserted at time %t.", $time);
				end
			3'b101: // oops, ack and rty
				begin
					err_wb_cnt = err_wb_cnt +1;
					$display("Wishbone error: ACK_I and RTY_I are both asserted at time %t.", $time);
				end
			3'b110: // oops, ack and err
				begin
					err_wb_cnt = err_wb_cnt +1;
					$display("Wishbone error: ACK_I and ERR_I are both asserted at time %t.", $time);
				end
			3'b111: // oops, ack, err and rty
				begin
					err_wb_cnt = err_wb_cnt +1;
					$display("Wishbone error: ACK_I, ERR_I and RTY_I are all asserted at time %t.", $time);
				end
		endcase
	
		if (err_wb_cnt > err_watchdog)
			begin
				$display("\nTestbench stopped. More than %d wishbone errors detected.\n", err_watchdog);
				$stop;
			end
	end

	// initial settings
	initial
	begin
		//adr = 32'hxxxx_xxxx;
		//adr = 0;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		cyc  = 1'b0;
		stb  = 1'bx;
		we   = 1'hx;
		sel  = {dwidth/8{1'bx}};

		err_tot_cnt = 0;
		err_cur_cnt = 0;
		err_wb_cnt  = 0;
		err_watchdog = 10;

		#1;
		$display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)\n");
	end


	////////////////////////////
	//
	// Wishbone write cycle
	//

	task wb_write;
		input   delay;
		integer delay;
		input   stb_delay;
		integer stb_delay;

		input	[awidth -1:0]	a;
		input	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		#1;
		// assert cyc_signal
		cyc  = 1'b1;
		stb  = 1'b0;

		// wait for stb_assertion
		repeat(stb_delay) @(posedge clk);

		// assert wishbone signals
		adr  = a;
		dout = d;
		stb  = 1'b1;
		we   = 1'b1;
		sel  = {dwidth/8{1'b1}};
		@(posedge clk);

		// wait for acknowledge from slave
		// err is treated as normal ack
		// rty is ignored (thus retrying cycle)
		while(~ (ack || err))	@(posedge clk);

		// negate wishbone signals
		#1;
		cyc  = 1'b0;
		stb  = 1'bx;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'hx;
		sel  = {dwidth/8{1'bx}};

	end
	endtask

	task wb_write_sel;
		input   delay;
		integer delay;
		input   stb_delay;
		integer stb_delay;

		input [dwidth/8 -1:0] s;
		input	[awidth   -1:0]	a;
		input	[dwidth   -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		#1;
		// assert cyc_signal
		cyc  = 1'b1;
		stb  = 1'b0;

		// wait for stb_assertion
		repeat(stb_delay) @(posedge clk);

		// assert wishbone signals
		adr  = a;
		dout = d;
		stb  = 1'b1;
		we   = 1'b1;
		sel  = s;
		@(posedge clk);

		// wait for acknowledge from slave
		// err is treated as normal ack
		// rty is ignored (thus retrying cycle)
		while(~ (ack || err))	@(posedge clk);

		// negate wishbone signals
		#1;
		cyc  = 1'b0;
		stb  = 1'bx;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'hx;
		sel  = {dwidth/8{1'bx}};

	end
	endtask

	////////////////////////////
	//
	// Wishbone read cycle
	//

	task wb_read;
		input   delay;
		integer delay;
		input   stb_delay;
		integer stb_delay;

		input	 [awidth -1:0]	a;
		output	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		#1;
		// assert cyc_signal
		cyc  = 1'b1;
		stb  = 1'b0;

		// wait for stb_assertion
		repeat(stb_delay) @(posedge clk);

		// assert wishbone signals
		adr  = a;
		dout = {dwidth{1'bx}};
		stb  = 1'b1;
		we   = 1'b0;
		sel  = {dwidth/8{1'b1}};
		@(posedge clk);

		// wait for acknowledge from slave
		// err is treated as normal ack
		// rty is ignored (thus retrying cycle)
		while(~ (ack || err))	@(posedge clk);

		// negate wishbone signals
		#1;
		cyc  = 1'b0;
		stb  = 1'bx;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'hx;
		sel  = {dwidth/8{1'bx}};
		d    = din;

	end
	endtask

	task wb_read_sel;
		input   delay;
		integer delay;
		input   stb_delay;
		integer stb_delay;

		input  [dwidth/8 -1:0] s;
		input	 [awidth   -1:0]	a;
		output	[dwidth   -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		#1;
		// assert cyc_signal
		cyc  = 1'b1;
		stb  = 1'b0;

		// wait for stb_assertion
		repeat(stb_delay) @(posedge clk);

		// assert wishbone signals
		adr  = a;
		dout = {dwidth{1'bx}};
		stb  = 1'b1;
		we   = 1'b0;
		sel  = s;
		@(posedge clk);

		// wait for acknowledge from slave
		// err is treated as normal ack
		// rty is ignored (thus retrying cycle)
		while(~ (ack || err))	@(posedge clk);

		// negate wishbone signals
		#1;
		cyc  = 1'b0;
		stb  = 1'bx;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'hx;
		sel  = {dwidth/8{1'bx}};
		d    = din;

	end
	endtask

	////////////////////////////
	//
	// Wishbone compare cycle
	// read data from location and compare with expected data
	//

	task wb_cmp;
		input   delay;
		integer delay;
		input   stb_delay;
		integer stb_delay;

		input [awidth -1:0]	a;
		input	[dwidth -1:0]	d_exp;

	begin
		wb_read (delay, stb_delay, a, q);

		if (d_exp !== q)
			begin
				err_tot_cnt = err_tot_cnt +1;
				err_cur_cnt = err_cur_cnt +1;
				$display("Data compare error(%d) at time %t. Received %h, expected %h at address %h", err_tot_cnt, $time, q, d_exp, a);
			end

		if (err_tot_cnt > err_watchdog)
			begin
				$display("\nTestbench stopped. More than %d errors detected.\n", err_watchdog);
				$stop;
			end
	end
	endtask


	////////////////////////////
	//
	// Error counter handlers
	//
	task set_cur_err_cnt;
		input value;
	begin
		err_cur_cnt = value;
	end
	endtask

	task show_cur_err_cnt;
		$display("\nCurrent errors detected: %d\n", err_cur_cnt);
	endtask

	task show_tot_err_cnt;
		$display("\nTotal errors detected: %d\n", err_tot_cnt);
	endtask

endmodule

