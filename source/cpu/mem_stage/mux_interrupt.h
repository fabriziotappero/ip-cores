#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_interrupt)
{
	sc_in<bool>		IN_A;
	sc_in<bool>		IN_B;

#ifdef _MULT_PIPELINE_
	sc_in<bool> 		hold_pipe;
#endif
	
	sc_in<sc_logic>		SEL;
	sc_out<bool>		OUT;
	
	
	void do_mux_interrupt();
	
	SC_CTOR(mux_interrupt)
	{
		SC_METHOD(do_mux_interrupt);
		sensitive << IN_A << IN_B << SEL;
	    #ifdef _MULT_PIPELINE_
		sensitive << hold_pipe;
	    #endif	
	}
};
