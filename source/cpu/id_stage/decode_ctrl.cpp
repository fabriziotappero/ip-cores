#include "decode_ctrl.h"

void decode_ctrl::do_decode_ctrl()
{
	if((if_id_IBUS.read() == SC_LOGIC_1)          || 
	   (if_id_inst_addrl.read() == SC_LOGIC_1)    ||
	   (syscall_exception.read() == SC_LOGIC_1)   ||
	   (illegal_instruction.read() == SC_LOGIC_1))
	   id_exception.write(SC_LOGIC_1);
	else
	   id_exception.write(SC_LOGIC_0);

};
