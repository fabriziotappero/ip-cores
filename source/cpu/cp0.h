
//
// $Id: cp0.h,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//

#ifndef _CP0_H
#define _CP0_H

#include <systemc.h>

#include "./cp0/cp0_register.h"
#include "./cp0/exception.h"

#include "./cp0/set_stop_pc.h"

#include "../constants/config.h"
#include "../constants/constants.h"
#include "../constants/cp0constants.h"
#include "../constants/avrconstants.h"
#include "../constants/mipsconstants.h"

SC_MODULE(cp0)
{
  sc_in<bool> in_clk;
  sc_in<bool> reset;

  //! Current instruction address
  /*!
    The current instruction address.
  */
  sc_in<sc_lv<32> > pc_out;
  
  //! Next instrition address
  /*!
    The next instruction address.
    This address can bee the new address after af jump.
  */
  sc_in<sc_lv<32> > pc_in;
  
  //! Data read/write signal, 1 is write
  sc_in<sc_logic> id_ex_datarw;
  
  //! Data req
  /*!
    Data req signal
  */
  sc_in<sc_logic> id_ex_datareq;

  //! Branch signal
  /*!
    Indicate that the instruction is a branch if signal bit is set.
  */
  sc_in<sc_logic> id_branch;
  
  //! Jump signal
  /*!
    Indicate that the instruction is a jump if signal bit is set.
  */
  sc_in<sc_logic> id_ctrl;

  //! Break signal
  /*!
    This signal indicate that a break instruction has occured.
  */
  // sc_in<sc_logic> inst_break;
  
  //! Syscall signal
  /*!
    This signal indicate a syscall instruction has occured.
  */
  // sc_in<sc_logic> inst_syscall;

  //! New pc signal
  /*!
    When an exception occurs, the program counter is loaded with at new value. 
  */
  sc_out<sc_lv<32> > new_pc;

  //! Load EPC in stead of PC?
  /*!
    This signal tells the mux to select new_pc from cp0
   */
  sc_out<sc_logic> load_epc;

  

  //! The data addres - from EX stage
  /*!
    The data addres, which is use to load or store a word.
  */
  sc_in<sc_lv<32> > ex_alu;

  //! Address error indicator to MEM stage
  /*!
    addr_err is raised to prevent a memory action to take place when an
    Address Error Exception occurs
   */
  sc_out<sc_logic> addr_err;

  //! The current cp0 instruction in id_stage (if any)
  /*
    Tells cp0 if the instruction in id_stage is relevant
   */
  sc_in<sc_lv<4> > cp0_inst;

  //! To all stages. Stops the cpu by halting cpu
  sc_in<bool>  x_insthold;
  sc_out<bool> insthold;

  //! Output register no. defined by address in reg_no
  sc_in<sc_uint<5> > reg_no;
  sc_in<sc_logic>    reg_rw;
  sc_in<sc_lv<32> >  reg_rs;
  sc_out<sc_lv<32> > reg_out;
  
  
  // EXCEPTIONS SIGNAL FROM DATAMEM aND INSTMEM
  sc_in<sc_logic> m_wb_inst_addrl;	// disaligned address in instmem during fetch stage
  sc_in<sc_logic> m_wb_IBUS;		//page fault in instmem
  sc_in<sc_logic> m_wb_data_addrl;	//disaligned address in datamem during  load instruction
  sc_in<sc_logic> m_wb_data_addrs;   //disaligned address in datamem during store instruction
  sc_in<sc_logic> m_wb_DBUS;		//page fault in datamem

  // EXCEPTION SIGNAL FROM INSTRUCTION FETCH STAGE  
  sc_in<sc_logic> 	m_wb_illegal_instruction;
  sc_in<sc_logic> 	m_wb_syscall_exception;
  
  // This signal is set to 1 by the ALU when an overflow occurs.
  sc_in<sc_logic> 	m_wb_ovf_excep;
  
  // INTERRUPT SIGNAL 
  sc_in<bool>	m_wb_interrupt_signal;
  
  sc_in<sc_uint<32> > 	m_wb_dataaddr;
  sc_in<sc_uint<32> > 	m_wb_instaddr;
  
    
  sc_signal<sc_lv<32> > 	cause;
  sc_signal<bool> 		check_excep;
  sc_signal<sc_uint<32> >	to_EPC;
  sc_signal<sc_uint<32> >	to_BadVAddr;
  sc_signal<sc_uint<32> >	EPC_FOR_RFE;
  
  //! Old Branch indication
  /*!
    This register is used to store informationen of previous branchs or jumps.
  */
  sc_signal<sc_logic> id_ex_branch_or_jump;

  // 32 registers 32 bit CP0
  sc_signal<sc_lv<32> > cp0regs[32];
  
   sc_out<sc_logic>		enable_interrupt;
   sc_out<sc_logic>		enable_kernel_mode;



  cp0_register *cp0_r;
  exception *excp;
  set_stop_pc *sspc;


  
  SC_CTOR(cp0)
    {

      cp0_r = new cp0_register("cp0_register");
      cp0_r->in_clk(in_clk);
      cp0_r->reset(reset);
      cp0_r->reg_no(reg_no);
      cp0_r->reg_rw(reg_rw);
      cp0_r->reg_rs(reg_rs);
      cp0_r->reg_out(reg_out);
      cp0_r->cause(cause);
      cp0_r->check_excep(check_excep);
      cp0_r->to_EPC(to_EPC);
      cp0_r->to_BadVAddr(to_BadVAddr);
      cp0_r->EPC_FOR_RFE(EPC_FOR_RFE);
      cp0_r->cp0_inst(cp0_inst);
      cp0_r->enable_interrupt(enable_interrupt);
      cp0_r->enable_kernel_mode(enable_kernel_mode);
      cp0_r->insthold(insthold);
      
      excp = new exception("exception");
      excp->in_clk(in_clk);
      excp->reset(reset);
      excp->m_wb_IBUS(m_wb_IBUS);
      excp->m_wb_inst_addrl(m_wb_inst_addrl);
      excp->m_wb_syscall_exception(m_wb_syscall_exception);
      excp->m_wb_illegal_instruction(m_wb_illegal_instruction);
      excp->m_wb_ovf_excep(m_wb_ovf_excep);
      excp->m_wb_DBUS(m_wb_DBUS);
      excp->m_wb_data_addrl(m_wb_data_addrl);
      excp->m_wb_data_addrs(m_wb_data_addrs);
      excp->m_wb_dataaddr(m_wb_dataaddr);
      excp->m_wb_instaddr(m_wb_instaddr);
      excp->cause(cause);
      excp->check_excep(check_excep);
      excp->to_EPC(to_EPC);
      excp->to_BadVAddr(to_BadVAddr);
      excp->m_wb_interrupt_signal(m_wb_interrupt_signal);
      excp->cp0_inst(cp0_inst);
      
      
      sspc = new set_stop_pc("set_stop_pc");
      sspc->in_clk(in_clk);
      sspc->reset(reset);
      sspc->x_insthold(x_insthold);
      sspc->insthold(insthold);
      sspc->pc_in(pc_in);
      sspc->cp0_inst(cp0_inst);
      sspc->new_pc(new_pc);
      sspc->load_epc(load_epc);
      sspc->check_excep(check_excep);
      sspc->EPC_FOR_RFE(EPC_FOR_RFE);
    }
};

#endif
