#include "reg_if.h"
/*
enable_fetch: segnale posto ad 1 per il normale funzionamento della pipeline.
Se si verifica un eccezione il coprocessore setta questo segnale a zero inibendo 
la scrittura sui registri di pipeline di questo stadio. 
Segnale per la gestione delle eccezioni  IBUS  e inst_addrl
*/


void reg_if::do_reg_if()
{
	if(reset.read() == true)
	{
		if_id_next_pc.write(0);
		if_id_inst.write(0);
		if_id_IBUS.write(SC_LOGIC_0);
		if_id_inst_addrl.write(SC_LOGIC_0);
		if_id_instaddr.write(0);
	}
	else
	{
		if((insthold.read() == false) && (datahold.read() == false) && (enable_fetch.read() == SC_LOGIC_1))
		{
			if_id_next_pc.write(if_pc_add.read());
			if_id_inst.write(instdataread.read());
			if_id_IBUS.write(IBUS.read());
			if_id_inst_addrl.write(inst_addrl.read());
			if_id_instaddr.write(pc_if_instaddr.read());
		}
		else 
		    if((insthold.read() == false) && (datahold.read() == false) && (enable_fetch.read() == SC_LOGIC_0))
		    {
			// QUESTA PaRTE �DA RIVEDERE!!!!
			if_id_next_pc.write(0);
			if_id_inst.write(0);
			if_id_IBUS.write(IBUS.read());
			if_id_inst_addrl.write(inst_addrl.read());
			if_id_instaddr.write(pc_if_instaddr.read());
		    }
		    else;
	}
}
