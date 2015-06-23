#include "systemc.h"

SC_MODULE(or_gate)
{
	sc_in<bool>	in_A;
	sc_in<bool>	in_B;
	
	sc_out<bool>	out_gate;
		
	void do_or_gate();
	
	SC_CTOR(or_gate)
	{
		SC_METHOD(do_or_gate);
		sensitive << in_A << in_B;
	
	}
}; 
