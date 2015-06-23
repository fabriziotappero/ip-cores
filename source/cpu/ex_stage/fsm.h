 //fsm.h
#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

enum state {IDLE, STAGE1, STAGE2, STAGE3, STAGE4};

SC_MODULE(fsm)
{
	sc_in<bool>		in_clk;
	sc_in<bool>		reset;
	sc_in<sc_lv<6> > 	id_ex_alu_function;
	sc_in<sc_lv<6> >	id_ex_alu_opcode;
	sc_out<bool> 		ready;
	sc_out<bool>		hold_pipe;
	
	sc_signal<state> 	current_state ,next_state;
	
	void update_state();
	void do_logic();
	
	SC_CTOR(fsm)
	{
		SC_METHOD(update_state);
		sensitive_pos << in_clk;
				
		SC_METHOD(do_logic);
		sensitive << id_ex_alu_function;
		sensitive << id_ex_alu_opcode;
		sensitive << current_state;
	}
};
