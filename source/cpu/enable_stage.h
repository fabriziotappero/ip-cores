#include "systemc.h"
#include "../constants/constants.h"

SC_MODULE(enable_stage)
{
	sc_in<sc_logic>		if_exception;
	sc_in<sc_logic>		id_exception;
	sc_in<sc_logic>		ex_exception;
	sc_in<sc_logic>		mem_exception;
	sc_in<sc_logic>		wb_exception;
	
	sc_out<sc_logic>	enable_pc;
	sc_out<sc_logic>	enable_fetch;
	sc_out<sc_logic>	enable_decode;
	sc_out<sc_logic>	enable_execute;
	sc_out<sc_logic>	enable_memstage;
	
	void do_enable_stage();
	
	SC_CTOR(enable_stage)
	{
		SC_METHOD(do_enable_stage);
		sensitive << if_exception << id_exception;
		sensitive << ex_exception << mem_exception;
		sensitive << wb_exception ;
	}
}; 
