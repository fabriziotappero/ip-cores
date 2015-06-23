#include "sign_extend.h"

void sign_extend::do_sign_extend()
{
	sc_lv<32> inst = if_id_inst.read();
	sc_lv<2> iec = id_extend_ctrl.read(); 

	if( iec == "00")
	   if(inst[15] == SC_LOGIC_1)
		id_sign_extend = (HALFWORD_ONE,inst.range(15,0));
	   else
		id_sign_extend = (HALFWORD_ZERO,inst.range(15,0));
  
	else 
	   if( iec == "01")
		id_sign_extend = (HALFWORD_ZERO,inst.range(15,0));
	   else
		if( iec == "10")
		   id_sign_extend = (inst.range(15,0),HALFWORD_ZERO);
		else
		   id_sign_extend = WORD_ZERO;

} 
