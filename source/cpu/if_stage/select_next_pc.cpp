#include "select_next_pc.h"

void select_next_pc::do_select_next_pc()
{
	#ifdef _DOBRANCH_
	
		//sc_lv<32> temp = new_pc;
		
		if (load_epc.read() == SC_LOGIC_1)
		{ 
			pc_in.write(new_pc.read());
		}
		else
		{
			if ((id_ctrl.read() == 0) && (id_branch.read() == 0))
				pc_in.write(if_pc_add.read());
			else
				if ((id_ctrl.read() == 0) && (id_branch.read() == 1))
					pc_in.write(id_new_pc.read());
				else
					if ((id_ctrl.read() == 1) && (id_branch.read() == 0))
						pc_in.write(id_jmp_tar.read());
					else // 1 && 1 - should never happen!
						pc_in.write(id_jmp_tar.read());
		}
	#else
		pc_in.write(if_pc_add.read());
	#endif
} 
