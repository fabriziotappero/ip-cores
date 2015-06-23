#include "reg_id.h"

void reg_id::do_reg_id()
{
  if(reset.read() == true)
    {
      id_ex_alu1.write(WORD_ZERO);
      id_ex_alu2.write(WORD_ZERO);
      id_ex_datastore.write(WORD_ZERO);
      id_ex_alu_ctrl.write("000000");
      id_ex_alu_sa.write("00000");
      id_ex_equal.write(SC_LOGIC_0);
      id_ex_datareq.write(SC_LOGIC_0);
      id_ex_datarw.write(SC_LOGIC_0);
      id_ex_memtoreg.write(SC_LOGIC_0);
      id_ex_writeregister_out.write("00000");
      id_ex_regwrite_out.write(SC_LOGIC_0);
      id_ex_writeregister.write("00000");
      id_ex_regwrite.write(SC_LOGIC_0);
      id_ex_byteselect.write("00");
      id_ex_bssign.write(SC_LOGIC_0);
      id_ex_inst.write(WORD_ZERO);
      
      // EXCEPTION SIGNALS
      id_ex_IBUS.write(SC_LOGIC_0);
      id_ex_inst_addrl.write(SC_LOGIC_0);
      id_ex_syscall_exception.write(SC_LOGIC_0);
      id_ex_illegal_instruction.write(SC_LOGIC_0);
      id_ex_instaddr.write(0);
      id_ex_alu_opcode.write("000000");
      id_ex_alu_function.write("000000");
    }
  else
    if((datahold.read() == false) && (insthold.read() == false) && (enable_decode.read() == SC_LOGIC_1))
      {
        id_ex_alu1.write(id_alu1.read());
	id_ex_alu2.write(id_alu2.read());
	id_ex_datastore.write(id_mux_fw2.read());
	id_ex_alu_ctrl.write(id_alu_ctrl.read());
	id_ex_alu_sa.write(id_alu_sa.read());
	id_ex_equal.write(id_equal.read());
	id_ex_datareq.write(id_datareq.read());
	id_ex_datarw.write(id_datarw.read());
	id_ex_memtoreg.write(id_memtoreg.read());
	id_ex_writeregister_out.write(id_writeregister.read());
	id_ex_writeregister.write(id_writeregister.read());
	id_ex_regwrite_out.write(id_regwrite.read());
	id_ex_regwrite.write(id_regwrite.read());
	id_ex_byteselect.write(id_byteselect.read());
	id_ex_bssign.write(id_bssign.read());
	id_ex_inst.write(if_id_inst.read());
	// EXCEPTION SIGNALS
	id_ex_IBUS.write(if_id_IBUS.read());
	id_ex_inst_addrl.write(if_id_inst_addrl.read());
	id_ex_syscall_exception.write(syscall_exception.read());
	id_ex_illegal_instruction.write(illegal_instruction.read());
	id_ex_instaddr.write(if_id_instaddr);
	
	id_ex_alu_opcode.write(id_opcode.read());
        id_ex_alu_function.write(id_function.read());
      }
    else
       if((datahold.read() == false) && (insthold.read() == false) && (enable_decode.read() == SC_LOGIC_0))
       {
	   id_ex_alu1.write(WORD_ZERO);
	   id_ex_alu2.write(WORD_ZERO);
	   id_ex_datastore.write(WORD_ZERO);
	   id_ex_alu_ctrl.write("000000");
	   id_ex_alu_sa.write("00000");
	   id_ex_equal.write(SC_LOGIC_0);
	   id_ex_datareq.write(SC_LOGIC_0);
	   id_ex_datarw.write(SC_LOGIC_0);
	   id_ex_memtoreg.write(SC_LOGIC_0);
	   id_ex_writeregister_out.write("00000");
	   id_ex_regwrite_out.write(SC_LOGIC_0);
	   id_ex_writeregister.write("00000");
	   id_ex_regwrite.write(SC_LOGIC_0);
	   id_ex_byteselect.write("00");
	   id_ex_bssign.write(SC_LOGIC_0);
	   
	   id_ex_alu_opcode.write("000000");
           id_ex_alu_function.write("000000");
	   id_ex_IBUS.write(if_id_IBUS.read());
	   id_ex_inst_addrl.write(if_id_inst_addrl.read());
	   id_ex_inst.write(if_id_inst.read());
	   id_ex_syscall_exception.write(syscall_exception.read());
	   id_ex_illegal_instruction.write(illegal_instruction.read());
	   id_ex_instaddr.write(if_id_instaddr);
       }
       else;




}











