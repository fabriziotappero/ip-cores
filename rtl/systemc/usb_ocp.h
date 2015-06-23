/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Module                                         ////
////  Function Interface                                         ////
////  OCP Interface                                              ////
////                                                             ////
////  SystemC Version: usb_ocp.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_ocp_if.v                               ////
//// Copyright (C) 2004      Alfredo Luiz Foltran Fialho         ////
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

#ifndef USB_OCP_H
#define USB_OCP_H

#include "usb.h"

// Command Encoding -> MCmd[2:0]
enum COMMAND {	OCP_IDLE = 0,
				OCP_WR = 1,
				OCP_RD = 2,
				OCP_RDEX = 3,
				// 100..110 -> Reserved,
				OCP_BCST = 7};

// Response Encoding -> SResp[1:0]
enum RESPONSE {	OCP_NULL = 0,
				OCP_DVA = 1,
				// 10 -> Reserved
				OCP_ERR = 3};

SC_MODULE(usb_ocp) {

  private:

	sc_signal<bool>	vcc;
	sc_signal<bool>	usb_rst_nc;

  public:

	sc_in<bool>			Clk;					// Basic Signal -> Clock signal
	sc_in<bool>			Reset_n;				// Sideband Signal -> Reset signal

	// PHY Interface
	sc_out<bool>		tx_dp, tx_dn, tx_oe;
	sc_in<bool>			rx_dp, rx_dn, rx_d;

	// Sideband Interface
	sc_out<bool>		SInterrupt;				// Interrupt
	sc_out<sc_uint<8> >	SFlag;					// Flags
	sc_out<bool>		SError;					// Error Indicator

	// Basic Interface
	sc_in<sc_uint<32> >	MAddr;
	sc_in<sc_uint<3> >	MCmd;
	sc_in<sc_uint<8> >	MData;
	sc_out<bool>		SCmdAccept;
	sc_out<sc_uint<8> >	SData;
	sc_out<sc_uint<2> >	SResp;

	// Local Signals

	sc_signal<bool>			empty;
	sc_signal<bool>			full;

	// Vendor Signals
	sc_signal<sc_uint<16> >	wValue;
	sc_signal<sc_uint<16> >	wIndex;
	sc_signal<sc_uint<16> >	vendor_data;

	// SFlag Signals
	sc_signal<bool>			SF_busy;
	sc_signal<sc_uint<4> >	SF_sel;
	sc_signal<bool>			SF_feature;

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
	void sflag_up(void);
	void sresp_up(void);

	// Destructor
//	~usb_ocp(void);

	SC_CTOR(usb_ocp) {
		vcc.write(true);

		SC_METHOD(mux);
		sensitive << MAddr << MCmd << MData;
		sensitive << ep1_f_full << ep2_f_dout << ep2_f_empty;
		sensitive << ep3_f_full << ep4_f_dout << ep4_f_empty;
		sensitive << ep5_f_full << ep6_f_dout << ep6_f_empty;
		sensitive << wValue << wIndex;
		SC_METHOD(sflag_up);
		sensitive << empty << full << SF_busy << SF_sel << SF_feature;
		SC_METHOD(sresp_up);
		sensitive << Clk.pos();

		// USB Instantiation and Binding
		i_usb = new usb("USB");
		i_usb->clk_i(Clk);
		i_usb->rst_i(Reset_n);
		i_usb->tx_dp(tx_dp);
		i_usb->tx_dn(tx_dn);
		i_usb->tx_oe(tx_oe);
		i_usb->rx_dp(rx_dp);
		i_usb->rx_dn(rx_dn);
		i_usb->rx_d(rx_d);
		i_usb->phy_tx_mode(vcc);
		i_usb->usb_rst(usb_rst_nc);
		i_usb->crc16_err(SError);
		i_usb->v_set_int(SInterrupt);
		i_usb->v_set_feature(SF_feature);
		i_usb->wValue(wValue);
		i_usb->wIndex(wIndex);
		i_usb->vendor_data(vendor_data);
		i_usb->usb_busy(SF_busy);
		i_usb->ep_sel(SF_sel);
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

