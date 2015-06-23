#include <stdio.h>

#include "systemc.h"
#include "usb_rom.h"

SC_MODULE(test) {
	sc_in<bool> clk;
	sc_out<sc_uint<8> > adr;
	sc_in<sc_uint<8> > dout;

	int i;

	void update(void) {
		i = 0;
		for (i = 0; i < 256; i++) {
			adr.write(i);
			wait(clk.posedge_event());
			wait(clk.negedge_event());
			fprintf(stdout, "ROM[%x]: %x\n", i, dout.read().to_uint());
		}
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
	sc_signal<sc_uint<8> > adr, dout;

	usb_rom i_rom("ROM");
	test i_test("TEST");

	i_rom.clk(clk);
	i_rom.adr(adr);
	i_rom.dout(dout);

	i_test.clk(clk);
	i_test.adr(adr);
	i_test.dout(dout);

	sc_trace_file *log = sc_create_vcd_trace_file("ROM_TEST");
	sc_trace(log, clk, "Clock");
	sc_trace(log, adr, "Address");
	sc_trace(log, dout, "ROM_Data");

	//sc_start(1000, SC_NS);
	sc_start();

	sc_close_vcd_trace_file(log);

	return 0;
}

