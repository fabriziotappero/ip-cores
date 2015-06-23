////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Level Test Bench DEMO                          ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_funct/////
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

`include "usb1_defines.v"

module test;

///////////////////////////////////////////////////////////////////
//
// Local IOs and Vars
//

reg		clk;
reg		clk2;
reg		rst;

integer		error_cnt;
reg	[7:0]	txmem[0:2048];
reg	[7:0]	buffer1[0:16384];
reg	[7:0]	buffer0[0:16384];
integer		buffer1_last;
reg	[31:0]	wd_cnt;
reg		setup_pid;
integer		pack_sz, pack_sz_max;
wire		tx_dp, tx_dn, tx_oe;
wire		rx_d, rx_dp, rx_dn;
reg		tb_tx_valid;
wire		tb_tx_ready;
reg	[7:0]	tb_txdata;
wire		tb_rx_valid, tb_rx_active, tb_rx_error;
wire	[7:0]	tb_rxdata;

wire	[7:0]	ep1_us_din;
wire		ep1_us_re, ep1_us_empty;
wire	[7:0]	ep3_us_din;
wire		ep3_us_re, ep3_us_empty;
wire	[7:0]	ep5_us_din;
wire		ep5_us_re, ep4_us_empty;

wire	[7:0]	ep2_us_dout;
wire		ep2_us_we, ep2_us_full;
wire	[7:0]	ep4_us_dout;
wire		ep4_us_we, ep4_us_full;


reg	[7:0]	ep1_f_din;
reg		ep1_f_we;
wire		ep1_f_full;
wire	[7:0]	ep2_f_dout;
reg		ep2_f_re;
wire		ep2_f_empty;
reg	[7:0]	ep3_f_din;
reg		ep3_f_we;
wire		ep3_f_full;
wire	[7:0]	ep4_f_dout;
reg		ep4_f_re;
wire		ep4_f_empty;
reg	[7:0]	ep5_f_din;
reg		ep5_f_we;
wire		ep5_f_full;

reg	[7:0]	ep0_max_size;
reg	[7:0]	ep1_max_size;
reg	[7:0]	ep2_max_size;
reg	[7:0]	ep3_max_size;
reg	[7:0]	ep4_max_size;
reg	[7:0]	ep5_max_size;
reg	[7:0]	ep6_max_size;
reg	[7:0]	ep7_max_size;

wire		rx_dp1;
wire		rx_dn1;
wire		tx_dp1;
wire		tx_dn1;
wire		rx_dp2;
wire		rx_dn2;
wire		tx_dp2;
wire		tx_dn2;

reg		usb_reset;
integer		n;
reg	[31:0]	data;

///////////////////////////////////////////////////////////////////
//
// Test Definitions
//

///////////////////////////////////////////////////////////////////
//
// Initial Startup and Simulation Begin
//


initial
   begin
	usb_reset = 0;
	$timeformat (-9, 1, " ns", 12);

`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	tb_tx_valid = 0;
	error_cnt = 0;
	wd_cnt = 0;
   	clk = 0;
   	clk2 = 0;
   	rst = 0;
	ep1_f_we=0;
	ep2_f_re=0;
	ep3_f_we=0;
	ep4_f_re=0;
	ep5_f_we=0;

   	repeat(10)	@(posedge clk);
   	rst = 1;
   	repeat(50)	@(posedge clk);
	usb_reset = 1;
   	repeat(300)	@(posedge clk);
	usb_reset = 0;
   	repeat(10)	@(posedge clk);

	if(1)
	   begin
		setup1;
		in0;
		out0;
	   end
	else
	if(1)
	   begin
		setup1;
	   end

   	repeat(500)	@(posedge clk);
   	$finish;
   end

///////////////////////////////////////////////////////////////////
//
// Watchdog Timer
//
always @(posedge clk)
	if(tx_dp1 | tx_dp2)		wd_cnt <= #1 0;
	else				wd_cnt <= #1 wd_cnt + 1;

always @(wd_cnt)
	if(wd_cnt>5000)
	   begin
		$display("\n\n*************************************\n");
		$display("ERROR: Watch Dog Counter Expired\n");
		$display("*************************************\n\n\n");
		$finish;
	   end

///////////////////////////////////////////////////////////////////
//
// Clock generation
//

always #10.42 clk = ~clk;
always #10.42 clk2 = ~clk2;

///////////////////////////////////////////////////////////////////
//
// Module Instantiations
//
	
usb_phy tb_phy(.clk(			clk			),
		.rst(			rst			),

		.phy_tx_mode(		1'b1			),
		.usb_rst(					),

		.rxd(			rx_dp1			),
		.rxdp(			rx_dp1			),
		.rxdn(			rx_dn1			),

		.txdp(			tx_dp1			),
		.txdn(			tx_dn1			),
		.txoe(						),

		.DataIn_o(		tb_rxdata		),
		.RxValid_o(		tb_rx_valid		),
		.RxActive_o(		tb_rx_active		),
		.RxError_o(		tb_rx_error		),

		.DataOut_i(		tb_txdata		),
		.TxValid_i(		tb_tx_valid		),
		.TxReady_o(		tb_tx_ready		),
		.LineState_o(					)
		);

parameter	LD = 40;

assign #(LD) rx_dp1 = !usb_reset & tx_dp2;
assign #(LD) rx_dn1 = !usb_reset & tx_dn2;

assign #(LD) rx_dp2 = !usb_reset & tx_dp1;
assign #(LD) rx_dn2 = !usb_reset & tx_dn1;

usb1_core u0(	.clk_i(			clk2			),
		.rst_i(			rst			),

		// USB Misc
		.phy_tx_mode(		1'b1			),
		.usb_rst(					),
		// USB Status
		.usb_busy(					),
		.ep_sel(					),

		// Interrupts
		.dropped_frame(					),
		.misaligned_frame(				),
		.crc16_err(					),

		// Vendor Features
		.v_set_int(					),
		.v_set_feature(					),
		.wValue(					),
		.wIndex(					),
		.vendor_data(					),

		// USB PHY Interface
		.tx_dp(			tx_dp2			),
		.tx_dn(			tx_dn2			),
		.tx_oe(						),

		.rx_d(			rx_dp2			),
		.rx_dp(			rx_dp2			),
		.rx_dn(			rx_dn2			),

		// End point 1 configuration
		.ep1_cfg(	`ISO  | `IN  | 14'd0256		),
		// End point 1 'OUT' FIFO i/f
		.ep1_dout(					),
		.ep1_we(					),
		.ep1_full(		1'b0			),
		// End point 1 'IN' FIFO i/f
		.ep1_din(		ep1_us_din		),
		.ep1_re(		ep1_us_re		),
		.ep1_empty(		ep1_us_empty		),
		.ep1_bf_en(		1'b0			),
		.ep1_bf_size(		7'h0			),

		// End point 2 configuration
		.ep2_cfg(	`ISO  | `OUT | 14'd0256		),
		// End point 2 'OUT' FIFO i/f
		.ep2_dout(		ep2_us_dout		),
		.ep2_we(		ep2_us_we		),
		.ep2_full(		ep2_us_full		),
		// End point 2 'IN' FIFO i/f
		.ep2_din(		8'h0			),
		.ep2_re(					),
		.ep2_empty(		1'b0			),
		.ep2_bf_en(		1'b0			),
		.ep2_bf_size(		7'h0			),

		// End point 3 configuration
		.ep3_cfg(	`BULK | `IN  | 14'd064		),
		// End point 3 'OUT' FIFO i/f
		.ep3_dout(					),
		.ep3_we(					),
		.ep3_full(		1'b0			),
		// End point 3 'IN' FIFO i/f
		.ep3_din(		ep3_us_din		),
		.ep3_re(		ep3_us_re		),
		.ep3_empty(		ep3_us_empty		),
		.ep3_bf_en(		1'b0			),
		.ep3_bf_size(		7'h0			),

		// End point 4 configuration
		.ep4_cfg(	`BULK | `OUT | 14'd064		),
		// End point 4 'OUT' FIFO i/f
		.ep4_dout(		ep4_us_dout		),
		.ep4_we(		ep4_us_we		),
		.ep4_full(		ep4_us_full		),
		// End point 4 'IN' FIFO i/f
		.ep4_din(		8'h0			),
		.ep4_re(					),
		.ep4_empty(		1'b0			),
		.ep4_bf_en(		1'b0			),
		.ep4_bf_size(		7'h0			),

		// End point 5 configuration
		.ep5_cfg(	`INT  | `IN  | 14'd064		),
		// End point 5 'OUT' FIFO i/f
		.ep5_dout(					),
		.ep5_we(					),
		.ep5_full(		1'b0			),
		// End point 5 'IN' FIFO i/f
		.ep5_din(		ep5_us_din		),
		.ep5_re(		ep5_us_re		),
		.ep5_empty(		ep5_us_empty		),
		.ep5_bf_en(		1'b0			),
		.ep5_bf_size(		7'h0			),

		// End point 6 configuration
		.ep6_cfg(		14'h00			),
		// End point 6 'OUT' FIFO i/f
		.ep6_dout(					),
		.ep6_we(					),
		.ep6_full(		1'b0			),
		// End point 6 'IN' FIFO i/f
		.ep6_din(		8'h0			),
		.ep6_re(					),
		.ep6_empty(		1'b0			),
		.ep6_bf_en(		1'b0			),
		.ep6_bf_size(		7'h0			),

		// End point 7 configuration
		.ep7_cfg(		14'h00			),
		// End point 7 'OUT' FIFO i/f
		.ep7_dout(					),
		.ep7_we(					),
		.ep7_full(		1'b0			),
		// End point 7 'IN' FIFO i/f
		.ep7_din(		8'h0			),
		.ep7_re(					),
		.ep7_empty(		1'b0			),
		.ep7_bf_en(		1'b0			),
		.ep7_bf_size(		7'h0			)
		); 	

// EP 1 FIFO
generic_fifo_sc_a #(8,9,0)
	f0(
	.clk(		clk2		),
	.rst(		rst		),
	.clr(		1'b0		),
	.din(		ep1_f_din	),
	.we(		ep1_f_we	),
	.dout(		ep1_us_din	),
	.re(		ep1_us_re	),
	.full(				),
	.empty(				),
	.full_r(	ep1_f_full	),
	.empty_r(	ep1_us_empty	),
	.full_n(			),
	.empty_n(			),
	.full_n_r(			),
	.empty_n_r(			),
	.level(				)
	);

// EP 2 FIFO
generic_fifo_sc_a #(8,9,0)
	f1(
	.clk(		clk2		),
	.rst(		rst		),
	.clr(		1'b0		),
	.din(		ep2_us_dout	),
	.we(		ep2_us_we	),
	.dout(		ep2_f_dout	),
	.re(		ep2_f_re	),
	.full(				),
	.empty(				),
	.full_r(	ep2_us_full	),
	.empty_r(	ep2_f_empty	),
	.full_n(			),
	.empty_n(			),
	.full_n_r(			),
	.empty_n_r(			),
	.level(				)
	);

// EP 3 FIFO
generic_fifo_sc_a #(8,9,0)
	f2(
	.clk(		clk2		),
	.rst(		rst		),
	.clr(		1'b0		),
	.din(		ep3_f_din	),
	.we(		ep3_f_we	),
	.dout(		ep3_us_din	),
	.re(		ep3_us_re	),
	.full(				),
	.empty(				),
	.full_r(	ep3_f_full	),
	.empty_r(	ep3_us_empty	),
	.full_n(			),
	.empty_n(			),
	.full_n_r(			),
	.empty_n_r(			),
	.level(				)
	);

// EP 4 FIFO
generic_fifo_sc_a #(8,9,0)
	f3(
	.clk(		clk2		),
	.rst(		rst		),
	.clr(		1'b0		),
	.din(		ep4_us_dout	),
	.we(		ep4_us_we	),
	.dout(		ep4_f_dout	),
	.re(		ep4_f_re	),
	.full(				),
	.empty(				),
	.full_r(	ep4_us_full	),
	.empty_r(	ep4_f_empty	),
	.full_n(			),
	.empty_n(			),
	.full_n_r(			),
	.empty_n_r(			),
	.level(				)
	);

// EP 5 FIFO
generic_fifo_sc_a #(8,6,0)
	f4(
	.clk(		clk2		),
	.rst(		rst		),
	.clr(		1'b0		),
	.din(		ep5_f_din	),
	.we(		ep5_f_we	),
	.dout(		ep5_us_din	),
	.re(		ep5_us_re	),
	.full(				),
	.empty(				),
	.full_r(	ep5_f_full	),
	.empty_r(	ep5_us_empty	),
	.full_n(			),
	.empty_n(			),
	.full_n_r(			),
	.empty_n_r(			),
	.level(				)
	);

///////////////////////////////////////////////////////////////////
//
// Test and test lib Includes
//
`include "tests_lib.v"
`include "tests.v"

endmodule

