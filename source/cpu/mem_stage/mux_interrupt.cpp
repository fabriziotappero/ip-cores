#include "mux_interrupt.h"

void mux_interrupt::do_mux_interrupt()
{
	#ifdef _MULT_PIPELINE_
	   if(hold_pipe.read() == 0)
	   {   
	      if(SEL.read() == SC_LOGIC_1)
	         OUT.write(IN_A.read());
	      else
	         OUT.write(IN_B.read());
	   }  
	   else
	      OUT.write(IN_B.read());
	#else
	      if(SEL.read() == SC_LOGIC_1)
	         OUT.write(IN_A.read());
	      else
	         OUT.write(IN_B.read());
	#endif
}
