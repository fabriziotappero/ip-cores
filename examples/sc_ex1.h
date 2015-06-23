#include "systemc.h"


SC_MODULE( icu ) {                   // module name

  sc_in<bool>            clk;
  sc_in<bool>            reset;
  sc_in<bool>            alu_ready;
  sc_in<sc_uint<4> >     instr_in;
  sc_out<bool>           alu_start;
  sc_out< sc_uint<8> >   control_out;

  /*   
  sc_signal<sc_uint<8> > pipe_0;  // internal "globals"
  sc_signal<sc_uint<8> > pipe_1;
  sc_signal<sc_uint<8> > pipe_2;
  sc_signal<sc_uint<8> > pipe_3;
  */

  void decoder_io();                 // tasks in cpp (fns?)
   
  SC_CTOR(icu) {                     // constructors for module
    SC_METHOD( decoder_io );         // list of methods
    sensitive_pos( clk );            //   event (this pos edge)
    // if others here forms OR to make event
  }
};
