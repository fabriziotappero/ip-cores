#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(comparator)
{
	sc_in<sc_lv<32> >	id_mux_fw1;
	sc_in<sc_lv<32> >	id_mux_fw2;
	sc_in<sc_lv<3> >	id_branch_select;
	sc_out<sc_logic>	id_equal;
	sc_out<sc_logic>	id_branch;
	
	void do_comparator();
	
	SC_CTOR(comparator)
	{
		SC_METHOD(do_comparator);
		sensitive << id_mux_fw1 << id_mux_fw2;
		sensitive << id_branch_select;
	}
};
