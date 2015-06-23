#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_alu1)
{
	sc_in<sc_lv<32> >	if_id_inst;
	sc_in<sc_logic>  	id_shamt_ctrl;
	sc_in<sc_logic>  	id_pc_store;
	sc_out<sc_lv<32> >	id_alu1;
	sc_in<sc_lv<32> >	if_id_next_pc;
	sc_in<sc_lv<32> >	cp0_reg_out;
	sc_in<sc_lv<32> >	id_mux_fw1;
	sc_in<sc_logic>  	id_mfc0;
	
	void do_mux_alu1();
	
	SC_CTOR(mux_alu1)
	{
		SC_METHOD(do_mux_alu1);
		sensitive << id_pc_store << id_shamt_ctrl << if_id_inst << id_mux_fw1;
		sensitive << if_id_next_pc << cp0_reg_out << id_mfc0;
	}
};
