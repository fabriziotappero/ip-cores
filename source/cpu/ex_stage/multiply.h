#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(multiply)
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;

#ifdef _MULT_PIPELINE_
	sc_in<bool> ready;
#endif
	
	sc_signal<sc_lv<64> > stage0;

#ifdef _MULT_PIPELINE_
	#if(DEPTH_MULT_PIPE == 1) 
	   sc_signal<sc_lv<64> > stage1;
	#else
	   #if(DEPTH_MULT_PIPE == 2) 
	      sc_signal<sc_lv<64> > stage1, stage2;
	   #else
	      #if(DEPTH_MULT_PIPE == 3) 
	         sc_signal<sc_lv<64> > stage1, stage2, stage3;
	      #else
	         #if(DEPTH_MULT_PIPE == 4) 
	            sc_signal<sc_lv<64> > stage1, stage2, stage3, stage4;
	         #else
	            cout << "Out Of Bound! Check DEPTH_MULT_PIPE in config.h!" << endl;
		    sc_stop();
	         #endif
	      #endif
	   #endif
	#endif
#endif
	sc_in<sc_lv<32> >	id_ex_alu1;
	sc_in<sc_lv<32> >	id_ex_alu2;
	sc_in<sc_lv<6> >	id_ex_alu_function;
	sc_in<sc_lv<6> > 	id_ex_alu_opcode;
	
	sc_out<sc_lv<32> >	hi;
	sc_out<sc_lv<32> >	lo;
		
	void do_multiply();
	
	void split();
#ifdef _MULT_PIPELINE_	
	void do_pipe();
#endif
	
SC_CTOR(multiply)
{

		SC_METHOD(do_multiply);
			sensitive << id_ex_alu1;
			sensitive << id_ex_alu2;
			sensitive << id_ex_alu_function;
			sensitive << id_ex_alu_opcode;
#ifdef _MULT_PIPELINE_
		SC_METHOD(do_pipe);
			sensitive_pos << in_clk;
#endif
		SC_METHOD(split);
			#ifndef _MULT_PIPELINE_
			sensitive << stage0;
			#endif
			#ifdef _MULT_PIPELINE_
			   #if(DEPTH_MULT_PIPE == 1) 
	   			sensitive << stage1;
			   #else
	   		     #if(DEPTH_MULT_PIPE == 2) 
	      			sensitive << stage2;
	   		     #else
	      			#if(DEPTH_MULT_PIPE == 3) 
	        		   sensitive << stage3;
	      			#else
	         		   #if(DEPTH_MULT_PIPE == 4) 
	            			sensitive << stage4;
	         		   #else
	            			cout << "Out Of Bound! Check DEPTH_MULT_PIPE in config.h!" << endl;
	        		   #endif
	      			#endif
	   		     #endif
			  #endif
			#endif
	}
};
