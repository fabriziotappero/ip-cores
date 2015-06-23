//
// $Id: sc_risc.cpp,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//
#include "sc_risc.h"

sc_risc::sc_risc(const sc_module_name& name_)
{
  cpu = new sc_cpu("cpu-processor");
 
  cpu->in_clk(in_clk);
  cpu->reset(reset);
  cpu->instdataread(instdataread);
  cpu->instdatawrite(instdatawrite);
  cpu->instaddr(instaddr);
  cpu->instreq(instreq);
  cpu->instrw(instrw);
  cpu->insthold(x_insthold);
  cpu->dataread(dataread);
  cpu->datawrite(datawrite);
  cpu->dataaddr(dataaddr);
  cpu->datareq(datareq);
  cpu->datarw(datarw);
  cpu->databs(databs);
  cpu->datahold(datahold);
  cpu->new_pc(new_pc);
  cpu->load_epc(load_epc);
  cpu->pc_in(pc_in);
  cpu->pc_out(pc_out);
  cpu->id_branch(id_branch);
  cpu->id_ctrl(id_ctrl);
  cpu->id_ex_datarw(id_ex_datarw);
  cpu->id_ex_datareq(id_ex_datareq);
  cpu->addr_err(addr_err);
  cpu->cp0_inst(cp0_inst);
  cpu->reg_rs(reg_rs);
  cpu->reg_out(reg_out);
  cpu->reg_no(reg_no);
  cpu->reg_rw(reg_rw);
  cpu->ex_id_forward(ex_id_forward);
  
  // EXCEPTION SIGNALS FROM DATAMEM AND INSTMEM
  cpu->IBUS(IBUS);
  cpu->inst_addrl(inst_addrl);
  cpu->DBUS(DBUS);
  cpu->data_addrl(data_addrl);
  cpu->data_addrs(data_addrs);
  
  // EXCEPTION STATUS VECTOR FROM CPU TO CP0
  cpu->m_wb_ovf_excep(m_wb_ovf_excep);
  cpu->m_wb_syscall_exception(m_wb_syscall_exception);
  cpu->m_wb_illegal_instruction(m_wb_illegal_instruction);
  cpu->m_wb_inst_addrl(m_wb_inst_addrl);		// disaligned address in instmem during fetch stage
  cpu->m_wb_IBUS(m_wb_IBUS);				//page fault in instmem
  cpu->m_wb_data_addrl(m_wb_data_addrl);		//disaligned address in datamem during  load instruction
  cpu->m_wb_data_addrs(m_wb_data_addrs);		//disaligned address in datamem during store instruction
  cpu->m_wb_DBUS(m_wb_DBUS);				//page fault in instmem
  cpu->m_wb_dataaddr(m_wb_dataaddr);
  cpu->m_wb_instaddr_s(m_wb_instaddr);
  cpu->interrupt_signal(interrupt_signal);
  cpu->m_wb_interrupt_signal(m_wb_interrupt_signal);
  cpu->enable_interrupt(enable_interrupt);
  cpu->enable_kernel_mode(enable_kernel_mode);
  
  co0 = new cp0("cp0_module");
  co0->in_clk(in_clk);
  co0->reset(reset);
  // to IF stage
  co0->new_pc(new_pc);
  co0->load_epc(load_epc);
  // to/from ID stage
  co0->pc_out(pc_out);
  co0->pc_in(pc_in);
  co0->id_ex_datarw(id_ex_datarw);
  co0->id_ex_datareq(id_ex_datareq);
  co0->id_branch(id_branch);
  co0->id_ctrl(id_ctrl);
  // co0->inst_break(inst_break);
  // co0->inst_syscall(inst_syscall);
  // to ID stage
  co0->cp0_inst(cp0_inst);
  co0->reg_no(reg_no);
  co0->reg_rw(reg_rw);
  co0->reg_out(reg_out);
  // from ID stage
  co0->reg_rs(reg_rs);
  // from EX stage
  co0->ex_alu(ex_id_forward);
 
  // to EX stage
  co0->addr_err(addr_err);
  // to all stages
  co0->x_insthold(insthold); // input to cp0
  co0->insthold(x_insthold);     // output from cp0*/
  
  // EXCEPTION STATUS VECTOR FROM CPU TO CP0
  co0->m_wb_inst_addrl(m_wb_inst_addrl);	// disaligned address in instmem during fetch stage
  co0->m_wb_IBUS(m_wb_IBUS);			//page fault in instmem
  co0->m_wb_data_addrl(m_wb_data_addrl);	//disaligned address in datamem during  load instruction
  co0->m_wb_data_addrs(m_wb_data_addrs);	//disaligned address in datamem during store instruction
  co0->m_wb_DBUS(m_wb_DBUS);			//page fault in instmem
  co0->m_wb_syscall_exception(m_wb_syscall_exception);
  co0->m_wb_illegal_instruction(m_wb_illegal_instruction);
  co0->m_wb_ovf_excep(m_wb_ovf_excep);
  co0->m_wb_dataaddr(m_wb_dataaddr);
  co0->m_wb_instaddr(m_wb_instaddr);
  co0->m_wb_interrupt_signal(m_wb_interrupt_signal);
  co0->enable_interrupt(enable_interrupt);
  co0->enable_kernel_mode(enable_kernel_mode);
  
}

