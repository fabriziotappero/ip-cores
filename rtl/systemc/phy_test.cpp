#include "systemc.h"
#include "usb_phy.h"

SC_MODULE(test) {
	sc_in<bool> clk, usb_rst;
	sc_out<bool> rst, phy_tx_mode;
	sc_in<bool> txdp, txdn, txoe;
	sc_out<bool> rxd, rxdp, rxdn;
	sc_out<sc_uint<8> > DataOut_i;
	sc_in<sc_uint<8> > DataIn_o;
	sc_out<bool> TxValid_i;
	sc_in<bool> TxReady_o, RxValid_o, RxActive_o, RxError_o;
	sc_in<sc_uint<2> > LineState_o;

	int i;

	void update(void) {
		i = 0;
		rst.write(false);
		wait();
		wait();
		rst.write(true);
		wait();
		wait();
		wait();
		wait();
		sc_stop();
	}

	SC_CTOR(test) {
		SC_THREAD(update);
		sensitive << clk.pos();
	}
};

int sc_main(int argc, char *argv[]) {

	sc_set_time_resolution(1.0, SC_NS);

	sc_clock clk("clock", 20.83, SC_NS);
	sc_signal<bool> rst, phy_tx_mode, usb_rst, txdp, txdn, txoe, rxd, rxdp, rxdn,
			TxValid_i, TxReady_o, RxValid_o, RxActive_o, RxError_o;
	sc_signal<sc_uint<8> > DataOut_i, DataIn_o;
	sc_signal<sc_uint<2> > LineState_o;

	usb_phy i_phy("PHY");
	test i_test("TEST");

	i_phy.clk(clk);
	i_phy.rst(rst);
	i_phy.phy_tx_mode(phy_tx_mode);
	i_phy.usb_rst(usb_rst);
	i_phy.txdp(txdp);
	i_phy.txdn(txdn);
	i_phy.txoe(txoe);
	i_phy.rxd(rxd);
	i_phy.rxdn(rxdn);
	i_phy.rxdp(rxdp);
	i_phy.DataOut_i(DataOut_i);
	i_phy.DataIn_o(DataIn_o);
	i_phy.LineState_o(LineState_o);
	i_phy.TxValid_i(TxValid_i);
	i_phy.TxReady_o(TxReady_o);
	i_phy.RxValid_o(RxValid_o);
	i_phy.RxActive_o(RxActive_o);
	i_phy.RxError_o(RxError_o);

	i_test.clk(clk);
	i_test.rst(rst);
	i_test.phy_tx_mode(phy_tx_mode);
	i_test.usb_rst(usb_rst);
	i_test.txdp(txdp);
	i_test.txdn(txdn);
	i_test.txoe(txoe);
	i_test.rxd(rxd);
	i_test.rxdn(rxdn);
	i_test.rxdp(rxdp);
	i_test.DataOut_i(DataOut_i);
	i_test.DataIn_o(DataIn_o);
	i_test.LineState_o(LineState_o);
	i_test.TxValid_i(TxValid_i);
	i_test.TxReady_o(TxReady_o);
	i_test.RxValid_o(RxValid_o);
	i_test.RxActive_o(RxActive_o);
	i_test.RxError_o(RxError_o);

	sc_trace_file *log = sc_create_vcd_trace_file("PHY_TEST");
	sc_trace(log, clk, "Clock");
	sc_trace(log, rst, "Reset");

	//sc_start(1000, SC_NS);
	sc_start();

	sc_close_vcd_trace_file(log);

	return 0;
}

