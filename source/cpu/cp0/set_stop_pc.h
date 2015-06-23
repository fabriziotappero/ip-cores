#include "systemc.h"
#include "../../constants/constants.h"

enum State {IdLe, STATE1, STATE2, STATE3, STATE4};
SC_MODULE(set_stop_pc)
{
	sc_in<bool>		in_clk;		// clock
	sc_in<bool>		reset;		// reset
	
	sc_in<bool>		x_insthold;	// freeze signal from InstMemory
	sc_out<bool>		insthold;	// output freeze signal
	
	sc_in<sc_lv<32> >	pc_in;		// program counter from PC_STAGE
	sc_in<sc_lv<4> >	cp0_inst;	// coprocessor CP0 instruction
	sc_out<sc_lv<32> >	new_pc;		// next PC when exception occur!
	sc_out<sc_logic>	load_epc;	// signal that tell to PC STAGE to load Exception_PC
	sc_in<bool>	        check_excep;	// signal that tell if there is an exception
	sc_in<sc_uint<32> >	EPC_FOR_RFE;	// PC that must be loaded when exception routine finish!
	
	sc_signal<State> 	currentstate , nextstate;	// State from Finite State Machine
	
	void update_state();
	void do_set_stop_pc();
	
	SC_CTOR(set_stop_pc)
	{
		SC_METHOD(update_state);
		sensitive_pos << in_clk;
		
		SC_METHOD(do_set_stop_pc);
		sensitive << reset;
		sensitive << x_insthold;
		sensitive << check_excep;
		sensitive << currentstate;
		sensitive << cp0_inst;
		sensitive << EPC_FOR_RFE;
		
	}
}; 
