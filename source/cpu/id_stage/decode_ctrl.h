#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(decode_ctrl)
{
	sc_in<sc_logic>		if_id_IBUS;
	sc_in<sc_logic>		if_id_inst_addrl;
	sc_in<sc_logic>		illegal_instruction;
	sc_in<sc_logic>		syscall_exception;
	sc_out<sc_logic>	id_exception;
	
	void do_decode_ctrl();
	
	SC_CTOR(decode_ctrl)
	{
		SC_METHOD(do_decode_ctrl);
		sensitive << if_id_IBUS << if_id_inst_addrl;
		sensitive << syscall_exception << illegal_instruction;
	}
}; 
