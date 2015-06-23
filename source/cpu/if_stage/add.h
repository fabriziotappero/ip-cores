#include "systemc.h"

SC_MODULE(add)
{
	sc_out<sc_lv<32> >	if_pc_add;
	sc_in<sc_lv<32> >	pc_out;
	
	void do_add();
	
	SC_CTOR(add)
	{
		SC_METHOD(do_add);
		sensitive << pc_out;
	}
};
