#include "systemc.h"
#include "../constants/constants.h" 

SC_MODULE(writeback_ctrl)
{
	sc_in<sc_logic>		m_wb_IBUS;
	sc_in<sc_logic>		m_wb_inst_addrl;
	sc_in<sc_logic>		m_wb_syscall_exception;
	sc_in<sc_logic>		m_wb_illegal_instruction;
	sc_in<sc_logic>		m_wb_ovf_excep;
	sc_in<sc_logic>		m_wb_DBUS;
	sc_in<sc_logic>		m_wb_data_addrl;
	sc_in<sc_logic>		m_wb_data_addrs;
	sc_in<bool>		m_wb_interrupt_signal;
	
	
	sc_out<sc_logic>	wb_exception;
	
	void do_writeback_ctrl();
	
	SC_CTOR(writeback_ctrl)
	{
		SC_METHOD(do_writeback_ctrl);
		sensitive << m_wb_IBUS << m_wb_inst_addrl << m_wb_syscall_exception;
		sensitive << m_wb_illegal_instruction << m_wb_ovf_excep;
		sensitive << m_wb_DBUS << m_wb_data_addrl << m_wb_data_addrs << m_wb_interrupt_signal;
	}
};
