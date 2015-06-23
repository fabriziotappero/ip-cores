//
// $Id: sc_cpu.cpp,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//
// #define _ASM_ONLY_
// #define _DOBRANCH_ -- should be defined in id_stage only!
#include "sc_cpu.h"
#include "../constants/config.h"

sc_cpu::sc_cpu(const sc_module_name& name_)
{
  SC_METHOD(clocktik);
  sensitive_pos << in_clk;
  
  pc = new pc_stage("pc_stage");
  pc->in_clk(in_clk);
  pc->reset(reset);
  pc->pc_in(pc_in);
  pc->pc_out(pc_out);
#ifdef _MULT_PIPELINE_
  pc->insthold(insthold_W);
#endif
#ifndef _MULT_PIPELINE_
  pc->insthold(insthold);
#endif
  pc->datahold(datahold);
  pc->instreq(instreq);
  pc->instaddr(instaddr);
  pc->instdatawrite(instdatawrite);
  pc->instrw(instrw);
  pc->enable_pc(enable_pc);
  cout << "PC STAGE ..... OK" << endl;
  
  if_s = new if_stage("if_stage");
  if_s->in_clk(in_clk);
  if_s->reset(reset);
  if_s->pc_out(pc_out);
  if_s->id_new_pc(id_new_pc);
  if_s->id_jmp_tar(id_jmp_tar);
  if_s->id_ctrl(id_ctrl);
  if_s->id_branch(id_branch);
  if_s->pc_in(pc_in);
  if_s->instdataread(instdataread);
  if_s->if_id_inst(if_id_inst);
  if_s->if_id_next_pc(if_id_next_pc);
#ifdef _MULT_PIPELINE_
  if_s->insthold(insthold_W);
#else
  if_s->insthold(insthold);
#endif
  if_s->datahold(datahold);
  if_s->new_pc(new_pc);
  if_s->load_epc(load_epc);
  
  
  // only to mananage exceptions
  //******************************************
  if_s->IBUS(IBUS);
  if_s->inst_addrl(inst_addrl);
  if_s->if_id_IBUS(if_id_IBUS);
  if_s->if_id_inst_addrl(if_id_inst_addrl);
  if_s->enable_fetch(enable_fetch);
  if_s->if_exception(if_exception);
  if_s->pc_if_instaddr(instaddr);
  if_s->if_id_instaddr(if_id_instaddr);
  //******************************************
  cout << "IF STAGE  ..... OK" << endl;
  
  
  
  id = new id_stage("id_stage");
  id->in_clk(in_clk);
  id->reset(reset);
#ifdef _MULT_PIPELINE_
  id->insthold(insthold_W);
#else
  id->insthold(insthold);
#endif
  id->datahold(datahold);
  id->if_id_next_pc(if_id_next_pc);
  	id->if_id_inst(if_id_inst);
  	id->id_ex_inst(id_ex_inst);
  id->id_jmp_tar(id_jmp_tar);
  id->id_new_pc(id_new_pc);
  id->id_branch(id_branch);
  id->id_ctrl(id_ctrl);
  id->id_ex_alu1(id_ex_alu1);
  id->id_ex_alu2(id_ex_alu2);
  id->id_ex_datastore(id_ex_datastore);
  id->id_ex_alu_ctrl(id_ex_alu_ctrl);
  id->id_ex_alu_opcode(id_ex_alu_opcode);
  id->id_ex_alu_function(id_ex_alu_function);
  id->id_ex_alu_sa(id_ex_alu_sa);

  id->id_ex_byteselect(id_ex_byteselect);
  id->id_ex_bssign(id_ex_bssign);

  id->id_ex_equal(id_ex_equal);
  id->id_ex_datareq(id_ex_datareq);
  id->id_ex_datarw(id_ex_datarw);
  id->id_ex_memtoreg(id_ex_memtoreg);
  id->id_ex_writeregister_out(id_ex_writeregister_out);
  id->id_ex_regwrite_out(id_ex_regwrite_out);
  id->id_ex_m_writeregister(id_ex_m_writeregister);
  id->id_ex_m_wb_writeregister(id_ex_m_wb_writeregister);
  id->id_ex_m_regwrite(id_ex_m_regwrite);
  id->id_ex_m_wb_regwrite(id_ex_m_wb_regwrite);
  id->ex_id_forward(ex_id_forward);
  id->m_id_forward(m_id_forward);
  id->wb_id_forward(wb_id_forward);
  id->cp0_inst(cp0_inst);
  id->cp0_reg_no(reg_no);
  id->cp0_reg_rw(reg_rw);
  id->cp0_reg_rs(reg_rs);
  id->cp0_reg_out(reg_out);
  // only to mananage exceptions
  //*******************************************************
  id->if_id_IBUS(if_id_IBUS);
  id->if_id_inst_addrl(if_id_inst_addrl);
  id->id_ex_IBUS(id_ex_IBUS);
  id->id_ex_inst_addrl(id_ex_inst_addrl);
  id->id_ex_syscall_exception(id_ex_syscall_exception);
  id->id_ex_illegal_instruction(id_ex_illegal_instruction);
  id->if_id_instaddr(if_id_instaddr);
  id->id_ex_instaddr(id_ex_instaddr);
  
  //*******************************************************
  id->enable_decode(enable_decode);
  id->id_exception(id_exception);
  id->enable_kernel_mode(enable_kernel_mode);	// when this bit is set to 0 the cpu are running in Kernel_mode
  cout << "ID STAGE  ..... OK" << endl;
  

  ex = new ex_stage("ex_stage");
  ex->in_clk(in_clk);
  ex->reset(reset);
#ifdef _MULT_PIPELINE_
  ex->insthold(insthold_W);
#else
  ex->insthold(insthold);
#endif
  ex->datahold(datahold);
  ex->id_ex_alu1(id_ex_alu1);
  ex->id_ex_alu2(id_ex_alu2);
  ex->id_ex_datastore(id_ex_datastore);
  ex->id_ex_alu_ctrl(id_ex_alu_ctrl);
  ex->id_ex_alu_opcode(id_ex_alu_opcode);
  ex->id_ex_alu_function(id_ex_alu_function);
  ex->id_ex_alu_sa(id_ex_alu_sa);
  ex->id_ex_byteselect(id_ex_byteselect);
  ex->id_ex_bssign(id_ex_bssign);

  ex->id_ex_equal(id_ex_equal);
  ex->id_ex_datareq(id_ex_datareq);
  ex->id_ex_datarw(id_ex_datarw);
  ex->id_ex_memtoreg(id_ex_memtoreg);
  ex->id_ex_writeregister_out(id_ex_writeregister_out);
  ex->id_ex_regwrite_out(id_ex_regwrite_out);
  ex->id_ex_m_writeregister(id_ex_m_writeregister);
  ex->id_ex_m_regwrite(id_ex_m_regwrite);
  ex->id_ex_m_datastore(id_ex_m_datastore);
  ex->ex_m_alu(ex_m_alu);
  ex->id_ex_m_datareq(id_ex_m_datareq);
  ex->id_ex_m_datarw(id_ex_m_datarw);
  ex->id_ex_m_memtoreg(id_ex_m_memtoreg);
  ex->id_ex_m_byteselect(id_ex_m_byteselect);
  ex->id_ex_m_bssign(id_ex_m_bssign);
  ex->ex_id_forward(ex_id_forward);
  // only to mananage exceptions
  //*******************************************************
  ex->id_ex_IBUS(id_ex_IBUS);
  ex->id_ex_inst_addrl(id_ex_inst_addrl);
  	ex->id_ex_inst(id_ex_inst);
  	ex->ex_mem_inst(ex_mem_inst);
  ex->id_ex_syscall_exception(id_ex_syscall_exception);
  ex->id_ex_illegal_instruction(id_ex_illegal_instruction);
  ex->ex_m_IBUS(ex_m_IBUS);
  ex->ex_m_inst_addrl(ex_m_inst_addrl);
  ex->ex_m_syscall_exception(ex_m_syscall_exception);
  ex->ex_m_illegal_instruction(ex_m_illegal_instruction);
  ex->ex_m_ovf_excep(ex_m_ovf_excep);
  ex->id_ex_instaddr(id_ex_instaddr);
  ex->ex_m_instaddr(ex_m_instaddr);
  //*******************************************************
  // from cp0
  ex->addr_err(addr_err);
  ex->enable_execute(enable_execute);
  ex->ex_exception(ex_exception);
#ifdef _MULT_PIPELINE_
  ex->hold_pipe(hold_pipe);
#endif
  cout << "EX STAGE  ..... OK" << endl;
  
  mem = new mem_stage("mem_stage");
  mem->in_clk(in_clk);
  mem->reset(reset);
#ifdef _MULT_PIPELINE_
  mem->insthold(insthold_W);
#else
  mem->insthold(insthold);
#endif
  mem->datahold(datahold);
  mem->dataread(dataread);
  mem->datawrite(datawrite);
  mem->dataaddr(dataaddr);
  mem->datareq(datareq);
  mem->datarw(datarw);
  mem->databs(databs);
  mem->ex_m_alu(ex_m_alu);
  mem->id_ex_m_datastore(id_ex_m_datastore);
  mem->id_ex_m_datareq(id_ex_m_datareq);
  mem->id_ex_m_datarw(id_ex_m_datarw);
  mem->id_ex_m_memtoreg(id_ex_m_memtoreg);

  mem->id_ex_m_byteselect(id_ex_m_byteselect);
  mem->id_ex_m_bssign(id_ex_m_bssign);

  mem->id_ex_m_writeregister(id_ex_m_writeregister);
  mem->id_ex_m_regwrite(id_ex_m_regwrite);
  mem->id_ex_m_wb_writeregister(id_ex_m_wb_writeregister);
  mem->id_ex_m_wb_regwrite(id_ex_m_wb_regwrite);
  mem->m_id_forward(m_id_forward);
  mem->wb_id_forward(wb_id_forward);

  mem->ex_m_IBUS(ex_m_IBUS);
  mem->ex_m_inst_addrl(ex_m_inst_addrl);
  mem->ex_m_syscall_exception(ex_m_syscall_exception);
  mem->ex_m_illegal_instruction(ex_m_illegal_instruction);
  mem->ex_m_ovf_excep(ex_m_ovf_excep);
  mem->DBUS(DBUS);
  mem->data_addrl(data_addrl);
  mem->data_addrs(data_addrs);
 
  mem->m_wb_IBUS(m_wb_IBUS);
  mem->m_wb_inst_addrl(m_wb_inst_addrl);
  	mem->ex_mem_inst(ex_mem_inst);
  	mem->mem_wb_inst(mem_wb_inst);
  mem->m_wb_syscall_exception(m_wb_syscall_exception);
  mem->m_wb_illegal_instruction(m_wb_illegal_instruction);
  mem->m_wb_ovf_excep(m_wb_ovf_excep);
  mem->m_wb_DBUS(m_wb_DBUS);
  mem->m_wb_data_addrl(m_wb_data_addrl);
  mem->m_wb_data_addrs(m_wb_data_addrs);

  mem->ex_m_instaddr(ex_m_instaddr);
  mem->m_wb_instaddr(m_wb_instaddr);
  mem->m_wb_dataaddr(m_wb_dataaddr);	//aggiunta l'uscita dell indirizzo DATAMEM in caso di page fault
  mem->mem_exception(mem_exception);
  mem->enable_memstage(enable_memstage);
  mem->interrupt_signal(interrupt_signal);
  mem->m_wb_interrupt_signal(m_wb_interrupt_signal);
  mem->enable_interrupt(enable_interrupt);
#ifdef _MULT_PIPELINE_
  mem->hold_pipe(hold_pipe);
#endif
  cout << "MEM STAGE  ..... OK" << endl;
  
#ifdef _MULT_PIPELINE_
  og1 = new or_gate("or_gate");
  og1->in_A(insthold);
  og1->in_B(hold_pipe);
  og1->out_gate(insthold_W);
#endif
  
  enable_stage1 = new enable_stage("enable_stage");
  enable_stage1->enable_pc(enable_pc);
  enable_stage1->enable_fetch(enable_fetch);
  enable_stage1->enable_decode(enable_decode);
  enable_stage1->enable_execute(enable_execute);
  enable_stage1->enable_memstage(enable_memstage);
  enable_stage1->if_exception(if_exception);
  enable_stage1->id_exception(id_exception);
  enable_stage1->ex_exception(ex_exception);
  enable_stage1->mem_exception(mem_exception);
  enable_stage1->wb_exception(wb_exception);
  
  
  writeback_ctrl1 = new writeback_ctrl("writeback_ctrl");
  writeback_ctrl1->m_wb_IBUS(m_wb_IBUS);
  writeback_ctrl1->m_wb_inst_addrl(m_wb_inst_addrl);
  writeback_ctrl1->m_wb_syscall_exception(m_wb_syscall_exception);
  writeback_ctrl1->m_wb_illegal_instruction(m_wb_illegal_instruction);
  writeback_ctrl1->m_wb_ovf_excep(m_wb_ovf_excep);
  writeback_ctrl1->m_wb_DBUS(m_wb_DBUS);
  writeback_ctrl1->m_wb_data_addrl(m_wb_data_addrl);
  writeback_ctrl1->m_wb_data_addrs(m_wb_data_addrs);
  writeback_ctrl1->wb_exception(wb_exception);
  writeback_ctrl1->m_wb_interrupt_signal(m_wb_interrupt_signal);
  
  mux_instaddr1 = new mux_instaddr("mux_instaddr");
  mux_instaddr1->m_wb_instaddr(m_wb_instaddr);
  mux_instaddr1->ex_m_instaddr(ex_m_instaddr);
  mux_instaddr1->m_wb_instaddr_s(m_wb_instaddr_s);
  mux_instaddr1->ex_mem_inst(mem_wb_inst);
  mux_instaddr1->m_wb_interrupt_signal(m_wb_interrupt_signal);
}
