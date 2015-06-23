#include "systemc.h"
#include "../../constants/constants.h" 

SC_MODULE(reg_mem)
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;

	sc_in<bool> insthold;
	sc_in<bool> datahold;

	sc_out<sc_lv<32> > 	wb_id_forward;
	sc_out<sc_lv<5> > 	id_ex_m_wb_writeregister;
	sc_out<sc_logic> 	id_ex_m_wb_regwrite;
	sc_in<sc_lv<32> >	id_store;
	sc_in<sc_lv<5> >	id_ex_m_writeregister;
	sc_in<sc_logic> 	id_ex_m_regwrite;
	
	// EXCEPTION SIGNALS
	sc_in<sc_logic>		ex_m_IBUS;
	sc_in<sc_logic>		ex_m_inst_addrl;
	sc_in<sc_logic>		ex_m_syscall_exception;
	sc_in<sc_logic>		ex_m_illegal_instruction;
	sc_in<sc_logic>		ex_m_ovf_excep;
	sc_in<sc_logic>		DBUS;
	sc_in<sc_logic>		data_addrl;
	sc_in<sc_logic>		data_addrs;
	
	// exception status vector -> to  CPO-Cause
	sc_out<sc_logic>	m_wb_IBUS;
	sc_out<sc_logic>	m_wb_inst_addrl;
	sc_out<sc_logic>	m_wb_syscall_exception;
	sc_out<sc_logic>	m_wb_illegal_instruction;
	sc_out<sc_logic>	m_wb_ovf_excep;
	sc_out<sc_logic>	m_wb_DBUS;
	sc_out<sc_logic>	m_wb_data_addrl;
	sc_out<sc_logic>	m_wb_data_addrs;
	
	sc_out<sc_uint<32> >	m_wb_instaddr;	//se un bit dell ESV �pari ad 1 allora questo �l'indirizzo della vittima
	sc_in<sc_uint<32> >	ex_m_instaddr;
	sc_in<sc_uint<32> >	ex_m_dataaddr;
	sc_out<sc_uint<32> >	m_wb_dataaddr;
	
	
		sc_in<sc_lv<32> > 	ex_mem_inst;  // instruction coming from EX_STAGE
		sc_out<sc_lv<32> > 	mem_wb_inst;  // instruction to WRITE_BACK Phases
	
	
	sc_in<bool>		interrupt_signal;
	sc_out<bool>		m_wb_interrupt_signal;
	
	sc_in<sc_logic>		enable_memstage;
	
	void do_reg_mem();
	
	SC_CTOR(reg_mem)
	{
		SC_METHOD(do_reg_mem);
		sensitive_pos << in_clk;
	}
};
