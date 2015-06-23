#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(sign_extend)
{
	sc_in<sc_lv<32> >	if_id_inst;
	sc_in<sc_lv<2> >	id_extend_ctrl; 
	sc_out<sc_lv<32> >	id_sign_extend;
	
	void do_sign_extend();
	
	SC_CTOR(sign_extend)
	{
		SC_METHOD(do_sign_extend);
		sensitive << if_id_inst << id_extend_ctrl;
	}
}; 
