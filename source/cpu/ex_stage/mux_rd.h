#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(mux_rd)
{
	sc_in<sc_lv<32> >	out_lo;
	sc_in<sc_lv<32> >	out_hi;
	sc_in<sc_lv<32> >	in_ex_id_forward_s;
	sc_in<sc_lv<32> >	in_ex_alu_s;
	sc_in<sc_lv<6> >	id_ex_alu_ctrl;
	sc_out<sc_lv<32> >	out_ex_id_forward_s;
	sc_out<sc_lv<32> >	out_ex_alu_s;
	
	void do_mux_rd();
	
	SC_CTOR(mux_rd)
	{
		SC_METHOD(do_mux_rd);
		sensitive << out_lo << out_hi << id_ex_alu_ctrl << in_ex_id_forward_s << in_ex_alu_s;
	}
} ;
