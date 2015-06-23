#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(exception)
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;
	
	sc_in<sc_logic> 	m_wb_IBUS;
	sc_in<sc_logic> 	m_wb_inst_addrl;
	sc_in<sc_logic> 	m_wb_syscall_exception;
	sc_in<sc_logic> 	m_wb_illegal_instruction;
	sc_in<sc_logic> 	m_wb_ovf_excep;
	sc_in<sc_logic> 	m_wb_DBUS;
	sc_in<sc_logic> 	m_wb_data_addrl;
	sc_in<sc_logic> 	m_wb_data_addrs;
	sc_in<sc_uint<32> >	m_wb_dataaddr;
	sc_in<sc_uint<32> >	m_wb_instaddr;
	sc_in<sc_lv<4> >	cp0_inst;
	
	//**************INTERRUPT****************
	sc_in<bool>		m_wb_interrupt_signal;
	//sc_out<sc_logic>	interrupt_exception;
	//sc_in<sc_uint<32> >	ex_m_instaddr;
	sc_signal<sc_logic>	to_SR;
	//***************************************	
	
	sc_out<sc_lv<32> >	cause;
	sc_out<bool>	check_excep;
	sc_out<sc_uint<32> >	to_EPC;
	sc_out<sc_uint<32> >	to_BadVAddr;
	
	
	
	void compute_cause();
	
	void check_for_exception();
	
	void check_for_interrupt();
	
	void check_for_Page_fault();
	
	void save_EPC();
	
	void handling_status_register();
	
	SC_CTOR(exception)
	{
		SC_METHOD(compute_cause);
		sensitive << m_wb_IBUS << m_wb_inst_addrl << m_wb_syscall_exception;
		sensitive << m_wb_illegal_instruction << m_wb_ovf_excep;
		sensitive << m_wb_DBUS << m_wb_data_addrl << m_wb_data_addrs;
		sensitive << m_wb_interrupt_signal;
		
		SC_METHOD(check_for_exception);
		sensitive << m_wb_IBUS << m_wb_inst_addrl << m_wb_syscall_exception;
		sensitive << m_wb_illegal_instruction << m_wb_ovf_excep;
		sensitive << m_wb_DBUS << m_wb_data_addrl << m_wb_data_addrs << m_wb_interrupt_signal;
		
		SC_METHOD(check_for_interrupt);
		//sensitive << interrupt_signal;
		
		SC_METHOD(check_for_Page_fault);
		sensitive << cause << m_wb_instaddr << m_wb_dataaddr;
		
		SC_METHOD(save_EPC);
		sensitive << check_excep;
		sensitive << m_wb_instaddr;
		
		SC_METHOD(handling_status_register);
		sensitive << m_wb_interrupt_signal;
		sensitive << cp0_inst << reset;
	}
};
