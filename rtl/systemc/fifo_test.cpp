#include "systemc.h"
#include "usb_fifo64x8.h"

SC_MODULE(test) {
	sc_in<bool> clk;
	sc_out<bool> rst, clr;
	sc_out<sc_uint<8> > din;
	sc_in<sc_uint<8> > dout;
	sc_out<bool> we, re;
	sc_in<bool> empty, full;

	int i;

	void update(void) {
		i = 0;
		rst.write(false);
		clr.write(false);
		we.write(false);
		re.write(false);
		wait();
		rst.write(true);
		wait(clk.posedge_event());
		we.write(true);
		while (!full.read()) {
			din.write(i++);
			wait(clk.posedge_event());
			wait(clk.negedge_event());
			cout << "WR: " << din.read() << endl;
		}
		we.write(false);
		wait(clk.posedge_event());
		re.write(true);
		while (!empty.read()) {
			wait(clk.posedge_event());
			wait(clk.negedge_event());
			cout << "RD: " << dout.read() << endl;
		}
		re.write(false);
		wait();
		wait();
		sc_stop();
	}

	SC_CTOR(test) {
		SC_THREAD(update);
		sensitive_pos(clk);
	}
};

int sc_main(int argc, char *argv[]) {

	sc_set_time_resolution(1.0, SC_NS);

	sc_clock clk("clock", 10.0, SC_NS);
	sc_signal<sc_uint<8> > din, dout;
	sc_signal<bool> rst, clr, we, re, empty, full;

	usb_fifo64x8 i_fifo("FIFO");
	test i_test("TEST");

	i_fifo.clk(clk);
	i_fifo.rst(rst);
	i_fifo.clr(clr);
	i_fifo.we(we);
	i_fifo.din(din);
	i_fifo.re(re);
	i_fifo.dout(dout);
	i_fifo.empty(empty);
	i_fifo.full(full);

	i_test.clk(clk);
	i_test.rst(rst);
	i_test.clr(clr);
	i_test.din(din);
	i_test.dout(dout);
	i_test.we(we);
	i_test.re(re);
	i_test.empty(empty);
	i_test.full(full);

	sc_trace_file *log = sc_create_vcd_trace_file("FIFO_TEST");
	sc_trace(log, clk, "Clock");
	sc_trace(log, din, "DataIn");
	sc_trace(log, dout, "DataOut");
	sc_trace(log, empty, "Empty");
	sc_trace(log, full, "Full");

	//sc_start(1000, SC_NS);
	sc_start();

	sc_close_vcd_trace_file(log);

	return 0;
}

