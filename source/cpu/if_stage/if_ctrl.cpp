#include "if_ctrl.h"

void if_ctrl::do_if_ctrl()
{
	if((IBUS.read() == SC_LOGIC_1) || (inst_addrl.read() == SC_LOGIC_1))
	   if_exception.write(SC_LOGIC_1);
	else
	   if_exception.write(SC_LOGIC_0);

} 
