#include "reg_ex.h"

void reg_ex::do_reg_ex()
{
	if(reset.read() == true)
	{
		ex_m_alu.write(WORD_ZERO);
		id_ex_m_datastore.write(WORD_ZERO);
	
		id_ex_m_datareq.write(SC_LOGIC_0);
		id_ex_m_datarw.write(SC_LOGIC_0);
	
		id_ex_m_memtoreg.write(SC_LOGIC_0);
		id_ex_m_writeregister.write("00000");
		id_ex_m_regwrite.write(SC_LOGIC_0);
	
		id_ex_m_byteselect.write("00");
		id_ex_m_bssign.write(SC_LOGIC_0); 
		
		out_lo.write(WORD_ZERO);
		out_hi.write(WORD_ZERO);
		
		// PIPELINED EXCEPTION SIGNALS
		ex_m_IBUS.write(SC_LOGIC_0);
		ex_m_inst_addrl.write(SC_LOGIC_0);
		ex_mem_inst.write(WORD_ZERO);
		ex_m_syscall_exception.write(SC_LOGIC_0);
		ex_m_illegal_instruction.write(SC_LOGIC_0);
		ex_m_ovf_excep.write(SC_LOGIC_0);
		ex_m_instaddr.write(0);
		
	}
	else
		if((datahold.read() == false) && (insthold.read() == false) && (enable_execute.read() == SC_LOGIC_1))
		{
			ex_m_alu.write(ex_alu_s.read());
			id_ex_m_datastore.write(id_ex_datastore.read());
			id_ex_m_datarw.write(id_ex_datarw.read());
			id_ex_m_memtoreg.write(id_ex_memtoreg.read());
			id_ex_m_writeregister.write(id_ex_writeregister_out.read());
	
			id_ex_m_byteselect.write(id_ex_byteselect.read());
			id_ex_m_bssign.write(id_ex_bssign.read());
			
			out_lo.write(in_lo.read());
			out_hi.write(in_hi.read());
			
			ex_m_IBUS.write(id_ex_IBUS.read());
			ex_m_inst_addrl.write(id_ex_inst_addrl.read());
			ex_mem_inst.write(id_ex_inst.read());
			ex_m_syscall_exception.write(id_ex_syscall_exception.read());
			ex_m_illegal_instruction.write(id_ex_illegal_instruction.read());
			ex_m_ovf_excep.write(ovf_excep.read());
			ex_m_instaddr.write(id_ex_instaddr.read());	
		// Address Error Exception
			if (addr_err.read() == SC_LOGIC_1)
			{
				#ifdef _DEBUG_
				cout << " ***************** Address Error Exception ****************** " << endl;
				#endif
				id_ex_m_datareq.write(SC_LOGIC_0);  // NB! No read/write
				id_ex_m_regwrite.write(SC_LOGIC_0); // NB! No register write
			}
			else
			{
				id_ex_m_datareq.write(id_ex_datareq.read());
				id_ex_m_regwrite.write(id_ex_regwrite_out.read());
			}
		
		}
		else
		   if((datahold.read() == false) && (insthold.read() == false) && (enable_execute.read() == SC_LOGIC_0))
		   {
		        ex_m_alu.write(WORD_ZERO);
			id_ex_m_datastore.write(WORD_ZERO);
			id_ex_m_datareq.write(SC_LOGIC_0);
			id_ex_m_datarw.write(SC_LOGIC_0);
			id_ex_m_memtoreg.write(SC_LOGIC_0);
			id_ex_m_writeregister.write("00000");
			id_ex_m_regwrite.write(SC_LOGIC_0);
			id_ex_m_byteselect.write("00");
			id_ex_m_bssign.write(SC_LOGIC_0); 
			out_lo.write(WORD_ZERO);
			out_hi.write(WORD_ZERO);
			
			ex_m_IBUS.write(id_ex_IBUS.read());
			ex_m_inst_addrl.write(id_ex_inst_addrl.read());
			ex_mem_inst.write(id_ex_inst.read());
			ex_m_syscall_exception.write(id_ex_syscall_exception.read());
			ex_m_illegal_instruction.write(id_ex_illegal_instruction.read());
			ex_m_ovf_excep.write(ovf_excep.read());
			ex_m_instaddr.write(id_ex_instaddr.read());
		   }
		   else;
		
}
