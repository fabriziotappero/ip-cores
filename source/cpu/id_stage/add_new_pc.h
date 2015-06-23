#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(add_new_pc)
{
	sc_in<sc_lv<32> >	if_id_next_pc;
	sc_in<sc_lv<32> >	id_sign_extend;
	sc_out<sc_lv<32> >	id_new_pc;

	void do_add_new_pc();
	
	SC_CTOR(add_new_pc)
	{
		SC_METHOD(do_add_new_pc);
		sensitive << if_id_next_pc << id_sign_extend;
	}

};
