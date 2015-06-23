#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(reg_if)
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;
	sc_in<bool> insthold;
	sc_in<bool> datahold;
	
	sc_in<sc_lv<32> > instdataread;
	sc_in<sc_lv<32> > if_pc_add;
	
	sc_out<sc_lv<32> > if_id_inst;
	sc_out<sc_lv<32> > if_id_next_pc;
	
	sc_in<sc_logic>		IBUS;
	sc_in<sc_logic>		inst_addrl;
	sc_out<sc_logic>	if_id_IBUS;
	sc_out<sc_logic>	if_id_inst_addrl;
	
	sc_in<sc_uint<32> >	pc_if_instaddr;
	sc_out<sc_uint<32> >	if_id_instaddr;
	sc_in<sc_logic>		enable_fetch;
	
	void do_reg_if();
	
	SC_CTOR(reg_if)
	{
		SC_METHOD(do_reg_if);
		sensitive_pos << in_clk;
	}
};
