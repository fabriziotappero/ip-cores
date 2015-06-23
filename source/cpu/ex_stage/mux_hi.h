#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_hi)
{
	sc_in<sc_lv<32> >	hi;
	sc_in<sc_lv<32> >	rs;
	sc_in<sc_lv<6> >	id_ex_alu_ctrl;
	sc_out<sc_lv<32> >	out;

	void do_mux_hi();
	
	SC_CTOR(mux_hi)
	{
		SC_METHOD(do_mux_hi);
		sensitive << hi << rs << id_ex_alu_ctrl;
	}
};
