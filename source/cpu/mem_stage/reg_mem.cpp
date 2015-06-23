#include "reg_mem.h"

void reg_mem::do_reg_mem()
{
   if(reset.read() == true)
   {
	wb_id_forward.write(WORD_ZERO);
	id_ex_m_wb_regwrite.write(SC_LOGIC_0);
	id_ex_m_wb_writeregister.write("00000");
	
	m_wb_IBUS.write(SC_LOGIC_0);
	m_wb_inst_addrl.write(SC_LOGIC_0);
	m_wb_syscall_exception.write(SC_LOGIC_0);
	m_wb_illegal_instruction.write(SC_LOGIC_0);
	m_wb_ovf_excep.write(SC_LOGIC_0);
	m_wb_DBUS.write(SC_LOGIC_0);
	m_wb_data_addrl.write(SC_LOGIC_0);
	m_wb_data_addrs.write(SC_LOGIC_0);
	m_wb_instaddr.write(0);
		mem_wb_inst.write(WORD_ZERO);
	m_wb_dataaddr.write(0);
	m_wb_interrupt_signal.write(false);
   }
   else
   {
      m_wb_interrupt_signal.write(interrupt_signal.read()); 
      
      if((datahold.read() == false) && (insthold.read() == false) && (enable_memstage.read() == SC_LOGIC_1))
      {
	  wb_id_forward.write(id_store.read());
	  id_ex_m_wb_regwrite.write(id_ex_m_regwrite.read());
	  id_ex_m_wb_writeregister.write(id_ex_m_writeregister.read());
	  
	  m_wb_IBUS.write(ex_m_IBUS.read());
	  m_wb_inst_addrl.write(ex_m_inst_addrl.read());
	  m_wb_syscall_exception.write(ex_m_syscall_exception.read());
	  m_wb_illegal_instruction.write(ex_m_illegal_instruction.read());
	  m_wb_ovf_excep.write(ex_m_ovf_excep.read());
	  m_wb_DBUS.write(DBUS.read());
	  m_wb_data_addrl.write(data_addrl.read());
	  m_wb_data_addrs.write(data_addrs.read());
	  m_wb_instaddr.write(ex_m_instaddr.read());
	  mem_wb_inst.write(ex_mem_inst.read());
	  m_wb_dataaddr.write(ex_m_dataaddr.read());
	  //m_wb_interrupt_signal.write(interrupt_signal.read());   
      }
      else
         if((datahold.read() == false) && (insthold.read() == false) && (enable_memstage.read() == SC_LOGIC_0))
         {
	  wb_id_forward.write(WORD_ZERO);
	  id_ex_m_wb_regwrite.write(SC_LOGIC_0);
	  id_ex_m_wb_writeregister.write("00000");
	  
	  m_wb_IBUS.write(ex_m_IBUS);
	  m_wb_inst_addrl.write(ex_m_inst_addrl.read());
	  m_wb_syscall_exception.write(ex_m_syscall_exception.read());
	  m_wb_illegal_instruction.write(ex_m_illegal_instruction.read());
	  m_wb_ovf_excep.write(ex_m_ovf_excep.read());
	  m_wb_DBUS.write(DBUS.read());
	  m_wb_data_addrl.write(data_addrl.read());
	  m_wb_data_addrs.write(data_addrs.read());
	  m_wb_instaddr.write(ex_m_instaddr.read());
	  mem_wb_inst.write(ex_mem_inst.read());
	  m_wb_dataaddr.write(ex_m_dataaddr.read());
	  //m_wb_interrupt_signal.write(interrupt_signal.read());
	 }
   }
} 
