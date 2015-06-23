#include "systemc.h"

SC_MODULE(sample_clock_generator) 
{
	sc_in<bool>		in_clk;
	sc_in<bool>		reset;
	sc_out<bool>	sample_clock;
	
	unsigned int		count;
	
	void do_sample_clock_generator();

	SC_CTOR(sample_clock_generator)
	{
		SC_METHOD(do_sample_clock_generator);
		sensitive_pos << in_clk;
		sensitive << reset;
	}
};
