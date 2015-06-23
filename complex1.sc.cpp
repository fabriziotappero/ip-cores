#include "complex1.sc.h"  

void cell1::cell()  
	{
	complex<sc_uint<8> > x, y; 
	complex<sc_uint<8> > o;
	
	
    x.set_real( in1_re.read() );
    x.set_imag( in1_im.read() );
    y.set_real( in2_re.read() );
    y.set_imag( in2_im.read() );
        
    o=sqrt(x);	   
	
    out_re.write( o.get_real() );
    out_im.write( o.get_imag() );
	
	}
	