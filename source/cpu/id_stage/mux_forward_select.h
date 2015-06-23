#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_forward_select)
{
	sc_in<sc_lv<32> >	id_reg;
	sc_in<sc_lv<32> >	ex_id_forward;
	sc_in<sc_lv<32> >	m_id_forward;
	sc_in<sc_lv<32> >	wb_id_forward;
	sc_in<sc_lv<2> >	id_fw_ctrl;
	
	sc_out<sc_lv<32> >	id_mux_fw;
	
	void do_mux_forward_select();
	
	SC_CTOR(mux_forward_select)
	{
		SC_METHOD(do_mux_forward_select);
		sensitive << id_reg << ex_id_forward << m_id_forward << wb_id_forward << id_fw_ctrl;
	}
}; 
