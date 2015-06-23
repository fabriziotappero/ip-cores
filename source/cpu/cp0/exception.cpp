#include "exception.h" 

void exception::compute_cause()
{
	sc_lv<5>  cause_5;
	sc_lv<32> cause_32;

	if(m_wb_inst_addrl.read() == SC_LOGIC_1) 
	   cause_5 = "00100" ;
	else
	   if(m_wb_IBUS.read() == SC_LOGIC_1) 
	      cause_5 = "00110" ;
	   else
	      if(m_wb_DBUS.read() == SC_LOGIC_1) 
	         cause_5 = "00111" ;
	      else
	         if(m_wb_data_addrl.read() == SC_LOGIC_1) 
	            cause_5 = "00100" ;
		 else
	   	    if(m_wb_data_addrs.read() == SC_LOGIC_1) 
		       cause_5 = "00101" ;
		    else
			if(m_wb_syscall_exception.read() == SC_LOGIC_1) 
			   cause_5 = "01000" ;
			else
			   if(m_wb_illegal_instruction.read() == SC_LOGIC_1)	// RI 
			      cause_5 = "01010";
			   else
			      if(m_wb_ovf_excep.read() == SC_LOGIC_1) 
			        cause_5 = "01100";
			      else
			         if(m_wb_interrupt_signal.read() == SC_LOGIC_1) 
			           cause_5 = "00000";
				 else
			            cause_5 = "00000";
	
	cause_32 = WORD_ZERO;
	cause_32.range(6,2) = cause_5;
	cause.write(cause_32); 
}

void exception::check_for_exception()
{
	if((m_wb_IBUS.read() == SC_LOGIC_1)          || 
	   (m_wb_inst_addrl.read() == SC_LOGIC_1)    ||
	   (m_wb_syscall_exception.read() == SC_LOGIC_1)   ||
	   (m_wb_illegal_instruction.read() == SC_LOGIC_1) ||
	   (m_wb_ovf_excep.read() == SC_LOGIC_1) ||
	   (m_wb_DBUS.read() == SC_LOGIC_1)    ||
	   (m_wb_data_addrl.read() == SC_LOGIC_1)   ||
	   (m_wb_data_addrs.read() == SC_LOGIC_1)   ||
	   (m_wb_interrupt_signal.read() == SC_LOGIC_1))
	   check_excep.write(true);
	else
	   check_excep.write(false);
}

void exception::check_for_interrupt()
{
	/*if(interrupt_signal.read() == SC_LOGIC_1)
	   interrupt_exception.write(SC_LOGIC_1);
	else
	   interrupt_exception.write(SC_LOGIC_0);*/
}

void exception::check_for_Page_fault()
{
	if((cause.read()).range(6,2) == "00110" )
	   to_BadVAddr.write(m_wb_instaddr.read());
	else
	   if((cause.read()).range(6,2) == "00111" )
	      to_BadVAddr.write(m_wb_dataaddr.read());
	   else
	      to_BadVAddr.write(0);
}

void exception::save_EPC()
{
	if(check_excep.read() == SC_LOGIC_1)
	   to_EPC.write(m_wb_instaddr.read());
	else
	     to_EPC.write(0);
}

//sensitive << m_wb_interrupt_signal;
//sensitive << cp0_inst << reset;
void exception::handling_status_register()
{
	if(reset.read() == true )
	   to_SR = SC_LOGIC_0;
	else
	{
	   if(m_wb_interrupt_signal.read() == SC_LOGIC_1)
	      to_SR = SC_LOGIC_1;
	   else 
	      if(cp0_inst.read() == CP0_ERET)
	         to_SR = SC_LOGIC_0;
	      else;
	}
	
}
