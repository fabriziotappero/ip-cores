#include "systemc.h"

enum FSM_STATE {Idle, State1};

SC_MODULE(flag_interr)
{
	sc_in<bool>	in_clk, reset;
	sc_in<bool>	interrupt_in;
	sc_out<bool>	interrupt_out;
	
	sc_signal<FSM_STATE> current_state, next_state;
	
	void do_fsm_update();
	void do_fsm_ctrl();
	
	SC_CTOR(flag_interr)
	{
		SC_METHOD(do_fsm_update);
		sensitive_pos << in_clk;
		
		SC_METHOD(do_fsm_ctrl);
		sensitive << reset << in_clk;
		sensitive << current_state;
	}
};
