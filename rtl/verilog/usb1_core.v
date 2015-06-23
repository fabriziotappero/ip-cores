/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 function IP core                                   ////
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

//  CVS Log
//
//  $Id: usb1_core.v,v 1.2 2002-10-11 05:48:20 rudi Exp $
//
//  $Date: 2002-10-11 05:48:20 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2002/09/25 06:06:49  rudi
//               - Added New Top Level
//               - Remove old top level and associated files
//               - Moved FIFOs to "Generic FIFOs" project
//
//
//
//
//
//
//

`include "usb1_defines.v"

/*

		// USB PHY Interface
		tx_dp, tx_dn, tx_oe,
		rx_d, rx_dp, rx_dn,
These pins are a semi-standard interface to USB 1.1 transceivers.
Just match up the signal names with the IOs of the transceiver.

		// USB Misc
		phy_tx_mode, usb_rst, 
The PHY supports single ended and differential output to the
transceiver Depending on which device you are using, you have
to tie the phy_tx_mode high or low.
usb_rst is asserted whenever the host signals reset on the USB
bus. The USB core will internally reset itself automatically.
This output is provided for external logic that needs to be
reset when the USB bus is reset.

		// Interrupts
		dropped_frame, misaligned_frame,
		crc16_err,
dropped_frame, misaligned_frame are interrupt to indicate error
conditions in Block Frame mode.
crc16_err, indicates when a crc 16 error was detected on the
payload of a USB packet.

		// Vendor Features
		v_set_int, v_set_feature, wValue,
		wIndex, vendor_data,
This signals allow to control vendor specific registers and logic
that can be manipulated and monitored via the control endpoint
through vendor defined commands.

		// USB Status
		usb_busy, ep_sel,
usb_busy is asserted when the USB core is busy transferring
data ep_sel indicated the endpoint that is currently busy.
This information might be useful if one desires to reset/clear
the attached FIFOs and want to do this when the endpoint is idle.

		// Endpoint Interface
This implementation supports 8 endpoints. Endpoint 0 is the
control endpoint and used internally. Endpoints 1-7 are available
to the user. replace 'N' with the endpoint number.

		epN_cfg,
This is a constant input used to configure the endpoint by ORing
these defines together and adding the max packet size for this
endpoint:
`IN and `OUT select the transfer direction for this endpoint
`ISO, `BULK and `INT determine the endpoint type

Example: "`BULK | `IN  | 14'd064" defines a BULK IN endpoint with
max packet size of 64 bytes

		epN_din,  epN_we, epN_full,
This is the OUT FIFO interface. If this is a IN endpoint, ground
all unused inputs and leave outputs unconnected.

		epN_dout, epN_re, epN_empty,
this is the IN FIFO interface. If this is a OUT endpoint ground
all unused inputs and leave outputs unconnected.

		epN_bf_en, epN_bf_size,
These two constant configure the Block Frame feature.

*/


module usb1_core(clk_i, rst_i,

		// USB PHY Interface
		tx_dp, tx_dn, tx_oe,
		rx_d, rx_dp, rx_dn,

		// USB Misc
		phy_tx_mode, usb_rst, 

		// Interrupts
		dropped_frame, misaligned_frame,
		crc16_err,

		// Vendor Features
		v_set_int, v_set_feature, wValue,
		wIndex, vendor_data,

		// USB Status
		usb_busy, ep_sel,

		// Endpoint Interface
		ep1_cfg,
		ep1_din,  ep1_we, ep1_full,
		ep1_dout, ep1_re, ep1_empty,
		ep1_bf_en, ep1_bf_size,

		ep2_cfg,
		ep2_din,  ep2_we, ep2_full,
		ep2_dout, ep2_re, ep2_empty,
		ep2_bf_en, ep2_bf_size,

		ep3_cfg,
		ep3_din,  ep3_we, ep3_full,
		ep3_dout, ep3_re, ep3_empty,
		ep3_bf_en, ep3_bf_size,

		ep4_cfg,
		ep4_din,  ep4_we, ep4_full,
		ep4_dout, ep4_re, ep4_empty,
		ep4_bf_en, ep4_bf_size,

		ep5_cfg,
		ep5_din,  ep5_we, ep5_full,
		ep5_dout, ep5_re, ep5_empty,
		ep5_bf_en, ep5_bf_size,

		ep6_cfg,
		ep6_din,  ep6_we, ep6_full,
		ep6_dout, ep6_re, ep6_empty,
		ep6_bf_en, ep6_bf_size,

		ep7_cfg,
		ep7_din,  ep7_we, ep7_full,
		ep7_dout, ep7_re, ep7_empty,
		ep7_bf_en, ep7_bf_size

		); 		

input		clk_i;
input		rst_i;

output		tx_dp, tx_dn, tx_oe;
input		rx_d, rx_dp, rx_dn;

input		phy_tx_mode;
output		usb_rst;
output		dropped_frame, misaligned_frame;
output		crc16_err;

output		v_set_int;
output		v_set_feature;
output	[15:0]	wValue;
output	[15:0]	wIndex;
input	[15:0]	vendor_data;

output		usb_busy;
output	[3:0]	ep_sel;

// Endpoint Interfaces
input	[13:0]	ep1_cfg;
input	[7:0]	ep1_din;
output	[7:0]	ep1_dout;
output		ep1_we, ep1_re;
input		ep1_empty, ep1_full;
input		ep1_bf_en;
input	[6:0]	ep1_bf_size;

input	[13:0]	ep2_cfg;
input	[7:0]	ep2_din;
output	[7:0]	ep2_dout;
output		ep2_we, ep2_re;
input		ep2_empty, ep2_full;
input		ep2_bf_en;
input	[6:0]	ep2_bf_size;

input	[13:0]	ep3_cfg;
input	[7:0]	ep3_din;
output	[7:0]	ep3_dout;
output		ep3_we, ep3_re;
input		ep3_empty, ep3_full;
input		ep3_bf_en;
input	[6:0]	ep3_bf_size;

input	[13:0]	ep4_cfg;
input	[7:0]	ep4_din;
output	[7:0]	ep4_dout;
output		ep4_we, ep4_re;
input		ep4_empty, ep4_full;
input		ep4_bf_en;
input	[6:0]	ep4_bf_size;

input	[13:0]	ep5_cfg;
input	[7:0]	ep5_din;
output	[7:0]	ep5_dout;
output		ep5_we, ep5_re;
input		ep5_empty, ep5_full;
input		ep5_bf_en;
input	[6:0]	ep5_bf_size;

input	[13:0]	ep6_cfg;
input	[7:0]	ep6_din;
output	[7:0]	ep6_dout;
output		ep6_we, ep6_re;
input		ep6_empty, ep6_full;
input		ep6_bf_en;
input	[6:0]	ep6_bf_size;

input	[13:0]	ep7_cfg;
input	[7:0]	ep7_din;
output	[7:0]	ep7_dout;
output		ep7_we, ep7_re;
input		ep7_empty, ep7_full;
input		ep7_bf_en;
input	[6:0]	ep7_bf_size;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

// UTMI Interface
wire	[7:0]	DataOut;
wire		TxValid;
wire		TxReady;
wire	[7:0]	DataIn;
wire		RxValid;
wire		RxActive;
wire		RxError;
wire	[1:0]	LineState;

wire	[7:0]	rx_data;
wire		rx_valid, rx_active, rx_err;
wire	[7:0]	tx_data;
wire		tx_valid;
wire		tx_ready;
wire		tx_first;
wire		tx_valid_last;

// Internal Register File Interface
wire	[6:0]	funct_adr;	// This functions address (set by controller)
wire	[3:0]	ep_sel;		// Endpoint Number Input
wire		crc16_err;	// Set CRC16 error interrupt
wire		int_to_set;	// Set time out interrupt
wire		int_seqerr_set;	// Set PID sequence error interrupt
wire	[31:0]	frm_nat;	// Frame Number and Time Register
wire		nse_err;	// No Such Endpoint Error
wire		pid_cs_err;	// PID CS error
wire		crc5_err;	// CRC5 Error

reg	[7:0]	tx_data_st;
wire	[7:0]	rx_data_st;
reg	[13:0]	cfg;
reg		ep_empty;
reg		ep_full;
wire	[7:0]	rx_size;
wire		rx_done;

wire	[7:0]	ep0_din;
wire	[7:0]	ep0_dout;
wire		ep0_re, ep0_we;
wire	[13:0]	ep0_cfg;
wire	[7:0]	ep0_size;
wire	[7:0]	ep0_ctrl_dout, ep0_ctrl_din;
wire		ep0_ctrl_re, ep0_ctrl_we;
wire	[3:0]	ep0_ctrl_stat;

wire		ctrl_setup, ctrl_in, ctrl_out;
wire		send_stall;
wire		token_valid;
reg		rst_local;		// internal reset
wire		dropped_frame;
wire		misaligned_frame;
wire		v_set_int;
wire		v_set_feature;
wire	[15:0]	wValue;
wire	[15:0]	wIndex;

reg		ep_bf_en;
reg	[6:0]	ep_bf_size;
wire	[6:0]	rom_adr;
wire	[7:0]	rom_data;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

// Endpoint type and Max transfer size
assign ep0_cfg = `CTRL | ep0_size;

always @(posedge clk_i)
	rst_local <= #1 rst_i & ~usb_rst;

///////////////////////////////////////////////////////////////////
//
// Module Instantiations
//

usb_phy phy(
		.clk(			clk_i			),
		.rst(			rst_i			),	// ONLY external reset
		.phy_tx_mode(		phy_tx_mode		),
		.usb_rst(		usb_rst			),

		// Transceiver Interface
		.rxd(			rx_d			),
		.rxdp(			rx_dp			),
		.rxdn(			rx_dn			),
		.txdp(			tx_dp			),
		.txdn(			tx_dn			),
		.txoe(			tx_oe			),

		// UTMI Interface
		.DataIn_o(		DataIn			),
		.RxValid_o(		RxValid			),
		.RxActive_o(		RxActive		),
		.RxError_o(		RxError			),
		.DataOut_i(		DataOut			),
		.TxValid_i(		TxValid			),
		.TxReady_o(		TxReady			),
		.LineState_o(		LineState		)
		);

// UTMI Interface
usb1_utmi_if	u0(
		.phy_clk(		clk_i			),
		.rst(			rst_local		),
		.DataOut(		DataOut			),
		.TxValid(		TxValid			),
		.TxReady(		TxReady			),
		.RxValid(		RxValid			),
		.RxActive(		RxActive		),
		.RxError(		RxError			),
		.DataIn(		DataIn			),
		.rx_data(		rx_data			),
		.rx_valid(		rx_valid		),
		.rx_active(		rx_active		),
		.rx_err(		rx_err			),
		.tx_data(		tx_data			),
		.tx_valid(		tx_valid		),
		.tx_valid_last(		tx_valid_last		),
		.tx_ready(		tx_ready		),
		.tx_first(		tx_first		)
		);

// Protocol Layer
usb1_pl  u1(	.clk(			clk_i			),
		.rst(			rst_local		),
		.rx_data(		rx_data			),
		.rx_valid(		rx_valid		),
		.rx_active(		rx_active		),
		.rx_err(		rx_err			),
		.tx_data(		tx_data			),
		.tx_valid(		tx_valid		),
		.tx_valid_last(		tx_valid_last		),
		.tx_ready(		tx_ready		),
		.tx_first(		tx_first		),
		.tx_valid_out(		TxValid			),
		.token_valid(		token_valid		),
		.fa(			funct_adr		),
		.ep_sel(		ep_sel			),
		.x_busy(		usb_busy		),
		.int_crc16_set(		crc16_err		),
		.int_to_set(		int_to_set		),
		.int_seqerr_set(	int_seqerr_set		),
		.frm_nat(		frm_nat			),
		.pid_cs_err(		pid_cs_err		),
		.nse_err(		nse_err			),
		.crc5_err(		crc5_err		),
		.rx_size(		rx_size			),
		.rx_done(		rx_done			),
		.ctrl_setup(		ctrl_setup		),
		.ctrl_in(		ctrl_in			),
		.ctrl_out(		ctrl_out		),
		.ep_bf_en(		ep_bf_en		),
		.ep_bf_size(		ep_bf_size		),
		.dropped_frame(		dropped_frame		),
		.misaligned_frame(	misaligned_frame	),
		.csr(			cfg			),
		.tx_data_st(		tx_data_st		),
		.rx_data_st(		rx_data_st		),
		.idma_re(		idma_re			),
		.idma_we(		idma_we			),
		.ep_empty(		ep_empty		),
		.ep_full(		ep_full			),
		.send_stall(		send_stall		)
		);

usb1_ctrl  u4(	.clk(			clk_i			),
		.rst(			rst_local		),

		.rom_adr(		rom_adr			),
		.rom_data(		rom_data		),

		.ctrl_setup(		ctrl_setup		),
		.ctrl_in(		ctrl_in			),
		.ctrl_out(		ctrl_out		),

		.ep0_din(		ep0_ctrl_dout		),
		.ep0_dout(		ep0_ctrl_din		),
		.ep0_re(		ep0_ctrl_re		),
		.ep0_we(		ep0_ctrl_we		),
		.ep0_stat(		ep0_ctrl_stat		),
		.ep0_size(		ep0_size		),

		.send_stall(		send_stall		),
		.frame_no(		frm_nat[26:16]		),
		.funct_adr(		funct_adr 		),
		.configured(					),
		.halt(						),

		.v_set_int(		v_set_int		),
		.v_set_feature(		v_set_feature		),
		.wValue(		wValue			),
		.wIndex(		wIndex			),
		.vendor_data(		vendor_data		)
		);


usb1_rom1 rom1(	.clk(		clk_i		),
		.adr(		rom_adr		),
		.dout(		rom_data	)
		);

// CTRL Endpoint FIFO
generic_fifo_sc_a #(8,6,0) u10(
		.clk(			clk_i			),
		.rst(			rst_i			),
		.clr(			usb_rst			),
		.din(			rx_data_st		),
		.we(			ep0_we			),
		.dout(			ep0_ctrl_dout		),
		.re(			ep0_ctrl_re		),
		.full_r(					),
		.empty_r(					),
		.full(			ep0_full		),
		.empty(			ep0_ctrl_stat[1]	),
		.full_n(					),
		.empty_n(					),
		.full_n_r(					),
		.empty_n_r(					),
		.level(						)
		);

generic_fifo_sc_a #(8,6,0) u11(
		.clk(			clk_i			),
		.rst(			rst_i			),
		.clr(			usb_rst			),
		.din(			ep0_ctrl_din		),
		.we(			ep0_ctrl_we		),
		.dout(			ep0_dout		),
		.re(			ep0_re			),
		.full_r(					),
		.empty_r(					),
		.full(			ep0_ctrl_stat[2]	),
		.empty(			ep0_empty		),
		.full_n(					),
		.empty_n(					),
		.full_n_r(					),
		.empty_n_r(					),
		.level(						)
		);

///////////////////////////////////////////////////////////////////
//
// Endpoint FIFO Interfaces
//

always @(ep_sel or ep0_cfg or ep1_cfg or ep2_cfg or ep3_cfg or
		ep4_cfg or ep5_cfg or ep6_cfg or ep7_cfg)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h0:	cfg = ep0_cfg;
	   4'h1:	cfg = ep1_cfg;
	   4'h2:	cfg = ep2_cfg;
	   4'h3:	cfg = ep3_cfg;
	   4'h4:	cfg = ep4_cfg;
	   4'h5:	cfg = ep5_cfg;
	   4'h6:	cfg = ep6_cfg;
	   4'h7:	cfg = ep7_cfg;
	endcase

// In endpoints only
always @(posedge clk_i)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h0:	tx_data_st <= #1 ep0_dout;
	   4'h1:	tx_data_st <= #1 ep1_din;
	   4'h2:	tx_data_st <= #1 ep2_din;
	   4'h3:	tx_data_st <= #1 ep3_din;
	   4'h4:	tx_data_st <= #1 ep4_din;
	   4'h5:	tx_data_st <= #1 ep5_din;
	   4'h6:	tx_data_st <= #1 ep6_din;
	   4'h7:	tx_data_st <= #1 ep7_din;
	endcase

// In endpoints only
always @(posedge clk_i)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h0:	ep_empty <= #1 ep0_empty;
	   4'h1:	ep_empty <= #1 ep1_empty;
	   4'h2:	ep_empty <= #1 ep2_empty;
	   4'h3:	ep_empty <= #1 ep3_empty;
	   4'h4:	ep_empty <= #1 ep4_empty;
	   4'h5:	ep_empty <= #1 ep5_empty;
	   4'h6:	ep_empty <= #1 ep6_empty;
	   4'h7:	ep_empty <= #1 ep7_empty;
	endcase

// OUT endpoints only
always @(ep_sel or ep0_full or ep1_full or ep2_full or ep3_full or
		ep4_full or ep5_full or ep6_full or ep7_full)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h0:	ep_full = ep0_full;
	   4'h1:	ep_full = ep1_full;
	   4'h2:	ep_full = ep2_full;
	   4'h3:	ep_full = ep3_full;
	   4'h4:	ep_full = ep4_full;
	   4'h5:	ep_full = ep5_full;
	   4'h6:	ep_full = ep6_full;
	   4'h7:	ep_full = ep7_full;
	endcase

always @(posedge clk_i)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h0:	ep_bf_en = 1'b0;
	   4'h1:	ep_bf_en = ep1_bf_en;
	   4'h2:	ep_bf_en = ep2_bf_en;
	   4'h3:	ep_bf_en = ep3_bf_en;
	   4'h4:	ep_bf_en = ep4_bf_en;
	   4'h5:	ep_bf_en = ep5_bf_en;
	   4'h6:	ep_bf_en = ep6_bf_en;
	   4'h7:	ep_bf_en = ep7_bf_en;
	endcase

always @(posedge clk_i)
	case(ep_sel)	// synopsys full_case parallel_case
	   4'h1:	ep_bf_size = ep1_bf_size;
	   4'h2:	ep_bf_size = ep2_bf_size;
	   4'h3:	ep_bf_size = ep3_bf_size;
	   4'h4:	ep_bf_size = ep4_bf_size;
	   4'h5:	ep_bf_size = ep5_bf_size;
	   4'h6:	ep_bf_size = ep6_bf_size;
	   4'h7:	ep_bf_size = ep7_bf_size;
	endcase

assign ep1_dout = rx_data_st;
assign ep2_dout = rx_data_st;
assign ep3_dout = rx_data_st;
assign ep4_dout = rx_data_st;
assign ep5_dout = rx_data_st;
assign ep6_dout = rx_data_st;
assign ep7_dout = rx_data_st;

assign ep0_re = idma_re & (ep_sel == 4'h00);
assign ep1_re = idma_re & (ep_sel == 4'h01) & !ep1_empty;
assign ep2_re = idma_re & (ep_sel == 4'h02) & !ep2_empty;
assign ep3_re = idma_re & (ep_sel == 4'h03) & !ep3_empty;
assign ep4_re = idma_re & (ep_sel == 4'h04) & !ep4_empty;
assign ep5_re = idma_re & (ep_sel == 4'h05) & !ep5_empty;
assign ep6_re = idma_re & (ep_sel == 4'h06) & !ep6_empty;
assign ep7_re = idma_re & (ep_sel == 4'h07) & !ep7_empty;

assign ep0_we = idma_we & (ep_sel == 4'h00);
assign ep1_we = idma_we & (ep_sel == 4'h01) & !ep1_full;
assign ep2_we = idma_we & (ep_sel == 4'h02) & !ep2_full;
assign ep3_we = idma_we & (ep_sel == 4'h03) & !ep3_full;
assign ep4_we = idma_we & (ep_sel == 4'h04) & !ep4_full;
assign ep5_we = idma_we & (ep_sel == 4'h05) & !ep5_full;
assign ep6_we = idma_we & (ep_sel == 4'h06) & !ep6_full;
assign ep7_we = idma_we & (ep_sel == 4'h07) & !ep7_full;

endmodule

