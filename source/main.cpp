//
// $Id: main.cpp,v 1.1 2006-01-25 16:57:56 igorloi Exp $
//
#include <systemc.h>
#include "top_debug.h"
#include "./constants/config.h"

int sc_main(int argc, char *argv[])
{
  sc_clock clk("clock", 20, SC_NS);
  
  if (argc == 1)
    {
      cout << "Usage:" << endl;
      cout << argv[0] << " <bin-file> [runlength (ns)]" << endl;
      return 0;
    }

   
   // Istanzio il modulo top level
   top_debug *debug_level;
   debug_level = new top_debug("debug_level", argv[1]);
   debug_level->in_clk(clk.signal());
   

  // Trace file - VCD format...
  sc_trace_file * trace_file;
  trace_file = sc_create_vcd_trace_file("main.trace");

#ifdef SIGNAL_SC_CPU
  sc_trace(trace_file, debug_level->top_level->in_clk, "clk");
  sc_trace(trace_file, debug_level->top_level->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->instaddr, "instaddr");
  sc_trace(trace_file, debug_level->top_level->instdataread, "instdataread");
  sc_trace(trace_file, debug_level->top_level->instreq, "instreq");
  sc_trace(trace_file, debug_level->top_level->instrw, "instrw");
  sc_trace(trace_file, debug_level->top_level->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->dataaddr, "dataaddr");
  sc_trace(trace_file, debug_level->top_level->dataread_m_dec, "dataread_m_dec");
  sc_trace(trace_file, debug_level->top_level->dataread_dec_cpu, "dataread_dec_cpu");
  sc_trace(trace_file, debug_level->top_level->datawrite, "datawrite");
  sc_trace(trace_file, debug_level->top_level->datareq, "datareq");
  sc_trace(trace_file, debug_level->top_level->datarw, "datarw");
  sc_trace(trace_file, debug_level->top_level->databs, "databs");
  sc_trace(trace_file, debug_level->top_level->datahold, "datahold");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->enable_pc, "enable_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->enable_fetch, "enable_fetch");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->enable_decode, "enable_decode");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->enable_execute, "enable_execute");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->enable_memstage, "enable_memstage");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_exception, "if_exception");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id_exception, "id_exception");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex_exception, "ex_exception");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem_exception, "mem_exception");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->wb_exception, "wb_exception");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->DBUS, "DBUS");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->data_addrl, "data_addrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->data_addrl, "data_addrs");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_ovf_excep, "ex_m_ovf_excep");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_syscall_exception, "ex_m_syscall_exception");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_illegal_instruction, "ex_m_illegal_instruction");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_inst_addrl, "ex_m_inst_addrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_IBUS, "ex_m_IBUS");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_id_instaddr, "if_id_instaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id_ex_instaddr, "id_ex_instaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex_m_instaddr, "ex_m_instaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->m_wb_instaddr, "m_wb_instaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->m_wb_dataaddr, "m_wb_dataaddr");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cause, "cause");
  sc_trace(trace_file, debug_level->top_level->risc->co0->check_excep, "check_excep");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_r->Temp_Status_Register, "cp0_r.Temp_Status_Register");
  sc_trace(trace_file, debug_level->top_level->risc->co0->to_EPC, "to_EPC");
  sc_trace(trace_file, debug_level->top_level->risc->co0->to_BadVAddr, "to_BadVAddr");
  //CP0 REGISTERS
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_r->cp0regs[8] , "cp0_regs[8]");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_r->cp0regs[14], "cp0_regs[14]");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_r->cp0regs[13], "cp0_regs[13]");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_r->cp0regs[12], "cp0_regs[12]");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->insthold, "sspc.insthold");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->new_pc, "sspc.new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->load_epc, "sspc.load_epc");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->check_excep, "sspc.check_excep");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->currentstate, "sspc.currentstate");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->nextstate, "sspc.nextstate");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->x_insthold, "sspc.x_insthold");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->in_clk, "sspc.in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->cp0_inst, "sspc.cp0_inst");
  sc_trace(trace_file, debug_level->top_level->risc->co0->sspc->EPC_FOR_RFE, "sspc.EPC_FOR_RFE");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_mux_fw2, "id.id_mux_fw2");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_sign_extend , "id.id_sign_extend");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->interrupt_signal, "interrupt_signal");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->interrupt_signal_out, "interrupt_signal_out");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->reg_mem1->datahold, "red_mem.datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->reg_mem1->insthold, "reg_mem.insthold");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->m_wb_interrupt_signal, "m_wb_interrupt_signal");
  sc_trace(trace_file, debug_level->top_level->risc->co0->excp->to_SR, "excp.to_SR");;
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_reg1, "id_reg1");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_reg2, "id_reg2");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->rs, "rs");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->rt, "rt");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage0, "ex.stage0");
  #ifdef  _MULT_PIPELINE_
     #if(DEPTH_MULT_PIPE == 1)
        sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage1, "ex.stage1");
     #else
        #if(DEPTH_MULT_PIPE == 2)
           sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage1, "ex.stage1");
	   sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage2, "ex.stage2");
        #else
           #if(DEPTH_MULT_PIPE == 3)
              sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage1, "ex.stage1");
	      sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage2, "ex.stage2");
	      sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage3, "ex.stage3");
           #else
	      #if(DEPTH_MULT_PIPE == 4)
                 sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage1, "ex.stage1");
	         sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage2, "ex.stage2");
		 sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage3, "ex.stage3");
		 sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->stage4, "ex.stage4");
              #endif
	   #endif
        #endif
     #endif
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->fsm1->ready, "fsm.ready");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->fsm1->current_state, "fsm.current_state");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->fsm1->hold_pipe, "fsm.hold_pipe");
  #endif
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->hi, "ex.hi");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->lo, "ex.lo");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_id_inst, "cpu.if_id_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id_ex_inst, "cpu.id_ex_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex_mem_inst, "cpu.ex_mem_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem_wb_inst, "cpu.mem_wb_inst");
  
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu_function, "ex.id_ex_alu_function");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu_opcode, "ex.id_ex_alu_opcode");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_function, "id.id_function");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_opcode, "id.id_opcode");
#endif

#ifdef SIGNAL_DATAMEM
  // MEMORY3
  sc_trace(trace_file, debug_level->top_level->datamem->memaddr, "datamem.dataaddr");
  sc_trace(trace_file, debug_level->top_level->datamem->memdataread, "datamem.dataread");
  sc_trace(trace_file, debug_level->top_level->datamem->memdatawrite, "datamem.datawrite");
  sc_trace(trace_file, debug_level->top_level->datamem->memreq, "datamem.datareq");
  sc_trace(trace_file, debug_level->top_level->datamem->memrw, "datamem.datarw");
  
  sc_trace(trace_file, debug_level->top_level->datamem->addrl, "data_addrl");
  sc_trace(trace_file, debug_level->top_level->datamem->addrs, "data_addrs");
  sc_trace(trace_file, debug_level->top_level->datamem->page_fault, "DBUS");
  
#endif

#ifdef SIGNAL_PC_STAGE
  // PC State
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->datahold, "datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->pc_in, "pc_in");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->pc_out, "pc_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instaddr, "instaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instdatawrite, "instdatawrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instreq, "instreq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instrw, "instrw");
#endif

#ifdef SIGNAL_IF_STAGE
  // IF State
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->datahold, "datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->pc_out, "pc_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_new_pc, "id_new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_jmp_tar, "id_jmp_tar");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_ctrl, "id_ctrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_branch, "id_branch");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->pc_in, "pc_in");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->instdataread, "instdataread");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_inst, "if_id_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_next_pc, "if_id_next_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->new_pc, "new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->load_epc, "load_epc");
#endif

#ifdef SIGNAL_ID_STAGE
  // ID Stage
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->datahold, "datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->if_id_next_pc, "if_id_next_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->if_id_inst, "if_id_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_jmp_tar, "id_jmp_tar");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_new_pc, "id_new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ctrl, "id_ctrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_branch, "id_branch");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_alu1, "id_ex_alu1");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_alu2, "id_ex_alu2");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_datastore, "id_ex_datastore");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_alu_ctrl, "id_alu_ctrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_equal, "id_ex_equal");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_byteselect, "id_ex_byteselect");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_bssign, "id_ex_bssign");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_alu_sa, "id_ex_alu_sa");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_datareq, "id_ex_datareq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_datarw, "id_ex_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_memtoreg, "id_ex_memtoreg");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_writeregister_out, "id_ex_writeregister_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_regwrite_out, "id_ex_regwrite_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_m_writeregister, "id_ex_m_writeregister");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_m_wb_writeregister, "id_ex_m_wb_writeregister");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_m_regwrite, "id_ex_m_regwrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->id_ex_m_wb_regwrite, "id_ex_m_wb_regwrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->ex_id_forward, "ex_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->m_id_forward, "m_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->wb_id_forward, "wb_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->cp0_inst, "cp0_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->cp0_reg_no, "cp0_reg_no");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->cp0_reg_rw, "cp0_reg_rw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->cp0_reg_rs, "cp0_reg_rs");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->cp0_reg_out, "cp0_reg_out");
  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[1], "$1");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[2], "$2");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[3], "$3");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[4], "$4");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[5], "$5");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[6], "$6");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[7], "$7");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[8], "$8");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[9], "$9");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[10], "$10");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[11], "$11");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[12], "$12");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[13], "$13");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[14], "$14");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[15], "$15");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[16], "$16");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[17], "$17");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[18], "$18");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[19], "$19");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[20], "$20");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[21], "$21");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[22], "$22");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[23], "$23");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[24], "$24");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[25], "$25");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[26], "$26");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[27], "$27");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[28], "$28");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[29], "$29");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[30], "$30");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->localreg->r[31], "$31");

#endif

#ifdef SIGNAL_EX_STAGE
  // EX Stage
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->datahold, "datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu1, "id_ex_alu1");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu2, "id_ex_alu2");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_datastore, "id_ex_datastore");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu_ctrl, "id_ex_alu_ctrl");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_equal, "id_ex_equal");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_byteselect, "id_ex_byteselect");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_bssign, "id_ex_bssign");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_alu_sa, "id_ex_alu_sa");

  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_datareq, "id_ex_datareq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_datarw, "id_ex_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_memtoreg, "id_ex_memtoreg");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_writeregister_out, "id_ex_writeregister_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_regwrite_out, "id_ex_regwrite_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_writeregister, "id_ex_m_writeregister");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_regwrite, "id_ex_m_regwrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_datareq, "id_ex_m_datareq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_datarw, "id_ex_m_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_datastore, "id_ex_m_datastore");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->ex_m_alu, "ex_m_alu");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_memtoreg, "id_ex_m_memtoreg");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->ex_id_forward, "ex_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_byteselect, "id_ex_m_byteselect");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->id_ex_m_bssign, "id_ex_m_bssign");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->ovf_excep, "ovf_excep");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->addr_err, "addr_err");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->lo, "multiply.lo");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->ex->multiply1->hi, "multiply.hi");
  
  
#endif

#ifdef SIGNAL_MEM_STAGE
  // MEM Stage
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->insthold, "insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->datahold, "datahold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_datareq, "id_ex_m_datareq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_datarw, "id_ex_m_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_datastore, "id_ex_m_datastore");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->ex_m_alu, "ex_m_alu");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_memtoreg, "id_ex_m_memtoreg");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_byteselect, "id_ex_m_byteselect");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_bssign, "id_ex_m_bssign");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->dataread, "dataread");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->datawrite, "datawrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->dataaddr, "dataaddr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->datareq, "datareq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->datarw, "datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->databs, "databs");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_writeregister, "id_ex_m_writeregister");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_regwrite, "id_ex_m_regwrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_wb_writeregister, "id_ex_m_wb_writeregister");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->m_id_forward, "m_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->wb_id_forward, "wb_id_forward");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_store, "id_store");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->mem->id_ex_m_wb_regwrite, "id_ex_m_wb_regwrite");
  
  
#endif

#ifdef SIGNAL_CP0
  // cp0
  sc_trace(trace_file, debug_level->top_level->risc->co0->in_clk, "in_clk");
  sc_trace(trace_file, debug_level->top_level->risc->co0->reset, "reset");
  sc_trace(trace_file, debug_level->top_level->risc->co0->pc_out, "pc_out");
  sc_trace(trace_file, debug_level->top_level->risc->co0->pc_in, "pc_in");
  sc_trace(trace_file, debug_level->top_level->risc->co0->id_ex_datarw, "id_ex_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->co0->id_ex_datareq, "id_ex_datareq");
  sc_trace(trace_file, debug_level->top_level->risc->co0->id_branch, "id_branch");
  sc_trace(trace_file, debug_level->top_level->risc->co0->id_ctrl, "id_ctrl");
  sc_trace(trace_file, debug_level->top_level->risc->co0->new_pc, "new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->co0->load_epc, "load_epc");
  sc_trace(trace_file, debug_level->top_level->risc->co0->m_wb_ovf_excep, "m_wb_ovf_excep");
  sc_trace(trace_file, debug_level->top_level->risc->co0->ex_alu, "ex_alu");
  sc_trace(trace_file, debug_level->top_level->risc->co0->addr_err, "addr_err");
  sc_trace(trace_file, debug_level->top_level->risc->co0->cp0_inst, "cp0_inst");

  sc_trace(trace_file, debug_level->top_level->risc->co0->x_insthold, "x_insthold");
  sc_trace(trace_file, debug_level->top_level->risc->co0->insthold, "insthold");

  sc_trace(trace_file, debug_level->top_level->risc->co0->reg_no, "reg_no");
  sc_trace(trace_file, debug_level->top_level->risc->co0->reg_rw, "reg_rw");
  sc_trace(trace_file, debug_level->top_level->risc->co0->reg_rs, "reg_rs");
  sc_trace(trace_file, debug_level->top_level->risc->co0->reg_out, "reg_out");
#endif

#ifdef ONEHOT_DEBUG
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_jalr, "onehot_debug.inst_jalr");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_addiu, "onehot_debug.inst_addiu");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_lw, "onehot_debug.inst_lw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_mtc0, "onehot_debug.inst_mtc0");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_mfc0, "onehot_debug.inst_mfc0");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_nop, "onehot_debug.inst_nop");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_sw, "onehot_debug.inst_sw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->id->inst_wait, "onehot_debug.inst_wait");
#endif

#ifdef SIGNAL_INTERRUPT

  // remaining inputs/outputs
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->pc_out, "cp0.pc_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->pc_in, "cp0.pc_in");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->id_ex_datarw, "cp0.id_ex_datarw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->id_ex_datareq, "cp0.id_ex_datareq");
  /*
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->id_branch, "cp0.id_branch");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->id_ctrl, "cp0.id_ctrl");
  */
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->new_pc, "cp0.new_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->load_epc, "cp0.load_epc");
  /*
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->ovf_excep, "cp0.ovf_excep");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->addr_err, "cp0.addr_err");
  */
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->cp0_inst, "cp0.cp0_inst");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->x_insthold, "cp0.x_insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->insthold, "cp0.insthold");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->reg_no, "cp0.reg_no");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->reg_rw, "cp0.reg_rw");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->reg_rs, "cp0.reg_rs");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->reg_out, "cp0.reg_out");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->co0->currentstate, "cp0.currentstate");

 
#endif

  /////////////////////////////////////////////////////////////////
  // Start the simulation
  /////////////////////////////////////////////////////////////////

  cout << "--->Start<---" << endl;
  sc_report::suppress_warnings(true);
  
  int runtime;
  if (argc == 3)
    runtime = atoi(argv[2]);
  else
    runtime = -1;

  sc_start(runtime);
  
  
  sc_close_vcd_trace_file(trace_file);

  return 0;
}
