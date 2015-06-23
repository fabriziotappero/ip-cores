//
// $Id: sc_cpu.h,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//

#ifndef _SC_CPU_H
#define _SC_CPU_H

#include <systemc.h>
#include "../constants/config.h"
#include "../constants/constants.h"
#include "pc_stage.h"
#include "if_stage.h"
#include "id_stage.h"
#include "ex_stage.h"
#include "mem_stage.h"
#include "enable_stage.h"
#include "writeback_ctrl.h"
#include "mux_instaddr.h"

#ifdef _MULT_PIPELINE_
#include "or_gate.h"
#endif

SC_MODULE(sc_cpu) 
{
// to CP0_STAGE
  sc_in<sc_lv<32> >	new_pc;
  sc_in<sc_logic> 	load_epc;
  sc_out<sc_lv<32> >	pc_in;
  sc_out<sc_lv<32> >	pc_out;
  sc_out<sc_logic> 	id_branch;
  sc_out<sc_logic> 	id_ctrl;
  sc_out<sc_logic>	id_ex_datarw;
  sc_out<sc_logic>	id_ex_datareq;
  sc_in<sc_logic>	addr_err;
  sc_in<bool>		insthold;
  sc_out<sc_lv<4> >	cp0_inst;
  sc_out<sc_lv<32> >	reg_rs;
  sc_in<sc_lv<32> >	reg_out;
  sc_out<sc_uint<5> >	reg_no;
  sc_out<sc_logic>	reg_rw;
  sc_out<sc_lv<32> >	ex_id_forward;
  
  
  // EXCEPTION SIGNAL FROM DATAMEM AND INSTMEM
  //*****************************************************************************************************
  sc_in<sc_logic>	inst_addrl;		// disaligned address in instmem during fetch stage
  sc_in<sc_logic>	IBUS;			//page fault in instmem
  sc_in<sc_logic>	data_addrl;		//disaligned address in datamem during  load instruction
  sc_in<sc_logic>	data_addrs;		//disaligned address in datamem during store instruction
  sc_in<sc_logic>	DBUS;			//page fault in instmem
  //*****************************************************************************************************
  
  // EXCEPTION SIGNALS TO ENABLE/DISABLE PIPELINED STAGE
  //*****************************************************************************************************
  sc_signal<sc_logic>	enable_pc;
  sc_signal<sc_logic>	enable_fetch;
  sc_signal<sc_logic>	enable_decode;
  sc_signal<sc_logic>	enable_execute;
  sc_signal<sc_logic>	enable_memstage;
  sc_signal<sc_logic>	if_exception;
  sc_signal<sc_logic>	id_exception;
  sc_signal<sc_logic>	ex_exception;
  sc_signal<sc_logic>	mem_exception;
  sc_signal<sc_logic>	wb_exception;
  sc_signal<sc_logic>	interrupt_exception;
  //*****************************************************************************************************
  
  // INTERRUPT SIGNALS
  //**********************************************
  sc_in<bool>	interrupt_signal;
  sc_out<bool>	m_wb_interrupt_signal;
  sc_in<sc_logic>	enable_interrupt;
  sc_in<sc_logic>	enable_kernel_mode;
  //**********************************************
  
    
  // PIPELINED EXCEPTION SIGNALS
  //*****************************************************************************************************
  	sc_signal<sc_lv<32> > 	id_ex_inst;		// from id_stage  to ex_stage
  	sc_signal<sc_lv<32> > 	ex_mem_inst;		// from ex_stage  to mem_stage
  	sc_signal<sc_lv<32> > 	mem_wb_inst;		// from mem_stage to WriteBack
  sc_signal<sc_logic> 	if_id_inst_addrl;		// from if_stage  to id_stage
  sc_signal<sc_logic> 	if_id_IBUS;			// from if_stage  to id_stage
  sc_signal<sc_logic> 	id_ex_inst_addrl;		// from id_stage  to ex_stage
  sc_signal<sc_logic> 	id_ex_IBUS;			// from id_stage  to ex_stage
  sc_signal<sc_logic> 	id_ex_syscall_exception;	// from id_stage  to ex_stage
  sc_signal<sc_logic> 	id_ex_illegal_instruction;	// from id_stage  to ex_stage
  sc_signal<sc_logic> 	ex_m_ovf_excep;			// from ex_stage  to mem_stage
  sc_signal<sc_logic> 	ex_m_inst_addrl;		// from ex_stage  to mem_stage
  sc_signal<sc_logic> 	ex_m_IBUS;			// from ex_stage  to mem_stage
  sc_signal<sc_logic> 	ex_m_syscall_exception;		// from ex_stage  to mem_stage
  sc_signal<sc_logic> 	ex_m_illegal_instruction;	// from ex_stage  to mem_stage
  sc_out<sc_logic> 	m_wb_DBUS;			// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_data_addrl;		// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_data_addrs;		// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_ovf_excep;			// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_syscall_exception;		// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_illegal_instruction;	// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_IBUS;			// from mem_stage to cp0_cause
  sc_out<sc_logic> 	m_wb_inst_addrl;		// from mem_stage to cp0_cause
  
  sc_signal<sc_uint<32> >	if_id_instaddr;		// from if_stage  to id_stage  (victim address instruction)
  sc_signal<sc_uint<32> >	id_ex_instaddr;		// from id_stage  to ex_stage  (victim address instruction)
  sc_signal<sc_uint<32> >	ex_m_instaddr;		// from ex_stage  to mem_stage address for INTERRUPT EPC
  sc_signal<sc_uint<32> >	m_wb_instaddr;		// from mem_stage to mux_instaddr (victim address instruction)
  sc_out<sc_uint<32> >		m_wb_instaddr_s;	// from mux_instaddr to EPC
  sc_out<sc_uint<32> >		m_wb_dataaddr;		// from mem_stage to cpo_cause (victim address instruction)
  //*****************************************************************************************************
  
  
  
  //
  // Very basic signals for the CPU!
  //
  //! Main clock signal
  sc_in<bool> in_clk;
  //! Main reset signal
  sc_in<bool> reset;
  
  //
  // Instruction memory interface
  //
  //! Instruction memory input data
  // sc_inout_rv<32> instdata;
  sc_in<sc_lv<32> > instdataread;
  sc_out<sc_lv<32> > instdatawrite;
  //! Instruction memory address
  sc_out<sc_uint<32> > instaddr;
  //! Instruction memory request
  sc_out<sc_logic> instreq;
  //! Instruction memory read/write signal. 1 for write. 0 for read.
  sc_out<sc_logic> instrw;
  //! Hold signal from cp0 (Was: instruction memory)
  
  
  //sc_in<bool> x_insthold;  //in sc_risc!

  //
  // Data memory interface
  //
  //! Data memory in/out data
  // sc_inout_rv<32> data;
  sc_in<sc_lv<32> > dataread;
  sc_out<sc_lv<32> > datawrite;
  //! Data memory address
  sc_out<sc_uint<32> > dataaddr;
  //! Data memory request
  sc_out<sc_logic> datareq;
  //! Data memory read/write signal. 1 for write. 0 for read.
  sc_out<sc_logic> datarw;
  //! Byte select signal. Select bytes to be written. 01 for byte, 10 for halfword
  sc_out<sc_lv<2> > databs;
  //! Hold signal from data memory
  sc_in<bool> datahold;


  // Misc. signals
  sc_signal<sc_lv<32> > id_new_pc;
  sc_signal<sc_lv<32> > id_jmp_tar;
  sc_signal<sc_lv<32> > if_id_inst;
  sc_signal<sc_lv<32> > if_id_next_pc;

  // signal from id_stage to ex_stage
  sc_signal<sc_lv<32> > id_ex_alu1;
  sc_signal<sc_lv<32> > id_ex_alu2;
  sc_signal<sc_lv<32> > id_ex_datastore;
  sc_signal<sc_lv<6> >  id_ex_alu_ctrl;
  sc_signal<sc_lv<6> >	id_ex_alu_opcode;
  sc_signal<sc_lv<6> >	id_ex_alu_function;
  sc_signal<sc_logic>   id_ex_equal;
  sc_signal<sc_lv<2> >  id_ex_byteselect;
  sc_signal<sc_logic>   id_ex_bssign;
  sc_signal<sc_lv<5> >  id_ex_alu_sa;

  // signal to mem_stage through ex_stage
  sc_signal<sc_logic>  id_ex_memtoreg;
  sc_signal<sc_lv<2> > id_ex_m_byteselect;
  sc_signal<sc_logic>  id_ex_m_bssign; 

  // signal to mem_stage
  sc_signal<sc_logic>   id_ex_m_datareq;
  sc_signal<sc_logic>   id_ex_m_datarw;
  sc_signal<sc_lv<32> > id_ex_m_datastore;
  sc_signal<sc_lv<32> > ex_m_alu;
  sc_signal<sc_logic>   id_ex_m_memtoreg;
  sc_signal<sc_logic>   m_ocp_cmd;

  // signal to control save in register
  sc_signal<sc_lv<5> > id_ex_writeregister_out;
  sc_signal<sc_logic>  id_ex_regwrite_out;

  // forwarding control signal
  sc_signal<sc_lv<5> >  id_ex_m_writeregister;
  sc_signal<sc_lv<5> >  id_ex_m_wb_writeregister;
  sc_signal<sc_logic>   id_ex_m_regwrite;
  sc_signal<sc_logic>   id_ex_m_wb_regwrite;
  //sc_signal<sc_lv<32> > ex_id_forward;
  sc_signal<sc_lv<32> > m_id_forward;
  sc_signal<sc_lv<32> > wb_id_forward;

  
  // signals between ID stage and cp0
  
  sc_signal<sc_logic>   inst_break;
  sc_signal<sc_logic>   inst_syscall;

#ifdef _MULT_PIPELINE_
  sc_signal<bool> 	hold_pipe;
  sc_signal<bool> 	insthold_W;
#endif

  pc_stage *pc;
  if_stage *if_s;
  id_stage *id;
  ex_stage *ex;
  mem_stage *mem;
  enable_stage *enable_stage1;
  writeback_ctrl *writeback_ctrl1;
  mux_instaddr *mux_instaddr1;
#ifdef _MULT_PIPELINE_
  or_gate *og1;
#endif  

  void clocktik()
    {
    };

  SC_HAS_PROCESS(sc_cpu);
  sc_cpu(const sc_module_name& name_);
 
};

#endif
