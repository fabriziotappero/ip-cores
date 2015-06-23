////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Level Test Bench - OCP Interface               ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////  Modifications: Alfredo Luiz Foltran Fialho                 ////
////                 alfoltran@opencores.org                     ////
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

`include "timescale.v"
`include "usb_defines.v"
`include "usb_ocp.v"

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

reg	[7:0]	ep_f_din;
wire	[7:0]	ep_f_dout;
reg	[2:0]	cmd;

reg	[31:0]	ep_f_addr;

reg	[7:0]	ep0_max_size;
reg	[7:0]	ep1_max_size;
reg	[7:0]	ep2_max_size;
reg	[7:0]	ep3_max_size;
reg	[7:0]	ep4_max_size;
reg	[7:0]	ep5_max_size;
reg	[7:0]	ep6_max_size;
reg	[7:0]	ep7_max_size;

wire	[7:0]	flags;

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
	cmd=3'b100;
	ep_f_addr=32'h00;

   	repeat(10)	@(posedge clk);
   	rst = 1;
   	repeat(50)	@(posedge clk);
	usb_reset = 1;
   	repeat(300)	@(posedge clk);
	usb_reset = 0;
   	repeat(10)	@(posedge clk);

	if(1)
	   begin
		setup0;
		in1;
		out2;
		in3;
		out4;
		in5;
		out6;
	   end
	else
	if(1)
	   begin
		setup0;
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

usb_ocp u0(	.Clk(			clk2			),
		.Reset_n(			rst			),

		// USB Status
		.SFlag(	flags),
		.SError(					),

		// Interrupts
		.SInterrupt(					),

		// USB PHY Interface
		.tx_dp(			tx_dp2			),
		.tx_dn(			tx_dn2			),
		.tx_oe(						),
		.rx_d(			rx_dp2			),
		.rx_dp(			rx_dp2			),
		.rx_dn(			rx_dn2			),

		// OCP Interface
		.MData(			ep_f_din		),
		.SData(			ep_f_dout		),
		.MCmd(		cmd		),
		.MAddr(			ep_f_addr		)
		); 	

///////////////////////////////////////////////////////////////////
//
// Test and test lib Includes
//
`include "tests_lib.v"
`include "tests_ocp.v"

endmodule

