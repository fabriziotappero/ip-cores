#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_alu2)
{
	sc_in<sc_lv<32> >	id_sign_extend;
	sc_in<sc_lv<2> >	id_sign_ctrl;
	sc_out<sc_lv<32> >	id_alu2;
	sc_out<sc_lv<32> >	cp0_reg_rs;
	sc_in<sc_lv<32> >	id_mux_fw2;
	
	void do_mux_alu2();
	
	SC_CTOR(mux_alu2)
	{
		SC_METHOD(do_mux_alu2);
		sensitive << id_mux_fw2 << id_sign_extend << id_sign_ctrl;
	}
};
