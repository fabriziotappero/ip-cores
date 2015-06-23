/* 
This is a example code that does nothing but uses the new
features included in new versions
*/


#include "systemc.h"

SC_MODULE(fsm){

   sc_in<bool> clk;
   sc_in<bool> rst,
   sc_in<bool> input1, input2;
   sc_out<sc_uint<2> > a,b,w;

   void regs();
   void fsm_proc();
   void dummy_proc();
   
   sc_signal<sc_uint<2> > state,next_state;
   sc_signal< sc_uint<32> > array[12];
   
   SC_CTOR(fsm){
 
     SC_METHOD(regs);
     sensitive_pos(clk);
     sensitive_neg(rst);
	 
     SC_METHOD(fsm_proc);
     sensitive(state);
     sensitive << input1;
     sensitive(input2);
     
     SC_METHOD(dummy_proc);
     sensitive << input1;
	  
 }
};
