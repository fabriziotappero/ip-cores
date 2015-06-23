#include "mux_jump.h"

void mux_jump::do_mux_jump()
{
	sc_lv<32> iinp = if_id_next_pc.read();
	sc_lv<32> iii =  if_id_inst.read();
  
	if(id_select_jump == SC_LOGIC_0)
	{
	   id_jmp_tar.write((iinp.range(31,28),iii.range(25,0),"00"));
	}
	else
	{
	   id_jmp_tar.write(id_mux_fw1.read());
	}
} 
