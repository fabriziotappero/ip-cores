#include "systemc.h"
#include "../../constants/config.h"
#include "../../constants/constants.h"

SC_MODULE(alu)
{
	sc_in<sc_lv<32> >	id_ex_alu1;
	sc_in<sc_lv<32> >	id_ex_alu2;
	sc_in<sc_lv<6> >	id_ex_alu_ctrl;
	sc_in<sc_logic> 	id_ex_equal;
	sc_in<sc_lv<5> >	id_ex_alu_sa;
	sc_out<sc_logic>	ovf_excep;
	sc_out<sc_logic>	carry;
	sc_out<sc_lv<32> >	ex_alu_s;
	sc_out<sc_lv<32> >	ex_id_forward_s;
  
	void do_alu();

	SC_CTOR(alu)
	{
		SC_METHOD(do_alu);
		sensitive << id_ex_equal << id_ex_alu_ctrl;
		sensitive << id_ex_alu1 << id_ex_alu2;
		sensitive << id_ex_alu_sa;
	}
};
