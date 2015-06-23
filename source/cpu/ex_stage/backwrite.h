#include "systemc.h"
// modulo completamente inutile!!!

SC_MODULE(backwrite)
{
	sc_in<sc_lv<32> >	ex_id_forward_s;
	sc_out<sc_lv<32> >	ex_id_forward;
	
	void do_backwrite();
	
	SC_CTOR(backwrite)
	{
		SC_METHOD(do_backwrite);
		sensitive << ex_id_forward_s;
	}
};
