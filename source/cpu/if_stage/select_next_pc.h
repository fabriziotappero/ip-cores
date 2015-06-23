#include "systemc.h"
#define _DOBRANCH_ 1
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(select_next_pc)
{
	sc_in<sc_lv<32> > 	new_pc;
	sc_in<sc_logic> 	load_epc;
	sc_in<sc_logic> 	id_ctrl;
	sc_in<sc_logic> 	id_branch;
	sc_in<sc_lv<32> > 	if_pc_add;
	sc_in<sc_lv<32> > 	id_new_pc;
	sc_in<sc_lv<32> > 	id_jmp_tar;
	
	sc_out<sc_lv<32> >	pc_in;
	
	
	void do_select_next_pc();
	
	SC_CTOR(select_next_pc)
	{
		SC_METHOD(do_select_next_pc);
		sensitive << if_pc_add << id_jmp_tar << id_new_pc << id_branch << id_ctrl << new_pc << load_epc;
	
	}
};
