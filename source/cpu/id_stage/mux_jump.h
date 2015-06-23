#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(mux_jump)
{
	sc_in<sc_lv<32> >	if_id_next_pc;
	sc_in<sc_lv<32> >	if_id_inst;
	sc_in<sc_logic>  	id_select_jump;
	sc_in<sc_lv<32> >	id_mux_fw1;
	sc_out<sc_lv<32> >	id_jmp_tar;
	
	void do_mux_jump();
	
	SC_CTOR(mux_jump)
	{
		SC_METHOD(do_mux_jump);
		sensitive << id_select_jump << if_id_inst << if_id_next_pc << id_mux_fw1;
	}
};
