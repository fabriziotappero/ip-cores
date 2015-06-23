/* 
This is a example code that does nothing but uses the new
features included in new versions
*/


#include "systemc.h"

SC_MODULE(dummy1){

   sc_in<bool> clk;
   sc_in<bool> rst;
   sc_in<sc_uint<2> > input1, input2;
   sc_out< sc_uint<2> > a,b,w;

   enum state_t {A,B};
   sc_signal<state_t> state,next_state;
   
   enum {S0,S1,S2,S3,EE} estado;
   enum {AAA} est;
   

   sc_signal<sc_uint<4> > temp;
   sc_signal<sc_uint<2>> b_a;

   void regs();
   void fsm_proc();
   sc_uint<2> func1 (sc_uint<2> a, sc_uint<2> b);
  
   moduleA *moda;
   moduleA *modb;
   
   SC_CTOR(dummy1){
 
     moda = new moduleA("MODA");
     
     moda->m1_in(b_a);
     moda->m1_out(w);
     
     modb = new moduleA("MODB");
     
     modb->m1_in(input2);
     modb->m1_out(b_a);


     SC_METHOD(regs);
     sensitive_pos(clk);
     sensitive_neg(rst);
	 
     SC_METHOD(fsm_proc);
     sensitive(state);
     sensitive << input1;
     sensitive(input2);
	  
 }
};
