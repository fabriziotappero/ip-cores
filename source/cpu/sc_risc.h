//
// $Id: sc_risc.h,v 1.1 2006-01-25 17:00:01 igorloi Exp $
//
#ifndef _SC_RISC_H
#define _SC_RISC_H

#include <systemc.h>
#include "../constants/constants.h"
#include "../constants/config.h"
#include "sc_cpu.h"
#include "cp0.h"

SC_MODULE(sc_risc) 
{
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
  sc_in<sc_lv<32> > instdataread;
  sc_out<sc_lv<32> > instdatawrite;
  //! Instruction memory address
  sc_out<sc_uint<32> > instaddr;
  //! Instruction memory request
  sc_out<sc_logic> instreq;
  //! Instruction memory read/write signal. 1 for write. 0 for read.
  sc_out<sc_logic> instrw;
  //! Hold signal from instruction memory
  sc_in<bool> insthold;

  //
  // Data memory interface
  //
  //! Data memory in/out data
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
  
  //INTERRUPT SIGNAL FROM TOP_MODULE
  sc_in<bool>		interrupt_signal;
  sc_signal<bool>	m_wb_interrupt_signal;
  
  //interrupt enable and Kernel_mode or User_mode Signal
  sc_signal<sc_logic>	enable_interrupt;
  sc_signal<sc_logic>	enable_kernel_mode;
  
  //exceptions signal from datamem and instmem
  sc_in<sc_logic> inst_addrl;	// disaligned address in instmem during fetch stage
  sc_in<sc_logic> IBUS;		//page fault in instmem
  sc_in<sc_logic> data_addrl;	//disaligned address in datamem during  load instruction
  sc_in<sc_logic> data_addrs;	//disaligned address in datamem during store instruction
  sc_in<sc_logic> DBUS;		//page fault in datamem
  
  sc_signal<sc_logic> 		m_wb_inst_addrl;	
  sc_signal<sc_logic> 		m_wb_IBUS;		
  sc_signal<sc_logic> 		m_wb_data_addrl;	
  sc_signal<sc_logic> 		m_wb_data_addrs;	
  sc_signal<sc_logic> 		m_wb_DBUS;		
  sc_signal<sc_logic>		m_wb_syscall_exception;		// Syscall
  sc_signal<sc_logic>		m_wb_illegal_instruction;	// illegal instruction
  sc_signal<sc_logic>		m_wb_ovf_excep;			// Overflow
  sc_signal<sc_uint<32> >	m_wb_instaddr;			//victim address in INSTMEM
  sc_signal<sc_uint<32> >	m_wb_dataaddr;			//Victim Address in DATAMEM
  sc_signal<sc_uint<32> >	ex_m_instaddr;		//address of the last non-completed instruction during interrupt
  
  
  // to CP0_STAGE
  sc_signal<sc_lv<32> >		new_pc;
  sc_signal<sc_logic> 		load_epc;
  sc_signal<sc_lv<32> >		pc_in;
  sc_signal<sc_lv<32> >		pc_out;
  sc_signal<sc_logic> 		id_branch;
  sc_signal<sc_logic> 		id_ctrl;
  sc_signal<sc_logic>		id_ex_datarw;
  sc_signal<sc_logic>		id_ex_datareq;

  sc_signal<sc_logic>		addr_err;
  sc_signal<bool>		x_insthold;
  sc_signal<sc_lv<4> >		cp0_inst;
  sc_signal<sc_lv<32> >		reg_rs;
  sc_signal<sc_lv<32> >		reg_out;
  sc_signal<sc_uint<5> >	reg_no;
  sc_signal<sc_logic>		reg_rw;
  sc_signal<sc_lv<32> >		ex_id_forward;
  
  sc_signal<sc_logic> 		interrupt_exception;
  
  sc_cpu *cpu;
  cp0 *co0;
  

  SC_HAS_PROCESS(sc_risc);
  sc_risc (const sc_module_name& name_);
 
};

#endif
