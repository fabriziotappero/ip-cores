#include "set_stop_pc.h"

void set_stop_pc::update_state()
{
    if (reset.read() == true)
    {
        currentstate.write(IdLe);
    }
    else
    {
       currentstate.write(nextstate.read());
    }
}

void set_stop_pc::do_set_stop_pc()
{

      // FSM
      switch(currentstate)
	{
	case IdLe:
	{
	   
	   if( check_excep.read() == SC_LOGIC_1 )
	   {
	   	cout << " EXCEPTION " << endl;
		nextstate.write(STATE1);
		new_pc.write(WORD_ZERO);
		load_epc.write(SC_LOGIC_0);
		insthold.write(true);
	   }
	   else
	   	if(cp0_inst.read() == CP0_ERET)
		{
		   cout <<" CPO ERET" << endl;
		   nextstate.write(STATE3);
		   new_pc.write(WORD_ZERO);
		   load_epc.write(SC_LOGIC_0);
		   insthold.write(true);
		}
		else
	          {
		     nextstate.write(IdLe);
		     new_pc.write(WORD_ZERO);
        	     load_epc.write(SC_LOGIC_0);
		     insthold.write(x_insthold.read());
		  }
	}
	break;
	
	case STATE1:
	{   
	   insthold.write(x_insthold.read());
	   new_pc.write(0x00000008);
	   load_epc.write(SC_LOGIC_1);
	   nextstate.write(STATE2); 
	}
	break;
	
	case STATE2:
	{
	   nextstate.write(IdLe);
	   insthold.write(x_insthold.read());
	   new_pc.write(0x00000008);
	   load_epc.write(SC_LOGIC_1);
	}
	break;
	
	case STATE3:
	{
	   insthold.write(x_insthold.read());
	   new_pc.write(EPC_FOR_RFE.read());
	   load_epc.write(SC_LOGIC_1);
	   nextstate.write(IdLe);
	}
	break;
	
	case STATE4:
	{
	   nextstate.write(IdLe);
	   insthold.write(x_insthold.read());
	   new_pc.write(EPC_FOR_RFE.read());
	   load_epc.write(SC_LOGIC_1);
	}
	break;
	  
	default: 
	{
		nextstate.write(IdLe);
		new_pc.write(WORD_ZERO);
		load_epc.write(SC_LOGIC_0);
		insthold.write(x_insthold.read());
	}
	break;
	}
} 
