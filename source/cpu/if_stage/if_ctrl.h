#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(if_ctrl)
{
	sc_in<sc_logic>		IBUS;
	sc_in<sc_logic>		inst_addrl;
	sc_out<sc_logic>	if_exception;
	
	void do_if_ctrl();
	
	SC_CTOR(if_ctrl)
	{
		SC_METHOD(do_if_ctrl);
		sensitive << IBUS << inst_addrl;
	}
}; 
