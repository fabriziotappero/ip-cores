#include "systemc.h"
#include "usb_tx_phy.h"

SC_MODULE(test) {
	sc_in<bool> clk;
	sc_out<bool> rst, fs_ce, phy_tx_mode;
	sc_in<bool> txdp, txdn, txoe;
	sc_out<sc_uint<8> > DataOut_i;
	sc_out<bool> TxValid_i;
	sc_in<bool> TxReady_o;

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
	sc_signal<bool> rst, fs_ce, phy_tx_mode, txdp, txdn, txoe, TxValid_i, TxReady_o;
	sc_signal<sc_uint<8> > DataOut_i;

	usb_tx_phy i_tx_phy("TX_PHY");
	test i_test("TEST");

	i_tx_phy.clk(clk);
	i_tx_phy.rst(rst);
	i_tx_phy.fs_ce(fs_ce);
	i_tx_phy.phy_mode(phy_tx_mode);
	i_tx_phy.txdp(txdp);
	i_tx_phy.txdn(txdn);
	i_tx_phy.txoe(txoe);
	i_tx_phy.DataOut_i(DataOut_i);
	i_tx_phy.TxValid_i(TxValid_i);
	i_tx_phy.TxReady_o(TxReady_o);

	i_test.clk(clk);
	i_test.rst(rst);
	i_test.fs_ce(fs_ce);
	i_test.phy_tx_mode(phy_tx_mode);
	i_test.txdp(txdp);
	i_test.txdn(txdn);
	i_test.txoe(txoe);
	i_test.DataOut_i(DataOut_i);
	i_test.TxValid_i(TxValid_i);
	i_test.TxReady_o(TxReady_o);

	sc_trace_file *log = sc_create_vcd_trace_file("TX_TEST");
	sc_trace(log, clk, "Clock");
	sc_trace(log, rst, "Reset");

	//sc_start(1000, SC_NS);
	sc_start();

	sc_close_vcd_trace_file(log);

	return 0;
}

