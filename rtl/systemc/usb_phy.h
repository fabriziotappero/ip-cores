/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB PHY                                                    ////
////                                                             ////
////  SystemC Version: usb_phy.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_phy.v                                  ////
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

#ifndef USB_PHY_H
#define USB_PHY_H

#include "usb_tx_phy.h"
#include "usb_rx_phy.h"

//#define USB_ASYNC_RESET

SC_MODULE(usb_phy) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;
	sc_in<bool>			phy_tx_mode;
	sc_out<bool>		usb_rst;
	sc_out<bool>		txdp, txdn, txoe;
	sc_in<bool>			rxd, rxdp, rxdn;
	sc_in<sc_uint<8> >	DataOut_i;
	sc_in<bool>			TxValid_i;
	sc_out<bool>		TxReady_o;
	sc_out<sc_uint<8> >	DataIn_o;
	sc_out<bool>		RxValid_o;
	sc_out<bool>		RxActive_o;
	sc_out<bool>		RxError_o;
	sc_out<sc_uint<2> >	LineState_o;

	sc_signal<sc_uint<6> >	rst_cnt;
	sc_signal<bool>			reset, fs_ce;

	usb_tx_phy		*i_tx_phy;
	usb_rx_phy		*i_rx_phy;

	void reset_up(void);
	void rst_cnt_up(void);
	void usb_rst_up(void);
//	~usb_phy(void);

	SC_CTOR(usb_phy) {
		SC_METHOD(reset_up);
		sensitive << rst << usb_rst;
		SC_METHOD(rst_cnt_up);
		sensitive << clk.pos();
		SC_METHOD(usb_rst_up);
		sensitive << clk.pos();

		i_tx_phy = new usb_tx_phy("TX_PHY");
		i_tx_phy->clk(clk);
		i_tx_phy->rst(reset);
		i_tx_phy->fs_ce(fs_ce);
		i_tx_phy->phy_mode(phy_tx_mode);
		i_tx_phy->txdp(txdp);
		i_tx_phy->txdn(txdn);
		i_tx_phy->txoe(txoe);
		i_tx_phy->DataOut_i(DataOut_i);
		i_tx_phy->TxValid_i(TxValid_i);
		i_tx_phy->TxReady_o(TxReady_o);

		i_rx_phy = new usb_rx_phy("RX_PHY");
		i_rx_phy->clk(clk);
		i_rx_phy->rst(reset);
		i_rx_phy->fs_ce(fs_ce);
		i_rx_phy->rxd(rxd);
		i_rx_phy->rxdp(rxdp);
		i_rx_phy->rxdn(rxdn);
		i_rx_phy->DataIn_o(DataIn_o);
		i_rx_phy->RxValid_o(RxValid_o);
		i_rx_phy->RxActive_o(RxActive_o);
		i_rx_phy->RxError_o(RxError_o);
		i_rx_phy->RxEn_i(txoe);
		i_rx_phy->LineState(LineState_o);
	}

};

#endif

