#include "systemc.h"
#include "../../constants/config.h"
#include "../../constants/constants.h"

SC_MODULE(reg_ex)
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;
	sc_in<bool> insthold;
	sc_in<bool> datahold;
	
	sc_in<sc_logic> 	addr_err;
	
	sc_in<sc_lv<32> >	ex_alu_s;
	sc_out<sc_lv<32> >	ex_m_alu;
	
	sc_in<sc_lv<32> >	id_ex_datastore;
	sc_out<sc_lv<32> >	id_ex_m_datastore;
	
	sc_in<sc_logic> 	id_ex_datareq;
	sc_out<sc_logic>	id_ex_m_datareq;
	
	sc_in<sc_logic> 	id_ex_datarw;
	sc_out<sc_logic>	id_ex_m_datarw;
	
	sc_in<sc_logic> 	id_ex_memtoreg;
	sc_out<sc_logic>	id_ex_m_memtoreg;
	
	sc_in<sc_lv<5> >	id_ex_writeregister_out;
	sc_out<sc_lv<5> >	id_ex_m_writeregister;
	
	sc_in<sc_logic> 	id_ex_regwrite_out;
	sc_out<sc_logic>	id_ex_m_regwrite;
	
	sc_in<sc_lv<2> >	id_ex_byteselect;
	sc_out<sc_lv<2> >	id_ex_m_byteselect;
	
	sc_in<sc_logic> 	id_ex_bssign;
	sc_out<sc_logic>	id_ex_m_bssign;
	
	sc_in<sc_lv<32> >	in_lo;
	sc_out<sc_lv<32> >	out_lo;
	
	sc_in<sc_lv<32> >	in_hi;
	sc_out<sc_lv<32> >	out_hi;
	
	sc_in<sc_logic> 	id_ex_IBUS;
	sc_in<sc_logic>		id_ex_inst_addrl;
	
		sc_in<sc_lv<32> > 	id_ex_inst;  		// instruction coming from ID_STAGE
		sc_out<sc_lv<32> > 	ex_mem_inst;  		// instruction to MEM_STAGE
	
	sc_in<sc_logic> 	id_ex_syscall_exception;
	sc_in<sc_logic>		id_ex_illegal_instruction;
	sc_in<sc_logic>		ovf_excep;
	sc_out<sc_logic>	ex_m_IBUS;
	sc_out<sc_logic>	ex_m_inst_addrl;
	sc_out<sc_logic>	ex_m_syscall_exception;
	sc_out<sc_logic>	ex_m_illegal_instruction;
	sc_out<sc_logic>	ex_m_ovf_excep;
	
	sc_in<sc_uint<32> >	id_ex_instaddr;
	sc_out<sc_uint<32> >	ex_m_instaddr;
	
	sc_in<sc_logic>		enable_execute;
	
	void do_reg_ex();
	
	SC_CTOR(reg_ex)
	{
		SC_METHOD(do_reg_ex);
		sensitive_pos << in_clk;
	};
}; 
