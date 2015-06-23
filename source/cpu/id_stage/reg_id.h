#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(reg_id)
{
	sc_in<bool>	in_clk;
	sc_in<bool>	reset;
	sc_in<bool>	datahold;
	sc_in<bool>	insthold;
	
	sc_out<sc_lv<32> >	id_ex_alu1;
	sc_in<sc_lv<32> >	id_alu1;
	
	sc_out<sc_lv<32> >	id_ex_alu2;
	sc_in<sc_lv<32> >	id_alu2;
	
	sc_out<sc_lv<32> >	id_ex_datastore;
	sc_in<sc_lv<32> >	id_mux_fw2;
	
	sc_out<sc_lv<6> >	id_ex_alu_ctrl;
	sc_in<sc_lv<6> >	id_alu_ctrl;
	
	sc_out<sc_lv<6> >	id_ex_alu_opcode;
	sc_in<sc_lv<6> >	id_opcode;	
	
	sc_out<sc_lv<6> >	id_ex_alu_function;
	sc_in<sc_lv<6> >	id_function;
	
	sc_out<sc_lv<5> >	id_ex_alu_sa;
	sc_in<sc_lv<5> >	id_alu_sa;
	
	sc_out<sc_logic>	id_ex_equal;
	sc_in<sc_logic> 	id_equal;
	
	sc_out<sc_logic>	id_ex_datareq;
	sc_in<sc_logic> 	id_datareq;
	
	sc_out<sc_logic>	id_ex_datarw;
	sc_in<sc_logic> 	id_datarw;
	
	sc_out<sc_logic>	id_ex_memtoreg;
	sc_in<sc_logic> 	id_memtoreg;
	
	sc_out<sc_lv<5> >	id_ex_writeregister_out;
	sc_in<sc_lv<5> >	id_writeregister;
	
	sc_out<sc_lv<5> >	id_ex_writeregister;
	//sc_in<sc_lv<5> >	id_writeregister;
	
	sc_out<sc_logic>	id_ex_regwrite_out;
	sc_in<sc_logic> 	id_regwrite;
	
	sc_out<sc_logic>	id_ex_regwrite;
	//sc_in<sc_logic> 	id_regwrite;
	
	sc_out<sc_lv<2> >	id_ex_byteselect;
	sc_in<sc_lv<2> >	id_byteselect;
	
	sc_out<sc_logic>	id_ex_bssign;
	sc_in<sc_logic>		id_bssign;
	
	sc_in<sc_lv<32> >	if_id_inst;
	sc_out<sc_lv<32> >	id_ex_inst;
	
	// EXCEPTIONS SIGNALS
	sc_in<sc_logic> 	illegal_instruction;
	sc_in<sc_logic> 	syscall_exception;
	sc_in<sc_logic>  	if_id_IBUS;
	sc_in<sc_logic>  	if_id_inst_addrl;
	sc_out<sc_logic> 	id_ex_IBUS;
	sc_out<sc_logic>	id_ex_inst_addrl;
	sc_out<sc_logic> 	id_ex_syscall_exception;
	sc_out<sc_logic>	id_ex_illegal_instruction;
	
	sc_in<sc_uint<32> >	if_id_instaddr;
	sc_out<sc_uint<32> >	id_ex_instaddr;
	
	sc_in<sc_logic>   enable_decode;
	
	void do_reg_id();
	
	SC_CTOR(reg_id)
	{
		SC_METHOD(do_reg_id);
		//sensitive_pos << reset;
		sensitive_pos << in_clk;
	}
};
