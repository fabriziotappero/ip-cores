#include "reg_pc.h"

void reg_pc::do_reg_pc()
{
	sc_lv<32> pc;
	
	instdatawrite = WORD_ZERO;
	
	if(reset.read() == true)
	{
		instreq.write(SC_LOGIC_1);
		instrw.write(SC_LOGIC_0);
	
		instaddr = pc = PC_START;
		pc_out = pc = PC_START;
	}
	else
	{
		if((datahold.read() == false) && (insthold.read() == false) && (enable_pc.read() == SC_LOGIC_1))
		{
			instreq.write(SC_LOGIC_1);
			instrw.write(SC_LOGIC_0);
			pc = pc_in.read();
			instaddr.write(pc);
			pc_out.write(pc_in.read());
		}
		else 
		   if((datahold.read() == false) && (insthold.read() == false) && (enable_pc.read() == SC_LOGIC_0))
		   {
			instreq.write(SC_LOGIC_0);
			instrw.write(SC_LOGIC_0);
		
			instaddr = pc = PC_START;
			pc_out = pc = PC_START;
		   }
	}
} 
