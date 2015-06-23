/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1                                                    ////
////  Endpoints Config and FIFOs Instantiation                   ////
////                                                             ////
////  SystemC Version: usb.h                                     ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb.v                                      ////
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

#ifndef USB_H
#define USB_H

#include "systemc.h"
#include "usb_defines.h"
#include "usb_core.h"
#include "usb_fifo512x8.h"
#include "usb_fifo128x8.h"

SC_MODULE(usb) {

  private:

	sc_signal<bool>			vcc, gnd;
	sc_signal<sc_uint<8> >	gnd8;
	sc_signal<sc_uint<14> >	cfg1, cfg2, cfg3, cfg4, cfg5, cfg6, cfg7;
	sc_signal<bool>			ep1_we_nc, ep2_re_nc, ep3_we_nc, ep4_re_nc, ep5_we_nc, ep6_re_nc, ep7_we_nc, ep7_re_nc;
	sc_signal<sc_uint<8> >	ep1_dout_nc, ep3_dout_nc, ep5_dout_nc, ep7_dout_nc;

  public:

	sc_in<bool>				clk_i;
	sc_in<bool>				rst_i;

	// PHY Interface
	sc_out<bool>			tx_dp, tx_dn, tx_oe;
	sc_in<bool>				rx_dp, rx_dn, rx_d;
	sc_in<bool>				phy_tx_mode;

	// Misc
	sc_out<bool>			usb_rst;

	// Interrupts
	sc_out<bool>			crc16_err;

	// Vendor Features
	sc_out<bool>			v_set_int;
	sc_out<bool>			v_set_feature;
	sc_out<sc_uint<16> >	wValue;
	sc_out<sc_uint<16> >	wIndex;
	sc_in<sc_uint<16> >		vendor_data;

	// USB Status
	sc_out<bool>			usb_busy;
	sc_out<sc_uint<4> >		ep_sel;

	// Endpoint Interface
	// EP1
	sc_in<sc_uint<8> >		ep1_f_din;
	sc_in<bool>				ep1_f_we;
	sc_out<bool>			ep1_f_full;

	// EP2
	sc_out<sc_uint<8> >		ep2_f_dout;
	sc_in<bool>				ep2_f_re;
	sc_out<bool>			ep2_f_empty;

	// EP3
	sc_in<sc_uint<8> >		ep3_f_din;
	sc_in<bool>				ep3_f_we;
	sc_out<bool>			ep3_f_full;

	// EP4
	sc_out<sc_uint<8> >		ep4_f_dout;
	sc_in<bool>				ep4_f_re;
	sc_out<bool>			ep4_f_empty;

	// EP5
	sc_in<sc_uint<8> >		ep5_f_din;
	sc_in<bool>				ep5_f_we;
	sc_out<bool>			ep5_f_full;

	// EP6
	sc_out<sc_uint<8> >		ep6_f_dout;
	sc_in<bool>				ep6_f_re;
	sc_out<bool>			ep6_f_empty;

	// Local Signals
	// EP1
	sc_signal<sc_uint<8> >	ep1_us_din;
	sc_signal<bool>			ep1_us_re;
	sc_signal<bool>			ep1_us_empty;

	// EP2
	sc_signal<sc_uint<8> >	ep2_us_dout;
	sc_signal<bool>			ep2_us_we;
	sc_signal<bool>			ep2_us_full;

	// EP3
	sc_signal<sc_uint<8> >	ep3_us_din;
	sc_signal<bool>			ep3_us_re;
	sc_signal<bool>			ep3_us_empty;

	// EP4
	sc_signal<sc_uint<8> >	ep4_us_dout;
	sc_signal<bool>			ep4_us_we;
	sc_signal<bool>			ep4_us_full;

	// EP5
	sc_signal<sc_uint<8> >	ep5_us_din;
	sc_signal<bool>			ep5_us_re;
	sc_signal<bool>			ep5_us_empty;

	// EP6
	sc_signal<sc_uint<8> >	ep6_us_dout;
	sc_signal<bool>			ep6_us_we;
	sc_signal<bool>			ep6_us_full;

	usb_core				*i_core;			// CORE
	usb_fifo512x8			*i_ff_ep1;			// FIFO1
	usb_fifo512x8			*i_ff_ep2;			// FIFO2
	usb_fifo128x8			*i_ff_ep3;			// FIFO3
	usb_fifo128x8			*i_ff_ep4;			// FIFO4
	usb_fifo128x8			*i_ff_ep5;			// FIFO5
	usb_fifo128x8			*i_ff_ep6;			// FIFO6
/*
	// Destructor
	~usb(void) {
		if (i_core)
			delete i_core;
		if (i_ff_ep1)
			delete i_ff_ep1;
		if (i_ff_ep2)
			delete i_ff_ep2;
		if (i_ff_ep3)
			delete i_ff_ep3;
		if (i_ff_ep4)
			delete i_ff_ep4;
		if (i_ff_ep5)
			delete i_ff_ep5;
		if (i_ff_ep6)
			delete i_ff_ep6;
	}
*/
	SC_CTOR(usb) {
		vcc.write(true);
		gnd.write(false);
		gnd8.write(0);

		cfg1.write(ISO  | IN  | 256);
		cfg2.write(ISO  | OUT | 256);
		cfg3.write(BULK | IN  | 64);
		cfg4.write(BULK | OUT | 64);
		cfg5.write(INT  | IN  | 64);
		cfg6.write(INT  | OUT | 64);
		cfg7.write(0);

		// CORE Instantiation and Binding
		i_core = new usb_core("CORE");
		i_core->clk_i(clk_i);
		i_core->rst_i(rst_i);
		i_core->tx_dp(tx_dp);
		i_core->tx_dn(tx_dn);
		i_core->tx_oe(tx_oe);
		i_core->rx_dp(rx_dp);
		i_core->rx_dn(rx_dn);
		i_core->rx_d(rx_d);
		i_core->phy_tx_mode(vcc);
		i_core->usb_rst(usb_rst);
		i_core->crc16_err(crc16_err);
		i_core->v_set_int(v_set_int);
		i_core->v_set_feature(v_set_feature);
		i_core->wValue(wValue);
		i_core->wIndex(wIndex);
		i_core->vendor_data(vendor_data);
		i_core->usb_busy(usb_busy);
		i_core->ep_sel(ep_sel);

		// EP1 -> ISO IN 256
		i_core->ep1_cfg(cfg1);
		i_core->ep1_din(ep1_us_din);
		i_core->ep1_dout(ep1_dout_nc);
		i_core->ep1_we(ep1_we_nc);
		i_core->ep1_re(ep1_us_re);
		i_core->ep1_empty(ep1_us_empty);
		i_core->ep1_full(gnd);

		// EP2 -> ISO OUT 256
		i_core->ep2_cfg(cfg2);
		i_core->ep2_din(gnd8);
		i_core->ep2_dout(ep2_us_dout);
		i_core->ep2_we(ep2_us_we);
		i_core->ep2_re(ep2_re_nc);
		i_core->ep2_empty(gnd);
		i_core->ep2_full(ep2_us_full);

		// EP3 -> BULK IN 64
		i_core->ep3_cfg(cfg3);
		i_core->ep3_din(ep3_us_din);
		i_core->ep3_dout(ep3_dout_nc);
		i_core->ep3_we(ep3_we_nc);
		i_core->ep3_re(ep3_us_re);
		i_core->ep3_empty(ep3_us_empty);
		i_core->ep3_full(gnd);

		// EP4 -> BULK OUT 64
		i_core->ep4_cfg(cfg4);
		i_core->ep4_din(gnd8);
		i_core->ep4_dout(ep4_us_dout);
		i_core->ep4_we(ep4_us_we);
		i_core->ep4_re(ep4_re_nc);
		i_core->ep4_empty(gnd);
		i_core->ep4_full(ep4_us_full);

		// EP5 -> INT IN 64
		i_core->ep5_cfg(cfg5);
		i_core->ep5_din(ep5_us_din);
		i_core->ep5_dout(ep5_dout_nc);
		i_core->ep5_we(ep5_we_nc);
		i_core->ep5_re(ep5_us_re);
		i_core->ep5_empty(ep5_us_empty);
		i_core->ep5_full(gnd);

		// EP6 -> INT OUT 64
		i_core->ep6_cfg(cfg6);
		i_core->ep6_din(gnd8);
		i_core->ep6_dout(ep6_us_dout);
		i_core->ep6_we(ep6_us_we);
		i_core->ep6_re(ep6_re_nc);
		i_core->ep6_empty(gnd);
		i_core->ep6_full(ep6_us_full);

		// EP7 -> DEAD
		i_core->ep7_cfg(cfg7);
		i_core->ep7_din(gnd8);
		i_core->ep7_dout(ep7_dout_nc);
		i_core->ep7_we(ep7_we_nc);
		i_core->ep7_re(ep7_re_nc);
		i_core->ep7_empty(gnd);
		i_core->ep7_full(gnd);

		// FIFO1 Instantiation and Binding
		i_ff_ep1 = new usb_fifo512x8("FIFO1");
		i_ff_ep1->clk(clk_i);
		i_ff_ep1->rst(rst_i);
		i_ff_ep1->clr(gnd);
		i_ff_ep1->we(ep1_f_we);
		i_ff_ep1->din(ep1_f_din);
		i_ff_ep1->re(ep1_us_re);
		i_ff_ep1->dout(ep1_us_din);
		i_ff_ep1->empty(ep1_us_empty);
		i_ff_ep1->full(ep1_f_full);

		// FIFO2 Instantiation and Binding
		i_ff_ep2 = new usb_fifo512x8("FIFO2");
		i_ff_ep2->clk(clk_i);
		i_ff_ep2->rst(rst_i);
		i_ff_ep2->clr(gnd);
		i_ff_ep2->we(ep2_us_we);
		i_ff_ep2->din(ep2_us_dout);
		i_ff_ep2->re(ep2_f_re);
		i_ff_ep2->dout(ep2_f_dout);
		i_ff_ep2->empty(ep2_f_empty);
		i_ff_ep2->full(ep2_us_full);

		// FIFO3 Instantiation and Binding
		i_ff_ep3 = new usb_fifo128x8("FIFO3");
		i_ff_ep3->clk(clk_i);
		i_ff_ep3->rst(rst_i);
		i_ff_ep3->clr(gnd);
		i_ff_ep3->we(ep3_f_we);
		i_ff_ep3->din(ep3_f_din);
		i_ff_ep3->re(ep3_us_re);
		i_ff_ep3->dout(ep3_us_din);
		i_ff_ep3->empty(ep3_us_empty);
		i_ff_ep3->full(ep3_f_full);

		// FIFO4 Instantiation and Binding
		i_ff_ep4 = new usb_fifo128x8("FIFO4");
		i_ff_ep4->clk(clk_i);
		i_ff_ep4->rst(rst_i);
		i_ff_ep4->clr(gnd);
		i_ff_ep4->we(ep4_us_we);
		i_ff_ep4->din(ep4_us_dout);
		i_ff_ep4->re(ep4_f_re);
		i_ff_ep4->dout(ep4_f_dout);
		i_ff_ep4->empty(ep4_f_empty);
		i_ff_ep4->full(ep4_us_full);

		// FIFO5 Instantiation and Binding
		i_ff_ep5 = new usb_fifo128x8("FIFO5");
		i_ff_ep5->clk(clk_i);
		i_ff_ep5->rst(rst_i);
		i_ff_ep5->clr(gnd);
		i_ff_ep5->we(ep5_f_we);
		i_ff_ep5->din(ep5_f_din);
		i_ff_ep5->re(ep5_us_re);
		i_ff_ep5->dout(ep5_us_din);
		i_ff_ep5->empty(ep5_us_empty);
		i_ff_ep5->full(ep5_f_full);

		// FIFO6 Instantiation and Binding
		i_ff_ep6 = new usb_fifo128x8("FIFO6");
		i_ff_ep6->clk(clk_i);
		i_ff_ep6->rst(rst_i);
		i_ff_ep6->clr(gnd);
		i_ff_ep6->we(ep6_us_we);
		i_ff_ep6->din(ep6_us_dout);
		i_ff_ep6->re(ep6_f_re);
		i_ff_ep6->dout(ep6_f_dout);
		i_ff_ep6->empty(ep6_f_empty);
		i_ff_ep6->full(ep6_us_full);

	}

};

#endif

