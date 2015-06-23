#include "systemc.h"

SC_MODULE(reset_gen)
{
	sc_in<bool> in_clk;
	sc_out<bool> reset;
	
	void do_reset();

	SC_CTOR(reset_gen)
	{
		SC_THREAD(do_reset);
		sensitive << in_clk.pos();
	}
};
