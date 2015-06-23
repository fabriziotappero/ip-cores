#include "systemc.h"
#include "../constants/constants.h"

SC_MODULE(mux_instaddr)
{
	sc_in<sc_uint<32> >	m_wb_instaddr;
	sc_in<sc_uint<32> >	ex_m_instaddr;
	sc_in<sc_lv<32> >	ex_mem_inst;
	
	sc_in<bool>		m_wb_interrupt_signal;
	
	sc_out<sc_uint<32> >	m_wb_instaddr_s;
	
	
	void do_mux_instaddr();
	
	SC_CTOR(mux_instaddr)
	{
		SC_METHOD(do_mux_instaddr);
		sensitive << m_wb_instaddr << ex_m_instaddr << m_wb_instaddr;
		sensitive << ex_mem_inst;
	}
};
