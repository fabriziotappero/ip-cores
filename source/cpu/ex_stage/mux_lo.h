#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_lo)
{
	sc_in<sc_lv<32> >	lo;
	sc_in<sc_lv<32> >	rs;
	sc_in<sc_lv<6> >	id_ex_alu_ctrl;
	sc_out<sc_lv<32> >	out;
	
	void do_mux_lo();
	
	SC_CTOR(mux_lo)
	{
		SC_METHOD(do_mux_lo);
		sensitive << lo << rs << id_ex_alu_ctrl;
	}
} ;
