#include "systemc.h"
#include "../../constants/constants.h"
#include "../../constants/config.h"

SC_MODULE(control)
{
	sc_in<sc_lv<32> >	if_id_inst;
	sc_out<sc_lv<5> >	rs;
	sc_out<sc_lv<5> >	rt;
	sc_out<sc_lv<5> >	rd;
	sc_out<sc_lv<6> >	id_alu_ctrl;
	
	//*************************************************//
	//******** segnali per il moltiplicatore **********//
	sc_out<sc_lv<6> >	id_opcode;
	sc_out<sc_lv<6> >	id_function;
	//*************************************************//
	//*************************************************//
	
	sc_out<sc_lv<5> >	id_alu_sa;
	sc_out<sc_logic>	id_ctrl;
	sc_out<sc_lv<2> >	id_extend_ctrl;
	sc_out<sc_lv<2> >	id_sign_ctrl;
	sc_out<sc_lv<2> >	regdest;
	sc_out<sc_logic>	id_select_jump;
	sc_out<sc_logic>	id_pc_store;
	sc_out<sc_lv<3> >	id_branch_select;
	sc_out<sc_logic>	id_regwrite;
	sc_out<sc_logic>	id_shamt_ctrl;
	sc_out<sc_logic>	id_datarw;
	sc_out<sc_logic>	id_datareq;
	sc_out<sc_logic>	id_memtoreg;
	sc_out<sc_lv<2> >	id_byteselect;
	
	sc_out<sc_lv<4> >	cp0_inst;
	sc_out<sc_uint<5> >	cp0_reg_no;
	sc_out<sc_logic>	cp0_reg_rw;
	sc_out<sc_logic>	id_mfc0;
	sc_out<sc_logic>	illegal_instruction;
	sc_out<sc_logic>	syscall_exception;
#ifdef ONEHOT_DEBUG
	sc_out<sc_logic>	inst_addiu;
	sc_out<sc_logic>	inst_jalr;
	sc_out<sc_logic>	inst_lw;
	sc_out<sc_logic>	inst_mfc0;
	sc_out<sc_logic>	inst_mtc0;
	sc_out<sc_logic>	inst_nop;
	sc_out<sc_logic>	inst_sw;
	sc_out<sc_logic>	inst_wait;
#endif	
	void do_control();

	SC_CTOR(control)
	{
		SC_METHOD(do_control);
		sensitive << if_id_inst;
	}
};
