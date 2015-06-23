/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Level Test Bench                               ////
////                                                             ////
////  SystemC Version: usb_test.cpp                              ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: test_bench_top.v                           ////
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

#include "systemc.h"
#include "usb_phy.h"
#include "usb_top.h"

#define VCD_OUTPUT_ENABLE
//#define WIF_OUTPUT_ENABLE

SC_MODULE(test) {
	sc_in<bool>		clk, clk2;
	sc_out<bool>	rst;

	int i;

	void update(void) {
		rst.write(false);
		for (i = 0; i < 10; i++) wait(clk.posedge_event());
		rst.write(true);
		for (i = 0; i < 500; i++) wait(clk.posedge_event());
		sc_stop();
	}

	SC_CTOR(test) {
		SC_THREAD(update);
		sensitive_pos(clk);
	}
};

int sc_main(int argc, char *argv[]) {

	sc_set_time_resolution(1.0, SC_NS);

	sc_clock clk("clock", 20.84, SC_NS);
	sc_clock clk2("clock2", 20.84, SC_NS);

	sc_signal<bool>	rst, vcc;

	sc_signal<bool>	rx_dp1, rx_dn1, tx_dp1, tx_dn1;
	sc_signal<bool>	tb_rx_valid, tb_rx_active, tb_rx_error;
	sc_signal<bool>	tb_tx_valid, tb_tx_ready;
	sc_signal<sc_uint<8> > tb_rx_data, tb_tx_data;

	sc_signal<bool>	rx_dp2, rx_dn2, tx_dp2, tx_dn2;
	sc_signal<sc_uint<8> >	ep_f_din;
	sc_signal_rv<8> ep_f_dout;
	sc_signal<sc_uint<8> > ep_f_adr;
	sc_signal<bool> cs, ep_f_re, ep_f_we, ep_f_empty, ep_f_full;

	sc_signal<bool> usb_rst_nc, txoe_nc;
	sc_signal<sc_uint<2> > line_nc;

	sc_signal<bool> rst_nc, tx_oe_nc, crc16_nc, int_nc, feature_nc, busy_nc;
	sc_signal<sc_uint<4> > sel_nc;

	usb_phy			i_phy("HOST_PHY");
	usb_top			i_top("USB_TOP");
	test			i_test("TEST");

	i_phy.clk(clk);
	i_phy.rst(rst);
	i_phy.phy_tx_mode(vcc);
	i_phy.usb_rst(usb_rst_nc);
	i_phy.txdp(tx_dp1);
	i_phy.txdn(tx_dn1);
	i_phy.txoe(txoe_nc);
	i_phy.rxd(rx_dp1);
	i_phy.rxdp(rx_dp1);
	i_phy.rxdn(rx_dn1);
	i_phy.DataOut_i(tb_tx_data);
	i_phy.TxValid_i(tb_tx_valid);
	i_phy.TxReady_o(tb_tx_ready);
	i_phy.DataIn_o(tb_rx_data);
	i_phy.RxValid_o(tb_rx_valid);
	i_phy.RxActive_o(tb_rx_active);
	i_phy.RxError_o(tb_rx_error);
	i_phy.LineState_o(line_nc);

	i_top.clk_i(clk);
	i_top.rst_i(rst);
	i_top.tx_dp(tx_dp2);
	i_top.tx_dn(tx_dn2);
	i_top.tx_oe(tx_oe_nc);
	i_top.rx_dp(rx_dp2);
	i_top.rx_dn(rx_dn2);
	i_top.rx_d(rx_dp2);
	i_top.usb_rst(rst_nc);
	i_top.crc16_err(crc16_nc);
	i_top.v_set_int(int_nc);
	i_top.v_set_feature(feature_nc);
	i_top.usb_busy(busy_nc);
	i_top.ep_sel(sel_nc);
	i_top.adr(ep_f_adr);
	i_top.din(ep_f_din);
	i_top.dout(ep_f_dout);
	i_top.cs(cs);
	i_top.re(ep_f_re);
	i_top.we(ep_f_we);
	i_top.empty(ep_f_empty);
	i_top.full(ep_f_full);

	i_test.clk(clk);
	i_test.clk2(clk2);
	i_test.rst(rst);

	vcc.write(true);

#ifdef VCD_OUTPUT_ENABLE
	sc_trace_file *vcd_log = sc_create_vcd_trace_file("USB_TEST");
	sc_trace(vcd_log, clk, "Clock");
	sc_trace(vcd_log, rst, "Reset");
#endif

#ifdef WIF_OUTPUT_ENABLE
	sc_trace_file *wif_log = sc_create_wif_trace_file("USB_TEST");
	sc_trace(wif_log, clk, "Clock");
	sc_trace(wif_log, rst, "Reset");
#endif

	sc_start();

#ifdef VCD_OUTPUT_ENABLE
	sc_close_vcd_trace_file(vcd_log);
#endif

#ifdef WIF_OUTPUT_ENABLE
	sc_close_wif_trace_file(wif_log);
#endif

	return 0;
}

