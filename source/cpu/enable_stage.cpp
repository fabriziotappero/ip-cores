#include "enable_stage.h"

void enable_stage::do_enable_stage()
{
      if(wb_exception.read() == SC_LOGIC_1)
      {
         enable_pc.write(SC_LOGIC_0);
         enable_fetch.write(SC_LOGIC_0);
         enable_decode.write(SC_LOGIC_0);
         enable_execute.write(SC_LOGIC_0);
         enable_memstage.write(SC_LOGIC_0);
      }
      else
	if(mem_exception.read() == SC_LOGIC_1)
	{
	   enable_pc.write(SC_LOGIC_0);
	   enable_fetch.write(SC_LOGIC_0);
	   enable_decode.write(SC_LOGIC_0);
	   enable_execute.write(SC_LOGIC_0);
	   enable_memstage.write(SC_LOGIC_0);
	}
	else 
	   if(ex_exception.read() == SC_LOGIC_1)
	   {
	      enable_pc.write(SC_LOGIC_0);
	      enable_fetch.write(SC_LOGIC_0);
	      enable_decode.write(SC_LOGIC_0);
	      enable_execute.write(SC_LOGIC_0);
	      enable_memstage.write(SC_LOGIC_1);
	   }
	   else 
	      if(id_exception.read() == SC_LOGIC_1)
	      {
	         enable_pc.write(SC_LOGIC_0);
	         enable_fetch.write(SC_LOGIC_0);
	         enable_decode.write(SC_LOGIC_0);
	         enable_execute.write(SC_LOGIC_1);
	         enable_memstage.write(SC_LOGIC_1);
	      }
	      else 
	         if(if_exception.read() == SC_LOGIC_1)
	         {
	            enable_pc.write(SC_LOGIC_0);
	            enable_fetch.write(SC_LOGIC_0);
	            enable_decode.write(SC_LOGIC_1);
	            enable_execute.write(SC_LOGIC_1);
	            enable_memstage.write(SC_LOGIC_1);
	         }
		 else
		    {
		       enable_pc.write(SC_LOGIC_1);
	               enable_fetch.write(SC_LOGIC_1);
	               enable_decode.write(SC_LOGIC_1);
	               enable_execute.write(SC_LOGIC_1);
	               enable_memstage.write(SC_LOGIC_1);
		    }
		 
	   



}
