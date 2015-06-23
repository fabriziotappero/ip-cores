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
  sc_trace(trace_file, debug_level->top_level->risc->cpu->m_wb_interrupt_signal, "m_wb_interrupt_signal");
  //sc_trace(trace_file, debug_level->top_level->risc->co0->excp->m_wb_interrupt_signal, "excp.m_wb_interrupt_signal"); 

  
  //PC_STAGE
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->enable_pc, 	"pc.enable_pc");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->pc_in, 		"pc.pc_in");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->pc_out, 		"pc.pc_out");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instaddr, 	"pc.instaddr");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instdatawrite, 	"pc.instdatawrite");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instreq, 		"pc.instreq");
  sc_trace(trace_file, debug_level->top_level->risc->cpu->pc->instrw, 		"pc.instrw");
  
  //IF_STAGE
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->pc_in, 		"if_s.pc_in");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->pc_out, 	"if_s.pc_out");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_new_pc, 	"if_s.id_new_pc");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_jmp_tar, 	"if_s.id_jmp_tar");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_ctrl, 	"if_s.id_ctrl");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->id_branch, 	"if_s.id_branch");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->instdataread, 	"if_s.instdataread");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_inst, 	"if_s.if_id_inst");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_next_pc, 	"if_s.if_id_next_pc");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->new_pc;, 	"if_s.new_pc;");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->load_epc, 	"if_s.load_epc");  
  sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->IBUS, 		"if_s.IBUS");  
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->inst_addrl,	"if_s.inst_addrl");  
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_IBUS, 	"if_s.if_id_IBUS");  
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_id_inst_addrl, "if_s.if_id_inst_addrl");  
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->pc_if_instaddr, 	"if_s.pc_if_instaddr");
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_exception, 	"if_s.if_exception");
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->enable_fetch, 	"if_s.enable_fetch");
 sc_trace(trace_file, debug_level->top_level->risc->cpu->if_s->if_pc_add, 	"if_s.if_pc_add");
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  