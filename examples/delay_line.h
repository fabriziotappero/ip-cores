#include "systemc.h"

SC_MODULE( delay_line ) {

  sc_in<bool>            clk;
  sc_in<bool>            reset;
  sc_in<sc_uint<8> >     num_in;
  sc_out< sc_uint<8> >   num_out;
   
  sc_signal<sc_uint<8> > pipe_0;
  sc_signal<sc_uint<8> > pipe_1;
  sc_signal<sc_uint<8> > pipe_2;
  sc_signal<sc_uint<8> > pipe_3;

  void registers();
   
  SC_CTOR(delay_line) {
    SC_METHOD( registers );
	  sensitive_pos( clk );
  }
};
