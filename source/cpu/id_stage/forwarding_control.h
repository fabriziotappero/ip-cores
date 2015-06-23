#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(forwarding_control)
{
	sc_in<sc_lv<5> >	id_ex_writeregister;
	sc_in<sc_lv<5> >	id_ex_m_writeregister;
	sc_in<sc_lv<5> >	id_ex_m_wb_writeregister;
	sc_in<sc_logic> 	id_ex_regwrite;
	sc_in<sc_logic> 	id_ex_m_regwrite;
	sc_in<sc_logic> 	id_ex_m_wb_regwrite;
	sc_in<sc_lv<5> >	rs;
	sc_out<sc_lv<2> >	id_fw_ctrl;

	void do_forwarding_control();
	
	SC_CTOR(forwarding_control)
	{
		SC_METHOD(do_forwarding_control);
		sensitive << id_ex_writeregister << id_ex_m_writeregister;
		sensitive << id_ex_m_wb_writeregister << id_ex_regwrite;
		sensitive << id_ex_m_regwrite << id_ex_m_wb_regwrite << rs;
	}
};
