// Modulo decoder  
// Diee Cagliari
// V 1.0 

#include <systemc.h>

SC_MODULE(decoder)
{
	sc_in<sc_uint<32> >	dataaddr;
	
	sc_out<sc_lv<3> >	sel;
	
	void do_decoder();
	
	SC_CTOR(decoder)
	{
		SC_METHOD(do_decoder);
		sensitive << dataaddr;
	};

};
