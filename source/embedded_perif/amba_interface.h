#include "systemc.h"

SC_MODULE(amba_interface)
{
	sc_in<bool>		in_clk;
	sc_in<bool>		reset;
	
	sc_out<sc_lv<32> >	dataread;
	sc_in<sc_lv<32> >	datawrite;
	sc_in<sc_logic>  	datarw;
	sc_in<sc_logic> 	datareq;
	sc_in<sc_uint<32> >	dataaddr;
	sc_in<sc_lv<2> >	databs;
	sc_out<bool> 		datahold;

	SC_CTOR(amba_interface)
	{
	
	}
};
