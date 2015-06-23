// EX_STAGE
#ifndef _EX_STAGE_H
#define _EX_STAGE_H

  #include <systemc.h>

  #include "./ex_stage/reg_ex.h"
  #include "./ex_stage/alu.h"
  #include "./ex_stage/backwrite.h" 
  #include "./ex_stage/multiply.h"
  #include "./ex_stage/mux_lo.h"
  #include "./ex_stage/mux_hi.h"
  #include "./ex_stage/mux_rd.h"
  #include "./ex_stage/execute_ctrl.h"
  #include "../constants/config.h"

#ifdef _MULT_PIPELINE_
  #include "./ex_stage/fsm.h"
#endif
  
SC_MODULE(ex_stage) 
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;
	
	sc_in<bool> insthold;
	sc_in<bool> datahold;
	
	// signals from id_stage
	sc_in<sc_lv<32> > id_ex_alu1;
	sc_in<sc_lv<32> > id_ex_alu2;
	sc_in<sc_lv<32> > id_ex_datastore;
	sc_in<sc_lv<6> >  id_ex_alu_ctrl;
	sc_in<sc_lv<6> >  id_ex_alu_opcode;
	sc_in<sc_lv<6> >  id_ex_alu_function;
	sc_in<sc_logic>   id_ex_equal;
	sc_in<sc_lv<2> >  id_ex_byteselect;
	sc_in<sc_logic>   id_ex_bssign;
	sc_in<sc_lv<5> >  id_ex_alu_sa;
	
	// signals to be sent on to mem_stage
	sc_in<sc_logic> id_ex_datareq;
	sc_in<sc_logic> id_ex_datarw;
	sc_in<sc_logic> id_ex_memtoreg;
	
	// signal to control save in register
	sc_in<sc_lv<5> > id_ex_writeregister_out;
	sc_in<sc_logic> id_ex_regwrite_out;
	
	sc_out<sc_lv<5> > id_ex_m_writeregister;
	sc_out<sc_logic> id_ex_m_regwrite;
	
	sc_out<sc_logic> id_ex_m_datareq;
	sc_out<sc_logic> id_ex_m_datarw;
	sc_out<sc_lv<32> > id_ex_m_datastore;
	sc_out<sc_lv<32> > ex_m_alu;
	
	sc_out<sc_logic> id_ex_m_memtoreg;
	
	sc_out<sc_lv<32> > ex_id_forward;
	
	// Signals directly to mem stage
	sc_out<sc_lv<2> > id_ex_m_byteselect;
	sc_out<sc_logic>  id_ex_m_bssign;
	
	sc_signal<sc_logic> 	ovf_excep;
	
		sc_in<sc_lv<32> > 	id_ex_inst;  // instruction coming from ID_STAGE
		sc_out<sc_lv<32> > 	ex_mem_inst;  // instruction to MEM_STAGE
	
	sc_in<sc_logic> 	id_ex_IBUS;
	sc_in<sc_logic>		id_ex_inst_addrl;
	sc_in<sc_logic> 	id_ex_syscall_exception;
	sc_in<sc_logic>		id_ex_illegal_instruction;
	sc_out<sc_logic>	ex_m_IBUS;
	sc_out<sc_logic>	ex_m_inst_addrl;
	sc_out<sc_logic>	ex_m_syscall_exception;
	sc_out<sc_logic>	ex_m_illegal_instruction;
	sc_out<sc_logic>	ex_m_ovf_excep;
	
	sc_out<sc_logic>	ex_exception;
	sc_in<sc_logic>		enable_execute;
	
	sc_in<sc_uint<32> >	id_ex_instaddr;
	sc_out<sc_uint<32> >	ex_m_instaddr;
	
	// Signals from cp0
	// To prevent memory access in case of Address Error Exception
	sc_in<sc_logic> addr_err;
	
	sc_signal<sc_lv<32> > ex_alu_s;
	sc_signal<sc_lv<32> > ex_id_forward_s;
	sc_signal<sc_lv<32> > in_ex_alu_s;
	sc_signal<sc_lv<32> > in_ex_id_forward_s;
	
	// special registers
	sc_signal<sc_lv<32> > hi;
	sc_signal<sc_lv<32> > lo;
	sc_signal<sc_lv<32> > in_lo;
	sc_signal<sc_lv<32> > in_hi;
	sc_signal<sc_lv<32> > out_lo;
	sc_signal<sc_lv<32> > out_hi;
	
	
	// Output from pipelined Multiplier
	//********************************
#ifdef _MULT_PIPELINE_
	sc_out<bool>		hold_pipe;
	sc_signal<bool>		ready;
#endif
	//*********************************
	
	
	sc_signal<sc_logic> carry;
	
	reg_ex *reg_ex1;
	alu *alu1;
	backwrite *backwrite1;
	multiply *multiply1;
	mux_lo *mux_lo1;
	mux_hi *mux_hi1;
	mux_rd *mux_rd1;
	execute_ctrl *execute_ctrl1;
#ifdef _MULT_PIPELINE_
	fsm *fsm1;
#endif
	SC_CTOR(ex_stage)
	{
		reg_ex1 = new reg_ex("reg_ex");
		reg_ex1->in_clk(in_clk);
		reg_ex1->reset(reset);
		reg_ex1->insthold(insthold);
		reg_ex1->datahold(datahold);
		reg_ex1->addr_err(addr_err);
		reg_ex1->ex_alu_s(ex_alu_s);
		reg_ex1->ex_m_alu(ex_m_alu);
		reg_ex1->id_ex_datastore(id_ex_datastore);
		reg_ex1->id_ex_m_datastore(id_ex_m_datastore);
		reg_ex1->id_ex_datareq(id_ex_datareq);
		reg_ex1->id_ex_m_datareq(id_ex_m_datareq);
		reg_ex1->id_ex_datarw(id_ex_datarw);
		reg_ex1->id_ex_m_datarw(id_ex_m_datarw);
		reg_ex1->id_ex_memtoreg(id_ex_memtoreg);
		reg_ex1->id_ex_m_memtoreg(id_ex_m_memtoreg);
		reg_ex1->id_ex_writeregister_out(id_ex_writeregister_out);
		reg_ex1->id_ex_m_writeregister(id_ex_m_writeregister);
		reg_ex1->id_ex_regwrite_out(id_ex_regwrite_out);
		reg_ex1->id_ex_m_regwrite(id_ex_m_regwrite);
		reg_ex1->id_ex_byteselect(id_ex_byteselect);
		reg_ex1->id_ex_m_byteselect(id_ex_m_byteselect);
		reg_ex1->id_ex_bssign(id_ex_bssign);
		reg_ex1->id_ex_m_bssign(id_ex_m_bssign);
		reg_ex1->in_lo(in_lo);
		reg_ex1->out_lo(out_lo);
		reg_ex1->in_hi(in_hi);
		reg_ex1->out_hi(out_hi);
		//**************************************************************
		reg_ex1->id_ex_IBUS(id_ex_IBUS);
		reg_ex1->id_ex_inst_addrl(id_ex_inst_addrl);
		reg_ex1->id_ex_syscall_exception(id_ex_syscall_exception);
		reg_ex1->id_ex_illegal_instruction(id_ex_illegal_instruction);
		reg_ex1->ovf_excep(ovf_excep);
		reg_ex1->ex_m_IBUS(ex_m_IBUS);
		reg_ex1->ex_m_inst_addrl(ex_m_inst_addrl);
		reg_ex1->ex_m_syscall_exception(ex_m_syscall_exception);
		reg_ex1->ex_m_illegal_instruction(ex_m_illegal_instruction);
		reg_ex1->ex_m_ovf_excep(ex_m_ovf_excep);
		reg_ex1->id_ex_instaddr(id_ex_instaddr);
		reg_ex1->ex_m_instaddr(ex_m_instaddr);
			// instruction  from ID_STAGE to EX_STAGE
			//******************************************************
			reg_ex1->id_ex_inst(id_ex_inst);
			reg_ex1->ex_mem_inst(ex_mem_inst);
			//******************************************************
		//**************************************************************
		reg_ex1->enable_execute(enable_execute);
		
		execute_ctrl1 = new execute_ctrl("execute_ctrl");
		execute_ctrl1->id_ex_IBUS(id_ex_IBUS);
		execute_ctrl1->id_ex_inst_addrl(id_ex_inst_addrl);
		execute_ctrl1->id_ex_syscall_exception(id_ex_syscall_exception);
		execute_ctrl1->id_ex_illegal_instruction(id_ex_illegal_instruction);
		execute_ctrl1->ovf_excep(ovf_excep);
		execute_ctrl1->ex_exception(ex_exception);
		
		alu1 = new alu("alu");
		alu1->id_ex_alu1(id_ex_alu1);
		alu1->id_ex_alu2(id_ex_alu2);
		alu1->id_ex_alu_ctrl(id_ex_alu_ctrl);
		alu1->id_ex_equal(id_ex_equal);
		alu1->id_ex_alu_sa(id_ex_alu_sa);
		alu1->ovf_excep(ovf_excep);
		alu1->carry(carry);
		alu1->ex_alu_s(in_ex_alu_s);
		alu1->ex_id_forward_s(in_ex_id_forward_s);
		
		backwrite1 = new backwrite("backwrite");
		backwrite1->ex_id_forward_s(ex_id_forward_s);
		backwrite1->ex_id_forward(ex_id_forward);
		
		
		multiply1 = new multiply("multiply"); 
		multiply1->in_clk(in_clk);
		multiply1->reset(reset);
	#ifdef _MULT_PIPELINE_
		multiply1->ready(ready);
	#endif
		multiply1->id_ex_alu1(id_ex_alu1);
		multiply1->id_ex_alu2(id_ex_alu2);
		multiply1->id_ex_alu_function(id_ex_alu_function);
		multiply1->id_ex_alu_opcode(id_ex_alu_opcode);
		multiply1->hi(hi);
		multiply1->lo(lo);
		
#ifdef _MULT_PIPELINE_
		fsm1 = new fsm("fsm");
		fsm1->hold_pipe(hold_pipe);
		fsm1->ready(ready);
		fsm1->in_clk(in_clk);
		fsm1->reset(reset);
		fsm1->id_ex_alu_function(id_ex_alu_function);
		fsm1->id_ex_alu_opcode(id_ex_alu_opcode);
#endif	
		mux_lo1 = new mux_lo("mux_lo");
		mux_lo1->lo(lo);
		mux_lo1->rs(id_ex_alu1);
		mux_lo1->id_ex_alu_ctrl(id_ex_alu_ctrl);
		mux_lo1->out(in_lo);
		
		mux_hi1 = new mux_hi("mux_hi");
		mux_hi1->hi(hi);
		mux_hi1->rs(id_ex_alu1);
		mux_hi1->id_ex_alu_ctrl(id_ex_alu_ctrl);
		mux_hi1->out(in_hi);
		
		mux_rd1 = new mux_rd("mux_rd");
		mux_rd1->in_ex_id_forward_s(in_ex_id_forward_s);	// dalla ALU
		mux_rd1->in_ex_alu_s(in_ex_alu_s);      		// dalla ALU
		mux_rd1->out_lo(out_lo);            			// dai registri LO
		mux_rd1->out_hi(out_hi);            			// dai registri HI 
		mux_rd1->id_ex_alu_ctrl(id_ex_alu_ctrl);		// selettore del MUX
		mux_rd1->out_ex_id_forward_s(ex_id_forward_s);		// USCITE verso i registri di pipeline
		mux_rd1->out_ex_alu_s(ex_alu_s);
	}
};

#endif
