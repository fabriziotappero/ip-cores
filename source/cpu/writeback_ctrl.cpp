#include "writeback_ctrl.h"

void writeback_ctrl::do_writeback_ctrl()
{
	if((m_wb_IBUS.read() == SC_LOGIC_1)          || 
	   (m_wb_inst_addrl.read() == SC_LOGIC_1)    ||
	   (m_wb_syscall_exception.read() == SC_LOGIC_1)   ||
	   (m_wb_illegal_instruction.read() == SC_LOGIC_1) ||
	   (m_wb_ovf_excep.read() == SC_LOGIC_1) ||
	   (m_wb_DBUS.read() == SC_LOGIC_1)    ||
	   (m_wb_data_addrl.read() == SC_LOGIC_1)   ||
	   (m_wb_data_addrs.read() == SC_LOGIC_1)   ||
	   (m_wb_interrupt_signal.read() == SC_LOGIC_1))
	   wb_exception.write(SC_LOGIC_1);
	else
	   wb_exception.write(SC_LOGIC_0);
	
	
	
	
	
	
	
	
} 
