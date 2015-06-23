// Multiplexer 8 -> 1
// V 1.0 
// Diee Cagliari

#include <systemc.h>

SC_MODULE(mux)
{
	sc_in<sc_lv<32> > 	in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7;
	sc_out<sc_lv<32> > 	out_mux;
	
	sc_in<sc_lv<3> >	sel;
	
	void do_mux();
	
	SC_CTOR(mux)
	{
		SC_METHOD(do_mux);
		sensitive << in_0 << in_1 << in_2 << in_3 << in_4 << in_5 << in_6 << in_7;
		sensitive << sel;
		
	}
};

