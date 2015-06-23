#include "mux.h"

void mux::do_mux()
{
	sc_uint<3> usel;
	usel = sel.read();
	
	switch(usel)
	{
		case 0: out_mux.write(in_0);
		break;
	
		case 1: out_mux.write(in_1);
		break;

		case 2: out_mux.write(in_2);
		break;
	
		case 3: out_mux.write(in_3);
		break;
	
		case 4: out_mux.write(in_4);
		break;
		
		case 5: out_mux.write(in_5);
		break;
	
		case 6: out_mux.write(in_6);
		break;
	
		case 7: out_mux.write(in_7);
		break;
	
		default: out_mux.write(in_0);
		break;
	}
} 
