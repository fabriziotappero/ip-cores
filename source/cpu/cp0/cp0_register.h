#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(cp0_register)
{
	sc_in<bool>		in_clk;
	sc_in<bool>		reset;
	sc_in<bool>		insthold;
	
	sc_signal<sc_lv<32> >	cp0regs[32];
	
	sc_in<sc_uint<5> > 	reg_no;
	sc_in<sc_logic>    	reg_rw;
	sc_in<sc_lv<32> >  	reg_rs;
	sc_out<sc_lv<32> > 	reg_out;
	
	sc_in<bool> 	check_excep;
	//sc_in<sc_logic>		interrupt_signal;
	sc_in<sc_lv<32> >	cause;
	sc_in<sc_uint<32> >	to_BadVAddr;
	sc_in<sc_uint<32> >	to_EPC;
	
	sc_in<sc_lv<4> >	cp0_inst;
	
	sc_out<sc_uint<32> >	EPC_FOR_RFE;
	sc_signal<sc_lv<32> >	Temp_Status_Register;
	
	sc_out<sc_logic>	enable_interrupt;
	sc_out<sc_logic>	enable_kernel_mode;
	
	void cp0_register_read();
	void cp0_register_write();
	void cp0_status_register();
	void enable_interrupt_and_OS();
	
	SC_CTOR(cp0_register)
	{
		SC_METHOD(cp0_register_read);
		sensitive << reg_no  << cp0regs[0] << cp0regs[1] << cp0regs[2];
		sensitive << cp0regs[3]  << cp0regs[4]  << cp0regs[5]  << cp0regs[6]  << cp0regs[7];
		sensitive << cp0regs[8]  << cp0regs[9]  << cp0regs[10] << cp0regs[11] << cp0regs[12];
		sensitive << cp0regs[13] << cp0regs[14] << cp0regs[15] << cp0regs[16] << cp0regs[17];
		sensitive << cp0regs[18] << cp0regs[19] << cp0regs[20] << cp0regs[21] << cp0regs[22];
		sensitive << cp0regs[23] << cp0regs[24] << cp0regs[25] << cp0regs[26] << cp0regs[27];
		sensitive << cp0regs[28] << cp0regs[29] << cp0regs[30] << cp0regs[31];
		
		SC_METHOD(cp0_register_write);
		sensitive_neg << in_clk;
		//sensitive << cause << to_EPC << to_BadVAddr;
		//sensitive << check_excep;
		
		SC_METHOD(cp0_status_register);
		sensitive << check_excep << cp0_inst << cp0regs[12];
		
		SC_METHOD(enable_interrupt_and_OS);
		sensitive << cp0regs[12];
	}



}; 
