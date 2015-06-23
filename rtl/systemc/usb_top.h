/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Module                                         ////
////  Function Interface                                         ////
////                                                             ////
////  SystemC Version: usb_top.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_8051_if.v                              ////
//// Copyright (C) 2003      Alfredo Luiz Foltran Fialho         ////
////                         alfoltran@ig.com.br                 ////
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

#ifndef USB_TOP_H
#define USB_TOP_H

#include "usb.h"

SC_MODULE(usb_top) {

  private:

	sc_signal<bool>	vcc;

  public:

	sc_in<bool>			clk_i;
	sc_in<bool>			rst_i;

	// PHY Interface
	sc_out<bool>		tx_dp, tx_dn, tx_oe;
	sc_in<bool>			rx_dp, rx_dn, rx_d;

	// Misc
	sc_out<bool>		usb_rst;

	// Interrupts
	sc_out<bool>		crc16_err;

	// Vendor Features
	sc_out<bool>		v_set_int;
	sc_out<bool>		v_set_feature;

	// USB Status
	sc_out<bool>		usb_busy;
	sc_out<sc_uint<4> >	ep_sel;

	// Function Interface
	sc_in<sc_uint<8> >	adr;
	sc_in<sc_uint<8> >	din;
	sc_out_rv<8>		dout;
	sc_in<bool>			cs;
	sc_in<bool>			re, we;
	sc_out<bool>		empty, full;

	// Local Signals

	// Vendor Signals
	sc_signal<sc_uint<16> >	wValue;
	sc_signal<sc_uint<16> >	wIndex;
	sc_signal<sc_uint<16> >	vendor_data;

	// Endpoint Interface
	// EP1
	sc_signal<sc_uint<8> >	ep1_f_din;
	sc_signal<bool>			ep1_f_we;
	sc_signal<bool>			ep1_f_full;

	// EP2
	sc_signal<sc_uint<8> >	ep2_f_dout;
	sc_signal<bool>			ep2_f_re;
	sc_signal<bool>			ep2_f_empty;

	// EP3
	sc_signal<sc_uint<8> >	ep3_f_din;
	sc_signal<bool>			ep3_f_we;
	sc_signal<bool>			ep3_f_full;

	// EP4
	sc_signal<sc_uint<8> >	ep4_f_dout;
	sc_signal<bool>			ep4_f_re;
	sc_signal<bool>			ep4_f_empty;

	// EP5
	sc_signal<sc_uint<8> >	ep5_f_din;
	sc_signal<bool>			ep5_f_we;
	sc_signal<bool>			ep5_f_full;

	// EP6
	sc_signal<sc_uint<8> >	ep6_f_dout;
	sc_signal<bool>			ep6_f_re;
	sc_signal<bool>			ep6_f_empty;

	usb						*i_usb;			// USB

	// Mux Function
	void mux(void);

	// Destructor
//	~usb_top(void);

	SC_CTOR(usb_top) {
		vcc.write(true);

		SC_METHOD(mux);
		sensitive << adr << cs << din << re << we;
		sensitive << ep1_f_full << ep2_f_dout << ep2_f_empty;
		sensitive << ep3_f_full << ep4_f_dout << ep4_f_empty;
		sensitive << ep5_f_full << ep6_f_dout << ep6_f_empty;
		sensitive << wValue << wIndex;

		// USB Instantiation and Binding
		i_usb = new usb("USB");
		i_usb->clk_i(clk_i);
		i_usb->rst_i(rst_i);
		i_usb->tx_dp(tx_dp);
		i_usb->tx_dn(tx_dn);
		i_usb->tx_oe(tx_oe);
		i_usb->rx_dp(rx_dp);
		i_usb->rx_dn(rx_dn);
		i_usb->rx_d(rx_d);
		i_usb->phy_tx_mode(vcc);
		i_usb->usb_rst(usb_rst);
		i_usb->crc16_err(crc16_err);
		i_usb->v_set_int(v_set_int);
		i_usb->v_set_feature(v_set_feature);
		i_usb->wValue(wValue);
		i_usb->wIndex(wIndex);
		i_usb->vendor_data(vendor_data);
		i_usb->usb_busy(usb_busy);
		i_usb->ep_sel(ep_sel);
		i_usb->ep1_f_din(ep1_f_din);
		i_usb->ep1_f_we(ep1_f_we);
		i_usb->ep1_f_full(ep1_f_full);
		i_usb->ep2_f_dout(ep2_f_dout);
		i_usb->ep2_f_re(ep2_f_re);
		i_usb->ep2_f_empty(ep2_f_empty);
		i_usb->ep3_f_din(ep3_f_din);
		i_usb->ep3_f_we(ep3_f_we);
		i_usb->ep3_f_full(ep3_f_full);
		i_usb->ep4_f_dout(ep4_f_dout);
		i_usb->ep4_f_re(ep4_f_re);
		i_usb->ep4_f_empty(ep4_f_empty);
		i_usb->ep5_f_din(ep5_f_din);
		i_usb->ep5_f_we(ep5_f_we);
		i_usb->ep5_f_full(ep5_f_full);
		i_usb->ep6_f_dout(ep6_f_dout);
		i_usb->ep6_f_re(ep6_f_re);
		i_usb->ep6_f_empty(ep6_f_empty);
	}

};

#endif

