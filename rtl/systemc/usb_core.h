/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1                                                    ////
////  Function IP Core                                           ////
////                                                             ////
////  SystemC Version: usb_core.h                                ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_core.v                                ////
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

#ifndef USB_CORE_H
#define USB_CORE_H

#include "usb_defines.h"

#include "usb_phy.h"
#include "usb_sie.h"
#include "usb_ep0.h"
#include "usb_rom.h"
#include "usb_fifo64x8.h"

/*
		USB PHY Interface
		tx_dp, tx_dn, tx_oe,
		rx_d, rx_dp, rx_dn,
These pins are a semi-standard interface to USB 1.1 transceivers.
Just match up the signal names with the IOs of the transceiver.

		USB Misc
		phy_tx_mode, usb_rst, 
The PHY supports single ended and differential output to the
transceiver. Depending on which device you are using, you have
to tie the phy_tx_mode high or low.
usb_rst is asserted whenever the host signals reset on the USB
bus. The USB core will internally reset itself automatically.
This output is provided for external logic that needs to be
reset when the USB bus is reset.

		Interrupts
		crc16_err,
crc16_err, indicates when a crc 16 error was detected on the
payload of a USB packet.

		Vendor Features
		v_set_int, v_set_feature, wValue,
		wIndex, vendor_data,
This signals allow to control vendor specific registers and logic
that can be manipulated and monitored via the control endpoint
through vendor defined commands.

		USB Status
		usb_busy, ep_sel,
usb_busy is asserted when the USB core is busy transferring
data ep_sel indicated the endpoint that is currently busy.
This information might be useful if one desires to reset/clear
the attached FIFOs and want to do this when the endpoint is idle.

		Endpoint Interface
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

*/

SC_MODULE(usb_core) {

  public:

	sc_in<bool>			clk_i;
	sc_in<bool>			rst_i;

	// PHY Interface
	sc_out<bool>		tx_dp, tx_dn, tx_oe;
	sc_in<bool>			rx_dp, rx_dn, rx_d;
	sc_in<bool>			phy_tx_mode;

	// Misc
	sc_out<bool>		usb_rst;

	// Interrupts
	sc_out<bool>		crc16_err;

	// Vendor Features
	sc_out<bool>		v_set_int;
	sc_out<bool>		v_set_feature;
	sc_out<sc_uint<16> >wValue;
	sc_out<sc_uint<16> >wIndex;
	sc_in<sc_uint<16> >	vendor_data;

	// USB Status
	sc_out<bool>		usb_busy;
	sc_out<sc_uint<4> >	ep_sel;

	// Endpoint Interface
	// EP1
	sc_in<sc_uint<14> >	ep1_cfg;
	sc_in<sc_uint<8> >	ep1_din;
	sc_out<sc_uint<8> >	ep1_dout;
	sc_out<bool>		ep1_we, ep1_re;
	sc_in<bool>			ep1_empty, ep1_full;

	// EP2
	sc_in<sc_uint<14> >	ep2_cfg;
	sc_in<sc_uint<8> >	ep2_din;
	sc_out<sc_uint<8> >	ep2_dout;
	sc_out<bool>		ep2_we, ep2_re;
	sc_in<bool>			ep2_empty, ep2_full;

	// EP3
	sc_in<sc_uint<14> >	ep3_cfg;
	sc_in<sc_uint<8> >	ep3_din;
	sc_out<sc_uint<8> >	ep3_dout;
	sc_out<bool>		ep3_we, ep3_re;
	sc_in<bool>			ep3_empty, ep3_full;

	// EP4
	sc_in<sc_uint<14> >	ep4_cfg;
	sc_in<sc_uint<8> >	ep4_din;
	sc_out<sc_uint<8> >	ep4_dout;
	sc_out<bool>		ep4_we, ep4_re;
	sc_in<bool>			ep4_empty, ep4_full;

	// EP5
	sc_in<sc_uint<14> >	ep5_cfg;
	sc_in<sc_uint<8> >	ep5_din;
	sc_out<sc_uint<8> >	ep5_dout;
	sc_out<bool>		ep5_we, ep5_re;
	sc_in<bool>			ep5_empty, ep5_full;

	// EP6
	sc_in<sc_uint<14> >	ep6_cfg;
	sc_in<sc_uint<8> >	ep6_din;
	sc_out<sc_uint<8> >	ep6_dout;
	sc_out<bool>		ep6_we, ep6_re;
	sc_in<bool>			ep6_empty, ep6_full;

	// EP7
	sc_in<sc_uint<14> >	ep7_cfg;
	sc_in<sc_uint<8> >	ep7_din;
	sc_out<sc_uint<8> >	ep7_dout;
	sc_out<bool>		ep7_we, ep7_re;
	sc_in<bool>			ep7_empty, ep7_full;

	// Local Signals

	// SIE Interface
	sc_signal<sc_uint<8> >	DataOut;
	sc_signal<bool>			TxValid;
	sc_signal<bool>			TxReady;
	sc_signal<sc_uint<8> >	DataIn;
	sc_signal<bool>			RxValid;
	sc_signal<bool>			RxActive;
	sc_signal<bool>			RxError;
	sc_signal<sc_uint<2> >	LineState;

	// Internal Register File Interface
	sc_signal<sc_uint<7> >	funct_adr;			// This function address (set by Controller)
	sc_signal<bool>			int_to_set;			// Set time out interrupt
	sc_signal<bool>			int_seqerr_set;		// Set PID sequence error interrupt
	sc_signal<sc_uint<32> >	frm_nat;			// Frame number and time register
	sc_signal<bool>			nse_err;			// No such endpoint error
	sc_signal<bool>			pid_cs_err;			// PID CS error
	sc_signal<bool>			crc5_err;			// CRC5 error

	// Status Signals
	sc_signal<sc_uint<11> >	frame_no;
	sc_signal<bool>			addressed;
	sc_signal<bool>			configured;
	sc_signal<bool>			halt;

	// Data and Control Signals
	sc_signal<sc_uint<8> >	tx_data_st;
	sc_signal<sc_uint<8> >	rx_data_st;
	sc_signal<sc_uint<14> >	cfg;
	sc_signal<bool>			ep_empty;
	sc_signal<bool>			ep_full;
	sc_signal<sc_uint<8> >	rx_size;
	sc_signal<bool>			rx_done;

	// EP0 Signals
	sc_signal<sc_uint<8> >	ep0_din;
	sc_signal<sc_uint<8> >	ep0_dout;
	sc_signal<bool>			ep0_re, ep0_we;
	sc_signal<sc_uint<8> >	ep0_size;
	sc_signal<sc_uint<8> >	ep0_ctrl_dout, ep0_ctrl_din;
	sc_signal<bool>			ep0_ctrl_re, ep0_ctrl_we;
	sc_signal<sc_uint<4> >	ep0_ctrl_stat;

	// Control Pipe Interface
	sc_signal<bool>			ctrl_setup, ctrl_in, ctrl_out;
	sc_signal<bool>			send_stall;
	sc_signal<bool>			token_valid;
	sc_signal<bool>			rst_local;			// Internal reset

	// ROM Signals
	sc_signal<sc_uint<8> >	rom_adr;
	sc_signal<sc_uint<8> >	rom_data;

	// FIFO Signals
	sc_signal<bool>			idma_re, idma_we;
	sc_signal<bool>			ep0_empty, ep0_full;

	sc_signal<bool>			stat1, stat2;

	usb_phy					*i_phy;				// PHY
	usb_sie					*i_sie;				// SIE
	usb_ep0					*i_ep0;				// EP0
	usb_rom					*i_rom;				// ROM
	usb_fifo64x8			*i_ff_in;			// FIFO_IN
	usb_fifo64x8			*i_ff_out;			// FIFO_OUT

	// Internal Reset Function
	void rst_local_up(void);

	// Misc Functions
	void stat_up(void);
	void frame_no_up(void);

	// Muxes Functions
	void cfg_mux(void);
	void tx_data_mux(void);
	void ep_empty_mux(void);
	void ep_full_mux(void);

	// Decos Functions
	void ep_dout_deco(void);
	void ep_re_deco(void);
	void ep_we_deco(void);

	// Destructor
//	~usb_core(void);

	SC_CTOR(usb_core) {
		SC_METHOD(rst_local_up);
		sensitive << clk_i.pos();

		SC_METHOD(stat_up);
		sensitive << stat1 << stat2;
		SC_METHOD(frame_no_up);
		sensitive << frm_nat;

		SC_METHOD(cfg_mux);
		sensitive << ep_sel << ep0_size << ep1_cfg << ep2_cfg << ep3_cfg;
		sensitive << ep4_cfg << ep5_cfg << ep6_cfg << ep7_cfg;
		SC_METHOD(tx_data_mux);
		sensitive << clk_i.pos();
		SC_METHOD(ep_empty_mux);
		sensitive << clk_i.pos();
		SC_METHOD(ep_full_mux);
		sensitive << ep_sel << ep0_full << ep1_full << ep2_full << ep3_full;
		sensitive << ep4_full << ep5_full << ep6_full << ep7_full;

		SC_METHOD(ep_dout_deco);
		sensitive << rx_data_st;
		SC_METHOD(ep_re_deco);
		sensitive << idma_re << ep_sel << ep1_empty << ep2_empty << ep3_empty;
		sensitive << ep4_empty << ep5_empty << ep6_empty << ep7_empty;
		SC_METHOD(ep_we_deco);
		sensitive << idma_we << ep_sel << ep1_full << ep2_full << ep3_full;
		sensitive << ep4_full << ep5_full << ep6_full << ep7_full;

		// PHY Instantiation and Binding
		i_phy = new usb_phy("PHY");
		i_phy->clk(clk_i);
		i_phy->rst(rst_i);				// ONLY external reset
		i_phy->phy_tx_mode(phy_tx_mode);
		i_phy->usb_rst(usb_rst);
		i_phy->txdp(tx_dp);
		i_phy->txdn(tx_dn);
		i_phy->txoe(tx_oe);
		i_phy->rxd(rx_d);
		i_phy->rxdp(rx_dp);
		i_phy->rxdn(rx_dn);
		i_phy->DataOut_i(DataOut);
		i_phy->TxValid_i(TxValid);
		i_phy->TxReady_o(TxReady);
		i_phy->DataIn_o(DataIn);
		i_phy->RxValid_o(RxValid);
		i_phy->RxActive_o(RxActive);
		i_phy->RxError_o(RxError);
		i_phy->LineState_o(LineState);

		// SIE Instantiation and Binding
		i_sie = new usb_sie("SIE");
		i_sie->clk(clk_i);
		i_sie->rst(rst_local);
		i_sie->DataOut(DataOut);
		i_sie->TxValid(TxValid);
		i_sie->TxReady(TxReady);
		i_sie->DataIn(DataIn);
		i_sie->RxValid(RxValid);
		i_sie->RxActive(RxActive);
		i_sie->RxError(RxError);
		i_sie->token_valid(token_valid);
		i_sie->fa(funct_adr);
		i_sie->ep_sel(ep_sel);
		i_sie->x_busy(usb_busy);
		i_sie->int_crc16_set(crc16_err);
		i_sie->int_to_set(int_to_set);
		i_sie->int_seqerr_set(int_seqerr_set);
		i_sie->pid_cs_err(pid_cs_err);
		i_sie->crc5_err(crc5_err);
		i_sie->frm_nat(frm_nat);
		i_sie->nse_err(nse_err);
		i_sie->rx_size(rx_size);
		i_sie->rx_done(rx_done);
		i_sie->ctrl_setup(ctrl_setup);
		i_sie->ctrl_in(ctrl_in);
		i_sie->ctrl_out(ctrl_out);
		i_sie->csr(cfg);
		i_sie->tx_data_st(tx_data_st);
		i_sie->rx_data_st(rx_data_st);
		i_sie->idma_re(idma_re);
		i_sie->idma_we(idma_we);
		i_sie->ep_empty(ep_empty);
		i_sie->ep_full(ep_full);
		i_sie->send_stall(send_stall);

		// EP0 Instantiation and Binding
		i_ep0 = new usb_ep0("EP0");
		i_ep0->clk(clk_i);
		i_ep0->rst(rst_local);
		i_ep0->rom_adr(rom_adr);
		i_ep0->rom_data(rom_data);
		i_ep0->ctrl_setup(ctrl_setup);
		i_ep0->ctrl_in(ctrl_in);
		i_ep0->ctrl_out(ctrl_out);
		i_ep0->frame_no(frame_no);
		i_ep0->send_stall(send_stall);
		i_ep0->funct_adr(funct_adr);
		i_ep0->addressed(addressed);
		i_ep0->configured(configured);
		i_ep0->halt(halt);
		i_ep0->ep0_din(ep0_ctrl_dout);
		i_ep0->ep0_dout(ep0_ctrl_din);
		i_ep0->ep0_re(ep0_ctrl_re);
		i_ep0->ep0_we(ep0_ctrl_we);
		i_ep0->ep0_stat(ep0_ctrl_stat);
		i_ep0->ep0_size(ep0_size);
		i_ep0->v_set_int(v_set_int);
		i_ep0->v_set_feature(v_set_feature);
		i_ep0->wValue(wValue);
		i_ep0->wIndex(wIndex);
		i_ep0->vendor_data(vendor_data);

		// ROM Instantiation and Binding
		i_rom = new usb_rom("ROM");
		i_rom->clk(clk_i);
		i_rom->adr(rom_adr);
		i_rom->dout(rom_data);

		// FIFO_IN Instantiation and Binding
		i_ff_in = new usb_fifo64x8("FIFO_IN");
		i_ff_in->clk(clk_i);
		i_ff_in->rst(rst_i);
		i_ff_in->clr(usb_rst);
		i_ff_in->we(ep0_ctrl_we);
		i_ff_in->din(ep0_ctrl_din);
		i_ff_in->re(ep0_re);
		i_ff_in->dout(ep0_dout);
		i_ff_in->empty(ep0_empty);
		i_ff_in->full(stat2);

		// FIFO_OUT Instantiation and Binding
		i_ff_out = new usb_fifo64x8("FIFO_OUT");
		i_ff_out->clk(clk_i);
		i_ff_out->rst(rst_i);
		i_ff_out->clr(usb_rst);
		i_ff_out->we(ep0_we);
		i_ff_out->din(rx_data_st);
		i_ff_out->re(ep0_ctrl_re);
		i_ff_out->dout(ep0_ctrl_dout);
		i_ff_out->empty(stat1);
		i_ff_out->full(ep0_full);
	}

};

#endif

