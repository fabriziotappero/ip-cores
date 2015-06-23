#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_writeregister)
{
	sc_in<sc_lv<2> >	regdest;
	sc_in<sc_lv<5> >	rt;
	sc_in<sc_lv<5> >	rd;
	sc_out<sc_lv<5> >	id_writeregister;
	
	void do_mux_writeregister();
	
	SC_CTOR(mux_writeregister)
	{
		SC_METHOD(do_mux_writeregister);
		sensitive << rt << rd << regdest;
	}
}; 
