#include "systemc.h"    // for systemc
#include <stdio.h>      // for io interfacing with c
#include <stdlib.h>     // for executing linux command within c code
#include "firTF.h"
#include "stimuli.h"

int sc_main(int argc, char* argv[])
{
    // Testing Internal Signal
    sc_clock fir_clk("fir_clk", 10, SC_NS);     // CLOCK
    sc_signal<bool > fir_clr;                   // RESET
    sc_signal<sc_uint<1> > fir_in;              // INPUT
    sc_signal<sc_int<15> > fir_out;             // OUTPUT

    firTF DUT("firTF");
    DUT.fir_clr(fir_clr);
    DUT.fir_clk(fir_clk);
    DUT.fir_in(fir_in);
    DUT.fir_out(fir_out);

    stimuli inputVector("stimuli");
    inputVector.clr(fir_clr);
    inputVector.clk(fir_clk);
    inputVector.streamout(fir_in);

 	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

    sc_trace(fp, fir_clr, "fir_clr");
	sc_trace(fp, fir_clk, "fir_clk");
	sc_trace(fp, fir_in, "fir_in");
	sc_trace(fp, fir_out, "fir_out");
	//sc_trace(fp, DUT.multi_add[0], "multi_add[0]");
	//sc_trace(fp, DUT.multi_add[1], "multi_add[1]");
	//sc_trace(fp, DUT.multi_add[2], "multi_add[2]");
	//sc_trace(fp, DUT.add_delay[0], "add_delay[0]");
	//sc_trace(fp, DUT.add_delay[1], "add_delay[1]");
	//sc_trace(fp, DUT.delay_add[0], "delay_add[0]");
	//sc_trace(fp, DUT.delay_add[1], "delay_add[1]");

    fir_clr = true;
	sc_start(20, SC_NS);
	fir_clr = false;
	sc_start(410, SC_NS);

	sc_close_vcd_trace_file(fp);

    //system("more fir_output.txt");
    //system("rm fir_output.txt");

	return 0;
}
