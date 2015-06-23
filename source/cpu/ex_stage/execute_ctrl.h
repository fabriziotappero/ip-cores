#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(execute_ctrl)
{
	sc_in<sc_logic>		id_ex_IBUS;
	sc_in<sc_logic>		id_ex_inst_addrl;
	sc_in<sc_logic>		id_ex_illegal_instruction;
	sc_in<sc_logic>		id_ex_syscall_exception;
	sc_in<sc_logic>		ovf_excep;
	sc_out<sc_logic>	ex_exception;
	
	void do_execute_ctrl();
	
	SC_CTOR(execute_ctrl)
	{
		SC_METHOD(do_execute_ctrl);
		sensitive << id_ex_IBUS << id_ex_inst_addrl;
		sensitive << id_ex_illegal_instruction << id_ex_syscall_exception;
		sensitive << ovf_excep;
	}
}; 
