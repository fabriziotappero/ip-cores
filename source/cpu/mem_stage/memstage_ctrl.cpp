#include "memstage_ctrl.h"

void memstage_ctrl::do_memstage_ctrl()
{
	if((ex_m_IBUS.read() == SC_LOGIC_1)          || 
	   (ex_m_inst_addrl.read() == SC_LOGIC_1)    ||
	   (ex_m_syscall_exception.read() == SC_LOGIC_1)   ||
	   (ex_m_illegal_instruction.read() == SC_LOGIC_1) ||
	   (ex_m_ovf_excep.read() == SC_LOGIC_1) ||
	   (DBUS.read() == SC_LOGIC_1)    ||
	   (data_addrl.read() == SC_LOGIC_1)   ||
	   (data_addrs.read() == SC_LOGIC_1)   ||
	   (interrupt_signal.read() == SC_LOGIC_1))
	   mem_exception.write(SC_LOGIC_1);
	else
	   mem_exception.write(SC_LOGIC_0);

};
