#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(reg_pc)
{
	sc_in<bool> 		in_clk;
	sc_in<bool> 		reset;
	
	sc_in<bool> 		insthold;
	sc_in<bool> 		datahold;
	
	sc_in<sc_logic>		enable_pc;
	
	sc_in<sc_lv<32> > 	pc_in;
	sc_out<sc_lv<32> > 	pc_out;
	
	sc_out<sc_uint<32> > 	instaddr;
	sc_out<sc_lv<32> > 	instdatawrite;
	
	sc_out<sc_logic> 	instreq;
	sc_out<sc_logic> 	instrw;
	
	
	void do_reg_pc();
	
	SC_CTOR(reg_pc)
	{
		SC_METHOD(do_reg_pc);
		sensitive_pos << in_clk;
	}
};
