#include "systemc.h"
#include "usb_rx_phy.h"

SC_MODULE(test) {
	sc_in<bool> clk;
	sc_out<bool> rst;
	sc_in<bool> fs_ce;
	sc_out<bool> rxd, rxdp, rxdn, RxEn_i;
	sc_in<sc_uint<8> > DataIn_o;
	sc_in<bool> RxValid_o, RxActive_o, RxError_o;
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
	sc_signal<bool> rst, fs_ce, rxd, rxdp, rxdn, RxValid_o, RxActive_o, RxError_o, RxEn_i;
	sc_signal<sc_uint<8> > DataIn_o;
	sc_signal<sc_uint<2> > LineState_o;

	usb_rx_phy i_rx_phy("RX_PHY");
	test i_test("TEST");

	i_rx_phy.clk(clk);
	i_rx_phy.rst(rst);
	i_rx_phy.fs_ce(fs_ce);
	i_rx_phy.rxd(rxd);
	i_rx_phy.rxdn(rxdn);
	i_rx_phy.rxdp(rxdp);
	i_rx_phy.DataIn_o(DataIn_o);
	i_rx_phy.LineState(LineState_o);
	i_rx_phy.RxValid_o(RxValid_o);
	i_rx_phy.RxActive_o(RxActive_o);
	i_rx_phy.RxError_o(RxError_o);
	i_rx_phy.RxEn_i(RxEn_i);

	i_test.clk(clk);
	i_test.rst(rst);
	i_test.fs_ce(fs_ce);
	i_test.rxd(rxd);
	i_test.rxdn(rxdn);
	i_test.rxdp(rxdp);
	i_test.DataIn_o(DataIn_o);
	i_test.LineState_o(LineState_o);
	i_test.RxValid_o(RxValid_o);
	i_test.RxActive_o(RxActive_o);
	i_test.RxError_o(RxError_o);
	i_test.RxEn_i(RxEn_i);

	sc_trace_file *log = sc_create_vcd_trace_file("RX_TEST");
	sc_trace(log, clk, "Clock");
	sc_trace(log, rst, "Reset");
	sc_trace(log, RxError_o, "RX_Error");

	//sc_start(1000, SC_NS);
	sc_start();

	sc_close_vcd_trace_file(log);

	return 0;
}

