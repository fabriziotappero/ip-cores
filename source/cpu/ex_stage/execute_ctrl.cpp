#include "execute_ctrl.h"

void execute_ctrl::do_execute_ctrl()
{
	if((id_ex_IBUS.read() == SC_LOGIC_1)          || 
	   (id_ex_inst_addrl.read() == SC_LOGIC_1)    ||
	   (id_ex_syscall_exception.read() == SC_LOGIC_1)   ||
	   (id_ex_illegal_instruction.read() == SC_LOGIC_1) ||
	   (ovf_excep.read() == SC_LOGIC_1))
	   ex_exception.write(SC_LOGIC_1);
	else
	   ex_exception.write(SC_LOGIC_0);

};
