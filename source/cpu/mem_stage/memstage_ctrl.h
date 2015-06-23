#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(memstage_ctrl)
{
	sc_in<sc_logic>		ex_m_IBUS;
	sc_in<sc_logic>		ex_m_inst_addrl;
	sc_in<sc_logic>		ex_m_illegal_instruction;
	sc_in<sc_logic>		ex_m_syscall_exception;
	sc_in<sc_logic>		ex_m_ovf_excep;
	sc_in<sc_logic>		DBUS;
	sc_in<sc_logic>		data_addrl;
	sc_in<sc_logic>		data_addrs;
	sc_in<bool>		interrupt_signal;
	sc_out<sc_logic>	mem_exception;
	
	
	void do_memstage_ctrl();
	
	SC_CTOR(memstage_ctrl)
	{
		SC_METHOD(do_memstage_ctrl);
		sensitive << ex_m_IBUS << ex_m_inst_addrl;
		sensitive << ex_m_illegal_instruction << ex_m_syscall_exception;
		sensitive << ex_m_ovf_excep << DBUS << data_addrl << data_addrs << interrupt_signal;
	}
}; 
