//! MEM Stage module
//
// $Id: mem_stage.h,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//
#ifndef _MEM_STAGE_H
#define _MEM_STAGE_H

#include "systemc.h"

#include "./mem_stage/select_mem.h"
#include "./mem_stage/reg_mem.h"
#include "./mem_stage/multiplexer_mem.h"
#include "./mem_stage/memstage_ctrl.h"
#include "./mem_stage/mux_interrupt.h"
#include "./mem_stage/flag_interr.h"

SC_MODULE(mem_stage) 
{
	sc_in<bool> in_clk;
	sc_in<bool> reset;
	
	sc_in<bool> insthold;
	sc_in<bool> datahold;
	
	sc_in<sc_logic> id_ex_m_datareq;
	sc_in<sc_logic> id_ex_m_datarw;
	sc_in<sc_lv<32> > id_ex_m_datastore;
	sc_in<sc_lv<32> > ex_m_alu;
	
	// signal to mem_stage from ex_stage
	sc_in<sc_logic>  id_ex_m_memtoreg;
	sc_in<sc_lv<2> > id_ex_m_byteselect;
	sc_in<sc_logic>  id_ex_m_bssign; 
	
	// signal to data memory
	sc_in<sc_lv<32> > dataread;
	sc_out<sc_lv<32> > datawrite;
	sc_out<sc_uint<32> > dataaddr;
	sc_out<sc_logic> datareq;
	sc_out<sc_logic> datarw;
	sc_out<sc_lv<2> > databs;
	
	// signal to control save in register
	sc_in<sc_lv<5> > id_ex_m_writeregister;
	sc_in<sc_logic> id_ex_m_regwrite;
	
	sc_out<sc_lv<5> > id_ex_m_wb_writeregister;
	sc_out<sc_logic> id_ex_m_wb_regwrite;
	
	sc_out<sc_lv<32> > m_id_forward;
	sc_out<sc_lv<32> > wb_id_forward;
	
	sc_in<sc_logic>		enable_memstage;
	sc_out<sc_logic>	mem_exception;
	
	sc_signal<sc_lv<32> > id_store;
	
	// EXCEPTION SIGNALS
	sc_in<sc_logic>		ex_m_IBUS;
	sc_in<sc_logic>		ex_m_inst_addrl;
	sc_in<sc_logic>		ex_m_syscall_exception;
	sc_in<sc_logic>		ex_m_illegal_instruction;
	sc_in<sc_logic>		ex_m_ovf_excep;
	sc_in<sc_logic>		DBUS;
	sc_in<sc_logic>		data_addrl;
	sc_in<sc_logic>		data_addrs;
	
	// INTERRUPT SIGNAL
	sc_in<bool>		interrupt_signal;
	sc_out<bool>		m_wb_interrupt_signal;
	sc_in<sc_logic>		enable_interrupt;
	sc_signal<bool>		interrupt_signal_out;
	sc_signal<bool>		interrupt_out_out;
	sc_signal<bool>		ground;
	
	// exception status vector -> to  CPO-Cause
	sc_out<sc_logic>	m_wb_IBUS;
	sc_out<sc_logic>	m_wb_inst_addrl;
	sc_out<sc_logic>	m_wb_syscall_exception;
	sc_out<sc_logic>	m_wb_illegal_instruction;
	sc_out<sc_logic>	m_wb_ovf_excep;
	sc_out<sc_logic>	m_wb_DBUS;
	sc_out<sc_logic>	m_wb_data_addrl;
	sc_out<sc_logic>	m_wb_data_addrs;
	
		sc_in<sc_lv<32> > 	ex_mem_inst;  // instruction coming from EX_STAGE
		sc_out<sc_lv<32> > 	mem_wb_inst;  // instruction to WRITE_BACK Phases
	
	sc_in<sc_uint<32> >	ex_m_instaddr;
	sc_out<sc_uint<32> >	m_wb_instaddr;
	
	// sc_in<sc_uint<32> >  ex_m_dataaddr; il segnale �dataddr!
	sc_out<sc_uint<32> >	m_wb_dataaddr;
	
#ifdef _MULT_PIPELINE_
	sc_in<bool>		hold_pipe;
#endif

	select_mem *select_mem1;
	multiplexer_mem *multiplexer_mem1;
	reg_mem *reg_mem1;
	memstage_ctrl *memstage_ctrl1;
	mux_interrupt *mux_interrupt1;
	flag_interr *flag_interr1;
	
	SC_CTOR(mem_stage)
	{
		select_mem1 = new select_mem("select_mem");
		select_mem1->id_ex_m_datareq(id_ex_m_datareq);
		select_mem1->id_ex_m_datarw(id_ex_m_datarw);
		select_mem1->id_ex_m_byteselect(id_ex_m_byteselect);
		select_mem1->id_ex_m_datastore(id_ex_m_datastore);
		select_mem1->datawrite(datawrite);
		select_mem1->ex_m_alu(ex_m_alu);
		select_mem1->dataaddr(dataaddr);
		select_mem1->datareq(datareq);
		select_mem1->datarw(datarw);
		select_mem1->databs(databs);
		select_mem1->enable_memstage(enable_memstage);	
		
		multiplexer_mem1 = new multiplexer_mem("multiplexer_mem");
		multiplexer_mem1->id_ex_m_byteselect(id_ex_m_byteselect);
		multiplexer_mem1->id_ex_m_bssign(id_ex_m_bssign); 
		multiplexer_mem1->id_ex_m_memtoreg(id_ex_m_memtoreg);
		multiplexer_mem1->ex_m_alu(ex_m_alu);
		multiplexer_mem1->dataread(dataread);
		multiplexer_mem1->id_store(id_store);
		multiplexer_mem1->m_id_forward(m_id_forward);
		
		reg_mem1 = new reg_mem("reg_mem");
		reg_mem1->in_clk(in_clk);
		reg_mem1->reset(reset);
		reg_mem1->insthold(insthold);
		reg_mem1->datahold(datahold);
		reg_mem1->wb_id_forward(wb_id_forward);
		reg_mem1->id_ex_m_wb_writeregister(id_ex_m_wb_writeregister);
		reg_mem1->id_ex_m_wb_regwrite(id_ex_m_wb_regwrite);
		reg_mem1->id_store(id_store);
		reg_mem1->id_ex_m_writeregister(id_ex_m_writeregister);
		reg_mem1->id_ex_m_regwrite(id_ex_m_regwrite);
		
		reg_mem1->ex_m_IBUS(ex_m_IBUS);
		reg_mem1->ex_m_inst_addrl(ex_m_inst_addrl);
		reg_mem1->ex_m_syscall_exception(ex_m_syscall_exception);
		reg_mem1->ex_m_illegal_instruction(ex_m_illegal_instruction);
		reg_mem1->ex_m_ovf_excep(ex_m_ovf_excep);
		reg_mem1->DBUS(DBUS);
		reg_mem1->data_addrl(data_addrl);
		reg_mem1->data_addrs(data_addrs);
		reg_mem1->ex_m_instaddr(ex_m_instaddr);
  		reg_mem1->ex_m_dataaddr(dataaddr);
		reg_mem1->interrupt_signal(interrupt_out_out);
		reg_mem1->m_wb_interrupt_signal(m_wb_interrupt_signal);
		
		reg_mem1->m_wb_IBUS(m_wb_IBUS);
		reg_mem1->m_wb_inst_addrl(m_wb_inst_addrl);
		reg_mem1->m_wb_syscall_exception(m_wb_syscall_exception);
		reg_mem1->m_wb_illegal_instruction(m_wb_illegal_instruction);
		reg_mem1->m_wb_ovf_excep(m_wb_ovf_excep);
		reg_mem1->m_wb_DBUS(m_wb_DBUS);
		reg_mem1->m_wb_data_addrl(m_wb_data_addrl);
		reg_mem1->m_wb_data_addrs(m_wb_data_addrs);
		reg_mem1->m_wb_instaddr(m_wb_instaddr);
		reg_mem1->m_wb_dataaddr(m_wb_dataaddr);
			reg_mem1->ex_mem_inst(ex_mem_inst);
			reg_mem1->mem_wb_inst(mem_wb_inst);
		reg_mem1->enable_memstage(enable_memstage);
		
		memstage_ctrl1 = new memstage_ctrl("memstage_ctrl");
		memstage_ctrl1->ex_m_IBUS(ex_m_IBUS);
		memstage_ctrl1->ex_m_inst_addrl(ex_m_inst_addrl);
		memstage_ctrl1->ex_m_syscall_exception(ex_m_syscall_exception);
		memstage_ctrl1->ex_m_illegal_instruction(ex_m_illegal_instruction);
		memstage_ctrl1->ex_m_ovf_excep(ex_m_ovf_excep);
		memstage_ctrl1->DBUS(DBUS);
		memstage_ctrl1->data_addrl(data_addrl);
		memstage_ctrl1->data_addrs(data_addrs);
		memstage_ctrl1->mem_exception(mem_exception);
		memstage_ctrl1->interrupt_signal(interrupt_out_out);
		
		flag_interr1 = new flag_interr("flag_interr");
		flag_interr1->in_clk(in_clk);
		flag_interr1->reset(reset);
		flag_interr1->interrupt_in(interrupt_signal_out);
		flag_interr1->interrupt_out(interrupt_out_out);
		
		ground.write(false);
		
		mux_interrupt1 = new mux_interrupt("mux_interrupt");
		mux_interrupt1->IN_A(interrupt_signal);
		mux_interrupt1->IN_B(ground);
	#ifdef _MULT_PIPELINE_
		mux_interrupt1->hold_pipe(hold_pipe);
	#endif
		mux_interrupt1->SEL(enable_interrupt);
		mux_interrupt1->OUT(interrupt_signal_out);
	}
};


#endif
